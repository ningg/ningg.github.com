---
layout: post
title: JavaScript基本知识
description: JavaScript中涉及的常识
published: true
category: javascript
---



##常见问题


###var定义变量

变量都是全局变量，使用var定义之后，转变为局部变量，推荐只要定义变量，就使用var；

###JavaScript可放置的位置

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
	
###添加、清除页面中定时任务

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


























##参考来源

* [MDN - JavaScript][MDN - JavaScript]
* [JavaScript可放置的位置][JavaScript可放置的位置]
* [MDN - JavaScript中clearInterval(en)][MDN - JavaScript中clearInterval(en)]
* [MDN - JavaScript中clearInterval(zh)][MDN - JavaScript中clearInterval(zh)]







[NingG]:    http://ningg.github.com  "NingG"
[JavaScript可放置的位置]:				http://www.cainiao8.com/web/js_note/js_note_02_weizhi.html
[MDN - JavaScript]:						https://developer.mozilla.org/zh-CN/docs/Web/JavaScript
[MDN - JavaScript中clearInterval(en)]:	https://developer.mozilla.org/en-US/docs/Web/API/WindowTimers/clearInterval
[MDN - JavaScript中clearInterval(zh)]:	https://developer.mozilla.org/zh-CN/docs/Web/API/Window/clearInterval









