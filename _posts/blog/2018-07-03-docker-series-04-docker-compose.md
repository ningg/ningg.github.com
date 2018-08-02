---
layout: post
title: Docker 系列：Docker Compose
description:Docker Compose 有什么用？如何安装？如何使用？
published: true
category: docker
---

## 0. 概要

Docker Compose，几个问题：

* 有什么作用？
* 如何安装？
* 如何使用？

## 1. Compose 的作用

之前的文章介绍了 `Dockerfile`，通过一个文件，可以定义一个`镜像`。而 `Compose` 则，定义一个项目，项目内，可以涵盖多个服务，每个服务，都是由**相同的**`镜像`生成的容器。

* `服务`（service）：**相同的**`镜像`，生成的多个容器；
* `项目`（project）：多个`服务`构成；

Compose 通过 `docker-compose.yml` 文件，定义一个项目。其本质：

* **源码**：[Docker Compose 源码] 是 Python 编写的
* **服务编排**：通过 Docker API，进行容器生命周期的管理
* **通用性**：只要满足 Docker API，就可以使用 `Compose` 进行编排管理


## 2. 安装

Compose 是独立的工具，需要单独安装：

* 服务器上，需要先安装 `Docker Engine`，因为 `Compose` 是跟 Docker 引擎配合的工具；
* `Docker for Mac` 以及 `Docker for Windows` 已经自带了 **docker-compose** 工具；

其他环境，参考 [Install Docker Compose] 进行安装.

```
# 查看 compose 版本
$ docker-compose version
docker-compose version 1.21.1, build 5a3f1a3
docker-py version: 3.3.0
CPython version: 3.6.4
OpenSSL version: OpenSSL 1.0.2o  27 Mar 2018
```

## 3. 使用

关于使用 Compose，分为 2 个部分：

1. 定义 `docker-compose.yml` 文件
1. 使用 `compose` 命令，进行 project 的管理


### 3.1 docker-compose.yml 文件

关于 `docker-compose.yml` 文件的写法：

* [Compose 模板文件]
* [Compose file version 3 reference]






### 3.2 docker-compose 命令

关于 `docker-compose` 命令：

* [compose 命令]
* [Overview of docker-compose CLI]







## 4. 参考资料

* [Overview of Docker Compose]
* [Install Docker Compose]
* [Docker Compose 源码]







[Overview of Docker Compose]:		https://docs.docker.com/compose/overview/
[Docker Compose 源码]:		https://github.com/docker/compose
[Install Docker Compose]:		https://docs.docker.com/compose/install/
[Compose 模板文件]:				https://yeasy.gitbooks.io/docker_practice/content/compose/compose_file.html
[compose 命令]:					https://yeasy.gitbooks.io/docker_practice/content/compose/commands.html
[Overview of docker-compose CLI]:			https://docs.docker.com/compose/reference/overview/
[Compose file version 3 reference]:		https://docs.docker.com/compose/compose-file/




[NingG]:    http://ningg.github.com  "NingG"






