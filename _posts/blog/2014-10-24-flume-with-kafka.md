---
layout: post
title: Flume 1.5.0.1：如何将flume聚合的数据送入Kafka
description: Flume负责数据聚合，Kafka作为消息队列，需要接收Flume发来的消息
categories: flume kafka big-data
---

##背景

Flume收集分布在不同机器上的日志信息，聚合之后，将信息送入Kafka消息队列，问题来了：如何将Flume输出的信息送入Kafka中？


##




##Flume复习



###几个概念



* Flume event: a unit of data flow, having a byte payload and an optional set of string attributes.（event中包含了，payload和attributes）
* Flume agent: a (JVM) process, that hosts the components through which events flow from an external source to the next destination(hop).（agent对应JVM process）
* Channel:  passive store, keeps the event until it's consumded by a Flume Sink.（Channel不会主动消费event，其等待Sink来取数据，会在本地备份Event）
* Sink: remove the event from the channel and put it into external repository.（Sink主动从Channel中取出event）

![](/images/flume-user-guide/UserGuide_image00.png) 




