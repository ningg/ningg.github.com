---
layout: post
title: JavaScript基本知识
description: JavaScript中涉及的常识
published: true
category: javascript
---





## TODO

* JavaScript编码规范：
	* [网易邮箱前端Javascript编码规范：基础规范][网易邮箱前端Javascript编码规范：基础规范]
	* [Web前端：11个让你代码整洁的原则][Web前端：11个让你代码整洁的原则]
	* [JavaScript初学者应注意的七个细节][JavaScript初学者应注意的七个细节]
	* 几个较为全面的来源，再去查找，浏览现有规范有个印象
* JavaScript中常用概念的理解：
	* [理解 JavaScript（一）]
	* 还有 二 ~ 四
	* [“流式”前端构建工具——gulp.js 简介][“流式”前端构建工具——gulp.js 简介]





## 常见问题


### var定义变量

关于var定义变量：

* 不用var定义的变量，是全局变量；
* 使用var定义之后，转变为局部变量；*（推荐只要定义变量，就使用var）*
* `var $name`与`var name`两种方式的差异：
	* 两种方式完全等同，都是定义局部变量，第一种`$name`中`$`没有特殊含义，只是作为变量名称的一部分；
	* 什么情况下使用`$name`形式的变量命名方式？通常标识`$name = $("#id")`标识为一个jQuery对象时，在变量名上添加`$`字符作为前缀来标识，当然有人习惯在变量名前添加`j`字符来标识jQuery对象；


### JavaScript可放置的位置

几个位置：

* 内嵌JS代码，HTML 标签的任意位置：
	* `<body></body>`中；
	* `<head></head>`中；
* 外部引入JS代码：

示例代码如下：

	// 内嵌JS代码
	<script type="text/javascript"> 
	...
	</script>

	// 引入外部JS代码
	<script type="text/javascript" src="../resources/test.js"></script>
	
### 添加、清除页面中定时任务

添加定时任务，示例代码如下：

	function retrieveTransAmount() {
		$.ajax({
			type : 'get',
			url : appContext + '/nativepages/retrieveTransAmountPerDay.do',
			timeout : 1500,
			success : function(data) {
				$("#trans_amount").text(data);
			}
		});
	}

	//定时刷新总量数据
	setInterval(retrieveTransAmount, 2300);

清楚定时任务，示例代码：

	var timer = setInterval(retrieveTransAmount, 2300);
	clearInterval(timer);

特别说明：英文原版包含内容更充分，可以比较下面两个：

* [MDN - JavaScript中clearInterval(en)][MDN - JavaScript中clearInterval(en)]
* [MDN - JavaScript中clearInterval(zh)][MDN - JavaScript中clearInterval(zh)]


### 函数声明、命名函数表达式

两种方式的最大不同，可调用事件的不同：

* 函数声明，可以在任意地方使用；
* 命名函数表达式，只有在声明之后，才能使用；

上述现象称为：`函数声明提升`，参考[MDN - 函数声明提升][MDN - 函数声明提升]

也可以参考之前的博文：[jQuery常用操作][jQuery常用操作]

### JavaScript语言基本语法

几点：

* 单行代码使用`;`结尾；


### 两个整数相除，结果不一定为整数

示例代码：

	var interval = 23 / 10;
	var interval_int = Math.floor(interval);//向下取整
	var interval_int2 = Math.ceil(interval);//向上取整
	
### 判断变量是否为空

判断变量`startDay`的值，是否为空：

	if(!startDay){
		startDay = endDay;
	}


更多内容参考：

* [如何判断Javascript对象是否存在][如何判断Javascript对象是否存在]


















## 参考来源

* [MDN - JavaScript][MDN - JavaScript]
* [JavaScript可放置的位置][JavaScript可放置的位置]
* [MDN - JavaScript中clearInterval(en)][MDN - JavaScript中clearInterval(en)]
* [MDN - JavaScript中clearInterval(zh)][MDN - JavaScript中clearInterval(zh)]
* [jQuery常用操作][jQuery常用操作]
* [如何判断Javascript对象是否存在]










[NingG]:    http://ningg.github.com  "NingG"
[JavaScript可放置的位置]:				http://www.cainiao8.com/web/js_note/js_note_02_weizhi.html
[MDN - JavaScript]:						https://developer.mozilla.org/zh-CN/docs/Web/JavaScript
[MDN - JavaScript中clearInterval(en)]:	https://developer.mozilla.org/en-US/docs/Web/API/WindowTimers/clearInterval
[MDN - JavaScript中clearInterval(zh)]:	https://developer.mozilla.org/zh-CN/docs/Web/API/Window/clearInterval
[MDN - 函数声明提升]:					https://developer.mozilla.org/zh-CN/docs/Web/JavaScript/Reference/Statements/function

[网易邮箱前端Javascript编码规范：基础规范]:	http://blog.jobbole.com/19197/
[Web前端：11个让你代码整洁的原则]:				http://blog.jobbole.com/23617/
[JavaScript初学者应注意的七个细节]:			http://blog.jobbole.com/8481/
[理解 JavaScript（一）]:						http://segmentfault.com/a/1190000000347914
[“流式”前端构建工具——gulp.js 简介]:			http://segmentfault.com/a/1190000000435599


[jQuery常用操作]:								http://ningg.top/jquery-usage/
[如何判断Javascript对象是否存在]:				http://www.ruanyifeng.com/blog/2011/05/how_to_judge_the_existence_of_a_global_object_in_javascript.html
