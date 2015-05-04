---
layout: post
title: HTML中常见操作
description: 一些常用操作技巧
published: true
category: html
---


##常用场景



###input文本框设置和移除默认值


**HTML5**： placeholder属性，示例代码如下：

```
<input type="text" name="loginName" placeholder="邮箱/手机号/QQ号">
```


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




























##参考来源

* [PlaceHolder的两种实现方式][PlaceHolder的两种实现方式]






[NingG]:    http://ningg.github.com  "NingG"

[PlaceHolder的两种实现方式]:		http://www.cnblogs.com/snandy/p/4115883.html










