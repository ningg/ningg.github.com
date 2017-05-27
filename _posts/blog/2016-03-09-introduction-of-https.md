---
layout: post
title: HTTPS：原理剖析
description: 为什么会产生 HTTPS 协议？HTTPS 协议设计的原理
published: true
category: http
---

## 0. 概要

Web 应用已经全面升级为 HTTPS 服务，有几个基本的问题：

1. 为什么：HTTP 应用这么多年，遇到什么问题了吗？为什么要升级到 HTTPS？
1. 是什么：HTTPS 是什么？如何解决这些问题的？
1. 怎么做：Web 服务，如何开启 HTTPS 支持？浏览器？DNS？Nginx 代理服务器？
1. 附录：引入 HTTPS 的收益？代价？

## 1. 为什么：HTTP 的问题

HTTP，基于 TCP 的应用层协议，明文传输，存在隐患：

1. 窃听：传输内容，被第三方获取
1. 篡改：传输内容，被修改
1. 劫持：伪造 Server 身份，为 Client 服务；又称：冒充、中间人攻击

 ![](/images/http/http-problems.png)

## 2. 是什么：HTTPS 提升安全性

有没有什么办法，解决上述问题？

1. 归类一下，都是安全性问题，根源是「明文传输」，怎么解决？加密。
1. 加密，怎么加密？
	1. 加密、解密，需要密钥
	1. 传递密钥之前，是明文传输，此时，如何传递「密钥」？
	1. 使用「非对称加密」，传递「对称加密」的「密钥」
1. 整个过程：
	1. 非对称加密：Client 向 Server 传递「密钥」
	1. 对称加密：Client 和 Server 都获得「密钥」后，即可进行「对称加密」
	1. 思考：完整的请求响应过程，使用「非对称加密」，是否可以？（窃听）
1. 使用「非对称加密」+「对称加密」，能否解决所有安全问题？（窃听、篡改、劫持）
	1. 劫持：风险仍然存在，中间人攻击（劫持）
	1. 效率问题：非对称加密效率低、耗时长（相对于对称加密）
1. 劫持，产生的根源：无法验证「公钥」是否真的是指定网站所有。
	1. Client 如何验证「公钥」的有效性？
	1. 引入`数字证书`，数字证书中包含公钥，只要证书是可信的，公钥就是可信的
	1. 浏览器中，内置通用数字证书的验证逻辑和「根证书」
1. 数字证书的验证过程：如何验证数字证书是有效的？数字证书是否有伪造风险？
	1. 数字证书，内部包含：`公钥`和`数字签名`，使用根数字证书，验证公钥和数字签名的匹配关系
	1. 依赖浏览器中内置的「根数字证书」
	1. 数字证书：依赖链
 
![](/images/http/https-mitm.png)


HTTPS 请求的连接建立过程：

1. HTTP 是完全基于 TCP 协议的， TCP 是三次握手，建立的连接；
1. HTTPS 请求，基于 SSL/TLS，连接是如何建立的？
1. 断网重连机制？

![](/images/http/https-with-rsa-handshake.png)

 
特别说明：

1. HTTPS 的 RSA 算法，建立加密通信的过程：非对称加密
1. 握手阶段，RSA 算法，使用 3 个随机数，生成 Session Key 作为加密密钥的原因：
	1. 防止「随机数 C」被猜出
	1. 引入多个随机因素，增加 Session Key 的随机性
1. 「步骤 1」：Client 会发出：支持的「非对称/对称加密」算法
1. 「步骤 2」：Server会返回：选用的「非对称/对称加密」算法
1. 「步骤 3」：Client 确认算法
1. 「步骤 4」：Server 确认算法

几个关键词：

非对称加密：实现「密钥协商」
对称加密：采用协商的密钥，进行「数据加密」
数字证书：实现「身份认证」

补充：如果使用 DH（ Diffie-Hellman算法）进行非对称加密，实际上，调整的是「步骤 3」交换「随机数 C」的过程，更多细节参考：[http://www.ruanyifeng.com/blog/2014/09/illustration-ssl.html](http://www.ruanyifeng.com/blog/2014/09/illustration-ssl.html)

DH 非对称加密：

![](/images/http/https-with-dh-handshake.png)
 
 
思考：

> HTTPS 是否加密：HTTP Header 和 HTTP Body？
> 
> RE：因为 HTTPS 是运行在 SSL/TLS 之上的，所以， HTTPS 的所有数据（header 和 body）都是加密的。

## 3. 怎么做：如何升级到 HTTPS？

* 端到端，都要支持 SSL/TLS：
* 浏览器：
* Nginx
	* [Nginx 使用ssl模块配置HTTPS支持](https://www.centos.bz/2011/12/nginx-ssl-https-support/)
	* [Configuring HTTPS Server](http://nginx.org/en/docs/http/configuring_https_servers.html)
* Web Server Container：是否有影响？
	* [Jetty 配置 SSL](http://www.eclipse.org/jetty/documentation/current/configuring-ssl.html)

 
## 4. 实例

现在常用的 HTTPS 细节：

* 非对称加密算法：RSA？DH？
* 对称加密算法：AES？

举例：

> The connection to this site is encrypted and authenticated using a strong protocol (TLS 1.2), a strong key exchange (ECDHE_RSA with P-256), and a strong cipher (AES_256_GCM).

* ECDHE_RSA ：非对称加密算法，DH 的升级版本
* AES_256_GCM：对称加密算法，AES（Advanced Encryption Standard，先进加密标准）

## 5. 附录

### 5.1. 附录：加密和密钥

这一部分，对加密、解密、密钥、公钥、私钥、对称加密、非对称加密，进行简单介绍。

从使用场景入手：

> 场景：对一部分内容，加密和解密。

各个术语：

1. 明文：加密之前的内容
1. 密文：加密之后的内容
1. 加密密钥：明文→ 密文，加密过程中，使用的密钥
1. 解密密钥：密文→ 明文，解密过程中，使用的密钥
1. 对称加密：「加密密钥」等于「解密密钥」
1. 非对称加密：「加密密钥」不等于「解密密钥」
	1. 「公钥」加密的内容，只有「私钥」能解密
	1. 「私钥」加密的内容，只有「公钥」能解密
	1. **非对称加密，是单向的**，公钥是公开的，任何人都可以获取公钥，从而获得 Server 信息的明文
	1. 非对称加密的典型作用：传递对称加密的密钥
1. 公钥：公开的密钥，对应到「非对称加密」中的 Client 端的「加密密钥」
1. 私钥：私有的密钥，对应到「非对称加密」中的 Server 端的「解密密钥」

![](/images/http/encrypt-and-decode.png)

### 5.2. 附录：HTTPS 的代价

HTTPS （HTTP over SSL/TLS）：

1. 使用 SSL 安全通道，非对称加密：交换随机数，生成对称加密的密钥；
1. 数据传输过程中：完整的 HTTP 协议，但使用密钥进行「对称加密」；

HTTPS 相对 HTTP ，获得了很好的安全性，那是否有代价呢？

* 连接建立过程：增加了 SSL 的握手过程，连接建立时间，比 HTTP 要长 2～5 倍
* 数据传输过程：HTTP 数据传输，需要加密、解密，时长更长

HTTP vs. HTTPS：

1. HTTP耗时 = TCP握手
1. HTTPs耗时 = TCP握手 + SSL握手 （TCP 和 SSL 共用了一个请求）

![](/images/http/tcp-handshake-3-times.png)

![](/images/http/tcp-discard-4-times.png)

![](/images/http/ssl-handshake-4-times.png)

![](/images/http/tcp-with-ssl-handshake.png)

使用 curl 命令，可以统计 TCP握手 和 SSL握手的时间：

```
curl -w "TCP handshake: %{time_connect}, SSL handshake: %{time_appconnect}\n" -so /dev/null https://www.baidu.com
```

不同的网站，TCP握手时间和 SSL握手时间，差异比较大，一般认为：

* SSL 握手时间，是 TCP 握手时间的 2～10 倍。

更多操作细节，参考：[http://www.ruanyifeng.com/blog/2014/09/ssl-latency.html](http://www.ruanyifeng.com/blog/2014/09/ssl-latency.html)

## 6. 参考资料

* [图解SSL/TLS协议](http://www.ruanyifeng.com/blog/2014/09/illustration-ssl.html)
* [SSL/TLS协议运行机制的概述](http://www.ruanyifeng.com/blog/2014/02/ssl_tls.html)
* [SSL延迟有多大？](http://www.ruanyifeng.com/blog/2014/09/ssl-latency.html)
* [TLS 握手优化详解](https://imququ.com/post/optimize-tls-handshake.html)



## 术语解释

### HTTP

HTTP，超文本传输协议，应用层的协议，大部分网站都是通过 HTTP 协议来传输 Web 页面、以及 Web 页面上包含的各种东东（图片、CSS 样式、JS 脚本）。

### SSL/TSL

很多相关的文章都把这两者并列称呼（SSL/TLS），两者可以视作同一个东西的不同阶段：

* `SSL`，`Secure Sockets Layer`，**安全套接层**；它是在上世纪90年代中期，由网景公司设计的。（顺便插一句，网景公司不光发明了 SSL，还发明了很多 Web 的基础设施——比如“CSS 样式表”和“JS 脚本”）
* `TLS`，`Transport Layer Security`，**传输层安全协议**；到了1999年，`SSL` 因为应用广泛，已经成为互联网上的事实标准。IETF 就在那年把 `SSL` 标准化。标准化之后的名称改为 `TLS`


为啥要发明 SSL 这个协议捏？

1. 原先互联网上使用的 HTTP 协议是明文的
2. HTTP 协议，存在很多缺点，
	3. 偷窥（嗅探）：传输内容
	4. 篡改：传输内容

`SSL` 协议，就是为了解决这些问题。

### HTTPS

HTTPS，`HTTP over SSL`，或者 `HTTP over TLS`：

* 通常所说的 HTTPS 协议，说白了就是“**HTTP 协议**”和“**SSL/TLS 协议**”的组合。
* 可以把 HTTPS 大致理解为“HTTP over SSL”或“HTTP over TLS”（反正 SSL 和 TLS 差不多）。

## HTTP 协议的特点

### HTTP 的版本和历史

出现过 3 种 HTTP 协议版本：

1. HTTP 0.9：
	2. 未广泛使用
2. HTTP 1.0：
	3. 广泛使用
	4. 短链接
3. HTTP 1.1：
	1. 广泛使用
	2. 长连接

### HTTP 与 TCP 之间关系

HTTP 是应用层协议，其传输层使用 TCP 协议。

TCP 协议：

1. 面向连接
2. 可靠
3. 数据顺序到达

### HTTP 如何使用 TCP？

使用 TCP 的 2 种方式：

* 短连接：每次都创建一个 TCP 连接，使用完之后就释放；
* 长连接：Keep-Alive，持久连接，一个 TCP 连接建立后，会多次复用，不会使用一次就释放掉；

举例：

短连接：

1. 通过 HTTP 请求，获取网页，会建立一个 TCP 连接，请求到网页内容后，**TCP 连接释放**；
2. 再次请求网页内的 图片和外部 CSS、JS 时，会**重新创建 TCP 连接**；

长连接：

1. 通过 HTTP 请求，获取网页，会建立一个 TCP 连接，请求到网页内容后，**TCP 连接仍然保持**；
2. 再次请求网页内的 图片和外部 CSS、JS 时，会**复用之前 TCP 连接**；

HTTP 如何使用 TCP ？

* HTTP 1.0 使用 TCP 短连接：因为当时网页比较简单（互联网初期）；
* HTTP 1.1 使用 TCP 长连接：通过 keep-alive 字段控制，有一个超时时间，以更好适应网页中包含大量图片以及外部 CSS 和 JS 的情况；

思考：

1. TCP 长连接中，keep-alive 是谁设置的？
2. keep-alive，超时之后，谁负责释放 TCP 连接？
3. 超时时间，同时保存在 client 和 server 侧？



## 参考资料

* [扫盲 HTTPS 和 SSL/TLS 协议[1]：背景知识、协议的需求、设计的难点](https://program-think.blogspot.com/2014/11/https-ssl-tls-1.html)




[NingG]:    http://ningg.github.com  "NingG"