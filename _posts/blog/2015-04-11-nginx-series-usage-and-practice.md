---
layout: post
title: Nginx 系列：再探 Nginx，配置和实践
description: nginx 中关键的配置，实践上遇到哪些问题？
category: nginx
---

## 1. 背景

使用 nginx 时，一个关键点是如何配置 nginx，所有这些配置中， `--conf-path` 对应的配置文件是一个重点。

## 2. 查看 nginx 配置

通过如下命令，即可查看当前 nginx 的配置：

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

1. `--conf-path`：/usr/local/etc/nginx/nginx.conf 配置文件
1. `--http-log-path`：访问日志
1. `--error-log-path`：错误日志

## 3. nginx.conf 配置文件

前面我们知道了，/usr/local/etc/nginx/nginx.conf 是 nginx 服务运行过程中的具体配置文件。

这一部分，我们将通过剖析 nginx.conf 文件，弄清下面几点：

1. 设置端口？
1. 开启日志？修改日志存储路径？
1. 配置反向代理映射规则？

### 3.1. 文件内部结构

nginx.conf 文件的内部结构：

```
#user  nobody;
worker_processes  1;
 
#error_log  logs/error.log;
#error_log  logs/error.log  notice;
#error_log  logs/error.log  info;
 
#pid        logs/nginx.pid;
  
events {
    worker_connections  1024;
}
 
 
http {
    include       mime.types;
    default_type  application/octet-stream;
 
    #log_format  main  '$remote_addr - $remote_user [$time_local] "$request" '
    #                  '$status $body_bytes_sent "$http_referer" '
    #                  '"$http_user_agent" "$http_x_forwarded_for"';
 
    #access_log  logs/access.log  main;
 
    sendfile        on;
    #tcp_nopush     on;
 
    #keepalive_timeout  0;
    keepalive_timeout  65;
 
    #gzip  on;
 
    server {
        listen       8080;
        server_name  localhost;
 
        #charset koi8-r;
 
        #access_log  logs/host.access.log  main;
 
        location / {
            root   html;
            index  index.html index.htm;
        }
 
        #error_page  404              /404.html;
 
        # redirect server error pages to the static page /50x.html
        #
        error_page   500 502 503 504  /50x.html;
        location = /50x.html {
            root   html;
        }
 
        # proxy the PHP scripts to Apache listening on 127.0.0.1:80
        #
        #location ~ \.php$ {
        #    proxy_pass   http://127.0.0.1;
        #}
 
        # pass the PHP scripts to FastCGI server listening on 127.0.0.1:9000
        #
        #location ~ \.php$ {
        #    root           html;
        #    fastcgi_pass   127.0.0.1:9000;
        #    fastcgi_index  index.php;
        #    fastcgi_param  SCRIPT_FILENAME  /scripts$fastcgi_script_name;
        #    include        fastcgi_params;
        #}
 
        # deny access to .htaccess files, if Apache's document root
        # concurs with nginx's one
        #
        #location ~ /\.ht {
        #    deny  all;
        #}
    }
 
    # another virtual host using mix of IP-, name-, and port-based configuration
    #
    #server {
    #    listen       8000;
    #    listen       somename:8080;
    #    server_name  somename  alias  another.alias;
 
    #    location / {
    #        root   html;
    #        index  index.html index.htm;
    #    }
    #}
 
 
    # HTTPS server
    #
    #server {
    #    listen       443 ssl;
    #    server_name  localhost;
 
    #    ssl_certificate      cert.pem;
    #    ssl_certificate_key  cert.key;
 
    #    ssl_session_cache    shared:SSL:1m;
    #    ssl_session_timeout  5m;
 
    #    ssl_ciphers  HIGH:!aNULL:!MD5;
    #    ssl_prefer_server_ciphers  on;
 
    #    location / {
    #        root   html;
    #        index  index.html index.htm;
    #    }
    #}
    include servers/*;
}
```


nginx.conf 文件内部结构：

1. worker_processes
1. error_log
1. events
1. http
	1. access_log
	1. server
		1. listen 8080
		1. server_name localhost
		1. access_log
		1. location

注：https 时，上面的 server 配置略有不同。

### 3.2. 静态资源

系统设计时，动态资源、静态资源，要在 url 上能够区分出来，这样才能使用 nginx 为静态资源提供单独的映射关系。

举例：下面就是动静态资源分离的简单配置：

```
server {
    location / {
        root /data/www;
    }
 
    location /images/ {
        root /data;
    }
}
```

上面 location 内部配置 `root /data/www` 的含义：

1. root 表示：Sets the root directory for requests。
1. 把 request 的根目录指向 /data/www 目录。

### 3.3. 动态资源

对于动态资源，nginx 一般会把 request 转发到相应的服务器。
举例：下面把动态资源转发到其他服务器，静态资源直接指向本地：

```
server {
    location / {
        proxy_pass http://localhost:8080/;
    }
 
    location ~ \.(gif|jpg|png)$ {
        root /data/images;
    }
}
```

其中，location 使用了 proxy_pass 配置，当 proxy_pass 指向多个 ip 地址时，可以使用 server group 的配置，如下：

```
upstream backend {
    server backend1.example.com       weight=5;
    server backend2.example.com:8080;
    server unix:/tmp/backend3;
 
    server backup1.example.com:8080   backup;
    server backup2.example.com:8080   backup;
}
 
server {
    location / {
        proxy_pass http://backend;
    }
}
```

关于 proxy_pass， 更多细节参考：

1. [https://nginx.org/en/docs/http/ngx_http_proxy_module.html](https://nginx.org/en/docs/http/ngx_http_proxy_module.html)
1. [https://nginx.org/en/docs/http/ngx_http_upstream_module.html](https://nginx.org/en/docs/http/ngx_http_upstream_module.html)

备注：关于 location 的路径匹配，会单独写一个 wiki。

## 4. 实践

### 4.1. 目标

预期目标：

> 本地 nginx 使用 stash 上的 nginx 配置，对外提供服务。

### 4.2. 准备内容

准备内容：

* stash 上 nginx 配置文件

### 4.3. 启动 nginx

通过如下命令，在本地启动 nginx：

```
nginx -c /Users/guoning/Projects/Work/movie-nginx-conf/nginx.conf
```

### 4.4. 修改本地 hosts 配置

在本地 /private/etc/hosts 文件中，添加域名映射：

```
##
# Host Database
#
# localhost is used to configure the loopback interface
# when the system is booting.  Do not change this entry.
##
127.0.0.1   localhost
255.255.255.255 broadcasthost
::1             localhost
  
// 新增的域名映射
127.0.0.1   test.test.com
```

### 4.5. 本地访问对应域名

在本地访问 test.test.com 域名，即会使用本地的 nginx 服务。

### 4.6. 如何验证效果

如何确定就是本地 nginx 提供的服务呢？有 2 个方法：

#### 方法一：PING

在本地 ping test.test.com ，看看是否解析到本地

 
#### 方法二：观察访问日志

查看本地 nginx 服务器的访问日志，具体，针对 test.test.com 域名，查看其在 nginx 中设置的访问日志，

通过 tail 命令，查看访问日志的内容，即可确定，nginx 服务器是否能够正常提供服务。

### 4.7. 无法正常关闭 nginx 服务

如果通过 `nginx -s quit` 方式退出 nginx 服务时，出现如下异常：

```
// 终止 nginx 服务时，出现异常：
$ nginx -s quit
nginx: [error] open() "/usr/local/var/run/nginx.pid" failed (2: No such file or directory)
```

原因说明：

* 上面说无法找到 nginx 的 pid 文件，因此无法关闭 nginx 服务。通常是由于 nginx 默认配置的 pid 文件跟，nginx.conf 中指定的 pid 文件位置不统一。

解决办法：

1. 找到现有的 nginx.pid 文件
1. 创建一个 soft link 指向现有的 nginx.pid 文件

具体：

```
// 关闭 nginx 服务时，出现异常：
$ nginx -s quit
nginx: [error] open() "/usr/local/var/run/nginx.pid" failed (2: No such file or directory)
 
// 找到现有的 nginx.pid 文件
$ find / -name nginx.pid 2>/dev/null
/usr/local/Cellar/nginx/1.8.0/logs/nginx.pid
 
// 创建一个 soft link 指向现有的 nginx.pid 文件
$ sudo ln -s /usr/local/Cellar/nginx/1.8.0/logs/nginx.pid /usr/local/var/run/nginx.pid
 
// 再次尝试关闭 nginx
$ nginx -s quit
nginx: [alert] kill(1547, 3) failed (1: Operation not permitted)
 
// 切换身份，执行退出 nginx 服务命令
$ sudo nginx -s quit
```

更多细节参考： [http://stackoverflow.com/q/14176477](http://stackoverflow.com/q/14176477)

## 5. 参考资料

* [https://nginx.org/en/docs/beginners_guide.html](https://nginx.org/en/docs/beginners_guide.html)
* [https://nginx.org/en/docs/http/ngx_http_core_module.html](https://nginx.org/en/docs/http/ngx_http_core_module.html)
* [https://nginx.org/en/docs/http/ngx_http_proxy_module.html](https://nginx.org/en/docs/http/ngx_http_proxy_module.html)
* [https://nginx.org/en/docs/http/ngx_http_upstream_module.html](https://nginx.org/en/docs/http/ngx_http_upstream_module.html)
* [http://stackoverflow.com/q/14176477](http://stackoverflow.com/q/14176477)




[NingG]:    http://ningg.github.com  "NingG"
[Nginx开发从入门到精通]:		http://tengine.taobao.org/book/
[nginx doc]:		https://nginx.org/en/docs/
[nginx source code]:		https://github.com/nginx/nginx







