---
layout: post
title: Understanding the JVM：Java中对象产生初始化过程
description: 父类什么时候初始化？构造函数和类变量呢？
category: jvm
---

## 实例

直接看下面代码：

	class Parent {
		static {
			System.out.println("---static Parnet---");
		}

		public Parent() {
			System.out.println("----Parent----");
		}
	}

	class Child extends Parent {
		static Other other = new Other();

		public Child() {
			System.out.println("----Child-----");
		}

		Brother b = new Brother();
	}

	class Brother {
		static {
			System.out.println("---static Brother---");
		}

		public Brother() {
			System.out.println("----Brother----");
		}
	}

	class Other {
		static {
			System.out.println("---static Other---");
		}

		public Other() {
			System.out.println("---Other---");
		}
	}

	public class Test {
		public static void main(String[] args) {
			 Child child=new Child();
		}
	}

运行结果：

	---static Parnet---
	---static Other---
	---Other---
	----Parent----
	---static Brother---
	----Brother----
	----Child-----

具体解释：

![](/images/understanding-jvm/java-object-init.png)


简单总结一下：

1. `父类优先`：
	1. 父类的 Class，优先
	2. 父类的成员对象和构造函数，优先
2. `类优先`：静态方法和静态对象
3. `对象`：
	1. 普通成员：初始化
	2. 构造函数

### 创建对象

在 Java 语言层面上，我们创建一个对象是如此简单：`ClassA intance = new ClassA();` 但是在虚拟机内部，其实经历了非常复杂的过程才完成了这一个程序语句。

* 虚拟机遇到一条 new 指令时，首先将去检查这个指令的参数是否能在**常量池中定位到一个类的引用**，并且检查这个符号引用代表的**类是否已经被加载、解析和初始化过**。如果没有，就得执行类的加载过程；
* 类加载检查过之后，**虚拟机就为这个新生对象分配内存**。目前有两种做法，使用哪种方式是由 GC 回收器是否带有压缩整理功能决定的:
	* **指针碰撞（Bump the Pointer）**：没用过的内存和用过的内存用一个指针划分（所以需要保证 java 堆中的内存是整理过的，一般情况是使用的 GC 回收器有 compact 过程），假如需要分配8个字节，指针就往空闲内存方向，挪8个字节；
	* **空闲列表（Free List）**：虚拟机维护一个列表，记录哪些内存是可用的，分配的时候从列表中遍历，找到合适的内存分配，然后更新列表


上面解决了分配内存的问题，但是也引入了一个新的问题：并发！！！

就刚才的一个修改指针操作，就会带来隐患：对象 A 正分配内存呢，突然！！对象 B 又同时使用了原来的指针来分配 B 的内存。解决方案也有两种：

* **同步处理**——实际上虚拟机采用 CAS 配上失败重试来保证更新操作的原子性
* **把内存分配的动作按照线程划分在不同的空间之中进行**，即每个线程在 Java 堆中预先分配一小块内存，成为**本地线程分配缓存（Thread Local Allocation Buffer，TLAB）**。哪个线程要分配内存，就在哪个线程的 TLAB 上分配，用完并分配新的TLAB时，才需要同步锁定（虚拟机是否使用 TLAB，可以通过`-XX:+/-UseTLAB` 参数来设置）

好了，上面给内存分配了空间，那么**内存清零**放在什么时候呢？一种情况是分配 TLAB 的时候，就对这块分配的内存清零，或者可以在使用前清零，这个自己实现。

接下来要对对象进行必要的设置，比如

* 这个对象是哪个类的实例
* 如何才能找到类的元数据信息
* 对象的 hashcode 值是多少
* 对象的 GC 分代年龄等信息

这些信息都放在对象头中。

> HotSpot VM，使用上面的字节码规范，对象的头部，包含了指向的类对象地址，因此，属于`直接引用`方式，访问对象；策略上，还有另一种方式：`对象句柄`访问对象。

上面的步骤都完成后，从虚拟机角度来看，一个新的对象已经产生了，但是从 Java 程序的视角来看，对象创建才刚刚开始——方法还没有执行，所有的字段都还为零。而这个过程又是一个非常复杂过程，具体可以参考前面的文章，讲解 Java 的对象是如何初始化的。从编译阶段的 constantValue 到准备阶段、初始化阶段、运行时阶段都有涉及。

**继续**：Java对象创建之后，如何初始化？



### 对象的内存中布局


首先我们要知道的是：在 HotSpot 虚拟机中，对象在内存中存储的布局可以分为3块区域：**对象头（Header）、实例数据（Instantce Data）、对齐补充（Padding）**。当然，我们不必要知道太深入，大概知道每个部分的作用即可：

* 对象头（Header）：包含两部分信息
	* 第一部分用于存储**对象自身的运行时数据**，如 hashcode 值、GC 分代的年龄、锁状态标志、线程持有的锁等，官方称为“Mark Word”。
	* 第二部分是**类型指针**，即**对象指向它的类元数据的指针**，虚拟机通过这个指针来确定这个对象是哪个类的实例
* 实例数据（Instance Data）：就是程序代码中所定义的各种类型的字段内容
* 内存对齐：这个在前面博文中已经说过好多次了，不懂的可以去看看即可




### 对象的访问定位

对象的访问定位，这个问题要好好整理一下，特别是两个配图。

如何访问对象实例呢？也就是说，如何找到对象实例？两种方式：

*（[insideJVM ed 2-Chapter 5](http://www.artima.com/insidejvm/ed2/jvm6.html)）有详细的配图和介绍，还没有细看*

#### 使用句柄

一个对象实例，需要对象的类数据*（类型数据）*、对象的实例数据，两类数据共同实现一个对象实例。

**使用句柄**：Java Heap中开辟一个句柄池，JVM Stack中对象reference就是一个句柄，每个句柄指向对象地址和类地址；

![](/images/understanding-jvm/reference-pool.jpg)

**疑问**：对象引用、对象句柄，是什么？

* `对象引用`：指向对象实例；
* `对象句柄`：包含对象引用、类的引用；

#### 直接指针

**直接指针**：JVM Stack中对象reference直接指向对象的实例数据，同时，对象实例数据指向类数据。

![](/images/understanding-jvm/direct-reference.jpg)



#### 使用句柄 vs. 直接指针

两种方式的目的相同：找到对象实例，并访问对象实例。由于实现方式不同，有如下差异：

* 使用句柄，访问对象实例，好处：reference中存储的是稳定的句柄地址，不会随着GC 对象位置的移动发生改变，只需要调整句柄中对象实例的地址；
* 直接指针，访问对象实例，好处：访问速度快，节省了一次指针定位的时间开销；**Sun HotSpot VM使用直接指针方式访问对象**；




[java中对象产生初始化过程]:			http://blog.csdn.net/mashangyou/article/details/24529583
[Java中类的初始化顺序总结]:			http://blog.csdn.net/jinyongqing/article/details/7631788






