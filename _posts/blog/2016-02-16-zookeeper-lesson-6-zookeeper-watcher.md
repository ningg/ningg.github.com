---
layout: post
title: ZooKeeper 技术内幕：watcher 监视点
description: ZK 中监视点的作用？常见的问题？
published: true
category: zookeeper
---

## 背景

ZK Client 要实时获取 ZNode 的数据状态，2 种方案：

1. **轮询**：实时性差，资源利用率低，浪费大量的 CPU 和 带宽；
2. **事件**：数据状态变更时，主动通知 Client，节省大量资源；ZK Server 通过 `watcher` 监视点，来实现事件通知。

使用 `watcher` 时，常见的几个问题：

1. 什么时候触发？
2. 常见问题有哪些？

## 什么时候触发 watcher

监视点，由下面 2 个要素构成：

1. 数据节点 ZNode
2. 事件类型 event：
	* 节点监视点：
		* 节点创建
		* 节点删除
		* 节点数据更新
	* 子节点监视点：
		* 子节点创建
		* 子节点删除

ZK 监视点，典型特征：

1. 单次触发：状态变更一次，就触发监视点，发送通知；
2. 通知优先：先向 Client 发送通知，再变更 ZNode 状态；
3. 与会话关联：会话过期，则等待的监视点会被删除；
4. 跨服务器生效：Client 跟服务节点断开后，连接其他服务节点时，Client 会重新发送未触发的监视点列表，在新的服务器上注册；
5. 无法移除：监视点一旦设置，就无法手动移除；只有 2 种方式：
	* 触发监视点
	* 会话过期、或关闭

## 常见问题

### 问题 1：单次触发，是否会丢失事件

`单次触发，丢失事件`，肯定会的：

1. 单次触发：事件触发后，监视点消失；
2. 间隔事件：在 Client 收到通知与读取最新状态之间，可能发生其他事件；
3. 无法捕获：间隔内发生的事件，Client 无法捕获到

**单次触发**可能**丢失事件**，ZK 采用**推拉结合**方式，获取事件变更的详细信息，在大多数业务场景下，并不会引入问题：

1. Master 向 Slave 的任务分配：Slave 收到 Master 分配的多个任务：Slave 下，新增多个顺序节点。

单次触发，配合**推拉结合**，实际上，将多个事件分摊到一个通知上，具有积极作用。降低了通知的数量。

结论：

1. 单次触发，会丢失事件
2. 单次触发，配合**推拉结合**，能满足大部分业务场景，不会因为丢失事件引入问题
3. 单次触发，丢失事件，有积极作用：降低了通知的数量

### 问题 2：多个事务操作，原子性

ZK `3.4.0+` 开始，支持 multiop，即：原子性的执行多个 ZK 操作，所有操作要么全部成功，要么全部失败。

本质：

1. Leader 对`一组事务操作`，发起提案
2. Follower 对完整提案进行投票，由于底层基于 TCP 传输，有顺序性保证，所有 Follower 上事务执行顺序，跟 Leader 完全一致，只要 Leader 能执行成功，所有 Follower 在无突发异常的情况下，都能执行成功

### 问题 3：缓存管理，Client 负责管理缓存

通过使用 ZK 的 watch 机制，可以：

1. Client 侧：
	* 本地缓存 ZK 数据：App 在本地缓存一份数据，不用每次都从 ZK 读取数据
	* 设置 watch：监听数据变更
2. Server 侧：
	* 发送通知：数据变更时，向所有 watch 的 Client 发送通知，由 Client 的 App 负责清理缓存。

### 问题 4：顺序性，写的顺序、读的顺序、通知的顺序

写的顺序：

1. 所有 Follower 都跟 Leader 上的事务执行顺序保持一致
2. Follower 上事务提交，可能晚于 Leader，但顺序不会乱

读的顺序：

1. ZK Client，可能连接在不同的 ZK Server 上，会观察到相同的更新顺序
2. ZK Client 观察到的时间，有前后差异
3. 建议：ZK Client 使用 ZK 进行所有涉及 ZK 状态的通信，避免产生 ZK 外部**隐藏通道**数据不一致的问题。

Note：

> **隐藏通道**，`hidden channel`，ZK Client 收到 ZK 上状态变更通知时，告知其他 ZK Client，但，其他 ZK Client 从其连接的 ZK Server 上，未查询到状态变更。

通知的顺序：不使用 multiop，依赖 watch 机制，实现`原子更新一组配置`

1. 创建一个节点，并设置 watch：节点删除时，一组配置可以使用
2. 逐个设置一组配置
3. 触发 watch：删除节点，触发通知，Client 来读取`一组配置`，避免读取到`部分更新`

### 问题 5：监视点的生命周期

监视点的生命周期：

1. 跟 Session 生命周期绑定：Session 关闭或超时，监视点会自动清除
2. 监视点只保存在内存中，不会持久化到磁盘
3. Client 重连有效：Client 侧保存一份监视点信息，Client 重连到另一个 Server 后，会向 Server 发送监视点列表，重新设置监视点


## 实践

设置一个监视点：

````
// 监视点：节点删除
// 监视点：节点数据更新
stat /znode true


// 监视点：子节点创建
// 监视点：子节点删除
ls /znode true
````



## 参考资料

* [从Paxos到Zookeeper分布式一致性原理与实践] 第7章 7.1.5
* [ZooKeeper-Distributed Process Coordination] 第2章 2.1.3 & 第4章










[NingG]:    http://ningg.github.com  "NingG"
[从Paxos到Zookeeper分布式一致性原理与实践]:	https://book.douban.com/subject/26292004/
[ZooKeeper-Distributed Process Coordination]:    http://shop.oreilly.com/product/0636920028901.do










