---
layout: post
title: ZooKeeper 技术内幕：ACL 权限访问控制
description: ZooKeeper 上如何控制权限？权限控制的粒度？
published: true
category: zookeeper
---


## 背景

ZK 类似文件系统，Client 可以在上面创建节点、更新节点、删除节点；如何保证 ZK 上数据安全呢？

1. ZK 是否有权限控制？
2. 权限控制，是基于 user？还是基于 data？
3. 权限控制的实现细节
4. 是否区分：读权限和写权限

## ACL：ZK 中权限控制

权限控制，要解决的核心问题：

> **谁**对**什么**，有**哪些权限**

ACL 权限控制，使用：`schema:id:permission` 来标识，主要涵盖 3 个方面：

1. 权限模式（Schema）：鉴权的策略
2. 授权对象（ID）
3. 权限（Permission）

### 权限模式 Schema

常用的权限模式如下：

#### IP

IP： 使用 IP 识别用户，可以精确匹配 IP，也可以匹配到 IP 段

* ip:168.192.1.23 ：精确匹配到 IP
* ip:168.192.0.1/24：模糊匹配 IP 段，168.192.0.*

Note： IP 地址是 32 位，十进制表示 4 个十进制；IP 段，表示前面多少位相同。

#### Digest

Digest，类似 `username:password`，用户名和密码。

#### World

没有密码，对所有用户都开放权限。可以看作特殊的 Digest 模式。

#### Super

只有超级用户，才有权限，也可看作特殊的 Digest 模式。

### 授权对象 ID

授权对象是指，权限赋予的用户或者一个实体，例如：IP 地址或者机器。

授权模式 schema 与 授权对象 ID 之间关系：

![](/images/zookeeper/zk-acl-schema-with-id.png)

### 权限 Permission

ZooKeeper 中数据节点的权限分为 5 类：

* Create（C）：创建子节点
* Delete（D）：删除子节点
* Read（R）：读取当前节点，以及子节点列表
* Write（W）：更新当前节点
* Admin（A）：当前节点的 ACL 管理

## ZK 中 ACL 特性

ZK 中 ACL 特性：

1. 无继承性：子节点，**不会继承**父节点的 ACL；
2. Client 仍可以访问子节点，即使不可以访问父节点；

## ACL：实践

设置 ACL:

1. 创建节点时，设置 ACL：`create [-s] [-e] path data acl`
2. 单独设置 ACL：`setAcl path acl`

````
// 设置 ACL：创建节点时
[zk: localhost:2181(CONNECTED) 27] create -e /zookeeper-e ephemeral digest:foo:haha:cdrwa
Created /zookeeper-e
// 查看数据：无权限
[zk: localhost:2181(CONNECTED) 28] get /zookeeper-e
Authentication is not valid : /zookeeper-e
// 查看节点 ACL 
[zk: localhost:2181(CONNECTED) 29] getAcl /zookeeper-e
'digest,'foo:haha
: cdrwa

````

Note: 

>* ZK 中，为节点设置 ACL 权限之后，不能修改 ACL 权限；
>* 为 ZNode 设置 ACL 权限的 client，能够删除 ZNode，查看节点的 ACL;


实践建议：

1. 如果网络不可信，则：digest 模式、ip 模式，都不可信；
2. ZK 中的 SASL 模式，解决网络不可信问题；

SASL(Simple Authentication and Security Layer) 简单认证与安全层。 SASL 将底层鉴权系统抽象为一个框架，因此应用程序可以使用 SASL，支持多种协议。ZK 中，常常使用 Keberos 协议。


## 附录

### UGO 权限控制

UGO，（`User`，`Group`，`Others`），是（`用户`，`组`，`权限`）的简称。

Linux\Unix **文件系统**，采用 UGO 的权限控制，针对`文件/文件夹`的`创建者`，创建者所在`组`以及`其他用户`，分别分配不同的权限。

UGO 的权限控制，是基于用户的，跟系统的用户体系严格绑定。

### ACL 权限控制

ACL，Access Control List，访问权限列表。

从 data 角度出发，赋予权限。

Note：

> 目前绝大部分 Unix 系统都支持了 ACL，Linux 内核从 2.6+ 也开始支持 ACL。

### RBAC 权限控制

RBAC，(Role-Based Access Control )基于角色的访问控制。

* 一个用户拥有若干角色，每一个角色拥有若干权限。
* 构成 **用户-角色-权限** 的授权模型。

在这种模型中，用户与角色之间，角色与权限之间，一般者是多对多的关系。


## 参考资料

* [从Paxos到Zookeeper分布式一致性原理与实践] 第7章 7.1.5
* [ZooKeeper-Distributed Process Coordination] 第6章 6.1








































[NingG]:    http://ningg.github.com  "NingG"
[从Paxos到Zookeeper分布式一致性原理与实践]:	https://book.douban.com/subject/26292004/
[ZooKeeper-Distributed Process Coordination]:    http://shop.oreilly.com/product/0636920028901.do










