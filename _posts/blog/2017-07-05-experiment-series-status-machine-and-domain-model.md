---
layout: post
title: 实验平台：设计--领域模型 & 状态机
description: 实验平台，具体落地的过程，需要考虑哪些关键细节？这些关键细节，如何实现？
published: true
category: experiment
---

实验平台，具体落地过程，涉及到一些通用问题，当前 blog 将进行详细的讨论：

## 领域模型

实验平台，结合领域知识，进行通用的领域模型设计：

![](/images/experiment-series/domain-model-design.png)


## 实验管理状态机

实验平台中，实验的生命周期是流转的，不同的状态，可以承载不同的操作/业务功能：

![](/images/experiment-series/experiment-lifecycle.png)



## 参考资料

* [阿里妈妈大规模在线分层实验实践](http://www.infoq.com/cn/articles/alimama-large-scale-online-hierarchical-experiment)
* [超越AB-Test，算法参数化与Google实验架构](http://www.weiot.net/article-4661-1.html)
* [大众点评并行 AB 测试框架 Gemini](http://www.csdn.net/article/2015-03-24/2824303)
* [Experiments at Airbnb](https://medium.com/airbnb-engineering/experiments-at-airbnb-e2db3abf39e7)
* [微博广告分层实验平台(Faraday)架构实践](http://www.infoq.com/cn/articles/weibo-ad-layered-experiment-platform-faraday)
* [Overlapping Experiment Infrastructure- More, Better, Faster Experimentation.pdf](https://static.googleusercontent.com/media/research.google.com/zh-CN//pubs/archive/36500.pdf)










































[NingG]:    http://ningg.github.com  "NingG"










