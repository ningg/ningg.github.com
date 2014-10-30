---
layout: post
title: 安装CentOS 6.4
description: 安装系统，有两点要说一下：磁盘如何分区？网络如何配置？
category: linux
---

##1. 简介

CentOS（Community Enterprise Operating System，企业社区操作系统）是Linux发行版本之一。Red Hat Enterpris Linux（RHEL，红帽企业级Linux）依照开放源码规定，开源了每个RHEL版本的源代码，CentOS正是基于RHEL的源代码重新编译而成的[1]，并且在RHEL基础上修复了一些已知的bug，相对与其他Linux发行版本，CentOS稳定性值得信赖。当前，很多企业都在服务器上安装CentOS系统，来支撑线上应用。
CentOS与RHEL的最大区别在于：

1.	RHEL中包含了部分封闭源码的工具，而CentOS包含的所有工具都是开源的；
2.	RHEL提供技术服务，以此来收费；

值得注意的是，2014年初，CentOS宣布加入Red Hat[2]。

备注：CentOS的版本与RHEL版本基本一一对应，举例，CentOS 6.4对应RHEL 6.4的源代码。

##2. 安装CentOS 6

说到安装Linux系统，不要着急，官网肯定有操作手册来说明这个事，嗯，CentOS应用这么广泛，帮助手册总该有吧，要不然与其身份也不相符合。很不幸，[CentOS的官网](http://www.centos.org/docs/)中，并没有CentOS 6的操作手册，欧，赶快查查什么原因：CentOS完全基于RHEL源码编译而来，并且版本基本一一对应，因此，直接使用RHEL的官网文档即可[3]。

**特别说明**：本文所有安装CentOS 6的步骤、配置，都参考自RHEL 6官方文档[5]。

###2.1.	基本设置

这一部分，主要演示几点：如何通过CD/DVD光驱来重装系统。
 
步骤 1. 	重启系统，出现图1界面时，点击”F11”按钮，目的：设置Boot Menu。
说明：当点击完”F11”按钮之后，如图1界面最下端所示，”F11”按钮背景由黑色变为白色。

![](/images/centos-installation/001.png)



步骤 2. 	当出现图2所示界面时，选择”1”，目标：从光驱中加载系统。

![](/images/centos-installation/002.png)


稍等一会儿，有可能出现图3所示界面，不要管他，等一段时间即可
备注：如果长时间停留在图3界面，则敲击Enter。
 
![图 3](/images/centos-installation/003.png)

步骤 3. 	出现如图4时，选择“Install sytem with basic video driver”（第二项），目标：重装系统。
备注：也可选择“Install or upgrade an existing system”（第一项），但，有可能显示器画面出现倾斜异常（显卡驱动问题），因此推荐 “Install sytem with basic video driver”（第二项）。
 
![](/images/centos-installation/004.png)
图 4
 
步骤 4. 	出现如图5所示界面后，通过”Tab”键，选择“Skip”选项，并使用“Space”键来确认即可。目标：在安装之前，不进行磁盘、网卡、内存等硬件设备的测试。（因为太浪费时间了）
 
![](/images/centos-installation/005.png)
图 5

选择”Skip”之后，可能会出现图6所示界面，稍等一会儿，会自动跳入下个页面（如图7）。等待时间：几十秒~几分钟。

![](/images/centos-installation/006.png) 
图 6
 
步骤 5. 	出现如图7所示页面后，点击”Next”。

![](/images/centos-installation/007.png)
图 7
 
步骤 6. 	在如图8所示界面，选择安装CentOS过程中，页面的显示语言，当安装服务器时，建议选择“English（English）”。
备注：这一步选定哪种语言，貌似对安装系统没有影响，而实际测试发现，有些细微差异，例如，安装完系统后，系统环境变量LANG会有细微差异。

![](/images/centos-installation/008.png)
图 8
 
步骤 7. 	参照下图9~15，一步步安装下去即可。

![](/images/centos-installation/009.png)
图 9

图9：选择系统键盘语言，选“U.S. English”即可。

![](/images/centos-installation/010.png)
图 10

图10：选择系统安装的磁盘，选“Basic Storage Devices”。

![](/images/centos-installation/011.png) 
图 11

特别说明：有可能会出现图11界面，如果没有出现，则忽略图11。

图11：是否覆盖掉所有系统数据，如果是重装系统，数据已经做过备份，则直接选“Fresh Installation”。

![](/images/centos-installation/012.png)
图 12

图12：设定主机名（hostname），按照要求进行设置即可。

备注：

1.	在图11页面的左下角，也可以通过“配置网络”按钮来设定网络，但不建议在此通过页面来配置网络（因为可能碰到乱七八糟的问题），而建议安装完系统后，通过简单命令来配置网络。
2.	也可以安装完系统后，打开文件”/etc/sysconfig/network”，修改其中HOSTNAME字段。

![](/images/centos-installation/013.png)
图 13

图13：选定时区，选定“Asia/Shanghai”即可。

![](/images/centos-installation/014.png) 
图 14

图14：设定root密码

![](/images/centos-installation/015.png) 
图 15：选“Use Anyway”

图15：提示密码不够安全，直接点击“Use Anyway”（无论如何都使用）即可。

特别说明：至此，安装并没有结束，下面“2.2磁盘分区”部分才是重点。

 
###2.2.	磁盘分区

从图16开始，我们将进行磁盘分区，这一部分有些配置的东西，需要认真看了。

备注：在此之前，需要补充一点理论知识：

**1.	为什么要进行磁盘分区？**

磁盘分区两点考虑，也就是说两个好处：

* 数据安全：不同磁盘分区之间相互独立，某个分区损坏，不会影响其他分区内的数据；
* 读写性能：读写数据时，磁盘分区对应一段连续的磁柱，由于磁柱集中，提升数据的读写效率；

**2.	磁盘分区要分为几个区？**

磁盘分区方案，官网建议[7]，应该包含如下几个分区：

|分区|	作用	|官方建议大小|	此次安装使用|
|--|--|--|--|
|/boot|	存放OS kernel，以及系统bootstrap过程要使用的其他文件|	>250MB|	500MB|
|swap|	虚拟内存：当内存空间不足时使用此空间	|至少4GB，推荐为内存的1~2倍	|128GB （系统内存64GB）|
|/	|存放：系统安装文件|	3~5GB|	60GB|
|/home|	存放：user data \n单独分区的目标：将user data与系统文件隔离|	没有|	100GB（实际是sda磁盘的剩余空间）|

 
步骤 8. 	在图16界面，选择“Use All Space”，同时，勾选左下的“Review and modify partitioning layout”，目标：进入磁盘分区设置页面，调整磁盘分区。
 
![](/images/centos-installation/016.png)
图 16：选“Use All Space”和勾选“Review and modify partitioning layout”

中间可能要等待一段时间
 
步骤 9. 	在图17所示页面，选择要进行分区的的磁盘，通常将“Data Storage Devicess”中所有磁盘都添加到“Install Target Devices”中，添加结果如图18所示。

![](/images/centos-installation/017.png) 
图 17


![](/images/centos-installation/018.png) 
图 18

图18：将“Data Storage Devicess”中所有磁盘都添加到“Install Target Devices”后的结果。 

步骤 10. 	在图19所示页面，删除磁盘sda默认的分区：LVM Volume groups下的vg_cib61、sda下sda1和sda2；删除结果如图20所示。

特别说明：要删除sda2分区，需要先删除LVM Volume groups下的vg_cib61。

![](/images/centos-installation/019.png) 
图 19

![](/images/centos-installation/020.png)
图 20

图20：删除sda上所有分区之后的结果。 

步骤 11. 	在图20页面，按照提前规划的分区方案，在sda磁盘的Free空间上，依次划分/boot、swap、/、/home共计4个分区。

![](/images/centos-installation/021.png) 
图 21

图21：选择sda下Free空间，” Create” “Standard Partition”，即可进行创建分区，具体“/boot、swap、/、/home”的分区操作，依次参考图22、图23、图24、图25。

![](/images/centos-installation/022.png) 
图 22
 
![](/images/centos-installation/023.png)
图 23
 
![](/images/centos-installation/024.png)
图 24

![](/images/centos-installation/025.png)
图 25

步骤 12. 	这一步是进行LVM设置，如果没有LVM创建LV的需要，请直接跳过这一步，直接参考“步骤13”。 

在此之前，补充一点LVM相关的理论知识：

**1.	为什么要用LVM？**

**LVM要解决的典型问题**：一块磁盘的空间160GB，其存满数据后，需要扩容，怎么办？传统静态分区时，需要将磁盘中近160GB的数据复制到1TB的磁盘上，然后，使用1TB的磁盘替换掉原来160GB的磁盘。（这个是传统扩容的基本原理，还有其他的原理吗？）

**LVM基本原理**：要解决上面磁盘空间不足时，磁盘的扩容问题，LVM提供了一个基本思路：LVM将底层的磁盘封装抽象为逻辑卷（logical volume），上层应用不直接从物理磁盘分区中读数据，而是从逻辑卷中读数据；LVM负责底层磁盘到逻辑卷的映射和管理；增加底层磁盘时，通过LVM可以为逻辑卷动态扩充容量，而这对上层应用是无影响的（透明的）。

说这么多，总结一点：LVM能够将多个小磁盘抽象为一个大逻辑卷，并且支持磁盘的动态扩容，提高了磁盘管理的灵活性。

图26、图27、图28、图29：展示了在sdb1、sdc1、sdd1上创建一个大小约为850GB大小的VG（命名为vg_cib61），并且在这一VG上创建一个500GB大小的LV（lv_00）的基本过程。脑袋疼，不想多说，请自行查找其他资料。

![](/images/centos-installation/026.png) 
图 26
 
![](/images/centos-installation/027.png)
图 27
 
![](/images/centos-installation/028.png)
图 28
 
![](/images/centos-installation/029.png)
图 29

图29：创建Logical Volume时，并没有设置Mount Point，因为当前并不能确定挂载目录，装完系统之后，可以通过命令进行挂载。
 
步骤 13. 	设置完磁盘分区后，到达图30所示界面，直接点击“Next”。

特别说明：如果没有在步骤12中设置LVM，则没有图30中的“LVM Volume Groups”部分。

![](/images/centos-installation/030.png)
图 30
 
![](/images/centos-installation/031.png)
图 31：选“Write changes to disk”
 
![](/images/centos-installation/032.png)
图 32
 
![](/images/centos-installation/033.png)
图 33
 
![](/images/centos-installation/034.png)
图 34：选“Basic Server”
 
![](/images/centos-installation/035.png)
图 35
 
![](/images/centos-installation/036.png)
图 36

##3.	配置网络

安装完系统之后，需要进行网络配置，目标：保证机器能够入网。

通常直接修改/etc/sysconfig/network-scripts/ifcfg-eth0文件即可，此次使用的是静态配置IP方式，因此需要进行如下修改（保持ifcfg-eth0文件中其他字段不变）：

	ONBOOT=yes
	BOOTPROTO=static
	IPADDR=168.7.2.111
	NETMASK=255.255.255.0
	GATEWAY=168.7.2.126

特别说明：服务器上有eth0--eth5，共计6个网口，需要根据具体情况，修改配置文件，上例中修改的是ifcfg-eth0文件，而在其他服务器上，如果网线插在eth3口，则需要修改ifcfg-eth3文件。

有个小问题，值得说一下：服务器通常带有eth0--eth5多个网口，如何将eth0~5与实际的物理网口对应起来？

RE：需要借助工具：ethtool，执行命令`ethtool -p eth0`，再去看看那排网口，会有发现的~执行Ctrl + C，即可终止此命令。

##4.	格式化磁盘并挂载

场景 1.	格式化单个磁盘，并进行挂载，命令如下：

	# 格式化磁盘
	mkfs -t ext3 /dev/sdb1
	# 新建挂载点
	mkdir -p /srv/hadoop/data1
	# 挂载磁盘
	mount /dev/sdb1 /srv/hadoop/data1
 
场景 2.	批量格式化多个磁盘，并进行挂载，本质上就是重复“场景1”，只不过使用shell脚本来实现，脚本如下：

	for i in {b..k}; do mkfs -t ext3 /dev/sd${i}1; done

	for i in {1..10}; do mkdir -p /srv/hadoop/data${i}; done

	array=(b c d e f g h i j k)
	for((i=0;i<${#array[@]};i++)); do mount /dev/sd${array[i]}1 /srv/hadoop/data$(($i+1)); done


场景 3.	设置开机自动挂载磁盘

上面两个场景中，都涉及到mount磁盘到某个目录，但如果系统一不小心重启了，这些磁盘就需要重新挂载。解决办法：在fstab文件中设置开机自动挂载磁盘。
通过命令：man  fstab就可以查看fstab文件每列的含义：

|1|	2	|3	|4	|5	|6|
|--|--|--|--|--|--|
|`<special device>`|	`<mount point>`|	`<fs type>`|	`<mount options>`|	`<dump>`|	`<fsck>`|

上述/etc/fstab文件每行数据，都有6个字段，如上图所示，简要说明几点：

* 间隔符号：不同字段之间使用 ”空格” 或者 “Tab” 键来间隔
* special device：要挂载的设备，例如：/dev/sdb1;
* mount point：设备挂载的目标目录；
* fs type：要挂载的设备上文件系统的类型；
* options：mount命令进行挂载时，输入的参数；
* dump：是否要对此文件系统进行备份，0代表不做dump备份，1代表需要dump备份，2代表也需要dump备份，但2的重要程度低于1；
* fsck：系统启动时，是否检测文件系统的完整性，0代表不检测，根目录/需要设置为1，其他需要开机扫描的文件系统设置为2；

来个fstab文件的样例，朝着这个格式来做就可以：

	/dev/sdb1  /srv/hadoop/data1  ext3  defaults  0  0

配置完fstab文件，一定要来一条命令：`mount -a`
含义：`Mount all filesystems (of the given types) mentioned in fstab.`
这一命令可用于检查fstab文件中的配置是否正确。

##5.	参考来源

1. [CentOS简介][CentOS简介]
1. [Red Hat and CentOS Project Join Forces to Speed Open Source Innovation][Red Hat and CentOS Project Join Forces to Speed Open Source Innovation]
1. [CentOS 6 docs参考RHEL 6即可][CentOS 6 docs参考RHEL 6即可]
1. [RHEL官方文档][RHEL官方文档]
1. [RHEL 6官文文档“Installation Guide”][RHEL 6官文文档“Installation Guide”]
1. [设定bootloader][设定bootloader]
1. [Recommended Partitioning Schema][Recommended Partitioning Schema]


##6.	附录

几个有用的命令：

命令 1. 	`dmidecode -t 1`，查看当前服务器的序列号。

	[root@localhost ~]# dmidecode -t 1
	# dmidecode 2.11
	SMBIOS 2.7 present.

	Handle 0x0100, DMI type 1, 27 bytes
	System Information
			Manufacturer: HP
			Product Name: ProLiant ********
			Version: Not Specified
			Serial Number: ********
			UUID: ****-****-****-****-****
			Wake-up Type: Power Switch
			SKU Number: ****-****
			Family: ProLiant




[CentOS简介]:		http://www.centos.org/about/ 
[Red Hat and CentOS Project Join Forces to Speed Open Source Innovation]:		http://www.redhat.com/en/about/press-releases/red-hat-and-centos-join-forces
[CentOS 6 docs参考RHEL 6即可]:		http://lists.centos.org/pipermail/centos/2012-November/130123.html
[RHEL官方文档]:		https://access.redhat.com/documentation/en-US/Red_Hat_Enterprise_Linux/
[RHEL 6官文文档“Installation Guide”]:		https://access.redhat.com/documentation/en-US/Red_Hat_Enterprise_Linux/6/html/Installation_Guide/index.html
[设定bootloader]:		https://access.redhat.com/documentation/en-US/Red_Hat_Enterprise_Linux/6/html/Installation_Guide/s1-x86-bootloader.html
[Recommended Partitioning Schema]:		https://access.redhat.com/documentation/en-US/Red_Hat_Enterprise_Linux/6/html/Installation_Guide/s2-diskpartrecommend-x86.html


































[RHEL 6: Recommended Partitioning Scheme]:	https://access.redhat.com/documentation/en-US/Red_Hat_Enterprise_Linux/6/html/Installation_Guide/s2-diskpartrecommend-x86.html
[RHEL 6: Disk Partitioning Setup]:	https://access.redhat.com/documentation/en-US/Red_Hat_Enterprise_Linux/6/html/Installation_Guide/s1-diskpartsetup-x86.html
[CentOS 6 docs?]:	http://lists.centos.org/pipermail/centos/2012-November/130123.html
[RHEL 6: Installation Guide]:	https://access.redhat.com/documentation/en-US/Red_Hat_Enterprise_Linux/6/html/Installation_Guide/index.html
[An Introduction to Disk Partitions]:	https://access.redhat.com/documentation/en-US/Red_Hat_Enterprise_Linux/6/html/Installation_Guide/ch-partitions-x86.html#tb-partitions-types-x86