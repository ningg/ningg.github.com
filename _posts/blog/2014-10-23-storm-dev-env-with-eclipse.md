---
layout: post
title: Win下搭建Storm topology的开发调试环境
description: Storm官方文档的阅读和笔记
categories: storm
---

##背景

Storm topologies，支撑multilang，不过通常使用java来编写，这样我就想在Eclipse下来编写Storm topologies，毕竟IDE能够加快开发效率。

> 下面的内容，基本都是从官网看的，使用自己语言重新写了一遍，建议有追求的Coder/Engineer/Scientist，还是去看官网吧，看官网才是捷径。

##系统环境

今天要进行Storm topology开发的系统，基本环境：win xp(x86)操作系统；更详细的编译环境信息，通过如下方式查看：`CMD`--`systeminfo`，这个命令执行需要时间，10~40s，稍等一会儿，得到如下信息：

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


##eclipse下查看storm-start工程

[storm-starter][storm-starter]是Storm官网提供的一个例子，简要介绍了storm topology的编写，在[storm Tutorial][storm Tutorial]中重点讲解了这个例子；总之，一点：[storm-starter][storm-starter]是入门学习的典型例子。OK，我准备在Eclipse下查看[storm-starter][storm-starter]工程。

说一下我在Eclipse下的操作步骤：

1. 下载storm发行版本的源代码：[apache-storm-0.9.2-incubating-src.zip][storm downloads]，并解压；
1. `File`--`Import`--`Existing Maven Projects`；
1. 选择storm源代码的`examples\storm-starter`目录，对，然后一路next下去；

好了，中间可能提示maven项目有错误，不要管，一直往下走。接下来说一下如何解决maven项目的bug，我导入storm-starter工程后，`pom.xml`文件上冒了个<span style="color:red">红色的X</span>，找到相应位置，按下`F2`，显示出错信息：

	Plugin execution not covered by lifecycle configuration: 
	com.theoryinpractise:clojure-maven-plugin:1.3.18:compile 
	(execution: compile, phase: compile)

![](/images/storm-dev-env-with-eclipse/pom-error.png)

OK，不要管这个，直接在storm-starter工程上，`右键`--`Run As`--`Maven build`，输入参数：`clean install -DskipTests=true`；然后，`Run`；至此，打完收工，妥妥的，结果如下图所示：

![](/images/storm-dev-env-with-eclipse/build-finished.png)

到这一步，就可以参照[storm Tutorial][storm Tutorial]、[storm-starter][storm-starter]中的说明进行一步步的操作，来熟悉Storm topology。

**疑问**：Eclipse下就可以直接开发、调试topology了吗？

**RE**：是的，直接开发，[storm Tutorial][storm Tutorial]中的例子就是这样。

##Maven方式构建工程

如果希望新建工程，并在其内进行Storm的开发，则，推荐新建Maven工程，并在其`pom.xml`下，添加如下配置：

	<dependency>
      <groupId>org.apache.storm</groupId>
      <artifactId>storm-core</artifactId>
      <version>0.9.3</version>
      <!-- keep storm out of the jar-with-dependencies -->
      <scope>provided</scope>
    </dependency>

在实际场景中，我编写的Storm topol程序，从Kafka中读取数据，具体`pom.xml`为：

	<dependencies>
        <dependency>
            <groupId>org.apache.kafka</groupId>
            <artifactId>kafka_2.9.2</artifactId>
            <version>0.8.1.1</version>
            <!-- use provided scope, so users can 
			pull in whichever scala version they choose -->
            <scope>provided</scope>
            <exclusions>
                <exclusion>
                    <groupId>org.apache.zookeeper</groupId>
                    <artifactId>zookeeper</artifactId>
                </exclusion>
                <exclusion>
                    <groupId>log4j</groupId>
                    <artifactId>log4j</artifactId>
                </exclusion>
            </exclusions>
        </dependency>
        
        <dependency>
          <groupId>org.apache.storm</groupId>
          <artifactId>storm-core</artifactId>
          <version>0.9.3</version>
          <!-- keep storm out of the jar-with-dependencies -->
          <scope>provided</scope>
        </dependency>
        
        <dependency>
        	<groupId>org.apache.storm</groupId>
        	<artifactId>storm-kafka</artifactId>
            <version>0.9.3</version>
        </dependency>
        
    
	</dependencies>
  
	<build>
	    <plugins>
	        <plugin>
	           <artifactId>maven-assembly-plugin</artifactId>
	           <configuration>
	             <descriptorRefs>
	           	   <descriptorRef>jar-with-dependencies</descriptorRef>
	             </descriptorRefs>
	             <archive>
	           	   <manifest>
	           	      <mainClass></mainClass>
	           	   </manifest>
	             </archive>
	           </configuration>
	           <executions>
	             <execution>
	           	   <id>make-assembly</id>
	           	   <phase>package</phase>
	           	   <goals>
	           	     <goal>single</goal>
	           	   </goals>
	             </execution>
	           </executions>
	        </plugin>
	    </plugins>
	</build>
	
**注**：如果pom.xml一直提示出错，则update project(Maven)，或者close project之后再打开也可以。
	
##本地安装Storm

下载[Storm的binary版本][storm downloads]，就两点：

1. 把 Storm的`bin`目录添加到`PATH`中；
2. 验证是否安装成功：执行`storm`命令，查看是否提示出错；

**疑问**：如果只是开发Storm topology，需要在本地win xp系统上安装Storm？
**RE**：我来告诉你吧，本地安装Storm，核心用途是：充当client，向远端Storm cluster提交编写好的topology。重新来理一下，eclipse下新建工程，maven添加storm的依赖，即可进行topology的开发；然后通过本地安装的storm，可以进行本地的test、develop；最终，通过本地安装的storm充当client，可以向storm cluster提交topology。在实际使用过程中，发现无法在windows下的CMD中运行`storm jar`命令，因此，我在windows下安装了Cygwin（其中需要安装Python），在其中运行`storm jar`命令向远端的storm集群提交topol。更多细节参考[Storm：Running topologies on a production cluster][Storm：Running topologies on a production cluster]。

**疑问**：上面已经可以进行Storm topology的开发了，但如果希望查看Storm源代码，特别是Clojure编写的那部分，怎么办？
**RE**：关于这个问题，官网有提示：[Creating a new Storm project][Storm: Creating a new Storm project]。

##特别说明

进行Storm开发的详细过程：

* Eclipse下编写Storm topol；
* 将Storm topol运行代码打包发布；
* 通过本地Storm client向远端Storm cluster提交Storm topol及其依赖的jar；

具体参考博客：[Storm：Running topologies on a production cluster][Storm：Running topologies on a production cluster]。


##参考来源

* [Storm Example: storm-starter](https://github.com/apache/incubator-storm/tree/master/examples/storm-starter)
* [Storm: Setting up development environment](http://storm.apache.org/documentation/Setting-up-development-environment.html)
* [Storm: Creating a new Storm project](http://storm.apache.org/documentation/Creating-a-new-Storm-project.html)
* [Running topologies on a production cluster][Running topologies on a production cluster]



[NingG]:    http://ningg.github.com  "NingG"
[storm-starter]:	https://github.com/apache/storm/tree/master/examples/storm-starter
[storm Tutorial]:	http://storm.apache.org/documentation/Tutorial.html
[storm downloads]:	http://storm.apache.org/downloads.html
[Storm: Creating a new Storm project]:	http://storm.apache.org/documentation/Creating-a-new-Storm-project.html
[Storm：Running topologies on a production cluster]:			/running-topol-on-a-prod-cluster/
[Running topologies on a production cluster]:	http://storm.apache.org/documentation/Running-topologies-on-a-production-cluster.html