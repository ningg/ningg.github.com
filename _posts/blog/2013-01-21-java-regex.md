---
layout: post
title: java中正则表达式的使用
description: 正则表达式，就是字符串的匹配规则，目标是找出特定字符串，Java中如何使用正则表达式？
category: java
---


几点：

* 定义String：regular Exp.
	* 正则表达式：
	* java中，字符串形式，需要将"\"书写为`\\`;
* 定义Pattern
	* Pattern pattern = Pattern.compile(String regex);
	* 思考：为什么要有`Pattern`?
* 定义Matcher
	* Matcher matcher = pattern.matcher(String inputString);
	* matcher.reset(String inputString);
	* matcher.find();
	* matcher.group();实质为matcher.group(0);
	* matcher.group(int);


特别说明：

* matcher.group();
	* 实质为matcher.group(0);
	* 其对应输出整个regex所匹配出的字符串；
* matcher.group(int);
	* 对应输出regex所匹配的对应`()`内的内容；
	* 具体第几个`()`，只需要从左向右数`(`即可；


示例代码如下：

	...
	String targetPatternRegex = ".*(\\d){4}-(\\d){2}-(\\d){4}.*";
	...
	Pattern targetPattern = Pattern.compile(targetPatternRegex);
	boolean result = targetPattern.matcher(fileName).matches();
	...
	
**思考**：两个类Matcher和Pattern，如何定义和使用？


* Matcher.matches();
* Pattern.matcher(String);





















##参考来源



















[NingG]:    http://ningg.github.com  "NingG"





