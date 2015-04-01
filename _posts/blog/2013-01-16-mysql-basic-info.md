---
layout: post
title: MySQL--基本操作
description: 开源的数据库MySQL的常用操作、内部原理
category: MySQL
---
##简介

难得最近两天重新接触Mysql，正好整理一下基本的知识。下面是自己本篇文章的大纲：

> 1. 增删改查；
> 2. `group by`、`order by`、`distinct`；
> 3. 常用函数：`count()`、`min()`、`max()`、`substing_index()`等；
> 4. 查看mysql日志，主要是针对`warings`\`errors`的查询和处理；
> 5. mysql存储过程；
> 6. 数据备份；
> 7. 常用工具的介绍及特点；
> 8. （万佛归宗）MySQL的整体框架，备份时内部的线程机制，语句执行效率。

首先对于上面的8个要点进行一个整体的说明：`1-3`是基本的操作；`4-7`属于较深入的学习（有点难度），但仍然是操作过程；`8`是整个MySQL的基础，最核心的东西，从这里就可以窥见Mysql的起源了。操作部分关键是要记忆+操作；底层的理论需要一些理解（brain power）。

**说明**：整篇的表述，都是以自己浅显的理解为基础的；有描述不当的地方，还请留言指正。

##具体

###1.增删改查

###2.group by、order by、distinct

###3.常用函数：count、min、max、substring_index

前3项，参照下面链接，把命令反复敲2遍，重复的也要敲。

1. [MySQL常用命令汇总1](http://www.cnblogs.com/hateislove214/archive/2010/11/05/1869889.html)
2. [MySQL常用命令汇总2](http://zhaofeng2007625.blog.163.com/blog/static/311815972010111512437937/)
3. [MySQL常用命令汇总3](http://blog.sina.com.cn/s/blog_9707fac301017kb3.html)

**NOTE**:有疑问的地方多GOOGLE，实在无法解决的，就跳过。
简要说明几点（查找《MySQL必知必会》中对应部分）：

`group by `分组，本质将表格分为逻辑组，基于逻辑组，同时进行相同处理（统计、汇总等）；可以嵌套分组，（效率很低的嵌套分组，过滤分组）常在group by之后，添加一个order by，按照某种规律进行排序。

`order by` 排序，按多个列排序：order by column_1,column_2；DESC:降序；ASC：默认值，升序。（多列排序、指定排序方向）

`distinct` 过滤重复内容；可以使用distinct column_1,column_2；（多列去重）

`select`语句最后添加“\G”，会以列的格式来显示行。

`alter`：修改表结构等。

###4.日志

**读日志是熟悉使用一个工具的最基本要求**。如果执行了一个sql脚本之后，提示`n warnings`，可以使用`show warnings`命令来查看详细信息。

假设场景：

> * 现在mysql运行，希望知道哪些sql命令正在运行；（正在执行的命令）
> * 现在mysql运行，希望知道曾经执行过的sql命令；（历史命令）
> * 运行出现问题，mysql无法正常使用，现在希望查看mysql的运行日志；

查看mysql的运行状态，命令：status；结果如下：

	mysql> status;
	--------------
	mysql  Ver 14.14 Distrib 5.1.60, for redhat-linux-gnu (x86_64) using readline 5.1
	 
	Connection id:          21449
	Current database:       chinacache
	Current user:           root@localhost
	SSL:                    Not in use
	Current pager:          stdout
	Using outfile:          ''
	Using delimiter:        ;
	Server version:         5.1.60 Source distribution
	Protocol version:       10
	Connection:             Localhost via UNIX socket
	Server characterset:    utf8
	Db     characterset:    utf8
	Client characterset:    utf8
	Conn.  characterset:    utf8
	UNIX socket:            /home/data/mysqlData/mysql5.5.sock
	Uptime:                 33 days 9 min 48 sec
	 
	Threads: 9  Questions: 15701727  Slow queries: 47  Opens: 1039  Flush tables: 1  Open tables: 541  Queries per second avg: 5.505
	--------------

注意看，上面最后一行`slow queries`这一项的值，如果多次查看的值都大于0，则说明有些查询的sql命令执行时间过长。

查看当前正在运行的SQL，使用命令`show processlist；`，从中找出运行较慢的语句，再使用`explain`命令查看这些语句的执行计划。如下：

	mysql> show processlist;
	+-------+------+----------------------+------------+---------+------+----------------+-
	| Id    | User | Host                 | db         | Command | Time | State          |
	+-------+------+----------------------+------------+---------+------+----------------+-
	| 21185 | root | localhost            | chinacache | Sleep   | 3744 |                | 
	| 21449 | root | localhost            | chinacache | Sleep   |  501 |                | 
	| 21626 | root | localhost            | chinacache | Query   |    0 | NULL           | 
	| 21630 | root | localhost            | chinacache | Query   |    0 | Sorting result | 
	| 21695 | root | localhost            | chinacache | Sleep   |  685 |                | 
	| 21732 | zuo  | 10.108.210.111:50198 | chinacache | Sleep   |   19 |                | 
	| 21733 | zuo  | 10.108.210.111:50201 | chinacache | Sleep   |  258 |                | 
	| 21742 | zuo  | 10.108.210.111:50229 | chinacache | Sleep   |   19 |                | 
	| 21744 | root | localhost            | wordpress  | Sleep   |    6 |                | 
	+-------+------+----------------------+------------+---------+------+----------------+-
	9 rows in set (0.00 sec)

 对于MySQL的历史命令：需要在`my.cnf`文件中添加:

	[mysqld]
	log=command.log

重新启动`mysqld`，之后所有的命令都可以到上述文件中查询得到。

查看当前启用的日志[7]，以及日志的存储路径：

	show variables like ‘log_%’;

###5.mysql存储过程（procedure）

什么是`mysql的存储过程`[1][2][3]？简单的说，为方便使用而保存的一条或者多条MySQL语句的集合，就是一个sql脚本文件，有输入\出参数，根据参数来动态执行其内部SQL语句（存储过程，实际是一种函数）。

	DELIMITER //
	-- Name:ordertotal
	-- Parameters:onumber = order number
	--            taxable = 0 if not taxable, 1 if taxable
	--            ototal = order total variable
	CREATE PROCEDURE ordertotal(
			  IN onumber INT,
			  IN taxable BOOLEAN,
			  OUT ototal DECIMAL(8,2)
	)COMMENT 'Obtain order total, optionally adding tax'
	BEGIN
	 
	-- Declare variable for total
	DECLARE total DECIMAL(8,2);
	-- Declare tax percentage
	DECLARE taxrate INT DEFAULT 6;
	 
	-- Get the order total
	SELECT SUM(item_price*quantity)
			FROM ordertimes WHERE order_num = onumber INTO total;
	 
	-- Is this taxable?
	IF taxable THEN 
			-- YES, so add taxrate to the total
			SELECT total+(total/100*taxrate) INTO total;
	END IF;
	 
	-- And finally, save to our variable
	SELECT total INTO ototal;
	 
	END //
	 
	DELIMITER ;

看上面简单的`存储过程`[1]，以此为例进行说明：首先，从意识上将上面的存储过程，看做一个函数。

具体细节：

> * `DELIMITER //`表示暂时更改分隔符（mysql内判断为开始执行的分隔符）；
> * `–- `（最后有一个空格）表示单行注释；
> * 上面的`procedure`包含了2个输入参数（IN）和一个返回参数（OUT）；
> * 过程body中，使用`declare`定义了2个局部变量，`declare`要求使用变量名和类型；`select… into…` 语句将查询结果保存到`into`后面的变量中；
> * `if…then…end` if语句表示了是否一个条件判断执行过程。

**补充**：`procedure`的参数后面有`COMMENT`类似于备注，当使用`SHOW PROCEDURE STATUS;`时可以看到此字段。

**NOTE**:注意存储过程中的**输入参数** 不能作为表名（`table name`）,如果必须将表名当做输入参数，可以使用预处理机制：`PREPARE`、`EXECUTE`、`DEALLOCATE PREPARE`。具体借鉴另一篇blog[MYsql——数据去重](/mysql-data-cleaning/)。

**NOTE**:上面使用`DECLARE`进行变量的声明，在很多情况下会看到`set @var`类型的变量，关于变量详细信息参考[5]（猜测只是变量的作用范围不同，其他的本质都是变量，没有什么不同？）。


常用的操作：

* 执行存储过程：`CALL procedure_name(params);`
* 删除存储过程：`DROP PROCEDURE procedure_name;`（`DROP PROCEDURE IF EXISTS procedure_name;`）
* 显示所有正在运行的存储过程：`SHOW PROCEDURE STATUS`;其中包含了`procedure`的名称、创建时间、修改时间等;
* 显示存储过程的创建语句：`SHOW CREATE PROCEDURE procedure_name`;

###6.数据备份（操作）

(doing…)

###7.常用工具

(doing…)

###8.(万佛归宗)Mysql整体框架，内部线程机制，语句执行效率

(doing…)
 
 
##常见问题


###查看Table的建表语句

执行如下SQL语句即可：

	> show create table student;
	>
	| student | CREATE TABLE `student` (
	  `studentzj` varchar(11) NOT NULL COMMENT '主键',
	  `studentid` varchar(5) NOT NULL,
	  `name` varchar(20) NOT NULL,
	  `gender` char(1) DEFAULT NULL,
	  `birthday` date DEFAULT NULL,
	  PRIMARY KEY (`studentzj`)
	) ENGINE=InnoDB DEFAULT CHARSET=utf8   |

 
##参考来源

1. 《MySQL必知必会》Page171
2. http://blog.sina.com.cn/s/blog_71f4cdbe0100yut4.html
3. http://www.ccvita.com/100.html
4. http://www.ccvita.com/category/mysql/
5. http://blog.csdn.net/lxgwm2008/article/details/7738306
6. http://joewalker.iteye.com/blog/277626
7. http://blog.sina.com.cn/s/blog_406127500100pvar.html



[NingG]:    http://ningg.github.com  "NingG"
