---
layout: post
title: Nginx 系列：Nginx 原理
description: Nginx 性能有多高？为什么高性能？HTTP 请求的完整处理流程
category: nginx
---





## 常见问题剖析

### Nginx vs. Apache

nginx vs. apache：

* [http://www.oschina.net/translate/nginx-vs-apache](http://www.oschina.net/translate/nginx-vs-apache)

网络 IO 模型：

1. nginx：epoll(freebsd 上是 kqueue )
	1. 高性能
	1. 高并发
	1. 占用系统资源少
1. apache：select
	1. 更稳定，bug 少
	1. 模块更丰富
 
参考：[https://www.zhihu.com/question/19571087](https://www.zhihu.com/question/19571087)




[NingG]:    http://ningg.github.com  "NingG"
[Nginx开发从入门到精通]:		http://tengine.taobao.org/book/
[nginx doc]:		https://nginx.org/en/docs/
[nginx source code]:		https://github.com/nginx/nginx







