---
layout: post
title: Kubernetes 系列：安装 & 入门
description: Kubernetes 有什么用？如何安装？如何使用？
published: true
category: docker
---

## 概要

关于 Kubernetes ，几个方面：

* 准备工作
	* 有什么作用？
	* 如何安装？
* 基本用法

## 准备工作

官网地址： [Kubernetes Documentation]

### 有什么用

Kubernetes 是一种解决方案，聚焦容器的集群管理、服务编排。

### 安装

完全按照官网 [Install Minikube] 进行操作即可。

> **备注**: `Minikube`, 在本地的 VM 中，启动一个单节点的 Kubernetes 集群。`Minikube` 包括了**所有功能**，以及所有的**核心组件**，进行本地**应用开发**，基本足够了。

在 minikube 下，配置 kubelet、apiserver、proxy、controller-manager、etcd、scheduler 等，具体配置参数，可参考：[Running Kubernetes Locally via Minikube]。

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
* 获取一个远端 Kubernetes 集群访问权限，kubectl 的通用配置：[Sharing Cluster Access document]


补充说明:

* 上述安装 kubectl 命令后，如果没有命令的自动补全，则，可以单独设置：[Install and Set Up kubectl]


#### 安装 Minikube

细节参考： [Install Minikube]

此次我安装的是最新版本 `v0.28.2`，具体 Mac 下，安装步骤：

```
brew cask install minikube
```

安装过程中，出现问题的解决方案：

```
# 出现的问题
Error: Permission denied @ dir_s_mkdir - /usr/local/Caskroom/minikube

# 解决方案
sudo chown -R `whoami`:admin /usr/local/Caskroom
```

如果网络不好，但是可以通过浏览器下载，则，可以把下载之后的文件，复制到指定的目录：

* `minikube` 对应目录： `~/.minikube/cache/iso`
* `kubeadm` 和 `kubelet` 对应目录： `~/.minikube/cache/v1.10.0`

具体的目录结构，例如：

```
~/.minikube/cache
 - iso
   - minikube-v0.28.1.iso
 - v1.10.0
   - kubeadm
   - kubelet
```

## 基本用法

几个方面：

* 启动
* 查看信息：状态、规模等
* 终止


下述异常，以及解决方案：

```
# 异常现象
Error with pre-create check: "VBoxManage not found. Make sure VirtualBox is installed and VBoxManage is in the path"

# 解决方案
# 1. 查询 virtualbox
brew search virtualbox
# 2. 安装 virtualbox
brew cask install virtualbox
```

关于 Kubernetes 的基本用法，参考：

* [Running Kubernetes Locally via Minikube]
* [Install and Set Up kubectl]

具体的操作：

```
# 1. 启动 Minikube 集群：一个单节点的 Kubernetes 集群
$ minikube start

Starting local Kubernetes v1.10.0 cluster...
Starting VM...
Getting VM IP address...
Moving files into cluster...
Setting up certs...
Connecting to cluster...
Setting up kubeconfig...
Starting cluster components...
Kubectl is now configured to use the cluster.
Loading cached images from config file.

# 查看日志
$ minikube logs

# 查看集群状态
$ kubectl get pods --namespace=kube-system -o wide

# 查看 minikube 的状态
$ minikube status

# 查看 minikube 已经启动的插件
$ minikube addons list


# 2. 本地连接到 minikube 集群
$ kubectl cluster-info

# 3. 查看本地 minikube 集群的信息
$ kubectl cluster-info dump | less

# 4. 关闭 minikube 集群
$ minikube stop

# 5. 删除 minikube 集群
$ minikube delete

# 6. 启动 dashboard：
$ minikube dashboard
```

备注：上述操作中，`minikube dashboard` 命令，会直接打开 `http://192.168.99.100:30000` Kubernetes 的管理后台页面.


特别说明：上述过程，有可能遇到一些问题，他们的解决方案，如下：

```
# 1. 问题描述： 无法连接到 minikube 内部的网络
Error starting cluster: timed out waiting to elevate kube-system RBAC privileges: creating clusterrolebinding: Post https://192.168.99.100:8443/apis/rbac.authorization.k8s.io/v1beta1/clusterrolebindings: Service Unavailable

# 解决办法：
关闭本机的 VPN 等

# 2. kubernetes-dashboard 等 pod 一直出现 CrashLoopBackOff 异常，无法正常启动 dashboard
$ kubectl get po --all-namespaces
...
NAMESPACE     NAME                                    READY     STATUS             RESTARTS   AGE
kube-system   kubernetes-dashboard-5498ccf677-fh2rj   0/1       CrashLoopBackOff   11         2h
...

# 解决办法：重新创建一次镜像
$ minikube stop
$ minikube delete
$ minikube start


# 统一执行
$ minikube stop && minikube delete && minikube start
```

特别说明： 

> 中国国内，因为 GFW 的存在，可能无法拉取镜像等内容，此时，需要以代理方式启动 minikube。

具体分为 2 个步骤：

1. 定位问题：查询 minikube 的启动日志，判断是否是 GFW 导致的
2. 解决问题：以 HTTP 和 HTTPS 的代理模式，启动 minikube

操作细节：

```
# 查询启动日志
$ minikube logs 

...
Aug 21 15:31:28 minikube kubelet[2687]: E0821 15:31:28.536418    2687 kuberuntime_manager.go:646] createPodSandbox for pod "kube-controller-manager-minikube_kube-system(16a099baef9c74567ee1930ed78d0339)" failed: rpc error: code = Unknown desc = failed pulling image "k8s.gcr.io/pause-amd64:3.1": Error response from daemon: Get https://k8s.gcr.io/v2/: net/http: request canceled while waiting for connection (Client.Timeout exceeded while awaiting headers)
...

# 以 HTTP 和 HTTPS 代理模式，启动 minikube
$ minikube start --docker-env=HTTP_PROXY=http://127.0.0.1:8118 --docker-env=HTTPS_PROXY=https://127.0.0.1:8118
```

如果没有 HTTP 和 HTTPS 本地代理， 则，基于之前的 `ShadowsocksX` 采用的 Socket5 代理，只在浏览器生效，在 iterm 等终端，无法翻墙。

具体解决办法：

1. 设置 HTTP 代理：iterm 等终端中，设置 HTTP 代理
	* 细节参考： [握手时代、触碰时代](http://ningg.top/cloud-machine-series-cross-the-wall/)
2. 使用 HTTP 代理，启动 minikube 集群：参考上面的命令

另外，如果没有 HTTP 代理，同时，也没有 ShadowsocksX 等 Socket5 代理时，则，可以手动下载镜像文件，细节参考：

* [mac使用minikube安装kubernetes](https://my.oschina.net/go4it/blog/828941)
* [Mac 安装 minikube](https://www.jianshu.com/p/c7d50bb46c8c)

本次的解决办法：

1. iterm 终端，升级为 HTTP 代理
2. 仍然有部分 image 找不到，手动进行下载，具体参考下面细节

查看 minikube 启动的 log 日志，发现仍有 image 找不到：

```
# 查看 minikube 的 log 日志
minikube logs

...
Aug 21 17:31:37 minikube kubelet[2693]: E0821 17:31:37.453747    2693 pod_workers.go:186] Error syncing pod 9a2b8fee6510861e37a3351eb1aba711 ("kube-apiserver-minikube_kube-system(9a2b8fee6510861e37a3351eb1aba711)"), skipping: failed to "CreatePodSandbox" for "kube-apiserver-minikube_kube-system(9a2b8fee6510861e37a3351eb1aba711)" with CreatePodSandboxError: "CreatePodSandbox for pod \"kube-apiserver-minikube_kube-system(9a2b8fee6510861e37a3351eb1aba711)\" failed: rpc error: code = Unknown desc = failed pulling image \"k8s.gcr.io/pause-amd64:3.1\": Error response from daemon: Get https://k8s.gcr.io/v2/: net/http: request canceled while waiting for connection (Client.Timeout exceeded while awaiting headers)"
...

```

手动下载 image，并且打 tag：(阿里的镜像查询地址：[https://dev.aliyun.com/search.html](https://dev.aliyun.com/search.html))

```
# 1. 登录 minikube 虚拟机
minikube ssh

# 2. 下载镜像
docker pull anjia0532/pause-amd64:3.1

# 3. 打一个新的 Tag
docker tag anjia0532/pause-amd64:3.1 k8s.gcr.io/pause-amd64:3.1

# 4. 查看镜像
docker image ls

# 5. 其他镜像

docker pull anjia0532/pause-amd64:3.1 && docker tag anjia0532/pause-amd64:3.1 k8s.gcr.io/pause-amd64:3.1

docker pull registry.cn-beijing.aliyuncs.com/k8s_images/etcd-amd64:3.1.12 && docker tag registry.cn-beijing.aliyuncs.com/k8s_images/etcd-amd64:3.1.12 k8s.gcr.io/etcd-amd64:3.1.12

docker pull registry.cn-hangzhou.aliyuncs.com/k8sth/kube-scheduler-amd64:v1.10.0 && docker tag registry.cn-hangzhou.aliyuncs.com/k8sth/kube-scheduler-amd64:v1.10.0 k8s.gcr.io/kube-scheduler-amd64:v1.10.0

docker pull registry.cn-hangzhou.aliyuncs.com/k8sth/kube-controller-manager-amd64:v1.10.0 && docker tag registry.cn-hangzhou.aliyuncs.com/k8sth/kube-controller-manager-amd64:v1.10.0 k8s.gcr.io/kube-controller-manager-amd64:v1.10.0

docker pull registry.cn-hangzhou.aliyuncs.com/k8sth/kube-apiserver-amd64:v1.10.0 && docker tag registry.cn-hangzhou.aliyuncs.com/k8sth/kube-apiserver-amd64:v1.10.0 k8s.gcr.io/kube-apiserver-amd64:v1.10.0

docker pull registry.cn-hangzhou.aliyuncs.com/google_containers/kube-addon-manager:v8.6 && docker tag registry.cn-hangzhou.aliyuncs.com/google_containers/kube-addon-manager:v8.6 k8s.gcr.io/kube-addon-manager:v8.6

docker pull registry.cn-shenzhen.aliyuncs.com/kubernetes1_x/k8s-dns-kube-dns-amd64:1.14.8 && docker tag registry.cn-shenzhen.aliyuncs.com/kubernetes1_x/k8s-dns-kube-dns-amd64:1.14.8 k8s.gcr.io/k8s-dns-kube-dns-amd64:1.14.8

docker pull registry.cn-shenzhen.aliyuncs.com/kubernetes1_x/k8s-dns-sidecar-amd64:1.14.8 && docker tag registry.cn-shenzhen.aliyuncs.com/kubernetes1_x/k8s-dns-sidecar-amd64:1.14.8 k8s.gcr.io/k8s-dns-sidecar-amd64:1.14.8

docker pull registry.cn-shenzhen.aliyuncs.com/kubernetes1_x/k8s-dns-dnsmasq-nanny-amd64:1.14.8 && docker tag registry.cn-shenzhen.aliyuncs.com/kubernetes1_x/k8s-dns-dnsmasq-nanny-amd64:1.14.8 k8s.gcr.io/k8s-dns-dnsmasq-nanny-amd64:1.14.8

docker pull registry.cn-shanghai.aliyuncs.com/google-gcr/storage-provisioner:v1.8.1 && docker tag registry.cn-shanghai.aliyuncs.com/google-gcr/storage-provisioner:v1.8.1 gcr.io/k8s-minikube/storage-provisioner:v1.8.1

docker pull registry.cn-hangzhou.aliyuncs.com/zhangyouliang/kubernetes-dashboard-amd64:v1.8.1 && docker tag registry.cn-hangzhou.aliyuncs.com/zhangyouliang/kubernetes-dashboard-amd64:v1.8.1 k8s.gcr.io/kubernetes-dashboard-amd64:v1.8.1

docker pull registry.cn-shenzhen.aliyuncs.com/kubernetes1_x/kube-proxy-amd64:v1.10.0 && docker tag registry.cn-shenzhen.aliyuncs.com/kubernetes1_x/kube-proxy-amd64:v1.10.0 k8s.gcr.io/kube-proxy-amd64:v1.10.0

docker image ls

```

在外部，查看 pod：

```
# 查看 pods 列表
kubectl describe pods

# 删除失败的 pods


```

关联细节，参考：

* [failed pulling image "k8s.gcr.io/pause-amd64:3.1"](https://github.com/anjia0532/gcr.io_mirror/issues/5)


## 参考资料

* [Kubernetes 指南--非常专业易懂]
* [Kubernetes Documentation]
* [Install Minikube]
* [Install and Set Up kubectl]
* [Running Kubernetes Locally via Minikube]
* [Kubernetes中文社区]


特别说明，3 个非常有价值的治疗：

* [Kubernetes Documentation]
* [Kubernetes 指南]
* [Kubernetes 完全教程]






[NingG]:    http://ningg.github.com  "NingG"
[Kubernetes Documentation]:				https://kubernetes.io/docs/home/
[Install Minikube]:					https://kubernetes.io/docs/tasks/tools/install-minikube/
[Install and Set Up kubectl]:			https://kubernetes.io/docs/tasks/tools/install-kubectl/
[Sharing Cluster Access document]:			https://kubernetes.io/docs/tasks/access-application-cluster/configure-access-multiple-clusters/
[Running Kubernetes Locally via Minikube]:				https://kubernetes.io/docs/setup/minikube/
[Kubernetes中文社区]:		http://docs.kubernetes.org.cn/
[Kubernetes 指南--非常专业易懂]:		https://github.com/ningg/kubernetes-handbook
[Kubernetes 指南]:						https://legacy.gitbook.com/book/feisky/kubernetes/details
[Kubernetes 完全教程]:					http://jolestar.com/kubernetes-complete-course/
[Running Kubernetes Locally via Minikube]:				https://kubernetes.io/docs/setup/minikube/










