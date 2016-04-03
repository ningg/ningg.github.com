---
layout: post
title: Linux下查看 full command arguments
description: Linux下正在运行的command arguments中包含一些配置参数，如何进行查看呢？
category: linux
---


Linux下，查看一个正在运行的命令的详细启动参数，可以运行如下命令：

	ps -ef | grep [pattern]

但是有个问题，命令的详细执行参数过长时，会被截断，具体看下行：

	[storm@server apache-flume-1.5.2-bin]$ ps -ef | grep flume
	storm    52842 48176  0 15:25 pts/0    00:00:15 /usr/java/default/bin/java
	-Xms128m -Xmx512m -Dflume.monitoring.type=ganglia -Dflume.monitoring.host
	s=239.2.11.165:8649 -cp /home/storm/apache-flume-1.5.2-bin/conf-165:/home
	/storm.p（此处被开始，内容被系统强制省略）

本来截断信息，无所谓的；不过恰好，截断信息中含有有用的内容，我x，这个一定要把他揪出来。查询一下，发现一个[相关的讨论][how to get the command line args passed to a running process on unix/linux systems]，赶紧尝试一下其中的解决办法：

	// 查找 <pid>
	ps -ef | grep [pattern]
	
	// 查看 <pid> 对应命令的详细参数
	cat /proc/<pid>/cmdline
	
很不幸呀，上述查看`/proc/<pid>/cmdline`的内容与`ps -ef`获取的command arguments没有差别。怎么办？还好，自己的命令都是`nohup ... `启动的，在启动目录下，`nohup.out`文件中保存了详细的启动参数，在其中直接可以看出。问题解决了，暂时就这样吧，更深层的内容，找机会解决了。



TODO：

* `/proc/<pid>`文件的详细用法及含义；










## 参考来源


* [how to get the command line args passed to a running process on unix/linux systems][how to get the command line args passed to a running process on unix/linux systems]









## 杂谈


博客中写什么内容？

* 琐碎的小问题：
	* 今后遇到次数多了，方便进行系统思考；
* 系统思考、梳理的问题：
	* 预期：随着理解深入，调整表述









[NingG]:    http://ningg.github.com  "NingG"

[how to get the command line args passed to a running process on unix/linux systems]:					http://stackoverflow.com/questions/821837/how-to-get-the-command-line-args-passed-to-a-running-process-on-unix-linux-syste






