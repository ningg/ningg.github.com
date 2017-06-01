---
layout: post
title: 基础原理系列：跨域问题 & 解决思路
description: 跨域问题，实践经验
published: true
category: 基础原理
---

## 1. 概述

几个疑问：

1. 什么是跨域？如何判断是否产生「跨域」？
1. 跨域，带来的问题？
1. 跨域问题，解决思路？

## 2. 跨域：是什么

跨域的问题根源：浏览器的「同源策略」。

### 2.1. 同源策略

同源策略（Same-Origin Policy）：1995 年，Netscape 公司，将「同源策略」引入浏览器，此后，所有浏览器都遵循「同源策略」。

同源策略：

* A 网页设置的 Cookie，B 网页不能访问，除非「A B 同源」。
* 即：非同源网站之间， Cookie 隔离。

同源：是指「3 个相同」

* 协议
* 域名
* 端口

同源策略的意义：浏览器安全的基石，保证用户信息安全，防止恶意网站窃取数据。

Cookie 是存储在浏览器端的文本信息，通常存储一些个人隐私信息，大部分网站通过 Cookie 内信息识别用户的登陆状态，如果 Cookie 被恶意窃取，则产生巨大安全隐患。

思考：

> 同源的网站，会共享 Cookie，还会共享其他信息么？

随着互联网的发展，更加严格的「同源策略」：如果 A网站和 B网站，不同源，则

1. Cookie、LocalStorage 和 IndexDB 无法读取
1. DOM 无法获得
1. AJAX 请求不能发送

「同源策略」绝大部分情况下，都很必要，但也限制了业务的灵活应用，一些特殊场景下，期望绕过「同源策略」。

### 2.2. 跨域

核心几点：

1. 跨域：发生在浏览器
1. 跨域的根源：浏览器为了安全所遵循的「同源策略」
1. 同一个域：3 个相同

## 3. 跨域：带来的问题

跨域时，2 个请求无法共享 Cookie 等数据，也无法嵌套发送 Ajax 请求。

解决办法：

1. 请求无法共享 Cookie 数据：网页设置 document.domain 参数，实现一级域名共享 Cookie
1. 无法嵌套发送 Ajax 请求：需要特殊处理。（见下文）

跨域：解决方案

### 3.1. Cookie

Cookie 是服务器写入浏览器的一小段信息，只有同源的网页才能共享。但是，两个网页一级域名相同，只是二级域名不同，浏览器允许通过设置document.domain共享 Cookie。

举例来说，A网页是http://w1.example.com/a.html，B网页是http://w2.example.com/b.html，那么只要设置相同的document.domain，两个网页就可以共享Cookie。

```
document.domain = 'example.com';
```

现在，A网页通过脚本设置一个 Cookie。

```
document.cookie = "test1=hello";
```

B网页就可以读到这个 Cookie。

```
var allCookie = document.cookie;
```

注意，这种方法只适用于 Cookie 和 iframe 窗口，LocalStorage 和 IndexDB 无法通过这种方法，规避同源政策，而要使用PostMessage API。另外，服务器也可以在设置Cookie的时候，指定Cookie的所属域名为一级域名，比如.example.com。

```
Set-Cookie: key=value; domain=.example.com; path=/
```
这样的话，二级域名和三级域名不用做任何设置，都可以读取这个Cookie。

### 3.2. Ajax

同源政策规定，AJAX请求只能发给同源的网址，否则就报错。

除了架设服务器代理（浏览器请求同源服务器，再由后者请求外部服务），有三种方法规避这个限制。

1. JSONP
1. WebSocket
1. CORS

#### 3.2.1. JSONP

完整内容，参考：[same-origin-policy](http://www.ruanyifeng.com/blog/2016/04/same-origin-policy.html)

本质：

1. 网页内部，通过 <script> 标签，向不同源的网站请求数据，不受「同源策略」约束；
1. 服务端受到请求后，需要将 data 放入指定名字「回调函数」中传回，避免使用 JSON.parse 步骤。

特点：

* 需要服务器配套改造。

#### 3.2.2. CORS

CORS是跨源资源分享（Cross-Origin Resource Sharing）的缩写。它是W3C标准，是跨源AJAX请求的根本解决方法。相比JSONP只能发GET请求，CORS允许任何类型的请求。

关键点：

1. CORS需要浏览器和服务器同时支持。
1. 目前，所有浏览器都支持该功能，IE浏览器不能低于IE10。
1. 整个CORS通信过程，都是浏览器自动完成，不需要用户参与。
1. 对于开发者来说，CORS通信与同源的AJAX通信没有差别，代码完全一样。
1. 浏览器一旦发现AJAX请求跨源，就会自动添加一些附加的头信息，有时还会多出一次附加的请求，但用户不会有感觉。

因此，实现CORS通信的关键是服务器。只要服务器实现了CORS接口，就可以跨源通信。

浏览器将CORS请求分成两类：简单请求（simple request）和非简单请求（not-so-simple request）。

只要同时满足以下两大条件，就属于简单请求。 

（1) 请求方法是以下三种方法之一：

* HEAD
* GET
* POST

（2）HTTP的头信息不超出以下几种字段：

* Accept
* Accept-Language
* Content-Language
* Last-Event-ID
* Content-Type：只限于三个值application/x-www-form-urlencoded、multipart/form-data、text/plain

凡是不同时满足上面两个条件，就属于非简单请求。 浏览器对这两种请求的处理，是不一样的。
详细内容，参考：[《跨域资源共享 CORS》](http://www.ruanyifeng.com/blog/2016/04/cors.html)

## 4. 参考资料

1. [《跨域资源共享 CORS》](http://www.ruanyifeng.com/blog/2016/04/cors.html)
1. [《浏览器同源策略》](http://www.ruanyifeng.com/blog/2016/04/same-origin-policy.html)
































[NingG]:    http://ningg.github.com  "NingG"










