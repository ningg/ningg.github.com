---
layout: post
title: Redis 设计与实现：过期 key
description: Redis 中，针对过期 key 的处理
published: true
category: redis
---

关于 Redis 的 Master-Slave 结构，读写分离时，过期 key 的处理，经常遇到问题：

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



[NingG]:    http://ningg.github.com  "NingG"