---
layout: post
title: Linux下禁止用户远程登录
description: 如何确定哪些用户可以远程登录？如何禁止用户远端登录？
category: linux
---

##背景

有些用户不安份，能不能禁止用户登录（锁定用户）？

##分析

说实话，这个问题很小，不过思路不能丢，要禁止用户登录，涉及几个问题：

* 如何操作，会锁定用户，使其无法登录？
* 如何判断哪些用户已经被锁定？
* 如何解锁用户，允许其登录？
* 有没有批量锁定用户的命令？

吹个牛，上面的几个点，就跟实际做事情的要点是一样的，即：

* 如何把事情做成？
* 如何验证事情已经做成？
* 如果出现差错，如何消除事情的影响？
* 如何又快又好的把事情做成？


##锁定用户和解锁用户

通过命令`usermod`即可完成对用户的锁定和解锁：
	
	// Lock a user´s password. This puts a ´!´ in front of the
	// encrypted password, effectively disabling the password. 
	[root@ningg ~]# usermod -L ningg
	
	// Unlock a user´s password. This removes the ´!´ in front 
	// of the encrypted password. 
	[root@ningg ~]# usermod -U ningg

也可以设定用户的自动解锁时间，具体参考`man usermod`。需要说明一点，通过`usermod -L [login]`锁定用户`[login]`，则，当用户尝试登录时，会提示："incorrect password"；而root用户，则可以通过`su - ningg`直接转换为用户ningg的身份。

**备注**：命令`passwd`也可以进行用户的锁定和解锁：`passwd -l [login]`和`passwd -u [login]`两个命令。


##查看是否锁定用户

查看`/etc/shadow`文件，以`:`分割的第二行，如果以`!`或者`*`开头，则表示当前用户无法远程登录，只能通过root用户以su命令切换身份而来，具体，看下面的示例：

	[root@ningg ~]# vim /etc/shadow
	root:$6$t(省略...):16407:0:99999:7:::
	bin:*:15628:0:99999:7:::
	daemon:*:15628:0:99999:7:::
	ftp:*:15628:0:99999:7:::
	nobody:*:15628:0:99999:7:::
	ningg:$6$t(省略...):16374:0:99999:7:::
	flume:!!:16380::::::

**疑问**：以`!`与`*`开头，有没有差异？
	
##修改shell类型

通过修改用户登录之后的shell类型实现禁止用户登录，具体命令如下：

	// chsh - change your login shell
	chsh -s /sbin/nologin ningg
	
用户登录，提示信息：This account is currently not available.

###特殊的shell：/sbin/nologin

`/sbin/nologin`本质是用户的login shell，不过这个nologin shell有些特殊，需要说一说。`/sbin/nologin`使用户无法登录，本质是：用户无法使用bash或其他shell来登入系统，这个账户仍然可以使用其他系统资源，例如：www服务由帐号apache管理，其可以进行系统程序的工作，但是无法登入主机；

**疑问**：

* 用户登入系统、获取shell，只是获取shell时，被拒绝；那如果不去获取shell，是否可以登录？
* 用户的login shell是`/sbin/nologin`，那么，这类用户如何使用其他系统资源呢？其本质还得使用shell吧，只不过这个shell不是login shell；


当用户的login shell被设置为`/sbin/nologin`时，用户登录时，会被拒绝，并且提示信息：This account is currently not available；这个提示信息是可以定制的，具体定制方法：新建`/etc/nologin.txt`，并在其中写入提示信息即可。

###禁止所有用户登录

如果因为系统维护升级等原因，希望禁止所有用户登录，则按照上面的方式，一个一个禁用用户，很无聊，而且容易出错，一种下面是简便的解决方法：

	##在/etc目录下建立一个nologin文档
	touch /etc/nologin ##如果该文件存在，那么Linux上的所有用户（除了root以外）都无法登录
	##在/etc/nologin（注意：这可不是3中的nologin.txt啊！）写点什么，告诉用户为何无法登录
	
	##cat /etc/nologin
	9：00－10：00 系统升级，所有用户都禁止登录！
	 
解禁帐号也简单，直接将`/etc/nologin`删除就行了！

##比较两种方式

整理上面两种禁止用户登录的方式，其出发思路不同：

* 禁用用户登录密码：`usermod -L [login]`
	* 此时，root用户通过`su - [login]`仍可以切换为`login`用户身份；
* 禁用用户的login shell：`chsh -s /sbin/nologin [login]`
	* 此时，root用户无法通过`su`命令切换为`[login]`用户身份；

**重要遗留问题**：当设置为`/sbin/nologin`时，这一用户如何才能调用其他系统资源？



##参考来源

* [Linux如何禁止用户登录][Linux如何禁止用户登录]
* [Linux下用户和组管理][Linux下用户和组管理]
* 鸟哥的Linux私房菜（第三版） 第14章 Linux帐号管理与ACL权限设定






[Linux如何禁止用户登录]:		http://www.cnblogs.com/zero1665/archive/2010/06/06/1752492.html
[Linux下用户和组管理]:			http://ningg.github.io/linux-user-and-group/
[NingG]:    					http://ningg.github.com  "NingG"
