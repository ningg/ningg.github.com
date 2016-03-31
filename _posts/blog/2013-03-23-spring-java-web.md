---
layout: post
title: Spring搭建 java web 的基本架子 (todo)
description: java web的基本架子
published: true
categories: web spring
---

目标：

* 搭建一个基本的java web架子，包括：
	* 前端数据发送、接收；
	* 后端数据处理；
	* 数据存储；
* 整理使用Spring搭建架子的基本过程，以及注意事项；
* 重新熟悉Spring思路，整理这一基本思路；*（关键）*

补充：Spring涵盖的内容很广，此次主要涉及Spring web部分知识。



利用spring，搭建java web架子，整体分为几点：

* 基本的后端处理架子
	* Spring
	* Hibernate + Spring jdbc
	* MyBatis *（尚未熟悉）*
* 基本的前端展示架子


todo:

* [Spring MVC常见内容][Spring MVC常见内容]



## 工具

|工具|版本|说明|
|----|----|----|
|MyEclipse| 2014|java web IDE|





## 后端架子






### Spring


















## 常见问题


### MyEclipse的环境配置

在使用MyEclipse时，需要进行的前期配置：

* JDK
* Maven
	* Maven的JDK

### MyEclipse下，maven管理java web工程

在Myeclipse下，创建web project时，选中`Add maven support`，一路点击`Next`，后面有两个选项：

* MyEclipse JEE project structure：标准Java EE结构；
* Standard Maven JEE project structure *（推荐）*：Maven的标准结构；

UPDATE：20150325，分两步，从简单的来，先用`MyEclipse JEE project structure`，后期再尝试新建工程，使用`Standard Maven JEE project structure`。

UPDATE：20150404，另一种，以Maven project为中心，最后选择`archetypes`时，选择Archetype：`maven-archetype-webapp`即可。

### 数据库操作脚本

（TODO）

在web工程中，添加目录：SQLScript，其下，添加*.sql脚本，要求脚本文件命名为：ddl_timestamp.sql；要求，具体sql语句中，每个字段都必须添加comment？其他人有没有类似经验。

### java代码规范

java代码规范，几点：

* java代码规范（变量命名）；
* java web中MVC相关的代码规范；
	* DAO层的命令：Dao？DAO？
	* 包名：dao\dao.impl\service\service.impl\web\vo ？



### TODO

几个问题：

* java web上如何登记对数据库的修改
* maven管理的java web如何发布？如何debug测试？
	* 直接在server下进行deploy就可以了吗？
* 微框架，Spring boot用于解决什么问题？将会产生什么影响？
	* [Spring Boot 官网][Spring Boot 官网]
	* [Java Bootstrap - Dropwizard vs. Spring Boot][Java Bootstrap - Dropwizard vs. Spring Boot]
	* [SHOULD YOU USE SPRING BOOT IN YOUR NEXT PROJECT?][SHOULD YOU USE SPRING BOOT IN YOUR NEXT PROJECT?]
	* [深入学习微框架：Spring Boot][深入学习微框架：Spring Boot]
* Spring MVC中获取jsp片段：
	* [spring mvc中返回ModelAndView后执行ajax异步请求][spring mvc中返回ModelAndView后执行ajax异步请求]
	* [How to render a View using AJAX in Spring MVC][How to render a View using AJAX in Spring MVC]
	* [Spring框架，如何返回数据给视图(jsp文件)][Spring框架，如何返回数据给视图(jsp文件)]
* Spring security中对应的用户管理：
	* 用户登录的时候，哪个地方捕获用户登录信息？同时实例化一个用户身份实例，今后直接获取该实例即可；




## 参考来源


* [spring mvc中返回ModelAndView后执行ajax异步请求][spring mvc中返回ModelAndView后执行ajax异步请求]
* [How to render a View using AJAX in Spring MVC][How to render a View using AJAX in Spring MVC]
* [Spring框架，如何返回数据给视图(jsp文件)][Spring框架，如何返回数据给视图(jsp文件)]








[NingG]:    http://ningg.github.com  "NingG"

[深入学习微框架：Spring Boot]:							http://www.infoq.com/cn/articles/microframeworks1-spring-boot
[SHOULD YOU USE SPRING BOOT IN YOUR NEXT PROJECT?]:		http://steveperkins.com/use-spring-boot-next-project/
[Java Bootstrap - Dropwizard vs. Spring Boot]:			http://blog.takipi.com/java-bootstrap-dropwizard-vs-spring-boot/
[Spring Boot 官网]:										http://projects.spring.io/spring-boot/
[spring mvc中返回ModelAndView后执行ajax异步请求]:		http://blog.csdn.net/cdnsa/article/details/21167789
[How to render a View using AJAX in Spring MVC]:		http://stackoverflow.com/questions/4816080/how-to-render-a-view-using-ajax-in-spring-mvc
[Spring框架，如何返回数据给视图(jsp文件)]:				http://blog.csdn.net/lee353086/article/details/8620470


[Spring MVC常见内容]:			http://my.oschina.net/zhdkn/blog?catalog=318414






