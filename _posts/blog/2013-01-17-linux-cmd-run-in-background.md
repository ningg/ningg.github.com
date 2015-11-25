---
layout: post
title: Linux 后台运行命令
description: SSH远程操作linux服务器：SSH连接中断，导致当前运行的命令也终止
category: Linux
---

##问题背景

使用`SecureCRT`/`putty`等客户端，远程连接Linux服务器，并且执行脚本时，由于网络不稳定，有可能导致连接中断，在这种情况下，我担心会影响脚本程序的正常执行（不能肯定是否一定会影响）；因此希望启动一个脚本，让其在后台一直运行，不会随着`连接中断`而终止掉。

__外加问题__：现在一个命令的输出信息过多，希望后台运行时，不保存输出信息。

##解决办法

###简要说明
先说最终的解决办法：

	nohup sh collectCloSpan.sh &

简要说明：

1. `&`：表示启动子进程，`sh collectCloSpan.sh`在后台运行；
2. `nohup`：表示，如果当前连接到服务器的终端关闭，进程`sh collectCloSpan.sh` 继续执行，不受影响;
3. 进程`sh collectCloSpan.sh`的输出信息，保存在当前路径的`nohup.out`文件中。（如果当前路径不允许新建文件，则，输出信息保存在`~/nohup.out`文件中）

好了，现在怎么解决`nohup.out`文件过大的问题呢？

**补充说明**：除了 `nohup CMD &`的解决方案，还有一个更优的方案： `screen` 命令。*（会单独写一篇文章介绍 screen 命令）*

###输出文件过大

经过查询有2个解决思路：

1. 完全删除输出信息：一点输出信息都不想要；
2. 删除过时的输出信息，只保留最近一段时间的输出信息。

完全删除输出信息：在程序后台运行之后，直接删除文件nohup.out文件即可，除非重新运行程序，否则，不会再有`nohup.out`文件；

删除过时的输出信息（在线清空文件内容）：

	/*执行效率较高*/
	cp /dev/null nohup.out

或者
	
	/*文件很大时，执行较慢*/
	cat /dev/null > nohup.out

关于`/dev/null`到底是什么，自己`google`或者`baidu`吧。

感兴趣的可以具体看下面的详细说明。*（不感兴趣的可以直接跳过了）。*

##效果验证 & 细节分析

后台运行脚本（[参考1](https://www.ibm.com/developerworks/cn/linux/l-cn-nohup/)）：

	nohup ping www.baidu.com &

然后等待，出现如下结果：

![LINUX后台运行命令nohup测试](/images/linux-cmd-run-in-background/linux-cmd-run-in-background.jpg)


输入命令`jobs`可以查看现有的后台程序，如上图；并且可以使用`fg 1`命令，将第一个后台程序，调入前台。

在`shell`环境下，使用`exit`命令退出；如上图所示。*（启动进程`nohup ping www.baidu.com &`后，如果没有返回到`shell`环境，则直接敲`回车(Enter)`即可）*


再次使用`SecureCRT`/`putty`等终端登录，并输入如下命令：

	ps –ef | grep “ping”

可以看到上图中结果，原来的进程`pid`为`13380`还在执行，只是此进程的`父进程`变为`pid=1`的特殊进程。

__总结__：后台运行：`command &`和 `nohup command &`有区别吗？

答：

1. `command &`：启用新进程，后台运行，关掉中断，命令会终止运行；
2. `nohup command &`：启动新进程，后台运行，关掉终端，命令会继续运行（nohup：让进程忽略 SIGHUP 中断信号）；

特别说明：上述 `nohup command &` 的本意：

1. `&`：启用子进程运行 command；
2. `nohup`：设定子进程忽略 SIGHUP 进程中断信号；如果子进程的父进程终止运行，则子进程将父进程设置为 `pid = 1` 的超级进程

##进程的挂起与运行

通常挂起、执行进程的基本步骤：

1. `ctrl + z`：挂起当前执行的前台进程；*（命令挂起，并没有在后台执行）*
2. `jobs`：查询被挂起的进程；
3. `fg jobsNo`：继续执行被挂起的进程；*（`jobsNo`：使用`jobs`查询获取的进程编号）*


下面对几个命令，简要介绍一下：

|命令|说明|
|:--|:--|
|`ctrl + z`|挂起进程|
|`ctrl + c`|终止进程|
|`jobs`|list the `active jobs` (both `running jobs` and `stopped jobs`).|
|`fg [jobspec]`|在foreground继续执行进程|
|`bg [jobspec ...]`|在background继续执行进程。*（此时，无法使用`ctrl + z`和`ctrl + c`来操作进程）*|


**思考**：进程的`active`,`running`,`stopped`,`suspended`几种状态是什么？他们之间有什么关系？

##参考来源

1. <https://www.ibm.com/developerworks/cn/linux/l-cn-nohup/>
2. <http://www.linuxidc.com/Linux/2010-09/28366.htm>
3. <http://www.cnblogs.com/lwm-1988/archive/2011/08/20/2147299.html>


[NingG]:    http://ningg.github.com  "NingG"
