---
layout: post
title: Linux下查询磁盘空间和扩充磁盘空间
description: 磁盘空间占满，文件无法写入，这是一类问题，梳理一下
category: linux
---


##背景与分析

磁盘空间占满，文件无法写入，此时应用运行出错，面对此情况，基本思路如下：

* 定位问题
	* 磁盘分区情况
	* 不同分区的磁盘占用情况
	* 分区下，哪个目录占用空间最大
* 解决问题
	* 删除文件
	* 磁盘扩容
	
##定位问题

###磁盘分区及占用

简要说明几点：

* 每个分区（partition）就是一个文件系统（File System），拥有自己的文件系统类型（ext3、ext4等）；
* 每个分区（parition），由inode和block构成；
	* 磁盘空间不足，通常是block数量不足，但也可能inode数量不足（小文件很多）；
	* 通常，一个file对应一个inode和多个block；（新建symbolic link文件，不会消耗新的inode）

具体示例代码：

	# 查看磁盘分区情况
	$ df -hT
		Filesystem    Type    Size  Used Avail Use% Mounted on
		/dev/sda3     ext4     58G   31G   25G  56% /
		tmpfs        tmpfs     32G     0   32G   0% /dev/shm
		/dev/sda1     ext4    485M   38M  423M   9% /boot
		/dev/sda5     ext4     94G  845M   89G   1% /home
	
	
	# 查看每个分区inode的使用情况
	$ df -ihT
		Filesystem    Type    Inodes   IUsed   IFree IUse% Mounted on
		/dev/sda3     ext4      3.7M    114K    3.6M    4% /
		tmpfs        tmpfs      7.9M       1    7.9M    1% /dev/shm
		/dev/sda1     ext4      126K      39    125K    1% /boot
		/dev/sda5     ext4      6.0M    7.9K    6.0M    1% /home
	
	
	
	# 查看指定目录所在分区的情况
	$ df -hT /tmp
		Filesystem    Type    Size  Used Avail Use% Mounted on
		/dev/sda3     ext4     58G   31G   25G  56% /


	
	# 查看指定目录文件的大小
	$ du -hs /tmp
		2.3M	/tmp






**特别说明**：几点：

* `df`命令，不显示`unmounted file systems`；
* `df`命令，常用3个选项：
	* `-T`，文件系统类型；
	* `-i`，inode的使用情况；
	* `-h`，自动以K\M\G方式输出结果；


###文件查找

典型场景：

* 按大小查找文件
* 查找最大的10个文件


####按大小查找文件

示例代码：

	# 查找文件大小 > 1GB 的文件
	# find命令中 -type -size 两个选项
	find -type f -size +1G | xargs du -h | sort -h


####查找最大的10个文件




###文件夹大小排序

典型场景：

* 某一文件夹下，文件/文件夹，按照大小进行排序；


####某一文件夹下，所有文件/文件夹大小

利用`du -hsx`命令查询文件大小，具体命令：

	# 查询根目录 ‘/’ 下，所有文件/文件夹的大小（排除p开头的文件）
	# -h, --human-readable, print sizes in human readable format (e.g., 1k 234M 2G)
	# -s, --summarize, display only a total for each argument
	# -x, --one-file-system, display only a total for each argument
	du -hsx /[^p]* | sort -rh | head -n 3


查询文件夹下，递归几级目录的大小：

	du -hx --max-depth=1 | sort -rh | head -n 3



####某一文件夹下，所有文件大小（不统计文件夹）

利用`ls -lhS`命令即可，具体命令：

	# 指定目录下，文件按照大小来排序
	# -l, use a long listing format
	# -h, print sizes in human readable format (e.g., 1K 23M 4G)
	# -S, sort by file size
	# -d, list directory entries instead of contents
	ls -lhSd /


**特别说明**：只能查询文件的大小，而无法查询文件夹大小







##解决问题

面对磁盘空间不足，两个思路解决办法：

* 删除无用大文件；
* 对磁盘扩容；



（todo：直接删除文件，对磁盘扩容，两个方面：增加inode、通过lvm扩容，等到需要磁盘扩容时，再整理这一部分内容）







##几个命令

与文件系统相关的几个常用命令：

* `lsblk`：查询所有磁盘，包含`unmounted disk`；
	* 查询所有磁盘的文件类型，特别是未挂载的磁盘，`sudo lsblk -f`；
* `df`：查询磁盘分区占用情况、文件系统类型，block和inode，`df -ihT`；
* `du`：查看文件大小，`du -hs`；
* `fdisk`：




###安装

`lsblk`命令是在util-linux或者util-linux-ng包中的，如果本机没有`lsblk`命令，需要先安装一下，具体：

	yum install util-linux-ng



###lsblk

关于此命令，没有太多要说的，其选项，大部分涉及的内容很琐碎，磁盘的细节信息，暂时未用到，关于其输出只列几个常识。

	$ lsblk
	NAME   MAJ:MIN RM   SIZE RO TYPE MOUNTPOINT
	sda      8:0    0 558.9G  0 disk 
	├─sda1   8:1    0   500M  0 part /boot
	├─sda2   8:2    0  97.7G  0 part /
	├─sda3   8:3    0  62.5G  0 part [SWAP]
	├─sda4   8:4    0     1K  0 part 
	└─sda5   8:5    0 398.2G  0 part /home
	sdb      8:16   0   256M  1 disk 
	└─sdb1   8:17   0   251M  0 part 

	
关于上述条目的名称：
	
* `NAME` ：设备名称。
* `MAJ:MIN`：major:minor，此栏显示的主设备号和次设备号。
* `RM`：remove，此栏显示该设备是否是可移动的。注意，在这个例子中，设备sdb和sr0的RM值等于1，表明它们是可移动的。
* `SIZE`：该列是设备的大小信息。例如298.1G表明该设备是298.1GB和1K表示该设备的大小为1KB。
* `RO`：Read Only，这表示一个设备是否是只读的。在这种情况下，所有的设备的RO = 0，表明它们不是只读的。
* `TYPE`：此栏显示的块设备的信息是否是磁盘或磁盘中的分区（部分）。在本例中的ada和sdb是磁盘而sr0是一个只读存储器（ROM）。
* `MOUNTPOINT`：此栏显示在该设备挂载的挂载点。


**特别说明**：`lsblk`命令会显示，所有的磁盘，包含`unmounted disk`。


###find

`find`命令，几个选项，简要说明如下：

* `-name [pattern]`：`[pattern]`表示使用通配符`*` `?` `[]`，进行文件名的匹配；
* `-regex [pattern]`：`[pattern]`表示利用Regular Expression，正则表达式；
* `-type f`：限定文件类别；
* `-size +1G`：限定文件大小；

（doing... 陆续补充，每次补充都是回顾）






















[NingG]:    http://ningg.github.com  "NingG"





