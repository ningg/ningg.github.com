---
layout: post
title: MyBatis中缓存机制
description: 一级缓存、二级缓存的实现原理
published: true
category: MyBatis
---




整体上，来一张图：

![](/images/mybatis-cache/mybatis-cache.png)




## 一级缓存

一级缓存是Session会话级别的，几点：

* 缓存由谁管理？
	* 当使用MyBatis开启一次和数据库的会话，MyBatis会创建出一个SqlSession对象表示一次数据库会话
	* SqlSession内部管理一个简单的缓存，记录每次查询的结果，相同的查询，直接读取缓存，不再查询数据库
* 缓存什么时候清除？
	* SqlSession调用close()方法
	* SqlSession调用clearCache()方法
	* SqlSession调用update操作（包括：update、delete、insert）
* 缓存中内容是什么？
	* HashMap保存的key-value对
	* key是根据查询的sql语句生成的 *（这个是关键内容）*

关于一级缓存的性能问题，详细查看：[MyBatis的一级缓存实现详解 及使用注意事项]





## 二级缓存


MyBatis并不是简单地对整个Application就只有一个Cache缓存对象，它将缓存划分的更细，即是Mapper级别的，即每一个Mapper都可以拥有一个Cache对象，具体如下：

* 为每一个Mapper分配一个Cache缓存对象（使用`<cache>`节点配置）；
* 多个Mapper共用一个Cache缓存对象（使用`<cache-ref>`节点配置）；

MyBatis对二级缓存的支持粒度很细，它会指定某一条查询语句是否使用二级缓存。

在二级缓存的设计上，MyBatis大量地运用了装饰者模式，如CachingExecutor, 以及各种Cache接口的装饰器。

关于装饰者模式，参考：[装饰者模式]



## 一级缓存和二级缓存的使用顺序


请注意，如果你的MyBatis使用了二级缓存，并且你的Mapper和select语句也配置使用了二级缓存，那么在执行select查询的时候，MyBatis会先从二级缓存中取输入，其次才是一级缓存，即MyBatis查询数据的顺序是：

`二级缓存`  ———> `一级缓存`  ——> `数据库`



## todo


Hibernate vs. MyBatis

* [Hibernate与MyBatis的对比]
* [Hibernate 与mybatis的区别]


## 参考来源


* [深入理解MyBatis原理]
* [Mybatis数据源与连接池]
* [MyBatis缓存机制的设计与实现]				
* [MyBatis的一级缓存实现详解 及使用注意事项]	
* [MyBatis的二级缓存的设计原理]					
* [装饰者模式]









[NingG]:    http://ningg.github.com  "NingG"

[深入理解MyBatis原理]:		http://blog.csdn.net/column/details/mybatis-principle.html
[Mybatis数据源与连接池]:	http://blog.csdn.net/luanlouis/article/details/37671851?utm_source=tuicool

[MyBatis缓存机制的设计与实现]:						http://blog.csdn.net/luanlouis/article/details/41390801
[MyBatis的一级缓存实现详解 及使用注意事项]:			http://blog.csdn.net/luanlouis/article/details/41280959
[MyBatis的二级缓存的设计原理]:						http://blog.csdn.net/luanlouis/article/details/41408341


[装饰者模式]:				http://blog.csdn.net/luanlouis/article/details/19021803


[Hibernate与MyBatis的对比]:			http://www.cnblogs.com/younggun/archive/2013/08/04/3235878.html
[Hibernate 与mybatis的区别]:		http://blog.csdn.net/julinfeng/article/details/19821923



