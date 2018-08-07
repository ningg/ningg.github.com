---
layout: post
title: Docker 系列：Docker Machine
description: Docker Machine 能解决什么问题？如何使用？基本原理是什么？
published: true
category: docker
---

## 概要

Docker Machine，目标：

* 在各种平台上，快速安装 Docker 环境，即，快速创建 **Docker 服务器**。

几个方面：

1. Docker Machine 安装
2. Docker Machine 使用

`docker-machine` 本质就是通过 `REST API` 跟 Docker Daemon 进行交互，实现创建 Docker 运行环境（`Docker 服务器`）.

![](/images/docker-series/docker-machine.png)

## 安装

Docker for Mac 和 Docker for Windows，自带了 docker-machine ，查看具体版本的命令：

```
$ docker-machine -v
docker-machine version 0.14.0, build 89b8332
```

其他环境，需要安装 docker-machine，参考：

* [Docker Machine](https://docs.docker.com/machine/)


## 使用

Docker Machine 支持多种后端驱动：

* 物理机
* 虚拟机
* 云平台

### 本地物理机

在本地物理机上，使用 `virtualbox` 驱动，创建 Docker 运行环境：

```
# 使用 virtualbox 驱动， 创建 Docker 主机，命名为 test
docker-machine create -d virtualbox test

# 查看列表
docker-machine ls

# 通过 ssh 登录机器
docker-machine ssh test
```

除此之外，还可以使用其他几个驱动：

* macOS：`xhyve` 驱动
* Windows 10：`hyperv` 驱动


### 官方支持的驱动

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



## 附录

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


## 参考资料

* [Docker Machine]
* [Docker Machine 项目]







[Docker Machine]:			https://docs.docker.com/machine/
[Docker Machine 项目]:		https://yeasy.gitbooks.io/docker_practice/content/machine/




[NingG]:    http://ningg.github.com  "NingG"













