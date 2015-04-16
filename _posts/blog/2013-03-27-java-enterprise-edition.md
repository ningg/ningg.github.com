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

###Java EE

简要几点：

* Java EE（Java Plantform，Enterprise Edition），是一系列标准的集合，有个白皮书；
	* 疑问：对应一个标准白皮书？在[官网][Java EE at a Glance]，可以查看到[Java EE的白皮书][Java EE 7 Whitepaper]，其中对Java EE的定位有详细说明；
	* Java EE这个标准/规范，包含了很多其他的规范？
* Java EE 有很多实现，例如，当前[官网][Java EE at a Glance]提到，有20+种 Java EE 6的具体实现；
* Java EE，也是一个标准，在JCP（[Java Community Process][Java Community Process]）中可以搜索`java ee`找到相应的标准；
* Java EE，只是标准，需要依托具体的lib实现；

通过查看[Java EE的白皮书][Java EE 7 Whitepaper]可知，Java EE 7包含了14个JSR（Java Specification Requests）：

* JSR 236: Concurrency Utilities for Java EE 1.0 
* JSR 338: Java Persistence API 2.1 
* JSR 339: Java API for RESTful Web Services 2.0 
* JSR 340: Java Servlet 3.1 
* JSR 341: Expression Language 3.0 
* JSR 342: Java Platform, Enterprise Edition 7 
* JSR 343: Java Message Service 2.0 
* JSR 344: JavaServer Faces 2.2  
* JSR 345: Enterprise JavaBeans 3.2 
* JSR 346: Contexts and Dependency Injection for Java EE 1.1 
* JSR 349: Bean Validation 1.1 
* JSR 352: Batch Applications for the Java Platform 1.0 
* JSR 353: Java API for JSON Processing 1.0 
* JSR 356: Java API for WebSocket 1.0

上述查证来看，如何利用Java EE来进行java web的开发呢？在[官网][Java EE at a Glance]上仔细瞅瞅，看到了吧：[Java EE7 Tutorial][Java EE7 Tutorial]，到页面中一看，很多实用资料：Tutorials、Release Documentation、API Documentation and Tag Reference等等；特别是两个内容：

* [Your First Cup: An Introduction to the Java EE Platform][Your First Cup - An Introduction to the Java EE Platform]
* [The Java EE 7 Tutorial][The Java EE 7 Tutorial]

支持Java EE的服务器：

* Java EE的官网上，提到了GlassFish，但没提Tomcat，参考[Java EE Compatibility][Java EE Compatibility]；
* Tomcat官网上，提到Tomcat是支持Java EE的，参考[Tomcat Specification][Tomcat Specification]；*（疑问：此处说Tomcat支持Java EE API，是只支持Java EE的完整标准吗？不是完整标准，实现完整Java EE标准的是TomEE）*


更多细节，参考：

* [Java EE at a Glance][Java EE at a Glance]
* [Java EE 7 Whitepaper][Java EE 7 Whitepaper]

####如何学习Java EE？

有两种观点：

* 买本书，照着学习；
* 不需要买书，参考官方tutorial就行了；

到底应该怎么做呢？

* 直接动手开干？你不是通过读书，学会骑自行车的；
* 有一本书籍和tutorial作为参考？

更多内容，参考：[What to learn for making Java web applications in Java EE 6?][What to learn for making Java web applications in Java EE 6?]

####Java EE Web Profile vs. Full Platform

一个是简介版，包含的jar包较少，另一个是完整版，包含Java EE的完整jar包。JCP中有两者的规范。更多信息参考[Introducing the Java EE Web Profile][Introducing the Java EE Web Profile]。


###Spring web

几个疑问：

* Spring web就是 Spring MVC？
* Spring 也能用于进行web开发，也是一系列规范？还是一些列组件和实现？










###web.xml文件

几个疑问：

* 为什么要存在web.xml？web.xml文件的放置位置？*（为什么有web.xml？）*
* web.xml内部结构以及内容？*（怎么写web.xml文件？）*

####文件web.xml存在的意义

几点：

* web.xml是在JCP下的Servlet规范中提出的；
* 位置：`APP_ROOT/WEB-INF/web.xml`，应用部署时的说明文件（Deployment Descriptor）；参考：[JSR315][JSR315]中Web Applications下Deployment Hierarchies章节内容；
* 当没有servlet、filter、listener等时，不比配置web.xml文件；即，只有静态文件和JSP页面时，可以没有web.xml文件；参考：[JSR315][JSR315]中Web Applications下Inclusion of a web.xml Deployment Descriptor章节内容；

####如何写web.xml文件？

直接参考：[JSR315][JSR315]中Deploment Descriptor章节内容即可。*（会针对web.xml文件单独整理一篇博文）*

####web.xml文件与WAR包间关系


web.xml是遵循servlet规范的，war包是否也是符合servlet规范的？有一篇[博文](http://ningg.top/java-war-format/) 中提及，但并没有深入讨论，仅参考。

思考：jar、war、ear文件组织结构的用途？原始参考来源？


##闲聊


当前java & scala的web框架Play，已经逐渐流行起来了，如果继续做web方面内容，需要了解、熟悉一下：

* [PlayFramework][PlayFramework]



##参考来源

* [Difference Between Servlet and JSP][Difference Between Servlet and JSP]
* [Java EE at a Glance][Java EE at a Glance]
* [JSR315][JSR315]
* [JSR245][JSR245]
* [Java EE 7 Whitepaper][Java EE 7 Whitepaper]
* [Java Community Process][Java Community Process]
* [Tomcat8.0][Tomcat8.0]
* vdisk下github/jvm目录内，上传了几个JSR，方便查看；
* 多在[Java EE官网][Java EE at a Glance]点击链接，会发现很多整理好的内容，如果有的链接是无效的，就想办法找到对应的有效链接，例如Java EE Tutorial。







[NingG]:    				http://ningg.github.com  "NingG"



[Difference Between Servlet and JSP]:		http://www.javabeat.net/difference-servlet-jsp/
[Java Community Process]:					https://www.jcp.org/en/home/index
[JSR315]:									https://www.jcp.org/en/jsr/detail?id=315			"JSR 315: JavaTM Servlet 3.0 Specification"
[JSR245]:									https://www.jcp.org/en/jsr/detail?id=245			"JSR 245: JavaServerTM Pages 2.1"
[Tomcat8.0]:								http://tomcat.apache.org/tomcat-8.0-doc/index.html
[Tomcat Specification]:						http://wiki.apache.org/tomcat/Specifications
[Java EE at a Glance]:						http://www.oracle.com/technetwork/java/javaee/overview/index.html
[Java EE 7 Whitepaper]:						http://www.oracle.com/technetwork/java/javaee/javaee7-whitepaper-1956203.pdf
[Java EE7 Tutorial]:						http://docs.oracle.com/javaee/7/index.html
[Your First Cup - An Introduction to the Java EE Platform]:		https://docs.oracle.com/javaee/7/firstcup/index.html
[The Java EE 7 Tutorial]:					https://docs.oracle.com/javaee/7/tutorial/index.html
[What to learn for making Java web applications in Java EE 6?]:			http://stackoverflow.com/questions/1960280/what-to-learn-for-making-java-web-applications-in-java-ee-6
[Java EE Compatibility]:					http://www.oracle.com/technetwork/java/javaee/overview/compatibility-jsp-136984.html
[Introducing the Java EE Web Profile]:		http://jaxenter.com/introducing-the-java-ee-web-profile-103275.html
[PlayFramework]:							https://www.playframework.com/

