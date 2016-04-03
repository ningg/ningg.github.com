---
layout: post
title: Flume、Kafka、Storm小结
description: Flume(apache-flume-1.5.0.1)、Kafka()、Storm()这三个东西都研究一段时间了，做个阶段性小结
categories: flume kafka storm 
---

## Flume

### 可靠性和可恢复性

#### Reliability

The events are staged in a channel on each agent. The events are then delivered to the next agent or terminal repository (like HDFS) in the flow. The events are removed from a channel only after they are stored in the channel of next agent or in the terminal repository. This is a how the single-hop message delivery semantics in Flume provide end-to-end reliability of the flow.（**single-hop message delivery semantics**：Channel中的event仅在被成功处理之后，才从Channel中删掉。）

Flume uses a transactional approach to guarantee the reliable delivery of the events. The sources and sinks encapsulate in a transaction the storage/retrieval, respectively, of the events placed in or provided by a transaction provided by the channel. This ensures that the set of events are reliably passed from point to point in the flow. In the case of a multi-hop flow, the sink from the previous hop and the source from the next hop both have their transactions running to ensure that the data is safely stored in the channel of the next hop.（**multi-hop**：）

**notes(ningg)**：Flume如何保证事物操作？没看懂

#### Recoverability

The events are staged in the channel, which manages recovery from failure. Flume supports a durable file channel which is backed by the local file system. There’s also a memory channel which simply stores the events in an in-memory queue, which is faster but any events still left in the memory channel when an agent process dies can’t be recovered.（Channel需保证崩溃后，能恢复events，具体：本地FS上保存durable file channel，另，占用一个in-memory queue，Channel进程崩溃后，能加快恢复速度；但，如果agent进程崩溃，将导致内存泄漏：无法回收这一内存）



## Kafka

（TODO List）

（Kafka集群涉及到的可扩展性和可靠性）



## Storm

（TODO List）

（Storm集群相关的可扩展性和可靠性）



## Flume/Kafka/Storm框架性能测试

简要说一下，性能测试的目标：弄清楚整个框架的承载能力，到底能处理多达流量的数据。

### 前期问题

几个搭建测试环境相关的问题：

* **Flume集群与Kafka集群之间**，**是否要走网络**？简要来说，Flume集群的最后一个聚合的Agent是否要放置到Kafka即群里？
	* **RE**：Flume的最后一个负责聚合的Agent即使放置在某个Kafka broker上，仍然是要走网络的，因为Kafka本身就是一个集群，Flume的Kafka Sink与其他Kafka broker连接时，走的也是网络；

* **Flume收集的数据源**，**是否同时包含IP:port和日志**？Flume提供了从这两种source收集数据的能力，测试的时候要覆盖到。

## 搭建测试环境步骤

* 实现Flume集群；
	* 165、166收集数据，并以avro方式汇聚到167；
	* 167上以logger方式将收到的message输出到stdout；
* 实现Kafka集群；
	* 配置每一个 Kafka broker 的 id 以及 zookeeper 集群；
	* 将167上Flume agent的sink修改为Flume Kafka Sink；
	* 

### 测试方案列表



#### zookeeper集群

当前使用的是CDH中自带的zookeeper：

* 节点位置：
	* 168.7.1.68:2181
	* 168.7.1.69:2181
	* 168.7.1.70:2181

**notes(ningg)**：zookeeper集群的基本原理，如何监控其性能？

#### Flume集群

* 节点位置：
	* 168.7.2.165: 21811
	* 168.7.2.166: 21811
	* 168.7.2.167: 21811（作为聚合的Agent）
* 下载路径和版本信息：
	* 下载路径：http://flume.apache.org/download.html
	* 版本信息：apache-flume-1.5.0.1-bin

Flume的配置文件需要考虑几点：

* source包含两个：Exec Source、NetCat Source、avro Source；
* Sink包含：logger Sink、avro Sink、Flume Kafka Sink；

**notes(ningg)**：一个问题，使用Exec Source来进行收集数据时，有一种情况，如果`tail -F`命令意外终止了，Flume无法自动重启这一命令，原因：Flume无法确定是文件没有新增信息，还是tail命令意外终止；为解决这一问题，官网有两个建议：

* 使用Spooling Directory Source，不过这个Source也有一个问题，他要求将文件添加到一个固定目录，这就会造成信息传递的实时性降低；
* 通过JDK直接与Flume集成；

**个人想法**：官网给出的信息很权威，不过可以到官网的JIRA上看看，其他人也遇到这个问题，应该会有其他思路。


#### Kafka集群

* 节点位置：
	* 168.7.2.165:9091
	* 168.7.2.166:9091
	* 168.7.2.167:9091
* 下载路径和版本信息：
	* 下载路径：http://kafka.apache.org/downloads.html
	* 版本信息：kafka_2.9.2-0.8.1.1

**notes(ningg)**：有几个疑问：

* 如何确定当前Kafka集群中broker存活状态？
* Kafka运行过程中，可定制的输出日志有哪些？输出日志位置？

#### Storm集群

* 节点位置：
	* 168.7.1.68:2181
	* 168.7.1.69:2181
	* 168.7.1.70:2181

**notes(ningg)**：如何构建Storm集群？


## 问题汇总

* Flume、Kafka、Storm构成框架，如何监控每个模块的存活状态和性能？如何确定系统处理的瓶颈位置？

## 参考来源












[NingG]:    http://ningg.github.com  "NingG"










