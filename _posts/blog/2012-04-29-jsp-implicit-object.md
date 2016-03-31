---
layout: post
title: JSP内置对象，request、response、session、application的解释和使用
description: JSP页面中有一些可以直接使用的隐藏对象
published: true
category: jsp
---

几个要点：

* 内置对象的基本含义；
* 使用内置对象的典型场景；


## JSP内置对象


在JSP页面中不需要声明，可以直接使用，是JSP容器为每个JSP页面提供的Java对象。


### request对象

request对象是javax.servlet.http.HttpServletRequest 类的实例。每当客户端请求一个JSP页面时，JSP引擎就会制造一个新的request对象来代表这个请求。

request对象提供了一系列方法来获取HTTP头信息，cookies，HTTP方法等等。

常用方法：

* request.getProtocol():获取请求使用的通信协议，如http/1.1等 
* request.getServletPath():获取请求的JSP也面所在的目录。 
* request.getContentLength():获取HTTP请求的长度。 
* request.getMethod():获取表单提交信息的方式，如POST或者GET。 
* request.getHeader(String s):获取请求中头的值。一般来说，S参数可取的头名有accept,referrer、accept-language、content-type、accept-encoding、user-agent、host、cookie等，比如，S取值user-agent将获得用户的浏览器的版本号等信息。 
* request.getHeaderNames():获取头名字的一个枚举。 
* request.getHeaders(String s):获取头的全部值的一个枚举。 
* request.getRemoteAddr():获取客户的IP地址。 
* request.getRemoteHost():获取客户机的名称（如果获取不到，就获取IP地址）。 
* request.getServerName():获取服务器的名称。 
* request.getServePort():获取服务器的端口。 
* request.getParameterNames():获取表单提交的信息体部分中name参数值的一个枚举。








### response对象

response对象是javax.servlet.http.HttpServletResponse类的实例。当服务器创建request对象时会同时创建用于响应这个客户端的response对象。

response对象也定义了处理HTTP头模块的接口。通过这个对象，开发者们可以添加新的cookies，时间戳，HTTP状态码等等。


### session对象

session对象是 javax.servlet.http.HttpSession 类的实例。和Java Servlets中的session对象有一样的行为。
session对象指的是客户端与服务器的一次会话，从客户连到服务器的一个WebApplication开始，直到客户端与服务器断开连接为止。

常用方法：

* session.getID()：服务器上通过session来分别不同的用户，sessionID：任何链接到服务器上的用户，服务器都会为之分配唯一的一个不会重复的sessionID。由服务器统一管理，人为不能控制。
* session.getId().length()：id的长度为32位
* session.isNew()：判断是否是新的用户
* session.invalidate()：使session失效
* session.getCreationTime()：得到session的创建时间，返回long类型，通过Date得到时间
* session.getLastAccessedTime()：得到最后一次操作时间，返回long类型
* getMaxInactiveInterval()：返回seesion存在期限   
* setMaxInactiveInterval()：设定seesion存在期限
* 属性设置：
	* session.setAttribute(String  name，Object  value)
	* session.getAttribute(String  name)
	* session.removeAttribute(String  name)



### application对象

application对象直接包装了servlet的ServletContext类的对象，是javax.servlet.ServletContext 类的实例。
这个对象在JSP页面的整个生命周期中都代表着这个JSP页面。这个对象在JSP页面初始化时被创建，随着jspDestroy()方法的调用而被移除。

application对象实现了用户间数据的共享，可存放全局变量。它开始于服务器的启动，直到服务器的关闭，在此期间，此对象将一直存在；这样在用户的前后连接或不同用户之间的连接中，可以对此对象的同一属性进行操作；在任何地方对此对象属性的操作，都将影响到其他用户对此的访问。服务器的启动和关闭决定了application对象的生命。



## 整理和对比

JSP提供的内置对象如下：

|内置对象 | 类型  |作用域|
|:-----|:----|:----|
|pageContext | javax.servlet.jsp.pageContext | page |
|request | javax.servlet.http.HttpServletRequest | request |
|response | javax.servlet.http.HttpServletResponse | page |
|session|  javax.servlet.http.HttpSession | session |
|application | javax.servlet.ServletContext | application |
|config | javax.servlet.ServletConfig  |page |
|out | java.servlet.jsp.JspWriter | page |
|page | java.lang.Object | page |
|exception | java.lang.Throwable  |page |

### 属性的设置和取得

设置和获取属性：

* 设置属性：`public void setAttribute(String name，Object.value)`
* 取得属性：`public void getAttribute(String name)`

### 四类范围

几类范围：

* 在一个页面范围内：page
* 在一次服务器请求范围内：request
* 在一次会话范围内：session
* 在一个应用服务器范围内：application




## 常见问题



### Request中getContextPath、getServletPath、getRequestURI、getRealPath的区别

假定你的web application 名称为news,你在浏览器中输入请求路径：

	http://localhost:8080/news/main/list.jsp
	
则执行下面向行代码后打印出如下结果：

* System.out.println(request.getContextPath());
	* 打印结果：/news
* System.out.println(request.getServletPath());
	* 打印结果：/main/list.jsp
* System.out.println(request.getRequestURI());
	* 打印结果：/news/main/list.jsp
* System.out.println(request.getRealPath("/"));
	* 打印结果：F:\Tomcat 6.0\webapps\news\test

常用：request.getContextPath()来定位到web应用的根目录；






思考：

* forward与redirect之间的区别？
* session与cookie之间联系？







几个参考来源：

* [JSP内置对象(1)----request、response][JSP内置对象(1)----request、response]
* [JSP内置对象(2)----out、application][JSP内置对象(2)----out、application]
* [比较page、request、session、application的使用范围][比较page、request、session、application的使用范围]




































[NingG]:    http://ningg.github.com  "NingG"


[JSP内置对象(1)----request、response]:		http://blog.csdn.net/beijiguangyong/article/details/7417546
[JSP内置对象(2)----out、application]:		http://blog.csdn.net/beijiguangyong/article/details/7424271
[比较page、request、session、application的使用范围]:		http://blog.csdn.net/seawaywjd/article/details/7335804








