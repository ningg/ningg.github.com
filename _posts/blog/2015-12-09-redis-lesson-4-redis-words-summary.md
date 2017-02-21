---
layout: post
title: Redis 设计与实现：术语 & 名词 & 操作
description: 常用术语解释汇总
published: true
category: redis
---

涵盖几个方面：

* 名词
* 缩写：对应的全称、简单说明
* 操作：全称、简单说明

## 术语 & 名词

|名词|说明|备注|
|---|---|---|
| RDB | 全量、持久化，状态 | Redis DataBase，Redis Dump Binary |
| AOF | 增量、持久化，操作 | Append-Only File |
| snapshot | 持久化文件，就称为快照？ |   |


疑问：

* RDB，加载速度快，但AOF更新速度快，但优先采用AOF加载
	* 更新速度快，优先使用 AOF
	* AOF 加载，本质是：创建伪客户端，逐条执行 AOF 文件
	* RDB 加载速度快
	* AOF 加载，本质是：直接 load 内存镜像
* RDB、AOF加载时，Redis 服务器进程是否阻塞？
	* BGSAVE\BGREWRITEAOF，都是子进程处理，不会阻塞任何请求
* BGSAVE生成RDB文件时，Redis 服务器仍能提供服务，仅限于 read命令吗？
	* BGSAVE 时，子进程处理，不会阻塞任何命令，包括 read、write；中间使用了「写时复制」的技术
* RDB、AOF生成的时机？必须手动触发？可以配置触发策略？
	* 都有：手动触发、自动触发，2 种触发策略；
	* RDB 可以关闭、AOF 无法关闭？
	* RDB：配置 save 指令，可以自动触发
	* AOF：可以自动配置重写策略
* 生成RDB时，如何处理过期key？
	* 生成 RDB、以及 rewrite AOF 时，都不会写入「过期 key」
	* AOF 文件，针对惰性删除、定期删除的过期 Key，会增加一条 DEL 操作。


## 操作

|名词|说明|备注|
|---|---|---|
| SAVE | 持久化，生成 RDB 文件，服务器进程，阻塞 |  |
| BGSAVE | 持久化，生成 RDB 文件，子进程，服务器进程非阻塞  | Background SAVE  |
| BGREWRITEAOF | 子进程，重写AOF文件 | Background Rewrite AOF |

|名词|说明|备注|
|---|---|---|
| SELECT |   |   |
| SET |   |   |
| GET |   |   |
| FLUSHDB |   |   |
| FLUSHALL |   |   |
| HSET |   |   |
| RPUSH | List，右侧，队尾，追加 | Right Push |
| LPOP | List，左侧，队首，获取 | Left Pop |
| DEL |   |   |
| LRANGE |   |  |
| RANDOMKEY | 随机获取一个key |   |
| SREM | Set，删除 | Set Remove |
| SADD | Set，增加 | Set Add |
| SMEMBERS | Set，查询 | Set Members |


|名词|说明|备注|
|---|---|---|
| EXPIRE | 设置过期时间（秒），时间段 |   |
| PEXPIRE | 设置过期时间（毫秒），时间段 |   |
| EXPIREAT | 设置过期时间（秒），时间点，UNIX时间戳 |   |
| PEXPIREAT | 设置过期时间（毫秒），时间点，UNIX时间戳 |   |
| TIME | 查看当前时间，时间点 |   |
| TTL | 剩余的过期时间（秒），时间段 | Time To Live，存活时间 |
| PTTL | 剩余的过期时间（毫秒），时间段 |   |
| PERSIST | 去除过期时间 |   |

|名词|说明|备注|
|---|---|---|
| WATCH |   |   |
| MULTI |   |   |
| EXEC |   |   |
| DISCARD |   |   |

|名词|说明|备注|
|---|---|---|
| PUBLISH |   |   |
| SUBSCRIBE | 订阅频道 | Subscribe |
| UNSUBSCRIBE |   |   |
| PSUBSCRIBE | 订阅模式 | Pattern Subscribe |

|名词|说明|备注|
|---|---|---|
| info | 节点状态 |   |
| replicateof `<ip>` `<port>` | 设置当前节点为 ip:port 的slave |   |

|名词|说明|备注|
|---|---|---|
| cluster info | 集群状态 |   |
| cluster nodes | 节点状态 |   |
| cluster addslots `[slot]` | 槽指派 |  |
| cluster keyslot `[key]` | 计算key对应的slot |   |
| cluster replicate `<node_id>` | 设置当前节点为`<node_id>`节点的slave |   |
| cluster getkeysinslot `<slot>` `<count>` | 从`<slot>`中获取`<count>`个key | 使用跳跃表 |
| cluster setslot `<slot>` importing `<source_id>` | 目标节点，准备好从源节点导入指定 slot 的key |   |
| cluster setslot `<slot>` importing `<target_id>` | 源节点，准备好向目标节点迁移指定 slot 的key |   |


疑问：

* PEXPIRE，毫秒，P的含义？
	* precise，精确的
* WATCH，key发生变化时，事务失败，事务是否回滚？Redis中事务是否支持回滚？
	* 队列中，可以撤销命令的执行，但命令一旦执行，就无法回滚
 
 
## 参考资料

* [Redis Commands](http://redis.io/commands)









[NingG]:    http://ningg.github.com  "NingG"







