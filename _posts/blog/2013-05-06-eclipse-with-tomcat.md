---
layout: post
title: Eclipse下查看Tomcat源码
description: 在Eclipse下查看Tomcat的源代码
published: true
category: tomcat
---

关注点：

* 如何在Eclipse下查看Tomcat的源码？
* 在Eclipse下，通过源码启动Tomcat？

##Eclipse下查看Tomcat源码

在Tomcat官网上，认真浏览一下，找到[Tomcat8 - Building with Eclipse][Tomcat8 - Building with Eclipse]，简单列几个步骤：

* 从Tomcat官网下载最新的Tomcat源码包，当前版本为：`apache-tomcat-8.0.21-src.zip`；
* 对源码的压缩文件解压；
* 将`${tomcat.source}/build.properties.default`复制一份，并重命名为`${tomcat.source}/build.properties`；
* 在`build.properties`中，修改`base.path`参数，其用于指向本地共享lib的位置，此次我的设置是：`base.path=D:/reference/tomcat/apache-tomcat-8.0.21-share`
* 下载Apache Ant 1.8.2+
* 在`${tomcat.source}`下，运行 `ant ide-eclipse`
* Elipse下，通过`Java->Build Path->Classpath Variables`方式，绑定两个变量：`TOMCAT_LIBS_BASE`为`base.path`，`ANT_HOME`为ant 1.8.2+的位置；
* 以类`org.apache.catalina.startup.Bootstrap`作为入口，来起停Tomcat；*（更多细节，参考官网Building with Eclipse部分）*

![](/images/eclipse-with-tomcat/tomcat-eclipse.png)

注：如果需要使用代理，则，在build.properties中进行如下配置：

	# -- Proxy
	proxy.host=127.0.0.1
	proxy.port=8080
	proxy.use=on


上述步骤是，利用官网的Tomcat源码包，通过Ant编译得到Tomcat的Eclipse Java Project，在Eclipse下来查看。为了方便，已经将上述编译好的Eclipse Java Project提交到[GitHub上][Tomcat 8.0 src(GitHub)]了，下载下来，作为Java Project，可以直接导入到Eclipse下查看。



##Eclipse下，通过源码启动Tomcat


（TODO）











##参考资料

* [Tomcat8 - Building with Eclipse][Tomcat8 - Building with Eclipse]












[NingG]:    http://ningg.github.com  "NingG"


[Tomcat8 - Building with Eclipse]:			http://tomcat.apache.org/tomcat-8.0-doc/building.html#Building_with_Eclipse
[Tomcat 8.0 src(GitHub)]:					https://github.com/ningg/tomcat-8.0







