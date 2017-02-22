---
layout: post
title: Redis 设计与实现：集群方案
description: Redis Cluster 中，数据分片的实现细节
published: true
category: redis
---

Redis 集群，分布式数据库方案：

1. 分片
1. 复制
1. 故障转移？

几个典型问题：

1. 单节点的 Redis 服务器，能够组成 Redis 集群吗？
	1. 不能，需要重启，并配置：`cluster-enabled yes`
	1. 集群模式、非集群模式下，Redis 服务器的运行机制，有差异
	1. 差异有哪些？
1. 如何构建 Redis 集群？
	1. 集群模式，启动多个 Redis 节点
	1. 多节点，加入同一个集群：
		1. `CLUSTER MEET <ip> <port>`
1. `redis-cli -c` ：Client 以集群模式，接入 Redis 集群？与普通模式有差异吗？
 
构造 Redis 集群的基本过程（Cluster meet）：

![](/images/redis/redis-cluster-construct-progress.png)

## 1. Redis 节点集群模式 vs. 单机模式

设置集群模式：`cluster-enabled yes`, 之后再启动 Redis 节点。

1. 节点（运行在集群模式下的 Redis 服务器）会继续使用所有在单机模式中使用的服务器组件， 比如说：
1. 节点会继续使用**文件事件处理器**来处理命令请求和返回命令回复。
1. 节点会继续使用**时间事件处理器**来执行 serverCron 函数， 而 serverCron 函数又会调用集群模式特有的 clusterCron 函数：clusterCron 函数负责执行在集群模式下需要执行的常规操作， 比如向集群中的其他节点发送 Gossip 消息， 检查节点是否断线； 又或者检查是否需要对下线节点进行自动故障转移， 等等。
1. 节点会继续使用**数据库**来保存键值对数据，键值对依然会是各种不同类型的对象。
1. 节点会继续使用 **RDB 持久化**模块和 **AOF 持久化**模块来执行持久化工作。
1. 节点会继续使用**发布与订阅**模块来执行 PUBLISH 、 SUBSCRIBE 等命令。
1. 节点会继续使用**复制**模块来进行节点的复制工作。
1. 节点会继续使用 **Lua 脚本**环境来执行客户端输入的 Lua 脚本。

诸如此类。

除此之外， 节点会继续使用 redisServer 结构来保存服务器的状态， 使用 redisClient 结构来保存客户端的状态， 至于那些只有在集群模式下才会用到的数据， 节点将它们保存到了 cluster.h/`clusterNode` 结构， cluster.h/`clusterLink` 结构， 以及 cluster.h/`clusterState`结构里面。

## 2. 数据结构

1. clusterState ：整个集群，什么状态？包含多少 Node？
	1. 记录了在当前节点的视角下， 集群目前所处的状态 —— 比如集群是在线还是下线， 集群包含多少个节点， 集群当前的配置纪元。
1. clusterNode：集群内，单个Node，什么情况？地址？
	1. 保存了一个节点的当前状态， 比如节点的创建时间， 节点的名字， 节点当前的配置纪元， 节点的 IP 和地址， 等等。
1. clusterNode：集群内，单个Node，与其余Node之间的交互情况？
	1.  link 属性是一个 clusterLink 结构， 该结构保存了连接节点所需的有关信息， 比如套接字描述符， 输入缓冲区和输出缓冲区。

补充说明：

> redisClient 结构和 clusterLink 结构的相同和不同之处
> 
> redisClient 结构和 clusterLink 结构都有自己的套接字描述符和输入、输出缓冲区， 这两个结构的区别在于:
> 
> 1. redisClient 结构中的套接字和缓冲区是用于连接客户端的 
> 2. clusterLink 结构中的套接字和缓冲区则是用于连接节点的

## 3. CLUSTER MEET 命令的实现

![](/images/redis/redis-cluster-cluster-meet-cmd.png)

几点：

1. Client 连接「节点A」，发送「CLUSTER MEET」命令
1. 「节点A」与「节点B」握手成功之后，结果：
	1. 两个节点，会建立对方的 ClusterNode 数据结构
	1. 之后， 「节点A」 会将「节点B」的信息通过 Gossip 协议传播给集群中的其他节点， 让其他节点也与「节点B」进行握手， 最终， 经过一段时间之后，「节点B」会被集群中的所有节点认识

疑问：Gossip 协议的简单工作过程？

## 4. 槽指派（slot）

Redis 集群，两个基本过程：

1. 构建集群：集群模式启动，cluster meet 命令构建
1. 集群上线：完成 16384 个槽的分配（索引时， `0 ～ 16383`：2048 x 8，2KB）

如何进行槽指派：客户端连接到指定 Node上，执行 `cluster addslots ...`命令，并且只能为当前连接的 Node 指派 slot。

实现细节：

1. 记录槽指派信息：
	1. 每个节点的 clusterNode中，使用 2048 长度的char数组（二进制位数组）slots[]，记录当前 clusterNode 处理的slot
	1. 判断当前节点，是否处理某个 slot，时间复杂度 `O(1)`
1. 传播槽指派信息：
	1. 节点会将自己的slots数组，发送给其他节点，其他节点，会更新 clusterState中 nodes 列表找出对应的clusterNode，更新其中 slots 数组
	1. 疑问：什么时候发？如何发？Redis 集群的消息机制，后文会说到
1. 记录所有槽的指派信息：
	1. clusterState结构中，clusterNode *slot[16384]的数组，记录 1 个 slot 由哪个 clusterNode 处理
1. 槽指派信息，存储在两个地方 clusterState.slots & clusterNode.slots，解决两个问题：
	1. 通过 slot 查询 clusterNode：时间复杂度 `O(1)`
	1. 通过 cluster查询 slot：时间复杂度 `O(1)`

![](/images/redis/redis-cluster-slots-to-cluster-node.png)

## 5. Redis 集群中，执行命令

Client 连接到某个 Node，并且执行命令时，判断过程：

![](/images/redis/redis-cluster-moved-cmd.png)

执行过程，命令示例：

```
// 当 slot 不在当前 clusterNode 时，返回 MOVED 错误信息
// MOVED 信息，引导 Client 连接正确的 Node
MOVED <slot> <ip>:<port>
```

![](/images/redis/redis-cluster-moved-cmd-1.png)

![](/images/redis/redis-cluster-moved-cmd-2.png)


疑问：如何观察 MOVED 信息返回之后的过程？

RE：连接都变了，能够看到执行命令之后，用户连接的 node 已经发生变化

补充说明：

> 1. Redis Cluster 采用「重定向」机制，Client 会跟新的 Server Node 创建新连接
> 2. ZooKeeper 采用「转发」机制，Client 跟当前 Follower 保持连接，Follower 将事务请求转发到 Leader。


一个集群客户端，通常会与集群中的多个Node创建套接字连接，而所谓的节点转向，实际是换一个套接字来发送命令；

如果MOVED错误提供的Node与当前client之间不存在套接字连接，则 client 会先创建连接，然后再进行转向。

![](/images/redis/redis-cluster-moved-cmd-details.png)

## 6. Redis 集群内，节点数据库的实现

数据库存储的数据：

1. key - value：键、值
1. key - expire time：键、过期时间

集群与单机的差异：

1. 集群内，**节点只能使用 0 号数据库**；单机模式，Redis 服务器没有这个限制。
2. 集群模式下，clusterState 中，不仅保存 key-value、key-expireTime，而且会使用 slots-to-keys 跳跃表，来保存 slot 与 key 之间的关系。
	1. 分值（score）：slot
	1. 成员（member）：key
	1. 跳跃表：按照分值（slot）进行升序排列，因为有序，可以很方便找到某一个分值（score）下的所有成员（member）

思考：根据 key，如何计算出，其对应的slot？

## 7. 重新分片

> 重新分片：新的 master 加入时，重新分配 slot，同时，相关slot 上所属的键值对也会从源master迁移到目标master 。

重新分片：

1. 可以在线进行，不需要终止集群服务；
1. 通常由 Redis 集群管理软件 `redis-trib` 负责执行

将一个键从一个节点迁移到另一个节点的实际过程（redis-trib 负责）：

![](/images/redis/redis-cluster-redis-trib-cmd.png)

重新分片的整个过程：

![](/images/redis/redis-cluster-re-slot.png)

重新分片过程中，典型错误：

> slot 从「源节点」向「目标节点」迁移的过程中，slot 内的一部分 key 在「源节点」、一部分 key 在「目标节点」

此时，Node 会返回 `ASK` 错误，redis-cli 会自动转向，跟处理 `MOVED` 错误类似。

## 8. 主从复制与故障转移

基本过程：

1. master 下线之后，推举出一个 slave 自动升级为new master
1. old master 重新上线，将成为 new master 的slave

几个关键点：

1. 多个 slave 存在时，如何推举出 new master？
1. 如何将 old master 设置为 new master 的 slave？

Redis cluster 的整体过程中：

1. 设置 slave
	1. 向 slave 发送：`cluster replicate <node_id>`
	1. clusterState.myself.slaveof 指向clusterNode
	1. clusterState.myself.flags 中，关闭 `REDIS_NODE_MASTER`，并开启 `REDIS_NODE_SLAVE`
	1. slave 从 master 复制内容，类似非集群模式命令：`SLAVEOF <master_ip> <master_port>`
1. 其他节点会将 master 对应的 clusterNode.slaves 指向 slave 对应的 clusterNode
	2. 疑问：设置 slave 之后，如何告知其他 node？

### 8.1. 故障检测

集群内，节点定期向其他节点发送 PING 命令，在规定时间内，如果没有收到 PONG 响应，则，将对方clusterNode 标记为「疑似下线」（probable Fail，PFail）。

1. 节点互相发送信息，交换整个集群的节点状态，例如：在线、疑似下线（PFAIL）、已下线（FAIL）
1. 每个 clusterNode 中都存在一个下线报告列表（failure reports），每个 Node 收到一个 clusterNode 的「疑似下线」报告时，就更新对应 clusterNode 的 fail_reports 列表
1. 1/2 以上的 master 都将某一个 masterA 标记为 PFAIL，则，当前节点将 masterA 标记为 FAIL，同时，向集群广播 masterA 为 FAIL 状态
 
clusterNode 的「疑似下线」列表：

![](/images/redis/redis-cluster-p-fail-list.png)

注：每个「疑似下线」报告，都对应 node、time 两个属性，其中 time 用于判断「疑似下线」报告是否过时。

### 8.2. 故障转移

slave 发现 master 「已下线」，则，进行故障转移：

1. 从 slave 中推选一个 new master；
1. slave 执行 SLAVEOF no one 命令，成为 new master
1. new master 撤销所有 olde master 的槽指派，并将这些槽全部指派给自己。
1. new master 向集群中广播一条 PONG 消息，通知其它节点本节点已经由从节点变成了主节点。
1. 新的主节点开始接收和自己负责处理的槽有关的命令，故障转移完成

### 8.3. 推举 new master

slave 发现 master 「已下线」后，

1. 每个 slave 都向其余所有的 master 发送「FAILOVER_AUTH_REQUEST」请求
1. 只有 master 有投票权
1. 只有 slave 获取 「N/2 + 1」(半数以上) 投票后，才能成为 new master
1. 如果没有 slave 获得半数以上的投票，则，开启下一个「配置纪元」，直到选出 new master 为止

与 选举领头 Sentinel 策略基本一致，都是使用 Raft 算法来实现。

特别说明：

> Redis Cluster 方案，不需要使用 Sentinel 来进行故障转移了。

## 9. 消息

集群内，节点消息 5 类：

1. MEET：将消息接收这添加到集群中。
1. PING：集群中每隔一秒会从已知节点列表中随机选出五个节点，然后对这五个中最长时间没有发送过PING消息的节点发送PING消息，以此来检测节点是否在线。此外，节点A最后以此收到节点B发送的PONG消息的时间距离当前时间超过了节点A的cluster-node-timeout选项设置时长的一半，那么节点A也会向节点B发送PING消息，防止节点A因为长时间没有随机选中节点B作为PING消息的发送对象而导致节点B的信息更新滞后。
1. PONG：MEET和PING的回复消息。另外一个节点也可以通过PONG消息通知集群中其它节点本节点已经由从节点升级成了主节点。
1. FAIL：当一个主节点A判断另一个主节点B已经进入FAIL状态时，节点A会向集群广播一条关于B的FAIL消息，所有收到该消息的节点都会把B标记为已下线。这时不使用Gossip协议的原因是Gossip协议会有延迟需要一段时间才能传播至整个集群，而当结点已下线时需要尽快完成故障转移。
1. PUBLISH：当结点收到一个PUBLISH命令时，节点会执行该命令，并向集群广播一条PUBLISH消息，所有接收到这条PUBLISH消息额节点都会执行相同的命令。

Redis 集群内，利用 Gossip 协议，交换不同节点的状态信息。具体，Gossip 协议由 MEET、PING、PONG 三种消息实现。

消息头：

1. sender 的槽指派信息
1. sender 为 slave 时，指定对应的 master 信息

## 10. 集群命令整理

|命令|说明|
|---|---|
|CLUSTER ADDSLOTS ...|	为当前节点，分配 slot|
|CLUSTER KEYSLOT ...|	查看当前 key 对应的 slot|
|CLUSTER GETKEYSINSLOT `<slot>` `<count>`| 	最多返回 count 个属于 slot 的 key|
|CLUSTER REPLICATE `<node_id>`|	当前节点，设置成 <node_id> 的 slave|


[NingG]:    http://ningg.github.com  "NingG"