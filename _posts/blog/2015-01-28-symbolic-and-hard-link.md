---
layout: post
title: Linux下symbolic link 和 hard link
description: linux下，链接文件有两类，符号链接文件和硬链接文件
category: linux
---

Linux下一切皆文件，设备也被映射为文件；（依据在哪？）

初步几点：

* symbolic link和hard link的初步区别；
* ln命令创建两种link文件；
* inode的简介；
* 整理一个典型的文件系统ext2 *（参考鸟哥私房菜）*
	* 作用？
	* 组成？（基本原理）
	* 磁盘扩容等；






## 两种link文件

linux下link文件：为已经存在的文件，创建另一个名字（别名），而不复制文件的内容。
link文件有两种：hard link（硬链接）和symbolic link（符号链接，软链接）。

### 文件系统基本知识

文件系统中，几点：

* 一切皆文件，文件夹本质也是文件、打印机等外部设备也是文件；
* 每个文件占用一个inode，inode指向文件的真正内容；
* 读取文件内容，需要先通过文件名指向正确的inode编号，然后获取文件内容；
* 文件夹的内容是其下属所有文件的名称与inode的对应关系；


这就有一种可能，即：多个文件对应同一个inode；这种情况就称为链接；

思考：文件和文件夹，在文件系统中存储是否有差异？（inode层级）


下图为创建hard link和symbolic link时，文件系统中具体的结构：

![](/images/symbolic-and-hard-link/symbolic-and-hard-link.png)


### hard link

指向同一个inode的两个不同名字，hard link是相互的，只有指向同一文件inode的所有hard link都删除，文件内容才会删除；不同hard link之间互不影响，相互对立。


（附一张图片：文件系统中hard link、原文件、inode、物理存储位置，之间的关系）

hard link只能在单一文件系统中进行，不能跨文件系统，hard link只存在一个partition内建立的关联关系；hard link也不能链接到目录，本质上在文件系统层面是可以的，但操作系统层面上，可能会限制针对目录建立hard link，避免子目录通过hard link指向父目录，这样整个树状文件目录内，会产生环结构。*（如果不是必须，不用纠结这一问题，记下即可，否则，可查看源码来解决）*

增加hard link，本质上，只是在文件夹（硬链接所属文件夹）的block中增加一条关联到原文件inode的记录；疑问：一个文件夹下包含的文件名列表，存储在文件夹inode对应的block中？

When to use Hard Link:

* Storage Space: Hard links takes very negligible amount of space, as there are no new inodes created while creating hard links. In soft links we create a file which consumes space (usually 4KB, depending upon the filesystem)
* Performance: Performance will be slightly better while accessing a hard link, as you are directly accessing the disk pointer instead of going through another file.
* Moving file location: If you move the source file to some other location on the same filesystem, the hard link will still work, but soft link will fail.
* Redundancy: If you want to make sure safety of your data, you should be using hard link, as in hard link, the data is safe, until all the links to the files are deleted, instead of that in soft link, you will lose the data if the master instance of the file is deleted.

中文表述一下：

* 更改原始文件名称时，hard link不受影响；
* 在同一partition上，移动原始文件的位置，不会影响hard link；
* 保证文件的安全性，原始文件被删除，通过hard link仍能访问原始文件，即，本质上文件并没有被删除；
* 操作系统层面上，禁止对directory创建link；

### symbolic link

指向其他link的link文件，不指向真正的inode，当源链接文件删除之后，symbolic link文件即失效；

（附一张图片：文件系统中symbolic link、源文件、inode、物理存储位置，之间的关系）

When to use Soft Link:

* Link across filesystems: If you want to link files across the filesystems, you can only use symlinks/soft links.
* Links to directory: If you want to link directories, then you must be using Soft links, as you can’t create a hard link to a directory.

中文表述一下：

* 不同filesystem（partition）之间，创建link文件；
* 为directory创建link；
* 当原始文件重命名或移动位置之后，symbolic link无法找到原始文件；


疑问：

* symbolic link可以跨越不同的partition吗？
* 原始文件重命名或移动位置之后，symbolic link失效；
* 为什么？最上面的symbolic link图示对吗？创建symbolic link时，a new file is created with a new inode；但是新的直接指向源文件的inode？还是新的inode指向新文件？具体如何匹配的？


## 查看Inode信息

### 指定文件的Inode信息

命令`stat [file]`和命令`ls -dil [file]`可查看文件的inode信息：

	[ningg@localhost ~]$ stat .
	  File: '.'
	  Size: 4096      	Blocks: 8          IO Block: 4096   directory
	Device: 805h/2053d	Inode: 10330113    Links: 15
	Access: (0700/drwx------)  Uid: (  500/   storm)   Gid: (  500/   storm)
	Access: 2015-01-28 16:58:00.000000000 +0800
	Modify: 2015-01-28 16:46:52.000000000 +0800
	Change: 2015-01-28 16:46:52.000000000 +0800
	
	[ningg@localhost ~]$ ls -dil .
	10330113 drwx------. 15 storm storm 4096 Jan 28 16:46 .


上述的`Inode`表示文件对应的inode位置，`Links`表示inode上对应的hard link数，仅当`Links`为0时，才能删除当前文件；补充一个问题：如何计算一个文件/文件夹，对应的Links数？

* 计算一个文件对应的Links数：针对一个文件的所有hard link个数，新建一个文件时，初始Links=1；
* 计算一个文件夹对应的Links数：针对一个文件夹的所有hard link个数，新建一个文件夹时，初始Links=2，因为在文件夹内部存在文件`.`，其也为指向当前目录的hard link；当在文件夹下创建子文件夹时，由于子文件夹下的`..`文件存在，文件夹的Links数也会增加；


### 文件系统的Inode信息

查询当前文件系统的inode信息：


	[ningg@localhost ~]$ df -i
	Filesystem            Inodes   IUsed   IFree IUse% Mounted on
	/dev/sda1            1875968  293264 1582704   16% /
	none                  210613     764  209849    1% /dev
	none                  213415       9  213406    1% /dev/shm
	none                  213415      63  213352    1% /var/run
	none                  213415       1  213414    1% /var/lock
	/dev/sda2            7643136  156663 7486473    3% /home

## 创建Link文件

利用命令`ln`来创建link文件：

	# 默认为 TARGET 文件创建一个hard link文件，并命名为LINK_NAME
	ln [TARGET] [LINK_NAME]

	# 为 TARGET 文件创建一个symbolic link文件，并命名为LINK_NAME
	ln -s [TARGET] [LINK_NAME]

**备注**：`ln`命令下，`-f`和`-n`选项，当前无法弄清楚其用途，仅做标记。




## 参考来源

* [Hard Link vs Soft Link][Hard Link vs Soft Link]
* [Understanding Linux/Unix Filesystem Inode][Understanding Linux/Unix Filesystem Inode]
* [Understand UNIX / Linux Inodes Basics with Examples][Understand UNIX / Linux Inodes Basics with Examples]
* [Understanding UNIX / Linux symbolic (soft) and hard links][Understanding UNIX / Linux symbolic (soft) and hard links]







[NingG]:    													http://ningg.github.com  "NingG"
[Hard Link vs Soft Link]:										http://www.geekride.com/hard-link-vs-soft-link/
[Understanding Linux/Unix Filesystem Inode]:					http://www.geekride.com/understanding-unix-linux-filesystem-inodes/
[Understand UNIX / Linux Inodes Basics with Examples]:			http://www.thegeekstuff.com/2012/01/linux-inodes/
[Understanding UNIX / Linux symbolic (soft) and hard links]:	http://www.cyberciti.biz/tips/understanding-unixlinux-symbolic-soft-and-hard-links.html







