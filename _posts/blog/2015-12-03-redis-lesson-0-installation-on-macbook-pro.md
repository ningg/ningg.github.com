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

 
## 参考资料

* [https://redis.io/download](https://redis.io/download)






[NingG]:    http://ningg.github.com  "NingG"










