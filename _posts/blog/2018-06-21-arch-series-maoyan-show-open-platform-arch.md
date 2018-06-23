---
layout: post
title: 实践系列：猫眼演出分销平台的技术架构和关键落地细节
description: 分销平台是什么？有什么用？技术上要考虑哪些要点？如何进行架构设计？实践过程中，如何落地？
category: 技术架构
---

## 0. 目标

之前主导建设的`猫眼分销平台`，其中涉及**订单交易**部分，是**电商业务**下的典型场景，进行一下分享讨论。

> Note：整理有一个 keynote 版本，当时一起进行系统建设的另一个`师兄 & 好友`小宇，现在阿里。

## 1. 概要

* **背景**：
	* 为扩大销量，引入下游「分销商」，准备自建分销平台
	* 分销平台作为基础服务，支持下游渠道接入
	* 对外开放资源的同时，要求做好「系统安全」和「资源权限」管理
* 难点与挑战：
	* **订单设计**：订单状态含义要清晰内聚，而且状态流转可控
		* 出票接口幂等：避免针对同一订单重复出票
		* 掉单问题：出票之前 `fail fast` 策略提升用户体验，出票采取「协商策略」减少掉单
	* **应收结算**：订单状态流转，能够支撑对下游分销商的应收款收取和对上游资源方结算单的结算
	* **系统安全**控制：账号权限、资源权限、权限时效控制

![](/images/arch/maoyan/maoyan_open_platform_position.png)

## 2. 分销平台：架构&细节

几个方面：

* 功能模块：为了满足需求，同时，能够进行落地开发，功能的边界拆分.
* 业务架构：整体业务边界和范围
* 关键要点：落地实现的细节

### 2.1. 功能模块

分销平台，主要功能模块：

* **数据分发**：向分销商分发基础数据
* **账号管理**：只有指定账号才能获取数据资源
* **权限管理**：不同账号的资源权限粒度不同
* **订单管理**：订单状态伴随用户下单、出票过程流转
* **对接结算**：根据订单状态和退款记录，生成结算单

![](/images/arch/maoyan/maoyan_open_platform_function_model.png)

### 2.2. 业务架构

为了满足业务需求，围绕上述的功能模块分析，分销平台的业务架构：

![](/images/arch/maoyan/maoyao_open_platform_arch.png)


### 2.3. 关键要点

几个方面：

1. 领域模型
1. 订单系统
1. 应收结算：资金沉淀
1. 系统安全：接口验签 + 时间窗口

#### 2.3.1. 领域模型

分销平台的领域模型设计：

![](/images/arch/maoyan/maoyan_open_platform_domain_model.png)

领域模型的落地细节：

![](/images/arch/maoyan/maoyan_open_platform_domain_model_details.png)



#### 2.3.2. 订单系统

订单系统，涉及几个要点：

* **订单状态拆分**：
	* **配送状态**：物流状态
	* **下单出票状态**
* **接口幂等**：相同的下单出票请求，只会触发一次真正的下单出票
* **组合策略**：降低掉单率
	* `Fail Fast` ：出票之前，通常用户未付款，采取快速失败策略
	* `协商策略`：出票过程中，如果不确定是否成功，就进入协商状态（fail cache）
	* `补偿策略`：资源方退票时，为保证结算周期的精确，记录退票操作记录，系统容错性、可用性
* **结算、应收逻辑**：根据明确的订单状态，生成结算流水和应收流水

##### 2.3.2.1. 订单状态拆分

![](/images/arch/maoyan/maoyan_open_platform_order_status_machine.png)


订单状态拆分之后：

* 配送状态
* 下单出票状态

带来的好处：

* 配送之后的订单，在极端情况下，仍可以进行「退票」等操作
 
a.配送状态:

![](/images/arch/maoyan/maoyan_open_platform_order_status_machine_deliver.png)

b.下单出票状态:

![](/images/arch/maoyan/maoyan_open_platform_order_status_machine_fix.png)



##### 2.3.2.2. 组合策略：极致优化掉单率

为了极致优化掉单率以及提升资金沉淀，采用组合策略：

* `Fail Fast` ：出票之前，通常用户未付款，采取快速失败策略
* **协商策略**：出票过程中，如果不确定是否成功，就进入协商状态（fail cache）
* **补偿策略**：资源方退票时，为保证结算周期的精确，记录退票操作记录，系统容错性、可用性

![](/images/arch/maoyan/maoyan_open_platform_order_status_machine_combined_strategy.png)

#### 2.3.3. 应收结算：资金沉淀

特别说明：

> 设计订单的时候，不仅仅是设计订单，在设计阶段，考虑应收和结算的逻辑

应收和结算原则：

* 在指定的应收结算周期内，完成流水核对
* 资金沉淀：应收 >= 结算

应收和结算时间基准：

* 应收：
	* 正流水：
		* 订单状态为：LOCKED、CANCELED、FIXING、FIXED、REFUNDING、REFUNDED、REFUND_FAIL
		* 结算周期的时间基准：下单成功时间
	* 负流水：
		* 订单状态为：CANCELED、REFUNDED
		* 结算周期的时间基准：
			* 分销商退票成功时间
			* 如果没有退票成功时间，以取消成功时间为准
* 结算：
	* 正流水：
		* 订单状态为：FIXED、REFUNDING、REFUNDED、REFUND_FAIL
		* 结算周期的时间基准：出票成功时间
	* 负流水：
		* 订单状态为：REFUNDING、REFUNDED、REFUND_FAIL
		* 结算周期的时间基准：资源方退票成功时间

![](/images/arch/maoyan/maoyan_open_platform_settlement_details.png)

#### 2.3.4. 系统安全

系统安全：

* HTTP：接口验签 + 时间窗口
	* 窃听风险
	* 篡改风险
	* 重放攻击
* HTTPS：时间窗口
	* 重放攻击
	* HTTPS 自身的 SSL/TSL 层，解决了窃听和篡改的风险

对于 HTTP 的 BA 认证 和 HTTPS 的实现原理，可以参考：

* [HTTP Basic Auth 剖析](http://ningg.top/http-basic-auth-details/)：HTTP 接口验签的实现原理和细节
* [HTTPS：原理剖析](http://ningg.top/introduction-of-https/)

## 3. 相关问题（Q&A）

* Q：美团侧业务和分销系统的关系 ？ 
	* A：两个系统上层分离，依赖于基础数据（单点）的库存等数据。
* Q：Fail cahce的轮询阈值 ？ 
	* A：依赖于供应商提供的利率，响应效率等因素创建规则，分开判断。
* Q：有用到分布式事务吗 ？ 
	* A：大事务拆分成小事务，能用业务解决的尽量不用技术解决。
* Q：订单状态的补偿机制 ？ 
	* A：补偿机制内聚在核心的支付系统中，通过定时器的方式将中间态改为终态。

## 4. 参考资料

* 之前工作的要点总结




[NingG]:    http://ningg.github.com  "NingG"
