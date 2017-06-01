---
layout: post
title: 工具系列：IntelliJ IDEA (Mac) 运行速度优化
description: Mac 下，IntelliJ IDEA 运行速度过慢，可以优化一下
category: tool 
---



## 1. 背景

IDEA 下运行程序，经常假死 5 s，作为 Mac 怎么能允许暂停 5s 的世界？

考虑优化一下，操作流畅，心情才会愉悦。

## 2. IDEA 优化配置

### 2.1. JVM 参数配置

打开 idea，菜单 --> help --> edit custom vm options，调整参数，重启即可。

具体调整参数：

```
-Xms2g
-Xmx2g
-XX:ReservedCodeCacheSize=1024m
-XX:+UseCompressedOops
```

### 2.2. debug 速度优化

debug 速度很慢，但是 run 速度很快，常见原因，有 2 类：

1. 在 method 上添加了断点
	* 解决办法：删除断点，debug 启动之后，再添加断点；或者把断点添加到 method 内部，而不是添加再 method 的签名处；
1. 本地 hosts 文件，需要更新
	* 解决办法：命令终端中，直接执行：`scutil --set HostName "localhost"` 命令

具体命令：

```
# solution: mac idea debug restart very slow
scutil --set HostName "localhost"
```

## 3. 参考来源


1. [http://blog.mkfree.com/posts/227](http://blog.mkfree.com/posts/227)





















[NingG]:    http://ningg.github.com  "NingG"
