---
layout: post
title: Flume 1.5.0.1：windows下安装Flume agent
description: Windows下安装配置Flume
category: flume
---

## 背景

最近要采集windows下的数据，希望能用Flume来进行采集汇总，但是不知道Flume在windows下的兼容性怎么样，OK，测试一下。


## 在windows下配置Flume

### 系统环境

相关版本信息：

* Flume：apache-flume-1.5.0.1-bin.tar.gz
* windows：Microsoft Windows Server 2008 R2 Enterprise（x64-based PC）


### 解决办法

* 下载`apache-flume-1.5.0.1-bin.tar.gz`*（当前的最新版本，之后的版本应该也是可以的）*
* 解压之后，在`conf`目录下创建文件``


### windows下tail命令

至此为止，windows上，已经成功部署了flume。

## 思路

> 截止上一部分，已经实现了Windows下flume的部署，这一部分主要是闲谈点其他的东西。

[官方文档][Flume 1.5 User Guide]上，看了一下，没有说windows上部署的问题；再查看flume的启动脚本，只有一个脚本`flume-ng`，而且是bash写的。凭借自己对flume官方文档的一些了解，基本没有提及windows上安装部署的问题；Flume是ASF下的项目，通过[官网][How to Get Involved]知道，Flume的开发、讨论都在[Flume JIRA][Flume JIRA]上；抓紧上去查一下，看看有没有人提到：windows下flume的安装配置问题，找到两个主要相关内容：[FLUME-1334][FLUME-1334]和[FLUME-1335][FLUME-1335]。大概理解一下，奥，原来一帮engineer在讨论Flume直接运行在windows的问题，他们的目标大意是：利用一个脚本，直接在windows安装、启动flume服务。而且已经有人提供了一些patch，当前初步打算，**利用这些patch来更新当前flume代码，并且在本地进行试用**。

情况总是变化的，查看[FLUME-1335][FLUME-1335]时，看到其下面评论[run flume 13x on win][run flume 13x on win]；同时在google上搜索`flume windows`，看到了几个地方：

* [build flume 13x up on windows][build flume 13x up on windows]
* [windows下编译flume 1.3.1][windows下编译flume 1.3.1]

上面看到，[apache的官网][build flume 13x up on windows]在2012-12也提到在windows下编译、运行flume，所以当即决定，参照[apache的官网][build flume 13x up on windows]来进行windows下flume的编译和安装配置。

总结一下上面的思路：

* 官方文档、官方讨论交流区发现patch；（最新）
* 官方早期文档、其他开发人员提供windows下flume编译、配置；（较旧）
* 采用[官方早期文档][build flume 13x up on windows]进行windows下编译、配置；
* 结果：发现flume 1.5.0.1版本，不需要在windows下编译，直接进行配置，也能启动flume；








## 参考来源







## 杂谈

说出解决问题的思路，这种分享精神，我自己都感动到了。







[NingG]:    						http://ningg.github.com  "NingG"
[Flume JIRA]:						https://issues.apache.org/jira/browse/FLUME
[Flume 1.5 User Guide]:				http://flume.apache.org/FlumeUserGuide.html
[How to Get Involved]:				http://flume.apache.org/getinvolved.html
[FLUME-1335]:						https://issues.apache.org/jira/browse/FLUME-1335
[FLUME-1334]:						https://issues.apache.org/jira/browse/FLUME-1334
[run flume 13x on win]:				http://mapredit.blogspot.de/2012/07/run-flume-13x-on-windows.html
[build flume 13x up on windows]:	https://cwiki.apache.org/confluence/display/FLUME/Build+Flume+1.3.x+up+on+Windows
[windows下编译flume 1.3.1]:			http://abloz.com/2013/02/18/compile-under-windows-flume-1-3-1.html


