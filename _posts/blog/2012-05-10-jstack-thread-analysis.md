---
layout: post
title: jstack对运行的Thread进行分析
description: 分析当前JVM运行情况
published: true
category: java
---


当Java应用运行时，如果CPU占用高，此时，需要对应用的性能进行分析，简要步骤如下：

* top命令 - O/F ：查看哪个Process占用大量CPU，记录pid；
* `top -H -p [pid]`：查看Process内部Thread的运行情况，重点记录排在前面运行的Thread；
* `jstack -l [pid] > [pid].stack`：获得对应pid下Thread的详细情况；
* `jmap [pid]`：查看内存堆栈信息；
* `vmstat`：查看机器状态，特别是排队线程个数

`vmstat`命令查看得到的机器状态如下：

![](/images/jstack-thread-analysis/vmstat.png)

vmstat来看看机器的情况，发现当前的排队线程有时高达76，低时也有10个以上，已经超出了CPU数。既然是线程的情况，就重新执行`jstack -l [pid] > [pid].stack`，来详细分析Waiting的线程。


思考：

* vmstat输出结果参数的含义？
* jstack、jmap详解；（JVM性能调优工具）














##参考来源

* [一个Tomcat高CPU占用问题的定位][一个Tomcat高CPU占用问题的定位]















[NingG]:    http://ningg.github.com  "NingG"

[一个Tomcat高CPU占用问题的定位]:		http://www.jmatrix.org/java/771.html









