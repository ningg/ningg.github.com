---
layout: post
title: ZooKeeper 典型应用场景
description: ZooKeeper 的应用实例剖析
published: true
category: zookeeper
---

## 背景

分析了 ZK 的实现机制，以及运维配置的内容，现在到了关键的问题：

1. 哪些应用场景，能够使用 ZK 呢？
2. 这些应用场景下，如何使用 ZK 呢？
3. 生产环境中，分布式系统，使用 ZK 的实例有哪些呢？

回顾一下之前的内容：

1. ZK：提供分布式系统协作的基础设施，简化业务系统中涉及分布式协作的开发工作；
2. ZK：依赖 ZAB 协议，保证了分布式系统的数据一致性；
3. ZK：提供版本、监视点机制，分别解决：
	* 版本：解决并发更新问题，本质是乐观锁
	* 监视点：事件触发，通知机制，提升系统效率
4. ZK：事务的顺序性，由 Leader 保证，Leader 上启用单线程执行事务，为每个事务生成唯一有序的 zxid；
5. ZK：监视点，是单次触发事件，存在事件丢失现象，具体要看场景，大部分场景下，单次触发事件，有积极的意义
6. ZK 数据都存储在内存中，快照和事务日志都是磁盘文件，用于恢复内存现场
7. ZK 快照是异步线程生成的 Fuzzy 快照，但由于 ZK 的事务操作都是幂等的，重放事务操作并不会带来问题；

## ZK 典型应用场景 & 实现

ZK 基于 `Watcher 事件通知`、`丰富的节点类型`可以实现分布式应用的核心功能：

1. 数据的发布、订阅：
3. 命名服务
6. Leader 选举
7. 分布式锁：
8. 分布式队列：

### 数据的发布订阅

数据的发布订阅（Publish/Subscribe）系统：就是**配置中心**

1. **目标**：配置信息的`集中管理`和`动态更新`；
2. **过程**：发布者，将数据发布到 ZK 的上，订阅者进行订阅数据，达到动态获取数据的目的；

具体过程参考：

![](/images/zookeeper/zk-application-pub-sub.png)

发布订阅中，2 种典型模式的对比：

1. Push 模式：
	* Server 端的`消息队列`：不考虑消息累积问题，维护简单，Server 只需维护一份`消息队列`即可
	* Subscriber 端的`消息队列`：需维护一个消息缓存队列，实现生产者-消费者模型，维护复杂
	* 实时性：消息的实时性好，Server 端无需在意 Subscriber 的消费速度
	* 可靠性：要求 Server & Subscriber 都要保证消息队列的可靠性
2. Pull 模式：
	* Server 端的`缓存队列`：完整的生产者-消费者模型，可能出现消息累积，维护复杂
	* Subscriber 端的`消息队列`：不需要维护，根据自己消费速度，自己行读取消息
	* 实时性：消息实时性较弱，并且轮询会浪费 CPU 和网络资源
	* 可靠性：只需要保证 Server 端消息队列的可靠性即可

而 ZK，发布订阅模型，采用`推拉结合`方式：

1. 设置订阅：Client 在 Server 上注册监视点
2. Server push：Server 事件触发时，告知 Client 有时间发生，但未告知详细发生的内容
3. Client pull：Client 主动 pull 一次，查询具体的变化

推拉结合的方式，主要优点：轻量级的 push，分 2 阶段，设计简单，同时，支持丰富的业务场景。

思考：

> 配置信息，存储方案：
> 
> 1. 方案一：存储在 ZK 上？（常用）
> 2. 方案二：单独存储，只使用 ZK 作为监视点，触发事件？ 

典型场景：

1. Nginx 的负载均衡：加权轮询，调整权值
2. ...


### 命名服务

`命名服务`是分布式系统最基本的公共服务之一，被命名的实体，通常是：

1. 集群中的机器
2. 服务地址

命名服务的关键点：

1. 全局唯一的名字

ZK 中，使用`持久化的顺序节点`，作为全局唯一 ID（全局唯一ID）。

### Leader 选举

主要针对**初始的 Leader 选举**，不包含：**崩溃恢复的 Leader 选举**。

初始的 Leader 选举，目标：选举出唯一的一个 Leader。

因此，只要有一个，能够保证`数据唯一性`的组件即可。

唯一性的组件：

1. 关系型数据库：主键（ID），所有的 Server 都去插入一个数据，完全相同的主键 ID，插入成功的 Server ，成为 Leader；
	* 问题：Leader 崩溃之后，如何告知其他 Server？Leader 数据变更后，如何告知其他 Server？
2. ZK：ZNode 是唯一的，`创建``临时节点`，创建成功的，成为 Leader；其他节点 watch Leader 节点的数据更新状态和存活状态。

补充：针对 **崩溃恢复的 Leader 选举**，比较复杂，一般屏蔽在 ZK 内部，现实业务场景中，通常设定一个 Server 为 Leader 的 Backup，Leader 崩溃之后，自动切换为 Leader。


### 分布式锁

排它锁：`临时节点`的创建和删除，同时，考虑死锁的问题
	* 获取锁：`创建``临时节点`
	* 释放锁：Client 的会话过期、宕机、Client 主动删除`临时节点`

### 分布式队列

分布式队列，2 种模型：

1. FIFO：先入先出
	* 临时顺序节点：创建和释放
2. Barrier：分布式屏障，所有的队列元素都聚集齐之后，才会进行处理，一般用于分布式并行计算的场景，合并多个子计算的结果。
	* 创建节点：其中记录需要等待的「子节点个数」
	* 监听：子节点列表的变动
	* 增加子节点：每一个子计算结束，就在节点下创建一个子节点


## ZK 使用示例

### Kafka

todo





## 参考资料

* [从Paxos到Zookeeper分布式一致性原理与实践] 第8章








[NingG]:    http://ningg.github.com  "NingG"
[从Paxos到Zookeeper分布式一致性原理与实践]:	https://book.douban.com/subject/26292004/
[ZooKeeper-Distributed Process Coordination]:    http://shop.oreilly.com/product/0636920028901.do
[ZooKeeper Administrator's Guide-A Guide to Deployment and Administration]:	http://zookeeper.apache.org/doc/trunk/zookeeperAdmin.html
[TaoKeeper]:	https://github.com/alibaba/taokeeper	"ZooKeeper-Monitor"








