---
layout: post
title: Redis 设计与实现：客户端 & 服务器
description: 客户端、服务器实现细节和交互的基本过程
published: true
category: redis
---


这一部分专注：Redis 的客户端 & 服务器原理。

Redis，一服务器、多客户端：

* 服务器端，**单进程单线程**，与多个客户端相连
* 服务器端，为每个连接的客户端，建立一个`redisClient`，存储客户端状态信息

![](/images/redis/redis-server-and-client-connection.png)

![](/images/redis/redis-client-and-server-redisServer.png)
 
redisClient 很重要，简单说一下其中包含的信息：

* 客户端，套接字描述符
* 客户端，名字
* 客户端，标志值（flag）
* 客户端，正在使用的数据库的指针，以及该数据库的号码
* 客户端，当前要执行的命令、命令的参数、命令参数的个数，以及指向命令实现函数的指针
* 客户端，输入缓冲区、输出缓冲区
* 客户端，复制状态信息，以及进行复制所需的数据结构
* 客户端，执行BRPOP、BLPOP等列表阻塞命令时，使用的数据结构
* 客户端，事务状态，以及执行WATCH命令时用到的数据结构
* 客户端，执行发布与订阅功能时，用到的数据结构
* 客户端，身份验证标志
* 客户端，创建时间，客户端和服务器最后一次通信的时间，以及客户端的输出缓冲区大小超出软性限制（soft limit）的时间

## 客户端

### 客户端的属性

套接字描述符：fd

* 范围：-1，0，1，...
* 命令：CLIENT list，可以查看连接到服务器的所有客户端信息
* fd = -1，伪客户端，不是来自网络
	* AOF：载入AOF文件，还原数据库状态
	* Lua脚本：执行Lua脚本中包含Redis的命令
* fd = 0，1...，通过网络与Redis服务器通信

名字：name

* 默认：客户端没有name，为null
* 命令：CLIENT setname [client_name]，然后通过 CLIENT list 命令查看

标志值：flag

* 取值：单个标志，多个标志的二进制或
* 标志使用常量表示
* 角色标志：
	* `REDIS_MASTER\REDIS_SLAVE`：主从复制时，主服务器、从服务器，相互为Client/Server，`REDIS_MASTER` 主服务器，`REDIS_SLAVE` 从服务器
	* `REDIS_PRE_PSYNC`：版本低于 2.8 的从服务器，只能与 `REDIS_SLAVE` 标志同时出现
	* `REDIS_LUA_CLIENT`：Lua脚本里包含Redis命令的伪客户端
* 状态标志：
	* `REDIS_MONITOR`：客户端正在执行MONITOR命令
	* `REDIS_UNIX_SOCKET`：UNIX套接字链接客户端
	* `REDIS_BLOCKED`：BRPOP、BLPOP等命令阻塞
	* `REDIS_UNBLOCKED`：已经不再阻塞，只能与`REDIS_BLOCKED`标志同时出现
	* `REDIS_MULTI`：正在执行事务
	* `REDIS_DIRTY_CAS`：事务使用WATCH命令监视的key已被修改，事务失败，与`REDIS_MULTI`标志同时存在
	* `REDIS_DIRTY_EXEC`：事务再命令入队时异常，事务失败，与`REDIS_MULTI`标志同时存在
	* `REDIS_CLOSE_ASAP`
	* `REDIS_CLOSE_AFTER_REPLY`
	* `REDIS_ASKING`
	* `REDIS_FORCE_AOF`：强制服务器将当前命令，写入AOF
	* `REDIS_FORCE_REPL`：强制服务器将当前命令，复制给从服务器
	* `REDIS_MASTER_FORCE_REPLY`
	* ...

关于上述Client的状态标志：`FORCE_AOF`、`FORCE_REPL`

* PUBSUB命令，会使客户端打开 `FORCE_AOF` 标志
* SCRIPT LOAD命令，会使客户端打开 `FORCE_AOF`、`FORCE_REPL` 标志
* 正常情况下，只读命令，不会改变数据库状态，因此，不需要添加到AOF文件中
* PUBSUB会改变订阅者的状态，不具有幂等性，需要强制追加到AOF中
* SCRIPT LOAD没有修改数据库，但修改了服务器状态，

输入缓冲区：

* 作用：存储客户端发送来的命令，每次只保存一条命令？
* 对应属性：sds querybuf
* 根据输入内容，动态的缩小或扩大
* 最大值 1GB，超过 1GB 服务器将关闭这个客户端

命令与命令参数：

* 服务器自动分析命令（存储在输入缓冲区）
* 获得命令参数数组（argv）&个数（argc）

命令的实现函数：

* 命令参数数组argv的第一个参数argv[0]，查询命令表，获得命令实现函数
* 命令表，查找操作不区分大小写

输出缓冲区：

* 作用：客户端执行命令，结果保存在输出缓冲区中
* 客户端，有 2 个输出缓冲区：固定区域、可变区域
* 固定区域：16KB
* 可变区域：不确定（List）
* 固定区域占满或者内容过大无法保存在固定区域时，启用可变区域
* 疑问：一定会先使用固定区域，然后再使用可变区域吗？

身份认证：

* 作用：客户端是否通过身份认证
* 对应属性：authenticated
* 服务器需要开启权限认证，配置文件中 requirepass 选项；未开启权限认证时，authenticated 默认为 0，不影响客户端的使用
* 0，未认证，AUTH 命令可以执行，其他命令全部被拒绝
* 1，已认证

时间：

* ctime：客户端创建时间，用于计算客户端与服务器已经连接多长时间
* lastinteraction：客户端、服务器，最后一次交互的时间，客户端的请求或者服务器的回复，用于计算 client 空转（idle）时间
* obuf_soft_limit_reached_time：输出缓冲区，第一次达到软性限制（soft limit）的时间
* 疑问：输出缓冲区，soft limit 是什么？

### 客户端的创建 & 关闭

整体上，客户端分为：普通客户端、伪客户端。其中，伪客户端指：不走网络连接的客户端，例如：AOF文件加载、Lua脚本执行Redis命令。

创建普通客户端：

* 普通客户端：通过网络连接服务器
* 客户端，调用connect函数连接服务器
* 服务器，调用连接事件处理器，创建客户端状态 redisClient

关闭普通客户端：

* 网络连接断开：网络原因，或者客户端进程终止
* 异常输入：客户端发送的命令，不符合协议格式
* CLIENT KILL （疑问：谁执行的？）
* 客户端空转（idle）时间超时：服务器端设置 timeout，当然主从服务器时，有例外
* 命令请求，超过输入缓冲区限制（默认 1GB）
* 命令响应，超过输出缓冲区限制，限制输出缓冲区大小， 2 种模式：
	* 硬限制（hard limit）：超过之后，立即关闭客户端
	* 软限制（soft limit）：超过软限制，但未超过硬限制，客户端中 `obuf_soft_limit_reached_time` 记录触发软限制（soft limit）的起始时间；如果持续超过 soft limit，并且超过限制时间，则关闭客户端

`client-output-buffer-limit <normal | slave | pubsub> <hard limit> <soft limit> <soft seconds>`：

* 普通客户端、从服务器客户端、发布订阅客户端
* 设置hard limit、soft limit、soft seconds

Lua 脚本的客户端：

* 伪客户端：Lua 脚本中执行Redis命令
* 服务器启动初始化时，创建 Lua 脚本的客户端，只有当服务器关闭时，才关闭

AOF 文件的客户端：
* 伪客户端：加载AOF文件
* 加载AOF 文件时，创建客户端，加载完毕后，关闭客户端

### 回顾

[http://redisbook.com/preview/client/review.html](http://redisbook.com/preview/client/review.html)




## 服务器

### 命令执行过程

客户端 & 服务器之间，执行命令的基本过程：

![](/images/redis/redis-client-and-server-interactive-progress.png)

### serverCron 函数

Redis 服务器中 serverCron 函数：

* 默认每隔 100ms 执行一次
* 负责管理管理服务器资源，保持服务器的良好运转
* serverCron 函数，主要与 redisServer 服务器状态数据相关

思考：serverCron 是 fork 出来的子进程复制执行的。

serverCron 函数的主要功能：

* 更新服务器，缓存的系统时间：unixtime、mstime，秒级、毫秒级UNIX时间戳，缓存的系统时间精度不够
	* 每 100ms 更新一次
	* 适用：打印日志、更新服务器的LRU时钟、判断是否执行持久化任务、计算服务器上线时间（uptime）
	* 不适用：设置key的过期时间、添加慢查询日志，此时，会再次执行系统调用，获取当前的准确时间
* 更新，LRU时钟：lruclock，缓存的系统时间，用于计算 key 的空转时间（idle time）
	* 每 10s 更新一次
	* 对象的最后一次访问时间：lru，利用 `lruclock - lru` 可以计算出对象的空转时间
	* 命令：`OBJECT IDLETIME`、`INFO server`
* 更新服务器，每秒执行命令次数：
	* 抽样方式计算：记录两次统计的时间点、执行命令的绝对值，计算每毫秒执行命令数目，乘以 1000，然后存入循环数组中
	* 循环数组，长度 16，当客户端执行命令 INFO server 时，计算循环数组的均值，返回：`instantaneous_ops_per_sec` 属性
* 更新服务器，内存峰值记录：
	* 服务器使用内存数量，如果达到新的峰值，则更新 `stat_peak_memory`
	* 命令：INFO memory，查看内存峰值，`used_memory_peak`、`used_memory_peak_human`
* 处理SIGTERM信号：
	* 启动服务器时，服务器进程的SIGTERM信号关联处理器 singtermHandler 函数
	* 信号处理器，在收到SIGTERM信号后，打开服务器状态的`shutdown_asap`标识（设置为1，表示关闭服务器）
	* 在关闭服务器之前，会**先进行RDB持久化操作**
* 管理客户端资源：serverCron 函数每次都会调用 clientsCron 函数，其会对一定数量的客户端进行以下 2 个检查：
	* 客户端、服务器连接超时，很长时间没有互动，则关闭客户端
	* 客户端在执行上一次命令之后，输入缓冲区大小已经超过一定长度，则释放当前输入缓冲区，新建一个默认大小的输入缓冲区，节省内存
* 管理数据库资源：serverCron函数，每次都会执行databasesCron函数，其会检查一部分数据库，删除过期 key，对字典进行收缩操作
* 执行被延迟的BGREWRITEAOF：
	* 服务器执行BGSAVE期间，如果收到同一客户端的BGREWRITEAOF命令，则会将其执行延迟到BGSAVE执行完毕之后
	* redisServer中的 `aof_rewrite_scheduled` = 1 表示延迟执行BGREWIRTEAOF
	* 仅当没有BGSAVE、BGREWRITEAOF命令执行，同时`aof_rewrite_scheduled`=1时，才会执行
* 检查持久化操作的运行状态：
	* redisServer中，`rdb_child_pid`、`aof_child_pid`标识RDB、AOF持久化进程的id，如果id = -1，则表示没有持久化在执行
	* 如果没有持久化进程，则会检查是否满足触发持久化条件
* 将AOF缓冲区中的内容写入AOF文件：
	* 如果开启了AOF功能，并且AOF缓冲区中还有数据，则同步到AOF文件中
* 关闭异步客户端：关闭输出缓冲区大小超过限制的客户端（**疑问：为什么叫异步？**）
* 增加cronloops计数器的值：唯一用途，在复制模块中实现「每执行serverCron函数N次就执行一次指定代码」的功能

### 服务器初始化

启动服务器时，需要经过一系列的初始化，完成初始化之后，才能接受客户端的命令请求：

* 初始化服务器的状态结构：initServerConfig函数
	* 创建 redisServer 服务器状态对象 server
	* 并为属性赋予默认值
	* 创建命令表
* 加载配置选项：命令中指定 redis.conf 配置文件，或者 `--port xxxx` 指定端口，调整 redisServer的属性
* 初始化服务器的数据结构：initServer函数
	* `server.clients`：所有客户端状态
	* `server.db`：所有数据库
	* `server.pubsub_channels`：频道订阅的字典
	* `server.pubsub_patterns`：模式订阅的字典
	* `server.lua`：Lua脚本环境
	* `server.slowlog`：慢查询日志
* 还原数据库状态：上述目标 初始化 redisServer 服务器状态对象 server
	* 完成初始化后，需要加载持久化文件，还原数据库状态
	* AOF、RDB同时存在时，优先采用 AOF 方式还原
	* 疑问：为什么优先AOF？因为 AOF 更新频率更高
* 执行事件循环：接受客户端的连接请求？


## 小结

![](/images/redis/redis-client-and-server-interactive-progress.png)

几个关键点：

1. 操作对象：redisClient
1. 两个缓冲区：服务器端，redisClient 的输入缓冲区、输出缓冲区
1. 执行前的分析和检查：命令执行之前，分析、检查命令
1. 子进程：执行命令后，子进程进行必要处理

关于输出缓冲区：

1. 分为：固定区（16KB）、可变区
1. 一次命令的执行结果，不会被截断，只能存储到固定区或可变区
1. 优先使用固定区，如果固定区空间不足，则将命令执行结果放置到可变区
1. 如果可变区已经启用，则，不会继续向固定区追加数据
1. 可变区分为：`hard limit`、`soft limit` + `timeout`，触发关闭 Client 条件
	* 超过 `hard limit`，立即关闭？
	* 超过 `soft limit`，并且`timeout`，立即关闭？

关闭 Client ，有两种情况，redisClient 中 flag：

1. `REDIS_CLOSE_AFTER_REPLY`：返回执行结果后，再关闭
	* 适用命令：quit、kill、输入缓冲区中数据不符合协议规范
	* 不会继续读取输入缓冲区中命令
	* 不会向输出缓冲区，添加内容
	* 返回当前时刻输出缓冲区中内容
2. `REDIS_CLOSE_ASAP`：异步释放，cronServer下次执行时，安全关闭
	* 使用情况：输出缓冲区，超过 hard limit、soft limit + timeout
	* 不会返回输出缓冲区中内容
	* cronServer下次执行时，安全关闭
	* 不是 As Soon As Possible


## 参考来源

* [服务器与客户端](http://origin.redisbook.com/internal/redis.html) 





[NingG]:    http://ningg.github.com  "NingG"










