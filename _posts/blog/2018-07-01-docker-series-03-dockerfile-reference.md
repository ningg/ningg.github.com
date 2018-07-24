---
layout: post
title: Docker 系列：Dockerfile 参考手册
description: Dockerfile 有什么作用？可靠的信息源在哪？哪些最佳实践？
published: true
category: docker
---

## 概要

Dockerfile 是：创建 image 的描述文件，用于快速制作镜像，例如：

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
* 基本结构：Dockerfile 由哪些内容构成
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

### 基本结构

Dockerfile 是制作镜像的描述文件：

* 由多行命令组成
* 通过 `#` 构成单行注释
* 一般包含 4 部分：
	* `基础镜像`信息：`FROM [IMAGE]`
	* 维护者信息：`MAINTAINER ...`
	* 镜像`操作命令`：`RUM [CMD]`，每运行一条 RUN 命令，镜像就添加新的一层，并提交
	* **容器启动**时，`执行的命令`：`CMD [CMD]`

### 指令说明

Dockerfile 中，可以包含多种指令，每种指令的含义：

|选项|	用法|	说明|
|:----|:----|:----|
|FROM|`FROM <image>:<tag>`|	指定基础镜像|
|MAINTAINER|	`MAINTAINER <name> <email>`|创建者信息|
|RUN|`RUN <command>`|执行容器操作，主要用来安装软件|
|CMD|`CMD ["executable","param1","param2"]` 或 `CMD command param1 param2` 或 `CMD ["param1","param2"]` (作为ENTRYPOINT的参数)|镜像启动时的操作，会被容器的启动命令覆盖。指定多次则最后一条生效|
|ENTRYPOINT|同 CMD，与CMD差别主要在于其在容器启动时不会被覆盖|启动容器执行的命令，CMD可为其提供参数。指定多次则最后一条生效，如果之后的CMD是完整指令则会被其覆盖。|
|USER|`USER daemon`|指定容器的用户，默认为 root|
|EXPOSE|`EXPOSE <port> <port> ...	`|暴露容器端口|
|ENV|`ENV <key> <value>	`设置容器内环境变量|
|COPY|`COPY <src> <dest>`|从**宿主机**拷贝内容到**容器**内,/结尾表示目录，差别自己体会吧|
|ADD|`ADD <src> <dest>`|高级版的COPY，如果 `<src>` 为url则表示下载文件，如果 `<src>` 为可识别的压缩文件，拷贝后会进行解压。建议最好还是用COPY|
|VOLUME|`VOLUME ["<mountpoint>"]`|	指定挂载点，对应目录会映射到宿主机的目录上，宿主机对应的目录是自动生成的无法指定|
|WORKDIR|`WORKDIR <path>`|切换容器内目录，相当于cd|
|ONBUILD|[参考](http://www.cnblogs.com/51kata/p/5265107.html)|在子镜像中执行，比如在A镜像的Dockerfile中添加 ONBUILD 指令，该指令在构建构成不会执行，当B镜像以A镜像为基础镜像时，构建B镜像的过程中就会执行改指令|


详细信息，参考：

* [使用Dockerfile构建镜像](https://www.jianshu.com/p/a0892512f86c)
* 《Docker 技术入门与实践》





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
* [Dockerfile 指令详解](https://yeasy.gitbooks.io/docker_practice/image/dockerfile/)











[NingG]:    http://ningg.github.com  "NingG"
