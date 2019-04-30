---
layout: post
title: MySQL 最佳实践：常见问题汇总(3)
description: 常见的一些问题，以及底层原理又是什么？
published: true
category: mysql
---


## 1. 三个范式

关于关系型数据库的 3 个范式：

* 第 1 范式：**列不可分**，原子性；例如：地址信息，提取省份和城市。
* 第 2 范式：**非主键属性**完全依赖**主键属性**，一张表格只保存一类数据；例如：学生选课信息，学号、课程名称、学分，需要将课程信息（课程名称、学分）单独提取出来。
* 第 3 范式：**非主键属性**之间，**不存在传递依赖**，即，非主键列之间，没有相互关联关系；

个人感觉，第 2 范式与第 3 范式比较相似；

使用范式的情况：

1. **范式的目标**：**降低数据冗余**；带来的问题：副作用：查询数据时，需要进行表的连接操作；
1. 表格的连接操作比较耗时，需要在**数据冗余**与**范式**之间做好权衡，通常允许一部分的数据冗余来减少表格的连接操作；

更多细节，参考：[数据库设计 3 个范式](/database-nf/)


## 2. 行锁和表锁

MySQL InnoDB 存储引擎，行锁、表锁的基本区别：

* 有索引的时候，行锁；
* 没有索引的时候，表锁；
* InnoDB引擎，支持行锁；（MyISAM引擎支持表锁）

MySQL中行锁、表锁：

* 只有通过索引条件检索数据时，InnoDB才使用行锁，否则，InnoDB将使用表锁；
* MySQL的行锁，是针对索引加的锁，不是针对记录加锁，因此，当访问不同记录行，但是如果使用相同的索引键，仍会产生锁冲突；
* 当表有多个索引的时候，不同的事务可以使用不同的索引锁定不同的行，另外，不论是使用主键索引、唯一索引或普通索引，InnoDB都会使用行锁来对数据加锁。
* MySQL语句自动优化，不使用索引，此时会使用表锁，增加冲突概率：即便在条件中使用了索引字段，但是否使用索引来检索数据是由MySQL通过判断不同执行计划的代价来决定的，如果MySQL认为全表扫描效率更高，比如对一些很小的表，它就不会使用索引，这种情况下InnoDB将使用表锁，而不是行锁。因此，在分析锁冲突时，别忘了检查SQL的执行计划，以确认是否真正使用了索引；
* UPDATE/DELETE SQL尽量带上WHERE条件并在WHERE条件中设定索引过滤条件，否则会锁表，此时性能很差；

更多细节，参考：

* [MySQL中索引、行锁、表锁](/mysql-index-instance-1/)
* [MySQL- InnoDB锁机制](https://www.cnblogs.com/aipiaoborensheng/p/5767459.html)

## 3. 定位低效率的 SQL

定位执行效率较低的SQL语句

* 开启**慢查询日志** （MySQL 5.6与之前的版本，配置上有差异）：只在 SQL 执行结束，才会生成日志
* 查看当前MySQL**正在执行的线程**：线程状态、执行语句，`show processlist`;

具体要点：

1. 开启**慢查询日志**；
1. 慢查询日志，是在**查询结束后**才记录，故，正在执行的慢SQL并不能被定位到；
1. 使用`show processlist`命令查看当前MySQL在**进行的线程**，包括线程的状态、是否锁表等等，可以实时地查看SQL的执行情况；
1. 使用`mysqldumpslow`工具，来辅助查看慢查询日志；
1. 使用`explain`，来分析SQL的执行计划；

更多细节，参考：

* [MySQL 基础：定位效率较低的SQL](/basic-mysql-performance/)

## 4. MyISAM 和 InnoDB 存储引擎比较

关键点：

* InnoDB：
	* 支持事务、支持外键、行锁；
	* 不支持全文检索（不支持fulltext类型的索引）
	* 对应磁盘上文件，`数据文件`与`索引文件`相融合，2 个文件：
		* `frm文件`存放`表结构`
		* `ibd文件`是：数据文件与索引文件
	* 因为是`行锁`，当有大量insert、update时，采用InnoDB存储引擎；
* MyISAM：
	* 不支持事务、不支持外键、表级锁；
	* 支持全文搜索；
	* 对应磁盘上文件：一张MyISAM表存放在 3 个文件：
		* `frm文件`中存放`表结构
		* `MYD`（MYData）是数据文件
		* `MYI`（MYIndex）是索引文件
	* 查询速度快


更多细节，参考：

* [MySQL 基础：数据库MyISAM和InnoDB存储引擎的比较](/basic-mysql-compare-myisam-innodb/)

## 5. Explain 命令

Explain + SQL：可以分析 SQL 的执行计划，辅助定位问题

![](/images/mysql-explain-cmd/explain-details.png)

Explain 的分析结果，几个典型字段，以及含义：

* type：查询到目标数据的方式，全表扫描、范围扫描、主键查询？
	* all：全表扫描
	* index：全表扫描，但依照 index 的排序进行
	* range：依赖索引的范围扫描，一般 where 语句中出现了 between 或 > 之类符号
	* const：常量查询，一般是根据主键进行匹配查询
	* ref：则，需要查看 ref 字段的内容
* possible_keys：可以选择的索引
* key：最终选择的索引
* key_len：索引字段长度
* rows：预估需要扫描的行数
* extra：
* using index：只使用 index 就能获得结果，索引为覆盖索引，涵盖了所有查询的字段，无需回表查询

更多细节，参考：

* [mysql覆盖索引详解](https://blog.csdn.net/jh993627471/article/details/79421363)
* [MySQL中Explain命令](/mysql-explain-cmd/)


## 6. 常见问题汇总

之前的汇总：

* [MySQL 最佳实践：常见问题汇总(2)](http://ningg.top/mysql-best-practice-tips-collection-2/)
* [MySQL 最佳实践：中间件](http://ningg.top/mysql-best-practice-tips-mysql-middleware/)
* [MySQL 最佳实践：分库分表](http://ningg.top/mysql-best-practice-tips-split-database-and-table/)
* [MySQL 技术内幕：主从同步和主从延时](http://ningg.top/inside-mysql-master-slave-delay/)
* [MySQL 技术内幕：索引的数据结构及算法](http://ningg.top/inside-mysql-index-data-structure/)
* [MySQL 技术内幕：事务隔离级别和MVCC](http://ningg.top/inside-mysql-transaction-and-mvcc/)











[NingG]:    http://ningg.github.com  "NingG"











