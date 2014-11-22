---
layout: post
title: MySQL字符编码和大小写敏感问题
description: 没有系统整理过MySQL知识，先这样零散地整理了
category: mysql
---

##背景

关于MySQL，遇到几个问题，列一下：

乱码问题：字符集不统一；
无法启动：查看错误日志；
无法删除database：先在数据存储目录清理；
table找不到：table区分大小写；

MySQL版本：

	[devp@localhost ~]$ mysql -V
	mysql  Ver 14.14 Distrib 5.6.20, for Linux (x86_64) using  EditLine wrapper


##乱码问题

看官网，mysql的refman（reference manual，参考手册）中，globalization --> character set configuration，其中提到：
system、server、client的charset不一致时，会产生乱码。

通过如下命令查看一下，当前mysql各个组件的字符集详情：

	mysql> show variables like "character%";
	+--------------------------+----------------------------+
	| Variable_name            | Value                      |
	+--------------------------+----------------------------+
	| character_set_client     | utf8                       |
	| character_set_connection | utf8                       |
	| character_set_database   | latin1                     |
	| character_set_filesystem | binary                     |
	| character_set_results    | utf8                       |
	| character_set_server     | latin1                     |
	| character_set_system     | utf8                       |
	| character_sets_dir       | /usr/share/mysql/charsets/ |
	+--------------------------+----------------------------+
	8 rows in set (0.00 sec)

通过命令：show collation，查看当前MySQL支持的字符集。从上面查询结果可知，server的字符集与system、client不同，则，在my.cnf文件中`[mysqld]`下，设定server的字符集即可。

	# /usr/my.cnf
	[mysqld]
	character_set_server=utf8
	
**特别说明**：如果client的编码格式不为utf8，则，需要在`my.cnf`文件中添加如下配置（参考[charset connection][charset connection]）：

	# /usr/my.cnf
	[mysql]
	default-character-set=utf8
	
	
重新启动MySQL，OK（根据[官网解释](http://dev.mysql.com/doc/refman/5.6/en/server-system-variables.html#sysvar_character_set_server)，不需要向数据库重新插入数据）。database的编码方式，不要手动调整，其始终与default database保持一致，若没有default database，则由server的编码方式决定。

##无法启动

通过service mysql start，无法启动MySQL，提示出错，略焦躁，不要着急，有错误日志，查看即可。错误日志位置：/var/lib/mysql/*.err，出错信息：

	[ERROR] /usr/sbin/mysqld: unknown variable 'default-character-set=utf-8'
	
原来是在my.cnf文件中添加了一个变量，MySQL无法识别，从my.cnf删除即可。官方文档中[MySQL Server Administration](http://dev.mysql.com/doc/refman/5.6/en/server-administration.html)，有查看错误日志的详细信息，另外，错误日志位置参考[Installing and Upgrading MySQL](http://dev.mysql.com/doc/refman/5.6/en/installing.html)中提到的安装目录结构。


##无法删除Database

删除database时，出错：

	mysql> drop database test;
	ERROR 1010 (HY000): Error dropping database (can't rmdir './test', errno: 39)
	
解决办法：到MySQL存放数据的路径下（/var/lib/mysql/），将test数据库对应目录（./test）下内容清空，再删除test数据库即可。


##找不到table

MySQL无法连接，提示表格不存在，设置table名称不区分大小写：

1. 用ROOT登录，修改`my.cnf`
1. 在`[mysqld]`下加入一行：`lower_case_table_names=1`
1. 重新启动数据库即可;

**思考**：字段是否区分大小写？数据库还有其他大小写敏感的地方吗？


##参考来源

* [MySQL官方文档](http://dev.mysql.com/doc/)
* [Installing and Upgrading MySQL](http://dev.mysql.com/doc/refman/5.6/en/installing.html)
* [MySQL Server Administration](http://dev.mysql.com/doc/refman/5.6/en/server-administration.html)





[charset connection]:			http://dev.mysql.com/doc/refman/5.6/en/charset-connection.html

[NingG]:    http://ningg.github.com  "NingG"