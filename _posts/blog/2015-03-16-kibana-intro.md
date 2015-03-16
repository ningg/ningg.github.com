---
layout: post
title: Kibana入门操作
description: 常用操作入门
category: kibana
---

当前使用组件的版本：

|组件|版本|
|----|----|
|ElasticSearch|`1.4.4`|
|Java| `1.7.0_67` HotSpot(64) 64-Bit|
|Kibana|`kibana-4.0.1-linux-x64`|



##启动

Kibana本质就是一个Web工程，启动命令：`bin/kibana`，具体查看启动脚本，发现最终启动的是NodeJS相关的服务：`bin/../node/bin/node bin/../src/bin/kibana.js`，NodeJS我不懂，具体没看明白。几个疑问：

* 如何后台启动Kibana？
	* `nohup bin/kibana &`
* Kibana运行日志位置？
* 如何监控Kibana运行状态？























[NingG]:    http://ningg.github.com  "NingG"

















