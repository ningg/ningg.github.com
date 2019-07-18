---
layout: post
title: Consul：入门 & 实践
description: Consul 使用过程中的几个疑问，以及几个常用操作
published: true
category: consul
---




几个方面：

1. 使用：
	1. 启动
	1. 查看运行状态
	1. 定位启动问题、执行问题
1. 原理


## 1.常用操作

启动时，连接到远端 consul 集群（king）：

```
$ consul agent -ui -data-dir=/tmp/consul -datacenter=king -encrypt MoQXrePcUWfb1bKn+Qpsmg== -advertise='172.17.9.119' -retry-join consul.king.ningg.io
```


查看当前 consul 集群状态：`consul members`

```
$ consul members
Node             Address            Status  Type    Build  Protocol  DC    Segment
king1.ningg.io  10.201.27.2:8301   alive   server  0.9.3  2         king  <all>
king2.ningg.io  10.201.28.2:8301   alive   server  0.9.3  2         king  <all>
king3.ningg.io  10.201.29.2:8301   alive   server  0.9.3  2         king  <all>
localhost        172.17.9.119:8301  alive   client  0.9.3  2         king  <default>
```

## 2.典型场景

几个典型场景下，怎么操作 consul

### 场景A：Spring Cloud 中，注销服务

几个方面：

1. 查询当前 consul 集群信息
1. 注销服务

具体操作，参考下文。

查询当前 consul 集群信息：

```
$ curl 127.0.0.1:8500/v1/catalog/nodes

[{"ID":"d2f860fa-14dd-0241-3c66-31b7891adafb","Node":"protoss.ningg.io","Address":"10.201.52.2","Datacenter":"protoss","TaggedAddresses":{"lan":"10.201.52.2","wan":"10.201.52.2"},"Meta":{"consul-network-segment":""},"CreateIndex":5,"ModifyIndex":6}]
```

注销服务：

```
$ cat payload.json 
{
  "Datacenter": "protoss",
  "Node": "protoss.ningg.io",
  "ServiceID": "protoss-api-0"
}
 
$ curl --request PUT --data @payload.json 127.0.0.1:8500/v1/catalog/deregister
```

Note：上述操作只能临时解决一下问题，服务会自动重新注册.

参考资料：

* [https://www.consul.io/api/catalog.html](https://www.consul.io/api/catalog.html)



## 3.原理

关于 Consul 原理，2 个方面：

1. 术语：其的含义，反映出了部分原理
2. 原理细节



### 3.1.Consul Index

异步 Servlet/ 阻塞查询特性：

* HTTP header里包含一个 X-Consul-Index 的key。
* 这个key标识了请求资源的当前状态。 
* 然后在接下来的查询里可以在请求头里加入这个 X-Consul-Index key，表示你想等待任何在这个key表示的index之后的更改后的资源值。
* Note：只有一部分 HTTP API 支持阻塞查询特性。

举例：

* /v1/event/list?wait=1m&index=12365592386954179651
* 上述内容表示：consul-index 在 12365592386954179651 之后有更新时，才会返回响应，超时时间为 wait=1m



参考资料：

* [http://supershll.blog.163.com/blog/static/37070436201682153258756/](http://supershll.blog.163.com/blog/static/37070436201682153258756/)
* [https://github.com/hashicorp/consul/issues/361](https://github.com/hashicorp/consul/issues/361)



### 3.2.Consul Watch 的实现

Consul 的 Watch 实现细节： 

* [http://blog.csdn.net/younger_china/article/details/52243799](http://blog.csdn.net/younger_china/article/details/52243799)



### 3.3.Consul vs. Zookeeper

Consul vs. Zookeeper：

* 服务发现：Zookeeper vs etcd vs Consul： [http://dockone.io/article/667](http://dockone.io/article/667)
* Consul和ZooKeeper的区别： [http://dockone.io/article/300](http://dockone.io/article/300)
















[NingG]:    http://ningg.github.com  "NingG"










