---
layout: post
title: Apache Thrift：服务开发框架
description: Apache Thrift 是什么？能做什么？有什么注意事项？
published: true
category: thrift
---



## 1. 背景

公司内部通过 Thrift 进行 rpc 调用，准备详细学习一下：

1. Thrift 是什么？
1. Thrift 能做什么?
1. Thrift 怎么用？
1. Thrift 使用时，需要搭建环境吗？怎么搭建？
1. Thrift 的内部原理是什么？ 

## 2. Thrift 是什么

### 2.1. 概要

Apache Thrift，是一个软件框架，包含有代码生成引擎，能够生成多种语言的代码，主要作用：构建远程调用的服务（构建 RPC）。

### 2.2. 消息传输形式

服务调用的方式很多，简单汇总一下：

1. 基于 SOAP 消息格式的 Web Service 服务
1. 基于 JSON 消息格式的 RESTful 服务

具体消息的传输形式：

1. XML 形式：SOAP 消息格式就是 XML 形式
1. JSON 形式：相对于 XML 形式，JSON 形式体积小、效率高
1. 二进制形式：相对 XML 和 JSON 形式，效率更高

**Thrift 框架**，使用`二进制形式`传输消息，同时`支持多语言`环境。

### 2.3. 如何支持多语言环境

无论现有软件是使用哪种语言编写的，例如 Java、C++、PHP、Pythoh、Ruby等，使用 Thrift 发布的服务都能与现有软件无缝对接。

Thrift 框架，是如何支持多语言环境的？

1. **定义服务**：使用接口描述语言（IDL）定义并描述服务
1. **生成代码**：通过代码生成引擎，生成不同语言对应的代码

上面 Thrift 通过 IDL 定义服务之后，需要在服务器端编写代码：描述服务器端的具体实现细节（实现 Iface 或 AsyncIface 接口）。

## 3. Thrift 能做什么

Thrift 用于构建远程调用的服务，并且支持跨语言的实现。

另外：

* [使用 swift 注解编写 thrift 服务](https://blog.csdn.net/qq_25788637/article/details/79503964)
* IntelliJ IDEA 下，添加 Thrift Support 插件


MTthrift 使用过程的注意事项：

* thrift server 侧，推荐返回 `Lists.newArrayList()`，大部分情况下，使用 `Collections.emptylist()` 有隐患（因为是 Immutable 的对象）。
* Date 类型字段，在 Thrift Model 中切换为 Long（不是 Integer），**理由**：原始 IDL 也不支持 Date 类型。
* 不支持`泛型`，针对泛型，需要处理为具体的对象，理由：原始 IDL 也不支持泛型。

 

## 4. 参考资料

* [http://thrift.apache.org/](http://thrift.apache.org/)
* [https://github.com/apache/thrift](https://github.com/apache/thrift)
* [https://www.ibm.com/developerworks/cn/java/j-lo-apachethrift/](https://www.ibm.com/developerworks/cn/java/j-lo-apachethrift/)

























[NingG]:    http://ningg.github.com  "NingG"










