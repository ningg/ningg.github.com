---
layout: post
title: Cygwin下常用安装包
description: Win 7 下使用Cygwin时，常见问题
published: true
category: linux
---

本来不想用Cygwin的，条件限制，需要早Windows 7 下进行一些Linux操作，装虚拟机太耗系统资源，就安了个Cygwin，既然要用，那就整理个小笔记吧，避免今后再用的时候忘记。


##下载

到[Cygwin 官网][Cygwin 官网]上直接下载即可；



##安装包


|命令|安装包|
|:----|:----|
|wget|wget|
|clear|ncurses |
|curl|curl |
|top\free|procps|
|vim|vim|


##常见问题

###Cygwin下能够使用CMD下的命令？

可以，Cygwin下，能够直接使用Win OS下配置的环境变量指向的命令。


###Cygwin下能够直接启动shell脚本吗？

能，而且建议这样做，例如，Tomcat，以`$TOMCAT_HOME/bin/startup.sh`的方式启动。
















##参考来源

* [Cygwin 官网][Cygwin 官网]












[NingG]:    http://ningg.github.com  "NingG"

[Cygwin 官网]:		https://www.cygwin.com/









