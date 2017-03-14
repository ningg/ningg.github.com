---
layout: post
title: Apache Kafka 0.10 技术内幕：安装 Kafka
description: 重新梳理一遍 Kafka，从安装 Kafka 集群开始
published: true
category: kafka
---

## 背景

之前一直使用 Kafka，并且在针对 Kafka 的内部实现机制，进行了 2 次分享。每次分享过程中，针对 Kafka 的介绍很详细，但是，分享的时间毕竟是短暂的，后面仍有很多同事会一起来讨论一些细节。为了方便个人积累的规模化复制，方便其他人不限时间、不限地点的查阅，因此，准备写一个 Kafka 系列。

在线分享自己对 Kafka 的理解，也方便大家交流讨论。

## 概要

现在 Kafka 已经出了 0.10.x，是最新的版本，几个问题：

1. Kafka 是什么，能用来做什么？
2. 如何搭建 Kafka 运行环境，体验 Kafka 的使用和概念

要琢磨 Kafka，首先需要收集资料，第一首的资料就是官网，这个不能少，除此之外，还有市面上的书籍，汇总所有资料如下：

* [Kafka 官网]
* [Kafka a Distributed Messaging System for Log Processing]
* [Learning Apache Kafka(2nd Edition)]
* [Kafka 设计解析-郭俊]

补充说明：因为 Kafka 已经演进到了 0.10.x 版本，而一些文章是针对 0.7.x～0.9.x 版本的 Kakfa 写的，因此，这一系列文章都将主要依靠 [Kafka 官网] 作为最主要的参考资料。

## Kafka 是做什么的？

[Kafka 官网] 对 Kafka 定位： 一个消息队列（Message Queue），高效、分布式、实时的消息队列。

1. 可伸缩：水平扩展，很好的伸缩性
2. 高可用：部分节点宕机，仍能提供服务
3. 速度快：数据的存储和读取速度快


> 现在 Kafka 0.10.x 版本，官网对 Kafka 的定位：`分布式`、`流式`平台。有`缓冲功能`的数据流`管道`。

Kafka 在最初 MQ 的基本结构上，增加了扩展功能：

* Stream Processors：流式处理器，从一些 Topic 中读取数据，处理后，送入另一些 Topic 中
* Connectors：连接器，与其他数据源之间同步数据，例如，MySQL 向 Kafka 同步数据，Kafka 向 MySQL 同步数据

基本的 MQ 结构：

* Producers：消息的生产者
* Consumers：消息的消费者

Kafka 具体结构：

![](/images/apache-kafka-10/kafka-apis.png)

特别说明：

> Apache Kafka 0.7.x~0.8.x 中，并没有提到 Stream Processors 和 Connectors。


## 搭建 Kafka 运行环境(单节点模式)

这一部分，主要参考： [Kafka 官网-Quickstart] 来操作。

### 下载

[下载](http://kafka.apache.org/downloads) Kafka 源码包，并且解压：

```
> tar -xzf kafka_2.11-0.10.2.0.tgz
> cd kafka_2.11-0.10.2.0
```

### 启动

Kafka 集群的运行，需要依赖 ZooKeeper 集群，如果没有ZooKeeper 集群，则，使用下述命令，先启动一个 ZK 集群：

```
// 先启动一个 ZK 集群（实际是一个单节点的 ZK 集群）
> bin/zookeeper-server-start.sh config/zookeeper.properties
[2017-03-13 23:43:08,455] INFO Reading configuration from: config/zookeeper.properties (org.apache.zookeeper.server.quorum.QuorumPeerConfig)
```

启动 Kafka 集群（单节点）：

```
> bin/kafka-server-start.sh config/server.properties
[2017-03-13 23:44:45,309] INFO starting (kafka.server.KafkaServer)
[2017-03-13 23:44:45,312] INFO Connecting to zookeeper on localhost:2181 (kafka.server.KafkaServer)
...
[2017-03-13 23:44:46,068] INFO New leader is 0 (kafka.server.ZookeeperLeaderElector$LeaderChangeListener)
[2017-03-13 23:44:46,086] INFO Kafka version : 0.10.2.0 (org.apache.kafka.common.utils.AppInfoParser)
[2017-03-13 23:44:46,086] INFO Kafka commitId : 576d93a8dc0cf421 (org.apache.kafka.common.utils.AppInfoParser)
[2017-03-13 23:44:46,087] INFO [Kafka Server 0], started (kafka.server.KafkaServer)
```

### 创建 Topic

创建 Topic：（Kafka 集群中，数据是以 Topic 分类的）

```
> bin/kafka-topics.sh --create --zookeeper localhost:2181 --replication-factor 1 --partitions 1 --topic test
Created topic "test".
```
查询 Kafka 集群上，现有的 Topic：

```
> bin/kafka-topics.sh --list --zookeeper localhost:2181
test
```

### 产生消息

向 Kafka 集群的 Topic 内，送入消息：（使用 Kafka 自带 producer.sh 脚本，默认一行输入为一条 Message）

```
> bin/kafka-console-producer.sh --broker-list localhost:9092 --topic test
hello !
你好！
```

### 消费消息

从 Kafka 集群的指定 Topic 内，读取消息：

```
> bin/kafka-console-consumer.sh --bootstrap-server localhost:9092 --topic test --from-beginning
hello !
你好！
```

## 搭建 Kafka 运行环境(集群模式)

参考： [Kafka 官网-Quickstart] 来操作；具体涵盖的内容：

1. 搭建 Kafka 集群
2. 创建包含多个副本的 Topic
3. 查看 Topic 中，每个 partition 对应多副本所在 Broker 的 Leader-Follower 角色
4. 强制 kill 掉 Leader 所在的 Broker，观察 Leader 自动故障转移

此外，还有：

1. 尝试使用 Connector：
	1. Source Connector：从外部文件读取数据，存入到 Kafka 中；
	2. Sink Connector：将 Kafka 中数据，转存到文件中；
2. 尝试使用 Stream Processor



## 参考资料

* [Kafka 官网]
* [Kafka a Distributed Messaging System for Log Processing]
* [Learning Apache Kafka(2nd Edition)]
* [Kafka 设计解析-郭俊]






[Kafka 官网]:		http://kafka.apache.org/
[Kafka 官网-Quickstart]:		http://kafka.apache.org/quickstart
[Kafka 设计解析-郭俊]:		http://www.jasongj.com/categories/Kafka/
[Learning Apache Kafka(2nd Edition)]:		http://file.allitebooks.com/20150612/Learning%20Apache%20Kafka,%202nd%20Edition.pdf
[Kafka a Distributed Messaging System for Log Processing]:	http://docs.huihoo.com/apache/kafka/Kafka-A-Distributed-Messaging-System-for-Log-Processing.pdf
[NingG]:    http://ningg.github.com  "NingG"





