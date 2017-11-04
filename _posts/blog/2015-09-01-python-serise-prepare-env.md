---
layout: post
title: Python 系列：环境配置、安装依赖
description: 配置 Python 的运行环境，安装依赖
published: true
category: python
---


## 背景

依赖包的管理。

## 环境安装

基本情况：

* 安装环境：Macbook Pro 16 
* 安装 Python

几个部分：

* 安装 `python`
* 安装 `pip`

具体代码：

```
// 安装 python
brew install python
// 查看 python 版本
python -V
```

## 配置 IDE（IntelliJ IDEA）

由于一直使用 IntelliJ IDEA，快捷操作比较熟练，因此，继续使用 IntelliJ IDEA 进行 python 代码编写。

准备工作：

* 安装 Python 插件
* 配置识别 pip 安装的依赖

下面配几个截图，简单描述一下过程。

安装 Python 插件：

![](/images/python-series/install-python-plugins-for-idea.png)

将 pip 安装的依赖，添加到 classpath：

![](/images/python-series/pip-install-dependency-add-to-path.png)

debug 配置：

![](/images/python-series/debug-config.png)


## 依赖管理

使用 pip 进行依赖管理：

```
// 安装 PyMySQL
pip install PyMySQL
// 安装 pymongo
pip install pymongo
// 安装 geopy
pip install geopy
```

 
## 参考资料

* [python操作Mongodb](http://caoyudong.com/2016/10/26/python%E6%93%8D%E4%BD%9CMongodb/)




[NingG]:    http://ningg.github.com  "NingG"










