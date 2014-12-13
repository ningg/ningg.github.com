---
layout: post
title: Batch file 入门
description: 之前写过一段shell脚本（bash），那是在linux下用的，而在win下，则需要写batch文件
category: windows
---

##背景

最近做某个环境在win下的适配，需要一个bat脚本，基本作用：就是一条命令，需要包含输入参数，通常输入参数是写死在命令中的，现在希望能够将这些参数单独提取出来。

##变量

	@echo on
	set var1=hello
	set var2=world
	echo %var1% %var2% !
	PAUSE

执行之后，显示结果：

	C:\Documents and Settings\adm\2014-11-23>set var1=hello

	C:\Documents and Settings\adm\2014-11-23>set var2=world

	C:\Documents and Settings\adm\2014-11-23>echo hello world !
	hello world !

	C:\Documents and Settings\adm\2014-11-23>PAUSE
	请按任意键继续. . .

修改`@echo off`，再次运行，结果如下：

	hello world !
	请按任意键继续. . .

几点注意：

* `set var1=hello!`其中`=`前后不能有` `(空格)；


##注释

如何在bat脚本中添加注释呢？两种方式：

* `::`(双冒号)；*（推荐）*
* `rem`；



##脚本输入参数

参考[command line parmas][pass command line parmas to a batch file]，通过如下命令，输入参数：

	::SCRIPT: test-command.bat
	echo off
	fake-command /u %1 /p %2
	
然后，运行命令：`test-command admin password`，则，具体执行的命令：

	fake-command /u admin /p password


实际上，还有一种输入方式：交互式输入，具体参考：[prompt for user input(interact)][prompt for user input]




##附录


###命令行中调用bat脚本

	call script.bat


###获取指定目录

获取运行bat脚本的目录：

	echo %CD%

获取bat脚本所在目录的parent目录，具体参考[batch parent folder][get windowss batch parent folder]：
	
	setlocal
	for %%i in ("%~dp0..") do set "folder=%%~fi"
	echo %folder%
	

##参考来源

* [batch guide][batch guide]





[NingG]:    								http://ningg.github.com  "NingG"
[batch guide]:								http://www.infionline.net/~wtnewton/batch/batguide.html
[get windowss batch parent folder]:			http://stackoverflow.com/questions/16623780/how-to-get-windows-batchs-parent-folder
[pass command line parmas to a batch file]:	http://stackoverflow.com/questions/26551/how-to-pass-command-line-parameters-to-a-batch-file
[prompt for user input]:					http://stackoverflow.com/questions/1223721/in-windows-cmd-how-do-i-prompt-for-user-input-and-use-the-result-in-another-com


