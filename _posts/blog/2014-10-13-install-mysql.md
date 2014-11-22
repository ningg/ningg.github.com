---
layout: post
title: MySQL安装
description: 经常要安装MySQL，虽然整理有文档，但每次都会遇到点问题，这次系统整理一下
category: mysql
---

##背景

“在服务器上装个MySQL，我要用。”“OK，稍等。”这么一稍等，就等了40mins，而且，自己之前整理的MySQL安装步骤，并不完整，借这次安装的机会，整理一下吧。

##安装MySQL

通常安装MySQL分为几个基本步骤：本地安装MySQL、设置MySQL的root密码、开启MySQL允许远程访问。

###本地安装MySQL

Linux环境下安装MySQL，有两种方式：rpm包方式、yum源方式（暂不考虑编译源代码方式）。


####rpm包方式

到MySQL官网，下载MySQL社区开源版本，详细版本号为：MySQL-5.6.21-1.linux_glibc2.5.x86_64.rpm-bundle.tar。这是一个集合，包含了如下组件：

* MySQL-server
* MySQL-client
* MySQL-embedded
* MySQL-shared
* MySQL-shared-compat
* MySQL-test
* MySQL-devel

#####1.解压MySQL安装包

执行如下命令：

	[root@ningg mysql]#tar -xf MySQL-5.6.21-1.linux_glibc2.5.x86_64.rpm-bundle.tar
	[root@ningg mysql]#ls
		MySQL-server-5.6.20-1.el6.x86_64.rpm
		MySQL-client-5.6.20-1.el6.x86_64.rpm      
		MySQL-shared-5.6.20-1.el6.x86_64.rpm
		MySQL-devel-5.6.20-1.el6.x86_64.rpm       
		MySQL-shared-compat-5.6.20-1.el6.x86_64.rpm
		MySQL-embedded-5.6.20-1.el6.x86_64.rpm    
		MySQL-test-5.6.20-1.el6.x86_64.rpm

#####2.创建MySQL系统管理员

执行如下命令：

	[root@ningg mysql]#groupadd mysql
	[root@ningg mysql]#useradd -g mysql mysql
	[root@ningg mysql]#id mysql
		uid=27(mysql) gid=27(mysql) groups=27(mysql)

#####3.安装MySQL rpm包

执行命令如下：

	[root@ningg mysql]#rpm -ivh "*.rpm"
	Preparing...              ########### [100%]
	   1:MySQL-devel          ########### [ 14%]
	   2:MySQL-client         ########### [ 29%]
	   3:MySQL-test           ########### [ 43%]
	   4:MySQL-embedded       ########### [ 57%]
	   5:MySQL-shared-compat  ########### [ 71%]
	   6:MySQL-shared         ########### [ 86%]
	   7:MySQL-server         ########### [100%]

补充一下，如果安装出现意外，希望卸载MySQL组件，则，卸载顺序如下：

	[root@ningg ~]# rpm -e MySQL-server-5.5.24-1.rhel5
	[root@ningg ~]# rpm -e MySQL-embedded-5.5.24-1.rhel5
	[root@ningg ~]# rpm -e MySQL-shared-5.5.24-1.rhel5
	[root@ningg ~]# rpm -e MySQL-devel-5.5.24-1.rhel5
	[root@ningg ~]# rpm -e MySQL-test-5.5.24-1.rhel5
	[root@ningg ~]# rpm -e MySQL-client-5.5.24-1.rhel5

> 思考：如何保证是mysql用户启动的MySQL？如果使用root运行MySQL，一旦MySQL进程被Hacker控制，Hacker就拥有了root权限？

		
####yum源方式

（doing...）




###设置MySQL的root密码

更详细内容参考[MySQL 5.6 Manual: User account management](http://dev.mysql.com/doc/mysql-security-excerpt/5.6/en/user-account-management.html)

####1.修改MySQL启动配置

查找`my.cnf`文件位置，两个命令：`locate "my.cnf"`和`find / -name "my.cnf"`（备注：两个命令有差异，具体参考[文章](http://312788172.iteye.com/blog/730280)）。
通常文件位置`/etc/my.cnf`或者`/usr/my.cnf`，依具体情况行事，在其中设置不启用授权表：

	[root@ningg mysql]# vim /usr/my.cnf
	# For advice on how to change settings please see
	# http://dev.mysql.com/doc/refman/5.6/en/server-configuration-defaults.html

	[mysqld]
	# 新增加下面一行，含义：设置不启用授权表
	skip-grant-tables


####2.重置root密码

重新启动MySQL：`service mysql restart`，然后进行如下操作：

	[root@ningg mysql]# mysql

	mysql> use mysql
	mysql> update user set Password=PASSWORD('1234') where User='root';
	mysql> flush privileges;

之后，修改`my.cnf`文件，注释掉`skip-grant-tables`；然后，重启MySQL：`service mysql restart`。
	
####3.补充说明

针对msyql数据库下的user表，说明几点：

	mysql> use mysql
	#使用下面命令查看表格当前记录
	mysql> select * from user \G;
	#查看user表格的字段类型
	mysql> describe user;
	#查看Host\User\Password字段；
	mysql> select host,user,password from user;
	+-----------+------+---------------+
	| host      | user | password      |
	+-----------+------+---------------+
	| %         | root | *81B936FD50F6 |
	| cib02167  | root | *81B936FD50F6 |
	| 127.0.0.1 | root | *81B936FD50F6 |
	| ::1       | root | *81B936FD50F6 |
	+-----------+------+---------------+

具体：

* user表：用户信息、用户权限、密码、可以登录访问的远端主机等。
* host字段：表示登录MySQL的主机，可以是IP、主机名，如果为`%`则表示任何客户端主机都能登录，建议开发时，设置为`%`。


命令SET PASSWORD

	#设置用户在不同主机环境下的登录密码
	SET PASSWORD FOR 'root'@'%' = PASSWORD('newpass');

命令UPDATE

	# 可修改user表格内容（MySQL不区分大小写）
	update user set password=password('new-pw') where user='root' and host='%';

更新授权表
	
	# 修改用户信息等，务必flush
	flush privileges


###开启MySQL允许远程访问

在user表中，添加一条`user=root`且`host=%`的记录，并且通过SET PASSWORD命令重置密码即可。host字段取值`%`，即表示任何客户端机器，涵盖远程访问的机器。

	# 可修改user表格内容（MySQL不区分大小写）
	update user set password=password('new-pw') where user='root' and host='%';

> 疑问：如果没有`user=root`且`host=%`的记录怎么办？
> 
> RE：新建一条记录，或者将`user=root`的记录，利用update命令修改为`host=%`，比较官方的做法，添加一个用户root@%即可；参考官网：[adding users][adding users]
	
##常见问题

**问题1**：You must SET PASSWORD before executing this statement

解决办法：根据提示直接使用set password命令重置密码即可，如下：

	mysql> set password=password('new-pw');

**问题2**：这个本质上是不是MySQL的管理问题？有哪些用户，哪些用户可以远程登录？

回应：是的，你很用心在思考，官方文档有很多细节，很有意思的，可以看一下，具体：`MySQL Manual`--`Security in MySQL`--`User Account Management`，有详尽的说明。

**问题3**：MySQL上如何新增/删除用户？参考[adding users][adding users]和[removing users][removing users]
	
	-- 先刷新一下权限（避免问题发生）
	flush privileges;

	-- 创建用户 test:passwd
	create user 'test'@'%' identified by 'passwd';

	-- 为用户分配权限
	grant all privileges on *.* to 'test'@'%' with grant option;

	-- 查看用户权限
	show grants for 'test'@'%';

	-- 删除用户
	drop user 'test'@'%';


##参考来源

* [MySQL 5.6 Manual: Privilege system grant tables](http://dev.mysql.com/doc/mysql-security-excerpt/5.6/en/grant-table-structure.html)
* [MySQL 5.6 Manual: User account management](http://dev.mysql.com/doc/mysql-security-excerpt/5.6/en/user-account-management.html)
* [MySQL开源社区版本下载地址](http://dev.mysql.com/downloads/mysql/)
* [MySQL官方文档下载地址](http://dev.mysql.com/doc/)
* [linux下which、whereis、locate、find 命令的区别](http://312788172.iteye.com/blog/730280)



##闲谈

这篇文章，写的都是小问题，如果读过MySQL的官方文档，就知道`User Account Management`的基本知识了，也不用遇到什么问题就蒙圈了，用一个东西，先浏览学习一下官方文档很必要的，看似浪费时间，其实是捷径。当然，一个个小问题折磨自己，才让我意识到读一遍MySQL官方文档的好处。


[NingG]:    http://ningg.github.com  "NingG"

[adding users]:		http://dev.mysql.com/doc/mysql-security-excerpt/5.6/en/adding-users.html
[removing users]:			http://dev.mysql.com/doc/mysql-security-excerpt/5.6/en/removing-users.html
