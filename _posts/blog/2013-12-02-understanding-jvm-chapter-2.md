---
layout: post
title: 内存区域与内存溢出异常——Understanding the JVM
description: JVM运行时，其中占用的内存分为几块？用于存放什么东西？与GC有什么关系吗？如何创建对象实例？对象实例包含哪些信息？如何获取对象实例？
category: jvm
---


## 开篇随便说

C++编写的程序，编写的程序上，要为每个对象分派内存、回收内存；而Java编写的程序，JVM负责进行内存回收（又称垃圾回收，Garbage Collector，简称GC），不过JVM有可能出现内存泄漏和溢出方面的问题*（对象是可达的，但是对象是无用的）*。

上面提到JVM对其分配的内存进行GC，那就涉及几个问题：

* JVM内存分为几个区域？
* 每个区域存储的内容？
* 每个区域可能引发的问题？

最终，需要回答一个问题：

* JVM获取的内存空间，为什么要分区域？每个区域什么用途？没有行不行？

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


**notes(ningg)**：在JDK 1.7、JDK 1.8中Runtime Constant Pool还是Method area的一部分吗？

特别提一下：class文件中常量池（Constant Pool Table）与运行时常量池（Runtime Constant Pool）的区别。执行程序的时候，会将class文件的constant pool table中内容存放到Runtime constant pool中，但runtime constant pool具有动态性，其中内容并不仅限于class文件的constant pool table，程序运行期间，可将新的常量放入池中，常见的比如String的intern()方法。


### Direct Memory，直接内存

Direct Memory，不是JVM runtime data areas的一部分，也不是JVM specification中定义的内存区域。但这一内存区域，也被频繁使用，也会导致OutOfMemoryError，因此，将Directory放到此处一并进行说明。

#### 常用场景

JDK 1.4 引入NIO（New Input/Output）类，引入基于通道（channel）和缓冲区（buffer）的I/O方式，可使用Navtive函数库直接分配堆外内存，然后通过java heap中的DirectByteBuffer对象作为这块内存的引用，进行操作。这一实现方式，可以避免Java Heap与Native Heap之间来回复制数据带来的性能损耗。




## 参考来源

* [深入理解Java虚拟机][深入理解Java虚拟机]
* [Inside the Java Virtual Machine(2nd Edition)][Inside the Java Virtual Machine(2nd Edition)]
* [Java Language and Virtual Machine Specifications][Java Language and Virtual Machine Specifications]


## 备注

> 上面提到的只是大致的JVM 内存区域划分情况，具体：对象是如何创建的、内存中如何分布、如何访问这个对象，需要进一步参考[深入理解Java虚拟机][深入理解Java虚拟机]的2.3 “HotSpot虚拟机对象探秘”章节。还有，书中每个章节的实战部分，需要用心去实践一下，理论要有，实际操作上：参数配置、问题定位与修正，这个能力是工作能力，也要有。


### 创建对象

在 Java 语言层面上，我们创建一个对象是如此简单：`ClassA intance = new ClassA();` 但是在虚拟机内部，其实经历了非常复杂的过程才完成了这一个程序语句。

* 虚拟机遇到一条 new 指令时，首先将去检查这个指令的参数是否能在**常量池中定位到一个类的引用**，并且检查这个符号引用代表的**类是否已经被加载、解析和初始化过**。如果没有，就得执行类的加载过程；
* 类加载检查过之后，**虚拟机就为这个新生对象分配内存**。目前有两种做法，使用哪种方式是由 GC 回收器是否带有压缩整理功能决定的:
	* **指针碰撞（Bump the Pointer）**：没用过的内存和用过的内存用一个指针划分（所以需要保证 java 堆中的内存是整理过的，一般情况是使用的 GC 回收器有 compact 过程），假如需要分配8个字节，指针就往空闲内存方向，挪8个字节；
	* **空闲列表（Free List）**：虚拟机维护一个列表，记录哪些内存是可用的，分配的时候从列表中遍历，找到合适的内存分配，然后更新列表


上面解决了分配内存的问题，但是也引入了一个新的问题：并发！！！

就刚才的一个修改指针操作，就会带来隐患：对象 A 正分配内存呢，突然！！对象 B 又同时使用了原来的指针来分配 B 的内存。解决方案也有两种：

* **同步处理**——实际上虚拟机采用 CAS 配上失败重试来保证更新操作的原子性
* **把内存分配的动作按照线程划分在不同的空间之中进行**，即每个线程在 Java 堆中预先分配一小块内存，成为**本地线程分配缓存（Thread Local Allocation Buffer，TLAB）**。哪个线程要分配内存，就在哪个线程的 TLAB 上分配，用完并分配新的TLAB时，才需要同步锁定（虚拟机是否使用 TLAB，可以通过`-XX:+/-UseTLAB` 参数来设置）

好了，上面给内存分配了空间，那么**内存清零**放在什么时候呢？一种情况是分配 TLAB 的时候，就对这块分配的内存清零，或者可以在使用前清零，这个自己实现。

接下来要对对象进行必要的设置，比如

* 这个对象是哪个类的实例
* 如何才能找到类的元数据信息
* 对象的 hashcode 值是多少
* 对象的 GC 分代年龄等信息

这些信息都放在对象头中。

上面的步骤都完成后，从虚拟机角度来看，一个新的对象已经产生了，但是从 Java 程序的视角来看，对象创建才刚刚开始——方法还没有执行，所有的字段都还为零。而这个过程又是一个非常复杂过程，具体可以参考前面的文章，讲解 Java 的对象是如何初始化的。从编译阶段的 constantValue 到准备阶段、初始化阶段、运行时阶段都有涉及。

**继续**：Java对象创建之后，如何初始化？



### 对象的内存中布局


首先我们要知道的是：在 HotSpot 虚拟机中，对象在内存中存储的布局可以分为3块区域：**对象头（Header）、实例数据（Instantce Data）、对齐补充（Padding）**。当然，我们不必要知道太深入，大概知道每个部分的作用即可：

* 对象头（Header）：包含两部分信息
	* 第一部分用于存储**对象自身的运行时数据**，如 hashcode 值、GC 分代的年龄、锁状态标志、线程持有的锁等，官方称为“Mark Word”。
	* 第二部分是**类型指针**，即**对象指向它的类元数据的指针**，虚拟机通过这个指针来确定这个对象是哪个类的实例
* 实例数据（Instance Data）：就是程序代码中所定义的各种类型的字段内容
* 内存对齐：这个在前面博文中已经说过好多次了，不懂的可以去看看即可




### 对象的访问定位

对象的访问定位，这个问题要好好整理一下，特别是两个配图。

如何访问对象实例呢？也就是说，如何找到对象实例？两种方式：

*（[insideJVM ed 2-Chapter 5](http://www.artima.com/insidejvm/ed2/jvm6.html)）有详细的配图和介绍，还没有细看*

#### 使用句柄

一个对象实例，需要对象的类数据*（类型数据）*、对象的实例数据，两类数据共同实现一个对象实例。

**使用句柄**：Java Heap中开辟一个句柄池，JVM Stack中对象reference就是一个句柄，每个句柄指向对象地址和类地址；

![](/images/understanding-jvm/reference-pool.jpg)

**疑问**：对象引用、对象句柄，是什么？

* 对象引用：指向对象实例；
* 对象句柄：包含对象引用、类的引用；

#### 直接指针

**直接指针**：JVM Stack中对象reference直接指向对象的实例数据，同时，对象实例数据指向类数据。

![](/images/understanding-jvm/direct-reference.jpg)



#### 使用句柄 vs. 直接指针

两种方式的目的相同：找到对象实例，并访问对象实例。由于实现方式不同，有如下差异：

* 使用句柄，访问对象实例，好处：reference中存储的是稳定的句柄地址，不会随着GC 对象位置的移动发生改变，只需要调整句柄中对象实例的地址；
* 直接指针，访问对象实例，好处：访问速度快，节省了一次指针定位的时间开销；**Sun HotSpot VM使用直接指针方式访问对象**；


## 闲谈

看看JVM最具权威的官方文档（[Java Language and Virtual Machine Specifications][Java Language and Virtual Machine Specifications]）吧，这是所有JVM相关信息的最初来源，其他绝大多数知识都是对其的理解和重新表述，当然不同的人的理解也有误差。


> 预告：下一篇文章，介绍GC，大概想了一下，几个问题：如何确定对象可以被回收？如何进行回收？


[Java Language and Virtual Machine Specifications]:			http://docs.oracle.com/javase/specs/
[深入理解Java虚拟机]:										http://book.douban.com/subject/24722612/
[NingG]:    												http://ningg.github.com  "NingG"
[Inside the Java Virtual Machine(2nd Edition)]:							http://www.artima.com/insidejvm/blurb.html
[深入理解Java虚拟机 - 第二章、Java内存区域与内存溢出异常]:			http://github.thinkingbar.com/jvm-ii/







