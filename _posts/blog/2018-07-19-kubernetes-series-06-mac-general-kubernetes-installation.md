---
layout: post
title: Kubernetes 系列：Mac 上，安装通用的 K8s 集群
description: 多节点的 K8s 集群，涉及虚拟机、网络配置等内容
published: true
category: docker
---


## 概要

由于本地直接使用 minikube，屏蔽了很多操作细节，为了加深对 K8s 集群的理解，需要构造环境，安装一个生产级别的 K8s 集群。

> 目标：在 Mac 上，安装一个生产级别的 K8s 集群。

几个方面：

1. 虚拟机：Mac 上，安装虚拟机，启动多个 CentOS 系统
2. 构造 K8s 集群：基于上述的多个虚拟机，安装配置多节点的 K8s 集群

## 虚拟机

Mac 上，通过虚拟机，启动多个 CentOS 系统的虚拟节点，分为几个方面：

* 安装虚拟机
* 运行虚拟机

### 安装虚拟机

在 Mac 上，安装虚拟机，具体操作：

```
# 查询 virtualbox
brew search virtualbox
# 安装 virtualbox
brew cask install virtualbox
```

### 运行虚拟机

如何基于上述虚拟机，运行一个 CentOS 的实例呢？2 个步骤：

1. 下载 CentOS 的镜像文件
2. 运行虚拟机

从 [CentOS Download](https://www.centos.org/download/)，下载「Everything ISO」。

在 VirtualBox 中，创建并运行虚拟机：







## 参考资料

* TODO






[NingG]:    http://ningg.github.com  "NingG"










