---
layout: post
title: JQuery简介
description: JQuery的基本知识、使用JQuery的基本要点
published: true
category: JQuery
---

几点：

* JQuery与JavaScript之间的关系，JQuery能解决哪些问题？
* 如何使用JQuery？基本思路：选择元素、绑定动作、动态效果；


##基本路线


* JQuery介绍
* 选择器
* DOM操作
* 事件和动画
* 表单操作
* Ajax应用
* 插件
* 完整Demo



Javascript几个劣势：

* 复杂的文档对象模型（DOM）
* 不一致的浏览器实现*（兼容性问题）*
* 开发、调试工具缺乏

Ajax，Asynchronous JavaScript And XML，异步的JavaScript和XML。

##JQuery简介

JQuery的特点：

* 轻量级，30KB；
* 选择器，CSS1~CSS3几乎所有的选择器；
* DOM操作的封装：DOM操作是什么？对HTML内不同元素的操作？哪些操作？属性变更、元素增删？
* 可靠的事件处理：为元素绑定事件，哪些事件？点击？
* Ajax操作的封装，函数`$.ajax()`
* 浏览器兼容
* 链式操作方式：同一个JQuery对象的多个动作，可以直接连写，而不必重复获取对象；
* 隐式迭代：JQuery定位到所有`.myclass`的元素时，隐藏这些元素，不需要显式的遍历，JQuery里方法，可以直接操作对象集合，而不是单个对象，减少了手写循环迭代代码；
* 行为层与结构层的分离：JQuery选择器选中元素，然后直接给元素添加事件；这样元素的行为层和结构层就分离了；
* 丰富的插件、完善的文档；
* 开源；


JQuery两个版本：

* jquery.min.js，生产版（最小化、压缩版）
* jquery.js，开发板（未压缩）


JQuery对象，什么含义？

* `jQuery` 和 `$`等价
* `$.ajax`等价于`jQuery.ajax`，`$(".foo")`与`jQuery(".foo")`等价；

疑问：上面的`jQuery`与`$`之间的关系？到底什么含义？


###jQuery代码风格


jQuery建议代码规范：

* 对同一个对象，操作少于3个的，直接写成1行: `$("li").show().unbind("click")`;
* 对同一个对象，操作超过3个的，每行写一个操作；
* 对于多个对象，每个对象些一行，如果涉及子元素，进行缩进；
* 添加注释：`// 注释`


###DOM对象与jQuery对象

理清几个问题：

* DOM对象，是什么？
* jQuery对象，是什么？
* 2类对象之间，什么关系、


####DOM对象

DOM，Document Object Model，文档对象模型，每一份DOM都可以看作一棵树；一个HTML页面中，有很多标签，每个标签都看作一个节点，构成一颗树，称为DOM树，每个节点都是一个DOM对象。可以通过javascript来获取DOM对象，示例代码如下：

	var domObj = document.getElementById("id");	//获得DOM对象
	var ObjHTML = domObj.innerHTML;				//使用JavaScript中的属性innerHTML


####jQuery对象

jQuery对象，通过jQuery包装DOM对象之后，产生的对象，几点：

* jQuery对象可以使用jQuery里的方法；
* jQuery对象，无法使用DOM对象的方法；
* DOM对象，不能使用jQuery对象的方法；


####jQuery对象与DOM对象之间相互转换

示例代码：

	var jQueryObj = $("#id");		// jQuery对象
	var domObj = jQueryObj[0];		// 获取DOM对象
	var domObj2 = jQueryObj.get(0);

	var domObj = document.getElementById("id");		// DOM对象
	var jQueryObj = $(domObj);						// 获取jQuery对象

备注：`$()`函数，获取jQuery对象；为什么？哪个地方定义的？

####解决jQuery与其他库的冲突

调用`jQuery.noConflict();`将变量`$`的控制权放弃，也可以使用`var $j = jQuery.noConfilct();` 在放弃`$`变量同时，自定义jQuery的其他别名；


##选择器


###CSS选择器

几点：

* 网页结构HTML实现，表现样式CSS实现；
* HTML和CSS实现了，网页结构和表现样式的分离；


CSS选择器，几类：

* 标签选择器*（`div`）*
* 类选择器*（`.myclass`）*
* ID选择器*（`#id`）*
* 群组选择器*（`,`逗号间隔）*
* 后代选择器*（`div li`空格间隔）*
* 通配选择器*（`*`什么含义？）*




##参考来源

* [JQuery Tutorial][JQuery Tutorial]
















[NingG]:    			http://ningg.github.com  "NingG"
[JQuery Tutorial]:		http://www.w3cschool.cc/jquery/jquery-tutorial.html










