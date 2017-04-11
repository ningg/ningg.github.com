---
layout: post
title: Nginx 系列：健康检查
description: 检测服务节点存活状态，完成服务的自动注册和异常节点的自动摘除。
category: nginx
---

## 0. 背景
**服务治理**的一个重要任务是感知服务节点变更，完成`服务自动注册`及`异常节点的自动摘除`。这就需要服务治理平台能够：`及时`、`准确`的感知service节点的健康状况。

## 1. 方案概述

Nginx 提供了三种HTTP服务健康检查方案供用户选择：

1. **TCP层默认检查方案**：定时与后端服务建立一条`tcp连接`，链接建立成功则认为服务节点是健康的。
2. **HTTP层默认检查方案**：TCP层检查有一定的局限性：
	1. 很多**HTTP服务是带状态**的，端口处于listen状态并不能代表服务已经完成预热；
	2. **不能真实反映**服务内部**处理逻辑**是否产生拥堵。
	3. 这时可以选择`http层`健康检查，会向服务发送一个http请求`GET / HTTP/1.0\r\n\r\n`，返回状态是2xx或3xx时认为后端服务正常。
3. 自定义方案：可根据下文描述自定义检查方案。

## 2. 配置参数详解

一个常用的健康检查配置如下：

```
check fall=3 interval=3000 rise=2 timeout=2000 type=http;
check_http_expect_alive http_2xx http_3xx ;
check_http_send "GET /checkAlive HTTP/1.0\r\n\r\n" ;
```
下面针对每个配置参数，进行详细介绍。

### 2.1 check

check 字段参数如下：

```
Syntax: check interval=milliseconds [fall=count] [rise=count] [timeout=milliseconds] [default_down=true|false] [type=tcp|http|ssl_hello|mysql|ajp] [port=check_port]
Default: 如果没有配置参数，默认值是：interval=30000 fall=5 rise=2 timeout=1000 default_down=true type=tcp
```

`check` 字段各个参数含义如下：

* `interval`：向后端发送的健康检查包的间隔。
* `fall(fall_count)`: 如果连续失败次数达到fall_count，服务器就被认为是down。
* `rise(rise_count)`: 如果连续成功次数达到rise_count，服务器就被认为是up。
* `timeout`: 后端健康请求的超时时间。
* `default_down`: 设定初始时服务器的状态，如果是true，就说明默认是down的，如果是false，就是up的。默认值是true，也就是一开始服务器认为是不可用，要等健康检查包达到一定成功次数以后才会被认为是健康的。
* `type`：健康检查包的类型，现在支持以下多种类型
	* `tcp`：简单的tcp连接，如果连接成功，就说明后端正常。
	* `ssl_hello`：发送一个初始的SSL hello包并接受服务器的SSL hello包。
	* `http`：发送HTTP请求，通过后端的回复包的状态来判断后端是否存活。
	* `mysql`: 向mysql服务器连接，通过接收服务器的greeting包来判断后端是否存活。
	* `ajp`：向后端发送AJP协议的Cping包，通过接收Cpong包来判断后端是否存活。
	* `port`: 指定后端服务器的检查端口。可以指定不同于真实服务的后端服务器的端口，比如后端提供的是443端口的应用，你可以去检查80端口的状态来判断后端健康状况。默认是0，表示跟后端server提供真实服务的端口一样。


### 2.2 check_http_expect_alive

`check_http_expect_alive` 指定主动健康检查时HTTP回复的成功状态：

```
Syntax: check_http_expect_alive [ http_2xx | http_3xx | http_4xx | http_5xx ]
Default: http_2xx | http_3xx
```

### 2.3 check_http_send 

`check_http_send` 配置http健康检查包发送的请求内容

为了减少传输数据量，推荐采用"HEAD"方法。当采用长连接进行健康检查时，需在该指令中添加keep-alive请求头，如："HEAD / HTTP/1.1\r\nConnection: keep-alive\r\n\r\n"。 同时，在采用"GET"方法的情况下，请求uri的size不宜过大，确保可以在1个interval内传输完成，否则会被健康检查模块视为后端服务器或网络异常。

```
Syntax: check_http_send http_packet
Default: "GET / HTTP/1.0\r\n\r\n"
```

## 3. 完整示例

完整示例，如下：

```
http {
    upstream cluster1 {
        # simple round-robin
        server 192.168.0.1:80;
        server 192.168.0.2:80;
        check interval=3000 rise=2 fall=5 timeout=1000 type=http;
        check_http_send "HEAD / HTTP/1.0\r\n\r\n";
        check_http_expect_alive http_2xx http_3xx;
    }
    upstream cluster2 {
        # simple round-robin
        server 192.168.0.3:80;
        server 192.168.0.4:80;
        check interval=3000 rise=2 fall=5 timeout=1000 type=http;
        check_keepalive_requests 100;
        check_http_send "HEAD / HTTP/1.1\r\nConnection: keep-alive\r\n\r\n";
        check_http_expect_alive http_2xx http_3xx;
    }
    server {
        listen 80;
        location /1 {
            proxy_pass http://cluster1;
        }
        location /2 {
            proxy_pass http://cluster2;
        }
        location /status {
            check_status;
            access_log   off;
            allow SOME.IP.ADD.RESS;
            deny all;
        }
    }
}
```
 
## 4. 参考文档

* [TEngine：http_upstream_check_cn](http://tengine.taobao.org/document_cn/http_upstream_check_cn.html)




[NingG]:    http://ningg.github.com  "NingG"
[Nginx开发从入门到精通]:		http://tengine.taobao.org/book/
[nginx doc]:		https://nginx.org/en/docs/
[nginx source code]:		https://github.com/nginx/nginx







