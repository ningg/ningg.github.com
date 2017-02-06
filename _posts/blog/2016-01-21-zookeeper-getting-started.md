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

**思考**：启动 ZooKeeper 服务节点时，是否可以配置`conf` 文件夹的位置？

可以直接指定 `zoo.cfg` 配置文件，即可启动，具体命令：

````
[localhost:zookeeper-3.4.9 root]$bin/zkServer.sh start zoo_2181.cfg
ZooKeeper JMX enabled by default
Using config: /Users/guoning/ningg/projects/zookeeper/zookeeper-3.4.9/bin/../conf/zoo_2181.cfg
````

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


### 安装和启动

ZooKeeper 的**单机模式**和**集群模式**之前配置文件的差异不大，下面是**集群模式**中，单个 ZooKeeper 节点的典型配置：

````
tickTime=2000
dataDir=/tmp/zookeeper
clientPort=2181
# 多少个 tickTime 时间内，必须连接到 Leader
initLimit=5
# 多少个 tickTime 时间内，必须跟 Leader 同步一次
syncLimit=2
server.1=zoo1:2888:3888
server.2=zoo2:2888:3888
server.3=zoo3:2888:3888
````

逐个启动： `bin/zkServer.sh start zoo_2181.cfg`

### 一台服务器上 ZooKeeper 集群搭建

在一台物理服务器上，搭建 4 节点的 ZooKeeper 集群，基本步骤：

1. 创建 4 个配置文件
2. 每个配置文件，配置不同的 `clientPort` 和 `dataDir` 
3. 每个 `dataDir` 对应的目录下，都创建一个 `myid` 文件
4. `myid`文件中，只填写一个（1～255）的数字，对应配置文件中的`server.[myid]`，以标识当前服务节点的配置。

具体我实验过程的配置文件如下。

#### zoo.cfg 配置文件

`conf/zoo_2181.cfg` 文件：

````
# The number of milliseconds of each tick
tickTime=2000
# The number of ticks that the initial
# synchronization phase can take
initLimit=10
# The number of ticks that can pass between
# sending a request and getting an acknowledgement
syncLimit=5
# the directory where the snapshot is stored.
# do not use /tmp for storage, /tmp here is just
# example sakes.
dataDir=/tmp/zookeeper/2181
# the port at which the clients will connect
clientPort=2181
# the maximum number of client connections.
# increase this if you need to handle more clients
#maxClientCnxns=60
#
# Be sure to read the maintenance section of the
# administrator guide before turning on autopurge.
#
# http://zookeeper.apache.org/doc/current/zookeeperAdmin.html#sc_maintenance
#
# The number of snapshots to retain in dataDir
#autopurge.snapRetainCount=3
# Purge task interval in hours
# Set to "0" to disable auto purge feature
#autopurge.purgeInterval=1
server.1=localhost:2881:3881
server.2=localhost:2882:3882
server.3=localhost:2883:3883
server.4=localhost:2884:3884
````

`conf/zoo_2182.cfg` 文件：

````
# The number of milliseconds of each tick
tickTime=2000
# The number of ticks that the initial
# synchronization phase can take
initLimit=10
# The number of ticks that can pass between
# sending a request and getting an acknowledgement
syncLimit=5
# the directory where the snapshot is stored.
# do not use /tmp for storage, /tmp here is just
# example sakes.
dataDir=/tmp/zookeeper/2182
# the port at which the clients will connect
clientPort=2182
# the maximum number of client connections.
# increase this if you need to handle more clients
#maxClientCnxns=60
#
# Be sure to read the maintenance section of the
# administrator guide before turning on autopurge.
#
# http://zookeeper.apache.org/doc/current/zookeeperAdmin.html#sc_maintenance
#
# The number of snapshots to retain in dataDir
#autopurge.snapRetainCount=3
# Purge task interval in hours
# Set to "0" to disable auto purge feature
#autopurge.purgeInterval=1
server.1=localhost:2881:3881
server.2=localhost:2882:3882
server.3=localhost:2883:3883
server.4=localhost:2884:3884
````

`conf/zoo_2183.cfg` 文件：

````
# The number of milliseconds of each tick
tickTime=2000
# The number of ticks that the initial
# synchronization phase can take
initLimit=10
# The number of ticks that can pass between
# sending a request and getting an acknowledgement
syncLimit=5
# the directory where the snapshot is stored.
# do not use /tmp for storage, /tmp here is just
# example sakes.
dataDir=/tmp/zookeeper/2183
# the port at which the clients will connect
clientPort=2183
# the maximum number of client connections.
# increase this if you need to handle more clients
#maxClientCnxns=60
#
# Be sure to read the maintenance section of the
# administrator guide before turning on autopurge.
#
# http://zookeeper.apache.org/doc/current/zookeeperAdmin.html#sc_maintenance
#
# The number of snapshots to retain in dataDir
#autopurge.snapRetainCount=3
# Purge task interval in hours
# Set to "0" to disable auto purge feature
#autopurge.purgeInterval=1
server.1=localhost:2881:3881
server.2=localhost:2882:3882
server.3=localhost:2883:3883
server.4=localhost:2884:3884
````


`conf/zoo_2184.cfg` 文件：

````bash
# The number of milliseconds of each tick
tickTime=2000
# The number of ticks that the initial
# synchronization phase can take
initLimit=10
# The number of ticks that can pass between
# sending a request and getting an acknowledgement
syncLimit=5
# the directory where the snapshot is stored.
# do not use /tmp for storage, /tmp here is just
# example sakes.
dataDir=/tmp/zookeeper/2184
# the port at which the clients will connect
clientPort=2184
# the maximum number of client connections.
# increase this if you need to handle more clients
#maxClientCnxns=60
#
# Be sure to read the maintenance section of the
# administrator guide before turning on autopurge.
#
# http://zookeeper.apache.org/doc/current/zookeeperAdmin.html#sc_maintenance
#
# The number of snapshots to retain in dataDir
#autopurge.snapRetainCount=3
# Purge task interval in hours
# Set to "0" to disable auto purge feature
#autopurge.purgeInterval=1

server.1=localhost:2881:3881
server.2=localhost:2882:3882
server.3=localhost:2883:3883
server.4=localhost:2884:3884
````

#### dataDir 目录下，myid 文件

对应的 dataDir 目录下，都创建一个名为 `myid` 的文件，其中，内容分别为其对应的 `server.[myid]`

* `/tmp/zookeeper/2181/myid`：内容 `1`
* `/tmp/zookeeper/2182/myid`：内容 `2`
* `/tmp/zookeeper/2183/myid`：内容 `3`
* `/tmp/zookeeper/2184/myid`：内容 `4`

#### 自定义启动\停止脚本

为了方便同时启动、关闭 zookeeper 集群，编写 2 个脚本：

启动脚本 `start_zk_cluster.sh`：

````
bin/zkServer.sh start zoo_2181.cfg
bin/zkServer.sh start zoo_2182.cfg
bin/zkServer.sh start zoo_2183.cfg
bin/zkServer.sh start zoo_2184.cfg
````

关闭脚本 `stop_zk_cluster.sh`：

````
bin/zkServer.sh stop zoo_2181.cfg
bin/zkServer.sh stop zoo_2182.cfg
bin/zkServer.sh stop zoo_2183.cfg
bin/zkServer.sh stop zoo_2184.cfg
````

#### 通过 client 验证 ZK 集群

通过命令方式，分别连接到 ZK 集群的不同节点：

````
// 连接到 2181 端口 
bin/zkCli.sh -server localhost:2181
// 连接到 2182 端口
bin/zkCli.sh -server localhost:2182

````

通过一个 cient 链接创建 ZNode，通过另一个 client 链接查询新建的 ZNode。




[Getting Started]:		https://zookeeper.apache.org/doc/trunk/zookeeperStarted.html

[ZooKeeper-Distributed Process Coordination]:    http://shop.oreilly.com/product/0636920028901.do
[从Paxos到Zookeeper分布式一致性原理与实践]:	    https://book.douban.com/subject/26292004/

[JLine]:			https://github.com/jline
[ZooKeeper]:		https://zookeeper.apache.org/    "ZooKeeper"
[NingG]:    		http://ningg.github.com    "NingG"










