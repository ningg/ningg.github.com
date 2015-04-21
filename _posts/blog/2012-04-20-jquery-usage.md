---
layout: post
title: JQuery常用操作
description: 利用JQuery来实现前端常见效果
published: true
category: jquery
---



##常见问题

###为元素绑定点击事件

下面几种方法：

* 方法 1：独立function，单独绑定click事件，异常：页面加载完之后，自动触发click操作，同时，click绑定事件失效；
* 方法 2：内嵌function，绑定click事件，正常；
* 方法 3：独立function，同时，使用属性`onclick`绑定function；
* 方法 4：独立function，单独绑定click事件，在`click`对应的事件中，无论多么简单的function，都在外面添加一层匿名`function(){}` *（什么原因？）*
* 方法 5：独立function，但返回handler，同时，绑定click事件时，直接使用handler即可；*（去真正的官网，理解这一内容，具体看下面的参考）*

疑问：出现上述现象的原因？几个参考来源：

* [jQuery官网 click][jQuery官网 click]
* [jQuery官网 function][jQuery官网 function]
* [difference between assigning function to variable or not][difference between assigning function to variable or not]
* [Javascript function declarations vs function operators][Javascript function declarations vs function operators]

####方法1：

	function retrieveTransNum() {
		$.ajax({
			type : 'get',
			url : appContext + '/nativepages/retrieveTransNum.do',
			//dataType : 'json',
			timeout : 2000,
			success : function(result) {
				$('#switch-area .mini-panel-body').append(result);
			}
		});
	} 
	
	$("#trans-num-li").bind("click", retrieveTransNum());
	

####方法2：

	$("#trans-num-li").bind("click", function retrieveTransNum() {
		$.ajax({
			type : 'get',
			url : appContext + '/nativepages/retrieveTransNum.do',
			//dataType : 'json',
			timeout : 2000,
			success : function(result) {
				$('#switch-area .mini-panel-body').empty().append(result);
			}
		});
	});

####方法3：
	
	...
	<li id="trans-num-li" onclick="retrieveTransNum()">
	...
	
	function retrieveTransNum() {
		$.ajax({
			type : 'get',
			url : appContext + '/nativepages/retrieveTransNum.do',
			//dataType : 'json',
			timeout : 2000,
			success : function(result) {
				$('#switch-area .mini-panel-body').append(result);
			}
		});
	} 
	
####方法4：

	function retrieveTransNum() {
		$.ajax({
			type : 'get',
			url : appContext + '/nativepages/retrieveTransNum.do',
			//dataType : 'json',
			//timeout : 2000,
			success : function(result) {
				//针对CAP4J前端渲染框架，需要将获取的html片段，添加到.mini-panel-body中
				$('#switch-area .mini-panel-body').append(result);
			}
		});
	}
	
	$("#trans-num-li").bind("click", function(){
		retrieveTransNum();
	});

####方法5：

	var retrieveTransNumHandler = function retrieveTransNum() {
		$.ajax({
			type : 'get',
			url : appContext + '/nativepages/retrieveTransNum.do',
			//dataType : 'json',
			//timeout : 2000,
			success : function(result) {
				//针对CAP4J前端渲染框架，需要将获取的html片段，添加到.mini-panel-body中
				$('#switch-area .mini-panel-body').append(result);
			}
		});
	}
	
	$("#trans-num-li").bind("click", retrieveTransNumHandler);


####思考

上述`方法1`、`方法4`、`方法5`中定义function时，有两种方式：

* 直接定义function：会被共享；
* 将function内容赋给一个var：只使用一次的情况；

使用场景，参考：[Javascript function declarations vs function operators][Javascript function declarations vs function operators]。






###绑定多个点击事件

直接调用多次`click(function(){})`方法即可：

	$(document).ready(function (){

		$(".div2").click(function() {
			initDiv();
			//initDivLi();
			//当前被点击的div改变背景色
			$(this).css("background", "rgb(194, 203, 207)");
			//取消当前div的mouseout和mouseover事件
			$(this).unbind("mouseout");
			$(this).unbind("mouseover");
		});
		
		$(".div2").click(
			function() {
				$(this).next("div").slideToggle("slow").siblings(
						".div3:visible").slideUp("slow");
				/* $(this).next("div").slideToggle("normal"); */
			});
		
	});

思考：当为元素绑定多个`click`事件时，如何进行区分事件的执行顺序？

























##参考来源

* [JQuery-tutorial][JQuery-tutorial]
* [jQuery教程][jQuery教程]
* [jQuery官网 click][jQuery官网 click]
* [jQuery官网 function][jQuery官网 function]
* [difference between assigning function to variable or not][difference between assigning function to variable or not]
* [Javascript function declarations vs function operators][Javascript function declarations vs function operators]









[NingG]:    			http://ningg.github.com  "NingG"
[jQuery-tutorial]:		http://www.w3cschool.cc/jquery/jquery-tutorial.html
[jQuery教程]:			http://www.w3school.com.cn/jquery/index.asp
[jQuery官网 click]:		http://api.jquery.com/click/
[jQuery官网 function]:	http://api.jquery.com/Types/#Function
[difference between assigning function to variable or not]:		http://stackoverflow.com/questions/11146814/difference-between-assigning-function-to-variable-or-not
[Javascript function declarations vs function operators]:		http://helephant.com/2012/07/14/javascript-function-declaration-vs-expression/




