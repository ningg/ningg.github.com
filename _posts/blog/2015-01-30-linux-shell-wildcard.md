---
layout: post
title: Linux下通配符（Wildcards）的使用
description: 在Linux下要进行查询时，要用到通配符，整理一下
category: linux
---

##帮助文档

执行命令`man 7 glob`，即可查看Linux shell下通配符的帮助文档，具体：

	# 查看glob命令的第7章节，其中有对wildcards的说明
	man 7 glob






##wildcards梳理

* `*`：匹配，任意字符的0个或1个；
* `?`：匹配，任意字符的1个；
* `[]`：匹配，括号中字符的任意1个；
* `[!]`：匹配，括号中字符之外的任意字符的1个；
* `{,}`：匹配，字符串（子模式，可以包含wildcards）中的任意1个；`,`分割不同的字符串，并且其前后不能出现空格；
* '\'（backslash）：将`*`，`?`，`[`，`]`等特殊字符转义为普通字符；注：此时，建议利用`""`（双引号）将包含wildcards的字符串包含起来；


##通配符与正则表达式

典型区别：

* 通配符（Wildcards）中，`?`、`*`，不需要配合基础字符；
	* `?`：表示针对任意字符，出现一次；
	* `*`：表示针对任意字符，出现0次或多次；
* 正则表达式（Regular Exp.）中，`?`、`*`，需要依附基础字符；
	* `?`：仅当`a?`才有含义，表示出现`a`字符0次或1次；
	* `*`: 仅当`a*`才有含义，表示出现`a`字符0次或0次以上；
	* `?`、`*`，仅表示字符的次数，而不表示字符本身；



##参考来源


* [GNU/Linux Command-Line Tools Summary][GNU/Linux Command-Line Tools Summary]










[NingG]:    http://ningg.github.com  "NingG"

[GNU/Linux Command-Line Tools Summary]:				http://www.tldp.org/LDP/GNU-Linux-Tools-Summary/html/x11655.htm
