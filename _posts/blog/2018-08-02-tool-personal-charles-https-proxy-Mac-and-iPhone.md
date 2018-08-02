---
layout: post
title: 工具系列：Charles 抓取 https 请求（iPhone）
description: Charles 作为代理，配置 HTTPS 代理
category: tool 
---

## 1. 概要

> 目标：Charles 作为代理，抓取 https 请求.

## 2. Charles 抓取 https 请求

采用 Charles 抓取 https 请求，具体分为几个方面：

1. 基础设置：是抓取 https 请求之前的基本设置
	1. Mac 上，Charles 的安装
	1. Mac 上，Charles 的证书设置
1. 抓取 https 请求的配置：
	1. iPhone 上，配置网络代理
	1. iPhone 上，设置信任 Charles 证书
	1. Mac 上，设置需要 Charles 抓取的 https 的 url 域名

### 2.1. 基础配置

基础配置，就是抓取 https 请求之前的基本配置，具体包括：

1. Mac 上，Charles 的安装
1. Mac 上，Charles 的证书设置

#### 2.1.1. Mac 上，Charles 的安装

下载 Charles：

* 可以从 [https://www.charlesproxy.com/](https://www.charlesproxy.com/) 官网下载最新版本
* 也可以下载「本地备份」： charles-proxy-4.2.6.dmg （For Mac， 2018-07-10 最新下载）

Mac 下安装 Charles：

![](/images/tool-charles/install-charles.png)


安装成功后，打开 Charles：

![](/images/tool-charles/open-charles.png)


#### 2.1.2. Mac 上，Charles 的证书设置

本地安装 Charles 后，为了能够抓取 https 请求，需要在 Mac 上，「配置 Charles 的证书」：


![](/images/tool-charles/mac-charles-config-1.png)
 

在 Mac 上，验证「Charles 证书」是否已经生效：在 Mac 系统的「钥匙串」中，查看「登录」or「系统」or「系统根证书」，查看是否存在 Charles Proxy 的证书。

![](/images/tool-charles/mac-charles-config-2.png)

 

如果「钥匙串」存在 Charles 证书，则，打开「证书」，需要进一步「确认」证书「是否授信」，如果没有授信，则，需要进行授信，具体参考下图：


![](/images/tool-charles/mac-charles-config-3.png)
 

如果「钥匙串」不存在 Charles 证书， 则，需要将「上一步」中「导出」的「Charles 证书」，「导入」到「系统」or「登录」项，并进行「授信」，具体「导入证书」的操作，参考下图：

![](/images/tool-charles/mac-charles-config-4.png)


### 2.2. 抓取 https 请求的配置

抓取 https 请求的配置，具体几个方面：

1. iPhone 上，配置网络代理
1. iPhone 上，安装并设置信任 Charles 证书
1. Mac 上，设置需要 Charles 抓取的 https 的 url 域名

#### 2.2.1. iPhone 上，配置网络代理

在 iPhone 上，配置网络代理，具体步骤：

1. 选择已经连接的「无线网络」，配置「HTTP 代理」
1. 配置「代理」的 IP 和端口

![](/images/tool-charles/iphone-charles-config-1.png)
 

补充信息：

具体 Charles 的端口，可以通过「Proxy」–「Proxy Settings...」进行查看，细节，看下面截图：


![](/images/tool-charles/mac-charles-config-proxy-info.png)


![](/images/tool-charles/mac-charles-config-proxy-info-details.png)

 

 

#### 2.2.2. iPhone 上，安装并设置信任 Charles 证书

具体，在 iPhone 上，用「浏览器」打开： [www.charlesproxy.com/getssl/](www.charlesproxy.com/getssl/) 地址，即可进行「证书安装」：


![](/images/tool-charles/iphone-charles-config-2.png)
 

iPhone 上，安装 Charles 证书后，一定需要验证一下，具体验证方法：

* `设置` -> `通用` -> `关于本机` -> `证书信任设置`

![](/images/tool-charles/iphone-charles-config-3.png)


 

#### 2.2.3. Mac 上，设置需要 Charles 抓取的 https 的 url 域名

在 Mac 上，打开 Charles ，设置需要「抓取」的 HTTPS 域名：


![](/images/tool-charles/mac-charles-config-enable-ssl.png)


配置之后，即可通过 Charles 抓取并查看 https 请求的参数，参考下面截图：

![](/images/tool-charles/mac-charles-config-https-request-and-response-details.png)

## 3. 参考资料

* [https://www.jianshu.com/p/468e2905a3e1](https://www.jianshu.com/p/468e2905a3e1)
* [抓包工具Charles 注册码/破解方法](https://blog.csdn.net/txz_gray/article/details/58589072)
* [charles系列破解激活办法](https://blog.csdn.net/qq_25821067/article/details/79848589)






[NingG]:    http://ningg.github.com  "NingG"
