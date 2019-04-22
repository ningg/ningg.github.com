---
layout: post
title: JVM 实践：GC 原理
description: Java 代码执行过程是什么？JVM 内存是怎么被分配的？为什么需要被回收？又如何回收？核心原理和要点是什么
category: jvm
---

## 1. 背景

从 14 年，第一次在团队中分享 JVM 的 GC 原理以及调优实践，17 年在美团分享一次，最近面向公司的支付技术团队又分享了一次，做了局部内容的更新。在美团那次，技术学院录了部分视频，美团的读者可以到 mit 上搜一下。18 年这次，围绕 JDK8 以及 G1 垃圾收集器，做了部分内容更新，这次集中放出来吧，准备 2 篇 blog 来描述 JVM GC 原理和调优实践。（*自己有一个 keynote 版本*）


## 2. 主要内容

主要几个方面：

1. 基本逻辑：
	1. Java 代码执行过程
	1. JVM 内存分配
	1. JVM 内存回收
1. 实现细节：
	1. 整体策略：分代策略
	1. 垃圾收集器
1. 实践：具体 JVM 调优的详细场景和操作

### 2.1. 基本逻辑

#### 2.1.1. Java 代码执行过程

##### 2.1.1.1. JVM 是什么

* 什么是 JVM?
	* 对操作系统（OS）：JVM 是一个应用程序，一个`进程`
	* 对 Java 代码：Java 代码的`运行环境`，实现跨平台
	* JVM 版本：
		* **不同厂商有不同版本**的 JVM：Sun、IBM 等
		* `Hotspot` 是比较流行的版本（Oracle）
* 其他 JVM：
	* Sun 早期的 Classic
	* IBM 的 J9
	* Oracle 的 JRockit

![](/images/jvm-series/what_is_jvm.png)


##### 2.1.1.2. Java 代码执行过程

JVM 整体由 4 部分组成：

1. **加载**：类加载器 ClassLoader
1. **执行**：执行引擎
1. **内存**：运行时数据区，Runtime Date Area
1. **内存回收**：垃圾回收

![](/images/jvm-series/java_code_run_progress.png)

#### 2.1.2. 内存分配

##### 2.1.2.1. 运行时数据区

1. 方法区：
	1. 类：Class
	1. 静态变量
	1. 常量池（字符串常量、数字常量）
1. Java 堆：
	1. 对象：Object
	1. 数组
1. Java 栈：Java 方法调用过程
	1. 操作数栈
	1. 局部变量表
	1. 方法出口
1. 本地方法栈：本地方法调用过程
1. 程序计数器：Program Counter

![](/images/jvm-series/runtime_data_area.png)


##### 2.1.2.2. 实例

JVM 内存空间：
1. 线程共享：
	1. Java 堆
	1. 直接内存
	1. 方法区
1. 线程独占：
	1. Java 栈
	1. 本地方案栈
	1. PC 寄存器

![](/images/jvm-series/runtime_data_area_demo.png)


#### 2.1.3. 内存回收

##### 2.1.3.1. 为什么要回收内存

* **背景**：
	* 「**已被占用**」的内存，只有「**被释放**」，才能再次使用
	* 不释放内存，`内存泄露`
* Java 代码，运行在 JVM 上：
	* 由 JVM 负责内存回收，**自动回收**
	* Garbage Collection：垃圾回收
* 内存回收，**目标**：回收`不再使用`的内存，释放空间，防止内存泄漏
* GC 的核心问题：
	* **回收哪些内存**？
	* **如何回收内存**？
	* 回收内存时，是否需要**暂停服务**？

##### 2.1.3.2. 回收哪些内存

* 核心问题一：回收哪些内存？
	* 标准：已被占用，但**不再被使用**的内存
	* JVM 内存`分配的粒度`：对象、基础类型
* **判断策略**：
	* **引用计数**
	* 根结点可达（**根搜索**）：哪些是根结点


**引用计数**：

* 具体原理：
	1. Object 每次被引用，计数加「+1」
	1. Object 每次被释放引用，计数「-1」
	1. 判断 Object 的引用次数 「＝0」
* 优点：
	* 判断简单
	* 算法效率高
* 缺点：
	* 多个 Object 之间，「循环引用」内存泄漏

![](/images/jvm-series/pointer-counter.png)


**根搜索**：

* 根结点可达（根搜索）：
	* 从「确定被使用」的对象，出发
	* 遍历所有「可到达的对象」
	* 「可到达的对象」之外的内存，一律回收
* 优点：
	* 解决「循环引用」内存泄漏
* 根结点（Root Node）：
	* Java 栈：引用的对象
	* 本地方法栈：引用的对象
	* 方法区：静态属性，引用的对象
	* 方法区：常量属性，引用的对象

![](/images/jvm-series/root-search.png)


##### 2.1.3.3. 如何回收

核心问题二：如何回收？

* 标记-清除
* 标记-清除-压缩（简称：标记-整理）
* 标记-复制-清除（简称：复制）

`分代回收`：根据对象存活时间，分级策略

* 分代回收策略：（Hotspot）
	* 根据对象「**存活时间**」，分级管理
		* `新生代`：存储新建的对象，`存活时间短`，90%的对象用完就可以回收
		* `老年代`：新生代中，`存活时间较长`的对象
		* `永久代`：类加载的信息，`存活时间特别长`，几乎不会被回收
* **优点**：
	* **分级管理**，**差异化管理**
	* 减少重复劳动
* **缺点**：
	* 高级别对象，占用内存时间更长


![](/images/jvm-series/hotspot_vm_heap_generation.png)


### 2.2. 实现细节

#### 2.2.1. 简要

背景：

* 前面的「**内存回收策略**」是「`方法论`」，是`核心思路`
* **垃圾收集器**，是内存回收的`具体实现`
* JVM 官方规范中，并`没有规定`垃圾收集器的`实现细节`
* 不同厂商、不同 JVM ，垃圾收集器，存在差异较大
* `HotspotVM` 是最`流行`的 JVM 实现之一
* 后面针对 HotspotVM 内的具体实现进行介绍

#### 2.2.2. 具体的 GC 垃圾收集器

* 简介：
	* 判断是否回收对象：`根搜索`
	* `分代算法`：基于分代算法，采用不同策略
	* `关联关系`：存在连线的垃圾收集器，可以配合使用
	* `权衡场景`：**没有万能**的收集器，`只有适合`场景的收集器
* **实现历史**：
	* Parallel、G1 没有使用传统的 GC 代码框架，无法配合 CMS
	* JDK1.6+ ，引入 Parallel Old，用于配合 Parallel Scavenge 使用
	* JDK1.7+，引入 G1（Garbage First）
* **Server 模式**，默认组合：（`已经过时`）
	* 新生代：Parallel Scavenge 
	* 老年代：Serial Old
* 吞吐量和 CPU 资源敏感的场景（`计算密集型`），推荐组合：
	* 新生代：Parallel Scavenge
	* 老年代：Parallel Old
* 响应时间敏感的场景（`交互型`），推荐组合：
	* 新生代：ParNew
	* 老年代：CMS


![](/images/jvm-series/hotspot_vm_gc_collectors.png)



#### 2.2.3. CMS 垃圾收集器（老年代）

* **CMS**，Concurrent Mark-Sweep，（老年代-并发-收集器）：多线程，非独占式
	* **策略**：**标记-清除**
	* **优点**：「停顿时间」最短
	* **缺点**：内存碎片（有补偿策略）
	* **适用场景**：互联网 Web 应用的 Server 端，涉及用户`交互`、响应速度快。
* **CMS 具体过程**：
	* **初始标记**：仅标记「GC Roots」直接引用的对象
	* **并发标记**：从 GC Roots 出发，标记可达对象
	* **重新标记**：标记「并发标记」过程中，变更的对象
	* **并发清除**：清除「无用对象」
* **CMS 降级**：Concurrent Mode Failure
	* 并发标记、清理过程，work thread 在运行，申请「老年代」空间可能失败
	* **后备预案**：临时启动 `Serial Old` 收集器

![](/images/jvm-series/par_and_cms.png)


#### 2.2.4. G1 垃圾收集器（新生代、老年代）

G1，Garbage First：

* **目标**：替代 CMS
* **内存布局**：
	* 内存组织粒度 Region
	* 新生代/老年代不要求连续内存空间
* **分代**：G1 独立管理，新生代、老年代
* **策略**：标记-清除-整理，不会产生内存碎片（Region 间复制）
* **并发**：降低停顿时间，减弱 STW 停顿
* **可预测的停顿**：精确控制 gc 停顿时间
	* 每个 Region 维护一个 「Garbage Value」，优先队列
	* 优先回收「Garbage Value」最大，回收价值最大的 Region
* **Young GC** 和 **Full GC**： 跟前面概念完全一致
	* 尽可能减少 Full GC


![](/images/jvm-series/g1_collector.png)



#### 2.2.5. CMS vs. G1

* `G1` vs. `CMS`
	* **内存组织粒度**：G1 将内存划分为「Region」，避免内存碎片
	* **内存灵活性**：Eden、Survivor、Tenured 不再固定，内存使用效率更高
	* **适用范围**：G1 能够应用在「新生代」，CMS 只能应用在「老年代」
	* **可控性**：可控的 STW 时间，根据预期的停顿时间，只回收部分 Region
* G1 **适用场景**：
	* **服务端**，**多核 CPU**，JVM 占用内存较大（>4GB）
	* 业务场景中，应用会产生大量**内存碎片**、需要经常压缩
	* 可控、**可预期**的 **GC 停顿时间**，防止高并发下应用的血崩现象
	* **是否升级到 G1**：
		* 现在采用的收集器没有出现问题，就暂时没有理由选择 G1，等待 G1 持续的优化即可
		* 服务器端，`交互型应用`，追求`快速响应`，现在就可以尝试一下 G1
		* `计算密集型`应用，**G1 并不会明显改善吞吐量**


![](/images/jvm-series/cms_vs_g1.png)



### 2.3. 实践：JVM 调优实践

单独进行一次分享和整理：

* TODO： 参考另一篇 blog.

### 2.4. 补充

#### 2.4.1. Young GC & Full GC

* `Young GC` vs. `Full GC`：
	* **Young GC**，Minor GC，新生代 GC
		* 发生地点：**新生代**
		* 发生时间：在「新生代」创建对象时，连续存储空间不足，触发 Young GC
		* 特点：**速度快**、**频次高**
	* **Full GC**，Major GC，老年代/永久代 GC
		* 发生地点：**老年代**/**永久代**
		* 发生时间：
			* Young GC 之前，预判「老年代」的空间是否充足；
			* 大对象直接进入「老年代」，但「老年代」空间不足；
		* 特点：**速度慢**（比 Young GC 慢 10 倍+）、需要控制频次
* **补充**：
	* Full GC 并不包含 Young GC；Full GC 一般伴随 Young GC （不绝对）
	* Full GC，暂停时间比较长，认为 Stop-The-World （STW），参数配置时，重点考虑降低 Full GC 次数。

![](/images/jvm-series/hotspot_vm_heap_generation.png)

 

## 3. 讨论问题


讨论问题

* 方法区是否会发生GC？：
	* Re：在进行 full gc 的时候，会对方法区进行垃圾回收；另一方面，可以设置 JVM 启动参数，禁止针对方法区进行 GC；
* G1相对于CMS来说，在解决退化问题时的细节策略是什么？
	* Re：G1 跟 CMS 类似，在「并发标记阶段」，也存在空间不足，导致退化为 Serial Old 垃圾收集器的风险，具体细节和处理办法，后面会补充；


## 4. 参考资料

* 《深入理解 Java 虚拟机— JVM高级特性与最佳实践（第2版）》
* 《实战 Java 虚拟机—JVM故障诊断与性能优化》
* [Java Garbage Collection  Basics](http://www.oracle.com/webfolder/technetwork/tutorials/obe/java/gc01/index.html) (Oracle) 
* [Getting Started with the G1 Garbage Collector](http://www.oracle.com/webfolder/technetwork/tutorials/obe/java/G1GettingStarted/index.html)
* [The Java Language Specification](https://docs.oracle.com/javase/specs/index.html) Java SE 6\7\8
* [The Java Virtual Machine Specification](https://docs.oracle.com/javase/specs/index.html) Java SE 6\7\8
* [Java 8 移除永久代](http://www.infoq.com/cn/articles/Java-PERMGEN-Removed/)







[NingG]:    http://ningg.github.com  "NingG"
