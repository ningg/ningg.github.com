---
layout: post
title: Apache Kafka 0.10 技术内幕：设计思路
description: MQ 的设计思路，如何保证消息的有序性？如何解决并发效率问题？如何做到高可用？
published: true
category: kafka
---

## 目标

Kafka 简单的看作一个 MQ，那 Kafka 如何设计的呢？

1. MQ 本质是 Queue（队列），其中的消息是否是有序的？
2. Kafka 是 MQ，如何保证并发效率？大量的 Producer 以及大量的 Consumer，如何提升生产和消费效率？
3. Kafka 集群的可用性，怎么样？如果 Kafka 集群的单个节点宕机，是否会影响整个集群的可用性？

## Kafka 整体结构

Kafka 集群，是集群，是服务器的集群，每一个服务节点，称为 `Broker`，由 `id` 唯一标识。

Kafka 集群整体结构如下：

![](/images/apache-kafka-10/kafka-general-structure.png)

Kafka 集群结构：

1. **Broker**：集群的每个服务节点，称为 `Broker`
2. **Producer**: 向 kafka 指定 topic 发送数据的程序，称作 `Producer` 
3. **Consumer**: 从 kafka 指定 topic 消费数据的程序，称作 `Consumer`

## 核心问题

### 问题1：不同业务数据，分开存放

不同的业务数据，分开存放：

1. OS：CPU、内存、网络
1. APP：pv、响应时间

解决方式：`topic`

1. 同一种数据放入同一个 topic
1. 不同数据，通过 topic 分离

![](/images/apache-kafka-10/kafka-design-topic.png)


### 问题2：消息的单播、多播？

消息的单播、多播？

1. 单播：一条 msg，一个 consumer
1. 多播：一条 msg，多个 consumer

解决方式：`consumer group`

1. 一个 msg，送入多个 consumer group
1. 一个 consumer group 中，只能有一个 consumer 处理某一条 msg

![](/images/apache-kafka-10/kafka-consumer-group.png)

### 问题3：并发效率

并发效率：

1. 同一类业务数据，多 producer，多 consumer
1. 并行处理？

解决方式：`partition`

1. 一个 topic，划分为 多个 partition
1. partition 之间能够并行处理

![](/images/apache-kafka-10/kafka-partition-parallel.png)

### 问题4：msg 之间的顺序保证

msg 之间的顺序保证：

1. 推荐系统中，时间序列挖掘
1. 业务需求上，严格限制，msg 之间的先后顺序

解决办法：partition 内部有序

1. 将有顺序要求的 msg，送入`同一个` `partition`
1. 将时间戳，放入 msg 内

### 问题5：Kafka 的可用性

Kafka 的可用性：

1. Kafka 集群，由broker组成
1. 某个 broker 宕掉，数据是否会丢失？

解决办法：`replica`

1. 每个 partion 都存储多份，分布在不同 broker 上
1. replica 的角色，分为 leader、follower

![](/images/apache-kafka-10/kafka-replica-on-multi-broker.png)

## 小结

> Kafka 中，没有凭白无故的引入新的`术语`，每引入一个`术语`，都是用来解决问题的.

关键术语（关键原理）：

1. `topic`: kafka维护的消息种类,每一类消息由一个topic标识 
1. `consumer group`：解决单播、多播问题
1. `partition`: 每个topic可以分成多个区，分布在不同的broker上
1. `replica`: 每个topic可以设置副本数，所有的副本称作replica 
	* `leader`: 所有的副本中只有leader处理读写，其他的follower从leader同步 
	* `isr`: replica中能够跟上leader的实例称作isr 

Kafka 集群的典型内部结构：

![](/images/apache-kafka-10/kafka-inner-structure-demo.png)

## 参考资料

* [Kafka 官网]
* [Top 10 Uses For A Message Queue]
* [Kafka a Distributed Messaging System for Log Processing]
* [Learning Apache Kafka(2nd Edition)]
* [Kafka 设计解析-郭俊]


[Kafka 官网]:		http://kafka.apache.org/
[Kafka 官网-Quickstart]:		http://kafka.apache.org/quickstart
[Kafka 设计解析-郭俊]:		http://www.jasongj.com/categories/Kafka/
[Learning Apache Kafka(2nd Edition)]:		http://file.allitebooks.com/20150612/Learning%20Apache%20Kafka,%202nd%20Edition.pdf
[Kafka a Distributed Messaging System for Log Processing]:	http://docs.huihoo.com/apache/kafka/Kafka-A-Distributed-Messaging-System-for-Log-Processing.pdf
[NingG]:    http://ningg.github.com  "NingG"
[Top 10 Uses For A Message Queue]:		www.iron.io/blog/2012/12/top-10-uses-for-message-queue.html





