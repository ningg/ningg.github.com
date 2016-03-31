---
layout: post
title: Java Socket编程中参数详解
description: Socket、ServerSocket中参数的详细解释
published: true
category: java
---


Java Socket网络编程中涉及的参数详解：

## backlog

backlog：ServerSocket对应的最大的客户端等待队列长度，即，当ServerSocket.accept()所在线程阻塞时，新的Client仍可以与Server建立连接，只是这些连接会被放置在Client等待队列中，backlog参数设定了这一等待队列的最大长度；示例代码如下：

	package top.ningg.java.socket;

	import java.io.BufferedReader;
	import java.io.IOException;
	import java.io.InputStreamReader;
	import java.net.ServerSocket;
	import java.net.Socket;

	public class SocketParams {
		public static void main(String[] args) throws IOException {
			int port = 7777;
			int backlog = 2;
			
			ServerSocket serverSocket = new ServerSocket(port, backlog);
			
			Socket clientSocket = serverSocket.accept();
			System.out.println("Client Socket port: " + clientSocket.getLocalPort());
			
			while(true){
				BufferedReader in = new BufferedReader(new InputStreamReader(clientSocket.getInputStream()));
				System.out.println(in.readLine());
			}
			
		}
	}

这段测试代码在第一次处理一个客户端时，就不会处理第二个客户端，所以除了第一个客户端，其他客户端就是等待队列了。所以这个服务器最多可以同时连接3个客户端，其中2个等待队列。可以telnet localhost 7777测试下。

这个参数设置为-1表示无限制，默认是50个最大等待队列，如果设置无限制，那么你要小心了，如果你服务器无法处理那么多连接，那么当很多客户端连到你的服务器时，每一个TCP连接都会占用服务器的内存，最后会让服务器崩溃的。

* 通常，根据服务器处理能力，设定一个线程池，来进行clientSocket的处理，超过的部分就进行排队（backlog），因为处理能力有限，排队的队列长度也要限制；
* 对于不在排队队列中，已经成功建立的ClientSocket，如果当前处于挂起状态，其仍会收到Client发送来的数据，这些数据缓存在TCP接收缓存区，会压垮服务器。

**思考**：如何调用线程池？单独写一篇博客；


## （todo）















## 参考来源


* [Java网络编程中Socket参数详解][Java网络编程中Socket参数详解]















[NingG]:    http://ningg.github.com  "NingG"


[Java网络编程中Socket参数详解]:		http://blog.csdn.net/jiangwei0910410003/article/details/21021615








