---
layout: post
title: RocketMQ：环境搭建 & 运维监控
description: 如何快速搭建 RocketMQ 的运行环境？生产环境中，又有哪些注意事项？如何进行运维监控？
published: true
category: RocketMQ
---

写在开头：

> 技术团队，已经有了 Kafka 作为 MQ，在收集日志，主要是为数据收集服务，例如日志、MySQL 的 binlog；
> 
> 为了扩展 MQ 在生产环境的应用场景，预研一下其他几个 MQ，以此对整个 MQ 实现方案有一个相对全面的视野，提升技术选型的决策效率。

## 0.概要

**目标**：

* **环境搭建**：RocketMQ 的运行环境
	* RocketMQ 单机：非生产环境，测试环境
	* RocketMQ 集群：生产环境，考虑可用性、稳定性
* **运维监控**：RocketMQ 的运行状态


## 1.环境搭建

RocketMQ 环境的搭建，下面两个方面：

* **单机**：完全参考 [RocketMQ-Quick Start](http://rocketmq.apache.org/docs/quick-start/) 即可。
* **集群**：生产环境，参考 [RocketMQ-Deployment](http://rocketmq.apache.org/docs/rmq-deployment/)




## 2.运维监控

如何运维、监控 RocketMQ 的状态？

调研分析，现有的 RocketMQ 运维监控方案：

* todo


官方提供的监控方案：

* [incubator-rocketmq-externals](https://github.com/apache/incubator-rocketmq-externals)


具体安装部署的步骤：

* [RocketMQ-Console-Ng](https://github.com/apache/rocketmq-externals/tree/master/rocketmq-console)



## 3.参考资料


* [RocketMQ-Quick Start](http://rocketmq.apache.org/docs/quick-start/)
* [RocketMQ-Deployment](http://rocketmq.apache.org/docs/rmq-deployment/)
* [分布式开放消息系统(RocketMQ)的原理与实践](https://www.cnblogs.com/wxd0108/p/6038543.html)
* [incubator-rocketmq-externals](https://github.com/apache/incubator-rocketmq-externals)
* [RocketMQ-Console-Ng](https://github.com/apache/rocketmq-externals/tree/master/rocketmq-console)












[NingG]:    http://ningg.github.com  "NingG"

