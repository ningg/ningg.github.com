---
layout: post
title: 大型网站架构：伸缩性
description: 伸缩性是什么？如何衡量？如何优化？
published: true
category: arch
---


整体思路：
什么是系统伸缩性？衡量指标？
如何做？常见思路？

## 1. 伸缩性，是什么

网站的可伸缩性，是指：不改变软件、硬件的设计，只通过增加机器数量，就能扩大服务能力（减少机器数量，就缩小网站服务能力）。即：

1. 不改变：软硬件设计
1. 变更机器数量，扩大或减小服务能力。
1. 机器数量 → QPS

## 2. 伸缩性，为什么需要

这是跟互联网的特点相匹配的：

1. **网站发展规律**：`渐进式`，都是演进而来的，从小到大，从一台机器扩展到集群
1. **运营需求**：突发峰值访问，即，短时间内，访问量和交易规模，爆发式增长

Note：

> 伸缩性，更多的是伸，因为，一旦系统到了缩的阶段，就说明要衰退了。

小知识：

> 传统行业思维介入互联网，一般会依照传统行业的管理模式和经营理念，上来就想打造一个大型网站。
这种「大型网站起步」的思维，需要调整一下，来适应互联网的快速变化。







[NingG]:    http://ningg.github.com  "NingG"









