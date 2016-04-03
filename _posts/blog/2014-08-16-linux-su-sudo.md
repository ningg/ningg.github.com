---
layout: post
title: Linux下su和sudo进行身份变换
description: Linux下，如果一直使用root身份来操作，是很危险的，应该：只在必要的时候才切换root权限，而且root密码只有管理员一人知道才合理
category: Linux
---

## 背景## 

最近，一些普通用户要在服务器上，安装软件，不时遇到权限问题，因此，只好将root密码献了出去；太多人知道root密码是件很危险的事，特别是，有的人习惯使用root权限登录，这中情况下，很有可能误操作，删除系统文件；有没有其他办法来避免这个问题呢？

说几个典型场景：

**场景A**：用户 `UserA` 输入命令 `find / -name "hello"`，结果提示: 

	find: /etc/cups/ssl: Permission denied


操作服务器时，不同用户之间的权限差异，概括几点：

* 是否有权限，读（r）、写（w）、执行（x），文件 `FileA` ；
* 是否有权限，执行命令`commandA`；实质上，命令`commandA`对应了某个可执行的文件`commandA-File`，有权限执行命令`commandA`等价于具有文件`commandA-File`的执行（x）权限；
* 用户`UserA`，找不到命令`commandA`，说明，没有将命令`commandA`添加到用户`UserA`的环境变量`PATH`中；

之前介绍的Linux ACL（Access Control List，访问控制列表），已经实现了对文件`rwx`权限的控制，因此，问题基本解决。

Linux下，进行身份变换这一功能，有必要吗？公认的原因有几个：

* 使用一般帐号：系统日常维护的好习惯。仅当需要设定系统环境时，才变换为root身份，来进行系统管理；
* 使用较低权限启动系统服务。例如，额外建立一个用户起名：apache，并以此来启动apache软件，这样如果apache程序被攻破了，系统还不至于被摧毁；
* 软件本身的限制：有些远程连接程序（例如ssh），可设置为仅允许非root用户登录；

基于上述考虑，通常使用一般帐号登录，在必要的时候，切换成root身份。问题来了：如何使一般用户转换为root用户呢？主要方式有两种：

* `su - root`命令，直接切换为root用户：
	* 需要输入root密码来确认；
* `sudo CMD`命令，利用root身份执行命令`CMD`：
	* 需要事先设定普通用户具备sudo的权限；
	* 在进行sudo操作时，需要输入普通用户自己的密码；

## su命令## 

使用`man su`来查看命令使用方法：

	NAME
		   su - run a shell with substitute user and group IDs

	SYNOPSIS
		   su [OPTION]... [-] [USER [ARG]...]

	DESCRIPTION
		   Change  the  effective  user  id  and group id to that of
		   USER.

		   -, -l, --login
				  make the shell a login shell

		   -c, --command=COMMAND
				  pass a single COMMAND to the shell with -c

		   --session-command=COMMAND
				  pass a single COMMAND to the shell with -c and  do
				  not create a new session

		   -f, --fast
				  pass -f to the shell (for csh or tcsh)

		   -m, --preserve-environment
				  do not reset environment variables

		   -p     same as -m

		   -s, --shell=SHELL
				  run SHELL if /etc/shells allows it

		   --help display this help and exit

		   --version
				  output version information and exit

		   A mere - implies -l.   If USER not given, assume root.


**特别说明**：命令`su - root`与`su root`命令差异很大：

* `su - root`：使用login shell方式登录；
* `su root`：使用non-login shell方式登录；

（疑问：login shell 和 non-login shell之间有什么差异？）

（说明：non-login shell方式登录，很多环境变量无法读取到，需要使用绝度路径的方式来执行）

命令`su - root`需要root密码，因此不方便多用户之间的使用；有没有既能够以root身份来执行命令，同时也不需要root密码的方式？有，sudo命令，就是干这个的。

## sudo命令## 

使用`man sudo`来查看命令详情：

	NAME
		   sudo, sudoedit - execute a command as another user

	SYNOPSIS
		   sudo -h | -K | -k | -L | -V

		   sudo -v [-AknS] [-g group name|#gid] [-p prompt]
		   [-u user name|#uid] [command]

		   sudo -l[l] [-AknS] [-g group name|#gid] [-p prompt]
		   [-U user name] [-u user name|#uid] [command]

		   sudo [-AbEHnPS] [-C fd] [-g group name|#gid] [-p prompt]
		   [-r role] [-t type] [-u user name|#uid] [VAR=value]
		   [-i | -s] [command]

		   sudoedit [-AnS] [-C fd] [-g group name|#gid] [-p prompt]
		   [-u user name|#uid] file ...

	DESCRIPTION
		   sudo allows a permitted user to execute a command as the
		   superuser or another user, as specified in the sudoers
		   file.  The real and effective uid and gid are set to
		   match those of the target user as specified in the passwd
		   file and the group vector is initialized based on the
		   group file (unless the -P option was specified).  If the
		   invoking user is root or if the target user is the same
		   as the invoking user, no password is required.
		   
		   Otherwise, sudo requires that users authenticate
		   themselves with a password by default (NOTE: in the
		   default configuration this is the user’s password, not
		   the root password).  Once a user has been authenticated,
		   a time stamp is updated and the user may then use sudo
		   without a password for a short period of time (5 minutes
		   unless overridden in sudoers).

		   When invoked as sudoedit, the -e option (described
		   below), is implied.

		   sudo determines who is an authorized user by consulting
		   the file /etc/sudoers.  By running sudo with the -v
		   option, a user can update the time stamp without running
		   a command.  If a password is required, sudo will exit if
		   the user’s password is not entered within a configurable
		   time limit.  The default password prompt timeout is 5
		   minutes.

		   If a user who is not listed in the sudoers file tries to
		   run a command via sudo, mail is sent to the proper
		   authorities, as defined at configure time or in the
		   sudoers file (defaults to root).  Note that the mail will
		   not be sent if an unauthorized user tries to run sudo
		   with the -l or -v option.  This allows users to determine
		   for themselves whether or not they are allowed to use
		   sudo.

		   If sudo is run by root and the SUDO_USER environment
		   variable is set, sudo will use this value to determine
		   who the actual user is.  This can be used by a user to
		   log commands through sudo even when a root shell has been
		   invoked.  It also allows the -e option to remain useful
		   even when being run via a sudo-run script or program.
		   Note however, that the sudoers lookup is still done for
		   root, not the user specified by SUDO_USER.

		   sudo can log both successful and unsuccessful attempts
		   (as well as errors) to syslog(3), a log file, or both.
		   By default sudo will log via syslog(3) but this is
		   changeable at configure time or via the sudoers file.

sudo命令，注意事项：

1. 默认，只有root能使用`sudo`命令；
2. 基本用法：`sudo -u [username] [command]`；
3. 没有指定`-u [username]`选项时，默认`-u root`；
4. root执行sudo时，不需要输入密码；
5. `sudo -u [username] [command]`中当前用户即为`username`时，也不需要输入密码；（即，自己切换为自己身份时，不需要输入密码）

sudo执行流程：

1. 用户执行sudo时，系统于/etc/sudoers文件中，查找用户是否有执行sudo的权限；
2. 若具有执行sudo的权限，则让用户输入自己密码来确认执行；
3. 密码正确，则执行命令；

用户是否具有sudo执行权限，依据是/etc/sudoers文件，因此，为某一用户开通sudo权限，本质就是修改/etc/sudoers文件，直接使用vim来编辑，有可能会破坏文件的规范，推荐使用命令`visudo`来修改这一文件。

## visudo命令## 

### 场景A：单个用户拥有root所有命令### 

（分析：拥有root的所有命令？命令难道不是添加到PATH环境变量中就可以了吗？不是的，命令添加到PATH变量中，也是需要用户有这个命令的执行`x`权限的。）

如果希望dev用户使用root的所有命令，那么可以进行如下修改：

	[root@localhost ~]# visudo
	...
	## Allow root to run any commands anywhere
	root    ALL=(ALL)       ALL
	# 新增的一行
	dev		ALL=(ALL)       ALL
	...

下面对新增行的格式进行简要说明：

	用户      用户登录来源主机名=(可切换的身份)	可执行的命令
	root                     ALL=(ALL)	       	ALL

上面四个组件含义进行简要说明：

1. 用户：这个用户可以使用sudo命令，默认为root用户；
2. 用户登录来源主机：设定允许用户通过哪些主机登录过来；
3. 可切换的身份：可以切换为什么身份来执行命令，默认root可以切换为任何用户；
4. 可执行的命令：务必使用绝对路径；
5. ALL关键词：代表任何身份、主机、命令；

现在dev用户就可以执行sudo命令了，按照下面操作试一试：

	[dev@localhost /]$ head -n 1 /etc/shadow
	head: cannot open '/etc/shadow' for reading: Permission denied
	[dev@localhost /]$ sudo head -n 1 /etc/shadow
	[sudo] password for devp:
	root:$6$2t1NiW.e$SM0:16296:0:99999:7:::

授予sudo命令的执行权限之前，需调查用户的人品，除非必要，一概不授予普通用户sudo权限。上述设置中，dev用户相当于拥有了整个系统的所有权限，通过`sudo visudo`命令，用户`dev`也能够像`root`用户一样设定所有用户的sudo权限，欧，这也太危险了。


### 场景B：群组的sudo权限及免密码功能### 

如果希望`group=dev`内的所有成员都具有sudo命令权限，则进行如下设置：

	[root@localhost ~]# visudo
	...
	## Allows people in group wheel to run all commands
    # %wheel        ALL=(ALL)       ALL
	# 新增的一行
    %dev   ALL=(ALL)       ALL
	...
	
通过上述设置，`group=dev`内成员都具有了sudo权限命令，今后赋予新的成员sudo权限时，只需要将其加入`dev`组内即可，而不必每次都修改`/etc/sudoers`文件。补充：如何设置用户免密码使用sudo权限？OK，请看如下操作：

	[root@localhost ~]# visudo
	...
	## Same thing without a password
	# %wheel        ALL=(ALL)       NOPASSWD: ALL
	...

### 场景C：命令受限的sudo权限### 

前面两个场景中，普通用户获得了与root相当的权限，甚至普通用户反过来能修改root的密码（使用命令：`sudo -u root passwd`），这是篡权啊，想想就害怕。然而，害怕并不能解决问题，一些情况下，又必须给普通用户sudo权限，好了，能不能只给用户受限制的sudo权限呢？

下面以添加用户dev，使其辅助root修改其他用户的密码：

	[root@localhost ~]# visudo
	...
	## 为`dev`用户添加权限，使其辅助root修改其他用户密码
	dev        ALL=(root)       /usr/bin/passwd [A-Za-Z]*,!/usr/bin/passwd,!/usr/bin/passwd root
	...

几点说明：

* 通过sudo授权用户可执行的命令`/usr/bin/passwd`等，要使用绝对路径；
* 多个授权命令之间，使用逗号`,`分割；
* 在命令前添加感叹号`!`，表示禁止执行此命令；

### 场景D：visudo用别名简化配置### 

针对这个情况，举个例子，就清晰了：

	User_Alias ADMPW = pro1,pro2
	Cmnd_Alias ADMPWCMD = !/usr/bin/passwd, \
			/usr/bin/passwd [A-Za-z]*, !/usr/bin/passwd root

	ADMPW ALL=(root) ADMPWCOM

实际场景中如果忘记了这个例子，没有关系的，只需要`visudo`命令，就能看到文件`/etc/sudoers`中注释部分的提示了。

### sudo命令密码有效时长### 

如果第一次执行sudo命令，则需要输入用户密码，但短时间内T，再次使用sudo命令时，并不需要输入密码。因为系统相信短时间T内，你不会离开服务器，所以再次执行sudo命令，是同一个人。

（如何设置sudo命令密码的有效时长？）

### sudo搭配su的使用方式### 

很多时候，我们需要大量的执行很多root的工作，所以，一直使用sudo觉得很烦！那有没有方法使用sudo搭配su，一口气身份转换为root，并且还用用户自己的密码来编程root呢？是有的，而且方法简单的会让你想笑！具体如下：

	[root@www ~]visudo
	...
	User_Alias ADMINS =pro1,pro2,pro3
	ADMINS ALL=(root) /bin/su -
	...
	
接下来，上述pro1、pro2、pro3共计3个用户，只需要输入`sudo su -`命令，并且输入自己的密码后，立即转换为root身份了！但root密码不会外流。

**特别说明**：所有sudo用户，都是经过人格调查后，服务器管理员绝对信任的用户，否则，禁掉这一用户的sudo权限。


## 参考来源## 

* 《[鸟哥的Linux私房菜 基础版（第三版）--Chapter 14]()》


[NingG]:    http://ningg.github.com		"NingG"



