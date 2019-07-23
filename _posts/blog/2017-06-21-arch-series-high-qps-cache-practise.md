---
layout: post
title: 实践系列：高并发的缓存实践
description: 高并发场景下，缓存体系如何设计？
category: 技术架构
---



## 0.背景

在沟通「商品首页」展示时，如何保证高性能、高可用，具体来说，3 个方面需要注意：

1.  本地缓存
2.  分布式缓存
3.  冷数据存储方案：未命中缓存的冷数据，数据库并发压力

## 1.高并发的缓存实践

具体来说，围绕下面 3 项，逐个讨论：

1.  本地缓存
2.  分布式缓存
3.  冷数据存储方案：未命中缓存的冷数据，数据库并发压力

### 1.1.本地缓存

本地缓存，一般采用 Guava，此时，需要考虑 2 个问题：

1.  数据一致性：本地缓存，会导致数据一致性减弱
2.  线上服务的影响：大量本地缓存，会导致「堆内存占用」过多，并且导致 gc，会影响线上服务的执行

业界解决方案：

*   TODO

Think：

1.  JVM 上，本地内存的缓存，分级？
2.  JVM 上，如何使用「直接内存」？直接内存是否存在安全性问题？（多进程都访问）

关于堆外内存：

1.  JDK 1.8 默认的「堆外内存大小」跟「堆大小」一致，<span style="color: rgb(47, 47, 47)">如果没设置-XX:MaxDirectMemorySize，则默认与-Xmx参数值相同</span>

2.  堆外内存：

    1.  **是什么？**JVM 进程占用的「直接内存」，非堆内存
       1.  疑问：这个内存，是 JVM 进程独占的吗？是否有其他进程访问的风险？
       2.  确定：这个内存本质是受 OS 管理的，其他进程可能会访问到
       3.  「堆外内存」：JVM 在直接内存中，开启的一块内存区域
           1.  利用 unsafe 包内工具，直接对物理内存进行的读写
           2.  是「byte 数组」
           3.  Java 对象不能直接保存在里面，需要经过「序列化/反序列化」实现存取
    2.  **有什么用？**
        1.  **减少 GC 次数**：「堆外内存」的占用，不需要
        2.  **减少复制次数**：「堆内数据」发送到远端时（网络 IO or 文件 IO），会先复制到「直接内存」再发送，使用「堆外内存」节省了这一步
    3.  **适用场景**：
        1.  长期存在和能复用的场景：「堆外内存」的分配和回收，也是需要成本的
        2.  注重稳定性的场景：「堆外内存」能有效避免因 GC 导致的暂停
        3.  适合简单对象存储：内部存储的都是「byte 数组」，Java 对象的读写，需要经过「序列化/反序列化」，复杂对象的「序列化/反序列化」需要特别注意
        4.  适合注重 IO 效率的场景：用「堆外内存」读写文件，效率高
    4.  **有什么问题？**
        1.  **内存泄露**：对外内存如果泄露，很难排查
        2.  **不适合存储复杂对象**：内部存储的都是「byte 数组」，Java 对象的读写，需要经过「序列化/反序列化」，复杂对象的「序列化/反序列化」需要特别注意
    5.  **如何分配对外内存？**
        1.  分配：本质 unsafe 包，直接操作物理内存，都要转换为「字节数组」
        2.  复杂的 Java 对象，都需要手动进行「序列化/反序列化」，因此，复杂对象不建议存储在「对外内存」
    6.  **如何实现「堆外内存」的读写？**
        1.  有开源方案，实现「堆外内存」的读写

### 1.2.分布式缓存

分布式缓存，存在几个问题：

1.  分布式缓存存储不足时，如何处理？只有 LRU 清理缓存这一种策略？
2.  分布式缓存，Redis 单实例，能支持最大多少并发连接数？QPS 又是多大？

**实践中，典型问题**：

*   Redis 单实例的并发连接数，以及如何设置？默认 1w，可以设置为 1~10w，底层使用 IO 多路复用
*   QPS 如何衡量，跟「并发连接数」之间，是什么关系？1kw

**关联资料**：

*   Redis 单机的并发连接数：默认设置为 1w，可以调整 1~10w 之间
    * 参考资料：
    	*   [redis客户端连接，最大连接数查询与设置](https://blog.51cto.com/jschu/1851998 "redis客户端连接，最大连接数查询与设置")
       *   [由Redis客户端连接数大小说开去](https://www.jianshu.com/p/549d4555ae16 "由Redis客户端连接数大小说开去")
*   Redis 单机的 QPS 峰值：5w 左右

**分布式缓存的：雪崩、击穿、并发（并发控制）**

*   [https://github.com/doocs/advanced-java/blob/master/docs/high-concurrency/redis-caching-avalanche-and-caching-penetration.md](https://github.com/doocs/advanced-java/blob/master/docs/high-concurrency/redis-caching-avalanche-and-caching-penetration.md "https://github.com/doocs/advanced-java/blob/master/docs/high-concurrency/redis-caching-avalanche-and-caching-penetration.md")
*   [http://ningg.top/computer-basic-theory-cache-intro-and-best-practice/](http://ningg.top/computer-basic-theory-cache-intro-and-best-practice/ "http://ningg.top/computer-basic-theory-cache-intro-and-best-practice/")
*   [https://blog.51cto.com/13904503/2165627](https://blog.51cto.com/13904503/2165627 "https://blog.51cto.com/13904503/2165627")

Note：

*   **并发**：大量请求，集中到达，读取同一个 key，都未命中缓存，都去 DB 中查询，导致 DB 压力激增
*   **并发控制**：本质就是「互斥锁」例如 Redis 的 setnx，获取互斥锁的，其他请求会「本地自旋」查询「缓存」
*   **谨慎使用**：针对「热点数据」需要精细分析业务，然后，谨慎使用「缓存的并发控制」

### 1.3.冷热库存储

采用 MySQL 存储数据时，在请求量过大，并且缓存空间有限的情况下，如何考虑「冷数据」的处理：

* 假设首页的 QPS 20w，每次 50 个商品，缓存命中率 90%

* 在不使用 redis 的 mget（multiGet）

可以使用 NoSQL 方案，例如阿里的 Tair，内存存储，并发效率更高，具体还需要进一步实践。

## 2.参考资料

*   基础原理系列：缓存通用原理和实践 [http://ningg.top/computer-basic-theory-cache-intro-and-best-practice/](http://ningg.top/computer-basic-theory-cache-intro-and-best-practice/ "http://ningg.top/computer-basic-theory-cache-intro-and-best-practice/")
*   Spring 源码：Spring Cache**  **[http://ningg.top/spring-framework-series-spring-cache/](http://ningg.top/spring-framework-series-spring-cache/ "http://ningg.top/spring-framework-series-spring-cache/")
*   [常见性能优化策略的总结](https://tech.meituan.com/2016/12/02/performance-tunning.html "常见性能优化策略的总结")
*   聊聊轻量级本地缓存设计：[https://toutiao.io/posts/56yqwd/preview](https://toutiao.io/posts/56yqwd/preview "https://toutiao.io/posts/56yqwd/preview")
*   如何优雅的设计和使用缓存？（推荐）：[https://blog.51cto.com/13904503/2165627](https://blog.51cto.com/13904503/2165627 "https://blog.51cto.com/13904503/2165627")
*   Java缓存深入理解：[https://cloud.tencent.com/developer/article/1028722](https://cloud.tencent.com/developer/article/1028722 "https://cloud.tencent.com/developer/article/1028722")
*   本地缓存（Java实现之理论篇）：[https://www.jianshu.com/p/866e8455e769](https://www.jianshu.com/p/866e8455e769 "https://www.jianshu.com/p/866e8455e769")
*   缓存那些事：[https://tech.meituan.com/2017/03/17/cache-about.html](https://tech.meituan.com/2017/03/17/cache-about.html "https://tech.meituan.com/2017/03/17/cache-about.html")
*   [https://github.com/ningg/personal](https://github.com/ningg/personal "https://github.com/ningg/personal")
*   JVM 堆外内存：
    *   从0到1起步-跟我进入堆外内存的奇妙世界：[https://www.jianshu.com/p/50be08b54bee](https://www.jianshu.com/p/50be08b54bee "https://www.jianshu.com/p/50be08b54bee")
    *   关于JVM堆外内存的一切：[https://juejin.im/post/5be538fff265da611b57da10](https://juejin.im/post/5be538fff265da611b57da10 "https://juejin.im/post/5be538fff265da611b57da10")
    *   [http://mizhichashao.com/post/4](http://mizhichashao.com/post/4 "http://mizhichashao.com/post/4")
    *  [关于java中的本地缓存-总结概述](https://iamzhongyong.iteye.com/blog/2038982 "关于java中的本地缓存-总结概述")
*   缓存的 3 种模式：[缓存更新的套路](https://coolshell.cn/articles/17416.html "缓存更新的套路")
*   Redis 单机的并发连接数：默认设置为 1w，可以调整 1~10w 之间
    *   参考资料：
       *   [redis客户端连接，最大连接数查询与设置](https://blog.51cto.com/jschu/1851998 "redis客户端连接，最大连接数查询与设置")
		*   [由Redis客户端连接数大小说开去](https://www.jianshu.com/p/549d4555ae16 "由Redis客户端连接数大小说开去")
*   Redis 单机的 QPS 峰值：2 kw 左右























[NingG]:    http://ningg.github.com  "NingG"





