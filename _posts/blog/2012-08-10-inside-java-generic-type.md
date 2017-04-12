---
layout: post
title: Java 剖析：Generic Type（泛型）
description: 泛型是什么？如何使用？
published: true
category: java
---

ArrayList很常见，泛型也是，泛型对集合类尤其有用。

关键的问题：

* 为什么要使用泛型？

## 一、泛型

泛型（Generic Type）的主要作用：

* 类/接口/方法，能够被不同类型对象重用：只存在一份 class 文件（字节码文件）
* 编译期，类型检查，发现 bug；

Tips：

> 1. 编译期，是指源代码翻译成机器识别的代码。
> 2. 运行时，是指代码在机器中运行。
> 
> Java中，泛型只存在编译期，运行时，不存在泛型。


## 二、实现没有泛型的简易版ArrayList

简易版的ArrList有个Obejct对象（因为是Object，我们可以add任意类型。）比如说，Integer 和 String的。代码如下：

	package javaBasic.generic;
	 
	/*
	 * 简易版ArrayList
	 */
	class ArrList
	{
		private Object obj;
	 
		public Object getObj()
		{
			return obj;
		}
	 
		public void add(Object obj)
		{
			this.obj = obj;
		}
		 
	}
	 
	public class TestArrayList
	{
		public static void main(String[] args)
		{
			ArrList arrList = new ArrList();
			arrList.add(1);
			arrList.add("1");
			 
			Integer objInt = (Integer) arrList.getObj();
			System.out.println(objInt);
		}
	}

运行可以看出会出现ClassCastException：


	Exception in thread "main" java.lang.ClassCastException: java.lang.String cannot be cast to java.lang.Integer
		at javaBasic.generic.TestArrayList.main(TestArrayList.java:30)

想问的问题是：”这Object对象属性，怎么不能强转呢？“

答：编译时，代码没错的。运行main时，当set了String类型时，将结果强制转换为Integer就会报错。

泛型的作用：

1. 泛型，相比于需要强制转换的Object代码，具有更好的安全性和可读性。
2. 泛型，在`编译期` `类型检查`，发现bugs

## 三、使用改写简易版ArrayList

使用泛型代码如下：

	package javaBasic.generic;
	 
	/*
	 * 简易版ArrayList
	 */
	class ArrList<T>
	{
		private T obj;
	 
		public T getObj()
		{
			return obj;
		}
	 
		public void add(T obj)
		{
			this.obj = obj;
		}
		 
	}
	 
	public class TestArrayList
	{
		public static void main(String[] args)
		{
			ArrList<Integer> arrList = new ArrList<>();
			arrList.add(1);
	//      arrList.add("1");
			 
			Integer objInt = arrList.getObj();
			System.out.println(objInt);
		}
	}

这时候如果想用`arrList.add("1");`会发现：IDE环境主动报错:

![](/images/java-generic-type/image_thumb.png)


Java 泛型只是编译期的概念，因为编译后类型会被擦除，还原真实类型。上述例子中，T 就相当于Integer。


Tips：

> 如何编写泛型（Generic Type）？最简单的方式：`public class CLASSNAME<K, V>{...}`直接在类名后添加`<>`即可，内部可以指定多个泛型。

## 四、泛型分类

根据位置不同，泛型可以分为：

* 泛型类
* 泛型接口
* 泛型方法

泛型类:

	public class Holder<T> {
		public final T obj;
		public Holder(T obj) {
			this.obj = obj;
		}
		public T get() {
			return obj;
		}
	}

泛型接口：泛型接口可以用来做生成器，专门用来负责创建对象的类。

	public interface Generator<T> {
		public T generate();
	}

泛型方法：泛型与其所在的类是否是泛型类没有关系，但是对于一个static方法来说，无法访问泛型类的类型参数，所以如果一个static方法想使用泛型能力，就必须让它成为泛型方法。

	public class Test{
		public <T> void set(T x) {
			System.out.println(x.getClass().getName());
		}

		public <H> H get(Class<H> m) {
			m.getName();
			return m;
		}
	 
		public static <M> void m(M m) {
			m.getClass().getName();
		}
	}




## 五、小结

泛型，作用：

1. **类型安全**：泛型，定义了变量类型，编译期间就可以类型检查；
2. **消除类型强制转换**：避免手动的强制类型转换，强制类型转换是自动和隐式的，代码可读性好；
3. 代码重用：更好的安全性和可读性

泛型，实现细节：

1. 编译时，`类型检查`；
2. 编译时，`类型擦除`；
3. 泛型类，编译后的 class 文件，不包含泛型的概念，`底层是 Object` 类型；
4. 一个泛型的类，底层都是同一个 class 文件，泛型参数对应底层是 Object 类型；
5. 调用类，生成的字节码中
	1. `编译时`，将强制`类型转换` `插入字节码`中
	1. `运行时`，进行强制类型转换；


## 六、参考资料



* [Java泛型详解]
* 《Effective Java （第2版）》 第5章 泛型




[NingG]:    http://ningg.github.com  "NingG"
[Java泛型详解]:				http://www.cnblogs.com/lzq198754/p/5780426.html



