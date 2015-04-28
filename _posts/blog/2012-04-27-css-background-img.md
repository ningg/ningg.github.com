---
layout: post
title: CSS中背景图片定位
description: 多个图标集中在一张背景图上，网页中显示指定区域
published: true
category: css
---

##CSS Sprites简介

CSS Sprites是网页图片处理方式，将一个页面中涉及到的零星图片包含到一张大图中，目标：

* 避免网站中零星的图片一张一张显示出来；
* 对于当前的网络环境，< 200KB的单张图片，加载时间差异不大；

使用图片做背景时，本质是使用属性：`background-image`组合`background-repeat`、`background-position`等来实现。调整`background-position`即可实现，背景显示不同的图片，CSS Sprites *（指包含了很多图标的一张背景图）* 一般只能使用到固定大小的盒子（box）里，这样遮挡住不应该看到的部分。

	p {
		width: 25px;
		height: 25px;
		background-image: url(../images/sprites.png);
		background-repeat: no-repeat;
		background-position: 0 -350px; 
		background-color: black;
	}
	
特别说明：上述`background-position`对应的两个参数为，x、y的定位坐标点，可以通过画图类软件来查看`sprites.png`图片中对应的坐标点。


###优缺点

* 优点：将多张图片，合并为一张图片，减少HTTP的连接数，提升网页响应时间；
* 缺点：每个小图标改动，都需要对整张图片进行编辑；并且，由于需要固定`background-position`对应的px值，失去了`center`之类的灵活性；

###图片定位几种方式

几种方式：

* 描述性词语：left、top、center
* 数值：20px、1em
* 百分比：20%、50%

简要介绍：

* 关键字：background-position: top right; 
* 像素：background-position: 0px 0px; 
* 百分比：background-position: 0% 0%;

上面的位置，含义：相对于容器左上角的点，图片的左上角的点，之间位置关系，参考下图；只有在`background-repeat: no-repeat;`条件下，`bacaground-position: 0px -23px;`设置才有效。

![](/images/css-background-img/css-background-img.png)


几点：

* 数值、百分比，可以混合使用，例如：`50% 20px`
* 数值、描述性词语，不混用
* 描述性词语，建议单独使用，例如：`right bottom`


##参考来源

* [CSS 背景图片定位][CSS 背景图片定位]



































[NingG]:    http://ningg.github.com  "NingG"
[CSS 背景图片定位]:			http://wenku.baidu.com/view/60a843ec102de2bd96058898.html?re=view










