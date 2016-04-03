---
layout: post
title: MySQL中datetime字段的使用
description: 如何查询datetime字段？如何按照datetime字段进行归类？
published: true
category: mysql
---


## 背景

有一张表格usercount：

	mysql> desc usercount;
	+--------------+-------------+------+-----+---------+-------+
	| Field        | Type        | Null | Key | Default | Extra |
	+--------------+-------------+------+-----+---------+-------+
	| datetimes    | datetime    | NO   | PRI | NULL    |       |
	| type         | varchar(20) | NO   | PRI |         |       |
	| number       | varchar(20) | NO   | PRI |         |       |
	| usercount    | int(11)     | YES  |     | 0       |       |
	| auditorcount | int(11)     | YES  |     | 0       |       |
	+--------------+-------------+------+-----+---------+-------+
	5 rows in set (0.00 sec)

	mysql> select * from usercount limit 2;
	+---------------------+------+--------+-----------+--------------+
	| datetimes           | type | number | usercount | auditorcount |
	+---------------------+------+--------+-----------+--------------+
	| 2015-05-12 09:00:00 | cib  | 00     |         1 |        12118 |
	| 2015-05-12 10:00:00 | cib  | 00     |         1 |        35804 |
	+---------------------+------+--------+-----------+--------------+
	2 rows in set (0.00 sec)

目标：统计指定时间段内，每天累计的usercount，具体：

* 查找到指定时间段内，记录数目；
* 对返回结果，按照年月日进行group操作，同时按照usercount字段进行sum操作；
* 最后结果以：datetime的年月日、以及sum(usercount)输出；


## 查询指定时间段内结果

几种方式：

* between ... and ...

### between...and方式

代码如下：

	mysql> select * from usercount where 
	(datetimes between '2015-05-17 00:00:00' and '2015-05-19 23:00:00') 
		and (type = 'cib') and (number = '00');
	+---------------------+------+--------+-----------+--------------+
	| datetimes           | type | number | usercount | auditorcount |
	+---------------------+------+--------+-----------+--------------+
	| 2015-05-17 00:00:00 | cib  | 00     |         1 |        35842 |
	| 2015-05-17 01:00:00 | cib  | 00     |         1 |        35834 |
	... ...
	| 2015-05-19 23:00:00 | cib  | 00     |         1 |        35635 |
	+---------------------+------+--------+-----------+--------------+
	24 rows in set (0.01 sec)

Tips：

> datetime类型字段的between...and...是一个闭合区间，包含起点和终点；


## 按照年月日进行group

几种方式：

* left(FIELD_NAME, LEN)



### left函数

示例代码如下：

	mysql> select * from usercount 
		where (datetimes between '2015-05-17 00:00:00' and '2015-05-19 23:00:00')
			and (type = 'cib') and (number = '00') 
		group by left(datetimes, 10);
	+---------------------+------+--------+-----------+--------------+
	| datetimes           | type | number | usercount | auditorcount |
	+---------------------+------+--------+-----------+--------------+
	| 2015-05-17 00:00:00 | cib  | 00     |         1 |        35732 |
	| 2015-05-18 00:00:00 | cib  | 00     |         1 |        35929 |
	| 2015-05-19 00:00:00 | cib  | 00     |         1 |        35842 |
	+---------------------+------+--------+-----------+--------------+
	3 rows in set (0.00 sec)

## 计算group内字段的sum结果

直接对group获得的分组，进行组内`sum(FIELD_NAME)`操作即可，示例代码：

	mysql> select datetimes,sum(usercount) from usercount 
	where (datetimes between '2015-05-17 00:00:00' and '2015-05-19 23:00:00') 
		and (type = 'cib') and (number = '00') 
	group by left(datetimes, 10);
	+---------------------+----------------+
	| datetimes           | sum(usercount) |
	+---------------------+----------------+
	| 2015-05-17 00:00:00 |             24 |
	| 2015-05-18 00:00:00 |             24 |
	| 2015-05-19 00:00:00 |             24 |
	+---------------------+----------------+
	3 rows in set (0.01 sec)

如果希望只返回datetimes字段的年月日信息，可以对查询结果字段使用`left(FIELD_NAME, LEN)`函数截取，示例代码如下：

	mysql> select left(datetimes, 10),sum(usercount) from usercount
	 where (datetimes between '2015-05-17 00:00:00' and '2015-05-19 23:00:00') 
	 and (type = 'cib') and (number = '00') 
	 group by left(datetimes, 10);
	+---------------------+----------------+
	| left(datetimes, 10) | sum(usercount) |
	+---------------------+----------------+
	| 2015-05-17          |             24 |
	| 2015-05-18          |             24 |
	| 2015-05-19          |             24 |
	+---------------------+----------------+
	3 rows in set (0.00 sec)

如果希望返回结果，按照datetimes字段升序排列，则，使用`order by FIELD_NAME asc`，示例代码如下：

	mysql> select left(datetimes, 10),sum(usercount) from usercount
	 where (datetimes between '2015-05-17 00:00:00' and '2015-05-19 23:00:00')
		and (type = 'cib') and (number = '00') 
	 group by left(datetimes, 10) 
	 order by datetimes asc;
	+---------------------+----------------+
	| left(datetimes, 10) | sum(usercount) |
	+---------------------+----------------+
	| 2015-05-17          |             24 |
	| 2015-05-18          |             24 |
	| 2015-05-19          |             24 |
	+---------------------+----------------+
	3 rows in set (0.00 sec)


## datetime类型字段的查询范围


当datetime类型字段，只使用`2015-05-19`格式来约束datetime时，默认为`2015-05-19 00:00:00`，示例代码如下：

	mysql> select datetimes,sum(usercount) from usercount 
	where (datetimes between '2015-05-17' and '2015-05-19') 
		and (type = 'cib') and (number = '00') 
	group by left(datetimes, 10) 
	order by datetimes asc; 

	+---------------------+----------------+
	| datetimes           | sum(usercount) |
	+---------------------+----------------+
	| 2015-05-17 00:00:00 |             24 |
	| 2015-05-18 00:00:00 |             24 |
	| 2015-05-19 00:00:00 |              1 |
	+---------------------+----------------+
	3 rows in set (0.00 sec)

## 关于datetime、date、time、timestamp的简单对比


todo:

* [mysql 字段类型总结---date datetime 等时间类型][mysql 字段类型总结---date datetime 等时间类型]




















[NingG]:    http://ningg.github.com  "NingG"


[mysql 字段类型总结---date datetime 等时间类型]:			http://blog.csdn.net/xluren/article/details/32738555










