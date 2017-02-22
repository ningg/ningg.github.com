---
layout: post
title: Redis 设计与实现：Sentinel
description: Redis 中 Sentinel 作用，注意事项
published: true
category: redis
---

## 0. 概要

基本问题：

1. Sentinel 是什么？
1. 能做什么？
1. 原理？

> Redis 的高可用解决方案：依赖 sentinel 系统
> 
> 一个 Sentinel 集群，可以支持多个 Redis 的 Master-Slave 集群。

Sentinel 实现 Redis 高可用的细节：

1. sentinel 系统监控 Redis 的 master 和 slave
1. master 下线后，在 slave 中选举出新的 master
1. 将其余 slave 设置为 new master 的 slave
1. 将 old master 设置为 new master 的 slave
1. old master 重新上线后，将作为 slave 存在

基本知识：

* sentinel 是特殊模式下的 redis 服务器
* sentinel 可以看做现有Redis 集群的客户端
* 启动 Sentinel ，还需要启动 Redis 吗？RE：需要，因为 Sentinel 跟原始 Redis 集群，是两个维度的东西

## 1. 是什么？

sentinel（哨兵），是什么？

1. 为提升 redis 集群可用性的一种机制
1. 配合 redis 的 master & slave 结构使用
1. 目标：当 master 下线之后，推举出 slave 替代 master，配置其他 slave 为 new master 的slave
1. sentinel 不是后台进程，是独立的，与现有 redis 集群并列的另外一个进程（系统）
1. 跟现有 redis 集群在同一台物理服务器上，也可以不再同一物理服务器上

![](/images/redis/redis-sentinel-general.png)

关于 master 下线，分为：主观下线、客观下线

* 主观下线：单个 sentinel 判断 master 下线
* 客观下线：设定的多个 sentinel 判断 master 下线

## 2. 能用来，做什么？

**1.一个典型的 master-slave 结构**

![](/images/redis/redis-sentinel-specific-master-slave-struct.png)

要解决的基本问题：

> 当 master 失去连接：
> 
> 1. 如何启用 slave 替代 master？
> 1. 多个 slave 时，选取哪个 slave？

上面的问题，如果解决不了，那配置 master、slave 结构有什么用？

sentinel 的使命：解决上述问题。

**2.为提升系统可用性，配置 sentinel 机制：启动一个指向 master 的 sentinel**

![](/images/redis/redis-sentinel-set-sentinel-to-master-slave.png)

**3.sentinel 经过初始化等过程后，与 master、slave之间建立起命令连接**

![](/images/redis/redis-sentinel-ms-cmd-with-sentinel.png)

备注：实际上，先与 master 建立`命令连接`，通过这一连接发现其 slave，然后与slave建立`命令连接`。（sentinel 以 10s/次 的频率向 master 发送 INFO 命令，并以此发现 slave）

思考：sentinel 连接 master、slave时，是否需要添加权限认证？

Re：如果 master 开启权限认证，则需要 sentinel、slave 都设置连接密码。

**4.sentinel 通过命令连接，与 master、slave 建立起订阅连接**

![](/images/redis/redis-sentinel-pubsub-cmd-between-sentinel-and-ms.png)

备注：命令连接和订阅连接的用途不同：

1. 命令连接：sentinel 获取 master、slave 信息
1. 订阅连接：sentinel 获取当前 master 关联的其他 sentinel

**5. 当 master 下线（失去连接）时**

1. sentinel 从 slave 中推举出 new master
1. sentinel 设置其余 slave 为 new master 的 slave
1. sentinel 设置 old master 为 new master 的 slave

思考：推举出哪一个 slave 成为 Master？标准呢？

**6. 上面 sentinel 成为单点，因此，可将sentinel 扩展为集群**

![](/images/redis/redis-sentinel-mulit-sentinel.png)

备注：上述 sentinel 集群中，sentinel A、Sentinel B、Sentinel C 实际上都与 master、slave 建立起了「命令连接」和「订阅连接」，为了绘图清晰，省略了这些连接。

也可以使用下面截图来表示「sentinel 系统」与「redis 集群」之间的关系：

![](/images/redis/redis-sentinel-sentinel-cluster-with-ms-cluster.png)
 
简单总结一下吧：

1. sentinel 启动时，指定其监听的 master（可以指定多个 master）
1. sentinel 与 master 建立「命令连接」
1. sentinel 通过与 master 建立的「命令连接」，发现 slave
1. sentinel 与 slave 建立「命令连接」
1. sentinel 通过与 master 建立的「命令连接」，建立「订阅连接」
1. sentinel 通过「订阅连接」发现其他 sentinel
1. sentinel 与其他 sentinel 建立 「命令连接」，形成 sentinel 系统

几个连接的作用：

* sentinel 与 master 之间的「命令连接」：发现 slave
* sentinel 与 slave 之间的「命令连接」：old master 下线后，设置 new master，同时，将其余 slave 设置为 new master 的 slave
* sentinel 与 master 之间的「订阅连接」：发现同一个 master 上的其他 sentinel，形成 sentinel 系统
* sentinel 与 slave 之间的「订阅连接」：什么作用？莫非是等 slave 成为 new master 之后，才使用？
* sentinel 与 sentinel 之间的「命令连接」：当某一个 old master 下线后，推举出一个领头的 sentinel，由这个 sentinel 负责进行故障迁移

## 3. 基本原理

针对一次master下线，slave 接替 master 的过程，Sentinel 的基本工作过程：

1. 启动并初始化 sentinel
1. 获取 master 信息
1. 获取 slave 信息
1. 向 master 、slave 发送信息
1. 接收 master 、slave 的订阅信息（频道信息）
1. 检测 master 下线状态
	1. 主观下线状态：sentinel 向 master 发送 PING 命令，在down-after-milliseconds时间内，没有得到回复，或者得到无效回复（只有 +PONG、-LOADING、-MASTERDOWN 有效），则判定为「主观下线」，即，一个 sentinel 认为的下线；
	1. 客观下线状态：sentinel 发现 master 下线之后，向其他sentinel 询问 master 是否下线，其他 sentinel 会立刻通过「命令连接」进行判断，如果超过设定数量（quorum）的 sentinel 都认为 master 已经下线，则设置 master 为「客观下线」，即，多个 sentinel 认为的下线；
1. 选举领头 sentinel
	1. 领头 sentinel 主导故障转移：
	1. master 下线后，在 slave 中选举出新的 master
	1. 将其余 slave 设置为 new master 的 slave
	1. 将 old master 设置为 new master 的 slave
	1. old master 重新上线后，将作为 slave 存在

特别说明：两个关键算法/策略，今后再去补充：

1. 多个 sentinel 中，如何推举出「领头 sentinel」？
1. 多个 slave 中，如何选出「new master」？

简单说一下思路：选择的基本原则是，尽可能无缝切换。

## 4. 启动并初始化 sentinel
两种方式：

> redis-sentinel /path/to/your/sentinel.conf
> 
> 或者
> 
> redis-server /path/to/your/sentinel.conf --sentinel
> 
> // 特别说明：redis-server --sentinel /path/to/your/sentinel.conf 命令无效

上述两个命令效果相同。

当启动 sentinel 时，需要执行以下步骤：

1. 初始化服务器
1. 普通 Redis 服务器代码，替换为 Sentinel 专用代码
1. 初始化 Sentinel 状态
1. 根据指定配置文件，初始化 Sentinel 监视的 master 列表
1. 创建连接 master 的网络

疑问：启动 Sentinel ，还需要启动 Redis 吗？RE：需要，因为 Sentinel 跟原始 Redis 集群，是两个维度的东西。

## 5. sentinel.conf 配置文件

Redis 3.0 sentinel.conf 中常见配置项：

```
# Example sentinel.conf
 
# sentinel 端口
port 26379
 
# NAT 相关配置，暂时忽略
# sentinel announce-ip <ip>
# sentinel announce-port <port>
 
# Sentinel 数据存储位置
dir /tmp
 
# 指定监听的 master：master_name，ip，port，quorum（判断 master 主观下线的 sentinel 最小个数）
# master_name 中限制的有效字符：A-z 0-9 .-_
sentinel monitor mymaster 127.0.0.1 6379 2
 
# 指定 master 需要的鉴权密码
sentinel auth-pass mymaster MySUPER--secret-0123passw0rd
 
# 指定判断 master、slave 主观下线的阈值，单位：ms，默认：30s
sentinel down-after-milliseconds mymaster 30000
 
# 故障迁移时，每次迁移的 slave 个数，注：slave 迁移期间，slave 无法提供迁移服务，因此，建议参数设置为 1
sentinel parallel-syncs mymaster 1
 
# sentinel failover-timeout 超时时间
sentinel failover-timeout mymaster 180000
 
# NOTIFICATION SCRIPT
# master 出现异常时，sentinel 进行通知：email、SMS等
# sentinel notification-script <master-name> <script-path>
 
# CLIENTS RECONFIGURATION SCRIPT
# master 出现异常，sentinel 选举出新的 master 后，告知 clients：master 的新地址
# sentinel client-reconfig-script mymaster /var/redis/reconfig.sh
```

更多细节参考： [Redis 3.0 的 Sentinel 配置文件](https://raw.githubusercontent.com/antirez/redis/3.0/sentinel.conf)

## 参考来源

* [Redis 3.0 的 Sentinel 配置文件](https://raw.githubusercontent.com/antirez/redis/3.0/sentinel.conf)





[NingG]:    http://ningg.github.com  "NingG"







