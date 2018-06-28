---
layout: post
title: Docker 系列：基础用法，镜像、容器
description: 如何获取镜像？如何制作镜像？如何启动容器？如何终止容器？
published: true
category: docker
---

## 概要

几个方面：

* 基本信息：Docker 版本，以及命令列表
* 镜像：唯一标识是什么？
	* 基本操作：获取镜像、上传镜像、删除镜像（本地、远端）
	* 创建
	* 查询
	* 分析
	* 导出：离线携带
* 容器：唯一标识是什么？
	* 查询
	* 创建
	* 运行
	* 终止
	* 分析

更多细节，可以参考：

* 官方文档：[Docker - Get Started](https://docs.docker.com/get-started/)

## 基本信息

查询 Docker 基本信息，涵盖：Docker 命令、Docker 运行状态等信息的操作

```
## List Docker CLI commands
docker
docker container --help

## Display Docker version and info
docker --version
docker version
docker info

## Execute Docker image
docker run hello-world

## List Docker images
docker image ls

## List Docker containers (running, all, all in quiet mode)
docker container ls
docker container ls --all
docker container ls -aq
```

## 镜像

镜像（image）的唯一标志：`name:tag`，其中，`tag` 默认取值为 `latest`.

主体，几个方面：
	* 基本操作：获取镜像、上传镜像、删除镜像（本地、远端）
	* 创建
	* 查询
	* 分析
	* 导出：离线携带

### 基本操作

镜像基本操作：

```
# 1. 从远端获取，从仓库拉取镜像
docker pull name:tag

# 2. 删除（多标签指向同一镜像时，只删标签）
docker rmi name:tag

# 3. 上传至远端（需要提前登录 docker login）
docker push name:tag
```


### 创建

创建镜像，具体操作：

```
# 1. 基于运行的容器，创建
# a. 查询容器：
docker ps
# b. 创建 
docker commit -m "message" CONTAINER name:tag

# 2. 使用本地的 gz 安装文件，创建
docker import FILE - name:tag

# 3. 基于 Dockerfile，创建
TODO

# 4. 创建别名
docker tag currName:currTag newName:newTag
```


### 查询

查询镜像，2 个方面：

* 从远端仓库，查询
* 从本地，查询

```
# 1. 从远端仓库，查询
docker search name:tag

# 2. 从本地，查询
docker images
docker images -a
docker images --no-trunc
```

Note：

> 镜像的大小: 大小为逻辑大小，实际是分层的


### 分析

分析镜像的详情：

```
# 1. 分析：版本、架构等信息
docker inspect name:tag
docker inspect name:tag -f {{".Os"}}

# 2. 分析历史：镜像的每层更新信息
docker history name:tag
docker history name:tag --no-trunc
```

### 导出

将镜像文件导出，方便离线携带：

```
# 1. 导出:本地文件(用于分享给他人)
docker save name:tag -o localFile

# 2. 导入:镜像列表	(用于添加到本地的镜像列表)
docker load --input localFile
docker load < localFile
```

Think: `本地镜像列表` 有什么用？涵盖了 `镜像文件` 自身么？


## 容器

`容器`的唯一标志为 `hashCode`。

Note：

> 「容器」跟「镜像」之间，不同的地方：`容器`有一个`可读可写文件层`， 而`镜像`只有`可读文件层`。

整体，围绕`容器`的操作，分为下述几类：

* 查询
* 创建
* 运行
* 终止

### 查询

查询容器，具体命令：

```
# 1. 查询，所有运行的容器（hashCode）
docker ps
docker ps -a

# 2. 查询，所有容器
docker container ls
docker container ls -all
```

### 创建

创建容器，具体命令：

```
# 创建容器，此时，容器并未启动
docker create -it [image]
```


### 运行

运行容器，分为几个方面：

```
# 1. 运行，容器
docker container start [container]
docker start [container]

# 2. 运行镜像，生成容器（如果镜像不存在，会自动 docker pull [image]）
docker container run [image]

# 3. 进入容器，并执行命令（i：interactive 交互模式， t：Allocate a pseudo-TTY 启动终端）
docker exec -it [container] /bin/bash
```

### 终止

终止容器，具体命令：

```
# 终止容器
docker container stop [container]
docker container kill [container]
```


## 参考资料

* 官网：[https://www.docker.com/](https://www.docker.com/)
* 官方文档：[Docker - Get Started](https://docs.docker.com/get-started/)








[NingG]:    http://ningg.github.com  "NingG"
