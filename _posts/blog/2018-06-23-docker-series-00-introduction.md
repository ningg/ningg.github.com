---
layout: post
title: Docker 系列：简介 & 安装 & 使用
description: Docker 是什么？用来解决什么问题？官方网站在哪里？如何安装和启动？
published: true
category: docker
---

## 概要

几个问题：

* Docker 是什么？解决什么问题？
* Docker 相关的信息源：官网？版本迭代跟踪？源码库？
* Docker 的安装和简单使用？

## Docker 是什么？

从官网 [https://www.docker.com/](https://www.docker.com/) 开始，首页中看到几个重要信息：

* [What is Docker?](https://www.docker.com/what-docker)
* [Product](https://www.docker.com/get-docker)
* [Community](https://www.docker.com/docker-community)
* Support：
	* [Customer Portal](https://success.docker.com/)
	* [Documentation](https://docs.docker.com/)
	* [Support](https://success.docker.com/support)

OK，最权威、最齐全的信息，就从上面这些链接上开始了。


### Docker 是什么

Docker 是什么？

* 是一家公司，容器平台提供商
* 也是`容器平台`的解决方案
* 为研发、运维，解决大部分部署环境差异
* 方便进行灵活的服务编排

### Docker 的版本

Docker 的版本，有 2 个：

* 企业版：DOCKER ENTERPRISE EDITION (EE)
* 社区版：DOCKER COMMUNITY EDITION (CE)

他们提供的支持和扩展，存在差异，更多细节参考 [Docker 的版本](https://www.docker.com/get-docker)

备注，截止写 blog 的时候， Docker 最新版本为 `1.18`

### Docker 社区

Docker 社区：[Community](https://www.docker.com/docker-community) 提供了 3 方面的信息：

* [Community Group](https://community.docker.com/registrations/groups/4316)：发烧友集中营，尝试新特性、分享新观点
* [Forums](https://forums.docker.com/)：通用问题讨论
* [Blogs](https://blog.docker.com/)：官网的一些博客，技术性不太强

### Docker 入门课程

特别要说明的是 [Community](https://www.docker.com/docker-community) 提供了一个学习课程：

* [Play with Docker Classroom](https://training.play-with-docker.com/)
* 补充信息：[Full list of individual labs](https://training.play-with-docker.com/alacart/)

上面的资料，有一定的逻辑组织关系，可以作为 Docker 入门资料学习下。



### Docker vs. Moby

Docker 公司，借助 Moby ，提出 `容器平台` 的**构建规范**：

* [全面解读Moby和LinuxKit，Docker称沟通不善招致误解](http://www.infoq.com/cn/news/2017/05/Moby-LinuxKit-Docker)
* [Moby Project 官网](http://www.mobyproject.org/)
* [Moby 源码](https://github.com/moby/moby)



## Docker 的信息源

主要分为 2 个方面：

1. 官网 & 代码
1. 手册

### 官网 & 代码 & 版本迭代

几个方面：

* **官网**：
	* [https://www.docker.com/](https://www.docker.com/)
* **版本迭代跟踪**：涵盖每个版本的 feature list
	* [Docker CE](https://github.com/docker/docker-ce)
	* [Docker CE 每个版本的 feature list](https://github.com/docker/docker-ce/releases)
* **源码库**：
	* [Docker CE](https://github.com/docker/docker-ce)
* **参考手册** & **问题支持**：
	* [Documentation](https://docs.docker.com/)
	* [Support](https://success.docker.com/support)


### 手册

具体手册，2 个地方都可以查：

* 官网：[Documentation](https://docs.docker.com/)
* GitHub Page：[https://docker.github.io/](https://docker.github.io/)

上述 2 个地方的手册，内容是完全相同的，涵盖几个方面：

* [Guides](https://docker.github.io/)： 手册首页，可以切换 Docker 手册的版本
* [Product Manuals](https://docker.github.io/ee/)：主要是针对 EE 版本，进行界面化操作的介绍
* [Glossary](https://docker.github.io/glossary/)：术语表
* [Reference](https://docker.github.io/reference/)：指导手册，包含 
	* File formats
	* Command-line interfaces (CLIs)
	* Application programming interfaces (APIs)
	* Drivers and specifications
* [Samples](https://docker.github.io/samples/)：各类场景的操作示例


## 安装 & 使用

直接按照 [Documentation](https://docs.docker.com/) 中 [Get Started](https://docker.github.io/get-started/)，逐步阅读并操作即可。



## 参考资料

* 官网：[https://www.docker.com/](https://www.docker.com/)












[NingG]:    http://ningg.github.com  "NingG"
