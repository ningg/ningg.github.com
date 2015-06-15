---
layout: post
title: Java中Class和Object
description: 
category: java
---

class与object之间：

* 什么含义；
* 什么时候使用；

##class

**疑问**：几点：

* Class是什么？
* 什么情况下使用Class?

使用Class的几个场景：

* slf4j绑定Class时
	* Logger logger = LoggerFactory.getInstance(Class);

常用 3 种方式：

* Object.getClass()；
* 类名后添加`.class`后缀；
* Class.forName("fully-qualified name of a class")；



更多解释参考：[Retrieving Class Objects][Retrieving Class Objects]



##Object


Java中，Object是所有类的父类，可以显式继承Object类，也可以隐式继承Object类。


###Object类的方法

Object自带的方法：

* getClass()：获取运行时类
* clone()：完成对象的复制
* equals()：默认判断`==`，基本类型的值、对象的引用地址，
* hashCode()：获取对象hashcode，方便HashTable
* toString()：对象的字符串表示
* wait()：当前线程，挂起等待
* notify()：唤醒其他在当前对象上等待的一个线程
* notifyAll()：唤醒其他在当前对象上等待的所有线程，此时，多线程并发访问，不一定是线程安全的；
* finalize()：GC时，当确定该对象的引用不存在时，由垃圾回收器调用；


###clone()方法

一个对象调用`clone()`方法，要求类必须继承`Cloneable`接口。

####深克隆 vs. 浅克隆

如果对象中有其他对象的引用，使用浅拷贝无法完成对象的整个克隆，因为如果使用浅拷贝，只是对象的引用得到的拷贝，而两个引用是指向了同一个对象，对其中一个修改还是会影响到另外一个对象。这时后我们需要引入深拷贝，深拷贝实现起来也比较简单，只需要对对象中的对象再次进行clone操作。



###equals()方法

equals方法，需要满足以下三点： 

1. 自反性：就是说a.equals(a)必须为true。 
1. 对称性：就是说a.equals(b)为true的话，b.equals(a)也必须为true。 
1. 传递性：就是说a.equals(b)为true，并且b.equals(c)为true的话，a.equals(c)也必须为true。 


###hashCode()方法

重写hashCode()的原则： 

* **不唯一原则**：不必对每个不同的对象都产生一个唯一的hashcode，只要你的HashCode方法使get()能够得到put()放进去的内容就可以了。
* **分散原则**：生成hashcode的算法尽量使hashcode的值分散一些，不要很多hashcode都集中在一个范围内，这样有利于提高HashMap的性能；
* a.equals(b)，则a与b的hashCode()必须相等；

















##参考来源

* [Retrieving Class Objects][Retrieving Class Objects]
* [Java中equals方法，判断两个对象是否相等]
* [java中的Clone（深拷贝，浅拷贝）]
* [java中Object类 源代码详解][java中Object类 源代码详解]





[NingG]:    http://ningg.github.com  "NingG"


[Retrieving Class Objects]:							http://docs.oracle.com/javase/tutorial/reflect/class/classNew.html
[Java中equals方法，判断两个对象是否相等]:			http://ningg.top/java-equal/
[java中的Clone（深拷贝，浅拷贝）]:					http://blog.csdn.net/centre10/article/details/6847973
[java中Object类 源代码详解]:						http://www.cnblogs.com/langtianya/archive/2013/01/31/2886572.html






