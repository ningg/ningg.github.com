---
layout: post
title: Apache Thrift：Thrift 服务的工程代码实践
description: thrift 方式的 rpc 服务调用，有哪些实践经验？是否可以复用？
published: true
category: thrift
---



## 1. 实践

整体上分为几步：

1. 使用 java 注解编写 thrift 代码：方法签名中添加异常；
1. 服务提供方
	1. 通过 dozer 进行对象转换
	1. 发布服务
1. 服务调用方
	1. 在Thrift service 上封装一层， 向上层屏蔽 rpc 细节
	1. 对象转换：dozer
	1. 异常处理：统一的异常处理

**在 ThriftService 之上封装的 Service**：

* **好处**：
	* **便利**：在 ProjectB 工程中，就像在 ProjectA 工程中一样，使用 ProjectAService，特别方便；
	* **向上屏蔽细节**：封装之后，不会再感知到 RPC 的存在；
	* **代码逻辑清晰**：SRP 原则，本地 service 一套处理方法，thrift service 一套处理方法，分别放置在不同 package，聚合同类处理；
* **弊端**：
	* **model 多处复制**：每个封装的 service 都需要复制一次相关的 model
	* 考虑解决办法：
		* **方案 A**：所有 model 集中到一个 jar 包：
			* **弊端**：增加业务方的开发成本，开发一个工程，需要同步修改多个工程
			* **好处**：只会存在一份 model
			* **备选方案**：考虑父子工程
		* **方案 B**：只复制一份 model 到 thrift 的 jar 包：（*倾向此方案*）
			* **弊端**：仍然复制了一份 model
			* **好处**：简单、直接


![](/images/thrift-series/thrift-rpc-server-and-client.png)



## 2. 代码模块划分

整个工程的代码模块划分，增加 2 个模块：

* **thrift service（server impl）**：thrift server 端，基于 basic service，实现 thrift service，一般需要将 domain model 封装为 thrift model。
* **thrift service（client repackage）**：thrift client 端，基于 thrift service，重新封装一层 service，一般包含： thrift model 与 domain model 之间的转换、Thrift Exception 异常转换等。

![](/images/thrift-series/thrift-server-client-code-project-module.png)












[NingG]:    http://ningg.github.com  "NingG"










