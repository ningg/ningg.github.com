---
layout: post
title: JVM 实践：浅析JVM中垃圾回收
description: 分代回收？
published: true
category: jvm
---


Java内存分配和回收的机制概括的说，就是：**分代分配，分代回收**。

Note：

> **分代策略**，本质就是`分级策略`，同一类特征的堆内存对象（特征：对象存活时间），集中在一起，使用相同的垃圾回收策略，提升效率。

对象将根据存活的时间被分为：

* 新生代（Young Generation）：`复制`策略，存活对象少
* 老年代（Old Generation）：`标记-压缩`策略，存活对象多
* 永久代（Permanent Generation，也就是方法区）


![](/images/understanding-jvm/3-generation.png)


## 新生代

新生代，被分为 3 个空间：

1. Eden 区：新申请的对象，分配在 Eden 区
2. Survivor 0 区：复制策略使用的复制区
3. Survivor 1 区：复制策略使用的复制区

什么时候触发 Young GC？（Young GC，就是发生在新生代的 GC）

* 新生代空间不足时：新分配对象时，发现 Eden 空间不足，此时，会触发 Young GC

Young GC 的具体过程：

* `Eden 区`存活对象：复制到 `Survivor 1 区`
* `Survivor 2 区`中存活对象：复制到 `Survivor 1 区`
* `Eden 区` 和 `Survivor 1 区`：清空

什么时候，对象进入`老年代`？

* **存活时间达标**：Survivor 区中，对象`年龄`达到`阈值`（Survivor 区中，每复制一次，年龄加一）
* **对象过大**：新创建的对象`大小`，超过`阈值`，直接进入`老年代`

详细说明：看下面

新生代（Young Generation）：对象被创建时，内存的分配首先发生在新生代（大对象可以直接 被创建在老年代），大部分的对象在创建后很快就不再使用，因此很快变得不可达，于是被新生代的GC机制清理掉（IBM的研究表明，98%的对象都是很快消 亡的），这个GC机制被称为Minor GC或叫Young GC。新生代可以分为3个区域：Eden区和两个存活区（Survivor 0 、Survivor 1）。

1. 绝大多数刚创建的对象会被分配在Eden区，其中的大多数对象很快就会消亡。**Eden区是连续的内存空间，因此在其上分配内存极快；**
1. 当Eden区满的时候，执行Minor GC，将消亡的对象清理掉，并将剩余的对象复制到一个存活区Survivor0（此时，Survivor1是空白的，两个Survivor总有一个是空白的）；
1. 此后，每次Eden区满了，就执行一次Minor GC，并将剩余的对象都添加到Survivor0；
1. 当Survivor0也满的时候，将其中仍然活着的对象直接复制到Survivor1，以后Eden区执行Minor GC后，就将剩余的对象添加Survivor1（此时，Survivor0是空白的）。
1. 当两个存活区切换了几次（HotSpot虚拟机默认15次，用-XX:MaxTenuringThreshold控制，大于该值进入老年代）之后，仍然存活的对象（其实只有一小部分，比如，我们自己定义的对象），将被复制到老年代。


![](/images/understanding-jvm/minor-gc.png)


从上面的过程可以看出，Eden区是连续的空间，且Survivor总有一个为空。经过一次GC和复制，一个Survivor中保存着当前还活 着的对象，而Eden区和另一个Survivor区的内容都不再需要了，可以直接清空，到下一次GC时，两个Survivor的角色再互换。因此，这种方 式分配内存和清理内存的效率都极高，这种垃圾回收的方式就是著名的“停止-复制（Stop-and-copy）”清理法（将Eden区和一个Survivor中仍然存活的对象拷贝到另一个Survivor中），这不代表着停止复制清理法很高效，其实，它也只在这种情况下高效，如果在老年代采用停止复制，则挺悲剧的。

在Eden区，HotSpot虚拟机使用了两种技术来加快内存分配。分别是`bump-the-pointer`和`TLAB（Thread-Local Allocation Buffers）` *线程本地分配缓存* ，这两种技术的做法分别是：

* 指针碰撞：提高对连续内存的分配效率，由于Eden区是连续的，因此bump-the-pointer技术的核心就是跟踪最后创建的一个对象，在对 象创建时，只需要检查最后一个对象后面是否有足够的内存即可，从而大大加快内存分配速度；
* TLAB（线程本地分配缓存）：保证多线程在利用指针碰撞方式分配内存时的安全，本质是：在TLAB内部使用指针碰撞；TLAB技术是对于多线程而言的，将Eden区分为若干 段，每个线程使用独立的一段，避免相互影响。TLAB结合bump-the-pointer技术，将保证每个线程都使用Eden区的一段，并快速的分配内存。

## 老年代

老年代（Old Generation）：对象如果在新生代存活了足够长的时间而没有被清理掉（即在几次 Young GC后存活了下来），则会被复制到老年代，老年代的空间一般比新生代大，能存放更多的对象，在老年代上发生的GC次数也比新生代少。当老年代内存不足时， 将执行Major GC，也叫 Full GC。采用**标记-整理**算法。


什么时候触发 Full GC：老年代空间不足时，触发 Full GC，是发生在老年代的 GC

* Young GC 之前，检查老年代空间不足：触发 Full GC，先在老年代清理出一片空间，再进行 Young GC；
* 大对象直接进入老年代，老年代空间不足：触发 Full GC，清理出一片空间

总之：Full GC 的时间，就是，有对象要进入老年代，但，老年代空间不足。

所以，

* Full GC 通常伴随 Young GC
* Full GC 不一定伴随 Young GC








## 参考来源

* [Java 内存区域和GC机制][Java 内存区域和GC机制]







[NingG]:    http://ningg.github.com  "NingG"

[Java 内存区域和GC机制]:		http://www.cnblogs.com/hnrainll/archive/2013/11/06/3410042.html









