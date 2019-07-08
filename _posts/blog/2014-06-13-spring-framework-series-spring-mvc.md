---
layout: post
title: Spring 源码：Spring MVC
description: Spring 框架下，MVC 模式的底层实现
published: true
category: spring
---

## 1. 简介

典型问题：

1. 几个上下文？2 个？为什么？
1. HTTP 请求，如何被捕获？
1. 整个 HTTP 请求到响应的基本过程？
1. 数据绑定？可定制点？
1. 数据校验？

数据绑定相关：

1. Controller 中数据绑定的基本原理
1. 数据绑定常用注解以及处理细节

## 2. Servlet

Servlet，全程 Server Applet，Java Servlet 是服务器端的应用程序。

1. Servlet 是 Java web 的核心。
1. Servlet 可以使用 javax.servlet 和 javax.servlet.http 包创建。
1. Java Servlet 是运行在带有支持 Java Servlet 规范的解释器的 web 服务器上的 Java 类。

通常的 Java web 服务器，都支持 Java Servlet 规范 （补充：绝大多数 Java web 也支持 JSP 规范）

1. Servlet 流行版本为 3.0，[JSR 315](https://jcp.org/aboutJava/communityprocess/final/jsr315/index.html)
1. 在 [web Application Specifications](http://wiki.apache.org/tomcat/Specifications) 页面，能够看到典型的 Java web 服务器 Tomcat 实现的 JSR 规范。

关于 web.xml 文件：

1. web.xml是Servlet [规范](https://www.jcp.org/en/jsr/detail?id=315)中定义的
1. web.xml不是必须的，当只有静态内容时，可以不设置web.xml；

`web.xml` 文件中 `listener`、`filter`、`servlet` 的简介：

1. **context-param**：设定参数，用于生成运行环境：上下文
1. **listener**：监听器，监听触发事件，参考 JSR 315 的 11.2 部分
	1. 生命周期中不同点，触发事件：
		1. ServletContextListener：web application 初始化开始和结束，此监听事件一般用来初始化上下文环境。
		1. HttpSessionListener：session 创建、销毁
		1. ServletRequestListener：请求进入 web application 和返回
	1. 不同操作，触发事件：
		1. ServletContextAttributeListener：增加属性、删除属性、修改属性
		1. HttpSessionAttributeListener：同上
		1. ServletRequestAttributeListener：同上
1. **filter**：过滤器，对请求和响应进行处理，参考：[http://stackoverflow.com/q/4720942](http://stackoverflow.com/q/4720942) 和 JSR 315 的 6.1 部分
1. **servlet**：具体的服务程序
1. **加载顺序**：
	1. `context-param` → `listener`  → `filter`  → `servlet`
	1. 同一类配置，按先后顺序执行

web.xml 对应的执行过程：

1. 部署web工程的时候，web容器会读取web.xml文件，读取<listener>和<context-param>两个节点；
1. web容器创建ServletContext（Servlet上下文），当前web工程的所有部分都共享这个Context（上下文）；
1. web容器将<context-param>转换为key-value，交给ServletContext；
1. web容器将<listener>对应类进行实例化，并创建监听器；

Servlet 的加载时间，`load-on-startup`，`<load-on-startup>5</load-on-startup>`元素几点：

1. 设定了servlet加载顺序；
1. 如果为0或正整数，则，容器在配置的时候，就会加载并初始化这些Servlet，并且，值小的，优先加载；若值相等，则，随机选取加载顺序；
1. 若值为负整数，则，容器会在调用这个Servlet时，才会加载，延迟加载；（如果是负整数，就直接省略即可）
1. 值，整数；
1. 默认，不指定`<load-on-startup>`时，延迟加载，跟设置为负数等价。

## 3. Spring MVC

几个典型问题：

1. 如何准备运行环境？上下文
1. HTTP 请求到响应的基本过程？
1. 数据绑定？数据校验？
1. 异常处理？

### 3.1. 上下文环境

什么是上下文？程序运行所需要的基础环境（`web.xml` 文件中配置）：

![](/images/spring-framework/root-and-servlet-web-application-context.png)

 
两个上下文之间的关系：

1. Servlet 独占 Servlet 的上下文
1. 所有的 Servlet 共享 Root 上下文
 
![](/images/spring-framework/root-with-servlet-web-app-context.png)
 
针对只有一个 DispatcherServlet 的场景，也可以只使用 Root WebApplicationContext：（这个如何实现？）

![](/images/spring-framework/root-without-servlet-web-app-context.png)

### 3.2. HTTP 请求到响应的基本过程

![](/images/spring-framework/spring-mvc-arch.png)

几个细节：

1. `List<HandlerMapping>`：将用户 request 的 url 映射为一个 Handler，其中包含：method、path，并且将 Handler 映射为对应的 Controller
1. `List<HandlerAdapter>`：在调用 Controller 对应的 method 之前，进行数据绑定等操作，并执行对应的 method
1. `List<HandlerExceptionResolver>`：对抛出的异常信息，进行处理
1. `RequestToViewNameTranslator`：为 view name 添加指定的前缀、后缀
1. `List<ViewResolver>`：根据 view name，获取真正的 View

最简单粗暴的理解：

* URL 发到哪个入口？哪个类的哪个方法来处理？
	* Re：一个映射关系
* 处理结果如何返回？
	* Re：返回页面、返回 JSON
* 中间出错怎么办？
	* Re：catch 异常，统一处理

### 3.3. 数据绑定和数据校验

TODO：单独一篇 blog 整理
 
### 3.4. 异常处理

DisptacherServler 中：

* `List<HandlerExceptionResolver>`：对抛出的异常信息，进行处理


### 3.5. HTTP 缓存机制

Spring MVC 中配置，开启 ETag：`web.xml` 中配置

```
<filter>
    <filter-name>shallowEtagHeaderFilter</filter-name>
    <filter-class>org.springframework.web.filter.ShallowEtagHeaderFilter</filter-class>
    <async-supported>true</async-supported>
</filter>
<filter-mapping>
    <filter-name>shallowEtagHeaderFilter</filter-name>
    <servlet-name>springServlet</servlet-name>
</filter-mapping>
```
 
## 4. 参考来源

1. [Servlet 简介](http://www.runoob.com/servlet/servlet-intro.html)
1. [web.xml 文件简介](http://ningg.top/web-xml-file-intro/)
1. [web.xml 中的listener、 filter、servlet 加载顺序及其详解](http://www.cnblogs.com/zhangxz/archive/2010/09/14/1825832.html)
1. [Difference between Filter and Listener in Servlet](http://stackoverflow.com/questions/4720942/difference-between-filter-and-listener-in-servlet-java-ee) 
1. [Spring揭秘-23章，Spring MVC初体验](http://leaver.me/2014/07/13/Spring%E6%8F%AD%E7%A7%98-23%E7%AB%A0%EF%BC%8CSpring%20MVC%E5%88%9D%E4%BD%93%E9%AA%8C/)
1. [Understanding Spring MVC](http://www.codejava.net/frameworks/spring/understanding-spring-mvc)
1. [web MVC framework](http://docs.spring.io/spring/docs/current/spring-framework-reference/html/mvc.html)


## 5. 附录

补充资料：

1. [http://www.xdemo.org/springmvc-data-bind/](http://www.xdemo.org/springmvc-data-bind/)
1. [http://starscream.iteye.com/blog/1072179](http://starscream.iteye.com/blog/1072179)













[NingG]:    http://ningg.github.com  "NingG"










