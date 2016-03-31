---
layout: post
title: WebSocket梳理
description: 浏览器与服务器端进行全双工通信，即，任何一方都可以向另一方发送信息
published: true
category: websocket
---

WebSocket，几点：

* 解决什么问题？
* 传统解决方案？
* 什么原理？
* 实例代码？


## 解决什么问题？

针对实时通信的场景*（实时Web应用）*，几点：

* 传统Web中，由Browser主动向Server发送请求，以此获得Server端数据；
* 如果要实现实时通信，实时获取Server端的数据，通常是Client端定期发送HTTP请求，Server端进行响应并返回数据；
* HTTP协议：基于请求/响应模式的、无状态的、应用层协议；

**补充**：HTTP协议为什么不允许Server主动向Client推送数据？如果允许Server向Client主动推送数据，则，Client很容易受到攻击，特别是广告商会将广告信息，强行推送给Client，因此HTTP的单向特性是必要的。

**疑问**：WebSocket只能用于构建实时Web应用吗？WebSocket只能与HTML5结合吗？



WebSocket，是HTML5引入Web的新特性，目标：构建高效的实时Web应用。*（WebSocket是HTML5特有的吗？）*下图展示了Polling和WebSocket两种模式下，Web应用的效率：

![](/images/websocket-intro/latency-comparison.gif)

相对于传统的基于HTTP协议Polling方式构建的Web应用，WebSocket方式构建的Web应用，具有如下优点：

* 节省带宽；*（HTTP协议的HEAD比较大）*
* 节省服务器CPU资源；*（HTTP协议的Polling方式，即使Server没有数据也要接收Request）*


## 传统解决方案

上述构建实时Web应用的场景，传统的解决方案是：轮询、长轮询、流，

### 轮询（Polling）

轮询（Polling）又称定期轮询：Client定期向Server发送请求，以此保持与Server端数据的同步。*（通常使用Ajax技术，局部刷新Web页面）*；**缺点：由于Client定期向Server发送请求，当Server端没有数据更新时，Client仍旧发送请求，这造成带宽的浪费以及Server端CPU的耗费。**

![](/images/websocket-intro/polling.png)

### 长轮询（Long Polling）

长轮询是对普通轮询的改进和提高，目标：降低无效的网络传输。基本原理：Server接收到Client的请求之后，如果没有数据更新，则连接保持一段时间，直到有数据更新或者连接超时，这样可以减少无效的Client与Server之间的交互。实例：WebQQ。

**缺陷**：当Server端数据频繁更新时，Server端必须等待下一个请求到来，才能发送更新的数据，这中间的延迟为 2 x RTT（往返时间），另外，在网络拥塞的情况下，等待时间更久；同时，HTTP的数据包HEAD部分数据量很大（400+Byte），但真正有效的数据很少（10Byte），这样的数据包在网络中周期传输，浪费带宽。

![](/images/websocket-intro/long-polling.png)

### 流（长连接）

流（也称，长连接方式）是指Client在页面内使用一个隐蔽的窗口向Server端发起一个长连接请求。Server端接到这个请求后，进行响应，并且不断更新连接状态，保证连接不过期。如此可以保证Server与Client之间的实时通信。实例：Comet技术*（基于HTTP长连接的Server端Push技术）*。**缺点**：大并发情况下，服务器可能会宕机。


### 小结

HTML5 WebSocket的目标：取代Polling、Comet技术，实现Browser与Server之间实时通信。浏览器通过JavaScript向服务器发出建立 WebSocket 连接的请求，连接建立以后，客户端和服务器端就可以通过 TCP 连接直接交换数据。因为 WebSocket 连接本质上就是一个 TCP 连接，所以在数据传输的稳定性和数据传输量的大小方面，和轮询以及 Comet 技术比较，具有很大的性能优势。

## WebSocket实现原理

### OSI模型、TCP/IP

OSI（Open System Interconnection Reference Model，开放式系统互联通信参考模型），OSI模型分为7层：TCP/IP网络模型，可以看作对OSI模型的简化，具体如下：

![](/images/websocket-intro/osi-tcp-ip.png)

注：HTTP、WebSocket协议，都属于OSI模型的应用层。

### WebSocket、HTTP、TCP

上面提到的应用层协议：HTTP、WebSocket，都是基于TCP协议来传输数据的。使用TCP协议，就遵守TCP协议的三次握手建立连接和四次握手释放连接，只是连接建立之后发送的内容不同，或者断开的时间不同。

![](/images/websocket-intro/tcp-3-4.gif)


WebSocket，依赖HTTP协议进行一次握手，握手成功后，数据就直接从TCP通道传输，与HTTP无关了。

### WebSocket、Socket

Socket不是协议，而是应用层与传输层/传输层之间的抽象接口，此用户向用户屏蔽下层协议的使用细节，更加方便易用。

![](/images/websocket-intro/socket.gif)

WebSocket则是完整的应用层协议；从使用上来说，WebSocket更易用，而Socket更灵活。

### WebSocket、HTML5

WebSocket API是HTML5标准的一部分，但这并不代表 WebSocket 一定要用在 HTML 中，或者只能在基于浏览器的应用程序中使用。实际上，很多语言、框架、服务器都提供了WebSocket的支持，例如：

* 基于Node.js的Socket.io
* Apache 对 WebSocket 的支持： Apache Module mod_proxy_wstunnel
* Nginx 对 WebSockets 的支持： NGINX as a WebSockets Proxy 、 NGINX Announces Support for WebSocket Protocol 、WebSocket proxying

## WebSocket原理

WebSocket是为解决客户端与服务端实时通信而产生的技术。**其本质是先通过HTTP/HTTPS协议进行握手后创建一个用于交换数据的TCP连接，此后服务端与客户端通过此TCP连接进行实时通信**。

**Tomcat 7.0.27开始支持WebSocket服务**，在tomcat webapps/examples目录下有关于websocket的示例及源码，有兴趣的可以自行查看。
WebSocket规范当前还没有正式版本，草案变化也较为迅速。Tomcat7当前支持 RFC6455 定义的WebSocket，而RFC 6455目前还未成型，将来可能会修复一些Bug，甚至协议本身也可能会产生一些变化。**RFC6455定义的WebSocket协议由握手和数据传输两个部分组成**：

### 握手信息格式

首先是通过握手信息建立TCP链接，为后续的信息传输做好准备。

来自**客户端**的握手信息类似如下：

	GET /chat HTTP/1.1
	Host: server.example.com
	Upgrade: websocket
	Connection: Upgrade
	Sec-WebSocket-Key: dGhlIHNhbXBsZSBub25jZQ==
	Origin: http://example.com
	Sec-WebSocket-Protocol: chat, superchat
	Sec-WebSocket-Version: 13

**服务器端**的握手信息类似如下：

	HTTP/1.1 101 Switching Protocols
	Upgrade: websocket
	Connection: Upgrade
	Sec-WebSocket-Accept: s3pPLMBiTxaQ9kYGzzhZRbK+xOo=
	Sec-WebSocket-Protocol: chat

### 传输信息格式

一旦客户端和服务端都发送了握手信息并且成功握手，则数据传输部分将开始。数据传输对客户端和服务端而言都是一个**双工通信通道**，客户端和服务端来回传递的数据称之为“消息”。

客户端通过WebSocket URI发起WebSocket连接，WebSocket URIs模式定义如下:

	ws-URI = "ws:" "//" host [ ":" port ] path [ "?" query ]
	wss-URI = "wss:" "//" host [ ":" port ] path [ "?" query ]


ws是普通的WebSocket通信协议，而wss是安全的WebSocket通信协议(就像HTTP与HTTPS之间的差异一样)。在缺省情况下，ws的端口是80而wss的端口是443(与HTTP/HTTPS是相同的嘛！)。当然也可以修改它的端口号，若改为8000，则形式如：

	ws://localhost:8000/examples/websocket/chat  

**建立连接后，随后通过socket.send(message);即可实现消息的发送和接收。**


### 优势所在

WebSocket的优势：

* 服务器与客户端之间交换的标头信息很小，大概只有2字节； 
* 客户端与服务器都可以主动传送数据给对方，真正的全双工；
* 不用频率创建TCP请求及销毁请求，减少网络带宽资源的占用，同时也节省服务器资源；

## WebSocket实例

Tomcat7提供的与WebSocket相关的类均位于包org.apache.catalina.websocket之中，Servlet处理类以org.apache.catalina.websocket.WebSocketServlet作为它的父类。

WebSocketServlet：提供遵循RFC6455的WebSocket连接的Servlet基本实现。客户端使用WebSocket连接服务端时，需要将WebSocketServlet的子类作为连接入口。同时，该子类应当实现WebSocketServlet的抽象方法createWebSocketInbound，以便创建一个inbound实例(MessageInbound或StreamInbound)。

一个标准的websocket servlet如下所示，**其核心逻辑是在收到客户端发来的消息后立即将其发回客户端**：


（TODO）











## 参考来源

* [Socket 与 WebSocket][Socket 与 WebSocket]
* [WebSocket官网][WebSocket官网]
* [WebSocket（2）--为什么引入WebSocket协议][WebSocket（2）--为什么引入WebSocket协议]
* [初探WebSocket][初探WebSocket]
* [WebSocket协议（IERF）][WebSocket协议（IERF）]
* [WebSocket 是什么原理？为什么可以实现持久连接？][WebSocket 是什么原理？为什么可以实现持久连接？]





[NingG]:    http://ningg.github.com  "NingG"



[Socket 与 WebSocket]:							http://zengrong.net/post/2199.htm/comment-page-1
[WebSocket官网]:								http://www.websocket.org/quantum.html
[WebSocket（2）--为什么引入WebSocket协议]:		http://blog.csdn.net/yl02520/article/details/7298309
[初探WebSocket]:								http://itweige.com/tomcat-websocket/
[WebSocket协议（IERF）]:						http://tools.ietf.org/html/rfc6455
[WebSocket 是什么原理？为什么可以实现持久连接？]:		http://www.zhihu.com/question/20215561


