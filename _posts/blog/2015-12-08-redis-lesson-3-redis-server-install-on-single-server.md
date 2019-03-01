---
layout: post
title: Redis 设计与实现：单服务器建 Redis 集群
description: 实际操作，联系 Redis 的常用命令
published: true
category: redis
---


## 1. 物理环境

* 服务器：redis-2
* IP：43.2.218.137
* login：redis

## 2. 搭建步骤

几个步骤：

* 新建配置文件
* 启动节点
* 构建集群

配置文件：

```
cluster-enabled yes
cluster-config-file nodes.conf
cluster-node-timeout 5000
appendonly yes
port 7000
```

创建节点：

```
// 当前目录，创建配置文件模板文件
$ vim redis.conf
// 内容：
cluster-enabled yes
cluster-config-file nodes.conf
cluster-node-timeout 5000
appendonly yes
  
// 创建文件夹
// 分配配置文件
// 到每个文件夹下，调整端口号
$ for i in {0..7}; do mkdir 700${i}; cp redis.conf 700${i}/; echo "port 700${i}" >> 700${i}/redis.conf; done
  
// 查询修改结果
$ grep -rni "port 700" .
./7000/redis.conf:5:port 7000
./7001/redis.conf:5:port 7001
./7002/redis.conf:5:port 7002
./7003/redis.conf:5:port 7003
./7004/redis.conf:5:port 7004
./7005/redis.conf:5:port 7005
./7006/redis.conf:5:port 7006
./7007/redis.conf:5:port 7007
```

启动节点：
注：为了方便查看 Redis 服务器运行情况，在前台启动

```
// 新建 screen
screen redis-0
// 到指定目录
cd 7000
// 启动 redis server
redis-server redis.conf
// 切换出去当前 screen
Ctrl + A + D
```

### 2.1. 构造集群、槽指派

**目标**：端口 7000、7001、7002 共计 3 个实例，构造成多 master 的集群。

构造集群：

```
// 连接到集群
redis-cli -p 7000
// 将 master 添加到集群
127.0.0.1:7000> cluster meet 127.0.0.1 7001
OK
127.0.0.1:7000> cluster meet 127.0.0.1 7002
OK
  
// 查询集群状态：cluster nodes
127.0.0.1:7000> cluster nodes
6f989f5088b48d0a738fda4450857f338a4f2f04 127.0.0.1:7002 master - 0 1448861033304 2 connected
8d8e092074beebc6e6084970d05f26fc6a854aab 127.0.0.1:7000 myself,master - 0 0 0 connected
587235d77a59b5dc429ab871072fba43194a25e4 127.0.0.1:7001 master - 0 1448861032302 1 connected
 
 
// 查询集群基础信息：cluster info
127.0.0.1:7000> cluster info
cluster_state:fail
cluster_slots_assigned:0
cluster_slots_ok:0
cluster_slots_pfail:0
cluster_slots_fail:0
cluster_known_nodes:3
cluster_size:0
cluster_current_epoch:2
cluster_my_epoch:0
cluster_stats_messages_sent:7124
cluster_stats_messages_received:7124
```

槽指派，完成槽指派，集群才能上线：

```
// 连接到集群内部，查看集群状态：Redis 集群未上线
127.0.0.1:7000> cluster info
cluster_state:fail
cluster_slots_assigned:0
cluster_slots_ok:0
cluster_slots_pfail:0
cluster_slots_fail:0
cluster_known_nodes:3
cluster_size:0
cluster_current_epoch:2
cluster_my_epoch:0
cluster_stats_messages_sent:7124
cluster_stats_messages_received:7124
  
// 槽指派，为 7000 端口 Redis 实例指派槽
redis-cli -p 7000 cluster addslots {0..5000}
// 槽指派，为 7001 端口 Redis 实例指派槽
redis-cli -p 7001 cluster addslots {5001..10000}
// 槽指派，为 7002 端口 Redis 实例指派槽
redis-cli -p 7002 cluster addslots {10001..16383}
  
// 连接到集群内部，查看集群状态：Redis 集群已上线
127.0.0.1:7000> cluster info
cluster_state:ok
cluster_slots_assigned:16384
cluster_slots_ok:16384
cluster_slots_pfail:0
cluster_slots_fail:0
cluster_known_nodes:3
cluster_size:3
cluster_current_epoch:2
cluster_my_epoch:0
cluster_stats_messages_sent:8765
cluster_stats_messages_received:8765
```

使用 Redis 集群：

```
// 通用模式
redis-cli -p 7000
// 设置 key
127.0.0.1:7000> set msg "happy new year!"
(error) MOVED 6257 127.0.0.1:7001
  
  
// 集群模式
redis-cli -c -p 7000
// 设置 key
127.0.0.1:7000> set msg "happy new year!"
-> Redirected to slot [6257] located at 127.0.0.1:7001
OK
127.0.0.1:7001>
  
  
// 重新连接到 7000
redis-cli -c -p 7000
// 读取 key
127.0.0.1:7000> get msg
-> Redirected to slot [6257] located at 127.0.0.1:7001
"happy new year!"
127.0.0.1:7001>
```

备注：两种模式启动 redis-cli 客户端：

* 通用模式：`redis-cli -p 7000`
* 集群模式：`redis-cli -c -p 7000`，能够识别 `ASK`、`MOVED` 错误，并自动重定向

集群模式，能够自动 `follow -ASK and -MOVED redirections`.

**思考**：Redis cluster 中 slot（槽）的作用？

* 数据分片，依赖于 slot，
	* 定位 master
	* 新的 master 加入时，进行重新分片
* 数据存储过程（set）：
	* 计算出 key 对应的 slot
	* 找到负责这个 slot 的master，返回 MOVED 错误
	* 重定向连接到这个 master
	* 将 key-value 存储起来
* 数据读取过程（get）：
	* 计算出 key 对应的 slot
	* 找到负责这个 slot 的master，返回 MOVED 错误
	* 重定向连接到这个 master
	* 读取 key 对应的 value

### 2.2. Redis 重新分片

Redis 集群重新分片，说明几点：

1. 重新分片：新的 master 加入时，重新分配 slot，同时，相关slot 上所属的键值对也会从源master迁移到目标master 。
2. 重新分片：
	* 可以在线进行，不需要终止集群服务；
	* 通常由 Redis 集群管理软件 redis-trib 负责执行

将一个键从一个节点迁移到另一个节点的实际过程（redis-trib 负责）：

![](/images/redis/redis-install-on-single-server-re-slot.png)

关于重新分片，详细过程，参考《Redis 的设计与实现》 P266

### 2.3. 主从复制

**目标**：构造 master-slave 结构

```
// 将新节点，加入集群
127.0.0.1:7005> cluster meet 127.0.0.1 7004
OK
  
// 查看集群状态
127.0.0.1:7005> cluster nodes
587235d77a59b5dc429ab871072fba43194a25e4 127.0.0.1:7001 master - 0 1448869758734 1 connected 5001-10000
8fa1f601397d81fd48eb29bf1c4649fde8756a7d 127.0.0.1:7003 slave 8d8e092074beebc6e6084970d05f26fc6a854aab 0 1448869759435 3 connected
fb45582b5b16dffe72aae02cc3db9c5ca8ca1419 127.0.0.1:7004 master - 0 1448869758934 0 connected
6f989f5088b48d0a738fda4450857f338a4f2f04 127.0.0.1:7002 master - 0 1448869758634 2 connected 10001-16383
8d8e092074beebc6e6084970d05f26fc6a854aab 127.0.0.1:7000 master - 0 1448869758434 3 connected 0-5000
cbdfe71a19769057a8d1fc7c4f7ddc7f031afab8 127.0.0.1:7005 myself,master - 0 0 5 connected
127.0.0.1:7005> cluster info
cluster_state:ok
cluster_slots_assigned:16384
cluster_slots_ok:16384
cluster_slots_pfail:0
cluster_slots_fail:0
cluster_known_nodes:6
cluster_size:3
cluster_current_epoch:5
cluster_my_epoch:5
cluster_stats_messages_sent:52
cluster_stats_messages_received:52
  
// 配置新节点为 slave
127.0.0.1:7005> cluster replicate 8d8e092074beebc6e6084970d05f26fc6a854aab
OK
  
// 查看集群状态
127.0.0.1:7005> cluster nodes
587235d77a59b5dc429ab871072fba43194a25e4 127.0.0.1:7001 master - 0 1448869779974 1 connected 5001-10000
8fa1f601397d81fd48eb29bf1c4649fde8756a7d 127.0.0.1:7003 slave 8d8e092074beebc6e6084970d05f26fc6a854aab 0 1448869777970 3 connected
fb45582b5b16dffe72aae02cc3db9c5ca8ca1419 127.0.0.1:7004 master - 0 1448869778471 0 connected
6f989f5088b48d0a738fda4450857f338a4f2f04 127.0.0.1:7002 master - 0 1448869777970 2 connected 10001-16383
8d8e092074beebc6e6084970d05f26fc6a854aab 127.0.0.1:7000 master - 0 1448869779473 3 connected 0-5000
cbdfe71a19769057a8d1fc7c4f7ddc7f031afab8 127.0.0.1:7005 myself,slave 8d8e092074beebc6e6084970d05f26fc6a854aab 0 0 5 connected
```

特别说明：

1. 设置一个节点为 slave，需要先通过 `cluster meet <host> <port>` 将节点加入集群
2. 执行命令：`cluster replicate <node_id>`，将当前节点设置为指定 `<node_id>` 的 slave

### 2.4. 故障转移

故障转移：

1. 所有的 master 先判断 old master 已经 Fail
1. 第一个判断出 old master 已经 Fail 的master 向集群中所有节点广播：old master Fail 的消息
1. old master 的 slave 获知 master 已经 Fail 之后，会向其余 master 拉选票
1. 选票获胜的 slave 晋升为 new master
1. 其余 slave 设置为 new master 的slave
1. old master 也设置为 new master 的 slave

疑问：old master 再次上线之后，自动切换为 new master 的slave，哪个机制实现的？略神奇呀

* master 会定期给 slave 发送消息吗？

### 2.5. 补充：Docker 镜像方式

Docker 镜像方式，启动 Redis 服务：参考 [Mac 上搭建 Redis 服务器](http://ningg.top/redis-lesson-0-installation-on-macbook-pro/)。

如何基于 Docker 容器，来构建 Redis 集群。

基本步骤：

1. 创建 Redis 节点：docker 容器，实现 Redis 节点
2. 连接到 Redis 节点，进行集群管理
3. TODO：同一个宿主机上，不同的容器之间，网络如何互通？如何识别不同容器的 ip ？需要单独整理一份

具体命令：

```
# 1. 基于本地配置文件， 启动 Redis 节点
# 下面 /Users/guoning/ningg/projects/Redis/docker-config/7000/redis.conf 是本地配置文件的位置
docker run -v /Users/guoning/ningg/projects/Redis/docker-config/7000/redis.conf:/usr/local/etc/redis/redis.conf --name myredis1 redis redis-server /usr/local/etc/redis/redis.conf

# 2. 连接到 Redis 节点
# redis: 默认，容器中 redis 表示 Redis 服务地址
# 7000: 上一步中，设置了 Redis 的启动端口为 7000
docker run -it --link myredis1:redis --rm redis redis-cli -h redis -p 7000
```

 
## 3. 集群操作命令
命令列表：

|命令|说明|备注|
|---|---|---|
|`cluster info`|	集群状态||
|`cluster nodes`|节点状态||
|`cluster addslots [slot]`|槽指派||
|`cluster keyslot [key]	`|计算key对应的slot||
|`cluster getkeysinslot <slot> <count>`|从`<slot>`中获取`<count>`个key|使用跳跃表|
|`cluster setslot <slot> importing <source_id>`|目标节点，准备好从源节点导入指定 slot 的key	|
|`cluster setslot <slot> importing <target_id>`|源节点，准备好向目标节点迁移指定 slot 的key	||
|`cluster replicate <node_id>`|设置节点为slave||
 
## 4. 单服务器试用 Master & Slave 与 Sentinel

* 物理环境：redis-2
* 目录：/home/redis/redis-master-slave-sentinel/
* 登陆用户：redis

### 4.1. 搭建步骤
### 4.1.1. 搭建 Master & Slave 结构

启动 redis master：

```
// 启动 3 个节点
cd /home/redis/redis-master-slave-sentinel/6000
redis-server redis.conf
  
cd /home/redis/redis-master-slave-sentinel/6001
redis-server redis.conf
  
cd /home/redis/redis-master-slave-sentinel/6002
redis-server redis.conf
```

将 6001 和 6002 设置为 6000 的slave（下面代码以 6001 为例，6002 同理）：

```
// 连接到 6001
redis-cli -h localhost -p 6001
 
  
// 查看节点状态
localhost:6001> info
...
# Replication
role:master
connected_slaves:0
...
  
// 将 6001 设置为 slave
localhost:6001> slaveof localhost 6000
OK
  
// 查看节点状态
localhost:6001> info
...
# Replication
role:slave
master_host:localhost
master_port:6000
master_link_status:up
...
  
// 6002 的设置，同上
```

查看 master & slave 的状态：

```
// 连接到 6000
redis-cli -h localhost -p 6000
 
  
// 查看节点状态
localhost:6000> info replication
# Replication
role:master
connected_slaves:2
slave0:ip=127.0.0.1,port=6001,state=online,offset=701,lag=0
slave1:ip=127.0.0.1,port=6002,state=online,offset=701,lag=0
master_repl_offset:701
repl_backlog_active:1
repl_backlog_size:1048576
repl_backlog_first_byte_offset:2
repl_backlog_histlen:700
```

Note：slave 默认为 read-only

疑问 ：

* 配置 master & slave 结构，有几种方式？
	* 执行命令： `slaveof <host> <port>`
	* 节点启动时，配置选项： `slaveof <host> <port>`
* 任意节点都可以指定 master 成为 slave 吗？有没有权限控制？
	* master 启动时，配置选项：`requirepass <pw>`
	* slave 启动时，需要配置选项：`masterauth <pw>`

关于 redis 节点配置选项，更多内容参考： 小宇的 redis-3.0.4配置文件翻译

#### 4.1.2. 搭建 Sentinel 集群
sentinel 集群，由多个 sentinel 节点组成，每个 sentinel 节点，可以看作特殊的 redis 节点。

sentinel 的配置文件：

```
// 端口
port 26379
// 指定监听的 master：master_name，ip，port，quorum（判断 master 主观下线的 sentinel 最小个数）
// master_name 中限制的有效字符：A-z 0-9 .-_
sentinel monitor mymaster 127.0.0.1 6379 2
```

Note：只配置 master，sentinel 利用发现机制，自动监听 slave
 
启动 sentinel：

```
redis-sentinel sentinel.conf
```
 
### 4.2. 常用命令

命令列表：


|命令|说明|备注|
|---|---|---|
|`info`|节点状态||
|`info replication`|节点状态中的部分||
|`info server	`| ||
|`info clients`|	 ||	 
|`info memory	`|||
|`info persistence`|||
|`info stats`|||
|`info cpu`| ||
|`info cluster`|	||
|`info keyspace`|||
 	 	 
## 5. 参考来源


* [http://redis.io/topics/cluster-tutorial](http://redis.io/topics/cluster-tutorial) 其中，Creating and using a Redis Cluster
* [http://redis.io/commands](http://redis.io/commands)，Redis 命令集合




[NingG]:    http://ningg.github.com  "NingG"







