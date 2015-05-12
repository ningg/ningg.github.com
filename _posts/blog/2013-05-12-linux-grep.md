---
layout: post
title: Linux下grep命令
description: 查询内容
published: true
category: linux
---

几点：

* grep -rni
* grep -A 10

##grep常用选项

> 用法：grep [-cinv] '搜寻字符串' filename

说明：

-c ：计算找到 '搜寻字符串' 的次数
-i ：忽略大小写的不同，所以大小写视为相同
-n ：顺便输出行号
-v ：反向选择，亦即显示出没有 '搜寻字符串' 内容的那一行
-A 10：匹配到后，输出当前行向后10行
--color=auto：查询结果，设置颜色


##场景

###搜索文件夹

具体：查询logs目录下所有含有ERROR的行，并且含有2015-02-03的行，命令如下：

	grep -rni "ERROR" logs | grep "2015-02-03" > error.log

###正则表达式

取前面非字符的字符

> grep -n '[^a-zA-Z]oo' pp 

行首和行尾的特殊处理 `$^`，若是希望取得第一行是 the 开头的字符行

> grep -n '^the' pp 

任意字符和重复字符
	* `.`：绝对的任意字符
	* `*`：0个或是多个相同字符
	
要查看gf中间是两个字符的数据

> grep -n 'g..f' pp


































[NingG]:    http://ningg.github.com  "NingG"











