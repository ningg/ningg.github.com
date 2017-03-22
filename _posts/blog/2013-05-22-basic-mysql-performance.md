---
layout: post
title: MySQL 基础：定位效率较低的SQL
description: 
published: true
category: mysql
---

几点：

* 基本操作和概念：
	* MySQL**配置文件**位置，查找`my.cnf`或`my.ini`
	* MySQL**数据文件**位置，`ps -ef | grep mysql`
	* 查看MySQL的版本，`man mysql` 可知 `mysql -V`
	* `mysql` 与 `mysqld` 之间关系
	* 游标的含义
* 定位执行效率较低的SQL语句
	* 开启慢查询日志 *（MySQL 5.6与之前的版本，配置上有差异）*
	* 查看当前MySQL正在执行的线程：线程状态、执行语句，`show processlist;`



## 常见概念


### 问题：mysql与mysqld之间关系

可以直接通过man命令查看两者的简介，即：

* `man mysql`
* `man mysqld`

简要说明几点：

* `mysqld`是**服务器端的后台进程**，启动服务器，本质就是启动该进程；
* `mysql`是连接MySQL的**命令行客户端工具**；


参考来源：

* [mysql命令(官网)]
* [mysqld命令(官网)]


### 问题：查看MySQL的版本

通过`man mysql`可知`mysql -V`即可查询mysql的版本信息，具体如下：

	$ mysql -V
	mysql  Ver 14.14 Distrib 5.6.20, for Linux (x86_64) using  EditLine wrapper


### 问题：MySQL配置文件位置，查找`my.cnf`或`my.ini`

命令：

```
find / -name "my.cnf"
```

### 问题：MySQL数据文件位置？

直接查询MySQL服务器端的运行进程信息，`ps -ef | grep mysqld`，具体：

```
$ ps -ef | grep mysqld
root      8368     1  0 Mar13 ?        00:00:00 /bin/sh /usr/bin/mysqld_safe --datadir=/var/lib/mysql --pid-file=/var/lib/mysql/cib02167.pid
mysql     8505  8368  4 Mar13 ?        3-05:54:30 /usr/sbin/mysqld --basedir=/usr --datadir=/var/lib/mysql --plugin-dir=/usr/lib64/mysql/plugin --user=mysql --log-error=/var/lib/mysql/cib02167.err --pid-file=/var/lib/mysql/cib02167.pid
```

从上述查询结果可知，`datadir`指定了数据文件目录。


### 问题：游标的含义？


批量 SQL 构成一个`存储过程`，其中，一个存储过程 SQL 语句，分为几类：

1. 无返回结果：INSERT, UPDATE, DROP, DELETE等
2. 单行结果：select语句返回单行变量并可传给本地变量(select ..into)
3. 多行结果：多行结果集的select语句,并可使用MySQL`游标`循环处理

更多信息，参考：[http://www.cnblogs.com/sk-net/archive/2011/09/07/2170224.html](http://www.cnblogs.com/sk-net/archive/2011/09/07/2170224.html)


## 慢查询及优化


几点：

* 开启`慢查询` `日志`；
* 慢查询日志是在`查询结束`后才记录，故正在执行的慢SQL并不能被定位到；
* 使用`show processlist`命令查看当前MySQL在进行的线程，包括线程的状态、是否锁表等等，可以实时地查看SQL的执行情况；
* 使用`mysqldumpslow`工具来辅助查看慢查询日志；
* 使用`explain`来分析SQL的执行计划；

慢查询日志，详情：[http://www.cnblogs.com/sk-net/archive/2011/09/07/2170224.html](http://www.cnblogs.com/sk-net/archive/2011/09/07/2170224.html)


### 慢查询日志参数

配置参数，要解决几个问题：

1. 慢查询，是否开启
2. 慢查询，时间阈值
3. 慢查询，存储方式：数据表？文件？
4. 慢查询，文件存储：文件地址


MySQL 慢查询的相关参数解释：

* `slow_query_log` ：是否开启慢查询日志，1表示开启，0表示关闭。
* `long_query_time` ：慢查询阈值，当查询时间多于设定的阈值时，记录日志。
* `log_output`：日志存储方式。`log_output='FILE'`表示将日志存入文件，默认值是`'FILE'`。`log_output='TABLE'`表示将日志存入数据库，这样日志信息就会被写入到`mysql.slow_log`表中。MySQL数据库支持同时两种日志存储方式，配置的时候以逗号隔开即可，如：`log_output='FILE,TABLE'`。日志记录到系统的专用日志表中，要比记录到文件耗费更多的系统资源，因此对于需要启用慢查询日志，又需要能够获得更高的系统性能，那么建议优先记录到文件。
* `log-slow-queries`：旧版（5.6以下版本）MySQL数据库慢查询日志存储路径。可以不设置该参数，系统则会默认给一个缺省的文件`host_name-slow.log`
* `slow-query-log-file`：新版（5.6及以上版本）MySQL数据库慢查询日志存储路径。可以不设置该参数，系统则会默认给一个缺省的文件`host_name-slow.log`



todo：

* [MySQL索引原理及慢查询优化][MySQL索引原理及慢查询优化]
* [MySql定位执行效率较低的SQL语句][MySql定位执行效率较低的SQL语句]
* [mysql性能问题定位][mysql性能问题定位]
* [如何定位效率较低的SQL][如何定位效率较低的SQL]

单独写一篇：

* [影响MySQL性能的五大配置参数][影响MySQL性能的五大配置参数]




## 参考来源

* [MySQL索引原理及慢查询优化][MySQL索引原理及慢查询优化]
* [MySql定位执行效率较低的SQL语句][MySql定位执行效率较低的SQL语句]
* [mysql性能问题定位][mysql性能问题定位]
* [如何定位效率较低的SQL][如何定位效率较低的SQL]













[NingG]:    http://ningg.github.com  "NingG"



[mysql命令(官网)]:			https://dev.mysql.com/doc/refman/5.6/en/mysql.html
[mysqld命令(官网)]:			https://dev.mysql.com/doc/refman/5.6/en/mysqld.html



[MySQL索引原理及慢查询优化]:			http://blog.chedushi.com/archives/10000
[MySql定位执行效率较低的SQL语句]:		http://blog.itpub.net/195110/viewspace-1082666/



[mysql性能问题定位]:		http://www.2cto.com/database/201309/246919.html
[如何定位效率较低的SQL]:	http://linux.chinaunix.net/techdoc/database/2009/07/20/1125187.shtml


[影响MySQL性能的五大配置参数]:		http://blog.csdn.net/xifeijian/article/details/19775017
