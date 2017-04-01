---
layout: post
title: Understanding the JVM：JVM性能监控与故障处理工具
description: 如何监控JVM性能？如何进行故障定位？进程还是线程？
category: jvm
---


## 概述

对常用的jdk命令不太熟悉，只能简单使用jstack分析一下CPU消耗，感觉还是系统学习一下比较好；首先列举6个命令行工具：

* jps：JVM Process Status Tool，显示指定系统内所有的HotSpot虚拟机进程
* jstat：JVM Statistics Monitoring Tool，用于收集HotSpot虚拟机各方面的运行数据
* jinfo：Configuration Info for Java，显示虚拟机配置信息
* jmap：Memory Map for Java，生成虚拟机的内存转储快照(heap dump文件)
* jhat：JVM Heap Dump Browser，用于分析heap dump文件，会建立一个HTTP/HTML服务器，让用户可以在浏览器查看分析结果
* jstack：Stack Trace for Java，显示虚拟机的线程快照

然后还有两个GUI工具：

* jconsole：略微过时的JVM各状态查看工具
* visualVM：Sun出品的强大的JVM工具，推荐使用！

## 1. jps：虚拟机进程状况工具

首先，jps的全称是JVM Process Status Tool，和Unix的ps命令有类似功能：

> 它可以列出正在运行的虚拟机进程PID，并显示虚拟机执行主类（Main Claas，main()函数所在的类）的名称，以及这些进程的内地虚拟机的唯一ID（LVMID，Local Virtual Machine Identifier）。

命令格式：`jps [options] [hostid]`

举个例子:

* 输入`jps -l`后，显示结果为：5912 org.apache.catalina.startup.Bootstrap，前面的5912就是java的pid，后面是Main Class的名称。
* 输入`jps -v`后，显示结果会在上面基础上列出各个**虚拟机启动的JVM参数**，这个很有用！！！

说白了，jps会列出当前所有的Java进程。这个命令非常简单，但是很好用。比如你启动了多个tomcat进程，使用`jps -l`就可以得到所有tomcat进程的pid。然后再使用下面的命令对相应的tomcat进程进行分析。


## 2. jstat：虚拟机统计信息监视工具

jstat的全称是JVM Statistics Monitoring Tool，它用于监视**虚拟机各种运行状态信息**。可以显示**本地或远程虚拟机进程中的类装载、内存、垃圾收集、JIT编译等运行数据**，在没有GUI图形界面，只提供纯文本控制台环境的服务器上，它将是运行期定位虚拟机性能问题的首选工具。

具体命令格式：

	$ jstat -help
	Usage: jstat -help|-options
		   jstat -<option> [-t] [-h<lines>] <vmid> [<interval> [<count>]]

	Definitions:
	  <option>      An option reported by the -options option
	  <vmid>        Virtual Machine Identifier. A vmid takes the following form:
						 <lvmid>[@<hostname>[:<port>]]
					Where <lvmid> is the local vm identifier for the target
					Java virtual machine, typically a process id; <hostname> is
					the name of the host running the target Java virtual machine;
					and <port> is the port number for the rmiregistry on the
					target host. See the jvmstat documentation for a more complete
					description of the Virtual Machine Identifier.
	  <lines>       Number of samples between header lines.
	  <interval>    Sampling interval. The following forms are allowed:
						<n>["ms"|"s"]
					Where <n> is an integer and the suffix specifies the units as
					milliseconds("ms") or seconds("s"). The default units are "ms".
	  <count>       Number of samples to take before terminating.
	  -J<flag>      Pass <flag> directly to the runtime system.

`jstat -options`对应的选项：

	$ jstat -options
	-class
	-compiler
	-gc
	-gccapacity
	-gccause
	-gcnew
	-gcnewcapacity
	-gcold
	-gcoldcapacity
	-gcpermcapacity
	-gcutil
	-printcompilation




假如我想监控gc，每250ms查询一次，一共查询20次，进程号为1234。命令就是:`jstat -gc 5912 250 20`。那么，如果是远程机器又该如何做呢？很简单，使用`jstatd`。和mysql类似，`mysql`是客户端，`mysqld`是服务器端。所以当远程机器开始了`jstatd`，就相当于开启了远程虚拟机进程的监控，本地可通过RMI查看远程机器的运行时数据，非常方便。

	$ jstat -gc 5912 250 20
	 S0C    S1C    S0U    S1U      EC       EU        OC         OU       PC     PU    YGC     YGCT    FGC    FGCT     GCT
	4288.0 1920.0  0.0   1919.5 23936.0   7214.3   31744.0     4592.5   21248.0 16440.1      5    0.045   0      0.000    0.045
	4288.0 1920.0  0.0   1919.5 23936.0   7214.3   31744.0     4592.5   21248.0 16440.1      5    0.045   0      0.000    0.045


在这里，option主要分为3类：

* 类装载
* 垃圾收集
* 运行期编译状况

具体选项很简单，man一下即可。

比如我们想详细了解一下当前JVM的内存使用情况，就可以使用看下各个内存区域的使用率。`jstat -gcutil 5912`（前面统计generation占用，单位为百分比；后面统计次数和时间，单位为s）

	$ jstat -gcutil 5912
	S0     S1     E      O      P     YGC     YGCT    FGC    FGCT     GCT
	0.00  99.98  32.15  14.47  77.38      5    0.045     0    0.000    0.045

## 3. jinfo：Java配置信息工具

jinfo全称为Configuration Info for Java，它的作用是**实时地查看和调整虚拟机的各项参数**。

命令格式：`jinfo [ option ] pid`，详细信息如下：

	$ jinfo -h
	Usage:
		jinfo [option] <pid>
			(to connect to running process)
		jinfo [option] <executable <core>
			(to connect to a core file)
		jinfo [option] [server_id@]<remote server IP or hostname>
			(to connect to remote debug server)

	where <option> is one of:
		-flag <name>         to print the value of the named VM flag
		-flag [+|-]<name>    to enable or disable the named VM flag
		-flag <name>=<value> to set the named VM flag to the given value
		-flags               to print VM flags
		-sysprops            to print Java system properties
		<no option>          to print both of the above
		-h | -help           to print this help message

举例：

* 查询参数可以使用`jinfo -flag PrintGCDetails 5912`，是时候抛弃上面提到的`java -XX:+PrintFlagsFinal | grep PrintGCDetails`了。
* 比较牛逼的是，jinfo可以**在运行期修改参数**（当然，必须是jvm可以在运行期可写的参数了），比如`jinfo -flag +PrintGCDetails`就可以加上打印GC日志的功能了。

## 4. jmap：Java内存映像工具

jmap全称为Memory Map for Java，它用于**生成堆的转储快照**（一般称为heap dump或者dump文件）。当然，jmap的作用并不仅仅是为了**获取dump文件供其他工具分析当前JVM的内存情况**，它还可以**查询finalize执行队列，Java堆和永久代的详细信息，如空间使用率、当前用的是哪种收集器等**。它的命令格式为：`jmap [ option ] vmid`

常用的几个选项我直接列出来吧：

* `-dump`:生成heap dump文件。格式为`jmap -dump:[live,]format=b,file=,`其中live是否只dump存活的对象
* `-finalizeinf`o:显示在F-Queue中等待finalizer线程执行finalize方法的对象
* `-heap`：显示java堆的详细信息，比如使用**哪种回收器、参数配置、分代状况**等等
* `-histo`：显示堆中对象统计信息，包括类、实例数量和合计容量
* `-permstat`:以ClassLoader为统计口径显示永久代内存状态

比如我得到dump快照，就可以先通过jps拿到虚拟机的LVMID，然后使用`jmap -dump:format=b,file=haha.bin <LVMID>`就可以了。这里我在MacOS下，dump出了eclipse的heap dump文件，大小为83M。可以供下面jhat分析使用。

## 5. jhat：虚拟机堆转储快照分析工具

上面我们使用jmap得到了dump快照，而jhat就是分析dump快照的利器。它的全称是JVM Heap Analysis Tool，。jhat内置了一个微型的HTTP/HTML服务器，生成dump文件的分析结果后，可以在浏览器中查看。但一般情况下，这个命令使用的几率不会太大。首先对于线上服务器来说，生成dump快照后，分析快照是一个很耗时且吃硬件的过程，如果dump快照过于复杂，甚至会影响线上服务。记得我在网上看过这个方法，然后在我们线上服务器用jmap生成了heap dump文件，发现dump文件大概有10G。用jhat一分析，服务器瞬间就报警了= =，于是赶紧kill了。。。作者建议是将这个dump快照拷贝到线下，然后使用更强大的GUI工具来直观分析，比如Eclipse Memory Analyzer、IBM HeapAnalyzer等工具。但是对于超过5G的dump，一般是打不开的。。。。。。我已经尝试了好多次了，都打不开。

如果打开后，可以在本地localhost:7000查看结果。拉到最下面有个Heap Histogram，点进去就可以看到虚拟机中所有对象实例的数目和大小。


## 6. jstack：Java堆栈跟踪工具

jstack全称为Stack Trace for Java，它用于生成虚拟机当前时刻的线程快照（一般称为threaddump或者javacore文件）。**线程快照**就是当前虚拟机内存**每一个线程正在执行的方法堆栈的集合**。生成线程快照的主要目的就是**定位线程出现长时间停顿的原因**，比如线程间死锁、死循环、请求外部资源导致的长时间等待都是导致线程长时间停顿的常见原因。比如上次我们线上的一个HashMap造成的死循环，就是用jstack分析出来的。

Tips：

> 在JDK 1.5中，java.lang.Thread类新增了一个叫做`getAllStackTraces()`方法用于获取虚拟机中所有线程的StackTraceElement对象，可以通过这个方法做一个管理员界面，用JSP可以随时查看当前服务的线程堆栈。

## 7. JDK的可视化工具

JDK除了提供大量的命令行工具外，还提供了两个功能强大的可视化工具：**JConsole**和**VisualVM**，这两个工具是JDK的正式成员，而很搞笑的是，上面介绍的JDK工具，都被贴上了"Unsupported and experimental"的标签= =

其实现在**Sun主推VisualVM**了，因为JConsole稍微有点老。而且可视化工具基本不需要学习，稍微看看就知道啥情况。说白了就是把上面的jdk工具，比如jstat、jmap、jstack结果套个GUI。运行`${JDK_HOME}/bin/jvisualvm`即启动VisualVM。

Bingo：

> 其中看了感觉比较有价值的是BTrace这个插件，它竟然可以动态的在项目中插入调试信息，想想我们停掉服务、加调试代码、重启，太low了啊。有空得学习一下visualVM。










[深入理解Java虚拟机 - 第四章、JVM性能监控与故障处理工具]:			http://github.thinkingbar.com/jvm-iv/







