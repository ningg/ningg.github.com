---
layout: post
title: ZooKeeper 技术内幕：系统模型
description: 内部包含哪些组件和元素？他们的作用？
published: true
category: zookeeper
---

## 概要

几个问题：

1. ZK 中数据是如何存储的？最小存储单元？
2. 每个存储单元，内部存储了哪些信息？
3. 每个节点，有版本的概念吗？版本用来解决什么问题？
4. Watcher 机制，如何实现的？
5. 权限 ACL 如何实现？有什么作用？

具体来说：

1. 数据模型：由节点构成
2. 节点特性：节点内部存储的信息
3. 版本：存储在 Session 和 节点上？解决什么问题？
4. 权限控制：ACL？控制 Session 的权限？

## 数据模型

### 数据节点

ZooKeeper 上记录信息，都是以「数据节点」（ZNode）为最小单元存储的：

1. ZNode 是数据存储最小单元
2. ZNode 既可以存储数据，也可以挂载子节点，形成「节点树」结构

![](/images/zookeeper/znode-tree.png)

每个 ZNode 都有生命周期，根据生命周期不同，ZNode 可以划分为：

* 持久节点（Persistent）：创建之后，需要**主动**删除
* 临时节点（Ephemeral）：跟客户端的 Session 生命周期一致；Client Session 失效，则临时节点会自动清除；Session 失效，并不是指 TCP 连接断开；临时节点，不能包含子节点，只能为叶子节点。
* 持久顺序节点（Persistent Sequential）
* 临时顺序节点（Ephemeral Sequential）

特别说明：

* `顺序节点`，父节点会维护第一级子节点的创建顺序
* 顺序节点实现方式：父节点自动为**子节点名**添加**数字后缀**，作为新的、完整的名字
* 同一级顺序节点的个数，有上限：整型的最大值。

### 事务

事务：

1. ZK中，事务操作，是指：能够`改变` ZooKeeper `服务器状态`的操作
2. 事务操作，包含：
	* 创建 ZNode
	* 删除 ZNode
	* 修改 ZNode 上的数据
	* Session 的创建
	* Session 的失效
3. ZK中，每个事务请求，ZK 都会为其分配一个**全局唯一**的事务ID，ZXID，64位数字。
4. 通过 ZXID，表示事务的全局顺序。

### 会话

客户端会话（Session）：ZK Client 与 ZK Server 之间，创建并保持 TCP 连接，即创建了一个 Session。 Session 跟下面几点，息息相关：

1. 临时节点的生命周期
2. 客户端请求的顺序执行
3. Watcher 通知机制

Session 在整个运行过程中，会在不同状态之间切换，即：Session 有一个`状态转移图`。
















































[NingG]:    http://ningg.github.com  "NingG"










