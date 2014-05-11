---
layout: post
title: MySQL--数据去重
description: 一次利用MySQL，进行数据清洗的规范操作
category: MySQL
---


##问题背景

一张表有几个字段：

|字段|类型|
|:--|:--|
|IP|	varchar(30)|
|timeStart|	double(13,3)|
|durationTime|	double(13,3)|
|httpURL|	varchar(1000)|
|terminalType|	varchar(1000)|

现在要去重，重复的标准：IP相同，httpURL也相同；保留重复数据中timeStart最小的那条记录。估计的**瓶颈**: 数据量很大，近千万条记录，需要考虑方案的可行性和效率。

__猜测__：MySQL数据库中有没有专门负责去重的机制？

##解决方法

经初步分析，可选择的方法有：

> 1. 在同一张表中进行处理；
> 2. 使用另一张表格；
> 3. 使用文本进行处理；

针对上面3种方法，进行简要说明：

###1.在同一张表中进行处理

* __表格预处理__：排序，按照“timeStart”从小到大进行排序；
* __查询__：在排序好的Table中，从上到下进行逐条读取记录，并查询后面的记录中是否有重复；
* __去重__：删除重复记录；


###2.使用另一张表

* __表格预处理__：排序，按照“timeStart”从小到大进行排序；（同上），现在将预处理之后得到的表格记为TableA；
* __新建TableB__：字段与TableA保持一致；
* __向TableB中插入数据__：从TableA中逐条取出记录，判断在TableB中没有重复后，插入TableB中；

###3.使用文本进行处理

* __文本转换__：将表中记录，导出为文本形式；
* __去重__：针对文本进行去重；

###4.具体解决细节&代码

现在，咱们先按某一字段进行排序[1]：

~~~ sql
SELECT * FROM oldTalbe \
ORDER BY IP,timeStart LIMIT 10;
~~~

现在有了预期的排序结果，但是怎样才能以这个结果来更新数据库呢？有一个简单的办法，新建一个额外表，并将查询的结果逐条插入。复制表结构[2]的sql语句如下：

	CREATE TABLE newTable LIKE oldTable;

将查询结果逐条的插入到newTable中[2][3]：

	INSERT INTO newTable \
				   SELECT * FROM oldTable \
				   ORDER BY IP,timeStart;

运行上面的代码时间：`21s`，总数据量：`260万`。（若不使用排序，只进行数据复制，耗时`4.3s`）我们无聊了(这一步仅仅是测试，自己玩的，不感兴趣，可以直接跳过)：尝试将无序的记录先添加入新建的表格中，针对同一个表格使用`insert into`和`select`，即sql语句如下：

	INSERT INTO newTable 
				   SELECT * FROM oldTable; 
	INSERT INTO newTable \
				   SELECT * FROM newTable \
				   ORDER BY IP,timeStart;

测试结果显示，后来执行完之后，数据翻倍变为`520万`，而且时间在`4mins`以上。

刚刚lby大牛路过，我把自己的问题描述了一下；他说自己之前做过，有两种办法，一时间只想到一种：先复制表结构到新表newTable，然后对于newTable添加一个约束Unique(IP,httpURL)，OK；现在可以向newTable中添加数据了，约束条件会帮助我们自动去重。完整的代码如下[4]：

	#复制表结构
	CREATE TABLE newTable LIKE oldTable;
	 
	#修改表字段，因为httpURL太大
	ALTER TABLE newTable MODIFY httpURL VARCHAR(300);
	 
	#为表格添加约束条件（在Mysql5中，如果约束字段过大，则报错，因此要先执行上面的修改表字段）
	ALTER TABLE newTable ADD UNIQUE(IP,timeStart);
	 
	#为新表中添加数据（约束条件自动去重）
	INSERT IGNORE newTable \
				   (SELECT * FROM newTable \
				   ORDER BY IP,timeStart);

__NOTE__:现有MySQL中注释方法：1）单行注释，“#”，“–-空格/tab”；2）多行注释，“/*…*/”

__MySQL中提前终止或者后台运行SQL语句的操作__：`ctrl+c` or `ctrl+d`；

Lby大牛刚才过来，提醒了一下可以考虑SQL中`select distinct IP,httpURL`的相关语句，至少可以使用下面的语句，统计一下去重后最终的记录个数：

	SELECT COUNT(DISTINCT IP,httpURL) \
					  FROM oldTable;

测试结果发现，上面的记录个数要比之前使用`Unique`进行约束方式，多了10条记录。猜测：跟`httpURL`字段被人为减少到`varchar(300)`有关。(后来的几次运行，此问题消失了)。

__遗留问题__：思考将上面的内容以脚本形式书写出来，并且将`newTable`、`oldTable`作为变量输入。思路：1）在SQL语句脚本内，设置变量；2）使用单独的shell脚本，配合SQL语句脚本。

__NOTE__:如何验证去重是否完成？基本思路：

> 1. 从`oldTable`中随便取出一个`IP`对应的多条记录进行处理，获取其中不同`httpURL`的个数，以及每个`httpURL`对应的最小`timeStart`字段；
> 2. 从`newTable`中找出对应的`IP`，查询其对应的`httpURL`，以及对应的时间。（与上面的结果进行对比，如果完全相同，则说明去重正确）

具体验证代码如下：

针对oldTable执行下面代码

	#对应上面的步骤1
	#从oldTable中查询IP,可以知道哪些IP的记录最多
	SELECT IP,COUNT(*) FROM oldTable GROUP BY IP ORDER BY COUNT(*);
	 
	#从上面的结果中，找出记录数较多的IP，查询其对应的httpURL以及最小的时间，要求：按照httpURL进行排序
	SELECT DISTINCT httpURL，MIN（timeStart） FROM oldTable WHERE IP='10.10.10.10' ORDER BY httpURL;

针对newTable执行下面代码

	#对应上面的步骤2
	#从newTable中找出对应IP的httpURL，以及timeStart
	SELECT httpURL，timeStart FROM newTable WHERE IP='10.10.10.10' ORDER BY httpURL;

如果上面针对`oldTable`和`newTable`的查询结果相同，则表示去重完成。（可以随意更换上面的IP值，进行验证）

###5.SQL脚本实现去重

刚刚还说上面的遗留问题，现在已经解决了，用了一下午时间吧。下面对于以SQL脚本实现上述功能，进行一个小结。我们使用MySQL的存储过程，来实现动态输入变量`newTable`、`oldTable`。最终代码如下：

	/*
	 *usage：
	 *      1) login the 'mysql' ;
	 *      2) source ~/deduc.sql;
	 *      3) CALL deduc('oldTable','newTable');
	 *
	 *function: de-duplication, remove the repeat record, and store the result in a new table;
	 *
	 *parameters:
	 *      oldTable: the original table, that we need to remove the repeat record;
	 *      newTable: the new build table, where we store the results.
	 *
	 *author：Ning Guo
	 *
	 *time: 1/15/2013
	 *
	 *程序运行效果：
	 *  260万数据，去重之后为60万，执行时间为：1min23s
	 */
	 
	USE chinacache;
	DROP PROCEDURE IF EXISTS deduc;
	DELIMITER //
	CREATE PROCEDURE deduc(
			$oldTable VARCHAR(100),
			$newTable VARCHAR(100)
	)
	BEGIN
			SET @SQL = concat('DROP TABLE IF EXISTS ',$newTable);
			PREPARE stmt1 FROM @SQL;
			EXECUTE stmt1;
			DEALLOCATE PREPARE stmt1;
	 
			SET @SQL = concat('CREATE TABLE ',$newTable,' LIKE ',$oldTable);
			PREPARE stmt1 FROM @SQL;
			EXECUTE stmt1;
			DEALLOCATE PREPARE stmt1;
	 
			SET @SQL = concat('ALTER TABLE ',$newTable,' MODIFY httpURL VARCHAR\(300\)');
			PREPARE stmt1 FROM @SQL;
			EXECUTE stmt1;
			DEALLOCATE PREPARE stmt1;
	 
			SET @SQL = concat('ALTER TABLE ',$newTable,' ADD CONSTRAINT UNIQUE\(IP\,httpURL\)');
			PREPARE stmt1 FROM @SQL;
			EXECUTE stmt1;
			DEALLOCATE PREPARE stmt1;
	 
			SET @SQL = concat('INSERT IGNORE ',$newTable,' \(SELECT \* FROM ',$oldTable,' ORDER BY IP\,timeStart\)');
			PREPARE stmt1 FROM @SQL;
			EXECUTE stmt1;
			DEALLOCATE PREPARE stmt1;
	 
	END //
	DELIMITER ;


由于MySQL不支持表名作为存储过程的变量，因此应该使用预定义语句：`PREPARE`、`EXECUTE`、`DEALLOCATE PREPARE`来进行实现[6]。

###6.补充知识——存储过程[7][8]

什么是存储过程？可以将其看做一个批处理文件，包含多条MySQL语句，其会根据输入的参数（可以没有输入参数），有选择地执行对应的程序；而且可以有返回参数。

`DELIMITER //`的使用：为了区分存储过程内`;`与存储过程结束的标志，使用`DELIMITER`来临时更改`语句结束分隔符`。

调用存储过程：`CALL deduc()`；

删除存储过程：`DROP PROCEDURE deduc`；

存储过程传入的参数不能作为表名：因此借鉴使用预定义语句`PREPARE`、`EXECUTE`、`DEALLOCATE PREPARE`。[8]

几个常用的查询命令：

|命令|说明|
|:--|:--|
|show procedure status|查询所有procedure的名称、创建时间|
|show create procedure “procedure_name”|查询某一procedure的创建语句|
 
 
##参考来源

1. 《MySQL必知必会》Page33；
2. http://www.2cto.com/database/201202/120259.html
3. 《MySQL必知必会》Page136；
4.  http://blog.sina.com.cn/s/blog_6fb90ed30100o09p.html
5.  http://www.bhcode.net/article/20090220/4175.htm
6.  http://bbs.csdn.net/topics/330197598
7. 《MySQL必知必会》Page163；
8.  http://blog.csdn.net/freecodetor/article/details/5818283


[NingG]:    http://ningg.github.com  "NingG"
