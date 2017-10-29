---
layout: post
title: MongoDB 系列：Mac 上安装启动 MongoDB
description: 一切操作，从搭建环境开始
published: true
category: mongodb
---

## 概要

解决几个问题：

1. 安装：Mac 上，安装 MongoDB
2. 使用：如何连接、登录，如何使用 MongoDB？

## MongoDB 初识

### 安装

直接登录到官网，从信息源头开始：

* [官网 https://www.mongodb.com/](https://www.mongodb.com/)
* [官网文档](https://docs.mongodb.com/manual/installation/)

在 Mac 下，按下述说明，进行安装：

* [Install MongoDB Community Edition on OS X](https://docs.mongodb.com/manual/tutorial/install-mongodb-on-os-x/)

直接使用 `homebrew` 来安装：

```
# 更新 brew 仓库
brew update

# 查询 mongodb
brew search mongodb

# 查看 mongodb 的版本
brew info mongodb

# 安装 mongodb
brew install mongodb
```

### 启动

安装之后，运行之前，需要先进行一些配置：

* 数据存储目录：`/data/db` 这是默认目录
* 权限：确保 mongo 程序有`目录`的`写权限`

启动 MongoDB

```
# 启动 mongo（使用默认数据目录 /data/db）
mongod

# 启动 mongo（使用指定的数据目录 MONGO_DATA_PATH）
mongod --dbpath MONGO_DATA_PATH
```

查看帮助手册：`mongod --help`

### 使用

启动 mongoDB 后，可以试用一下：

```
# 使用 MongoDB
mongo

# 帮助命令
mongo --help

// 帮助命令
mongos> help
  
// 选择 db 和 collection
mongos> use [db]
```

如果需要鉴权，使用下述命令：

```
// 连接到 mongo
mongo 10.1.200.229:27017/test -u *** -p *** -authenticationDatabase admin
```

其中：`authenticationDatabase` 设定`用户表`.



## 参考资料

* [官网 https://www.mongodb.com/](https://www.mongodb.com/)
* [官网文档](https://docs.mongodb.com/manual/installation/)
* [Install MongoDB Community Edition on OS X](https://docs.mongodb.com/manual/tutorial/install-mongodb-on-os-x/)










[NingG]:    http://ningg.github.com  "NingG"










