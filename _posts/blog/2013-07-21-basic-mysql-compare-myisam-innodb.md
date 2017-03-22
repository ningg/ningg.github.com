---
layout: post
title: MySQL 基础：数据库MyISAM和InnoDB存储引擎的比较
description: 两个存储引擎MyISAM、InnoDB的适用场景
published: true
category: mysql
---




关键点：

* InnoDB：
	* 支持事务、支持外键、行锁；
	* 不支持全文检索（不支持fulltext类型的索引）
	* 对应磁盘上文件，`数据文件`与`索引文件`相融合，2 个文件：
		* `frm文件`存放`表结构`
		* `ibd文件`是：数据文件与索引文件
	* 因为是`行锁`，当有大量insert、update时，采用InnoDB存储引擎；
* MyISAM：
	* 不支持事务、不支持外键、表级锁；
	* 支持全文搜索；
	* 对应磁盘上文件：一张MyISAM表存放在 3 个文件：
		* `frm文件`中存放`表结构
		* `MYD`（MYData）是数据文件
		* `MYI`（MYIndex）是索引文件
	* 查询速度快
	





## 参考来源

* [MySQL数据库MyISAM和InnoDB存储引擎的比较][MySQL数据库MyISAM和InnoDB存储引擎的比较]
* [MySQL存储引擎－－MyISAM与InnoDB区别][MySQL存储引擎－－MyISAM与InnoDB区别]








[NingG]:    http://ningg.github.com  "NingG"
[MySQL数据库MyISAM和InnoDB存储引擎的比较]:		http://www.cnblogs.com/panfeng412/archive/2011/08/16/2140364.html
[MySQL存储引擎－－MyISAM与InnoDB区别]:			http://blog.csdn.net/xifeijian/article/details/20316775







