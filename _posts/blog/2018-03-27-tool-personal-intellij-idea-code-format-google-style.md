---
layout: post
title: 工具系列：代码规范 (Google Style Guide)
description: 统一代码规范，避免代码格式的差异，干扰 code review
category: tool 
---

## 背景 & 目标

背景和目标，分开来看：

* **背景**：不同的小组\同学，采用不同的代码格式规范，导致每次 format 代码，都有大量的变化，review 代码时，引入很多干扰项。
* **目标**：统一代码格式规范，保证 format 代码时，不会引入格式上的干扰，提升小组协作效率、代码 review 效率。

Note： `Eclipse` 和 `IDEA` 的同学，都有一定比例，因此需要同时统一 `Eclipse` 和 `IDEA` 工具的代码格式规范。

**补充说明**：

> 之前写了一篇 blog，也是说这个代码格式规范，[工具系列：后台代码规范 (Eclipse、IDEA)
](http://ningg.top/tool-personal-intellij-idea-code-format/), 当前这篇 blog，算是升级版本，向业界通用的代码格式规范靠拢，向前演进一下。


**配置步骤**：

1. **下载配置文件**：代码格式规范的配置文件 BasicJavaCodeFormatter.xml
1. **工具中配置**：Eclipse 或 IDEA 上引入配置，参考下文。

## Eclipse 设置代码格式

两个方面:

* 下载配置文件： [Style guides for Google-originated open-source projects] 中，下载 `eclipse-java-google-style.xml` 代码格式规范文件
* 导入配置文件：TODO

TODO:

* 补充截图，进行说明

## IDEA 设置代码格式

两方面：

1. 进行配置：导入配置
2. 使用配置：格式化代码

### 进行配置

两个方面:

* 下载配置文件： [Style guides for Google-originated open-source projects] 中，下载 `intellij-java-google-style.xml` 代码格式规范文件
* 导入配置文件：参考下面详细说明。


在 IDEA 下，具体导入配置的操作：

* 路径：`Preference` -- `Editor` -- `Code Style` -- `Java`

具体的截图：


![](/images/tool-idea/google-code-style-guide-for-idea-java.jpeg)


### 使用配置

如何使用上述配置？Re：直接进行代码格式化即可，具体快捷操作：`opt` + `cmd` + `L`


## 参考资料


* [Style guides for Google-originated open-source projects]











[NingG]:    http://ningg.github.com  "NingG"
[Style guides for Google-originated open-source projects]:    https://github.com/google/styleguide    "Style guides for Google-originated open-source projects"
