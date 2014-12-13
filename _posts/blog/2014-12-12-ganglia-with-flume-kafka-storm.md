---
layout: post
title:	Ganglia监控Flume、Kafka、Storm
description:	存在感对于每个人的生活有多么的重要，可能平时并不是太关注，其实他就是生活的全部
categories: ganglia flume kafka storm
---

##背景

通常利用Flume、Kafka、Storm来搭建实时的日志分析系统，那如何对这一系统运行状态进行监控呢？赶快调研一下，看看业内其他人怎么做的监控，当前能够查到的唯品会工程师`Yaobaniu`对外分享的实时日志分析平台材料，初步可以推断其使用Zabbix进行的监控，因为`baniu`在PPTV工作时，主要工作就是专注利用Zabbix进行集群监控，并且在`baniu`的其他分享资料中，见到过Zabbix监控界面的截图，so，初步推断是Zabbix。不过，本文将采用Ganglia来进行监控，原因很简单：

* 没有Zabbix的使用经验；
* Flume官网中有利用Ganglia监控Flume运行状态的介绍；
* Kafka、Storm的ecosystem中也见到了与Ganglia结合的身影；

##前期准备

在阅读本文之前，要求对Ganglia的安装配置有一个基本的了解，具体要了解几点：

* 安装Ganglia集群；
* gmond的配置文件`gmond.conf`；
* gmetad的配置文件`gmetad.conf`；

上面的内容，可以参考自己之前的几篇博文：

（ganglia的整个系列）

##软件版本

|软件|版本|
|--|--|
|Flume	|apache-flume-1.5.0.1-bin.tar.gz  | 
|Kafka	|kafka_2.9.2-0.8.1.1.tgz| 
|Storm	|apache-storm-0.9.2-incubating.tar.gz | 
|Ganglia| | 




##Ganglia with Flume


Flume的官网上[Monitoring][Flume doc：Monitoring]部分，显示通过简单配置，即可完成Ganglia对Flume的监控，关于具体细节，参考阅读[Flume user-guide-monitoring][Flume user-guide-monitoring]。

同时Flume的监控问题，在JIRA上也有较广泛的讨论，为开拓思路，也可以看看[jira Flume][jira Flume]。




##Ganglia with Kafka

本文将描述一下，围绕“利用Ganglia监控Kafka”这一问题，如何思考、如何分析、如何搜索解决方案。

###分析

直接列一下，分析、查找途径：

* 查看Kafka的[官方文档][Kafka doc：Monitoring]其中提到了Monitoring，是利用`Yammer Metrics`来收集数据的，并且列出了一些需要着重关注的指标；
* [Kafka ecosystem][Kafka ecosystem]中查看到[Ganglia Integration][Ganglia Integration]；
* [Ganglia cwiki][Ganglia cwiki]中查看到[JMX reporters][JMX reporters]，并在其下查看到[kafka-ganglia][kafka-ganglia]；
* 浏览[jira Kafka][jira Kafka]，大部分涉及到Kafka Ganglia的内容为bug修复，版本升级；


上面是对整个Kafka官网的初步查询结果，从中可以看到，已经有利用Ganglia监控Kafka的监控方案了，具体有两个：

* [Ganglia Integration][Ganglia Integration]；
	* 利用JMXTrans来收集Kafka运行状态；
	* 通过Json来配置，收集指定的Kafka运行状态数据；
	* 调整gweb页面；
	* 最后更新时间：2013.06
* [kafka-ganglia][kafka-ganglia]；
	* 利用Kafka官网提到的Yammer Metrics收集到的数据；
	* 利用metrics-ganglia.jar将Yammer Metrics收集的数据发送到Ganglia展示；
	* 最后更新时间：2014.01

###kafka-ganglia(criteo)
	
由于最新工程对当前版本兼容性可能更好，以及与Kafka利用Yammer Metrics机制保持一致，初步决定采用[kafka-ganglia][kafka-ganglia]工程。拿到这一工程后，利用Maven对其进行构建，不过我本地测试需要调整一下`artifactId=scalatest_2.9.2`的版本：

	<dependency>
      <groupId>org.scalatest</groupId>
      <artifactId>scalatest_2.9.2</artifactId>
      <version>1.7.2</version>
      <scope>test</scope>
    </dependency>

不过其中涉及到一个情况：ganglia web上显示收集到的Kafka指标过多，近`1k+`，过于臃肿，需要进行定制和过滤；

* 筛选出能够反映Kafka集群运行状态的关键指标；
* 如果指标为Yammer metrics中的meter类别，针对单个指标分析需要过滤的项，并定制进行过滤，不要显示在ganglia web上；

经过自己简单分析，上面两个问题都有解决的办法：

* 依照官网[Kafka doc：Monitoring][Kafka doc：Monitoring]中提到的特别需要关注的参数，进行提炼之后，借助[kafka-ganglia][kafka-ganglia]中的`exclude.regex`机制来过滤掉不需要的参数，另外，需要特别注意criteo在实现的时候，利用的是`matcher.matches()`方法，其尝试匹配整个Metric name；*（利用matcher.find()方法时，匹配的是是否找到这一参数）*
* 定制[kafka-ganglia][kafka-ganglia]中的`exclude.regex`机制，如果需要监控的参数很少，则实现`include`机制，可以利用Regular Exp，也可以使用Set机制；
* 对于筛选出的特定参数，如果其是Yammer Metrics中的meter类型，则其中包含了`count`、`mean rate`、`1-min rate`、`5-min rate`、`15-min rate`共计5个指标，那这些指标是有些重复的，原因是Ganglia提供了对一个参数的长期监控，例如`1-min rate`就可以推测出`5-min rate`等。通过初步分析，认为保留`count`和`1-min rate`指标即可。那代码上如何实现？初步分析，认为重写`metrics-ganglia-2.2.0.jar`中的`com.yammer.metrics.reporting`包内的`GangliaReporter`类即可。*（此想法只是指出方向，并未进行实际验证）*

###Ganglia Integration(adambarthelson)

（doing...）

从上以部分发现，如果利用`metrics-ganglia-2.2.0.jar`来实现Ganglia对Kafka的监控，有几个方面需要定制，涉及到一些定制的工作量。而[Ganglia Integration][Ganglia Integration]好像可以直接通过Json文件来指定收集特定的参数，涉及到的定制可能会较少。

（doing...）

初步计划，在配置完Ganglia对Storm的监控时，学习一下jmxtrans的基本知识，然后回过头来，再来尝试一下[Ganglia Integration][Ganglia Integration]。






##Ganglia with Storm

如何找到Ganglia监控Storm的方法？找到方法后，具体如何进行操作？

###分析

对于ASF（Apache Software Foundation，Apache软件基金会）下的opensource项目，我个人认为有几个信息源：

* open-source项目的官网：`http://***.apache.org`；
* Apache的Confluence网站：`http://cwiki.apache.org/`；
* Apache在Jira上进行的问题讨论：`https://issues.apache.org/`；
* google search；

此次查询如何利用Ganglia来监控Storm，还按照这几个信息源来查询：

* 官网中，只找到如下几个来源，monitoring Storm相关：
	* [setup a storm cluster][setup a storm cluster]
	* [running topol on prod cluster][running topol on prod cluster]
* google查到相关内容如下：
	* [BOOK-Learning Storm][BOOK-Learning Storm]*（通过某种合法方式，拿到了这本书的草稿版）*
	* [Monitoring Storm][Monitoring Storm]

其中[BOOK-Learning Storm][BOOK-Learning Storm]详细介绍了Ganglia监控Storm的具体操作步骤，其基本原理是利用jmxtrans*（从哪收集的运行数据？谁负责发送给Ganglia？）*

###Ganglia监控Storm

> 这一部分参考自[BOOK-Learning Storm][BOOK-Learning Storm]，细微的地方做出调整。

Storm doesn't have built-in support to monitor the Storm cluster using Ganglia. However, with
jmxtrans, you can enable Storm monitoring using Ganglia. The `jmxtrans` tool allows you to
connect to any JVM and fetches its JVM metrics without writing a single line of code. The JVM
metrics exposed via JMX can be displayed on Ganglia using jmxtrans. Hence, jmxtrans acts as a
bridge between Storm and Ganglia.

![](/images/learning-storm/jmxtrans-ganglia.png)

需要在Storm运行的节点上安装jmxtrans：

（自己有一篇单独介绍jmxtrans的博客，给个链接）


####supervisor.json


	{
		"servers": [
			{
				"port": "12346", 
				"host": "IP_OF_SUPERVISOR_MACHINE", 
				"queries": [
					{
						"outputWriters": [
							{
								"@class": "com.googlecode.jmxtrans.model.output.GangliaWriter", 
								"settings": {
									"groupName": "supervisor", 
									"host": "IP_OF_GANGLIA_GMOND_SERVER", 
									"port": "8649"
								}
							}
						], 
						"obj": "java.lang:type=Memory", 
						"resultAlias": "supervisor", 
						"attr": [
							"ObjectPendingFinalizationCount"
						]
					}, 
					{
						"outputWriters": [
							{
								"@class": "com.googlecode.jmxtrans.model.output.GangliaWriter", 
								"settings": {
									"groupName": " supervisor ", 
									"host": "IP_OF_GANGLIA_GMOND_SERVER", 
									"port": "8649"
								}
							}
						], 
						"obj": "java.lang:name=Copy,type=GarbageCollector", 
						"resultAlias": " supervisor ", 
						"attr": [
							"CollectionCount", 
							"CollectionTime"
						]
					}, 
					{
						"outputWriters": [
							{
								"@class": "com.googlecode.jmxtrans.model.output.GangliaWriter", 
								"settings": {
									"groupName": "supervisor ", 
									"host": "IP_OF_GANGLIA_GMOND_SERVER", 
									"port": "8649"
								}
							}
						], 
						"obj": "java.lang:name=Code Cache,type=MemoryPool", 
						"resultAlias": "supervisor ", 
						"attr": [
							"CollectionUsageThreshold", 
							"CollectionUsageThresholdCount", 
							"UsageThreshold", 
							"UsageThresholdCount"
						]
					}, 
					{
						"outputWriters": [
							{
								"@class": "com.googlecode.jmxtrans.model.output.GangliaWriter", 
								"settings": {
									"groupName": "supervisor ", 
									"host": "IP_OF_GANGLIA_GMOND_SERVER", 
									"port": "8649"
								}
							}
						], 
						"obj": "java.lang:type=Runtime", 
						"resultAlias": "supervisor", 
						"attr": [
							"StartTime", 
							"Uptime"
						]
					}
				], 
				"numQueryThreads": 2
			}
		]
	}









##杂谈

"见自己，见天地，见众生"，突然想到这句话，说是排rank大多是年轻人的想法，而实际上绝大部分有点成绩的人最后都殊途同归：见众生；做对众生有用、有益的事情。




[NingG]:    						http://ningg.github.com  "NingG"
[Kafka doc：Monitoring]:			http://kafka.apache.org/documentation.html#monitoring
[Kafka ecosystem]:					https://cwiki.apache.org/confluence/display/KAFKA/Ecosystem
[Ganglia Integration]:				https://github.com/adambarthelson/kafka-ganglia
[Ganglia cwiki]:					https://cwiki.apache.org/confluence/display/KAFKA/Index
[JMX reporters]:					https://cwiki.apache.org/confluence/display/KAFKA/JMX+Reporters
[kafka-ganglia]:					https://github.com/criteo/kafka-ganglia
[jira Kafka]:						https://issues.apache.org/jira/browse/KAFKA

[Flume doc：Monitoring]:			https://flume.apache.org/FlumeUserGuide.html#monitoring
[Flume user-guide-monitoring]:		/flume-user-guide-monitoring
[jira Flume]:						https://issues.apache.org/jira/browse/FLUME



[setup a storm cluster]:			http://storm.apache.org/documentation/Setting-up-a-Storm-cluster.html
[running topol on prod cluster]:	http://storm.apache.org/documentation/Running-topologies-on-a-production-cluster.html
[BOOK-Learning Storm]:				https://www.safaribooksonline.com/library/view/learning-storm/9781783981328/
[Monitoring Storm]:					https://blog.relateiq.com/monitoring-storm/



