---
layout: post
title: Kubernetes 系列：安装 & 入门
description: Kubernetes 有什么用？如何安装？如何使用？
published: true
category: docker
---

## 概要

关于 Kubernetes ，几个方面：

* 有什么作用？
* 如何安装？
* 基本的使用？

## Kubernetes

官网地址： [Kubernetes Documentation]

### 有什么用

Kubernetes 是一种解决方案，聚焦容器的集群管理、服务编排。

### 安装

完全按照官网 [Install Minikube] 进行操作即可。

> **备注**: `Minikube`, 在本地的 VM 中，启动一个单节点的 Kubernetes 集群。`Minikube` 包括了**所有功能**，以及所有的**核心组件**，进行本地**应用开发**，基本足够了。


#### 安装 kubectl 客户端

说明信息：

* `kubectl`：跟 Kubernetes 服务端交互的 command-line tool（`命令行工具`）。

我使用的是 MacPro，因此，采用下述方式，进行安装：

```
# 1. 通过 homebrew 安装 kubectl
brew install kubernetes-cli

# 2. 查看版本
kubectl version
```

上述安装过程中，可能遇到下述问题，具体问题和解决办法：

```
# 1. 当前用户的权限不够
$ brew install kubernetes-cli
Error: /usr/local/Cellar is not writable. You should change the
ownership and permissions of /usr/local/Cellar back to your
user account:
  sudo chown -R $(whoami) /usr/local/Cellar
Error: Cannot write to /usr/local/Cellar

# 解决办法：变更权限
$ sudo chown -R $(whoami) /usr/local/Cellar


# 2. Xcode 版本过低
Error: Your Xcode (8.3.2) is too outdated.
Please update to Xcode 9.2 (or delete it).
Xcode can be updated from the App Store.

# 解决办法：在 App Store 中，搜索 Xcode 进行更新

# 3. 没有权限
Homebrew: Could not symlink, /usr/local/bin is not writable

# 解决办法：变更目录权限
sudo chown -R `whoami`:admin /usr/local/bin

# 补充：有的情况下，还需要变更 share 和 opt 的权限
sudo chown -R `whoami`:admin /usr/local/share
sudo chown -R `whoami`:admin /usr/local/opt
```

#### 配置 kubectl

安装 kubectl 之后，需要进行`配置`，才能跟 Kubernetes 集群交互。

关于 kubectl 的配置：

* `kube-up.sh` 创建集群 or 安装 Minikube 后，会自动创建配置
* 默认配置的位置，`~/.kube/config`
* 获取一个远端 Kubernetes 集群访问权限，kubectl 的通用配置：[ Sharing Cluster Access document](https://kubernetes.io/docs/tasks/access-application-cluster/configure-access-multiple-clusters/)


TODO:

* 配置命令的自动补全







## 参考资料

* [Kubernetes Documentation]
* [Install Minikube]






[NingG]:    http://ningg.github.com  "NingG"
[Kubernetes Documentation]:				https://kubernetes.io/docs/home/
[Install Minikube]:					https://kubernetes.io/docs/tasks/tools/install-minikube/
[]:			https://kubernetes.io/docs/tasks/access-application-cluster/configure-access-multiple-clusters/











