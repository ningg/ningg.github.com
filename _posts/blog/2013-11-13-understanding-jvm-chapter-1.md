---
layout: post
title: 走进Java——Understanding the JVM
description: Java的特点、发展历程、当前发展定位
category: jvm
---

## Java几个特点

从Java语言的几个特点说起：

### 一次编写，到处执行

Java：`Write Once，Run Anywhere`，归根结底是在JVM上运行的。整体几个过程：

* 编写.java源文件
* 编译为.class字节码文件
* .class文件在JVM上运行

即，“一次编写，到处执行”的口号，实际是，有JVM的地方才能执行，因为其依赖于JVM。关于上述3个过程，有几个小问题：

* 直接用JVM执行.java文件不行吗？为什么需要.class文件？
* java语法
* class文件格式
* JVM怎么运行的class文件（加载过程）
* 利用class文件能否得到java文件



### 内存管理

Java提供相对安全的内存管理和访问机制，主要是几个术语：

* 垃圾回收
* 内存模型（数据摆放）
* 指针越界（引用，reference）

**疑问**：程序占用的内存，不用主动释放？例如：`obj = new Class()`;

### 热点代码

Java实现了热点代码检测、运行时编译及优化，能够实现：Java应用程序随应用运行时间的增加而获得更高的性能。

疑问：

* 一边运行，一边编译？JIT（Just In Time）及时编译器？
* 编译器的作用是什么？.class文件转换为二进制机器代码？



### 第三方类库

Java有丰富多样的第三方类库，实现各种功能。（举几个例子？）



## 两个名词：JDK、JRE

说两个术语JDK和JRE：

* JDK：Java Development Kit，Java开发工具集，是支持程序开发的最简环境，包含几个部分：
	* Java语言
	* JVM
	* Java API类库（自带）
* JRE：Java Runtime Env.，Java运行环境，是Java程序运行的标准环境，包含几个部分：
	* JVM
	* Java API类库中Java Standard Edition（Java SE）API子集

再说两个称呼吧：

* 在JDK 1.2	版本后，Java拆分为3个方向：
	* J2SE（Java 2 Plantform，Standard Edition）面向桌面应用开发；
	* J2EE（Java 2 Plantform，Enterprise Edition）面向企业级开发；
	* J2ME（Java 2 Plantform，Micro Edition）面向移动端开发；
* JDK 1.6 版本终结了上述J2XX的命名方式，对应启用如下命名：
	* Java SE 6；
	* Java EE 6；
	* Java ME 6；


## JDK的发展过程

* JAVA，1995年诞生；
* JDK 1.0（1996），纯解释执行的Java虚拟机实现（Classic VM）；
* JDK 1.2（1998），是个里程碑：
	* 拆分为J2SE、J2EE、J2ME共计3个方向；
	* 首次在JVM中内置JIT编译器；
* JDK 1.4（2002），新特性：
	* 正则表达式
	* 异常链
	* NIO
	* 日志类
	* XML解析器
	* XSLT转换器
* JDK 1.5（2004），重大改进：
	* 语法层面上，增强易用性：
		* 自动装箱？
		* 泛型？
		* 动态注解（有静态注解吗？）
		* 枚举？
		* 可变长参数？
		* 遍历循环（foreach循环）
	* 虚拟机和API层面上，重大改进;
		* Java的内存模型（Java Memory Model）？
		* 并发包：java.util.concurrent？
* JDK 1.6（2006），几个方面：
	* 命名上：
		* J2EE -- JAVA EE 6
		* J2SE -- JAVA SE 6
		* J2ME -- JAVA ME 6
	* 语法层面上：
		* 提供动态语言支持（通过内置Mozilla JavaScript Rhino引擎实现）
		* 提供编译API？
		* 微型HTTP服务器API？
	* Java虚拟机层面上：
		* 锁与同步
		* 垃圾收集
		* 类加载等的算法
	* 开源工作进展上：
		* 2006.11开始逐步开源JDK的各个组件
		* OpenJDK 1.7 与 Sun JDK 1.7 的代码基本一致


## JVM

几个熟知的Java Virtual Machine：

* Classic VM
* Exact VM
* HotSpot VM

### HotSpot VM

重点说一下HotSpot VM，两个点：

* 准确式内存管理（Exact Memory Management）
	* VM知道内存中某个位置的数据具体什么类型
	* 例如：123456是整型还是引用，如果将123456位置的数据移动，则知道内存中哪些123456需替换；
* 热点代码检测，具体：
	* 执行计数器
	* 找出最具编译价值的代码
	* JIT编译器以**方法**（Method）为单位，进行编译

**疑问**：编译器、解释器，作用是什么？（以java编写、执行过程来说明）

说一个有意思的：Java语言能够实现Java语言本身的运行环境吗？几个思考：

* 什么叫Java语言的运行环境？其提供什么作用？
* Java语言能够实现这一功能吗？

JVM，java运行环境，语言自身实现其运行环境，元循环，Meta-Circular，两个例子：JavaInJava虚拟机，Maxine VM。

### Google Android Dalvik VM

说几点吧，列一下清晰一些：

* Dalvik VM，只能被称为"虚拟机"，而不是"JAVA 虚拟机"
* Dalvik VM没有执行Java虚拟机规范
* 不能直接执行Java的Class文件
* 寄存器架构，不是JVM中常见的栈架构

Dalvik VM与Java之间有千丝万缕的联系：

* Dalvik VM的执行文件dex文件，可以通过class文件转换得到；
* 使用Java语法编写应用程序
* 可以直接使用大部分Java的API
* Android 2.2中已经实现及时编译器；

## JAVA当前重要进展

### 多核并行

#### 背景

CPU硬件的发展方向，已经从单CPU高频率转向为多核心，随着多核时代来临，软件开发越来越关注并行编程领域。

#### JAVA API与Lambda函数式编程

JDK 1.5中引入java.util.concurrent包，实现一个粗粒度的并发框架；JDK 1.7中引入java.util.concurrent.forkjoin包，Folk/Join模式是处理并行编程的经典方法。

**疑问**：Folk/Join模式，是经典的并行编程方法？怎么说？

极其重要进展：Java 8 中，提供Lambda函数式编程，函数式编程的重要有点是：程序天然的适合并行运行；这将有助于Java在多核时代继续保持主流语言的地位。


### 64位JVM

#### 背景

主流CPU开始支持64位架构，一个问题：32位、64位CPU是怎么衡量的？

#### 效果

64位虚拟机有什么好处？更多的计算资源？更多的内存空间？超过4G的内存空间，就必须要使用64位JVM？

与32位JVM相比，64位JVM几个地方需要考虑：

* 指针膨胀；
* 各种数据类型对齐补白；

上面的结果是：64位JVM占用更多内存（额外10%~30%）。*（具体什么原因？）*

## 编译自己的JDK

JDK的很多底层方法是本地化的（native），如何跟踪这些方法？需要编译一下JDK源码。


## 参考来源

* [深入理解Java虚拟机][深入理解Java虚拟机]


[深入理解Java虚拟机]:		http://book.douban.com/subject/24722612/
[NingG]:    				http://ningg.github.com  "NingG"
