---
layout: post
title: Docker 系列：核心原理和实现(2)
description: Docker 使用的 Unix 底层核心技术有哪些？有哪些关键要点？
published: true
category: docker
---

## 概要

> 特别说明：这篇是在公司内部组织的 Docker 技术专题中，讨论分享的文章。作者是我带的一个 94 年的小青年（LanDi），非常有潜力。

容器技术，主要关注下面几点：

* 安全
* 隔离
* 资源控制

Docker 作为容器的一种典型实现，也围绕上述几个方面在进行。具体实现上，使用了 Unix 内核提供的一些技术，四个方面：

* 命名空间（Namespace）：资源隔离、用户隔离
* 控制组（Control Group）：资源配额
* 联合文件系统（Union Filesystem）：镜像文件的差量分发
* 网络 （Network）：多种方案的对比，需要考虑 `网络效率`、`适用场景`

下文将进行详细介绍。

## 命名空间（Namespace）

Linux Namespace 是`内核级别`的`资源隔离`方法，不同 namespace 之间，各自拥有的资源，相互没有影响，调整任何一个 namespace，都不会影响其他 namespace.

目前 Linux 内核实现了七种不同的 namespaces：

|命名空间|系统调用参数（标记位）| Linux 内核版本|
|:----|:-----|:----|
|Mount namespaces|`CLONE_NEWNS`|Linux 2.4.19|
|UTS namespaces|`CLONE_NEWUTS`|Linux 2.6.19|
|IPC namespaces|`CLONE_NEWIPC`|Linux 2.6.19|
|PID namespaces|`CLONE_NEWPID`|Linux 2.6.24|
|Network namespaces|`CLONE_NEWNET`|Linux 2.6.29|
|User namespaces	|`CLONE_NEWUSER`|Linux 3.8|
|Cgroup|`CLONE_NEWCGROUP`|Linux 4.6|

补充说明：

* 其中 cgroup namespace 为新提出的，暂时没有在 Docker 中使用
* 每个命名空间，是`单个资源`的`命名空间`，隔离对应资源
* 命名空间的`唯一标识`，整型数字

在 Linux 系统，执行下述命令，查看当前进程所属的命名空间：

```
# 查看当前进程所属的命名空间：
# $$ 在 shell 场景下，会自动识别为当前进程的 pid
ls -l /proc/$$/ns
```

加入 or 退出一个命名空间，可以直接使用 Linux 提供的系统调用。

Linux 提供了三个 API 用来创建进程，并使其加入或脱离某个 Namespace：

```
#clone() ：创建进程并把它放入一个 namespace，当前进程保持不变
#-flags：传入 namespace 对应参数
int clone(int (*child_func)(void *), void *child_stack
            , int flags, void *arg);

#setns(): 将当前进程加入某 namespace 中
#-fd：指向/proc/[pid]/ns/目录里相应namespace对应的文件，表示要加入哪个namespace
#-nstype：指定namespace的类型
int setns(int fd, int nstype);

#unshare()：使当前进程退出当前的 namespace，加入新指定的 namespace 中
#-flags：指定一个或者多个上面的CLONE_NEW*
int unshare(int flags);
```

### Mount namespaces


**作用**：用来隔离文件系统的挂载点，不同的 Mount namespace 拥有独立的挂载点信息，不相互影响，有利于构建容器或者用户自己的文件目录。

当前进程所在mount namespace里的所有挂载信息，可以在 `/proc/[pid]/mounts``、/proc/[pid]/mountinfo`和`/proc/[pid]/mountstats`里面找到。

```
ls -l /proc/$$/ns
```

补充说明：

* Mount namespace，是第一个加入 Linux 内核的命名空间，因此，叫做 `CLONE_NEWNS` 参数，而没有叫做 `CLONE_NEWMOUNT`
* 新的mount namespace是在调用系统函数clone()的时候指定CLONE_NEWS，或者调用unshare()的时候被创建；
* 当一个新的mount namespace被创建的时候，它会从调用方的mount namespace中复制mount point列表；
* 可以在每个namespace中通过mount()/unmount()独立的添加和删除mount points；
* 默认情况下，mount point的变更仅对进程所在的namespace中的进程可见；

基于 mount namespace 的隔离性，为了实现一定程度的共享，在 Linux 2.6.15 中，引入 `shared subtree` 技术：

* 允许在 `mount namespace` 之间自动，受控地传播mount和unmount事件；
* 用途举例：将光盘安装在一个mount namespace中，可以在所有其他namespace中触发该磁盘的安装
* 本质使用了 2 个技术：
	* **Peer groups**（`对等组`）：对等组是一组mount points，它们将挂载和卸载事件相互传播；
	* **propagation type**（`传播类型`）：在此mount point下创建和删除的mount point是否传播到其他mount point；针对每个`挂载点`，单独指定 `propagation type`；

更多细节，参考 [mount namespace和shared subtrees](https://blog.csdn.net/bob_fly1984/article/details/80717373)


### UTS namespaces

**作用**：用来隔离系统的「主机名 hostname」以及「NIS 域名」。

补充： NIS 域名，集中控制「用户登录账号」相关信息的服务，细节参考 [Linux Namespace : UTS](https://www.cnblogs.com/sparkdev/p/9377072.html)

具体：

* 这两种资源可以通过 sethostname 和 setdomainname 函数来设置；
* 通过 uname, gethostname 和 getdomainname 函数来获取；

UTS namespace `不存在``嵌套关系`，即不存在一个namespace是另一个namespace的父namespace。

内核中的实现：

1. 在老版本的 Linux 中，UTS 的相关信息保存在一个`全局变量`中，所有进程都共享这个全局变量。
2. 在新版本中，在每个`进程`对应的`结构体` `task_struct` 中，增加了一个 nsproxy 字段，保存相关信息。不同 UTS namespace 中的进程，指针指向的结构体不同，从而达到了隔离 UTS 信息的目的。


### IPC namespaces































## 参考资料

* TODO








[NingG]:    http://ningg.github.com  "NingG"
