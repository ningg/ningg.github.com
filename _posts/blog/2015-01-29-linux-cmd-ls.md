---
layout: post
title: Linux下查看文件、统计文件行数
description: 简要梳理一下，几种场景下，ls命令和wc命令的用法
category: linux
---

## 查看文件基本信息：ls命令


### 按文件修改时间排序

有时要查询最近改动的文件，通过`ls -tr [dir]`命令即可实现查询，具体：

	# -t: sort by modification time
	# -r: reverse order while sorting
	ls -tr .

### 设置查询结果配色

有时，希望区分ls查询的结果，可执行文件、文件、文件夹，为方便阅读，现实不同的颜色，具体命令：

	# --color= 
	ls --color=auto .
	
	# 可选参数：always，never，auto；
	# 建议使用：--color=auto
	[storm@cib02167 tmp]$ ls -al --color=default
	ls: invalid argument `default' for `--color'
	Valid arguments are:
	  - `always', `yes', `force'
	  - `never', `no', `none'
	  - `auto', `tty', `if-tty'
	Try `ls --help' for more information.


### 通配符查询文件

通过利用Linux下命令的通配符（Wildcards），可以只查看满足一定规则的文件：

	# 查询以'.'开头的所有文件夹，
	# 如果为文件夹，通过'-d'配置只显示文件夹整体情况，不显示文件夹的内容
	ls -dl .*

**备注**：通配符（Wildcards）与正则表达式（Regular Expression）不是一个概念，说两点：

* 之前专门写过一篇[正则表达式的文章]；
* 准备单独再写一篇[通配符的文章];
	
	
### 查看文件大小

	# -h:  with -l, print sizes in human readable format (e.g., 1K 234M 2G)
	ls -lh [file]


### 查看文件的子目录

	# -R: --recursive, list subdirectories recursively
	ls -lR [file] | less


### 只显示文件或目录

选项`-F`：--classify, append indicator (one of `*/=>@|`) to entries；（注：不要与`-l`配合使用）；其中：

* `/`，目录；
* `@`，链接文件；
* `*`，可执行文件；

具体操作如下：

	# 只显示目录
	ls -F | grep "/$"
	ls -al | grep "^d"
	
	# 只显示文件（不包含link文件）
	ls -al | grep "^-"

	# 统计文件个数
	ls -al | grep "^-" | wc -l



## 统计文件的行数：find、xargs和wc命令

针对`find`、`xargs`和`wc`命令的简介：

* `find`：
* `xargs`：
* `wc`：	

（todo：Find命令详解、xargs命令详解、wc命令详解，重点关注其manual手册中内容，借鉴别人的理解）


### 统计demo目录下，js文件数量：

	find demo/ -name "*.js" |wc -l

### 统计demo目录下所有js文件代码行数：

	find demo/ -name "*.js" |xargs cat|wc -l 
	# 或 
	wc -l `find ./ -name "*.js"` | tail -n1

### 统计demo目录下所有js文件代码行数，过滤了空行：

	find /demo -name "*.js" |xargs cat|grep -v ^$|wc -l


	
	
	
	
## 参考来源

* [Linux统计文件行数][Linux统计文件行数]
	
	
	

	
[NingG]:    						http://ningg.github.com  "NingG"
[Linux统计文件行数]:				http://www.cnblogs.com/fullhouse/archive/2011/07/17/2108786.html








