---
layout: post
title: Linux下快速跳转到指定路径
description:  每次登录之后，都需要cd到指定路径，这类重复劳动可以避免
category: Linux
---

##问题背景

最近部署`Hadoop`，路径为：`/home/hadoop/hadoop-1.0.4`，每次登陆`linux`系统都需要，机械式的重复`cd /home/hadoop/hadoop-1.0.4`命令。

##解决思路

经初步分析，有4条路可走：
1. 在用户登陆的默认路径下，建一个脚本，每次登陆后，执行脚本，转到hadoop路径；
2. 使用alias，将上面“cd /home/hadoop/hadoop-1.0.4”命令简化为其他替代命令；
3. 使用link文件，直接指向hadoop安装路径；
4. 直接修改，用户登陆后的默认路径；（弊端：原来默认路径下的文件，使用变得繁琐）；

##具体

###1.简简单单写个脚本

在用户登陆的默认目录下，新建`hadoop-auto.sh`

	#!/bin/bash
	# hadoop-auto.sh
	cd /home/hadoop/hadoop-1.0.4

并执行：

	chmod 775 hadoop-auto.sh

ok，脚本写好，也赋予了权限，可以运行一下试试了。敲入如下命令，坐等结果：

	./hadoop-auto.sh

 哭了，仍然在默认路径，貌似没有效果。几个情况？

冷静下来，分析一下，事情是有原因的：一些脚本的执行方式，实质是打开一个子bash，执行完脚本后，自动退出子bash，并不影响当前bash的状态。

好了，找到原因，我们就来详细分辨一下`source`、`sh`、`bash`、`./`四种执行脚本方式的区别：


|执行方式|使用格式|说明|
|:--|:--|:--|
|`source` 或`.`（点）	|`source FileName`或 `. FileName`	|使用当前`bash`下，执行|
|`sh` 或 `bash`			|`sh FileName`或 `bash FileName`	|打开一个子`bash`，执行|
|`./`					|`./FileName`						|打开一个子`bash`，执行|

__补充__：

* `sh`和`bash`有细微差别，自己google；
* 问题本质：子进程结束后，子进程内各项变量和操作不会传回父进程。

通过上面分析，在默认路径下，敲入如下命令：

	source hadoop-auto.sh
 
ok，搞定。

###2.随随便便改个别名

在linux系统中敲入如下命令：

	alias GO_hadoop=’cd /home/hadoop/hadoop-1.0.4′

再执行如下命令

	GO_hadoop

瞬间转到`hadoop`的安装路径，搞定；但是重启之后，此`alias`设置将失效，为保证长期有效，修改`/etc/bashrc`，在文件最后加上：

	`alias GO_hadoop=’cd /home/hadoop/hadoop-1.0.4′

__补充__：

* 自己查证，修改`~/.bashrc`和`/etc/bashrc`的区别
* 3. 和 4.  就不写了，有兴趣的自己google查一下。


[NingG]:    http://ningg.github.com  "NingG"
