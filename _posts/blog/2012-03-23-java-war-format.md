---
layout: post
title: Java WAR包的格式
description: java web 打包方式的说明
published: true
category: java
---

##简介

java web 工程，包含几部分：

* web components *（是什么？）*
* web resources，例如静态图片等；



关于 java web，几点：

* 需要符合 Java Servlet specification；


##WAR格式

WAR格式，就是部署java web的目录组织结构。

![](/images/java-war-format/web-module-structure.png)


关于目录结构，几点：

* Assembly Root，整个java web的根目录；
* WEB-INF，核心处理逻辑的位置；
	* web.xml，web资源表述文件；
	* classes目录，核心处理逻辑代码；
	* lib目录，依赖的jar包；
* Web pages，展示页面所需要的资源，通常也需要如下几个目录：
* img目录 *（可选）*
* css目录 *（可选）*
* js目录 *（可选）*
* META-INF *（可选）* ，打包为war的元信息数据；


##Maven构建时，java web目录结构

本部分将着重开发过程中，Maven构建时，java web目录结构。注意，使用Maven管理的java project与java web project，基本类似：

* pom.xml，maven的工程对象模型（Project Object Module）
* src/main/java，项目类
* src/main/resources，项目资源
* src/test/java，测试类
* src/test/resources，测试资源
* src/main/webapp，web资源的目录

具体如下图：

![](/images/java-war-format/java-web-maven.png)

对应的部署结构：

![](/images/java-war-format/deployment-assembly.png)






疑问：JSTL的作用？JSP Standard Tag Library，JSP标准标签库。




##参考来源

* [Java EE 7 Tutorial - Packaging Web Archives][Java EE 7 Tutorial - Packaging Web Archives]
* [Java Platform, Enterprise Edition (Java EE) 7][Java Platform, Enterprise Edition (Java EE) 7]
* [wiki：war file format][wiki：war file format]




##闲谈

WAR，对应查看Java EE 的帮助文档；JAR，对应查看Java SE 的帮助文档。需要花时间浏览一遍Java EE Tutorial。









[NingG]:    http://ningg.github.com  "NingG"


[Java Platform, Enterprise Edition (Java EE) 7]:		https://docs.oracle.com/javaee/7/index.html
[Java EE 7 Tutorial - Packaging Web Archives]:			https://docs.oracle.com/javaee/7/tutorial/packaging003.htm
[wiki：war file format]:								http://en.wikipedia.org/wiki/WAR_%28file_format%29









