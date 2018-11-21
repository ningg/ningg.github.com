---
layout: post
title: Elastic 系列：概述
description: 根据之前 solr 搜索服务的使用，针对 ElasticSearch 作为轻量级搜索中心的思考
published: true
category: elasticsearch
---


## 概要

**轻量级搜索中心**：之前公司内部，采用 solr 的 web 服务，作为业务侧的搜索中心，同时，搜索中心的运维、管理等工作，也直接由业务研发负责，业务演进效率非常高。

通用的业务分析，不涉及海量数据，也不涉及极其复杂的分析，因此，solr 采用 Master + Slave 结构，即可满足需求：

1. **集群结构**：`1 + 2` 集群，1 个 Master、2 个 Slave，具体发布服务时，设置指定的机器为 master，其他指定机器为 slave 角色
2. **域名区分**：Nginx 上配置 master.solr.xxx.com 和 slave.solr.xxx.com
3. **读写分离**：Nginx 上配置，更新的请求 POST 送入 master 服务器，读取的请求 GET 送入 slave

当时 Solr 的 web 服务配置，跟 [Solr服务的搭建] 基本类似，只不过采用 Maven + Jetty 的管理方式，同时，依赖服务启动的环境变量，指定具体机器上的 master 和 slave 角色。

关于上述场景，有几个疑问：

1. **索引文件存储**：上述 solr 服务，完全以 web 服务发布，其构建的索引文件，直接存储在「具体机器本地」吗？也就是说，如果需要迁移机器，也需要迁移索引文件 or 需要重建索引文件。
2. **ElasticSearch 服务**：按照上述 solr 的 web 服务模式，当前流行的 ElasticSearch 是否也可以直接构建 `轻量级`的搜索中心呢？

基于上述业务场景，考虑 ElasticSearch 构建 `轻量级搜索中心`.

## Elastic 思考


> **基本思路**：接触到 ElasticSearch，希望构建轻量级的搜索中心，但 Elastic 的社区可能是另外的操作思路，因此，需要：
> 
> 1. 熟悉：先理解 Elastic 的全貌，并试用其基本用法；
> 2. 使用：再其起对轻量级搜索中心的支持；


### 熟悉 Elastic

关于 Elastic 服务，几个思路：

1. 能做什么：当前官方对 Elastic 的定位
1. 如何使用：
	1. 基本用法：常用组件的基本用法
	1. 运维部署：生产部署方案，物理机、虚拟机、Docker、Kubernetes 等方案

主要参考：

* [Elastic] 官网

### 使用 Elastic

使用 Elastic：构建轻量级搜索中心






## 参考资料

* [Solr服务的搭建]
* [Elastic] 官网









[NingG]:    http://ningg.github.com  "NingG"
[Solr服务的搭建]:		https://my.oschina.net/u/3375733/blog/1546608
[Elastic]:		https://www.elastic.co/cn/









