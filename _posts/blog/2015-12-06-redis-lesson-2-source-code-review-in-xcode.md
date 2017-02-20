---
layout: post
title: Redis 设计与实现：使用Xcode 查看 Redis 源码
description: 构建源码阅读环境
published: true
category: redis
---

## 1. 安装 Xcode

下载途径：

* 从 App Store 中安装 Xcode，一般需要 3~10 小时，公司的有线网络 30mins
* 内网也有 Xcode 的镜像，鉴于上次有人篡改 Xcode 并提供下载，最终选择了 App Store 下载
 
Xcode用法

* 开发、调试
* 快捷键：wiki中搜索

## 2. Xcode中查看Redis源码

### 2.1. 新建工程

具体操作：

Create a New Project

![](/images/redis/redis-source-code-review-xcode-create-project.png)

「OS X」--「Application」–「Command Line Tool」，填写必要信息，即可创建一个「Command Line Tool」工程

![](/images/redis/redis-source-code-review-xcode-clv.png)

![](/images/redis/redis-source-code-review-xcode-fill-project-name.png)

在上述工程下：「File」–「Add Files to...」– 参考下面截图

![](/images/redis/redis-source-code-review-xcode-select-files.png)

到此，即可在Xcode下查看Redis的源码了。

补充：

上述自己操作创建的Xcode 查看Redis3源码的工程，已经提交到Github上了：[Redis3-Xcode](https://github.com/ningg/Redis3-Xcode)

### 2.2. 阅读Redis 源码

源码阅读，几个问题：

* Redis 是单进程单线程的服务器，启动的入口方法在哪？
* ...

TODO：依照 [河狸家：Redis 源码的深度剖析] 的思路，反复过几遍代码。
 
参考资料：

* [如何阅读 Redis 源码？]

## 3. 熟练Xcode

熟练工具的使用，提升工作效率，愉悦心情

### 3.1. 编辑器风格

设置编辑器的风格：

* Preferences ---- Text Editing
	* Show Line numbers

### 3.2. 快捷键

Xcode下，常用快捷键：

* 页面显示
* 代码查看
* 代码编辑（todo）
* 运行调试（todo）

#### 3.2.1. 页面显示

 页面显示快捷键，列表如下：
 
|快捷键|说明|备注|
|---|---|---|
|`⌘ + ,`|	打开Preferences||	 
|`⌘ + shift + Y`|打开/关闭，控制台||
|`⌘ [+Alt] + Enter`|打开/关闭，辅助编辑窗口||
|`⌘ + 数字0`|	打开/关闭，左侧工程导航窗口||
|`⌘ + option + 数字0`|打开/关闭，右侧工具面板||
|`⌘ + 1，2，3, ...，8`|工程导航器快捷切换。从左向右依次对应1到8。|
|`option + 鼠标左键`|辅助编辑器中，打开文件||

#### 3.2.2. 代码查看

代码查看快捷键，列表如下：

|快捷键|说明|备注|
|---|---|---|
|`⌘ + shift + O`|查找文件、struct、func（代替你在导航中找文件，非常好用）|找到 func后，可以「Find Call Hierarchy」|
|`⌘ + shift + F`|整个工程中，所有文件一起检索||
|`⌘ + shift + J`|在项目导航中显示当前文件 (在大项目中尤其好用)||
|`⌘ + shift + ctrl + H`|	查找 func 的调用位||
|`ctrl + 6`|当前文件中，查找 func||
|`⌘ + L`|定位到文件的指定行||
|`ctrl + i`|对选中文字 重新格式化缩进||
|`ctrl + up`|文件顶端	||
|`ctrl + down`|文件底端||
|`⌘ + ctrl + ← / →`|返回「上一次/下一次」光标位置|也可以：「两指」在触摸板上左右滑动|
 
## 4. Xcode插件

### 4.1. 高亮插件

NOTE：**高亮插件，在 Xcode 7.1.1 下，不兼容**

完全按照 [SCXcodeMiniMap](https://github.com/stefanceriu/SCXcodeMiniMap) 进行安装，具体步骤如下：

安装 [Alcatraz](https://github.com/supermarin/Alcatraz)：

```
curl -fsSL https://raw.github.com/supermarin/Alcatraz/master/Scripts/install.sh | sh
```

重启 Xcode，在「Window」–「Package Manager」中搜索并安装 [SCXcodeMiniMap](https://github.com/stefanceriu/SCXcodeMiniMap) 。
 
## 5. 参考资料

* [http://www.cocoachina.com/special/xcode/](http://www.cocoachina.com/special/xcode/)
* [14个Xcode中常用的快捷键操作](http://www.cocoachina.com/ios/20141224/10752.html)
* [https://github.com/antirez/redis/issues/2009](https://github.com/antirez/redis/issues/2009)
* [Build Makefile Projects with Xcode](http://daozhao.goflytoday.com/2014/02/%E4%BD%BF%E7%94%A8xcode%E5%8E%BB%E5%BC%80%E5%8F%91makefile%E7%9A%84projectbuilding-makefile-projects-with-xcode/)





[NingG]:    http://ningg.github.com  "NingG"



[河狸家：Redis 源码的深度剖析]:			http://mp.weixin.qq.com/s?__biz=MjM5ODc5ODgyMw==&mid=211169817&idx=1&sn=d5d0f6b10961bae54e58c7593105e8dd&3rd=MzA3MDU4NTYzMw==&scene=6#rd
[如何阅读 Redis 源码？]:		http://blog.huangz.me/diary/2014/how-to-read-redis-source-code.html





