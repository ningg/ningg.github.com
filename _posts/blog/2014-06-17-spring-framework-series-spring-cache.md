---
layout: post
title: Spring 源码：Spring Cache
description: Spring 框架下，缓存的底层实现机制
published: true
category: spring
---

本文关注几点：

1. 为什么：没有 Spring Cache 之前，如何使用缓存？Spring Cache 解决什么问题？
1. 怎么用：如何使用 Spring Cache？
1. 内部机制：Spring Cache 的内部实现机制？

关于缓存的通用问题（并发失效），本文暂不涉及。

## 1. Spring Cache之前，如何使用缓存

> 目标：自定义一个缓存的实现，不实用第三方组件。

场景：对查询方法做缓存（以帐号Account对象为例）

* 以账号名称为 key，账号对象为 value
* 以帐号名称为参数，查询时：
	* 先查缓存，如果命中，则返回结果
	* 缓存未命中，则从数据库查询，并添加缓存
* 要求缓存管理器，提供reload缓存（清空缓存）的服务

帐号对象 Account 如下：

```
package cacheOfAnno;
 
 public class Account { 
    
   // 私有属性
   private int id;
   private String name;
   
   // getter setter 方法
   public Account(String name) {
     this.name = name;
   }
   public int getId() {
     return id;
   }
   public void setId(int id) {
     this.id = id;
   }
   public String getName() {
     return name;
   }
   public void setName(String name) {
     this.name = name;
   }
 }
```
 
定义缓存管理器（MyCacheManager），负责实现缓存逻辑，支持对象的查询、增加、修改和删除，支持值对象的泛型。

```
package oldcache;
 
 import java.util.Map;
 import java.util.concurrent.ConcurrentHashMap;
 
 // 使用泛型
 public class MyCacheManager<T> { 
  
   // 缓存空间
   private Map<String,T> cache =
       new ConcurrentHashMap<String,T>();
   
   // 命名为 getValue
   public T getValue(Object key) {
     return cache.get(key);
   }
 
   // 命名 addCache
   public void addOrUpdateCache(String key,T value) {
     cache.put(key, value);
   }
   
   // 命名 evictCache
   public void evictCache(String key) {// 根据 key 来删除缓存中的一条记录
     if(cache.containsKey(key)) {
       cache.remove(key);
     }
   }
   
   public void evictCache() {// 清空缓存中的所有记录
     cache.clear();
   }
 }
```
 
实际使用场景中，需要在Service层来对Account进行增删改查操作。下面将利用MyCacheManager缓存管理器来实现一个带缓存功能的AccountService：

```
package oldcache;
 
 import cacheOfAnno.Account;
 
 public class AccountService {
   private MyCacheManager<Account> cacheManager;
   
   public AccountService() {
     cacheManager = new MyCacheManager<Account>();// 构造一个缓存管理器
   }
   
   public Account getAccountByName(String acctName) {
     Account result = cacheManager.getValue(acctName);// 首先查询缓存
     if(result!=null) {
       System.out.println("get from cache..."+acctName);
       return result;// 如果在缓存中，则直接返回缓存的结果
     }
     result = getFromDB(acctName);// 否则到数据库中查询
     if(result!=null) {// 将数据库查询的结果更新到缓存中
       cacheManager.addOrUpdateCache(acctName, result);
     }
     return result;
   }
   
   public void reload() {
     cacheManager.evictCache();
   }
   
   private Account getFromDB(String acctName) {
     System.out.println("real querying db..."+acctName);
     return new Account(acctName);
   }
}
```
 
上述自定义的缓存方案，有一些特点：

1. 缓存代码和业务代码耦合度太高：如上面的例子，AccountService 中的 getAccountByName() 方法中有了太多缓存的逻辑，不便于维护和变更
1. 功能不丰富、不灵活：不支持按照某种条件的缓存，比如只有某种类型的账号才需要缓存，这种需求会导致代码的变更
1. 缓存的管理器与存储空间耦合度高：不能灵活的切换为第三方的缓存模块

简单来说，自定义缓存的代码：耦合度高、易用性较差、不够灵活。

## 2. Spring Cache 带来的便利

注意：Spring 3.1+ 开始支持Spring Cache功能，其所需的类都在 spring-context-*.jar 包中。
利用 Spring Cache，重新实现 AccountService：

```
package cacheOfAnno;
 
 import org.springframework.cache.annotation.CacheEvict;
 import org.springframework.cache.annotation.Cacheable;
 
 public class AccountService {
   @Cacheable(value="accountCache")// 使用了一个缓存名叫 accountCache
   public Account getAccountByName(String userName) {
     // 方法内部实现不考虑缓存逻辑，直接实现业务
     System.out.println("real query account."+userName);
     return getFromDB(userName);
   }
   
   private Account getFromDB(String acctName) {
     System.out.println("real querying db..."+acctName);
     return new Account(acctName);
   }
 }
```
 
 @Cacheable(value=”accountCache”)，这个注释的意思是：

1. 当调用这个方法的时候，会从命名为 accountCache 的缓存空间中查询
1. 如果缓存中没有，则执行实际的方法（即查询数据库），并将执行的结果存入缓存，否则返回缓存中的对象
1. 上述缓存中的 key 就是参数 userName，value 就是 Account 对象
1. “accountCache”缓存是在 spring*.xml 中定义的缓存空间名称

疑问：上述缓存未命中时，查询数据库，返回对象，并将对象存入缓存？还是先存入缓存，再返回对象？合理的方式，应先返回，再存入缓存。Re：具体看AOP时，Advice 切入的时机。

启用Spring Cache的配置文件 spring-cache.xml 如下：

```
<beans xmlns="http://www.springframework.org/schema/beans"
xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
  xmlns:cache="http://www.springframework.org/schema/cache"
   xmlns:p="http://www.springframework.org/schema/p"
  xsi:schemaLocation="http://www.springframework.org/schema/beans
  http://www.springframework.org/schema/beans/spring-beans.xsd
    http://www.springframework.org/schema/cache
    http://www.springframework.org/schema/cache/spring-cache.xsd">
    
  <!-- 开启缓存注解 -->
  <cache:annotation-driven cache-manager="cacheManager" />
 
  <bean id="accountServiceBean" class="cacheOfAnno.AccountService"/>
 
   <!-- generic cache manager -->
  <bean id="cacheManager"
  class="org.springframework.cache.support.SimpleCacheManager">
    <property name="caches">
      <set>
        <bean
          class="org.springframework.cache.concurrent.ConcurrentMapCacheFactoryBean"
          p:name="default" />
        
        <bean
          class="org.springframework.cache.concurrent.ConcurrentMapCacheFactoryBean"
          p:name="accountCache" />
      </set>
    </property>
  </bean> 
</beans>
```

关于上述Spring Cache相关的缓存配置文件，简要解释几点：

1. 增加 Spring Cache的命名空间
1. cache:annotation-driven，开启注解支持
1. SimpleCacheManager，担当缓存管理器
1. caches指定 2 个缓存存储空间：default、accountCache，都采用ConcurrentMapCacheFactoryBean

补充说明：

1. cache:annotation-driven，完整的写法：cache:annotation-drivern cache-manager="cacheManager" proxy-target-class="true"，其中cache-manager默认值为cacheManager，可以不写。
1. SimpleCacheManager内部Cache有一个缺省的实现，name="deafult"，是基于ConcurrentHashMap实现的一个缓存区域
 
写一个测试代码：

```
package cacheOfAnno;
 
 import org.springframework.context.ApplicationContext;
 import org.springframework.context.support.ClassPathXmlApplicationContext;
 
 public class Main {
   public static void main(String[] args) {
     ApplicationContext context = new ClassPathXmlApplicationContext(
        "spring-cache-anno.xml");// 加载 spring 配置文件
     
     AccountService s = (AccountService) context.getBean("accountServiceBean");
     // 第一次查询，应该走数据库
     System.out.print("first query...");
     s.getAccountByName("somebody");
     // 第二次查询，应该不查数据库，直接返回缓存的值
     System.out.print("second query...");
     s.getAccountByName("somebody");
     System.out.println();
   }
 }
  
// 测试结果：
 first query...real query account.somebody// 第一次查询
 real querying db...somebody// 对数据库进行了查询
 second query...// 第二次查询，没有打印数据库查询日志，直接返回了缓存中的结果
```

使用Spring Cache的好处：

1. 缓存代码与业务代码，松耦合：只需在方法上添加注解即可
1. 易用、灵活：支持增加缓存、按条件增加缓存、清空缓存

下文将简要总结一下Spring Cache提供的几个注解：Cacheable、CachePut、CacheEvict （疑问：没有Caching？）

### 2.1. Cacheable

![](/images/spring-framework/cacheable.png)
 
### 2.2. CachePut

![](/images/spring-framework/cacheput.png)
 
### 2.3. CacheEvict

![](/images/spring-framework/cacheevict.png)
 
### 2.4. Caching

![](/images/spring-framework/caching.png)
 
 
## 3. 内部机制

Spring Cache 就是基于 AOP 实现的，在方法的调用之前、之后，分别获取方法的请求参数和返回值，进而实现缓存逻辑。

![](/images/spring-framework/plain-obj.jpg)

使用AOP机制之后，通过 POJO 对象的代理对象来进行方法调用，在调用前后，都可以插入缓存代码：

![](/images/spring-framework/plain-obj-with-proxy.jpg)

疑问：上述代理对象种，可以在 return 之后，再设置缓存吗？ Re：不可以，因为是同步的，一定要在代理对象内方法执行 return 之前，设置缓存。

## 4. 扩展性

Spring Cache 是基于注释（annotation）的缓存（cache）技术，它本质上不是一个具体的缓存实现方案（例如 EHCache 或者 OSCache），而是一个对缓存使用的抽象。Spring Cache 作为缓存管理的抽象层，具有很好的灵活性和可扩展性。

基于Spring Cache，如何定制自己的缓存管理方案？

* CacheManager 接口的实现：告诉 Spring 有哪些 Cache 实例，Spring 会根据 Cache 的名字查找 Cache 的实例 
* Cache 接口的实现：Cache 接口负责实际的缓存逻辑，例如增加键值对、存储、查询和清空等；利用 Cache 接口，可以对接任何第三方的缓存系统，例如 EHCache、OSCache，甚至一些内存数据库例如 memcache 或者 h2db

NOTE：Spring Cache 提供了CompositeCacheManager用于组合CacheManager，即可以从多个CacheManager中轮询得到相应的Cache，如

```
<bean id="cacheManager" class="org.springframework.cache.support.CompositeCacheManager"> 
    <property name="cacheManagers"> 
        <list> 
            <ref bean="ehcacheManager"/> 
            <ref bean="jcacheManager"/> 
        </list> 
    </property> 
    <property name="fallbackToNoOpCache" value="true"/> 
</bean>
```

当调用cacheManager.getCache(cacheName) 时，会先从第一个cacheManager中查找有没有cacheName的cache，如果没有接着查找第二个，如果最后找不到，因为fallbackToNoOpCache=true，那么将返回一个NOP的Cache否则返回null。

## 5. 使用注意

几点：

* Spring AOP的内部调用问题：Spring Cache 利用 AOP机制实现缓存管理：通过动态生成的proxy对象进行处理，如果对象的引用是通过this的内部引用，则proxy失效，因此 Spring Cache失效
* 非public方法的问题：和Spring AOP的内部调用问题类似，如果一定要在非 public 方法上实现基于注解的缓存，必须基于AspectJ的AOP机制
* CacheEvict的可靠性问题：@CacheEvict有一个属性 beforeInvocation，默认为false，即，仅当方法成功时，才会清理缓存，如果方法内部抛出异常，则放弃清理缓存

## 6. 其他问题

几点：

* 缓存 null 对象：查询获得一个null对象，也是需要进行缓存的，否则，每次查询都要访问数据库，增加数据库的压力。
* 避免缓存对象的集合
	* 缓存对象集合，带来了额外的数据冗余，在保证数据一致性的时候增加了复杂度；
	* 缓存ID->单个对象，能够更好的复用缓存，节省cache server的内存占用
	* 查询ID列表 -> 通过缓存逐个获取单个对象， 先取ID集合再根据ID取对象 产生了多次IO操作
* 主动失效 vs. 被动失效：
	* 主动失效：不设置缓存失效时间，被缓存的数据发生改变的时候，主动清除缓存数据
	* 被动失效：设置较短的缓存失效时间，在数据发生改变时不去刷新缓存，需要容忍一段时间的数据不一致
	* 建议：由于被动失效会产生潜在bug，因此推荐采用主动失效
* 持久化 vs 缓存：一定先持久化，再添加缓存
* 新增缓存的入口：在查询时，添加缓存
* 清除缓存的入口：在更新、删除时，清除缓存
* Caching注解
* 利用 Spring Cache 如何设置缓存失效时间？Re：通常跟具体的缓存实现方案相关，例如 Redis 作为缓存时，通过调用命令 Expire 命令设置 key 的失效时间。
* SpEL（Spring Expression Language）：简要梳理

备注：简单补充一点 Redis 种过期key 的清除策略：

1. 惰性删除过期 key
1. 定期删除过期 key
1. 定时删除过期 key （Redis 中未使用）
 
 
缓存Null对象：

查询获得一个null对象，也是需要进行缓存的，否则，每次查询都要访问数据库，增加数据库的压力。Spring Cache已经实现了这一点，下面是Cache接口中 get(Object key) 的描述：

```
/**
  * Return the value to which this cache maps the specified key.
  * <p>Returns {@code null} if the cache contains no mapping for this key;
  * otherwise, the cached value (which may be {@code null} itself) will
  * be returned in a {@link ValueWrapper}.
  * @param key the key whose associated value is to be returned
  * @return the value to which this cache maps the specified key,
  * contained within a {@link ValueWrapper} which may also hold
  * a cached {@code null} value. A straight {@code null} being
  * returned means that the cache contains no mapping for this key.
  */
 ValueWrapper get(Object key);
```

NOTE：查询获得 null 对象，表示数据库中没有找到符合条件的记录。


## 7. 参考来源

1. [Spring Framework 4.1.x Reference](http://docs.spring.io/spring/docs/4.1.0.RELEASE/spring-framework-reference/htmlsingle/#cache-annotations-caching)
1. [Spring Framework 4.2.x Reference](http://docs.spring.io/spring/docs/current/spring-framework-reference/htmlsingle/) ：特别说明，Spring 4.2.x 中，Spring Cache的注解，属性值有变化
1. [注释驱动的 Spring cache 缓存介绍](https://www.ibm.com/developerworks/cn/opensource/os-cn-spring-cache/#ibm-pcon)




















[NingG]:    http://ningg.github.com  "NingG"










