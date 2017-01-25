---
layout: post
title: ZooKeeper 技术内幕：Leader 选举
description: ZooKeeper 内节点角色，Leader 选举的详细过程
published: true
category: zookeeper
---


## 概要

几个问题，引发思考：

1. 什么时候 leader 选举？
2. 选举的过程？
3. 选举过程中，是否能提供服务？
4. 选举结果，是否会丢失数据？


## 服务器角色

2 个小问题：

1. 服务器节点有多少角色？
2. 每个角色的作用？

### 角色

ZK 集群中，服务器节点，有 3 中角色：

1. Leader：ZK 集群工作机制的核心，主要工作：
	* 调度者：集群内部各个服务节点的调度者
	* 事务请求：事务请求的唯一调度和处理者，保证集群事务处理的顺序性
2. Follower：主要职责：
	* 非事务请求：Follower 直接处理非事务请求，对于事务请求，转发给 Leader
	* Proposal 投票：Leader 上执行事务时，需要 Follower 投票，Leader 才真正执行
	* Leader 选举投票
3. Observer：ZK `3.3.0+` 版本开始引入，提升 ZK 集群的非事务处理能力，主要职责：
	* 非事务请求：Follower 直接处理非事务请求，对于事务请求，转发给 Leader

特别说明：Observer 跟 Follower 的唯一区别：

1. Follower 参与投票：Leader 选举、Proposal 提议投票（事务执行确认）
2. Observer 不参与投票：只用于提供非事务请求的处理

疑问：节点成为 Follower 还是 Observer 是 配置文件中设定的？

## Leader 选举

2 个小问题：

1. 什么时候，进行 Leader 选举？
2. Leader 选举的具体过程，是什么？


### 时机

下面任何一种情况，都会触发 Leader 选举：

1. 启动时，集群服务器刚启动
2. 运行时，Leader 崩溃

服务器的状态流转：

![](/images/zookeeper/zknode-flow-chart.png)


### 过程

Leader 选举过程，本质就是广播`优先级消息`的过程，选出**数据最新的服务节点**，选出**优先级最高的服务节点**，基本步骤：

1. 各个服务器节点，广播自己的优先级标识 `(sid，zxid)` 
2. 服务器节点收到其他广播消息后，跟自己的优先级对比，自己优先级低，则变更当前节点投票的优先级`(sid，zxid)` ，并广播变更后的结果
3. 当任意一个服务器节点收到的投票数，超过了`法定数量`(quorum)，则，升级为 Leader，并广播结果。

疑问：`法定数量`（quorum），一般设置为集群规模大小的半数以上，quorum 在哪配置的？

特别说明：

1. 服务器节点的优先级标识：`(sid，zxid)` 
2. 优先比较 `zxid` （事务 ID），其次比较`sid`（服务器ID）
3. `sid` (服务器 ID) 是节点配置文件中设定的
4. 当前服务器上的 `zxid` 是什么时候设定的？是在 Leader 执行事务过程中，向当前服务器同步的？

具体选举过程：

![](/images/zookeeper/leader-election-general.png)

补充说明：

1. 由于网络延时，服务器节点得不到足够多的广播信息时，会做出错误的投票判断，纠正过程会更耗时
2. 选举过程中，服务器节点，会等待一定时间，再广播投票信息，时间间隔一般设定为 `200 ms`
3. 上面 Leader 选举，采取 `Push 方式` 广播消息，称为 `快速 Leader 选举`，因为之前的 Leader 选举，采用 `Pull 方式`，每隔 `1s` 拉取一次。

真正的投票信息：

|属性|说明|
|---|---|
|id|被推举 Leader 的 sid|
|zxid|被推举 Leader 的事务ID|
|electionEpoch|投票的轮数，约束：同一轮投票，计数有效|
|peerEpoch|被推举 Leader 的 epoch|
|state|当前服务器的状态|

疑问：Leader 负责执行所有的事务操作，一次事务操作，

1. Leader 如何将事务操作同步到 Follower 和 Observer ？同步、异步？
2. 如何保证同步过程中，事务一定执行成功？事务失败的影响？

Leader 上执行的事务状态，通过 `Zab` 状态更新的广播协议，更新到 Follower 和 Observer。 


## 附录

### 分布式系统 Leader 选举：脑裂

脑裂（split brain）：服务器集群的 2 个子集，能够同时独立选举 Leader，并正常运行，形成 2 个集群。

解决办法：Leader 选举的`法定数量`（quorum），超过正常集群的半数。

Leader 选举的必要条件：节点数量 > `法定数量`。



## 参考资料

* [从Paxos到Zookeeper分布式一致性原理与实践]
* [ZooKeeper-Distributed Process Coordination] 第9章 9.2 








































[NingG]:    http://ningg.github.com  "NingG"
[从Paxos到Zookeeper分布式一致性原理与实践]:	    https://book.douban.com/subject/26292004/
[ZooKeeper-Distributed Process Coordination]:    http://shop.oreilly.com/product/0636920028901.do










