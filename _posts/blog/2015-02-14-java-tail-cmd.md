---
layout: post
title: Java实现tail命令
description: Unix下的tail命令能够实时捕获文件的增量更新，java中如何实现？
category: java
---


## 开篇闲谈

实时捕获文件的新增内容，如何实现？拍拍脑袋，需要借助3个变量：

* File-snapshot-new：文件发生变动后，快速做出的副本；
* File-snapshot-old：文件发生变动后，将File-snapshot-new的内容备份到File-snapshot-old中；
* File-snapshot-delta：File-snapshot-new与File-snapshot-old的差异部分；
* File-current：当前文件内容；

具体过程：

* 初始File-snapshot-old为null；
* 对现有文件做一个副本，File-snapshot-new，并启动Thread将File-snapshot-new与File-napshot-old的差异部分File-snapshot-delta发送出去；
* 一个Thread监听文件的变动（最后修改日期）；
* 如果文件发生变动，立即将File-snapshot-new内容转移到File-snapshot-old中，同时，将File-current内容备份到File-snapshot-new中；
* File-snapshot-delta内容不为空，则将其发送出去；

我x，上面好复杂，不会这么困难吧。抓紧去学习一下别人的思路。


上述整个过程，都在避免一种情况：在发送一个文件新增内容的时候，文件又有新增内容；而最佳的逻辑是：

* 顺序遍历文件内容，在正在读取的位置，打上标记；
* 标记：字符长度，不涉及内容；





## BufferedReader

利用BufferedReader下的`readLine()`方法来实现，示例代码如下：

	public class JavaTail {

		public static void main(String[] args) throws IOException {
			
			String srcFilename = "E:/1.log";
			String charset = "GBK";
			
			InputStream fileInputStream = new FileInputStream(srcFilename);
			Reader fileReader = new InputStreamReader(fileInputStream, charset);
			BufferedReader bufferedReader = new BufferedReader(fileReader);
			
			String singleLine = "";
			while(true){
				if( (singleLine = bufferedReader.readLine()) != null ){
					System.out.println(singleLine);
					continue;
				}
				
				try {
					Thread.sleep(1000L);
				} catch (InterruptedException e) {
					Thread.currentThread().interrupt();
					break;
				}
				
			}
			
			bufferedReader.close();
		}
	}


编写成multi-thread方式：进程中，单独启动一个线程来监听文件，示例代码如下：

	package com.github.ningg.tail;

	import java.io.IOException;
	import java.util.concurrent.Executors;
	import java.util.concurrent.ScheduledExecutorService;
	import java.util.concurrent.TimeUnit;

	public class JavaTail{

		public static void main(String[] args) throws IOException, InterruptedException {
			
			String srcFilename = "E:/2.log";
			String charset = "GBK";
			
			Thread.sleep(5000L);
			
			ScheduledExecutorService executor = Executors.newSingleThreadScheduledExecutor();
			SpoolingRunnable spool = new SpoolingRunnable(srcFilename, charset, true);
			
			executor.scheduleWithFixedDelay(spool, 1, 1, TimeUnit.SECONDS);
			Thread.sleep(20000L);
			
			System.out.println("--------------SHUTDOWN EXECUTOR----------------");
			spool.setKeepReading(false);
			Thread.sleep(20000L);

			System.out.println("-------------- RESTART EXECUTOR----------------");
			spool.setKeepReading(true);
			Thread.sleep(20000L);
			
			System.out.println("--------------SHUTDOWN EXECUTOR----------------");
			spool.setKeepReading(false);
			spool.destroy();
		}
		
	}

以及另一个文件：`SpoolingRunnable.java`：

	package com.github.ningg.tail;

	import java.io.BufferedReader;
	import java.io.FileInputStream;
	import java.io.FileNotFoundException;
	import java.io.IOException;
	import java.io.InputStream;
	import java.io.InputStreamReader;
	import java.io.Reader;
	import java.io.UnsupportedEncodingException;

	public class SpoolingRunnable implements Runnable{

		private String filename;
		private String charset;
		private volatile boolean keepReading;
		
		private BufferedReader bufferedReader = null;
		
		public SpoolingRunnable( String filename, String charset,
				boolean keepReading) {
			this.filename = filename;
			this.charset = charset;
			this.keepReading = keepReading;
		}

		public void run() {
			try {
				if(bufferedReader == null){
					InputStream is = new FileInputStream(filename);
					Reader reader = new InputStreamReader(is, charset);
					bufferedReader = new BufferedReader(reader);
				}
				
				String singleLine = "";
				
				while(keepReading){
					if( (singleLine = bufferedReader.readLine()) != null ){
						System.out.println(singleLine);
						continue;
					}
					
					Thread.sleep(1000L);
				}
				
				System.out.println("-----[stop: keep reading]-----");
				
			} catch (FileNotFoundException e) {
				e.printStackTrace();
			} catch (UnsupportedEncodingException e) {
				e.printStackTrace();
			} catch (IOException e) {
				e.printStackTrace();
			} catch (InterruptedException e) {
				e.printStackTrace();
			}
	//		finally{
	//			Thread.currentThread().interrupt();
	//		}
			
		}

		public void destroy() throws IOException{
			bufferedReader.close();
		}
		
		public String getFilename() {
			return filename;
		}

		public SpoolingRunnable setFilename(String filename) {
			this.filename = filename;
			return this;
		}

		public String getCharset() {
			return charset;
		}

		public SpoolingRunnable setCharset(String charset) {
			this.charset = charset;
			return this;
		}

		public boolean isKeepReading() {
			return keepReading;
		}

		public SpoolingRunnable setKeepReading(boolean keepReading) {
			this.keepReading = keepReading;
			return this;
		}
		
		
	}






**特别说明**：整理java实现tail，最初本意是因为需要在Flume的agent上利用java实现捕获文件增量内容，因为java编写的代码，有了JRE，就可以跨平台；最近事情又有新的进展：

* 当前看来github上，已经有人实现了Flume的tail source，具体在github上搜索`tail flume`即可；
* 学习了一下flume的spooling directory source，其机制可以用于实现tail directory source，并且采用这一方式，能够达到很高的可靠性；
* 下一步打算：基于flume自带的spooling directory source机制，实现tail directory source，并且在github上开源；



利用Flume自带API，实现的java tail功能，源文件`TestLineDeserializer.java`：

	package com.github.ningg.flume.source;

	import java.io.File;
	import java.io.IOException;
	import java.nio.charset.Charset;

	import org.apache.flume.Context;
	import org.apache.flume.Event;
	import org.apache.flume.serialization.DecodeErrorPolicy;
	import org.apache.flume.serialization.DurablePositionTracker;
	import org.apache.flume.serialization.EventDeserializer;
	import org.apache.flume.serialization.EventDeserializerFactory;
	import org.apache.flume.serialization.PositionTracker;
	import org.apache.flume.serialization.ResettableFileInputStream;
	import org.apache.flume.serialization.ResettableInputStream;

	public class TestLineDeserializer {

		public static void main(String[] args) throws IOException, InterruptedException {
			
			String srcFilename = "E:/2.log";
			String metaFilename = "E:/meta.log";
			String charset = "GBK";
			String decodeErrorPolicy = "IGNORE";
			String deserializerType = "LINE";
			Context context = new Context();
			
			
			File srcFile = new File(srcFilename);
			File metaFile = new File(metaFilename);
			
			PositionTracker tracker = DurablePositionTracker.getInstance(metaFile, srcFile.getPath());
			ResettableInputStream in = new ResettableFileInputStream(srcFile, tracker,
											ResettableFileInputStream.DEFAULT_BUF_SIZE, 
											Charset.forName(charset), DecodeErrorPolicy.valueOf(decodeErrorPolicy));
			
			EventDeserializer eventDeserializer = EventDeserializerFactory.getInstance(deserializerType, context, in);
			
			Event event = null;
			String singleLine = "";
			
			
			while(true){
				if ( (event = eventDeserializer.readEvent()) != null){
					singleLine = new String(event.getBody());
					System.out.println(singleLine);
					continue;
				}
				
				Thread.sleep(1000L);
			}
			
			
		}
		
	}









## 参考来源

* [Java IO implementation of unix/linux “tail -f”][Java IO implementation of unix/linux “tail -f”]
* [Listening changes on a text file (Unix Tail implementation with Java)][Listening changes on a text file (Unix Tail implementation with Java)]
* [github-tail source of flume][github-tail source of flume]




[NingG]:    												http://ningg.github.com  "NingG"
[Java IO implementation of unix/linux “tail -f”]:			http://stackoverflow.com/questions/557844/java-io-implementation-of-unix-linux-tail-f
[Listening changes on a text file (Unix Tail implementation with Java)]:	http://en.newinstance.it/2005/11/19/listening-changes-on-a-text-file-unix-tail-implementation-with-java/
[github-tail source of flume]:								https://github.com/search?utf8=%E2%9C%93&q=tail+flume













