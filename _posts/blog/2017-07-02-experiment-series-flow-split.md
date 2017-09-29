---
layout: post
title: 实验平台：设计--流量分割
description: 如何把流量切分开，分配到各个实验分组上？
published: false
category: experiment
---

实验平台，具体落地过程，涉及到一些通用问题，当前 blog 将进行详细的讨论：

## 流量：物理分割 vs. 逻辑分割

实验架构的流量分割，2 种可选方案：

* 流量**物理分割**：
	* 入口分割
	* 代码隔离
	* 独立部署
* 流量**逻辑分割**：
	* 代码耦合
	* 统一部署

下面是 `物理分割` 和 `逻辑分割` 的 2 个示意图：

![](/images/experiment-series/flow-spllit-physical.png)

![](/images/experiment-series/flow-spllit-logical.png)


流量的物理分割和逻辑分割，优缺点和适用场景：

* 物理分割
	* 开发模式：分支开发模式
	* 优点：
		* 业务侵入小
		* 上线方便：不需要调整代码
	* 缺点：
		* 扩展性差：进行 N 个实验，每组实验分为 M 组，则需要 M*N 个分支
		* 联动部署：代码部署和分流路由，联动部署
		* 控制逻辑分散：代码分支和分流路由
		* 运维复杂：需要区分不同分支、不同机器，并配合分流路由
	* 实际经验：
		* Google
		* Baidu

* 逻辑分割	
	* 开发模式：主干开发模式
	* 优点：
		* 控制逻辑集中：业务代码，集中控制分流路由和实验策略
		* 运维简单：正常上线部署
	* 缺点：
		* 业务侵入大
		* 上线不方便：需要删掉不再使用的实验代码
	* 实际经验：
		* 微软
		* Amazon
		* 点评

重点从下面 4 个方面考虑：

* 运维的便利性：逻辑分流 +1
* 控制逻辑集中：逻辑分流 +1 （影响局部性）
* 业务代码侵入性：物理分流 +1
* 实验扩展性：逻辑分流 +1

结论：

* 「逻辑分流」方式，在运维便利性、实验扩展性以及影响局部性上，都更优；
* 根据当前的开发流程和运维基础设施，初步决定采用「逻辑分流」方式；

![](/images/experiment-series/experiment-flow-spllit-physical-vs-logical.png)


## 参考资料

* [阿里妈妈大规模在线分层实验实践](http://www.infoq.com/cn/articles/alimama-large-scale-online-hierarchical-experiment)
* [超越AB-Test，算法参数化与Google实验架构](http://www.weiot.net/article-4661-1.html)
* [大众点评并行 AB 测试框架 Gemini](http://www.csdn.net/article/2015-03-24/2824303)
* [Experiments at Airbnb](https://medium.com/airbnb-engineering/experiments-at-airbnb-e2db3abf39e7)
* [微博广告分层实验平台(Faraday)架构实践](http://www.infoq.com/cn/articles/weibo-ad-layered-experiment-platform-faraday)
* [Overlapping Experiment Infrastructure- More, Better, Faster Experimentation.pdf](https://static.googleusercontent.com/media/research.google.com/zh-CN//pubs/archive/36500.pdf)










































[NingG]:    http://ningg.github.com  "NingG"










