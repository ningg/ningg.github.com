---
layout: post
title: Java实现tail命令
description: Unix下的tail命令能够实时捕获文件的增量更新，java中如何实现？
category: java
---


##开篇闲谈

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


上述整个过程，都在避免，在发送一个文件新增内容的时候，文件又有新增内容；而最佳的逻辑是：

* 顺序遍历文件内容，在正在读取的位置，打上标记；
* 标记：字符长度，不涉及内容；





##BufferedReader

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



















##参考来源








[NingG]:    												http://ningg.github.com  "NingG"
[Java IO implementation of unix/linux “tail -f”]:			http://stackoverflow.com/questions/557844/java-io-implementation-of-unix-linux-tail-f




[Listening changes on a text file (Unix Tail implementation with Java)]:	http://en.newinstance.it/2005/11/19/listening-changes-on-a-text-file-unix-tail-implementation-with-java/














