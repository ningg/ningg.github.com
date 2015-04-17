---
layout: post
title: web.xml文件简介
description: 
published: true
category: web
---

几点：

* web.xml详解：
	* 原始官网来源；
	* 当前广泛的解释，理解之后整理，配合样例；
* Spring下web.xml详解：
	* 原始官网来源；
	* 样例解释；

##web.xml文件详解


简要几点：

* web.xml是Servlet[规范][JSR315]中定义的；*（这就是官网）*
* web.xml不是必须的，当只有静态内容时，可以不设置web.xml；
* Servlet[规范][JSR315]中绘制的Deployment Descriptor Diagram，没有看懂，哈哈，标注有点多；

###web.xml中包含的内容

直接来原文：

* ServletContext Init Parameters
* Session Configuration
* Servlet Declaration
* Servlet Mappings
* Application Lifecyle Listener classes
* Filter Definitions and Filter Mappings
* MIME Type Mappings
* Welcome File list
* Error Pages
* Locale and Encoding Mappings
* Security configuration, including login-config, security-constraint, security-role, security-role-ref and run-as

###基本过程

几点：

* 部署WEB工程的时候，WEB容器会读取web.xml文件，读取`<listener>`和`<context-param>`两个节点；*（只是这两个节点吗？）*
* WEB容器创建ServletContext（Servlet上下文），当前WEB工程的所有部分都共享这个Context（上下文）；*（疑问：依照读取的web.xml创建一个ServletContext？）*
* WEB容器将`<context-param>`转换为key-value，交给ServletContext；
* WEB容器将`<listener>`对应类进行实例化，并创建监听器；

###Load-on-startup

`<load-on-startup>5</load-on-startup>`元素几点：

* 设定了servlet加载顺序；
* 如果为0或正整数，则，容器在配置的时候，就会加载并初始化这些Servlet，并且，值小的，优先加载；若值相等，则，随机选取加载顺序；
* 若值为负整数，则，容器会在调用这个Servlet时，才会加载，延迟加载；*（如果是负整数，就直接省略即可）*
* 值，整数；默认，不指定`<load-on-startup>`时，延迟加载；

###加载顺序

listener、filter、servlet的加载顺序，与他们的书写顺序无关，而实际加载顺序：

1. ServletContext
1. listener
1. filter
1. servlet

思考：上述的理论支撑在哪？设计来源？context-param，为ServletContext提供键值对，即，Servlet上下文的信息，这些信息listener、filter、servlet都有可能用到，因此，真正加载顺序是：

1. context-param
1. listener
1. filter
1. servlet

其他几点说明：

* filter-mapping必须出现在filter之后，否则出现filter-name未定义情况；
* 同一类请求，设置多个filter时，默认按照filter-mapping的顺序进行拦截；
* servlet也有servlet-mapping，与filter情况类似；
* filter、listener的用途；















##参考来源


* [xml入门][xml入门]*（之前的一篇文章）*










[NingG]:    		http://ningg.github.com  "NingG"
[xml入门]:			/xml-intro/









