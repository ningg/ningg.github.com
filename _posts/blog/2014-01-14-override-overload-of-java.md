---
layout: post
title: java 重载 & 重写
description: java对象，强制类型转换后，方法调用时，潜在的问题
category: java
---

##问题背景

阅读程序时，看到在子类中的各种@Override的注解，例如：

	public class A{
		public void speak(int i){
			  ...
		}
		...
	}
	 
	public class B extends A{
		@Override
		public void speak(int i){
			  ...
		}
		...
		public static void main(String[] args){
			B b = new B();
			A a1;
			a1 = (A)b;
	 
			a1.speak(1);
		}
	}

类`B`继承了`A`，并且在`B`中`Override`了方法`speak()`;现在问`a1.speak(1)`调用的是`class A`？`class B`？中的`speak()`方法？

##分析

上面的例子是一个典型的`重写`，因为：`subclass`中方法的名称、输入参数、返回参数都与`supclass`中完全相同。

现在有一个问题：重写的方法前没有`@Override`行不行？*(这个问题很好，说明you’re thinking。)*没有`@Override`的注解完全可以，只需要满足：`subclass`中方法的名称、输入参数、返回参数与`supclass`中完全相同即可实现方法的重写。

现在问题又来了：既然没有`@Override`也能实现方法的重写，为什么很多地方都加了`@Override`？原因很简单，添加了`@Override`，编译器会依照`supclass`中方法来进行检查，保证此方法真的实现重写。（避免了因为粗心等造成的`bug`）

__重写（`override`）__：就是覆盖；基于继承的，重写父类的方法，方法名什么都一样，方法体不同。

* 相同的名称；
* 相同的返回类型；
* 子类中，重写的方法访问修饰符权限保持一致，或者增大（`public`>`protected`>`default`>`private`）；
* 子类中，重写的方法抛出的异常不能变的更宽泛；

__重载（`overload`）__：基于同一个类的，不同的重载方法，主要是参数列表不同

* 相同的名称；
* 必须有不同的参数列表；
* 可以有不同的返回类型，可以有不同的访问修饰符，可以抛出不同的异常；

__重写 & 重载__：都是多态性的体现，重写是子类与父类间的多态性，重载是同一类中多态性的体现。

##参考来源

1. <http://blog.csdn.net/smyhmz/article/details/2716638>
2. <http://blog.csdn.net/leonardwang/article/details/7046180>


[NingG]:    http://ningg.github.com  "NingG"
