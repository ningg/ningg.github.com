---
layout: post
title: HTTP Basic Auth 剖析
description: HTTP 的安全性，如何保证？加密？签名？
published: true
category: http
---

## 1. 背景

梳理 BA 认证的过程，以及每一步的意义和解决的问题：

1. 明文输入
1. 数字签名
1. 潜在风险：是否可能被攻破

note：

1. HTTP BA（基本认证）原始 BA 认证：
	1. HTTP 头部：Authorization
	1. Authorization: Basic QWxhZGRpbjpvcGVuIHNlc2FtZQ==
	1. 其「数字签名」默认 Base64 编码，能够被解密出来
1. HTTP BA 定制：
	1. HTTP 头部：Authorization
	1. Authorization: Basic QWxhZGRpbjpvcGVuIHNlc2FtZQ==
	1. 其「数字签名」定制的「签名算法」和「私钥」
		1. 计算数字签名过程中，加入「请求参数」和「时间」
		1. 防止篡改和重放攻击（时间窗口）
			1. 请求参数：参与「计算签名」，防止篡改
			2. 时间戳：参与「计算签名」，防止重放攻击

## 2. HTTP BA 认证

HTTP BA 基本数字签名：

针对用户名和密码，进行 Base64 编码：

1. 每 3 个8Bit的字节，转换为4 个 6 Bit的字节；
1. 6 Bit再添 2 位高位 0；
1. 组成四个 8 Bit的字节；
1. `3*8` = `4*6` = 24
1. 3 个字节，变为 4 个字节，字符串长度增长 1/3
1. Base64 的元字符：数字、字母、+、/

Base64 编码：是最简单的数字签名，能够避免人眼识别，但机器都可以解码出原文。

### 2.1. HTTP 请求中，未携带 BA 认证信息

客户端请求（没有认证信息）：

```
GET /private/index.html HTTP/1.0
Host: localhost
```

服务端应答：401 未授权

```
HTTP/1.0 401 Authorization Required
Server: HTTPd/1.0
Date: Sat, 27 Nov 2004 10:18:15 GMT
WWW-Authenticate: Basic realm="Secure Area"
Content-Type: text/html
Content-Length: 311
 
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN"
 "http://www.w3.org/TR/1999/REC-html401-19991224/loose.dtd">
<HTML>
  <HEAD>
    <TITLE>Error</TITLE>
    <META HTTP-EQUIV="Content-Type" CONTENT="text/html; charset=ISO-8859-1">
  </HEAD>
  <BODY><H1>401 Unauthorized.</H1></BODY>
</HTML>
```

### 2.2. HTTP 请求中，携带 BA 认证信息

客户端的请求（用户名“"Aladdin”，口令, password “open sesame”）：

```
GET /private/index.html HTTP/1.0
Host: localhost
Authorization: Basic QWxhZGRpbjpvcGVuIHNlc2FtZQ==
```

服务端的应答：

``` 
HTTP/1.0 200 OK
Server: HTTPd/1.0
Date: Sat, 27 Nov 2004 10:19:07 GMT
Content-Type: text/html
Content-Length: 10476
```

### 2.3. 工具测试 Base64 编码

可以使用 shell 来测试 base64 编码：

``` 
# 编码
$ echo -n "Aladdin:open sesame" | base64
QWxhZGRpbjpvcGVuIHNlc2FtZQ==
  
# 解码
$ echo -n "QWxhZGRpbjpvcGVuIHNlc2FtZQ==" | base64 -D
Aladdin:open sesame
```

## 3. HTTP BA 定制数字签名

HTTP BA 定制数字签名的作用：

> 安全通信：防止参数篡改（无法防止窃听）

HTTP BA 认证，需要提前沟通的内容：

1. `client_id`：字符串，一般推荐 16个字符，代表调用方
1. `secret`：跟 `client_id` 绑定，每个 `client_id` 对应一个 secret
1. 数字签名算法：使用 secret，对 HTTP 请求行内容，计算数字签名
	1. 使用 Secret
	1. `string_to_sign`：HTTP 请求方法、uri、date、param（param 利用 TreeMap 按照字典序排序）
	1. `signature` = `base64` ( `HMAC-SHA256` ( ( `string_to_sign`, `appkey` ) ) );



HTTP BA 签名的基本过程：

1. 计算数字签名，Client 端：根据 `client_id`，使用对应 secret，对 `string_to_sign` 进行数字签名运算
	1. `string_to_sign`：uri、date、param
1. 传输数字签名，HTTP 头部携带数字签名
	1. Authorization：头部
	1. Authorization: AWS shanghai:frJIUN8DYpKDtOLCwozzyllqDzg=
		1. AWS：A web service
		1. shanghai：client id
		1. frJIUN8DYpKDtOLCwozzyllqDzg=：具体的数字签名
1. 验证数字签名，Server 端：根据 client_id 找出对应的 secret，并根据「签名算法」，计算签名，进行校验。

BA 认证：使用「私钥」计算数字签名，通过数字签名，验证消息的完整性和可信性。

1. 私钥：双方线下沟通「身份标识」和「私钥」
1. 签名算法：线下沟通「签名算法」和「签名原始字符串」
1. 双方：都使用「私钥」、「签名算法」、「签名原始字符串」，验证数字签名的正确性

### 3.1. 具体算法
HMAC-SHA2

HMAC：Hash-based Message Authentication Code，使用 secret 对 message 进行hash 运算，具体 Hash 算法，MD5、SHA-1、SHA-2

1. MD5：输出 hash 值 128 bit
	1. MD5的全称是Message-Digest Algorithm 5（信息-摘要算法）。128位长度。目前MD5是一种不可逆算法。
	1. 具有很高的安全性。它对应任何字符串都可以加密成一段唯一的固定长度的代码。
1. SHA-1：输出 hash 值 160 bit
	1. SHA1的全称是Secure Hash Algorithm(安全哈希算法) 。
	1. SHA1基于MD5，加密后的数据长度更长，
	1. 因此，比MD5更加安全，但SHA1的运算速度就比MD5要慢了。
	1. 它对长度小于264的输入，产生长度为160bit的散列值。比MD5多32位。
	1. 2017年荷兰密码学研究小组CWI和Google正式宣布攻破了SHA-1
1. SHA-2：输出 hash 值 256 bit 等，具体实现不同，bit 位数也不同
	1. 包含SHA-256 、SHA-512等
	1. 暂未被攻破
1. Base64：编码方式转换，3 个 8 bit，转换为 4 个 6 bit，高 2 bit填充 0
	1. 3 个 8 bit，变为 4 个 6 bit；
	1. 高位 bit，填充 0；
	1. 安全性：低，可以解码
 
## 4. 参考资料

1. [http://baike.baidu.com/item/base64](http://baike.baidu.com/item/base64)
1. [https://zh.wikipedia.org/wiki/SHA%E5%AE%B6%E6%97%8F](https://zh.wikipedia.org/wiki/SHA%E5%AE%B6%E6%97%8F)

















[NingG]:    http://ningg.github.com  "NingG"










