---
layout: post
title: 基础原理系列：异常信息和异常码
description: 异常码，实践经验
published: true
category: 基础原理
---

## 1. 简介

当请求异常时，需要两类异常信息：

1. 用户可见的异常信息（外部异常信息）：用于告知用户发生了什么情况，方便用户进行下一步操作
1. 开发人员可见的异常信息（内部异常信息）：用户开发人员快速定位问题

几个典型问题：

1. 抛出内部异常：要求给出详细的信息，快速定位问题发生的场景，方便重现错误；
1. 异常信息的转换：内部异常要转换为外部异常，屏蔽过多的异常细节，为用户提供简要的说明信息，引导用户的下一步操作

Java 语言中，异常处理机制，可以参考：

* [Java 剖析：异常处理](/inside-java-exception/)

## 2. 内部异常信息

疑问：

1. 内部异常的种类有哪些？
1. 如何进行分类管理？分类是为了统一和规范

异常分类，可以通过不同维度进行：

1. 业务实体维度：
	1. 实体A 相关
	1. 实体B 相关
	1. 实体通用
1. 业务上，异常产生原因维度：
	1. 资源不存在
	1. 状态不合法
	1. 输入参数不合法
	1. 没有操作权限
1. 异常发生位置：
	1. 用户输入不合法：用户引发的错误
	1. Controller 层的错误
	1. Service 层的错误
	1. DAO 层的错误

实际上，因为编写代码是业务逻辑代码，因此，倾向于从异常产生原因+业务实体的维度划分异常，举例：

1. 异常1：资源不存在，资源类型为"项目"，id:100
1. 异常2：资源状态不合法，资源类型为"项目"，id:100，资源状态为 A，无法取消

## 3. 外部异常信息

疑问：

1. 外部异常的种类有哪些？
1. 如何进行分类管理？分类是为了统一和规范

外部异常信息，实际上是基于内部异常信息做了一层处理：

1. 封装
1. 转换
1. 归类
1. ...

无论内部异常有多少，最终给外部的异常种类，还是越少越好，而且要简洁，外部异常的目标聚焦在为用户提供简要的说明信息，引导用户的下一步操作。

## 4. 实践

### 4.1. 错误码

#### 4.1.1. 现有方案调研

几种错误码对比：

![](/images/computer-basic-theory/error-comparision.png)

#### 4.1.2. 经验总结

![](/images/computer-basic-theory/error-code-meanings.png)
 
#### 4.1.3. 实例

下面给一组实际使用的错误码：


|错误码|对应异常|作用|备注|
|---|---|---|---|
|30001|ParamErrorException|参数错误||
|40001|NeedLoginException|你需要登录||
|40003|ForbiddenException|您没有资源的操作权限, 资源:%s, 资源唯一标识和取值, %s:%s||
|40009|ResourceAlreadyExistException|资源已存在, 资源类型:%s, 资源唯一标识和取值, %s:%s||
|40010|ResourceNotFoundException|资源不存在, 资源类型:%s, 资源唯一标识和取值, %s:%s||
|40011|ResourceAlreadyDeletedException|资源已删除, 资源类型:%s, 资源唯一标识和取值, %s:%s||
|40012|ResourceDuplicateKeyException|唯一性约束条件限制, %s操作失败, 资源类型:%s, 资源唯一标识和取值, %s:%s||
|50000|InnerServerErrorException|服务器内部错误||
|50001|ThriftException|服务器内部远程调用异常, 详细信息: %s||
 
 
### 4.2. 异常命名

常用的异常命名：

|异常命名|说明|
|---|---|
|TypeNotMatch	|类型不匹配|
|IllegalStatus|非法的状态|
|IllegalParam	|参数不正确|
|InvalidParam|参数无效|
|ResourceNotFound|资源不存在|
|ResourceAlreadyDeleted	|资源已经删除|
|ResourceAlreadyExist|资源已存在|
|ResourceNoPermission|没有资源权限|
|SystemError	|系统内部错误|
 
不必约束在上面的命名中，异常可以随时随地命名，有助于快速定位错误，例如下面这样：

![](/images/computer-basic-theory/error-code-demo-1.png)

![](/images/computer-basic-theory/error-code-demo-2.png)

上面异常命名很流畅，有几个可以借鉴的地方：

* 以功能模块为前缀，命名异常（微博 API 的错误码，采用这种策略）
* 异常的粒度适当，没有刻意共用异常

## 5. 其他

### 5.1. HTTP 状态码

简要列出几类 HTTP 状态码：

|状态码|说明|
|---|---|
|1xx|信息提示|
|2xx|成功|
|3xx|重定向（要求浏览器进行下一步动作）|
|4xx|客户端错误|
|5xx|服务器错误|
 

## 6. 参考来源

1. [微信公众平台，全局返回码](https://mp.weixin.qq.com/wiki/10/6380dc743053a91c544ffd2b7c959166.html)
1. [支付宝，开放平台，公共错误码](https://doc.open.alipay.com/doc2/detail.htm?spm=a219a.7629140.0.0.7Ct6Mh&treeId=115&articleId=104796&docType=1)
1. [微博 API，错误代码](http://open.weibo.com/wiki/Error_code)
1. [有效处理 Java 异常三原则](http://www.importnew.com/1701.html)
1. [异常处理的误区和经验总结](http://www.ibm.com/developerworks/cn/java/j-lo-exception-misdirection/)
1. [HTTP 状态码](https://www.w3.org/Protocols/rfc2616/rfc2616-sec10.html)


















[NingG]:    http://ningg.github.com  "NingG"










