---
layout: post
title: 算法阅读：OcVFDT
description: One-class Very Fast Decision Tree for One-class Classification of Data Streams
category: data stream algorithm
---

论文原文：

> [OcVFDT: One-class Very Fast Decision Tree for One-class Classiﬁcation of Data Streams. SensorKDD-2009](http://dl.acm.org/citation.cfm?id=1601981)

下面是阅读论文的笔记：

## Problem:

* 现有的`Data stream`分类器，都是`supervised`分类器；
* `supervised`分类器，要求：`train set`中`instance`都有已知的`class`标签；满足这样条件的`train set`很难获得。

## 解决办法：

* 提出`OcVFDT`算法，效果：`train set`中，一部分`instance`已知`class`标签，剩余`instance`的`class`标签未知；

### 几个基本知识补充说明：

* `one-class`分类：`class`只有2类，`instance`的标签只有两种值，`A`和`非A`，`A`又被称为`target class`；

### OcVFDT有如下几个特点：

1. 只解决`One-class`的分类问题；
2. `train set`：一部分`instance`的`class`为`A`，剩余`instance`为`unknown`；这两类`instance`在`data stream`中服从均匀分布；（对于已经明确`class`为`非A`的`instance`，直接丢弃，不计入`train set`）
3. 算法目前只处理离散属性，对于连续属性，可以先进行离散化处理在使用此算法；
4. 不能处理`concept drift`；
5. 内存空间有限，只扫描一次数据；
6. 能够处理海量数据；
7. 基于算法：`VFDT`和`POSC4.5`；

`OcVFDT`基于`VFDT`的改进，本质仍然是决策树，但与`VFDT`不同的是：

1. 采用`POSC4.5`中使用的信息增益`OcIG(A)`，来衡量属性的分裂概率；
2. 生成一堆树，最后使用自己提出的参数`e(T)`来选取最佳决策树；

__疑问__：`OcVFDT`是怎样被创造出来的？

> 难道是巧合，闭着眼睛瞎尝试，然后走了运，出了个算法？不是的，有依据，即使是一个证据不充分的灵感，那也是最初这样尝试的依据。

下面将深入分析`OcVFDT`算法的最初产生依据：（未完，待续）



[NingG]:    http://ningg.github.com  "NingG"
