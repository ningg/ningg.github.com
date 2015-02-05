---
layout: post
title: 不同OS环境下部署Flume Agent
description: Flume用于收集信息，因此，不可避免的，需要部署在不同的环境
category: flume
---


##分析

开篇扯一扯，Flume Agent要部署到不同的OS环境下，典型的代表：Win XP、Win Server 2008、Linux、Unix。Flume运行在JVM之上，正常情况下，只要安装JRE即可运行Flume Agent。查看[Flume官方文档][Flume User Guide]，安装Flume Agent时，系统要满足如下几个要求：

* **Java Runtime Environment** - Java 1.6 or later (Java 1.7 Recommended)
* **Memory** - Sufficient memory for configurations used by sources, channels or sinks
* **Disk Space** - Sufficient disk space for configurations used by channels or sinks
* **Directory Permissions** - Read/Write permissions for directories used by agent

整体上，在windows下安装Flume-ng的解决方案，有几个信息源：

* Flume官网：官网、讨论区；
* Hadoop商业版企业Hortonworks、Cloudera等；
* 通过Search Engine查找；

##Windows XP

在Win XP下安装部署一个Flume Agent，同时利用Tail命令实时收集某一文件上追加的内容，简单说，分下面几步：

* 下载Flume Agent；
* 下载Windows XP下的Tail命令；
* 定制Flume Agent的bat启动脚本；

###下载Flume Agent

下载地址：[Flume官方下载地址][Flume download]

###下载Window XP下的Tail命令

在StackOverflow上简要查了一下，UnxUtils，GNU utilities for Win32，可在Win32下实现tail命令，具体下载地址：[UnxUtils官网][UnxUtils]。

###定制Windown XP下的bat启动脚本

在Linux下启动Flume，使用的是`bin/flume-ng`脚本，这个脚本需要`bash shell`环境的支持，而Windows下没有`bash shell`，这样是不是就没有办法在Windows下启动Flume了？仔细想一下，两点：

* Flume是运行在JVM上的，有JRE就可以启动了；
* `bin/flume-ng`启动脚本，本质就是启动JVM实例；
* Windows下编写一个简单的bat脚本，就可以实现`bin/flume-ng`类似的功能；

上面基本思路理清楚了，去官网查一下，看看有没有人在Windows XP下进行Flume Agent的部署，借鉴一下。找到如下几个参考来源：

* [Flume windows version][Flume windows version]
* [windows下编译flume][windows下编译flume]
* [Build Flume 1.3.x on Windows][Build Flume 1.3.x on Windows]

具体编写之后的`bin/flume-win.bat`启动脚本如下：

	::@echo off

	::USAGE: 	apache-flume-1.5.0.1-bin>call bin/flume-win*.bat
	::AUTHOER:	Ning Guo of CIB
	::TIME:		2014/11/28  12:55

	::set java home
	set JAVA_HOME="D:\Program Files\Java\jdk1.7.0_67"

	::set configuration file
	set CONF_FILE=logToKafka.properties

	::set agent name 
	set AGENT_NAME=agent


	::retrieve the parent directory
	setlocal
	for %%i in ("%~dp0..") do set "folder=%%~fi"
	set FLUME_HOME="%folder%"


	%JAVA_HOME%\bin\java.exe -Xms128m -Xmx512m -Dflume.monitoring.type=ganglia -Dflume.monitoring.hosts=168.7.2.165:8649 -Dlog4j.configuration=file:///%FLUME_HOME%\conf\log4j.properties -cp %FLUME_HOME%\lib\* org.apache.flume.node.Application -f %FLUME_HOME%\conf\%CONF_FILE% -n %AGENT_NAME%

	pause
	
	

上述涉及flume的配置文件`logToKafka.properties`，其内容如下：


	############################################################## COMPONENTS
	# The configuration file needs to define the sources, 
	# the channels and the sinks.
	# Sources, channels and sinks are defined per agent, 
	# in this case called 'agent'

	agent.sources = seqGenSrc
	agent.channels = memoryChannel
	agent.sinks = loggerSink


	############################################################## SOURCES
	# For each one of the sources, the type is defined


	# Exec Source For Flume agent on Win XP(UnxUtils).
	agent.sources.seqGenSrc.type = exec
	agent.sources.seqGenSrc.command = E:\reference\svn-new-doc\flume\UnxUtils\usr\local\wbin\tail.exe --follow=name --retry E:/1.log
	agent.sources.seqGenSrc.restart = true
	agent.sources.seqGenSrc.restartThrottle = 1000
	agent.sources.seqGenSrc.batchSize = 100
	#agent.sources.seqGenSrc.charset = GBK


	# Exec Source For Flume agent on Win Server 2008.
	#agent.sources.seqGenSrc.type = exec
	#agent.sources.seqGenSrc.command = get-content d:/flume/1.log -wait
	#agent.sources.seqGenSrc.shell = powershell
	#agent.sources.seqGenSrc.restart = true
	#agent.sources.seqGenSrc.restartThrottle = 1000
	#agent.sources.seqGenSrc.batchSize = 100
	#agent.sources.seqGenSrc.charset = GBK


	############################################################## SINKS

	agent.sinks.loggerSink.type = com.thilinamb.flume.sink.KafkaSink 
	#agent.sinks.loggerSink.topic = goodjob
	agent.sinks.loggerSink.topic = good
	#agent.sinks.loggerSink.charset = GBK
	agent.sinks.loggerSink.kafka.metadata.broker.list = 168.7.1.67:9091,168.7.1.68:9091,168.7.1.69:9091,168.7.1.70:9091
	agent.sinks.loggerSink.kafka.serializer.class = kafka.serializer.StringEncoder
	agent.sinks.loggerSink.kafka.request.required.acks = 1


	############################################################## CHANNELS
	# Each channel's type is defined.
	agent.channels.memoryChannel.type = memory
	agent.channels.memoryChannel.capacity = 100000

	
	############################################################## RELATIONS
	# The channel can be defined as follows.
	agent.sources.seqGenSrc.channels = memoryChannel

	#Specify the channel the sink should use
	agent.sinks.loggerSink.channel = memoryChannel

	
	
**补充说明**：此次启动的Flume Agent通过本地tail命令收集日志内容，并通过KafkaSink将信息送入Kafka中，具体涉及几点：

* Flume的插件`plugins.d`，在重写的`flume-win.bat`脚本中，并没有去扫描插件目录`plugins.d`，并且在`-cp`选项后通过`:`添加路径的目录，将导致`flume-win.bat`；




	
##Windows Server 2008

Windows Server 2008 与Windows XP基本相同，只需要调整一下`logToKafka.properties`脚本中sources部分，将command由`tail`（UnxUtils）替换为`get-content`（powershell），因为UnxUtils下的`tail`命令，在Windows Server 2008环境下，在Flume的source中时，无法捕获日志内容。**（很奇怪，原因不明）**

**原因定位**：在windows下，`tail -f`命令无法使用的原因，初步确定是因为，`tail -f`进程没有及时向Flume agent进程返回数据，而是在`tail`命令执行结束时，才将所有的内容一起返回；具体，可以监控`tail`命令，会出现内容已经发到Flume agent的现象。









[NingG]:    					http://ningg.github.com  "NingG"
[Flume User Guide]:				http://flume.apache.org/FlumeUserGuide.html
[Flume download]:				http://flume.apache.org/download.html 
[UnxUtils]:						http://sourceforge.net/projects/unxutils/
[Flume windows version]:		http://abloz.com/flume/windows_download.html
[windows下编译flume]:			http://abloz.com/2013/02/18/compile-under-windows-flume-1-3-1.html
[Build Flume 1.3.x on Windows]:			https://cwiki.apache.org/confluence/display/FLUME/Build+Flume+1.3.x+up+on+Windows