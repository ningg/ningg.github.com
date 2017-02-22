---
layout: post
title: Redis 设计与实现：主从复制
description: Redis 的 master-slave 结构
published: true
category: redis
---

> ppt: [Redis 主从复制](/images/redis/Redis-Master-Slave.pdf)

## 概要

开始之前，简单说一下 Redis 集群中下面 3 者之间的关系：

* 主从复制：master & slave 机制，提升系统可用性，需要与 sentinel 机制配合，sentinel 负责故障迁移
* sentinel 机制：配合 master & slave 机制，提高系统的可用性
* 数据分片：多 master，每个master 分担一部分数据，分布式集群
	* redis cluster 内部的 master & slave 结构，能够自动进行故障迁移
	* redis cluster 的关注点：单机的内存不足，需要多节点分布式内存存储

思考：Redis Cluster 内部，自动故障转移，依赖 Sentinel 机制？


复制，就是主从复制：

1. 只存在于 master、slave 之间;
2. 复制，分为：同步复制、异步复制，Reids 的 MS 之间是`异步复制`；

> 主从复制的目标：master、slave数据保持一致。

几个典型问题：

1. 如何配置 master、slave 角色？即，一个 redis 节点，如何设置为 master、slave？
	* slave 上，执行 SLAVEOF 命令
	* slave 上，设置 slaveof 配置

主从复制，分为`全量同步`（sync）和`命令传播`（command propagate）两个操作：

* **全量同步**：将 slave 状态更新至 master 的当前状态，利用 RDB 文件进行；（**全量**） 
* **增量命令传播**：master 上执行 write 命令，导致slave 与 master 状态不一致，slave 上也需要执行这些 write 命令（**增量**）

特别说明：

1. 新加入的 Slave 在从 Master 进行`全量同步`时，Master 仍可以提供 write 服务；
2. Master 何时会终止 write 服务，只提供 read 服务？配置文件中设定 min-slave 以及 max-lag。

## 1. 旧版主从复制
slave 新加入时，进行主从复制，包括：全量、增量两个过程：

![](/images/redis/redis-sync-and-cmd-propagate.png)

当 slave 与 master 同步之后，master 上执行新的命令，则：

![](/images/redis/redis-master-slave-async.png)
 
实现细节，几个（查证详细过程）：

1. slave 加载完 RDB 后，不会立即告知 master，master 什么时候触发命令传播？
1. slave 通过向 master 发送 PING 命令，反馈自己加载 RDB 文件过程？
1. 命令传播，时间间隔？master 执行的命令，多久能够传播到 slave？

疑问：

1. 有几个缓冲区？作用分别是什么？
2. AOF 缓冲区？复制积压缓冲区？Client 输出缓冲区？

## 2. 旧版主从复制的局限

主从复制，几种情况：

1. **初次，主从复制**：slave 之前没有复制过 master 的状态，包含：`全量同步`和`增量命令传播`，2 个过程
1. **断网重连，主从复制**：命令传播过程中，网络连接中断，slave 重新连接到 master，重新进行主从复制
 
旧版主从复制功能，**局限性**：`断网重连`，主从复制时，会执行 SYNC 同步命令，非常耗时（磁盘 IO、网络IO）。

备注：

SYNC 同步命令，消耗大量资源：

1. 每次执行 SYNC 同步命令，master 、slave都需要执行如下动作：
	1. master 执行 BGSAVE 命令，生成 RDB 文件，这一过程中，master 消耗大量的 CPU、内存、磁盘I/O资源
	1. master 将 RDB 文件发送给 slave，这一过程，消耗 master、slave 大量的网络资源（带宽、流量），影响 master 响应的时间
	1. slave 接收到 RDB 文件后，需要载入 RDB 文件，这一过程中，slave 完全阻塞，无法提供服务
1. 策略：只在真正必要是，才使用 SYNC 命令

Redis 开始支持 PSYNC（部分重同步）的版本：

> [ Redis 2.8 Release Candidate 1 (2.7.101) ] Release date: 18 Jul 2013
> 
> ...
> 
> * [NEW] Slaves are now able to partially resynchronize with the master, so most of the times a full resynchronization with the RDB creation in the master side is not needed when the master-slave link is disconnected for a short amount of time.
> ...


## 3. 新版本主从复制

Redis 2.8 开始，使用 `PSYNC` 命令，替代 `SYNC` 命令，来进行`网络闪断`后的重新主从同步。

PSYNC（Partial Synchronize） 主要解决的问题：

> **断网重连后**，master & slave 之间的重新同步，条件满足时，避免 RDB 文件的资源消耗。

PSYNC 包含两种情景：

* **完整重同步**（full resynchronization）：与 SYNC 命令一致，触发 master 生成RDB 文件并发送给 slave，同时，master 向 slave 发送缓存区内的 write 命令；
* **部分重同步**（partial resynchronization）：主要针对，断网重连之后，slave 与 master 之间的同步，只进行差异部分的同步，疑问，就是：命令传播？
 
实现细节，疑问：

1. master 是否存在两个缓冲区？生成 RDB文件时，write 命令存储至缓冲区
1. 命令传播时，复制积压缓冲区，用于支持部分同步
1. 有了 PSYN 命令，是否还需要 SYNC 命令？

Re：

1. master & slave 场景，只有一个缓冲区，无论是否生成 RDB 文件：
	1. 写入：write 命令使用
	2. 读取：命令传播、部分重同步
1. 如果master 开启了 AOF 功能，则 write 命令也会向 aof 文件缓冲区写入一份。
1. 可以完全使用 PSYN 替代 SYNC 命令，但为了兼容，Redis 2.8+ 之后，仍然支持 SYNC 命令。

## 4. 部分同步的实现原理

![](/images/redis/redis-master-slave-psync.png)

补充参数的说明：

1. 复制偏移量（replication offset）：master、slave 都有这一 offset
	1. master：每次向 slave 发送 n 个字节数据时，就会将自己的 offset + n
	1. slave：每次收到 master 发送的 n 个字节数据时，就会将自己的 offset + n
	1. 如果 master 的offset 相同，则处于同步状态
	1. 疑问：master 向 slave 每次发送一个命令？上述数据什么含义？如果一次发送的数据无法构成一条完整的命令，如何处理？实际上，上述数据是，协议形式的命令
	1. 疑问：offset 什么时候重置\清零？
1. 复制积压缓冲区（replication backlog）：
	1. master 上维护的一个固定大小的缓冲队列，FIFO，默认 1 MB
	1. master 进行命令传播时，会将命令发送给所有 slave，同时，写入复制积压缓冲区（repli backlog）
	1. 如何设置 replication backlog 的大小？
	1. slave 通过 PSYNC 命令，将自己的offset 发送给 master，如果 slave 的 offset 与master 的offset 不相等，并且 slave 的 offset 存在于 replication backlog 中，则此时，执行部分同步即可；否则，需要执行完整同步
1. 服务器 ID（run ID）：
	1. master、slave 都有 run ID
	1. slave 进行初次复制时，会记录 master 的run ID
	1. slave 重新连接上一个 master 时，会发送之前保存的 run ID，用于确认，是否为同一个 master

备注：

> 设置复制积压缓冲区的大小：
> 
> 1. 默认大小：1MB
> 2. 计算应设置大小： `second` x `write_size_per_second`
> 	* second：slave 与 master 之间断开连接之后，重新连接的时间间隔
> 	* `write_size_per_second`：master 平均每秒执行的write 命令大小，以协议格式计算
> 	* 为了安全，通常设置大小为：2 x `second` x `write_size_per_second`
> 3. 修改配置文件中：`repl-backlog-size` 选项

疑问：

> slave 升级为 new master 之后，其余 slave 是否需要进行一次完整主从复制？Re：sentinel 机制，故障迁移的详细过程

PSYNC 同步命令的详细执行过程：

![](/images/redis/redis-master-slave-psync-progress.png)

主从复制时，基本过程：

1. client 向 slave 发送命令：`SLAVEOF <master_ip> <master_port>`
1. slave 在本地登记对应 master 的 ip、port
1. slave 与 master 建立连接
1. slave 向 master 发送命令 PING，判断连接状态是否良好，否则重新建立连接
1. slave 向 master 发送命令 AUTH，进行身份认证
1. slave 向 master 发送命令 `REPLCONF listening-port <port-num>`，告知 master ，当前 slave 所在监听的端口号
	1. master 接收到 slave 信息后，将slave 监听的端口号记录到 redisClient 的 `slave_listening_port` 属性
	1. 其唯一作用：master 执行 INFO replication 命令时，打印出 slave 的监听端口
1. slave 向 master 发送命令 PSYNC，进行同步
	1. 其中，master、slave 互为对方的客户端
	1. master 能够向 slave 传播命令，本质：master 为 slave 的客户端
1. master 向 slave 进行命令传播

心跳检测，基本过程：

> 命令传播阶段，slave 以 1个/秒，向 master 发送命令：`REPLCONF ACK <replication_offset>`，即 slave 当前的复制偏移量


发送 REPLCONF ACK 命令的作用：

1. 检测 master、slave 的连接状态
1. 辅助实现 min-slaves 选项
	1. min-slaves-to-write：slave 数量下限，小于这一值时，master拒绝执行 write 命令
	1. min-slaves-max-lag：slave 服务器 REPLCONF ACK 命令最后一次执行距离当前时间间隔，如果 slave 数量达到下限，同时 slave 的延迟（lag）值都大于等于 max-lag，则master 拒绝执行 write 命令
1. 检测命令丢失
	1. slave 的复制偏移量，小于 master 的复制偏移量，则，master 会从 复制积压缓冲区中，取出丢失的命令，再次发给 slave 执行
	1. 上述补发数据，跟网络断线重新连接过程很相似，唯一差异：当前只是丢失命令，并 slave、master 并没有断开网络连接，没有触发 断开网络连接的机制

备注：

> Redis 2.8+ 之后，引入的：复制积压缓冲区、REPLCONF ACK 命令
> 
> Redis 2.8 版本之前，master、slave 之间命令传播时，如果网络原因丢失命令，不会进行补发，因此，严格意义上，此时 slave 与 master 之间存在状态不一致的风险

## 5. 主从复制，异步进行

![](/images/redis/redis-master-slave-async.png)
 
Redis 3.0+ 通过命令方式，来支持主从复制的同步：

* [http://redis.io/commands/WAIT](http://redis.io/commands/WAIT)
* [http://antirez.com/news/66](http://redis.io/commands/WAIT) 
* [http://antirez.com/news/58 ](http://antirez.com/news/58 )

特别说明：

> 上述主从复制的同步，需要由 client 发起命令来确认，即，client 主动触发，才能确认主从复制的同步。

## 6. 相关配置

redis.conf 文件中，几个配置选项：

```
// 配置 master 的地址
slaveof <master_ip> <master_port>
 
// 填写 master 设定的密码
requirepass <master-password>
// 主从同步过程中、与 master 失去连接时，是否提供读取数据的服务，有可能为脏数据
slave-serve-stale-data yes
// 设定 slave 为只读模式
slave-read-only yes
  
// 向 master 发送 PING 消息的频率，下面配置表示：10s 一次
repl-ping-slave-period 10
// 主从复制的超时时间，认为master-slave连接已断开
// repl-timeout的设值一定要大于repl-ping-slave-period，否则即使主从之间通信并不繁忙，也会出现超时
repl-timeout 60
  
// 在 SYNC 之后，关闭从服务器上TCP_NODELAY，此时，命令传播时，slave 能够快速获得 master 上的更新，但更耗带宽
repl-disable-tcp-nodelay no
  
// 复制积压缓存区的大小，用于支持 PSYNC，只在第一个 slave 接入时，初始化
repl-backlog-size 1mb
// 最后一个 slave 断开连接后，master 释放 backlog 的倒计时间，默认 60mins
repl-backlog-ttl 3600
  
// slave 的优先级，sentinel 选取 new master 时的依据，取值越小，越优先；取值为 0 时，表示永不升级为 master
slave-priority 100
  
// slave 异常时，master 不再提供 write 服务
// slave 异常的判定条件：min-slaves-to-write、min-slaves-max-lag
// 任何一个条件设置为 0，都会禁用这一功能
// 默认 min-slaves-to-write 0
min-slaves-to-write 3
min-slaves-max-lag 10
  
  
// master 开启鉴权，设定密码
masterauth <master-password>
```
  
疑问：

1. repl-ping-slave-period 参数，是设定 slave 向 master 发送 PING 命令的频率吗？默认 REPLCONF ACK PING 是 1 s 吧？
2. `TCP_NODELAY` 什么含义？如何开启/关闭？
3. backlog：Master 上，为所有的 Slave 分配的公用复制挤压缓冲区


更多配置信息，参考：

* [http://redis.io/topics/config](http://redis.io/topics/config)




[NingG]:    http://ningg.github.com  "NingG"







