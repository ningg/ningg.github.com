---
layout: post
title: 开发实践：RESTFul 接口规范
description: restful 风格的接口，有哪些约束 or 建议？
published: true
category: 开发实践
---


## 1. 从需求入手

* 对象：增删改查
* 对象列表：获取
* 对象的复杂处理：挖掘、整理、汇总

## 2. 资源分类

* 对象型：`**/project/1`
* 列表型：`**/projects`
* 算法型：`**/project/search?input=**`

## 3. 设计 URI

### 3.1. URI 命名

* 有意义的单词，全部小写
* 多个单词时，使用下划线分隔，设计良好的 URI 通常会避免多个单词
* 不推荐使用缩写

### 3.2. URI 结构

几点：

* 路径变量：表示层次结构
* 路径标点：表示非层次结构

#### 3.2.1. 路径变量

> id为8的deal的评论列表：
> 
> * /deal/8/comments
> 
> id为8的商家下第88条评论：
> 
> * /merchant/8/comment/88

上述通过**实体关联关系进行路径导航**，一般是 id 导航；如果实体之间关联层级过深，则，使用**查询参数**，替代路径层级导航。

* 路径层级：GET /zoo/1/area/2/animal/3
* 查询参数：GET /zoo/1?area=2&animal=3

组合实体的访问：必须通过父实体的 id导航访问。组合实体不是first-class的实体，它的生命周期完全依赖父实体，无法独立存在，在实现上通常是对数据库表中某些列的抽象，不直接对应表，也无id。

#### 3.2.2. 路径标点

"."表达不同的representation，约定 Response 返回的数据格式

* /deal/6.json
* /deal/8.xml

### 3.3. URI 对外暴露的方法

GET，获取服务器的资源：

* 安全性：服务器端响应 GET 请求并不会对服务器造成副作用
* 不要使用 GET 方法来修改服务器端的状态信息

POST，创建资源：

* 创建从属资源
* 客户端无法确定对应 URI
* POST 请求，不安全，也不是幂等的，因此，发布 POST 请求需要小心

**备注**：幂等，多次操作与只进行一次的效果相同。

PUT，创建资源和更新资源：

* 与 POST 创建资源的区别：客户端知道 URI，具有幂等性
* 在网络环境差的情况下，可将 POST 创建资源重构成 PUT 创建资源

DELETE，删除资源：

* 资源划分粒度要使得，删除资源不用带参数
* 具备幂等性

HTTP 请求返回码：

* 建议：HTTP 头部的返回码统一用200（OK），具体状态在 body 中使用参数标识
* body 中返回码的值，与 HTTP 协议中返回码的值保持一致，便于大家统一理解

 

HTTP 常见状态码：

* 操作成功，2xx：200，ok；201，created
* Client Error，4xx：400，bad request；401，未授权；404，not found
* Server Error，5xx：500，internal server error

 

小结

> REST，Representational States Transfer，表现层状态转化 & 有状态传输，本质上：REST 关注于资源，将所有的内容看做一个资源：图片、文本、计算，为每一个资源分配唯一的地址，并对这些资源进行规范的操作。

几个方面：

* 资源的地址：URI，URL（URI 是抽象，URL 是具体实现）
* 资源的形式：实体文件如：图片，文本，html，json。甚至一些算法及服务
* 对资源的操作：GET\POST\PUT\DELETE


![](/images/develop-series/restful-api-object.png)


 

## 4. URL 补充

避免层级过深的 URL，/ 在 URL 中表示层级，按实体关联关系进行对象导航，通常是 id 导航。

过深的 URL 层级导航，容易造成 URL 迅速膨胀，例如：GET /zoo/1/area/2/animal/3，推荐使用查询参数，替代路径中的实体导航，例如：GET /zoo/1?area=2&animal=3

## 5. 请求及返回内容的规范
 

几点：

* json和xml对象的属性，必须 使用驼峰法命名：一个单词时全部小写，多个单词时第一个单词小写，后续的单词首字母大写；
* 单个对象：对象包含在 data 元素中{}；
* 多个对象：data 是一个 list[{},{},...]，paging 包含分页信息{offset,limit,total}
* 错误与异常：error 元素中，包含{code, type, message}

```
//  单个对象
{
   "data" : {
        "bdId" : 8,
        "bdName": "Rongjun",
        "commission" : 1200.00,
        ...
    }
}
 
// 多个对象
{
     "data" : [
           {
              "code" : "1234567890",
              "status": 0,
           },
           {
              "code" : "234578901",
              "status": 128,
           }
           ...
      ]
     "paging" : {
           "offset" : 0,
           "limit" : 20,
       "total" : 100
      }
}
 
// 错误信息
{
    "error" : {
        "code" : 401,  /* code 仅用于表示有错误，相同的 code 可能有不同的 type 和 message */
        "type" : "PermissionDenied",   /* type表示真正的错误类型，错误类型的唯一标示 */
        "message" : "抱歉，你没有足够的权限" /* 错误对应的详细说明，和type成对。可以理解type是title，message是body */
    }
}
 
```

POST/PUT 提交的请求数据：

* 当请求方法为POST或PUT时，通常需要在Request Body中传递数据。
* Request数据格式（Incoming Representation）可以根据需要采用url form或json格式。
* 建议优先考虑采用json格式，此时，HTTP Header的“Content-Type”设置为"application/json"。
* 相比于Response的格式定义，考虑到Request body中传递的都是业务数据，不需要用data来和其他信息做区别，建议采用 {x:1, y:2} 的格式。

疑问：Request 通过 POST 方式传递数据时，如何定义数据的编码格式？

## 6. 猫眼演出接口约定

整体上遵循技术文档-前后端约定，补充一些：

* B 端 API 接口，/api/admin 开头，.json 结尾
* C 端 API 接口，/api开头，.json 结尾
* C 端 Web 接口，实际对象实体开头

## 7. 异常处理

出现异常时，要满足两种场景：

1. 开发调试时，方便看到完整的异常信息，方便调试
1. 线上服务时，屏蔽异常细节信息，只需向用户显示提示信息

技术上，两种情况：

1. 请求 Web 页面，出现异常，或者 model 中属性异常
1. 调用 API 端口，出现异常，通常是 Ajax 请求对应的 JSON 数据

从业务与非业务角度，异常分为两类：

1. 业务异常：自己的业务代码抛出，表示一个用例的前置条件不满足、业务规则冲突等，比如参数校验不通过、权限校验失败。抛出异常，好处：终止业务逻辑的继续执行。
1. 非业务异常：表示不在预期内的问题，通常由类库、框架抛出，或由于自己的代码逻辑错误导致，比如数据库连接失败、空指针异常、除0错误等等。

技术细节实现上，所有异常，返回给用户时，都需要两类信息：

1. 异常对应的HTTP响应码
1. 异常的文本描述信息

Spring MVC 下，具体技术解决方案：在Controller 层使用统一的异常拦截器：

* 设置 HTTP 响应的状态码：业务类异常，使用它指定的 HTTP code；非业务类异常，统一使用500
* Response Body 的错误码：异常类名
* Response Body 的错误描述：业务类异常，使用它指定的错误文本；



## 8. 其他

常用命名方法：

* DAO 层，方法命名：`insert`、`update`、`getBy*`、`delete`
* Service 层，方法的命名：`add`、`update*`、`getBy*`、`remove`
* Controller 层，方法命名：`create`、`update`、`getBy*`、实际操作的语意：`on`、`off`、`publish`、`delete`、`sync`



出错信息：

```
// 错误信息
{
    "success": false,
    "data" : {
        "reason" : "没有权限",
        "message": "详细信息..."
    }
}
```



PUT vs. POST:

* POST：Ajax 中，对 post 方法提供了封装，能够快捷调用，[http://stackoverflow.com/q/2153917](http://stackoverflow.com/q/2153917)
* PUT：通常要求更新操作具备幂等性













[NingG]:    http://ningg.github.com  "NingG"










