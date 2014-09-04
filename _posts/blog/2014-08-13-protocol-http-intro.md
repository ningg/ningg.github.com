---
layout: post
title: HTTP协议
description: 打开浏览器，输入一个网址，回车，一个HTTP请求就发送出去了，等待HTTP响应返回，就看到网上的内容了
categories: Protocol HTTP
---

##背景

> 最近要用java来构造HTTP请求、接收HTTP响应，并从HTTP响应中获取尽可能多的上下文信息，自己每次都查看JAVA的API，不过结果总是浑浑噩噩的感觉，因为自己并不确定HTTP响应中包含了哪些详细的信息，更何谈要提取这些信息了。

（备注：不要求大而全，而要求先能够解决问题）

##HTTP协议的由来

OSI模型把网络通信分成七层：物理层、数据链路层、网络层、传输层、会话层、表示层和应用层，对于开发网络应用人员来说，一般把网络分成五层，这样比较容易理解。这五层为：物理层、数据链路层、网络层、传输层和应用层（最顶层），如下图所示：

网络中的计算机互相通信就是实现了层与层之间的通信，要实现层与层之间的通信，则各层都要遵守规则，这样才能完成更好的通信， 我们就把它们之间遵守的规则就叫个“协议”，然而网络上的五层之间遵守的协议不一样，每层都有各自的协议。下面就对各层进行简要介绍：

__物理层__

物理层是五层模型中的最底层，物理层为计算机之间的数据通信提供了传输媒体和互连设备的标准，为数据传输提供了可靠的环境，媒体包括电缆、光纤、无线信道等，互连设备指是计算机和调制解调器之间的互连设备，如各种插头、插座等。该层的作用是透明的传输比特流（即二进制流），为数据链路层提供一个传输原始比特流的物理连接。

总结一下：

* 目标：透明地传输bit。
* 传输单元：bit。

__数据链路层__

数据链路层是模型中的第2层，该层对接受到物理层传输过来的比特流进行分组，一组电信号构成的数据包，就叫做"帧"，数据链链路层就是来传输以"帧"为单位的数据包，把数据传递给上一层（网络层），帧数据由两部分组成：帧头和帧数据，帧头包括接受方物理地址（就是网卡的地址）和其他的网络信息，帧数据就是要传输的数据体。数据帧的最长为1500字节，如果数据很长，就必须分割成多个帧进行发送。

总结一下：

* 目标：通过`MAC地址`来标识设备，并且在两个相邻设备之间，透明、可靠地传输`数据帧`。
* 传输单元：`帧`，包含帧头和帧数据。

__网络层__

该层通过寻址（寻址地址）来建立两个节点之间的连接，大家都知道我们的电脑连接上网络后都一个IP地址，我们可以通过IP地址来确定不同的计算机是否在同一个子网内。如果我们的电脑连接上网络后就有两种地址：物理地址和网络地址（IP地址），网络上的计算机要通信，必须要知道通信的计算机“在哪里”， 首先通过网络地址来判断是否处于同一个子网，然后再对物理地址（MAC）地址进行处理，从而准确确定要通信计算机的位置。

在网络层中有我们熟悉的IP协议（即规定网络地址的协议），目前广泛采用的是IP协议第四版（IPv4）,这个版本规定，网络地址由32位二进制位组成。

网络层中以IP数据包的形式来传递数据，IP数据包也包括两部分：头（Head）和数据(Data)，IP数据包放进数据帧中的数据部分进行传输。

总结一下：

* 目标：通过`IP地址`来标识网络节点，并且在网络中任意两个节点之间，透明、可靠地传输`IP数据包`。
* 传输单元：`IP数据包`，包含包头和数据。


__传输层__

通过MAC和IP地址，我们可以找到互联网上任意两台主机来建立通信。然而这里有一个问题，找到主机后，主机上有很多程序都需要用到网络，比如说你在一边听歌和好用QQ聊天，当网络上发送来一个数据包时，是怎么知道它是表示聊天的内容还是歌曲的内容的， 这时候就需要一个参数来表示这个数据包是发送给那个程序（进程）来使用的，这个参数我们就叫做`端口号`，主机上用端口号来标识不同的程序（进程），端口是0到65535之间的一个整数，0到1023的端口被系统占用，用户只能选择大于1023的端口。

传输层的功能就是建立端口到端口的通信，网络层就是建立主机与主机的通信，这样如果我们确定了主机和端口，这样就可以实现程序之间的通信了。我们所说的Socket编程就是通过代码来实现传输层之间的通信。因为初始化Socket类对象要指定IP地址和端口号。

在传输层有两个非常重要的协议：UDP 协议和TCP协议

采用UDP协议话传输的就是UDP数据包，同样UDP数据包也由头和数据两部分组成，头部分主要标识了发送端口和接受端口，数据部分就是具体的内容信息。同样UDP数据包是放入IP数据包中的"数据"部分，IP数据包再放入数据帧中在网络上传输。

由于UDP协议的可靠性差（数据发送后无法确定对方是否收到），所以又定义了一个可靠性高的协议——TCP协议，TCP协议采取了握手的方式要确保对方收到了数据。

总结一下：

* 目标：通过`IP地址：端口号`来标识网络节点上的一个进程，并在网络中任意两个节点上的两个进程之间，实现消息的透明传输。
* 传输单元：数据包，TCP数据包或者UDP数据包。

__应用层__

应用层是模型中的最顶层，是用户与网络的接口，HTTP协议就属于这一层。HTTP协议能做什么？
很多人首先一定会想到：浏览网页。没错，浏览网页是HTTP的主要应用，但是这并不代表HTTP就只能应用于网页的浏览。HTTP是一种协议，只要通信的双方都遵守这个协议，HTTP就能有用武之地。比如咱们常用的QQ，迅雷这些软件，都会使用HTTP协议(还包括其他的协议)。需要说明的是，应用层HTTP协议传输的数据，在传输层，是由TCP协议承载的。

数据流动的时候，发送端，应用数据从上层向下，层层打包（添加包头），接收端，数据从下层向上，层层解包（去除包头）。

（应用层到底是什么？应用层与端口之间什么关系？会话层、表示层、应用层之间又有什么差异？）

##HTTP协议如何工作

利用HTTP协议传输数据时，其基本过程：Client发送HTTP请求，Server返回HTTP响应；如下图所示：


（插入一个图片）


###Request\Response格式

详细信息请参考：[RFC2616].

关于HTTP headers的简要汇总和介绍，请参看：[Quick reference to HTTP headers]

####Request####

Request格式：

（插入一张图片：Request格式）

备注：

1. <CR><LF>为回车换行，其中：CR，Carriage Return，回车，打字机头部位置；LF，Line Feed，换行，打字机向下换一行；
2. `Null Line`中必须只有<CR><LF>而无其他空格；
3. 在HTTP/1.1协议中，所有的`Headers`中，除Host外，都是可选的；

Requset实例：

	GET http://www.cnblogs.com/gpcuster/ HTTP/1.1
	Host: www.cnblogs.com
	Proxy-Connection: keep-alive
	Cache-Control: max-age=0
	Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8
	User-Agent: Mozilla/5.0 (Windows NT 5.1) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/36.0.1985.125 Safari/537.36
	Referer: http://www.baidu.com/s?wd=http%3A%2F%2Fwww.cnblogs.com%2Fgpcuster%2F&rsv_spt=1&issp=1&rsv_bp=0&ie=utf-8&tn=baiduhome_pg&rsv_n=2&rsv_sug3=1&rsv_sug4=271&inputT=2186
	Accept-Encoding: gzip,deflate,sdch
	Accept-Language: zh-CN,zh;q=0.8,en;q=0.6
	Cookie: __gads=ID=d58f6aafc2b1682a:T=1399182693:S=ALNI_MbGQmpINTGEw1DKhg8-v-WGcqmDGg; CNZZDATA4902471=cnzz_eid%3D780096130-1402377079-http%253A%252F%252Fwww.baidu.com%252F%26ntime%3D1403490466; CNZZDATA3980738=cnzz_eid%3D371156967-1402987944-http%253A%252F%252Fwww.baidu.com%252F%26ntime%3D1404384515; CNZZDATA1923552=cnzz_eid%3D857445479-1402888944-http%253A%252F%252Fwww.cnblogs.com%252F%26ntime%3D1405079579; AJSTAT_ok_times=5; gs_u_GSN-690926-A=567797657:3115:11443:1407743725372; _ga=GA1.2.1054927095.1399182860; __utma=226521935.1054927095.1399182860.1407743656.1407743991.33; __utmb=226521935.2.10.1407743991; __utmc=226521935; __utmz=226521935.1407743991.33.27.utmcsr=baidu|utmccn=(organic)|utmcmd=organic|utmctr=http%3A%2F%2Fwww.cnblogs.com%2Fgpcuster%2F
	If-Modified-Since: Mon, 11 Aug 2014 07:59:18 GMT

	
####Response####
	
Response格式：

（插入一张图片：Response格式）

	HTTP/1.1 200 OK
	Date: Mon, 11 Aug 2014 07:59:41 GMT
	Content-Type: text/html; charset=utf-8
	Transfer-Encoding: chunked
	Proxy-Connection: keep-alive
	Vary: Accept-Encoding
	Cache-Control: private, max-age=10
	Expires: Mon, 11 Aug 2014 07:59:33 GMT
	Last-Modified: Mon, 11 Aug 2014 07:59:23 GMT
	X-UA-Compatible: IE=10
	Content-Encoding: gzip

####常用的Headers####

（doing...）

参考：

http://blog.csdn.net/adparking/article/details/7265496
http://blog.csdn.net/kfanning/article/details/6062118
http://www.cnblogs.com/loveyakamoz/archive/2011/07/22/2113614.html
http://blog.sina.com.cn/s/blog_5dd2af0901012oko.html
http://canrry.iteye.com/blog/1331292


###建立连接的方式###

HTTP支持2种建立连接的方式：非持久连接和持久连接（HTTP 1.0 默认：持久连接的带流水线方式）

####非持久连接####

让我们查看一下非持久连接情况下，从Server到Client传送一个Web页面的步骤。假设该页面由：1个基本HTML文件和10个JPEG图像构成，而且所有这些对象都存放在同一台服务器中。再假设该基本HTML文件的URL为：`gpcuster.cnblogs.com/index.html`。

下面是具体步骡:

1. `HTTP Client`初始化一个与`HTTP Server`之间的TCP连接。`HTTP Server`使用默认端口号80监听来自`HTTP Client`的连接建立请求。
2. `HTTP Client`经由与TCP连接相关联的本地套接字，发出—个HTTP请求消息。这个消息中包含路径名/somepath/index.html。
3. `HTTP Server` 经由与TCP连接相关联的本地套接字，接收这个请求消息，再从服务器主机的内存或硬盘中取出对象/somepath/index.html，经由同一个套接字发出包含该对象的响应消息。
4. `HTTP Server`告知TCP关闭这个TCP连接(不过TCP要到客户收到刚才这个响应消息之后才会真正终止这个连接)。
5. `HTTP Client`经由同一个套接字接收这个响应消息，TCP连接随后终止。
6. HTTP响应中，所封装的对象是一个HTML文件。`HTTP Server`从响应中取出这个HTML文件，加以分析后发现其中有10个JPEG对象的引用。
7. `HTTP Client`针对每一个JPEG对象引用，重复步骡1-5。

上述步骤之所以称为`非持久连接`，原因是每次`HTTP Server`返回一个HTTP响应后，相应的TCP连接就被关闭，即，每个TCP连接只用于传输一个请求消息和一个响应消息。针对上述例子，用户每请求一次那个web页面，就反复建立、释放了11个TCP连接。

关于非持久连接，总结一下：

* HTTP请求之前，建立TCP连接，HTTP响应之后，释放TCP连接；
* 每个TCP连接只承载一组HTTP请求和响应消息；

备注：

* 名词`套接字`socket是什么？
* TCP连接建立时，有3次握手，详细过程；
* TCP连接释放时，也有4次握手，详细过程；

####持久连接####


`非持久连接`有几点效率问题：

1. 每个等待请求的对象，都需要建立并维护一个独立的TCP连接；对于每个这样的连接，TCP得在客户端和服务器端分配TCP缓冲区，并维持TCP变量。对于有可能同时为来自数百个不同客户的请求提供服务的web服务器来说，这会严重增加其负担。
2. 如前所述，每个对象都有2个RTT的响应延长——一个RTT用于建立TCP连接，另—个RTT用于请求和接收对象。
3. 每个对象都受TCP慢启动影响，因为每个TCP连接都有一个慢启动阶段。
4. *（优点）*也有优势：并行TCP连接的使用，能够部分减轻RTT延迟和慢启动延迟的影响。

为解决非持久连接情况下，反复建立、释放TCP连接时，所产生的资源占用、效率低下的问题，提出了`持久连接`，其核心：

1. `HTTP Server`返回一个HTTP响应之后，TCP连接保持存活一段时间，用于承载后续的其他HTTP请求/响应;
2. TCP连接的存活时间是可以设定的;
3. 超过存活时间之后，TCP连接自动释放；

持久连接分为`不带流水线(without pipelining)`和`带流水线(with pipelining)`两个版本。

不带流水线的持久化连接，特点如下：

1. Client只在收到前一个请求的响应后才发出新的请求，这种情况下，web页面所引用的每个对象(上例中的10个图像)都经历1个RTT的延迟，用于请求和接收该对象；
2. 服务器返回一个响应后，开始等待下一个请求，而这个新请求却不能马上到达，这段时间服务器资源便闲置了；

带流水线的持久化连接，特点如下：

1. HTTP/1.1的默认模式；
2. HTTP Client每碰到一个对象引用，就立即发出一个请求（如果没有可用的TCP连接，则新建一个），`HTTP Server`每收到一个请求，就立即返回一个响应；
3. 所有引用到的对象一共只经历1个RTT的延迟(而不是像不带流水线的版本那样，每个引用到的对象都各有1个RTT的延迟)；
4. 带流水线的持久连接中服务器空等请求的时间比较少；

###缓存机制###

HTTP/1.1中缓存机制主要目标：提高页面访问速度；实现途径，有两条：

1. 减少Client发送请求的次数：Client本地缓存页面，发送请求之前先检查一下，当前缓存页面是否`过期（expiration）`；
2. Server只发送局部响应信息：即，Server不返回完整的响应信息，以此减少网络带宽的占用，`验证（validation）`机制能够实现此目标；

实际上，HTTP定义了3中缓存机制：

* __Freshness__ allows a response to be used without re-checking it on the origin server, and can be controlled by both the server and the client. For example, the Expires response header gives a date when the document becomes stale, and the Cache-Control: max-age directive tells the cache how many seconds the response is fresh for.
* __Validation__ can be used to check whether a cached response is still good after it becomes stale. For example, if the response has a Last-Modified header, a cache can make a conditional request using the If-Modified-Since header to see if it has changed.
* __Invalidation__ is usually a side effect of another request that passes through the cache. For example, if URL associated with a cached response subsequently gets a POST, PUT or DELETE request, the cached response will be invalidated.

关于web缓存方面的内容可以参考：Caching Tutorial for Web Authors and Webmasters（[英文版](https://www.mnot.net/cache_docs/#DEFINITION)）（[中文版](http://www.chedong.com/tech/cache_docs.html)）

##基于HTTP的应用##

###HTTP代理###

（doing...）

参考：[浅析HTTP协议]

1. 透明代理
2. 非透明代理
3. 反向代理



###多线程下载###

（doing...）

基本过程如下：

* 下载工具开启多个线程，来发出HTTP请求；
* 每个HTTP请求只请求资源文件的一部分：Content-Range:bytes 20000-40000/47000
* 合并每个线程下载的文件

###HTTPS传输协议原理###

（doing...）

参考：[浅析HTTP协议]

###WEB开发过程中常用的Request Methods###

（doing...）

参考：[浅析HTTP协议]

* HEAD
	*（Head方法）要求响应与相应的GET请求的响应一样，但是没有的响应体（response body）。这用来获得响应头（response header）中的元数据信息（meta-infomation）有（很）帮助，（因为）它不需要传输所有的内容。
* TRACE
	*（Trace方法告诉服务器端）返回收到的请求。客户端可以（通过此方法）察看在请求过程中中间服务器添加或者改变哪些内容。
* OPTIONS
	* 返回服务器（在指定URL上）支持的HTTP方法。通过请求“*”而不是指定的资源，这个方法可以用来检查网络服务器的功能。
* CONNECT
	* 将请求的连接转换成透明的TCP/IP通道，通常用来简化通过非加密的HTTP代理的SSL-加密通讯（HTTPS）。

###用户与服务器交互###

（doing...）

参考：[浅析HTTP协议]

1. 身份认证；
2. cookie；
3. 待条件的GET；

	
##java中的HTTP协议

（doing...）



###java中HTTP协议


（主要两种方式：java api 和 http-common.jar?）


###servlet中HTTP协议




##参考来源

1. [W3C: HTTP (HTTP Activity statement)]
2. [W3C中文版简介]
3. [HTTP协议原理解析第一篇](http://www.cnblogs.com/qiqibo/p/3143964.html)
4. [浅析HTTP协议](http://www.cnblogs.com/gpcuster/archive/2009/05/25/1488749.html)
5. [面向站长和网站管理员的Web缓存加速指南-翻译](http://www.chedong.com/tech/cache_docs.html)
6. [RFC2616]
7. [Quick reference to HTTP headers]
8. [O'Reilly - HTTP Pocket Reference]
9. [Sams - HTTP Developers Handbook]

##附录

对与几个名词/组织的简介

###W3C
万维网联盟（World Wide Web Consortium，简称W3C）创建与1994年，是Web技术领域，影响力较强的国际中立性，技术标准机构。其致力于开发协议、标准、指南，来确保Web的长期发展。详细信息参考：[W3C: HTTP (HTTP Activity statement)]。

###IETF
互联网工程任务组（Internet Engineering Task Force，简称IETF）成立于1985年底，是全球互联网领域，极具权威的技术标准化组织，主要任务是负责互联网相关技术规范的研发和制定，当前绝大多数互联网技术标准都出自IETF。详细信息参考：[IETF]。


###RFC

IETF（互联网工程任务组）产生两种文件，一个叫Internet Draft，即"互联网草案"，另一个叫RFC（Request For Comments，意见征求书、请求注解书），RFC相对Draft更为正式，一般情况下，RFC文档发布后，其内容不再做变动。
 
[W3C: HTTP (HTTP Activity statement)]:	http://www.w3.org/Protocols/
[W3C中文版简介]:						http://www.chinaw3c.org/about.html
[IETF: HTTP]:							http://datatracker.ietf.org/wg/httpbis/charter/
[IETF]:									http://www.ietf.org/
[RFC2616]:								http://tools.ietf.org/html/rfc2616
[Quick reference to HTTP headers]:		http://www.cs.tut.fi/~jkorpela/http.html
[浅析HTTP协议]:							http://www.cnblogs.com/gpcuster/archive/2009/05/25/1488749.html
[O'Reilly - HTTP Pocket Reference]:		
[Sams - HTTP Developers Handbook]:		
