---
layout: post
title: Linux的环境变量
description: 环境变量是什么？不同的用户拥有不同的环境变量，怎么设置的？
category: Linux
---

##背景

最近某个需求，要去修改jar包内的配置文件，中间几个细节不想多说，但期间有个需求是：

1. 将Linux自带的JDK由OpenJDK升级为Oracle(Sun)版本的JDK；
2. 要求所有用户都能使用Oracle(Sun)版本的JDK；

##安装软件

这次把软件的安装过程拿出来，为了说明几件小事：Linux下安装软件最好通过已成符号链接文件进行，以方便软件今后的升级；

	// 将jdk的压缩文件解压到目录/usr/java下，解压之后文件夹为jdk-7u51-linux-x64
	tar -zxvf jdk-7u51-linux-x64.gz -C /usr/java
	// 在目录/usr/java下新建一个符号连接default
	ln -n jdk-7u51-linux-x64 default

下面添加环境变量：

	vim ~/.bashrc
	// 添加环境变量JAVA_HOME（要求：对所有用户有效）
	export JAVA_HOME=/usr/java/default
	// 将java添加到PATH中（要求：对所有用户有效）
	export PATH=$JAVA_HOME/bin:$PATH

注：上面使用符号链接文件的方式，来设置软件安装路径，方便软件升级，很巧妙，仔细体会一下。

##环境变量

###简介

变量的作用范围一般是某个进程（正在运行的程序）之内，如果希望多个进程共享这个变量，也是可以的，将这个变量设置为`环境变量`即可，环境变量也称为，全局变量，共享变量；在child shell和child process中，可以继续使用此环境变量。

上面可以看出：环境变量是在某个进程中设置的，而且，目标是希望其他进程共享。

设置环境变量：

	export JAVA_HOME=/usr/java/default
	export PATH=$PATH:$JAVA_HOME/bin

###作用范围

当前系统中设置的环境变量，两个基本问题：

1. 环境变量在哪设置的？
2. 它的作用范围是什么？

`环境变量`是在一个bash进程中定义的，其作用范围是当前进程以及当前进程的所有子进程。

根据范围大小，可以设置一些环境变量：

1. 所有bash进程共享的环境变量；
2. 某个用户独享的环境变量；

* /etc/profile：整个系统共享的环境变量；
* ~/.bash_profile 或者 ~/.bash_login 或者 ~/.profile 或者 ~/.bashrc，各个用户独享的环境变量；

（详解：各个文件加载过程？以及各个文件的用途，为什么要分这么多文件/层次来加载？等待补充）

**解决办法**：`man bash`，在bash的帮助文档中，有详细说明：





TODO:

* [理解Linux环境变量及配置文件执行顺序][理解Linux环境变量及配置文件执行顺序]
* [Bash: about .bashrc, .bash_profile, .profile, /etc/profile, etc/bash.bashrc and others][Bash: about .bashrc, .bash_profile, .profile, /etc/profile, etc/bash.bashrc and others]






##参考来源

* 《鸟哥私房菜（第三版）》 第11章 认识和学习BASH








[理解Linux环境变量及配置文件执行顺序]:															http://liuzhijun.iteye.com/blog/1744465
[Bash: about .bashrc, .bash_profile, .profile, /etc/profile, etc/bash.bashrc and others]:		http://stefaanlippens.net/bashrc_and_others
[What's the difference between .bashrc, .bash_profile, and .environment?]:						http://stackoverflow.com/questions/415403/whats-the-difference-between-bashrc-bash-profile-and-environment




