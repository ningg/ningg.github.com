---
layout: post
title: Flume实现将Kafka中数据传入ElasticSearch中
description: 
categories: flume kafka elasticsearch
---

目标：利用Flume Agent实现，将Kafka中数据取出，送入ElasticSearch中。

分析：Flume Agent需要的工作，两点：

* Flume Kafka Source：负责从Kafka中读取数据；
* Flume ElasticSearch Sink：负责将数据送入ElasticSearch；

当前Flume 1.5.2已经包含了ElasticSearchSink，因此，需要定制实现Flume Kafka Source即可。当前从Jira上得知，Flume 1.6.0 中将包含Flume-ng-kafka-source，但是，当前Flume 1.6.0版本并没有发布，怎么办？两条路：

* github上别人开源的Flume-ng-kafka-source
* flume 1.6.0分支的代码中flume-ng-kafka-source

初步选定Flume 1.6.0分支中的flume-ng-kafka-source部分，这部分代码已经包含在[flume-ng-extends-source][flume-ng-extends-source]。

##编译代码

执行命令：`mvn clean package`得到jar包：`flume-ng-extends-source-x.x.x.jar`。


##安装插件

两类jar包：

* lib中jar包
	* `flume-ng-extends-source-x.x.x.jar`
* libext中jar包
	* `kafka_2.9.2-0.8.2.0.jar`
	* `kafka-clients-0.8.2.0.jar`
	* `metrics-core-2.2.0.jar`
	* `scala-library-2.9.2.jar`
	* `zkclient-0.3.jar`

**疑问**：maven打包时，如何将当前jar包以及其依赖包都导出？
参考[thilinamb flume kafka sink](https://github.com/thilinamb/flume-ng-kafka-sink)

##配置

在properties文件中进行配置，配置样本文件：

	# Kafka Source For retrieve from Kafka cluster.
	agent.sources.seqGenSrc.type = com.github.ningg.flume.source.KafkaSource
	#agent.sources.seqGenSrc.batchSize = 2
	agent.sources.seqGenSrc.batchDurationMillis = 1000
	agent.sources.seqGenSrc.topic = good
	agent.sources.seqGenSrc.zookeeperConnect = 168.7.2.164:2181,168.7.2.165:2181,168.7.2.166:2181
	agent.sources.seqGenSrc.groupId = elasticsearch
	#agent.sources.seqGenSrc.kafka.consumer.timeout.ms = 1000
	#agent.sources.seqGenSrc.kafka.auto.commit.enable = false

	# ElasticSearchSink for ElasticSearch.
	agent.sinks.loggerSink.type = org.apache.flume.sink.elasticsearch.ElasticSearchSink
	agent.sinks.loggerSink.indexName = flume
	agent.sinks.loggerSink.indexType = log
	agent.sinks.loggerSink.batchSize = 100
	#agent.sinks.loggerSink.ttl = 5
	agent.sinks.loggerSink.client = transport
	agent.sinks.loggerSink.hostNames = 168.7.1.69:9300
	#agent.sinks.loggerSink.client = rest
	#agent.sinks.loggerSink.hostNames = 168.7.1.69:9200
	#agent.sinks.loggerSink.serializer = org.apache.flume.sink.elasticsearch.ElasticSearchLogStashEventSerializer



##定制

目标：定制ElasticSearchSink的serializer。

现象：设置ElasticSearchSink的参数`batchSize=1000`后，当前ES中当天的Index中出现了`120,000`+的记录，而此时，原有平台发现，当前产生的数据只有`20,000`，因此，猜测KafkaSource将Kafka集群中指定topic下的所有数据都传入了ES中。


几点：

ElasticSearchSink中新的配置参数：

* indexNameBuilder=org.apache.flume.sink.elasticsearch.TimeBasedIndexNameBuilder
	* 上述将以`indexPrefix`-`yyyy-MM-dd`方式，每天产生一个Index；
	* 其他选项：org.apache.flume.sink.elasticsearch.SimpleIndexNameBuilder，其直接以设定的`indexPrefix`（实际就是设置的`indexName`）
* dateFormat=`yyyy-MM-dd`
* timeZONE=`Etc/UTC`
* serializer=org.apache.flume.sink.elasticsearch.ElasticSearchLogStashEventSerializer
	* 上述选项，将 flume event 的 Header 中 key-value 添加到一个新增的字段`@fields`中；
	* 其他选项：org.apache.flume.sink.elasticsearch.ElasticSearchDynamicSerializer，其直接将body、header构造为一个JSON字符串，添加到ElasticSearch中。














[NingG]:    						http://ningg.github.com  "NingG"
[flume-ng-extends-source]:			https://github.com/ningg/flume-ng-extends-source












