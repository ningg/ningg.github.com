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

> server.xml配置文件详解，官网地址：[Apache Tomcat 8 Configuration Reference][Apache Tomcat 8 Configuration Reference]

Tomcat Server的结构图：

![](/images/tomcat-intro/tomcat-server-framework.jpg)

Tomcat的server.xml文件基本结构：

	<Server>
		<Listener />
		<GlobaNamingResources></GlobaNamingResources
		<Service>
			<Executor />
			<Connector />
			<Engine>
				<Cluster />
				<Realm />
				<Realm />
				   <Host>
					   <Valve />
					   <Context />
				   </Host>
			</Engine>
		</Service>
	</Server>

####Server

Server是Catalina Servlet容器。属性如下：

* className：指定实现org.apache.catalina.Server接口的类，默认值为org.apache.catalina.core.StandardServer
* address：Tomcat监听shutdown命令的地址，默认为localhost
* port：Tomcat监听shutdown命令的端口。设置为`-1`，则禁止通过端口关闭Tomcat，同时shutdown.bat也不能使用
* shutdown：通过指定的地址（address）、端口（port）关闭Tomcat所需的字符串。修改shutdown的值，对shutdown.bat无影响


####Listener

Listener即监听器，负责监听特定的事件，当特定事件触发时，Listener会捕捉到该事件，并做出相应处理。Listener通常用在Tomcat的启动和关闭过程。Listener可嵌在Server、Engine、Host、Context内。常用属性：

* className：指定实现org.apache.catalina.LifecycleListener接口的类

####GlobalNamingResources

GlobalNamingResources用于配置JNDI。

####Service

Service包装Executor、n个Connector、1个Engine，Connector获取request，Engine处理request。Server可以包含多个Service组件。
常用属性：

* className：指定实现org.apache.catalina.Service接口的类，默认值为org.apache.catalina.core.StandardService
* name：Service的名字


####Executor


Executor即Service提供的线程池，供Service内各组件使用，特别是Connector组件。


####Connector

Connector是Tomcat接收请求的入口，每个Connector有自己专属的监听端口；Connector有两种：HTTP Connector和AJP Connector。
常用属性：

* port：Connector接收请求的端口
* protocol：Connector使用的协议（HTTP/1.1或AJP/1.3）
* connectionTimeout：每个请求的最长连接时间（单位：ms）
* redirectPort：处理http请求时，收到一个SSL传输请求，该SSL传输请求将转移到此端口处理
* executor：指定线程池，如果没设置executor，可在Connector标签内设置maxThreads（默认200）、minSpareThreads（默认10）
* acceptCount：Connector请求队列的上限。默认为100。当该Connector的请求队列超过acceptCount时，将拒绝接收请求

HTTP与AJP：

* HTTP：监听browser发送的http请求；
* AJP：其他WebServer（Apache）的servlet/jsp代理请求；

####Engine

Engine负责处理Service内的所有请求。它接收来自Connector的请求，并决定传给哪个Host来处理，Host处理完请求后，将结果返回给Engine，Engine再将结果返回给Connector。
常用属性：

* name：Engine的名字
* defaultHost：指定默认Host。Engine接收来自Connector的请求，然后将请求传递给defaultHost，defaultHost 负责处理请求
* className：指定实现org.apache.catalina. Engine接口的类，默认值为org.apache.catalina.core. StandardEngine
* backgroundProcessorDelay：Engine及其部分子组件（Host、Context）调用backgroundProcessor方法的时间间隔。
	* backgroundProcessorDelay为负，将不调用backgroundProcessor。
	* backgroundProcessorDelay的默认值为10
	* Tomcat启动后，Engine、Host、Context会启动一个后台线程，定期调用backgroundProcessor方法；
	* backgroundProcessor方法主要用于重新加载Web应用程序的类文件和资源、扫描Session过期 
* jvmRoute：Tomcat集群节点的id。部署Tomcat集群时会用到该属性，

几点：

* Service包含一个或多个Connector组件
* Service内必须包含一个Engine组件
* Service内的Connector共享一个Engine

####Host

关于Host，几点：

* 代表一个Virtual Host，虚拟主机，每个虚拟主机和某个网络域名Domain Name相匹配
* 每个虚拟主机下都可以部署(deploy)一个或者多个Web App，每个Web App对应于一个Context，有一个Context path
* 当Host获得一个请求时，将把该请求匹配到某个Context上，然后把该请求交给该Context来处理
* 匹配的方法是“最长匹配”，所以一个path==”"的Context将成为该Host的默认Context
* 所有无法和其它Context的路径名匹配的请求都将最终和该默认Context匹配

Engine与Host之间，几点：

* Engine下可以配置多个虚拟主机Virtual Host，每个虚拟主机都有一个域名
* 当Engine获得一个请求时，它把该请求匹配到某个Host上，然后把该请求交给该Host来处理
* Engine有一个默认虚拟主机，当请求无法匹配到任何一个Host上的时候，将交给该默认Host来处理



Host负责管理一个或多个Web项目。常用属性：

* name：Host的名字
* appBase：存放Web项目的目录（绝对路径、相对路径均可）
* unpackWARs：当appBase下有WAR格式的项目时，是否将其解压（解成目录结构的Web项目）。设成false，则直接从WAR文件运行Web项目
* autoDeploy：是否开启自动部署。设为true，Tomcat检测到appBase有新添加的Web项目时，会自动将其部署
* startStopThreads：线程池内的线程数量。Tomcat启动时，Host提供一个线程池，用于部署Web项目。
	* startStopThreads为0，并行线程数=系统CPU核数
	* startStopThreads为负数，并行线程数=系统CPU核数+startStopThreads，如果（系统CPU核数+startStopThreads）小于1，并行线程数设为1
	* startStopThreads为正数，并行线程数= startStopThreads
	* startStopThreads默认值为1
	* startStopThreads为默认值时，Host只提供一个线程，用于部署Host下的所有Web项目。如果Host下的Web项目较多，由于只有一个线程负责部署这些项目，因此这些项目将依次部署，最终导致Tomcat的启动时间较长。此时，修改startStopThreads值，增加Host部署Web项目的并行线程数，可降低Tomcat的启动时间

####Context

* Context代表一个运行在Host上的Web Application，一个Host上可以有多个Context（即，多个Web Application）。
* 一个Web Application由一个或者多个Servlet组成
* Context在创建的时候将根据配置文件$CATALINA_HOME/conf/web.xml和$WEBAPP_HOME/WEB-INF/web.xml载入Servlet类
* 当Context获得请求时，将在自己的映射表(mapping table)中寻找相匹配的Servlet类
* 如果找到，则执行该类，获得请求的回应，并返回。

将一个Web项目（D:\MyApp）添加到Tomcat，在Host标签内，添加Context标签

	<Context path="" docBase="D:\MyApp"  reloadable="true" crossContext="true"></Context>

常用属性：

* path：该Web项目的URL入口。
	* path设置为””，输入http://localhost:8080即可访问MyApp；
	* path设置为”/test/MyApp”，输入http://localhost:8080/test/MyApp才能访问MyApp
* docBase：Web项目的路径，绝对路径、相对路径均可（相对路径是相对于CATALINA_HOME\webapps）
* reloadable：是否自动检测并重新部署Web项目；
	* 设置为true，Tomcat会自动监控Web项目的/WEB-INF/classes/和/WEB-INF/lib变化，当检测到变化时，会重新部署Web项目。
	* reloadable默认值为false。
	* 通常项目开发过程中设为true，项目发布的则设为false
* crossContext：设置为true，该Web项目的Session信息可以共享给同一host下的其他Web项目。默认为false

####Cluster

Tomcat集群配置。

####Realm

Realm可以理解为包含用户、密码、角色的”数据库”。Tomcat定义了多种Realm实现：

* JDBC Database Realm
* DataSource Database Realm
* JNDI Directory Realm
* UserDatabase Realm等

####Valve

Valve可以理解为Tomcat的拦截器，而我们常用filter为项目内的拦截器。Valve可以用于Tomcat的日志、权限等。Valve可嵌在Engine、Host、Context内。



####小结：Request处理过程

request为http://localhost:8080/examples/index.html，回顾一下Tomcat处理请求的流程图：

![](/images/tomcat-intro/request-process.png)

Server和Service充当的就是包装的角色：

* Server包装了Listener、GlobalNamingResources、Service；
* Service包装了Executor、Connector、Engine；


更多细节：

* [Apache Tomcat 8 Configuration Reference][Apache Tomcat 8 Configuration Reference]
* [Tomcat server.xml详解]
* [Tomcat 8 server.xml详解]
* [Tomcat系列之服务器的安装与配置以及各组件详解][Tomcat系列之服务器的安装与配置以及各组件详解]
* [Tomcat启动过程原理详解][Tomcat启动过程原理详解]
* [从零认识tomcat，构建一机多实例tomcat集群][从零认识tomcat，构建一机多实例tomcat集群]




###context.xml

（todo）

###tomcat-users.xml


（todo）




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







##Tomcat Server处理一个HTTP请求的过程


假设来自客户的请求为：

	http://localhost:8080/wsota/wsota_index.jsp

基本过程：

1. 请求被发送到本机（localhost）端口8080，被在那里侦听的Coyote HTTP/1.1 Connector获得
1. Connector把该请求交给它所在的Service的Engine来处理，并等待来自Engine的回应
1. Engine获得请求localhost/wsota/wsota_index.jsp，匹配它所拥有的所有虚拟主机Host
1. Engine匹配到名为localhost的Host（即使匹配不到也把请求交给该Host处理，因为该Host被定义为该Engine的默认主机）
1. localhost Host获得请求/wsota/wsota_index.jsp，匹配它所拥有的所有Context
1. Host匹配到路径为/wsota的Context（如果匹配不到就把该请求交给路径名为""的Context去处理）
1. path=”/wsota”的Context获得请求/wsota_index.jsp，在它的mapping table中寻找对应的servlet
1. Context匹配到URL PATTERN为*.jsp的servlet，对应于JspServlet类
1. 构造HttpServletRequest对象和HttpServletResponse对象，作为参数调用JspServlet的doGet或doPost方法
1. Context把执行完了之后的HttpServletResponse对象返回给Host
1. Host把HttpServletResponse对象返回给Engine
1. Engine把HttpServletResponse对象返回给Connector
1. Connector把HttpServletResponse对象返回给客户browser

##单实例应用程序配置一例

规划： 

* 网站网页目录：/web/www，域名：www.test1.com 
* 论坛网页目录：/web/bbs，URL：bbs.test1.com/bbs 
* 网站管理程序：$CATALINA_HOME/wabapps，URL：manager.test.com，允许远程访问的地址：172.23.136.* 
 

注：下面两个配置文件，没有验证。

**conf/server.xml **配置文件：

	<Server port="8005" shutdown="SHUTDOWN"> 
	  <Listener className="org.apache.catalina.core.AprLifecycleListener" SSLEngine="on" /> 
	  <Listener className="org.apache.catalina.core.JasperListener" /> 
	  <Listener className="org.apache.catalina.core.JreMemoryLeakPreventionListener" /> 
	  <Listener className="org.apache.catalina.mbeans.GlobalResourcesLifecycleListener" /> 
	  <Listener className="org.apache.catalina.core.ThreadLocalLeakPreventionListener" /> 
	  
	  <!-- 全局命名资源，来定义一些外部访问资源，其作用是为所有引擎应用程序所引用的外部资源的定义 -->
	  <GlobalNamingResources>  
		<!-- 定义的一个名叫“UserDatabase”的认证资源，将conf/tomcat-users.xml加载至内存中，在需要认证的时候到内存中进行认证 --> 
		<Resource name="UserDatabase" auth="Container" 
				  type="org.apache.catalina.UserDatabase" 
				  description="User database that can be updated and saved" 
				  factory="org.apache.catalina.users.MemoryUserDatabaseFactory" 
				  pathname="conf/tomcat-users.xml" /> 
	  </GlobalNamingResources> 
	  
	  <!-- # 定义Service组件，同来关联Connector和Engine，一个Engine可以对应多个Connector，每个Service中只能一个Engine --> 
	  <Service name="Catalina"> 
		<!-- 修改HTTP/1.1的Connector监听端口为80.客户端通过浏览器访问的请求，只能通过HTTP传递给tomcat。  --> 
		<Connector port="80" protocol="HTTP/1.1" connectionTimeout="20000" redirectPort="8443" /> 
		<Connector port="8009" protocol="AJP/1.3" redirectPort="8443" /> 
		<Engine name="Catalina" defaultHost="test.com"> 
		<!-- 修改当前Engine，默认主机是，www.test.com  --> 
		<Realm className="org.apache.catalina.realm.LockOutRealm"> 
			<Realm className="org.apache.catalina.realm.UserDatabaseRealm" 
				   resourceName="UserDatabase"/> 
		</Realm> 
		<!-- # Realm组件，定义对当前容器内的应用程序访问的认证，通过外部资源UserDatabase进行认证   -->
		  <Host name="test.com"  appBase="/web" unpackWARs="true" autoDeploy="true"> 
		  <!--  定义一个主机，域名为：test.com，应用程序的目录是/web，设置自动部署，自动解压    --> 
			<Alias>www.test.com</Alias> 
			<!--    定义一个别名www.test.com，类似apache的ServerAlias --> 
			<Context path="" docBase="www/" reloadable="true" /> 
			<!--    定义该应用程序，访问路径""，即访问www.test.com即可访问，网页目录为：相对于appBase下的www/，即/web/www，并且当该应用程序下web.xml或者类等有相关变化时，自动重载当前配置，即不用重启tomcat使部署的新应用程序生效  --> 
			<Context path="/bbs" docBase="/web/bbs" reloadable="true" /> 
			<!--  定义另外一个独立的应用程序，访问路径为：www.test.com/bbs，该应用程序网页目录为/web/bbs   --> 
			<Valve className="org.apache.catalina.valves.AccessLogValve" directory="/web/www/logs" 
				   prefix="www_access." suffix=".log" 
				   pattern="%h %l %u %t &quot;%r&quot; %s %b" /> 
			<!--   定义一个Valve组件，用来记录tomcat的访问日志，日志存放目录为：/web/www/logs如果定义为相对路径则是相当于$CATALINA_HOME，并非相对于appBase，这个要注意。定义日志文件前缀为www_access.并以.log结尾，pattern定义日志内容格式，具体字段表示可以查看tomcat官方文档 --> 
		  </Host> 
		  <Host name="manager.test.com" appBase="webapps" unpackWARs="true" autoDeploy="true"> 
		  <!--   定义一个主机名为man.test.com，应用程序目录是$CATALINA_HOME/webapps,自动解压，自动部署 --> 
			<Valve className="org.apache.catalina.valves.RemoteAddrValve" allow="172.23.136.*" /> 
			<!--   定义远程地址访问策略，仅允许172.23.136.*网段访问该主机，其他的将被拒绝访问  --> 
			<Valve className="org.apache.catalina.valves.AccessLogValve" directory="/web/bbs/logs" 
				   prefix="bbs_access." suffix=".log" 
				   pattern="%h %l %u %t &quot;%r&quot; %s %b" /> 
			<!--   定义该主机的访问日志   --> 
		  </Host> 
		</Engine> 
	  </Service> 
	</Server> 
 
**conf/tomcat-users.xml**配置文件：

	<?xml version='1.0' encoding='utf-8'?> 
	<tomcat-users> 
	  <role rolename="manager-gui" /> 
	  <!--  定义一种角色名为：manager-gui  --> 
	  <user username="cz" password="manager$!!110" roles="manager-gui" /> 
	  <!--  定义一个用户的用户名以及密码，并赋予manager-gui的角色    --> 
	</tomcat-users> 





##参考来源

* [Apache Tomcat][Apache Tomcat]
* [Apache Tomcat 7-more about the cat][Apache Tomcat 7-more about the cat]
* [How to Install Apache Tomcat and Get Started with Java Servlet Programming][How to Install Apache Tomcat and Get Started with Java Servlet Programming]
* [web.xml文件梳理][web.xml文件梳理]
* [Servlet下URL映射规则以及冲突匹配原则][Servlet下URL映射规则以及冲突匹配原则]
* [深入学习Tomcat8][深入学习Tomcat8]
* [Apache Tomcat 8 Configuration Reference][Apache Tomcat 8 Configuration Reference]
* [Apache Tomcat 8 Architecture][Apache Tomcat 8 Architecture]
* [Tomcat 8 server.xml详解][Tomcat 8 server.xml详解]




##杂谈

重走web路，一年多没碰web的东西，该忘的都忘了，用到的时候，需要重新查阅，现在只有解决问题的基本思路，索性借着这次重新使用java web的机会把整体的内容再过一遍。







[NingG]:    http://ningg.github.com  "NingG"


[Apache Tomcat]:								http://tomcat.apache.org/
[Apache Tomcat 7-more about the cat]:			http://www.ntu.edu.sg/home/ehchua/programming/howto/Tomcat_More.html
[How to Install Apache Tomcat and Get Started with Java Servlet Programming]:	http://www.ntu.edu.sg/home/ehchua/programming/howto/Tomcat_HowTo.html
[Tomcat/Apache 6]:								http://www.datadisk.co.uk/html_docs/java_app/tomcat6/tomcat6.htm
[web.xml文件梳理]:								http://ningg.top/web-xml-file-intro/
[Servlet下URL映射规则以及冲突匹配原则]:			http://ningg.top/servlet-url-pattern/
[深入学习Tomcat8]:								http://blog.csdn.net/column/details/tomcat8.html
[Apache Tomcat 8 Configuration Reference]:		http://tomcat.apache.org/tomcat-8.0-doc/config/index.html
[Apache Tomcat 8 Architecture]:					http://tomcat.apache.org/tomcat-8.0-doc/architecture/index.html


[Tomcat 8 server.xml详解]:						http://blog.csdn.net/flyliuweisky547/article/details/20790601
[Tomcat server.xml详解]:						http://blog.sina.com.cn/s/blog_6925c03c0101d6tx.html
[Tomcat系列之服务器的安装与配置以及各组件详解]:	http://freeloda.blog.51cto.com/2033581/1299644
[从零认识tomcat，构建一机多实例tomcat集群]:		http://grass51.blog.51cto.com/4356355/1123400
[Tomcat启动过程原理详解]:						http://www.ha97.com/4820.html


