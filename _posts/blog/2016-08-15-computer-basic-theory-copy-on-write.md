---
layout: post
title: 基础原理系列：写时复制（copy on write）
description: 子进程完全复制一份主进程的内存，底层采用写时复制策略，优化复制性能
published: true
category: 基础原理
---


## 1. 目标

疑问：

* Redis 在生成 RDB 快照文件时，是否会终止对外服务？
* 快照，是精确的？模糊的？

![](/images/computer-basic-theory/redis-multi-process-demo.png)

典型问题：

* 终止服务：生成快照的时候，耗费大量的磁盘 IO，是否会终止服务？
* 快照模糊：生成的快照是精确到指定时刻的内存数据，还是在某个时间段内的内存数据？

> 关键点：在`继续提供服务`的情况下，如何保证`快照是精确的`？

## 2. 思路演进

如果要达到：保证`快照是精确`的，同时`继续提供服务`，怎么做？
 
思路 1：继续提供服务之前，复制一份内存数据，用于生成快照。

![](/images/computer-basic-theory/fork-and-copy.png)

 
思路 2：继续提供服务，只有当有人修改当前内存数据时，才去复制一份原始内存内容，用于生成快照。（内存复制的时间，向后推迟）

![](/images/computer-basic-theory/fork-and-copy-until-edit.png)

思路 3：继续提供服务，只有当有人修改当前内存数据时，才去复制被修改的内存页，用于生成快照。（内存复制的时间，向后推迟；内存粒度，拆解更细）

![](/images/computer-basic-theory/fork-and-copy-small-unit-until-edit.png)
 
上面就是 Copy-On-Write 写时复制技术的思路。

## 3. Copy-On-Write 简介

Copy-On-Write （写时复制），是一个偷懒的艺术，能够达到内存共享、节省内存的效果。

> 子进程，只有在父进程发生写动作时，才真正去分配物理空间，并复制内存数据。

细节参考：[Linux写时拷贝技术(copy-on-write)](http://www.cnblogs.com/biyeymyhjob/archive/2012/07/20/2601655.html)

## 4. Redis 中 RDB 过程分析

Redis 中，执行 BGSAVE 命令，来生成 RDB 文件时，本质就是调用了 Linux 的系统调用 fork() 命令，Linux 下 fork() 系统调用，实现了 copy-on-write 写时复制。

## 5. 补充

### 5.1. 快照机制的意义

快照机制的作用，要点：

1. 磁盘数据：快照、日志，用于恢复现场（内存数据）
1. 内存数据：程序运行的现场

### 5.2. Redis 背景知识

Redis 相关的背景知识：

1. Redis 是单进程单线程对外提供服务的，
1. Redis 在生成 RDB 快照文件时，有 2 种选择，命令： SAVE 和 BGSAVE 命令
1. Redis 可以配置自动生成快照，在配置文件中配置即可，基本语意：执行多少次写操作，触发一次 BGSAVE
1. Redis 在使用 BGSAVE 生成 RDB 快照时，仍会对外提供服务，因为使用了 Copy-On-Write（写时复制）技术
1. Redis 的 RDB 快照是精确的，精确到执行时刻的状态，因为使用了 Copy-On-Write 技术

### 5.3. Linux 内存模型

Linux 内存管理模型，常见几种：

1. 分段模型
1. 分页模型：大多数 OS，默认 1 个 Page 4KB，Page 大小可设置为 2M、4M，但是对内存的换入换出不太友好。
1. 分段+分页模型

细节参考：

* [Linux 内存模型](http://www.ibm.com/developerworks/cn/linux/l-memmod/)
* [Memory Page Size](http://stackoverflow.com/q/16976544)

## 6. 参考来源

1. [Redis Persistence](http://redis.io/topics/persistence)，Redis 官网
1. [C++ 中，实现写时复制的细节](http://blog.csdn.net/haoel/article/details/24077)
1. [写时复制的细节（有图）](http://www.cnblogs.com/biyeymyhjob/archive/2012/07/20/2601655.html)
1. [Linux 内存模型](http://www.ibm.com/developerworks/cn/linux/l-memmod/)
























[NingG]:    http://ningg.github.com  "NingG"










