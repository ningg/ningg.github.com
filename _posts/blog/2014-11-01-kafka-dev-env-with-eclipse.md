---
layout: post
title: Eclipse下搭建Kafka的开发环境
description: 使用Kafka，先要搭建一个开发环境，这属于基础设施
categories: kafka
---

##背景

最近要进行Kafka开发，在[官网](http://kafka.apache.org/code.html)看到可以在IDE下开发，赶紧点进去看了看，并且在本地Eclipse下搭建了个Kafka的开发环境，主要参考来源：

* [Kafka Developer Setup][Kafka Developer Setup]


##编译环境(非代理)

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


###开始编译

需要提前下载几个东西：

* Kafka源码包：[kafka-0.8.1.1-src.tgz](http://kafka.apache.org/downloads.html)
* Eclipse下的Scala 2.10.x IDE plugin：[For Scala 2.10.4](http://scala-ide.org/download/current.html)
* Eclipse下的IvyIDE plugin：[ apache-ivyde-2.2.0.final-201311091524-RELEASE.zip](http://ant.apache.org/ivy/ivyde/download.cgi)

###Eclipse下安装插件

基本步骤：打开Eclipse--Help--Install new Software，具体见下图：

![](/images/kafka-dev-env-with-eclipse/install-new-software.png)

![](/images/kafka-dev-env-with-eclipse/install-plugins.jpg)


对于IvyDE，如果上述办法添加插件出错，则，进行如下操作：

* IvyDE features `features/org.apache.ivyde.*.jar` to put in your `$ECLIPSE_HOME/features`
* IvyDE plugins `plugins/org.apache.ivyde.*.jar` to put in your `$ECLIPSE_HOME/plugins`


###生成Eclipse project file

由于我的电脑是Windowns 7，因此安装了Cygwin，下面的操作都是在Cygwin下进行的，具体是，到Kafka源码包的路径下，执行如下命令：

	cd $KAFKA_SRC_HOME
	./gradlew eclipse


###kafka工程导入Eclipse

将上一步生成的project导入到Eclipse中，具体：`File` -> `Import` -> `General` -> `Existing Projects into Workspace`，结果如下图：

![](/images/kafka-dev-env-with-eclipse/kafka-src.jpg)



###问题及解决办法

上述kafka工程导入Eclipse后，实质是几个工程：perf、examples、core、contrib、clients；其中perf、core工程是scala工程，其余为java工程；但是examples工程中提示多个问题，列出一个看一下：

	# The import kafka.consumer cannot be resolved
	import kafka.consumer.ConsumerConfig;

上述问题，在网上搜了一圈，最终StackOverFlow上找到了：[Eclipse scala.object cannot be resolved](http://stackoverflow.com/questions/22102257/eclipse-scala-object-cannot-be-resolved)，不过，上面的提示对于当前的问题，好像没有用；因为，examples工程以调用的是core工程的核心代码，而不是scala-library中的代码；并且，examples工程在`Java Build Path`--`Projects`(Required projects on the build path)中已经添加了core工程：

![](/images/kafka-dev-env-with-eclipse/examples-core-build-path.jpg)

怎么还是有错？奥，core工程是scala工程，而examples工程是java工程，并且在examples中引用的core中代码也都是*.scala代码，OK，将examples工程也转换为scala工程吧：点击examples工程，`右键`--`Configure`--`add Scala Nature`，clean一下examples工程，OK，examples工程的错误没啦。不过core工程仍然还有错误，大意如下:

	kafka.utils.nonthreadsafe  required: scala.annotation.Annotation

解决办法：打开core工程下`Annotations_2.8.scala`文件，添加一行代码：

	import scala.annotation.StaticAnnotation

clean一下core工程，OK，这次总算搞定了，开始开发吧。


##编译环境(代理)

利用公司内网进行编译，开始之前，先查询一下机器配置，命令`CMD`--`systeminfo`，显示结果如下：

	C:\Documents and Settings\ningg>systeminfo

	OS 名称:      Microsoft Windows XP Professional
	OS 版本:      5.1.2600 Service Pack 3 Build 2600
	OS 制造商:    Microsoft Corporation
	OS 构件类型:  Multiprocessor Free
	系统制造商:   LENOVO
	系统型号:     ThinkCentre M6400t-N000
	系统类型:     X86-based PC
	处理器:       安装了 1 个处理器。
	       [01]: x86 Family 6 Model 58 Stepping 9 GenuineIntel ~3392 Mhz
	BIOS 版本:    LENOVO - 14f0
	物理内存总量: 3,546 MB

**编译环境(代理)**与**编译环境(非代理)**基本一致，不过需要配置一下代理，仅此而已，下面只列出两者有差异的地方。
	
###生成Eclipse project file

目标：通过代理方式要Cygwin能够联网，并且在Cygwin下编译Kafka对应的eclipse环境。

####设置Cygwin的http代理

在Cygwin下无法上网，并且没有`wget`命令，那好，重装一下Cygwin，并且安装过程中增加`wget`工具；然后，配置Cygwin的代理：

	# set http proxy
	export http_proxy=http://username:passwd@ip:port
	
	# test whether http_proxy is useful.
	wget www.baidu.com
	
按照当前的设置，Cygwin环境就联网了。另，仍有个问题，每次重启Cygwin的终端窗口，都需要重新设置http_proxy，如何解决？

####gradle代理设置

上述设置，并无法执行`./gradlew eclipse`，具体出错信息是：无法下载一些maven的中央仓库中的依赖。gradle是第一次接触，说是与Maven功能类似的自动构建工具，细节不多说，既然是工具，应该跟Maven类似，可以配置代理，查询一下，OK，果真能设置，具体操作：在工程的根目录下，创建文件`gradle.properties`，其中添加proxy设置：

	systemProp.http.proxyHost=IP
	systemProp.http.proxyPort=port
	systemProp.http.proxyUser=username
	systemProp.http.proxyPassword=password
	systemProp.http.nonProxyHosts=*.nonproxyrepos.com|localhost

配置好代理之后，在Cgywin下执行命令`./gradlew eclipse`即可；另外，也可在`gradle.properties`中修改编译源码时，对应的scala版本。

**notes(ningg)**：gradle是什么，要有个基本的了解，当前[参考](http://stevex.blog.51cto.com/4300375/1339735)，其中提到两个地方：

* gradle入门：[http://spring.io/guides/gs/gradle/](http://spring.io/guides/gs/gradle/)
* gradle官网有免费电子书：《Building and Testing with Gradle》

##杂谈

今天在公司，折腾一下午，网络问题，脑袋都大了，回来后，不到30mins就搞定了，顺便还整理了下，形成了此文；没有稳定的网络，对于有追求的工程师，就如同拿着锄头的特战队员，能力再牛，照样被拿微冲的小白恐吓。

补充：今天（2014-11-03）到公司，还是不死心，重新尝试了一下在代理环境中编译Kafka源码；具体参考上面**编译环境(代理)**。

今天无意间看到某句话，贴出来，算是勉励自己：

> 大部分事情，多用心、多用时间，都是可以超过大部分人的。人做事其实是习惯，只有这样的人，才是优秀的。人生里，要识别出这样的人，和优秀者接近，远离平庸。不要急，多练多体会，水平会逐步提高。我每次都是搜索菜谱，然后用心比较，选择正确的步骤整合。

[Kafka Developer Setup]:		https://cwiki.apache.org/confluence/display/KAFKA/Developer+Setup
