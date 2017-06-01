---
layout: post
title: Spring 源码：概要
description: Spring 框架，源码学习概要
published: true
category: spring
---

## 1. 概要

重走 Spring 之路，梳理源码和最佳实践：

* IOC
* AOP
* 事务
* Task
* Test
* Cache
* DB
* ...

此次主线：Java Web 框架，顺便梳理 Spring。从设计框架的角度，去学习框架。

场景：

1. 框架的用途？满足哪些场景？
1. 怎么写框架？
1. 框架要支持哪些关键模块？事务？AOP？安全？与其他框架的对接？
1. 潜在瓶颈？
1. 一些常用的写法？开发过程中，常用的设计模式

## 2. 小组讨论

讨论形式：

* 内容来源：一方面要有自己的思路、另一方面借鉴别人的总结
* 形式：
	* 侧重典型场景，避免过于牵扯细节
	* 一图胜千言，多使用图片
	* 讨论之前，明确问题：什么问题？怎么解决的？什么原理？不做糊涂的讨论
	* 每次讨论，单独准备 keynote、wiki，方便问题聚焦，避免无谓的切换
	* 不指定主讲人，谁想讲谁讲，每次主持 2 人
	* 做好前期计划、后期总结：问题、资料整理
	* 学习小组最终结束时，讨论出一个汇总、定稿
* 时间：
	* 25mins 场景介绍 + 15mins 自由讨论
	* 力求简短

## 3. 讨论

### 3.1. 第一次

分享内容：IoC及Spring IoC启动过程

具体：

1. IoC 的目标：对象之间的依赖关系解耦
1. 本质：工厂类 + 反射
1. 不为每个类创建工厂类，因此，抽象工厂类
1. IoC，控制反转，对象之间的依赖关系，从代码中剥离，交给 IoC 容器负责。
1. Web 工程启动过程：main → jetty → Spring context
1. IoC 原理本质上很简单，只是 Spring 优雅的设计，让代码变得晦涩，最简单粗暴的方式，分下面几步：
	1. 扫描所有 class ，生成 Class_Map，key为id，value 为 class 对象；
	1. 扫描 Class_Map，生成 Object_Map，key 为 id，value 为 class 对应的实例对象；
	1. 扫描 Object_Map，为每一个 Object 中的 field 绑定 Object；

疑问：

1. @PostConstruct 注解的执行时间，在 Bean 生命周期中的位置。
 
下次安排：

* 主题：AOP

### 3.2. 第二次


分享内容：Spring AOP

具体：

1. Spring AOP 和 AspectJ 是 2 种具体的实现
1. Spring AOP 中，直接使用 AspectJ 的注解，但具体动态代理机制用的是 SpringAOP 自己的机制
1. 编织：
	1. 静态编织：编译阶段，java → class 字节码时，处理注解
	1. 动态代理：运行时阶段，根据 class 字节码，动态生成代理class
1. 类加载：编译、加载、初始化、卸载
1. 代理类的实现：继承方式、组合方式
	1. JDK 动态代理：组合
	1. CGLIB 字节码增强：继承
	1. 继承、组合方式的优劣？
1. 拦截器链：JDK 动态代理中，采用拦截器链
 
疑问：

* CGLIB 中是否有拦截器链？
 
下次安排：

* 主题：MVC

### 3.3. 第三次

Spring MVC

具体：

1. Servlet与http关系，Servlet规范，web.xml规范规定要有
1. Filter的重要性，本质上springmvc很多用到该技术
1. web.xml配置，执行过程，按配置顺序
1. DispatchServlet
1. Controller与Servlet
1. namespace对应注解的处理

疑问：

* http response 转换为 JSON 串的处理细节
 
下次安排：

* 主题：Spring命名空间和MessageConverter

### 3.4. 第四次

分享内容：Spring Namespace XML、Spring MessageConverter

具体：

1. Spring Namespace XML，namespace的处理逻辑、好处、场景、自定义
1. Spring MessageConverter，Object到JSON转换

疑问：

1. p命名空间，[beans-p-namespace](http://docs.spring.io/spring/docs/current/spring-framework-reference/htmlsingle/#beans-p-namespace)
1. c命名空间，[beans-c-namespace](http://docs.spring.io/spring/docs/current/spring-framework-reference/htmlsingle/#beans-c-namespace)

下次安排：

* 主题：Spring Boot

### 3.5. 第五次

分析内容：Spring Boot揭秘

具体：

1. Spring配置的一种发展趋势：JavaConfig
1. SpringBoot的启动过程

疑问：

1. Jetty和Tomcat都同时配置的话会如何选择启动？
1. 是否会加载很多无用的class文件等，加重虚拟机的负载？
1. 如果自己的一个项目，如何改造为能够被springboot自动加载？

下次安排：

* 主题：Spring Task

### 3.6. 第六次

分析内容：Spring Task

具体：

1. concurrent 包中：ThreadPoolExecutor 实现 Executor 接口
1. corePoolSize：小于 corePoolSize 时，优先执行；
1. workQueue：一旦运行线程达到 corePoolSize，就排队优先
1. 如果队列排满，则新起线程，要求线程数小于：maximumPoolSize，如果已经达到 maximumPoolSize 则，开启独立处理策略（调用线程来执行、丢弃等）；
1. 定时任务：
	1. 实际是 workQueue（小顶堆），根据执行时间排序，每次取出一个任务，会判断是否为周期任务
1. Timer：
	1. 执行时机：时间点？时间段？时间基准？
	1. 任务并发性：Timer 单线程
	1. 异常的影响：

下次安排：

* 主题：Spring 事务

### 3.7. 第七次

分析内容：Spring Transaction

具体：

* 事务简介（定义、ACID）、事务属性（隔离级别、传播规则、超时时间、只读属性、回滚规则）
* Spring事务用法：编程式、声明式
* Spring事务机制、有效性
* 事务传播规则

下次安排：

* 主题：Spring Cache

### 3.8. 第八次

分享内容：Spring Cache

具体：

* Cache和Buffer的区别：一次性；对应用的透明性
* 缓存满时移除策略：LFU、LRU、FIFO
* 缓存失效实现策略：主动？惰性？
* TTL(Time To Live) 和TTI(Time To Idle)
* Spring提供的几个注解，复杂的规则使用SpEL

下次安排：

* 主题：Spring Test

### 3.9. 第九次

分享内容：SpringTest

具体：

* Spring Test 是基于 JUnit 实现的
* JUnit：
	* JUnitCore 是 JUnit 的程序入口，@RunWith 中配置的值就是这个
	* @RunWith 是 JUnit 自带注解，用于指定程序入口，如果没有设定 @RunWith 则使用默认的 ClassRunner
	* RunNotifier 中注册多个 Listener
	* 默认的 Runner：BlockJUnit4ClassRunner
	* JUnit4 中引入 Statement：使用装饰者模式，通过链式结构，将具体的测试逻辑与对应的 beforeClass 和 afterClass 对应的处理逻辑
	* run 方法过程：获取 Statement ，然后进行拼接
	* 针对每一个 @Test 测试逻辑，都会执行一次 @Before 和 @After
	* 整体 Class 执行过程中，只执行一次 @BeforeClass 和 @AfterClass （是静态方法 public static）
	* 默认情况下，针对每一个 @Test 测试逻辑，都会重新实例化一个 ServiceTest 实例
* Spring Test：
	* Spring Test 通过 @RunWith 进入 JUnit4
	* 本质是：增加了 txManager，其中组装了 testContext + List<TestListener> ，通用的业务逻辑是通过 TestListener 来进行定制的。
	* TestListener 中有多处可以定制的切点

疑问：

* 查证：每个 TestClass 默认会重新构建一次 testContext？Spring 中 DI （对应DIListener）会重新执行一次，可能有配置，能够让不同的 TestClass 共享同一个 testContext 么？

下次安排：

* 主题：Spring Validation、Binding

### 3.10. 第十次

分析内容：Spring Validation, Data binding, and Type Conversion

具体：

1. data binding目标、简介、机制、过程
1. Type Conversion，本质都是：String → Java Object
1. 枚举的处理，先ordinal，再name
1. Formatter
1. 数据校验，注解、标签、规则
1. 异常转换，三种
1. 配置
1. 三者相互独立、没有依赖

下次安排：

* 主题：无--阶段结束，转入下一主题。


## 4. 参考资料

1. Spring 3.x 企业应用开发
1. Spring 揭秘
1. 《架构探险：Java Web 框架》黄勇
1. 《Spring 实战 （第 4 版）》
2. [开涛-Spring 系列](http://jinnianshilongnian.iteye.com/blog/1752171)
3. [Spring 系列](http://my.oschina.net/flashsword/blog?catalog=413619)






[NingG]:    http://ningg.github.com  "NingG"










