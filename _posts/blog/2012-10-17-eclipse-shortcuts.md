---
layout: post
title: Eclipse的快捷键
description: Eclipse是Java项目过程中，广泛使用的集成开发环境，其下有很多快捷操作
category: tool
---

##背景

查看源码、项目开发，效率不高，是脑袋不行？很有可能，但另一方面，对于开发工具的熟练使用能够提升效率，节省出的敲键盘时间，可以用于思考。

##Eclipse快捷键

###设置快捷键

`Windowns`--`Preferences`--`General`--`Keys`，其中，可以为不同的操作绑定快捷键。

###常用快捷键

__代码查看__

源代码上查看方法引用位置、类间继承关系的快捷键（操作）。
自己用得最上手的几个快捷键（操作）列举如下：

|快捷操作|说明|
|:--|:--|
|`F3`|查找method、class出处（不如下面的方法常用）|
|`ctrl + 鼠标点击（左击）`|最直接的查找method、class出处的方法（比上面的方法更常用和有效）|
|`alt + ←(left)`|返回上一次鼠标位置，举例，如同一个人在雪地里踩脚印，想回到上一个脚印的位置，就是这个快捷键|
|`alt + →(right)`|与`alt + ←`相反 |
|`ctrl + shift + r/R`|根据名称匹配，查找当前工作区源代码文件|
|选中“class”，右键“reference”—“Hierarchy”|查找，哪个类继承了此类（不如下面方法常用）|
|`F4`|查看类的继承关系（被谁继承），并且在Type Hierarch窗口中显示（比上面方法跟有效）|
|选中“class”， 然后 `ctrl + T`|显示当前类的继承关系|
|`ctrl + alt + h/H`|查看当前方法\变量被调用的位置|
|`ctrl + h`|搜索某个字符串在整个工程中出现的位置|
|`ctrl + shift + L`|显示快捷键窗口 |
|`ctrl + M`|最大化当前窗口|
|`ctrl + w`|关闭当前源代码窗口|
|`ctrl + shift + w`|关闭所有打开的源代码窗口|
|`alt + 1`|显示Eclipse下的错误或警告信息，以及Eclipse给出的备选解决方案|
|`ctrl + shift + e`|切换Edit窗口|
|`F12`|光标定位Edit窗口|
|`ctrl + F6`|切换Edit窗口|
|`ctrl + L`|光标定位到指定行|




__代码编辑__

|快捷操作|说明|
|:--|:--|
|`ctrl + N`|创建class\package\folder\project|
|`ctrl + /`|注释（取消注释），当前行|
|`ctrl + shift + / `|注释，选中的多行；（注释xml文件中内容）|
|`ctrl + shift + \ `|取消注释，选中的多行|
|`ctrl + d`|删除当前行|
|`alt + up/down`|上下行代码之间互换位置|
|`ctrl + alt + up/down`|复制本行代码，并粘贴在上行、或者下行|
|`ctrl + shift + O`|自动添加、去除import包|
|`Alt + /`|自动代码提示（很方便，极其常用），个人常将其修改为`shift + space`，修改办法参考上一部分：**设置快捷键**|
|`F11`|debug方式执行当前代码|
|`ctrl + F11`|执行当前代码（只用一个main时，自动执行；当有多个main存在时，提示选择main） |
|`alt + shift + t`|显示重构的提示栏|
|`alt + shift + r`|类、成员变量、成员方法的重命名|
|`alt + shift + m`|将多行代码抽取为独立的方法|
|`alt + shift + a`|多行编辑模式，再按取消|

补充说明：经常`右键`，可以查看到很多操作及相应的快捷键。

Eclipse中几个窗口的功能：

* __outline__: 简要显示当前class中的attribute、method
* __search__: 选中“class”，右键“reference”—“Hierarchy”查找，哪个类继承了此类时，结果显示在此窗口中。
* __console__: 输出结果、出错、警告等信息
* __problem__: 编译前，警告、出错等信息的提示，可以在其中quick fix出现的错误；
* __Type Hierarchy__: 显示当前类的继承关系（包括父类、子类）；注意此窗口中有几个按钮很重要。
* __packet Explorer__: 查看当前源代码的组织结构


[NingG]:    http://ningg.github.com  "NingG"
