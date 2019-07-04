---
layout: post
title: RocketMQ：延迟队列
description: 延迟队列的实现原理、业务实践，潜在问题以及如何补偿？
published: true
category: RocketMQ
---

## 0.概要

**目标**：RocketMQ 的延迟队列的底层实现原理，潜在问题，以及业务使用过程中，如何补偿。

**具体焦点**：延迟队列，`Scheduled Message`，定时消息

* 底层实现原理
* 业务实践中，潜在问题和补偿策略

## 1.延迟队列

几个方面：

* 底层实现原理
* 业务实践：潜在问题和补偿策略

### 1.1.底层实现原理

几个方面：

* RocketMQ （开源版本）：支持 18 个级别的延迟消息队列
* 具体的级别：参考下面说明，1s、5s、10s等

目前rockatmq支持的延迟时间有：18 个级别，在 Broker 启动前，可以在配置文件中设置

> 1s 5s 10s 30s 1m 2m 3m 4m 5m 6m 7m 8m 9m 10m 20m 30m 1h 2h

以上支持的延迟时间在 `msg.setDelayTimeLevel` 对应的级别依次是`1`，`2`，`3` ...

![](/images/rocketmq-series/scheduled-msg.png)

上图是 RocketMQ 的 Scheduled Message（定时消息/延迟消息）的实现原理，其主要分为 2 部分：

1. **消息落盘**：落在`独立的延迟队列`中
1. **消息调度**：依靠定时任务，进行消息的`消费`，并在时间到达后，将消息，写入`真正的目标 Topic`中

Tips：

> **核心**：将 msg 暂存在「延迟队列」中，依赖定时任务，定期检查，将满足条件的 msg，送回「真正的目标队列」中；
> 
> **特别说明**：上述处理，都是在 RocketMQ 的「**Server 端/服务器端**」进行处理的；

**消息落盘**：详细过程

1. **替换 Topic 和 queueId**：在写入CommitLog之前，如果是延迟消息，替换掉消息的`Topic`和`queueId`(被替换为延迟消息特定的Topic，queueId则为延迟级别对应的id)
1. **消息转存**：消息写入`CommitLog`之后，提交 `dispatchRequest` 到 `DispatchService`
1. **落盘存储**：根据替换后的 `Topic` 和 `queueId`，将 msg 写入 `Scheduled` 的 `ConsumeQueue` 中（特定Queue，不会被消费）

**消息调度**：详细过程

1. **定时任务监听**：给每个Level设置定时器，从`ScheduledConsumeQueue`中读取信息，msg 已经耗尽延时时间，则，从`CommitLog`中读取消息内容，恢复成正常的消息内容写入`CommitLog`
1. **消息转存**：写入`CommitLog`后，提交 `dispatchRequest` 给 `DispatchService`
1. **落盘存储**：由于已恢复 `Topic` 等属性，所以，此时`DispatchService`会将消息投递到正确的`ConsumeQueue`中

回顾一下这个方案，最大的**优点**就是**没有排序**：

1. **分级隔离**：先发一条level是5s的消息，再发一条level是3s的消息，因为他们会属于不同的ScheduleQueue所以投递顺序能保持正确
1. **同级有序**：如果先后发两条level相同的消息，那么他们的处于同一个ConsumeQueue且保持发送顺序
1. **固定数量**：因为level数固定，每个level的有自己独立的定时器，开销也不会很大
1. **系统可靠**：ScheduledConsumeQueue其实是一个普通的ConsumeQueue，所以可靠性等都可以按照原系统的M-S结构等得到保障（多副本存储）

但是这个方案也有一些问题：

1. **灵活性有限**：
	1. 固定了Level，不够灵活，最多只能支持18个Level
	1. 业务是会变的，但是Level需要提前划分，不支持修改
1. **大数据量问题**：
	1. 如果要支持30天的延迟，CommitLog的量会很大，这块怎么处理没有看到

### 1.2.业务实践

**焦点**：业务角度，常见问题，以及解决方案

典型的**应用场景**：

* **消息重试**：消费失败的消息，送入「`目标队列`」的「`延迟队列`」，并且设置好「`目标重试时间`」

## 2.参考资料

* [延迟队列，实现原理](https://www.cnblogs.com/hzmark/p/mq-delay-msg.html)
* [RocketMQ 延迟队列的原理](http://silence.work/2018/12/16/RocketMQ-%E5%BB%B6%E8%BF%9F%E6%B6%88%E6%81%AF%E7%9A%84%E4%BD%BF%E7%94%A8%E4%B8%8E%E5%8E%9F%E7%90%86%E5%88%86%E6%9E%90/)
* [RocketMQ实战 - RocketMQ延时消息](https://www.jianshu.com/p/504fc5d65fae)
* [RocketMQ 定时消息和消息重试](http://www.iocoder.cn/RocketMQ/message-schedule-and-retry/)













[NingG]:    http://ningg.github.com  "NingG"

