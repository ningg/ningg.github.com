---
layout: post
title: 实验平台：架构设计
description: 实验平台，有什么作用？整体架构，要涵盖哪些主要功能？
published: true
category: experiment
---

实验平台，几个朴素的疑问：

1. 是什么？有什么用？
2. 整体架构，要涵盖哪些关键功能？

## 是什么

实验平台的定位：

> 线上流量`动态伸缩`，验证产品`策略`，实现 DDD（Data-Driven-Design，数据驱动设计）

通俗的说：

* 借助实验平台，使用部分线上流量，在可控的影响范围内，验证策略的好坏。（*好像还是不够通俗*）

## 整体架构

实验架构，整体要包含几个方面：

* 实验平台：
	* 实验管理：配置参数、设置状态、流量伸缩等
	* 配置分发：实验配置分发到业务端
	* 结果展示：实验结果的收集和反馈
* 实验 client：业务方，引入 jar ，启动实验 client
	* 本地缓存：client 在业务应用本地，缓存实验配置
	* 及时更新：client 及时感知实验的变更，并及时更新本地缓存
* 数据平台：
	* 实时收集
	* 实时分析汇总

上面 3 个方面，能行成一个稳定闭环，实现：配置管理、流量生效、结果反馈。

实验架构，内部关键细节：

![](/images/experiment-series/experiment-series-framework.png)

实验平台，架构的关键技术点 & 实现思路：

![](/images/experiment-series/details-of-framework.png)



Experiment Config Client，其以 lib 包的形式，引入到使用方，提供的功能：

* **本地缓存**：使用方，依赖 Experiment Config Client，实现本地缓存实验配置
* **及时更新**：基于 HTTP polling 机制, 默认 10s 更新一次本地缓存
* **服务发现**：依赖 consul 发现 Experiment Service 
* **服务降级**：当 Config Client 无法连接到 Experiment Service 时，则，调用方会读取 local cache 中实验配置， local cache 被清空后，在调用方会暂停实验
* **声明式调用**：依赖 Feign 声明方式, 调用 Experiment Service  的 REST 接口
* **配置解析**：根据业务方传入参数, 解析出对应的实验组
* **统一日志格式**：工具类中, 提供统一的日志格式

## 参考资料

* [阿里妈妈大规模在线分层实验实践](http://www.infoq.com/cn/articles/alimama-large-scale-online-hierarchical-experiment)
* [超越AB-Test，算法参数化与Google实验架构](http://www.weiot.net/article-4661-1.html)
* [大众点评并行 AB 测试框架 Gemini](http://www.csdn.net/article/2015-03-24/2824303)
* [Experiments at Airbnb](https://medium.com/airbnb-engineering/experiments-at-airbnb-e2db3abf39e7)
* [微博广告分层实验平台(Faraday)架构实践](http://www.infoq.com/cn/articles/weibo-ad-layered-experiment-platform-faraday)
* [Overlapping Experiment Infrastructure- More, Better, Faster Experimentation.pdf](https://static.googleusercontent.com/media/research.google.com/zh-CN//pubs/archive/36500.pdf)










































[NingG]:    http://ningg.github.com  "NingG"










