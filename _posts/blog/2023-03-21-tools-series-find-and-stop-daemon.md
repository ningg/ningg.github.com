---
layout: post
title: 后台进程，查询、关闭
description: mac 和 linux 下，有一些软件卸载不干净，需要手动清理.
published: true
categories: mbp tool linux
---

## 0.概要

**背景**：有时候安装软件出错，无法彻底卸载，查看仍有遗留进程，并且 kill 掉之后会自动重启。

**焦点**：关闭 daemon 进城。

适用的环境： mac、linux




## 1.查询进程

```
// 查询进程
ps aux | grep xxxx


// 查询启动项
sudo launchctl list | grep xxxx


// 深度查询启动项
sudo find /Library/LaunchDaemons /Library/LaunchAgents ~/Library/LaunchAgents -name "*.plist" | grep gate
sudo find / -name "*.plist" | grep gate

```

sudo launchctl stop com.e.xxxxgate.surf


## 2.修改服务的配置文件

重上一步骤中，找到具体 plist 位置：


```
/Library/LaunchDaemons/com.e.xxxxgate.daemon.plist
/System/Volumes/Data/Users/mmm/.xxxxgate/TSurf/com.e.xxxxgate.surf.plist
/Users/mmm/.xxxxgate/TSurf/com.e.xxxxgate.surf.plist

/Library/Application Support/yyyygate/NetworkAuditAuth/com.xm.network.audit.plist
/Library/Application Support/yyyygate/usec/com.xm.agent.usec.plist

```

编辑配置文件：


```
cat  /Library/LaunchDaemons/com.e.xxxxgate.daemon.plist

sudo vim /Library/LaunchDaemons/com.e.xxxxgate.daemon.plist


// 下面两项，都改为 false
<key>KeepAlive</key>
<key>RunAtLoad</key>
```

## 3.生效配置文件

```
sudo launchctl unload /Library/LaunchDaemons/com.e.xxxxgate.daemon.plist
sudo launchctl load /Library/LaunchDaemons/com.e.xxxxgate.daemon.plist

sudo launchctl unload "/Library/Application Support/yyyygate/NetworkAuditAuth/com.network.audit.plist"
sudo launchctl unload "/Library/Application Support/yyyygate/usec/com.agent.usec.plist"
```

## 4.关闭服务

```
sudo launchctl stop com.e.xxxxgate.daemon
```