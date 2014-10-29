---
layout: post
title: Flume 1.5.0.1：如何将flume聚合的数据送入Kafka
description: Flume负责数据聚合，Kafka作为消息队列，需要接收Flume发来的消息
categories: flume kafka big-data
---

##背景

Flume收集分布在不同机器上的日志信息，聚合之后，将信息送入Kafka消息队列，问题来了：如何将Flume输出的信息送入Kafka中？

定一个场景：flume读取apache的访问日志，然后送入Kafka中，最终消息从Kafka中取出，显示在终端屏幕上（stdout）。


##Flume复习

整理一下Flume的基本知识，参考来源有两个：

* [Flume Documentation][Flume Documentation]
* Book: [apache-flume-distributed-log-collection-hadoop][apache-flume-distributed-log-collection-hadoop]

###几个概念

* Flume **event**: a unit of data flow, having a byte payload and an optional set of string attributes.（event中包含了，payload和attributes）
* Flume **agent**: a (JVM) process, that hosts the components through which events flow from an external source to the next destination(hop).（agent对应JVM process）
* **Channel**:  passive store, keeps the event until it's consumded by a Flume Sink.（Channel不会主动消费event，其等待Sink来取数据，会在本地备份Event）
* **Sink**: remove the event from the channel and put it into external repository.（Sink主动从Channel中取出event）

![](/images/flume-user-guide/UserGuide_image00.png) 


###练习

**场景**：Flume收集apache访问日志，然后，在标准终端（stdout）显示。

**分析**：Flume官方文档中，已经给出了一个demo，flume从`localhost:port`收集数据，并在标准终端上显示。基于这一场景，只需要修改Source即可。

####构造实例

通过参阅Flume官网，得知`ExecSource`可用于捕获命令的输出，并将输出结果按行构造event，`tail -F [local file]`命令用于查阅文件`[local file]`的新增内容；在`$FLUME_HOME/conf`目录下，新建文件`apache_log_scan.log`，内容如下：

	a1.sources = r1
	a1.sinks = k1
	a1.channels = c1

	a1.sources.r1.type = exec
	a1.sources.r1.command = tail -F /var/log/httpd/access_log

	a1.sinks.k1.type = logger

	a1.channels.c1.type = memory
	a1.channels.c1.capacity = 1000
	a1.channels.c1.transactionCapacity = 100

	a1.sources.r1.channels = c1
	a1.sinks.k1.channel = c1

启动Flume agent，命令如下：
	
	[ningg@localhost flume]$ cd conf
	[ningg@localhost  conf]$ sudo ../bin/flume-ng agent --conf ../conf --conf-file example.conf --name a1 -Dflume.root.logger=INFO,console
	...
	...
	 Component type: SOURCE, name: r1 started

然后访问一下Apache承载的网站，可以看到上面的窗口也在输出信息，即，已经在捕获Apache访问日志`access_log`的增量了。（可以另起一个窗口，通过`tail -F access_log`查看日志的实际内容）

####存在的问题

通过比较Flume上sink的输出、`tail -F access_log`命令的输出，发现输出有差异：
	
	# Flume上logger类型sink的输出
	Event: { headers:{} body: 31 36 38 2E 35 2E 31 33 30 2E 31 37 35 20 2D 20 168.5.130.175 -  }

	# access_log原始文件上的新增内容
	168.5.130.175 - - [23/Oct/2014:16:34:59 +0800] "GET /..."

思考：

1. logger类型的sink，遇到`[`字符就结束？
2. logger类型的sink，有字符长度的限制吗？
3. channel有长度限制？channel中存储的event是什么形式存储的？

通过`vim access_log`，向文件最后添加一行内容，发现应该是logger类型的sink，对于event的长度有限制；或者，memory类型的channel对于存储的event有限制。





##参考来源

* [Flume Documentation][Flume Documentation]
* Book: [apache-flume-distributed-log-collection-hadoop][apache-flume-distributed-log-collection-hadoop]









[Flume Documentation]:	http://flume.apache.org/documentation.html
[apache-flume-distributed-log-collection-hadoop]:	http://files.hii-tech.com/Book/Hadoop/PacktPub.Apache.Flume.Distributed.Log.Collection.for.Hadoop.Jul.2013.pdf



