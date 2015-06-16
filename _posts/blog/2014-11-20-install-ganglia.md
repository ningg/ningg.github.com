---
layout: post
title: Ganglia简介与安装
description: 系统监控
categories: ganglia linux
---



##背景

（当前文档仍然需要再梳理一遍）


准备监控整个Flume、Kafka、Storm框架运行状态，不想重复造轮子，初步查询官网发现这个几个东西都可以跟Ganglia结合。初步查了一下Ganglia的应用很广泛，上Ganglia，走起。


##Ganglia基本知识

[Ganglia官网][Ganglia]提供了较为简介的介绍，整理一下有几点：

* Ganglia是一个可扩展性不错的分布式监控系统；
* 监控对象：集群，这个集群上可以有分布式系统，也可以只是单独的集群；
* Ganglia本身就是分布式的集群，那就有集群结构，Ganglia集群采用分层结构；
* Ganglia利用了一些现有的技术，列几个：
	* XML for data representation;
	* XDR for compact, portable data transport;
	* RDDtool for data storage and visualization;
	* data structures and algorithms to achieve very low per-node overheads and high concurrency;


###软件版本信息

此次采用最新的Ganglia版本，具体：

* [ganglia-3.6.1(ganglia monitoring core)][ganglia-3.6.1(ganglia monitoring core)]
* [ganglia-3.6.2(ganglia-web)][ganglia-3.6.2(ganglia-web)]
	
当前（2014-11-20），Ganglia由以下几个组件构成：

* 2个 unique daemons：`gmond`、`gmetad`;
* 1个 PHP-based web frontend;
* 几个 small utility programs;


**特别说明**：下面针对Ganglia组件的介绍，完全参考自ganglia-3.6.1:ganglia monitoring core源码压缩包中的ganglia.html文件。

###Ganglia Monitoring Daemon (gmond)

Gmond is a multi-threaded daemon which runs on each cluster node you want to monitor. Installation is easy. You don't have to have a common NFS filesystem or a database backend, install special accounts, maintain configuration files or other annoying hassles.

Gmond has four main responsibilities: monitor changes in host state, announce relevant changes, listen to the state of all other ganglia nodes via a unicast or multicast channel and answer requests for an XML description of the cluster state.

Each gmond transmits in information in two different ways: unicasting/multicasting host state in external data representation (XDR) format using UDP messages or sending XML over a TCP connection.

**notes(ningg)**：关于`gmond` daemon说几点：

* gmond部署位置：每一个需要监控的node；
* gmond需要的配置：安装简便，不依赖数据库；
* gmond进程的作用：
	* monitor changes in host state
	* announce relevant changes
	* listen to the state of all other ganglia nodes via a unicast or multicast channel
	* answer requests for an XML description of the cluster state
* gmond进程向其他节点发送信息（unicasting or multicasting）有两种方式：
	* UDP：external data representation（XDR）；
	* TCP：XML；

###Ganglia Meta Daemon (gmetad)

Federation in Ganglia is achieved using a tree of point-to-point connections amongst representative cluster nodes to aggregate the state of multiple clusters. At each node in the tree, a Ganglia Meta Daemon (gmetad) periodically polls a collection of child data sources, parses the collected XML, saves all numeric, volatile metrics to round-robin databases and exports the aggregated XML over a TCP sockets to clients. Data sources may be either gmond daemons, representing specific clusters, or other gmetad daemons, representing sets of clusters. Data sources use source IP addresses for access control and can be specified using multiple IP addresses for failover. The latter capability is natural for aggregating data from clusters since each gmond daemon contains the entire state of its cluster.

**notes(ningg)**：关于gmetad说几点：

* Ganglia也是集群，那就有集群的结构，Ganglia：树状结构；
* gmetad部署位置：树的每个node上；
* gmetad进程的作用：
	* periodically polls a collection of child data sources
	* parses the collected XML
	* saves all numeric, volatile metrics to round-robin databases
	* exports the aggregated XML over a TCP sockets to clients
* gmetad进程从child data source收集数据，data source是指：
	* gmond daemons, representing specific clusters
	* other gmetad daemons, representing sets of clusters
* data source有几个区分点：
	* use source IP addresses for access control
	* using multiple IP addresses for failover（失效备援）


###Ganglia PHP Web Frontend


The Ganglia web frontend provides a view of the gathered information via real-time dynamic web pages. Most importantly, it displays Ganglia data in a meaningful way for system administrators and computer users. Although the web frontend to ganglia started as a simple HTML view of the XML tree, it has evolved into a system that keeps a colorful history of all collected data.

The Ganglia web frontend caters to system administrators and users. For example, one can view the CPU utilization over the past hour, day, week, month, or year. The web frontend shows similar graphs for Memory usage, disk usage, network statistics, number of running processes, and all other Ganglia metrics.

The web frontend depends on the existence of the `gmetad` which provides it with data from several Ganglia sources. Specifically, the web frontend will open the local port `8651` (by default) and expects to receive a Ganglia XML tree. The web pages themselves are highly dynamic; any change to the Ganglia data appears immediately on the site. This behavior leads to a very responsive site, but requires that the full XML tree be parsed on every page access. Therefore, the Ganglia web frontend should run on a fairly powerful, dedicated machine if it presents a large amount of data.

The Ganglia web frontend is written in the PHP scripting language, and uses graphs generated by gmetad to display history information. It has been tested on many flavours of Unix (primarily Linux) with the Apache webserver and the PHP module (5.0.0 or later). The GD graphics library for PHP is used to generate pie charts in the frontend and needs to be installed separately. On RPM-based system, it is usually provided by the php-gd package.

**notes(ningg)**：关于PHP Web Frontend说几点：

* 提供real-time dynamic web pages；这个实时的动态页面信息是如何获得的呢？
	* 每个web page都需要解析整个XML tree；
	* 如果data的量比较大，则建议web frontend运行在一个专用的主机上；
* 能够提供的监控数据：
	* CPU利用率
	* Memory usage
	* disk usage
	* network statistics
	* number of running processes等等；
* 时间维度上：hour、day、week、month、year；
* Web Frontend依赖于`gmetad`进程，gmetad进程负责从Ganglia sources中获取data并提供给web frontend；
* Web Frontend默认开启`8651`端口，来接收Ganglia XML tree数据；
* Ganglia Web Frontend是PHP语言实现的，并且通过安装GD graphics library（php）可展现饼状图；


**notes(ningg)**：疑问，Web Frontend 只能读取其运行的服务器上`gmetad`提供的数据？这就是说，要求web frontend必须运行在整个Ganglia集群的树状结构的根节点？


##配置基础环境

当前服务器基本环境（CentOS 6.4 x86_64）：

	[root@localhost html]# lsb_release -a
	LSB Version:    :base-4.0-amd64:base-4.0-noarch:core-4.0-amd64:core-4.0-noarch:graphics-4.0-amd64:graphics-4.0-noarch:printing-4.0-amd64:printing-4.0-noarch
	Distributor ID: CentOS
	Description:    CentOS release 6.4 (Final)

###新增用户和组

为方便所有操作，以及进行权限管理，新建用户ganglia：

	useradd ganglia
	# 默认，创建user：ganglia时，也创建了group：ganglia
	# groupadd ganglia

如何卸载gweb？（make uninstall）
	
###几个基本组件

`gmetad`进程需要去[rrdtool][rrdtool]，同时如果要同时在node上安装`gmetad`和`gmond`，则需要提前安装：`apr*`、`pcre*`、`zlib*`，具体：

	#gcc
	yum install gcc
	
	#rrdtool
	yum install rrdtool
	yum install rrdtool-devel

	#apr
	yum install apr
	yum install apr-devel

	#libpcre
	yum install pcre
	yum install pcre-devel

	#zlib-devel
	yum install zlib
	yum install zlib-devel
	
	#python-devel
	yum install python
	yum install python-devel
	
	#gperf
	yum install gperf
	
上面这么多组件，也可以运行一条命令完成安装：

	sudo yum install gcc rrdtool rrdtool-devel apr apr-devel pcre pcre-devel zlib zlib-devel pyton python-devel gperf
	
###libconfuse

	# 出错信息
	libconfuse not found

	... can not be used when making a shared object; recompile with -fPIC
	/usr/local/confuse/lib/libconfuse.a: could not read symbols: Bad value
	
具体版本信息：confuse-2.7.tar.gz，下载来源：

* [libconfuse][libconfuse]
* [libconfuse(GitHub)][libconfuse(GitHub)]

下载之后，直接安装即可。
	
	tar -zxvf confuse-2.7.tar.gz
	cd confuse-2.7
	
	./configure CFLAGS=-fPIC --disable-nls
	make
	make install

###libexpat

	# 出错信息
	libexpat not found

具体版本信息：expat-2.1.0.tar.gz，下载来源：

* [libexpat][libexpat]
* [libexpat(GitHub)][libexpat(GitHub)]

下载之后，直接安装即可。

	tar -zxvf expat-2.1.0.tar.gz
	cd expat-2.1.0
	
	./configure
	make
	make install


##安装Ganglia

安装Ganglia有几种方式：

* rpm包：rpm -Uvh ganglia-*.rpm *（http://dl.fedoraproject.org/pub/epel/6/x86_64/ 中有ganglia 3.1相关的rpm包）*
* yum源：yum install ganglia*
* 本地编译源代码：make && make install

由于在[Ganglia官网][ganglia-3.6.2(ganglia-web)]上没有找到最新的rpm包，并且本地配置的yum源没有提供ganglia组件，因此本次采用编译源代码方式。

在前面配置好基础环境之后，这一部分简要说一下，如何安装、启动Ganglia，具体包括：

* gmond
* gmetad
* web frontend

###gmond和gmetad

此次安装版本为：[ganglia-3.6.1(ganglia monitoring core)][ganglia-3.6.1(ganglia monitoring core)]
	
安装命令：

	tar -zxvf ganglia-3.6.1.tar.gz
	cd ganglia-3.6.1
	
	# ./configure默认安装 gmond
	# 利用 --with-gmetad选项，同时安装 gmetad
	./configure --with-gmetad --enable-gexec
	make
	make install

####配置gmetad
	
由于gmetad依赖rrdtool，需要设置两个东西：

设置datasource和UID，具体：
	
	vim /usr/local/etc/gmetad.conf
	data_source "RT-SYS" localhost
	setuid_username "apache"

设置rrdtool的数据目录，具体命令：

	mkdir -p /var/lib/ganglia/rrds
	chown -R apache:apache /var/lib/ganglia/rrds

上述`chown`时，利用的用户UID与gmetad.conf中`setuid_username`的配置保持一致；另外，安装配置好之后，可通过命令`gmetad -d 2`来在前台运行gmetad进程，以方便查看其运行状态。

####配置gmond

利用gmond的默认配置生成配置文件：

	gmond -t > /usr/local/etc/gmond.conf
	
	vim /usr/local/etc/gmond.conf
	cluster {  
		name="RT-SYS"   //和gmetad.conf配置文件对应  
		owner="apache"   //和gmetad.conf配置文件对应  
		latlong="unspecified"  
		url="unspecified"  
	}  
	
**备注**：`whereis`命令的用途？例如下面怎么解释

	[root@localhost html]# whereis gmond
	gmond: /usr/local/sbin/gmond /usr/local/etc/gmond.conf

gmond的详细信息，可以通过命令`man gmond`和`man gmond.conf`来查看。

###添加服务：gmond、gmetad


通过上述安装步骤，服务器上应该已经安装了以下文件：

* /usr/local/bin/gstat
* /usr/local/bin/gmetric
* /usr/local/sbin/gmond
* /usr/local/sbin/gmetad

**备注**：本地实测是上面的位置，与官方源码自带文档ganglia-3.6.1/ganglia.html的说法有差异。

在Linux上按照上述步骤，通过编译源码方式安装的的Ganglia，那可以将`gmond`和`gmetad`添加到sys service中，并且配置是否开机启动。
配置gmetad服务步骤如下（gmond同理）：

	[root@cib02166 ganglia-3.6.1]# cd gmetad
	[root@localhost gmetad]# cp gmetad.init /etc/rc.d/init.d/gmetad
	
	[root@localhost gmetad]# vim /etc/init.d/gmetad
	# 修改/etc/init.d/gmetad中 GMETAD=/usr/local/sbin/gmetad


	[root@localhost gmetad]# chkconfig --add gmetad
	[root@localhost gmetad]# chkconfig --list gmetad
	gmetad          0:off   1:off   2:on    3:on    4:on    5:on    6:off

	[root@localhost gmetad]# service gmetad start
	Starting GANGLIA gmetad:                                   [  OK  ]

**思考**：如何验证gmond、gmetad已经正常安装并成功启动？

**RE**：两种方法

* 方法1：通过命令`netstat -tpnl | grep "gmond"`即可查看是否启动，当然也可以通过`service gmond status`查看；
* 方法2：通过`gmond -d 5`在前台启动进程，并查看输出信息。


**思考**：

* 不添加service，怎么启动gmond、gmeta？
* 为什么要有gmetad.init？
* /etc/rc.d/init.d/目录又是干什么的？
* chkconfig命令的含义？

###web frontend

####安装前准备

此次安装版本为：[ganglia-3.6.2(ganglia-web)][ganglia-3.6.2(ganglia-web)]

**注意**：提前说几点：

* 运行web frontend的节点，需要提前安装gmetad进程；
* `ganglia-web-3.6.2/conf.php`文件包含了大部分的配置信息：
	* template
	* gmetad location
	* RRDtool location
	* set the default time range and metrics for graphs

提前安装配置Apache服务器，具体安装命令：
	
	# 安装apache服务器，以及PHP支持的组件
	yum install php-common php-cli php php-gd httpd

####安装web frontend（推荐）

在ganglia web的解压文件中能够看到一个文件`Makefile`，通过对其进行设置就可以实现web frontend的快捷安装，具体要配置的参数如下：

	# Location where gweb should be installed to (excluding conf, dwoo dirs).
	GDESTDIR = /usr/share/ganglia-webfrontend

	# Location where default apache configuration should be installed to.
	GCONFDIR = /etc/ganglia-web

	# Gweb statedir (where conf dir and Dwoo templates dir are stored)
	GWEB_STATEDIR = /var/lib/ganglia-web

	# Gmetad rootdir (parent location of rrd folder)
	GMETAD_ROOTDIR = /var/lib/ganglia

	APACHE_USER = www-data

将对上面可配置的参数进行简要介绍：

* GDESTDIR：Location where gweb should be installed to (excluding conf, dwoo dirs)，要与Apache服务器的配置文件`http.conf`中`$DocumentRoot`保持一致，通常命名为`$DocumentRoot/ganglia`
* GCONFDIR：Location where default apache configuration should be installed to.*（什么含义？）*
* GWEB_STATEDIR：Gweb statedir (where conf dir and Dwoo templates dir are stored)
* GMETAD_ROOTDIR：gmetad rootdir，parrent localtion of rrd folder
* APACHE_USER：设置Apache服务器的UID，具体，与Apache服务器配置文件`http.conf`中`$User`保持一致

配置完`Makefile`文件后，直接运行如下命令：

	cd ganglia-web-3.6.2
	make install
	
	service httpd start
	service gmetad start

打开浏览器，查看[http://locahost/ganglia]
	
（疑问：makefile的作用？单纯的命令集合吗？）
	
	
####安装web frontend（弃用）
	
	tar -zxvf ganglia-web-3.6.2.tar.gz
	cd ganglia-web-3.6.2
	
	# 将整个文件夹ganglia-web-3.6.2复制到apache服务器的DocumentRoot所指定的目录下
	cp -a -f ganglia-web-3.6.2 /var/www/html/
	ln -s /var/www/html/ganglia-web-3.6.2 /var/www/html/ganglia
	
	service httpd restart
	
然后通过：[http://locahost/ganglia]即可访问。如果[http://locahost/ganglia]显示如下页面：

![](/images/install-ganglia/web-frontend-error.jpg)

大意是说无法创建目录以及文件，OK，估计是权限问题，在后台，手动创建一个根目录，并将owner更改为apache（是启动httpd的用户）：

	mkdir -p /var/lib/ganglia-web/conf
	mkdir -p /var/lib/ganglia-web/dwoo/cache
	mkdir -p /var/lib/ganglia-web/dwoo/compiled
	chown -R apache:apache /var/lib/ganglia-web



##遇到的错误以及解决办法

###错误1

	# service gmond start时，出现错误：
	error while loading shared libraries: libconfuse.so.0: cannot open shared object file: No such file or directory
	
解决办法：
	
	cd /usr/local/lib
	ln -s libconfuse.so.0 libconfuse.so.0.0.0
	cp libconfuse.so.0 ../lib64/
	service gmond start
	
###错误2

启动gmetad之后，通过命令`service gmetad status`查询出现：

	gmetad dead but subsys locked

分析：上述错误没有见过呀，`subsys locked`很眼熟，应该是进程已被锁定，但有这一点信息还不够，遇到问题时，基本思路：

* 收集详细的错误信息，来分析错误；
* 根据上述分析，采取处理对策；

解决办法：

`gmetad`进程的启动日志在哪？文件`/var/log/messages`；*（启动信息输出到messages中，这是在哪设置的？）*通过如下命令来查看具体信息：

	[root@localhost log]# tail -f messages
	/usr/local/sbin/gmetad[9510]: Please make sure that /var/lib/ganglia/rrds exists: No such file or directory

奥，原来gmetad进程存储数据的目录`/var/lib/ganglia/rrds`没有创建，抓紧创建一下（命令：`mkdir -p /var/lib/ganglia/rrds`），再次启动gmetad，还是不行，查看错误信息：

	[root@localhost log]# tail -f messages
	/usr/local/sbin/gmetad[11701]: Please make sure that /var/lib/ganglia/rrds is owned by nobody
	
gmetad在启动之后，会自动归指定UID接管，具体在`/usr/local/etc/gmetad.conf`中配置`setuid_username`：
	
	#-------------------------------------------------------------------------------
	# If you don't want gmetad to setuid then set this to off
	# default: on
	# setuid off
	#
	#-------------------------------------------------------------------------------
	# User gmetad will setuid to (defaults to "nobody")
	# default: "nobody"
	setuid_username "storm"
	#
	#-------------------------------------------------------------------------------

然后，修改目录`/var/lib/ganglia/rrds`的所属用户和组（与上述设置保持一致）：

	chown -R storm:storm /var/lib/ganglia/rrds
	
OK，再次启动gmetad，成功启动。

###错误3

通过rpm包或者yum源方式安装web frontend时，默认web frontend会被安装在`/usr/share/ganglia-webfrontend`目录下，这样通过[http://locahost/ganglia]()就无法进行访问。

解决办法：

	# 利用符号链接
	ln -s /usr/share/ganglia-webfrontend /var/www/html/ganglia

###错误4

通过浏览器访问[http://locahost/ganglia]()时，出现如下错误信息：

	There was an error collecting ganglia data (127.0.0.1:8652):fsockopen error: Permission denied 解决方法

解决办法：

	setenforce 0

附：

* setenforce 1 设置SELinux 成为enforcing模式
* setenforce 0 设置SELinux 成为permissive模式
	
	
**疑问**：Linux下SELinux是什么安全机制？`setenforce 0`的含义是什么？
	
###错误5

在一批新服务器上，安装的Linux版本与上文提到的一致；
按照本文前一部分的步骤来安装Ganglia时，当执行`./configure --with-gmetad --enable-gexec`之后，再执行`make`命令时，具体出错信息如下：

	libtool: link: gcc -std=gnu99 -I../lib -I../gmond -I../include -D_LARGEFILE64_SOURCE -g -O2 -fno-strict-aliasing -Wall -D_REENTRANT -o .libs/gmetad gmetad.o cmdline.o data_thread.o server.o process_xml.o rrd_helpers.o export_helpers.o conf.o type_hash.o xml_hash.o cleanup.o daemon_init.o  /usr/lib64/libapr-1.so ../lib/.libs/libganglia.so -lrrd -lm -ldl -lnsl -lz -lpcre -lexpat -lconfuse -lpthread -pthread -Wl,-rpath -Wl,/usr/lib64 -Wl,-rpath -Wl,/usr/local/lib64
	gmetad.o: In function 'write_root_summary':
	/home/storm/goodjob/ganglia/ganglia-3.6.1/gmetad/gmetad.c:239: undefined reference to 'in_type_list'
	gmetad.o: In function 'sum_metrics':
	/home/storm/goodjob/ganglia/ganglia-3.6.1/gmetad/gmetad.c:157: undefined reference to 'in_type_list'
	server.o: In function 'metric_summary':
	/home/storm/goodjob/ganglia/ganglia-3.6.1/gmetad/server.c:76: undefined reference to 'in_type_list'
	process_xml.o: In function 'finish_processing_source':
	/home/storm/goodjob/ganglia/ganglia-3.6.1/gmetad/process_xml.c:1084: undefined reference to 'in_type_list'
	process_xml.o: In function 'fillmetric':
	/home/storm/goodjob/ganglia/ganglia-3.6.1/gmetad/process_xml.c:97: undefined reference to 'in_type_list'
	process_xml.o:/home/storm/goodjob/ganglia/ganglia-3.6.1/gmetad/process_xml.c:627: more undefined references to 'in_type_list' follow
	collect2: ld returned 1 exit status
	make[2]: *** [gmetad] Error 1
	make[2]: Leaving directory '/home/storm/goodjob/ganglia/ganglia-3.6.1/gmetad'
	make[1]: *** [all-recursive] Error 1
	make[1]: Leaving directory '/home/storm/goodjob/ganglia/ganglia-3.6.1'
	make: * [all] Error 2

在网上一顿乱收，没有找到解决方案，倒过头来，看看上面的出错信息，貌似是gmetad安装过程出的错，OK，那只安装gmond就可以了吧，试试`./configure --enable-gexec`命令，OK，可以了。






###补充思考

**疑问**：本文中实际是直接编译源码来安装组件的，即：`./configure`以及`make install`方式，那有个问题：在安装成功后，删掉安装时使用的源码文件，会影响安装的组件吗？*（个人感觉应该不影响才是基本需求）*

**RE**：要弄清上面的问题，需要弄清楚`./configure`以及`make install`执行过程中，导致进行了哪些操作？即：如何将软件安装到哪了？配置文件在哪？


##配置Ganglia集群的拓扑

上面主要说的是一个目标：在一台服务器上安装Ganglia的组件：gmond、gmetad、web frontend；这些都是针对单个服务器（single ganglia node）来说的。那如何将多个Ganglia node构成一个Ganglia cluster呢？之前我们简单提到：Ganglia是按照树状结构来组织的，下面将说一下细节。

构成拓扑的有几个概念：node、cluster、grid，什么含义？

**疑问**：同一台服务器上，能够部署多个gmond吗？有个问题是：我在3台服务器上，同时部署了3个集群：Flume Cluster、Kafka Cluster、Storm Cluster，希望能够在3个页面上分别监控每个集群的情况。这就涉及一个问题：Ganglia监控的基本单元是物理服务器？还是逻辑上的一个节点？在应用层，Ganglia监控服务情况如何？


（doing...）

##与Ganglia集成

（通过Ganglia来监控Flume、Kafka、Storm的运行状态，不仅仅是OS层面的，更重要的是具体应用及其组件的运行状态）

（doing...）





##回顾与总结

Ganglia用于监测分布式系统的运行状态，如何把Ganglia集群用起来？

* 安装Ganglia：
	* Ganglia本身也是集群；
	* Ganglia集群拓扑是树状结构；
	* 在Ganglia集群的所有node上安装Ganglia组件；
	* 配置Ganglia集群的拓扑结构；
	* 在某个服务器上，汇总并实时刷新监控数据；
* 定制Ganglia来监控应用系统：
	* （如何定制？下面是随便说的）
	* 需要监控服务器OS的运行情况，在这些服务器上安装Ganglia的gmond；
	* 在Flume、Kafka、Storm运行的服务器上，监控JVM应用的状态，只需要JMX+JMXTrans即可，不必安装Ganglia的gmond；
	* Ganglia gmond收集应用的运行状态数据，并汇总到Ganglia的某个node*(gmond或者gmetad)*；
	* 疑问：在Ganglia集群外的某个服务器上，可以安装、使用web frontend吗？可以，但需要在服务器上配置一个gmetad；





##参考来源

* [分布式监控工具Ganglia介绍与集群部署][分布式监控工具Ganglia介绍与集群部署]
* [GangLia简介][GangLia简介]
* [Ganglia(GitHub)][Ganglia(GitHub)]
* [libexpat(GitHub)][libexpat(GitHub)]
* [libconfuse(GitHub)][libconfuse(GitHub)]
* [编译出错 recompile with -fPIC][编译出错 recompile with -fPIC]
* [Problems compiling ganglia 3.1][Problems compiling ganglia 3.1]
* [gmetad dead but subsys locked][gmetad dead but subsys locked]
* [Setup and configure Ganglia-3.6 on CentOS/RHEL 6.3][Setup and configure Ganglia-3.6 on CentOS/RHEL 6.3]
* [Ganglia 体系结构及功能介绍][Ganglia 体系结构及功能介绍]（力荐）
* Massie M L, Chun B N, Culler D E. [The ganglia distributed monitoring system: design, implementation, and experience][The ganglia distributed monitoring system: design, implementation, and experience] Journal. Parallel Computing, 2004, 30(7): 817-840.
* [Ganglia安装过程][Ganglia安装过程]


**notes(ningg)**：关于gmond的配置信息，官方参考来源有几个：

* ganglia-3.6.1:ganglia monitoring core源码中ganglia.html文件有Configuration介绍；
* ganglia-3.6.1:ganglia monitoring core源码中gmond/gmond.conf.html文件有详尽的说明；
* 安装完gmond之后，`man gmond`可查看gmond命令的基本信息，`man gmond.conf`可以参看gmond详细的配置信息；
* sourceforge上的[Ganglia Mailing Lists][Ganglia Mailing Lists]，可以直接搜索；*（Ganglia跟之前接触的Apache开源项目不同，其在sourceforge上进行讨论，因此通过Mailing Lists搜索问题，是获取信息的关键途径）*
* [Monitoring with Ganglia][Monitoring with Ganglia]

**特别推荐参考来源**：又有新发现，GitHub上有wiki：

* [Ganglia core(GitHub) WIKI][Ganglia core(GitHub) WIKI]
* [Ganglia web(GitHub) WIKI][Ganglia web(GitHub) WIKI]

##闲谈

今天无意间看到`YUKI小糖`的[Ganglia集群部署文章][分布式监控工具Ganglia介绍与集群部署]，看到其也会在博文中唠叨几句；突然相当，我x，难道这是工程师的共同习性吗？莫不是因为一天到晚跟机器接触太久了，没有人说话，就通过博客来唠叨了吧~~啊哈哈~~*（平静一下心情，细想想，还是挺凄凉的...）*



[NingG]:    					http://ningg.github.com  "NingG"
	
[rrdtool]:						http://www.rrdtool.org/
[Ganglia]:						http://ganglia.info/
[Ganglia(GitHub)]:				https://github.com/ganglia
[Ganglia web(GitHub) WIKI]:		https://github.com/ganglia/ganglia-web/wiki
[Ganglia core(GitHub) WIKI]:	https://github.com/ganglia/monitor-core/wiki


[libexpat]:					http://www.libexpat.org/
[libexpat(GitHub)]:			https://github.com/LuaDist/libexpat
[libconfuse]:				http://www.nongnu.org/confuse/
[libconfuse(GitHub)]:		https://github.com/martinh/libconfuse

[ganglia-3.6.1(ganglia monitoring core)]:	http://sourceforge.net/projects/ganglia/files/
[ganglia-3.6.2(ganglia-web)]:				http://sourceforge.net/projects/ganglia/files/
[分布式监控工具Ganglia介绍与集群部署]:		http://www.cnblogs.com/yuki-lau/p/3201110.html

[GangLia简介]:								http://blog.csdn.net/shenlan211314/article/details/7421758
[编译出错 recompile with -fPIC]:			http://blog.csdn.net/xqj198404/article/details/9447211
[Problems compiling ganglia 3.1]:			http://sourceforge.net/p/ganglia/mailman/message/19414944/
[Ganglia Mailing Lists]:					http://sourceforge.net/p/ganglia/mailman/
[CentOS安装配置ganglia]:					http://blog.csdn.net/wsgzg1991/article/details/9496907

[Monitoring with Ganglia]:					/monitoring_with_ganglia.zip
[Ganglia 体系结构及功能介绍]:				http://yaoweibin2008.blog.163.com/blog/static/11031392008763256465/

[Ganglia安装过程]:							http://blog.csdn.net/xxd851116/article/details/21527055




[The ganglia distributed monitoring system: design, implementation, and experience]:		The-Ganglia-Distributed-Monitoring-System.pdf
[Setup and configure Ganglia-3.6 on CentOS/RHEL 6.3]:		https://sachinsharm.wordpress.com/2013/08/17/setup-and-configure-ganglia-3-6-on-centosrhel-6-3/
[gmetad dead but subsys locked]:			http://sourceforge.net/p/ganglia/mailman/ganglia-general/thread/A526454B-CDD5-4B0F-9805-68A92B9459E9@crackpot.org/
