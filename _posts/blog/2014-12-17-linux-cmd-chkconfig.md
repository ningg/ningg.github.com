---
layout: post
title: Linux命令：chkconfig
description: 将应用添加到系统服务中，并设置服务的启动级别
category: linux
---

（未完成整理）

关注几个小问题：

* 如何添加系统服务？
* 如何设置系统服务，开机自启动？
* 如何删除系统服务？
* 如何查看当前系统服务，以及对应服务的开机启动状态？
* 如果系统服务已经存在，如何重新添加系统服务？即，要覆盖掉之前系统服务的配置？

##chkconfig

通过man查询chkconfig的基本用法：

	chkconfig [--list] [--type type][name]
	chkconfig --add name
	chkconfig --del name
	chkconfig --override name
	chkconfig [--level levels] [--type type] name <on|off|reset|resetpriorities>
	chkconfig [--level levels] [--type type] name

列举几个例子：

	# 添加服务jmxtrans
	chkconfig --add jmxtrans
	
	# 设置服务jmxtrans启动级别
	chkconfig --level 2345 jmxtrans on
	
##系统服务runlevel

（doing...）

系统的runlevel到底什么用途？什么含义？

	# 查看当前系统的运行级别
	runlevel
	
	# 查看当前系统运行级别
	who -r
	
下面草草列一点别人的总结：

首先了解linux的运行级别有哪些？6个运行级别：
 
    # 0 - 停机（千万不要把initdefault设置为0 ）
    # 1 - 单用户模式
    # 2 - 多用户，但是没有NFS
    # 3 - 完全多用户模式
    # 4 - 没有用到
    # 5 - X11
    # 6 - 重新启动（千万不要把initdefault设置为6 ）

对各个运行级的详细解释：

* `0`：为停机，机器关闭。
* `1`：为单用户模式，就像Win9x下的安全模式类似。
* `2`：为多用户模式，但是没有NFS支持。
* `3`：为完整的多用户模式，是标准的运行级。
* `4`：一般不用，在一些特殊情况下可以用它来做一些事情。例如在笔记本电脑的电池用尽时，可以切换到这个模式来做一些设置。
* `5`：就是X11，进到X Window系统了。
* `6`：为重启，运行init 6机器就会重启。

	#修改级别
	vi /etc/inittab
	把id:3:initdefault:中的3改为相应的级别
 

每次系统开机的时候，都会根据不同的runlevel级别启动不同的服务。运行`chkconfig --list`可以查看所有服务在不同运行级别下的启动状况。

**疑问**：几个疑问，写一下：

* 如何查看当前系统runlevel？
* 如何更换当前系统的runlevel？
* 更换runlevel时，需要重启吗？
* 服务器一旦启动，则runlevel就固定了？




	
**特别说明**：Linux下的run level很重要，要分析其产生原因、使用方式。



##Linux下系统服务的含义？

（doing...）

（可以单独开一篇文章）

鸟哥私房菜（第三版）--第18章 认识系统服务（deamons）




##参考来源

* [chkconfig命令][chkconfig命令]
* [About run levels][About run levels]
* [chkconfig命令（集合）][chkconfig命令（集合）]





[NingG]:    						http://ningg.github.com  "NingG"
[chkconfig命令]:					http://blog.csdn.net/youyu_buzai/article/details/3956845
[About run levels]:					https://docs.oracle.com/cd/E37670_01/E41138/html/ol_runlevels.html
[chkconfig命令（集合）]:				http://www.cnblogs.com/qmfsun/p/3847459.html



