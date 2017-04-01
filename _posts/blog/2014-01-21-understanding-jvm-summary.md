---
layout: post
title: Understanding the JVM：汇总
description: JVM涉及常见问题汇总
published: true
category: jvm
---


## JVM的内存分配

JVM的内存空间，即，JVM运行时数据区（JVM runtime data areas），分为几个：

* JVM堆（JVM Heap）：对象实例、数组
* 方法区（Method Area）：包含常量池（Constant Pool），类信息、静态变量、常量
* 虚拟机栈（JVM Stack）：由栈帧构成，包含：局部变量表、动态连接；
* 本地方法栈（Native Stack）
* 程序计数器（Program Count Register）：字节码行号指示器


其中：程序计数器、虚拟机栈、本地方法栈是Thread私有的，而JVM堆、方法区，是线程共享的。

![](http://ningg.top/images/understanding-jvm/runtime-data-areas.png)


![](http://ningg.top/images/understanding-jvm/internal-arch-of-jvm.gif)


### 细节参考

* [内存区域与内存溢出异常]



## 垃圾回收——GC

JVM负责为对象分配内存和回收内存，具体：**分代分配**，**分代回收**。

* 年轻代（Young Generation）：Eden、Survivor1、Survivor2
* 老年代（Old Generation）
* 永久代（Permanent Generation，也就是方法区）


两种GC：

* Young GC：也称，Minor GC，发生在`年轻代`，垃圾回收，有几种算法：标记--清除、复制、标记--整理，其中，**标记--清除**方式，会产生内存碎片，因此，在实际应用中多采用**复制**或者**标记--整理**两者之一，其中`年轻代`，由于绝大多数对象都在创建之后*（约95%）*，很快就不再使用，因此采用**复制**方式，具体，1个`Eden` + 2个`Survivor`，他们分配空间的大小为`8:1:1`，`Eden`中存活的对象与`Survivor From`中存活的对象，会复制到`Survivor To`中；对象复制次数达到一定值时，会被分配到`Old Generation`中；
* Full GC：也称，Major GC，发生在`老年代`，一般是由`Young GC`触发，实际上，大对象的分配直接发生在`老年代`，这也有可能触发Full GC；在`老年代`中发生的Full GC，因为存活的对象很多，采用**复制**算法效率较低，因此采用**标记--整理**算法；


关于Young GC，参考下图：

![](http://ningg.top/images/understanding-jvm/minor-gc.png)


思考：Full GC，只是针对老年代的GC？是否还包含永久代的GC？是的，Full GC 的时候，会同时清理老年代和永久代，永久代的GC要求很苛刻，主要是方法区中常量池内的常量、无用的类*（卸载）*；方法区的GC，并不是必须的，通过JVM的启动参数，可以进行配置。

### 细节参考

* [浅析JVM中垃圾回收]



## 引用计数、根搜索

如何判断JVM运行时数据区中对象是否存活呢？常用两种方式：引用技术、根搜索。

* 引用计数：对象每被引用一次，计数器就`+1`，引用失效，计数器`-1`，当计数器为0时，表示对象已死，但无法解决循环引用问题；
* 根搜索：设定一些对象为GC ROOTS，这些对象可达的JVM对象是存活对象。
	* GC ROOTS：一定会被使用的对象
	* GC ROOTS 需要的对象，也是会被使用的对象 


### 根搜索

* 设置GC Roots，作为对象起始点，GC Roots首先是Java对象：
	* 方法区中，静态引用指向的对象；
	* 方法区中，常量引用指向的对象；
	* 本地方法栈中JNI（Java Native Interface，本地Native方法）引用的对象；
	* 虚拟机栈中引用的对象；
* 从GC Roots向下搜索，可达的Java对象是存活的，回收不可达的对象；


### 细节参考

* [垃圾回收与内存分配策略]


## 对象访问

虚拟机栈的本地变量表中，记录了对象引用，常用两种访问对象的方式：

* 句柄：堆中开辟句柄池，通过句柄池，定位到对象实例和对象类型；
* 直接指针：虚拟机栈的本地变量表中，直接存储对象的实例的地址，对象实例再指向对象类型；


![](http://ningg.top/images/understanding-jvm/reference-pool.jpg)


![](http://ningg.top/images/understanding-jvm/direct-reference.jpg)



### 使用句柄 vs. 直接指针

两种方式的目的相同：找到对象实例，并访问对象实例。由于实现方式不同，有如下差异：

* 使用句柄，访问对象实例，好处：reference中存储的是稳定的句柄地址，不会随着GC 对象位置的移动发生改变，只需要调整句柄中对象实例的地址；
* 直接指针，访问对象实例，好处：访问速度快，节省了一次指针定位的时间开销；**Sun HotSpot VM使用直接指针方式访问对象**；


## 对象初始化

2个小问题：

* 什么时候初始化？
* 初始化时，对象内部：静态代码、静态成员、普通成员、构造函数，他们执行的先后顺序？


### 什么时候，对象初始化？


有且只有四种情况必须立即对类进行”初始化”（而加载、验证、准备当然在初始化的前面了）：

* 遇到new、getstatic、putstatic、invokestatic这四条指令码时，如果类没有进行初始化，必须触发初始化。
	* new肯定是新建对象
	* get/putstatic是读取或者设置一个类的静态字段（static final修饰的是编译期放入常量池了，所以不算）
	* invokestatic是调用一个类的静态方法
* 使用`java.lang.reflect`包的方法对类进行反射调用的时候，如果类没有进行初始化，必须触发初始化
* 当初始化一个类时，如果其父类还没有初始化，则触发初始化
* 当虚拟机启动时，用户需要指定一个要执行的主类（包含`main()`方法的类），虚拟机会先初始化这个主类


### 对象初始化，对象内部细节


没有父类时，对象初始化时，内部细节：

1. 静态成员、静态代码块
1. 普通成员
1. 构造函数

有父类时，对象初始化时，内部细节：

* 父类：
	* 静态成员、静态代码块
* 子类：
	* 静态成员、静态代码块
* 父类：
	* 普通成员
	* 构造函数
* 子类：
	* 普通成员
	* 构造函数


![](http://ningg.top/images/understanding-jvm/java-object-init.png)


### 细节参考

* [Java中对象产生初始化过程]
* [虚拟机类加载机制]


## 类加载

> 对于Java中的任意一个类，都需要**由加载它的类加载器和这个类本身一同确立其在JVM中的唯一性**，*(定位一个类，需要类加载器 + 类本身)*。 所以，看两个类是否相等（Class对象的`equals()`方法等），前提就是由一个类加载器加载的。如果不是一个类加载器加载的，即使是同一个`.class`文件也肯定是不相等的。理解这点是开发自己的类加载器的大前提。

关于类加载器的工作，大体上有3步：

1. 检查这个类是否已经被加载过
1. 如果没有被加载过，调用父类加载器去加载
1. 如果父类加载器加载失败，就调用当前类加载器去加载

**双亲委派模型**的工作过程是：如果一个类加载器收到了类加载的请求，那么它首先会把这个请求**委派给父加载器**完成，以此类推。因此所有的类加载请求最终都应该传送到顶层的引导类加载器中，只有当父加载器无法完成这个加载请求，子加载器才会尝试自己去加载。那么，回到上面的问题。为什么要使用这种代理机制呢？

> 这样做Java类和它的类加载器就一起具备了**带有优先级的层次关系**。例如类java.lang.Object,它存放在rt.jar中，无论哪一个类加载这个类，最终都会被委派到引导类加载器去完成它的加载，因此Object类在程序中的各种类加载器环境中都是一个类。这样做也保证**安全性**，因为如果有人想恶意置入代码，类加载器的代码就避免了这种情况的发生。

![](http://ningg.top/images/understanding-jvm/classloader_tree.jpg)


## 细节参考

* [虚拟机类加载机制]

## 类执行（字节码执行）


Java虚拟机一共提供了 4 条字节码指令来进行**方法调用**，分别是：

1. `invokestatic`：调用静态方法
1. `invokespecial`：调用实例构造器`<init>`方法(看仔细，不是`<clinit>`)、私有方法和父类方法
1. `invokevirtual`：调用所有的虚方法
1. `invokeinterface`：调用接口方法，会在运行时确定一个实现该接口的对象

只要能被invokestatic和invokespecial调用的方法，才可以在解析阶段确定唯一的调用版本，符合这个条件的有静态方法、私有方法、实例构造器和父类方法，它们在**类加载**的时候就会把符号引用解析成直接引用。这些方法可以称为非虚方法，与之相反的invokevirtual和invokeinterface就是虚方法了，这些就需要在**运行时**确定实现该接口的对象。

**解析调用**一定是一个静态的过程，在**编译期间**就能完全确定，在类装载的解析阶段就会把涉及的符号引用全部转变为可确定的直接引用，不会延迟到运行期再完成。而**分派调用**则可能是静态的或者动态的。

### 分派调用

**分派调用**过程将会揭示**Java多态特性**是如何实现的，比如重载和重写，这里的实现当然不是语法那么low，我们关心的是**JVM如何确定正确的目标方法**。而分派共分为四种：*（静态分派：重载，动态分派：重写Override）*

* 静态单分派
* 静态多分派
* 动态单分派
* 动态多分派

结论我们先记住：*（重载静态、重写动态）*

* 重载：参数静态类型
* 重写：参数动态类型


Tips：

> 一定要看：[虚拟机字节码执行引擎]



### 重载

Tips：

> **重载**是由**静态类型决定的**。那么，编译器在处理重载函数时，使用哪个版本的重载函数就取决于传入参数的静态类型。

示例代码：


	public class StaticDispatch {
	static abstract class Human {
		
	}
	
	static class Man extends Human {
		
	}
	
	static class Woman extends Human {
		
	}
	
	public void sayHello(Human guy) {
		System.out.println("hello, Human");
	}
	
	public void sayHello(Man guy) {
		System.out.println("hello, Man");
	}
	
	public void sayHello(Woman guy) {
		System.out.println("hello, Woman");
	}
	
	public static void main(String []args) {
		Human man = new Man();
		Human woman = new Woman();
		
		StaticDispatch staticDispatch = new StaticDispatch();
		staticDispatch.sayHello(man);
		staticDispatch.sayHello(woman);
	}
	}

请思考一下答案应该是神马呢？*（为什么使用静态方法？）*

正确答案是：

	hello, Human
	hello, Human

这里我们需要定义两个重要概念：

	Human man = new Man();

我们把上面的Human称为变量man的**静态类型**，后面的Man称为man的**实际类型**。它们的区别在于：

> 变量本身的静态类型不会改变，而且在编译期就可以知道；而实际类型变化的结果到运行时才能确定，编译时无法知道。


### 重写

Tips：

> 对于多态来说，**重写**使用的是参数的**实际类型**。

示例代码如下：

	public class DynamicDispatch {
	static abstract class Human {
		protected abstract void sayHello();
	}
	
	static class Man extends Human {
	
		@Override
		protected void sayHello() {
			System.out.println("hello, Man");
		}
	}
	
	static class Woman extends Human {
	
		@Override
		protected void sayHello() {
			System.out.println("hello, Woman");
		}
		
	}
	
	public static void main(String[] args) {
		Human man = new Man();
		Human woman = new Woman();
		
		man.sayHello();
		woman.sayHello();
		
		man = new Woman();
		man.sayHello();
	}
	}/*output:
	hello, Man
	hello, Woman
	hello, Woman
	*/


### 细节参考

* [虚拟机字节码执行引擎] *（一定要看）*



## 性能调优


6个命令行工具：

* jps：JVM Process Status Tool，显示指定系统内所有的HotSpot虚拟机进程
* jstat：JVM Statistics Monitoring Tool，用于收集HotSpot虚拟机各方面的运行数据
* jinfo：Configuration Info for Java，显示虚拟机配置信息
* jmap：Memory Map for Java，生成虚拟机的内存转储快照(heap dump文件)*（堆快照）*
* jhat：JVM Heap Dump Browser，用于分析heap dump文件，会建立一个HTTP/HTML服务器，让用户可以在浏览器查看分析结果
* jstack：Stack Trace for Java，显示虚拟机的线程快照*（栈快照）*

然后还有两个GUI工具：

* jconsole：略微过时的JVM各状态查看工具
* visualVM：Sun出品的强大的JVM工具，推荐使用！


补充：

* `top` + `jstack`：
	* `top`命令定位消耗CPU的进程，以及进程下不同线程消耗CPU的情况
	* 利用`jstack`命令定位进程下所有线程的栈，以此来定位和调试代码性能
	


### 细节参考

* [jstack对运行的Thread进行分析]
* [JVM性能监控与故障处理工具]

## 内存模型

要知道**为什么要有Java内存模型**。

> Java虚拟机规范定义了Java内存模型（Java Memory Model，**JMM**)来实现**屏蔽掉各种硬件和操作系统的内存访问差异**，以实现让Java程序在各种平台下都能达到一致的并发效果。要抓住重点：**屏蔽硬件差异，保证并发。而程序的功能就是数据流的交互，所以保证数据的快速、正确访问就是Java内存模型的核心。**

### 主内存与工作内存

Java内存模型的主要目标是**定义程序中各个变量的访问规则，即在虚拟机中奖变量存储到内存和从内存中取出变量这样的底层细节**。此处的变量和Java程序中的变量略有区别，它包括了**实例字段、静态字段和构成数组对象的元素**，但是不包括局部变量和方法参数，因为它们是线程私有的，不会被共享，自然不存在竞争问题。*（JVM堆中的数据，是多线程共享的）*

Java内存模型规定了所有的变量存储在JVM的**主内存**中。每条线程还有自己的**工作内存**（类比高速缓存）。线程工作内存中保存了被该线程使用到的变量的主内存副本拷贝，**线程对变量的所有操作（读取、赋值等）都必须在工作内存中进行，而不能直接读写主内存中的变量**。不同线程之间的工作内存也是相互独立的，**线程间变量值传递均需要主内存完成**。线程、主内存、工作内存之间的关系如下图所示：

![](/images/understanding-jvm/jmm.jpg)


### volatile型变量

关键字volatile是Java虚拟机提供的最轻量级的同步机制，但是它并不容易被正确地、完整地理解，所以在遇到多线程数据竞争的问题时一律使用`synchronized`来进行同步。而了解volatile变量的语义对后面了解多线程操作的其他特性有很重要的意义，所以我们先通俗的说一下volatile的语义。

> volatile是轻量级同步机制，它保证被修饰的变量在修改后立即列入主内存，使用变量前必须从主内存刷新到工作内存，这样就保证了所有线程的可见性。


由于volatile变量只保证可见性，在不符合以下两条规则的运算场景中，我们仍然需要通过加锁（使用`synchronized`或者`java.util.concurrent`中的原子类）来保证原子性
	
* 运算结果并不依赖变量的当前值，或者能够确保**只有单一的线程修改变量的值**
* 变量不需要与其他的状态变量共同参与不变约束


### 细节参考

* [Java内存模型与线程]



## Java与线程

其实**并发**不一定必须依靠**多线程**（PHP还依靠**多进程**并发呢），但是在Java中，并发和线程脱不开关系。所以，我们先来八一八线程的实现。注意，不是Java线程的实现，而是线程的实现哦。


我们知道，**线程是比进程更轻量级的调度执行单位**，线程的引入，可以把一个进程的**资源分配**和**执行调度**分开，各个线程既可以共享进程资源（内存地址、文件I/O等），又可以独立调度（线程是CPU调度的最基本单位）。


### 线程安全


怎么写出线程安全的代码呢？有如下几个方法：

#### 1. 互斥同步（悲观锁）

这个是针对**临界资源**的，互斥同步是最常见的一种并发正确性保证手段。在Java里，最基本的互斥同步手段就是`synchronized`关键字。synchronized关键字经过编译后，会在同步块的前后分别形成monitorenter和monitorexit这两个字节码指令，这两个字节码都需要一个reference类型的参数来指明要锁定和解锁的对象。**如果Java程序中的synchronized明确指定了对象参数，那就是这个对象的reference；如果没有明确指定，那就根据synchronized修饰的是实例方法还是类方法，去取对应的对象实例或Class对象来作为锁对象**。

如果某个线程取得锁，那么其他线程再取锁的时候就会发现已经被锁定，要使用的话就必须阻塞直到那个线程把锁释放。

而除了`synchronized`之外，我们还可以使用`java.util.concurrent`包中的**重入锁(ReentrantLock)来实现同步**，在基本用法上，ReentrantLock和synchronized相似，都具备一样的线程重入性，只是代码写法上有点区别，一个表现为API层面的互斥锁，一个表现为原生语法层面的互斥锁。不过**ReentrantLock比synchronized增加了一些高级功能**，主要有：

* **等待可中断**：指持有锁的线程长期不释放锁的时候，正在等待的线程可以选择放弃等待，改为处理其他事情，可中断特性对处理时间非常长的同步块很有帮助
*  **公平锁**：多个线程在等待同一个锁时，必须**按照申请锁的时间顺序来依次获取锁**；非公平锁则不能保证这一点：锁释放时，**任何一个等待锁的线程都有机会获得锁**。synchronized中的锁是非公平的，ReentrantLock默认情况下也是非公平锁，但是可通过带boolean的构造函数要求使用公平锁
*  **锁绑定多个条件**：指一个ReentrantLock对象可以同时**绑定多个Condition对象**，而在synchronized中，锁对象的wait()和notify()或notifyAll()方法可以实现一个隐含的条件，如果要和多于一个的条件关联的时候，就不得不额外添加一个锁。


经过上面的描述，我们可以简单的认为ReentrantLock比synchronized多了几个特性，所以在使用到那些特性的时候选择合适的方法就可以了。至于效率问题，在JDK比较老的版本两者性能差距较大，但随着JDK的优化，两者的性能几乎相差无几。所以选择的关键就是使用场景了。

#### 2. 非阻塞同步（乐观锁）

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


### 细节参考

* [Java内存模型与线程]
* [线程安全与锁优化]





[NingG]:    http://ningg.github.com  "NingG"



[jstack对运行的Thread进行分析]:			http://ningg.top/jvm-best-practice-jstack-thread-analysis/
[浅析JVM中垃圾回收]:					http://ningg.top/jvm-gc/
[Java中对象产生初始化过程]:				http://ningg.top/java-object-init-process/
[内存区域与内存溢出异常]:				http://ningg.top/understanding-jvm-chapter-2/
[垃圾回收与内存分配策略]:				http://ningg.top/understanding-jvm-chapter-3/
[JVM性能监控与故障处理工具]:			http://ningg.top/understanding-jvm-chapter-4/
[虚拟机类加载机制]:						http://ningg.top/understanding-jvm-chapter-7/
[虚拟机字节码执行引擎]:					http://ningg.top/understanding-jvm-chapter-8/
[Java内存模型与线程]:					http://ningg.top/understanding-jvm-chapter-12/
[线程安全与锁优化]:						http://ningg.top/understanding-jvm-chapter-13/




