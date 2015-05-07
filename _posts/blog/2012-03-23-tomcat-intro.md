---
layout: post
title: Tomcat 梳理 (todo)
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

Tomcat依赖`server.xml`文件来启动Sserver，一个Tomcat实例，核心就是启动容器Catalina。

Tomcat部署Webapp时，依赖`context.xml`和`web.xml`来部署Web应用。实际上，在部署任何一个webapp时，Tomcat自带的context.xml以及web.xml都会生效，同时webapp自带的META-INF/context.xml和WEB-INF/web.xml也会定义每个webapp的特定行为。


###web.xml

此处的web.xml文件，也是由Servlet官方规范来限定的，更多信息可参考：

* [web.xml文件梳理][web.xml文件梳理]
* [Servlet下URL映射规则以及冲突匹配原则][Servlet下URL映射规则以及冲突匹配原则]

补充：

* `$TOMCAT_HOME/conf/web.xml`文件配置了tomcat下web应用的默认web.xml配置；
* web.xml中定义了多个`servlet`和`servlet-mapping`：
	* 要先定义`servlet`再定义`servlet-mapping`；
	* 当一个url满足多个`servlet`时，按照`servlet`定义的先后顺序来进行处理？
* Tomcat自带web.xml，与web应用自己配置的web.xml文件之间关系？
	
	
web.xml文件中，示例代码片段：

	<web-app>
	
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
		
		<servlet>
			<servlet-name>jsp</servlet-name>
			<servlet-class>org.apache.jasper.servlet.JspServlet</servlet-class>
			<init-param>
				<param-name>fork</param-name>
				<param-value>false</param-value>
			</init-param>
			<init-param>
				<param-name>xpoweredBy</param-name>
				<param-value>false</param-value>
			</init-param>
			<load-on-startup>3</load-on-startup>
		</servlet>
		
		<!-- The mapping for the default servlet -->
		<servlet-mapping>
			<servlet-name>default</servlet-name>
			<url-pattern>/</url-pattern>
		</servlet-mapping>

		<!-- The mappings for the JSP servlet -->
		<servlet-mapping>
			<servlet-name>jsp</servlet-name>
			<url-pattern>*.jsp</url-pattern>
			<url-pattern>*.jspx</url-pattern>
		</servlet-mapping>
		
		<filter>
			<filter-name>...</filter-name>
			<filter-class>...</filter-class>
		</filter>
		
		<filter-mapping>
			<filter-name>...</filter-name>
			<url-pattern>...</url-pattern>
		</filter-mapping>
		
		<!-- session失效时间（mins） -->
		<session-config>
			<session-timeout>30</session-timeout>
		</session-config>
		
		<!-- 请求静态资源时，根据资源后缀，添加`Content-Type`属性 -->
		<mime-mapping>
			<extension>123</extension>
			<mime-type>application/vnd.lotus-1-2-3</mime-type>
		</mime-mapping>

		<!-- 欢迎页面 -->
		<welcome-file-list>
			<welcome-file>index.html</welcome-file>
			<welcome-file>index.htm</welcome-file>
			<welcome-file>index.jsp</welcome-file>
		</welcome-file-list>

	</web-app>




**思考**：上述代码中，当请求url为`index.jsp`时，上述两个Servelt如何进行处理？RE：单独整理了一篇文章。

###server.xml

Tomcat Server的结构图：

![](/images/tomcat-intro/tomcat-server-framework.jpg)



更多细节：

* [Tomcat server.xml详解]
* [Tomcat 8 server.xml详解]
* [Tomcat系列之服务器的安装与配置以及各组件详解][Tomcat系列之服务器的安装与配置以及各组件详解]
* [Tomcat启动过程原理详解][Tomcat启动过程原理详解]
* [从零认识tomcat，构建一机多实例tomcat集群][从零认识tomcat，构建一机多实例tomcat集群]




###context.xml



###tomcat-users.xml






##Tomcat基本原理

todo:

* [深入学习Tomcat8][深入学习Tomcat8]
* [Apache Tomcat 8 Configuration Reference][Apache Tomcat 8 Configuration Reference]，Tomcat的详细配置
* [Apache Tomcat 8 Architecture][Apache Tomcat 8 Architecture]，Tomcat的启动原理


推荐资料：

* [Tomcat/Apache 6][Tomcat/Apache 6]
* [Apache Tomcat 7-more about the cat][Apache Tomcat 7-more about the cat]
* [How to Install Apache Tomcat and Get Started with Java Servlet Programming][How to Install Apache Tomcat and Get Started with Java Servlet Programming]

疑问：tomcat运行时，是一个Process，那在tomcat容器中部署的web应用，是作为process启动的？还是直接thread？















##参考来源

* [Apache Tomcat][Apache Tomcat]
* [Apache Tomcat 7-more about the cat][Apache Tomcat 7-more about the cat]
* [How to Install Apache Tomcat and Get Started with Java Servlet Programming][How to Install Apache Tomcat and Get Started with Java Servlet Programming]
* [web.xml文件梳理][web.xml文件梳理]
* [Servlet下URL映射规则以及冲突匹配原则][Servlet下URL映射规则以及冲突匹配原则]
* [深入学习Tomcat8][深入学习Tomcat8]
* [Apache Tomcat 8 Configuration Reference][Apache Tomcat 8 Configuration Reference]
* [Apache Tomcat 8 Architecture][Apache Tomcat 8 Architecture]





##杂谈

重走web路，一年多没碰web的东西，该忘的都忘了，用到的时候，需要重新查阅，现在只有解决问题的基本思路，索性借着这次重新使用java web的机会把整体的内容再过一遍。







[NingG]:    http://ningg.github.com  "NingG"


[Apache Tomcat]:								http://tomcat.apache.org/
[Apache Tomcat 7-more about the cat]:			http://www.ntu.edu.sg/home/ehchua/programming/howto/Tomcat_More.html
[How to Install Apache Tomcat and Get Started with Java Servlet Programming]:	http://www.ntu.edu.sg/home/ehchua/programming/howto/Tomcat_HowTo.html
[Tomcat/Apache 6]:								http://www.datadisk.co.uk/html_docs/java_app/tomcat6/tomcat6.htm
[web.xml文件梳理]:								http://ningg.top/web-xml-file-intro/
[Servlet下URL映射规则以及冲突匹配原则]:		http://ningg.top/servlet-url-pattern/
[深入学习Tomcat8]:								http://blog.csdn.net/column/details/tomcat8.html
[Apache Tomcat 8 Configuration Reference]:		http://tomcat.apache.org/tomcat-8.0-doc/config/index.html
[Apache Tomcat 8 Architecture]:					http://tomcat.apache.org/tomcat-8.0-doc/architecture/index.html


[Tomcat 8 server.xml详解]:						http://blog.csdn.net/flyliuweisky547/article/details/20790601
[Tomcat server.xml详解]:						http://blog.sina.com.cn/s/blog_6925c03c0101d6tx.html
[Tomcat系列之服务器的安装与配置以及各组件详解]:	http://freeloda.blog.51cto.com/2033581/1299644
[从零认识tomcat，构建一机多实例tomcat集群]:	http://grass51.blog.51cto.com/4356355/1123400
[Tomcat启动过程原理详解]:						http://www.ha97.com/4820.html


