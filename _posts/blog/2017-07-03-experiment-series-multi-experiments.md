---
layout: post
title: 实验平台：关键技术细节--分层
description: 实验平台，具体落地的过程，需要考虑哪些关键细节？这些关键细节，如何实现？
published: true
category: experiment
---

实验平台，具体落地过程，涉及到一些通用问题，当前 blog 将进行详细的讨论：


### 分层实验模型（分层）

分层的作用？

* 不同分层之间：并发进行多个实验，不同实验之间流量正交
* 同一分层：业务上相互关联的实验，分布到同一层进行。

朴素的疑问：

1. 实验平台，如何同时进行多个实验？
1. 如果同时进行的实验个数是 10 个、100 个，是否会导致实验平台不可用？

这就要求实验平台的可扩展性要好，不会因为并发实验个数的增长导致实验平台的复杂度指数增长，因此，采用「分层实验模型」

「分层实验模型」，典型场景：

1. 流量独占：例如，针对某个城市，或某类特征用户，只进行一个实验，不让这些用户再参与其他实验
1. 流量共享：多实验并行
	1. 相互干扰的实验：分在同一层
	1. 相互不干扰的实验：可以分在不同层，也可以分在同一层（一般建议分在不同层）

分层模型的主要思想为：不同实验层间，进行「独立流量划分」和「独立实验」，互不影响，具体策略参数有下面约束：

1. 相关联的策略参数，位于同一层；
1. 相互独立的策略参数，分属于不同层；
1. 一个实验参数，只能在出现在一个实验层；

![](/images/experiment-series/layers-details.png)



## 参考资料

* [阿里妈妈大规模在线分层实验实践](http://www.infoq.com/cn/articles/alimama-large-scale-online-hierarchical-experiment)
* [超越AB-Test，算法参数化与Google实验架构](http://www.weiot.net/article-4661-1.html)
* [大众点评并行 AB 测试框架 Gemini](http://www.csdn.net/article/2015-03-24/2824303)
* [Experiments at Airbnb](https://medium.com/airbnb-engineering/experiments-at-airbnb-e2db3abf39e7)
* [微博广告分层实验平台(Faraday)架构实践](http://www.infoq.com/cn/articles/weibo-ad-layered-experiment-platform-faraday)
* [Overlapping Experiment Infrastructure- More, Better, Faster Experimentation.pdf](https://static.googleusercontent.com/media/research.google.com/zh-CN//pubs/archive/36500.pdf)










































[NingG]:    http://ningg.github.com  "NingG"










