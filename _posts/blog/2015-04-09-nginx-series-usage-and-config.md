---
layout: post
title: Nginx 系列：初识 Nginx，使用和配置
description: 如何使用 Nginx，其中的关键配置有哪些
category: nginx
---

## 1. 背景

本地 Mac 上，已经安装了 nginx 服务器，几个基本的问题：

1. 如何启动、终止 nginx 服务？
1. nginx 有哪些基本的配置，需要注意？
	1. 设置端口？
	1. 开启日志？修改日志存储路径？
	1. 配置反向代理映射规则？

预期目标：

> 本地 nginx 如何使用 stash 上的 nginx 配置，对外提供服务？具体操作，参考：《再探 nginx：配置和实践》

## 2. nginx 的启动和终止

通过 man 命令查询 nginx 命令的使用说明。

```
// 查看 nginx 命令的使用说明
man nginx
```

具体效果，如下：

![](/images/nginx-series/man-nginx-cmd.png)

具体 nginx 服务的启动和终止命令：

```
// 启动 nginx
$ nginx
  
// 查看 nginx 的执行状态
$ ps -ef | grep nginx
  501  1045     1   0  4:18下午 ??         0:00.00 nginx: master process nginx
  501  1046  1045   0  4:18下午 ??         0:00.00 nginx: worker process
  501  1048   627   0  4:18下午 ttys000    0:00.00 grep nginx
  
// 关闭 nginx 服务
$ nginx -s quit
```

补充说明：

1. 使用命令：nginx 启动服务。
1. 使用命令：`nginx -s [signal]` 方式，操作 nginx 服务。
1. signal 详解：
	1. stop — fast shutdown
	1. quit — graceful shutdown
	1. reload — reloading the configuration file （重新加载配置文件）
	1. reopen — reopening the log files

疑惑：

> 1. 启动 Nginx 服务时，如何能够实时输出启动文档？观察启动过程？查看启动日志？
> 2. Nginx 对外提供服务时，如何查看 http 请求记录？

思考： 上面的本质是说 nginx 的 2 类日志，错误日志、访问日志。


## 3. nginx 服务的配置

### 3.1. 探索 nginx 命令的启动过程

通过命令，逐步探索 nginx 命令的启动过程：

1. nginx 命令的安装位置？
1. nginx 服务器的安装位置？
1. nginx 命令的具体执行过程？

通用的命令排查思路如下：

```
// 查看 nginx 命令的位置
$ which nginx
/usr/local/bin/nginx
  
// 确定 nginx 命令的真正位置
$ ll /usr/local/bin/nginx
lrwxr-xr-x  1 guoning  admin    31B  8 13 15:58 /usr/local/bin/nginx -> ../Cellar/nginx/1.8.0/bin/nginx
```

具体效果如下：

![](/images/nginx-series/nginx-cmd-specific-script.png)

很遗憾，找到 nginx 命令的执行文件，并不是 shell 脚本，因此，无法通过执行文件查看 nginx 命令的具体执行过程。

### 3.2. 查看 nginx 的配置

如何查看 nginx 的当前配置呢？man nginx 能够查询到结果。

```
// 查看当前 nginx 的配置
$ nginx -V
 
nginx version: nginx/1.8.0
built by clang 7.0.0 (clang-700.0.72)
built with OpenSSL 1.0.2d 9 Jul 2015
TLS SNI support enabled
 
configure arguments:
--prefix=/usr/local/Cellar/nginx/1.8.0
--with-http_ssl_module
--with-pcre
--with-ipv6
--sbin-path=/usr/local/Cellar/nginx/1.8.0/bin/nginx
--with-cc-opt='-I/usr/local/Cellar/pcre/8.37/include -I/usr/local/Cellar/openssl/1.0.2d_1/include'
--with-ld-opt='-L/usr/local/Cellar/pcre/8.37/lib -L/usr/local/Cellar/openssl/1.0.2d_1/lib'
--conf-path=/usr/local/etc/nginx/nginx.conf
--pid-path=/usr/local/var/run/nginx.pid
--lock-path=/usr/local/var/run/nginx.lock
--http-client-body-temp-path=/usr/local/var/run/nginx/client_body_temp
--http-proxy-temp-path=/usr/local/var/run/nginx/proxy_temp
--http-fastcgi-temp-path=/usr/local/var/run/nginx/fastcgi_temp
--http-uwsgi-temp-path=/usr/local/var/run/nginx/uwsgi_temp
--http-scgi-temp-path=/usr/local/var/run/nginx/scgi_temp
--http-log-path=/usr/local/var/log/nginx/access.log
--error-log-path=/usr/local/var/log/nginx/error.log
--with-http_gzip_static_module
```

注意上面的几个配置：

1. `--conf-path`：配置文件
1. `--http-log-path`：访问日志
1. `--error-log-path`：错误日志

疑问：

* 如何查看正在运行的 nginx 服务器配置？

### 3.3. 配置 nginx

nginx 能够提供几个基本功能：

1. 静态文件服务：响应静态文件的请求
1. 反向代理：设定 url 映射规则

关键看 --conf-path 对应的配置文件了，准备单独写一篇 wiki，详细说一下。

看这里：[再探 nginx：配置和实践](/nginx-series-usage-and-practice/)

## 4. 附录：补充内容

### 4.1. 代理 vs. 反向代理

都是代理，代理有什么好处？

1. 屏蔽细节
1. 进行通用处理：高效

简单科普：代理（proxy） vs. 反向代理（reverse proxy）

1. 代理：
	1. 从 Client 角度出发
	1. Client 感知 proxy 存在， Client 上指定 proxy 的地址
	1. Client 从 Internet 中请求内容时，让 proxy 进行请求的转发
1. 反向代理：
	1. 从 Server 角度出发
	1. Server 向外提供服务时，不直接提供服务，reverse proxy 对外提供服务
	1. reverse proxy 收到 Client 的请求后，会转发到相应的 Server 上

具体效果：

![](/images/nginx-series/proxy-and-reverse-proxy.png)
 
## 5. 参考资料

* `man nginx`：nginx 命令手册
* [Beginner Guide](https://nginx.org/en/docs/beginners_guide.html)
* [nginx control](https://nginx.org/en/docs/control.html)






[NingG]:    http://ningg.github.com  "NingG"
[Nginx开发从入门到精通]:		http://tengine.taobao.org/book/
[nginx doc]:		https://nginx.org/en/docs/
[nginx source code]:		https://github.com/nginx/nginx







