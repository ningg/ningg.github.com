---
layout: post
title: ZooKeeper 技术内幕：配置和运维
description: 常用的配置？监控？运维？
published: true
category: zookeeper
---

## 背景

前面一系列的 ZK 技术内幕分析，已经掌握了 ZK 的核心原理，现在的问题是：

1. 如何使用 ZK 呢？ZK 常用的配置有哪些？
2. ZK 如何运维？监控？

## ZK 的配置

要在生产环境中运行 ZK 集群，仅仅启动 ZK 是不够的，需要对 ZK 的每一个配置参数进行详细的讲解。

### 基本配置

要正常启动 ZK 节点，就必须配置的参数：

![](/images/zookeeper/zk-devops-config-basic.png)

3 个参数，都不支持`系统属性方式配置`：

1. `系统属性方式`，即，启动命令中添加 `-DclientPort=2181` 等
2. `clientPort`：
	* 无默认值，必须配置，建议为 `2181`
	* 作用：对外的服务连接接口
3. `dataDir`：
	* 无默认值，必须配置
	* 作用：存储快照
	* 备注：默认 `dataLogDir` 为 `dataDir`，用于存储事务日志
4. `tickTime`：
	* 有默认值，默认 `3000` ms
	* 作用：标识 ZK 中最小的时间粒度
	* 备注：ZK 中很多运行的时间间隔都是使用 tickTime 倍数表示，例如 Session 的超时时间，默认 `2*tickTime`

### 高级配置

更多高级的配置参数，参考：官网文档[ZooKeeper Administrator's Guide-A Guide to Deployment and Administration]

## ZK 监控

官网有 2 种方式，可以查看 ZK 集群的运行状态：

1. 四字命令：stat、conf、mntr 等
2. 开启远程 JMX：Java 管理扩展接口，然后 JConsole 通过 JMX 接口连接，即可查看 ZK 运行状态

对于 ZK 集成监控，有一些开源实现，可以借鉴，比如：阿里的 [TaoKeeper]

## 高可用集群

主要涉及：容灾和扩容

### 容灾

服务器节点的奇偶设置。

1. 过半策略：6 个服务节点，要求故障节点数量 `<=2`，5 个服务节点，要求故障节点数量 `<=2`
2. 偶数个服务节点，并没有在容灾上，有所改善。

ZK 通过使用 `过半策略` 已经很好的解决了 `单点问题`。

增加使用`多机房`异地部署，避免因为机房断电引发的问题。


### 扩容 & 缩容

ZK 在扩容、缩容方面， 2 类策略可选：

1. 整体重启：
	* 先终止集群
	* 更新 ZK 配置
	* 再次启动
2. 逐台重启：每次重启一台，并不会终止服务。

另外：zk 3.5.0+ 开始支持动态配置，能够动态更新配置文件，实现扩容。 reconfig，重配置。


## 日常运维

ZK 的日常运维，主要是：

1. 数据和日志的管理：磁盘文件清理
2. 磁盘性能：因为每次事务运行，都需要写入事务日志，加上过半策略，会有多次的 磁盘 IO，因此 磁盘 IO 的性能，直接影响事务执行速度

ZK 的发行版本中，提供了事务日志和快照清理的脚本：`zkCleanup.sh`。

ZK 也支持配置方式开启自动清理机制。





## 参考资料

* [从Paxos到Zookeeper分布式一致性原理与实践] 第8章








[NingG]:    http://ningg.github.com  "NingG"
[从Paxos到Zookeeper分布式一致性原理与实践]:	https://book.douban.com/subject/26292004/
[ZooKeeper-Distributed Process Coordination]:    http://shop.oreilly.com/product/0636920028901.do
[ZooKeeper Administrator's Guide-A Guide to Deployment and Administration]:	http://zookeeper.apache.org/doc/trunk/zookeeperAdmin.html
[TaoKeeper]:	https://github.com/alibaba/taokeeper	"ZooKeeper-Monitor"








