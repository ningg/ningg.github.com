---
layout: post
title: 工程Flume NG extends source辅助记录
description: 工程开发细节
category: open-source
---










##常见问题





###github上创建工程，克隆到本地


在github上创建 new repository：flume-ng-extends-source之后，在本地执行git clone命令，即可：

	git clone https://github.com/ningg/flume-ng-extends-source.git


###将本地内容，提交到远端git repository中

几个命令：

	git add --all .
	git commit -m "create maven project"
	git push origin master
	
**思考**：上述命令：git push origin master 中`origin`和`master`是什么含义？
	
	
###在指定目录创建maven工程
	
在Eclipse下，Ctrl + N 创建 Maven Project时，选择：

* Create a simple project(skip archetype selection)
* Location：E:\flume-ng-extends-source

这样，才能使最终生成的maven project以`E:\flume-ng-extends-source`为根目录；在这中间遇到一个问题，当不选定`Create a simple project`时，创建的maven project始终`E:\flume-ng-extends-source`为根目录。


###git下设置.gitignore

对于java编写的maven projcet，使用git进行管理时，需要设置`.gitignore`，几点：

* `.gitignore`是什么？
* 利用git管理maven project时，哪些文件需要设置为`gitignore`？
* 如何设置git的`.gitignore`？


**解决办法**：对于Eclipse创建的Maven工程，直接在`.gitignore`文件中，添加如下内容：

	# Eclipse
	.classpath
	.project
	.settings/
	# Maven
	target/


**参考**：

* [Git ignores and Maven targets][Git ignores and Maven targets]






##参考来源

* [Git ignores and Maven targets][Git ignores and Maven targets]
* [A .gitignore file for Intellij and Eclipse with Maven][A .gitignore file for Intellij and Eclipse with Maven]












[NingG]:    http://ningg.github.com  "NingG"



[Git ignores and Maven targets]:							http://stackoverflow.com/questions/991801/git-ignores-and-maven-targets
[A .gitignore file for Intellij and Eclipse with Maven]:	http://gary-rowe.com/agilestack/2012/10/12/a-gitignore-file-for-intellij-and-eclipse-with-maven/




