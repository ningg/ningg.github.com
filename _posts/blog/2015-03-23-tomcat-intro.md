---
layout: post
title: Tomcat 入门
description: Tomcat是一个web容器，如何启动、常用配置又有哪些？
published: true
category: tomcat
---

几点：

* 如何安装、启动Tomcat？
* Tomcat中常用的配置，以及含义？
* Tomcat的基本原理？
	* Tomcat的运行机制；
	* web在Tomcat中的处理过程；


##简介

Apache Tomcat，开源软件*（这句是废话）*，支持Java Servlet和JavaServer Pages（JSP）的实现，具体Java Servlet和JavaServer Pages specification是由JCP（Java Community Process）主导制定。

	

##安装、启动Tomcat

几个步骤：

* 到[Apache Tomcat][Apache Tomcat]下载Tomcat 7.0.59；
* 解压；
* 执行`$APACHE_HOMT/bin/startup.bat`；
* 通过浏览器访问：`http://localhost:8080`即可看到Tomcat主页面；


实际上，执行`$APACHE_HOMT/bin/startup.bat`后，会出现如下信息：

	2015-3-23 16:51:55 org.apache.coyote.AbstractProtocol start
	信息: Starting ProtocolHandler ["http-apr-8080"]
	2015-3-23 16:51:55 org.apache.coyote.AbstractProtocol start
	信息: Starting ProtocolHandler ["ajp-apr-8009"]
	2015-3-23 16:51:55 org.apache.catalina.startup.Catalina start
	信息: Server startup in 691 ms

上述信息中，出现的两个数字`8080`、`8009`为Tomcat默认监听的端口。



##Tomcat常用配置

（常用场景）







##Tomcat基本原理

推荐资料：

* [Tomcat/Apache 6][Tomcat/Apache 6]
* [Apache Tomcat 7-more about the cat][Apache Tomcat 7-more about the cat]
* [How to Install Apache Tomcat and Get Started with Java Servlet Programming][How to Install Apache Tomcat and Get Started with Java Servlet Programming]

疑问：tomcat运行时，是一个Process，那在tomcat容器中部署的web应用，是作为process启动的？还是直接thread？















##参考来源

* [Apache Tomcat][Apache Tomcat]
* [Apache Tomcat 7-more about the cat][Apache Tomcat 7-more about the cat]
* [How to Install Apache Tomcat and Get Started with Java Servlet Programming][How to Install Apache Tomcat and Get Started with Java Servlet Programming]






##杂谈

重走web路，一年多没碰web的东西，该忘的都忘了，用到的时候，需要重新查阅，现在只有解决问题的基本思路，索性借着这次重新使用java web的机会把整体的内容再过一遍。







[NingG]:    http://ningg.github.com  "NingG"


[Apache Tomcat]:								http://tomcat.apache.org/
[Apache Tomcat 7-more about the cat]:			http://www.ntu.edu.sg/home/ehchua/programming/howto/Tomcat_More.html
[How to Install Apache Tomcat and Get Started with Java Servlet Programming]:	http://www.ntu.edu.sg/home/ehchua/programming/howto/Tomcat_HowTo.html
[Tomcat/Apache 6]:								http://www.datadisk.co.uk/html_docs/java_app/tomcat6/tomcat6.htm










