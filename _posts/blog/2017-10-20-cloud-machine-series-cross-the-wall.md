---
layout: post
title: 握手时代、触碰时代
description: 因为一些情况，导致生活环境跟事实的时代有些差异，握手时代，体会到时代的浪潮
published: true
category: 云主机
---


## 概要

`时代`是什么？事情的发生、基础设施的完善，都有时代的特征；

* 知道当代的事情、使用当代的基础设施，就**是**`当代的人`；
* 不知道当代的事情、无法使用当代的基础设施，就**不是**`当代的人`；

**弄潮儿**，是引领时代的人；这些人必能感知时代最新的事和基础设施。

`触碰时代`，是有代价的、有门槛的，不是谁都有意识、有条件、有能力触碰的。如果具备条件去触碰时代，就要行动起来去触碰时代，成为一个现代人，甚至成为弄潮儿。

说了这么多，就是因为 `THE WALL`，cross or not?

## 触碰时代

触碰时代，需要基础设施：

1. 服务器：中转请求
1. 客户端：包装请求，发送给服务端

### 服务器

在国内输入 `搬瓦工VPS` 能够查到优惠套餐和优惠码，到指定位置付费即可。（支持 *Alipay*）

细节不展开了：

* 官网：https://bwh1.net （*官网没有优惠套餐*）

最终选定了：

```
VPS technology: KVM/KiwiVM
OS: 32 or 64 bit Centos, Debian, Ubuntu
Instant OS reload
IPv4: 1 dedicated address
IPv6 support: **No**
Full root access
Instant RDNS update from control panel
```

在控制台（`Control Panel`）中，安装 SS Server，即可获得 SS 配置，建议修改 `SS Server port`，不要使用默认端口。

### 客户端

我有 2 个设备，都需要触碰时代：

* Macbook Pro
* iPhone

因此，需要找合适的 SS 客户端。

当前使用下述客户端：

* https://github.com/shadowsocks/shadowsocks
* SsrConnect：免费 for iOS client.


2 种代理模式：

* `自动代理模式`：PAC 代理模式
* `全局代理模式`


TODO: 考虑剖析一下 SS 的原理。

## 使用限制

### 系统代理 vs. Socks5 代理

上述 `ShadowsocksX` 客户端，开启 shadowsocks 后，自动开启了 `系统代理`。

系统代理

* shadowsocks 创建的 「系统代理」 将自动接管浏览器的访问 全部请求
* 浏览器默认不需要任何设置，也无需安装 代理插件 （Firefox 除外）
* 如果浏览器安装了代理插件，需要 禁用 代理插件或将代理插件设置为 使用系统代理

SOCKS5 代理

* 若不 【启用系统代理】 shadowsocks 成功连接代理服务器后，仅创建了 「SOCKS5 代理」
* 浏览器需要安装 代理插件 并设置 shadowsocks 创建的 SOCKS5 代理端口，才能科学上网


更多细节，参考：

* [shadowsocks on Mac OS X]
* [ShadowsocksX-NG 工作原理](https://fafe.me/2017/10/07/shadowsocksx-ng/)

### iterm2 命令终端

系统自带的终端或 iTerm 2 是不走 Socks5 的，因此，为了让 iTerm2 走「代理」，需要特殊的设置，一般 2 个途径：

1. 使用新版客户端 ShadowsocksX-NG：
	* 新版 ShadowsocksX-NG，有的版本，跟 Mac OSX 存在兼容性问题，需要注意
	* [shadowsocks可以用X-NG却用不了](https://github.com/shadowsocks/ShadowsocksX-NG/issues/174)
	* [Mac 10.13.6无法打开问题](https://github.com/shadowsocks/ShadowsocksX-NG/issues/879)
2. 借助工具，将 HTTP 代理，转换为 Socks5 代理：
	* [使用 shadowsocks 加速 Mac 自带终端或iTerm 2](https://tech.jandou.com/to-accelerate-the-terminal.html)

通过多次尝试，最终选定 [使用 shadowsocks 加速 Mac 自带终端或iTerm 2](https://tech.jandou.com/to-accelerate-the-terminal.html) 的方案，设定 iterm 的 http 代理。

进行的关键操作：

```
# 安装 privoxy
brew install privoxy

# 配置 HTTP 代理
vim /usr/local/etc/privoxy/config

# 上述 config 文件，末尾追加（下面配置的 1080 端口，是 Shadowsocks 默认配置的）
...
listen-address 0.0.0.0:8118
forward-socks5 / localhost:1080 .
...

# 查看启动状态
netstat -na | grep 8118

# 手动启动（不一定需要手动启动，根据上面查询结果判断）
/usr/local/sbin/privoxy /usr/local/etc/privoxy/config

```

一般需要进行 1 个自动操作：

```
# 开机自启动 privoxy
brew services start privoxy

```

终端里 privoxy 的使用，配置 privoxy 的代理 `快速开启` 和 `快速关闭` 的命令：

```
#  ~/.bash_profile 里加入开关函数
function proxy_off(){
    unset http_proxy
    unset https_proxy
    echo -e "已关闭代理"
}

function proxy_on() {
    export no_proxy="localhost,127.0.0.1,localaddress,.localdomain.com"
    export http_proxy="http://127.0.0.1:8118"
    export https_proxy=$http_proxy
    echo -e "已开启代理"
}

# 配置立即生效
source  ~/.bash_profile

# 开启代理
proxy_on

# 关闭代理
proxy_off

# 验证：是否走代理
curl ip.gs

Current IP / 当前 IP: 97.64.37.104
ISP / 运营商:  it7.net
City / 城市: Los Angeles California
Country / 国家: United States
```

## 附录

术语介绍：

* VPS(Virtual Private Server)：就是 VM ，虚拟主机。


> 【更新】：2023.01.15 使用了下面配置: 
> 
> *  [V2Ray搭建详细图文教程](https://github.com/233boy/v2ray/wiki/V2Ray%E6%90%AD%E5%BB%BA%E8%AF%A6%E7%BB%86%E5%9B%BE%E6%96%87%E6%95%99%E7%A8%8B)
> * [V2Ray一键安装脚本](https://github.com/233boy/v2ray/wiki/V2Ray%E4%B8%80%E9%94%AE%E5%AE%89%E8%A3%85%E8%84%9A%E6%9C%AC)
> 
> 
> [更新]： 2023.02.19
> 
> [https://github.com/v2fly/fhs-install-v2ray](https://github.com/v2fly/fhs-install-v2ray)
> 
> [https://github.com/v2fly/v2ray-examples](https://github.com/v2fly/v2ray-examples) 独立的配置
> 
> 
> [https://github.com/wulabing/Xray_onekey](https://github.com/wulabing/Xray_onekey)
> 
> 
> [更新]： 2024.01.04
> 
> 主机迁移之后，需要进行的工作：
> 
> 1.域名解析迁移：https://dns.console.aliyun.com/ ，域名解析到新的 ip
> 
> 2.本地主机上，ping 域名，看看是否可以查询到解析结果
> 
> 3.ssh 远程到新的主机上，查看 v2ray 进程细节

域名：ningg.top
主机记录：alidnscheck
记录值：fe368e6e121a48cdad34ffd18b4569ee


几个命令：

```
 systemctl enable v2ray
 
 systemctl start v2ray
 
 systemctl status v2ray
 
 // ssh 远程登录后，可以直接执行 v2ray 命令
 ssh user@ip -p port
 
 // 查看对应的 url 或者 qr 码
 v2ray
 
 ```
 
 安装文件的位置：
 
 ```
installed: /usr/local/bin/v2ray
installed: /usr/local/bin/v2ctl
installed: /usr/local/share/v2ray/geoip.dat
installed: /usr/local/share/v2ray/geosite.dat
installed: /usr/local/etc/v2ray/config.json
installed: /var/log/v2ray/
installed: /var/log/v2ray/access.log
installed: /var/log/v2ray/error.log
installed: /etc/systemd/system/v2ray.service
installed: /etc/systemd/system/v2ray@.service
```




## 参考资料

* [https://bwh1.net](https://bwh1.net)
* [PAC 代理模式](https://lvii.gitbooks.io/outman/content/ss.pac.mode.html)
* [shadowsocks on Mac OS X]
















[NingG]:    http://ningg.github.com  "NingG"

[shadowsocks on Mac OS X]: 		https://lvii.gitbooks.io/outman/content/ss.mac.html








