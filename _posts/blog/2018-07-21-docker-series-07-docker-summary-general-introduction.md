---
layout: post
title: Docker 系列：Docker 技术 & 生态的概述
description: Docker 有什么用？技术原理是什么？大的技术架构？小的关键细节？底层原理？Docker 集群又是怎么回事？
published: true
category: docker
---

## 1. 概要

组里 Q3 的技术氛围建设，确立了一个技术专题 《Docker 技术与原理》，做好动员和整体安排后，第一次我来开头，要质量高一些，做一个榜样，通过做出的事情，不断强化大家对团队理念的认可：高质量、不将就。

> Note： 当前 blog ，有一份 keynote，`Docker：概述.key`

主要目标：

* Docker 生态相关内容的介绍，核心概念，以及每个组件 or 工具，解决问题的边界。

涵盖几个方面：

1. Docker 有什么用？
	1. 业务场景中：细分场景，需要提供哪些功能？
1. Docker 技术原理
	1. 技术架构
	1. 关键概念
	2. 底层原理
1. Docker 单机 & 集群
	1. Docker Machine
	1. Docker swarm mode
	1. Kubernetes

整体分享的时候，基本过程：

* 发出疑问：引导思考
* 确定目标：自助部署、自助运维
* 总结引导：
	* 给出小总结，突出重点
	* 给出大总结，梳理脉络
* 发出疑问

## 2. Docker 有什么用

围绕 Docker 几个基本疑问：

1. Docker 要解决什么问题？
1. Docker 之前，是怎么解决的？
1. Docker 提供的优势？
1. Docker 还有其他优势吗？

### 2.1. 解决什么问题

**本质上**：开发 & 运维效率

* 提升`开发`--`运维`的效率
* **单个环境**：
	* **快速部署环境**：环境的多样性，不同物理机 or 云主机环境下，快速构造服务的运行环境，部署多种组件
	* **高效管理环境**：服务的高效伸缩、服务监控以及自动拉起（只能感知进程，无法感知业务）
* **多环境之间**：
	* 多环境之间灵活隔离：隔离 or 耦合
* 系统可伸缩性：
	* 服务快速伸缩：机器准备、环境准备、基础服务准备等（硬件 → 操作系统 → 业务服务）
 

更多细节，参考：[官网：Why Docker]

![](/images/docker-series/docker-summary-why-docker-1.png)

![](/images/docker-series/docker-summary-why-docker-2.png)

 

官网的核心观点：

* 提升了效率，节省了成本（时间、人力），就能把资源（时间、人力）投入到其他关键的地方，而不是支撑工作上


### 2.2. 核心理念

**核心理念**：标准化、减少多样性，降低复杂度，提升效率

* **统一**：
	* 虚拟层之上，`统一`暴露`接口`
	* `统一一个镜像`：涵盖 OS 和 APP 层逻辑
* **集中**：集中`管理镜像`、`分发镜像`
 
![](/images/docker-series/docker-summary-core-tips.png)

一张 Docker 整体生态的图片：仓库、容器等

![](/images/docker-series/docker-summary-core-tips-server-with-registry.png)


### 2.3. 对比：之前方案

Docker ：

* 「容器平台」的一种流行的实践方案（容器平台还有其他实现方案）

Docker 之前，如何解决上面问题的：

* **Docker 容器**：
	* 直接利用系统内核，进行资源共享、资源隔离、资源限额，没有虚拟 OS 等额外的虚拟层，系统效率损耗小（待确定？）
* **VM**：
	* 效率损耗：虚拟硬件，虚拟 OS（完整的 OS 视图）
	* 存在复杂、独立的管理程序 Hypervisor，耗用系统资源

![](/images/docker-series/docker-summary-docker-vs-vm-1.png)

![](/images/docker-series/docker-summary-docker-vs-vm-2.png)
 

Docker 容器，几个特点：

* **轻量级**：直接调用系统内核，资源损耗少
* **可插拔**：无论是本地、物理机还是云端，都可以快速的启动和终止，耦合小
* **可伸缩**：快速横向扩展服务数量
 

更多细节，参考：

* [官网：Get Start]
* [Container-based virtualization](https://www.safaribooksonline.com/library/view/hands-on-devops/9781788471183/107e0675-fe24-431b-b090-27bbf801e6c0.xhtml)

## 3. Docker 技术原理

关于 Docker 技术原理，几个方面：

* 技术架构
* 关键概念
* 底层原理

### 3.1. 技术架构

Docker Engine（Docker 核心引擎），是一个 C/S 结构，客户端/服务器 模式。

整体分为 2 部分：

* **Client**：客户端，提供命令接口的客服端（CLI, Command Line Interface），例如 docker 命令
* **Server**：服务器，分为 2 部分
	* **对外接口**：REST API，接收 Client 的命令，管理容器
	* **后台进程**：后台进程 dockerd，实现功能，包括创建并管理容器、镜像，以及网络、磁盘。

Docker Engine Components Flow：

![](/images/docker-series/docker-summary-client-and-server-1.png)

整理一个示意图：

* Client + Server
* 仓库：Registry

Docker Architecture Diagram

![](/images/docker-series/docker-summary-client-and-server-2.svg)

 

如果需要修改本地 docker client，连接到远端 docker server，如何修改？

* Re： https://yq.aliyun.com/articles/581105

### 3.2. 关键概念

几个关键概念：

* **Image（镜像）**：
	* 是一个可执行的文件，用于启动一个应用，包含，应用代码、依赖的库、运行环境（JRE 等）、环境变量、配置文件。
* **Container（容器）**：
	* 使用 Image 启动的一个进程实例。
* **Service（服务）**：
	* 一组 Container ，提供的对外服务。这些 Container 使用同一个 image 镜像文件。
* Stack（应用）：
	* 一组 Service，相互协作，对外提供服务。
	* 可以看做一个完整的 Application
	* 一些复杂业务场景，会拆分为多个 Stack

他们之间的关系，示意图：

![](/images/docker-series/docker-summary-objects-releation.png)

#### 3.2.1. 镜像：Dockerfile

构建 Image（镜像）：

* Dockerfile：
	* 描述基础镜像、环境变量、执行命令等，磁盘、网络等的配置
* Dockerfile 文件：
	* 定义「构建镜像」的细节
	* 每个 Dockerfile 文件，只能描述一个 Image
	* 给出一个 Dockerfile 的说明

Dockerfile 文件样例：（[https://docs.docker.com/get-started/part2/](https://docs.docker.com/get-started/part2/)）

```

# Use an official Python runtime as a parent image
FROM python:2.7-slim
 
# Set the working directory to /app
WORKDIR /app
 
# Copy the current directory contents into the container at /app
ADD . /app
 
# Install any needed packages specified in requirements.txt
RUN pip install --trusted-host pypi.python.org -r requirements.txt
 
# Make port 80 available to the world outside this container
EXPOSE 80
 
# Define environment variable
ENV NAME World
 
# Run app.py when the container launches
CMD ["python", "app.py"]
```


#### 3.2.2. Stack & Service：docker-compose

构建 Stack（应用）：涵盖 Service

* Docker compose：
	* 需要独立安装
	* 描述 Service 的细节：容器数量、镜像、资源限额、重启策略（？是这样命名吗）、磁盘、网络
	* docker-compose.yml 文件：
		* 定义 Service 细节
		* 每个 docker-compose.yml 文件，可以描述多个 Service
* 给一个 docker-compose.yml 的例子
 

docker-compose.yml 文件样例：（[https://docs.docker.com/get-started/part5/](https://docs.docker.com/get-started/part5/)）

```
version: "3"
services:
  web:
    # replace username/repo:tag with your name and image details
    image: username/repo:tag
    deploy:
      replicas: 5
      restart_policy:
        condition: on-failure
      resources:
        limits:
          cpus: "0.5"
          memory: 50M
        reservations:
          cpus: "0.25"
          memory: 20M
    ports:
      - "80:80"
    networks:
      - webnet
  visualizer:
    image: dockersamples/visualizer:stable
    ports:
      - "8080:8080"
    volumes:
      - "/var/run/docker.sock:/var/run/docker.sock"
    deploy:
      placement:
        constraints: [node.role == manager]
    networks:
      - webnet
networks:
  webnet:
```

### 3.3. 底层原理

#### 3.3.1. 资源隔离 & 资源限额

Docker 直接调用「系统内核」，实现资源隔离、限额，如何实现的？

几个切入点：

* 系统资源，有哪些？
* 哪些技术，针对这些资源，可以隔离和限额？

细节：

* 系统资源，从 OS 角度，分为：
	* CPU：进程（涵盖 CPU + 内存）
	* 存储：外部磁盘
	* 网络
* 资源的隔离：namespaces 技术
* 资源的限额：control groups 技术（cgroups），CPU 数量 和 内存大小

具体：

|资源类别|资源隔离：namespace|资源限额：cgroup|
|:--|:--|:--|
|CPU：进程（涵盖 CPU + 内存）	|pid namespace：进程隔离 & ipc namespace：进程间通信隔离|内存 + CPU|
|存储：外部磁盘	|mnt namespace：磁盘挂载点隔离|--|
|网络|net namespace：网络接口隔离|--	|
|用户|uts namespace：用户隔离|--	|
 

疑问：

* 一个 Container 是一个进程？
* Container 无法支持多进程的服务？
* Container 的资源限额：CPU 核心数量和 内存大小
 

#### 3.3.2. 联合文件系统（分层文件系统）

Union file systems, or UnionFS，通过分层方式，标识差量部分。提供几点便利：

* **构造镜像**：只构造差量部分，高效
* **分发镜像**：只分发差量部分，高效

现在有多种联合文件系统的实现：

* AUFS
* btrfs
* vfs
* DeviceMapper

使用命令： `docker info` 可以查看当前系统的文件格式

 
![](/images/docker-series/docker-summary-union-fs.png)


## 4. Docker 单机 & 集群

Docker 单机和集群，重点关注几个方面：

* Docker Machine
* Docker swarm mode
* Kubernetes

### 4.1. Docker Machine

Docker Machine，目标：

* 在`各种平台`上，快速安装 Docker 环境，即，快速创建 **Docker 服务器**(`Docker Node`)。


基本操作：

* Docker Machine 安装：是独立的组件，需要单独安装
* Docker Machine 使用

在本地物理机上，使用 virtualbox 驱动，创建 Docker 运行环境：

```
# 使用 virtualbox 驱动， 创建 Docker 主机，命名为 test
docker-machine create -d virtualbox test
 
# 查看列表
docker-machine ls
 
# 通过 ssh 登录机器
docker-machine ssh test
```

docker-machine 官方支持的驱动，-d 选项可以指定：

* amazonec2
* azure
* digitalocean
* exoscale
* generic
* google
* hyperv
* none
* openstack
* rackspace
* softlayer
* virtualbox
* vmwarevcloudair
* vmwarefusion
* vmwarevsphere

### 4.2. Docker Swarm

关于 swarm 的历史演进：

* **Docker Swarm**：
	* 在 Docker 1.12 版本之前，是独立的组件
	* 独立于 Docker Engine 之外，需要独立安装；
* **swarm mode**：
	* 在 Docker 1.12+ (涵盖1.12)，内置到了 Docker Engine 之中
	* 无需独立安装；
 
![](/images/docker-series/docker-machine.png)

几个核心概念：

* **Swarm（集群）**：一堆机器，构造成 docker 集群，叫做 Swarm。
* **Node（节点）**：Swarm 集群中，安装了 Docker 运行环境的机器，物理机 or 虚拟机
	* 角色：
		* **Manager**：负责管理集群
			* Manager 中，只能有一个 Leader
			* 多个 Manager 之间，依赖 Raft 协议，选举出 Leader
		* **Worker**：负责运行具体的 Container
			* Manager 节点，默认，也做为 Worker 节点，承担 Container 运行任务
 
![](/images/docker-series/swarm-diagram.png)


登录 Docker 机器后，需要执行命令，来开启 swarm mode 模式，然后，才能构造 swarm 集群。

具体命令：

```
# 登录到 Docker 机器（命名为 manager）
docker-machine ssh manager
 
# 完成下述 swarm 初始化，此时，当前节点成为 manager 节点
docker swarm init --advertise-addr 192.168.99.100
  
# 加入 Node
docker swarm join ...
  
# 部署应用（单个镜像）
docker service create ...
  
# 部署应用（依赖 docker-compose.yml 文件，部署一组镜像多个服务）
docker stack deploy ...
```

几个关键点：

* swarm 集群内部，**路由网络**：外部请求，访问任何一个 Node，无论是否有对应的 Service，都会路由到目的 Node 上，参考下面截图（ingress network）。
* swarm 集群，**工作原理**：manager Node 和 worker Node 的协作细节，参考下面截图（Docker Engine Client & swarm manager & worker node）
 

routing mesh diagram:

![](/images/docker-series/docker-summary-swarm-lb.png)

 
Docker Engine Client & swarm manager & worker node：

![](/images/docker-series/service-lifecycle.png)


Swarm 集群下，存在一个核心概念： Service 和 Task

* **Service**：
	* 一个服务，可能涵盖多个容器
	* Service 创建多个容器，每个容器对应一个 Task
* **Task**：
	* worker 节点上，创建一个容器的任务
* **Service 分类**：
	* replicated service：容器数量固定，跟 worker node 数量无关；
	* global service：每个 worker node ，运行一个容器，容器数量跟 worker node 绑定；

### 4.3. Kubernetes

Kubernetes 是一种解决方案，聚焦容器的集群管理、服务编排。

TODO：

* 单独整理一次吧。
* 这次不涵盖了。

## 5. 附录

### 5.1. Docker 的版本

几个方面：

Docker 的版本编号：如何判断 Docker 版本

![](/images/docker-series/docker-version-of-mac.png)
 

特别说明：

* Docker 的所有版本，都可以在 GitHub 上查看： 
	* [https://github.com/moby/moby/labels](https://github.com/moby/moby/labels)
* Docker 在 `2017.01.18` 发布了 `version/1.13` 版本后
	* 就不再使用 `1.x` 的版本编排方式了
	* 改为使用 `YY.MM` 的日期格式
* 当前 blog 时，最新的版本为 `18.09`


## 6. 参考资料

信息源头：

* [https://www.docker.com/](https://www.docker.com/) 官网
* [https://docs.docker.com/](https://docs.docker.com/) 官网文档
* [https://docs.docker.com/engine/docker-overview/](https://docs.docker.com/engine/docker-overview/) 概览
* [使用本地的docker客户端连接远程docker的守护进程](https://yq.aliyun.com/articles/581105)
* [Docker Getting Start: Related Knowledge](http://tiewei.github.io/cloud/Docker-Getting-Start/)
* [https://docker-doc.readthedocs.io/zh_CN/latest/terms/layer.html](https://docker-doc.readthedocs.io/zh_CN/latest/terms/layer.html)









[NingG]:    http://ningg.github.com  "NingG"

[官网：Why Docker]:		https://www.docker.com/why-docker
[官网：Get Start]:		https://docs.docker.com/get-started/











