---
layout: post
title: Sentry 系列：简介
description: Sentry 是业务异常日志的收集、聚合、展示平台，能辅助研发快速定位异常，修复线上问题
published: true
category: sentry
---



`Sentry` 本身是：错误日志的`聚合`、`展现`、`搜索`平台。

Sentry 本身不包含日志收集，但其依赖 SDK 将各自语言、环境的错误发送给 Sentry，由 Sentry 统一对错误信息：

1. **分类**
1. **采样存储**：（疑问：如何采样？采样频率？默认是全量存储的）
1. **阈值报警**：（疑问：如何设置阈值？如何报警？）

通过不同语言的 `SDK`，完成错误日志收集：

1. **统一格式**：统一了错误日志格式
1. **屏蔽细节**：屏蔽日志收集实现细节
1. **运维**：不同语言，如何进行 SDK 升级？需要逐个服务，手动升级
1. **隔离性**：Sentry 服务异常，client SDK 是否会影响正常的应用服务？需要 client 侧设置队列长度和拒绝策略
1. **扩展性**：用户登陆，如何对接到 sso？这个主要是 Sentry 管理后台的登录问题，不涉及 Sentry 服务端



Sentry 关联资料：

* Sentry 官网：[https://sentry.io/welcome/](https://sentry.io/welcome/)
* Sentry 服务端安装：[Self-Hosted Sentry](https://docs.sentry.io/server/)

















[NingG]:    http://ningg.github.com  "NingG"














