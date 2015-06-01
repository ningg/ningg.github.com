---
layout: post
title: 单例模式
description: 设计一个类，只能生成该类的一个实例，如何实现？
published: true
category: CS basic
---


> 单例模式：设计一个类，要求只能生成该类的一个实例，如何实现？

单例模式的具体要求：

* 单例类，只能有一个实例
* 单例类，必须自己创建这个实例
* 单例类，必须为其他对象，提供这一实例

开始之前，先说一下“设计模式”，这个跟数据库设计的 3 个范式类似，都是从常用的经验中整理出来的。


##分析

几点：

* 编写一个类，有通用的写法
* 由于只能生成该类的一个实例，因此，类的构造方法必须私有
* 不能通过类的构造方法访问，只能利用静态方法，获取类的实例
* 类没有实例化时，只能访问类的静态成员变量
* 需要保证多线程访问时，也只能生成该类的一个实例
* 第一次调用时，才去创建类的实例，能够提升空间的使用效率


##实现

为了提升空间利用率，两种方式：

* 类加载时，就进行实例化；*（饿汉式单例）*
* 在第一次调用时，才去实例化对象；*（懒汉式单例）*


###恶汉式单例


代码如下：

	package top.ningg.java.singleton;

	public class Singleton {

		private Singleton(){
			
		}
		
		private static Singleton singleton = new Singleton();
		
		public static synchronized Singleton getInstance(){
			return singleton;
		}
	}



###懒汉式单例


代码如下：

	package top.ningg.java.singleton;

	public class Singleton {

		private Singleton(){
			
		}

		private static Singleton singleton = null;
		
		public static synchronized Singleton getInstance(){
			if(singleton == null){
				singleton = new Singleton();
			}
			return singleton;
		}
	}




































[NingG]:    http://ningg.github.com  "NingG"











