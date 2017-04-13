---
layout: post
title: 服务器并发模型
description: 服务器如何多个客户端？
published: true
categories: linux
---

典型问题：

* 多个 Client 同时连接 Server 时，Server 如何提供服务？
* 上述场景，更进一步，Server 如何提供高效的服务？Client 能够尽快获得响应

之前提到过 Linux 下 IO 模型，解决：应用程序如何高效率的读写多个文件？文件：普通文件、网络连接。Linux 下常见的 IO 模型：

* Blocking IO
* Non-blocking IO
* IO Multiplexing
* Asynchronous IO

在读写文件过程中，







































[NingG]:    http://ningg.github.com  "NingG"










