---
layout: post
title: MySQL 最佳实践：分库分表
description: MySQL 中，常见的分库分表思路
category: mysql
---

## 概要

关于 MySQL 的分库分表，有几个基本问题：

1. 为什么需要分库分表？解决什么问题？
2. 如何分库分表？
3. 分库分表，需要考虑哪些因素？

## 分库分表

### 为什么？

MySQL 的 InnoDB 存储引擎，使用 `B+Tree` 结构存储索引和数据，当单表的数据量很大时，出现几个现象：

1. 单机`硬件性能`问题：
	1. 单台数据库的`存储能力`不够：单个 DB 的磁盘不足以存储大量数据；
	2. 单机的`网络`、`CPU`都有瓶颈
2. 单机`服务能力`问题：
	1. `数据读取`效率低：因为 `B+Tree` 树深度增加，数据读取效率降低；
	2. `事务并发`效率低：`并发更新`、`并发新增`时，可能会`锁表`，限制了事务并发的效率，同时，数据量大时，索引的数据量也很大，更新索引的效率也很低；
3. `升级扩展`问题：
	1. 单表过大，限制了`表结构调整`相关操作，限制业务升级；
	

备注：

> `自增ID` 与 `锁`，多事务并发新增数据时，自增ID，需要依赖加锁，来解决并发引发的一致性问题：
> 
> 1. **自增长计数器**：auto-increment counter，每个包含自增长 ID 的表，都维护一个
> 2. **表锁**：对`自增长计数器`锁定，AUTO-INC Locking，是一种特殊的`表锁`：不是在事务提交后释放，而是在获取自增 ID 后，就释放
> 3. **优化**：使用`互斥量`（mutex），替代 `表锁`（AUTO-INC Locking），进行优化

### 怎么做？

进行分库分表，要考虑哪些因素呢？

1. `路由规则`：从业务角度分析，确定一条`数据`分配到哪个`库`、哪个`表`；
2. `分库分表`的`维度`：从业务角度出发，根据哪些字段，分库、分表？

分库分表，常见问题：

1. `多维度`的分库分表：从业务角度分析，可能会进行`多维度`的分库分表（举例：按照用户维度分表，但业务上，又需要根据商品维度查询）一般解决思路：
	1. **业务侧**：`双写`，维持`多维度`的分库分表（数据冗余一份）
	2. **数据分级**：`主维度`同步更新 + `次维度`异步更新（bin log），解决`多维度`的分库分表
	3. **搜索中心**：引入集中的搜索中心，解决`多维度分表`的业务需求，只维护`单一维度`的分库分表
2. **联合查询**：分库分表之后，对于`联合查询`问题，一般需要全表扫描，效率极低，建议使用`搜索中心`
3. **跨库事务**：从业务上，避免跨库事务，分布式事务的引入，会加大系统复杂度


#### 核心问题：分库分表，单表多大合适? 

实践经验：

* 单表 `1000万`：写入、读取性能是比较好.
* 留一点 buffer：
	* 单表全是**数值型**（int、datetime）的保持在 `800万`条记录以下；
	* 单表有**字符型**（char、varchar）的单表保持在`500万`以下；

### 整体思路

分库、分表，整体思路，有 2 个：

1. 垂直分库：将单库中数据，拆到多个库中；例如，拆出：用户库、订单库等等；（综合业务，拆分为多个子业务）
2. 水平分表：按照某个路由规则，将数据分散到多个子表中；

垂直分库：

![](/images/mysql-best-practice/mysql-best-practice-vertical-split.jpg)

水平分表：

![](/images/mysql-best-practice/mysql-best-practice-level-split.jpg)

### 补充：分区表

`MySQL 5.1` 版引入的`分区`是一种简单的`水平分表`方案：

1. `建表`的时候，加上`分区参数`，`对应用透明`的无需修改代码
2. 分区表是一个`独立的逻辑表`，但是底层由多个`物理子表`组成
3. `索引`也是按照分区的子表定义，没有全局索引

#### 创建分区表

分区表分为 `RANGE`,`LIST`,`HASH`,`KEY` 四种类型，并且分区表的索引是可以局部针对分区表建立的

创建分区表：

```
CREATE TABLE sales (
    id INT AUTO_INCREMENT,
    amount DOUBLE NOT NULL,
    order_day DATETIME NOT NULL,
    PRIMARY KEY(id, order_day)
) ENGINE=Innodb PARTITION BY RANGE(YEAR(order_day)) (
    PARTITION p_2010 VALUES LESS THAN (2010),
    PARTITION p_2011 VALUES LESS THAN (2011),
    PARTITION p_2012 VALUES LESS THAN (2012),
    PARTITION p_catchall VALUES LESS THAN MAXVALUE);
```   

这段语句表示将表内数据按照`order_dy`的年份范围进行分区：2010年一个区,2011一个,2012一个,剩下的一个.

Note： 

* 分区字段`order_day`必须包含在`主键`中
* 当年份超过阈值,到了2013,2014时,需要手动创建这些分区

替代方法就是使用HASH：

```
CREATE TABLE sales (
    id INT PRIMARY KEY AUTO_INCREMENT,
    amount DOUBLE NOT NULL,
    order_day DATETIME NOT NULL
) ENGINE=Innodb PARTITION BY HASH(id DIV 1000000);
```

这种分区表示每100W条数据建立一个分区,且没有阈值范围的影响.

#### 使用分区表

使用上，跟普通表一样，无特约束。

#### 分区表的优点

分区表的优点：

1. **局部查询**：根据查找条件，也就是 where后面的条件，查找`只查找` `部分分区`
2. **磁盘吞吐量**：跨`多个磁盘`来分散数据查询，来获得更大的查询吞吐量


## 参考来源

* [唯品会订单分库分表的实践总结以及关键步骤](http://www.infoq.com/cn/articles/summary-and-key-steps-of-vip-orders-depots-table)
* [分库分表的几种常见形式以及可能遇到的难](http://www.infoq.com/cn/articles/key-steps-and-likely-problems-of-split-table)
* [MySQL大表优化方案](https://segmentfault.com/a/1190000006158186)
* [MySQL分区表（总结）](http://blog.51yip.com/mysql/1013.html)




[NingG]:    http://ningg.github.com  "NingG"
