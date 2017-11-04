---
layout: post
title: Scrapy 系列：Scrapy 爬取 Weibo 数据简单 demo 试用
description: 在具体场景下，试用一下 Scrapy
published: true
category: scrapy
---

## 概要

几个方面：

1. 配置：[SinaSpider](https://github.com/LiuXingMing/SinaSpider)
2. 启动：SinaSpider，来抓取微博数据


## SinaSpider

几个方面：

1. 配置
2. 使用

### 配置

具体操作：

```
# 下载源码
git clone git@github.com:LiuXingMing/SinaSpider.git
```

### 使用

2 个方面：

1. 基础环境： Mongo、Redis
2. 启动 SinaSpider

具体操作：

```
# 启动 Mongo
mongod

# 启动 Redis
src/redis-server

# 启动 SinaSpider
cd Sina_spider3
python launch.py
```

备注：

* Mac 下安装 Redis：[ningg.top](ningg.top) 中其他文章
* Mac 下安装 Mongo：[ningg.top](ningg.top) 中其他文章


## 参考资料

* [Scrapy-GitHub](https://github.com/scrapy/scrapy)











































[NingG]:    http://ningg.github.com  "NingG"










