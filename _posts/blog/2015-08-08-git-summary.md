---
layout: post
title: Git梳理
description: 版本控制的基本原理是什么？实用操作？团队协作？
published: true
category: Git
---

## 关于版本控制说几句


版本控制，最简单的含义：写一个版本的内容，提交，再写一个版本，再提交，突然想重新查看某个版本，通过版本号直接查看即可。整体来说：

* 版本号：标识不同版本
* 版本库：存放多个版本的信息，能够新增版本、查看旧版本
* 工作空间：通常用于向版本库添加新版本、从版本库获取旧版本

版本库有两个作用：版本控制、团队协作

## Git版本控制原理


Git，就是进行版本控制的，因此，至少应包含2个结构：

* 版本库（空间）：存放各个版本的信息；
* 工作空间：当前能够查看、编辑文件的位置，通常一个目录，目录下的所有文件/文件夹，都会被纳入版本库进行版本控制；

实际上，Git包含了3个空间：

* 版本库空间：HEAD指向最后一次提交的结果
* 暂存区（Stage/Index）：为什么要有这个空间？
* 工作区（Working Dir）：


由于Git是分布式的版本控制，因此，时间上是4个空间：

* 远端版本库
* 本地版本库
* 暂存区
* 工作区


为实现团队协作，Git进行分布式版本控制时，引入了“分支（Branch）”，即，不同的人从同一个分支上，创建各自独立的分支，在各个分支上进行版本控制，并在适当的时候，合并分支。官方的说法：一个分支进行一个特性的开发，不同的分支可以并行开发不同的特性，在分别调试之后，最后进行合并。


梳理一下逻辑，到目前为止，几个基本问题：

* 怎么创建一个版本库？git init
* 怎么标识一个本地版本库？
* 怎么标识一个分支？
* 怎么标识一个远端版本库？git remote add origin <server>
* 怎么标识一个远端分支？



### 实用操作

关于Git在本地版本库空间、暂存空间、开发空间之间，相互提交文件、回滚文件的操作命令，参考：[Git work cmd]，是一张插入。







## Git 团队协作原理


主要围绕分支来进行，不同的功能，在不同的分支上进行开发，实现开发功能的隔离，避免相互干扰。整体上，分支有本地分支、远程分支，针对每个分支又有：创建分支、切换分支、删除分支、查询分支；在本地分支与远程分支之间，又有：以远程分支内容更新本地分支，将本地分支内容更新到远程分支上。梳理一下：

* 本地分支：
	* 创建分支：
		* git init，初始化新仓库
		* git branch feature_x start-point，在start-point上创建新的分支，不切换到新分支上；
		* git checkout -b feature_x start-point，创建feature_x分支，并且，自动切换到新分支
	* 切换分支：
		* git checkout branchname
	* 删除分支：
		* git branch -d branchname
		* git branch -D branchname
	* 查询分支：
		* git branch
		* git branch --list
	* 合并分支：
		* git merge anotherbranch，将其他分支中内容合并到当前分支
* 远端分支：
	* 创建分支：
	* 切换分支：
	* 删除分支：
		* git branch -r -d branchname
		* git branch -d -r origin/todo origin/html，会删除远端分支上内容吗？
	* 查询分支：
		* git branch -r
		* git branch -a(显示所有分支)
* 本地分支与远端分支之间：
	* 获取远端分支内容
	* 提交本地分支内容




## Git 实践


### 1. 基本配置

常用配置信息：

	# 配置用户信息：
	$ git config --global user.name "John Doe"
	$ git config --global user.email johndoe@example.com
	
	# 配置文本编辑器
	$ git config --global core.editor vim
	
	# 查看配置信息
	$ git config --list
	
	# 查看单个配置信息
	$ git config user.name

如果用了 --global 选项，那么更改的配置文件就是位于你用户主目录下的那个，以后你所有的项目都会默认使用这里配置的用户信息。如果要在某个特定的项目中使用其他名字或者邮箱，只要去掉 --global 选项重新配置即可，新的设定保存在当前项目的 .git/config 文件里。

### 2. 查看帮助文档

想了解 Git 的各式工具该怎么用，可以阅读它们的使用帮助，方法有三：

	$ git help <verb>
	$ git <verb> --help
	$ man git-<verb>




## 疑问：汇总

几点：

* git clone、git fetch、git pull、git push、git merge之间的关系
* git merge、git push origin master、git pull origin master之间的关系
* git remote、git remote add
* 


一个 branch 对应的upstream是什么？有什么作用？如何设置？如何删除？如何修改？




疑问：如何查看不同的提交版本？如何比对不同提交版本之间的差异？














## 参考来源

* [git - 简明指南]
* [图解Git]
* [Git work cmd]
* [Git 社区参考书]












[git - 简明指南]:			http://rogerdudler.github.io/git-guide/index.zh.html
[图解Git]:					http://marklodato.github.io/visual-git-guide/index-zh-cn.html
[Git work cmd]:				https://www.lucidchart.com/documents/view/a53dfe33-3535-469c-a363-b9d49e78eeb6
[Git 社区参考书]:				http://git-scm.com/book/zh/v1







[NingG]:    http://ningg.github.com  "NingG"










