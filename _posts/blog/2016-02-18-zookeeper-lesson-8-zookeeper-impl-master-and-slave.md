---
layout: post
title: ZooKeeper 技术内幕：利用 ZK 实现主从集群
description: 一个主从集群，要实现哪些基本功能？利用 ZK，如何实现？
published: true
category: zookeeper
---


## 背景

ZK 构建了分布式系统协作的基础设施，提供了`高容错`的`分布式一致性`解决方案。

如何基于 ZK 的基础设施，实现一个主从集群呢？

简单来说，2 个问题：

1. 一个主从集群，需要实现哪些基本功能？
2. 基于 ZK，如何实现这些功能？

## 主从集群：需求分析

主从集群，内部涉及 2 个角色：

1. Master
2. Slave

角色的功能不同：

1. Master：协调 Slave 执行 Task
	* 数量：只能有 1 个
	* 功能：
		* 收集 Client 提交的 Task
		* 收集存活的 Slave
		* 将 Task 分配给 Slave 执行
		* 监控 Task 的执行状态，如果 Task 执行失败，则，重新分配给另一个 Slave 执行
2. Slave：执行 Task
	* 数量：多个
	* 功能：
		* 执行 Task
		* Master 崩溃后，Slave 内推举出新的 Master
3. Client：提交 Task，并等待响应

整体上，分为 2 个阶段：

1. Master 选举阶段：**竞争**，所有 Slave 都参与选举，诞生一个 Master
2. Slave 工作阶段：**协作**，Master 收集 Task，并分配给 Slave 执行

节点角色的状态转移图：用于 Master 选举阶段 (节点平等)

![](/images/zookeeper/zk-master-and-slave-status-flow-chart.png)

Note：

> 要求 Slave 跟 Master 同步数据，而且要求后期推举 Slave 成为 Master，相当于从实现了一遍 ZK 的 Leader 选举过程，过于复杂，因此，不推荐上述状态转移图。

节点角色的状态转移图：用于 Master 选举阶段 （节点不平等，预设角色）

![](/images/zookeeper/zk-master-and-slave-status-flow-chart-2.png)

Note：

> 上述状态转移图方案，预设了：
> 
> * 1主：Master
> * 1备用主节点：Master Bak
> * 多个Slave：Slave

进行领域模型设计：用于 Slave 工作阶段

![](/images/zookeeper/zk-master-and-slave-domain-design.png)


## 主从集群：实现

基于 ZK 的 watch 监视点机制，具体实现时：

1. Master：协调 Slave 执行 Task
	* 收集 Client 提交的 Task：
	* 收集存活的 Slave：监听 slave 对应的临时节点
	* 将 Task 分配给 Slave 执行：监听 task 对应的临时节点
	* 监控 Task 的执行状态，如果 Task 执行失败，则，重新分配给另一个 Slave 执行


### Master 选举

#### 初始 Master 推举

本质：实现一个排它锁，获得锁的服务器节点，就是成为 Master 节点，其他节点成为 Slave。

ZK 机制：所有节点都去`抢占式`创建一个 ZNode 节点，创建成功的，成为 Master。

具体代码：

````
// 创建 ZNode 成功，成为 master
[zk: localhost:2181(CONNECTED) 4] create -e /master "master1.example.com:2333"
Created /master

// 创建 ZNode 失败，成为 slave
[zk: localhost:2184(CONNECTED) 0] create -e /master "master2.example.com:2333"
Node already exists: /master

// Slave 查询 Master 详情
[zk: localhost:2184(CONNECTED) 1] get /master
master1.example.com:2333
cZxid = 0x100000004
ctime = Fri Feb 17 23:36:22 CST 2017
mZxid = 0x100000004
mtime = Fri Feb 17 23:36:22 CST 2017
pZxid = 0x100000004
cversion = 0
dataVersion = 0
aclVersion = 0
ephemeralOwner = 0x15a4c457d560001
dataLength = 24
numChildren = 0
````

Master 已经推举成功后，Master 仍有可能崩溃，并且被备用 Master 替代，因此，所有的 Slave，可以设置监视点：监听 Master 的数据内容。

````
// 监视点：监听 Master 的数据内容
[zk: localhost:2184(CONNECTED) 3] stat /master true
cZxid = 0x100000004
ctime = Fri Feb 17 23:36:22 CST 2017
mZxid = 0x100000004
mtime = Fri Feb 17 23:36:22 CST 2017
pZxid = 0x100000004
cversion = 0
dataVersion = 0
aclVersion = 0
ephemeralOwner = 0x15a4c457d560001
dataLength = 24
numChildren = 0
````

#### Master_Bak 得到 Master 崩溃通知

当 Master 节点，被删除时，Master_Bak 获得通知：

````
// Master 崩溃，Master_Bak 收到通知
[zk: localhost:2184(CONNECTED) 4]
WATCHER::

WatchedEvent state:SyncConnected type:NodeDeleted path:/master
````

#### Master_Bak 切换角色，成为 Master

备用主节点，得到通知，再次创建 /master 节点，成为活动主节点

````
// Master_Bak，成为活动主节点
[zk: localhost:2184(CONNECTED) 4]  create -e /master "master2.example.com:2333"
Created /master
````

#### Slave 得到 Master 变更通知

Slave 得到 Master 变更通知，分为 2 类：

1. Master 被删除：Slave 设置监视点，监听 Master 创建事件
2. Master 信息变更：Slave 根据 Master 变更的信息，进行对应操作，例如：重连到其他 url 等，根具体业务场景相关；

### 工作阶段

完整的工作时序图，如下：

![](/images/zookeeper/zk-master-and-slave-time-serials.png)

#### Master 初始创建：Slave、Task、Task-Slave Relation 存储目录

创建 3 个 ZNode 用于管理 Slave、Task、Task-Slave Relation ：

````
[zk: localhost:2184(CONNECTED) 5] create /workers ""
Created /workers
[zk: localhost:2184(CONNECTED) 6] create /tasks ""
Created /tasks
[zk: localhost:2184(CONNECTED) 7] create /assign ""
Created /assign
[zk: localhost:2184(CONNECTED) 8] ls /
[zookeeper, workers, tasks, master, assign]

````

Master 监听 Slave、Task 的注册，即，监听子节点列表：

````
[zk: localhost:2184(CONNECTED) 9] ls /workers true
[]
[zk: localhost:2184(CONNECTED) 10] ls /tasks true
[]

````


#### Slave 注册

Slave 连接到集群后，会进行注册，告知 Master，已经上线

````
[zk: localhost:2181(CONNECTED) 0] create -e /workers/worker1.example.com "worker1.example.com:2224"
Created /workers/worker1.example.com

````

此时，Master 收到新的 Slave 上线通知：

````
[zk: localhost:2184(CONNECTED) 11]
WATCHER::

WatchedEvent state:SyncConnected type:NodeChildrenChanged path:/workers
````

Master 为 Slave 分配工作目录，并且监听工作目录中的任务：

````
[zk: localhost:2184(CONNECTED) 13] create /assign/worker1.example.com ""
Created /assign/worker1.example.com
[zk: localhost:2184(CONNECTED) 14] ls /assign/worker1.example.com true
[]
````

#### Client 角色

客户端，向 Master 提交任务：（顺序节点）

````
[zk: localhost:2181(CONNECTED) 0] create -s /tasks/task- "cmd"
Created /tasks/task-0000000000
````
客户端，需要获知任务的执行结果，因此，添加监视器：

````
[zk: localhost:2181(CONNECTED) 1] ls /tasks/task-0000000000 true
[]
````

客户端提交新的 Task 后，Master 会收到通知：

````
[zk: localhost:2184(CONNECTED) 15]
WATCHER::

WatchedEvent state:SyncConnected type:NodeChildrenChanged path:/tasks
````

Master 通过查询，将新的 task，以一定算法，分配给某个 worker：

````
[zk: localhost:2184(CONNECTED) 15] ls /tasks true
[task-0000000000]
[zk: localhost:2184(CONNECTED) 16] create /assign/worker1.example.com/task-0000000000 ""
````

Slave 收到 Task 分配的通知：

````
WATCHER::Created /assign/worker1.example.com/task-0000000000


WatchedEvent state:SyncConnected type:NodeChildrenChanged path:/assign/worker1.example.com
````

Slave 查询自己的工作目录表，确认 Task 是分配给自己的，并且在 Task 执行结束时，更新 Task 状态：

````
[zk: localhost:2184(CONNECTED) 18] ls /assign/worker1.example.com true
[task-0000000000]
[zk: localhost:2184(CONNECTED) 17] create /tasks/task-0000000000/status "done"
Created /tasks/task-0000000000/status
````

Client 收到 Task 执行结果通知，并检查结果：

````
[zk: localhost:2181(CONNECTED) 2]
WATCHER::

WatchedEvent state:SyncConnected type:NodeChildrenChanged path:/tasks/task-0000000000

[zk: localhost:2181(CONNECTED) 2] get /tasks/task-0000000000
cmd
cZxid = 0x100000011
ctime = Sat Feb 18 00:19:57 CST 2017
mZxid = 0x100000011
mtime = Sat Feb 18 00:19:57 CST 2017
pZxid = 0x100000013
cversion = 1
dataVersion = 0
aclVersion = 0
ephemeralOwner = 0x0
dataLength = 3
numChildren = 1
[zk: localhost:2181(CONNECTED) 3] get /tasks/task-0000000000/status
done
cZxid = 0x100000013
ctime = Sat Feb 18 00:27:54 CST 2017
mZxid = 0x100000013
mtime = Sat Feb 18 00:27:54 CST 2017
pZxid = 0x100000013
cversion = 0
dataVersion = 0
aclVersion = 0
ephemeralOwner = 0x0
dataLength = 4
numChildren = 0
````



## 参考资料

* [从Paxos到Zookeeper分布式一致性原理与实践] 第7章 7.1.3
* [ZooKeeper-Distributed Process Coordination] 第2章 2.4







[NingG]:    http://ningg.github.com  "NingG"
[从Paxos到Zookeeper分布式一致性原理与实践]:	https://book.douban.com/subject/26292004/
[ZooKeeper-Distributed Process Coordination]:    http://shop.oreilly.com/product/0636920028901.do










