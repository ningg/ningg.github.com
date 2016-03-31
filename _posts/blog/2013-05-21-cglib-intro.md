---
layout: post
title: cglib-Code生成类库
description: 在运行过程中，动态生成类和接口的代码
published: true
categories: cglib spring
---


CGLib (Code Generation Library) 是一个强大的,高性能,高质量的Code生成类库。它可以在运行期扩展Java类与实现Java接口。Hibernate用它来实现PO字节码的动态生成。CGLib 比 Java 的 java.lang.reflect.Proxy 类更强的在于它不仅可以接管接口类的方法，还可以接管普通类的方法。

CGLib 的底层是Java字节码操作框架 —— ASM。



## 参考来源

* [Java动态代理 CGLib]
* [cglib动态代理介绍(一)]
* [cglib源码学习交流]

























[NingG]:    http://ningg.github.com  "NingG"


[Java动态代理 CGLib]:					http://www.oschina.net/p/cglib/
[cglib源码学习交流]:					http://blog.csdn.net/liulin_good/article/details/6411201
[cglib动态代理介绍(一)]:				http://blog.csdn.net/xiaohai0504/article/details/6832990






