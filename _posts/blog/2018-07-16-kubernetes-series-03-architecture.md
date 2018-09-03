---
layout: post
title: Kubernetes 系列：核心架构
description: 物理架构？逻辑架构？
published: true
category: docker
---

## 概要

Kubernetes 集群，几个基本疑问：

* Kubernetes 的 Docker 集群，是由什么构成的？
* 看得见、摸得着的东西，是什么？（物理架构、部署架构）
* 不同 Docker 节点之间，协作机制、处理逻辑是什么？


## 核心概念

几个方面：

* 核心概念：什么含义，什么用途
* 逻辑关系：核心概念之间协作关系



## 核心架构

两个方面：

1. 逻辑架构
2. 物理架构

### 逻辑架构

Kubernetes 的核心工作过程：

1. **资源对象**：`Node`、`Pod`、`Service`、`Replication Controller` 等都可以看作一种资源对象
2. **操作**：通过使用 `kubectl` 工具，执行**增删改查**
3. **存储**：对象的**目标状态**（**预设状态**），保存在 `etcd` 中持久化储存；
4. **自动控制**：跟踪、对比 etcd 中存储的**目标状态**与资源的**当前状态**，对差异`资源纠偏`，`自动控制`集群状态。

### 节点(Master & Node)

Kubernetes 的节点，分为 2 种角色：

* Master：管理节点
	* 作用：Kubernetes 操作命令，控制整个
* Node：工作节点

具体，2 种角色的节点，需要运行的进程和职责不同：

**Master 管理节点**：管理整个 Kubernetes 集群，接收外部命令，维护集群状态。

* **apiserver**： Kubernetes API Server
	* 集群控制的入口
	* **资源**的增删改查
	* `kubectl` 直接与 API Server 交互，默认端口 `6443`。
* **controller-manager**: 控制器的管理器
	* 每个**资源**，都对应有一个**控制器**（*疑问：作用是什么？*）
	* controller manager 管理这些控制器
	* controller manager 是自动化的循环控制器
	* Kubernetes 的核心控制守护进程，默认监听10252端口。（*疑问：为什么有监听段口感？*）
* **scheduler**： 负责将 pod 资源调度到合适的 node 上。
	* 调度算法：根据 node 节点的`性能`、`负载`、`数据位置`等，进行调度。
	* 默认监听10251 端口。
* **etcd**: 一个高可用的 `key-value` 存储系统
	* 作用：存储**资源**的状态
	* 支持 Restful 的API。
	* 默认监听 2379 和 2380 端口（2379提供服务，2380用于集群节点通信）（疑问：集群节点，是说 etcd 的集群？ Master 集群？）

**Node 节点**：Master 节点，将任务调度到 Node 节点，以 docker 方式运行；当 Node 节点宕机时，Master 会自动将 Node 上的任务调度到其他 Node 上。

* **kubelet**: 负责达到 Pod 的目标运行状态
	* Kubelet是在每个Node节点上运行agent
	* 负责维护和管理所有容器
	* Kubelet不会管理不是由Kubernetes创建的容器
	* 定期向Master汇报自身信息，如操作系统、Docker版本、CPU、内存、pod 运行状态等信息
* **kube-proxy**：
	* **功能**：服务发现、反向代理。
	* **反向代理**：支持TCP和UDP连接转发，默认基于Round Robin算法将客户端流量转发到与service对应的一组后端pod。
	* **服务发现**：使用 etcd 的 watch 机制，监控集群中service和endpoint对象数据的动态变化，并且维护一个service到endpoint的映射关系。（本质是：路由关系）
* **runtime**：一般使用 `docker` 容器，也支持其他的容器。


### Pod

Pod 是 Kubernetes 集群运行的最小单元。

* 一个或多个`容器`的`集合`
* Pod：包含`一个` `Pause 容器`和`多个``业务容器`

**Pause 容器**：

* 镜像：pause-amd64
* 作用：非常重要
	* Pod容器的`根容器`
	* `业务容器``无关`
	* 其状态，代表整个 pod 的状态
* 网络：
	* **独立 IP 地址**：每个Pod被分配一个独立的IP地址
	* Pause 容器的`IP`：Pod里的多个业务容器共享
	* **共享网络命名空间**：Pod中的每个容器共享网络命名空间，包括`IP地址`和`网络端口`
	* **localhost 通信**：Pod内的容器可以使用localhost相互通信
	* **Pod 间通信**：k8s 支持`底层网络`集群内任意两个Pod之间进行通信
* 磁盘：
	* 共享 volumes：Pod中的所有容器都访问共享volumes，允许这些容器共享数据。
	* 持久化：volumes 还用于Pod中的数据持久化，以防其中一个容器需要重新启动而丢失数据。


### Label




## 资源定义

几个方面：

* Pod 定义
* TODO


### Pod 定义

下面是一个 Pod 的资源定义：

```
apiVersion: v1
kind: Pod
metadata:
  name: myweb
  labels:
    name: myweb
spec:
  containers:
  - name: myweb
    image: kubeguide/tomcat-app:v1
    ports:
    - containerPort: 8080
    env:
    - name: MYSQL_SERVER_HOST
      value: 'mysql'
    - name: MYSQL_SERVER_PORT
      value: '3306'
  - name: db
    image: mysql
    resources:
      requests:                  # 最小资源申请量
        memory: "64Mi"     # 64M内存
        cpu: "250m"           # 0.25个CPU
      limits:                       # 最大配额
        memory: "128Mi"   # 128M 内存
        cpu: "500m"           # 0.5个CPU
```  

Pod 的常用操作：

```
kubectl create -f  pod_file.yaml            # 创建pod
kubectl describe pods POD_NAME  # 查看pod详细信息
kubectl get pods                               # pods 列表
kubectl delete pod POD_NAME    # 删除pod
kubectl replace  pod_file.yaml      # 更新pod
```






## 遗留问题

定义资源的模板：

* TODO：官网查询？详细含义？




## 参考资料


* [Kubernetes Documentation]
* [Kubernetes 指南]
* [Kubernetes 核心概念简介]







[NingG]:    http://ningg.github.com  "NingG"


[Kubernetes Documentation]:				https://kubernetes.io/docs/home/
[Kubernetes 指南]:						https://legacy.gitbook.com/book/feisky/kubernetes/details
[Kubernetes 核心概念简介]:				http://blog.51cto.com/tryingstuff/2119034








