---
layout: post
title: 读写锁：使用场景和实现方案（ZooKeeper 实现）
description: 读写锁，是什么？为什么需要？如何实现？基于 ZooKeeper 如何实现一个读写锁？
published: true
category: zookeeper
---

## 0.概要

锁，分为「**互斥锁**」和「**共享锁**」：

* **互斥锁**：`写锁`，是互斥锁
* **共享锁**：`读锁`，是共享锁

**互斥锁**，保证了资源的串行有序访问，但，系统**并发性能较低**，在「`高频读`-`低频写`」的场景中，一般采用「**读写锁**」方案，`ReadWriteLock`，支持共享读操作。

下文从几个方面展开：

1. 读写锁的特性 
1. ZooKeeper 中，读写锁的实现
1. 实践建议

## 1.读写锁的特性

「读-写锁」，业务上，要满足「**读共享、写互斥**」即可，实际场景中，需要考虑多种策略，他们都会影响最终「读写锁」的性能：

1. **释放优先**：当一个操作「**释放写锁**」时，并且队列中同时存在`读线程`和`写线程`时，那么是读线程**优先获得锁**，还是写线程，或者说是最先发出请求的线程
1. **读线程插队**：如果当读线程「**持有读锁**」时，有**写线程在等待**，那么新到达的读线程能否立即获得访问权，还是应该在写线程后面等待？
	* 如果允许读线程插队到线程前面，那么将提高并发性，但却可能造成写线程发生饥饿问题。
1. **重入性**：读锁、写锁是否允许重入。
1. **降级**：如果一个线程「**持有写锁**」，那么它能否在**不释放锁**的情况下「**降级成读锁**」？
1. **升级**：「**持有读锁**」的线程能否**优于**其他正在等待的读线程和写线程而「**升级成写锁**」？
	* 在大多数的「**读-写锁**」实现中，并**不支持升级**，因为很容易造成死锁（如果两个读线程同时升级为写锁，那么二者都不会释放读取锁） 

**读写锁的含义**：

1. **写锁**：互斥，同一时刻，只有一个进程，持有写锁
1. **读锁**：共享，同一时刻，可以多个进程，持有读锁
1. **组合**：
	1. **读锁**：所有的「**写锁**」都失效时，可以「**加读锁**」，读锁共享
	1. **写锁**：所有的「**读锁**」和「**写锁**」都失效时，可以「**加写锁**」，写锁互斥，跟所有的读写动作都互斥


## 2.ZooKeeper 中，读写锁的实现

ZooKeeper 的读写锁，**本质是**：

1. **生成 2 类锁**：一个**读锁**（共享）、一个**写锁**（互斥）
1. **同一个目录下**，创建「**临时顺序节点**」，**前缀不同**，`共享自增序号`

**补充信息**：

1. 创建 `/zookeeperLock/sharedLock/ip-type-id` 的「**临时顺序节点**」，来代表`读写锁`。
1. 其中`type`有 2 种枚举值：
	1. `R`：读锁（共享）
	1. `W`：写锁（互斥）
1. 获取「**读锁**」，会在ZooKeeper 上，创建类似节点：`/sharedLock/10.0.10.1-R-0000000001`。
1. 获取「**写锁**」，会在ZooKeeper 上，创建类似节点：`/sharedLock/10.0.10.1-W-0000000002`。 

具体 ZooKeeper 内部，采用 `InterProcessReadWriteLock` 实现共享的读写锁，具体过程：

1. **创建**「**临时顺序节点**」：根据需要获取的锁，创建对应的「读」或者「写」对应的「临时顺序节点」
1. 获取「**临时顺序节点**」的**全量列表**
1. 获取「读锁」或者「写锁」，业务**逻辑判断**：
	1. **读锁**：所有`前驱节点`中，没有「**W 类型**」节点存在，则，获取 **R 读锁成功**；
	1. **写锁**：所有`前驱节点`，`都不存在`，则，获取 **W 写锁成功**；即，当前节点的「序号最小」，则，获取 W 写锁成功；
1. 获取「**读锁**」或者「**写锁**」**失败**，则，**监听**「当前路径」的「**子节点列表变更**」，进入**等待锁状态**。Note：为了避免「羊群效应」，可以只监听「前驱节点」。

Note：

> 从上述处理逻辑中，可以看出，`InterProcessReadWriteLock` 是「公平锁」。

具体 ZooKeeper 命令，使用示例：

```
[zk: localhost:2181(CONNECTED) 1] ls /
[zookeeper, zk_test]
​
# 1. 创建「临时顺序节点」
[zk: localhost:2181(CONNECTED) 2] create -s -e /zk_test/P-W- hello
Created /zk_test/P-W-0000000000
[zk: localhost:2181(CONNECTED) 3] create -s -e /zk_test/P-W- hello
Created /zk_test/P-W-0000000001
​
# 2. 创建「临时顺序节点」，前缀不同
[zk: localhost:2181(CONNECTED) 5] create -s -e /zk_test/P-R- hello
Created /zk_test/P-R-0000000002
[zk: localhost:2181(CONNECTED) 6] create -s -e /zk_test/P-R- hello
Created /zk_test/P-R-0000000003
[zk: localhost:2181(CONNECTED) 7] create -s -e /zk_test/P-R- hello
Created /zk_test/P-R-0000000004
[zk: localhost:2181(CONNECTED) 8] create -s -e /zk_test/P-R- hello
Created /zk_test/P-R-0000000005
​
# 3. 查看「临时顺序节点」
[zk: localhost:2181(CONNECTED) 9] ls /zk_test
[P-R-0000000002, P-W-0000000000, P-R-0000000003, P-W-0000000001, P-R-0000000004, P-R-0000000005]
​
# 4. 查询「临时顺序节点」所属的 Session：ephemeralOwner 对应为 session 的 ID
[zk: localhost:2181(CONNECTED) 10] get /zk_test/P-W-0000000000
hello
cZxid = 0x8
ctime = Wed Feb 27 15:38:11 CST 2019
mZxid = 0x8
mtime = Wed Feb 27 15:38:11 CST 2019
pZxid = 0x8
cversion = 0
dataVersion = 0
aclVersion = 0
ephemeralOwner = 0x1692ddeb5fb0002
dataLength = 5
numChildren = 0
[zk: localhost:2181(CONNECTED) 11] get /zk_test/P-W-0000000001
hello
cZxid = 0x9
ctime = Wed Feb 27 15:38:17 CST 2019
mZxid = 0x9
mtime = Wed Feb 27 15:38:17 CST 2019
pZxid = 0x9
cversion = 0
dataVersion = 0
aclVersion = 0
ephemeralOwner = 0x1692ddeb5fb0002
dataLength = 6
numChildren = 0
```

## 3.实践建议

与「**互斥锁**」相比，「**读-写锁**」允许对共享数据，进行**更高的并发访问**。

虽然一次只有一个线程（writer 线程）可以修改共享数据，但在许多情况下，任何数量的线程可以同时读取共享数据（reader 线程），读-写锁利用了这一点。

实践中：

> 在实践中，「**读-写锁**」只有在多处理器上，`高频读` + `低频写` 场景下，才能提高性能。 
> 
> 而在其他情况下，「**读-写锁**」的性能却比「独占锁」的性能要差一点，这是因为「**读-写锁**」的**复杂性更高**。
> 
> 所以，要对程序进行分析，判断「读-写锁」是否能提高性能，特别是，大多数场景下，`高频读的场景`，可依赖**读取缓存**，**提升并发能力**。

## 4.参考资料

1. [读写锁ReadWriteLock](https://blog.csdn.net/jinggod/article/details/78526066)
1. [ZooKeeper典型应用——分布式锁](https://blog.csdn.net/lemon89/article/details/76268820)








[NingG]:    http://ningg.github.com  "NingG"
[从Paxos到Zookeeper分布式一致性原理与实践]:	https://book.douban.com/subject/26292004/
[ZooKeeper-Distributed Process Coordination]:    http://shop.oreilly.com/product/0636920028901.do
[ZooKeeper Administrator's Guide-A Guide to Deployment and Administration]:	http://zookeeper.apache.org/doc/trunk/zookeeperAdmin.html
[TaoKeeper]:	https://github.com/alibaba/taokeeper	"ZooKeeper-Monitor"








