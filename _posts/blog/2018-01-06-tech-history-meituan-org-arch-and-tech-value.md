---
layout: post
title: 科技历史系列：美团组织架构和技术团队理念
description: 不同的组织结构，可以承载不同的效率；团队理念，看似抽象，却能发挥无穷的力量；美团作为新的互联网代表，其从组织和技术团队理念上，有哪些可以学习的地方。
category: 科技历史 
---

## 1. 概要

关于组织结构，说几个共识：

1. **组织**：不同的组织结构，能承载不同的效率；
1. **阶段**：不同阶段、不同场景，适用不同的组织结构；
1. **发展**：发展阶段不同，组织结构需要相应调整，以适应发展，避免制约发展；

当前文章，专注分析、借鉴一些典型互联网公司的技术团队「组织结构」，几个方面：

1. 收集情况
1. 分析优劣

Note：

> 并不是存在即合理，要有我们自己的思考、分析；
> 
> 当然，很多事实，会辅助我们分析；

当前文章，挑选下面几家典型组织进行分析：

* 美团：当前文章，暂时，只针对美团进行分析
* 头条

对于美团，分析其组织结构，从几个方面入手：

1. 现状：技术团队组织结构
1. 关键点：发展过程中的组织结构，落地细节
1. 基于职能划分 vs. 基于项目划分

## 2. 现状：技术团队的组织架构

当前美团的团队现状（截止 2018-01-06）：

![](/images/tech-history/meituan-org/meituan-org-2018.png)



## 3. 关键点：落地细节

几个关键落地细节：

1. 理念
1. 前台业务 vs. 中后台业务
1. 技术团队的划分标准：「基于职能」划分 vs. 「基于项目」划分

### 3.1. 理念

**理念**，看起来很虚，但却是做事的「`原点`」，判断一个事情**该不该做**、该**如何做**的时候，就靠理念评判。

**技术团队的理念**：（中早期， 2016 年之前快速发展阶段）

* 要么牛逼，要么滚蛋
* 做有积累的事
* 大处着眼，小处着手

**团队建设**：

* 招聘并培养优秀的人
* 持续学习并分享

更多的细节，可以参考 美团技术学院刘江的分享

* [要么牛逼，要么滚蛋！这就是美团工程师文化！](http://www.php230.com/weixin1452245983.html) （这是美团在 2016 年之前，极速发展阶段的一个片段，很真实，感受很深）

### 3.2. 前台业务 vs. 中后台业务

「前台业务」& 「中后台业务」的关系：

1. **前台业务**：都有自己「独立的技术部」
1. **中后台业务**：提供通用的基础技术服务，增强全流程研发支撑能力，例如：数据、搜索、POI、广告、基础服务治理，支付、用户登录、邮件接口、活动平台等等;
1. **中后台业务**：不约束前台业务的发展，前台业务一般情况下，会基于中后台的服务进行扩展，例如，每个前台业务都调用「公司统一的用户服务」，统一账户，同时，也会自建自己的用户中心，满足差异化需求；
1. **前台成长沉淀**：前台业务发展的过程中，沉淀、积累的经验，反哺中后台业务，比如前台业务中，成长出来的中间件，如果多事业群通用，即可贡献到中后台，人员全自由流动。
1. **定期沟通**：「中后台业务」每季度跟各个「前台业务」沟通，收集需求 & 建议，保持线下沟通，提升协作效率；

### 3.3. 技术团队划分标准

100+ 以上的技术团队，如何划分成组？

* 短期基于项目
* 中长期基于职能
* 保持人员在内部的可流动性，避免一人只做一事，鼓励内部流动交流
 

## 4. 参考来源

* [美团社会招聘](https://job.meituan.com)
* [美团技术团队](https://tech.meituan.com)
* [http://36kr.com/p/5105920.html](http://36kr.com/p/5105920.html)
* 内部成员描述




[NingG]:    http://ningg.github.com  "NingG"

