---
layout: post
title: Servlet下URL映射规则以及冲突匹配原则
description: 当多个servlet对应的url-pattern都能与url匹配时，哪个Servlet来进行响应？能够多个Servelt响应同一个URL吗？
published: true
category: web
---

##url-pattern中通配符`*`

url-pattern中通配符`*`的使用规则:

* 同一个Servlet可以被映射到多个URL上，即多个`<servlet-mapping>`元素的`<servlet-name>`子元素的设置值可以是同一个Servlet的注册名。  
* 在Servlet映射到的URL中也可以使用`*`通配符，但是只能有两种固定的格式：
	* 一种格式是`*.扩展名`；
	* 另一种格式是以正斜杠（`/`）开头并以`/*`结尾。

示例代码如下：

	<servlet-mapping>
		<servlet-name>AnyName</servlet-name>
		<url-pattern>*.do</url-pattern>
	</servlet-mapping>

	<servlet-mapping>
		<servlet-name>AnyName</servlet-name>
		<url-pattern>/action/*</url-pattern>
	</servlet-mapping>


##servlet容器对url的匹配过程：

当一个请求发送到servlet容器的时候，容器先会将请求的url减去当前`应用上下文的路径`作为servlet的映射url，比如我访问的是 `http://localhost/test/aaa.html`，我的应用上下文是`test`，容器会将`http://localhost/test`去掉，剩下的`/aaa.html`部分拿来做servlet的映射匹配。这个映射匹配过程是有顺序的，而且**当有一个servlet匹配成功以后，就不会去理会剩下的servlet了**（filter不同，后文会提到）。其匹配规则和顺序如下： 

* **精确路径匹配**。例子：比如servletA 的url-pattern为 /test，servletB的url-pattern为 /* ，这个时候，如果我访问的url为http://localhost/test ，这个时候容器就会先进行精确路径匹配，发现/test正好被servletA精确匹配，那么就去调用servletA，也不会去理会其他的servlet了。
* **最长路径匹配**。例子：servletA的url-pattern为/test/*，而servletB的url-pattern为/test/a/*，此时访问http://localhost/test/a时，容器会选择路径最长的servlet来匹配，也就是这里的servletB。 
* **扩展匹配**，如果url最后一段包含扩展，容器将会根据扩展选择合适的servlet。例子：servletA的url-pattern：*.action 
* **缺省匹配**，如果前面三条规则都没有找到一个servlet，容器会根据url选择对应的请求资源。如果应用定义了一个default servlet，则容器会将请求丢给default servlet（什么是default servlet？请见:web.xml文件中缺省映射路径"/"问题以及客户端访问web资源的匹配规则）。 

根据这个规则表，就能很清楚的知道servlet的匹配过程，所以定义servlet的时候也要考虑url-pattern的写法，以免出错。 

对于filter，不会像servlet那样只匹配一个servlet，因为**filter的集合是一个链，所以只会有处理的顺序不同，而不会出现只选择一个filter**。Filter的处理顺序和filter-mapping在web.xml中定义的顺序相同。 

##缺省匹配


web.xml中如果某个Servlet的映射路径仅仅为一个正斜杠（`/`），那么这个Servlet就成为当前Web应用程序的**缺省Servlet**。

凡是在web.xml文件中找不到匹配的`<servlet-mapping>`元素的URL，它们的访问请求都将交给缺省Servlet处理，也就是说，**缺省Servlet用于处理所有其他Servlet都不处理的访问请求**。

在`$TOMCAT_HOMT\conf\web.xml`文件中，注册了一个名称为`org.apache.catalina.servlets.DefaultServlet`的Servlet，并将这个Servlet设置为了**缺省Servlet**。(`\conf\web.xml`文件所有发布到tomcat的web应用所共享的)

     <servlet>
        <servlet-name>default</servlet-name>
        <servlet-class>org.apache.catalina.servlets.DefaultServlet</servlet-class>
        <init-param>
           <param-name>debug</param-name>
           <param-value>0</param-value>
        </init-param>
        <init-param>
           <param-name>listings</param-name>
           <param-value>false</param-value>
        </init-param>
        <load-on-startup>1</load-on-startup>
    </servlet>

    <servlet-mapping>
       <servlet-name>default</servlet-name>
       <url-pattern>/</url-pattern>
    </servlet-mapping>


当访问**Tomcat服务器**中的某个**静态HTML文件和图片**时，实际上是在访问这个缺省Servlet，由**Default Servlet类寻找**，当寻找到了请求的html或图片时，则返回其资源文件，如果没有寻找到则报出404错误。

如果在**web应用的web.xml**文件中的`<servlet-mapping>`中配置了`/`，如：

    <servlet>
      <servlet-name>ServletDemo3</servlet-name>
      <servlet-class>edu.servlet.ServletDemo3</servlet-class>
    </servlet>
    <servlet-mapping>
      <servlet-name>ServletDemo3</servlet-name>
      <url-pattern>/</url-pattern>
    </servlet-mapping>

则当请求的url和上面其他的`<servlet-mapping>`均不匹配时，则会交给`ServletDemo3.java`处理,而不在交给`DefaultServlet.java`处理，也就是说，当请求web应用中的静态文本或图片或avi视屏等时，则全部进入了ServletDemo3.java,而不会正常返回页面资源。即，web应用的web.xml配置覆盖Tomcat自带的web.xml文件配置。





##url-pattern详解 

在web.xml文件中，以下语法用于定义映射： 

* 以`/`开头和以`/*`结尾的是用来做**路径映射**的。
* 以前缀`*.`开头的是用来做**扩展映射**的。 
* `/` 是用来定义**default servlet映射**的。 
* 剩下的都是用来定义**详细映射**的。比如：`/aa/bb/cc.action`

所以，为什么定义`/*.action`这样一个看起来很正常的匹配在启动tomcat时会报错？因为这个匹配既属于**路径映射**，也属于**扩展映射**，导致容器无法判断。

##示例(*.do的优先级别最低)

对于如下的一些映射关系：

* Servlet1 映射到 `/abc/*` 
* Servlet2 映射到 `/*`
* Servlet3 映射到 `/abc` 
* Servlet4 映射到 `*.do`

问题：
* 当请求URL为`/abc/a.html`，`/abc/*`和`/*`都匹配，哪个servlet响应?
	* Servlet引擎将调用Servlet1。
* 当请求URL为`/abc`时，`/abc/*`和`/abc`都匹配，哪个servlet响应?
	* Servlet引擎将调用Servlet3。
* 当请求URL为`/abc/a.do`时，`/abc/*`和`*.do`都匹配，哪个servlet响应?
	* Servlet引擎将调用Servlet1。
* 当请求URL为`/a.do`时，`/*`和`*.do`都匹配，哪个servlet响应?
	* Servlet引擎将调用Servlet2。
* 当请求URL为`/xxx/yyy/a.do`时，`/*`和`*.do`都匹配，哪个servlet响应?
	* Servlet引擎将调用Servlet2。




















##参考来源

* [Servlet映射规则和Servlet的映射URL冲突时匹配原则][Servlet映射规则和Servlet的映射URL冲突时匹配原则]







[NingG]:    http://ningg.github.com  "NingG"


[Servlet映射规则和Servlet的映射URL冲突时匹配原则]:		http://blog.csdn.net/xh16319/article/details/8014107








