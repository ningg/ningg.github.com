---
layout: post
title: JVM 实践：G1 垃圾收集器
description: JDK 1.7 推出稳定版的 G1 垃圾收集器，工作原理是什么？实践过程中，有哪些注意事项？
category: jvm
---

## 0.概要

> **写在开头**：当前文章，都是针对 JDK8 中 G1 的实现，进行描述的

G1 垃圾收集器的详解，几个方面：

1. 工作原理：
	1. 内存特点
	1. GC：
		1. young gc
		1. mixed gc
		1. full gc
1. 实践：
	1. 常用参数
	1. 常见问题

## 1.内存特点：G1

**内存特点**：

* **粒度**：`Region`，通过参数，可以设置大小
* **分代策略**：仍然是`分代回收`，新生代 + 老年代
* Region 分类：
	* Eden
	* Survivor
	* Old
	* Humongous：大对象 Region，单个对象超过 region 的 50%，如果超过一个 Region，则，会占用连续的 Region
	* Free：空闲 Region、可用 Region
* **Region 的分类**，`动态可变`：Region 被释放后，是 Free Region，后续可能被作为 `Eden` or `Survivor` or `Old` or `Humongous` 分区使用。

**关联术语**：

* **CSet**：`Collection Set`，待回收的 Region 集合
* **RSet**：`Remembered Set`，引用当前 Region 的其他 Region集合，是 points-in的，每个 Region 都有一个 RSet；在 `JDK10` 中，只有部分 Region 才存在 RSet。

**关键用途**：

* **RSet**：指向「当前 Region」 的「其他 Region 集合」，有两个典型应用场景
	* **young gc**：指向「Eden」和「Survivor」Region 的 「Old」和「Humongous」Region 集合，避免全堆扫描
	* **mixed gc**：确定「Old」Region 之间的相关引用，确定 Region 的回收价值

## 2.GC：G1

G1 垃圾收集器，具体的 GC，分为下述几种：

1. **young gc**：标记-复制
	1. 「新生代」的垃圾回收
	1. CSet 中，只包含 Eden、Survivor
1. **mixed gc**：标记-复制
	1. 「新生代」和「部分老年代」的垃圾回收
	1. CSet 中，包含 Eden、Survivor、部分 Old、Humongous
1. **full gc**：
	1. G1 gc 失败，退化为 Serial 方式
	1. 单线程全堆扫描，对整个 Heap 进行垃圾回收，涵盖所有的「新生代」和「老年代」

**特别说明**：

> G1 垃圾收集器，GC 都是针对 CSet 进行的

### 2.1.Young GC

Young GC，关键细节：

* 针对「**年轻代**」的 Eden、Survivor 分区，进行 GC
* **存活的对象**，放置在 「新的 Survivor 分区」或「Old 分区」
* **触发的时机**：Eden 分区空间不足，无法为普通对象分配存储空间（非大对象）

**Young GC 的执行过程**：就是「标记-复制」算法

1. **根扫描**
1. **确定**「老年代」对「新生代」的**引用**，避免全堆扫描：
	1. 根据 card table，扫描 dirty 部分，更新 RSet
	1. 新生代中，根据 RSet，确定 Old 对 Eden 和 Survivor 对象的引用
1. **标记复制**：将存活对象，放入到 Survivor 区 或者 Old 区
	1. 新的 Survivor 区：是 Free Region 升级来的
	1. 被释放的 Eden 和 Survivor 区：会标记为 Free Region 空白的可用分区

Tips：

* G1 在 Young GC 过程中，是串行？并行？并发？是否会暂停工作线程？
	* Re：可以多线程，就看怎么设置了，会暂停工作线程，不是并发的。

### 2.2.Mixed GC

Mixed GC，关键细节：

* 针对「**年轻代**」和「**部分老年代**」的 GC，具体 Eden、Survivor、Old、Humongous Region
* **存活的对象**，放置在「新的 Survivor 分区」或「Old 分区」
* **触发的时机**：「并发标记周期」中，完成了最后的「**筛选回收**」阶段后，标记出了 X 的 Old Region 分区


Mixed GC 的执行过程：就是「标记-复制」算法

1. **并发标记周期**：针对 `Old 分区`，进行标记
	1. **初始标记**：依赖 Young GC
	1. **扫描根分区**：如果有 Young GC，则，Young GC block 阻塞等待
	1. **并发标记**：
		1. 可以并发进行 Young GC
		1. 结束后，并不会进入 Young GC 阶段
	1. **重新标记**：不能进行 Young GC
	1. **筛选回收**：结束后，进入 mixed 阶段
1. **Mixed GC**，**本质**就是对 **CSet** 中 Region 的回收
	1. **CSet**：在 mixed 模式下，其中涵盖了  Eden、Survivor、Old、Humongous Region
	1. **筛选回收阶段**：针对 Old 分区
		1. **完全可回收的 Region**：不存在存活的对象，直接回收 Region，标记为 Free Region 可用分区
		1. 存在**部分存活的对象的 Region**：标记分数后，追加在 C-Set 中



实际上，可以认为是 2 条线：

* **Young GC**：
	* 基于 C-Set，进行 Region 回收，本质上，只针对「年轻代」进行回收；
	* 如果 C-Set 中，涵盖了标记为 X 的 Old Region，则，称为 Mixed GC，此时，既针对「年轻代」，也针对「部分老年代」Region 进行回收
* **并发标记周期**：标记出 Old Region，哪些需要回收，标记为 X
	* 完成「并发标记阶段」后，Young GC，自动升级为 mixed 模式，即，Mixed GC
	* Mixed GC：基于 C-Set，进行 Region 回收，只不过，此时，C-Set 中，涵盖了一部分 Old Region

![](/images/jvm-series/g1-gc.png)

1 个插图：并发标记周期的说明

* **并发标记周期**：
	* 触发时机：「老年代」分区的占比，达到阈值
	* 整个周期说明
* **Mixed GC**：模式生效点、失效点
	* **生效点**：存在 X 状态的 Old Region，即，标记并发周期的「筛选回收」阶段结束后，再次触发的 GC，就是 Mixed GC
	* **失效点**：完成所有的 X 状态 Old Region 的清理后，会进入 Young GC 状态
* **补充说明**：
	* 部分 X 状态的 Old Region：每次 Mixed GC，只有部分 X 状态的 Old Region 会被放入 C-Set
	* 完整 C-Set 都被回收：C-Set 中所有 Region，每次 GC 都会被回收

**特别说明**：

> G1的收集都是STW的；
> 
> 但「年轻代」和「老年代」的 GC **界限模糊**，采用了混合(`mixed`)收集的方式。
> 
> **Young GC**，可能快速切换为 Mixed GC，只要 X 标记的 Old Region 存在和消失，就会自动升级 or 降级；
> 
> 这样，即使堆内存很大时，也可以限制**收集 Region 的范围**，从而**降低停顿**，达到设置的「暂停时间的目标」。

### 2.3.其他

#### 2.3.1.启发式算法

**启发式算法**：根据执行状态，动态调整

1. 设置了「暂停时间的目标」（默认 200ms），G1 会自动调整「年轻代」的空间大小
1. 如果显式设置「年轻代」的大小，则，用户设置的「暂停时间的目标」会自动失效

#### 2.3.2.SATB，增量式的标记算法

G1 垃圾收集器，采用了 **SATB**（Snapshot At The Beginning），初始快照，增量式的标记算法，具体：

1. **标记开始时**：Region 创建一个 Snapshot
1. **存量标记**：只针对 Snapshot 中存活的对象，进行标记
1. **增量标记**：Snapshot 之后，新生成的对象，都被标记为「存活对象」，此次不回收，下次标记再说

#### 2.3.3.G1：适用场景

就目前而言、CMS还是默认首选的GC策略、可能在以下场景下G1更适合：

1. **多核+大内存**：服务端多核CPU、JVM内存占用较大的应用（至少大于4G）
1. **业务多碎片**：应用在运行过程中会产生大量内存碎片、需要经常压缩空间
1. **防止高并发雪崩**：想要更可控、可预期的GC停顿周期；防止高并发下应用雪崩现象


### 2.4.小结

G1 垃圾收集器，围绕其 Young GC 和 Mixed GC，从整体宏观的角度上，跟之前所有的「串行」「并行」「并发」的垃圾收集器，存在本质的差异：

1. 之前的垃圾收集器，要实现 **2 个基本步骤**：
	1. **步骤1**：找到需要回收的对象
	1. **步骤2**：回收
	1. **Note**：上面两个步骤「步骤2」依赖「步骤1」，并且串行进行
1. G1 垃圾收集器，在「**老年代**」，把 2 个步骤「同时进行」：
	1. **找到需要回收的对象**：
		1. 在找到需要回收的 Old Region 过程中，仍然可以同时「回收对象」，即 GC
		1. 找到需要回收的 Old Region 过程，称为「**并发标记周期**」
	1. **回收对象**：
		1. 在「找需要回收的对象」**过程中**，可以持续并发的进行 GC，称为 `Young GC`，只会收「新生代」
		1. 「找需要回收的对象」**过程结束后**，再进行的 GC，称为 `Mixed GC`，会同时回收「新生代」和「部分老年代」

参考示意图：

![](/images/jvm-series/g1-gc.png)

## 3.实践

2 个方面：

1. 常用参数
1. 常见问题

TODO：

* [详解 JVM Garbage First(G1) 垃圾收集器](https://blog.csdn.net/coderlius/article/details/79272773)
* [G1 垃圾收集器调优](https://www.oracle.com/technetwork/cn/articles/java/g1gc-1984535-zhs.html)

## 4.参考资料

* [详解 JVM Garbage First(G1) 垃圾收集器](https://blog.csdn.net/coderlius/article/details/79272773)
* [Garbage First G1收集器 理解和原理分析](https://liuzhengyang.github.io/2017/06/07/garbage-first-collector/)
* [深入理解G1垃圾收集器](http://ifeve.com/%E6%B7%B1%E5%85%A5%E7%90%86%E8%A7%A3g1%E5%9E%83%E5%9C%BE%E6%94%B6%E9%9B%86%E5%99%A8/)
* [JVM G1混合回收（mixed GC）的一些理解](https://www.jianshu.com/p/0b978e57d430)=
* [JVM性能调优实践——G1 垃圾收集器介绍篇（超详细）](https://cloudpai.gitee.io/2018/08/23/2018-08-23-12/)
* [G1 垃圾收集器调优](https://www.oracle.com/technetwork/cn/articles/java/g1gc-1984535-zhs.html)



[NingG]:    http://ningg.github.com  "NingG"
