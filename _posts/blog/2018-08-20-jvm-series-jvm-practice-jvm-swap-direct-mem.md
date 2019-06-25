---
layout: post
title: JVM 实践：直接内存和 swap
description: gc 耗时增加，有一个典型原因就是 swap 虚拟内存生效，堆外内存被交换到了磁盘上
category: jvm
---


JVM 的 gc 耗时增加，一般有下面几个原因：

1. 垃圾收集器的选取
2. 参数配置不合理：包含空间大小，以及垃圾收集器退化等
3. swap 虚拟内存生效：堆外内存占用空间过大，导致数据被交换到磁盘上


VM 运行时，占用的内存空间，一般涵盖几个方面：

1. 运行时数据区：
	1. 堆
	1. 方法区：JDK 1.8 开始，移入了「直接内存」元数据区
	1. JVM 栈：gc 不会进行回收
	1. 本地方法栈
	1. PC 程序寄存器
1. 直接内存：NIO 的 buffer、unsafe 包直接操作内存等

如果服务器出现大量的 swap 交换，需要排查原因，以及确定解决办法。

几个典型问题：

* swap 可以禁用吗？如何操作？
* JVM 不在 gc 范围内的内存，都有哪些？哪些参数可以控制呢？


具体几个 JVM gc 耗时增加，跟 swap 相关的实际 case，找时间深入学习下：

* [swap.used.percent占比较高异常排查](https://blog.csdn.net/cweeyii/article/details/72886167)
* [Java堆外内存增长问题排查Case](https://coldwalker.com/2018/08//troubleshooter_native_memory_increase/)
* [【JVM】内存和SWAP问题](https://www.cnblogs.com/wangzhongqiu/p/10868562.html)





[NingG]:    http://ningg.github.com  "NingG"
