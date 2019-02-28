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
* [Docker Command-Line Interfaces (CLIs)] 官网完整的命令说明

一个典型的示意图：

![](/images/docker-series/docker-commands.png)

上图是一个image的简单使用：

1. 镜像：
	1. 通过 dockerfile 来 build image，本质就是基于 container 进行 commit 操作
1. 容器：
	1. 运行容器：直接run container
	1. 管理容器：container进行stop、start、restart
	1. 构造镜像：基于 container 进行 commit 操作
1. 本地导出：对image进行save保存，以及加载load操作
1. 镜像仓库：
	1. 把image上传（push）到镜像仓库
	1. 从仓库pull到本地

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

特别说明：

> 命令查询入口：多查看 `docker` 命令，其输出的提示信息，显示 `docker` 可以操作 `对象`（镜像、容器、网络、磁盘、配置等等），也可以直接执行`动作`（查看信息、查看镜像列表、制作镜像等等）

## 镜像

镜像（image）的唯一标志：`name:tag`，其中，`tag` 默认取值为 `latest`.

主体，几个方面：

* 基本操作：获取镜像、上传镜像、删除镜像（本地、远端）
* 创建
* 查询
* 分析
* 导出：离线携带

设置 Docker Registry **镜像加速器**：

* 登录 [https://cr.console.aliyun.com/cn-hangzhou/mirrors](https://cr.console.aliyun.com/cn-hangzhou/mirrors) 后，可以获取专属的**镜像加速地址**。

具体，参考下述配置：

![](/images/docker-series/docker-registry-accelerate-mirror-config.png)


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

# 2. 使用本地的文件，创建（本地文件是 docker export 从容器导出的）
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

## 附录

### 附录 A：Docker 命令的详解

自带 `docker` 命令，具体操作参数细节。

详细信息，参考：

* [Docker 常用指令详解](https://www.jianshu.com/p/7c9e2247cfbd)

#### 对象的管理命令

针对对象的管理命令列表：

|选项|说明|
|:----|:----|
|container|管理容器|
|image|管理镜像|
|network|管理容器网络(默认为bridge、host、none三个网络配置)|
|plugin|管理插件|
|system|管理系统资源。其中, docker system prune 命令用于清理没有使用的镜像, 容器, 数据卷以及网络|
|volume|管理数据卷|
|swarm|管理Swarm模式|
|service|管理Swarm模式下的服务|
|node|管理Swarm模式下的docker集群中的节点|
|secret|管理Swarm模式下的敏感数据|
|stack|Swarm模式下利用compose-file管理服务|

说明

* 其中 `container` 、`image` 、`system` 一般用后面的简化指令。
* `Swarm` 模式用来管理 **docker 集群**：
	* 它将一群 Docker 宿主机，看做一个单一的虚拟的主机
	* 实现对多台物理机的**集群管理**。

#### 通用的管理命令

|选项|说明|
|:----|:----|
|attach|进入运行中的容器, 显示该容器的控制台界面。注意, 从该指令退出会导致容器关闭|
|build	|根据 Dockerfile 文件构建镜像|
|commit|提交容器所做的改为为一个新的镜像|
|cp|在容器和宿主机之间复制文件|
|create|根据镜像生成一个新的容器|
|diff|展示容器相对于构建它的镜像内容所做的改变|
|events|实时打印服务端执行的事件|
|exec|在已运行的容器中执行命令|
|export|导出`容器`到本地`快照文件`|
|history|显示镜像每层的变更内容|
|images|列出本地所有镜像|
|import|导入本地`容器``快照文件`为镜像|
|info|显示 Docker 详细的系统信息|
|inspect|查看容器或镜像的配置信息, 默认为json数据|
|kill| `-s` 选项向容器发送信号, 默认为SIGKILL信号(强制关闭)|
|load|导入`镜像`压缩包|
|login|登录第三方仓库|
|logout|退出第三方仓库|
|logs|打印容器的控制台输出内容|
|pause|暂停容器|
|port|容器端口映射列表|
|ps|列出正在运行的容器, `-a` 选项显示所有容器|
|pull|从镜像仓库拉取镜像|
|push|将镜像推送到镜像仓库|
|rename|重命名容器名|
|restart|重启容器|
|rm|删除已停止的容器, `-f` 选项可强制删除正在运行的容器|
|rmi|删除镜像(必须先删除该镜像构建的所有容器)|
|run|根据镜像生成并进入一个新的容器|
|save|打包`本地镜像`, 使用压缩包来完成迁移|
|search|查找镜像|
|start|启动关闭的容器|
|stats|显示容器对资源的使用情况(内存、CPU、磁盘等)|
|stop|关闭正在运行的容器|
|tag|修改镜像tag|
|top|显示容器中正在运行的进程(相当于容器内执行 `ps -ef` 命令)|
|unpause|恢复暂停的容器|
|update|更新容器的硬件资源限制(内存、CPU等)|
|version|显示docker客户端和服务端版本信息|
|wait|阻塞当前命令直到对应的容器被关闭, 容器关闭后打印结束代码|
|daemon|这个子命令已过期, 将在Docker 17.12之后的版本中移出, 直接使用dockerd|

补充说明：

* 基于**容器**：
	* docker export：导出镜像文件
	* docker import：导入镜像文件
* 基于**本地镜像**：
	* docker save：导出镜像文件
	* docker load：导入镜像文件

## 参考资料

* 官网：[https://www.docker.com/](https://www.docker.com/)
* 官方文档：[Docker - Get Started](https://docs.docker.com/get-started/)
* [Docker Command-Line Interfaces (CLIs)]








[NingG]:    http://ningg.github.com  "NingG"

[Docker Command-Line Interfaces (CLIs)]:			https://docs.docker.com/engine/reference/run/