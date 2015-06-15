---
layout: post
title: Spring之AOP--代理模式
description: AOP的实例、底层原理
published: true
categories: Spring Java
---


关于Spring AOP，几点：

* 有什么用？
* 使用实例
* 底层原理
* 常用术语


几点：

* 代理模式：静态代理、动态代理、cglib代理
* 使用场景：日志；
* 常用术语：
* 实例






Aspect Oriented Programming  面向切面编程。解耦是程序员编码开发过程中一直追求的。AOP也是为了解耦所诞生。

> 具体思想是：定义一个切面，在切面的纵向定义处理方法，处理完成之后，回到横向业务流。

AOP 在Spring框架中被作为核心组成部分之一，的确Spring将AOP发挥到很强大的功能。最常见的就是事务控制。工作之余，对于使用的工具，不免需要了解其所以然。学习了一下，写了些程序帮助理解。

AOP 主要是利用**代理模式**的技术来实现的。

##1、静态代理：就是设计模式中的proxy模式

###a、业务接口

	/*
	 * 抽象主题角色：声明了真实主题和代理主题的共同接口。
	 * 
	 */

	public interface ITalk {

		public void talk(String msg);

	}

###b、业务实现

	/*
	 * 真实主题角色：定义真实的对象。
	 * 
	 */
	public class PeopleTalk implements ITalk {

		public String username;
		public String age;

		public PeopleTalk(String username, String age) {
			this.username = username;
			this.age = age;
		}

		public void talk(String msg) {
			System.out.println(msg + "!你好,我是" + username + "，我年龄是" + age);
		}

		public String getName() {
			return username;
		}

		public void setName(String name) {
			this.username = name;
		}

		public String getAge() {
			return age;
		}

		public void setAge(String age) {
			this.age = age;
		}

	}

###c、代理对象

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


###d、测试类

	/*
	 * 代理测试类，使用代理
	 *
	 */
	public class ProxyPattern {

		public static void main(String[] args) {
			// 不需要执行额外方法的。
			ITalk people = new PeopleTalk("AOP", "18");
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



##2、动态代理



动态代理：jdk1.5中提供，利用反射。实现InvocationHandler接口。


> 业务接口还是必须得，业务接口，业务类同上。

###a、代理类：

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

###b、测试类

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
	people talk业务说法
	切面之后执行

说明只要在业务调用方法切面之前，是可以动态的加入需要处理的方法。

从代码来看，如果再建立一个业务模块，也只需要一个代理类。

> ITalk iTalk = (ITalk) new DynamicProxy().bind(new PeopleTalk());  将业务接口和业务类绑定到动态代理类。

但是这种方式：**还是需要定义接口**。

##3、利用cglib

CGLIB是针对类来实现代理的，他的原理是对指定的目标类生成一个子类，并覆盖其中方法实现增强。采用的是继承的方式。不细说，看使用

###a、业务类

	/*
	 * 业务类
	 * 
	 */
	public class PeopleTalk {

		public void talk(String msg) {
			System.out.println("people talk" + msg);
		}

	}

###b、cglib代理类

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

###c.测试类

	/*
	 * 测试类
	 * 
	 */
	public class Test {

		public static void main(String[] args) {
			PeopleTalk peopleTalk = (PeopleTalk) new CglibProxy().getInstance(new PeopleTalk());
			peopleTalk.talk("业务方法");
			peopleTalk.spreak("业务方法");
		}

	}

最后输出结果：

	事物开始
	people talk业务方法
	事物结束
	事物开始
	spreak chinese业务方法
	事物结束

由于篇幅有限，这篇主要对AOP的原理简单实现做了演示和阐述，有助自己理解。至于Spring的AOP实现上面无外乎其右，不过实现方面复杂的多。

notes：上述输出，有错。















##参考来源

* [理解AOP]


















[NingG]:    http://ningg.github.com  "NingG"


[理解AOP]:					http://www.cnblogs.com/yanbincn/archive/2012/06/01/2530377.html







