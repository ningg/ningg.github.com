---
layout: post
title: Vim编辑器常用操作
description: vim是Linux下自带的编辑器，熟练使用，能够节省不少时间
categories: vim
---

面向实际应用场景，进行梳理：

## 常见场景

（todo：弄清楚vim的信息源，例如，官网、帮助手册上，如何快速定位下述场景的问题）


### 修改配色

两个地方配置，可修改vim的配色：

* `/etc/vimrc`：影响所有用户；
* `~/.vimrc`文件，如果文件`~/.vimrc`不存在，则，直接新建即可；


遇到的问题：当前默认vim编辑文档时，文档内容没有显示区分颜色，并且设置`syntax on`显示颜色之后，文档的注释基本看不清楚，那如何对注释内容的颜色进行调整？
在`~/.vimrc`文件中添加如下命令，即可实现，vim编辑器的高亮显示，以及修改配色：

	syntax on
	hi comment ctermfg=gray
	
**特别说明**：上述配置，也可以在vim的`:`模式下输入。（vim有几种模式？如何进行切换？）

在修改文件配置过程中，涉及到的几个缩写的含义：

* `hi`：highlight；
* `cterm`：command terminal；
* `fg`：foreground；

上面理解可能有误，需要参考[Vim Tutorial From Official website][Vim Tutorial From Official website] 进行校验。


### 高亮检查结果

在`~/.vimrc`中进行如下设置：

	" 设置搜索结果的高亮显示
	set hlsearch
	



### 批量注释


在块选择模式下，进行批量注释和注释的取消；

#### 批量注释

* `ctrl + v` 进入块选择模式；
* 移动光标，选择要注释的行；
* 大写 `I` ，在一行中输入`#`；
* 按`ESC`，之后再进入`:`，则，完成批量注释；


#### 取消注释

* `ctrl + v` 进入块选择模式；
* 移动光标，选择多行的行首；
* 敲击`x`，删除选定的字符；
* OK，打完收工；



### 调用`:`下的历史命令


（TODO:具体没查询）


* `q:`，显示历史命令;
* 在命令行下（`:`模式），`Ctrl + f`即可查看历史命令；
* 在历史命令中，与vim模式下完全相同，可以编辑和选择，然后在调整之后的行上，直接回车即可；
* 在命令行下（`:`模式），先输入几个字符，直接按`up/down`即可实现对历史命令的查询；



## 快捷键

（TODO：参考鸟哥私房菜）

大概几点：

* 文档搜索、替换；
* 光标移动；（按word、按行）
* 多文档编辑；



### 光标快速移动

几种方式：

* w
* W
* b
* B

### 内容快速查找

* `#`：查找到的内容，高亮显示
* `*`：查找到的内容，高亮显示
* `v`进入可视模式，同时复制希望查找的内容，在`/`窗口中`ctrl+r`，然后输入`0`，即可粘贴刚刚复制的内容

**备注**：如何获取vim下的复制、粘贴内容：

**RE**：`:register` 即可查看，同时，”0、”1、”2、”3、”4等等代表之前复制的记录；



### 替换

替换动作：vim中，`:%s/from/to/g`，替换整个文档中的from字符串为to字符串；


**TODO**：参考 Vdisk.weibo.com/github/vim-editor下内容。



## 参考来源


* [Using Vim Syntax Highlighting][Using Vim Syntax Highlighting]
* [Vim Documentation][Vim Documentation]
* [Vim Tutorial From Official website][Vim Tutorial From Official website] （TODO）
* [Vim实现批量注释的方法][Vim实现批量注释的方法]
* [Vim下查看历史命令][Vim下查看历史命令]
* [Vim实用命令行][Vim实用命令行]




**备注**：鸟哥中有对vim进行深入介绍（todo）











[NingG]:    									http://ningg.github.com  "NingG"
[Using Vim Syntax Highlighting]:				http://www.sbf5.com/~cduan/technical/vi/vi-4.shtml
[Vim Documentation]:							http://www.vim.org/docs.php
[Vim Tutorial From Official website]:			/download/vim-editor		"on Vdisk.weibo.com/github/vim-editor"
[Vim实现批量注释的方法]:						http://be-evil.org/vim-how-to-comment-multi-line-code.html
[Vim下查看历史命令]:							http://www.douban.com/group/topic/7502081/
[Vim实用命令行]:								http://www.haodaima.net/art/2774935




