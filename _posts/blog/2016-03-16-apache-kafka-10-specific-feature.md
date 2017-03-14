---
layout: post
title: Apache Kafka 0.10 技术内幕：典型特点
description: Kafka 使用了哪些机制，让其拥有哪些特性？让 Kafka 脱颖而出？
published: true
category: kafka
---

## 目标

Kafka 之前就有各种个样的 MQ：

* Kafka 有什么优势呢？
* Kafka 采用了哪些机制，保证这些优势呢？


## Kafka 的典型特点

Kafka 的优势：

* **Producer**：
	*  支持`同步复制`和`异步复制`
		* 复制策略，控制方：Producer 控制？还是 Kafka cluster 控制？
	* **批量发送**：Nagle 策略，利用`缓冲区`、`超时时间`，合并小的数据包
		* 减少网络 IO 次数
		* 增加有效 payload 比例，提升有效吞吐量
* **Broker**：
	* 利用sendfile系统调用，`zero-copy`(零拷贝)，批量传输数据
	* 消息磁盘持久化，不在内存中 cache，充分利用磁盘顺序读写优势
		* broker 没有 cache 压力，因此，更适合支持 pull 模式
* **Consumer**：
	* pull 模式，broker 无状态，consumer 自己保存 offset
		* 配置过期时长（broker）
		* 多次回放数据

### msg 复制：同步、异步

Broker 上，通过配置 `min.insync.replicas` 参数，控制`同步复制`、`异步复制`、`部分同步复制`。

参数 `min.insync.replicas` 可以配置的位置：

* Broker 上
* Topic 上：Topic 上配置，优先于 Broker 的配置

![](/images/apache-kafka-10/kafka-msg-sync-replica.png)

Note：要想参数 `min.insync.replicas` 生效，需要 Producer 上设置 `acks to "all"` (等待响应)。

### log zero-copy 零拷贝

如果不使用 sendfile 系统调用，则：需要将 log 文件

1. 先从 Page Cache 复制到 Broker 的内存空间
2. 从 Broker 内存空间，复制到 Kernel Buffer 空间

具体过程：

![](/images/apache-kafka-10/kafka-broker-log-without-sendfile.png)

思考： Page Cache 的作用？从磁盘读取 File，详细过程？几个 Cache？


Kafka Broker 利用sendfile系统调用，`zero-copy`(零拷贝)，批量传输数据：

![](/images/apache-kafka-10/kafka-broker-log-with-sendfile.png)

### broker log 数据存储

Kafka 上 log 的磁盘持久化存储过程。

Kafka - topic - partition 的存储关系：

* 一个 partition 对应一个`文件夹`
* 一个 partition 分为多个 segment
	* segment 命名：`offset.log`
	* segment 对应一个 index 文件

补充： 属于同一个 Topic 的 partition，只能通过`文件夹名称`前缀来识别，即，partition 对应文件夹的上一层，并没有 topic 对应的文件夹。

**核心问题**：一个 Topic 的 一个 partition，如何快速 seek 到任意 offset

![](/images/apache-kafka-10/kafka-log-file.png)

## 小结

* 支持同步复制和异步复制
* sendFile 系统调用，实现零拷贝（zero-copy）
* 磁盘持久化：partition 文件夹下，分为多个 segment，每个 segment 对应一个 index 文件，记录 offset 跟磁盘物理位置的关系
* pull 模式：不需要感知 Consumer 消费状态，控制简单
* broker 无状态

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





