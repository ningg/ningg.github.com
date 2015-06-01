---
layout: post
title: Spring整合Redis
description: Spring MVC中采用Redis作为数据缓存层
published: true
categories: spring web
---

几点：

* Redis是数据源，Spring中如何配置多个数据源？
* Spring中如何配置Redis数据源？
* 对Redis的基本操作

详细信息参考：[Simple Web DEMO][Simple Web DEMO]

##Maven中配置

利用spring-data-redis模块，实现Spring与Redis之间的集成，具体，在pom.xml中添加依赖：

	<dependencies>
		<dependency>
			<groupId>org.springframework.data</groupId>
			<artifactId>spring-data-redis</artifactId>
			<version>1.5.0.RELEASE</version>
		</dependency>
	</dependencies>

##Spring中配置Bean

在Spring配置文件中，添加如下bean配置：

	<bean id="jedisConnFactory" 
		class="org.springframework.data.redis.connection.jedis.JedisConnectionFactory" 
		p:use-pool="true"/>

	<!-- redis template definition -->
	<bean id="redisTemplate" 
		class="org.springframework.data.redis.core.RedisTemplate" 
		p:connection-factory-ref="jedisConnFactory"/>

几个疑问：

* `<bean>`中`p:use-pool`属性的含义？这种方式编写属性，与`<bean>`下`<property>`的差异？
* `<bean>`对应着一个`class`，如何确定这个`class`所对应的属性？

注：使用Maven来管理工程，能够方便的查看`JedisConnectionFactory`的源码，其中对应的属性、构造函数等，包含的信息丰富。


###完整配置信息


























Spring+Redis，参考：















 http://snowolf.iteye.com/blog/1666908
 http://www.cnblogs.com/sand-tiny/p/4155683.html 
 http://blog.jobbole.com/44476/
 http://blog.csdn.net/qinsihang/article/details/22722253
 http://blog.csdn.net/qinsihang/article/details/20128893
 
 http://aiilive.blog.51cto.com/1925756/1627478
 http://zhaozhiming.github.io/blog/2015/04/12/spring-data-redis/
 http://blog.csdn.net/A_lele123/article/details/43406547
 http://www.ibm.com/developerworks/cn/java/os-springredis/










[NingG]:    http://ningg.github.com  "NingG"


[Simple Web DEMO]:						https://github.com/ningg/simple-web-demo
[Spring Data Redis - 官网]:				http://projects.spring.io/spring-data-redis/









