---
layout: post
title: MySQL中索引、行锁、表锁
description: 不同的存储引擎支持不同粒度的锁，同时也与具体的SQL语句相关
published: true
category: MySQL
---

几点：

* 如何查看一张表格是否创建索引？
* 如何创建索引？修改索引？
* SQL执行过程中，如何确定调用了行锁还是表锁？


##查看索引

官网来源：[MySQL 5.6 SHOW INDEX Syntax][MySQL 5.6 SHOW INDEX Syntax]。

具体命令：

* `show index from tbl_name`
* `show keys from tbl_name`

查询结果如下：

![](/images/mysql-index-instance-1/show-index.png)

其中包含多个字段，详细说明参考[官网][MySQL 5.6 SHOW INDEX Syntax]，简单说几个：

* Collation：Column在索引中存储的方式。在MySQL中，有值`A`（升序）或`NULL`（无分类）。
* Cardinality：索引中不重复数值的个数，估计值，也称`基数`。通过运行`ANALYZE TABLE`或`myisamchk -a`可以修改`Cardinality`。**基数**，根据被存储为整数的统计数据来计数，所以即使对于小型表，该值也没有必要是精确的。基数越大，当进行联合时，MySQL使用该索引的机会就越大。
* Sub_part：如果列只是被部分地编入索引，则为被编入索引的字符的数目。如果整列被编入索引，则为`NULL`。
* Packed：指示关键字如何被压缩。如果没有被压缩，则为`NULL`。


##创建/修改索引

索引的目标：加快数据的查询速率；索引文件，跟数据文件类似，也是存储在磁盘上的文件，实际上索引文件较小时，可以完全读入内存，但事实是：索引文件通常很大无法完全加载到内存，进行数据检索时，需要经过多次磁盘IO；

###建表时，建索引


（todo）





###建表后，修改索引


（todo）



##查看MySQL下的环境变量

在MySQL下查看环境变量，命令：

* `show variables;`
* `show variables like "auto%";`：查看指定前缀的环境变量


##行锁和表锁

几点：

* 调用存储过程中，行锁、表锁的基本区别：
	* 有索引的时候，行锁；
	* 没有索引的时候，表锁；
	* InnoDB引擎，支持行锁；*（MyISAM引擎支持表锁）*
* MySQL中行锁、表锁：
	* 只有通过索引条件检索数据时，InnoDB才使用行锁，否则，InnoDB将使用表锁；
	* MySQL的行锁，是针对索引加的锁，不是针对记录加锁，因此，当访问不同记录行，但是如果使用相同的索引键，仍会产生锁冲突；
	* 当表有多个索引的时候，不同的事务可以使用不同的索引锁定不同的行，另外，不论是使用主键索引、唯一索引或普通索引，InnoDB都会使用行锁来对数据加锁。
	* MySQL语句自动优化，不使用索引，此时会使用表锁，增加冲突概率：即便在条件中使用了索引字段，但是否使用索引来检索数据是由MySQL通过判断不同执行计划的代价来决定的，如果MySQL认为全表扫描效率更高，比如对一些很小的表，它就不会使用索引，这种情况下InnoDB将使用表锁，而不是行锁。因此，在分析锁冲突时，别忘了检查SQL的执行计划，以确认是否真正使用了索引；
	* UPDATE/DELETE SQL尽量带上WHERE条件并在WHERE条件中设定索引过滤条件，否则会锁表，此时性能很差；

思考：上述的行锁、表锁，是写锁吗？还是读锁？还是都有可能？RE：既有读锁，也有写锁，详细阅读下面扩展内容：

* [MySQL中SELECT+UPDATE处理并发更新问题解决方案分享]









（todo）：

* [MySQL行锁和表锁]
* [Mysql InnoDB行锁实现方式]

























##参考来源

* [MySQL 5.6 Reference Manual][MySQL 5.6 Reference Manual]
* [创建索引、修改索引、删除索引的命令语句][创建索引、修改索引、删除索引的命令语句]
* [MySQL数据库如何创建索引][MySQL数据库如何创建索引]





##杂谈

对于MySQL多查看官方手册，其中包含的内容权威、丰富。

MySQL官方手册的查看方法：

* 在线打开[MySQL 5.6 Reference Manual][MySQL 5.6 Reference Manual]；
* 在`Search manual`方框内，检索相应的命令，例如`show index from `；








[NingG]:    http://ningg.github.com  "NingG"


[MySQL 5.6 Reference Manual]:			http://dev.mysql.com/doc/refman/5.6/en/index.html
[MySQL 5.6 SHOW INDEX Syntax]:			http://dev.mysql.com/doc/refman/5.6/en/show-index.html

[创建索引、修改索引、删除索引的命令语句]:			http://www.cnblogs.com/mfryf/p/3642667.html
[MySQL数据库如何创建索引]:							http://jingyan.baidu.com/article/da1091fbd166ff027849d687.html

[MySQL行锁和表锁]:						http://keshion.iteye.com/blog/1409563
[Mysql InnoDB行锁实现方式]:				http://www.2cto.com/database/201208/145888.html

[MySQL中SELECT+UPDATE处理并发更新问题解决方案分享]:		http://www.jb51.net/article/50103.htm




