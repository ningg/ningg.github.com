---
layout: post
title: Java Enterprise Edition，Java EE，J2EE
description: Java EE本质是什么？
published: true
categories: web java
---

梳理几个小问题：

* Java Enterprise Edition，哪里提出的？
* Java EE，怎么定位？适用哪些场景，用于解决什么问题？
* Java EE，类似的东西还有吗？他们之间差异有哪些？

接触和使用Java EE有几年了，但上面的问题，还真没有去细查过，今天就来查一下。

查询之后，几点：

* 关于名称，Java EE、J2EE：
	* 在JDK 1.5 之前*（包含JDK 1.5）*，Java Enterprise Edition，简称为J2EE；
	* 从JDK 1.6 开始，Java Enterprise Edition，简称为Java EE；
* Java EE是什么？下面几个术语的关系：
	* servlet
	* JSP
	* Java EE，就是Java web？
	* Spring mvc
	* web.xml文件


##常见问题

###Servlet vs. JSP

简要列几点：*（未整理完）*

* 现有Servlet规范，后又JSP规范产生；
* JSP出现之前，Servlet中负责以流形式，输出最终的页面，流中手动书写了大量的HTML标签；即，Servlet同时负责逻辑处理以及页面显示；
* JSP出现之后，最终页面使用JSP来编写，其中可以嵌入JavaBean的信息，实现了页面显示与后端处理逻辑的分离；
* 本质上：JSP执行之前，也要编译为Servlet；

补充几点：

* Servlet和JSP都是是规范，在JCP（[Java Community Process][Java Community Process]）中可以找到*（通过搜索框，直接搜索关键词`Servlet`或者`JSP`）*；
* 列两个当前常用的规范：
	* [JSR 315: JavaTM Servlet 3.0 Specification][JSR315]
	* [JSR 245: JavaServerTM Pages 2.1][JSR245]
* Tomcat是Servlet/JSP运行容器，具体这一容器支撑哪个版本规范，可以从Tomcat官网上查看得知，例如，[Tomcat8.0][Tomcat8.0]的Documentation中提到，Tomcat v8.0 实现了 Servlet 3.1 和 javaServer Pages 2.3两个规范；



更多细节，参考：

* [Difference Between Servlet and JSP][Difference Between Servlet and JSP]
* [Java Community Process][Java Community Process]






















##参考来源

* [Difference Between Servlet and JSP][Difference Between Servlet and JSP]










[NingG]:    				http://ningg.github.com  "NingG"



[Difference Between Servlet and JSP]:		http://www.javabeat.net/difference-servlet-jsp/
[Java Community Process]:					https://www.jcp.org/en/home/index
[JSR315]:									https://www.jcp.org/en/jsr/detail?id=315			"JSR 315: JavaTM Servlet 3.0 Specification"
[JSR245]:									https://www.jcp.org/en/jsr/detail?id=245			"JSR 245: JavaServerTM Pages 2.1"
[Tomcat8.0]:								http://tomcat.apache.org/tomcat-8.0-doc/index.html






