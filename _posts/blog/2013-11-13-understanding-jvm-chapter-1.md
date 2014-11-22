---
layout: post
title: Understanding the JVM——Chapter 1：走进Java
description: 
category: jvm
---

##Java几个特点

从Java语言的几个特点说起：

###一次编写，到处执行

Java：`Write Once，Run Anywhere`，归根结底是在JVM上运行的。整体几个过程：

* 编写.java源文件
* 编译为.class字节码文件
* .class文件在JVM上运行

即，“一次编写，到处执行”的口号，实际是，有JVM的地方才能执行，因为其依赖于JVM。关于上述3个过程，有几个小问题：

* java语法
* class文件格式
* JVM怎么运行的class文件（加载过程）
* 利用class文件能否得到java文件

###内存管理

Java提供相对安全的内存管理和访问机制，主要是几个术语：

* 垃圾回收
* 内存模型（数据摆放）
* 指针越界（引用，reference）

###热点代码

Java实现了热点代码检测、运行时编译及优化，能够实现：Java应用程序随应用运行时间的增加而获得更高的性能。

###第三方类库

Java有丰富多样的第三方类库，实现各种功能。（举几个例子？）

##两个名词：JDK、JRE

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








##参考来源





[NingG]:    http://ningg.github.com  "NingG"
