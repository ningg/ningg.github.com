---
layout: post
title: MOA框架的学习策略
description: MOA框架学习有段时间了，小结一下
category: MOA
---

断断续续学习[MOA]:`Massive Online Analysis`，将近2个月了，来个小结，记录一下现在的想法。

本阶段学习`MOA`的目标：使用`MOA`定制自己的算法。

![building](/images/summary-moa-framework/building.jpg)

可以选择的学习途径：

* 阅读官方文档；
* 研究API(包括具体源代码上的实现)；
* 前人的总结；（网络、论文、书籍）
* 找一个具体的算法，直接动手实现代码；

MOA的学习，不能完全依靠MOA官方的几个文档,更重要的是对API的熟练使用（__对于JAVA编写的框架，这是很重要的一点__），这就要认真的分析学习他的源代码；源代码的学习有一个很方便的切入点：先在源代码上实现一个很简单，但是很典型的例子；然后研究这个例子的深层实现（__弄清楚属性存储结构、函数功能__）。

##官方文档

针对MOA的官方文档简要介绍如下：

1. Manual.pdf
2. Tutorial1.pdf(Introduction to MOA)
3. Tutorial2.pdf(Introduction to API of MOA)
4. StreamMining.pdf

`Tutorial1.pdf`、`Tutorial2.pdf`页数不多，入门的简要介绍；`Manual.pdf`（70页）系统说明了如何使用`MOA`；`StreamMining.pdf `（180页）简要介绍`MOA`中运用的一些算法的理论知识，更详细的可以查看其中的参考文献。

__阅读建议__：先快速的按`Tutorial1.pdf`、`Tutorial2.pdf`操作一遍；今后，需要使用`MOA`时，可以参照`Manual.pdf`；关于理论上的知识查阅`StreamMining.pdf`。

##API学习

实现一个典型的例子，这个例子参考：`Tutorial2.pdf`。

针对这个例子分析，得出如下结果：

* 围绕`data stream generator`，学习：`InstanceStream`、`bstractOptionHandler`、 `AbstractMOAObject`、 `OptionHandler`、 `MOAObject`、 `RandomTreeGenerator`；
* 围绕`data stream`的数据结构和数据存储形式，学习：`Attribute`、 `Instance`、 `Instances`、 `AbatractList`、 `InstancesHeader`；
* 围绕学习算法`classifier learner`，学习：`AbstractClassifier`、 `Classifier`、 `DecisionStumpTutorial`；
* 围绕图形界面参数读取，学习：`Option`、 `AbstractOption`、 `Options`；[NOTE]：这部分只说明了与图形界面参数存储相关的类；

特别要记录的一点是：__记忆很重要，即使是在阅读源代码__。


[MOA]:	http://moa.cms.waikato.ac.nz/	"Massive Online Analysis"
[NingG]:    http://ningg.github.com  "NingG"
