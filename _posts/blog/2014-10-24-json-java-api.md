---
layout: post
title: JSON简介以及JAVA API
description: 常用的数据交换格式有XML和JSON，如何进行解析、转换
categories: json java
---

##背景

最近做个数据采集的东西，初步决定使用JSON作为数据交换格式，OK，学习整理一下。

##JSON简介

JSON（JavaScript Object Notation），轻量级的数据交换格式，易于阅读和编写，同时机器也很容易输出JSON格式、解析JSON格式。JSON是完全独立于语言的文本格式，这使其成为理想的数据交换语言。

JSON中两类基本结构：

* `key:value`：键-值对，通过key来标识value；
* `array`：有序的数组；

JSON利用上述的两类基本结构，实现了集中基本数据类型：

**Object**：An object is an unordered set of name/value pairs. An object begins with { (left brace) and ends with } (right brace). Each name is followed by : (colon) and the name/value pairs are separated by , (comma).
（无序的key-value对，以`{`开头，以`}`结尾，其内部以`,`逗号分隔）

![](/images/json-java-api/object.gif)


**Array**：An array is an ordered collection of values. An array begins with `[` (left bracket) and ends with `]` (right bracket). Values are separated by , (comma).
（有序的value序列，以`[`开头，以`]`结尾，其内部以`,`逗号分隔）

![](/images/json-java-api/array.gif)

**Value**：A value can be a string in double quotes, or a number, or true or false or null, or an object or an array. These structures can be nested.
（Value表示的内容比较广，既可以是""包含起来的String，也可以是数字，或者`true`\`false`；另一方面，也可以是`Object`或者array）

![](/images/json-java-api/value.gif)

**String**：A string is a sequence of zero or more Unicode characters, wrapped in double quotes, using backslash escapes. A character is represented as a single character string. A string is very much like a C or Java string.
（`""`双引号包含起来的Unicode 字符，其中可以使用`backslash`来标识转义字符）

![](/images/json-java-api/string.gif)

**Number**：A number is very much like a C or Java number, except that the octal and hexadecimal formats are not used.
（不支持octal和hexadecimal formats）


![](/images/json-java-api/number.gif)

Whitespace can be inserted between any pair of tokens. Excepting a few encoding details, that completely describes the language.
（任何符号之间都可插入空格`whitespace`）

**notes(ningg)**：JSON中`key`能否重复？



##处理JSON的JAVA API

处理JSON格式数据，无非两条路：

* JDK 自带的 Java API；（官方）
* 第三方jar包提供的java API；

**特别说明**：[JSR 353][JSR 353]指出，今后的Java SE 6以及Java EE 7中要添加API来支持JSON格式数据的解析和转换。当前个人查证，在JDK6u30中没有java API来解析JSON；Java EE 7中，已经提供了`javax.json`包来支持解析JSON。

当前项目需求，在JDK5以及之上的版本都能进行JSON字符串与JSON对象之间的转换，OK，那直接上第三方jar包得了。

###java解析JSON的第三方jar包

从[JSON 主页][介绍 JSON]可知，当前，有很多的第三方jar包：org.json、org.json.me、jsonp、[Jackson Json Processor][Jackson Json Processor]、[google-gson][google-gson]、Json-lib...，有点多呀，到底选哪个呢？当前初步考虑在如下两个中选：

* Spring中使用的是[org.codehaus.jackson][Jackson Json Processor]详细版本号`1.9.13`（后来Spring 3.2中已经支持Jackson2了）
* [google-gson][google-gson]的官方网站打不开，不过在maven中央仓库找到了gson的[jar包][google-gson-maven]，虽然无法查看官网的文档，不过maven中央仓库的javadoc、source文件也可以用来学习。

最终决定采用gson，其基本的JSON操作，参考：[JSON转换利器:Gson][JSON转换利器:Gson]

##解析JSON字符串的效率问题

[处理JSON的Java API ：JSON的简介][处理JSON的Java API ：JSON的简介]中提到解析JSON的API分为两类：

* 对象模型API
* 流API

这两种方式在原理、效率上都有差异，TODO

##参考来源

* [介绍 JSON](http://www.json.org/json-zh.html)
* [处理JSON的Java API ：JSON的简介][处理JSON的Java API ：JSON的简介]
* [JSR 353][JSR 353]
* [JSON转换利器:Gson][JSON转换利器:Gson]


[NingG]:    http://ningg.github.com  "NingG"
[JSR 353]:	https://jcp.org/en/jsr/detail?id=353
[Jackson Json Processor]:	http://jackson.codehaus.org/
[JSON转换利器:Gson]:		http://blog.csdn.net/lk_blog/article/details/7685169
[google-gson]:				http://code.google.com/p/google-gson/
[google-gson-maven]:		http://repo1.maven.org/maven2/com/google/code/gson/gson/2.2.3/
[处理JSON的Java API ：JSON的简介]:		http://ifeve.com/json-java-api/