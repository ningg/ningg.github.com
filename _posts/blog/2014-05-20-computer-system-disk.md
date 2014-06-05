---
layout: post
title: 硬盘结构
description: 计算机上，数据写在硬盘上，那么，硬盘是什么结构？硬盘读写速度有没有瓶颈？
category: computer system
---

##硬盘

硬盘大小：台式机3.5寸，笔记本尺寸2.5寸。

下图为硬盘的物理结构：

![true-disk](/images/computer-system-disk/true-disk.jpg)

上图可以直观看出，硬盘包含如下几个基本结构：

* 盘片*（存储数据）*
* 磁头*（向盘片，读取/写入数据）*
* 主轴马达
* 机械手臂

给一个正在读取磁盘内容的近景图：

![disk-reading](/images/computer-system-disk/disk-reading.JPG)

上图可以明显的看出，一个盘片对应的磁头可能有多个。

下面将对磁盘涉及的专业术语进行简要介绍，先来一张磁盘结构的简图：

![cylinder_head_sector](/images/computer-system-disk/cylinder_head_sector.svg)




[NingG]:    http://ningg.github.com  "NingG"
