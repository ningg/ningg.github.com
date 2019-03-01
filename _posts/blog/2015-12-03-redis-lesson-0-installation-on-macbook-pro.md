---
layout: post
title: Redis 设计与实现：Mac 上搭建 Redis 服务器
description: 本地 Mac 上运行 Redis 服务器
published: true
category: redis
---

## 背景

因为开发需要，在本地启动一个 Redis 服务器

## Mac 上搭建 Redis 服务器


### 下载 & 安装

在 [https://redis.io/download](https://redis.io/download)  下载 Redis 3.2.x。

```
$ tar xzf redis-3.2.9.tar.gz
$ cd redis-3.2.9
$ make
```

### 启动

启动 Redis 服务器：

```
$ src/redis-server
```

### 使用

```
$ src/redis-cli
redis> set foo bar
OK
redis> get foo
"bar"
  
# 连接到指定的机器
$ src/redis-cli -h [hostname] -a [passwd]
```

## Docker 镜像方式，启动 Redis

Docker 镜像方式，启动 Redis：

1. 拉取镜像：拉取 Redis 指定版本的镜像
1. 配置参数：需要知道 Redis 镜像的配置参数，对应的环境变量等信息
1. 启动容器：基于镜像，启动 Redis 服务

关于 Redis 镜像的构建过程， Dockerfile 文件，更多细节，参考

1. [https://redis.io/](https://redis.io/)
1. [https://redis.io/download](https://redis.io/download)
1. [Redis Imager of DockerHub]
1. [https://github.com/docker-library/redis/blob/7be79f51e29a009fefdc218c8479d340b8c4a5e1/5.0/Dockerfile](https://github.com/docker-library/redis/blob/7be79f51e29a009fefdc218c8479d340b8c4a5e1/5.0/Dockerfile) 

Docker 镜像方式，启动 Redis ，具体步骤：

```
# 1. 拉取镜像
docker pull redis

# 2. 查看镜像：镜像详情
docker image ls

# 2.1 分析镜像详情
docker inspcet redis

# 2.2 分析镜像分层命令
docker history redis

# 2.3 分析镜像分层命令（详细）
docker history redis --no-trunc

# 3. 启动镜像（参考下面链接中，Redis 的 Docker 镜像的主页，有详细说明）
--name: 容器命名为 some-redis
-d: 后台进程方式，启动容器
redis: 镜像名称
redis-server --appendonly yes: 启动容器之后，执行的 CMD 命令
docker run --name some-redis -d redis redis-server --appendonly yes

# 3.1 查询所有容器
docker container ls

# 3.2 启动容器时，设置配置参数，可以参考下面（Use redis Docker image 参考资料的说明）
https://hub.docker.com/_/redis?tab=description

# 4. 使用 redis-cli 连接到 Redis 实例：
docker run -it --link some-redis:redis --rm redis redis-cli -h redis -p 6379

# 4.1 连接到 Redis 服务器后，可以执行下述命令：查看所有的 key
keys *
```

具体 Docker 命令的操作：

* Docker 的基本命令，参考： [http://ningg.top/docker-series-01-basic-usage/](http://ningg.top/docker-series-01-basic-usage/)
* Use redis Docker image： [Redis Imager of DockerHub]


 
## 参考资料

* [https://redis.io/download](https://redis.io/download)






[NingG]:    http://ningg.github.com  "NingG"

[Redis Imager of DockerHub]:		https://hub.docker.com/_/redis?tab=description










