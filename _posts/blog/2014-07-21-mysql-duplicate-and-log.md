---
layout: post
title: MySQL中主从复制以及日志简析
description: 主从复制的基本过程，MySQL中常见日志的作用
published: true
category: mysql
---




## 主从复制基本过程



![](/images/mysql-duplicate-and-log/duplicate.png)



MySQL的复制，是异步的，对应3个进程，即：

* Master上 1 个IO进程，负责向Slave传输binary log（binlog）
* Slave上 2 个进程：IO进程和执行SQL的进程，其中：
	* IO进程，将获取的日志信息，追加到relay log上；
	* 执行SQL的进程，检测到relay log中内容有更新，则在Slave上执行sql；


## MySQL中日志简析



参考ppt：[MySQL日志简析-5.1][MySQL日志简析-5.1]，特别说明，针对当前MySQL 5.5版本，有些细节需要调整，因此，具体操作的时候，需要去读官方文档。











## 参考来源

* [mysql binlog 复制][mysql binlog 复制]



















[NingG]:    http://ningg.github.com  "NingG"


[mysql binlog 复制]:			http://blog.csdn.net/arkblue/article/details/39484071
[MySQL日志简析-5.1]:			http://vdisk.weibo.com/s/Cbfky8Pv7vR9S







