---
layout: post
title: 工具系列：Java 代码规范 (code style + check style)
description: 统一代码规范，借助工具，进行自动的代码格式化、以及代码的格式的自动校验
category: tool 
---

## 0. 概要

当前 wiki，围绕几个问题，进行讨论：

* **为什么**：统一代码规范的必要性
* **怎么做**：
	* **明确规范**
	* **使用规范**

## 1. 为什么：统一代码规范的必要性

为什么需要`统一`代码规范：

* **背景**：不同的小组\同学，采用不同的代码格式规范，导致每次 format 代码，都有大量的变化，review 代码时，引入很多干扰项。
* **目标**：统一代码格式规范，保证 format 代码时，不会引入格式上的干扰，提升小组协作效率、代码 review 效率。

## 2. 怎么做

如何`统一`代码规范呢？需要 2 件事情：

1. **明确规范**：明确「统一」的代码规范
1. **使用规范**：借助工具，自动化格式代码 + 自动校验代码

### 2.1. 明确规范

根据 Java Code Style 调研 中的调研以及「企业微信群：Java Code Style」中的讨论 & 投票，决定采用：`定制版`的 Google Java Code Style。

选用 Google Java Code Style，具体原因：

* 业界使用广泛，基本是通用标准
* 自动化校验工具完善，有完善的 checkstyle 配置文档

基于 Google Java Code Style， 为满足`代码美感`，借鉴其他公司的定制，进行一些定制：

* GoogleStyle-Customize 的 Java 代码规范：
	* IntelliJ IDEA： `intellij-java-google-style.xml` （[在线查看](https://github.com/ningg/styleguide/blob/gh-pages/intellij-java-google-style.xml)）
	* 定制的 Google Style Code 工程： [https://github.com/ningg/styleguide](https://github.com/ningg/styleguide) （**Note：可以查看定制的细节**）

### 2.2. 使用规范

使用代码规范，分为 2 方面：

1. **代码格式化**：自动化的代码格式化
1. **代码校验**：代码格式的自动校验

#### 2.2.1. 代码格式化

在 IntelliJ IDEA下，使用  `intellij-java-google-style.xml` 进行代码格式化之前，需要先进行配置。具体配置步奏，参考下述截图。


设置配置文件，路径：`IntelliJ IDEA ` → `Preference` → `Editor` → `Code Style`，参考下图：


![](/images/tool-idea-code-style-and-check-style/code-style-config-1.png)


![](/images/tool-idea-code-style-and-check-style/code-style-config-2-choose-file.png)


![](/images/tool-idea-code-style-and-check-style/code-style-config-3-select-plan.png) 



配置了 code style 后，在 Mac 下，IDEA IntelliJ 进行代码格式化：（快捷键，`Shift` + `Command` + `L`）

![](/images/tool-idea-code-style-and-check-style/code-style-config-4-reformat-code.png)


#### 2.2.2. 代码校验

代码自动化检查的意义：

* **节省人力**：机器能做的事情，交给机器，特别是枯燥的事情，让机器去做
* **避免遗漏**：机器自动执行，全范围扫描

根据初步调研（基础工作-1-自动化代码检查），决定采用现在非常流行，并且比较通用的自动化代码检查工具 Checkstyle，检查 Java 代码编写规范。

> 备注：蚂蚁金服、快手，团队开发过程中，都在使用 Checkstyle，进行自动化代码检查。

Checkstyle 会在代码开发过程中，检查代码规范，一般检查的内容包括：

1. Javadoc注释
1. 命名约定
1. 标题
1. Import
1. 大小写
1. 空白
1. 修饰符
1. 代码
1. 类设计
1. 混合检查（包活一些有用的比如非必须的System.out和printstackTrace）
 

基于「定制的 Google Code Style」，需要对 原始 Google Code Style 的 Checkstyle 进行定制：

* 定制的 Checkstyle 配置：`google_checks.xml` （[在线查看](https://github.com/ningg/checkstyle/blob/master/src/main/resources/google_checks.xml)）
* 定制的 Checkstyle：[https://github.com/ningg/checkstyle](https://github.com/ningg/checkstyle)（*Note：可以查看定制的细节*）


使用 Checkstyle 分为 3 个方面：

* **安装插件**：在 IntelliJ IDEA 下安装 Checkstyle 的插件
* **配置插件**：配置 Checkstyle 的插件的检验规则
* **使用插件**：利用 Checkstyle，进行代码校验

##### 2.2.2.1. 安装插件

在 IDEA 下安装 Checkstyle 插件： （Note：下载比较耗时，需要等一会儿）

![](/images/tool-idea-code-style-and-check-style/check-style-config-1-plugin-install.png)
 

##### 2.2.2.2. 配置插件

下载定制的 Checkstyle（上文有配置文件），并且进行配置：

![](/images/tool-idea-code-style-and-check-style/check-style-config-2-configure.png)



##### 2.2.2.3. 使用插件

利用 Checkstyle 进行 check：（3 种，可以使用一种）

* `Check Current file`
* `Check All Modified file`
* `Check Project`

具体截图：

![](/images/tool-idea-code-style-and-check-style/check-style-config-3-usage.png)

## 3. 参考资料

* [工具系列：代码规范 (Google Style Guide)](http://ningg.top/tool-personal-intellij-idea-code-format-google-style/)
* [https://github.com/ningg/styleguide](https://github.com/ningg/styleguide)
* [https://github.com/ningg/checkstyle](https://github.com/ningg/checkstyle)

## 4. 附录

几个常见问题：

### 4.1 code style 和 check style 的关系

code style & check style：

* code style：
	* 定义，代码风格
	* 需要一个定义文件
* check style：
	* 校验，代码风格
	* 需要一个校验规则的描述文件

特别说明：

* code style 跟 check style 的「配置文件」必须一一对应
* 如果使用 Code Style A，然后再用 CheckStyle 进行校验，则，会出现不一致








[NingG]:    http://ningg.github.com  "NingG"

