---
layout: post
title: Java 剖析：String、StringBuffer、StringBuilder
description: Java中字符串相关内容梳理
published: true
category: java
---

我们先要记住三者的特征：

* String 字符串常量
* StringBuffer 字符串变量（线程安全）
* StringBuilder 字符串变量（非线程安全）

## 一、定义

查看API会发现，String、StringBuffer、StringBuilder都实现了 CharSequence接口，虽然它们都与字符串相关，但是其处理机制不同。

* String：
	* 是字符串常量；
	* final class，不能被继承；
	* 内部`final char[] value`，字符数组常量；
* StringBuffer：
	* 字符串变量；
	* 线程安全
	* final class，不能被继承；
	* 内部 `char[] value`，可以进行扩容，字符数组变量；*（实际上，为数组分配新的堆内存、销毁原数组空间）*
* StringBuilder：
	* 与StringBuffer类基本相同：
		* final class
		* 字符串变量
		* 内部 `char[] value`，可以进行扩容，字符数组变量
	* 非线程安全；

在性能方面，由于String类的操作是产生新的String对象，而StringBuilder和StringBuffer只是一个字符数组的扩容而已，所以String类的操作要远慢于StringBuffer和StringBuilder。

## 二、使用场景

几点：

* String：在字符串不经常变化的场景中可以使用String类，例如常量的声明、少量的变量运算。
* StringBuffer：在频繁进行字符串运算（如拼接、替换、删除等），并且运行在**多线程环境**中，则可以考虑使用StringBuffer，例如XML解析、HTTP参数解析和封装。
* StringBuilder：在频繁进行字符串运算（如拼接、替换、和删除等），并且运行在**单线程的环境**中，则可以考虑使用StringBuilder，如SQL语句的拼装、JSON封装等。

## 三、分析

简要的说， String 类型和 StringBuffer 类型的主要性能区别其实在于 String 是不可变的对象, 因此在每次对 String 类型进行改变的时候其实都等同于生成了一个新的 String 对象，然后将指针指向新的 String 对象。所以经常改变内容的字符串最好不要用 String ，因为每次生成对象都会对系统性能产生影响，特别当内存中无引用对象多了以后， JVM 的 GC 就会开始工作，那速度是一定会相当慢的。

而如果是使用 StringBuffer 类则结果就不一样了，每次结果都会对 StringBuffer 对象本身进行操作，而不是生成新的对象，再改变对象引用。所以在一般情况下我们推荐使用 StringBuffer ，特别是字符串对象经常改变的情况下。而在某些特别情况下， String 对象的字符串拼接其实是被 JVM 解释成了 StringBuffer 对象的拼接，所以这些时候 String 对象的速度并不会比 StringBuffer 对象慢，而特别是以下的字符串对象生成中， String 效率是远要比 StringBuffer 快的：

	String S1 = “This is only a" + “ simple" + “ test";
	StringBuffer Sb = new StringBuilder(“This is only a").append(“ simple").append(“ test");

你会很惊讶的发现，生成 String S1 对象的速度简直太快了，而这个时候 StringBuffer 居然速度上根本一点都不占优势。其实这是 JVM 的一个把戏，在 JVM 眼里，这个

`String S1 = “This is only a" + “ simple" + “test";`其实就是：`String S1 = “This is only a simple test";`

所以当然不需要太多的时间了。但大家这里要注意的是，如果你的字符串是来自另外的 String 对象的话，速度就没那么快了，譬如：

	String S2 = "This is only a";
	String S3 = "simple";
	String S4 = "test";
	String S1 = S2 +S3 + S4;

这时候 JVM 会规规矩矩的按照原来的方式去做。

## 四、结论

**1. 在大部分情况下 StringBuffer > String**

Java.lang.StringBuffer是线程安全的可变字符序列。一个类似于 String 的字符串缓冲区，但不能修改。虽然在任意时间点上它都包含某种特定的字符序列，但通过某些方法调用可以改变该序列的长度和内容。在程序中可将字符串缓冲区安全地用于多线程。而且在必要时可以对这些方法进行同步，因此任意特定实例上的所有操作就好像是以串行顺序发生的，该顺序与所涉及的每个线程进行的方法调用顺序一致。

StringBuffer 上的主要操作是 append 和 insert 方法，可重载这些方法，以接受任意类型的数据。每个方法都能有效地将给定的数据转换成字符串，然后将该字符串的字符追加或插入到字符串缓冲区中。append 方法始终将这些字符添加到缓冲区的末端；而 insert 方法则在指定的点添加字符。

例如，如果 z 引用一个当前内容是“start"的字符串缓冲区对象，则此方法调用 z.append("le") 会使字符串缓冲区包含“startle"(累加);而 z.insert(4, "le") 将更改字符串缓冲区，使之包含“starlet"。

**2. 在大部分情况下 StringBuilder > StringBuffer**

java.lang.StringBuilder一个可变的字符序列是JAVA 5.0新增的。此类提供一个与 StringBuffer 兼容的 API，但不保证同步，所以使用场景是单线程。该类被设计用作 StringBuffer 的一个简易替换，用在字符串缓冲区被单个线程使用的时候（这种情况很普遍）。如果可能，建议优先采用该类，因为在大多数实现中，它比 StringBuffer 要快。两者的使用方法基本相同。



## 五、String详解


几点：

* equals方法：
	* `str1.equals(str2)`判断两个字符串内容是否相等；
	* `str1 == str2`，比较两个字符串的引用是否相等，即，内存中地址位置是否相等；
* intern方法：
	* 判断String对应字符数组，是否在常量池中存在，如果存在，则返回常量池中的引用；
	* `String str1 = "abc";`编译期，确定为常量，会在常量池中放置`abc`的字符数组，并且将引用返回给`str1`;
	* `String str2 = new String("abc");`编译期无法确认为常量，因此，在JVM 堆中放置`abc`的字符数组，并且将引用返回给`str2`;
	* `str1 == str2`为false，`str1 == str2.intern()`为true；












[NingG]:    http://ningg.github.com  "NingG"











