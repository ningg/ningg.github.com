---
layout: post
title: 开发实践：通用 web 工程
description: 通用的 web 工程需要思考哪些方面
published: true
category: 开发实践
---

本文目标：利用各项基础服务，搭建 Web 工程。

## 0. 概要说明

本篇 wiki 基本过程：

1. 快速搭建整个 web 工程，做好基本记录，不要求很细节的内容
1. 使用过程中，逐个主题研究，补充各个细节

## 1. 搭建步骤

### 1.1. 创建工程

创建工程：WebProjectDemo

### 1.2. Maven 管理工程

将工程 clone 到本地：

```
git clone [git_path]
```

使用 Maven 管理工程，直接在 IntelliJ IDEA 中创建 Maven 工程即可：（archetype 使用 webapp）

![](maven-webapp-archetype.png)

【疑问】：如何查看不同 archetype 的目录结构？典型的 archetype 整理

最终创建的工程如图所示：

![](maven-webapp-archetype-details.png)

创建 `.gitignore` 文件，忽略 IDEA 工程文件 & class 文件：

```
# IDEA
.idea/**
*.iml
```

【疑问】：如何启动上述 web 应用？如何发布上述 web 应用？

为了方便进行单测，直接完善工程目录结构：

![](maven-webapp-archetype-details-add-test.png)

### 1.3. 使用 Spring Web

到 [Spring 官网](https://spring.io/projects)，逛一圈，看看如何将 Spring Web 集成到当前工程。在众多工程中，一眼看到 Spring Framework。

解释一下，就是说 SPRING FRAMEWORK 支持：

* 依赖注入(DI)
* 事务管理
* ...

[点进去](http://projects.spring.io/spring-framework/)，看看 SPRING FRAMEWORK 的 Features：

* Dependency Injection
* Aspect-Oriented Programming including Spring's declarative transaction management
* Spring MVC web application and RESTful web service framework
* Foundational support for JDBC, JPA, JMS
* Much more...

All avaible features and modules are described in the [Modules section of the reference documentation](http://docs.spring.io/spring-framework/docs/current/spring-framework-reference/html/overview.html#overview-modules).

就是他了，根据 [SPRING FRAMEWORK](http://projects.spring.io/spring-framework/) 页面的说明，在 pom.xml 中配置，将其集成到当前工程。

根据 [Spring MVC 官网](http://docs.spring.io/spring/docs/current/spring-framework-reference/html/mvc.html) 介绍，在 `web.xml` 文件中，添加 Spring MVC 的配置：

```
<context-param>
    <param-name>contextConfigLocation</param-name>
    <param-value>classpath:app.xml</param-value>
</context-param>
  
<!--添加 spring mvc-->
<servlet>
    <servlet-name>dispatcher</servlet-name>
    <servlet-class>org.springframework.web.servlet.DispatcherServlet</servlet-class>
    <init-param>
        <param-name>contextConfigLocation</param-name>
        <param-value>/WEB-INF/spring-mvc.xml</param-value>
    </init-param>
    <load-on-startup>1</load-on-startup>
</servlet>
<servlet-mapping>
    <servlet-name>dispatcher</servlet-name>
    <url-pattern>/*</url-pattern>
</servlet-mapping>
<listener>
    <listener-class>org.springframework.web.context.ContextLoaderListener</listener-class>
</listener>
```

上述两个配置文件的定位：

1. classpath:app.xml
	1. aop
	1. 初始化 bean：service、dao
	1. 数据源
	1. 缓存
1. /WEB-INF/spring-mvc.xml
	1. 初始化 bean：controller

对上面一些配置的简要描述：

1. ContextLoaderListener：初始化 Root application context
1. web-app > contextConfigLocation 参数，是固定参数，程序会在初始化 Root application context 时，会使用此参数
1. DispatcherServlet：会初始化 Servlet application context

更多信息，参考 [Spring MVC](http://docs.spring.io/spring/docs/current/spring-framework-reference/html/mvc.html) ，附一张插图：

![](dispatcher-servlet-details.png)

特别值得说明的是，一个工程中，可以有多个 DispatcherServlet，他们的 Servlet application context 各自独有，但共有 Root application context。

【疑问】：

1. 独有 Servlet application context 的优点？
1. 可以将所有的Controller 都放置到 Root application context 中吗？

## 2. 运行工程

使用 Maven 管理的 Web 工程，如何启动？正常的 Web 工程，最基本的思路：打成 war 包，部署到应用服务器。

Maven 下运行 Web 工程，有如下几种方式：

1. 插件式：用于 debug
1. 内嵌式：发布、运行
1. 打包式：传统

### 2.1. 插件式


详细内容参考：[maven-jetty-plugin-examples](http://www.mkyong.com/maven/maven-jetty-plugin-examples/)

插件方式启动 jetty，需要在 pom.xml 中 project.build.plugins 元素下配置：

```
<!--插件方式启用 jetty-->
<plugin>
    <groupId>org.eclipse.jetty</groupId>
    <artifactId>jetty-maven-plugin</artifactId>
    <version>9.2.8.v20150217</version>
    <configuration>
        <!--热部署-->
        <scanIntervalSeconds>2</scanIntervalSeconds>
    </configuration>
</plugin>
```

pom.xml 中添加依赖：

```
<!--jetty 插件所需依赖-->
<dependency>
    <groupId>org.aspectj</groupId>
    <artifactId>aspectjrt</artifactId>
    <version>1.8.8</version>
</dependency>
```

### 2.2. 内嵌式

内嵌式启动 Jetty，核心目标：不需要应用服务器，直接使用 jar 包即可运行，即，应用内包含了一个应用服务器。

todo

## 3. 添加数据源

配置 MySQL 数据库，基本过程：

1. 配置数据源
1. 启用线程池
1. 开启事务管理

基本配置如下：

```
<!--连接池-->
<bean id="dataSource" class="org.apache.commons.dbcp.BasicDataSource" destroy-method="close">
       <property name="driverClassName" value="${jdbc.driverClassName}" />
       <property name="url" value="${jdbc.url}" />
       <property name="username" value="${jdbc.username}" />
       <property name="password" value="${jdbc.password}" />
</bean>
 
<!--事务管理-->
<bean id="txManager" class="org.springframework.jdbc.datasource.DataSourceTransactionManager">
       <property name="dataSource" ref="dataSource"/>
</bean>
 
<!--数据库连接配置参数-->
<context:property-placeholder location="jdbc.properties"/>
```

【小结】：相对于原始 JDBC，使用 MyBatis 的优点？如下：

1. 数据库记录与Java 对象之间的自动映射，通常驼峰式命名
1. SQL语句中，支持命名参数方式，而之前只支持占位符
1. 写的代码更少，更简洁

Spring 工程中，如何启用 MyBatis？

```
<!--MyBatis-->
<bean id="sqlSessionFactory" class="org.mybatis.spring.SqlSessionFactoryBean">
    <property name="dataSource" ref="dataSource"/>
</bean>
 
<!--MyBatis-Spring 注册映射器-->
<mybatis:scan base-package="com.ningg.show.dao"/>
```

MyBatis 的工作过程：

1. 实例化一个 SqlSessionFactory，并以此为中心
1. SqlSessionFactory 创建一个 SqlSession
1. SqlSession 包含了面向数据库执行 SQL 命令所需的所有方法，通过 session 执行SQL命令
1. session 通过操作 Mapper 映射器，来执行 SQL

MyBatis-Spring 框架的主要作用：

1. 使 MyBatis 能够参与到 Spring 的事务管理中，不必为 MyBatis 创建一个新的特定的事务管理器
1. 事务处理期间，会创建 MyBatis 的一个单独的 SqlSession，事务完成后，session 会以恰当的方式提交或者回滚
 
参考：

1. [http://www.mybatis.org/mybatis-3/getting-started.html](http://www.mybatis.org/mybatis-3/getting-started.html)
1. [http://www.mybatis.org/spring/mappers.html](http://www.mybatis.org/spring/mappers.html)

## 4. 配置事务

事务管理，整体上分为2类：

1. 本地单数据源，事务管理
1. 多数据源，事务管理

Spring 同时支持上述两种方式。

开启事务支持，配置如下：

```
<!--事务管理-->
<bean id="txManager" class="org.springframework.jdbc.datasource.DataSourceTransactionManager">
       <property name="dataSource" ref="dataSource"/>
</bean>
 
 
<!--启用注解配置事务-->
<tx:annotation-driven transaction-manager="txManager" proxy-target-class="true" order="2" />
```

几点基本知识：

1. Java EE 的事务管理，是与线程绑定的
1. Spring 中，事务默认只会在抛出下面异常时，回滚：
	1. RuntimeException 及其子类
	1. Errors
1. 事务需要配置参数：
	1. 隔离级别
	1. 传播规则
	1. 超时时间
	1. 是否只读
1. 启用 proxy-target-class 
	1. 为 true 表示使用 CGLIB 的动态代理方式
	1. 为 false 表示使用 JDK 动态代理方式，要求动态代理对象必须实现接口
1. order 字段，表示 AOP 的执行顺序，默认为 0 ，表示在最外围
1. `<tx:annotation-drivern />` 只会在当前 web application context 中扫描 @Transactional 注解（特别注意）

## 5. 配置缓存


配置缓存层，缓存的实现方案有多种，最常见的是使用 Redis，这中间涉及到 Redis 集群的设计和搭建，Redis 集群通常包含 Sentinel 集群 和 Redis 集群。

启用 Spring Cache，进行如下配置：

```
<!--启用注解配置缓存-->
<cache:annotation-driven cache-manager="redisCacheManager" proxy-target-class="true" order="1"/>
 
<!-- 本地缓存 -->
<bean id="localCacheManager" class="org.springframework.cache.support.SimpleCacheManager">
    <property name="caches">
        <set>
            <ref bean="localCache"/>
        </set>
    </property>
</bean>
<bean id="localCache" class="org.springframework.cache.concurrent.ConcurrentMapCacheFactoryBean"/>
 
<!-- 分布式缓存 -->
<!-- 配置Sentinel，spring-data-redis 1.5.0开始支持此配置 -->
<bean id="sentinelConfig" class="org.springframework.data.redis.connection.RedisSentinelConfiguration">
    <constructor-arg name="master" value="mymaster"/>
    <constructor-arg name="sentinelHostAndPorts">
        <set>
            <value>168.7.2.165:26379</value>
            <value>168.7.2.166:26379</value>
            <value>168.7.2.167:26379</value>
        </set>
    </constructor-arg>
</bean>
 
<!-- 配置redis池，依次为最大实例数，最大空闲实例数，(创建实例时)最大等待时间，(创建实例时)是否验证 -->
<bean id="jedisPoolConfig" class="redis.clients.jedis.JedisPoolConfig">
    <property name="maxTotal" value="500"/>
    <property name="maxIdle" value="50"/>
    <property name="minIdle" value="5"/>
    <property name="maxWaitMillis" value="2000"/>
    <property name="testOnBorrow" value="true"/>
</bean>
 
<!-- redis连接配置，依次为数据库，是否使用池，(usePool=true时)redis的池配置 -->
<bean id="jedisConnFactory" class="org.springframework.data.redis.connection.jedis.JedisConnectionFactory">
    <property name="database" value="0"></property>
    <property name="usePool" value="true"/>
    <constructor-arg name="sentinelConfig" ref="sentinelConfig"/>
    <constructor-arg name="poolConfig" ref="jedisPoolConfig"/>
</bean>
 
<!-- redis模板配置 -->
<bean id="redisTemplate" class="org.springframework.data.redis.core.RedisTemplate">
    <property name="connectionFactory" ref="jedisConnFactory"/>
    <property name="defaultSerializer">
        <bean class="org.springframework.data.redis.serializer.StringRedisSerializer"/>
    </property>
</bean>
 
<!--redis 作为分布式缓存-->
<bean id="redisCacheManager" class="org.springframework.data.redis.cache.RedisCacheManager">
    <constructor-arg name="redisOperations" ref="redisTemplate"/>
</bean>
```

特别说明：Spring 中配置缓存与Spring 中配置事务十分类似，

1. `<cache:annotation-driven />` 只会在当前 web application context 中扫描缓存相关的注解.
1. 使用缓存时，对于缓存中的 key 设置，很讲究，通常采用前后缀的方式。

【疑问】：

1. 研究 CacheManager 的作用？
1. 如何定制 CacheManager？

## 6. 搜索（TODO）

Spring web 的搜索有 3 中常见做法：

1. MySQL：非文本的检索
1. Solr：文本检索
1. ES：文本检索、数据分析


参考来源

1. [Spring Data solr](http://docs.spring.io/spring-data/solr/docs/current/reference/html/)
1. [solr vs. ES](http://solr-vs-elasticsearch.com/)
1. [solr 服务](http://lucene.apache.org/solr/)

## 7. 定时任务 & 异步任务

### 7.1. 简介

定时任务，本质是 Java 多线程的内容。

Note：因为定时任务、异步任务使用的接口有差异，因此分开定义线程池。

### 7.2. spring 中对应配置

配置相关：

```
<!--开启 task 的注解方式-->
<task:annotation-driven proxy-target-class="true"/>
 
<!--定义: 定时任务的线程池-->
<task:scheduler id="taskScheduler" pool-size="32"/>
 
<!--启动定时任务-->
<task:scheduled-tasks scheduler="taskScheduler">
    <task:scheduled ref="orderAdaptorService" method="fetchAndFixOrder" fixed-delay="1000" initial-delay="6000"/>
</task:scheduled-tasks>
 
<!--定义: 异步任务的线程池-->
<task:executor id="syncExecutor" pool-size="8-64" keep-alive="300" queue-capacity="128" rejection-policy="DISCARD_OLDEST"/>
```

【疑问】：弄清楚注解的详细处理过程，bean 的初始化，哈哈～

### 7.3. 程序范例

上面使用 xml 配置，指定线程池的使用，实际上，一些情况下，需要在程序中调用线程池，添加异步任务或者定时任务。

定时任务的示例代码：

```
@Resource
private TaskScheduler fixOrderScheduler;
  
...
  
fixOrderScheduler.schedule(new Runnable() {
    @Override
    public void run() {
        orderAdaptorService.submitFix(order.getId());
    }
}, DateTime.now().plusSeconds(result.getNextActionDelay()).toDate());
```

异步任务的示例代码：

```
@Resource
private AsyncTaskExecutor fixOrderExecutor;
  
...
  
fixOrderExecutor.submit(new Runnable() {
    @Override
    public void run() {
        if (isFix) {
            orderAdaptorService.fix(orderId);
        } else {
            orderAdaptorService.query(orderId);
        }
    }
});
```


### 7.4. 参考来源

1. [spring scheduling](http://docs.spring.io/spring/docs/current/spring-framework-reference/html/scheduling.html)

## 8. 日志（TODO）

### 8.1. 简介

有各种各样的日志生成方式，当前最常见的是 log4j2，这就需要处理两个基本问题：

1. 基本方案：
	1. 抽象层：slf4j
	1. 实现层：log4j2
1. 对于依赖的各个jar 包
	1. 取消对其他日志记录方式的依赖
	1. 替换为 log4j2
1. 解决办法：
	1. pom.xml 中通过 exclude 方式排除不同 jar 依赖的日志记录方式
	1. 工程中直接使用 slf4j

### 8.2. log4j2 的配置方式

todo

## 9. 异常处理（TODO）

### 9.1. 简介

基本目标：

1. 能够抛出异常：系统运行异常、业务逻辑异常
1. 适当的异常，要能够抛到 UI 中

Spring 中使用 ControllerAdvice 和 ExceptionHandler 两个注解。

### 9.2. 参考来源

1. [exception-handling-in-spring-mvc](https://spring.io/blog/2013/11/01/exception-handling-in-spring-mvc)
 
## 10. 单元测试 & 集成测试（TODO）

### 10.1. 简介

需要考虑的基本问题：

1. 测试环境与开发环境完全隔离




















[NingG]:    http://ningg.github.com  "NingG"










