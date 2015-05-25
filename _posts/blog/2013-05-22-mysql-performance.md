---
layout: post
title: MySQL定位效率较低的SQL
description: 
published: true
category: MySQL
---

几点：

* 基本操作和概念：
	* MySQL配置文件位置，查找`my.cnf`或`my.ini`
	* MySQL数据文件位置，`ps -ef | grep mysql`
	* 查看MySQL的版本，man mysql可知`mysql -V`
	* mysql与mysqld之间关系
	* 游标的含义
	* MyISAM与InnoDB之间的区别，支持事务？系统表的存储引擎有哪些？
* 定位执行效率较低的SQL语句
	* 开启慢查询日志*（MySQL 5.6与之前的版本，配置上有差异）*
	* 查看当前MySQL正在执行的线程：线程状态、执行语句，`show processlist;`







todo：

* 整理MySQL的基本文章，将其合并整理。


##常见概念


问题：mysql与mysqld之间关系

可以直接通过man命令查看两者的简介，即：

* `man mysql`
* `man mysqld`

简要说明几点：

* mysqld是服务器端的后台进程，启动服务器，本质就是启动该进程；
* mysql是连接MySQL的命令行客户端工具；


参考来源：

* [mysql命令(官网)]
* [mysqld命令(官网)]


问题：查看MySQL的版本，

通过`man mysql`可知`mysql -V`即可查询mysql的版本信息，具体如下：

	$ mysql -V
	mysql  Ver 14.14 Distrib 5.6.20, for Linux (x86_64) using  EditLine wrapper


问题：MySQL配置文件位置，查找`my.cnf`或`my.ini`

命令：`find / -name "my.cnf"`

问题：MySQL数据文件位置？

直接查询MySQL服务器端的运行进程信息，`ps -ef | grep mysqld`，具体：

	$ ps -ef | grep mysqld
	root      8368     1  0 Mar13 ?        00:00:00 /bin/sh /usr/bin/mysqld_safe --datadir=/var/lib/mysql --pid-file=/var/lib/mysql/cib02167.pid
	mysql     8505  8368  4 Mar13 ?        3-05:54:30 /usr/sbin/mysqld --basedir=/usr --datadir=/var/lib/mysql --plugin-dir=/usr/lib64/mysql/plugin --user=mysql --log-error=/var/lib/mysql/cib02167.err --pid-file=/var/lib/mysql/cib02167.pid

从上述查询结果可知，`datadir`指定了数据文件目录。



问题：游标的含义？






问题：MyISAM与InnoDB之间的区别，支持事务？系统表的存储引擎有哪些？



##慢查询及优化


todo：

* [MySQL索引原理及慢查询优化][MySQL索引原理及慢查询优化]
* [MySql定位执行效率较低的SQL语句][MySql定位执行效率较低的SQL语句]
* [mysql性能问题定位][mysql性能问题定位]
* [如何定位效率较低的SQL][如何定位效率较低的SQL]

单独写一篇：

* [影响MySQL性能的五大配置参数][影响MySQL性能的五大配置参数]











##参考来源

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
