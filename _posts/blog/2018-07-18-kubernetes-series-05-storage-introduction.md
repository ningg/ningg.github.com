---
layout: post
title: Kubernetes 系列：存储
description: 如何定义存储？如何使用存储？
published: true
category: docker
---


## 概要

当前 Kubernetes 中，关于数据存储，几个概念，需要弄清楚他们存在的意义，以及用法。

* Volume：
	* VolumeMount
* PersistentVolume
* PersistentVolumeClaim


## 主要内容

PersistentVolume：（PV）

* 定义存储资源
* 生命周期，独立于 Pod 生命周期
* 是存储资源的抽象，需要满足指定的 API 接口

PersistentVolumeClaim：（PVC）

* 分配储存资源
* 与 Pod 相似。Pod 消耗节点资源，PVC 消耗 PV 资源
	* Pod 可以请求，特定级别的资源（CPU 和内存）。
	* PVC 可以请求，特定的大小和访问模式（例如，可以以读/写一次或 只读多次模式挂载）。

StorageClass ：

* 抽象层，向 PersistentVolumeClaim 提供资源，屏蔽多种 PersistentVolume 的差异




## 参考资料

* [Kubernetes Documentation]
* [Kubernetes 指南]
* [Kubernetes中的Persistent Volume解析]






[NingG]:    http://ningg.github.com  "NingG"


[Kubernetes Documentation]:				https://kubernetes.io/docs/home/
[Kubernetes 指南]:						https://legacy.gitbook.com/book/feisky/kubernetes/details
[Kubernetes中的Persistent Volume解析]:		https://jimmysong.io/posts/kubernetes-persistent-volume/









