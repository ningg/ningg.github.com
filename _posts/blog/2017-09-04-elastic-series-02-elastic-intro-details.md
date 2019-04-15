---
layout: post
title: Elastic 系列：定位和基本用法
description: Elastic 能解决什么问题？对外提供的组件，极其基本用法？
published: true
category: elasticsearch
---


## 1. 概要

关于 Elastic 服务，几个思路：

1. 能做什么：当前官方对 Elastic 的定位
1. 如何使用：
	1. 基本用法：常用组件的基本用法
	1. 运维部署：生产部署方案，物理机、虚拟机、Docker、Kubernetes 等方案



## 2. Elastic 定位

根据 [Elastic] 官网中的介绍， Elastic 定位：

* 以 `ElasticSearch` **搜索引擎**作为核心，扩展支持监控、告警、分析等关联场景。

先不关注太多情况，单纯只考虑 `ElasticSearch` 构建`轻量级`搜索中心的场景。


## 3. ElasticSearch 的用法

几个方面：

1. 基本用法：如何搭建一个 ElasticSearch 节点、以及集群？是否存在管理界面？
2. 基本原理：ElasticSearch 构建索引时，其基本原理、内部术语什么含义？

### 3.1. 基本用法

关于 ElasticSearch，如何搭建一个测试节点，以及基本的增加、查询、删除索引操作，参考：

* [ElasticSearch入门操作](/elasticsearch-intro/)

有个疑问：

* 是否存在 ElasticSearch 的管理后台页面，进行索引的增删改服务？


TODO


### 3.2. 基本原理

ElasticSearch 下，存在几个术语：

* node
* index
* type
* field
* document

具体的含义，以及相互关系。

TODO


## 4. 参考资料


* [Elastic] 官网
* [ElasticSearch]









[NingG]:    http://ningg.github.com  "NingG"
[Elastic]:		https://www.elastic.co/cn/
[ElasticSearch]:		https://www.elastic.co/cn/products/elasticsearch









