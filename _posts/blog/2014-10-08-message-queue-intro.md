---
layout: post
title: 消息队列（Message Queue）基本概念
description: 耳边不时响起“消息队列”，这么个东西，OK，好像很NB的样子，今天就来看看“消息队列”是个什么东西
category: message queue
---

## 背景

之前做日志收集模块时，用到flume，另外也有的方案，集成kafaka来提升系统可扩展性，其中涉及到`消息队列`，当时自己并不清楚为什么要使用`消息队列`，而在我自己提出的原始日志采集方案中不适用`消息队列`时，有几个基本问题：1.日志文件上传过程，有个基本的`生产者-消费者`问题；2.另外系统崩溃时，数据丢失的处理问题。

今天，几位同事再次谈到`消息队列`这么个东西，很NB的样子，我也想弄清楚，OK，搞起。

## 什么是消息队列

消息队列（Message Queue，简称MQ），从字面意思上看，本质是个队列，FIFO先入先出，只不过队列中存放的内容是`message`而已。其主要用途：不同进程Process/线程Thread之间通信。为什么会产生`消息队列`？这个问题问的好，我大概查了一下，没有查到最初产生消息队列的背景，但我猜测可能几个原因：

* 不同进程（process）之间传递消息时，两个进程之间耦合程度过高，改动一个进程，引发必须修改另一个进程，为了隔离这两个进程，在两进程间抽离出一层（一个模块），所有两进程之间传递的消息，都必须通过`消息队列`来传递，单独修改某一个进程，不会影响另一个；
* 不同进程（process）之间传递消息时，为了实现标准化，将消息的格式规范化了，并且，某一个进程接受的消息太多，一下子无法处理完，并且也有先后顺序，必须对收到的消息进行排队，因此诞生了事实上的`消息队列`；

不管到底是什么原因催生了`消息队列`，总之，上面两个猜测是其实际应用的典型场景。

## 为什么要用

切合前一部分猜测的`消息队列`产生背景，其主要解决两个问题：

* 系统解耦：项目开始时，无法确定最终需求，不同进程间，添加一层，实现解耦，方便今后的扩展。
* 消息缓存：系统中，不同进程处理消息速度不同，MQ，可以实现不同Process之间的缓冲，即，写入MQ的速度可以尽可能地快，而处理消息的速度可以适当调整（或快、或慢）。

下面针对**系统解耦**、**消息缓存**两点，来分析实际应用`消息队列`过程中，可能遇到的问题。虚拟场景：Process_A通过消息队列MQ_1向Process_B传递消息，几个问题：

* 针对MQ_1中一条消息message_1，如何确保Process_B从MQ_1中只取一次message_1，不会重复多次取出message_1？
* 如果MQ_1中message_1已经被Process_B取出，正在处理的关键时刻，Process_B崩溃了，哭啊，我的问题是，如果重启Process_B，是否会丢失message_1？

不要着急，阅读了下面的简要介绍后，水到渠成，上面几个问题就可以解决了。
消息队列有如下几个好处，这大都是由其**系统解耦**和**消息缓存**两点扩展而来的：

* 提升系统可靠性：
	* 冗余：Process_B崩溃之后，数据并不会丢失，因为MQ多采用`put-get-delete`模式，即，仅当确认message被完成处理之后，才从MQ中移除message；
	* 可恢复：MQ实现解耦，部分进程崩溃，不会拖累整个系统瘫痪，例，Process_B崩溃之后，Process_A仍可向MQ中添加message，并等待Process_B恢复；
	* 可伸缩：有较强的峰值处理能力，通常应用会有突发的访问流量上升情况，使用足够的硬件资源时刻待命，空闲时刻较长，资源浪费，而`消息队列`却能够平滑峰值流量，缓解系统组件的峰值压力；
* 提升系统可扩展性：
	* 调整模块：由于实现解耦，可以很容易调整，消息入队速率、消息处理速率、增加新的Process；
* 其他：
	* 单次送达：保证MQ中一个message被处理一次，并且只被处理一次，本质：get获取一个message后，这一message即被预定，同一进程不会再次获取这一message，当且仅当进程处理完这一message后，MQ中会delete这个message，否则，过一段时间后，这一message自动解除被预订状态，进程能够重新预定这个message；
	* 排序保证：即，满足队列的FIFO，先入先出策略；
	* 异步通信：很多场景下，不会立即处理消息，这是，可以在MQ中存储message，并在某一时刻再进行处理；
	* 数据流的阶段性能定位：获取用户某一操作的各个阶段（通过message来标识），捕获不同阶段的耗时，可用于定位系统瓶颈。


## 常用的消息队列

（doing...）

## 小结

`消息队列`实现了进程间通信的升级，如下图所示：



## 参考来源

* top 10 uses for message queue：[英文原文](http://blog.iron.io/2012/12/top-10-uses-for-message-queue.html)、[pdf版本](/download/message-queue-intro/top-10-mq.pdf)、[中文译文](http://www.oschina.net/translate/top-10-uses-for-message-queue)
* [Message Queue wiki](http://en.wikipedia.org/wiki/Message_queue)
* [http://bbs.csdn.net/topics/110160741](http://bbs.csdn.net/topics/110160741)
* [http://www.cnblogs.com/yuanyi_wang/archive/2009/12/30/1636178.html](http://www.cnblogs.com/yuanyi_wang/archive/2009/12/30/1636178.html)
* [http://www.php1.cn/article/9865.html](http://www.php1.cn/article/9865.html)




[NingG]:    http://ningg.github.com  "NingG"
