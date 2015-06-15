---
layout: post
title: MySQL的版本和组件
description: 简要说明MySQL的基本常见版本、以及其内部包含的组件
published: true
category: MySQL
---



##MySQL版本

从[MySQL官网-下载地址][MySQL官网--下载地址]可知，当前MySQL有如下几个版本：


###MySQL Enterprise Edition（commercial）

> MySQL，企业版，商业版本，需付费

MySQL Enterprise Edition includes the most comprehensive set of advanced features and management tools for MySQL.

* MySQL Database
* MySQL Storage Engines (InnoDB, MyISAM, etc.)
* MySQL Connectors (JDBC, ODBC, .Net, etc.)
* MySQL Replication
* MySQL Fabric
* MySQL Partitioning
* MySQL Utilities
* MySQL Workbench
* MySQL Enterprise Backup
* MySQL Enterprise Monitor
* MySQL Enterprise HA
* MySQL Enterprise Scalability
* MySQL Enterprise Security
* MySQL Enterprise Audit



###MySQL Cluster CGE（commercial）

> MySQL集群，商业版本，需付费

MySQL Cluster is a real-time open source transactional database designed for fast, always-on access to data under high throughput conditions.

* MySQL Cluster
* MySQL Cluster Manager
* Plus, everything in MySQL Enterprise Edition


###MySQL Community Edition（GPL）

> MySQL社区版本，遵循GPL，开源。

具体，MySQL Community Edition（GPL）包含多个MySQL相关的软件：

[MySQL官网-下载地址][MySQL官网--下载地址] 都是MySQL数据库相关的，数据库备份、监控、管理的软件/工具，以及MySQL集群（GPL）安装软件。

具体，包含下面一系列的组件：

* MySQL Community Server (GPL)
* MySQL Cluster(GPL)
* Faric(GPL)
* Utilities(GPL)
* Workbench(GPL)
* Proxy(GPL)
* Connectors



####MySQL Community Server (GPL)

> MySQL Server社区版，遵循GPL，开源，免费

MySQL Community Server is the world's most popular open source database. 

####MySQL Cluster (GPL)

MySQL Cluster，遵循GPL，开源，免费

MySQL Cluster is a real-time, open source transactional database.

####MySQL Fabric (GPL)

MySQL Fabric provides a framework for managing High Availability and Sharding.

####MySQL Utilities (GPL)

MySQL Utilities provides a collection of command-line utilities for maintaining and administering MySQL servers.

####MySQL Workbench (GPL)

MySQL Workbench is a next-generation visual database design application that can be used to efficiently design, manage and document database schemata. It is available as both, open source and commercial editions. 

####MySQL Proxy (GPL)

MySQL Proxy is a simple program that sits between your client and MySQL server(s) that can monitor, analyze or transform their communication. Its flexibility allows for a wide variety of uses, including load balancing; failover; query analysis; query filtering and modification; and many more.


####MySQL Connectors

MySQL offers standard database driver connectivity for using MySQL with applications and tools that are compatible with industry standards ODBC and JDBC. 



##MySQL组件

下载[MySQL Community Server (GPL)][MySQL官网--下载]，本文下载的是`5.6.20`版本：

> MySQL-5.6.20-1.el6.x86_64.rpm-bundle.tar 

解压后，得到多个rpm包：

* MySQL-client-5.6.20-1.el6.x86_64.rpm
* MySQL-devel-5.6.20-1.el6.x86_64.rpm 
* MySQL-embedded-5.6.20-1.el6.x86_64.rpm
* MySQL-server-5.6.20-1.el6.x86_64.rpm
* MySQL-shared-5.6.20-1.el6.x86_64.rpm
* MySQL-shared-compat-5.6.20-1.el6.x86_64.rpm
* MySQL-test-5.6.20-1.el6.x86_64.rpm

####MySQL-server-VERSION.linux_glibc2.5.i386.rpm

The MySQL server. You need this unless you only want to connect to a MySQL server running on another machine.

####MySQL-client-VERSION.linux_glibc2.5.i386.rpm

The standard MySQL client programs. You probably always want to install this package.

####MySQL-devel-VERSION.linux_glibc2.5.i386.rpm

The libraries and include files that are needed if to compile other MySQL clients, such as the Perl modules. Install this RPM if you intend to compile C API applications.

####MySQL-shared-VERSION.linux_glibc2.5.i386.rpm

This package contains the shared libraries (libmysqlclient.so*) that certain languages and applications need to dynamically load and use MySQL. It contains single-threaded and thread-safe libraries. Install this RPM if you intend to compile or run C API applications that depend on the shared client library.

####MySQL-shared-compat-VERSION.linux_glibc2.5.i386.rpm

This package includes the shared libraries for older releases, but not the libraries for the current release. It contains single-threaded and thread-safe libraries. Install this package if you have applications installed that are dynamically linked against older versions of MySQL but you want to upgrade to the current version without breaking the library dependencies.

As of MySQL 5.6.5, the MySQL-shared-compat RPM package enables users of Red Hat-provided mysql-*-5.1RPM packages to migrate to Oracle-provided MySQL-*-5.5 packages. MySQL-shared-compat replaces the Red Hat mysql-libs package by replacing libmysqlclient.so files of the latter package, thus satisfying dependencies of other packages on mysql-libs. This change affects only users of Red Hat (or Red Hat-compatible) RPM packages. Nothing is different for users of Oracle RPM packages.

####MySQL-embedded-VERSION.linux_glibc2.5.i386.rpm

The embedded MySQL server library.

####MySQL-test-VERSION.linux_glibc2.5.i386.rpm

This package includes the MySQL test suite.




##参考来源

* [MySQL官网--下载地址][MySQL官网--下载地址]
* [MySQL的三种安装方式][MySQL的三种安装方式]
* [MySQL官网--下载][MySQL官网--下载]







[MySQL官网--下载地址]:				http://www.mysql.com/downloads/
[MySQL的三种安装方式]:				http://pangge.blog.51cto.com/6013757/1059896
[MySQL官网--下载]:					http://dev.mysql.com/downloads/mysql/




























[NingG]:    http://ningg.github.com  "NingG"











