---
layout: post
title: Spring之AOP--代理模式
description: AOP的实例、底层原理
published: true
categories: Spring Java
---


关于Spring AOP，几点：

* 代理模式：静态代理、动态代理、cglib代理；*（底层原理）*
* 使用场景：日志、事务；
* 常用术语：
* 实例






Aspect Oriented Programming  面向切面编程。解耦是程序员编码开发过程中一直追求的。AOP也是为了解耦所诞生。

> 具体思想是：定义一个切面，在**切面的纵向定义处理方法**，处理完成之后，回到**横向业务流**。

AOP 在Spring框架中被作为核心组成部分之一，的确Spring将AOP发挥到很强大的功能。最常见的就是事务控制。工作之余，对于使用的工具，不免需要了解其所以然。学习了一下，写了些程序帮助理解。

AOP 主要是利用**代理模式**的技术来实现的。

##1. 静态代理：设计模式中proxy模式

###a. 业务接口

	/*
	 * 抽象主题角色：声明了真实主题和代理主题的共同接口。
	 * 
	 */

	public interface ITalk {

		public void talk(String msg);

	}

###b. 业务实现

	/*
	 * 真实主题角色：定义真实的对象。
	 * 
	 */
	public class PeopleTalk implements ITalk {

		public PeopleTalk() {
		}

		public void talk(String msg) {
			System.out.println(msg);
		}

	}

###c. 代理对象

	/*
	 * 代理主题角色：内部包含对真实主题的引用，并且提供和真实主题角色相同的接口。
	 * 
	 */
	public class TalkProxy implements ITalk {

		private ITalk talker;

		public TalkProxy(ITalk talker) {
			// super();
			this.talker = talker;
		}

		public void talk(String msg) {
			talker.talk(msg);
		}

		public void talk(String msg, String singname) {
			talker.talk(msg);
			sing(singname);	// 后置处理
		}

		private void sing(String singname) {
			System.out.println("唱歌：" + singname);
		}

	}


###d. 测试类

	/*
	 * 代理测试类，使用代理
	 *
	 */
	public class ProxyPattern {

		public static void main(String[] args) {
			// 不需要执行额外方法的。
			ITalk people = new PeopleTalk();
			people.talk("No ProXY Test");
			System.out.println("-----------------------------");

			// 需要执行额外方法的（切面）
			TalkProxy talker = new TalkProxy(people);
			talker.talk("ProXY Test", "代理");
		}

	}

从这段代码可以看出来，代理模式其实就是AOP的雏形。 上端代码中`talk(String msg, String singname)`是一个切面。在代理类中的`sing(singname)`方法是个后置处理方法。

这样就实现了，其他的辅助方法和业务方法的解耦。业务不需要专门去调用，而是走到talk方法，顺理成章的调用sing方法

再从这段代码看：

1. 要实现代理方式，必须要定义接口
1. 每个业务类，需要一个代理类*（为什么？因为每个业务类对应一个接口？）*

观察代码可以发现每一个**代理类**只能为一个接口服务，这样一来程序开发中必然会产生过多的代理，而且，所有的代理操作除了调用的方法不一样之外，其他的操作都一样，则此时肯定是重复代码。解决这一问题最好的做法是可以通过一个代理类完成全部的代理功能，那么此时就必须使用动态代理完成。 


##2. 动态代理



动态代理：jdk1.5中提供，利用反射。实现InvocationHandler接口。


> 业务接口还是必须得，业务接口，业务类同上。

###a. 代理类

	/*
	 * 动态代理类
	 * 
	 */
	public class DynamicProxy implements InvocationHandler {

		/* 需要代理的目标类 */
		private Object target;

		/*
		 * 写法固定，aop专用:绑定委托对象并返回一个代理类
		 * 
		 */
		public Object bind(Object target) {
			this.target = target;
			
			//要绑定接口(这是一个缺陷，cglib弥补了这一缺陷) 
			return Proxy.newProxyInstance(target.getClass().getClassLoader(), target.getClass().getInterfaces(), this);
		}

		/*
		 * @param Object
		 *            target：指被代理的对象。
		 * @param Method
		 *            method：要调用的方法
		 * @param Object
		 *            [] args：方法调用时所需要的参数
		 */
		@Override
		public Object invoke(Object proxy, Method method, Object[] args) throws Throwable {
			Object result = null;
			// 切面之前执行
			System.out.println("切面之前执行");
			// 执行业务
			result = method.invoke(target, args);
			// 切面之后执行
			System.out.println("切面之后执行");
			return result;
		}

	}

###b. 测试类

	/*
	 * 测试类
	 * 
	 */
	public class Test {

		public static void main(String[] args) {
			// 绑定代理，这种方式会在所有的方法都加上切面方法
			ITalk iTalk = (ITalk) new DynamicProxy().bind(new PeopleTalk());
			iTalk.talk("业务说明");
		}
	}

输出结果会是：

	切面之前执行
	业务说明
	切面之后执行

说明只要在业务调用方法切面之前和之后，是可以动态的加入需要处理的方法。

从代码来看，如果再建立一个业务模块，也只需要一个代理类。

> `ITalk iTalk = (ITalk) new DynamicProxy().bind(new PeopleTalk());`  将业务接口和业务类绑定到动态代理类。

但是这种方式：**还是需要定义接口**。


与静态代理类对照的是**动态代理类**，动态代理类的字节码在程序运行时由Java**反射机制**动态生成，无需程序员手工编写它的源代码。动态代理类不仅简化了编程工作，而且提高了软件系统的可扩展性，因为Java 反射机制可以生成**任意类型的动态代理类**。`java.lang.reflect` 包中的`Proxy`类和`InvocationHandler` 接口提供了生成动态代理类的能力。 

> **JDK的动态代理**依靠**接口**实现，如果有些类并没有实现接口，则不能使用JDK代理，此时，使用cglib动态代理。

##3. 利用cglib

> CGLIB是针对类来实现代理的，他的原理是对指定的目标类生成一个**子类**，并**覆盖其中方法实现增强**。采用的是**继承**的方式。不细说，看使用：

###a. 业务类

	/*
	 * 业务类
	 * 
	 */
	public class PeopleTalk {

		public void talk(String msg) {
			System.out.println("people talk" + msg);
		}

	}

###b. cglib代理类

	/*
	 * 使用cglib动态代理
	 * 
	 */
	public class CglibProxy implements MethodInterceptor {

		private Object target;

		/*
		 * 创建代理对象
		 * 
		 * @param target
		 * @return
		 */
		public Object getInstance(Object target) {
			this.target = target;
			Enhancer enhancer = new Enhancer();
			enhancer.setSuperclass(this.target.getClass());
			// 回调方法
			enhancer.setCallback(this);
			// 创建代理对象
			return enhancer.create();
		}

		@Override
		public Object intercept(Object proxy, Method method, Object[] args, MethodProxy methodProxy) throws Throwable {
			Object result = null;
			System.out.println("事物开始");
			result = methodProxy.invokeSuper(proxy, args);
			System.out.println("事物结束");
			return result;
		}

	}

###c. 测试类

	/*
	 * 测试类
	 * 
	 */
	public class Test {

		public static void main(String[] args) {
			PeopleTalk peopleTalk = (PeopleTalk) new CglibProxy().getInstance(new PeopleTalk());
			peopleTalk.talk("业务方法");
		}

	}

最后输出结果：

	事物开始
	people talk业务方法
	事物结束


由于篇幅有限，这篇主要对AOP的原理简单实现做了演示和阐述，有助自己理解。至于Spring的AOP实现上面无外乎其右，不过实现方面复杂的多。


* JDK的动态代理机制只能代理实现了**接口**的类，而不能实现接口的类就不能实现JDK的动态代理；
* cglib是针对**类**来实现代理的，他的原理是对指定的目标类生成一个**子类**，并覆盖其中方法实现增强，但因为采用的是继承，所以**不能对final修饰的类**进行代理；



##4. AOP 概念 

几个概念：

* Joinpoint（连接点）：程序执行时的某个特定的点，在Spring中就是某一个方法的执行 
* Pointcut（切点）：说的通俗点，spring中AOP的切点就是指一些方法的集合，而这些方法是需要被增强、被代理的。一般都是按照一定的约定规则来表示的，如正则表达式等。切点是由一类连接点组成。 
* Advice（通知)：还是说的通俗点，就是在指定切点上要干些什么。对于Spring AOP 来讲，有Before advice、AfterreturningAdvice、ThrowAdvice、AroundAdvice(MethodInteceptor)等
* Advisor（通知器)：其实就是切点和通知的结合
* Weaving：将Advisor加入到程序代码的过程，对于Spring AOP，由ProxyFactory或者ProxyFactoryBean负责织入动作。 
* Target：这个很容易理解，就是需要Aspect功能的对象。 
* Introduction：引入，就是向对象中加入新的属性或方法，一般是一个实例一个引用对象。当然如果不引入属性或者引入的属性做了线程安全性处理或者只读属性，则一个Class一个引用也是可以的（自己理解）。Per-class lifecycle or per-instance life cycle 

 


##5. AOP 种类 

* `静态织入`：指在编译时期就织入Aspect代码，AspectJ好像是这样做的。 
* `动态织入`：在运行时期织入，Spring AOP属于动态织入，动态织入又分静动两种，静则指织入过程只在第一次调用时执行；动则指根据代码动态运行的中间状态来决定如何操作，每次调用Target的时候都执行（性能较差）。 

##6. Spring AOP 代理原理 

Spring AOP 是使用代理来完成的，Spring 会使用下面两种方式的其中一种来创建代理： 

* **JDK动态代理**，特点只能代理**接口**，需要设定一组代理接口。 
* **CGLIB 代理**，可代理**接口**和**类**（`final method`，`final class`除外），本质生成子类。 


##7. Spring AOP 通知类型 

1、BeforeAdvice：前置通知需实现MethodBeforeAdvice，但是该接口的Parent是BeforeAdvice，致于什么用处我想可能是扩展性需求的设计吧。或者Spring未来也并不局限于Method的JoinPoint（胡乱猜测）。BeforeAdvice可以修改目标的参数，也可以通过抛出异常来阻止目标运行。 

2、AfterreturningAdvice：实现AfterreturningAdvice，我们无法修改方法的返回值，但是可以通过抛出异常阻止方法运行。 

3、AroundAdvice：Spring 通过实现MethodInterceptor(aopalliance)来实现包围通知，最大特点是可以修改返回值，当然它在方法前后都加入了自己的逻辑代码，因此功能异常强大。通过MethodInvocation.proceed()来调用目标方法（甚至可以不调用）。 

4、ThrowsAdvice：通过实现若干afterThrowing()来实现。 

5、IntroductionInterceptor：Spring 的默认实现为DelegatingIntroductionInterceptor 








##8. AOP的应用场景

在开发的过程中,我们总在专注逻辑的具体实现。但是，在实现过程中，我们不得不加上逻辑除外的其它处理，比如说，记录日志、异常处理、权限验证、事务管理等。 

在具体逻辑中，加上日志记录、权限验证等处理时有什么不妥呢？我认为主要有以下几点： 

1. **代码可读性**：大家都在追求简洁易读的代码，如果在具体逻辑实现中夹杂些与业务不相干的代码，这样的代码能简洁易读吗？ 
2. **代码移植性**： 代码开发过程中，大家都希望自己写的代码有复用性、移植性，这样，既减少了代码的开发量，又使自己的代码显得简洁。没听到大师常说吗？这框架还好，就是侵入性比较大，为什么侵入性不好，就是由于限制了开发出来代码的复用性和移植性。同理，在具体逻辑实现中夹杂与业务不相干的代码，同样限制了开发出来代码的复用性和移植性。 

怎么解决上面出现的问题呢？还好，可以使用java中的代理模式来解决这个问题。你可以采用自己写的接口代理来处理这个问题，也可以使用JDK自带的java动态代理。 



##9. 使用实例

* [Spring AOP]













##参考来源

* [理解AOP]
* [java动态代理（JDK和cglib）] *(力荐)*
* [Spring AOP 学习小结]
* [注解方式实现AOP的例子]
* [Spring AOP]














[NingG]:    http://ningg.github.com  "NingG"


[理解AOP]:							http://www.cnblogs.com/yanbincn/archive/2012/06/01/2530377.html
[java动态代理（JDK和cglib）]:		http://www.cnblogs.com/jqyp/archive/2010/08/20/1805041.html
[Spring AOP 学习小结]:				http://www.cnblogs.com/jqyp/archive/2010/08/20/1805033.html
[注解方式实现AOP的例子]:			http://xtu-xiaoxin.iteye.com/blog/630206
[Spring AOP]:						http://blog.csdn.net/xiaohai0504/article/details/6880991



