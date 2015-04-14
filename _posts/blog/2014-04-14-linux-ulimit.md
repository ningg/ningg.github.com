---
layout: post
title: Linux命令ulimit
description: 限定user、group所能使用系统资源的上限（CPU、内存、同时打开文件个数）
published: true
category: linux
---


##ulimit命令简介

通过`man ulimit`命令查询官方的简要解释如下：

> ulimit [-HSTabcdefilmnpqrstuvx [limit]]
   
Provides  control over the resources available to the shell and to processes started by it, on systems that allow such control.  The -H and -S options specify that the hard or soft limit is set for the given resource.  A hard limit cannot be increased by a non-root user once it is set; a soft limit may be increased up to the value of the  hard  limit.  If neither -H nor -S is specified, both the soft and hard limits are set.  The value of limit can be a number in the unit specified for the resource or one of the special values hard, soft, or unlimited, which stand for the current hard limit, the current soft limit, and no limit, respectively. If limit  is  omitted, the current value of the soft limit of the resource is printed, unless the -H option is given. When more than one resource is specified, the limit name and unit are printed before the value.  Other options are interpreted as follows:

* `-a` : All current limits are reported
* `-b` : The maximum socket buffer size
* `-c` : The maximum size of core files created
* `-d` : The maximum size of a process's data segment
* `-e` : The maximum scheduling priority ("nice")
* `-f` : The maximum size of files written by the shell and its children
* `-i` : The maximum number of pending signals
* `-l` : The maximum size that may be locked into memory
* `-m` : The maximum resident set size (many systems do not honor this limit)
* `-n` : The maximum number of open file descriptors (most systems do not allow this value to be set)
* `-p` : The pipe size in 512-byte blocks (this may not be set)
* `-q` : The maximum number of bytes in POSIX message queues
* `-r` : The maximum real-time scheduling priority
* `-s` : The maximum stack size
* `-t` : The maximum amount of cpu time in seconds
* `-u` : The maximum number of processes available to a single user
* `-v` : The maximum amount of virtual memory available to the shell
* `-x` : The maximum number of file locks
* `-T` : The maximum number of threads

If limit is given, it is the new value of the specified resource (the -a option is display only).  If no option is given, then -f is assumed.  Values are in  1024-byte increments,  except  for  -t, which is in seconds, -p, which is in units of 512-byte blocks, and -T, -b, -n, and -u, which are unscaled values.  The return status is 0 unless an invalid option or argument is supplied, or an error occurs while setting a new limit.

简要说明如下：

* 进行资源控制的对象？当前的shell以及其下启动的process；
* 什么时候生效？`ulimit -n 1024`设置之后，当前shell就生效了，重启即失效；


通过命令`ulimit -a`，即可查看当前shell及其下启动的process所允许占用资源的上限，例如：

	[dev@cib69 elasticsearch-1.4.4]$ ulimit -a
	core file size          (blocks, -c) 0
	data seg size           (kbytes, -d) unlimited
	scheduling priority             (-e) 0
	file size               (blocks, -f) unlimited
	pending signals                 (-i) 514940
	max locked memory       (kbytes, -l) 64
	max memory size         (kbytes, -m) unlimited
	open files                      (-n) 2048
	pipe size            (512 bytes, -p) 8
	POSIX message queues     (bytes, -q) 819200
	real-time priority              (-r) 0
	stack size              (kbytes, -s) 10240
	cpu time               (seconds, -t) unlimited
	max user processes              (-u) 1024
	virtual memory          (kbytes, -v) unlimited
	file locks                      (-x) unlimited


##limits.conf文件

上述使用`ulimit -n 1024`方式设置的参数，只对当前shell生效，重启之后失效，有没有永久生效的配置？有，文件`/etc/security/limits.conf`。文件的样例如下：

	# /etc/security/limits.conf
	#
	#Each line describes a limit for a user in the form:
	#
	#<domain>        <type>  <item>  <value>
	#
	#Where:
	#<domain> can be:
	#        - an user name
	#        - a group name, with @group syntax
	#        - the wildcard *, for default entry
	#        - the wildcard %, can be also used with %group syntax,
	#                 for maxlogin limit
	#
	#<type> can have the two values:
	#        - "soft" for enforcing the soft limits
	#        - "hard" for enforcing hard limits
	#
	#<item> can be one of the following:
	#        - core - limits the core file size (KB)
	#        - data - max data size (KB)
	#        - fsize - maximum filesize (KB)
	#        - memlock - max locked-in-memory address space (KB)
	#        - nofile - max number of open files
	#        - rss - max resident set size (KB)
	#        - stack - max stack size (KB)
	#        - cpu - max CPU time (MIN)
	#        - nproc - max number of processes
	#        - as - address space limit (KB)
	#        - maxlogins - max number of logins for this user
	#        - maxsyslogins - max number of logins on the system
	#        - priority - the priority to run user process with
	#        - locks - max number of file locks the user can hold
	#        - sigpending - max number of pending signals
	#        - msgqueue - max memory used by POSIX message queues (bytes)
	#        - nice - max nice priority allowed to raise to values: [-20, 19]
	#        - rtprio - max realtime priority
	#
	#<domain>      <type>  <item>         <value>
	#

	#*               soft    core            0
	#*               hard    rss             10000
	#@student        hard    nproc           20
	#@faculty        soft    nproc           20
	#@faculty        hard    nproc           50
	#ftp             hard    nproc           0
	#@student        -       maxlogins       4

	# End of file

举例，设置用户允许用户dev同时打开文件个数为64000，则，在`/etc/security/limits.conf`文件中添加如下配置即可：

	dev		soft	nofile	64000
	dev		hard	nofile	64000



##参考来源

* [修改linux最大打开文件数ulimit][修改linux最大打开文件数ulimit]
* Linux下`man ulimit`
* [通过 ulimit 改善系统性能][通过 ulimit 改善系统性能]





























[NingG]:    http://ningg.github.com  "NingG"
[修改linux最大打开文件数ulimit]:		http://it.yooxue.com/linux-zuidawenjianshu-ulimit/
[通过 ulimit 改善系统性能]:			http://www.ibm.com/developerworks/cn/linux/l-cn-ulimit/









