---
layout: post
title: CSS和JavaScript实现返回顶部效果
description: 返回顶部效果的几种实现方式
published: true
categories: javascript css
---



## JavaScript方式


### CSS代码：

下述样式关键是：

* position: fixed;	// 固定在页面上
* right: 10%;  // 图标固定的具体位置
* bottom: 10%; // 图标固定的具体位置

详细代码如下：

	#gotoTop{
		display:none;
		position:fixed;
		right:10%;
		bottom:10%;
		cursor:pointer;
		padding:12px 4px;
		width:30px;
		text-align:center;
		border:1px solid #e0e0e0;
		background:#000;
		color:#fff;
	}

	#gotoTop{
		_position:absolute;
		_top:expression(documentElement.scrollTop + documentElement.clientHeight * 3/4 + "px")
	}

	#gotoTop.hover {
		background:gray;
		text-decoration:none;
	}



### JavaScript代码：

	function gotoTop(min_height){
		$("#gotoTop").click(
			function(){
				$('html,body').animate({scrollTop:0},700);
		}).hover(
			function(){$(this).addClass("hover");},
			function(){$(this).removeClass("hover");
		});

		min_height ? min_height = min_height : min_height = 600;

		//为窗口的scroll事件绑定处理函数
		$(window).scroll(function(){

			//获取窗口的滚动条的垂直位置
			var s = $(window).scrollTop();

			//当窗口的滚动条的垂直位置大于页面的最小高度时，让返回顶部元素渐现，否则渐隐
			if( s > min_height){
				$("#gotoTop").fadeIn(100);
			}else{
				$("#gotoTop").fadeOut(200);
			};
		});
	};

	gotoTop();


### HTML代码片段：

	<div id="gotoTop">Top</div>














## 参考来源


* [简单返回顶部代码及注释说明][简单返回顶部代码及注释说明]













[NingG]:    http://ningg.github.com  "NingG"

[简单返回顶部代码及注释说明]:		http://www.cnblogs.com/mind/archive/2012/03/23/2411939.html









