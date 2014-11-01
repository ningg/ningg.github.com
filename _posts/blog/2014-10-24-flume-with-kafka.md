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

	# access_log原始文件上的新增内容（长度超过上面logger sink的输出）
	168.5.130.175 - - [23/Oct/2014:16:34:59 +0800] "GET /..."

思考：

1. logger类型的sink，遇到`[`字符就结束？
2. logger类型的sink，有字符长度的限制吗？
3. channel有长度限制？channel中存储的event是什么形式存储的？

通过`vim access_log`，向文件最后添加一行内容，发现应该是logger类型的sink，对于event的长度有限制；或者，memory类型的channel对于存储的event有限制。
**RE**：上述问题已经解决，Logger sink输出内容不完整，详情可参考[Advanced Logger Sink](/flume-advance-logger-sink)。

##Kafka复习

下面Kafka的相关总结都参考自：

* [Kafka 0.8.1 Documentation][Kafka 0.8.1 Documentation]

###几个概念

![](/images/kafka-documentation/producer_consumer.png)

* **消息队列**：Kafka充当消息队列，producer将message放入Kafka集群，consumer从Kafka集群中读取message；
* **内部结构**：按照topic来存放message，每个topic对应一个partitioned log，其中包含多个partition，每个都是一个有序的、message队列；
* **消息存活时间**：在设定的时间内，kafka始终保存所有的message，即使message已经被consume；
* **consume message**：每个consumer，只需保存在log中的offset，并且这个offset完全由consumer控制，可自由调整；鉴于此，cousumer之间相互基本没有影响；

![](/images/kafka-documentation/log_anatomy.png)

针对上面每个topic对应的partitioned log，其中包含了多个partition，这样设计有什么好处？

* single server上，单个log的大小由文件系统限制，而采用多partition模式，虽然单个partition也受限，但partition的个数不受限制；
* 多个partition时，每个partition都可作为一个unit，以此来支撑并发处理；
* partition是分布式存储的，即，某个server上的partition可能也存在其他的server上，两点好处：
	* 方便不同server之间的partition共享；
	* 配置每个partition的复制份数，提升系统可靠性；
* partition对应的server，分为两个角色：`leader`和`follower`：
	* 每个partition都对应一个server担当`leader`角色：负责所有的read、write；
	* 其他server担`follower`角色：重复`leader`的操作；
	* 如果`leader`崩溃，则自动推选一个`follower`升级为`leader`；
	* server只对其上的部分partition担当`leader`角色，方便cluster的均衡；

Producer产生的数据放到topic的哪个partition下？集中方式：

* 轮询：保证每个partition以均等的机会存储message，均衡负载；
* 函数：根据key in the message来确定partition；

Consumer读取message有两种模式：

* queueing：多个consumer构成一个pool，然后，每个message只被其中一个consumer处理；
* publish-subscribe：向所有的consumer广播message；

Kafka中通过将consumer泛化为consumer group来实现，来支持上述两种模式，关于此，详细说一下：

* consumer都标记有consumer group name，每个message都发送给对应consumer group中的一个consumer instance，consumer instance可以是不同的进程，也可以分布在不同的物理机器上；
* 若所有的consumer instances都属于同一个consume group，则为queuing轮询的均衡负载；
* 若所有的consumer instances都属于不同的consume group，则为publish-subscribe，message广播到所有的consumer；
* 实际场景下，topic对应为数不多的几个consumer group，即，consumer group类似`logical subscriber`；每个group中有多个consumer，目的是提升可扩展性和容错能力。


![](/images/kafka-documentation/consumer-groups.png)


**notes(ningg)**：几个问题：

* consumer group是与topic对应的？还是partition对应？
* consumer group方式能够提升可扩展性和容错能力？

Ordering guarantee，Kafka保证message按序处理，同时也保证并行处理，几点：

* 单个partition中的message保证按序处理，同时一个partition只能对应一个consumer instance；
* 不同partition之间，不保证顺序处理，多个partition实现了并行处理；

**notes(ningg)**：同一个partition中的message，当其中一个message A被指派给一个consumer instance后，在message A被处理完之前，message B是否会被指派出去？

###小结

Kafka通过 partition data by key 和 pre-partition ordering，满足了大部分需求。如果要保证所有message都顺序处理，则将topic设置为only one partition，此时，变为串行处理。















	
	
**notes(ningg)**：单个partition是以什么形式存储在server上的？纯粹的文档文件？

##参考来源

* [Flume Documentation][Flume Documentation]
* Book: [apache-flume-distributed-log-collection-hadoop][apache-flume-distributed-log-collection-hadoop]









[Flume Documentation]:	http://flume.apache.org/documentation.html
[apache-flume-distributed-log-collection-hadoop]:	http://files.hii-tech.com/Book/Hadoop/PacktPub.Apache.Flume.Distributed.Log.Collection.for.Hadoop.Jul.2013.pdf
[Kafka 0.8.1 Documentation]:		http://kafka.apache.org/documentation.html

