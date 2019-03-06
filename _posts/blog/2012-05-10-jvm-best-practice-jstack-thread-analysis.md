---
layout: post
title: JVM 实践：jstack对运行的 Thread 进行分析
description: 分析当前JVM运行情况
published: true
categories: jvm
---


当Java应用运行时，如果CPU占用高，此时，需要对应用的性能进行分析，简要步骤如下：

1. 定位进程
2. 定位线程
3. 输出线程的调用栈
4. 根据调用栈，分析代码，进行优化

具体操作：

* `top` 命令 - P/M ：查看哪个Process占用大量CPU，记录PID；
	* `top` 命令， 选中 `%CPU`，然后 `s` 选中这一字段进行排序
	* `top` 命令下， `c` 命令，则，显示完整的 command 执行参数
* `top -H -p [pid]`：查看Process内部Thread的运行情况，重点记录排在前面运行的Thread；
* `jstack -l [pid] > [pid].stack`：获得对应pid下Thread的详细情况；
* `jmap [pid]`：查看内存堆栈信息；
* `vmstat`：查看机器状态，特别是排队线程个数

`vmstat`命令查看得到的机器状态如下：

![](/images/jstack-thread-analysis/vmstat.png)

vmstat来看看机器的情况，发现当前的排队线程有时高达76，低时也有10个以上，已经超出了CPU数。既然是线程的情况，就重新执行`jstack -l [pid] > [pid].stack`，来详细分析Waiting的线程。

Note：`r` 运行态的线程数量，`b` 阻塞状态的线程数量。

## 1.查看进程

top命令`top` -- `P/M` （按照 `CPU` or `MEM` 排序），结果：

```
  PID USER      PR  NI  VIRT  RES  SHR S %CPU %MEM    TIME+  COMMAND                                                                   
 4796 storm     20   0 9935m 264m  13m S 134.5  0.8   3745:18 java  
```

## 2.查看线程

top命令`top -H -p 4796`，结果：

	PID USER      PR  NI  VIRT  RES  SHR S %CPU %MEM    TIME+  COMMAND                                                                     
	4967 storm     20   0 3582m 256m  12m S  0.7  0.8  72:37.82 java
	4915 storm     20   0 3582m 256m  12m S  0.3  0.8   7:44.29 java      

	
## 3.分析线程调用栈

4967是最耗CPU的线程，转换成16进制1367，再用`jstack`命令查看线程堆栈：

	[storm@cib02166 temp]$ jstack -l 4796 | grep 1367 -A 20 
	"Thread-2" prio=10 tid=0x00007f7194445800 nid=0x1367 waiting on condition [0x00007f7170ccb000]
	   java.lang.Thread.State: WAITING (parking)
		at sun.misc.Unsafe.park(Native Method)
		- parking to wait for  <0x00000000f07f4178> (a java.util.concurrent.locks.AbstractQueuedSynchronizer$ConditionObject)
		at java.util.concurrent.locks.LockSupport.park(LockSupport.java:186)
		at java.util.concurrent.locks.AbstractQueuedSynchronizer$ConditionObject.await(AbstractQueuedSynchronizer.java:2043)
		at java.util.concurrent.LinkedBlockingQueue.take(LinkedBlockingQueue.java:442)
		at backtype.storm.event$event_manager$fn__2467.invoke(event.clj:39)
		at clojure.lang.AFn.run(AFn.java:24)
		at java.lang.Thread.run(Thread.java:745)

	   Locked ownable synchronizers:
		- None

	"Thread-1" prio=10 tid=0x00007f7194507800 nid=0x1366 waiting on condition [0x00007f71710cf000]
	   java.lang.Thread.State: WAITING (parking)
		at sun.misc.Unsafe.park(Native Method)
		- parking to wait for  <0x00000000f07e2e90> (a java.util.concurrent.locks.AbstractQueuedSynchronizer$ConditionObject)
		at java.util.concurrent.locks.LockSupport.park(LockSupport.java:186)
		at java.util.concurrent.locks.AbstractQueuedSynchronizer$ConditionObject.await(AbstractQueuedSynchronizer.java:2043)
		at java.util.concurrent.LinkedBlockingQueue.take(LinkedBlockingQueue.java:442)  __
	

补充说明：如果是 docker 容器启动的 JVM， 则，需要先进入 docker 容器，再执行 jstack：

```
# 执行下述命令，进入 docker 容器
$ dockert -it [container] /bin/bash
```

## 备注

几点：

* 更通用：top + jstack
* 更方便：Jprofiler和java自带的可视化工具




思考：

* vmstat输出结果参数的含义？ 详细参考：[vmstat 命令参数详解
](http://blog.csdn.net/zhuying_linux/article/details/7336869)
* jstack、jmap详解；（JVM性能调优工具）






## 参考来源

* [一个Tomcat高CPU占用问题的定位][一个Tomcat高CPU占用问题的定位]
* [top命令](/linux-top/)









[NingG]:    http://ningg.github.com  "NingG"

[一个Tomcat高CPU占用问题的定位]:		http://www.jmatrix.org/java/771.html









