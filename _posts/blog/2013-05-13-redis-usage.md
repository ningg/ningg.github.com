---
layout: post
title: Redis梳理
description: 编译，安装，增删改查等
published: true
category: redis
---

几点：

* Redis集群，整体结构：
	* 几个组件？
	* 每个组件的作用？
* 如何使用Redis集群？
	* 查询数据类型，根据不同类型进行操作
	* 增删改查
* 安装Redis集群
	* 安装配置各个组件
	* 启停Redis
* Redis集群性能维护
	* 如何定位当前Redis性能
	* 调优的注意事项？

##下载与安装

此处使用的Redis版本为：redis-3.0.1.tar.gz

###make

基本命令：

	$ wget http://download.redis.io/releases/redis-3.0.1.tar.gz
	$ tar xzf redis-3.0.1.tar.gz
	$ cd redis-3.0.1
	$ make
	
安装之后，可执行文件已经写到`src`文件夹下，使用如下命令启动Redis：

	$ src/redis-server

通过内置的Redis客户端，来操作Redis Server：

	$ src/redis-cli
	redis> set foo bar
	OK
	redis> get foo
	"bar"

> 备注：上述redis的安装包中有一个README文件，其中，包含了编译、安装、运行Redis的简要过程。

###make install

上面完成了Redis源码编译，还需要安装，默认安装到`/usr/local/bin`：

	$ make install
	
同时，作为生产使用的Redis还需要进行一些设置（端口、配置文件、日志文件、数据文件），以方便后续操作：

	$ cd utils
	$ ./install_server.sh

具体配置过程：

	$ sudo utils/install_server.sh 
	Welcome to the redis service installer
	This script will help you easily set up a running redis server

	Please select the redis port for this instance: [6379] 
	Selecting default: 6379
	Please select the redis config file name [/etc/redis/6379.conf] 
	Selected default - /etc/redis/6379.conf
	Please select the redis log file name [/var/log/redis_6379.log] 
	Selected default - /var/log/redis_6379.log
	Please select the data directory for this instance [/var/lib/redis/6379] 
	Selected default - /var/lib/redis/6379
	Please select the redis executable path [] /usr/local/bin/redis-server
	
	Selected config:
	Port           : 6379
	Config file    : /etc/redis/6379.conf
	Log file       : /var/log/redis_6379.log
	Data dir       : /var/lib/redis/6379
	Executable     : /usr/local/bin/redis-server
	Cli Executable : /usr/local/bin/redis-cli
	Is this ok? Then press ENTER to go on or Ctrl-C to abort.
	
	Copied /tmp/6379.conf => /etc/init.d/redis_6379
	Installing service...
	Successfully added to chkconfig!
	Successfully added to runlevels 345!

###检测Redis服务状态

查看Redis是否启动：

	$ ps -ef | grep redis
	root     59569     1  0 14:34 ?        00:00:00 /usr/local/bin/redis-server *:6379              
	storm    63723 26372  0 14:44 pts/0    00:00:00 grep redis

注：上述使用`install_server.sh`配置后，Redis服务已经启动，并且User为root。

默认使用命令`service redis_6379 status` 即可查看Redis服务的运行状态。为什么是`redis_6379`？因为上述自动配置过程中，默认生成了启动文件`/etc/init.d/redis_6379`，可以将这个文件重命名为`redis`，即：

	$ service redis_6379 status
	Redis is running (59569)
	$ mv /etc/init.d/redis_6379 /etc/init.d/redis
	$ service redis status
	Redis is running (59569)
	
注：Service是以名字来区分的，修改名字即更换Service的标识。

###使用redis-cli登录

敲一个小例子：

	$ redis-cli 
	127.0.0.1:6379> set key 12
	OK
	127.0.0.1:6379> get key
	"12"




##Redis基本结构

几点：

* `redis-cli`登录进去之后，使用`select 3`，对应什么含义？
* 如何查看一个key属于什么类型？
* 对于不同类型key，如何操作？

Redis是数据库，数据库下面会包含具体的数据库，`select 3`：表示选中第3号DB；注：Redis的内部操作，可参考[redis Command][redis Command]。

常用操作：

* `select 3`，选择DB 3；
* `keys *`，查看所有的key；
	* `keys [pattern]`：查看满足条件的key
	* `type [key]`：查看key的类型
	* `exists [key]`：判断key是否存在
	* `del [key]`：删除key

Tips：

> 通过`redis-cli`进入命令行交互环境之后，输入的`select 3`以及`keys *`等命令，**不要使用`;`结尾，否则出错**。

##Redis中操作数据-CRUD

针对不同类型的key，可进行的操作，参考：[Redis 命令参考(中文)][Redis 命令参考(中文)]























##参考来源

* [安装redis及常见问题][安装redis及常见问题]
* [redis安装][redis安装]
* [分析Redis架构设计][分析Redis架构设计]
* [redis Command][redis Command]




[NingG]:    http://ningg.github.com  "NingG"


[安装redis及常见问题]:		http://www.weishanli.com/wordpress/%E5%AE%89%E8%A3%85redis%E5%8F%8A%E5%B8%B8%E8%A7%81%E9%97%AE%E9%A2%98/
[redis安装]:				http://www.cnblogs.com/Alight/p/4001198.html
[分析Redis架构设计]:		http://blog.csdn.net/a600423444/article/details/8944601
[redis Command]:			http://redis.io/commands
[Redis 命令参考(中文)]:		http://redisdoc.com/




