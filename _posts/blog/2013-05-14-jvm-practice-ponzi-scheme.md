---
layout: post
title: JVM 实践：GC 的 骗局
description: JVM 一直不停的 GC，不抛出 OOM 异常，无法正常提供服务，GC 欺骗了你
published: true
category: jvm
---


> 英文原文：[The Hotspot JVM is a Ponzi Scheme]


时不时的我就会听见有人抱怨说，他的HotSpot JVM不停的在垃圾回收，可是每次回收完后堆却还是满的。当他们发现这是因为JVM的内存已经不够了之后，通常会问这么个问题，为什么JVM不抛一个OutOfMemoryError(OOME)呢？毕竟来说，由于内存不足，我的程序都已经没法继续跑了，对吧？

先说重要的，如果你运气好的话，你永远不会发现你的JVM其实在你身上下了个庞氏骗局的套。它会一直告诉你，你的内存是无限的，就只管去用就好了。JVM的垃圾回收器会一直维持这么个错觉，在内存这一亩三分地上，啥事都好着呢。

然而在这个领域里可不止这一个庞氏骗局而已。操作系统处理内存也是这么副德性。你会不停的分配本地内存，直到最后触发了虚拟内存的交换，这下你就惨了——虽然程序没有完全停止，不过也差不多了，因为磁盘的速度跟内存比起来差太多了。

为了维持这个错觉，垃圾回收器会使用一个叫安全点（Safe Point)的咒语来冻结时间，应用程序根本不知道发生了什么。然而你的程序停止的时间长点是无所谓，但对于使用你的应用程序的人来说，时间可不是冻结的。如果你的应用程序的存活数据很多的话，垃圾回收器得费很大劲来维持这个错觉。你的程序可能不知道时间冻结得有多频繁，多久，但你的用户肯定知道！

由于你的程序相信你的JVM，而你的JVM也一直很努力，很英勇地（甚至有点傻）工作，来维持这种错觉，最后演出终于露馅的时候，你会想，为什么我的应用程序没有抛一个OOME出来呢？

## 使用ParNew新生代回收算法（和CMS配套使用）

我们来看一段GC日志，来看下能不能搞清楚是怎么回事，我们从一段大概10秒的日志的开头看起。

```
85.578: [GC 85.578: [ParNew: 17024K->2110K(19136K), 0.0352412 secs] 113097K->106307K(126912K), 0.0353280 secs]
```

这是一个正常完成的新生代并行回收的过程，通常这是由于新生代的 eden 区内存分配失败触发的。来看下里面的数据：

1. 所有的存活对象占用的空间是106307K
1. Survivor 区的已使用空间是2110K
1. 这说明老生代中的对象占用的空间是104197K(106307-2110)

我们再进一步的分析下：

1. 堆的总大小是126912K
1. 其中新生代的大小是19136K.
1. 这意味着老生代是107776K.

再稍微计算一下我们会发现，老生代是 `104197K/107776K` 也就是已经使用了 `97%` 了，这已经相当危险了！


## CMS 上场了

下面的一组日志表明，前面的 ParNew 回收是在一次 CMS 周期里执行的，而这次 CMS 已经完成了。不过这次 CMS 周期结束后紧接着又是一次 CMS。为什么呢，因为前面那次 CMS 只回收了 104197K-101397K = 2800K 内存，这大概只是老生代的 2.5%，于是只能继续 GC 了，但这暴露出一个严重的问题！

```
86. 306: [CMS-concurrent-abortable-preclean: 0.744/1.546 secs]86.306: [GC[YG occupancy: 10649 K (19136 K)]86.306: [Rescan (parallel) , 0.0039103 secs]86.310: [weak refs processing, 0.0005278 secs] [1 CMS-remark: 104196K (107776K)] 114846K (126912K), 0.0045393 secs]86.311: [CMS-concurrent-sweep-start]86.366: [CMS-concurrent-sweep: 0.055/0.055 secs]86.366: [CMS-concurrent-reset-start]86.367: [CMS-concurrent-reset: 0.001/0.001 secs]86.808: [GC [1 CMS-initial-mark: 101397K (107776K)] 119665K (126912K), 0.0156781 secs]
```

看来在这样的情况下，一个并发模式失败（Concurrent Mode Failure）的错误是必不可少的。

### 接下来是 Concurrent Mode Failure

下面这段日志说明，对于垃圾回收器来说，糟糕的事情发生了，CMS concurrent-mark 刚准备开始工作，而讨厌的 ParNew 又想把一堆数据提升到老生代来，但是现在空间已经不够了。

```
86. 824: [CMS-concurrent-mark-start]86.875: [GC 86.875: [ParNew: 19134K->19134K (19136K), 0.0000167 secs]86.875: [CMS87.090: [CMS-concurrent-mark: 0.265/0.265 secs] (concurrent mode failure): 101397K->107775K (107776K), 0.7588176 secs] 120531K->108870K (126912K), [CMS Perm : 15590K->15589K (28412K)], 0.7589328 secs]
```

更糟糕的是，ParNew 试图分配内存，于是 CMS 回收只能失败了（concurrent mode failure），为了不让程序知道发生了什么，以便让这个游戏继续下去，GC 决定使用它的杀手锏，Full GC。不过尽管用了这个大招，结果也并不妙，因为 Full GC 回收完后老生代还有 107775K 在使用而总的大小才只有 107776K！内存几乎是 100% 用完了。当然现在还能继续运行，因为新生代占用的 1095K (108870K-107775k)已经全塞到 survivor 区里了。这已经是千钧一发的时刻了，GC 为了维持这个庞氏骗局，只能继续垂死挣扎。

## 再来一次 Full GC

为了解决内存不足的问题，第二个 Full GC 现在上场了。这次发生在 JVM 启动后的 87.734 秒。前面一次暂停的时间是 0.7589328 秒。加上上次 Full GC 开始的时间 86.875 结果是 87.634 秒，也就是说应用程序只执行了 100ms 又开始被中断了。

这个英勇的行为为 GC 又赢取到了一次宝贵的时间，在下一次 CMS 开始之前，ParNew 的一次失败直接唤起了 Full GC,它还一直欺骗应用程序说现在一切都很好，其实不然。

```
87. 734: [Full GC 87.734: [CMS: 107775K->107775K (107776K), 0.5109214 secs] 111054K->109938K (126912K), [CMS Perm : 15589K->15589K (28412K)], 0.5110117 secs]
```

## 悲剧仍在继续

一轮又一轮的 CMS 以及伴随着的 concurrent mode failures 都表明了，虽然垃圾回收器还在力图维持局面，但说实话你得考虑下这个代价是不是有点太大了，这个时候是不是抛一个什么警告或者错误更好一些。


那么对 JVM 来说到底什么才是内存不足？

## 定义内存不足

显而易见，Java 堆的内存太小了，不足以维持应用程序的运行。大点的堆能让 GC 把这个庞氏骗局一直持续下去。不过应用程序并没有意味到问题的出现，但终端用户肯定是知道的。我们非常希望应用程序能在用户发觉之前发现这个问题。不幸的 是我们没有一个 AlmostOutOfMemoryError 的异常，不过我们可以通过调整 `GCTimeLimit` 和 `GCHeapFreeLimit` 参数来重新定义何时抛出 OutOfMemoryError 错误。

`GCTimeLimit` 的默认值是 `98%`，也就是说如果 98% 时间都用花在 GC 上，则会抛出 OutOfMemoryError。`GCHeapFreeLimit` 是回收后可用堆的大小。默认值是`2%`。

如果我们分析下 GC 日志里面的数据可以发现，GC 刚刚好没有超出这两个参数的阈值。因此 GC 会一直维持这个庞氏骗局。但是这两个值又设置的有点太武断了，你可以重新定义下它们，来告诉 GC，如果你这么努力工作就是为了维持这个错觉的话，或者你还是认输好一点，让应用程序能够知道它的内存已经用得差不多了。在这里把 `GCHeapFreeLimit` 设置成`5%`，`GCTimeLimit` 设置成 `90%`，来触发一个 OutOfMemoryError。这就能解释为什么应用程序这么久没有响应，也让这个庞氏骗局的受害者们知道，他们现在到底是什么情况。

## 总结

上面 JVM GC 欺骗的核心过程：

1. CMS：并发 GC 过程中
	1. 新生代对象：不断进入老年代，老年代空间不足 CMS 失败；
	2. 老年代 CMS 退化为：Serial Old 串行 GC，Stop-The-World；
2. Full GC 之后，因为满足条件，不会抛出 OOM
	1. 已经占用的 Heap 空间，未超过阈值（可用的 Heap 空间，满足 `GCHeapFreeLimit` (2%)）
	2. GC 时间占比，未超过阈值：`GCTimeLimit`（默认 98%）

解决办法：

1. CMS 垃圾收集器，降低 CMS 退化概率：
	1. 开启压缩，减少因为内存碎片，导致的 CMS 退化为 Serial Old 概率，具体参数：
	2. 降低触发 full gc 的阈值：老年代已使用内存空间占比。尽早进行 GC：`-XX:CMSInitiatingOccupancyFraction` 老年代空间占用比例，触发的阈值。默认：`68%` （Note：内存使用率增长较快，阈值调低，降低 CMS 退化风险；内存使用率增长较慢，阈值调高，减少 CMS 收集频率）
2. 调整 OOM 触发条件：`GCHeapFreeLimit`（可用空间占比）、`GCTimeLimit`（GC 时间占比）


Note：

> 老年代的 CMS 垃圾收集，可能会退化为 Serial Old，其中：
> 
> 1. CMS：默认，标记-清除；（*可以开启压缩*：`-XX:+UseCMSCompactAtFullCollection` 和 `-XX:CMSFullGCsBeforeCompaction` 多少次 full gc 进行一次压缩）
> 2. Serial Old：标记-清除-压缩

## 参考来源

* [The Hotspot JVM is a Ponzi Scheme]
* [HotSpot JVM GC 骗局]







[NingG]:    http://ningg.github.com  "NingG"

[The Hotspot JVM is a Ponzi Scheme]:		https://zeroturnaround.com/rebellabs/the-hotspot-jvm-is-a-ponzi-scheme-guest-post/
[HotSpot JVM GC 骗局]:		http://www.open-open.com/news/view/a169ce








