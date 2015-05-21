---
layout: post
title: Java 命令详解，java
description: 执行java命令时，需要考虑的选项
published: true
category: java
---


##java命令

###-cp 设定加载类路径

在JDK 7，存在`-cp`参数，具体参考：

* [Windows下java命令(JDK 7)][Windows下java命令(JDK 7)]
* [Linux下java命令(JDK 7)][Linux下java命令(JDK 7)]

在JDK 8，已经取消了`-cp`参数，详细参考：*（是这样吗？）*

* [Windows下java命令(JDK 8)][Windows下java命令(JDK 8)]
* [Linux下java命令(JDK 8)][Linux下java命令(JDK 8)]



###-D arguments 参数

> `-D<name>=<value>` set a system property  设置JVM系统属性；

在java源文件中，通过`System.getProperty("<name>")`即可获取上述设置的JVM系统属性；这种方式来传递属性，与`main(String[] args)`不同，因为`-D<name>=<value>`是JVM系统级的，在JVM上所有class文件中都可以获取，而`main(String[] args)`中，`args`默认是入口class的参数。



查看JVM内部所有的系统属性：`System.getProperties().list(System.out);`，我本地输出效果如下：*（与本地通过`env`命令，查看的效果不同）*

	-- listing properties --
	java.runtime.name=Java(TM) SE Runtime Environment
	sun.boot.library.path=D:\Program Files\Java\jdk1.7.0_67\jre...
	java.vm.version=24.65-b04
	java.vm.vendor=Oracle Corporation
	java.vendor.url=http://java.oracle.com/
	path.separator=;
	java.vm.name=Java HotSpot(TM) Client VM
	file.encoding.pkg=sun.io
	user.script=
	user.country=CN
	sun.java.launcher=SUN_STANDARD
	sun.os.patch.level=Service Pack 3
	java.vm.specification.name=Java Virtual Machine Specification
	user.dir=D:\Program-Files\workspace\TestBasic
	java.runtime.version=1.7.0_67-b01
	java.awt.graphicsenv=sun.awt.Win32GraphicsEnvironment
	java.endorsed.dirs=D:\Program Files\Java\jdk1.7.0_67\jre...
	os.arch=x86
	java.io.tmpdir=C:\DOCUME~1\Luious\LOCALS~1\Temp\
	line.separator=

	java.vm.specification.vendor=Oracle Corporation
	user.variant=
	os.name=Windows XP
	sun.jnu.encoding=GBK
	java.library.path=D:\Program Files\Java\jdk1.7.0_67\bin...
	
	test_input=test_value
	
	java.specification.name=Java Platform API Specification
	java.class.version=51.0
	sun.management.compiler=HotSpot Client Compiler
	os.version=5.1
	user.home=C:\Documents and Settings\Luious
	user.timezone=Asia/Shanghai
	java.awt.printerjob=sun.awt.windows.WPrinterJob
	file.encoding=UTF-8
	java.specification.version=1.7
	user.name=cib
	java.class.path=D:\Program-Files\workspace\TestBasic\bin
	java.vm.specification.version=1.7
	sun.arch.data.model=32
	java.home=D:\Program Files\Java\jdk1.7.0_67\jre
	sun.java.command=com.cib.time.TimE
	java.specification.vendor=Oracle Corporation
	user.language=zh
	awt.toolkit=sun.awt.windows.WToolkit
	java.vm.info=mixed mode, sharing
	java.version=1.7.0_67
	java.ext.dirs=D:\Program Files\Java\jdk1.7.0_67\jre...
	sun.boot.class.path=D:\Program Files\Java\jdk1.7.0_67\jre...
	java.vendor=Oracle Corporation
	file.separator=\
	java.vendor.url.bug=http://bugreport.sun.com/bugreport/
	sun.cpu.endian=little
	sun.io.unicode.encoding=UnicodeLittle
	sun.desktop=windows
	sun.cpu.isalist=pentium_pro+mmx pentium_pro pentium+m...

上述输出中：`test_input=test_value`，是我以`-Dtest_input=test_value`配置的。

####通过-Djava.ext.dirs来设置-cp（类搜索路径）

通过`-cp .;a.jar;b.jar`来指定类加载的jar时，windows下使用`;`分隔，linux下使用`:`分隔，需要列出所有jar包*（现在这一情况有没有改善？）*；如果希望通配符效果，使用：`java -Djava.ext.dirs=...`来替换`-cp`配置。

特别说明：不建议上述操作，具体：

虚拟机在运行一个类时，需要将其装入内存，虚拟机搜索类的方式和顺序如下：*（双亲委派模式）*

`Bootstrap classes` -- `Extension classes` -- `User classes`

* Bootstrap 中的路径是虚拟机自带的jar或zip文件，虚拟机首先搜索这些包文件，用`System.getProperty("sun.boot.class.path")`可得到虚拟机搜索的包名。
* Extension是位于jre/lib/ext目录下的jar文件，虚拟机在搜索完Bootstrap后就搜索该目录下的jar文件。用`System.getProperty("java.ext.dirs”)`可得到虚拟机使用Extension搜索路径。
* User classes搜索顺序为当前目录、环境变量 CLASSPATH、-classpath，用`System.getProperty("java.class.path”)`得到User classes路径。


####JVM系统环境与OS系统环境

上述`System.getProperty("<name>")`中System是指 JRE system，不是OS。



####Eclipse下配置VM参数

在Eclipse下如何配置VM的启动参数？即，如何配置`-D`属性？具体：`run as`  -- `run configurations`  -- `Arguments` -- `VM arguments`，直接书写`-D<name>=<value>`即可，*（多参数时，分行输入）*



####扩展阅读

* [JAVA 命令参数详解：-D][JAVA 命令参数详解：-D]




##参考来源

主要参考：Java的官方文档

* [Java SE Technologies][Java SE Technologies] *（所有内容，都从这个开始）*
* [Java Platform Standard Edition 8 Documentation][Java Platform Standard Edition 8 Documentation]
* [Java HotSpot VM Options][Java HotSpot VM Options]
* [java command][java command]
* [JVM系列三:JVM参数设置、分析][JVM系列三:JVM参数设置、分析]
* [Java命令行运行参数说明大全][Java命令行运行参数说明大全]




























[NingG]:    										http://ningg.github.com  "NingG"
[Java SE Technologies]:								http://www.oracle.com/technetwork/java/javase/tech/index.html
[Java Platform Standard Edition 8 Documentation]:	http://docs.oracle.com/javase/8/docs/index.html
[Java HotSpot VM Options]:							http://www.oracle.com/technetwork/articles/java/vmoptions-jsp-140102.html
[java command]:										http://docs.oracle.com/javase/7/docs/technotes/tools/windows/java.html
[JVM系列三:JVM参数设置、分析]:						http://www.cnblogs.com/redcreen/archive/2011/05/04/2037057.html
[Java命令行运行参数说明大全]:						http://xinklabi.iteye.com/blog/837435
[JAVA 命令参数详解：-D]:							http://blog.sina.com.cn/s/blog_605f5b4f0100hlt9.html


[Windows下java命令(JDK 7)]:							http://docs.oracle.com/javase/7/docs/technotes/tools/windows/java.html
[Linux下java命令(JDK 7)]:							http://docs.oracle.com/javase/7/docs/technotes/tools/solaris/java.html

[Windows下java命令(JDK 8)]:							http://docs.oracle.com/javase/8/docs/technotes/tools/windows/java.html
[Linux下java命令(JDK 8)]:							http://docs.oracle.com/javase/8/docs/technotes/tools/unix/java.html

