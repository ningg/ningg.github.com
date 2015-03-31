---
layout: post
title: Storm：Rationale
description: Storm官方文档的阅读和笔记
categories: storm
---

> 原文地址：[Storm Rationale](http://storm.apache.org/documentation/Rationale.html)，本文使用`英文原文+中文注释`方式来写。

##Background

The past decade has seen a revolution in data processing. MapReduce, Hadoop, and related technologies have made it possible to store and process data at scales previously unthinkable. Unfortunately, these data processing technologies are not realtime systems, nor are they meant to be. There’s no hack that will turn Hadoop into a realtime system; realtime data processing has a fundamentally different set of requirements than batch processing.
（Hadoop的相关技术已经很多，大规模数据处理方面很强，但realtime processing却不行）

However, realtime data processing at massive scale is becoming more and more of a requirement for businesses. The lack of a “Hadoop of realtime” has become the biggest hole in the data processing ecosystem.

Storm fills that hole.
（Storm将解决大规模数据的实时处理问题。）

Before Storm, you would typically have to manually build a network of queues and workers to do realtime processing. Workers would process messages off a queue, update databases, and send new messages to other queues for further processing. Unfortunately, this approach has serious limitations:
（在Storm之前，需要手动创建queues和workers，其中，worker从queue中取出message，并进行处理；不幸呐，这种方式有很严重的限制）

1. **Tedious**: You spend most of your development time configuring where to send messages, deploying workers, and deploying intermediate queues. The realtime processing logic that you care about corresponds to a relatively small percentage of your codebase.（重复劳动：花费大量时间来配置和部署）
1. **Brittle**: There’s little fault-tolerance. You’re responsible for keeping each worker and queue up.（系统很脆弱：需要不停地检测并保证worker、queue都是存活的）
1. **Painful to scale**: When the message throughput get too high for a single worker or queue, you need to partition how the data is spread around. You need to reconfigure the other workers to know the new locations to send messages. This introduces moving parts and new pieces that can fail.（扩展困难：流量上升后，添加worker、queue，需要重新进行处理逻辑配置，并且由于结构变得复杂，系统可靠性会降低）

Although the queues and workers paradigm breaks down for large numbers of messages, message processing is clearly the fundamental paradigm for realtime computation. The question is: how do you do it in a way that doesn’t lose data, scales to huge volumes of messages, and is dead-simple to use and operate?
（**问题是：能否实现一个方案，满足：不丢数据、易于扩展、使用和操作极其简单？**）

**notes(ningg)**：paradigm? break down? fundamental paradigm?什么含义？

Storm satisfies these goals.
（Storm就是这么一个方案）

##Why Storm is important

Storm exposes a set of primitives for doing realtime computation. Like how MapReduce greatly eases the writing of parallel batch processing, Storm’s primitives greatly ease the writing of parallel realtime computation.
（Storm暴漏了a set of primitives/原语，来进行realtime computation。就像MapReduce极大改善了parallel batch processing一样，Storm改善了parallel realtime computation）

**notes(ningg)**：primitives？对于一个software，primitives什么含义？

The key properties of Storm are:
（Storm的关键特性如下）

1. **Extremely broad set of use cases**: Storm can be used for processing messages and updating databases (stream processing), doing a continuous query on data streams and streaming the results into clients (continuous computation), parallelizing an intense query like a search query on the fly (distributed RPC), and more. Storm’s small set of primitives satisfy a stunning number of use cases.（广泛的应用场景）
1. **Scalable**: Storm scales to massive numbers of messages per second. To scale a topology, all you have to do is add machines and increase the parallelism settings of the topology. As an example of Storm’s scale, one of Storm’s initial applications processed 1,000,000 messages per second on a 10 node cluster, including hundreds of database calls per second as part of the topology. Storm’s usage of Zookeeper for cluster coordination makes it scale to much larger cluster sizes.（易于扩展：增加机器，配置并发数；备注：这跟使用zookeeper进行cluster管理相关。）
1. **Guarantees no data loss**: A realtime system must have strong guarantees about data being successfully processed. A system that drops data has a very limited set of use cases. Storm guarantees that every message will be processed, and this is in direct contrast with other systems like S4.（数据不丢失：Storm保证every message will be prcessed，而S4不行）
1. **Extremely robust**: Unlike systems like Hadoop, which are notorious for being difficult to manage, Storm clusters just work. It is an explicit goal of the Storm project to make the user experience of managing Storm clusters as painless as possible.（极其健壮：Storm Cluster非常易于管理，这也是其设计的初衷。）
1. **Fault-tolerant**: If there are faults during execution of your computation, Storm will reassign tasks as necessary. Storm makes sure that a computation can run forever (or until you kill the computation).（容错性：出错后，storm会reassign task。）
1. **Programming language agnostic**: Robust and scalable realtime processing shouldn’t be limited to a single platform. Storm topologies and processing components can be defined in any language, making Storm accessible to nearly anyone.（语言无关性：Storm topologies、processing components可使用多种语言实现）


##参考来源

* [Apache Storm](http://storm.apache.org/)
* [Apache Storm: Documentation Rationale](http://storm.apache.org/documentation/Rationale.html)




[NingG]:    http://ningg.github.com  "NingG"
