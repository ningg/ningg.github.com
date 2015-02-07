---
layout: post
title: java的编码问题：byte、char、string
description: 出现乱码？原因挺简单的，byte与char之间映射出错
category: java
---


##关注点

要解决几个问题：

* java中，出现乱码的原因？解决的基本原理？（下面两个是具体问题）
	* java中，对字符串String的读取，出现乱码的解决办法？
	* java中，对文件File的读写，出现乱码的解决办法？
* 补充知识：
	* `编码`：几种编码方式之间的差异：ASCII、UTF-8、GB2312、GBK、ISO8859-1；
	* `文件`：java下，文件读写，效率和编码；
	* `数组`：java下，基础类型（char、byte、int）数组的定义和使用


##乱码

java中，对String进行编码、解码的基本过程，见下图；简要解释一下：

* 编码解码，`String`通过`charsetIn`字符集映射为`byte[]`，然后`byte[]`再依照`charsetOut`映射为`String`的过程；
* `String`是`char[]`；
* 编码解码，本质是：`char[]`通过`charsetIn`字符集映射为`byte[]`，然后`byte[]`再依照`charsetOut`映射为`char[]`的过程；

**疑问**：`charset`字符集，对应于编码方式吗？


![](/images/java-encode-byte-char-string/encode-process.png)




###何时出现乱码？如何解决？

依照前文分析的编码解码基本过程，产生乱码，本质是输入的`char[]`与最终输出的`char[]`不一致，有如下几种：

* `char`在`charsetIn`字符集中不存在，无法找出对应的`byte[]`，只能强制转换为某个默认的`byte[]`；
* `charsetIn`与`charsetOut`不一致；

因此，解决乱码问题的思路也是清晰的：

* 选用合适的字符集`charsetIn`，当然，尽可能大的字符集`charsetIn`最好，不过，能够满足需求即可；
* 保证`charsetIn`与`charsetOut`字符集完全一致；



**思考**：上数的讨论都是基于原始输入`String`为正常String，没有携带乱码，但有一种情况：原始`String`中自身就携带乱码，此时，如何处理？



###字符串的编解码

几点：

* 获取`String`对应的`byte[]`：`String.getBytes(charset)`；
* 输出`byte[]`内容：`Arrays.toString(byte[])`
* 将`byte[]`编码为`String`：`new String(byte[], charset);`

测试代码如下：

	package com.github.ningg;

	import java.io.UnsupportedEncodingException;
	import java.util.Arrays;

	public class ByteAndString {

		public static void main(String[] args) throws UnsupportedEncodingException{
			
			String inputStr = "你好, Hello";
			String charset = "UTF-8";
			String outputStr = null;
			byte[] firstLayerByteArray = null;
			
			// default
			firstLayerByteArray = inputStr.getBytes();
			outputStr = new String(firstLayerByteArray);

			System.out.println("default:");
			System.out.println(Arrays.toString(firstLayerByteArray));
			System.out.println(outputStr);
			System.out.println("-------------");
			
			// UTF-8
			charset = "UTF-8";
			firstLayerByteArray = inputStr.getBytes(charset);
			outputStr = new String(firstLayerByteArray, charset);
			
			System.out.println(charset + ":");	
			System.out.println(Arrays.toString(firstLayerByteArray));
			System.out.println(outputStr);
			System.out.println("-------------");

			// GBK
			charset = "GBK";
			firstLayerByteArray = inputStr.getBytes(charset);
			outputStr = new String(firstLayerByteArray, charset);
			
			System.out.println(charset + ":");
			System.out.println(Arrays.toString(firstLayerByteArray));
			System.out.println(outputStr);
			System.out.println("-------------");

			// GB2312
			charset = "GB2312";
			firstLayerByteArray = inputStr.getBytes(charset);
			outputStr = new String(firstLayerByteArray, charset);
			
			System.out.println(charset + ":");
			System.out.println(Arrays.toString(firstLayerByteArray));
			System.out.println(outputStr);
			System.out.println("-------------");

			// ISO-8859-1
			charset = "ISO-8859-1";
			firstLayerByteArray = inputStr.getBytes(charset);
			outputStr = new String(firstLayerByteArray, charset);
			
			System.out.println(charset + ":");
			System.out.println(Arrays.toString(firstLayerByteArray));
			System.out.println(outputStr);
			System.out.println("-------------");
			
		}
	}

输出内容，如下：

	default:
	[-28, -67, -96, -27, -91, -67, 44, 32, 72, 101, 108, 108, 111]
	你好, Hello
	-------------
	UTF-8:
	[-28, -67, -96, -27, -91, -67, 44, 32, 72, 101, 108, 108, 111]
	你好, Hello
	-------------
	GBK:
	[-60, -29, -70, -61, 44, 32, 72, 101, 108, 108, 111]
	你好, Hello
	-------------
	GB2312:
	[-60, -29, -70, -61, 44, 32, 72, 101, 108, 108, 111]
	你好, Hello
	-------------
	ISO-8859-1:
	[63, 63, 44, 32, 72, 101, 108, 108, 111]
	??, Hello
	-------------





###文件内容的编解码












[NingG]:    http://ningg.github.com  "NingG"




