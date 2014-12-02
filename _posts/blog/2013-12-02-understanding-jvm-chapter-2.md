---
layout: post
title: Understanding the JVM——内存区域
description: JVM运行时，其中占用的内存分为几块？用于存放什么东西？与GC有什么关系吗？
category: jvm
---


##开篇随便说

C++编写的程序，编写的程序上，要为每个对象分派内存、回收内存；而Java编写的程序，JVM负责进行内存回收（又称垃圾回收，Garbage Collector，简称GC），不过JVM有可能出现内存泄漏和溢出方面的问题。

上面提到JVM对其分配的内存进行GC，那就涉及几个问题：

* JVM内存分为几个区域？
* 每个区域存储的内容？
* 每个区域可能引发的问题？

最终，需要回答一个问题：

* JVM获取的内存空间，为什么要分区域？每个区域什么用途？没有行不行？

##JVM运行时数据区

先来一张图：

![](/images/understanding-jvm/internal-arch-of-jvm.gif)

JVM上运行一个program时，要存储很多东西：字节码文件、实例化的类对象、方法的传入参数、方法的返回值、局部变量、运算的中间结果等。JVM将这些需要存储的内容，以`runtime data areas`（运行时数据区）的形式进行划分。The Java Virtual Machine Specification（Java SE 8 Edition）中指出runtime data areas，具体包括：

* PC(Program Counter) Register
* JVM Stack
* Native Method Stack
* Java Heap
* Method Area
* Run-time Constant Pool

整体上，这些data areas可以划分为两类：thread私有空间和thread共享空间，具体如下图：

![](/images/understanding-jvm/runtime-data-areas.png)


###PC(Program Counter) Register

简单的说，PC Register是字节码文件的行号指示器，标识当前执行的字节码位置；具体：如果正在执行Java method，则计数器记录的是正在执行的VM字节码指令的地址；如果正在执行native method，则计数器为空（Undefined）。

**PC Register**为什么是thread私有的？CPU资源分配的最小单元是thread，多个thread轮流占用CPU的内核，这样thread的换入换出时，要求保存每个thread的执行状态，这样就无法共用PC Register。


###JVM Stack







###Native Method Stack






###Java Heap






###Method Area






###Run-time Constant Pool














###PC Register





##参考来源

* [深入理解Java虚拟机][深入理解Java虚拟机]
* [Inside the Java Virtual Machine(2nd Edition)][Inside the Java Virtual Machine(2nd Edition)]




##闲谈

看看JVM最具权威的官方文档（[Java Language and Virtual Machine Specifications][Java Language and Virtual Machine Specifications]）吧，这是所有JVM相关信息的最初来源，其他绝大多数知识都是对其的理解和重新表述，当然不同的人的理解也有误差。



[Java Language and Virtual Machine Specifications]:			http://docs.oracle.com/javase/specs/
[深入理解Java虚拟机]:										http://book.douban.com/subject/24722612/
[NingG]:    												http://ningg.github.com  "NingG"
[Inside the Java Virtual Machine(2nd Edition)]:							http://www.artima.com/insidejvm/blurb.html