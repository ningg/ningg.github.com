---
layout: post
title: Docker 系列：swarm mode
description: Docker swarm mode 有什么用？如何安装？如何使用？
published: true
category: docker
---

## 概要

> **swarm 的作用**：Docker Engine 内置（原始）的**集群管理**和**编排工具**。


关于 swarm 的历史演进：

1. Docker Swarm：在 Docker `1.12` 版本之前，是独立的组件，独立于 Docker Engine 之外，需要独立安装；
2. swarm mode：在 Docker `1.12+`(涵盖`1.12`)，内置到了 Docker Engine 之中，无需独立安装；

官方建议：

> 如果要使用 swarm，直接升级到 Docker `1.12` 之后的新版本，使用 swarm mode 即可。

更多细节，参考：

* [Swarm mode overview]
* [Docker Swarm]
* [Use Compose with Swarm]


## swarm mode

Swarm mode 内置 `kv` 存储功能，提供了众多的新特性：

* **去中心化**：具有容错能力
	* 同一个`镜像`，启动节点，运行时可以设置不同角色 node、manager、worker
	* 声明式的服务模型，可以直接定义一个`应用`，包含哪些`服务`
	* 监听 worker 的状态，如果挂掉，会自动重启
* **服务发现**：内置了服务发现
* **负载均衡**：服务可以对接外部的 LB，swarm 也支持指定 service 在 node 上的分布
* **路由网格**：overlay 网络，虚拟网络，就近服务注册和服务发现，以及服务路由
* **动态伸缩**：服务层面的`容器`伸缩
* **滚动更新**：服务部署的粒度，细化到`容器` or `node`？
* **安全传输**：使用 TLS 协议进行安全的通信

这些特性，使得 Docker 原生的 `Swarm` 集群具备与 `Mesos`、`Kubernetes` 竞争的实力。

> 疑问： swarm mode 场景下，存在哪些对象？相互之间的关系是什么？











## 参考资料

* [Swarm mode overview]
* [Docker Swarm]
* [Use Compose with Swarm]







[Swarm mode overview]:		https://docs.docker.com/engine/swarm/
[Docker Swarm]:				https://docs.docker.com/swarm/
[Use Compose with Swarm]:	https://docs.docker.com/compose/swarm/





[NingG]:    http://ningg.github.com  "NingG"













