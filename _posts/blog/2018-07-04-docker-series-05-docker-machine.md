---
layout: post
title: Docker 系列：Docker Machine
description: Docker Machine 能解决什么问题？如何使用？基本原理是什么？
published: true
category: docker
---


### 1. Docker Machine

关于 Docker Machine，几个方面：

* 是什么：有什么用？
* 怎么用？
* 什么原理？


### 1.1. 是什么

> **Docker Machine** 是一个`独立的工具`，跟 Docker Engine 不一样。

Docker Machine 的目标：

* 在**各种平台**上（Linux、Windows、Mac、Cloud 等），
* 快速**创建** `Docker 节点`（*Docker 服务器*）
	* 快速安装 Docker 环境（运行 Docker Daemon）


**补充**：Docker Engine 是什么？

> Docker Engine（Docker 核心引擎），是一个 `C/S` 结构，`客户端`/`服务器` 模式。

整体分为 2 部分：

* **Client**：客户端，提供命令接口的客服端（CLI, Command Line Interface），例如 docker 命令
* **Server**：服务器，分为 2 部分
	* **对外接口**：REST API，接收 Client 的命令，管理容器
	* **后台进程**：后台进程 dockerd，实现功能，包括创建并管理容器、镜像，以及网络、磁盘。

![](images/docker-series/docker-engine-infra.png)

### 1.2. 怎么用

几个方面：

1. **安装** Docker Machine
1. **使用** Docker Machine



#### 1.2.1. 安装 Docker Machine

Docker for Mac 和 Docker for Windows，自带了 docker-machine ，查看具体版本的命令：

```
$ docker-machine -v
docker-machine version 0.14.0, build 89b8332
```

其他环境，需要安装 docker-machine，参考：

* [Docker Machine](https://docs.docker.com/machine/)

#### 1.2.2. 使用 Docker Machine


Docker Machine 支持多种后端驱动：

* 物理机
* 虚拟机
* 云平台

在本地物理机上，使用 `virtualbox` 驱动，创建 Docker 运行环境：

```
# 使用 virtualbox 驱动， 创建 Docker 主机，命名为 test
docker-machine create -d virtualbox test
 
# 查看列表
docker-machine ls
 
# 通过 ssh 登录机器（登录之后，可以查看 docker 服务进程和 docker CLI 命令工具）
docker-machine ssh test
  
# 登录之后，可以查看 docker 服务进程和 docker CLI 命令工具
ps -ef | grep docker
 
# 本地 docker CLI 连接到对应的 Docker Engine
eval $(docker-machine env test)
  
# 取消 docker CLI 连接到的 Docker Engine
eval $(docker-machine env -u)
  
# 暂停 docker 服务节点
docker-machine stop test
  
# 删除 docker 服务节点
docker-machine rm test
```

除此之外，还可以使用其他几个驱动：

* macOS：`xhyve` 驱动
* Windows 10：`hyperv` 驱动


#### 1.2.3. 官方支持的驱动

docker-machine 官方支持的驱动，`-d` 选项可以指定：

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

更多使用细节：[https://docs.docker.com/machine/drivers/](https://docs.docker.com/machine/drivers/)


### 1.3. 什么原理

`docker-machine` 本质就是通过 `REST API` 跟 Docker Daemon 进行交互，实现创建 Docker 运行环境（`Docker 服务器`）.

![](/images/docker-series/docker-machine.png)


## 2. 附录

如果遇到下面错误提示，则，需要提前安装 `virtualbox`。

错误描述：

```
Error with pre-create check: "VBoxManage not found. Make sure VirtualBox is installed and VBoxManage is in the path"
```

解决办法：

```
# 查询 virtualbox
brew search virtualbox

# 安装 virtualbox
brew cask install virtualbox
```


## 3. 参考资料

* [Docker Machine]
* [Docker Machine 项目]







[Docker Machine]:			https://docs.docker.com/machine/
[Docker Machine 项目]:		https://yeasy.gitbooks.io/docker_practice/content/machine/




[NingG]:    http://ningg.github.com  "NingG"













