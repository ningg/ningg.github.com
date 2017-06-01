---
layout: post
title: 工具系列：Charles 配置 https 代理
description: Charles 作为代理，配置 HTTPS 代理
category: tool 
---



## 1. 背景

有一些网站，需要通过 https 才能访问，如何利用 Charles 进行域名映射，将 https 的远端服务映射至其他的 https/http 服务呢？

## 2. Charles 配置 https 代理


Charles 配置 https 代理的整体步骤：

1. Mac 配置：
	1. Mac 上启动 Charles
	1. Charles 中启动 SSL 代理，并配置域名的映射关系
1. 手机配置：
	1. 手机配置网络代理
	1. 为 Charles代理添加 https 访问证书

### 2.1. 步骤 A：Mac 上启动 Charles

![](/images/tool-charles/charles-1.png)

### 2.2. 步骤 B：手机配置网络代理

![](/images/tool-charles/charles-2.png)

Note：上面配置的「服务器」和「端口」，以启动 Charles 的 Mac 机器为准。

### 2.3. 步骤 C：手机安装 Charles 的 https 证书

手机浏览器访问地址： www.charlesproxy.com/getssl/ ，会自动下载 SSL 证书，在手机上安装此证书。
### 2.4. 步骤 D： Charles 上开启 https 代理，并配置指定 https 域名映射的目标域名

#### 2.4.1. a. Charles 上，开启指定域名的 https 代理权限

![](/images/tool-charles/charles-3.png)

![](/images/tool-charles/charles-4.png)

![](/images/tool-charles/charles-5.png)


#### 2.4.2. b. Charles 上，添加域名映射规则

![](/images/tool-charles/charles-6.png)

![](/images/tool-charles/charles-7.png)














[NingG]:    http://ningg.github.com  "NingG"
