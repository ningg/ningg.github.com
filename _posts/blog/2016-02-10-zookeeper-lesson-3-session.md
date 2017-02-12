---
layout: post
title: ZooKeeper 技术内幕：会话
description: 什么用途？如何进行会话管理？
published: true
category: zookeeper
---

## 背景

Session 的作用：

1. ZK Server 执行任何请求之前，都需要 Client 与 Server 先建立 Session；
2. Client 提交给 Server 的任何请求，都必须关联在 Session 上；
3. Session 终止时，关联在 Session 上的`临时数据节点`都会自动消失；

疑问：

1. Session 是如何创建的？
2. 遇到 TCP 连接异常，Session 如何处理？
3. Session 有什么特性？

## Session 的用途

Session 的作用？

* `临时节点`的生命周期
* `Watcher` 通知机制
* Client 请求的执行顺序

本质上，就是：Session 映射到一个 TCP 长连接，并且标识这条长连接

* 通过 TCP 长连接，发送请求、接受响应
* 接收来自 Server 的 Watcher 事件通知


## Session 的创建

Session 创建的时机和实现细节：

1. Client 连接到 ZK Server，创建 TCP 长连接，并创建 Session；
2. Client 侧，创建 Session ？保存 Session？
	* Client 发起`创建 Session`的事务请求
	* Client 和 Server 都会保留一份 Session 内容


ZK Server 节点异常时，Client 会将会话透明的转移到其他服务节点上。疑问：如何透明的转到其他服务节点的？

## Session 连接保持

1. Client 创建会话时，会指定 Session 的`超时时间 t`；
2. Server 侧：经过 `t` 时间后，Server 收不到 Client 的任何消息，Server 判定：Session 过期；
3. Cleint 侧：经过 `t/3` 时间后，未收到任何消息，则，Client 会主动向 Server 发送心跳信息；
4. Client 侧：经过 `2t/3` 时间后，会尝试连接其他 Server 节点，此时，还有 `t/3` 时间；

Client 尝试连接其他 Server 时，要保证新的 Server 能看到的`最新事务` >＝ 之前 Server看到的`最新事务`，所以，Client 连接到 Server 后，会先判断 `最新事务`的 zxid 是否满足 `Client 上的最新 zxid` >= `Server 上的最新 zxid`；若不符合条件，则尝试连接到另一个 Server。

具体 Session 保持流程：

![](/images/zookeeper/client-server-keep-alive.png)

Note：

> 创建会话、删除会话，本身就是事务请求，任意时刻，在 ZK 集群中，都有法定数量（Quorum）的服务器节点，保存有 Session 的信息。

## Session 状态转移图

Session 同时保存在 Client 和 Server 侧。

从 Client 看， Session 的状态转移图：

![](/images/zookeeper/zookeeper-session-lifecycle.png)

特别说明：

1. Server 负责判断：Session 超时
2. Client 不会判断 Session 超时
3. Client 负责关闭 Session
	* Client 主动关闭 Session
	* Client 收到 Server 的 Session Expired 指令


## Session 管理

关于 Session 管理：

1. Session 管理内容：包括：`会话创建`、`会话激活`、`会话删除`
2. Session 管理者：只由 `Leader` 独立负责；其他 Server 节点，将会话信息转发给 `Leader`，上报 Session 的激活信息。


> Note：`事务请求转发`只发生在 Leader 跟 Follower/Observer 之间，不会发生在 Leader 跟 Client 之间。


### Session 结构

ZK Server 侧，保存了 Session 对象，其中，包含属性：

1. sessionID：服务节点启动时，时间戳 + sid（`myid`中的数字），经过一定算法计算得到 `基准 sessionID` 之后的 SessionID，都为`基准 SessionID`自增得到。
2. TimeOut：超时时间，时间段
3. TickTime：下次超时时间点，`TickTime 约为 currentTime + TimeOut`，方便 ZK Server 对会话`分桶策略`管理，高效的进行会话检查和清理。
4. isClosing：ZK Server 判定 Session 超时后，将会话标记为`已关闭`，确保不再处理其新请求；

### Session 清理：分桶策略管理

ZK 中 `Leader 服务器`，`定期清理`会话，为了高效处理，采用`分桶策略`：

1. 定期清理会话：时间间隔 ExpirationInterval，默认时 tickTime （默认 2s）
2. 会话组织：过期时间点 ExpirationTime（（currentTime + timeOut） ExpirationInterval 向上取整）
3. 会话清理策略：当前时间点 >= ExpirationTime, 清理分桶

Note：`分桶策略`本质是`批量处理策略`，提升效率。

补充信息：对于 `会话超时清理`，通用策略有 3 种：`定期清理`、`定时清理`、`惰性清理`，每一种的清理时机不同，有的采用`组合方式`进行清理；ZK 中，只采用`定期清理`策略。


### Session 激活：更新所属分桶

Client 定期发送心跳信息，更新 Session 所在的分桶。

![](/images/zookeeper/zk-session-expiration-time.png)






 
## 参考来源

1. [ZooKeeper-Distributed Process Coordination] Chapter 2.2 & 9.7
2. [从Paxos到Zookeeper分布式一致性原理与实践] Chapter 7.4 会话








[Getting Started]:		https://zookeeper.apache.org/doc/trunk/zookeeperStarted.html

[ZooKeeper-Distributed Process Coordination]:    http://shop.oreilly.com/product/0636920028901.do
[从Paxos到Zookeeper分布式一致性原理与实践]:	https://book.douban.com/subject/26292004/

[JLine]:			https://github.com/jline
[ZooKeeper]:		https://zookeeper.apache.org/    "ZooKeeper"
[NingG]:    		http://ningg.github.com    "NingG"










