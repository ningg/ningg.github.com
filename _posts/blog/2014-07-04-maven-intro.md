---
layout: post
title: maven使用入门
description: 项目构建，包括java源文件编译、文件复制、打包等，手动很繁琐，需要借助其他工具
category: maven
---

> 题记：[《Maven实战（迷你版）》](http://www.infoq.com/cn/minibooks/maven-in-action)这本书写的太好了，我忍不住把其中的内容又敲一遍。


**特别说明**： 当前新的构建工具 gradle 已经流行起来了，当前形势要求一定要熟悉、尝试，具体参考：

* [Gradle，构建工具的未来？][Gradle，构建工具的未来？]
* [Why Build Your Java Projects with Gradle Rather than Ant or Maven?][Why Build Your Java Projects with Gradle Rather than Ant or Maven?]
* [Java构建工具：Ant vs Maven vs Gradle][Java构建工具：Ant vs Maven vs Gradle]

## 0. 背景

今天在GitHub上找了一个java语言编写的HDFS client，其使用Maven来进行工程的管理和构建；作为Maven工程导入Eclipse，提示pom.xml相关错误近10条。

好吧，pom.xml是Maven的配置文件，看来Maven逃脱不了关系了。（之前，多次接触/使用Maven，不过都没有整理资料，导致每次使用都需要重新学习，如此反复，浪费时间，引以为戒，故有此博客）。

要学东西，需要先找些可靠、严谨的书籍，大概搜索了一下，[《Maven实战》](http://www.juvenxu.com/mvn-in-action/) 的评价较高，那就他了。 一两天内，也无法拿到纸质版的书籍，索性在InfoQ上找了一个[《Maven实战（迷你版）》](http://www.infoq.com/cn/minibooks/maven-in-action)。 

### 0.1 Maven是什么？能做什么？

在开始正式介绍之前，还总结一下Maven到底能做什么吧，所谓**学以致用**，还是希望能够在今后的开发中，把Maven用起来的。

Maven能做什么？




## 1. Maven的安装与配置

### 1.1 Maven的安装

从Maven官网下载软件，根据官方文档安装即可。基本步骤：

1. 下载并解压文件；
2. 添加环境变量：`$M2_HOME`=`Maven安装目录`，并将`$M2_HOME/bin`添加到`$PATH`。

**补充**：安装软件，就不可避免会遇到软件版本升级问题，现有较成熟的方案：

1. win环境下，升级新版本的软件后，直接修改环境变量，指向新版本目录即可；
2. Linux环境下，升级软件版本之后，修改环境变量；
3. 特别说明：Linux下，还有更简便的办法：在软件安装目录下，新建一个符号链接文件，环境变量指向此文件，软件升级后，只需更新此符号链接文件即可。

Linux下，使用符号链接文件，来作为软件升级方案：
	
	#新建符号链接apache-maven，指向apache-maven-3.0文件
	ln -s apache-maven-3.0 apache-maven
	
	#在配置文件~/.bashrc中，添加环境变量
	export M2_HOME=/home/devp/apache-maven
	export PATH=$M2_HOME/bin:$PATH
	
	#升级软件时，更新符号连接文件apache-maven
	rm apache-maven
	ln -s apache-maven-3.1 apache-maven

### 1.2 安装目录分析

前文简要说明了Maven的安装与升级步骤，现在我们简要分析一下Maven的安装文件。

#### 安装目录：M2_HOME

前面的讲解中，我们都是将环境变量`M2_HOME`指向Maven的安装目录，本文之后所有使用`M2_HOME`的地方都代表了该安装目录，让我们看一下该目录的安装结构和内容：

	|--bin
	|   |--m2.conf
	|   |--mvn
	|   |--mvnDebug
	|
	|--boot
	|   |--plexus-classworlds-xxx.jar
	| 	
	|--conf
	|   |--settings.xml
	|   |--logging
	|       |--simplelogger.properties
	|
	|--lib
	|   |--... ...
	|
	|--LICENSE
	|--NOTICE
	|--README.txt

**bin**：该目录包含了mvn运行的脚本，用来配置java命令，准备好classpath和相关的java命令参数，然后执行java命令。其中包含了mvn和mvnDebug两类脚本，打开来查看，就会看到mvnDebug只是比mvn多一条MAVEN_DEBUG_OPTS配置，作用就是在运行Maven时开启debug，方便调试Maven自身。此外，该目录还包含m2.conf文件，这是classworlds的配置文件，如果有必要，下文会对其进行介绍。

**boot**：以Maven 3.2.2为例，其中只包含了一个jar包plexus-classworlds-2.5.1.jar。这是一个类加载器框架，相对于默认的java类加载器，它提供了丰富的语法以方便配置，Maven使用该框架加载自己的类库。更多关于classworlds的信息请参考[http://classworlds.codehaus.org](http://classworlds.codehaus.org)。 对于普通的Maven用户，不必关心这一文件。

**conf**：该目录包含了一个非常重要的配置文件settings.xml，直接修改此文件，能够在机器上，全局定制Maven的行为。一般情况下，我们更偏向于复制该文件到 `~/.m2/` 目录下（此处 `~` 代表用户目录），然后修改该配置文件，在用户范围内定制Maven行为。

**lib**：该目录包含了Maven运行所需的各类java类库，Maven本身是分模块开发的，因此用户能够看到诸如：maven-compact-3.2.2.jar、maven-core-3.2.2.jar、maven-model-3.2.2.jar等文件，此外这里含包含了一些Maven用到的第三方依赖，例如：guava-14.0.1.jar、commons-cli-1.2.jar等。（对于Maven2来说，该目录只包含一个如maven-2.2.1-uber.jar的文件，它是由原本相互独立的jar文件的Maven模块以及依赖的第三方类库拆解后，重新合并而成的）。可以说，这个目录才是真正的Maven。

其他几个文件的简介：

* LICENSE：记录了Maven使用的软件许可证，Apache License Version 2.0。
* NOTICE：记录了Maven的发行机构。
* README.txt：包含了Maven的简要介绍、安装步骤以及参考资料的链接。

#### 本地仓库：~/.m2目录

安装完Maven之后，运行命令`mvn help:system` ，该命令打印出所有的Java系统属性和环境变量，这些信息对我们日常的编程工作很有帮助。这条命令执行之后，可以看到Maven会下载`maven-help-plugin`，包括pom文件和jar文件，这些文件都被存储在本地仓库中。

打开当前登录用户的主目录（即，用户目录），下文使用`~` 来表示用户目录。在用户目录下，可以看到 `.m2` 目录。默认情况下，该文件夹下放置了Maven本地仓库：`.m2/repository` 。所有的Maven构建（artifact）都被存储在本仓库中，以方便重用。我们可以在`~/.m2/repository/org/apache/maven/plugins/maven-help-plugins/` 目录下，找到刚才下载的pom文件和jar文件（两文件缺一不可）。Maven根据几套规则来确定任何一个构建（artifact）在仓库中的位置。**特别说明**：由于Maven仓库是通过简单文件系统，透明地展示给Maven用户的，有时候可以绕过Maven直接查看或修改仓库文件，在遇到疑难问题时，这往往十分有用。


### 1.3 配置HTTP代理

有时候公司处于安全考虑，要求通过安全认证的代理访问因特网。这就要求设置Maven通过HTTP代理方式，来访问外网的仓库，以下载所需的资源。

确认当前代理可用，然后编辑 `~\.m2\settings.xml` 文件（如果没有这一文件，就将`$M2_HOME\conf\settings.xml` 复制过来）。添加代理配置如下：

	<proxies>
	   <!-- proxy
	    | Specification for one proxy, to be used in connecting to the network.
	    |-->
	   <proxy>
	     <id>optional</id>
	     <active>true</active>
	     <protocol>http</protocol>
	     <!-- 
	     <username>proxyuser</username>
	     <password>proxypass</password>
	     -->
	     <host>proxy.host.net</host>
	     <port>80</port>
	     <nonProxyHosts>local.net|some.host.com</nonProxyHosts>
	   </proxy>
	</proxies>

上述代理的配置方式十分简单，porxies下可以配置多个proxy，如果声明了多个proxy元素，默认第一个proxy被激活，否则active值为true表示被激活。当代理服务需要认证时，需要配置username和password。nonProxyHosts元素用于指定哪些主机名不需要代理，可以使用 `|` 来分隔多个主机名。此外，该配置也支持通配符，例如，*.google.com表示所有以google.com结尾的域名访问都不通过代理。

### 1.4 安装Eclipse的Maven插件

对于一个稍微大一点的项目来说，没有IDE是不可想象的，还好很多IDE都有Maven的插件。

Eclipse平台下，插件名称：m2eclipse，我下载的Eclispe版本中，默认已经安装了此插件，因此，本文不暂讨论此问题。

### 1.5 Maven安装最佳实践

本节介绍一些配置要点，在Maven安装过程中，这些要点是非必要的，但这些要点却比较实用。

#### 1.5.1 配置用户范围的settings.xml

Maven用户可以选择配置 `$M2_HOME/settings.xml` 或者 `~/.m2/settings.xml` 。前者是全局范围的配置，整台机器上的所有用户都会受这一配置的影响，而后者是用户范围的，只有当前用户会受到该配置的影响。

推荐使用用户范围的配置，避免影响其他用户的配置，另一方面，也便于Maven升级：直接修改conf 目录下的settings.xml文件，这样每次升级时，都需要复制该文件，而如果使用`.m2/settings.xml`，则升级时，不需要触动settings.xml文件。

#### 1.5.2 不使用IDE内嵌的Maven

无论Eclipse还是NetBeans，当我们集成Maven时，都会安装一个内嵌的Maven：一方面，这个Maven通常比较新，但不一定很稳定；另一方面，通常我们还需要使用Maven的命令行方式，如果两个Maven版本不同的话，可能造成项目构建过程不一致，这也是我们不希望看到的。因此，建议单独下载安装一个Maven，并将恰配置到IDE中。

Eclipse下，配置Maven：`Windows`--`Preferences`--`Maven`--`Installations`。



### 1.6 常见错误

这一节，记录一些可能会遇到的问题，以及解决办法。

#### 1.6.1 创建/导入 Maven Project

错误详情：

> An internal error occurred during: "Updating Maven Project". Lorg/codehaus/plexus/archiver/jar/JarArchiver;

解决办法：在pom.xml中`<project> <build> <plugins>`下添加

	<plugin>
	  <groupId>org.apache.maven.plugins</groupId>
	  <artifactId>maven-jar-plugin</artifactId>
	  <version>2.4</version>
	</plugin>

重新更新`Maven Project...`（默认快捷键：`Alt + F5`）。

参考：[stackoverflow](http://stackoverflow.com/questions/14491298/an-internal-error-occurred-during-updating-maven-dependencies)

#### 1.6.2 Eclipse环境下，Maven报错找不到某些jar包


如果命令行方式下，使用`mvn`的命令编译没有问题，而使用Eclipse时，`mvn install`等出现问题，则，解决办法：在pom.xml中指定`<project> <build> <plugins>`内添加`<plugin>`，设置成与命令行条件下`mvn`调用的`<plugin>`保持一致。[参考1](http://blog.csdn.net/imlmy/article/details/8268293)、[参考2](http://blog.csdn.net/huang86411/article/details/17548481)，当然还有另一种办法：[手动下载jar和pom](http://central.maven.org/maven2/org/apache/maven/plugins/).


#### 1.6.3 新建或重新打开 Maven Project，出现错误

错误详情：

> An error occurred while filtering resources

解决办法：`Maven`--`Update project...` （快捷键：`alt + F5`），参考来源[StackOverflow][http://stackoverflow.com/questions/22785748/how-to-remove-error-eclipse-project-indicator-if-i-dont-have-any-error]。

**疑问**：在POM中 `<project> <dependencies>` 下添加 `<dependency>`元素 和 `<project> <build> <plugins>` 下添加 `<plugin>` 元素，有差异吗？有什么差异？（备注：当前调试结果，可得有差异）。

如果当前使用了代理等方式导致网络连接局部受限，造成命令行方式 `mvn`能够正常下载依赖的jar包，但在Eclipse环境下，无法下载所需的项目的依赖包，可以在命令行方式下，先进行下载，然后，在Eclipse下进行更新、运行即可。（命令行方式为主，因为进程独占，而在Eclipse下分配给mvn的线程时间有限）

**思考**：Maven已经在settings.xml中配置了代理，那么，在Eclipse中开发调试Maven工程时，需要再配置Eclipse的代理吗？RE：不需要，只需要在Maven的配置中指定代理即可。


## 2. 入门实例

在此之前，需要安装配置好Maven，如果要在Eclipse下建立Maven工程，则需要安装配置Eclipse下的Maven的插件。具体信息，参考：[《Maven实战（迷你版）》]中第一章 Maven的安装与配置。

### 2.1 编写POM

Maven项目的核心是：pom.xml文件。POM：（Project Object Model，项目对象模型）定义了项目的基本信息：

1. 项目如何构建（源文件编译、复制、打包）；
2. 项目所需的依赖（项目所需的依赖包，也可能需要依赖额外的包）；

现在我们新建一个Hello World项目，并编写一个最简单的pom.xml文件。

	<?xml version="1.0" encoding="UTF-8"?>
	<project xmlns="http://maven.apache.org/POM/4.0.0"
	   xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
	   xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 
	       http://maven.apache.org/maven-v4_0_0.xsd">
	  
	  <!-- POM模型的版本，对于Maven2和Maven3只能是4.0.0 -->
	  <modelVersion>4.0.0</modelVersion>
	  
	  <!-- groupId,artifactId,version 唯一定位项目（任何jar、pom、war） -->
	  <!-- 定义project属于哪个组 -->
	  <!-- 例如，公司为mycom，项目为myapp，则groupId：com.mycom.myapp -->
	  <groupId>com.github.ningg.mvnbook</groupId>
	  
	  <!-- 定义project在组内的代号，例如，你可能会为不同的子项目(模块)分配artifactId，
	  例如，myapp组下，myapp-util,myapp-domain -->
	  <artifactId>hello-world</artifactId>
	  
	  <!-- 定义当前artifact的版本，SNAPSHOT:快照，说明项目仍在开发中，当前还不稳定 -->
	  <version>1.0-SNAPSHOT</version>
	  
	  <!-- 声明一个别名，用户可理解的别名，不是必须的，但为方便交流，推荐每个POM -->
	  <name>Maven Hello World Project</name>
	  
	  <properties>
	    <!-- 告知Maven进行复制、编译等操作时，使用的编码方式 -->
	    <project.build.sourceEncoding>UTF-8</project.build.sourceEncoding>
	  </properties>
	</project>

代码第一行是XML头，指定版本和编码方式。project是所有pom.xml的根元素，它还声明了一些命名空间和xsd（XML Schemas Definition，XML结构定义）元素，虽然这些属性是非必须的，但它们能够让第三方工具（如IDE中的XML编辑器）帮助我们快速编译POM。

### 2.2 编写主代码

项目主代码与测试代码不同。项目主代码会被打包到最终发布的构件中（例如jar包），而测试代码只在运行测试的时候使用，不会被打包发布。
默认情况下，Maven假设项目的主代码位于src/main/java目录下，我们遵循Maven的约定，创建该目录，并在该项目下创建文件com/github/ningg/mvnbook/helloworld/HelloWorld.java，其内容如下：

	package com.github.ningg.mvnbook.helloworld;

	public class HelloWorld {

		public String sayHello(){
			return "Hello Maven";
		}
		
		public static void main(String[] args){
			System.out.println(new HelloWorld().sayHello());
		}
		
	}


补充说明如下：

1. 95%情况下，应将项目主代码放在src/main/java/目录下（Maven默认的约定），这样无需额外配置，Maven会自动搜索该项目主代码。
2. Java类的包名（package），应该与POM中定义的groupId和artifactId相吻合，例如，本例中的com.github.ningg.mvnbook.helloworld，这样代码结构清晰，符合基本逻辑，方便搜索构件或者java类。

### 2.3 进行编译

运行命令`mvn clean compile`，则输出：

	E:\reference\blogOfGit\maven-intro\hello-world>mvn clean compile
	[INFO] Scanning for projects...
	[INFO]
	[INFO] ------------------------------------------------------------------------
	[INFO] Building Maven Hello World Project 1.0-SNAPSHOT
	[INFO] ------------------------------------------------------------------------
	[INFO]
	[INFO] --- maven-clean-plugin:2.5:clean (default-clean) @ hello-world ---
	[INFO] Deleting E:\reference\blogOfGit\maven-intro\hello-world\target
	[INFO]
	[INFO] --- maven-resources-plugin:2.6:resources (default-resources) @ hello-world ---
	[INFO] Using 'UTF-8' encoding to copy filtered resources.
	[INFO] skip non existing resourceDirectory E:\reference\blogOfGit\maven-intro\hello-world\src\main\resources
	[INFO]
	[INFO] --- maven-compiler-plugin:2.5.1:compile (default-compile) @ hello-world ---
	[INFO] Compiling 1 source file to E:\reference\blogOfGit\maven-intro\hello-world\target\classes
	[INFO] ------------------------------------------------------------------------
	[INFO] BUILD SUCCESS
	[INFO] ------------------------------------------------------------------------
	[INFO] Total time: 0.828 s
	[INFO] Finished at: 2014-07-01T20:46:45+08:00
	[INFO] Final Memory: 6M/15M
	[INFO] ------------------------------------------------------------------------

说明：

1. 从输出信息上可以看出，Maven具体包含3个操作：clean、resources、compile
2. clean：清理目录target/；
3. resources：（本实例中，没有定义项目资源，暂时略过）；
4. compile：编译项目主代码，默认输出到target/目录下；

说明：上文提到的3个操作，对应了Maven的插件以及插件目标，例如：clean操作，实际上是maven-clean-plugin:2.5插件的clean目标；（Maven插件的编写是很重要的一个方向）

至此，Maven在没有修改pom.xml配置的情况下，就进行了项目的清理和编译任务，在下文中，将继续编写一些测试单元代码并让Maven自动化测试。

### 2.4 编写测试代码

为保持项目结构清晰，主代码与测试代码分别在独立的目录中，前文提到过，主代码在src/main/java/目录下，对应的测试代码的目录是src/test/java/。因此，在编写代码前，应先创建这两个目录。

在java世界中，JUnit是事实上的单元测试标准。要使用JUnit需要在项目的配置文件中添加一个JUnit依赖，修改项目POM如下：

	<dependencies>
	   <dependency>
	      <groupId>junit</groupId>
	      <artifactId>junit</artifactId>
	      <version>4.7</version>
	      <scope>test</scope>
	   </dependency>
	</dependencies>

在project元素下，添加了dependencies元素，该元素下可以包含多个dependency元素，用与声明项目所需的依赖，这里我们添加的是(groupId,artifactId,version)为(junit,junit,4.7)的project，有了这段声明，Maven会自动下载junit-4.7.jar包。你可能会问，Maven从哪里下载这个jar呢？实际上，没有使用Maven时，我们需要自己去JUnit官网下载这个jar；而使用了Maven，它会自动访问自己的[中央仓库](http://repo1.maven.org/maven2/) ，下载所需要的文件，我们也可以自己访问这个中央仓库，打开[junit/junit/4.7/](http://repo1.maven.org/maven2/junit/junit/4.7/) 路径，就能看到junit-4.7.pom和junit-4.7.jar。

上述POM代码中，还设置了scope=test，其表示当前依赖仅对测试代码有效，换句话说，测试代码中import junit代码是正确的，而主代码中如果使用import junit就会编译出错。如果不设定scope，默认scope=compile，表示该依赖对主代码和测试代码都有效。

配置好了测试依赖，就可以编写测试代码了，前面HelloWorld类中，需要测试sayHello()方法的返回值是否为“Hello Maven”。在src/test/java目录下创建文件，内容如下：

	package com.github.ningg.mvnbook.helloworld;

	import org.junit.Assert;
	import org.junit.Test;

	public class HelloWorldTest {

		@Test
		public void testSayHello(){
			HelloWorld helloWorld = new HelloWorld();
			String result = helloWorld.sayHello();
			Assert.assertEquals("Hello Maven", result);
		}
	}

（**注意**：Eclipse集成开发环境下，在src/main/java/以及src/test/java/目录下编写java文件时，如何使用代码提示，特别是，很多jar的依赖都在pom.xml中配置的，当前工程暂时看不到jar包，import jar包都会提示出错。**简要答复**：在Eclipse环境下，创建Maven工程，使用Maven来管理项目，只要Maven能够连接到Internet来下载依赖的包，就不会出现找不到jar的情况，而且能够使用Eclipse下的代码提示功能；额外补充一点：Eclipse下，Maven管理项目时，当要查看依赖jar包对应的源码包时，Maven会自动下载相应的源码包）
	
典型的单元测试，包含3个步骤：

1. 准备测试类及数据；
2. 执行要测试的行为；
3. 检查结果；

上述测试代码中，我们首先初始化一个要测试的HelloWorld实例，接着执行该实例的sayHello()方法并将结果保存到result变量中，最后使用JUnit框架的Assert类检查结果是否为我们期望的“Hello Maven”。在JUnit 3中，约定所有需要执行测试的方法都以test开头，这里我们使用JUnit 4，但我们仍遵守这一约定，在JUnit中，需要执行的测试方法都以`@Test`进行标注。

测试代码编写完成之后，调用Maven执行测试，运行命令：`mvn clean test`:

	E:\reference\blogOfGit\maven-intro\hello-world>mvn clean test
	[INFO] Scanning for projects...
	[INFO]
	[INFO] ------------------------------------------------------------------------
	[INFO] Building Maven Hello World Project 1.0-SNAPSHOT
	[INFO] ------------------------------------------------------------------------
	[INFO]
	
	...
	Downloading: http://repo.maven.apache.org/maven2/junit/junit/4.7/junit-4.7.pom
	Downloaded: http://repo.maven.apache.org/maven2/junit/junit/4.7/junit-4.7.pom (2 KB at 0.7 KB/sec)
	Downloading: http://repo.maven.apache.org/maven2/junit/junit/4.7/junit-4.7.jar
	Downloaded: http://repo.maven.apache.org/maven2/junit/junit/4.7/junit-4.7.jar (227 KB at 87.0 KB/sec)
	...
	
	[INFO] --- maven-clean-plugin:2.5:clean (default-clean) @ hello-world ---
	[INFO] Deleting E:\reference\blogOfGit\maven-intro\hello-world\target
	[INFO]
	[INFO] --- maven-resources-plugin:2.6:resources (default-resources) @ hello-world ---
	[INFO] Using 'UTF-8' encoding to copy filtered resources.
	[INFO] skip non existing resourceDirectory E:\reference\blogOfGit\maven-intro\hello-world\src\main\resources
	[INFO]
	[INFO] --- maven-compiler-plugin:2.5.1:compile (default-compile) @ hello-world ---
	[INFO] Compiling 1 source file to E:\reference\blogOfGit\maven-intro\hello-world\target\classes
	[INFO]
	[INFO] --- maven-resources-plugin:2.6:testResources (default-testResources) @ hello-world ---
	[INFO] Using 'UTF-8' encoding to copy filtered resources.
	[INFO] skip non existing resourceDirectory E:\reference\blogOfGit\maven-intro\hello-world\src\test\resources
	[INFO]
	[INFO] --- maven-compiler-plugin:2.5.1:testCompile (default-testCompile) @ hello-world ---
	[INFO] Compiling 1 source file to E:\reference\blogOfGit\maven-intro\hello-world\target\test-classes
	[INFO]
	[INFO] --- maven-surefire-plugin:2.12.4:test (default-test) @ hello-world ---
	[INFO] Surefire report directory: E:\reference\blogOfGit\maven-intro\hello-world\target\surefire-reports

	-------------------------------------------------------
	 T E S T S
	-------------------------------------------------------
	Running com.github.ningg.mvnbook.helloworld.HelloWorldTest
	Tests run: 1, Failures: 0, Errors: 0, Skipped: 0, Time elapsed: 0.016 sec

	Results :

	Tests run: 1, Failures: 0, Errors: 0, Skipped: 0

	[INFO] ------------------------------------------------------------------------
	[INFO] BUILD SUCCESS
	[INFO] ------------------------------------------------------------------------
	[INFO] Total time: 1.359 s
	[INFO] Finished at: 2014-07-01T21:41:33+08:00
	[INFO] Final Memory: 7M/16M
	[INFO] ------------------------------------------------------------------------

从输出结果可以看出，执行`mvn clean test`时，Maven实际执行了：clean: clean，resources: resources，compiler: compile，resources: testResources，compiler: testCompile，surefire: test。详细来说，Maven在执行测试（test）之前，会先执行：目录清理、主资源处理、主代码编译、测试资源处理、测试代码编译、执行测试等过程，这是Maven生命周期的一个特性，本文后续部分会详细介绍Maven的生命周期。（注：surefire是执行测试的插件，其运行测试用例，并输出测试报告。）

### 2.5 打包和运行

项目进行编译、测试之后，下一步就是打包（package）。Hello World项目的POM中没有设置打包类型，默认为jar；执行命令：`mvn clean package`进行打包，可以看到如下输出：

	... ...
	
	-------------------------------------------------------
	 T E S T S
	-------------------------------------------------------
	Running com.github.ningg.mvnbook.helloworld.HelloWorldTest
	Tests run: 1, Failures: 0, Errors: 0, Skipped: 0, Time elapsed: 0.016 sec

	Results :

	Tests run: 1, Failures: 0, Errors: 0, Skipped: 0

	[INFO]
	[INFO] --- maven-jar-plugin:2.4:jar (default-jar) @ hello-world ---
	[INFO] Building jar: E:\reference\blogOfGit\maven-intro\hello-world\target\hello-world-1.0-SNAPSHOT.jar
	[INFO] ------------------------------------------------------------------------
	[INFO] BUILD SUCCESS
	[INFO] ------------------------------------------------------------------------
	[INFO] Total time: 1.531 s
	[INFO] Finished at: 2014-07-01T22:00:37+08:00
	[INFO] Final Memory: 7M/17M
	[INFO] ------------------------------------------------------------------------

类似的，Maven在打包之前，会执行编译、测试等操作。这里我们看到jar:jar负责打包，实际上，就是jar插件的jar目标，将项目主代码打包成为一个名为hello-world-1.0-SNAPSHOT.jar的文件，该文件也位于target/目录下，它是根据artifactId-version.jar规则进行命名的，如有需要，可以使用finalName来定义文件名称。

至此，我们得到了最终的jar包，如有需要，可以将这个jar包复制到其他项目的classpath中，从而使用HelloWorld类。但是，如何才能让其他Maven项目直接引用这个jar包呢？我们需要一个安装步骤，执行`mvn clean install`:

	... ...
	
	-------------------------------------------------------
	 T E S T S
	-------------------------------------------------------
	Running com.github.ningg.mvnbook.helloworld.HelloWorldTest
	Tests run: 1, Failures: 0, Errors: 0, Skipped: 0, Time elapsed: 0.031 sec

	Results :

	Tests run: 1, Failures: 0, Errors: 0, Skipped: 0

	[INFO]
	[INFO] --- maven-jar-plugin:2.4:jar (default-jar) @ hello-world ---
	[INFO]
	[INFO] --- maven-install-plugin:2.4:install (default-install) @ hello-world ---
	[INFO] Installing E:\reference\blogOfGit\maven-intro\hello-world\target\hello-world-1.0-SNAPSHOT.jar to C:\Documents and
	 Settings\Luious\.m2\repository\com\github\ningg\mvnbook\hello-world\1.0-SNAPSHOT\hello-world-1.0-SNAPSHOT.jar
	[INFO] Installing E:\reference\blogOfGit\maven-intro\hello-world\pom.xml to C:\Documents and Settings\Luious\.m2\reposit
	ory\com\github\ningg\mvnbook\hello-world\1.0-SNAPSHOT\hello-world-1.0-SNAPSHOT.pom
	[INFO] ------------------------------------------------------------------------
	[INFO] BUILD SUCCESS
	[INFO] ------------------------------------------------------------------------
	[INFO] Total time: 1.219 s
	[INFO] Finished at: 2014-07-01T22:11:04+08:00
	[INFO] Final Memory: 5M/15M
	[INFO] ------------------------------------------------------------------------

从输出结果可知，在jar:jar之后，Maven又执行了install:install，其将当前项目的jar包以及其POM配置文件，安装到了Maven的本地库中(`~/.m2/repository/`)。前文讲述JUnit的POM及jar下载的时候，我们说只有构件被下载到本地仓库后，才能由所有Maven项目使用类似，只有将Hello World的构件安装到本地仓库后，
其他Maven项目才能使用它。

我们已经尝试使用了Maven的主要命令：mvn clean compile，mvn clean test，mvn clean package，mvn clean install。
执行test之前会先执行compile，执行package之前会先执行test，执行install之前会先执行package。至此，我们已经知道这些命令是用来干什么的了，可以在其他任何Maven项目中执行这些命令。

**重要提示**：到目前为止，我们还没有运行Hello World项目，不要忘了HelloWorld类可能有一个main方法。默认打包生成的jar包并不能直接运行其中的main方法，因为带有main方法的类信息不会添加到manifest中（我们可以打开jar文件中的META-INF/MANIFEST.MF文件，将无法看到Main-Class一行）。为了生成可执行的jar文件，我们需要借助maven-shade-plugin，配置该插件如下：

	<build>
	 <plugins>
	  <plugin>
	   <groupId>org.apache.maven.plugins</groupId>
	   <artifactId>maven-shade-plugin</artifactId>
	   <version>1.2.1</version>
	   <executions>
         <execution>
           <phase>package</phase>
           <goals>
             <goal>shade</goal>
           </goals>
           <configuration>
             <transformers>
             <transformer implementation="org.apache.maven.plugins.shade.resource.ManifestResourceTransformer">
               <mainClass>com.github.ningg.mvnbook.helloworld.HelloWorld</mainClass>
             </transformer>
             </transformers>
           </configuration>
         </execution>
	   </executions>
	  </plugin>
	 </plugins>
	</build>

上面的plugin元素在POM中的相对位置应该在 `<project><build><plugins>` 下面。其中我们配置，mainClass 为 com.github.ningg.mvnbook.helloworld.HelloWorld ，项目在打包时，会将该信息放在MANIFEST中。执行完 `mvn clean package` 之后，在target/目录下，我们可以看到 hello-world-1.0-SNAPSHOT.jar 
和 original-hello-world-1.0-SNAPSHOT.jar，前者是带有Main-class信息的可运行jar，后者是原始的jar，打开 hello-world-1.0-SNAPSHOT.jar 的 META-INF/MANIFEST.MF，可以看到 Main-class 信息。

我们在项目根目录中执行该jar文件：

	E:\...\hello-world>java -jar target/hello-world-1.0-SNAPSHOT.jar
	Hello Maven

（**注意**：java命令行的使用方法，jar包等知识的补充）
	
控制台输出：`Hello Maven`，这正是我们所期望的。

本小节介绍了一个Hello World实例，侧重点是Maven而非Java代码，介绍了POM，Maven项目结构，以及如何编译、测试、打包、发布、运行。

### 2.6 使用Archetype生成项目骨架

Hello World项目中有一些Maven的约定：

1. pom.xml在项目的根目录；
2. 主代码在src/main/java/目录下；
3. 测试代码在src/test/java/目录下；

我们称这些基本的目录结构和pom.xml文件内容为项目的骨架。每次创建项目都要手动创建项目骨架，会让程序员不高兴，为此，Maven提供了Archetype以帮助我们快速勾勒出项目骨架。

以Hello World为例，我们使用maven archetype来创建该项目的骨架，新建一个Maven项目目录。

如果是Maven3，简单运行：

	mvn archetype:generate

（如果是Maven2，请参考：[《Maven实战（迷你版）》][《Maven实战（迷你版）》]）

实际上，我们运行的是maven-archetype-plugin插件，其输入格式是：groupId: artifactId: version: goal ，注意冒号的分隔。紧接着，我们会看到很长的输出，有很多可用的archetype供我们选择，包括注明的Appfuse项目、JPA项目的archetype等等。每一个archetype前面都会对应一个编号，同时命令行会提示一个默认的编号，对应archetype为maven-archetype-quickstart，直接回车选择该archetype，紧接着Maven会提示我们输入要创建的项目的groupId，artifactId，version以及包名（package，默认与groupId和artifactId保持对应关系），具体如下：

	Define value for property 'groupId': : com.github.ningg.mvnbook
	Define value for property 'artifactId': : hello-world-archetype
	Define value for property 'version':  1.0-SNAPSHOT: :
	Define value for property 'package':  com.github.ningg.mvnbook: : com.github.ningg.mvnbook.helloworldarchetype
	Confirm properties configuration:
	groupId: com.github.ningg.mvnbook
	artifactId: hello-world-archetype
	version: 1.0-SNAPSHOT
	package: com.github.ningg.mvnbook.helloworldarchetype
	 Y: : Y
	[INFO] ----------------------------------------------------------------------------
	[INFO] Using following parameters for creating project from Old (1.x) Archetype: maven-archetype-quickstart:RELEASE
	[INFO] ----------------------------------------------------------------------------
	[INFO] Parameter: groupId, Value: com.github.ningg.mvnbook
	[INFO] Parameter: packageName, Value: com.github.ningg.mvnbook.helloworldarchetype
	[INFO] Parameter: package, Value: com.github.ningg.mvnbook.helloworldarchetype
	[INFO] Parameter: artifactId, Value: hello-world-archetype
	[INFO] Parameter: basedir, Value: E:\reference\blogOfGit\maven-intro
	[INFO] Parameter: version, Value: 1.0-SNAPSHOT
	[INFO] project created from Old (1.x) Archetype in dir: E:\reference\blogOfGit\maven-intro\hello-world-archetype
	[INFO] ------------------------------------------------------------------------
	[INFO] BUILD SUCCESS

	...

运行完毕之后，在当前目录下会生成一个hello-world-archetype目录，其下是一个完整的项目骨架。

**特别说明**：如果你有很多项目拥有类似的项目骨架（项目结构和配置文件），你可以一劳永逸的开发自己的archetype，然后在项目中使用自定义的archetype来快速生成项目骨架。（具体请参考：[《Maven实战（迷你版）》][《Maven实战（迷你版）》]）




## 附录

### 中央仓库查找jar包

基本步骤：

* [The Central Repository - Maven(Search Engine)][The Central Repository - Maven(Search Engine)]上查找jar包的groupId\artifactId\version；
* 通过Maven中添加`dependency`即可自动下载jar包以及源码；
* 迫不得已时，需要上[中央仓库][The Central Repository - Maven]查看具体jar是否存在等情况；

### 强制添加依赖


如果在pom中强制添加`<dependency>`，则，通过`assembly:assembly`生成的jar包中，会包含此依赖吗？还是会自动剔除未使用的jar包？

（todo...）

todo list：（需要详细学习）

* [maven权威指南 - 学习笔记][maven权威指南 - 学习笔记]






## 参考来源

* [《Maven实战（迷你版）》][《Maven实战（迷你版）》]
* [The Central Repository - Maven(Search Engine)][The Central Repository - Maven(Search Engine)]
* [The Central Repository - Maven][The Central Repository - Maven]
* [maven权威指南 - 学习笔记][maven权威指南 - 学习笔记]



## 杂谈

系统梳理一个常用的工具或者概念，应该有几点：

* 整个系统的基本思路，来龙去脉：
	* 什么情况下，怎么来的？
	* 怎么解决的？
	* 上述原理、思路，如何简单表述？*（便于记忆、分享）*
* 若是工具，则，掌握：
	* 基本原理
	* 基本用法/命令
	* 问题定位思路















[《Maven实战（迷你版）》]:											/download/maven/Maven+in+action.pdf
[The Central Repository - Maven(Search Engine)]:					http://search.maven.org/
[The Central Repository - Maven]:									http://repo1.maven.org/maven2/org/
[maven权威指南 - 学习笔记]:										http://macrochen.iteye.com/blog/531437

[Gradle，构建工具的未来？]:										http://www.infoq.com/cn/news/2011/04/xxb-maven-6-gradle
[Why Build Your Java Projects with Gradle Rather than Ant or Maven?]:	http://www.drdobbs.com/jvm/why-build-your-java-projects-with-gradle/240168608
[Java构建工具：Ant vs Maven vs Gradle]:								http://blog.csdn.net/napolunyishi/article/details/39345995


