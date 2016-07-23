---
layout: post
title: AIX下安装bash
description: AIX系统下默认shell是ksh，而Linux下是bash，习惯了bash，那就在AIX下继续使用bash吧
categories: aix
---

## AIX系统简介

AIX（Advanced Interactive eXecutive）是IBM基于AT&T Unix System V开发的一套类UNIX操作系统，运行在IBM专有的Power系列芯片设计的小型机硬件系统之上。它符合Open group的UNIX 98行业标准（The Open Group UNIX 98 Base Brand），通过全面集成对32-位和64-位应用的并行运行支持，为这些应用提供了全面的可扩展性。

关于AIX的入门知识和基本操作，参考：

* [快速透视AIX系统][快速透视AIX系统]
* [AIX常用命令汇总][AIX常用命令汇总]

## 安装bash

在Linux下，用户默认使用bash，包含了一些小功能：自动补全、上下按键、backspace删除按键等，这些简单操作在ksh下全部无法使用，简直是中煎熬，shell不就是内核之外的一层“外壳”么，直接换掉就行了。

### 检测是否已安装bash

	#rpm -qa | grep bash
	
如果没有内容返回，则表示未安装bash。

### 下载bash for AIX

通过如下命令查看当前系统信息：

	# oslevel	//查看操作系统版本
	6.1.0.0
	# bootinfo -y	//查看AIX机器硬件是32位还是64位
	64
	# bootinfo -K	//查看AIX系统内核是32位还是64位
	64

到官网[AIX toolbox][AIX toolbox]，下载bash-4.2-3.aix6.1.ppc.rpm（看起来，rpm包不区分32、64位）；

### 安装bash

安装bash，并查看是否完成安装，具体命令如下：

	# rpm -ivh bash-4.2-3.aix6.1.ppc.rpm
	...
	# rpm -qa | grep bash	// 查看是否完成bash的安装
	bash-4.2-3
	
### 更换shell

将某些用户user的默认shell由/usr/bin/ksh改为/usr/bin/bash

	# whereis bash		// 查看shell的安装位置
	bash: /usr/bin/bash
	
	# vi /etc/passwd	// 以user用户为例，更换shell
	...
	user:!:204:1::/home/user:/usr/bin/bash
	...
	
以用户user身份，打开一个新的终端，这样就是Linux下熟悉的bash风格了。

### 补充：更换提示符风格

	# vi ~/.profile
	...
	export PS1='[/u@/h /w]/$'		// 最后一行添加此内容
	
这样AIX下就呈现完整的bash环境了。





## 参考来源

* [AIX下安装bash][AIX下安装bash]
* [快速透视AIX系统][快速透视AIX系统]
* [AIX常用命令汇总][AIX常用命令汇总]





[NingG]:    		http://ningg.github.com  "NingG"
[AIX下安装bash]:	http://blog.csdn.net/zztp01/article/details/6213451
[AIX toolbox]:		http://www-03.ibm.com/systems/power/software/aix/linux/toolbox/alpha.html
[快速透视AIX系统]:	http://www.ibm.com/developerworks/cn/aix/library/1111_liuge_getstartaix/
[AIX常用命令汇总]:	http://www.ibm.com/developerworks/cn/aix/library/au-dutta_cmds.html
