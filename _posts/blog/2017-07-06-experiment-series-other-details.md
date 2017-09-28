---
layout: post
title: 实验平台：关键技术细节--其他落地细节
description: 实验平台，具体落地的过程，需要考虑哪些关键细节？这些关键细节，如何实现？
published: true
category: experiment
---

实验平台，具体落地过程，涉及到一些通用问题，当前 blog 将进行详细的讨论：

## 落地：其他细节分析

几个方面：

1. 流程固定、明确控制点：不同控制点，可以配置不同参数/比例，以此动态实验（广告系统为例）
1. 固定分桶数量：
	1. 提前设定分桶数量，例如 100 个
	1. 实验管理页面，如何动态调整流量？
	1. 底层实现 & 操作的便利性
1. hash 算法：
	1. md5 + mod
1. 白名单：指定流量命中指定分组
1. 默认分组问题：
	1. 分流路由标识缺失时，命中哪个分组？默认分组（对照组）
	1. 全量上线时，默认分组（对照组？实验组？）
1. 实验效果：
	1. 观察多长时间内的实验效果？
	1. 如何避免其他因素影响？节假日、天气、运动会事件等


## 参考资料

* [阿里妈妈大规模在线分层实验实践](http://www.infoq.com/cn/articles/alimama-large-scale-online-hierarchical-experiment)
* [超越AB-Test，算法参数化与Google实验架构](http://www.weiot.net/article-4661-1.html)
* [大众点评并行 AB 测试框架 Gemini](http://www.csdn.net/article/2015-03-24/2824303)
* [Experiments at Airbnb](https://medium.com/airbnb-engineering/experiments-at-airbnb-e2db3abf39e7)
* [微博广告分层实验平台(Faraday)架构实践](http://www.infoq.com/cn/articles/weibo-ad-layered-experiment-platform-faraday)
* [Overlapping Experiment Infrastructure- More, Better, Faster Experimentation.pdf](https://static.googleusercontent.com/media/research.google.com/zh-CN//pubs/archive/36500.pdf)










































[NingG]:    http://ningg.github.com  "NingG"










