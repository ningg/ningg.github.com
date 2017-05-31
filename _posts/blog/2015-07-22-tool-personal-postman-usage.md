---
layout: post
title: 工具系列：postman 快捷操作
description: 发送 http 请求，共享 http 请求
category: tool 
---

## 1. 背景

postman 用于构造、发送 HTTP 请求。

目标：

1. 高效的使用 postman
1. 共享 postman 的配置

## 2. 安装

postman 官网（https://www.getpostman.com/），下载、安装即可。

> Note：使用 Chrome 浏览器时，建议使用 Chrome 扩展程序，地址： [chrome://extensions/](chrome://extensions/)

注册 postman 账号，好处：

1. 不同账号之间，分享 postman 的文件夹
1. 同一账号，多设备间共享文件夹

postman 和 chrome 浏览器，共享 cookie：

1. 安装 postman app
1. chrome 中，安装 postman 插件：Interceptor extension.
1. postman app 中，开启「拦截器」

## 3. 使用实践

收藏夹，整理：

1. 对应关系：一个工程一个收藏夹
1. 层级关系：一个收藏夹下，可以有多个文件夹

api 参数配置：

1. 使用「:name」方式，可以指定参数

环境变量配置：

1. 开发、测试、上线，有不同的环境
	1. 不同环境，uri path 完全相同
	1. host 不同：域名不同
1. 环境变量，控制域名
1. 使用「{{url}}」来使用环境变量的取值

## 4. 参考资料

1. [https://www.getpostman.com/](https://www.getpostman.com/)
1. [https://www.getpostman.com/docs/](https://www.getpostman.com/docs/)
1. [postman-interceptor](https://chrome.google.com/webstore/detail/postman-interceptor/aicmkgpgakddgnaphhhpliifpcfhicfo/support?hl=en)











[NingG]:    http://ningg.github.com  "NingG"
