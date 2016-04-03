---
layout: post
title: java中并发编程：concurrency
description: 现实应用中，遇到稍微复杂一点的问题，就需要进行多线程的编程，package：java.util.concurrent能辅助解决此问题
category: java
---

## 开篇推荐

> 推荐阅读：[Java Tutorials：Lesson-Concurrency][Java Tutorials：Lesson-Concurrency]


## 基本知识点

直接列重点吧，几点：

* JDK 5.0，新增了`java.util.concurrent` packages，是 high-level concurrency APIs；
* JDK 5.0之前版本中，也有实现并发编程的基本支持；



## java.util.concurrent


（todo：基本用法）

其核心为：Executor，屏蔽很多细节。





**疑问**：在flume的spooling directory source中，用法的含义？

	...
	while (!Thread.interrupted()) {
	...









## 附录

### processor & core

CPU为2个processor，每个prcessor可以有8个core；core是执行thread的基本单元；





### process & thread

process（进程）和thread（线程）之间的关系，如下：

* 一个process内部可以包含n个thread；
* 计算机资源：CPU和内存；*（CPU本质是多个core）*
* process：内存分配的最小单元，即，一个process内所有的thread共享内存空间；
* thread：CPU分配的最小单元，即，每个core在同一时刻，只能被一个thread占用；



__关于`process`，几点__：

* process（进程）就是通常所说的Program（程序）或者Application（应用）；
* 当然，Application通常可能由多个process构成，这些process之间相互协作；
* 基本所有的OS都支持进程间通信（IPC，Inter Process Communication），例如，pipes、sockets；
* IPC，不仅局限于同一个system内，也可以在不同的system之间；
* JVM（Java Virtual Machine）实例，通常就是一个process；
* `process`至少有一个`thread`；
* java application中可以利用`ProcessBuilder`来创建additional process；*（此次暂不讨论multiprocess application）*





__关于`thread`，几点__：

* Thread被成为`lightweight process`；
* `process`至少有一个`thread`，同一个`process`下的所有`thread`共享进程资源，包括：memory 和 open files；
* 创建`process`和`thread`时，都需要提供执行环境（系统资源），创建thread所需要的系统资源，远少于process；*（简单来说，创建process的开销大，倾向于创建Thread）*
* 
















## 参考来源

* [Java Tutorials：Lesson-Concurrency][Java Tutorials：Lesson-Concurrency]















[NingG]:									    http://ningg.github.com  "NingG"
[Java Tutorials：Lesson-Concurrency]:			http://docs.oracle.com/javase/tutorial/essential/concurrency/









