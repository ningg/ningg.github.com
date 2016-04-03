---
layout: post
title: java中保留字--static、final
description: 
category: java
---


本文采用如下方式来整理：

* 场景
* 总结

## static


### import static class

遇到一种情况，常量所在类，被利用`import static classname`，例：

	import static org.apache.flume.source.SpoolDirectorySourceConfigurationConstants.*;
	...
	spoolDirectory = context.getString(SPOOL_DIRECTORY);
	...



### private static class

内部类：private static class

内部类，static class Builder？什么场景下使用？还需要new这个对象吗？（具体参考SpoolingDirectorySource.java）内部builder类，来构造对象？

* http://docs.oracle.com/javase/tutorial/java/javaOO/nested.html 
* http://stackoverflow.com/questions/7486012/static-classes-in-java 
* http://www.cnblogs.com/Alex--Yang/p/3386863.html 《Effective Java》P94










## final


### 常量命名

示例代码，参考：

	public static final String SPOOL_DIRECTORY = "spoolDir";



**思考**：使用`final`定义的常量，能够被修改吗？由于是`static`的变量，因此不需要实例化类的对象，直接调用class就能获取。


示例代码，参考：

	private final long length;
	
**思考**：上述使用`final`来标识成员`length`为常量，但为赋值，是否是在class实例化时，通过构造方法对`length`进行初始化赋值，并且由于使用final修饰，`length`在赋值之后不能再被修改？即：

* `final`修饰的成员变量，一旦赋值，不能更改；



## synchronized 


## 子类override method时，添加synchronized


	@Override
	public synchronized void configure(Context context) {
		spoolDirectory = context.getString(SPOOL_DIRECTORY);
	}



## transient

见到代码如下：

	private transient String charset = "UTF-8";

上述`transient`什么含义？























## 参考来源




















[NingG]:    http://ningg.github.com  "NingG"












