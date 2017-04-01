---
layout: post
title: Understanding the JVM：内存区域与内存溢出异常
description: JVM运行时，其中占用的内存分为几块？用于存放什么东西？与GC有什么关系吗？如何创建对象实例？对象实例包含哪些信息？如何获取对象实例？
category: jvm
---


## 开篇随便说

C++编写的程序，编写的程序上，要为每个对象分派内存、回收内存；而Java编写的程序，JVM负责进行内存回收（又称垃圾回收，Garbage Collector，简称GC），不过JVM有可能出现内存泄漏和溢出方面的问题。

> **内存泄漏**：不再使用的对象，一直占用内存空间，无法回收。

上面提到JVM对其分配的内存进行GC，那就涉及几个问题：

1. JVM内存分为几个区域？
1. 每个区域存储的内容？
1. 每个区域可能引发的问题？

最终，需要回答一个问题：

> JVM获取的内存空间：
> 
> 1. 为什么要分区域？
> 2. 每个区域什么用途？没有行不行？

## JVM运行时数据区

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


### PC(Program Counter) Register，程序计数器

简单的说，PC Register是字节码文件的行号指示器，标识当前执行的字节码位置；具体：如果正在执行Java method，则计数器记录的是正在执行的VM字节码指令的地址；如果正在执行native method，则计数器为空（Undefined）。需要说明的是，在某一指定时刻，一个thread只能在执行一个method，即thread的current method只有一个，PC Register就是指向这一method的字节码。

**PC Register**为什么是thread私有的？CPU资源分配的最小单元是thread，多个thread轮流占用CPU的内核，这样thread的换入换出时，要求保存每个thread的执行状态，这样就无法共用PC Register。




### JVM Stack，Java虚拟机栈

JVM Stack，Java Virtual Machine Stack，是thread私有的，其用于存储frames（下文会详细讲解）。其中frame是method在runtime时的基本结构，**其用于存储：局部变量表、操作数栈、动态链接、方法出口等信息**。*（这些都是什么信息？）*Method从调用到执行完成，对应frame的入stack和出stack动作。*（请尽快整理JVM stack中存储的frame是什么东西，因为JVM specification中frame的介绍就是安排在JVM stack之后的）*

**notes(ningg)**：普通程序员，将JVM占用的内存空间，简单划分为：堆、栈；这是粗粒度的简单划分，实际要复杂的多；而，普通程序员所说的“栈”就是JVM stack，特别是其中的局部变量表。

局部变量表中存放的内容可能有：各种基本类型数据、对象引用（不是对象本身）、returnAddress类型（指向一条字节码指令的地址）。

针对JVM Stack可能出现两类错误：

* 当需要的JVM stack深度大于VM所允许的最大深度时，StackOverflowError；
* 若JVM stack设置为可动态扩展，则当扩展时，若无法申请到足够的内存，则OutOfMemoryError；




### Native Method Stack，本地方法栈


启动一个JVM process，其中会用到native method，此时，存储native method的执行状态，就需要一个native method stack，这与JVM stack类似，有一点差异：

* JVM stack为执行java method（字节码）服务；
* native method stack为指向native method服务；

JVM specification中并没有对native method stack的实现细节做出规定，无论是实现方式、数据结构都可以自由发挥；设置Sun HotSpot VM 将native method stack与JVM stack合二为一。与Native method stack相关的Error也有两种：StackOverflowError和OutOfMemoryError。


### Java Heap，Java堆

存放内容：对象实例、数组。实际上，最近JIT编译器技术，例如栈上分配、标量替换等技术导致并不是所有的对象实例和数组都必须在java heap中分配空间。Java Heap是GC的重点区域，从GC角度来看：当前流行分代收集算法，Java heap可以细分为：新生到、老年代，更细致一点，有Eden区、From Survivor区、To Survivor区；从内存分配角度，thread共享的Java Heap可以划分出许多thread私有的分配缓冲区（Thread Local Allocation Buffer，TLAB），无论如何划分，目的只有一个：更好的回收内存、更好的分配内存。

通过两个参数可以设定Java Heap大小：`-Xmx\-Xms`。当Java Heap空间已满，并且无法扩展时，会抛出OutOfMemoryError。


### Method Area，方法区


Method Area，称作“方法区”，**其用于存储：类信息、常量、静态变量、JIT编译器编译后的代码等**。实际上，JVM specification将Method Area看作存储compiled code的区域，其中还将method area表述为java heap的一个逻辑部分，实际上HotSpot VM的实现中，将Method Aera称为java heap的“永久代”（Permanent Generation），不过Method Area与Permanent Generation并不等价，只是HotSpot利用Permanent Generation的方式来实现Method Area而已，利用Permanent Generation方式来实现Mehtod，并不完美，容易遇到内存溢出（OutOfMemoryError）错误；目前JDK 1.7 中，已经将字符串常量池从Permanent Generation中移除。



### Run-time Constant Pool



Runtime Constant Pool是Method area的一部分。需要简要说明一下class文件包含的内容：类的版本、字段、方法、接口等描述信息，还有常量池（Constant Pool Table）。其中，常量池，用于存放编译期产生的各种字面常量和符号引用。*（前面什么意思？）*


> **notes(ningg)**：在JDK 1.7、JDK 1.8中Runtime Constant Pool还是Method area的一部分吗？
> 
> 1. 不是的，JDK 1.7 开始，常量池迁移到了`直接内存`中；
> 2. JDK 1.8 开始，`永久代`的概念也去掉了，`方法区`，从`永久代`迁移到了`直接内存`；

特别提一下：class文件中常量池（Constant Pool Table）与运行时常量池（Runtime Constant Pool）的区别。执行程序的时候，会将class文件的constant pool table中内容存放到Runtime constant pool中，但runtime constant pool具有动态性，其中内容并不仅限于class文件的constant pool table，程序运行期间，可将新的常量放入池中，常见的比如String的intern()方法。


### Direct Memory，直接内存

Direct Memory，不是JVM runtime data areas的一部分，也不是JVM specification中定义的内存区域。但这一内存区域，也被频繁使用，也会导致OutOfMemoryError，因此，将Directory放到此处一并进行说明。

#### 常用场景

JDK 1.4 引入NIO（New Input/Output）类，引入基于通道（channel）和缓冲区（buffer）的I/O方式，可使用Navtive函数库直接分配堆外内存，然后通过java heap中的DirectByteBuffer对象作为这块内存的引用，进行操作。这一实现方式，可以避免Java Heap与Native Heap之间来回复制数据带来的性能损耗。


> Note：JVM GC 过程中，Full GC 时，会顺便清理一下`直接内存`的空间。

## 参考来源

* [深入理解Java虚拟机][深入理解Java虚拟机]
* [Inside the Java Virtual Machine(2nd Edition)][Inside the Java Virtual Machine(2nd Edition)]
* [Java Language and Virtual Machine Specifications][Java Language and Virtual Machine Specifications]


## 备注

> 上面提到的只是大致的JVM 内存区域划分情况，具体：对象是如何创建的、内存中如何分布、如何访问这个对象，需要进一步参考[深入理解Java虚拟机][深入理解Java虚拟机]的2.3 “HotSpot虚拟机对象探秘”章节。还有，书中每个章节的实战部分，需要用心去实践一下，理论要有，实际操作上：参数配置、问题定位与修正，这个能力是工作能力，也要有。

## 闲谈

看看JVM最具权威的官方文档（[Java Language and Virtual Machine Specifications][Java Language and Virtual Machine Specifications]）吧，这是所有JVM相关信息的最初来源，其他绝大多数知识都是对其的理解和重新表述，当然不同的人的理解也有误差。


> 预告：下一篇文章，介绍GC，大概想了一下，几个问题：如何确定对象可以被回收？如何进行回收？


[Java Language and Virtual Machine Specifications]:			http://docs.oracle.com/javase/specs/
[深入理解Java虚拟机]:										http://book.douban.com/subject/24722612/
[NingG]:    												http://ningg.github.com  "NingG"
[Inside the Java Virtual Machine(2nd Edition)]:							http://www.artima.com/insidejvm/blurb.html
[深入理解Java虚拟机 - 第二章、Java内存区域与内存溢出异常]:			http://github.thinkingbar.com/jvm-ii/







