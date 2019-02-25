---
layout: post
title: Redis 设计与实现：过期 key
description: Redis 中，针对过期 key 的处理
published: true
category: redis
---

关于 Redis 的 Master-Slave 结构，读写分离时，过期 key 的处理，经常遇到问题：

> 已经过期的 key, 从 slave 节点, 能够 `get` 查询到 key 仍然存在;
>
> 本质原因:
>
> 1. slave 节点无法主动进行 DEL 删除动作, 只能从 master 同步到更新命令, 即, slave 上 `惰性删除`策略失效
>
> 2. **Redis 3.2 之前**的版本中, get 命令, 从 slave 节点, 查询到 key 时, 即使 key 已经过期失效, 但仍返回这个 key.

业务上的影响:

> 查询到 已经过期的 key 的取值存在, 程序中, 错误判断为: 互斥锁已经被占用, 不会进入后续逻辑, 导致 `即使锁已被释放` 仍无法被再次占用。

具体原理:

1. 对 key 设置过期时间，相对与绝对时间都会转为绝对时间保存（PEXPIREAT 实现）
1. Redis 过期 key 删除策略
	1. **惰性删除**：获取 key 的时候，如果过期了删除。内存不友好，CPU 友好（读写之前会执行 expireIfNeeded）
	1. **定期删除**：serverCron，随机从 expires 字典中取一个 key，如果过期了就删除它。检查一定的数量或者到达指定的超时时间
1. RDB 相关：
	1. 执行生成 RDB 的时候不保存过期的 key；
	2. 载入 RDB 的时候，master 不载入已经过期的 key，slave 不论是否过期都载入，当与 master 进行数据同步的时候会删除这些 key
1. AOF 相关：
	1. 当过期 key 被删除的时候，会向 AOF 文件中追加一个 DEL 命令；AOF 重写后不包含过期 key
	1. 主服务器 key 过期后，会向所有从服务器发送一条 DEL 命令；从服务器不会主动删除过期 key，而是等待主服务器的 DEL 命令（从服务器没有惰性删除，导致有可能会获取到已经过期的 key，在 [Redis 3.2 版本中修复了这个问题](https://github.com/antirez/redis/issues/1768)，虽然不惰性删除，但是假如 key 过期了，不返回该 key）

Redis 3.2 之前，过期 key 的解决方案：

* 查询 key 是否存在时, 使用 `ttl` 命令:
    * 锁不存在: 结果 `< 0`, 表示 key 不存在;
    * 锁已经存在: 结果 `> 0`, 表示 key 存在。


Redis 3.2 之后, 修复了过期 Key 在 Slave 节点仍能 `get` 到取值, **修复策略**:

1. 查询 Key 是否存在
2. 如果 Key 存在, 则, 判断 key 是否过期
3. 如果 Key 未过期, 则, 返回 Key 的取值; 否则, 返回 null
4. 在 slave 节点上, 仍然不支持 `惰性删除` 的过期 key 删除策略

参考资料:

* Redis 命令, [TTL](https://redis.io/commands/ttl)
* Redis 命令, [SETNX](https://redis.io/commands/setnx)

[NingG]:    http://ningg.github.com  "NingG"