---
layout: post
title: Java Socket梳理
description: socket通信基本过程、长连接、短连接
published: true
category: java
---


## 长连接、短连接

### 短连接


连接->传输数据->关闭连接


### 长连接

一般长连接相对短连接而言的，长连接在传输完数后不关闭连接，而不断的发送包保持连接等待处理下一个数据包。

连接->传输数据->保持连接 -> 传输数据-> 。。。 ->关闭连接。

### 适用场景

短连接、长连接的适用场景如下：

短连接：连接数多、每次传输数据量少，例如，WEB网站的http服务采用短连接，因为WEB网站的连接为频繁连接，数量成千上万，而长连接会耗费更多资源，短连接更合适；
长连接：连接数少、传输数据量大，例如，数据库连接使用长连接，如果用短连接频繁通信会造成socket错误，而且频繁的socket创建也是对资源的浪费；



## Socket通信

对于即时类应用或者即时类游戏，HTTP协议很多时候无法满足我们的需求。这时，Socket对于我们来说就比较使用。Socket实际上以一个IP:PORT，是通信句柄。

### 原理


Java Socket原理类似于打电话过程：

1. 前提条件：通话两端都有一个电话，在上诉模型中就是Sokcet模型；
1. 接通路线：一方拔打电话，试图建立连接，在上述模型中就是客户端建立Java Socket对象；另一方随时监听有没有呼叫，当有呼叫到来时，摘机，在上述模型中就是在服务器端建立一个Java Socket对象，然后用其accept()方法监听客户端的连接请求，当有连接请求时accept方法返回客户端的Socket，于是双方就建立起连接；
1. 进行通话：双方通话，过程中双方都可以说和听，在上述模型中，每个Socket可以利用输入输出流进行读和写两种操作；在电话中一方听到的是对方说出的，反之亦然；上述模型中，一方读出的也是对方写入的，而写入的则是对方要读出的
1. 挂断


### 建立Socket通信模型

首先，在服务器端建立一个ServerSocket对象，用于监听客户端的连接请求：

	ServerSocket server；
	server＝new ServerSocket(5432);

在服务器端建立ServerSocket对象时必须进行异常处理，以便程序出错时及时作出响应。生成ServerSocket对象时必须选择一个端口注册，以和其它服务器程序分开，使互不干扰。应使用1024以上的端口进行通信，以免和常规通信发生端口冲突。

其次，在服务器端调用ServerSocket的accept（）方法进行监听，等待其它程序的连接请求。在连接请求收到之前一直阻塞调用线程，当有一个连接请求时，返回请求连接的Java Socket对象：

	Socket socket；  
	socket＝server.accept() 

当接到一个连接请求时，accept方法返回客户端的socket对象，于是连接成功。正常情况下，通过交换，由另外的线程去处理该连接，而server释放出来继续监听下一个连接请求。

最后，在客户端建立一个Java Socket对象，请求建立连接：

	Socket socket；  
	socket＝new Socket("localhost", 5432);  

在客户端建立Java Socket对象时也必须时行异常处理，主机名和端口号与连接的服务器名和提供该服务的服务程序的监听端口必须一致。

Socket与ServerSocket的交互过程如下：

![](/images/java-socket/socket-serversocket.png)


## Socket


### 构造函数

Socket的构造函数如下：

	Socket()
	Socket(InetAddress address, int port)throws UnknownHostException, IOException
	Socket(InetAddress address, int port, InetAddress localAddress, int localPort)throws IOException
	Socket(String host, int port)throws UnknownHostException, IOEx
	Socket(String host, int port, InetAddress localAddress, int localPort)throws IOExceptionception
 
除去第一种不带参数的之外，其它构造函数会尝试建立与服务器的连接。如果失败会抛出IOException错误。如果成功，则返回Socket对象。
InetAddress是一个用于记录主机的类，其静态getHostByName(String msg)可以返回一个实例，其静态方法getLocalHost()也可以获得当前主机的IP地址，并返回一个实例。Socket(String host, int port, InetAddress localAddress, int localPort)构造函数的参数分别为目标IP、目标端口、绑定本地IP、绑定本地端口。
 
### Socket方法

Socket的方法如下：

* getInetAddress();    　远程服务端的IP地址
* getPort();    　　　　远程服务端的端口
* getLocalAddress()    本地客户端的IP地址
* getLocalPort()    　本地客户端的端口
* getInputStream();   获得输入流
* getOutStream();    获得输出流

值得注意的是，在这些方法里面，最重要的就是`getInputStream()`和`getOutputStream()`了。
 
### Socket状态

Socket几个方法：

* isClosed();   //连接是否已关闭，若关闭，返回true；否则返回false
* isConnected();　//如果曾经连接过，返回true；否则返回false
* isBound();    //如果Socket已经与本地一个端口绑定，返回true；否则返回false

如果要确认Socket的状态是否处于连接中，下面语句是很好的判断方式。

	boolean isConnection=socket.isConnected() && !socket.isClosed();   //判断当前是否处于连接

### 半关闭Socket

很多时候，我们并不知道在获得的输入流里面到底读多长才结束。下面是一些比较普遍的方法：

* 自定义标识符（譬如下面的例子，当受到“bye”字符串的时候，关闭Socket）
* 告知读取长度（有些自定义协议的，固定前几个字节表示读取的长度的）
* 读完所有数据
* 当Socket调用close的时候关闭的时候，关闭其输入输出流

半关闭Socket，是指一方shutdown read，这样，另一方就不能write了，但此时，另一方仍可以read。



## ServerSocket

### 构造函数

ServerSocket的构造函数：

	ServerSocket()throws IOException
	ServerSocket(int port)throws IOException
	ServerSocket(int port, int backlog)throws IOException
	ServerSocket(int port, int backlog, InetAddress bindAddr)throws IOException
 
注意点：

1. port服务端要监听的端口；backlog客户端连接请求的队列长度；bindAddr服务端绑定IP
1. 如果端口被占用或者没有权限使用某些端口会抛出BindException错误。譬如1~1023的端口需要管理员才拥有权限绑定。
1. 如果设置端口为0，则系统会自动为其分配一个端口；
1. bindAddr用于绑定服务器IP，为什么会有这样的设置呢，譬如有些机器有多个网卡。
1. ServerSocket一旦绑定了监听端口，就无法更改。ServerSocket()可以实现在绑定端口前设置其他的参数。
 
### 单线程的ServerSocket

	public void service(){
		while(true){
			Socket socket=null;
			try{
				socket=serverSocket.accept();//从连接队列中取出一个连接，如果没有则等待
				System.out.println("新增连接："+socket.getInetAddress()+":"+socket.getPort());
				...//接收和发送数据
			}catch(IOException e){e.printStackTrace();}finally{
				try{
					if(socket!=null) socket.close();//与一个客户端通信结束后，要关闭Socket
				}catch(IOException e){e.printStackTrace();}
			}
		}
	}
 
### 多线程的ServerSocket

多线程的好处不用多说，而且大多数的场景都是多线程的，无论是我们的即时类游戏还是IM，多线程的需求都是必须的。下面说说实现方式：

* 主线程会循环执行ServerSocket.accept()；
* 当拿到客户端连接请求的时候，就会将Socket对象传递给多线程，让多线程去执行具体的操作；

实现多线程的方法要么继承Thread类，要么实现Runnable接口。当然也可以使用线程池，但实现的本质都是差不多的。
 
这里举例：
下面代码为服务器的主线程。为每个客户分配一个工作线程：

	public void service(){
		while(true){
			Socket socket=null;
			try{
				socket=serverSocket.accept();      //主线程获取客户端连接
				Thread workThread=new Thread(new Handler(socket)); //创建线程
				workThread.start();     //启动线程
			}catch(Exception e){
				e.printStackTrace();
			}
		}
	} 

当然这里的重点在于如何实现Handler这个类。Handler需要实现Runnable接口：

	class Handler implements Runnable{
		private Socket socket;
		public Handler(Socket socket){
			this.socket=socket;
		}
		
		public void run(){
			try{
				System.out.println("新连接:"+socket.getInetAddress()+":"+socket.getPort());
				Thread.sleep(10000);
			}catch(Exception e){e.printStackTrace();}finally{
				try{
					System.out.println("关闭连接:"+socket.getInetAddress()+":"+socket.getPort());
					if(socket!=null)socket.close();
				}catch(IOException e){
					e.printStackTrace();
				}
			}
		}
	}

当然实现多线程还有其它的方式，譬如线程池，或者JVM自带的线程池都可以。这里就不说明了。

![](/images/java-socket/socket-multi-thread.jpg)


## 完整Demo

此处的Demo代码已经提交到GitHub上simple-web-demo下learn-java-basic工程中top.ningg.java.socket包下。

### SocketOfServer

SocketOfServer.java文件，服务器端监听Socket连接：

	package top.ningg.java.socket;

	import java.io.IOException;
	import java.net.ServerSocket;
	import java.net.Socket;

	public class SocketOfServer {

		public SocketOfServer() throws IOException {

			int clientNum = 0;
			
			ServerSocket server = null;
			server = new ServerSocket(7777);
			System.out.println("Server started.");

			while (true) {
				clientNum++;
				
				Socket socket = server.accept();
				new ServerHandler(socket).start();
				
				System.out.println("Client Num is: " + clientNum);
			}

		}
		
		public static void main(String[] args) throws IOException {
			new SocketOfServer();
		}
	}

### ServerHandler

SocketOfServer.java文件，服务器端处理socket连接：

	package top.ningg.java.socket;

	import java.io.BufferedReader;
	import java.io.IOException;
	import java.io.InputStreamReader;
	import java.io.PrintWriter;
	import java.net.Socket;

	public class ServerHandler extends Thread{

		private Socket socket;
		
		public ServerHandler(Socket socket){
			this.socket = socket;
		}
		
		public void run() {
			try {
				BufferedReader in = new BufferedReader(new InputStreamReader(socket.getInputStream()));
				PrintWriter out = new PrintWriter(socket.getOutputStream());
				BufferedReader sysin = new BufferedReader(new InputStreamReader(System.in));
				String singleLine = null;
				
				System.out.println("[Client]: " + in.readLine());
				singleLine = sysin.readLine();
				
				while (!"bye".equals(singleLine)) {
					out.println(singleLine);
					out.flush();
					
					System.out.println("[Server]: " + singleLine);
					System.out.println("[Client]: " + in.readLine());

					singleLine = sysin.readLine();
				}
				
				out.close();
				in.close();
				socket.close();
				
				sysin.close();
				
			} catch (IOException e) {
				e.printStackTrace();
			}
			
		}
		
	}

### SocketOfClient

SocketOfClient.java客户端，向服务器端发起socket连接：

	package top.ningg.java.socket;

	import java.io.BufferedReader;
	import java.io.IOException;
	import java.io.InputStreamReader;
	import java.io.PrintWriter;
	import java.net.Socket;
	import java.net.UnknownHostException;

	public class SocketOfClient {

		public SocketOfClient() {
			try {
				Socket socket = new Socket("localhost", 7777);

				System.out.println("Established a connection...");

				BufferedReader sysin = new BufferedReader(new InputStreamReader(System.in));
				PrintWriter out = new PrintWriter(socket.getOutputStream());
				BufferedReader in = new BufferedReader(new InputStreamReader(socket.getInputStream()));
				
				String singleLine = null;
				String singleLineFromServer = null;
				singleLine = sysin.readLine();
				System.out.println("[Client]: " + singleLine);
				
				while(!"bye".equals(singleLineFromServer)){
					out.println(singleLine);
					out.flush();

					singleLineFromServer = in.readLine();
					System.out.println("[Server]: " + singleLineFromServer);

					singleLine = sysin.readLine();
					System.out.println("[Client]: " + singleLine);
				}
				
				out.close();
				in.close();
				socket.close();
				
				sysin.close();

			} catch (UnknownHostException e) {
				e.printStackTrace();
			} catch (IOException e) {
				e.printStackTrace();
			}
		}
		
		public static void main(String[] args) {
			new SocketOfClient();
		}
	}




## 参考来源


* [Java Socket对象原理的详细介绍][Java Socket对象原理的详细介绍]
* [Socket和ServerSocket学习笔记][Socket和ServerSocket学习笔记]
* [Java socket的一个完整实例][Java socket的一个完整实例]











[NingG]:    http://ningg.github.com  "NingG"



[Java Socket对象原理的详细介绍]:				http://developer.51cto.com/art/201003/189764.htm
[Socket和ServerSocket学习笔记]:					http://www.cnblogs.com/rond/p/3565113.html
[Java socket的一个完整实例]:					http://blog.csdn.net/karem/article/details/4639039





