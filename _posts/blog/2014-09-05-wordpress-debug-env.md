---
layout: post
title: wordpress的开发调试环境
description: wordpress的最近几年来一直流行的博客平台，基于其可以快速建站，但要想较深入定制，就需要对其运行架构有个基本了解
category: wordpress
---

##背景

用wordpress建站，两个功能：一个是展示团队工作，另一个是方便其他人进来讨论。

初步立意：使用wordpress搭建两个网站，团队工作展示一个，讨论区一个；

##组件与安装

环境：Win 7，已经安装了JDK 6 和 JDK 7

下载软件清单如下：

* 下载XAMPP：[https://www.apachefriends.org/zh_cn/index.html](https://www.apachefriends.org/zh_cn/index.html) 版本：1.8.3；对应PHP: 5.5.1
* 下载eclipse for php：[http://www.eclipse.org/downloads/](http://www.eclipse.org/downloads/)  版本：eclipse-php-luna-R-win32-x86_64
* 下载wordpress：[http://cn.wordpress.org/](http://cn.wordpress.org/) 版本：3.9
* 下载主题：
	1. hum：[http://wordpress.org/extend/themes/hum/](http://wordpress.org/extend/themes/hum/) 版本：0.2.1
	2. twenty eleven：[http://wordpress.org/themes/twentyeleven](http://wordpress.org/themes/twentyeleven) 版本：1.9
* 下载JDK：[Oracle JDK(Sun)](http://www.oracle.com/technetwork/java/javase/downloads/index.html) 版本：JDK 7u67

依次安装：

1. XAMPP：wordpress的运行环境
2. wordpress，并为其配置主题：
	* twenty eleven
	* hum
3. eclipse：将整个wordpress文件夹，新建为PHP Project；
	


##配置

设计搭建其调试环境所需要的基本配置。

###基本配置

主要是Apache、MySQL、PHP相关：

* 设置MySQL的root密码，两种方式都可以：
	1. CMD的命令行；
	2. myphpAdmin图形界面；

###主题配置

主要是为成功安装主题，所需要进行的配置。

* wordpress
	1. 取消twenty eleven主题中google front（因为google被墙了）



##调试

调试是学习一个框架/语言较快的方式，这一部分将着重介绍如何进行调试。关注几点：

* 如何进行调试；
* PHP web基本处理逻辑；
* wordpress中使用了哪些巧妙的设计，使其流行数年；






[NingG]:    http://ningg.github.com  "NingG"
