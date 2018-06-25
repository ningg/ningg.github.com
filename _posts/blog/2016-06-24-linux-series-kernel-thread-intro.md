---
layout: post
title: Linux 系列：kthreadd 进程、initd 进程、systemd 进程
description: 用户态、内核态，进程之间的关系？有哪些特殊的内核进程，作用是什么？
category: linux
---




## 概要

Linux下有3个特殊的进程：

* `idle`进程(pid = 0)
* `init`进程(pid = 1)
* `kthreadd`(pid = 2)



## 3 个特殊进程


### idle 进程，pid = 0

idle进程：

* 由`系统`自动创建, 运行在`内核态`；
* pid=0，其前身是`系统创建`的`第一个进程`
* `唯一一个`**没有**通过`fork`或者`kernel_thread`产生的进程；
* 完成`加载系统`后，演变为进程调度、交换；


### init 进程，pid = 1

* init进程由idle通过kernel_thread创建，在内核空间完成初始化后, 加载init程序, 并最终用户空间

由0进程创建，完成系统的初始化. 是系统中所有其它用户进程的祖先进程

Linux中的所有进程都是有init进程创建并运行的。首先Linux内核启动，然后在用户空间中启动init进程，再启动其他系统进程。在系统启动完成完成后，init将变为守护进程监视系统其他进程。


### kthreadd 进程，pid = 2

* kthreadd进程由idle通过kernel_thread创建，并始终运行在内核空间, 负责所有内核线程的调度和管理

它的任务就是管理和调度其他内核线程kernel_thread, 会循环执行一个kthread的函数，该函数的作用就是运行kthread_create_list全局链表中维护的kthread, 当我们调用kernel_thread创建的内核线程会被加入到此链表中，因此所有的内核线程都是直接或者间接的以kthreadd为父进程










## 参考资料

* TODO

















[NingG]:    http://ningg.github.com  "NingG"
