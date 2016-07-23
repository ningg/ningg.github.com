---
layout: post
title: JSP中涉及的编码问题
description: pageEncoding、contextType、charset涉及的多种编码之间的关系
published: true
category: jsp
---

JSP页面中代码：*（page指令）*

	<%@ page contextType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>

上述两个地方都设定了编码方式，有什么差异？

* pageEncoding：
	* JSP页面本身的编码
	* pageEncoding编码对应的优先级：pageEncoding > contextType中charset > ISO-8859-1*（默认）*
* contextType中charset含义：Server发送给Client的HTML页面的内容编码，默认为ISO-8859-1；

整体几个阶段：

* JSP页面编译为java源文件（servlet）：根据pageEncoding设定的编码方式读取JSP页面，并统一编译为UTF-8方式的java源文件（.java）；
* java源文件编译为class文件：javac读取UTF-8编码的java源文件，并编译为UTF-8编码的class字节码文件；
* 应用服务器（Tomcat等）输出HTML网页：应用服务器加载class文件，并生成最终的HTML文件，对应编码方式为contextType中的charset；

**疑问**：HTML网页对应编码方式的作用？几个过程中编码方式的含义：

* Server上，HTML页面生成；
* Server向Client发送HTML页面过程中；
* Client收到HTML页面后，浏览器展示HTML页面；








































[NingG]:    http://ningg.github.com  "NingG"











