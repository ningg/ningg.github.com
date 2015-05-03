---
layout: post
title: HTML中常见操作
description: 一些常用操作技巧
published: true
category: html
---


##常用场景



###input文本框设置和移除默认值



**input输入框**，示例代码如下：

```
<input name="textfield" 
	type="text" 
	value="点击添入标题" 
	onfocus="if (value =='点击添入标题'){value =''}" 
	onblur="if (value ==''){value='点击添入标题'}"/>
```


**textarea文本框**，示例代码如下：

```
<textarea name="textarea" 
	cols="80" rows="17" 
	onfocus="if(value=='正文：'){value=''}" 
	onblur="if (value ==''){value='正文：'}"></textarea>
```



































[NingG]:    http://ningg.github.com  "NingG"











