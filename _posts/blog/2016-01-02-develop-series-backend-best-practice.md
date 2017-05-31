---
layout: post
title: 开发实践：开发规范
description: 前后端交互过程中，有一些开发规范，能够降低沟通成本，提升代码复用率，提升项目开发效率
published: true
category: 开发实践
---


## 1. 接口规范

接口规范，约定前后端协作规范。

### 1.1. URL规范

* 符合RESTFul风格；
* URL命名应符合以下规则方便权限过滤和部署：
	* API接口以/api/**开头；
	* 后台页面以/admin/**开头；
	* 后台API接口以/api/admin/**开头。

### 1.2. 接口格式规范

```
{
    // 标识该次请求后台是否处理成功
    "success": true,
    // 请求失败的，给出错误信息
    "error": {
        // 错误码
        "code": 1000,
        // 错误信息
        "message": "不存在",
        // 异常信息，调试模式下可以给出
        "exception": ...
    }
    // 数据内容，每个业务接口具体定义
    "data": ...
    // 如果是分页数据，给出分页信息
    "paging": {
        // 分页起始位置
        "offset": 0,
        // 每一页的数量
        "limit": 20,
        // 总数量
        "total": 100,
        // 是否存在下一页
        "hasMore": true
    }
}
```

1.3. 错误码

错误码（code）为 5 位异常码：

|异常码|英文代码|说明|
|---|---|---|
|40001|NeedLoginException|需要登陆|
|40003|ForbiddenException|没有资源操作权限|
|40009|ResourceAlreadyExistException|资源已经存在|
|40010|ResourceNotFoundException|资源不存在|
|40011|ResourceAlreadyDeletedException|资源已删除|
|40012|ResourceDuplicateKeyException|唯一性条件约束，资源的新增/更新操作失败，一般表示「重复提交」|
|50000|InnerServerErrorException|服务器内部异常|
|50001|ThriftException|服务器内部远程调用异常|
 	 	 

### 1.4. 参数类型

|参数类型|说明|
|---|---|
|PathVariable|放在URL中的RESTFul参数|
|FormData|放在表单中的参数，一般是HTTP POST/PUT请求|
|QueryString|放在URL中的普通参数，?xxx=xxx|
|HttpHeader|放在HttpHeader中的参数，一般用来做状态保持|

### 1.5. 数据类型

一些比较特殊的数据类型，在这里做统一说明

|数据类型|备注|
|---|---|
|Enum|后台是枚举类型，在接口层面与int表现一致，后台会在文档中说明枚举文本对应的int值|
|Date|日期类型，默认格式是yyyy-MM-dd，如有特殊会特殊标明|
|Datetime|日期时间类型，默认格式是yyyy-MM-dd HH:mm:ss，如有特殊会特殊标明|
|`List<?>`|多值参数，客户端/前端可以采用以下两种方式传递给后台：在FormData/QueryString中传递重名参数，例如：languages=汉语，languages=日语；在参数名称后面加下标，例如：anguages[0]=汉语，languages[1]=日语|

### 1.6. 状态保持

#### 1.6.1. 用户Token

目前后台支持客户端通过三种方式传递token到后台：

|字段名称|参数类型|
|---|---|
|Token|HttpHeader|
|token|QueryString|
|token|FormData|

#### 1.7. 图片使用

1. 原图：前端获取的图片 url 为原图。
1. 缩略图：在图片 url 中添加后缀，即可获取缩略图

## 2. 开发规范

### 2.1. 代码规范

有单独的一个 blog 说明。

### 2.2. 数据库规范

使用的是 MySQL 数据库：

* 字符集统一使用utf8mb4，支持emoji；
* 除非特殊情况，所有字段请使用NOT NULL + 合理默认值，尽量使用业务不可达的值代表“NULL”语义；
* 主业务实体表必需包含以下三列：
	* id：一般是int/bigint，建议直接用bigint，要相信自己的业务有跑到21亿的那一天
	* created：数据的创建时间，方便排查问题，建议datetime类型
	* modified：数据的最后修改时间，方便排查问题，建议timestamp NOT NULL DEFAULT `CURRENT_TIMESTAMP` ON UPDATE `CURRENT_TIMESTAMP`
* 命名规范：
	* 库名：`{product}_{entity}`，例如：`pro_project`；
	* 表名：以系统模块名称作为前缀，例如：`connect_user`；
	* 列名称：下划线分隔；
	* 索引名称：
		* 普通索引：以`idx_`开头；
		* 唯一索引：以`uk_`开头；
		* 后面以索引顺序填充字段名称，以下划线分隔：
			* 字段名称如果包含ID，可以省略；
			* 字段名称如果是多个单词组成，用驼峰法。
			* 例如一个唯一索引是由`user_id`和`content_type`两个列组成，命名为：`uk_user_contentType`

### 2.3. 代码约定

* com.meituan.movie.pro.*
	* model：继承 CachealeEntity 或者 PropsEntity
	* service：一定要有接口，接口继承ICacheableService
		* impl：继承AbstractCacheableService
		* thrift
	* advice
	* dao
		* db
		* solr
	* web
		* controller
		* interceptor
		* advice
		* vo

## 附录

paging 那里，offset 和 limit 是 MySQL 那边的语法吧。 对于翻页，github 是用 page 和 per_page，[https://developer.github.com/v3/](https://developer.github.com/v3/)


### 附录 A：工程结构

工程需要覆盖的要点：

* 标准的 Maven 结构
* README.md 说明文档
* Spring MVC
	* mvc
	* 数据绑定
	* 数据校验
* 异常处理
* RPC：thrift client、thrift server
* 缓存：Medis
* 事务：事务管理
* 监控：jmonitor
* 日志：log4j、sentry
* 单元测试：
	* 表结构：schema.sql
	* 初始数据：data.sql
	* 测试用例


























[NingG]:    http://ningg.github.com  "NingG"










