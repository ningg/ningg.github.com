---
layout: post
title: Flume 1.6.0 梳理
description: Flume发行新版本了，梳理一下Flume的基本知识，尝试一下新特性
published: true
category: Flume
---

几点：

* Flume简介
* Flume 1.6.0的新特性
* Flume内部机制
	* 内部结构
	* 相关术语
	* 可靠性和可恢复性
* 搭建Flume插件定制环境
* 整理GitHub上定制的SpoolDirTailFileSource
	* 更新代码
	* 更新README



## Flume简介

 Apache Flume是一个高可靠、高可用的分布式的海量日志收集、聚合、传输系统。它可以从不同的日志源采集数据并集中存储。
 
* 收集、聚合事件流数据的分布式框架
* 通常用于log数据
* 采用ad-hoc方案，明显优点如下：
	* 可靠的、可伸缩、可管理、可定制、高性能
	* 声明式配置，可以动态更新配置
	* 提供上下文路由功能
	* 支持负载均衡和故障转移
	* 功能丰富
	* 完全的可扩展

Tips：

> ad-hoc方案：没有中心控制节点，每个节点都可以用户收集、转发数据。

## Flume 1.6.0新特性

完整的Flume 1.6.0升级的新特性参考[Flume 1.6.0 release page]，几个典型的新特性：

* Flume Sink and Source for Apache Kafka
* A new channel that uses Kafka
* Hive Sink based on the new Hive Streaming support
* End to End authentication in Flume
* Simple regex search-and-replace interceptor

还有几个：

* Write an startscript for flume agents on Windows
* event body data size can make it configurable for logger sinker
* Tool/script for deleting individual message from queue
* Support batchSize to allow multiple events per transaction to the Kafka Sink

会陆续尝试上述的新特性，`Flume 1.6.0`的版本说明，参考：[Flume 1.6.0 release page].


## Flume内部机制

从下面几个方面来说：

* 相关术语
* 内部结构
* 可靠性



### 相关术语

![](/images/flume-1-6-0-summary/flumeAgentModel.png)

Flume Agent内部以Flume Event形式传递数据，具体内部由Source、Channel、Sink多线程相互协调进行。


#### Flume Event

Flume Event，由 `byte[] body` 和 `Map<String, String> Headers`构成，是Flume Agent内数据流转的基本单元。

Flume中Event对应的源代码如下：

    package org.apache.flume;

    /*
     * Basic representation of a data object in Flume.
     * Provides access to data as it flows through the system.
     */
    public interface Event {
    
      /*
       * Returns a map of name-value pairs describing the data stored in the body.
       */
      public Map<String, String> getHeaders();
      public void setHeaders(Map<String, String> headers);
    
      /*
       * Returns the raw byte array of the data contained in this event.
       */
      public byte[] getBody();
      public void setBody(byte[] body);
    
    }

#### Flume Agent

Flume Agent，本质就是一个JVM进程，提供了Flume内部Source、Channel、Sink线程的运行环境。

具体：

* Source：从Flume Agent外部获取数据（Event），并将数据送入一个或者多个Channel中；
* Channel：被动的存储Event，等待Sink来读取Event；
* Sink：从Channel中读取Event，并将其送至下一级的Flume Agent或者其他目的地，例如HDFS;

Tips：

> Source 与 Sink 之间是异步进行的，Event在Channel进行缓存。



#### 核心概念：Interceptor

> 用于Source的一组Interceptor，按照预设的顺序在必要地方装饰和过滤events。

* 内建的Interceptors允许增加event的headers比如：时间戳、主机名、静态标记等等
* 定制的interceptors可以通过内省event payload（读取原始日志），在必要的地方创建一个特定的headers。




#### 核心概念：Channel Selector

channel selectors：用于设定Source中Event送入哪个Channel，通常是依照Event中的`Headers`下的具体属性，来决定Event送入哪个Channel，`channel selectors`通常有 3 种类型：

* 复制Replicating（default）：Source中Event送入所有的Channel中；
* 复用Multiplexing：依照Event的Headers下的指定属性，选取指定的Channel；
* 自定义


![](/images/flume-1-6-0-summary/multiplexing.png)



#### 核心概念：Sink Processor

> 多个Sink可以构成一个Sink Group。一个Sink Processor负责从一个指定的Sink Group中激活一个Sink。Sink Processor可以通过组中所有Sink实现负载均衡；也可以在一个Sink失败时转移到另一个。

* Flume通过Sink Processor实现负载均衡（Load Balancing）和故障转移（failover）
* 内建的Sink Processors:
	* Load Balancing Sink Processor – 使用RANDOM, ROUND_ROBIN或定制的选择算法
	* Failover Sink Processor 
	* Default Sink Processor（单Sink）
* 所有的Sink都是采取轮询（polling）的方式从Channel上获取events。这个动作是通过Sink Runner激活的
* Sink Processor充当Sink的一个代理




### 内部结构

单个Flume Agent的内部结构：

![](/images/flume-1-6-0-summary/flumeAgentModel.png)


多级Flume Agent构成拓扑：

![](/images/flume-1-6-0-summary/multi-agentFlow.png)

![](/images/flume-1-6-0-summary/multi-tiers.png)

利用`channel selectors`指定分发Event：

![](/images/flume-1-6-0-summary/multiplexing.png)


包含各个核心概念的Flume Agent内部结构：

![](/images/flume-1-6-0-summary/flume-inner.png)





### 可靠性

几点：

* Source、Sink采用事务机制，来保证可靠性；
* Channel提供File channel，保证进程重启，数据不丢失；































## 参考来源

* [Flume 1.6.0 release page]
* [Flume User Guide]
* [Apache Flume 中文介绍]








[NingG]:    http://ningg.github.com  "NingG"



[Flume 1.6.0 release page]: 	http://flume.apache.org/releases/1.6.0.html
[Flume User Guide]: 			http://flume.apache.org/FlumeUserGuide.html
[Apache Flume 中文介绍]:		http://blog.csdn.net/szwangdf/article/details/33275351





