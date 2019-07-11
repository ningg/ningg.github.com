---
layout: post
title: Apache Kafka 实践：重置 offset
description: 突发情况，需要重置指定 consumer group 的 offset
published: true
category: kafka
---


## 1.概要

* **背景**：线上环境在消费 Kafka 中数据，因为突发情况，需要重置 consumer group 对应的 offset。
* **目标**：重置对应 consumer group 的 offset。

## 2.重置 Offset

几个方面：

1. 情况收集：
	1. 哪个 Consumer Group
	1. 消费哪些 Topic
	1. 当前 Topic 和 Consumer Group 对应的 offset 都是多少
1. Offset 处理：
	1. 存储位置：consumer group 对应 offset 的存储位置
	1. 设置 Offset：如何设置 Offset？ 

直接查看当前的 offset：

```
./kafka-consumer-groups.sh --bootstrap-server kafka1.hdp.ningg.cn:9092 --describe --group pull-for-abacus-prod
TOPIC                          PARTITION  CURRENT-OFFSET  LOG-END-OFFSET  LAG        CONSUMER-ID                                       HOST                           CLIENT-ID
binlog.test_pay.test_refund      6          1472114         1472114         0          consumer-1-78074b08-5232-42d7-9a7a-68349f856095   /10.1.187.47                   consumer-1
binlog.test_pay.test_refund      7          1474380         1474380         0          consumer-1-78074b08-5232-42d7-9a7a-68349f856095   /10.1.187.47                   consumer-1
binlog.test_pay.test_refund      0          1470473         1470476         3          consumer-1-1b0855c5-404f-4eec-8c40-dfebc435faba   /10.30.173.144                 consumer-1
binlog.test_pay.test_refund      1          1474526         1474529         3          consumer-1-1b0855c5-404f-4eec-8c40-dfebc435faba   /10.30.173.144                 consumer-1
binlog.test_pay.test_refund      4          1472482         1472482         0          consumer-1-5d8f9bdc-af6f-4f6a-9f54-2a371c4cbc8b   /10.30.125.136                 consumer-1
binlog.test_pay.test_refund      5          1472702         1472707         5          consumer-1-5d8f9bdc-af6f-4f6a-9f54-2a371c4cbc8b   /10.30.125.136                 consumer-1
binlog.test_pay.test_refund      2          1473468         1473468         0          consumer-1-3875d283-6a7c-4691-8611-ca97b382c66a   /10.1.186.91                   consumer-1
binlog.test_pay.test_refund      3          1469992         1469995         3          consumer-1-3875d283-6a7c-4691-8611-ca97b382c66a   /10.1.186.91                   consumer-1
binlog.test_pay.test_refund      9          1473234         1473238         4          consumer-1-d5a49669-0c88-4b7b-b8a3-b68e379f10b6   /10.30.156.140                 consumer-1
binlog.test_pay.test_refund      8          1475842         1475842         0          consumer-1-92f73b05-b5c8-4ef3-b0c0-68243bdd4469   /10.30.149.137                 consumer-1
```

从上述查询可知，offset 没有托管在 ZK 上，而是托管在了 `__consumer_offsets` 中，因此，需要修改  `__consumer_offsets` 中的 `offset`。

Note：

* consumer group offset 在 ZK 上托管时，可以参考： [Manually resetting offset for a Kafka topic](https://community.hortonworks.com/articles/81357/manually-resetting-offset-for-a-kafka-topic.html)


在 Kafka 0.11+ 之后的版本中，提供了重置 offset 的工具：（确认：此工具也可以操作 Kafka 0.10 集群）

```
// 查看 consumer group 的 offset 状态
./kafka-consumer-groups.sh --bootstrap-server kafka1.hdp.ningg.cn:9092 --describe --group pull-for-abacus-prod
 
// 尝试重置  consumer group
./kafka-consumer-groups.sh --bootstrap-server kafka1.hdp.ningg.cn:9092 --group pull-for-abacus-prod --reset-offsets --to-earliest --all-topics
 
// 确认重置  consumer group
./kafka-consumer-groups.sh --bootstrap-server kafka1.hdp.ningg.cn:9092 --group pull-for-abacus-prod --reset-offsets --to-earliest --all-topics --execute
```

Note：

* 工具详情：[https://cwiki.apache.org/confluence/display/KAFKA/KIP-122%3A+Add+Reset+Consumer+Group+Offsets+tooling](https://cwiki.apache.org/confluence/display/KAFKA/KIP-122%3A+Add+Reset+Consumer+Group+Offsets+tooling)

完整的 kafka-consumer-groups 工具的操作选项：

```
$ ./kafka-consumer-groups.sh
List all consumer groups, describe a consumer group, delete consumer group info, or reset consumer group offsets.
Option                                  Description
------                                  -----------
--all-topics                            Consider all topics assigned to a
                                          group in the `reset-offsets` process.
--bootstrap-server <String: server to   REQUIRED (for consumer groups based on
  connect to>                             the new consumer): The server to
                                          connect to.
--by-duration <String: duration>        Reset offsets to offset by duration
                                          from current timestamp. Format:
                                          'PnDTnHnMnS'
--command-config <String: command       Property file containing configs to be
  config property file>                   passed to Admin Client and Consumer.
--delete                                Pass in groups to delete topic
                                          partition offsets and ownership
                                          information over the entire consumer
                                          group. For instance --group g1 --
                                          group g2
                                        Pass in groups with a single topic to
                                          just delete the given topic's
                                          partition offsets and ownership
                                          information for the given consumer
                                          groups. For instance --group g1 --
                                          group g2 --topic t1
                                        Pass in just a topic to delete the
                                          given topic's partition offsets and
                                          ownership information for every
                                          consumer group. For instance --topic
                                          t1
                                        WARNING: Group deletion only works for
                                          old ZK-based consumer groups, and
                                          one has to use it carefully to only
                                          delete groups that are not active.
--describe                              Describe consumer group and list
                                          offset lag (number of messages not
                                          yet processed) related to given
                                          group.
--execute                               Execute operation. Supported
                                          operations: reset-offsets.
--export                                Export operation execution to a CSV
                                          file. Supported operations: reset-
                                          offsets.
--from-file <String: path to CSV file>  Reset offsets to values defined in CSV
                                          file.
--group <String: consumer group>        The consumer group we wish to act on.
--list                                  List all consumer groups.
--new-consumer                          Use the new consumer implementation.
                                          This is the default, so this option
                                          is deprecated and will be removed in
                                          a future release.
--reset-offsets                         Reset offsets of consumer group.
                                          Supports one consumer group at the
                                          time, and instances should be
                                          inactive
                                        Has 3 execution options: (default) to
                                          plan which offsets to reset, --
                                          execute to execute the reset-offsets
                                          process, and --export to export the
                                          results to a CSV format.
                                        Has the following scenarios to choose:
                                          --to-datetime, --by-period, --to-
                                          earliest, --to-latest, --shift-by, --
                                          from-file, --to-current. One
                                          scenario must be choose
                                        To define the scope use: --all-topics
                                          or --topic. . One scope must be
                                          choose, unless you use '--from-file'
                                          scenario
--shift-by <Long: number-of-offsets>    Reset offsets shifting current offset
                                          by 'n', where 'n' can be positive or
                                          negative
--timeout <Long: timeout (ms)>          The timeout that can be set for some
                                          use cases. For example, it can be
                                          used when describing the group to
                                          specify the maximum amount of time
                                          in milliseconds to wait before the
                                          group stabilizes (when the group is
                                          just created, or is going through
                                          some changes). (default: 5000)
--to-current                            Reset offsets to current offset.
--to-datetime <String: datetime>        Reset offsets to offset from datetime.
                                          Format: 'YYYY-MM-DDTHH:mm:SS.sss'
--to-earliest                           Reset offsets to earliest offset.
--to-latest                             Reset offsets to latest offset.
--to-offset <Long: offset>              Reset offsets to a specific offset.
--topic <String: topic>                 The topic whose consumer group
                                          information should be deleted or
                                          topic whose should be included in
                                          the reset offset process. In `reset-
                                          offsets` case, partitions can be
                                          specified using this format: `topic1:
                                          0,1,2`, where 0,1,2 are the
                                          partition to be included in the
                                          process. Reset-offsets also supports
                                          multiple topic inputs.
--zookeeper <String: urls>              REQUIRED (for consumer groups based on
                                          the old consumer): The connection
                                          string for the zookeeper connection
                                          in the form host:port. Multiple URLS
                                          can be given to allow fail-over.
```


## 3.参考资料

* [https://www.ctheu.com/2017/08/07/looking-at-kafka-s-consumers-offsets/#ingest-the-json-into-druid](https://www.ctheu.com/2017/08/07/looking-at-kafka-s-consumers-offsets/#ingest-the-json-into-druid)
* [基于 Spring-Kafka 在消费 Kafka 中数据](https://docs.spring.io/autorepo/docs/spring-kafka-dist/1.1.6.BUILD-SNAPSHOT/reference/htmlsingle/#_topic_partition_initial_offset)
* [http://kafka.apache.org/documentation/#operations](http://kafka.apache.org/documentation/#operations)
* [Manually resetting offset for a Kafka topic](https://community.hortonworks.com/articles/81357/manually-resetting-offset-for-a-kafka-topic.html)： （consumer group offset 在 ZK 上托管） 









[Kafka 官网]:		http://kafka.apache.org/
[Kafka 官网-Quickstart]:		http://kafka.apache.org/quickstart
[Kafka 设计解析-郭俊]:		http://www.jasongj.com/categories/Kafka/
[Learning Apache Kafka(2nd Edition)]:		http://file.allitebooks.com/20150612/Learning%20Apache%20Kafka,%202nd%20Edition.pdf
[Kafka a Distributed Messaging System for Log Processing]:	http://docs.huihoo.com/apache/kafka/Kafka-A-Distributed-Messaging-System-for-Log-Processing.pdf
[NingG]:    http://ningg.github.com  "NingG"

