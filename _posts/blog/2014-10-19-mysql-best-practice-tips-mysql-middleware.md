---
layout: post
title: MySQL 最佳实践：中间件
description: 常用中间件的思路
category: mysql
---

几个朴素的问题：

1. MySQL 中间件，能解决什么问题？
2. 解决问题的基本思路？
3. 每种思路，具体实现方案

## MySQL 中间件，作用？

* 数据库直连：
	* 特点：简单直接
	* 单表、单库：`硬件`、`软件服务`、`后期维护`，都会成为问题
		* 物理瓶颈：单机存储、CPU、网络
		* 服务瓶颈：锁表的并发事务
		* 后期维护：单表过大变更 schema 维护成本
* 中间件：通过增加机器的方式，横向扩展数据服务，向业务侧屏蔽细节。

### 数据库直连

数据库直连，特点：

* 传统方式，直接连接数据库，访问数据库，这种方式简单。

数据库直连，问题：

* 随着数据量增大、访问量增大、读写都会遇到瓶颈

解决办法：

* 增加机器，数据库放到不同服务器上，在 App 和 DB 之间，添加 proxy 负责路由，就可以解决单机的瓶颈。

![](/images/inside-mysql/mysql-middleware-direct.png)

### 中间件：代理

中间件代理层，负责屏蔽底层细节，对外提供一致的服务，具体：

1. 读写分离
2. 分库分表
3. 故障转移

![](/images/inside-mysql/mysql-middleware-proxy.png)


## 基本思路

MySQL 中间件的目标：

1. 读写分离
2. 从库负载均衡
3. 分库分表
4. 故障转移

MySQL 中间件，整体上 2 个思路：

* 独立 proxy：独立的代理层
* client proxy：client 侧的代理层

![](/images/inside-mysql/mysql-middleware-separate-proxy.png)

![](/images/inside-mysql/mysql-middleware-client-based-proxy.png)


## 具体实现


几个常见 MySQL 中间件的对比：

* 独立 proxy：[Atlas]
* Client proxy：[TDDL]


具体特点，简单介绍：

Atlas:

* 奇虎360开发维护的一个基于MySQL协议的数据中间层项目。它实现了MySQL的客户端与服务端协议，作为服务端与应用程序通讯，同时作为客户端与MySQL通讯
* 实现读写分离、多从库负载均衡、fail over、统一连接池管理、单库分表
* 功能简单，性能跟稳定性较好
* 只支持分表，不支持分库

TDDL:

* 淘宝根据自己的业务特点开发了TDDL框架，主要解决了分库分表对应用的透明化以及异构数据库之间的数据复制，它是一个基于集中式配置的jdbc datasource实现
* 实现动态数据源、读写分离、分库分表
* 功能齐全
* 分库分表功能还未开源，当前公布文档较少，并且需要依赖diamond（淘宝内部使用的一个管理持久配置的系统）

另外，美团也开源了[DBProxy]中间件。


## 参考来源

* Java 中间件中，数据库中间件的介绍
* [Atlas]
* [TDDL]
* [DBProxy]










[NingG]:    http://ningg.github.com  "NingG"
[Atlas]:		https://github.com/Qihoo360/Atlas
[TDDL]:		https://github.com/alibaba/tb_tddl
[DBProxy]:	http://tech.meituan.com/dbproxy-pr.html







