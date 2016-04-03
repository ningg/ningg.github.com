---
layout: post
title: SQL语言中DDL、DML、DCL、TCL简介
description: SQL相关术语简介
published: true
category: MySQL
---


SQL（Structured Query Language，结构化查询语言），是操作RDBMS（relational database management system，关系型数据库管理系统）的专用语言。
SQL的众多命令，例如，create、drop、insert、grant等，可以被分为4类：

* DDL，Data Definition Language，定义数据库结构、表结构；
* DML，Data Manipulation Language，操作具体数据；
* DCL，Data Control Language，数据库控制语言，授权、角色控制；
* TCL，Transaction Control Language，事务控制语言*（有的SQL实现支持，有的不支持）*；

## DDL

定义数据库的三级结构，包括外模式、概念模式、内模式以及相互之间的映像，定义数据的完整性、安全控制等约束。*（有安全控制？）*
DDL，不需要commit。

思考：DDL，不需要commit？commit的作用是什么？

* CREATE – to create objects in the database
* ALTER – alters the structure of the database
* DROP – delete objects from the database
* TRUNCATE – remove all records from a table, including all spaces allocated for the records are removed
* COMMENT – add comments to the data dictionary
* RENAME – rename an object





## DML

对应数据库的增删改查（CRUD）操作。DML分为交互型DML和嵌入型DML两类。依据语言级别，DML又可分为过程性DML和非过程性DML两种。需要commit。

* SELECT – retrieve data from the a database
* INSERT – insert data into a table
* UPDATE – updates existing data within a table
* DELETE – Delete all records from a database table
* MERGE – UPSERT operation (insert or update)
* CALL – call a PL/SQL or Java subprogram
* EXPLAIN PLAN – interpretation of the data access path
* LOCK TABLE – concurrency Control





## DCL

数据库控制语言，授权、角色控制等

* GRANT – allow users access privileges to database
* REVOKE – withdraw users access privileges given by using the GRANT command






## TCL

设置事务控制*（不同SQL的实现方式，支持程度不同）*，通常针对DML语句。

* SAVEPOINT 设置保存点
* ROLLBACK  回滚
* SET TRANSACTION




## 小结


* 数据定义，（SQL DDL）用于定义SQL模式、基本表、视图和索引的创建和撤消操作；
* 数据操作，（SQL DML）数据操纵分成数据查询和数据更新两类。数据更新又分成插入、删除、和修改三种操作；
* 数据控制，包括对基本表和视图的授权，完整性规则的描述，事务控制等内容。
* 嵌入式SQL的使用规定。涉及到SQL语句嵌入在宿主语言程序中使用的规则。



## 为什么将SQL，细分为DDL\DML\DCL\TCL？

将SQL的操作，细分为4类：DDL\DML\DCL\TCL的作用，方便进行分类控制，例如：金融、税务等系统，禁止进行DDL操作。

思考：上述的权限控制，是否能够只针对单个SQL命令，例如INSERT\UPDATE等？即，更细粒度的权限控制。


















## 参考来源

* [SQL四种语言：DDL,DML,DCL,TCL][SQL四种语言：DDL,DML,DCL,TCL]
* [What is DDL, DML and DCL][What is DDL, DML and DCL]
* [Why are SQL statements divided into DDL, DML, DCL and TCL statements][Why are SQL statements divided into DDL, DML, DCL and TCL statements]










[NingG]:    						http://ningg.github.com  "NingG"
[SQL四种语言：DDL,DML,DCL,TCL]:		http://www.cnblogs.com/henryhappier/archive/2010/07/05/1771295.html
[What is DDL, DML and DCL]:			http://www.w3schools.in/mysql/ddl-dml-dcl/
[Why are SQL statements divided into DDL, DML, DCL and TCL statements]:			http://stackoverflow.com/questions/12803047/why-are-sql-statements-divided-into-ddl-dml-dcl-and-tcl-statements







