---
layout: post
title: AIX下安装IBM JDK 1.6
description: AIX机器上，软件环境的安装
categories: AIX
---

## 背景

安装某个软件，需要JRE 6、JRE 7（推荐），而默认执行`java -version`查看为JRE 5。思考一下，初步解决思路两个：

* 查看当前系统是否安装JRE 6 ：系统可能已安装，只不过默认使用JRE 5，这样只需更换一下java调用路径即可；
* 安装JRE 6：本机没有JRE 6，那就安装一个；

## 检测是否已经安装JRE6

	# find / -name java		
	...
	/usr/java5/bin/java
	/usr/java5/jre/bin/java
	/usr/java5_64/bin/java
	/usr/java5_64/jre/bin/java
	/usr/java6/bin/java
	/usr/java6/docs/content/apidoc/DTFJ/com/ibm/dtfj/java
	/usr/java6/docs/content/apidoc/Security/Certpath/java
	/usr/java6/jre/bin/java
	/usr/lib/java
	...

	# find / -name javac
	/oracle/product/11.2.0/jdk/bin/javac
	/usr/java5/bin/javac
	/usr/java5_64/bin/javac
	/usr/java6/bin/javac

	# /usr/java6/bin/java -version
	java version "1.6.0"
	Java(TM) SE Runtime Environment (build pap3260sr9fp1-20110208_03(SR9 FP1))
	IBM J9 VM (build 2.4, JRE 1.6.0 IBM J9 2.4 AIX ppc-32 jvmap3260sr9-20110203_74623 (JIT enabled, AOT enabled)
	J9VM - 20110203_074623
	JIT  - r9_20101028_17488ifx3
	GC   - 20101027_AA)
	JCL  - 20110203_01

从上面可知，系统已经安装了JDK 6，此可以替代JRE 6，具体路径：`/usr/java6/`。

## AIX环境下安装IBM JDK 1.6

(doing...)

请参考：[AIX环境下安装IBM JDK 1.6][AIX环境下安装IBM JDK 1.6]







[NingG]:    		http://ningg.github.com  "NingG"
[AIX下安装bash]:	http://blog.csdn.net/zztp01/article/details/6213451
[AIX toolbox]:		http://www-03.ibm.com/systems/power/software/aix/linux/toolbox/alpha.html
[快速透视AIX系统]:	http://www.ibm.com/developerworks/cn/aix/library/1111_liuge_getstartaix/
[AIX常用命令汇总]:	http://www.ibm.com/developerworks/cn/aix/library/au-dutta_cmds.html
[AIX环境下安装IBM JDK 1.6]:		http://blog.csdn.net/shenghuiping2001/article/details/5801984
