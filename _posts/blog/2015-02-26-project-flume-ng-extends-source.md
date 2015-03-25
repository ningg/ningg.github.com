---
layout: post
title: 工程Flume NG extends source辅助记录
description: 工程开发细节
categories: open-source git flume
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


###git出现错误

错误信息，如下：

	error: Your local changes to the following files would be overwritten by merge:
			README.md
	Please, commit your changes or stash them before you can merge.

分析：上述错误信息表示，从本地文件已经修改过了，但没有提交，如果强行从git服务器下载此文件，则文件内容将被覆盖；建议先提交本地文件改动的地方，或者直接放弃本地修改的内容。

解决办法：

####方法一：希望保存本地改动的文件，但不想与git服务器上版本合并（merge）

操作如下：

	git stash
	git pull
	git stash pop
	git diff -w +文件名		// 查看文件的合并情况


####方法二：放弃本地修改的内容，直接放弃本地文件

操作如下：

	git reset --hard
	git pull


详细参考：[Git冲突常见解决办法][Git冲突常见解决办法]
	
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


如何创建`.gitignore`文件，因为，在WIN环境下，OS一直提示"必须键入文件名"。
	* 直接执行命令`touch .gitignore`即可。

对于Eclipse创建的Maven工程，直接在`.gitignore`文件中，添加如下内容：

	# Eclipse
	.classpath
	.project
	.settings/
	# Maven
	target/


**疑问**：如何设置下一级目录中的.gitignore？

可以将 `.gitignore` 文件放置到工作树（working tree）下的其他目录，这将对当前目录以及子目录生效。










**参考**：[Git ignores and Maven targets][Git ignores and Maven targets]





###Eclipse下进行source的format

几点：

* 如何定制source的format？
* 如何快捷进行source的format？


###Eclipse下创建的java文件，自动添加头部注释信息

（todo）



###maven导出jar包

背景：当前自己都是eclipse的`Export`--`Jar file`/`Runnable Jar file`，如何利用maven直接生成jar包？

命令：`maven clean package`



###maven打包时，指定源文件编码方式



###maven打包时，如何将当前jar包以及其依赖包都导出？


参考[thilinamb flume kafka sink][https://github.com/thilinamb/flume-ng-kafka-sink]




##编程相关


###判断参数是否输入有误

（TODO：专门学习一下）

用到`guava-11.0.2.jar`包，示例代码如下：

	...
	Preconditions.checkState(spoolDirectory != null, "Configuration must specify a spooling directory");
	...
	Preconditions.checkNotNull(spoolDirectory);

###判断对象是否为null

（TODO：专门学习一下）

用到`guava-11.0.2.jar`包，示例代码如下：

	...
	private Optional<FileInfo> currentFile = Optional.absent();
	...

**思考**：使用上述`Optional<T>`有什么好处？



###过滤文件

利用java.io.FileFilter，示例代码如下：

	FileFilter filter = new FileFilter() {
      public boolean accept(File candidate) {
        String fileName = candidate.getName();
        if ((candidate.isDirectory()) ||
            (fileName.endsWith(completedSuffix)) ||
            (fileName.startsWith(".")) ||
            ignorePattern.matcher(fileName).matches()) {
          return false;
        }
        return true;
      }
    };
	List<File> candidateFiles = Arrays.asList(spoolDirectory.listFiles(filter));

















##参考来源

* [Git ignores and Maven targets][Git ignores and Maven targets]
* [A .gitignore file for Intellij and Eclipse with Maven][A .gitignore file for Intellij and Eclipse with Maven]
* [Git冲突常见解决办法][Git冲突常见解决办法]











[NingG]:    http://ningg.github.com  "NingG"



[Git ignores and Maven targets]:							http://stackoverflow.com/questions/991801/git-ignores-and-maven-targets
[A .gitignore file for Intellij and Eclipse with Maven]:	http://gary-rowe.com/agilestack/2012/10/12/a-gitignore-file-for-intellij-and-eclipse-with-maven/
[Git冲突常见解决办法]:										http://blog.csdn.net/iefreer/article/details/7679631





