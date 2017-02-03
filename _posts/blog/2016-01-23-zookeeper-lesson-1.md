---
layout: post
title: ZooKeeper 技术内幕：系统模型
description: 内部包含哪些组件和元素？他们的作用？
published: true
category: zookeeper
---

## 概要

几个问题：

1. ZK 中数据是如何存储的？最小存储单元？
2. 每个存储单元，内部存储了哪些信息？
3. 每个节点，有版本的概念吗？版本用来解决什么问题？
4. Watcher 机制，如何实现的？
5. 权限 ACL 如何实现？有什么作用？

具体来说：

1. 数据模型：由节点构成
2. 节点特性：节点内部存储的信息
3. 版本：存储在 Session 和 节点上？解决什么问题？
4. 权限控制：ACL？控制 Session 的权限？

## 数据模型

### 数据节点

ZooKeeper 上记录信息，都是以「数据节点」（ZNode）为最小单元存储的：

1. ZNode 是数据存储最小单元
2. ZNode 既可以存储数据，也可以挂载子节点，形成「节点树」结构

![](/images/zookeeper/znode-tree.png)
 
每个 ZNode 都有生命周期，根据生命周期不同，ZNode 可以划分为：

* 持久节点（Persistent）：创建之后，需要**主动**删除
* 临时节点（Ephemeral）：跟客户端的 Session 生命周期一致，只能作为叶子节点
* 持久顺序节点（Persistent Sequential）
* 临时顺序节点（Ephemeral Sequential）

关于**顺序节点**：

* `顺序节点`，父节点会维护第一级子节点的创建顺序
* 顺序节点实现方式：父节点自动为**子节点名**添加**数字后缀**，作为新的、完整的名字
* 同一级顺序节点的个数，有上限：整型的最大值。

关于**临时节点**：

* 跟客户端的 Session 生命周期一致；
* Client Session 失效，则临时节点会自动清除；
* Session 失效，并不是指 TCP 连接断开；
* 临时节点，不能包含子节点，只能为叶子节点。

数据节点，存储的信息：

1. 数据信息
2. 节点自身状态信息

节点中存储的具体信息：

```
[zk: localhost:2181(CONNECTED) 5] get /zk_test
哈哈哈
cZxid = 0x2
ctime = Tue Jan 24 16:39:15 CST 2017
mZxid = 0x2
mtime = Tue Jan 24 16:39:15 CST 2017
pZxid = 0x2
cversion = 0
dataVersion = 0
aclVersion = 0
ephemeralOwner = 0x0
dataLength = 9
numChildren = 0
```

其中，包含几类信息：

1. 当前节点创建和修改：创建、修改的`时间`和`事务`；
2. 当前节点版本号：`数据版本`、`ACL 版本`
3. 子节点个数、子节点列表变更：子节点个数变更和子节点列表变更的`事务`
4. 子节点版本号：子节点的`数据版本`
5. 临时节点的 Session ID：创建临时节点的 `ephemeralOwner`


### 事务

事务：

1. ZK中，事务操作，是指：能够`改变` ZooKeeper `服务器状态`的操作
2. 事务操作，包含：
	* 创建 ZNode
	* 删除 ZNode
	* 修改 ZNode 上的数据
	* Session 的创建
	* Session 的失效
3. ZK中，每个事务请求，ZK 都会为其分配一个**全局唯一**的事务ID，ZXID，64位数字。
4. 通过 ZXID，表示事务的全局顺序。

思考：

> 1. 事务的 ZXID 是怎么分配的？
> 2. 如何保证事务的时序性？（顺序执行）

特别说明：事务是跟 ZK 中服务器角色相关的，ZK 服务器角色有 3 种：Leader、Follower、Observer，其中，所有的**事务操作**都会被转发给 Leader，由 Leader 执行事务，完成 ZK 状态的变更。

事务请求的详细处理过程：

1. 一个事务为一个单位，以原子方式操作，需要保证同时变更`节点数据`和`节点版本号`，保证事务之间相互隔离；
2. ZK 中事务操作，**没有回滚**机制；但 Leader 跟 Follower 之间，有 Truncate 机制，当 Follower 的事务执行，比 Leader 新时，Leader 会发送 TRUNC 命令，让 Follower 截断事务；ZK 中，事务采取 2PC 策略，先写事务日志，然后发起 Proposal 投票，最后，听 Leader 号令 commit 事务。
3. 事务执行的**顺序性**：统一 Leader 执行所有的事务操作，并且 Leader 上，启用`单线程`执行所有事务，保证事务顺序；最近 ZK 增加了`多线程`的支持，提高事务处理的速度。
4. ZK 中事务，具有**幂等性**：同一个事务，执行多次，得到结果相同；多个事务，保证同一执行顺序，执行结果相同；
5. Leader 为每一个事务请求，分配 ZXID，保证不同 ZXID 有序
6. ZK Leader 选举过程中，通过交换 ZXID 判断，哪个 Follower 的数据最新
7. ZXID 为 long 型（64位）整数，2 部分（每个32位）：时间戳（epoch） + 计数器（counter）
	1. Leader 选举，会产生新的 epoch（自增）
	2. 同一个 Leader 生成的 ZXID，epoch 相同，counter 自增

思考：

> ZK 集群中，事务 ID，ZXID 是由 Leader 分配的，同时，所有的事务，都是由 Leader 执行的吗？


### 会话

客户端会话（Session）：ZK Client 与 ZK Server 之间，创建并保持 TCP 连接，即创建了一个 Session。 Session 跟下面几点，息息相关：

1. 临时节点的生命周期
2. 客户端请求的顺序执行
3. Watcher 通知机制

Session 在整个运行过程中，会在不同状态之间切换，即：Session 有一个`状态转移图`。



## 参考来源

* [从Paxos到Zookeeper分布式一致性原理与实践]









[NingG]:    http://ningg.github.com  "NingG"
[从Paxos到Zookeeper分布式一致性原理与实践]:	    https://book.douban.com/subject/26292004/


