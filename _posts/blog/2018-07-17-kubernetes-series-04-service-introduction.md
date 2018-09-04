---
layout: post
title: Kubernetes 系列：Service 和网络
description: 内部网络模式，有几种？有什么差异？
published: true
category: docker
---


## 概要

Kubernetes 中， Service 用于对外暴露网络。



## 主要内容

关于 Service 和网络：

* **type**: Service 的类型，常用的有 NodePort、ClusterIP.
	* `NodePort`：Service 集群`外部访问`；
	* `ClusterIP`：Service 集群`内部访问`；
* **protocol**：service 使用的协议，常用的有：`TCP`、`UDP`、`HTTP`
* **name**：为 port 定义一个name
	* 名为 `my-service.my-ns`的 Service
	* 有一个协议为`TCP`，名叫`http`的端口
	* 则，对`_http`.`_tcp`.`my-service.my-ns` 做一次 DNS SRV 查询来发现 `http` 的端口号。

关于端口号 `port`、`nodePort`、`targetPort`：

* **port**：**集群内部**访问，ClusterIP 模式的 Service，暴露在cluster ip上的端口，`<cluster ip>:port`，提供给**集群内部**访问service的入口。
* **nodePort**：**集群外部**访问，NodePort 模式的 Service，`<nodeIP>:nodePort`
	* 还有一种方式，Service 也可以提供集群外部访问。（`LoadBalancer`）
* **targetPort**：`pod` 的端口，从 port 和 nodePort 上到来的数据，经过 `kube-proxy`，流入到后端 `pod` 的 `targetPort` 上进入容器。

port、nodePort总结：

1. `port`和`nodePort`都是 service 的端口
2. `port` **集群内**访问
3. `nodePort` **集群外**访问
3. `port`和`nodePort`的数据，都需要经过反向代理 `kube-proxy` 流入后端pod的`targetPod`，从而到达pod上的容器内。


使用calico等`overlay`网络，可能导致`hostport`不可用，可以增加 `hostNetwork: true` 配置启用 `host` 模式 (在pod中定义)


## 关键问题

Kubernetes的网络方式主要解决以下几个问题：

1. **Pod 内部**：紧耦合的容器之间通信，通过 Pod 和 localhost 访问解决。
1. **Pod 之间**：Pod之间通信，建立`通信子网`，比如隧道、路由，Flannel、Open vSwitch、Weave。
1. **Pod 和外部**：Pod和Service，以及外部系统和Service的通信，引入Service解决。

Kubernetes的网络会给每个Pod分配一个IP地址，不需要在Pod之间建立链接，也基本不需要去处理容器和主机之间的端口映射。（疑问：什么含义？）

注意：Pod重建后，IP会被重新分配，所以内网通信不要依赖Pod IP；通过Service环境变量或者DNS解决。





## 参考资料

* [Kubernetes Documentation]
* [Kubernetes 指南]
* [Kubernetes Service & Network]
* [闲谈 Kubernetes 的主要特性和经验分享]
* [Labels and Selectors]






[NingG]:    http://ningg.github.com  "NingG"


[Kubernetes Documentation]:				https://kubernetes.io/docs/home/
[Kubernetes 指南]:						https://legacy.gitbook.com/book/feisky/kubernetes/details
[Kubernetes Service & Network]:		https://kubernetes.io/docs/concepts/services-networking/service/
[闲谈 Kubernetes 的主要特性和经验分享]:		http://www.itboth.com/d/NzQjMn/docker-kubernetes
[Labels and Selectors]:					https://kubernetes.io/docs/concepts/overview/working-with-objects/labels/









