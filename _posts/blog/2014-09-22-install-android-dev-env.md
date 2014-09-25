---
layout: post
title: 搭建Android开发环境
description: 做开发，不是盲目的，有一个要做的目标（产品），然后准备技术；敲定了技术方案之后，第一步就是搭建开发环境
category: android
---

##背景

哈哈，这个背景说不说呢？说，坦坦荡荡的：想做一个对Android手机的截屏图片，直接打马赛克的小APP，当前满足这一需求的APP有不少，例如：美图秀秀等，但是不好意思，我想要一个轻量级的，而且最简单的打码操作。

##搭建开发环境

打码APP，目标确定了，就开发搞起。*（具体功能是什么？技术方案定了吗？别急，这些我现在都不会、都不确定，个人估计折腾折腾就清晰的，我对这个还是有信心的）*

> **特别提醒**：下面是我看官网的操作记录，请那些还有丁点技术追求的coder，也去看官网，我写blog不是为了布道，而且blog的精准、严谨程度，与官网差得太远。

###下载软件

图省事，我从官网直接下载了”Eclipse ADT bundle”，详细版本信息：”adt-bundle-windows-x86_64-20140702.zip”，其下载地址如下：[https://dl.google.com/android/adt/adt-bundle-windows-x86_64-20140702.zip](https://dl.google.com/android/adt/adt-bundle-windows-x86_64-20140702.zip) 。由于GFW的存在，很多地方无法直接下载上面链接文件，怎么办？用迅雷，复制上面的链接，新建一个迅雷下载任务，妥了，下载完毕。


Eclipse ADT Bundle包含3个部分：

1.	Android SDK
2.	Eclipse IDE
3.	ADT(Android Developer Tools)：Eclipse下进行Android开发的插件；

客官，留意一下：上面Eclipse ADT Bundle对应的解压包中，自带了Android开发的文档，具体路径：`%ECLIPSE_ADT_BUNDLE%/sdk/docs/`，这个极其有用，我有问题，都会偷偷看这个。

###安装package

上面Eclipse ADT Bundle对应的解压包中eclipse直接可以使用了，不过很多时候，需要安装写package，来支持Android的开发。通常，通过Android SDK Manager来安装package，截个图如下：

![Android SDK Manager](/images/install-android-dev-env/sdk-manager.jpg)


安装package，本来挺简单个事，由于GFW的存在，唉，上面的package基本无法下载，或者极其慢，解决办法：修改hosts文件，在其中添加片段：

	#Google主页
	203.208.46.146 www.google.com
	#这行是为了方便打开Android开发官网 现在好像不VPN也可以打开
	#74.125.113.121 developer.android.com
	#更新的内容从以下地址下载
	203.208.46.146 dl.google.com
	203.208.46.146 dl-ssl.google.com
	****************************************

参考来源：[http://www.cnblogs.com/tc310/archive/2012/12/21/2828450.html](http://www.cnblogs.com/tc310/archive/2012/12/21/2828450.html)

##推荐书籍

* [第一行代码——Android](http://book.douban.com/subject/25942191/)
	* 这个入门不错，对于有开发经验的人员也可以借鉴一下



[NingG]:    http://ningg.github.com  "NingG"
