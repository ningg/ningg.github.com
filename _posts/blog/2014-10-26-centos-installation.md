---
layout: post
title: 安装CentOS 6.4
description: 安装系统，有两点要说一下：磁盘如何分区？网络如何配置？
category: linux
---


##背景

最近十几台服务器要重装系统了，在师兄带领下，自己预装了一台，虽然之前有几十次的装机经历，但这次心里仍然有些不踏实，因为这次的机器是生产上用的，系统规划的好坏直接影响到今后的应用。

##CentOS简介

从[CentOS官网](http://www.centos.org/about/)可知，CentOS是编译Red Hat Enterprise Linux（RHEL）源代码得到的开源Linux发行版本，CentOS的版本号与RHEL版本号基本上一一对应。

此次安装CentOS系统，整体上有如下几个问题：

* 磁盘需要分区吗？（primary partition、logical partition）
* 分为几个区？每个分区的作用？分区的大小？
* 多块磁盘怎么分区？

> 此次使用是CentOS发行版，CentOS官网得知：CentOS的docs与RHEL类似，因此，不单独提供docs；既然这样，我就直接找RHEL的docs好了。
> 本文主要参考[RHEL 6: Installation Guide][RHEL 6: Installation Guide]，这个文档我只看了[分区][RHEL 6: Disk Partitioning Setup]部分，需要好好看看。

###分区

参考[RHEL 6: Recommended Partitioning Scheme][RHEL 6: Recommended Partitioning Scheme]，系统需要设置如下几个分区：

* `swap`分区：作为virtual memory，当内存空间不足时，将其中的数据放入`swap`分区；swap
* `/boot`分区：
* `/`分区：
* `home`分区：





###网络配置



##参考资料

1. [RHEL 6: Installation Guide][RHEL 6: Installation Guide] 
1. [An Introduction to Disk Partitions][An Introduction to Disk Partitions] （需要阅读学习）
1. [RHEL 6: Disk Partitioning Setup][RHEL 6: Disk Partitioning Setup]
1. [RHEL 6: Recommended Partitioning Scheme][RHEL 6: Recommended Partitioning Scheme]
1. [CentOS 6 docs?][CentOS 6 docs?]




[NingG]:    http://ningg.github.com  "NingG"



[RHEL 6: Recommended Partitioning Scheme]:	https://access.redhat.com/documentation/en-US/Red_Hat_Enterprise_Linux/6/html/Installation_Guide/s2-diskpartrecommend-x86.html
[RHEL 6: Disk Partitioning Setup]:	https://access.redhat.com/documentation/en-US/Red_Hat_Enterprise_Linux/6/html/Installation_Guide/s1-diskpartsetup-x86.html
[CentOS 6 docs?]:	http://lists.centos.org/pipermail/centos/2012-November/130123.html
[RHEL 6: Installation Guide]:	https://access.redhat.com/documentation/en-US/Red_Hat_Enterprise_Linux/6/html/Installation_Guide/index.html
[An Introduction to Disk Partitions]:	https://access.redhat.com/documentation/en-US/Red_Hat_Enterprise_Linux/6/html/Installation_Guide/ch-partitions-x86.html#tb-partitions-types-x86