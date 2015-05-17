---
layout: post
title: Java中对象产生初始化过程
description: 父类什么时候初始化？构造函数和类变量呢？
category: jvm
---

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



[java中对象产生初始化过程]:			http://blog.csdn.net/mashangyou/article/details/24529583
[Java中类的初始化顺序总结]:			http://blog.csdn.net/jinyongqing/article/details/7631788






