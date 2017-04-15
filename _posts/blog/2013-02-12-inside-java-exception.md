---
layout: post
title: Java 剖析：异常处理
description: 异常如何捕获？如何定制返回用户的信息？主动抛出异常？
category: java
---

放松一下，当一个小白，面对**异常**，列几个简单的问题：

1. 异常，有什么用？
2. 异常，分为几类？分别要处理什么问题？
3. Spring 框架下，有没有统一的异常处理机制？

## 异常，有什么用？

程序执行过程中，主程序无法正常执行时，会**抛出一个信息**，告知原因。

Java 语言提供的 `Throwable` 类（*不是接口，是类*），就是用来抛出信息的。

至于抛出信息后，需要考虑几个问题：

1. 是否要继续执行？还是直接中断执行？
2. 是否有可能恢复正常？
3. 如何输出现场状态？

## 异常，分为几类？

![](/images/inside-java/exception-with-throwable-exception-runtimeexception.jpg)

Java 中，`Throwable` 类，有 3 个子类：

1. Error：错误
1. Exception：异常
	1. 受检异常（checked exception）：编写程序是，必须显式处理，一般声明在方法上
	1. 运行时异常（run-time exception）：非受检异常

Note：

> Java 中，Error、Exception、RuntimeException ：
> 
> 1. 父类都是：Throwable
> 2. Error：错误，程序无法恢复，中断执行
> 3. Exception：分为 2 类，受检异常和非受检异常（*又称运行时异常*）
> 4. RuntimeException：运行时异常，非受检异常
> 5. RuntimeException 是 Exception 的子类

关于 Java 中异常机制，具体使用场景：

1. Error：错误
	1. 致命错误，不可恢复
	1. 通常是配置参数问题，
	1. 比如 OOME(OutOfMemoryError)、NoClassDefFoundError
2. RuntimeException：运行时异常，非受检异常，一般无法确定异常原因
	1. 运行时异常，不可恢复
	1. 一般是程序编写 bug
	1. 比如：越界异常 IndexOutOfBoundsException，空指针异常 NPE（NullPointerException）
3. Exception：受检异常，知道异常的发生原因，有可能能恢复
	1. 知道异常原因，有可能能恢复
	1. 比如：FileNotFoundException、IOException


一般在业务编写过程中，个人偏向**自定义异常**，都是 `RuntimeException` 的子类，然后，利用统一的异常处理机制，在程序入口，捕获所有异常，并输出错误日志和异常栈。

具体场景下，捕获异常之后：

* 本地输出错误日志和异常栈，方便问题定位和分析
* 返回定制的信息，为用户返回提示信息
* 终止后续业务逻辑，直接返回，fail-fast 策略

## 讨论：统一异常处理机制

在指定的逻辑分层上进行统一的异常捕获；思考：

* controller？
* service？

因为 Controller 是程序入口，因此，在 Controller 上统一处理异常即可。



Java 中异常处理机制：

* 法级别的抛出异常 `throws Exception`；
	* 特点：抛出异常之后，后续代码不再执行；
	* 优势：代码易读，没有太多的try…catch结构；
	* 劣势：直接返回系统默认的Exception信息；
* 针对代码片段的主动捕获异常，并且定制抛出异常；
	* `try{…}catch(Exception e){ throw Exception; }finally{…}`
	* 特点：捕获异常之后，除非主动处理，否则，catch{}之外的代码，仍会继续执行；
	* 优势：定制异常的返回信息；
	* 思考：catch从小到大？finally{}的作用？

受检异常，转换为非受检异常，并抛出异常，终止当前线程执行，示例代码：

	...
	} catch (IOException ioe) {
      throw new FlumeException("Error instantiating spooling event parser",
          ioe);
    }

`FlumeException.java`源文件：

	package org.apache.flume;

	/*
	 * Base class of all flume exceptions.
	 */
	public class FlumeException extends RuntimeException {

	  private static final long serialVersionUID = 1L;

	  public FlumeException(String msg) {
		super(msg);
	  }

	  public FlumeException(String msg, Throwable th) {
		super(msg, th);
	  }

	  public FlumeException(Throwable th) {
		super(th);
	  }

	}


连续多个`catch(Exception exception)`动作，什么作用？

Re: 针对不同的异常，进行不同的处理，比如，事务的提交？回滚？

	try {
		...
	} catch (FlumeException ex){
		transaction.rollback();
	} catch (Exception ex){
		transaction.rollback();
		String errorMsg = "Failed to publish event: " + event ;
		logger.error(errorMsg);
		throw new EventDeliveryException(errorMsg, ex);
	} finally {
		transaction.close();
	}


下面代码的含义：

Re：输出异常发生时，输出一场栈，同时转换为 RuntimeException，向上传播/抛出。

	e.printStackTrace();
	Throwables.propagate(e);



## 参考来源

* 《Effective Java》 Chapter 9：Exception
* [异常 Of novoland](http://novoland.github.io/%E8%AE%BE%E8%AE%A1/2015/08/17/%E5%BC%82%E5%B8%B8.html)
* [Java Tutorial--Lesson: Exceptions][Java Tutorial--Lesson: Exceptions]
* [Java异常系统](http://kakack.github.io/2015/03/Java%E5%BC%82%E5%B8%B8%E7%B3%BB%E7%BB%9F/)

	








[NingG]:    http://ningg.github.com  "NingG"
[Java Tutorial--Lesson: Exceptions]:			http://docs.oracle.com/javase/tutorial/essential/exceptions/

