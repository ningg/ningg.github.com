---
layout: post
title: 工具系列：IntelliJ IDEA (Mac)
description: Mac 下，IntelliJ IDEA 的常用配置和快捷操作
category: tool 
---


## 1. 前期配置

### 1.1. 安装基本软件

在公司，使用 IDEA 之前，需要安装几个软件：

1. JDK 7
1. Maven
1. Git
1. IDEA

软件安装，基本步骤：

```
# 安装 JDK7
brew cask search java7
brew cask info java7
brew cask install java7
 
# 安装 Maven
brew search maven
brew info maven
brew install maven
 
# 安装 Git
brew search git
brew info git
brew install git
 
# 安装 IDEA
brew cask search idea
brew cask info intellij-idea
brew cask install intellij-idea
```

详细的安装步骤，参考：[个人的Mac配置](http://ningg.top/tool-personal-mac-configuration/)

### 1.2. 基本配置

#### 1.2.1. 配置 Maven

Maven需要配置一下公司私服地址，具体，将 `settings.xml` 文件，下载后放置到 「~/.m2/settings.xml」。

#### 1.2.2. 配置 IDEA

几点：

1. 获取注册码
1. 配置JDK
1. 配置Maven
1. 配置快捷键风格
1. 配置代码风格

##### 1.2.2.1. 获取 IDEA 注册码

官方购买，如果学习研究，可以从网上先找一个临时的。

##### 1.2.2.2. 配置JDK

在「IntelliJ IDEA」→ 「Preferences」中，设置 java 编译器级别：
 
![](/images/tool-idea/preference-jdk.png)

在「File」→ 「Project Structure」中，设置JDK 位置和版本：

![](/images/tool-idea/project-jdk.png)
 
检查 Module 的 Java 语言级别和 JDK 版本：

* 在「File」→ 「Project Structure」中，检查 Module 的 Java 语言级别和 JDK 版本：

![](/images/tool-idea/modules-source-jdk.png)


![](/images/tool-idea/modules-dependencies-jdk.png)

 
##### 1.2.2.3. 配置Maven

在「IntelliJ IDEA」→ 「Preferences」中，设置 Maven 版本。
 
##### 1.2.2.4. 快捷键风格

特别说明：本文所有的快捷键都是基于「Mac OS X 10.5+」的。
在「IntelliJ IDEA」→ 「Preferences」-「Keymap」

 
##### 1.2.2.5. 配置代码风格

NOTE：如非必要，这一部分可以先不配置

* 后台代码规范 Eclipse、IDEA（TODO）

### 1.3. 导入 Maven工程

直接 `Open` 打开 pom.xml 文件即可。

## 2. 基本过程

特别说明：本文所有的快捷键都是基于「Mac OS X 10.5+」的。

几点：

1. Open 一个工程，会自动检测：Maven 工程、Spring 工程；
1. 如何快速打开当前工程中的 README.md 文件？RE：cmd + shift + o
1. 如何最大化一个窗口？不同窗口的显示和隐藏？RE：cmd + shift + f12
1. 运行调试工程？对于Maven工程
	1. Edit Configurations.. （opt + ctrl + D）
	1. 添加Maven运行配置（cmd + N）
	1. 保存：点击 「OK」
	1. 运行：control + R，调试运行：control + D
1. 关闭当前小窗口：cmd + w
1. Page UP\Down，fn + up/down


Note：快捷键 cmd + shift + A，能够调出 Find Action 窗口，其中能够检索所有需要的命令，以及对应的快捷键。

几个关键词：

1. Navigate：检索整个空间的文件，常用几个：
	1. Back：上一次检索的位置，cmd + [ 
	1. Forward：下一次检索位置，cmd + ]
	1. File：检索所有文件，cmd + shift + O
	1. Tool Window：
	1. 隐藏，shift + esc，
	1. 显示，f12 （返回到最近一次的Tool Window）
1. Terminal窗口，option + f12，多次操作会有不同效果
	1. 显示/隐藏所有Tool Window，shift + cmd + f12 （类似最大化和还原）
	1. 最大化，shift + cmd + '
	1. 最小化，shift + esc
	1. 返回Edit窗口，esc

## 3. 窗口布局

几个窗口：

1. Edit
1. Tool Window

几个窗口之间聚焦的切换：

1. Edit --> Tool Window，f12，定位到最后一次的Tool Window
1. Tool Window --> Edit，esc

窗口的最大化、最小化、还原：

1. Edit：
	1. 最大化：shift + cmd + f12
	1. 还原：shift + cmd + f12
1. Tool Window：
	1. 最大化/还原：shift + cmd + '
	1. 最小化：shift + esc
	1. 还原：f12

下图中，注释说明了：tool bar、navigation bar、tool button、status bar，通过shift + cmd + a中搜索hide，可以控制这几项的显示：

![](/images/tool-idea/idea-view.png)

## 4. 常用快捷键

### 4.1. 显示快捷键

常用快捷键如下：
 
|快捷键|说明|
|---|---|
|cmd + ,|	显示 Preferences 窗口，可设置所有属性|
|cmd + ;|	项目配置（Project Structure）|
|cmd + b|	追踪代码，声明|
|cmd + option + b|	追踪代码，实现|
|cmd + [ \ ]|	上\下一次编辑|
|cmd + F12|	类方法列表 - outline|
|alt/option + F12|	显示Terminal tool window|
|cmd + L|	定位到指定行|
|cmd + shift + O|	所有文件，按照文件名查找|
|cmd + shift + F|	查找文件、文件中内容|
|cmd + shift + A|	查找所有操作，特别好用|
|cmd + E|	显示最新编辑的文件列表|
|cmd + 鼠标点击|	方法调用位置|
|cmd + opt + U|	类的继承关系（UML 图）|
|cmd + U	父类中对应的方法|
 
参考前面，两类窗口 Edit 和 Tool Window，相互之间的切换和显示。

### 4.2. 编辑代码

几点：

1. 代码自动补全
1. 上下行代码切换
1. 代码重构：方法抽取、类名统一重命名
 
|快捷键|说明|
|---|---|
|cmd + del|	删除行|
|cmd + x|	剪切行|
|cmd + d|	复制行，并粘贴|
|shift + option + up|	代码上移一行|
|shift + option + down|	代码下移一行|
 
代码重构：

|快捷键|说明|
|---|---|
|shift + F6|	重命名|
|cmd + F6|	重构方法的形参、返回值|
|cmd + option + L|	代码格式化|
|cmd + option + O|	优化 import 语句|

### 4.3. 版本管理

|快捷键|说明|
|---|---|
|alt/option + F12|	光标定位到 Terminal tool window，可以执行 `git add .` 命令|
|cmd + K|	弹出 git commit 提示框|
 
在 Terminal tool window 中执行命令：

```
git add .
```

然后执行快捷键：`cmd + K`， 来弹出 git commit 提示框。

 
### 4.4. 代码检查

Eclipse 下，会自动进行代码检查，IntelliJ IDEA 有没有呢？

IntelliJ IDEA，因为是收费软件，所以，功能只有想不到，没有 IDEA 做不到。

IntelliJ IDEA 下，执行代码检查的操作如下：

* 「Analyze」→ 「Inspect Code...」：检查所有代码，给出建议

快捷操作：
|快捷键|说明|
|---|----|
|cmd + shift + A| 查找所有操作|
 
在「cmd + shift + A」快捷键弹出的输入框中，输入：「Inspect Code」，直接选定操作，即可快速执行代码检查，效果如下：

![](/images/tool-idea/inspect-code-result.png)

## 5. 附录

### 5.1. 修改主题

在 Preferences 中，Apperance 下，修改:

1. 将Theme切换成＂Darcula＂
1. 同时为了避免中文乱码，把默认字体调整为＂DialogInput ＂，12号大小


### 5.2. 快捷键风格切换

在 Preference 中，Keymap 下，可以设置IDEA的快捷键风格：

1. 默认是：「Mac OS X 10.5+」
1. 对熟悉Eclipse的人员，可以修改为「Eclipse」（注：不推荐）

### 5.3. 快捷键小结

几个快捷键，值得一说：

f12：

* f12：返回最后一次tool window
* option + f12：显示Terminal tool window
* cmd + f12：类方法列表 - list
* shift + cmd + f12：Edit window的最大化和还原


几个十分常用的操作：

1. cmd + G：查找下一个
1. ctrl + opt + O：optimize import，调整import包
1. opt + cmd + L：reformat code，格式化代码
1. cmd + Del：删除当前行
1. shift + F6：重命名
1. cmd + F6：重构方法名称和输入参数；change signature
1. F6：移动代码，静态属性或者私有方法
1. ctrl + T：所有重构的命令
1. shift + click：关闭当前文件
1. cmd + shift + *：列编辑模式，光标同时定位多行


### 5.4. 调整代码展示

> 勤于思考，小步迭代 -> 整体革新

调整代码展示样式：

* 选中变量的背景颜色： https://blog.csdn.net/lxzpp/article/details/81081162
  * `Settings` -> `Editor` -> `Color Schema` -> `General`
  * 内部的 `Code` -> `Identifier under caret` 和 `Identifier under caret(write)`  

























[NingG]:    http://ningg.github.com  "NingG"
