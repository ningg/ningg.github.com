---
layout: post
title: Linux 下 使用 screen 进行会话管理
description: screen 的使用场景、用法
published: true
category: linux
---

##什么问题？

问题：

> 通过命令终端，在远端服务器上执行任务，任务比较耗时，执行时间很长，如果不小心关闭终端或者网络抖动，都导致任务中止。

之前的解决方法：`nohup CMD &` 在后台启动子进程。

现在使用 `screen` 命令，是更优的选择。

##如何使用？

几点：

* 创建screen：screen -S [screen_name]
* 退出screen：CTRL + A + D
* 查询screen：screen -ls
* 切换screen：screen -r [screen_name]/[screen_id]
* 关闭screen：exit / CTRL + D
* 查看screen的输出：CTRL + A


###完整的使用场景

典型场景：终端登陆服务器后，通常要打开很多窗口，使用 screen 可以保存窗口，每次登陆，只需要在 screen 之间切换即可。

###例子

#### 新建一个Screen Session

```
$ screen -S screen_session_name
```

#### 将当前Screen Session放到后台

```
$ CTRL + A + D
```

#### 唤起一个Screen Session

```
$ screen -r screen_session_name
```

#### 分享一个Screen Session

```
$ screen -x screen_session_name
```

通常你想和别人分享你在终端里的操作时可以用此命令。

#### 终止一个Screen Session

```
$ exit
$ CTRL + D
```

#### 查看一个screen里的输出

当你进入一个screen时你只能看到一屏内容，如果想看之前的内容可以如下：

```
$ Ctrl + a ESC
```

以上意思是进入Copy mode，拷贝模式，然后你就可以像操作VIM一样查看screen session里的内容了。

可以 Page Up 也可以 Page Down。

#### screen进阶

对我来说，以上就足够了，有特定需求时再说。


#### End

screen命令很好用，但是最让人头痛的是`CTRL+A`命令和BASH里的快捷键重复了，我不觉得替换一下快捷键是个很好的解决方案，所以这个问题一直存在我这里。

这里有更详细的说明：<http://www.ibm.com/developerworks/cn/linux/l-cn-screen/>



##什么原理？

screen 如何抵挡的住网络中断？什么道理？

先来回顾一下`nohup CMD &`，本质：子进程忽略 SIGHUP 中断信号，父进程跪了之后，自动将父进程设置为`pid = 1`的超级进程。

screen 命令，什么原理？






##参考来源

1. <https://github.com/chenzhiwei/linux/tree/master/screen>
2. <https://www.ibm.com/developerworks/cn/linux/l-cn-screen/>
3. 
































[NingG]:    http://ningg.github.com  "NingG"










