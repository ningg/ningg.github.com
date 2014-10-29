---
layout: post
title: Understanding LVM
description: LVM，Logical Volume Management，逻辑卷盘管理，主要用于解决静态分区时，分区大小调整的问题
categories: linux lvm
---

> 原文地址：[Understanding LVM][Understanding LVM]

LVM (Logical Volume Management) partitions provide a number of advantages over standard partitions. （LVM，Logical Volume Management，逻辑卷管理）：

* One or more physical volumes are combined to form a volume group. （n个physical volume，组成一个volume group）
* Each volume group's total storage is then divided into one or more logical volumes.（volume group被分割为n个logical volume）
* The logical volumes function much like standard partitions. （在user看来，logical volume跟standard partition一样）
* LVM partitions are formatted as physical volumes. They have a file system type, such as `ext4`, and a mount point.（logical volume有自己的file system type，以及mount point）


> **The /boot Partition and LVM**
>
> On most architectures, the boot loader cannot read LVM volumes. You must make a standard, non-LVM disk partition for your `/boot` partition.（绝大多数architecture下，boot loader不能读取LVM volume；因此，需要为`/boot`单独分区，并指定一个non-LVM的分区）
>
> However, on System z, the `zipl` boot loader supports `/boot` on LVM logical volumes with linear mapping.


To understand LVM better, imagine the physical volume as a pile of `blocks`. A block is simply a storage unit used to store data. Several piles of blocks can be combined to make a much larger pile, just as physical volumes are combined to make a volume group. The resulting pile can be subdivided into several smaller piles of arbitrary size, just as a volume group is allocated to several logical volumes.

An administrator may grow or shrink logical volumes without destroying data, unlike standard disk partitions. If the physical volumes in a volume group are on separate drives or RAID arrays then administrators may also spread a logical volume across the storage devices.

**notes(ningg)**：LVM有两个优点：

* **动态调整logical volume**：动态的grow or shrink Logical volume，数据不会损坏；
* **并发写drives**：如果physical volume是多个drives 或者 RAID arrays，则 a logical volume能够横跨这些storage devices，带来一个好处，向某一目录写数据时，能够向多个磁盘并发写，加快写数据的速度；

You may lose data if you shrink a logical volume to a smaller capacity than the data on the volume requires. To ensure maximum flexibility, create logical volumes to meet your current needs, and leave excess storage capacity unallocated. You may safely grow logical volumes to use unallocated space, as your needs dictate.

**notes(ningg)**：当将logical volume大小调整为小于其所存储数据的大小时，会丢失数据；通常，按照当前需求分配logical volume大小，其余的存储空间不分配，今后根据需要动态的增加logical volume的大小。

> **LVM and the Default Partition Layout**
> 
> By default, the installation process creates `/` and `swap` partitions within LVM volumes, with a separate `/boot` partition.




[Understanding LVM]:	https://access.redhat.com/documentation/en-US/Red_Hat_Enterprise_Linux/6/html/Installation_Guide/sn-partitioning-lvm.html 
[NingG]:    http://ningg.github.com  "NingG"
