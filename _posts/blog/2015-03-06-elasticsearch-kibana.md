---
layout: post
title: Kafka、ElasticSearch、Kibana实现日志分析平台
description: 看到专业内的东西，尝试建一个demo
categories: kafka elasticsearch kibana
---


##基本思路

几点：

* 对知识盲区清理，形成基本轮廓，先理念、后操作：
	* ElasticSearch
	* Kibana
	* Logstash：TODO
* 敲定路线图
	* 现有资源和条件
	* 设立目标
	* 框架细化
* 反复测试、开阔视野
	* 当前demo的缺陷
	* 前人的做法

##路线图


具体步骤，几点：

* Kafka中数据送入ElasticSearch
	* Flume从Kafka中取数
	* Flume将取来的数，送入ElasticSearch
* Kibana图形化展示ElasticSearch中的数据


##具体操作

###Flume从Kafka中读取数据


当前从Jira上得知，Flume 1.6.0 中将包含Flume-ng-kafka-source，但是，当前Flume 1.6.0版本并没有发布，怎么办？两条路：

* github上别人开源的Flume-ng-kafka-source
* flume 1.6.0分支的代码中flume-ng-kafka-source

初步选定Flume 1.6.0分支中的flume-ng-kafka-source部分，









##参考来源

* [ElasticSearch中文发行版][ElasticSearch中文发行版]
* [ElasticSearche权威指南][ElasticSearche权威指南]
* [精通 ElasticSearch][精通 ElasticSearch]
* [Kibana中文指南][Kibana中文指南]











[NingG]:    http://ningg.github.com  "NingG"

[ElasticSearch中文发行版]:			https://github.com/medcl/elasticsearch-rtf
[ElasticSearche权威指南]:			http://fuxiaopang.gitbooks.io/learnelasticsearch/
[精通 ElasticSearch]:				http://shgy.gitbooks.io/mastering-elasticsearch/
[Kibana中文指南]:					http://kibana.logstash.es/












