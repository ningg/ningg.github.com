---
layout: post
title: MySQL字段类型与适用场景
description: tinyint？smallint？int？bigint？
published: true
category: MySQL
---


##int相关


在MySQL中 int 的 最大值可以看成 2 个：

* 无符号的：2147483647，
	* 4byte，2的32次方，
	* 无符号的设定是：`unsigned`
* 有符号的：4294967295




|类型 |字节 |最小值 |最大值|
| 	  |     |(带符号的/无符号的) |(带符号的/无符号的)|
|TINYINT |1 |-128 |127 |
| 	  | 	  |0 |255|
|SMALLINT |2 |-32768 |32767|
| 	  | 	  |0 |65535|
|MEDIUMINT |3 |-8388608 |8388607|
| 	  | 	  |0 |16777215|
|INT |4 |-2147483648 |2147483647|
|	   | 	  |0 |4294967295|
|BIGINT |8 |-9223372036854775808 |9223372036854775807|
| 	  |	   |0 |18446744073709551615|


补充：

* bigint已经有长度了，在mysql建表中的length，只是用于显示的位数；
* 创建id的时候会给主键 、unsigned 、auto_increment  然后其他表与该表的id字段进行连接，注意最大值为 4294967295（42亿）


int类型为4字节，那`int(5)`的含义是什么？实际上`int(5)`与字段值的范围无关，仅表示显示效果。参考：[详解mysql int类型的长度值问题]。

##date、datetime、timestamp

几点：

* 几个时间相关字段类型的差异；
* Java中对应的类型；*（Hibernate、MyBatis等对应的VO）*

todo：

* [MySQL数据库和Java的时间类型详细解析][MySQL数据库和Java的时间类型详细解析]






























##参考来源

* [MySQL reference Manual - Chapter 11 Data Types][MySQL reference Manual - Chapter 11 Data Types]





[NingG]:    												http://ningg.github.com  "NingG"
[MySQL reference Manual - Chapter 11 Data Types]:			http://dev.mysql.com/doc/refman/5.6/en/data-types.html
[MySQL数据库和Java的时间类型详细解析]:						http://database.51cto.com/art/201005/202730.htm



[详解mysql int类型的长度值问题]:				http://www.2cto.com/database/201208/150865.html





