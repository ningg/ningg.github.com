---
layout: post
title: JVM 实践：GC 调优实践
description: JVM GC 一般会出现哪些问题？问题的原因是什么？如何定位这些问题？有哪些工具可以使用？
category: jvm
---

## 1. 概要

接着上一篇 blog：

* [JVM 实践：GC 原理](http://ningg.top/jvm-series-jvm-practice-jvm-gc-principle/)


## 2. 主要内容

主要分为 3 个方面：

* 排查工具
* JVM CPU 资源占用过高
* JVM 内存资源占用过高：OOM，OutOfMemoryError

### 2.1. 排查工具

几个工具，以及简介：

* `jps`：显示本地有几个 JVM 进程，并获取 pid
	* 命令格式：`jps -lvm`
* `jinfo`：运行环境参数，Java System 属性、JVM 命令参数，class path 等
	* 命令格式：`jinfo [pid]`
* `jstat`：JVM 运行状态信息，类加载、内存回收等
	* 命令格式：`jstat [-class | -gc] [pid] [interval] [count]`
* `jstack`：JVM 进程内部，所有线程的运行情况
	* 命令格式：`jstack [pid]`
* `jmap`：JVM 内，堆中存储的对象「堆转存快照」，使用 jhat 命令分析「堆转存快照」
	* 命令格式：`jmap [pid]`
* 备注：可视化工具 JConsole、**VisualVM**

详细操作使用，可以参考：

* [JVM 实践：jps、jinfo、jstat 命令详解](http://ningg.top/jvm-best-practice-cmd-details-jps-jinfo-jstat/)


其中，从上至下，要解决 5 个问题：

1. 有哪些 JVM 实例？ `jps`
1. JVM 启动参数？`jinfo`
1. JVM 运行状态（gc 的状态）？ `jstat`
1. JVM 中，栈？`jstack`
1. JVM 中，堆？`jmap`

### 2.2. CPU 资源占用过高

* **初步分析**：
	* 线程「死循环」
	* 线程「死锁」
* 具体**定位步骤**：（`进程` -- `线程` -- 分析`线程上下文`）
	* top 命令：Linux 命令，查看实时的 CPU 使用情况，获得 pid
	* top 命令：Linux 命令，查看进程中线程使用 CPU 的情况，记录 tid
	* jstack 命令：jvm 命令，查看指定进程下，所有线程的调用栈和执行状态
		* 根据 top 命令获取的 tid（转换为 16 进制）
		* 找出目标线程的调用栈和执行状态
	* 分析「目标线程」调用栈和执行状态，对应到源代码，修复问题


具体 case ，可以参考：

* [JVM 实践：jstack对运行的 Thread 进行分析](http://ningg.top/jvm-best-practice-jstack-thread-analysis/)




### 2.3. 内存占用过高：OOM，OutOfMemoryError

OOM 异常，细分为 3 类：

* `java.lang.OutOfMemoryError`: **Java heap space**
* `java.lang.OutOfMemoryError`: **PermGen space**
* `java.lang.OutOfMemoryError`：**null**

#### 2.3.1. OOM：Java heap space

* **现象**：java.lang.OutOfMemoryError: Java heap space
* **原因**：JVM 堆内存不足，2 类原因：
	* 堆内存**设置不够**，参数`-Xms`、`-Xmx`来调整
	* **内存泄漏**：jmap 输出「堆转储快照」，通过工具查看 GC Roots 的引用链，定位出泄漏代码的位置
	* 常见：
		* 业务代码中创建了大量「**大对象**」，并且长时间不能被垃圾收集器收集（存在被引用），此时，通过 jmap 命令输出「堆转存快照」，分析后，优化业务逻辑（老年代空间不足）
		* 不限长度的**队列**，`一直生产`对象，`没有消费`对象，导致内存溢出

#### 2.3.2. OOM：PermGen space

* **现象**：java.lang.OutOfMemoryError: PermGen space
* **原因**：JVM 「永久代」不足，3 类原因：
	* 「永久代」设置不够，参数 `-XX:MaxPermSize` 来调整
		* 32位机器默认 64M
		* 64位的机器默认 85M（指针膨胀）
	* 程序启动时，加载**大量的第三方jar包**
	* ASM（编译期）、CGLib（运行时），等**动态代理**技术，生成大量的 Class

#### 2.3.3. OOM：null

* **现象**：java.lang.OutOfMemoryError：null
* **原因**：「直接内存」空间不足
* **分析过程**：
	* 检查一下是否使用 Java NIO
* 解决办法：设置「直接内存」大小
	* 默认，跟 Java 堆一样大小，即，参数 -Xmx 的取值
	* MaxDirectMemorySize 设置「直接内存」
	* 注意：约束「直接内存」+「Java 堆」 < 「OS 物理内存」

### 2.4. 补充：

主要补充 3 个方面：

* 直接内存
* 永久代
* JDK 8 的差异

#### 2.4.1. 补充：直接内存

* **JVM 中，「直接内存」、Java 堆，之间的关系**
	* 直接内存：不属于运行时数据区，不受 Java 堆大小的限制，即，不受-Xmx 限制；
* **如何设置「直接内存」大小**？
	* 默认，跟 Java 堆一样大小，即，参数 -Xmx 的取值
	* MaxDirectMemorySize 设置「直接内存」
* **什么时候会使用「直接内存」**？
	* JDK 1.4 的 NIO，有一个缓冲区（Buffer），调用 Native 方法，使用的直接内存，减少数据的复制次数
	* JDK 1.7，「方法区」内部的「常量池」，迁移到「直接内存」中
* **「直接内存」的垃圾回收：什么时候进行**？如何进行？
	* JVM 会回收「直接内存」
	* 「直接内存」回收，跟 Java 堆的新生代、老年代不同，无法在发现「直接内存」空间不足时，通知垃圾回收器，来回收。
	* 老年代进行 `Full GC` 时，会`顺便清理`一下「直接内存」的废弃对象。

#### 2.4.2. 补充：永久代

* **永久代，是否会回收**？
	* 永久代，存储「方法区」的内容，主要是「类」和常量、静态变量
	* 其中，「类」占用空间很大，判断「无用的类」，需要同时满足：
	* 类所有的实例都已被回收
	* 加载该类的 ClassLoader 也被回收
	* 类对应的 Class 对象，没有被任何地方引用，主要是无法通过反射获取
* **永久代，什么时候会回收**？
	* 参数 -Xnoclassgc 控制是否开启永久代回收
	* 永久代满了，会触发 Full GC，如果 GC 后空间仍然不足，会抛出 OOM: PermGen space
	* 永久代和老年代捆绑在一起，无论谁满了，都会触发永久代和老年代的垃圾收集 

#### 2.4.3. 补充：JDK8 的差异

* **有哪些差异？**
	* 方法区：放在「直接内存」中，永久代的参数`-XX:PermSize`和`-XX:MaxPermSize`也被移除
	* 永久代：去除「永久代」概念，避免 OOM 问题（因为参数 MaxPermSize 约束了永久代大小）
* **带来的收益？不同？**
	* JDK7 中，永久代的最大空间一定得有个指定值，而如果 MaxPermSize 指定不当，就会OOM
		* 「永久代」参数 `-XX:MaxPermSize` 来调整
			* 32位机器默认 64M
			* 64位的机器默认 85M（指针膨胀）
	* JDK8 中，`-XX:MetaspaceSize` 和`-XX:MaxMetaspaceSize`设定「方法区」大小，但如果不指定，Metaspace的 大小仅受限于「直接内存」大小，上限是物理内存大小

## 3. 讨论问题

讨论过程中，提到的几个问题：

* OutOfMemroryError 什么时候挂掉进程，什么时候不会挂掉？
* MaxDirectMemorySize参数设置的是JVM所能够使用的直接内存的最大值？
* GC搜索越界？
	* 1、新生代引用老年代的大对象，发生YGC时，是否会需要搜索老年代（虚拟账本？是否参与GC？），在JVM实现时通过虚拟账本的方式隔绝GC搜索越界；
	* 2、FullGC时会发生老年代和永久代的GC搜索越界现象；
* FullGC时对直接内存如何进行GC？
* 反射为什么会导致永久代GC发生难以判断的情况？


## 4. 参考资料

* 《深入理解 Java 虚拟机— JVM高级特性与最佳实践（第2版）》
* 《实战 Java 虚拟机—JVM故障诊断与性能优化》
* [Java Garbage Collection  Basics](http://www.oracle.com/webfolder/technetwork/tutorials/obe/java/gc01/index.html) (Oracle) 
* [Getting Started with the G1 Garbage Collector](http://www.oracle.com/webfolder/technetwork/tutorials/obe/java/G1GettingStarted/index.html)
* [The Java Language Specification](https://docs.oracle.com/javase/specs/index.html) Java SE 6\7\8
* [The Java Virtual Machine Specification](https://docs.oracle.com/javase/specs/index.html) Java SE 6\7\8
* [Java 8 移除永久代](http://www.infoq.com/cn/articles/Java-PERMGEN-Removed/)







[NingG]:    http://ningg.github.com  "NingG"
