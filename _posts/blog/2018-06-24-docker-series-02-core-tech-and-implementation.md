---
layout: post
title: Docker 系列：核心原理和实现
description: Docker 是什么架构？ C/S 架构？其实现的核心原理有哪些？
published: true
category: Docker
---

## 概要

几个常见问题：

* Mac 上安装的 docker 是什么？是一个独立的进程？ docker 不是一个工具吗？
* docker 本地，需要设置「仓库地址」，如何设置呢？在哪设置？
* docker 跟 Maven 之间做类比，可以完全类比吗？就是一个「非进程类的工具」，需要指定一个仓库，就这样么？
* 如何查看本地，有哪些镜像？
* 本地已经存在的镜像，是否可以被覆盖更新？

需要分析 Docker 的设计理念和底层实现原理，才能提纲挈领，对上述问题，有个本质的理解。


按照 [Docker overview: 官网](https://docs.docker.com/engine/docker-overview/) 的思路，从几个方面介绍：

1. 入门介绍：
	1. Docker 平台（Docker Platform）
	2. Docker 引擎（Docker Engine）
	3. 适用场景
1. Docker 架构：
	1. Docker daemon：服务器
	2. Docker client：客服端
	3. Docker registries：私服
	4. Docker objects：镜像、容器、服务
1. 底层技术：
	1. 命名空间：namespace
	2. 控制组：control groups
	3. 联合文件系统（分层文件系统）：Union file systems
	4. 容器格式：Container format

## 入门介绍

Docker 是一个开发、分发、部署运行应用的平台，能够非常简便的控制应用之间的资源隔离，极大提升开发、测试、部署上线的效率。

### Docker 平台

Docker ：

1. 依赖`容器`，实现`应用`之间的`资源隔离`和`安全控制`；
2. `容器`运行时，能够直接调用 Kernel 接口（`系统调用`），效率非常高；
3. 容器，既可以运行在`物理机`上，甚至也可以运行在`虚拟机`上；

Docker 平台，提供`多种工具`，来`管理``容器`的整个`生命周期`：

* 开发：容器，开发应用，镜像的分层文件系统，方便进行快速开发和打包
* 测试：容器，快速构建测试环境
* 伸缩：容器，分布式系统伸缩的基本单元
* 部署：容器，在本地、云端，都可以快速部署

### Docker 引擎

Docker 引擎，本质是 `Client`-`Server` 模式，包含下述几个组件：

* **服务器**：
	* **对外接口**：REST API，接收 `Client` 的命令，管理容器 
	* **后台进程**：后台进程 `dockerd`，实现功能，包括创建并管理`容器`、`镜像`，以及`网络`、`磁盘`。
* **客服端**：提供命令接口的客服端（CLI, Command Line Interface），例如 `docker` 命令

参考示意图：

![](/images/docker-series/engine-components-flow.png)

### 适用场景

Docker 可以用来做什么呢？有什么好处呢？

* **持续集成和持续交付**： continuous integration & continuous delivery (CI/CD) ，使用容器，能够快速创建标准化环境。
* **多环境部署**：笔记本、刀片服务器、云服务器，都可以快速启动容器
* **易伸缩**：快速进行容器的伸缩
* **节省资源**：相同的物理服务器上，相对于传统的虚拟机，容器更节省资源

## Docker 架构

主要关键点：

1. Docker 是 C/S 架构，由 Client 和 Server 组成。
1. Client 通过 REST API 跟 Server 之间交互。
1. Docker Server 具体形式，就是 Docker Daemon 后台进程。
1. Docker Client 和 Docker Server，可以在同一台机器上，也可以不在一起。

具体的架构：

![](/images/docker-series/architecture.svg)

具体 4 个关键对象：

* Docker 服务器：Docker Daemon
* Dcoker 客服端：Docker Client
* Docker 仓库：Docker Registies
* Docker 对象：
	* 镜像：Images
	* 容器：Container
	* 服务：service

### Docker 服务器













## 参考资料

* [Docker overview: 官网](https://docs.docker.com/engine/docker-overview/)
* [Docker 入门教程](http://www.ruanyifeng.com/blog/2018/02/docker-tutorial.html)
* [Docker 微服务教程](http://www.ruanyifeng.com/blog/2018/02/docker-wordpress-tutorial.html)
* [CoolShell-Docker](https://coolshell.cn/tag/docker)
* [Docker CE 源代码](https://github.com/docker/docker-ce)
* [Docker 实践](https://www.kancloud.cn/huyipow/docker/502959)
* [Docker 核心技术与实现原理](https://draveness.me/docker)
* [Docker 简明教程](https://jiajially.gitbooks.io/dockerguide/)
* [笔记：Docker 核心技术与实现原理](https://zhoukekestar.github.io/notes/2017/12/01/docker.html)











[NingG]:    http://ningg.github.com  "NingG"
