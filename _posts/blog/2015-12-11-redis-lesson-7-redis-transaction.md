---
layout: post
title: Redis 设计与实现：事务
description: Redis 下，事务操作的特性
published: true
category: redis
---


Client 发起一次事务时：

* 多个命令、一次性、按顺序执行
* 事务在执行的期间，不会主动中断：
	* 服务器在执行完事务中的所有命令之后， 才会继续处理其他客户端的命令

事务执行的基本过程：

* **事务开始**：`multi` 命令，设置 redisClient 中事务 flag （`REDIS_MULTI`）
* **命令入队**：分析、检查命令，如果命令执行的情况不满足，则返回错误信息，并且继续等待下一个命令
* **事务执行**：exec 命令，一次性执行所有命令，并将结果一次性返回给 Client

Client 输入 `multi` 命令，将开启 redisClient 中事务flag，同时，在事务中：

* 命令 multi、exec、discard、watch，直接执行
* 其他命令，在「执行命令」之前，直接进入事务队列
* 事务不能嵌套：multi 命令内部，不能再次执行 multi 命令
* 没有使用 multi 命令开启事务，exec命令，执行会抛出异常

具体，事务操作的基本过程：

![](/images/redis/redis-client-and-server-interactive-progress.png)

watch 命令，实现**乐观锁**，可以在事务执行之前，监视任意数量的 key：

* 在执行事务之前，检查 key 是否被修改，如果被修改，则终止事务，抛出异常
* 只在 exec 时，才会检查 key 是否被修改
* watch 只针对一次事务有效

watch 命令，实现机制：

* 补充知识点：
	* redisDb：一个数据库
	* redisServer：redisDb 列表
	* redisClient：redisDb 当前使用的数据库
* redisDb 中，有一个 `watched_keys` 字典
	* 形式： `key - redisClient` 列表
	* 记录哪些key，被哪些Client 监视
* 触发监视机制，执行过程：
	1. 执行修改命令 set、lpush、sadd、del、flushdb等之后，
	1. 执行 touchWatchKey 函数，检查被修改的key 对应的watch clients
	1. 将 watch clients 的状态 flag 设置为 `REDIS_DIRTY_CAS`
	1. exec 执行事务时，检查到状态 `REDIS_DIRTY_CAS`，则拒绝执行事务

watch 命令，对应 redisDb 中的存储结构 `watched_keys` 字典：

![](/images/redis/redis-transaction-watch.png)

事务的ACID属性：

* A，原子性：事务中所有命令，作为一个整体，执行成功，或者都不执行；实现机制：日志回滚
* C，一致性：一般由业务约束，例如，转账时，入账出账相等
* I，隔离性：多个事务之间相互干扰程度，数据一致性 vs 并发效率
* D，持久性：写入磁盘的数据，断电之后，数据是否存在

Redis中，事务的ACID属性的表现：

1. 原子性：Redis 的一个事务，如果单个命令错误，不会回滚，也不影响其前后的其他命令执行
1. 一致性：
	1. 入队错误：整个事务都不执行，标记 redisClient 的 flag 为 `REDIS_EXEC_DIRTY` （Redis 2.6.5 之前的版本，即使入队错误，已经成功入队的命令，仍会执行）
	1. 执行错误：事务执行过程中，一条命令执行出错，不会影响其前后其他命令的执行
	1. 服务器宕机：RDB 模式，持久化文件都是一致状态；AOF模式，会自动恢复到最近的一次一致状态
1. 隔离性：单进程单线程的Server服务（读写数据），串行化
1. 持久性：RDB、AOF两种持久化方式

疑问：Redis 的一个事务中，是否会出现脏读、不可重复读、幻读的现象？

## 参考资料

* [http://origin.redisbook.com/feature/transaction.html](http://origin.redisbook.com/feature/transaction.html)




[NingG]:    http://ningg.github.com  "NingG"







