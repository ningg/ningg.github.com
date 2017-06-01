---
layout: post
title: Spring 源码：Testing
description: Spring 框架下，Testing 的底层实现机制
published: true
category: spring
---

## 0. 测试代码的重要作用

整理一下：

1. 避免低级 bug：数据库字段缺失、数据库CRUD代码不完整、JSON 字段是否完整；
1. 提升开发、调试效率：部署应用很耗时，避免因为小bug，反复打包部署；
1. 工程重构、新人交接时，测试代码提供很大便利；

## 1. 开卷前的思考

几点：

* Spring Testing：Spring TestContext 框架
* JUnit4
* IDEA 下，进行测试

Spring Testing 具体包括两个框架：

* Spring TestContext 框架
* Spring MVC Test Framework框架

针对 Spring TestContext框架，具体：

* 定位：
	* 基于注解：Spring TestContext 是Spring提供的一套基于注解的Test框架,
	* 多种实现：Spring TestContext 有非常好的兼容性,可以无缝兼容JUnit、TestNG等单元测试框架，并且在其基础上增加丰富的功能 
* 为什么不直接使用 JUnit4 ？直接使用 JUnit 4等框架时，有几个问题需要考虑：
	* 频繁初始化Spring容器：此问题已于JUnit4中被解决，通过使用@BeforeClass 可以有效防止Spring容器被多次初始化的问题 
	* 硬编码获取Bean：此问题是由于JUnit并不兼容Spring，所以当单元测试运行的时候，无法解释Spring独有的注解，从而需要使用硬编码来获取Bean 
	* 数据现场破坏：JUnit当中可以使用DBUnit来进行数据现场维护的解决方案，另，Spring TestContext通过AOP声明式事务来对单元测试进行回滚，有效的解决了数据现场的问题 
	* 事务：单元测试都需要和数据库进行交互，但传统的JUnit的组成单元为TestCase，并不存在事务的概念，而我们大多数情况下都需要观察事务的执行过程或总体的性能，特别是对长事务模块的测试, Spring TestContext允许单元测试支持事务的控制

思考：摆脱具体测试框架（JUnit4、TestNG），能够直接使用 Spring Test 吗？

Re：Spring Test 是一种抽象接口，需要底层具体的测试框架来承载，因此，只使用 Spring Test 无法正常工作。

## 2. 单元测试 & 集成测试

Unit Testing：单元测试，针对POJO上单个方法，进行测试，Spring中提供一系列的mock手段；

Integration Testing：集成测试，基于业务流程，进行测试；Spring Testing 在集成测试时，提供几点：

* 加载 Spring Context，并且缓存Context内容，避免重复初始化Spring Context；
* 利用Spring IoC机制，依赖注入bean
* 支持事务
* 提供一些抽象类，方便使用

## 3. Spring TestContext 源码剖析

简单理一下，测试一个方法所需的基本条件：

* 提供测试的上下文环境
* 捕捉方法测试之前、测试之后的动作
* 管理上面两项

### 3.1. Spring TestContext 框架概要

![](/images/spring-framework/spring-TestContext.png)

具体到Spring Test 框架，其核心是 org.springframework.test.context 包下：

* TestContext：提供运行测试用例的上下文环境 Spring application context，缓存 applicationContext；
* TestExecutionListener：监听器，提供依赖注入、applicationContext缓存、事务管理能力；
* TestContextManager：
	* Spring Test 框架的主入口
	* 内部包含：一个TestContext实例，以及多个TestExecutionListener
	* 在相应时间点，向其中TestExecutionListener发布事件通知，触发相应操作
* ContextLoader：负责根据配置加载 Spring 的 bean 定义，以构建 applicationContext 实例对象
* SmartContextLoader：Spring 3.1 引入的新加载方法，支持按照 profile 加载

Spring 提供了几个 TestExecutionListener 接口实现类，分别说明如下：

* DependencyInjectionTestExecutionListener：提供了自动注入的功能，它负责解析测试用例中 @Autowried 注解并完成自动注入；
* DirtiesContextTestExecutionListener：一般情况下测试方法并不会对 Spring 容器上下文造成破坏（改变 Bean 的配置信息等），如果某个测试方法确实会破坏 Spring 容器上下文，你可以显式地为该测试方法添加 @DirtiesContext 注解，以便 Spring TestContext 在测试该方法后刷新 Spring 容器的上下文，而 DirtiesContextTestExecutionListener 监听器的工作就是解析 @DirtiesContext 注解；
* TransactionalTestExecutionListener：它负责解析 @Transactional、 @Rollback 等事务注解的注解。@Transactional 注解让测试方法工作于事务环境中，不过在测试方法返回前事务会被回滚。你可以使用 @Rollback(false) 让测试方法返回前提交事务。此外，可以使用类或方法级别的 @TransactionConfiguration 注解改变事务管理策略。

Spring 通过 AOP hook 了测试类的实例创建、beforeClass、before、after、afterClass 等事件入口，执行顺序主要如下：

![](/images/spring-framework/spring-testing-aop-details.png)
 
* 测试执行者开始执行测试类，这个时候 Spring 获取消息，自动创建 TestContextManager 实例
* TestContextManager 会创建 TestContext，以记录当前测试的上下文信息，TestContext 则通过 ContextLoader 来获取 Spring ApplicationContext 实例
* 当测试执行者开始执行测试类的 BeforeClass、Before、After、AfterClass 的时候，TestContextManager 将截获事件，发通知给对应的 TestExecutionListener

JUnit 4 中可以通过 @RunWith 注解指定测试用例的运行器，Spring Test 框架提供了扩展于 org.junit.internal.runners.JUnit4ClassRunner 的 SpringJUnit4ClassRunner 运行器，它负责总装 Spring Test 测试框架并将其统一到 JUnit 4 框架中。

* @RunWith 注解将SpringJUnit4ClassRunner 指定为测试用例运行器，负责将 Spring TestContext 测试框架，无缝对接到 JUnit 测试框架中，它是 Spring TestContext 可以运行起来的根本所在。
* @TestExecutionListeners 注解，能够为当前测试用例注册监听器，从而能够支持丰富的注解，例如：@Autowire、@Rollback等

### 3.2. TestContext 提供的抽象测试用例类

Spring TestContext 为基于 JUnit 4.4 测试框架提供了两个抽象测试用例类，分别是 AbstractJUnit4SpringContextTests 和 AbstractTransactionalJUnit4SpringContextTests，而后者扩展于前者提供事务支持。

说明：

1. 编写的测试用例类，可以不继承上述抽象类，同时也不用添加@TextExecutionListener注解？思考：这些Listener是如何生效的？
1. AbstractJUnit4SpringContextTests 和 AbstractTransactionalJUnit4SpringContextTests，两个抽象基类，目标：获取applicationContext

（TODO）

## 4. 最佳实践

### 4.1. 在工程中配置 Spring Test + JUnit4

添加如下依赖即可：

```
<dependency>
    <groupId>junit</groupId>
    <artifactId>junit</artifactId>
    <version>${junitVersion}</version>
</dependency>
<dependency>
    <groupId>org.springframework</groupId>
    <artifactId>spring-test</artifactId>
    <version>${org.springframework-version}</version>
    <scope>test</scope>
</dependency>
```

### 4.2. 常用规范

几点：

* 命名：测试类、测试方法
	* 测试类：***Test
	* 测试方法：Test***
* 常用的注解：
	* @Test 
	* @Resource 
	* @Rollback
	* @After 
	* @RunWith
	* @ContextConfiguration
 
（todo）

注：JUnit 4 中编写单元测试，注意事项：

* 添加@Test
* public void TestMethod()：public void 修饰，无参，Test命名
 
### 4.3. 对接外部系统

场景：

> Service 层代码，会调用外部系统，如何测试Service？Mockito 与 Spring AOP 之间兼容有问题。

## 5. Spring 工程，搭建测试环境

Spring工程，包含普通Spring工程、Spring Web工程，测试方案有哪些？如何搭建？这才是本文的重点。

### 5.1. 测试方案调研

现有Spring工程采用的测试方案：

* [SpringSide4 - design](https://github.com/springside/springside4/wiki/Design)

特别说明：

Mockito 跟 Spring 结合时，存在潜在问题：Spring IoC容器管理的beanA，使用Mockito来mock beanA 内部beanB时，如果beanA实际是代理类，则mock的BeanB，只存在于beanA代理类中，并不存在于beanA的业务类里；实际上 Spring AOP机制，产生beanA代理类之后，具体执行单个方法时，先到达beanA代理类，然后转发beanA业务类。

更多细节，参考：

* [Mock Service with Mockito and Spring](https://groups.google.com/forum/#!topic/mockito/lcVUY1TWb4Y)
* [Mocks are not injected in Spring AOP proxies](https://github.com/mockito/mockito/issues/209)

解决办法：

```
ReflectionTestUtils.setField(unwrapProxy(magicCardLocalService), "magicCardService", magicCardService);
...
public static Object unwrapProxy(Object bean) {
if (AopUtils.isAopProxy(bean) && bean instanceof Advised) {
        Advised advised = (Advised) bean;
try {
            bean = advised.getTargetSource().getTarget();
        } catch (Exception e) {
            System.out.println("Exception unwrapping proxy object" + e);
        }
    }
return bean;
}
```

补充：官方可能会提供新的解决办法，[https://github.com/mockito/mockito/pull/277/files](https://github.com/mockito/mockito/pull/277/files)

### 5.2. 初步选定测试方案

几个典型场景：

* 依赖外部系统：
	* 单独测试依赖的外部系统
	* 模拟外部系统动作，屏蔽外部系统干扰，测试当前系统内部功能
* 数据现场：测试过程中产生的数据，测试结束时，要清理掉
* 事务：专门测试事务的效果和性能
* 重复启动Spring IoC容器：频繁初始化 IoC 容器耗时

初步选定：

* JUnit4
	* @BeforeClass：类初始化之前执行，要求 public static void
	* @Before：每个单元测试执行之前，都要执行一次，要求 public void ，无参
	* @Test：
	* @Test(expected=...class)：期待一个异常的发生
	* @Test(timeout=...)：设置超时时间（毫秒级别）
	* @Repeat(times)：设置循环执行次数
* Spring test
	* @RunWith(SpringJUnit4ClassRunner.class) ：启动 Spring 对测试类的支持
	* @ContextConfiguration ：指定 Spring 配置文件或者配置类的位置
	* @Transactional ：启动事务管理
	* @Autowired 、@Resource：注入 Spring 的 bean
	* @DirtiesContext：重新加载applicationContext，方法执行完成或类执行完成时
	* @TransactionConfiguration：指定事务管理器，默认为 transactionManager
	* @ActiveProfiles，指定一个或者多个 profile，测试类中仅仅加载这些名字的 profile 中定义的 bean 实例

### 5.3. 搭建测试环境

#### 5.3.1. 添加依赖

（todo）

#### 5.3.2. 实例代码

详细阅读：

* [使用 Spring 进行单元测试](https://www.ibm.com/developerworks/cn/java/j-lo-springunitest/)

## 6. 参考来源


* [Spring MVC测试框架详解——服务端测试](http://jinnianshilongnian.iteye.com/blog/2004660)
* [加速Java应用开发速度3——单元/集成测试+CI](http://jinnianshilongnian.iteye.com/blog/1893135)
* [springside4：Test-Overview](https://github.com/springside/springside4/wiki/Test-Overview)
* [JUnit with Spring](http://blog.csdn.net/fireofjava/article/details/8672310)
* [Mockito with Spring](http://blog.csdn.net/fireofjava/article/details/8687128)
* [使用 Spring 进行单元测试](https://www.ibm.com/developerworks/cn/java/j-lo-springunitest/)










[NingG]:    http://ningg.github.com  "NingG"










