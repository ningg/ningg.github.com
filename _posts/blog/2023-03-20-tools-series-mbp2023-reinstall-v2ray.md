---
layout: post
title: mbp2023 m2 pro 重新安装 V2rayU
description: 换了新电脑 MacBookPro (m2 pro core), 重新安装 V2rayU 的注意事项
published: true
categories: 云主机 mbp tool
---


## 0.概要

**焦点**：换了 mbp23，是 m2 pro 芯片，有些软件已经无法使用了，因此，需要做些适配工作。


## 1.基础环境：安装 Rosetta

m2 pro 芯片，是基于 arm 架构的，不再是 Intel 的芯片，为了兼容之前 Intel 上的应用，需要安装 `Rosetta`.

在 Mac 自带的 `Terminal 命令终端`(暂时不要在 iterm 内执行)，直接执行下述命令：

```
// 查看 cpu 架构，最后带有 arm64
$uname -a 
Darwin MacBook-Pro 22.3.0 Darwin Kernel Version 22.3.0: Mon Jan 30 20:39:46 PST 2023; root:xnu-8792.81.3~2/RELEASE_ARM64_T6020 arm64

// 安装 Rosetta
$sudo /usr/sbin/softwareupdate --install-rosetta --agree-to-license

```

关联资料：

* [Installing Rosetta 2 on this system is not supported Macbook Pro M1 Macos Monterey](https://discussions.apple.com/thread/253296449)
* [If you need to install Rosetta on your Mac](https://support.apple.com/en-us/HT211861)
* [搭载 Apple 芯片的 Mac 电脑](https://support.apple.com/zh-cn/HT211814)


## 2.彻底卸载 v2rayU

大部分遇到的问题，都是因为 v2rayU 未彻底卸载引发的，因此需要先卸载一遍。

1. 退出应用，并卸载：v2rayU 应用
2. 删除本地文件，具体命令，参考下面

```
cd ~/Library/LaunchAgents/
/bin/launchctl remove yanue.v2rayu.v2ray-core
/bin/launchctl remove yanue.v2rayu.http

rm -f ~/Library/LaunchAgents/yanue.v2rayu.v2ray-core.plist
rm -f ~/Library/Preferences/net.yanue.V2rayU.plist
rm -f ~/Library/Logs/V2rayU.log

rm -fr ~/.V2rayU/
```


关联资料：

* [V2rayU彻底卸载方法 #697](https://github.com/yanue/V2rayU/issues/697)
* [彻底卸载](https://github.com/yanue/V2rayU/blob/master/README.md#%E5%BD%BB%E5%BA%95%E5%8D%B8%E8%BD%BD)



## 3.重新安装 v2rayU 的 arm64 版本安装包

下载最新的 [V2rayU-arm64.dmg](https://github.com/yanue/V2rayU/releases)，依赖拖拽进行安装。

安装结束后，可以 `应用列表` 中，查看简介内，是否已勾选 `使用 Rosetta 打开`，如果没有勾选，则，手动勾选一下。


关联资料：

* [关于Apple M1 芯片软件安装异常的解决方法](https://zhuanlan.zhihu.com/p/358957639)


