---
layout: post
title: Docker 系列：Docker Compose
description: Docker Compose 有什么用？如何安装？如何使用？
published: true
category: docker
---

## 0. 概要

Docker Compose，几个问题：

几个方面：

* Compose 的作用？
* 如何使用 Compose？
	* 配置文件：docker-compose.yml
	* 管理命令：docker-compose



## 1. Compose 的作用

Compose（编排），介绍 Compose 之前，需要先分析一下 Docker 的使用过程：

1. **镜像**：构建`镜像`
	1. 涵盖内容：服务代码逻辑、环境变量等
	1. 构建方式：`Dockerfile` 文件，进行构建
1. **容器**：基于`镜像`，启动容器
	1. 涵盖内容：网络端口映射、磁盘数据挂载、环境变量设置等
	1. 启动方式：`docker run` 启动单个容器

如果涉及`多个容器`，而且，`不同的容器`基于`不同的镜像`，此时，就是`容器编排`对外提供服务，可以利用 `Compose` 进行实现。

* **服务**：将一组**相同**的 `image` 的容器，构成一个`服务 Service`
* **Compose** 提供的功能：
	* **定义服务**：`docker-compose.yml` 配置文件，设定下述内容
		* 基本镜像
		* 容器数量
		* 网络配置
		* 磁盘挂载
		* 环境变量
	* **服务扩容**：`docker-compose` 命令

`Docker Compose` 可以支持多种场景：

* **单机环境隔离**：通过设置  `COMPOSE_PROJECT_NAME` 环境变量，实现单物理机上的环境隔离
* **差量更新**：只更新变更的 service

具体 `docker-compose` 在整个 Docker 生态中的位置，参考：

![](/images/docker-series/docker-summary-objects-releation.png)


## 2. 如何使用 Compose

几个方面：

* 本质剖析
* 安装 Compose
* 使用 Compose
	* 定义服务：docker-compose.yml 配置文件
	* 管理服务：docker-compose 命令

### 2.1. 本质剖析

Compose 通过 `docker-compose.yml` 文件，定义一个项目。其本质：

* **源码**：[Docker Compose 源码] 是 Python 编写的
* **服务编排**：通过 Docker API，进行容器生命周期的管理
* **通用性**：只要满足 Docker API，就可以使用 `Compose` 进行编排管理

### 2.2. 安装 Compose

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

### 2.3. 使用 Compose

使用 Compose 分为 2 个方面：

* **定义服务**：`docker-compose.yml` 配置文件
* **管理服务**：`docker-compose` 命令

#### 2.3.1. 定义服务 docker-compose.yml

先贴一个典型的 [docker-compose.yml 文件](https://docs.docker.com/compose/compose-file/)：

```
version: "3"
services:
 
  redis:
    image: redis:alpine
    ports:
      - "6379"
    networks:
      - frontend
    deploy:
      replicas: 2
      update_config:
        parallelism: 2
        delay: 10s
      restart_policy:
        condition: on-failure
 
  db:
    image: postgres:9.4
    volumes:
      - db-data:/var/lib/postgresql/data
    networks:
      - backend
    deploy:
      placement:
        constraints: [node.role == manager]
 
  vote:
    image: dockersamples/examplevotingapp_vote:before
    ports:
      - "5000:80"
    networks:
      - frontend
    depends_on:
      - redis
    deploy:
      replicas: 2
      update_config:
        parallelism: 2
      restart_policy:
        condition: on-failure
 
  result:
    image: dockersamples/examplevotingapp_result:before
    ports:
      - "5001:80"
    networks:
      - backend
    depends_on:
      - db
    deploy:
      replicas: 1
      update_config:
        parallelism: 2
        delay: 10s
      restart_policy:
        condition: on-failure
 
  worker:
    image: dockersamples/examplevotingapp_worker
    networks:
      - frontend
      - backend
    deploy:
      mode: replicated
      replicas: 1
      labels: [APP=VOTING]
      restart_policy:
        condition: on-failure
        delay: 10s
        max_attempts: 3
        window: 120s
      placement:
        constraints: [node.role == manager]
 
  visualizer:
    image: dockersamples/visualizer:stable
    ports:
      - "8080:8080"
    stop_grace_period: 1m30s
    volumes:
      - "/var/run/docker.sock:/var/run/docker.sock"
    deploy:
      placement:
        constraints: [node.role == manager]
 
networks:
  frontend:
  backend:
 
volumes:
  db-data: 
```

另一个 docker-compose.yml [配置文件样例](https://docs.docker.com/compose/compose-file/)：

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

关于 `docker-compose.yml` 文件的写法：

* [Compose 模板文件]
* [Compose file version 3 reference]


#### 2.3.2. 管理服务 docker-compose 命令

docker-compose 命令，可以管理应用的`整个生命周期`：

* 启动、停止、重建 Service
* **查询**：Service 状态
* **日志**：输出运行中 Service 的日志
* **精确**：针对单个 Service，进行管理，例如终止

docker-compose 命令的基本用法：

```
$ docker-compose
Define and run multi-container applications with Docker.
 
Usage:
  docker-compose [-f <arg>...] [options] [COMMAND] [ARGS...]
  docker-compose -h|--help
```

几个常用命令：

```
# 启动
docker-compose up
  
# 查询
docker-compose ps
  
# 终止
docker-compose stop
  
# 终止容器，并删除容器，删除所有 volume（可选）
docker-compose down --volumes
  
# 差量更新（跟启动命令，完全一样）
docker-compose up
  
# 服务中，执行命令
docker-compose run web env
```

关于 `docker-compose` 命令：

* [compose 命令]
* [Overview of docker-compose CLI]



## 3. 讨论

Docker Compose：

* **适用场景**：单物理机上
	* TODO：是否可以跨不同的物理机？
* **定义服务**：docker-compose.yml 文件
	* 主要部分：
		* version：docker compose 文件的版本
		* services：
		* networks：
	* services：定义服务，可以定义多个，每个服务，要涵盖的内容
		* service name
			* image：镜像
			* build：基于 dockerfile 构建镜像，跟 image 可相互替代
				* 其下一级，可以设置关于 dockerfile 更多的细节参数
			* command：执行的命令，跟 dockerfile 中的命令部分类似
			* depends_on：依赖的服务
			* expose：网络端口
			* ports：端口映射绑定
			* networks：网络模式
			* links：设定一个跨服务的别名，也说明服务之间存在依赖关系
			* environment：设置环境变量


遗留问题：

* version 的含义：设定 docker-compose.yml 配置文件的规范和解析规范
* service 的 name：是构成 Service 的局部名称，会基于此增加「前缀」和「后缀」
* depends_on：执行的本质细节，是先执行？or 先执行并验证效果？
* expose 跟 ports 之间的关系？
* links: 命令本质
	* 是在容器的 host 文件中，生成一条 ip 解析记录？演示的过程中，没有找到




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






