---
layout: post
title: Docker 系列：核心原理和实现
description: Docker 是什么架构？ C/S 架构？其实现的核心原理有哪些？
published: true
category: docker
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

Docker Daemon 后台进程（`dockerd`），做几件事情：

1. 对外：通过 REST API，提供交互接口，监听外部的交互命令
2. 对内：管理 `镜像`、`容器`、`网络`、`磁盘`

补充说明：

* Docker Daemon 后台进程，可以跟其他 Docker Daemon 后台进程通信，来管理 Docker Service. (疑问： 什么含义？)


### Docker 客户端

几个方面：

1. 直接使用的 `docker` 命令，就是最常见的 Docker 客户端；
1. 使用 `docker` 命令，能够跟 `dockerd` 后台进程，进行交互；
1. docker 客户端，可以跟多个 `dockerd` 后台进程，进行交互； （疑问：什么含义？）

### Docker 仓库

Docker 仓库：

* 用于存储 `image`
* 常用的 Docker 仓库：`Docker Hub` 和 `Docker Cloud`
* 默认，docker 服务端的**默认**仓库是： `Docker Hub`
* 可以搭建自己的 Docker 仓库

### Docker 对象

Docker 场景下，几个常见对象的说明：

* 镜像：image
	* 可使用 Dockerfile 来快速创建镜像
* 容器：container
	* `image` 的运行实例，构成一个容器
	* 根据 `image`，来**创建**和**运行**一个容器时，可以指定`运行参数`
* 服务：service
	* 目标：
		* 对外，看起来是一个服务.
		* 可以通过 swarm，控制一起 Docker 服务器，进行容器的伸缩.
	* swarm：
		* 由一群 Docker 服务器构成，包括：manager 和 worker 两类节点
		* 不同的 Docker 服务器之间，通过 REST API 进行通信
		* Docker `1.12+` 开始支持 swarm 模式

更多细节，可以参考下文的「实例」部分的说明。



## 实例

下面一条命令的执行过程：

```
-- 目标：运行一个 ubuntu 容器，同时，进入容器的操作系统命令行
$ docker run -i -t ubuntu /bin/bash
```

具体分为下面几个过程：

1. **镜像**：如果 `dockerd` 的本地不存在 `ubuntu 镜像`，则，自动执行 `docker pull ubuntu` 命令，从 `Docker 仓库` 获取镜像，下载到 `Docker 服务器` 的本地；
2. **容器**：创建一个容器，跟命令 `docker container create` 类似；
3. **文件系统**：自动创建一个可读、可写层，允许容器在本地文件系统上，进行读写操作；
4. **网络**：为容器分配一个网络地址，容器可以使用宿主机的网络对外通信；
5. **启动**：启动容器，并且，执行 `/bin/bash` 命令，因为设置了 `-it` 选项，容器通过本地终端窗口，进行交互
6. **终止**：交互命令窗口中，输入 `exit` 容器会终止运行，但是，容器并未删除，可以再次重启，或者进一步删除容器；


## 底层技术

Docker 是使用 [Go](https://golang.org/) 语言编写的，使用了大量的 `Linux 内核调用`，以达到其对外的资源隔离.

Docker 的底层技术，涵盖：

1. 命名空间：namespace，OS 级别，实现资源隔离，避免`容器之间`相互干扰
2. 控制组：control groups
3. 联合文件系统（分层文件系统）：Union file systems
4. 容器格式：Container format

### 命名空间：资源隔离, OS 级别

Docker 引擎，通过**命名空间**（`namespace`），来实现容器之间的资源隔离，每个容器，只能看到自己空间内的东西。

Docker 引擎，使用的命名空间：（**OS 级别**）

* CPU：`进程`
	* **进程**，`pid` 命名空间 + `IPC` 命名空间
* 存储：
	* **文件目录**：磁盘，`mnt` 命名空间（内存，是否存在命名空间，不确定）
* 网络：
	* `net` 命名空间
* 用户和组：
	* `uts` ：uid 和 gid ？


详细说明：

* The `pid` namespace: Process isolation (`PID`: Process ID).
* The `net` namespace: Managing network interfaces (`NET`: Networking).
* The `ipc` namespace: Managing access to IPC resources (`IPC`: InterProcess Communication).
* The `mnt` namespace: Managing filesystem mount points (`MNT`: Mount).
* The `uts` namespace: Isolating kernel and version identifiers. (`UTS`: Unix Timesharing System).


### 控制组：资源限制，硬件级别

Docker 引擎，依赖**控制组**（control group, `cgroup`），实现`硬件资源`的**共享**和**限额**。

关于`限额`，几个方面：

1. 隔离
2. 优先级
3. 配额

可以控制限额的`硬件资源`：

* CPU
* 内存
* 磁盘
* 网络：这个有控制限额么？

疑问：

* 仍然是 OS 级别吧？因为所有的东西，都是在 OS 之上，对外暴露的

### 联合文件系统，分层文件系统

Union file systems, or `UnionFS`，通过`分层`方式，标识**差量部分**。提供几点便利：

* 快速构造镜像：只构造`差量部分`
* 快速分发镜像：只分发`差量部分`

现在有多种**联合文件系统**的实现：

* AUFS
* btrfs
* vfs
* DeviceMapper

更多细节，参考：

* [About storage drivers](https://docs.docker.com/storage/storagedriver/)
* [Docker Getting Start: Related Knowledge](http://tiewei.github.io/cloud/Docker-Getting-Start/)
* [https://docker-doc.readthedocs.io/zh_CN/latest/terms/layer.html](https://docker-doc.readthedocs.io/zh_CN/latest/terms/layer.html) 


### 容器格式

Docker 引擎，封装 `namespaces`、`control groups`、 `UnionFS` 构造成一个**容器格式**。当前默认的容器格式，是 `libcontainer`。

未来，结合了 `BSD Jails`或 `Solaris Zones` 技术，可能会诞生其他**容器格式**。




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
