---
layout: post
title: ZooKeeper 初探：安装、使用
description: 安装 ZooKeeper ，初步尝试使用，体验一下手感
published: true
category: zookeeper
---


## 背景

现在使用的很多基础组件，都用 ZK 进行分布式协作，之前看了很多 ZK 的内部实现细节，总感觉不直观，准备按照[官网文档][ZooKeeper]，本地安装、使用一下，试试手感。


## 整体思路

本文将按照下面思路进行：

1. 到[ZooKeeper官网][ZooKeeper] 看一下入门文档
2. 下载 ZooKeeper，并根据入门文档，操作一遍
3. 对比现有的 ZooKeeper 书籍，看看是否有遗漏的操作，整理自己的想法


### 资料收集

到[ZooKeeper官网][ZooKeeper]浏览了一下，当前 ZK 版本 `3.4`，资料有：

1. [Getting Started] - a tutorial-style guide for developers to install, run, and program to ZooKeeper
2. [Download](https://zookeeper.apache.org/releases.html) ZooKeeper from the release page.

再找一下 ZooKeeper 相关的书籍，买买买：

1. [ZooKeeper-Distributed Process Coordination]
2. [从Paxos到Zookeeper分布式一致性原理与实践]

### 安装&启动 Server

从官网下载后，解压即可使用，因为是 jar 包，不用专门安装，只要有 java 运行环境即可。

启动步骤：

1. `conf` 文件夹下，配置 `zoo.cfg` 文件
2. `bin/zkServer.sh start` 启动

ZK 单机模式下，`zoo.cfg` 文件配置样本：

```
tickTime=2000
dataDir=/var/lib/zookeeper
clientPort=2181
```

更多配置参数细节： [Getting Started]

### 启动 Client

启动步骤：

1. ZK 目录下，输入命令：`bin/zkCli.sh -server localhost:2181` 
2. 正常启动后，会创建 Session，并启用 JLine，可通过 console，直接跟 Server 交互

**补充信息**： JLine，是处理 console input 的 Java jar 包，更多信息参考：[JLine]

JLine 下，常用命令：

```bash
# 获取帮助
help

# 查看子节点
ls /

# 查看节点信息
get /

# 创建节点，填充信息
create /zk_test data

# 更新节点数据， 修改信息
set /zk_test new_date

# 删除节点
delete /zk_test

```

更多命令：

```
[zk: localhost:2181(CONNECTED) 7] help
ZooKeeper -server host:port cmd args
	stat path [watch]
	set path data [version]
	ls path [watch]
	delquota [-n|-b] path
	ls2 path [watch]
	setAcl path acl
	setquota -n|-b val path
	history
	redo cmdno
	printwatches on|off
	delete path [version]
	sync path
	listquota path
	rmr path
	get path [watch]
	create [-s] [-e] path data acl
	addauth scheme auth
	quit
	getAcl path
	close
	connect host:port
```


## 补充：集群模式

上面演示的安装、启动，都是**单机模式**，应用的开发、测试过程中，常采用。实际生产环境，更多采用 ZK 的**集群模式**，更多细节参考：[Getting Started]。




[Getting Started]:		https://zookeeper.apache.org/doc/trunk/zookeeperStarted.html

[ZooKeeper-Distributed Process Coordination]:    http://shop.oreilly.com/product/0636920028901.do
[从Paxos到Zookeeper分布式一致性原理与实践]:	    https://book.douban.com/subject/26292004/

[JLine]:			https://github.com/jline
[ZooKeeper]:		https://zookeeper.apache.org/    "ZooKeeper"
[NingG]:    		http://ningg.github.com    "NingG"










