---
layout: post
title: Apache Kafka 实践：ZK 上存储的数据结构
description: Kafka 集群，依赖 ZK 进行分布式协调；Kafka 集群场景下， ZooKeeper 的节点上存储了哪些信息？存储在哪些节点上呢？
published: true
category: kafka
---


## 1.背景

Kafka 集群，依赖 ZK 进行分布式协调。Kafka 集群场景下，ZooKeeper 的典型作用：

1. Partition 的 leader 指定
1. Partition 的 offset 记录
1. Consumer Group 和 Consumer 登记

当前文档，将专注于：分析 Kafka 集群场景下， ZooKeeper 的节点上存储了哪些信息？存储在哪些节点上？

特别说明：下文围绕 `Kafka 0.10.x` 版本进行讨论.

## 2.ZooKeper 节点剖析

Note：考虑针对 ZK 的使用和底层原理，进行一次分享。

### 2.1.ZK Client 连接

获取 ZK Server 地址后，通过下述命令连接到 ZK Server：

```
# 连接到 ZK Server
$bin/zkCli.sh -server localhost:2181
```


查看指定节点的信息：

```
# 查看指定节点的「子节点」信息
[zk: localhost:2181(CONNECTED) 0] ls /
[cluster, controller, brokers, storm, zookeeper, storm_bikelife_new, admin, isr_change_notification, storm_applog, storm_bikeapi, storm_wechatlog_new, controller_epoch, storm_bikeapi_new, storm_applog_new, storm_wechatlog, consumers, ambari-metrics-cluster, storm_users_new, config]
 
# 查看指定节点的自身存储的信息
[zk: localhost:2181(CONNECTED) 0] get /consumers/logstash_es/offsets/applog/1
4543272512
cZxid = 0x2000025cb
ctime = Sun Jun 04 23:09:35 CST 2017
mZxid = 0x302e61ee4
mtime = Sun Aug 20 18:22:21 CST 2017
pZxid = 0x2000025cb
cversion = 0
dataVersion = 5715022
aclVersion = 0
ephemeralOwner = 0x0
dataLength = 10
numChildren = 0
 
# 退出
[zk: localhost:2181(CONNECTED) 0] quit
Quitting...
```

### 2.2.Kafka 存储的信息

Kafka 有几类信息存储在 ZK 上，涵盖：

1. **Broker**：存活的 broker
1. **Topic**：现有的 topic，以及 Topic 下的 partition
1. **Consumer**：现有的 Consumer Group 以及 consumer owner

具体上述几类信息对应 ZK 上节点位置：

```
# brokers 信息
ls /brokers/ids
 
# topic 信息
ls /brokers/topics
 
# topic 下的 partition 信息（Note：下面命令中 applog 为 topic）
ls /brokers/topics/applog/partitions
 
# Consumer Group
ls /consumers
 
# Consumer owner（Note：下面命令中 logstash_es 为 Consumer Group， applog 为 topic，0 为 partition ）
get /consumers/logstash_es/owners/applog/0
```

细节太多，Kafka 集群在 ZK 上存储的信息，查看下图：

![](/images/apache-kafka-10/kafka-zk-data-structure.png)

## 3.参考资料

* [Kafka data structures in Zookeeper](https://cwiki.apache.org/confluence/display/KAFKA/Kafka+data+structures+in+Zookeeper)
* [http://kafka.apache.org/documentation.html#impl_zookeeper](http://kafka.apache.org/documentation.html#impl_zookeeper)
* [https://github.com/apache/kafka](https://github.com/apache/kafka)














[Kafka 官网]:		http://kafka.apache.org/
[Kafka 官网-Quickstart]:		http://kafka.apache.org/quickstart
[Kafka 设计解析-郭俊]:		http://www.jasongj.com/categories/Kafka/
[Learning Apache Kafka(2nd Edition)]:		http://file.allitebooks.com/20150612/Learning%20Apache%20Kafka,%202nd%20Edition.pdf
[Kafka a Distributed Messaging System for Log Processing]:	http://docs.huihoo.com/apache/kafka/Kafka-A-Distributed-Messaging-System-for-Log-Processing.pdf
[NingG]:    http://ningg.github.com  "NingG"

