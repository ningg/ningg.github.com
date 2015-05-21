---
layout: post
title: Java与数据库交互，Statement、PreparedStatement
description: Java操作数据库基本过程，Statement、PreparedStatement之间差异
published: true
category: MySQL
---



几点：

* JDBC是什么？
* Java操作MySQL数据库的基本过程
* Statement、PrepearedStatement之间比较


##JDBC

JDBC(Java Database Connectivity)，Java 数据库连接API，本质是Sun公司定义的一套接口规范，即，通过调用哪些确定的方法即可实现对数据库的操作。JDBC产生的原因很简单：

* 不同的数据库，原理之间有差异；
* 不同的数据库，操作命令也有差异；
* 如果针对不同的数据库，编写的Java代码也不同，这样Java代码可移植性很差；
* Java语言设计者，希望通过相同的Java代码操作不同的数据库，增强程序通用性；
* Java语言设计者，设定了一套标准的数据库操作API，JDBC API；
* 各个数据库厂商，根据自身特点，提供JDBC的具体实现；
	* MySQL，官网提供了[JDBC Driver for MySQL][JDBC Driver for MySQL]
	* SQL Server，官网提供了[JDBC Driver for SQL Server][JDBC Driver for SQL Server]

##JDBC实现原理

JDBC API支持两层和三层处理模型进行数据库访问，但在一般的JDBC体系结构由两层组成：

* JDBC API: 提供了应用程序对JDBC的管理连接。
* JDBC Driver API: 支持JDBC管理到驱动器连接。

JDBC API的使用驱动程序管理器和数据库特定的驱动程序提供透明的连接到异构数据库。

JDBC驱动程序管理器可确保正确的驱动程序来访问每个数据源。该驱动程序管理器能够支持连接到多个异构数据库的多个并发的驱动程序

![](/images/java-jdbc-mysql/jdbc-intro.jpg)
	

##Java操作MySQL数据库的基本过程

Java操作数据库的基本过程：

* 连接到数据库
* 创建SQL语句
* 执行SQL语句
* 查看SQL执行结果
* 关闭连接



pom.xml中添加如下依赖：

	<dependency>
		<groupId>mysql</groupId>
		<artifactId>mysql-connector-java</artifactId>
		<version>5.1.34</version>
	</dependency>


























##参考来源



* [JDBC Driver for MySQL][JDBC Driver for MySQL]
* [JDBC Driver for SQL Server][JDBC Driver for SQL Server]
* [JDBC4简介，JDBC是什么？][JDBC4简介，JDBC是什么？]
* [什么是JDBC][什么是JDBC]
* [jdbc编程基础（一）——jdbc是什么][jdbc编程基础（一）——jdbc是什么]
* [JDBC常见面试题集锦(一)][JDBC常见面试题集锦(一)]





[NingG]:    http://ningg.github.com  "NingG"
[JDBC Driver for MySQL]:			http://www.mysql.com/products/connector/
[JDBC Driver for SQL Server]:		https://msdn.microsoft.com/zh-cn/data/aa937724.aspx


[JDBC4简介，JDBC是什么？]:			http://www.yiibai.com/jdbc/jdbc-introduction.html
[什么是JDBC]:						http://yde986.iteye.com/blog/900373
[jdbc编程基础（一）——jdbc是什么]:	http://sharryjava.iteye.com/blog/325872
[JDBC常见面试题集锦(一)]:			http://it.deepinmind.com/jdbc/2014/03/18/JDBC%E5%B8%B8%E8%A7%81%E9%9D%A2%E8%AF%95%E9%A2%98%E9%9B%86%E9%94%A6%28%E4%B8%80%29.html





