---
layout: post
title: Nginx 系列：安装 Nginx
description: 琢磨原理之前，先安装一个
category: nginx
---

## 1. 背景

要理解一个东西，最好的方式就是接触和尝试，因此要在本地安装一个 Nginx

## 2. 安装 nginx

到 nginx 官网看了一下：[https://nginx.org/en/docs/install.html](https://nginx.org/en/docs/install.html) 其中说明里 Linux 下，nginx 的安装步骤，但是没有说 Mac 环境怎么安装 nginx。

### 2.1. Mac 下， 安装 nginx

Note：如果没有安装 brew， 则，参考 [http://brew.sh/](http://brew.sh/) 先安装 brew。

在 Mac 下，通过 brew 查看 nginx 详情：

```
// 查询 nginx
guoningdeMacBook-Pro:~ guoning$ brew search nginx
nginx
  
// 查看 nginx 模块的详情, 以及安装情况
guoningdeMacBook-Pro:~ guoning$ brew info nginx
nginx: stable 1.8.0 (bottled), devel 1.9.5, HEAD
HTTP(S) server and reverse proxy, and IMAP/POP3 proxy server
http://nginx.org/
Not installed
```  
 
通过 brew 安装 nginx：

```
// 安装 nginx （下面有一大段的 nginx 使用说明信息）
guoningdeMacBook-Pro:~ guoning$ brew install nginx
 
 
....
 
 
Docroot is: /usr/local/var/www
 
The default port has been set in /usr/local/etc/nginx/nginx.conf to 8080 so that
nginx can run without sudo.
 
nginx will load all files in /usr/local/etc/nginx/servers/.
 
To have launchd start nginx at login:
  ln -sfv /usr/local/opt/nginx/*.plist ~/Library/LaunchAgents
Then to load nginx now:
  launchctl load ~/Library/LaunchAgents/homebrew.mxcl.nginx.plist
Or, if you don't want/need launchctl, you can just run:
  nginx
==> Summary
/usr/local/Cellar/nginx/1.8.0: 7 files, 964K
```

 
## 2. 参考资料

* [https://segmentfault.com/a/1190000002963355](https://segmentfault.com/a/1190000002963355)
* [http://brew.sh/](http://brew.sh/)











[NingG]:    http://ningg.github.com  "NingG"
[Nginx开发从入门到精通]:		http://tengine.taobao.org/book/
[nginx doc]:		https://nginx.org/en/docs/
[nginx source code]:		https://github.com/nginx/nginx







