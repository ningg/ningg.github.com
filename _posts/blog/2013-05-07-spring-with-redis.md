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

## Spring Data Redis官网

官网地址：[Spring Data Redis - 官网][Spring Data Redis - 官网]，特别说明，页面右侧有[Reference][Spring Data Redis - Reference]文档，值得好好读读。

### Maven中配置

利用spring-data-redis模块，实现Spring与Redis之间的集成，具体，在pom.xml中添加依赖：

	<dependencies>
		<dependency>
			<groupId>org.springframework.data</groupId>
			<artifactId>spring-data-redis</artifactId>
			<version>1.5.0.RELEASE</version>
		</dependency>
	</dependencies>

### Spring中配置Bean

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


## 实际配置

下文将列出，实际场景中自己的配置。几点：

* 依赖的jar包
* 配置Redis数据源
* 操作Redis

### Maven中配置

pom.xml中配置依赖：

	<dependency>
		<groupId>org.springframework.data</groupId>
		<artifactId>spring-data-redis</artifactId>
		<version>1.5.0.RELEASE</version>
	</dependency>

	<dependency>
		<groupId>redis.clients</groupId>
		<artifactId>jedis</artifactId>
		<version>2.6.2</version>
	</dependency>

### 配置Redis数据源

在Spring的配置文件中，添加bean，以实现对Redis数据源的配置，具体如下：

	<!-- 配置Sentinel，spring-data-redis 1.5.0开始支持此配置 -->
	<bean id="sentinelConfig"
		class="org.springframework.data.redis.connection.RedisSentinelConfiguration">
		<constructor-arg name="master" value="mymaster" />
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
		<property name="maxTotal" value="500" />
		<property name="maxIdle" value="50" />
		<property name="minIdle" value="5" />
		<property name="maxWaitMillis" value="2000" />
		<property name="testOnBorrow" value="true" />
	</bean>

	<!-- redis连接配置，依次为数据库，是否使用池，(usePool=true时)redis的池配置 -->
	<bean id="jedisFactory"
		class="org.springframework.data.redis.connection.jedis.JedisConnectionFactory">
		<property name="database" value="0"></property>
		<property name="usePool" value="true" />
		<constructor-arg name="sentinelConfig" ref="sentinelConfig" />
		<constructor-arg name="poolConfig" ref="jedisPoolConfig" />
	</bean>

	<!-- redis模板配置 -->
	<bean id="redisTemplate" class="org.springframework.data.redis.core.RedisTemplate">
		<property name="connectionFactory" ref="jedisFactory" />
		<property name="defaultSerializer">
			<bean
				class="org.springframework.data.redis.serializer.StringRedisSerializer" />
		</property>
	</bean>


思考：Spring的配置文件中，bean的配置规范：

* bean的`<property>`含义？如何编写？
* bean的`<constructor-arg>`含义？如何编写？



### 操作Redis

在上述配置条件下，通过IoC机制，可以直接操作Redis，简单举个例子：


	@Resource(name = "redisTemplate")
	private RedisTemplate<String, Object> redisTemplate;

	@Override
	public String get(String key) {
		String result = (String)redisTemplate.opsForValue().get(key);
		return result;
	}

	@Override
	public String hget(String key, String field) {
		String result = (String) redisTemplate.opsForHash().get(key, field);
		return result;
	}

	@Override
	public List<Object> multiGet(String key, Collection<Object> listOfFields) {
		List<Object> resultOfList = redisTemplate.opsForHash().multiGet(key, listOfFields);
		return resultOfList;
	}








## 参考来源

* [Spring Data Redis - 官网][Spring Data Redis - 官网]
* [Spring Data Redis - Reference][Spring Data Redis - Reference]
* [使用Spring-data进行Redis操作]	
* [征服 Redis + Jedis + Spring （一）]
* [关于Redis的常识]		
* [Spring整合Redis作为缓存]	
* [Spring+Redis集成+关系型数据库持久化]
* [使用Spring Data Redis操作Redis（一）]
* [使用Spring Data Redis操作Redis（二）]
* [Redis客户端之Spring整合Jedis]
* [java之redis篇(spring-data-redis整合)]
* [Spring 整合 Redis]
* [redis 学习笔记(5)-Spring与Jedis的集成]





[NingG]:    http://ningg.github.com  "NingG"


[Simple Web DEMO]:							https://github.com/ningg/simple-web-demo
[Spring Data Redis - 官网]:					http://projects.spring.io/spring-data-redis/
[Spring Data Redis - Reference]:			http://docs.spring.io/spring-data/redis/docs/1.5.0.RELEASE/reference/html/

[使用Spring-data进行Redis操作]:				http://zhaozhiming.github.io/blog/2015/04/12/spring-data-redis/
[征服 Redis + Jedis + Spring （一）]:		http://snowolf.iteye.com/blog/1666908
[关于Redis的常识]:							http://blog.jobbole.com/44476/
[Spring整合Redis作为缓存]:					http://blog.csdn.net/qinsihang/article/details/22722253
[Spring+Redis集成+关系型数据库持久化]:		http://blog.csdn.net/qinsihang/article/details/20128893
[使用Spring Data Redis操作Redis（一）]:	http://aiilive.blog.51cto.com/1925756/1627455?utm_source=tuicool
[使用Spring Data Redis操作Redis（二）]:	http://aiilive.blog.51cto.com/1925756/1627478
[Redis客户端之Spring整合Jedis]:				http://blog.csdn.net/A_lele123/article/details/43406547
[java之redis篇(spring-data-redis整合)]:		http://www.cnblogs.com/tankaixiong/p/3660075.html
[Spring 整合 Redis]:						http://blog.csdn.net/java2000_wl/article/details/8543203
[redis 学习笔记(5)-Spring与Jedis的集成]:	http://www.cnblogs.com/yjmyzz/p/4113019.html






