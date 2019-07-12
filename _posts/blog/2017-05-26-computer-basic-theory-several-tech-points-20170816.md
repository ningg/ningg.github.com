---
layout: post
title: 基础原理系列：几个技术问题汇总（1）
description: MySQL 的主从复制、Spring 事务的写法、设计模式、领域驱动、Nginx 网关的高可用
published: true
category: 基础原理
---

## 0.概要

整理一些典型问题。


## 1.0526


参阅记录：personal 中信息。（更新：20190508）

### 1.1. MySQL 的主从结构，数据复制

MySQL ，M-S 结构中，默认是：`异步`、`单线程`的结构

**主从复制**：异步复制、半同步复制、全同步复制：

* **异步复制**：MySQL 默认「**异步复制**」，具体参考示意图。
* **半同步复制**：在 `MySQL 5.5+`：支持「**半同步复制**」，隐患： Slave 升级为 master 时，client 可能重复提交事务
* **全同步复制**：原生 MySQL 不支持 Master-Slave 之间「**全同步复制**」

**半同步复制**：单独说明一下

* **MySQL 5.5+**：支持「**半同步复制**」，具体的隐患，Master 收到 Slave 确认信息后，在返回给 Client 之前，Master 宕机，Slave 升级为 Master 后，Client 会再次提交事务。
* **MySQL 5.7+**：升级版的「**半同步复制**」，拆分为 `2PC`，两阶段提交
	* 分发事务：先把事务分发到 Slave，然后，收到 Slave 的 Ack（第一阶段）
	* 确认提交：然后，Master 上，再执行 commit（第二阶段）
	* 返回响应：之后，Master 向 Client 返回 Ack 确认信息


**异步复制**：

![](/images/computer-basic-theory/mysql-sync-async.png)


**半同步复制**：改进版本 `2PC`（两阶段提交）

![](/images/computer-basic-theory/mysql-sync-semi-ync.png)


**参考资料**：

* [MySQL 最佳实践：常见问题汇总(2)](https://ningg.top/mysql-best-practice-tips-collection-2/)
* [MySQL Replication 主从复制全方位解决方案](https://www.cnblogs.com/clsn/p/8150036.html)
* [MySQL 5.7半同步复制技术](https://www.jianshu.com/p/5ef1565738ab)


### 1.2.Spring 事务，加在实现类 or 加在接口？

关于 Spring 事务：`@Transactional`

1. **Transactional 注解**：可以被应用于「接口」和「接口方法」、「类」和「类的 public 方法」上。
1. **动态代理机制选择**：“proxy-target-class” 属性值来控制是基于接口的还是基于类的代理被创建。 <tx:annotation-driven transaction-manager=“transactionManager” proxy-target-class=“true”/> 注意：proxy-target-class属性值决定是基于接口的还是基于类的代理被创建。
	1. 若proxy-target-class=`true`，「基于类」的动态代理生效（这时需要cglib库）。
	1. 若proxy-target-class=`false`，或者省略，「基于接口」的代理（JDK 代理）。
1. **兼容性**：注解写到「接口方法」上，如果使用 cglib代理，则，「注解」失效，为了「保持兼容注解」最好都写到「实现类」上。
1. **Spring团队建议**：在具体的类（或类的方法）上使用 @Transactional 注解，而不要使用在类所要实现的任何接口上。在接口上使用 @Transactional 注解，只能当你设置了基于接口的代理时它才生效。因为注解是 不能继承的，这就意味着如果正在使用基于类的代理时，那么事务的设置将不能被基于类的代理所识别，而且对象也将不会被事务代理所包装。
1. @Transactional 的事务开启 ，或者是基于接口的 或者是基于类的代理被创建。所以在同一个类中一个方法调用另一个方法有事务的方法，事务是不会起作用的。 原因：（这也是为什么在项目中有些@Async并没有异步执行） spring 在扫描bean的时候会扫描方法上是否包含@Transactional注解，如果包含，spring会为这个bean动态地生成一个子类（即代理类，proxy），代理类是继承原来那个bean的。此时，当这个有注解的方法被调用的时候，实际上是由代理类来调用的，代理类在调用之前就会启动transaction。然而，如果这个有注解的方法是被同一个类中的其他方法调用的，那么该方法的调用并没有通过代理类，而是直接通过原来的那个bean，所以就不会启动transaction，我们看到的现象就是@Transactional注解无效。

更多细节，参考：[http://mojito515.github.io/blog/2016/08/31/transactionalinspring/](http://mojito515.github.io/blog/2016/08/31/transactionalinspring/)


### 1.3.设计模式

关于设计模式，几个核心问题：

1. 有哪些？
1. 分为几类？

设计模式：整体分为 3 类

1. **创建型**：封装了**创建对象**的过程，被调用方，只需要关注如何使用对象
	1. 工厂模式
	1. 原型模式
	1. 单例模式
1. **结构型**：对象的**组成**，以及**对象间**的**依赖关系**
	1. 扩展性
		1. 外观模式
		1. 组成模式
		1. 代理模式
		1. 装饰模式
	1. 封装：
		1. 适配器模式
		1. 桥接模式
1. **行为型**：**对象的行为**，涉及到算法和**对象间职责的分配**，行为模式描述了对象和类的模式
	1. 模板方法模式（Template Method）
	1. 观察者模式（Observer）
	1. 状态模式（State）
	1. 策略模式（Strategy）
	1. 职责链模式（Chain of Responsibility）
	1. 命令模式（Command）
	1. 访问者模式（Visitor）
	1. 调停者模式（Mediator）
	1. 备忘录模式（Memento）
	1. 迭代器模式（Iterator）
	1. 解释器模式（Interpreter）

更多细节，参考：

* [设计模式分类（创建型模式、结构型模式、行为模式）](https://github.com/jiayisheji/blog/issues/2)
* [设计模式学习笔记（总结篇：模式分类）](https://www.cnblogs.com/liuzhen1995/p/6047932.html)



### 1.4.领域模型设计（DDD）

关于领域模型驱动设计，有没有深刻的理解？

更多细节，参考：

* [https://www.zhihu.com/question/25089273](https://www.zhihu.com/question/25089273)

### 1.5.Nginx 网关，如何实现高可用？

Nginx 网关的高可用：`Keepalived` + `VIP` 方案，基于虚拟路由冗余协议实现

* 多个冗余 Nginx：配置多个 Nginx 冗余备份
* 只有一个 Master 角色
* 对外统一的 VIP：虚拟 IP 地址
* **自动推举**：Master 正常工作时，会周期发送组播的心跳，Backup 机器，如果收不到「心跳」，就会认为 Master 宕机，自动推举出一个新的 Master

更多细节，参考：

* [https://blog.csdn.net/a772304419/article/details/79438370](https://blog.csdn.net/a772304419/article/details/79438370)
















[NingG]:    http://ningg.github.com  "NingG"
[LRU算法]:		https://blog.csdn.net/wzy_1988/article/details/33444991









