---
layout: post
title: Java中异常处理
description: 异常如何捕获？如何定制返回用户的信息？主动抛出异常？
category: java
---


TODO


java中异常处理机制：

* 法级别的抛出异常 `throws Exception`；
	* 特点：抛出异常之后，后续代码不再执行；
	* 优势：代码易读，没有太多的try…catch结构；
	* 劣势：直接返回系统默认的Exception信息；
* 针对代码片段的主动捕获异常，并且定制抛出异常；
	* `try{…}catch(Exception e){ throw Exception; }finally{…}`
	* 特点：捕获异常之后，除非主动处理，否则，catch{}之外的代码，仍会继续执行；
	* 优势：定制异常的返回信息；
	* 思考：catch从小到达？finally{}的作用？

具体场景下，捕获异常之后，

* 返回定制的信息；
* 不再执行后续代码；

在指定的逻辑分层上进行统一的异常捕获；思考：

* controller？
* service？


主动抛出异常，示例代码：

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

	e.printStackTrace();
	Throwables.propagate(e);







##参考来源

* [Java Tutorial--Lesson: Exceptions][Java Tutorial--Lesson: Exceptions]

	



[NingG]:    http://ningg.github.com  "NingG"


[Java Tutorial--Lesson: Exceptions]:			http://docs.oracle.com/javase/tutorial/essential/exceptions/

