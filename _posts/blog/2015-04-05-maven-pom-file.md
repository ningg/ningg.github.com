---
layout: post
title: Maven中pom文件如何编写
description: pom文件中依赖、编译、范围、属性，这些东西怎么写？工程的pom、模块的pom怎么写？
published: true
category: maven
---




##properties定义与调用

定义，典型的xml定义属性的方式：

	<properties>
		<spring.version>4.1.6.RELEASE</spring.version>
	</properties>


调用，与shell中调用变量一致：

	<version>${spring.version}</version>

疑问：xml变量的定义，有规范吗？


##dependency的内scope的含义


几点：

* scope的含义；
* scope都有哪些取值；


##如何注释？

xml中如何注释？

	<!-- -->

































[NingG]:    http://ningg.github.com  "NingG"










