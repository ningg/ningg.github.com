---
layout: post
title: Redis 设计与实现：环境搭建手册
description: 熟悉一下，搭建 Redis 测试环境
published: true
category: redis
---

## 1. 来几台机器

美团云主机，绑定外网 IP 之后，即可使用：

```
// 登录美团云主机
ssh root@xxx
我的云主机配置：双核 4G 内存，Centos 7系统，系统详情：
// 查询发型版本
[root@guoning ~]# lsb_release -a
LSB Version:    :core-4.1-amd64:core-4.1-noarch:cxx-4.1-amd64:cxx-4.1-noarch:desktop-4.1-amd64:desktop-4.1-noarch:languages-4.1-amd64:languages-4.1-noarch:printing-4.1-amd64:printing-4.1-noarch
Distributor ID: CentOS
Description:    CentOS Linux release 7.0.1406 (Core)
Release:    7.0.1406
Codename:   Core
  
// 查询发型版本，另一种方式，更为通用
[redis@utopia software]$ cat /etc/*-release
CentOS Linux release 7.1.1503 (Core)
NAME="CentOS Linux"
VERSION="7 (Core)"
ID="centos"
ID_LIKE="rhel fedora"
VERSION_ID="7"
PRETTY_NAME="CentOS Linux 7 (Core)"
ANSI_COLOR="0;31"
CPE_NAME="cpe:/o:centos:centos:7"
HOME_URL="https://www.centos.org/"
BUG_REPORT_URL="https://bugs.centos.org/"
CENTOS_MANTISBT_PROJECT="CentOS-7"
CENTOS_MANTISBT_PROJECT_VERSION="7"
REDHAT_SUPPORT_PRODUCT="centos"
REDHAT_SUPPORT_PRODUCT_VERSION="7"
CentOS Linux release 7.1.1503 (Core)
CentOS Linux release 7.1.1503 (Core)
  
// 查询内核版本
[root@guoning ~]# uname -a
Linux guoning 3.10.0-123.el7.x86_64 #1 SMP Mon Jun 30 12:09:22 UTC 2014 x86_64 x86_64 x86_64 GNU/Linux
```

## 2. 基础环境

几点：

* 统一用户：新建用户 redis
* 统一目录：安装文件、数据、配置文件，统一目录存放
* 统一安装 Redis：统一 Redis 的版本

### 2.1. 统一用户：新建用户 redis

新建用户、开启权限：

```
// 新建用户
useradd redis
// 设置密码
passwd redis
// 开放 sudo 权限
visudo
// redis 用户，home 目录统一为：/home/redis
```

配置 SSH 免密码登录：

* 本质：将本地的公钥，上传到远端服务器的`~/.ssh/authorized_keys` 文件中。
* 示例代码如下：

```
// 上传公钥，配置免密码登录 （在 authorized_keys 后追加公钥）（有可能不需要执行 mkdir 命令）
cat ~/.ssh/id_rsa.pub | ssh redis@43.241.218.6 "mkdir -p ~/.ssh && cat >> ~/.ssh/authorized_keys"
  
// 上传公钥，配置免密码登录 （会覆盖 authorized_keys 中其他的公钥）
scp id_rsa.pub redis@43.241.218.6:/~/.ssh/authorized_keys
```

![](/images/redis/redis-installation-ssh.png)

上述上传公钥，配置免密码登录，更多细节参考：[http://askubuntu.com/questions/46424/adding-ssh-keys-to-authorized-keys](http://askubuntu.com/questions/46424/adding-ssh-keys-to-authorized-keys)

#### 2.1.1. 修改 .ssh 和 authorized_keys 权限

ssh 目录权限必须设置低点，不然 ssh 配置没用：

```
chmod 700 ~/.ssh
chmod 600 ~/.ssh/authorized_keys
```

更多细节参考：[http://www.openssh.com/faq.html#3.14](http://www.openssh.com/faq.html#3.14)

#### 2.1.2. SSH 客户端配置

为了方便，可以本地配置 SSH 客户端（详细信息参考：[设置 SSH 客户端的配置文件 - From：美团云](https://mos.meituan.com/library/10/how-to-use-ssh-client-connection-config-file/)）：

```
// 本地配置 SSH 客户端，新建文件 config
touch ~/.ssh/config
chmod 600 ~/.ssh/config
 
// config 文件中增加如下配置：
Host redis-1
    User redis
    Port 22
    HostName 43.2.218.6
  
// 完成上述配置之后，通过如下方式登录43.2.218.6服务器：
ssh redis-1
// 补充说明，下述方式，将覆盖掉上面配置的 User
ssh root@redis-1
```

此次涉及的集群中，每个节点，都使用如下的配置方式：

```
// config 文件中增加如下配置：
Host redis-1
    User redis
    Port 22
    HostName 43.2.218.6
Host redis-2
    User redis
    Port 22
    HostName 43.2.218.137
Host redis-3
    User redis
    Port 22
    HostName 43.2.218.205
 
Host redis-4
    User redis
    Port 22
    HostName 43.2.223.45
```

#### 2.1.3. 不同服务器之间 ，设置SSH 免密码登录

（todo）（有没有自动化的方式，特别是当有10台机器时，人工配置工作量指数级增长）

当前只设定 redis 用户在 Redis 集群内部双向免密码登录。

### 2.2. 统一目录

三类信息，安装文件、数据、配置文件，统一目录存放

* redis 用户的 home 目录：`/home/redis`
* 安装文件位置：`/home/redis/software`
	* Redis 源码文件：`redis-3.0.4.tar.gz`， 下载地址：[http://redis.io/download](http://redis.io/download)
* 安装位置：`/usr/local/bin`
* 数据文件位置：（参考下文的截图）
* 配置文件位置：（参考下文的截图）

### 2.3. 统一安装 Redis

实际上，有 puppet 类似工具来集中部署，这次涉及节点较少，暂时未启用 puppet。

```
[root@guoning ~]# yum search redis
perl-Redis.noarch : Perl binding for Redis database
python-redis.noarch : Python 2 interface to the Redis key-value store
syslog-ng-redis.x86_64 : redis support for syslog-ng
uwsgi-logger-redis.x86_64 : uWSGI - redislog logger plugin
uwsgi-router-redis.x86_64 : uWSGI - Plugin for Redis router support
redis.x86_64 : A persistent key-value database
 
[root@guoning ~]# yum info redis
已加载插件：changelog, fastestmirror
Loading mirror speeds from cached hostfile
可安装的软件包
名称 ：redis
架构 ：x86_64
版本 ：2.8.19
发布 ：2.el7
大小 ：419 k
源 ：epel/x86_64
简介 ： A persistent key-value database
网址 ：http://redis.io
协议 ： BSD
描述 ： Redis is an advanced key-value store. It is often referred to as a data
: structure server since keys can contain strings, hashes, lists, sets and
: sorted sets.
```

上面通过 yum 查到的 redis 为`2.8.19`版本。不过我想安装 `Redis 3.x`，OK，去 Redis 官网看看消息。

#### 2.3.1. 各个节点上安装 Redis3

CentOS 下源码方式安装 Redis3 的操作细节，参考：[http://ningg.top/redis-usage/][http://ningg.top/redis-usage/]

Redis 3 的配置概要：

![](/images/redis/redis-installation-redis-config-image.png)

查询启动、停止 redis 服务，命令如下：

```
// 查询 Redis 是否启动，返回 PONG 表示正在运行
$ redis-cli ping
PONG 
  
// 启动 Redis 服务
$ service redis_6379 start
```

#### 2.3.2. 配置 Redis 集群

上述只是配置了各个独立的 Redis 节点，这一部分将配置 Redis 集群。
分几步：

* 单服务器测试：
* 多服务器模拟真实环境

## 3. 启动Redis服务器

Redis有两种方式：

* 单机
* 集群

### 3.1. 单机

Redis 服务启动后，使用的配置文件？

* 启动 redis server 时，如果不指定 redis.conf 则，使用 默认配置
* 不同版本的 redis 的默认配置也不同：
	* [The self documented redis.conf for Redis 3.0](https://raw.githubusercontent.com/antirez/redis/3.0/redis.conf)
	* [The self documented redis.conf for Redis 2.8](https://raw.githubusercontent.com/antirez/redis/2.8/redis.conf)
* 如何查看正在运行的 redis 的配置？
	* 命令：`info`，查看启动 redis 时指定的配置文件
	* 然后对照 redis 版本，查看其默认配置文件

### 3.2. 集群

参考：todo

## 4. Redis 的配置文件

典型问题：

* Redis 服务器，可以配置哪些参数？
* Redis 的默认配置
	* 正在运行的 redis 服务器，如何查看其配置？
	* 正在运行的 redis 服务器，修改配置参数，是否一定要重启？

Re：

* Redis 的默认配置中，包含了 redis 的所有可配置参数
* 不同版本的 redis 的默认配置也不同：
	* [The self documented redis.conf for Redis 3.0](https://raw.githubusercontent.com/antirez/redis/3.0/redis.conf)
	* [The self documented redis.conf for Redis 2.8](https://raw.githubusercontent.com/antirez/redis/2.8/redis.conf)

运行过程中的 redis，通过如下方式，查看配置：

* 命令：info，查看启动 redis 时指定的配置文件
* 然后对照 redis 版本，查看其默认配置文件

运行过程中的 redis，可以使用如下方式，修改配置，而不用重启 redis 服务：

* 命令：`config set`、`config get`

NOTE：使用 `config set` 修改参数时，一定要同步修改 `redis.conf` 配置文件。详细内容：[http://redis.io/topics/config](http://redis.io/topics/config)

## 5. 源码环境搭建

环境：Mac
IDE：Xcode
源码来源：https://github.com/huangz1990/redis-3.0-annotated

使用Xcode查看 Redis 源码：（todo：使用Xcode 查看 Redis 源码 ）	 	 	 	 	 	 
 
## 7. 参考来源

* [设置 SSH 客户端的配置文件 - From：美团云](https://mos.meituan.com/library/10/how-to-use-ssh-client-connection-config-file/)







[NingG]:    http://ningg.github.com  "NingG"










