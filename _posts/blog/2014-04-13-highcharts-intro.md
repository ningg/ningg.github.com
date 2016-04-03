---
layout: post
title: Highcharts使用入门
description: 前端常用JS工具Highcharts的常见用法
published: true
category: javascript
---


## 柱状图、折线图


### 调整横轴坐标字体、斜放

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


### 颜色组

最终图形中显示的折线、柱状图等的颜色，具体在highcharts元素下，设置`colors`属性：

	colors: ["#7cb5ec", "#f7a35c", "#90ee7e", "#7798BF", "#aaeeee", "#ff0066", "#eeaaee",
			"#55BF3B", "#DF5353", "#7798BF", "#aaeeee"],


具体参考：[Highcharts API - colors](http://www.hcharts.cn/api/index.php#colors)


### 动态修改/添加/删除数据

示例代码如下：

	//修改数据
	$('#container-line').highcharts().xAxis[0].setCategories(result.category);
	$('#container-line').highcharts().series[0].setData(result.data);

	//添加数据
	$('#container-line').highcharts().addSeries({
		name : result.name
	}).setData(result.data);
	
	//删除数据
	var seriesList = $('#container-line').highcharts().series; //获得图表的所有序列
	for (var i = parseInt(seriesList.length)-1; i > 0; i--) { //通过for循环删除序列数据
		$('#container-line').highcharts().series[i].remove(false);
	}


### 更新参数

示例代码如下：

	$('#container-line').highcharts().series[0].update({
		name : result.name
	});

具体参考[Highcharts API 文档][Highcharts API 文档]中的函数部分。


### X轴刻度名称位于刻度线正下方

示例代码：

	xAxis: {
		tickmarkPlacement: 'on' //刻度正位于刻度线下方
	}

详细内容参考：[highcharts初级入门之tickmarkPlacement]


### 折线图中，多线条对比时，提示内容横轴显示内容

代码如下：

		xAxis: {
			categories: ['2015-02-03', '2015-02-04', '2015-02-05'],
        },
        yAxis: {
            title: {
                text: 'Snow depth (m)'
            },
            min: 0
        },
        tooltip: {
	       		headerFormat: '<table>',
	            pointFormat: '<tr><td style="color:{series.color};padding:0">{point.name}: </td>' +
	                '<td style="padding:0"><b>{point.y} </b></td></tr>',
	            footerFormat: '</table>',
	            shared: true,
	            crosshairs: true,
	            useHTML: true
       	},
        
        series: [{
            name: 'Winter 2007-2008',
            data: [
				{name:'2013-02-03', y:0},
                {name:'2013-02-04', y:0.6},
				{name:'2013-02-05', y:0.3}
            ]
        }, {
            name: 'Winter 2008-2009',
            data: [
                {name:'2014-02-03', y:0},
                {name:'2014-02-04', y:1.6},
				{name:'2014-02-05', y:1.3}
            ]
        }, {
            name: 'Winter 2009-2010',
            data: [
                {name:'2016-02-03', y:0},
                {name:'2016-02-04', y:2.6},
				{name:'2016-02-05', y:2.3}
            ]
        }]

效果如下图：

![](/images/highcharts-intro/multi-line-axis.png)


## 小结


使用Highcharts，几点：

* 多在google、baidu上搜索遇到的问题；
* 多看官网的API文档：
	* [Highcharts API 文档][Highcharts API 文档]












## 参考来源

* [Highcharts中文网][Highcharts中文网]
* [highcharts初级入门之tickmarkPlacement][highcharts初级入门之tickmarkPlacement]
* [Highcharts API 文档][Highcharts API 文档]
* [Jquery 图表插件 Highcharts 选项配置详细说明文档][Jquery 图表插件 Highcharts 选项配置详细说明文档]











[NingG]:    				http://ningg.github.com  "NingG"
[Highcharts中文网]:			http://www.hcharts.cn/index.php
[Highcharts API 文档]:		http://www.hcharts.cn/api/index.php


[highcharts初级入门之tickmarkPlacement]:			http://www.stepday.com/topic/?767
[Jquery 图表插件 Highcharts 选项配置详细说明文档]:		http://chengxudaren.com/index.php?act=article&op=detail&a_id=4







