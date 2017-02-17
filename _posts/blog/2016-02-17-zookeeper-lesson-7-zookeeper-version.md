---
layout: post
title: ZooKeeper 技术内幕：版本
description: ZK 中监视点的作用？常见的问题？
published: true
category: zookeeper
---

## 背景

ZK 中，ZNode 都有一个 `版本号`，

1. 版本号，都有哪些？
2. 版本号，如何修改？
3. 版本号，什么作用？

## 版本号

### 版本号，都有哪些？

每个 ZNode 都有 3 类版本信息：

* version：数据内容，版本
* cversion：子节点列表，版本
* aversion：ACL 权限，版本

![](/images/zookeeper/zk-znode-version.png)

特别说明：

1. ZK 中`版本`就是`修改次数`：即使修改前后，内容不变，但`版本`仍会`+1`：`version=0` 表示节点创建之后，修改的次数为 0。
2. `cversion` 子节点列表：ZNode，其中 cversion 只会感知`子节点列表`变更信息，新增子节点、删除子节点，而不会感知子节点数据内容的变更。
3. 


### 版本号，如何修改？

下述情况，版本号会自动更新：

1. 版本自增：每次变化，版本就加一；


### 版本号，什么作用？

目标：解决 ZNode 的`并发更新`问题，实现 CAS（Compare And Switch）乐观锁。

补充：乐观锁事务，分为 3 个典型阶段：

1. 数据读取
2. 写入校验
3. 数据写入

## 参考资料

* [从Paxos到Zookeeper分布式一致性原理与实践] 第7章 7.1.3
* [ZooKeeper-Distributed Process Coordination] 第2章 2.1.4








[NingG]:    http://ningg.github.com  "NingG"
[从Paxos到Zookeeper分布式一致性原理与实践]:	https://book.douban.com/subject/26292004/
[ZooKeeper-Distributed Process Coordination]:    http://shop.oreilly.com/product/0636920028901.do










