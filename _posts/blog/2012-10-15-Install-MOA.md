---
layout:        post
title:         MOA的安装
category:      MOA
description:   MOA源代码定制之前，需要先运行其java源代码；
---

##概述

###目标

同时查看MOA源代码和Weka的源代码，记录配置过程。

###具体步骤
1. 搭建[weka]环境，使其独立运行，无错误;
2. 重新搭建[MOA]环境，使其独立运行，无错误;
3. 如何在[MOA]独立环境中查看[weka]源代码;

###参考资料
+ [MOA]官网
+ [weka]官网 
+ [google]、[baidu]搜索

##搭建Weka环境

###主要参考来源

* [weka]
* [weka-FAQ]

###详细步骤

####可执行文件方式，搭建weka环境
从[weka官网][weka]中下载Weka安装文件。由于目前支持`MOA`的`Weka`必须是`3.7.X`以上版本，本次选择下载`weka-3.7-7`

操作系统环境：

    win XP Professional 5.1.2600 Service Pack 3 内部版本号2600 基于X86

可选择的Weka安装文件类型：

1. `weka-3-7-7.exe`(`windows X86`)需要安装，系统自动配置环境。
2. `weka-3-7-7.zip`无需安装，手动进入目录，使用命令行启动图形界面。

本次选择`weka-3-7-7.zip`，解压之后，运行方式：

    java –Xmx1000M –jar weka.jar
    
为了便于今后运行`weka`方便，我写了个`weka-start.bat`文件：

~~~~bat
d:
cd "\reference\data mining\数据挖掘\weka\weka 安装文件\weka-3-7-7"
java -Xmx1000M -jar weka.jar
~~~~

__说明__ ：对应于上面bat文件，本地`weka-3-7-7.zip`解压目录为：

    D：\reference\data mining\数据挖掘\weka\weka 安装文件\weka-3-7-7

__注意__ ：运行`weka`之前，需要安装`JDK`，具体版本，查看：

   [weka官网] `Requirements`目录

####源码方式，搭建weka环境
使用`weka`源码，在`eclipse`下，搭建`weka`工程。

`weka`源码位置：

    //weka-3-7-7.exe(windows X86)
    安装目录下“weka-src.jar”
    //weka-3-7-7.zip
    解压目录下“weka-src.jar”

或者，通过`subversion`来获得源码：

    http://weka.wikispaces.com/Subversion
    
解压`weka-src.jar`得到如下文件列表：

    //Ant build file for weka.
    build.xml
    //ANT file for generating JFlex/CUP parsers.
    parsers.xml
    /*POM是项目对象模型(Project Object Model)的简称，
     *它是Maven项目中的文件，使用XML表示，名称叫做pom.xml。
     *在Maven中，当谈到Project的时候，不仅仅是一堆包含代码的文件。
     *一个Project往往包含一个配置文件，包括了与开发者有关的，缺陷跟踪系统，
     *组织与许可，项目的URL，项目依赖，以及其他。它包含了所有与这个项目相关
     *的东西。事实上，在Maven世界中，project可以什么都没有，
     *甚至没有代码，但是必须包含pom.xml文件。
     */
    pom.xml
    .classpath.default
    .project.default
	
【说明】：更详细的内容，请自行查找`maven`、`ant`的知识。

    在eclipse中File  –>  import –>  existing Maven Projects ，选择weka-src的解压目录。

OK，至此，导入源代码成功（如果没有成功，请反复再看看前面的操作细节）。

从源代码运行`weka`
找出`java`文件：

    /weka-dev/src/main/java/weka/gui/GUIChooser.java
    
运行其中的`main`函数即可。

####附录：Maven知识

[目标]：`maven`可以完成什么工作？怎么完成？单独写一个文档。
(doing...)

##搭建MOA环境

###主要参考来源

* MOA自带文档[Manual.pdf]中`Installation`部分。
 
###详细步骤


####源码方式，搭建MOA环境

下载文件：[MOA download]中下载`MOA Release 2012.08`

解压并分析文件


	//启动moa图形界面的文件：moa.bat、moa.sh
	bin

	//api文档（html版本），moa手册：Manual.pdf、StreamMining.pdf、 Tutorial1.pdf、Tutorial2.pdf
	doc

	//moa自带的Tutorial2.pdf中例子2的源代码。
	examples
	 
	//moa对应生成的可执行jar包
	lib
	 
	//开源软件声明信息
	license

	//源码文件
	src

	//编译后，可执行的moa包
	moa.jar

	//用于测试java对象所占内存大小，所需要的包。
	sizeofag.jar



在eclipse下新建`java`工程，并将`src`文件夹下的源代码文件夹复制到工程的`src`目录下；注意所需`jar`包也需要添加进去。

工程运行，需要`weka.jar`包的支持，因此，下载`weka3.7.0`以上的版本，并添加到`java project`的路径中。

仔细观察，发现上面操作之后，`java`工程仍然提示有错，无法运行。打开出错的`java`源文件，发现`import moa.core.Globals`出，提示`cannot be resolved`。


__解决办法__ ：刚才`src`下添加的源文件，有2个`moa`文件夹，将占存储小的`moa`文件夹下源文件，复制到另一个`moa`文件夹下，保持文件夹内的相对路径不变。

__注意__ ：`moa`的`2012.08`版本中，使用`junit4`进行的单元测试。原因：`test/moa/integration/SimpleClusterTest.java` 中`import org.junit.Test;`存在于`junit4`中（`junit3`中不存在此用法）。
  
从源代码运行`weka`
找出`java`文件：

    /moa/src/moa/gui/GUI.java

运行其中的`main`函数即可。

####附录：Junit4知识

目标：`Junit4`的有什么用？怎么用？单独写一个文档。


##MOA环境下，查看weka源代码

在搭建好`MOA`环境之后，有些程序继承自`weka`，`Ctrl+”点击code”`方式查看源代码时，会弹出如下界面：

![attach-src](/images/install-moa/attach-sourcecode.jpg)

__解决办法__ ：点击上面的“Attach Source”按钮，并添加`weka-src.jar`包即可。





$$
\begin{align*}
  & \phi(x,y) = \phi \left(\sum_{i=1}^n x_ie_i, \sum_{j=1}^n y_je_j \right)
  = \sum_{i=1}^n \sum_{j=1}^n x_i y_j \phi(e_i, e_j) = \\
  & (x_1, \ldots, x_n) \left( \begin{array}{ccc}
      \phi(e_1, e_1) & \cdots & \phi(e_1, e_n) \\
      \vdots & \ddots & \vdots \\
      \phi(e_n, e_1) & \cdots & \phi(e_n, e_n)
    \end{array} \right)
  \left( \begin{array}{c}
      y_1 \\
      \vdots \\
      y_n
    \end{array} \right)
\end{align*}
$$














[MOA]: http://moa.cs.waikato.ac.nz "Massive Online Analysis"
[weka官网]: http://www.cs.waikato.ac.nz/ml/weka/ "Waikato Environment for Knowledge Analysis"
[weka]: http://www.cs.waikato.ac.nz/ml/weka/ "Waikato Environment for Knowledge Analysis"
[google]: http://www.google.com/ncr "google search engine"
[baidu]: http://www.baidu.com "baidu search engine"
[weka-FAQ]: http://weka.wikispaces.com/Frequently+Asked+Questions "weka Frequently Asked Questions"
[Manual.pdf]: http://heanet.dl.sourceforge.net/project/moa-datastream/documentation/Manual.pdf "MOA Manual Documentation"
[MOA download]: http://moa.cms.waikato.ac.nz/downloads/ "MOA download site"




