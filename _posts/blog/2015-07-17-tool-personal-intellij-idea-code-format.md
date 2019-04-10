---
layout: post
title: 工具系列：后台代码规范 (Eclipse、IDEA)
description: 统一代码规范，避免很多格式的差异照成 PR 中 review 代码的困难
category: tool 
---

小组内多成员协同开发，统一代码规范很必要，对于使用不同IDE的人员，这就是个问题。

> **特别说明**：直接参考最新版的代码规范 [Java 代码规范 (code style + check style)](http://ningg.top/tool-personal-intellij-idea-java-code-style/)

## 1. IDEA 下使用 Eclipse 的配置文件

1. 安装插件：直接在IDEA的Plugins中搜索『Eclipse Code Formatter』，安装这一插件即可。
	1. 插件的[官方网址](http://plugins.jetbrains.com/plugin/?idea&id=6546)
	1. [GitHub上开源维护网址](https://github.com/krasa/EclipseCodeFormatter)
1. 配置插件：
	1. 移动后台组，有一个Eclipse的代码格式规范 [MobileCodeFormatterV2.xml](/images/tool-idea/MobileCodeFormatterV2.xml) 
	1. 【Note】：上述文档 MobileCodeFormatterV2.xml 中，我将"lineSplit"参数，调整为160：MobileCodeFormatterV2-1.xml，以方便与其他同事代码格式保持一致。
	1. 下载文档MobileCodeFormatterV2.xml，并在IDEA下配置即可，效果参考下图。
1. 代码格式化
	1. IDEA下快捷键：cmd + opt + L

![](/images/tool-idea/eclipse-code-formatter-plugin.png)
 

## 2. 配置代码风格

为了在IDEA编辑器页面中能够区分空格和TAB键的输入内容，在Preference下选中：

* Editor
	* General
		* Appearance：选中『show whitespaces』和『show line numbers』

具体页面效果如下：

![](/images/tool-idea/idea-display-details.png)

其他设置：

* Preferences 中「Editor」–「Code Style」–「Right margin（columns）」每行的长度，建议160
* Preferences 中「Editor」–「Code Style」–「Java」--「Imports」

![](/images/tool-idea/code-display-import-details.png)

## 3. IDEA 其他插件

* GenerateSerialVersionUID
 
## 4. 参考来源

* [Eclipse、IDEA格式化统一](http://blog.csdn.net/preterhuman_peak/article/details/45719985)















[NingG]:    http://ningg.github.com  "NingG"
