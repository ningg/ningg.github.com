---
layout: post
title: MySQL--字段内信息抽取
description: MySQL表格内，抽取字段信息的一个基本例子
category: mysql
---
## 问题背景

现在有一张表，结构如下：

|字段|类型|
|:--|:--|
|IP|	varchar(30)|
|timeStart|	double(13,3)|
|durationTime|	double(13,3)|
|httpURL|	varchar(1000)|
|terminalType|	varchar(1000)|

现在要从字段`httpURL`中提取一些字符串，并作为新的属性，添加到表中。

一个典型的httpURL格式如下：

> http://appldnld.apple.com/iOS6/041cfbLY/com_Update/6b2a5.zip

现在要提取`iOS6`和`com_Update`字段，并且组合为：`iOS6_com_Update`，将此作为新字段添加到表中。

## 解决办法

初步思考，解决步骤如下：

> 1. 取出一条记录；
> 2. 将字段“httpURL”中信息提取出来，组合；
> 3. 将获得的最终组合信息，添加到最新字段中。

__关键__，使用`substring_index`函数。

直接贴上脚本吧（利用MySQL存储过程）：

	/*
	 *
	 *usage：
	 *      1) login the 'mysql' ;
	 *      2) source ~/enurl.sql;
	 *      3) CALL enurl('oldTable','newTable');
	 *
	 *function: get the information from column "httpURL", then store it in an new-bulit column "info_1"; we create a new table 'newTable' to store the results;
	 *
	 *parameters:
	 *      oldTable: the original table, that we need to get some information from the column "httpURL";
	 *      newTable: the new build table, where we store the results.
	 *
	 *author：Ning Guo
	 *
	 *time: 1/16/2013
	 *
	 *程序运行效果：
	 *  260万数据，执行时间为：1min 2s
	 *
	 *
	 */
	DROP PROCEDURE IF EXISTS enurl;
	DELIMITER //
	CREATE PROCEDURE enurl(
			$oldTable VARCHAR(60),
			$newTable VARCHAR(60)
	)
	BEGIN
			SET @SQL= concat('DROP TABLE IF EXISTS ',$newTable);
			PREPARE stmt1 FROM @SQL;
			EXECUTE stmt1;
			DEALLOCATE PREPARE stmt1;
	 
			SET @SQL= concat('CREATE TABLE ',$newTable,' SELECT * FROM ',$oldTable);
			PREPARE stmt1 FROM @SQL;
			EXECUTE stmt1;
			DEALLOCATE PREPARE stmt1;
	 
			SET @SQL= concat('ALTER TABLE ',$newTable,' ADD info_1 varchar(60)');
			PREPARE stmt1 FROM @SQL;
			EXECUTE stmt1;
			DEALLOCATE PREPARE stmt1;
	 
			SET @SQL= concat('UPDATE ',$newTable,' SET info_1=(select concat(substring_index(substring_index(httpURL,\'/\',4),\'/\',-1),concat(\'_\',substring_index(substring_index(
	httpURL,\'/\',6),\'/\',-1))))');
			PREPARE stmt1 FROM @SQL;
			EXECUTE stmt1;
			DEALLOCATE PREPARE stmt1;
	 
	END //
	DELIMITER ;

## 参考来源

1. http://www.chinesejy.com/jishu/508/518/20101017465148.html
2. http://www.jb51.net/article/27458.htm

[NingG]:    http://ningg.github.com  "NingG"
