---
layout: post
title: JDK源代码绑定
description: JDK的rt.jar对应的源代码，在JDK安装文件的src.zip中包含的源代码不全
category: java
---

通常查看JDK的源码，只需要绑定JDK安装目录下的`src.zip`文件即可；不过src.zip中包含的源代码不全，例如，查看rt.jar包对应的 `sun.nio` package。

## 源码绑定

几点：

* [openjdk-JDK6][openjdk-JDK6]上下载JDK6的源码：openjdk-6-src-b34-20_jan_2015.tar.gz
* 解压源码；
* rt.jar的源码绑定，具体：
	* Eclipse下，`Window`--`Preferences`--`Java`--`Installed JREs`；
	* `Edit JRE`--选中`rt.jar`--`Source Attachment Configuration`--`External File`或`External Folder`；
	* 此次选择`External Folder`，将`rt.jar`的源码绑定到`/JDK_SRC_HOME/jdk/src/share/classes`目录下；
	
	
**疑问**：JDK和JRE下有多个`*.jar`文件，例如：dt.jar、tools.jar、sa-jdi.jar、rt.jar等，如何确定这些jar文件与JDK源码文件夹的对应关系？简单来说，这些jar文件的源码需要绑定到哪些目录下？


（todo：如何确定JDK、JRE下各类jar包，对应的源码文件夹？基本思路：JDK的源码编译过程中，会说明每个文件夹的用途的，查看一下，或者闲暇时，编译下）






## 参考来源


* [openjdk-JDK6][openjdk-JDK6]
* [jdk添加源码-rt.jar/tools.jar][jdk添加源码-rt.jar/tools.jar]









[NingG]:    								http://ningg.github.com  "NingG"
[openjdk-JDK6]:								http://openjdk.java.net/projects/jdk6
[jdk添加源码-rt.jar/tools.jar]:						http://agapple.iteye.com/blog/1057192










