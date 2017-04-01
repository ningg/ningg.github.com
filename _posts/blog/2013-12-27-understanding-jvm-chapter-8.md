---
layout: post
title: Understanding the JVM：虚拟机字节码执行引擎
description: 如何执行class字节码文件？
category: jvm
---

## 前言

执行引擎是Java虚拟机最核心的组成部分之一。执行引擎在执行Java代码的时候可能有解释执行（通过解释器执行）和编译执行（通过即时编译器产生的本地代码执行）两种选择，也可能两者兼备，甚至还可能包含几个不同级别的编译器执行引擎。但从Java虚拟机规范中描述的执行引擎概念模型来说，所有的Java虚拟机的执行引擎都是一样的：它的输入是字节码文件，处理过程是字节码解析的等效过程，输出的是执行结果。

思考：

* 解释器、编译器，什么区别？
* 代码的执行过程，本质都是代码生成二进制机器码，差异在哪？


本章重点有下面几个小节：

* 运行时栈帧结构：JVM Stack、本地方法栈，保存现场、恢复现场；
* 方法调用
* 基于栈的字节码解释执行引擎

## 一、运行时栈帧结构

首先，**栈帧**是用于支持虚拟机进行**方法调用**和**方法执行**的**数据结构**（还记得不？栈帧是运行时数据区虚拟机栈的栈元素）。也就是说它就是一个类似结构体的东东，用于存放一些诸如

* 局部变量表
* 操作数栈
* 动态连接
* 方法返回地址

还有一些其他的附属信息。**每一个方法从调用开始到执行完毕，就对应着一个栈帧在虚拟机栈里面从入栈到出栈的过程**。

看图说话：

![](/images/understanding-jvm/frame.png)

栈帧是针对JVM Stack和Native Method Stack来说的，这个是Thread独有的，接下来就具体分析一下栈帧中的元素：

### 1. 局部变量表

稍微一想，**局部变量表**当然存储的是**方法参数+方法内的变量**。而这些数据被存在**变量槽**（Variable Slot，下称slot）的最小单位中，slot中能存放的类型为：

* 8种基类类型（bool/byte/char/short/int/long/float/double)
* reference
* returnAddress：指向字节码指令的地址

我们看到，Java虚拟机规范并没有规定每个slot的大小。所以不同的虚拟机或者操作系统可以有各自的实现。当然，一个slot可以存放一个32位以内的数据类型，包含了上面3类中除long和double的其他所有类型。而64的long和double则分配两个连续slot。这里我们可能会想到多线程访问的问题，但是请记得大前提：**Java虚拟机栈是线程私有的，对线程来说是原子性的**。所以这里连续不连续都不会引起安全问题。

上面说完了局部变量表的东西，那么JVM如何使用它们呢？答案是索引定位。

在方法执行时，虚拟机是通过局部变量表来完成参数值到参数变量列表的传递过程的，如果是非static方法，局部变量表的第0号索引的slot默认是当前对象实例的引用，也就是this指向的对象。而且slot可以复用，比如函数内变量作用域只在一个循环内，那么后面的变量可以占用这个slot。

关于局部变量还想再说一点，在《Java编程思想》的笔记里，曾经分三章提到了类的初始化，那么说**局部变量是没有初始化的**。在局部变量表中找到了答案：

* `类变量`（非实例变量）有 2 次赋初始值的过程:
	* 一个是准备阶段，赋予系统初始值（有final的话在编译时会加上ConstantValue属性，那么在准备时就是常量值了）;
	* 另外一次是初始化阶段，是程序员指定的值;
* `实例变量`是在使用 new 关键字后，在堆上先进行分配内存的时候获取一次数据类型的零值，然后再执行实例变量定义处的初始化（C++不允许），最后执行的是构造函数的初始化。

因此，对于类变量而言，如果程序员在定义处不指定初始值的话，准备阶段也会有默认值（数据类型的零值）。对于实例变量而言，在堆上分配的时候，由于需要分配内存，就会同时将这些内存的空间清空，赋予它们数据类型的零值。但是局部变量就不同了，因为准备阶段只处理方法区，堆只管新分配内存，而局部变量表可能复用 slot。所以，一个局部变量定义了但是没有初始值是不能使用的（一种情况是使用了新的 slot，会有零值；如果复用了 slot，那么值肯定就是错的。所以综合考虑，**局部变量必须指定初值**）。


### 2. 操作数栈

Java虚拟机的解释执行引擎被称为`基于栈的执行引擎`，其中所指的栈就是指——**操作数栈**。操作数栈也常被称为操作栈。

和局部变量区一样，操作数栈也是被组织成一个以字长为单位的数组。但是和前者不同的是，它不是通过索引来访问，而是通过标准的栈操作*（压栈和出栈）*来访问的。比如，如果某个指令把一个值压入到操作数栈中，稍后另一个指令就可以弹出这个值来使用。

虚拟机在操作数栈中存储数据的方式和在局部变量区中是一样的：如int、long、float、double、reference和returnType的存储。对于byte、short以及char类型的值在压入到操作数栈之前，也会被转换为int。

**虚拟机把操作数栈作为它的工作区——大多数指令都要从这里弹出数据，执行运算，然后把结果压回操作数栈**。比如，iadd指令就要从操作数栈中弹出两个整数，执行加法运算，其结果又压回到操作数栈中，看看下面的示例，它演示了虚拟机是如何把两个int类型的局部变量相加，再把结果保存到第三个局部变量的：

	begin
	iload_0    // push the int in local variable 0 onto the stack
	iload_1    // push the int in local variable 1 onto the stack
	iadd       // pop two ints, add them, push result
	istore_2   // pop int, store into local variable 2
	end

 在这个字节码序列里，前两个指令iload_0和iload_1将存储在局部变量中索引为0和1的整数压入操作数栈中，其后iadd指令从操作数栈中弹出那两个整数相加，再将结果压入操作数栈。第四条指令istore_2则从操作数栈中弹出结果，并把它存储到局部变量区索引为2的位置。下图详细表述了这个过程中局部变量和操作数栈的状态变化，图中没有使用的局部变量区和操作数栈区域以空白表示。

![](/images/understanding-jvm/operand-stack.gif)


### 3. 动态连接

每个栈帧都包含一个指向运行时常量池中该栈帧所属方法的引用，**持有这个引用是为了支持方法调用过程中的动态连接**。在前面知道，class文件中的常量池有大量的符号引用，字节码中的方法调用指令就以常量池中指向方法的**符号引用**为参数。这些符号引用一部分会在类加载阶段或者第一次使用的时候转换成直接引用，这种转化称为**静态解析**。另外一部分将在每一次的运行期间转换为直接引用，这部分称为**动态连接**。

### 4. 方法返回地址

一个方法执行结束有两种情况：

* 正常结束。绝大多数程序都会正常结束
* 异常结束。异常结束指的是在方法内部无法处理异常（没有匹配的异常处理器），那么方法就会异常退出。一个方法只要是异常退出，是不会给调用者任何返回值的。

无论何种方式的方法退出，都需要返回到方法被调用的位置，用于恢复上下文供程序继续处理。一般来说，方法正常退出时，调用者的PC计数器的值可以作为返回地址，栈帧很可能会保存这个计数器值。而方法异常退出时，返回地址是要通过异常处理器表来确定的，栈帧中一般不会保存这个信息。

方法退出相当于出栈，可能执行的操作有：

* 恢复上层调用方法的局部变量表和操作数栈
* 把返回值（如果有的话）压入调用者栈帧的操作数栈中
* 调整PC计数器指向下一条指令

### 5. 附加信息

这部分Java虚拟机规范没有明确规定，具体实现是虚拟机自己的事情。在实际开发中，**一般会把动态连接、方法返回地址和其他附加信息全部归为一类，称为栈帧信息**。

## 二、方法调用

方法调用阶段的唯一目的是：

> **确定被调用方法的版本（即调用哪一个版本）**，暂时还不涉及方法内部的具体运行过程。意思很明显，**将在所有的重载、覆盖函数中确定应该调用哪个版本**。*（找到要调用的方法）*

Tips：

> 这里需要说明一点，Class文件的编译过程不包含传统编译中的连接步骤，**一切方法调用在Class文件中都只是符号引用**，而不是方法在实际运行时内存布局的入口地址（直接引用），**这个特性给Java带来了更强大的动态扩展能力，但也使得Java方法的调用过程变得复杂，需要在类加载期间甚至到运行时才能确定目标方法的直接引用**。

### 1. 解析

什么是解析？

> 在class文件的二进制字节流中，所有的方法调用都是通过符号引用进行的。那么，在进入JVM后，有一部分方法调用就可以从符号引用转变为直接引用，要求就是：**编译期已知，运行期不可变**。所以，符合解析条件的都是在编译期确定下来的方法调用。大致想下就能想出来几种，比如类的静态方法、private修饰的方法、实例构造器等。嗯，正规来说，在Java语言中，符合“编译期可知，运行期不可变”的方法主要有：**静态方法和私有方法，前者直接与类型关联，后者在外部不可访问**。这两种方法都不可能通过继承或者别的方式重写出其他版本，因此他们都适合在**类加载阶段进行解析（解析的都必须在编译期确定哦**）。

Java虚拟机一共提供了 4 条方法调用字节码指令，分别是：

* invokestatic：调用静态方法
* invokespecial：调用实例构造器`<init>`方法(看仔细，不是`<clinit>`)、私有方法和父类方法
* invokevirtual：调用所有的虚方法
* invokeinterface：调用接口方法，会在运行时确定一个实现该接口的对象

只要能被invokestatic和invokespecial调用的方法，才可以在解析阶段确定唯一的调用版本，符合这个条件的有静态方法、私有方法、实例构造器和父类方法，它们在类加载的时候就会把符号引用解析成直接引用。这些方法可以称为非虚方法，与之相反的invokevirtual和invokeinterface就是虚方法了，这些就需要在运行时确定实现该接口的对象。

**解析调用**一定是一个静态的过程，在编译期间就能完全确定，在类装载的解析阶段就会把涉及的符号引用全部转变为可确定的直接引用，不会延迟到运行期再完成。而**分派调用**则可能是静态的或者动态的。

### 2. 分派

**分派调用**过程将会揭示**Java多态**特性是如何实现的，比如重载和重写，这里的实现当然不是语法那么low，我们**关心的是JVM如何确定正确的目标方法**。而分派共分为四种：*（静态分派：重载，动态分派：重写Override）*

* 静态单分派
* 静态多分派
* 动态单分派
* 动态多分派

结论我们先记住：

* 重载：参数静态类型
* 重写：参数动态类型

首先我们说明静态分派。首先是一段在面试中经常出现的代码：

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


如何感觉到惊诧就对了，下面我们解释。对于那些完全无压力而且能说出原因的人，请你们洗洗睡吧。咳咳，进入正题。这里我们需要定义两个重要概念：

	Human man = new Man();

我们把上面的Human称为变量man的静态类型，后面的Man称为man的实际类型。它们的区别在于：

> 变量本身的静态类型不会改变，而且在编译期就可以知道；而实际类型变化的结果到运行时才能确定，编译时无法知道。

下面是例子

	//实际类型变化
	Human man = new Man();
	man = new Woman();
	
	//静态类型变化
	sayHello((Man)man);
	sayHello((Woman)man);

知道了这个回到刚才那个例子就很清楚了，在main中man和woman的静态类型都是Human，但编译器在重载时是通过参数的静态类型而不是实际类型作为判断依据的。因为静态类型是编译期已知的，所以javac会在编译时确定该调用哪个版本，在本例子中就是`sayHello(Human guy)`了。

**所有依赖静态类型的分派都称为静态分派，而静态分派最典型的应用就是重载**。静态分派发生在编译时期，因此确定静态分派的动作实际上跟JVM无关。但是也有例子，即使编译器能精确的判断上个例子，但是对于一些无法知道静态类型的变量（比如字面值），编译器只好靠猜了，它会尽量选择最符合语境的方法。下面是一个例子：

	import java.io.Serializable;
	
	public class Overload {
	public static void sayHello(Object org) {
		System.out.println("hello Object");
	}
	
	public static void sayHello(int org) {
		System.out.println("hello int");
	}
	
	public static void sayHello(long org) {
		System.out.println("hello long");
	}
	
	public static void sayHello(Character org) {
		System.out.println("hello Character");
	}
	
	public static void sayHello(char org) {
		System.out.println("hello char");
	}
	
	public static void sayHello(char... org) {
		System.out.println("hello char...");
	}
	
	public static void sayHello(Serializable org) {
		System.out.println("hello Serializable");
	}
	
	public static void main(String[] args) {
		sayHello('a');
	}
	}/*output:
	hello char
	*/

很明显的结果。请依次注释掉char/int/long/Character/Serializable/Object，这时候应该只剩下char ...了。输出结果其实很容易知道。

需要说明的是，可变形参的重载优先级是最低的，上面8种版本只有当其他7种都注释的情况才会出现hello char...。这个代码演示了编译期选择静态分派目标的过程，这个过程是Java实现方法重载的本质。

下面说说动态分派。它和多态性的另外一个重要体现——重写（Override）有很大的关联。废话少说，上代码

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

这次代码运行的结果对于面向对象思维的程序员来说是很容易接受的。现在的问题还是一样：JVM是如何调用正确的方法呢？

最简单的方法就是打印一下StaticDispatch和DynamicDispatch的字节码（先编译，然后用`javap -c XXX`），然后大概看看程序的逻辑。然后是这样的：

* `StaticDispatch[编译期]`：前面说过，重载是由静态类型决定的。那么，编译器在处理重载函数时，使用哪个版本的重载函数就取决于传入参数的静态类型。并且因为静态类型是编译期可知的，所以在编译阶段，javac编译器就根据参数的静态类型决定使用哪个版本，同时把这个方法的符号引用写入到invokevirtual指令的参数中。在本例子中，就是编译器看到main中调用sayHello()的参数静态类型是Human，于是就把sayHello(Human guy)写入到main中2个调用sayHello()的invokevirtual指令中。
* `DynamicDispatch[运行期]`：对于多态来说，重写使用的是参数的实际类型。因为参数的实际类型是在运行期才能知道的，所以就需要学习一下invokevirtual的多态查找过程（上面那个是编译期写死使用哪个版本）：

	* 找到操作数栈顶的第一个元素所指向的对象的实际类型，记作C
	* 如果在类型C中找到与常量中的描述符和简单名称都相符的方法，进行访问权限验证，通过则返回这个方法的直接引用，查找过程结束；否则返回java.lang.IllegalAccessError
	* 否则，按照继承关系从下到上依次对C的各个父类进行第2步的搜索和验证过程
	* 如果还是没有找到合适的方法，就抛出java.lang.AbstractMethodError

Tips:

> 由于invokevirtual指令执行的第一步就是在运行时确定接收者的实际类型，所以两次调用中的invokevirtual指令把常量池中的类方法符号引用解析到了不同的直接引用，这个过程就是Java重写的本质。我们把这种在运行时确定方法执行版本的过程成为动态分派。

经过上面静态分派、动态分派的讲解，我们还得思考一个问题：**为什么重载是静态分派，而重写是动态分派呢？**

> 经过上面2个例子的分析，我们应该能总结出来它们实现的原理。**本质上来说，这是面向对象的多态特征的应用，它提供了一种运行时类型调整的方法。因为面向过程是无法实现多态机制的**。具体而言，**重载的时候根据参数的静态类型就可以进行方法版本的选择；而重写是多态的特性，我们想使用的类型只有在运行时才能确定，所以它是根据参数的实际类型来进行方法选择**。
嗯，最后说一下。因为运行时的动态分派非常频繁，为了性能考虑，Java会为类在方法区中建立一个虚方法表（和C++一样的啦），如果是接口，那么就是一个虚接口表，然后在这个表中进行查找。而不是大海捞针式。而这个方法区的方法表一般在类加载的连接阶段进行初始化，准备了类的变量初始值后，虚拟机会把该类的方法表也初始完成。

### 3. Java的静态单多分派、动态单分派模型

第一遍看的时候没搞清楚这啥玩意，目前看了第三遍，终于算是稍微清晰一点了。。。补一发T_T

	package jvm;
	
	public class Dispatch {
	
	static class QQ {
		
	}
	
	static class _360 {
		
	}
	
	public static class Father {
		public void hardChoice(QQ arg) {
			System.out.println("father choose QQ");
		}
		
		public void hardChoice(_360 arg) {
			System.out.println("father choose 360");
		}
	}
	
	public static class Son extends Father {
		@Override
		public void hardChoice(QQ arg) {
			System.out.println("son choose QQ");
		}
		
		@Override
		public void hardChoice(_360 arg) {
			System.out.println("son choose 360");
		}
	}
	
	public static void main(String[] args) {
		Father father = new Father();
		Father son = new Son();
		
		father.hardChoice(new _360());
		son.hardChoice(new QQ());
	}
	
	}/*output:
	father choose 360
	son choose QQ
	*/


在main中调用了2次 hardChoice()，一次是通过father调用，一次是通过son调用。那么，我们就来具体分析一下：

*  **编译阶段编译器的选择**：前面知道了是静态分派。既然是静态的，首先得知道静态类型是Father还是Son，这是一个宗量。然后选择重载版本的参数类型是QQ还是_360，这又是一个宗量。加起来之后，静态分派总共有两个宗量。所以 Java 语言的静态分派属于多分派类型
* **运行阶段虚拟机的选择**：经过编译期的静态分派，我们知道 father 最终执行的方法是 hardChoice(360), son 最终执行的方法是 hardChoice(QQ), 那么不管360是哪种360,QQ 是腾讯QQ 还是奇瑞 QQ，虚拟机都不会关心，只要你是 QQ 类型就可以。那么，最终选择方法的关键在于这个方法的接收者的实际类型，所以只有一个宗量。

综上可知：

> Java是静态多分派，动态单分派。具体可以google之，不过我看了一大圈下来还是没人能讲清楚的。等学到visitor设计模式再看看吧。。。。


## 三、基于栈的字节码解释执行引擎

前面说过，字节码的执行分为解释执行和编译执行，下面就来讲一下。

### 1. 解释执行

这个看了之后就是编译原理的流程，javac完成的工作有：

> 程序源代码 -> 词法分析 -> 语法分析到抽象语法树 -> 字节码

剩下的解释运行被实现在JVM中。怎么实现呢？Java编译器生成的字节码应该属于一种**基于栈的指令集架构**。而物理机多采用的是x86架构（也就是**寄存器架构**，二地址指令集）。大体上可以用一个例子来说明：比如计算1+1：

基于栈的指令集：

	iconst_1
	iconst_1
	iadd
	istore_0

两条iconst_1指令连续把2个常量1压入栈中，iadd把2个1弹出，结算结果为2后放入栈顶。然后istore_0把2放到局部变量表的0号slot中。

基于寄存器的指令集：

	mov eax, 1
	add eax, 1

mov把EAX寄存器的值设为1，然后add指令再把这个值+1,结果还是保存在EAX寄存器中。

那么这两种哪个更好呢？其实，两者各有优劣，要不然就不会出现两雄争霸的局面了。

* **基于栈**的指令集最主要优点是跟机器无关，具有**移植性**；缺点就是执行**速度较慢**，所有主流物理机的指令集都是寄存器架构从侧面说明了这一点。
* **寄存器**和硬件息息相关，程序依赖寄存器就会**失去移植性**。但是寄存器最主要的优点是**速度快**，因为频繁的入栈出栈会产生相当多的指令，而且栈是实现在内存中，而对于处理器来说，内存始终是执行速度的瓶颈。

下面用一个简单的例子来说明**基于栈**的解释器执行过程，首先是例子：

	public int calculate() {
		int a = 100;
		int b = 200;
		int c = 300;
		return (a + b) * c;
	}

编译后通过javap -c A得到字节码：

	public int calculate();
		Code:
		0: bipush        100
		2: istore_1
		3: sipush        200
		6: istore_2
		7: sipush        300
		10: istore_3
		11: iload_1
		12: iload_2
		13: iadd
		14: iload_3
		15: imul
		16: ireturn

我们把每条指令解释一下：

1. bipush 100，把100推入操作数栈顶
1. istore_1，把栈顶元素出栈并存放到局部变量表的1号slot（因为calculate不是static的，0号slot是指向本对象的this）
1. sipush 200一直到istore_3都是重复1-2步骤
1. iload_1，将1号slot的值复制到栈顶
1. iload_2，将2号slot的值复制到栈顶
1. iadd，出栈两个元素，将相加结果300压入栈顶
1. iload_3，将3号slot的值复制到栈顶
1. imul，出栈两个元素，将相乘结果90000压入栈顶
1. ireturn，将栈顶元素返回给调用者

上面只是一个简单的例子，在实际应用中，复杂的代码JVM会做很多优化，这里仅仅为了说明问题，所以比较简单。




























[深入理解Java虚拟机 - 第八章、虚拟机字节码执行引擎]:			http://github.thinkingbar.com/jvm-viii/







