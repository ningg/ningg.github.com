---
layout: post
title: Windows下常用命令
description: 
category: windows
---

> 说实话，之前在技术上很排斥windows，经过这段时间打磨，基本有个观点：倾向使用Linux，但环境限制需要解决windows下的某些情况时，本质就是问题，用心去解决。

##查看端口占用

Windows下，CMD中，通过如下命令查看端口占用情况：

	// netstat -h查看命令详情
	C:\Documents and Settings\ningg>  netstat -ano

	Active Connections

	  Proto  Local Address          Foreign Address        State           PID
	  TCP    0.0.0.0:135            0.0.0.0:0              LISTENING       1160
	  TCP    0.0.0.0:445            0.0.0.0:0              LISTENING       4
	  TCP    0.0.0.0:3389           0.0.0.0:0              LISTENING       1076
	  TCP    0.0.0.0:5140           0.0.0.0:0              LISTENING       4472
	  TCP    0.0.0.0:8081           0.0.0.0:0              LISTENING       1416
	  TCP    0.0.0.0:8197           0.0.0.0:0              LISTENING       5092
	  TCP    0.0.0.0:17866          0.0.0.0:0              LISTENING       1848
	  TCP    127.0.0.1:1028         0.0.0.0:0              LISTENING       780
	  TCP    127.0.0.1:1033         127.0.0.1:1034         ESTABLISHED     1116
	
现在希望终结占用5140端口的进程，上面查询可知PID=4472的进程占用此端口，如何终止这个进程呢？打开`任务管理器`，在`查看(V)`-->`选择列(S)...`-->勾选`PID（进程标识符）`，然后在任务管理器中`进程`页面，即可看到每个进程对应的PID号，终止掉对应PID的进程即可。下图为查询到的进程。

![](/images/windows-normal-cmd/pid-windows-manager.png)

##更改CMD的编码方式

###背景

最近通过[UNXutils][UNXutils]来实现windows下的tail命令时，如果log是`ANSI`格式编码，则CMD窗口能够正常显示；但如果log是`UTF-8`格式，则CMD窗口显示乱码。

###分析

本地文件的乱码问题，无非关注几个点：

* 原始文件的编码；
* 显示窗口的编码（解码方式）；
* 传输过程中的编码方式；*（对利用网络传输的内容有效）*

windows下，通过Notepad++编辑器，能够很容易查看当前log的编码方式，同时，利用Notepad++也能很方便地对log进行编码方式的转换。总结一下：能够完全掌握原始文件的编码。现在问题焦点就是显示窗口的编码方式了，如何查看？窗口是有属性的吧，对，就在CMD窗口的`属性`中，有两个相关项：`当前代码页`和`字体`。

再往下，不说了思考的细节了，直接说解决办法：

####1. 修改当前代码页的编码方式
	
	// 当前代码页修改为65001：UTF-8
	chcp 65001
	
补充：代码页默认936：ANSI/OEM - 简体中文（GBK）
	
####2. 修改CMD窗口的字体

选择字体为：Lucida Console

OK，确定对当前窗口生效。

##Java常见问题

	...
	java.lang.IllegalArgumentException: Malformed \uxxxx encoding.
	...

通常是properties配置文件中，路径中包含`\\`，则出现上述错误，需要将其替换为`/`即可。


##win下bat脚本中设置path


	set Path=%Path%;d:/


##windows下tail命令

整体上有两种方式，一种直接利用第三方的开源实现，另一种，利用windows下的powershell环境。

* [UNXutils][UNXutils]，直接下载后，在环境变量中配置之后，即可使用，推荐XP环境下使用；
* 利用powershell命令：`get-content mylog.log -wait`，更多参考：[11 ways to tail a log on windows][11 ways to tail a log on windows]；

注：powershell v1.0版本中，`get-content mylog.log -wait` 可以实现tail命令功能，但在powershell v2.0版本中，`get-content`命令可能有差异，具体参考：[更多阅读][windows powershell get-content]

##win下名词

* Win32：Windows 95, 98, ME, NT, 2000, XP, 2003, Vista














##参考来源

* [UNXutils][UNXutils]
* [11 ways to tail a log on windows][11 ways to tail a log on windows]
* [windows powershell get-content][windows powershell get-content]



[NingG]:    							http://ningg.github.com  "NingG"
[UNXutils]:								http://sourceforge.net/projects/unxutils/
[11 ways to tail a log on windows]:		http://www.stackify.com/11-ways-to-tail-a-log-file-on-windows-unix/
[windows powershell get-content]:			http://stackoverflow.com/questions/4426442/unix-tail-equivalent-command-in-windows-powershell


##杂谈

乐于分享，我算是这么一类人，有时候心想：把经验分享出去，会不会导致被别人反超？但转念又一想：即使有人花费一点点时间就学会了，自己花费挺长时间才总结积累的经验，那对我可能不利，但对整个社会、对民族总是好的，能作为社会向前的垫脚石，也算是有点用。






