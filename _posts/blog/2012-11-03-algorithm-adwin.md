---
layout: post
title: 算法阅读：ADWIN
description: Learning from Time-Changing Data with Adaptive Windowing
category: data stream algorithm
---

原文来源：

> [Learning from Time-Changing Data with Adaptive Windowing. Albert Bifet. Ricard Gavalda. 2006](http://epubs.siam.org/doi/abs/10.1137/1.9781611972771.42)

---

考虑concept_drift的典型data_stream_mining过程为：

> 1. 初次建模；
> 2. 检测change；
> 3. 更新模型；
> 4. 数据存储；

__说明__：”4.数据存储”是辅助前面三个功能的；那么，哪些数据需要存储呢？原始的example数据、最终的统计特征数据、其他中间数据。

## 1.ADWIN基本算法

ADWIN算法，主要为改进`2.检测change`过程。

`检测change`的主要策略之一是：`sliding window`(滑动窗口)。使用滑动窗口，通常是比较2个窗口(子窗口)中的统计值；依据2个窗口大小是否相等、两个窗口位置是否固定，可将滑动窗口分为4类（参考`MOA`自带文档`Stream Mining`中7.2），如下图：

![adwin sliding window](/images/algorithm-adwin/adwin-sliding-window.jpg)

`ADWIN`比其他动态调整`sliding window`的算法优越的地方：提出两个界限值（`False positive rate bound`：窗口内数据流的分布特征值没有改变，但判断失误，导致调整窗口的最大概率；`False negative rate bound`：窗口内数据流的分布特征值确实发生改变，窗口判断正确，并调整窗口的概率）。

上面是一个简要的介绍，下面将以问答式的探索过程，来重现当时的`ADWIN`算法产生场景：

在此之前有两个基本的问题：为什么要有滑动窗口？对于一个静态的流，滑动窗口大小是固定的，那这个固定值的大小是依据什么确定的？思考了这两个问题之后，就可以开始下面的问题了。

> * __目标__：动态调整滑动窗口大小，这是一个具体的操作；
> * __什么时候调整滑动窗口__？当检测到change时；
> * __怎么衡量change__？使用标识data_stream的特征值，如果特征值变化超过某一门限值，则认为，change已经发生，需要进行调整滑动窗口大小；
> * __特征值都有哪些__？方差、均值等；
> * __特征值的门限值怎么确定？即，判断标准是什么__？确定特征值的标准是：没有change发生时，判断change已经发生的概率要尽可能小；change已经发生，判断change已经发生的概率要尽可能大，并且速度要尽可能快。


分析到这，已经可以抽象出数学模型了，数据挖掘的问题已经成功转换为纯正的数学问题。（对于这个问题的问答式探索，不只是上面这一种角度，如果有兴趣可以从其他角度出发，抽象为其他数学问题；当然可能有的角度，探索下去，并不能将问题简化，需要多次尝试）以“没有change发生时，判断change已经发生的概率尽可能小”为数学模型的约束条件为例，抽象得到的数学模型可以描述为：

从一个稳定分布的流中，取两段数据，并求得他们的均值分别为`u1`、`u2`，那么求门限值e，使得 `|u1-u2|>e`的概率小于`σ`，其中`σ`为我们设定的概率值。

自己上面的数学描述不是很规范，但基本意思已经表示清楚了，`σ`在`ADWIN`中对应的实际意义是：没有`change`发生时，判断`change`已经发生的概率。

## 2.ADWIN2算法

`ADWIN`的初始算法，我们称作：`ADWIN0`，其存在以下两个缺点：

> 1. `possible cutpoint`过多，共计`W-1`个，其中`W`是`sliding window`的大小；
> 2. `slidling window`中存储完整的example内容，占用内存过多；


为克服上面两个问题，对`ADWIN0`算法进行了改进，得到`ADWIN2`算法，他在保证算法两个界限值（`False positive rate bound`、`False negative rate bound`）基本保持不变的情况下，减少了内存的使用，并且降低了算法处理时间。下面是对`ADWIN2`的简要说明：

> * `ADWIN2`算法的输入参数`M`，人为设定，其作用可以参考原论文；
> * `ADWIN2`中将原始的`sliding window`划分为`buckets`；对于`bucket`，我个人将其称为`subwindow`，因为`buckets`片段构成了整个`sliding window`；
> * `bucket`按大小(size)分为不同的级别：`1`，`2`，`4`，`8`，…（2的i次幂的形式）
> * 每个级别的`bucket`，最多可以同时存在M个；
> * 当某一个级别`bucket`存在`M+1`个时，将合并其中的前2个`bucket`，构成一个更高一级的`bucket`；
> * 以`bucket`的边界位置，作为`possible cutpoint`；
> * `last bucket`带入了当前的估计误差（因为`last_bucket`在时间上离现在最远，最不能反应当前`data stream`的数据特征），因此当检测到`change`时，就删掉`last bucket`；

上面部分都是对于论文的提炼、总结，最基本、最关键的还是对于论文的反复阅读，阅读过程中，可以参考上面自己的总结。

__建议__：博客只是辅助，推荐先阅读算法原文，然后逐条的琢磨本blog中的内容。

---

[NingG]:    http://ningg.github.com  "NingG"
