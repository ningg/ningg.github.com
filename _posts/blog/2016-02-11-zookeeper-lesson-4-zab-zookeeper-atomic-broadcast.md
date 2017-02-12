---
layout: post
title: ZooKeeper 技术内幕：消息广播（Zab & Paxos）
description: Leader 事务提议投票等消息传播过程
published: true
category: zookeeper
---


## 背景

ZK `Follower/Observer` 收到 `事务请求`后：

1. **请求转发**： `Follower/Observer` 将`事务请求`转发到 `Leader`；
2. **2PC**（2 phase commit，两阶段提交）：
	* `Leader` 向所有的 `Follower` 发送**提案**（Proposal） 
	* `Follower`将事务信息写入事务队列后， 向 `Leader` 返回 ACK 确认
	* `Leader` 接收到**法定数量** ACK 后，提交事务请求，并向 `Follower/Observer` 广播 Commit。

具体，事务执行过程中，**提案投票**过程见下图：

![/images/zookeeper/zk-proposal-zab.png]


## 广播协议：状态更新

上述事务提交的 2PC 策略，实际是由 Zab 协议保证的：

1. **ZAB**：ZooKeeper Atomic Broadcast protocol，ZooKeeper 原子广播协议。
2. **目标**：每次事务执行过程，都是`原子`的，要么成功、要么失败，不存在中间状态；
3. ZK 中，事务执行过程中，没有`回滚机制`；


ZAB 协议，具体策略：

1. **事务顺序执行**：Leader 确保 `T1` 事务提交成功后，才会广播事务 `T2`
2. **Follower 事务顺序执行**：所有 Follower 都会先提交 `T1`，再提交 `T2`

## ZAB 协议

ZK 并没有完全采用 Paxos 算法，而是采用 ZooKeeper Atomic Broadcast（ZAB, ZooKeeper原子广播协议）作为**数据一致性**的核心算法。

* 目标：数据一致性
* 特点：支持崩溃恢复
* 不是**通用的分布式一致性算法**，Paxos 才是**通用的**分布式一致性算法
* 具体：
	* **单一进程处理事务**：ZK 集群中，只有 Leader 负责处理事务请求
	* **ZAB 原子广播协议**：Leader 将事务消息广播到 Follower 和 Observer

ZAB 协议需要保证：

* **事务广播顺序**：先接收的事务，先广播
* **事务提交顺序**：先接收的事务，先提交
* **Follower/Observer 事务顺序**：Leader 上先提交的事务，在 Follower/Observer 上也先提交

Note：

> ZooKeeper 采用`提案投票`策略，并等待所有的 Follower 都返回确认信息，但，仍能保证所有的 Follower 上事务执行顺序跟 Leader 保持一致.
> 
> 原因：Leader 跟 Follower 之间采用 TCP 长连接，广播的事务消息具有顺序性。






## 参考资料

* [从Paxos到Zookeeper分布式一致性原理与实践]
* [ZooKeeper-Distributed Process Coordination] 第9章 9.2 








































[NingG]:    http://ningg.github.com  "NingG"
[从Paxos到Zookeeper分布式一致性原理与实践]:	https://book.douban.com/subject/26292004/
[ZooKeeper-Distributed Process Coordination]:    http://shop.oreilly.com/product/0636920028901.do










