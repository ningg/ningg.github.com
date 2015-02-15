---
layout: post
title: 编译flume：使用eclipse查看flume源码
description: flume是开源的分布式日志采集系统，深入使用flume，编译查看flume源码是正道
categories: flume hadoop
---

##背景

最近要弄日志收集系统，初始方案是将日志压缩之后，通过类似FTP方式上传，其中有一个问题：日志不能实时收集，因此，无法实时监控系统状态。Flume支持实时的日志采集，妥了，尝试用一下。

说点题外话，通过类似FTP方式上传文件时，还有几个问题，自己仍在思考：

* 日志上传时，如何确定日志上传完成？
* 如果上传过程中出现意外，接收端是否会丢弃已经接收到的文件片段？
* 传输的文件是否压缩？
* 传输文件直接上传到HDFS上，还是先上传到local FS上？
* 日志传输到服务器上之后，如何才能立即就进行分析？
* 分析日志之前，怎么判断日志是否满足规范？（命名、编码等）

##编译环境

查看自己机器的环境：我用笔记本来编译的，是win 7（x64）操作系统；更详细的编译环境信息通过如下方式查看：`CMD`-->`systeminfo`，这个命令收集系统信息，需要花费40s，稍等一会儿，得到如下信息：

	C:\Users\Administrator>systeminfo

	OS 名称:          Microsoft Windows 7 旗舰版
	OS 版本:          6.1.7601 Service Pack 1 Build 7601

	系统类型:         x64-based PC
	处理器:           安装了 1 个处理器。
		 [01]: Intel64 Family 6 Model 23 Stepping 6 GenuineIntel ~785 Mhz

	物理内存总量:     2,968 MB
	可用的物理内存:   819 MB
	虚拟内存: 最大值: 5,934 MB
	虚拟内存: 可用:   2,196 MB
	虚拟内存: 使用中: 3,738 MB

##Eclipse下查看Flume的源码（推荐）

下载完Flume的源码包之后，直接将整个flume源码目录，当作`Existing  Maven Projects`，`Import`到Eclipse中即可。注，遇到的几个问题：

* maven子模块`flume-dataset-sink`有错误，暂时未解决，close 此模块即可；
* `flume-ng-core`模块的pom.xml文档，提示出错：Plugin execution not covered by lifecycle configuration: org.codehaus.mojo:build-helper-maven-plugin:1.7:add-source (execution: add-source, phase: generate-sources)，暂时不管这一错误，整个工程也能正常运行；


下面附一张，将Flume source 以 Maven工程导入Eclipse的效果：

![](/images/build-flume/flume-maven-src.png)



###Flume源码的Debug

本质上Flume是启动一个JVM实例，具体启动参数，可以参考`/bin/flume-ng`脚本的最终启动命令。列几个启动脚本的常量，就是JVM实例的main class：

	FLUME_AGENT_CLASS="org.apache.flume.node.Application"
	FLUME_AVRO_CLIENT_CLASS="org.apache.flume.client.avro.AvroCLIClient"
	FLUME_VERSION_CLASS="org.apache.flume.tools.VersionInfo"
	FLUME_TOOLS_CLASS="org.apache.flume.tools.FlumeToolsMain"




TODO：

* 在本地开发Flume的组件；
* 本地启动Eclipse下的Flume工程（从入口类），





	
##开始编译（<span style="color:red">废弃</span>）

**备注**：不必再通过mvn命令，将原始的flume源码编译为Eclipse工程了，直接将原始的flume源码作为maven工程导入即可，具体，参考前一部分**Eclipse下查看Flume的源码（推荐）**。

OK，在这台Win7上，编译flume源码，走起。

> 特别说明：这些内容，都是我从官网看来的，建议有点追求的coder，多看看[flume官网]，这样才能有提高，我的博客仅仅是自己留作备份看的。

###下载源码

Apache flume的下载页面：[Apache Flume Download](http://flume.apache.org/download.html)。

我下载的是当前稳定版本flume对应的源码：[apache-flume-1.5.0.1-src](http://www.apache.org/dyn/closer.cgi/flume/1.5.0.1/apache-flume-1.5.0.1-src.tar.gz)


###开始编译

根据官方资料：[flume开发&调试环境]，开始编译。此次编译，我的目标很简单：在eclipse下查看flume的源代码。具体编译时，使用的命令：

	mvn install -DskipTests
	mvn eclipse:eclipse -DdownloadSources


###出现的问题

执行命令`mvn install -DskipTests`后，程序有一段时间静止在编译flume ng core的模块上，强行终止（操作：`ctrl + c`）后，使用  "mvn install -rf :flume-ng-core -X " 启动debug进行问题定位找到线索:

分析之后，修改flume-ng-core\scripts\目录下`saveVersion.ps1`，将其中powershell的两个参数`args[0]`和`args[1]`替换为实际值即可。在此之前，需要确认windows系统已经安装了powershell，验证是否安装powershell的方法：`运行`-->`powershell`，看看是否能够进入与`cmd`类似的命令页面（我的win7系统默认带了powershell）。
如果没有安装powershell，请参考：[windows管理框架](http://support.microsoft.com/kb/968929)。

在编译`flume-ng-morphline-solr-sink`过程中，由于GFW等等原因，可能无法访问` repository.cloudera.com`，导致编译失败，失败信息详情如下：


	[ERROR] Failed to execute goal on project flume-ng-morphline-solr
	-sink: Could not resolve dependencies for project org.apache.flum
	e.flume-ng-sinks:flume-ng-morphline-solr-sink:jar:1.5.0.1: Failed
	 to collect dependencies at org.kitesdk:kite-morphlines-all:pom:0
	.12.0: Failed to read artifact descriptor for org.kitesdk:kite-mo
	rphlines-all:pom:0.12.0: Could not transfer artifact org.kitesdk:
	kite-morphlines-all:pom:0.12.0 from/to cdh.repo (https://reposito
	ry.cloudera.com/artifactory/cloudera-repos): repository.cloudera.
	com: Unknown host repository.cloudera.com -> [Help 1]

浏览一下，失败信息的大意是：编译`flume-ng-morphline-solr-sink`过程中，寻找依赖(dependency)失败，这是由于远端cloudera仓库对应的域名`repository.cloudera.com`无法解析引发的。OK，既然找不到这个cloudera仓库，那直接取消对这一仓库的引用好了，具体：修改flume-ng-sinks\flume-ng-morphline-solr-sink\目录下`pom.xml`文件，将`<repository>`元素注释掉，最终效果如表：

  <repositories>

	<!--
	<repository>
	  <id>cdh.repo</id>
	  <url>https://repository.cloudera.com/artifactory/cloudera-repos</url>
	  <name>Cloudera Repositories</name>
	  <snapshots>
		<enabled>false</enabled>
	  </snapshots>
	</repository>

	<repository>
	  <id>cdh.snapshots.repo</id>
	  <url>https://repository.cloudera.com/artifactory/libs-snapshot-local</url>
	  <name>Cloudera Snapshots Repository</name>
	  <snapshots>
		<enabled>true</enabled>
	  </snapshots>
	  <releases>
		<enabled>false</enabled>
	  </releases>
	</repository>
	-->

  </repositories>

ok，重新执行命令`mvn install -DskipTests`，欧NO，又出错了，得到如下信息：

	[ERROR] Failed to execute goal on project flume-ng-morphline-solr
	-sink: Could not resolve dependencies for project org.apache.flum
	e.flume-ng-sinks:flume-ng-morphline-solr-sink:jar:1.5.0.1: The fo
	-llowing artifacts could not be resolved: org.kitesdk:kite-morphli
	nes-all:pom:0.12.0, org.kitesdk:kite-morphlines-solr-core:jar:tes
	-ts:0.12.0: Failure to find org.kitesdk:kite-morphlines-all:pom:0.
	12.0 in http://repo1.maven.org/maven2 was cached in the local repo
	-sitory, resolution will not be reattempted until the update inte
	rval of repo1.maven.org has elapsed or updates are forced -> [Help 1]

平复一下心情，看看上面的提示，大意是说找不到`kite-morphlines-all`，看来之前粗鲁的将`<repository>`元素注释掉，并不能解决问题，OK，再找两个替代的repository就好了，具体再次修改flume-ng-sinks\flume-ng-morphline-solr-sink\目录下`pom.xml`文件如下：


	  <repositories>
		<repository>
			<id>maven-restlet</id>
			<name>Public online Restlet repository</name>
			<url>http://maven.restlet.org</url>
		</repository>
	  </repositories>

并且修改flume源代码根目录下的`pom.xml`文件，将其中`<kite.version>0.12.0</kite.version>`，修改为`<kite.version>0.15.0</kite.version>`。


又有依赖(dependency)找不到了：

	[ERROR] Failed to execute goal on project flume-ng-morphline-solr
	-sink: Could not resolve dependencies for project org.apache.flum
	e.flume-ng-sinks:flume-ng-morphline-solr-sink:jar:1.5.0.1: Failed
	 to collect dependencies at org.kitesdk:kite-morphlines-all:pom:0
	.12.0 -> org.kitesdk:kite-morphlines-useragent:jar:0.12.0 -> ua_p
	arser:ua-parser:jar:1.3.0: Failed to read artifact descriptor for
	 ua_parser:ua-parser:jar:1.3.0: Could not transfer artifact ua_pa
	rser:ua-parser:pom:1.3.0 from/to maven-twttr (http://maven.twttr.
	com): Connection to http://maven.twttr.com refused: Connection ti
	med out: connect -> [Help 1]

再次修改flume-ng-sinks\flume-ng-morphline-solr-sink\目录下`pom.xml`文件，在`<repositories>`下添加一个元素：

	<repositories>
		
		... 
		
		<repository>
		  <id>p2.jfrog.org</id>
		  <url>http://p2.jfrog.org/libs-releases</url>
		</repository>
    </repositories>

重新编译，还不行，说是找不到`p2.jfrog.org`，怒了，翻墙，再编译，搞定。（有的网络环境，不需要翻墙，也能编译通过）

###eclipse下查看源码

上面编译之后，在eclipse下，`Import`-->`Existing Projects into Workspace`，然后选择flume编译源码的路径即可，结果如下图所示：

![eclipse-src](/images/build-flume/eclipse-flume-src.jpg)


**疑问**：

* 使用maven管理的代码，为什么不作为maven项目Import到eclipse下？而是先运行命令`mvn eclipse:eclipse`，然后将项目作为普通的java project导入到eclipse？**RE**：两种方式是等价的，只不过利用`mvn eclipse:eclipse`命令，下载jar，感觉稍微快一点，可以先通过mvn命令进行编译，然后，重新打开一个新的src文件夹，并将其作为maven项目import到eclipse下*（需要调整一些，build path）*；
* 使用eclipse来查看、调试flume源码，那如何对外发布源码？
* 总结一下，就是一个问题`mvn eclipse:eclipse`过程中到底执行了什么？为什么要这么做？避免了，eclipse下安装m2eclipse插件，不过一般eclipse都默认安装了m2eclipse插件。



> **后记**：每次编译代码，网络都让人蛋疼，GFW让人蛋疼，有一个VPN太重要了。




##参考来源

* [flume官网]
* [flume开发&调试环境]


[flume官网]:	http://flume.apache.org/
[flume开发&调试环境]:	https://cwiki.apache.org/confluence/display/FLUME/Development+Environment
	



[NingG]:    http://ningg.github.com  "NingG"
