---
layout: post
title: java中输出日志log4j和slf4j
description: 
categories: log java
---


几个要点：

* 在程序中插入，输出log的代码；
* 配置最终log文件的生成策略；



## slf4j

几点：

* 声明一个私有的常量的类成员（private static final）；
	* org.slf4j.Logger
	* org.slf4j.LoggerFactory.getLogger(Class)
* 记录日志
	* logger.info(String);
	* logger.info(String, Object);
	* logger.info(String, Object[]);

示例代码如下：

	...
	// 声明
	private static final Logger logger = LoggerFactory.getLogger(SpoolDirectorySource.class);
	...

	// 记录日志
	logger.info("SpoolingDirectorySource source starting with directory: {}", spoolDirectory);
	...

	// 不同级别日志
	if (logger.isDebugEnabled()) {
	  logger.debug("Initializing {} with directory={}, metaDir={}, " +
		  "deserializer={}",
		  new Object[] { ReliableSpoolingFileEventReader.class.getSimpleName(),
		  spoolDirectory, trackerDirPath, deserializerType });
	}

**思考**：几点：

* logger，必须为static final吗？难道一个class对应的logger，用于记录所有object对应的异常？
* 构造`Object[]`：
	* new Object[] {String, String}：本质是数组Array，之前有一篇blog可以[参考][Java中数组Array]。
	




















## 参考来源





















[NingG]:    http://ningg.github.com  "NingG"


[Java中数组Array]:				http://ningg.github.io/java-array/









