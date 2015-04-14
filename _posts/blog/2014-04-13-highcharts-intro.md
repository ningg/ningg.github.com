---
layout: post
title: Highcharts使用入门
description: 前端常用JS工具Highcharts的常见用法
published: true
category: javascript
---


##柱状图


###坐标轴

####调整横轴坐标字体、斜放

调整字体样式、设置横坐标斜放，代码如下：

	xAxis: {
			labels: {
                style: {
                    color: '#444',
					font: '0.85em/2 Microsoft YaHei,"Arial", "Helvetica", sans-serif',
                },
				rotation : -45  //控制斜放
            },
            categories: [
			...
			]
	}


####颜色组

最终图形中显示的折线、柱状图等的颜色，具体在highcharts元素下，设置`colors`属性：

	colors: ["#7cb5ec", "#f7a35c", "#90ee7e", "#7798BF", "#aaeeee", "#ff0066", "#eeaaee",
			"#55BF3B", "#DF5353", "#7798BF", "#aaeeee"],


具体参考：[Highcharts API - colors](http://www.hcharts.cn/api/index.php#colors)





##小结


使用Highcharts，几点：

* 多在google、baidu上搜索遇到的问题；
* 多看官网的API文档：
	* [Highcharts API 文档][Highcharts API 文档]




















##参考来源

* [Highcharts中文网][Highcharts中文网]






[NingG]:    				http://ningg.github.com  "NingG"
[Highcharts中文网]:			http://www.hcharts.cn/index.php
[Highcharts API 文档]:		http://www.hcharts.cn/api/index.php









