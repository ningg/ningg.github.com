---
layout: post
title: Android入门几个基本知识
description: 入门去了解一个领域，概念/术语很重要，本文将描述一下Android的几个基本概念
category: android
---

## 背景

最近参加某活动，也算掌握了点滴的内容，整理一下，算是阶段的笔记。


## Android的4个模块

Android开发中涉及4个模块/对象：

1. Activity；
2. Service；
3. Broadcast Receiver；
4. Content Provider；

### Activity

通常是用户界面，粒度也可能更细些，例如：菜单列表、图片、图片标题，都可能是一个单独的Activity；

### Service

没有用户界面，但会一直在后台运行，例如：进行其他操作时，播放背景音乐、后台下载数据；

### Broadcast Receiver

应用程序利用Broadcast Receiver机制，来接收、发送广播消息，举例：

1. 接收/拨打电话；
2. 接收/发送短信；
3. 手机所处时区改变时，应用程序会接收到通知；
4. 电池电量不足；
5. 用户选择一张图片；

### Content Provider

应用程序利用Content Provider机制，来进行数据共享，例如：读取系统电话簿中联系人；


## Activity的生命周期

生命周期？对，这个术语在计算机相关的开发中，总能听到，到底什么意思？干什么的？生命周期，`lifecycle`，其基本目标是：描述清楚一个对象从产生到消亡的过程，为开发者干预这一过程提供方法。*（用个通俗的术语来重新表述一下Object lifecycle：物体的状态变化路径）*

### 返回站（Back Stack）

说Activity的生命周期之前，补充一个概念：返回栈；为了方便管理Activity，将多个相互关联的Activity合并称作一个Task，一个Task对应一个Back Stack。如下图：

![](/images/android-lesson-one/diagram_backstack.png)

关于返回栈，简要说明几点（官方文档）：

1. A `task` is a collection of activities that users interact with when performing a certain job.
2. the back stack operates as a `last in, first out` object structure.
3. pushed onto the stack when started by the current activity and popped off when the user leaves it using the Back button.

### Activity状态

Activity从产生到消亡，会有几个典型的状态，简要说一下（来自官方文档）：

* 运行状态：栈顶，显示Activity；
* 暂停状态：不处于栈顶，但部分可见；
* 停止状态：不处于栈顶，也全部不可见；
* 销毁状态：返回栈中，已经移除；

### Acitivity lifecycle

Activity生命周期如下：

![activity_lifecycle.png](/images/android-lesson-one/activity_lifecycle.png)

备注：可利用上面7个回调方法，来调整Activity。


## Intent简介

Intent是不同组件之间进行交互的重要方式，基本点两个：

* 指明当前组件要执行的动作；
* 不同组件之间传递的数据；

Intent能够携带数据，具体用途有：

* 启动Activity；
* 启动Service；
* 发送广播；

Intent分为2类：

* 显式Intent：举例，Intent直接指定下一步启动的Activity；
* 隐式Intent；举例，通过Activity的`<activity><intent-filter>`来隐式指定，某个Activity来捕获哪一类的Intent；

## Android测试相关

之前，我对测试不感兴趣的，但最近感觉，开发中前期，对系统弄一个测试框架，能够提升开发、调试的效率，同时，也能在产品最终上线前进行较为全面的验证。

### 测试点

测试，到底要测哪些方面？

* 功能测试
	* 安装/卸载
	* 具体功能点
	* 联网（默认的联网方式：wifi or sim卡？网络切换是否有相应提示？飞行模式）
	* 程序进入输入功能时，是否正常弹出键盘？键盘是否遮挡应用需要输入内容的对话框？
	* home键与应用之间，多次切换
	* 返回上一级操作，退出程序后的提示
	* 当离开应用一段事件后，再次回到应用程序时，不能丢失用户数据；
	* 横屏、竖屏切换时，不能丢失用户数据；
	* 长按某一按钮，是否会触发其他事件；
	* PC端与APP端的数据同步（例如，bloger在PC端设置禁止他人评论，则，APP上也应禁止评论）
	* APP中内嵌的链接，程序如何处理？如果调用设备的浏览器，能否正常切回到APP？
	* 各个页面间，多次切换
* 性能测试
	* APP的整体响应速度；
	* 连续点击相同按钮（游戏类APP）
	* 快速划屏（游戏类APP）
	* 长时间使用应用
	* 当应用不处于活动状态时，不能大量消耗系统资源
	* 耗电情况
	* 运行过程中，需要产看内存和CPU的使用情况：`adb shell top`
* 异常测试
	* 低电量情况下使用应用
	* （处理以下情况时，应用不能崩溃，并且返回应用后，数据不能丢失）
	* 使用应用时，对来电的处理
	* 使用应用时，对短信的处理
	* 使用应用时，闹铃响起
	* 使用应用时，锁屏、解锁
	* 网络异常：使用应用时，断网；断网情况下，启动应用 
* UI测试
* 不同系统语言的支持
* 适配测试
	* 目标：测试不同厂家、型号的手机上，APP的运行效果；
	* 背景：由于手机型号、总类繁多，通常只关注当前用户数较多的手机
	* 问题1：如何找出用户较多的具体手机型号？
	* RE问题1：选几个纬度，屏幕尺寸、分辨率、Android系统版本，正交定位一下

### Android Testing Framework

下面会列出一张图（官网拿的），简要说几点：*（可能理解有错，会陆续更正）*

* `Mock Objects`：模拟系统的一切行为；另，支持依赖注入；
* JUnit：写单元测试；（白盒测试）
* Instrumentation：可以模拟系统行为，捕获Activity的任何一个回调方法；


![test_framework.png](/images/android-lesson-one/test_framework.png)

基于这一测试框架，能够进行如下几个测试：

* 单元测试；
* 框架测试；（什么意思？）
* UI测试；


备注：在官网文档中，`Develop`--`Tools`部分，针对`Tests`有详细介绍。


### 测试工具

列几个常用测试工具，以及简要的说明：

* monkey：产生伪随机事件流，用途：压力测试、随机点击；
* monkey runner：利用python脚本，进行自动化测试，可以测试安装/卸载、截图、业务使用流程；
* Hierarchy Viewer：可视化方式，显示UI树，用途：调试、优化，用户界面；另，可以放大界面；
* DDMS（Dalvik Debug Monitor Service）：Eclipse下的一个视图，用途：模拟设备的地理位置变动；
* traceview：跟踪程序性能，并且具体到method；*（`Debug.startMethodtrace(FILE)`启动跟踪）*




## 附录

### 几个名词

* 回归测试：修改代码之后，重新测试。
* AVD：Android Virtual Devices，模拟器
* SDK：Software Development Kit，软件开发平台
* ADT；Android Development Tools，Eclipse下Android开发时用到的插件
* ADB：Android Debug Bridge，调试桥


### 产品设计几点

* 允许用户登录情况下，使用app的大部分通用功能；
* 当且仅当用户要使用一些核心功能时，强制用户注册、登录；


## 参考来源

* [Android官方开发者网站](http://developer.android.com/index.html)
* [Android官方文档](http://developer.android.com/develop/index.html)


[NingG]:    http://ningg.github.com  "NingG"
