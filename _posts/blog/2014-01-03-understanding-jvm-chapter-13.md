---
layout: post
title: Understanding the JVM：线程安全与锁优化
description: 线程安全，锁优化机制
category: jvm
---


## 前言

这一章是讲线程安全和锁优化的，其中线程安全确实是一个和程序息息相关的问题，而锁优化是为了使JVM的效率更好。所以本章的重点放在**线程安全**这一点。*（多线程实现程序的并发执行，提升运行效率，但多线程时，需要解决线程安全问题）*

随着计算机技术的发展，追求更高性能的服务越来越重要。但是问题也随之而来，因为性能提升是建立在并发的基础上，而并发遇到的数据同步问题又非常令人头疼。所以要保证：

* 程序是线程安全的，即保证程序的正确性
* 在正确的前提下，优化代码提高性能

下面就来说说线程安全的问题。


## 一、线程安全

线程安全第一次碰见是在实习的时候，我写了一个模块，被问到是不是线程安全的。当时不知道啥意思- -！然后赶紧去看了相关资料，最后把模块改成线程安全的了。用我的话总结一下就是：

> 当外部多个线程调用这个模块的时候，数据不会因为多线程读写造成数据不一致，就可以说是线程安全了。

今天看到了一个更为严谨的定义（但是很晦涩）：

> 线程安全是指当多个线程访问一个对象时，如果不用考虑这些线程在运行时环境下的调度和交替执行，也不需要进行额外的同步，或者在调用方进行任何其他的协调操作，调用这个对象的行为都可以获得正确的结果，那么这个对象就是线程安全的。 
> 
> 大白话：多个线程访问同一个对象时，并发读、并发写，是否会产生不确定性，是否会产生相互干扰。

也就是说，如果一个方法封装了所有必要的正确性保证手段，能保证谁调用它都不用操心多线程相关的问题，也不用进行额外的保护措施，那么它就是线程安全的。

### 1. Java语言中的线程安全

我们可以根据线程安全的”安全程度“由强至弱来排序，将Java语言中各种操作共享的数据分为五类

1. 不可变
1. 绝对线程安全
1. 相对线程安全
1. 线程兼容
1. 线程独立

下面我们就逐个说明吧：）

#### 不可变

不可变对象一定是线程安全的，因为它根本不变呀！！比如final、String、枚举、java.lang.Number的部分子类如Long、Double、BigInteger、BigDecimal等


#### 绝对线程安全

绝对的东西应该很少存在，如果想实现绝对线程安全是要付出巨大代价的，甚至有些情况下根本不可能实现绝对线程安全。在Java API中标榜自己是线程安全的类，大多数都不会绝对的线程安全。我们知道，java.util.Vector是一个线程安全的容器，它的add()/get()/size()方法都是被synchronized修饰的，尽管这样效率很低，但是确实是安全的。悲剧的是，即使它所有的方法都被修饰成synchronized，也不意味着调用它的时候永远都不再需要同步手段了。下面就是打脸时刻

	public class VectorTest {
	public static Vector<Integer> vector = new Vector<Integer>();
	
	public static void main(String[] args) throws InterruptedException {
		while (true) {
			for (int i = 0; i < 10; i++) {
				vector.add(i);
			}
	
			Thread.sleep(50);
	
			Thread removeThread = new Thread(new Runnable() {
	
				@Override
				public void run() {
					for (int i = 0; i < vector.size(); i++) {
						vector.remove(i);
					}
				}
			});
	
			Thread printThread = new Thread(new Runnable() {
	
				@Override
				public void run() {
					for (int i = 0; i < 10; i++) {
						System.out.println(vector.get(i));
					}
				}
			});
	
			removeThread.start();
			printThread.start();
	
			while (Thread.activeCount() > 20)
				;
		}
	}
	}

额。。。作者说代码有问题，但是我跑了5分钟也没抛出异常= =不过想想也有可能，比如remove删除了i元素，那么get()的时候就可能越界了。。。所以这里加上一个Vector的对象锁最为合适。

#### 相对线程安全

相对线程安全就是通常意义上的线程安全，它需要保证对这个对象的单独操作是线程安全的，我们在调用的时候不需要做额外的保障措施，但是对于多个线程的调用，就需要在调用端使用额外的同步手段来保证调用的正确性。

在Java语言中，大部分的线程安全类都属于这种类型，例如Vector、HashTable、Collections的synchronizedCollection()方法包装的集合等

#### 线程兼容

线程兼容是指对象本身并不是线程安全的，但是可以通过在调用端使用同步手段来保证对象在并发环境中安全滴使用。我们平常说一个类不是线程安全的，就是指这种情况。Java API中大部分的类都是线程兼容的，比如**ArrayList和HashMap（非线程安全，说的就是你！原来是线程兼容的呀）**等。

#### 线程对立

线程对立是指不管调用端是否采取了同步措施，都无法在多线程环境中并发使用的代码。但是因为Java语言天生就具有多线程特性，所以这种代码是极少的，完全可以忽略。


## 二、线程安全的实现方法

了解了线程安全后，我们就要在写代码的时候保证这一点。而怎么写出线程安全的代码呢？有如下几个方法：

### 1. 互斥同步（悲观锁）

这个是针对**临界资源**的，互斥同步是最常见的一种并发正确性保证手段。在Java里，最基本的互斥同步手段就是`synchronized`关键字。synchronized关键字经过编译后，会在同步块的前后分别形成monitorenter和monitorexit这两个字节码指令，这两个字节码都需要一个reference类型的参数来指明要锁定和解锁的对象。**如果Java程序中的synchronized明确指定了对象参数，那就是这个对象的reference；如果没有明确指定，那就根据synchronized修饰的是实例方法还是类方法，去取对应的对象实例或Class对象来作为锁对象**。

如果某个线程取得锁，那么其他线程再取锁的时候就会发现已经被锁定，要使用的话就必须阻塞直到那个线程把锁释放。

而除了`synchronized`之外，我们还可以使用`java.util.concurrent`包中的**重入锁(ReentrantLock)来实现同步**，在基本用法上，ReentrantLock和synchronized相似，都具备一样的线程重入性，只是代码写法上有点区别，一个表现为API层面的互斥锁，一个表现为原生语法层面的互斥锁。不过**ReentrantLock比synchronized增加了一些高级功能**，主要有：

* **等待可中断**：指持有锁的线程长期不释放锁的时候，正在等待的线程可以选择放弃等待，改为处理其他事情，可中断特性对处理时间非常长的同步块很有帮助
*  **公平锁**：多个线程在等待同一个锁时，必须**按照申请锁的时间顺序来依次获取锁**；非公平锁则不能保证这一点：锁释放时，**任何一个等待锁的线程都有机会获得锁**。synchronized中的锁是非公平的，ReentrantLock默认情况下也是非公平锁，但是可通过带boolean的构造函数要求使用公平锁
*  **锁绑定多个条件**：指一个ReentrantLock对象可以同时**绑定多个Condition对象**，而在synchronized中，锁对象的wait()和notify()或notifyAll()方法可以实现一个隐含的条件，如果要和多于一个的条件关联的时候，就不得不额外添加一个锁。


经过上面的描述，我们可以简单的认为ReentrantLock比synchronized多了几个特性，所以在使用到那些特性的时候选择合适的方法就可以了。至于效率问题，在JDK比较老的版本两者性能差距较大，但随着JDK的优化，两者的性能几乎相差无几。所以选择的关键就是使用场景了。

### 2. 非阻塞同步（乐观锁 CAS）

`互斥同步`最主要的问题就是进行**线程阻塞和唤醒带来的性能问题**，因此这种同步也被称为**阻塞同步**。同时，这也是一种**悲观的并发策略**：总是认为只要不去做正确的同步措施就肯定会出问题。随着硬件指令集的发展，我们有了另外一个选择：**基于冲突检测的乐观并发策略**，通俗的说就是**先进行操作，如果没有其他线程争用共享数据，那操作就成功了；如果共享数据存在竞争，就再进行补偿措施（最常见的就是不断重试，直到成功为止），这种乐观的并发策略的许多实现都不需要把线程挂起**，因此这种同步操作被称为**非阻塞同步**。

还记得上面volatile实现的那个例子吗？结果不是200000，因为race的自增操作不是原子性的，这里可以使用原子性的AtomicInteger来完成，代码如下：


还记得上面volatile实现的那个例子吗？结果不是200000，因为race的自增操作不是原子性的，这里可以使用原子性的AtomicInteger来完成，代码如下：

	import java.util.concurrent.atomic.AtomicInteger;
	
	public class AtomicTest {
	public static volatile AtomicInteger race = new AtomicInteger();
	
	public static void increase() {
		race.incrementAndGet();
	}
	
	private static final int THREADS_COUNT = 20;
	
	public static void main(String[] args) {
		Thread[] threads = new Thread[THREADS_COUNT];
		for(int i = 0; i < THREADS_COUNT; i++) {
			threads[i] = new Thread(new Runnable() {
				
				@Override
				public void run() {
					for(int i = 0; i < 10000; i++) {
						increase();
					}
				}
			});
			threads[i].start();
		}
		
		while(Thread.activeCount() > 1) {
			Thread.yield();
		}
		
		System.out.println(race);
	}
	}

因为AtomicInteger的`incrementAndGet()`方法是原子性的，所以这里不会出现任何问题。

Note：原子性和内存可见性，要同时使用，才能保证并发自增操作是正确的，即，需要同时配置：`AtomicInteger` 和 `volatile`。


## 二、锁优化

高效并发永远是一个热门的话题，HotSpot虚拟机开发团队花费了大量的精力去实现各种锁优化技术，这些技术都是为了在线程之间更高效地共享数据，以及解决竞争问题，从而提高程序的执行效率。

至于具体的技术，这里就不细讲了，对锁机制有兴趣的可以深入了解一下。


[深入理解Java虚拟机 - 第十三章、线程安全与锁优化]:			http://github.thinkingbar.com/jvm-xiii/







