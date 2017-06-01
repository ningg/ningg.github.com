---
layout: post
title: Spring 源码：Transaction
description: Spring 框架下，事务的实现机制
published: true
category: spring
---

几个问题：

1. Transactional 注解对应 Handler 的详细执行过程？
1. Spring 下，同一个事务，能够包含 2 个线程吗？
1. Spring 下，一个事务，与 MySQL 中事务一一对应吗？
1. MySQL 的事务机制？

## 1. 基础知识

### 1.1. 事务简介

事务：一组操作，满足 ACID 几个特性。

事务的四个关键特性(ACID)

|关键特性|说明|
|---|---|
|原子性(atomicity)|一组操作，是一个不可分割的整体，要么全成功，要么全失败，没有中间态|
|一致性(consistency)	满足业务方面的一致性要求|
|隔离性(isolation)|多事务并发执行时，相互不干扰|
|持久性(durability)|一旦事务 commit，它的结果将不受系统错误的影响（通常被写到持久化存储器中）|

### 1.2. 事务的属性

要描述一个事务（Transaction），需要通过不同的属性值来描述。事务的常用属性：

|属性|备注|
|---|---|
|隔离级别|多个事务的并发执行效率|
|传播规则|事务的产生规则|
|超时时间|最多等多久|
|只读属性|是否是只读事务|
|回滚规则|什么情况下回滚|

### 1.3. 事务执行过程

事务执行的基本过程：

![](/images/spring-framework/general-transaction-demo.png)

### 1.4. 事务的分类

整体上，事务分为 2 类：

1. 全局事务，分布式事务，Global Transaction
1. 本地事务，单数据源事务，Local Transaction

上述 2 类事务的简介汇总：

|事务类别|实现方式|
|---|---|
|全局事务|常用的实现方式：1. JTA + JNDI、2. EJB CMT：容器管理事务|
|本地事务| |
 
## 2. Spring 事务用法

使用 Spring 事务机制的根本目标：数据库的连接、关闭、提交、回滚等标准操作，交给代理对象去做，业务代码跟事务管理代码剥离。

### 2.1. Spring 事务管理：不使用

不使用 Spring 事务管理机制，就只能手动进行 try...catch...finally 操作，来进行数据库的提交、回滚等动作。
示例代码如下：

```
try{
    // 获取连接
    conn = getConnection();
 
    // 设置: 不自动提交事务
    conn.setAutoCommit(false);
    Statement stmt = conn.createStatement();
    String SQL1 = “…";
    stmt.executeUpdate(SQL1);
    String SQL2 = “…";
    stmt.executeUpdate(SQL2);
 
    // 提交事务
    conn.commit();
}catch(SQLException se){
 
    //遇到异常时，回滚事务
    if(conn!=null)
        conn.rollback();
}finally{
 
    // 关闭连接
    try {
        if (con != null) con.close();
    } catch (SQLException ex) {
    }
}
```

### 2.2. Spring 事务管理：编程式

（Spring发展到现在，编程式事务已经很少被使用，只有在为了深入理解Spring事务管理才需要学习编程式事务使用）

#### 2.2.1. 直接使用PlatformTransactionManager

Spring 事务管理 3 个核心组件：

![](/images/spring-framework/spring-transaction-core-part.png)
 
PlatformTransactionManager 接口的示例代码如下：

```
public interface PlatformTransactionManager {
    //返回一个已经激活的事务或创建一个新的事务
    TransactionStatus getTransaction(TransactionDefinition definition) throws TransactionException;
    void commit(TransactionStatus status) throws TransactionException;
    void rollback(TransactionStatus status) throws TransactionException;
}
```

具体使用示例代码：

```
public class BankServiceImpl implements BankService {
     
    private BankDao bankDao;
    // 事务定义信息
    private TransactionDefinition txDefinition;
    // 事务管理器
    private PlatformTransactionManager txManager;
    ......
     
    // 完整的事务操作
    public boolean transfer(Long fromId， Long toId， double amount) {
         
        // 获取数据库连接: 包含事务状态.
        TransactionStatus txStatus = txManager.getTransaction(txDefinition);
        boolean result = false;
        try {
             
            // sql session 跟 事务管理器共用数据库连接
            result = bankDao.transfer(fromId， toId， amount);
             
            // 提交事务
            txManager.commit(txStatus);
             
        } catch (Exception e) {
             
            // 事务回滚
            result = false;
            txManager.rollback(txStatus);
            System.out.println("Transfer Error!");
        }
        return result;
    }
}
```
 
#### 2.2.2. 使用TransactionTemplate模板类

使用TransactionTemplate模板类:

1. 不需要显式地开始事务，甚至不需要显式地提交事务——都由模板完成
1. 但出现异常时，应通过TransactionStatus 的setRollbackOnly 显式回滚事务
1. TransactionTemplate 的execute 方法接收一个TransactionCallback 实例

代码示例:

```
transactionTemplate.execute(new TransactionCallback() {
    public Object doInTransaction(TransactionStatus status) {
        try{
            // do xxx
        }
        catch (Exception e) {
            status.setRollbackOnly();  // 将事务标识为不可提交的
        }
    }
);
```

在调用完setRollbackOnly()将事务标识为不可提交之后。大多数数据库可以继续执行读操作，但再执行写执行写操作是没有意义的，因为事务被标记此状态之后即使调用commit()也无法提交，只剩下回滚的可能性。

### 2.3. Spring 事务管理：声明式

**默认情况下，一个有事务的方法，遇到 RuntiomeException 时会回滚**。

声明式的，例如 @Transactional 注解，则只能被应用到public方法上, 对于其它非public的方法,如果标记了@Transactional也不会报错,但方法没有事务功能。

无论使用XML配置方式还是注解方式声明在需要事务的方法上，基本的事务管理器的bean配置都是不可少的。例如：  

```
<!-- 使用JDBC事务管理器 -->
<bean id="txManager" class="org.springframework.jdbc.datasource.DataSourceTransactionManager"> 
    <property name="dataSource" ref="dataSource" /> 
</bean>
```

#### 2.3.1. XML配置方式

这种方式的优势在于对原有的业务逻辑代码，是无侵入式的。

配置基于tx/aop命名空间：

1. 通过 tx:advice 配置事务管理增强
1. 通过 AOP 配置切点

例如：

```
<!-- 通过tx:advice 配置事务管理增强  -->
<tx:advice id="txAdvice" transaction-manager="txManager">
    <!-- 配置事务属性  -->
    <tx:attributes>
        <!-- 指定具体需要拦截的方法，对哪个方法用事务管理 -->
        <!-- 可以对要拦截的方法名使用通配符 -->
        <tx:method name="transfer" propagation="REQUIRED" isolation="DEFAULT" read-only="false" />
        <tx:method name="save*" propagation="REQUIRED" isolation="READ_COMMITTED"/> 
        <tx:method name="*" propagation="REQUIRED" isolation="READ_COMMITTED" read-only="true"/>
    </tx:attributes>
</tx:advice>
   
<!-- 配置AOP -->
<aop:config proxy-target-class="false">
    <!-- 配置切点 -->
    <aop:pointcut expression="execution(* service.MyService.*(..))" id="myTransactionPointcut"/>
    <!-- 对  myTransactionPointcut 切点 进行 txAdvice 增强 -->
    <aop:advisor advice-ref="txAdvice" pointcut-ref="myTransactionPointcut"/>
</aop:config>
```


#### 2.3.2. 注解方式

先添加声明式事务支持的自动配置：

```
<tx:annotation-driven transaction-manager="txManager" proxy-target-class="true" />
```

之后再需要事务化的方法上添加 @Transactional 注解即可。

注解上可以添加的属性有（配置 tx:annotation-driven 时，也可以添加的属性）：

|属性|类型|默认值|说明|
|---|---|---|---|
|transactionManager|String	|transactionManager|事务管理器的 bean id|
|propagation|Propagation枚举|REQUIRED|事务传播属性|
|isolation|isolation枚举|DEFAULT(所用数据库默认级别)|事务隔离级别|
|readOnly|boolean|false|是否才用优化的只读事务|
|timeout|int|-1|超时(秒)|
|rollbackFor|Class[]|{}|需要回滚的异常类|
|rollbackForClassName|String[]|{}|需要回滚的异常类名|
|noRollbackFor|Class[]|{}|不需要回滚的异常类|
|noRollbackForClassName|String[]|{}|不需要回滚的异常类名|

例如，使用如下配置：

```
@Transactional(propagation=Propagation.REQUIRED,isolation=Isolation.DEFAULT,rollbackFor=ArithmeticException.class)
```

声明的方法，支持事务，且使用REQUIRED的事务传播属性，使用DEFAULT的隔离级别，遇到ArithmeticException被抛出则回滚。

### 2.4. 编程式 vs. 声明式

Spring 事务管理，编程式 vs. 声明式的比较：
 
||业务代码耦合度|事务控制粒度|
|---|---|---|
|编程式|耦合|细粒度|
|声明式|不耦合|较粗粒度|
 
## 3. 实现原理

### 3.1. Spring 中事务机制概述

基本要点：

1. Spring事务管理是基于Connection来做的；
1. 事务管理器，会绑定数据源；
1. SqlSessionFactoryBean，也会绑定数据源；
1. 事务管理器、SqlSessionFactoryBean，无耦合关系；
1. 声明式事务，事务管理器对事务的控制通过aop实现，在before中开启事务，after中实现事务提交；
1. 编程式事务，TransactionTemplate 在template中，实现了对事务的开启和提交控制；


具体事务执行过程：

1. 事务的开启：获取Connection，并放在ThreadLocal中；
1. 后续的增删改查，都是通过Connection来操作的，而Connection的获取是先通过 ThreadLocal 获取；
1. 通过 ThreadLocal 的 Connection，保证事务管理器和SqlSession的数据库操作，保持在同一个数据库连接中；

特别说明：

1. 一个 Thread 可以获得多个 Connection；
1. 一个 Connection 同一时刻，只能被一个 Thread 占用；

Spring 中事务的基本原理：

![](/images/spring-framework/transaction-with-thread.png)

### 3.2. 注解方式代码详解

#### 3.2.1. Spring transaction 配置

开启事务的配置：

```
<beans xmlns="http://www.springframework.org/schema/beans"
    xmlns:mybatis="http://mybatis.org/schema/mybatis-spring"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xmlns:tx="http://www.springframework.org/schema/tx"
    xmlns:jdbc="http://www.springframework.org/schema/jdbc"
    xsi:schemaLocation="http://www.springframework.org/schema/beans http://www.springframework.org/schema/beans/spring-beans-4.1.xsd
                        http://www.springframework.org/schema/tx http://www.springframework.org/schema/tx/spring-tx-4.1.xsd
                        http://www.springframework.org/schema/jdbc http://www.springframework.org/schema/jdbc/spring-jdbc-4.1.xsd
                        http://mybatis.org/schema/mybatis-spring http://mybatis.org/schema/mybatis-spring.xsd">
 
    <mybatis:scan base-package="com.meituan.movie.pro.dao.db" />
 
    <bean id="sqlSessionFactory" class="org.mybatis.spring.SqlSessionFactoryBean">
        <property name="configLocation" value="classpath:mybatis-config.xml" />
        <property name="dataSource" ref="dataSource" />
    </bean>
 
    <bean id="transactionManager" class="org.springframework.jdbc.datasource.DataSourceTransactionManager">
        <property name="dataSource" ref="dataSource" />
    </bean>
 
    <!-- 使用annotation定义事务 -->
    <tx:annotation-driven order="2" transaction-manager="transactionManager" proxy-target-class="true" />
 
    <bean id="dataSource" class="com.alibaba.druid.pool.DruidDataSource" init-method="init" destroy-method="close">
        <!-- 基本属性 url、user、password -->
        <property name="url" value="${jdbc_url}" />
        <property name="username" value="${jdbc_username}" />
        <property name="password" ref="dbPassword" />
        <property name="driverClassName" value="${jdbc_driverClassName}" />
 
        <!-- 配置初始化大小、最小、最大 -->
        <property name="initialSize" value="${jdbc_initialSize}" />
        <property name="minIdle" value="${jdbc_minIdle}" />
        <property name="maxActive" value="${jdbc_maxActive}" />
 
        <!-- 配置获取连接等待超时的时间 -->
        <property name="maxWait" value="${jdbc_maxWait}" />
 
        <!-- 配置间隔多久才进行一次检测，检测需要关闭的空闲连接，单位是毫秒 -->
        <property name="timeBetweenEvictionRunsMillis" value="${jdbc_timeBetweenEvictionRunsMillis}" />
 
        <!-- 配置一个连接在池中最小生存的时间，单位是毫秒 -->
        <property name="minEvictableIdleTimeMillis" value="${jdbc_minEvictableIdleTimeMillis}" />
 
        <property name="testWhileIdle" value="${jdbc_testWhileIdle}" />
        <property name="testOnBorrow" value="${jdbc_testOnBorrow}" />
        <property name="validationQuery" value="${jdbc_validationQuery}" />
        <property name="connectionInitSqls" value="${jdbc_connectionInitSqls}" />
    </bean>
 
</beans>
```

其中几个核心概念：

* sqlSessionFactory
* TransactionManager
* DataSource

#### 3.2.2. tx 命名空间的处理细节

查看 tx 命名空间对应的 NameSpaceHandler：spring.handlers 文件中

```
http\://www.springframework.org/schema/tx=org.springframework.transaction.config.TxNamespaceHandler
```

### 3.3. 事务回滚

Spring 的事务管理器只对 `unchecked exception`进行异常回滚：

1. Error 和 RuntimeException 及其子类是 unchecked exception.
1. 其他 Exception 是 checked exception.  

如果在service层中，使用了try-catch来捕捉异常，导致sevice层出现的异常被 “截留”，无法抛出给事务管理器，这就给事务管理器造成一种假象，就像程序在运行中，没有产生任何问题，因此也就不会对出现 runtimeException进行回滚操作。

todo：补充对应的代码

### 3.4. 事务的有效性

事务无效的情况：

1. 在private方法上加@Transaction标签
1. 类内方法调用，AOP 机制未生效
1. 有多个事务管理器，@Transaction没有指定事务管理器name
1. 受检异常，想回滚，却没有指定rollbackFor
1. 在方法内拦截异常
1. 跨库事务

针对上述事务无效的情况，应对策略：

1. public
1. 有调用关系方法拆分到两个类中 or 在类中添加代理类引用
1. 多事务管理器，指定管理器name
1. 要回滚的受检异常，需要通过 rollbackFor 特殊指定
1. 不随便吞异常
1. 不用跨库事务（分布式事务）

todo：补充对应代码

## 4. 常见问题

### 4.1. 事务隔离级别

事务并发执行时，可能出现的现象：

![](/images/spring-framework/several-update-lose-demo.png)
 
Note：

* 不可重复读：读到了已经提交事务的更改数据，采用行锁。
* 幻读：读到了其他已经提交事务的新增数据，采用表锁。
 
事务的隔离级别，本质是事务的并发效率 vs. 数据一致性之间的权衡：

|隔离级别|脏读|不可重复读|幻读|第一类更新丢失|第二类更新丢失|
|---|---|---|---|---|---|
|READ UNCOMMITED|	Y|	Y|	Y|	Y|	Y|
|READ COMMITED|	N	|Y	|Y	 |	 | |
|REPEATABLE READ*|	N|	N|	Y	| 	| |
|SERIALIZABLE	N|	N|	N	| 	 | | |


### 4.2. 事务的传播规则

事务传播规则，本质就是事务的创建规则：不同的事务方法，相互调用时，事务在这些方法之间如何传播。

Spring 中支持的事务传播规则：

![](/images/spring-framework/spring-transaction-propergation.png) 
 
值得注意的下面的三种（假设有两个事务，子事务BC被嵌套在父事务AD之中）：

* REQUIRED：默认的选项。作为事务AD的子事务，事务BC只有在事务AD成功commit时才commit。可以称之为“联合成功”。（但该类型无法满足“隔离失败”）
* REQUIRES_NEW：启动一个新的，不依赖于环境的 "内部" 事务。它拥有自己的隔离范围、自己的锁，不依赖于外部事务。当内部事务开始执行时，外部事务将被挂起，内部事务结束时外部事务继续执行。即事务BC的rollback不影响事务AD的commit，可以称之为“隔离失败” 。（该类型无法满足“联合成功”，事务AD的成功与否完全不影响BC的提交）
* NESTED：开始一个 "嵌套的" 事务,  它是已经存在事务的一个真正的子事务. 事务BC开始执行时,  它将取得一个 savepoint。如果这个嵌套事务失败，我们将回滚到此 savepoint。嵌套事务BC是外部事务AD的一部分, 只有外部事务结束后它才会被提交。（同时满足“联合成功”与“隔离失败”）

简单示例：

![](/images/spring-framework/spring-transaction-propergation-demo.png)


## 5. 参考来源

* [Spring Transaction](http://docs.spring.io/autorepo/docs/spring/4.2.x/spring-framework-reference/html/transaction.html)






## 5. 附录

总结一下，几点：

1. Spring 中事务管理，是依赖于数据库连接的
1. 数据库连接与线程绑定
1. 事务的传播规则不同，同一个线程中，可以绑定多个数据库连接
1. Spring 中事务管理，很关键的两个概念：逻辑事务、物理事务，
1. 多个逻辑事务可映射为同一个物理事务
1. 同一个物理事务，可以看作同一个数据库连接
1. Spring 中默认传播规则为 PROPAGATION_REQUIRED，每个方法都是一个逻辑事务
	1. PROPAGATION_REQUIRED，默认传播规则，一个线程绑定同一个物理事务，就是同一个数据库连接
	1. PROPAGATION_REQUIRES_NEW，新建一个物理事务，此时出现，一个线程绑定同一个数据库的多个链接
	1. PROPAGATION_NESTED，内嵌在同一个事务中，使用 JDBC savepoints 机制

更多参考：[Spring Transaction](http://docs.spring.io/autorepo/docs/spring/4.2.x/spring-framework-reference/html/transaction.html)



 AOP 织入顺序，Order 越小优先级越高，afterReturning 相反。







[NingG]:    http://ningg.github.com  "NingG"










