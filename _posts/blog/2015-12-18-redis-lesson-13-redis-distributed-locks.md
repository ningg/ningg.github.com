---
layout: post
title: 分布式锁：方案分析（Redis 典型方案）
description: 为什么需要分布式锁？有哪些实现方案？Redis 如何实现分布式锁，又有哪些缺陷？ZooKeeper，是否可以实现分布式锁？
published: true
category: redis
---

## 0.概要

几个方面：

* 分布式锁**简介**
	* **作用**：分布式锁，有什么用
	* **使用**：基本使用过程
* Redis 实现分布式锁

## 1.分布式锁简介

分布式锁简介，从 3 方面进行：

1. **作用**：分布式锁，有什么用？
1. **使用**：分布式锁，如何使用？
1. **实现**：分布式锁，几种典型的实现方式

### 1.1.作用 & 典型用法

**作用**：`分布式场景`下，出现`竞争资源`时，为了保证`有序获取资源`，需要依赖「**分布式锁**」。

**使用**：使用分布式锁的典型步骤

1. **查询**：锁是否已经被占用
1. **获取**：获取锁
1. **处理**：处理竞争资源
1. **释放**：释放锁，允许其他进程再次获取锁

分布式锁，典型使用过程：

![](/images/redis/distributed-lock-usage-demo.png)

分布式锁的要求：

1. **高可用**：`高可用`的获取锁
1. **高性能**：`高性能`的获取锁
1. **锁失效机制**：避免`死锁`
1. **可重入**：对于同一个身份，获取锁之后，可以再次成功获取锁
1. **阻塞锁**：和ReentrantLock一样支持`lock`和`trylock`以及`tryLock(long timeOut)`，如果没有获得锁，则，可以等待一段时间
1. **公平锁**：按照请求`加锁的顺序`获得锁，非公平锁就相反是无序的

一个**通用问题**：

> **锁自动释放问题**（分布式锁的`安全性问题`）：锁失效机制，避免死锁，同时，会引入「进程阻塞」，**锁超时自动释放**的问题，`进程恢复后`，已经失去了锁；

上面「分布式锁的安全性问题」，业界讨论非常多，当前**无法完全避免**，只能**依赖「业务逻辑」**上，做最终`兜底逻辑`，DB 持久化之前，进行好最后的控制。

几种`典型原因`，都会造成上述分布式锁的安全性问题：

1. GC 停顿，分布式锁自动释放
1. 时钟跳跃，设置的过期时间非真实时间，分布式锁自动释放
1. 网络延迟

更多细节，参考：[https://juejin.im/post/5bbb0d8df265da0abd3533a5](https://juejin.im/post/5bbb0d8df265da0abd3533a5)

### 1.2.分布式锁，具体实现

分布式锁，几种**典型实现**：

1. **基于数据库**：一个表格，增加唯一性索引约束
1. **基于 Redis 的实现方式**：通过 SETNX 创建 key 获取锁，依赖 EXPIRE 设置锁的自动失效时间
1. **基于 Zookeeper 的实现方式**


#### 1.2.1.基于数据库，实现分布式锁

**基于数据库**：一个`表格`，增加`唯一性索引`约束

**步骤**：

1. 查询：查询 key 的记录是否存在
1. 获取：增加一条 key 的记录，增加成功
1. 处理：增加 key 成功后，表示已经获取锁，此时，可以独占处理竞争资源
1. 释放：删除 key 的记录，释放锁

**优点**：

* 简单：依赖数据库即可，实现简单

**缺点**：

1. 性能，依赖数据库的读写性能：较差，数据库中，增加、删除一条记录，一般在 5 ms 以上
1. 可用性，依赖数据库的可用性：需要数据库的主备集群
1. 锁失效机制：需要增加字段，标明锁失效时间，一旦进程没有释放锁，其他进程根据记录的锁失效时间，可以重新获取锁
1. 可重入：需要增加字段，记录当前进程的身份（IP 以及进程、线程标识），同一个身份，可以获取同一把锁
1. 其他：实现过程中，会遇到各种问题，为了解决这些问题，实现方式，会越来越复杂；同时，数据库方式的主要缺点在「性能」上，一般 5 ms 以上

#### 1.2.2.基于 Redis 的实现分布式锁

**基于 Redis** 的实现方式：通过 `SETNX` 创建 key 获取锁，依赖 `EXPIRE` 设置锁的**自动失效时间**

**几种实现**：查询 GET，获取 SET，释放 DEL，死锁 依赖 key 的过期机制.

1. `2.6.12 版本之前`（2012年11 月），需要使用 `MULTI` + `EXEC` 封装 Redis 事务，`SETNX key `+ `EXPIRE key` 设置失效时间
1. `2.6.12 版本后`，直接使用 `SET key NX PX timeout` 即可.


Redis 的**主从结构**，**过期 key** 的`读取方式`：

1. `3.2 版本之前`（2015年 8月），依赖 **TTL 查询 key 是否存在**（结果 > 0 表示存在），因为 Redis 的 master 和 slave 节点，数据读取不一致，过期 key 在 slave 上，仍能读取到
1. `3.2 版本之后`，完全依赖 **GET 即可查询 key 是否存在**

**几个常见问题**：

1. **问题 A**：`命令的原子性`（SET + EXPIRE），在 `Redis 2.6.2` 之后版本，使用 `SET key NX PX timeout` 一个命令，即可解决
1. **问题 B**：Redis 的 master-slave 结构（主从结构），主从同步是异步复制，潜在的数据不一致，极端情况下，从 slave 进行的查询 GET 请求会出现数据不一致，建议采用 Redlock 算法（多 master 冗余 + 过半投票策略）

优点：

1. **性能**：非常高效，锁获取性能在 1ms 以下
1. **锁失效机制**：key 的自动过期机制，原生支持锁失效，避免死锁

缺点：

* **可用性**：集群`主从同步`，是`异步复制`，master 节点写入 key 后失败，slave 升级为 master 后，可能丢失了 key，导致锁丢失；
	* **解决办法**，在 Redis 之外，使用 `多 master 冗余` + 外部实现`过半投票`策略（**Redlock** 算法）

#### 1.2.3.基于 ZooKeeper 的实现

基于 Zookeeper 的实现方式：

**几种实现**：临时节点，跟 client 的连接自动绑定，client 失去连接，会自动

1. **临时节点**：创建临时节点，`创建成功`，表示`获取锁`
1. **临时顺序节点**：创建临时顺序节点，查询其`序号是否最小`，如果`最小`，则`获取锁`；如果`不是最小序号`，则，可以 `watch 比前驱节点`的删除动作。

几个常见问题：

* 如何实现「**读写锁**」？创建「`临时顺序节点`」，读锁和写锁的**前缀不同**，会单独整理一篇 blog.

优点：

1. **高可用**：ZK 采用 ZAB 协议，`2PC` **过半投票确认**，保证 leader 切换过程中，临时节点仍存在
1. **高性能**：内存中存储，读写性能 `1ms` 以下
1. **阻塞锁**：依赖临时顺序节点，可以实现阻塞锁
1. **公平锁**：根据加锁顺序，依次获取锁

缺点：

* **性能**：采用 2PC（广播、过半确认、提交），性能不如 Redis（但跟 Redis 的 `Redlock` 差不多）

## 2.Redis 实现分布式锁

分为 3 个方面进行：

1. Redis 分布式锁-**传统方案**
1. Redis 分布式锁-**高可用方案**（`Redlock` 算法）
1. 实践建议

### 2.1.Redis 分布式锁-传统方案

几个方面：Redis 实现分布式锁，**传统方案**：

1. `2.6.12` 版本之前（2012年11 月），需要使用 `MULTI` + `EXEC` 封装 Redis 事务，`SETNX key` + `EXPIRE key` 设置失效时间
1. `2.6.12` 版本后，直接使用 `SET key NX PX timeout` 即可.

针对 Redis 主从结构，Slave 上仍可以读取到「过期 key」的缺陷：

1. `3.2 版本`之前（2015年 8月），依赖 **TTL 查询 key 是否存在**（`结果 > 0` 表示存在），因为 Redis 的 master 和 slave 节点，数据读取不一致，过期 key 在 slave 上，仍能读取到
1. `3.2 版本`之后，完全依赖 **GET 即可查询 key 是否存在**

具体资料：

* SET 命令：`SET key NX PX milliseconds`
	* [https://redis.io/commands/set](https://redis.io/commands/set)
	* 从 `Redis 2.6.12`，开始支持 `NX PX` 等选项
* `SETNX` 命令：**SET** if **N**ot e**X**ists，`MULTI` + `SETNX` + `Expire` + `EXEC`
	* [https://redis.io/commands/setnx](https://redis.io/commands/setnx)
	* [https://redis.io/commands/expire](https://redis.io/commands/expire)
	* [https://redis.io/commands/multi](https://redis.io/commands/multi)
	* [https://redis.io/commands/exec](https://redis.io/commands/exec)

历史演进：

1. Redis 2.6.2 之前，SET 命令 + EXPIRE 命令 （2012 年 11 月之前）
1. Redis 2.6 之后，单独的 SET 命令，SET key NX PX milliseconds 获取分布式锁
1. Redis 3.2 修正 主从节点之间，过期 key 的读取一致性（2015 年之后）


### 2.2.Redis 分布式锁-高可用方案（Redlock 算法）

**Redlock 算法**，本质：

> `多 master 冗余` + `过半投票`策略

Redlock 算法，典型步骤：

1. 获取机器的当前时间：startTime
1. client 向 `N` 个 `master` 节点，异步发送「**加锁请求**」，并设置超时时间（应小于锁自动释放时间）
1. 当 client 获取 `N/2 + 1` 个 `master` 节点的「**加锁成功**」请求后，即，表示「**获取锁成功**」；否则，向「**所有的 master 节点**」发送「**解锁请求**」进行解锁。

Think：

* `多 master 冗余` + `过半投票`策略，获取锁失败时，向「**所有的 master 节点**」发送「**释放锁的请求**」，是否会导致「其他进程」加锁成功后，锁也被释放。
* Re：这个地方有个细节，「**加锁时**」在设置的 key 上，**设置**了只有当前 client 知道的 **value 值（版本值）**，释放锁时，会根据此，进行**版本验证后**，**再释放锁**，因此，向「所有的 master 节点」发送「释放锁的请求」，不会有问题。

### 2.3.实践建议

实践过程中，一般使用 **Redis 分布式锁（传统方案）**，针对 Redis 集群主从之间`异步同步`引发的`主从切换`时，分布式锁失效的情况，一般建议：

* 在「**资源处理**」阶段，增加一个「**兜底策略**」：依赖 `DB 层`的 `CAS 乐观锁机制`，进行竞争资源的处理。

## 3.ZooKeeper 分布式锁

几个方面：

1. 写锁
1. 读写锁

`Curator` 是一个 jar 包，封装了 Zookeeper底层的 API，方便对 ZooKeeper 操作，并且其封装了「分布式锁」的功能，这样就无需我们自己实现了。

Curator 中提供的锁：

1. `InterProcessMutex` ：可重入锁，写锁
1. `InterProcessSemaphoreMutex`：不可重入锁，写锁
1. `InterProcessReadWriteLock`：可重入锁中，实现了读写锁，机制基本类似，都是**顺序临时节点**

### 3.1.写锁（可重入锁）InterProcessMutex

InterProcessMutex 是 Curator 实现的可重入锁，使用示例：

```
public class TestOfDistributeLock {
​
    public static void main(String[] args) {
        CuratorFramework client = null;
        String lockPath = null;
​
        // 创建「可重入锁」(写锁)
        InterProcessMutex lock = new InterProcessMutex(client, lockPath);
​
        try {
            // a. 获取锁
            lock.acquire();
​
            // b. 获取锁成功, 进行业务处理
            // ...
        } finally {
            // c. 释放锁
            lock.release();
        }
    }
}
```

关于 ZooKeeper 实现的可重入锁 InterProcessMutex ：

1. 使用 acquire 加锁
1. 使用 release 释放锁

获取锁，**加锁的具体流程**：

1. 首先进行可重入的判定: 这里的可重入锁记录在ConcurrentMap<Thread, LockData> threadData这个Map里面，如果threadData.get(currentThread)是有值的那么就证明是可重入锁，然后记录就会加1。我们之前的Mysql其实也可以通过这种方法去优化，可以不需要count字段的值，将这个维护在本地可以提高性能。
1. 然后在我们的资源目录下创建一个节点:比如这里创建一个/0000000002这个节点，这个节点需要设置为EPHEMERAL_SEQUENTIAL也就是临时节点并且有序。
1. 获取当前目录下所有子节点，判断自己的节点是否位于子节点第一个。
1. 如果是第一个，则获取到锁，那么可以返回。
1. 如果不是第一个，则证明前面已经有人获取到锁了，那么需要获取自己节点的前一个节点。/0000000002的前一个节点是/0000000001，我们获取到这个节点之后，再上面注册Watcher(这里的watcher其实调用的是object.notifyAll(),用来解除阻塞)。
1. object.wait(timeout)或object.wait():进行阻塞等待这里和我们第5步的watcher相对应。

**解锁的具体流程**:

1. 首先进行可重入锁的判定：如果有可重入锁只需要次数减1即可，减1之后加锁次数为0的话继续下面步骤，不为0直接返回。
1. 删除当前节点。
1. 删除threadDataMap里面的可重入锁的数据。

**ZK 的「互斥锁」**，本质：

1. **获取锁**：创建「**临时顺序节点**」，并查询是否为「`最小序号`」
	1. 如果`是`，则，`获取锁`；
	1. 否则，监听（watch）「`邻近的前驱节点`」的节点删除动作；
1. **释放锁**：`删除`自己创建的「`临时顺序节点`」

ZooKeeper 另一种实现**互斥锁的方式**：

* 多进程，竞争创建「**临时节点**」，创建失败的进程 watch 这个「**临时节点**」

### 3.2.读写锁

几个方面：

1. 读写锁的**含义**：需要满足哪些语义
1. ZooKeeper 中的读写锁，是**如何实现**的

读写锁的含义：

1. **写锁**：互斥，同一时刻，只有一个进程，持有写锁
1. **读锁**：共享，同一时刻，可以多个进程，持有读锁
1. 综合：
	1. 所有的`写锁`都失效时，可以`加读锁`
	1. 所有的`读锁`都失效时，可以`加写锁`

围绕「**读写锁**」单独整理一篇 blog.

## 4.参考资料

* [https://redis.io/topics/distlock](https://redis.io/topics/distlock)
* [Redis 发布版本记录](http://download.redis.io/releases/)
* [Redis 各版本新增特性汇总](http://gad.qq.com/article/detail/29299)
* [https://github.com/antirez/redis/releases](https://github.com/antirez/redis/releases) 
* [分布式锁的讨论](https://blog.csdn.net/wuliu_forever/article/details/78590254)
* [https://juejin.im/post/5bbb0d8df265da0abd3533a5](https://juejin.im/post/5bbb0d8df265da0abd3533a5)
* [分布式锁的实现原理](https://www.jianshu.com/p/6618471f6e75)
* [http://ifeve.com/zookeeper-lock/](http://ifeve.com/zookeeper-lock/)
* [http://ifeve.com/redis-lock/](http://ifeve.com/redis-lock/)



































[NingG]:    http://ningg.github.com  "NingG"