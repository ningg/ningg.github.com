---
layout: post
title: CentOS 6.x 运行环境配置
description: 运行环境
published: true
category: linux
---

## 环境概要

执行下述命令，查看 OS 基本信息：

```
[guoning@guoning ~]$ uname -a
Linux guoning.cloud.mos 2.6.32-431.1.2.0.1.el6.x86_64 #1 SMP Fri Dec 13 13:06:13 UTC 2013 x86_64 x86_64 x86_64 GNU/Linux

[guoning@guoning ~]$ lsb_release -a
LSB Version:	:base-4.0-amd64:base-4.0-noarch:core-4.0-amd64:core-4.0-noarch:graphics-4.0-amd64:graphics-4.0-noarch:printing-4.0-amd64:printing-4.0-noarch
Distributor ID:	CentOS
Description:	CentOS release 6.5 (Final)
Release:	6.5
Codename:	Final

```


## 配置环境


### JDK

查看当前系统的 jdk 版本：

```
[guoning@guoning ~]$ java --version
-bash: java: command not found

```

欧，竟然没有安装 JDK。执行下面命令，查看可以获取的 JDK 版本：

```
[guoning@guoning ~]$ yum search jdk
Loaded plugins: changelog, fastestmirror
Loading mirror speeds from cached hostfile
============================================================================================= N/S Matched: jdk =============================================================================================
copy-jdk-configs.noarch : JDKs configuration files copier
java-1.6.0-openjdk.x86_64 : OpenJDK Runtime Environment
java-1.6.0-openjdk-demo.x86_64 : OpenJDK Demos
java-1.6.0-openjdk-devel.x86_64 : OpenJDK Development Environment
java-1.6.0-openjdk-javadoc.x86_64 : OpenJDK API Documentation
java-1.6.0-openjdk-src.x86_64 : OpenJDK Source Bundle
java-1.7.0-openjdk.x86_64 : OpenJDK Runtime Environment
java-1.7.0-openjdk-demo.x86_64 : OpenJDK Demos
java-1.7.0-openjdk-devel.x86_64 : OpenJDK Development Environment
java-1.7.0-openjdk-javadoc.noarch : OpenJDK API Documentation
java-1.7.0-openjdk-src.x86_64 : OpenJDK Source Bundle
java-1.8.0-openjdk.x86_64 : OpenJDK Runtime Environment
java-1.8.0-openjdk-debug.x86_64 : OpenJDK Runtime Environment with full debug on
java-1.8.0-openjdk-demo.x86_64 : OpenJDK Demos
java-1.8.0-openjdk-demo-debug.x86_64 : OpenJDK Demos with full debug on
java-1.8.0-openjdk-devel.x86_64 : OpenJDK Development Environment
java-1.8.0-openjdk-devel-debug.x86_64 : OpenJDK Development Environment with full debug on
java-1.8.0-openjdk-headless.x86_64 : OpenJDK Runtime Environment
java-1.8.0-openjdk-headless-debug.x86_64 : OpenJDK Runtime Environment with full debug on
java-1.8.0-openjdk-javadoc.noarch : OpenJDK API Documentation
java-1.8.0-openjdk-javadoc-debug.noarch : OpenJDK API Documentation for packages with debug on
java-1.8.0-openjdk-src.x86_64 : OpenJDK Source Bundle
java-1.8.0-openjdk-src-debug.x86_64 : OpenJDK Source Bundle for packages with debug on
ldapjdk-javadoc.x86_64 : Javadoc for ldapjdk
icedtea-web.x86_64 : Additional Java components for OpenJDK - Java browser plug-in and Web Start implementation
ldapjdk.x86_64 : The Mozilla LDAP Java SDK

  Name and summary matches only, use "search all" for everything.

```

竟然没有 Oracle 的 JDK。 进入[Oracle JDK 7]，寻找最新的JDK地址，在以下代码中url替换最新的jdk地址。：

```
# 需要后缀参数：AuthParam
[guoning@guoning ~]$ wget http://download.oracle.com/otn-pub/java/jdk/7u79-b15/jdk-7u79-linux-x64.rpm?AuthParam=1469274764_7d8c2b160beccaecc9bdad622dac35cd

# 安装到本地
[guoning@guoning ~]$ sudo yum install jdk-7u79-linux-x64.rpm

# 检查 JDK 安装效果：
[guoning@guoning ~]$ java -version
java version "1.7.0_79"
Java(TM) SE Runtime Environment (build 1.7.0_79-b15)
Java HotSpot(TM) 64-Bit Server VM (build 24.79-b02, mixed mode)

```


### MySQL

#### 安装 MySQL

添加 Yum 仓库:

```

--------------- On RHEL/CentOS 6 ---------------
wget http://dev.mysql.com/get/mysql57-community-release-el6-7.noarch.rpm
# 如果是其他版本的CentOS，可以去MySQL官网找对应的仓库url

yum localinstall mysql57-community-release-el6-7.noarch.rpm
```

检查仓库是否添加成功

```
yum repolist enabled | grep "mysql.*-community.*"
```

安装 MySQL 的命令：

```
yum install mysql-community-server
  
# 上面的命令默认会安装最新版的MySQL，其他版本的MySQL，可配置 MySQL Yum仓库的子仓库：
# yum-config-manager --disable mysql57-community
# yum-config-manager --enable mysql56-community
```

#### 启动，设置密码

修改 my.cnf 文件：

```
...
[mysqld]

# 新增配置：
skip-grant-tables
...
```

重启 MySQL ：

```
service mysqld restart
连接 MySQL，修改密码：

mysql> update mysql.user set authentication_string=PASSWORD('rootROOT') where User='root';
mysql> flush privileges;
```

修改 my.cnf 文件中，MySQL 的启动配置：

```
[mysqld]
 
# 去除配置：
# skip-grant-tables
 
# 新增配置：
validate_password=OFF
```

重启 MySQL ：

```
service mysqld restart
```

重新连接 MySQL：

```
[root@guoning ~]# mysql -uroot -p
Enter password:
Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.
mysql>
mysql> show databases;
ERROR 1820 (HY000): You must reset your password using ALTER USER statement before executing this statement.
mysql> SET PASSWORD = PASSWORD('****');
```


### Maven

思考：设置 repo 后，通过 yum 命令来安装所需的软件。

[Maven 官网]，下载 maven 安装包：

```
# 下载安装包
$ wget http://mirrors.tuna.tsinghua.edu.cn/apache/maven/maven-3/3.3.9/binaries/apache-maven-3.3.9-bin.tar.gz

# 解压
$ tar -zxvf apache-maven-3.3.9-bin.tar.gz


# 移动到指定位置，集中存放
$ mv apache-maven-3.3.9 /usr

```

`/etc/profile` 文件中，修改环境变量：

```
# 文件末尾
# 用户安装的软件
MAVEN_HOME=/usr/apache-maven-3.3.9
export PATH=${MAVEN_HOME}/bin:${PATH}
```




































[NingG]:    http://ningg.github.com  "NingG"

[Oracle JDK 7]: 		http://www.oracle.com/technetwork/java/javase/downloads/jdk7-downloads-1880260.html
[Maven 官网]:			http://maven.apache.org/








