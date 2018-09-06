---
layout: post
title: Kubernetes 系列：安装生产级的 K8s 集群
description: 多节点的 K8s 集群，涉及虚拟机、网络配置等内容
published: true
category: docker
---


## 概要

由于本地直接使用 minikube，屏蔽了很多操作细节，为了加深对 K8s 集群的理解，需要构造环境，安装一个生产级别的 K8s 集群。之前 minikube 的安装、使用：

* [Kubernetes 系列：安装 & 入门](http://ningg.top/kubernetes-series-01-introduction/)
* [Kubernetes 系列：使用 minikube 部署应用](http://ningg.top/kubernetes-series-02-deploy-an-application/)

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

在 VirtualBox 中，创建并运行虚拟机。

### 网络配置

运行虚拟机之后，虚拟机正常情况下，是无法访问网络的，需要单独的配置。详细细节，可以参考：

* [在macOS上通过虚拟机搭建基础CentOS7系统环境]

我采用的也是「桥接网卡」模式：

1. Mac 采用无线 wifi 接入外网
2. 查询 Mac 接入 wifi 的网卡：`ifconfig` 命令，查询到是网卡 `en0`
3. 为虚拟机配置一个网卡：`设置` - `网络` - `网卡2`
	1. 连接方式：`桥接网卡`
	2. 界面名称：`en0: Wi-Fi(AirPod)`
3. 启动虚拟机：在虚拟机内部 `ping baidu.com` 测试网络连通性

具体示意图：

![](/images/kubernetes-series/install-centos-on-virtualbox.png)

### SSH 免密登录

在本地 Mac 上，设置 3 个 Linux 虚拟机的免密登录，参考：

* [Linux 集群管理中，SSH 双向免密](http://ningg.top/linux-cmd-ssh-rsa/)

具体，配置 ssh 的快速登录方式：文件 `~/.ssh/config` 中，增加如下配置

```
# local Mac kubernetes of virtualbox CentOS
Host master
    User root
    Port 22
    HostName 172.17.18.29

Host node-1
    User root
    Port 22
    HostName 172.17.18.173

Host node-2
    User root
    Port 22
    HostName 172.17.18.174
```

通过下述方式，分发本地密钥，实现 SSH 免密登录：

```
// 上传公钥，配置免密码登录 （在 authorized_keys 后追加公钥）（有可能不需要执行 mkdir 命令）
cat ~/.ssh/id_rsa.pub | ssh master "mkdir -p ~/.ssh && cat >> ~/.ssh/authorized_keys"
  
// 上传公钥，配置免密码登录 （会覆盖 authorized_keys 中其他的公钥）
scp id_rsa.pub ssh master:/~/.ssh/authorized_keys
```










## 参考资料

* [在macOS上通过虚拟机搭建基础CentOS7系统环境]
* [Kubernetes 系列：安装 & 入门](http://ningg.top/kubernetes-series-01-introduction/)
* [Kubernetes 系列：使用 minikube 部署应用](http://ningg.top/kubernetes-series-02-deploy-an-application/)






[NingG]:    http://ningg.github.com  "NingG"

[在macOS上通过虚拟机搭建基础CentOS7系统环境]:		https://wangzhen.space/2018/03/06/%E5%9C%A8macOS%E4%B8%8A%E9%80%9A%E8%BF%87%E8%99%9A%E6%8B%9F%E6%9C%BA%E6%90%AD%E5%BB%BA%E5%9F%BA%E7%A1%80CentOS%E7%B3%BB%E7%BB%9F%E7%8E%AF%E5%A2%83/








