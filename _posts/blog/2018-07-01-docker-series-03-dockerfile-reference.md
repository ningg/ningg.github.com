---
layout: post
title: Docker 系列：Dockerfile 参考手册
description: Dockerfile 有什么作用？可靠的信息源在哪？哪些最佳实践？
published: true
category: docker
---

## 概要

Dockerfile 是：制作 image 的描述文件，例如：

1. 基于某个 image？
2. 进行哪些操作？
3. 生成一个特定的 image

关于 Dockerfile 文件，有几个问题：

1. **对内**：制作 image 的描述文件，有哪些`命令` or `操作`？分为几类？按什么维度分类？
2. **对外**：已经有了 Dockerfile，如何制作 image？具体的操作步骤？

使用 Dockerfile，是一个不断积累、沉淀的过程，这篇 blog 不做大而全的讨论和描述，而用于：

1. 信息源：靠谱的信息源，一般是官方网站，以及极少数的业界经验；
2. 实践沉淀：记录使用 Dockerfile 过程中的一些常见问题和实践；

## Dockerfile

几个方面：

* 信息源：可靠的信息来源
* 入门实例：一个 dockerfile 最简单的入门实例


### 信息源

Dockerfile 的信息源：

* [Dockerfile reference](https://docs.docker.com/engine/reference/builder/)
* [Best practices for writing Dockerfiles](https://docs.docker.com/develop/develop-images/dockerfile_best-practices/)

更多关联信息：

[Develop with Docker](https://docs.docker.com/develop/develop-images/dockerfile_best-practices/)：

* Develop your apps on Docker
	* App development overview
	* App development best practices
	* Develop images
		* [Best practices for writing Dockerfiles](https://docs.docker.com/develop/develop-images/dockerfile_best-practices/)
		* [Create a base image](https://docs.docker.com/develop/develop-images/baseimages/)
		* [Use multi-stage builds](https://docs.docker.com/develop/develop-images/multistage-build/)
		* [Dockerfile reference](https://docs.docker.com/engine/reference/builder/)
		* [Manage images](https://docs.docker.com/develop/develop-images/image_management/)
	* [Docker app examples](https://docs.docker.com/samples/)

### 入门实例


TODO 参考：

* [Create a base image](https://docs.docker.com/develop/develop-images/baseimages/)
* [Use multi-stage builds](https://docs.docker.com/develop/develop-images/multistage-build/)





## 实践积累

TODO：使用 Dockerfile 的沉淀积累.










## 参考资料

* [Dockerfile reference](https://docs.docker.com/engine/reference/builder/)
* [Best practices for writing Dockerfiles](https://docs.docker.com/develop/develop-images/dockerfile_best-practices/)
* [Docker Reference：Docker 的所有关联手册](https://docs.docker.com/reference/)











[NingG]:    http://ningg.github.com  "NingG"
