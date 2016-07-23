---
layout: post
title: jQuery梳理
description: jQuery的基本知识、使用jQuery的基本要点
published: true
category: jquery
---

几点：

* jQuery与JavaScript之间的关系，jQuery能解决哪些问题？
* 如何使用jQuery？基本思路：
	* 选定元素*（选择器）*
	* 操作元素：绑定动作、动态效果*（DOM操作）*
* jQuery下Ajax如何使用？

> 遇到问题，首要查看[jQuery 官网 API][jQuery 官网 API]。

## 基本路线

几点：

* jQuery介绍
* 选择器：定位到元素
* DOM操作：添加属性、属性判断
* 事件和动画：为元素绑定事件、动画效果
* Ajax应用




## jQuery简介


JavaScript几个劣势：

* 复杂的文档对象模型（DOM）
* 不一致的浏览器实现*（兼容性问题）*
* 开发、调试工具缺乏

Ajax，Asynchronous JavaScript And XML，异步的JavaScript和XML。

jQuery的特点：

* 轻量级，30KB；
* 选择器，CSS1~CSS3几乎所有的选择器；
* DOM操作的封装：
	* DOM操作是什么？
	* 对HTML内不同元素的操作？哪些操作？属性变更、元素增删？
* 可靠的事件处理：为元素绑定事件，哪些事件？点击？
* Ajax操作的封装，函数`$.ajax()`
* 浏览器兼容
* 链式操作方式：同一个jQuery对象的多个动作，可以直接连写，而不必重复获取对象；
* 隐式迭代：JQuery定位到所有`.myclass`的元素时，隐藏这些元素，不需要显式的遍历，jQuery里方法，可以直接操作对象集合，而不是单个对象，减少了手写循环迭代代码；
* 行为层与结构层的分离：jQuery选择器选中元素，然后直接给元素添加事件；这样元素的行为层和结构层就分离了；
* 丰富的插件、完善的文档；
* 开源；


jQuery两个版本：

* jquery.min.js，生产版（最小化、压缩版），230KB
* jquery.js，开发板（未压缩），30KB


jQuery对象，什么含义？

* `jQuery` 和 `$`等价，`$`是简写方式
* `$.ajax`等价于`jQuery.ajax`，`$(".foo")`与`jQuery(".foo")`等价；

疑问：上面的`jQuery`与`$`之间的关系？到底什么含义？哪个地方对这些表示，进行定义？


简要说一下`$(document).ready()`，页面所有DOM结构绘制完，执行的JavaScript操作，与`window.onload = function(){...}`类似，但有差异：

* `$(document).ready(function(){...})`：
	* 执行时间：网页中DOM绘制完之后，即可执行，可能DOM相关的东西没有加载完毕，例如background中的图片还没有加载完；
	* 编写个数：可以写多个`$(document).ready(function () {...})`，每个都会执行
	* 简化写法：`$(function() {...})`
* `window.onload = function(){...}`：
	* 执行时间：网页中DOM绘制完之后，需要等待图片加载完毕，才会执行；
	* 编写个数：只能写一个，如果写了多个，则，最后一个有效；


### jQuery代码风格


jQuery建议代码规范：

* 对同一个对象，操作少于3个的，直接写成1行: `$("li").show().unbind("click")`;
* 对同一个对象，操作超过3个的，每行写一个操作；
* 对于多个对象，每个对象些一行，如果涉及子元素，进行缩进；
* 添加注释：`// 注释`


### DOM对象与jQuery对象

理清几个问题：

* DOM对象，是什么？
* jQuery对象，是什么？
* 2类对象之间，如何转换？


#### DOM对象

DOM，Document Object Model，文档对象模型，每一份DOM都可以看作一棵树；一个HTML页面中，有很多标签，每个标签都看作一个节点，构成一棵树，称为DOM树，每个节点都是一个DOM对象。可以通过JavaScript来获取DOM对象，示例代码如下：

	var domObj = document.getElementById("id");	//获得DOM对象
	var ObjHTML = domObj.innerHTML;		//使用JavaScript中的属性innerHTML


#### jQuery对象

jQuery对象，通过jQuery包装DOM对象之后，产生的对象，几点：

* jQuery对象可以使用jQuery里的方法；
* jQuery对象，无法使用DOM对象的方法；*（特别注意）*
* DOM对象，不能使用jQuery对象的方法；*（特别注意）*

例如：

	$("#foo").html();	//获取id=foo的对象的内部html代码，.html()方法是jQuery里的方法
	// 上述jQuery对象的操作，等效于下面DOM对象的操作
	document.getElementById("foo").innerHTML; 

#### jQuery对象与DOM对象之间相互转换

示例代码：

	var jQueryObj = $("#id");	// jQuery对象
	var domObj = jQueryObj[0];	// 获取DOM对象
	var domObj2 = jQueryObj.get(0);

	var domObj = document.getElementById("id");	// DOM对象
	var jQueryObj = $(domObj);	// 获取jQuery对象

备注：`$()`函数，获取jQuery对象；为什么？哪个地方定义的？

#### 解决jQuery与其他库的冲突

调用`jQuery.noConflict();`将变量`$`的控制权放弃，也可以使用`var $j = jQuery.noConfilct();` 在放弃`$`变量同时，自定义jQuery的其他别名`$j`；补充一点，通过`var variable`定义的变量`variable`在下文中直接引用即可，同理，`var $j`定义的变量`$j`，在下文中也直接使用`$j`，不要忘记了`$`符号，此处，其为变量名的一部分。


## 选择器

对一个元素进行操作之前，定位到这个元素，是第一步；选择器，负责定位元素。

### CSS选择器

常识几点：

* 网页结构HTML实现，表现样式CSS实现，元素动作JavaScript实现；
* HTML和CSS实现了，网页结构和表现样式的分离；
* CSS设置的样式应用到HTML文档中，3种方式：*（重用减少带宽占用和工作量，但增加了http连接数）*
	* 行间样式表；`<a style="color:red; margin:auto;">...</a>`，同一页面中，样式要写很多次
	* 内部样式表：`<style type="text/css">...</style>`，不能被多个页面重用
	* 外部样式表：`<link rel="stylesheet" type="text/css href="#" />`


CSS选择器，几类：

* 标签选择器*（`div`）*
* 类选择器*（`.myclass`）*
* ID选择器*（`#id`）*
* 群组选择器*（`,`逗号间隔）*
* 后代选择器*（`div li`空格间隔）*
* 通配选择器*（`*`什么含义？）*
* 还有几个，部分浏览器支持：
	* 伪类选择器*（`E:Pseudo`）*？
	* 子选择器*（`div > ul`）*
	* 临近选择器*（`.div2 + div3`）*
	* 属性选择器*（`div[attr]`）*？

注：CSS，Cascading Style Sheets，层叠样式表。

### jQuery选择器

jQuery选择器，完全继承CSS选择器的风格，几点：

* 兼容性：jQuery屏蔽了浏览器的差异；
* 建议：将网页内容（结构和样式）与动作分开，`<script type="text/javascript"> ... </script>`

一个网页，包含3类内容：

* 具体内容（HTML）
* 样式（CSS）
* 动作（JavaScript）

#### jQuery选择器的特点

几点：

* 写法简洁：`$()`在很多JavaScript类库中都被当作选择器函数使用，jQuery中也使用`$()`作为选择器函数
	* `$()`选择器，获取的永远是对象，不能通过`if($(#id))`来判断元素是否存在，而应使用`if($(#id).length > 0)`或者转换为DOM对象`if($(#id)[0])`；
* 支持CSS1~CSS3的选择器：CSS1、CSS2的全部选择器，CSS3的部分选择器，少量独特的选择器
* 完善的处理机制：原生JavaScript在选择元素时，需要判断元素是否存在，而jQuery选择器，可以无需判断元素是否存在

#### jQuery选择器分类及用法

几类：

* 基本选择器
	* `#id`：id选择器
	* `.class`：类选择器
	* `div`：标签选择器
	* `.class1, .class2`：群组选择器
* 层次选择器
	* `div ul`：后代选择器
	* `div > ul`：子代选择器（近第一级child）
	* `prev + next`：同级的下一个元素*（很少使用，使用`next()`方法替代）*；
	* `prev~siblings`：同级的后面所有元素*（很少使用，使用`nextAll()`方法替代，与`sibings()`有差异）*，
* 过滤选择器：`:`开头
	* 基本过滤：
	* 内容过滤：
	* 可见性过滤：
	* 属性过滤：
	* 子元素过滤：
	* 表单对象属性过滤：
	
* 表单选择器



##### 基本过滤器

比较常用，具体如下：

|选择器	|实例			|选取|
|-------|---------|--------|
|:first	|$("p:first")	|第一个 `<p>` 元素	|
|:last	|$("p:last")	|最后一个 `<p>` 元素	|
|:even	|$("tr:even")	|所有偶数 `<tr>` 元素	|
|:odd	|$("tr:odd")	|所有奇数 `<tr>` 元素	|
|:eq(index)	|$("ul li:eq(3)")	|列表中的第四个元素（index 值从 0 开始）|
|:gt(no)	|$("ul li:gt(3)")	|列举 index 大于 3 的元素|
|:lt(no)	|$("ul li:lt(3)")	|列举 index 小于 3 的元素|
|:not(selector)	|$("input:not(:empty)")	|所有不为空的输入元素|
|:header	|$(":header")	|所有标题元素 `<h1>, <h2> ...`|
|:animated	|$(":animated")	|所有动画元素|
|:focus		|$(":focus")	|当前具有焦点的元素|


##### 内容过滤

过滤规则与其包含的子元素或文本内容相关。

|选择器	|实例			|选取|
|-------|---------|--------|
|:contains(text)	|$(":contains('Hello')")	|所有包含文本 "Hello" 的元素				|
|:has(selector)		|$("div:has(p)")			|所有包含有 `<p>` 元素在其内的 `<div>` 元素	|
|:empty				|$(":empty")				|所有空元素									|
|:parent			|$(":parent")				|所有是另一个元素的父元素的元素				|

##### 可见性过滤

根据元素是否可见来判断：


|选择器	|实例			|选取|
|-------|---------|--------|
|:hidden	|$("p:hidden")		|所有隐藏的 `<p>` 元素|
|:visible	|$("table:visible")	|所有可见的表格|


下面集中过滤器，参考：[jQuery选择器][jQuery选择器]

* 属性过滤
* 子元素过滤
* 表单对象属性过滤



## DOM操作


DOM，文档对象模型，几点：

* 目的：描述脚本与结构化文档进行交互和访问的web标准；简单来说，DOM是为获取对象而存在的；
* 包含内容：DOM定义了一系列对象、方法、属性，用于访问、操作、创建文档的结构、样式、行为；
* 特点：与浏览器、平台、语言无关；

### jQuery中DOM操作

随便列几个：

* `text()`：元素节点的文本内容；
* `attr("attr_name")`：属性值；
* `append(str)`：插入新的元素；

DOM操作分类：

* 查找节点
* 创建节点
* 插入节点
* 删除节点
* 复制节点
* 替换节点
* 遍历节点
* 属性操作
* 样式操作
* 设置和获取HTML、文本、值




更多参考：

* [jQuery HTML / CSS 方法][jQuery HTML / CSS 方法]
* [jQuery 官网 API][jQuery 官网 API]


## jQuery中事件和动画



参考：

* [jQuery 官网 API][jQuery 官网 API]
* [jQuery 事件方法][jQuery 事件方法]
* [jQuery 效果方法][jQuery 效果方法]



## Ajax应用

Ajax：

* Asynchronous JavaScript And XML（异步的JavaScript和XML），
* JavaScript实现Ajax的核心是XMLHttpRequest对象，对应很多属性和方法；
* jQuery对Ajax操作进行了封装，提供load、ajax、get、post等操作：
	* 最底层：`$.ajax()`
	* 第2层：`load()`、`$.get()`、`$.post()`
	* 第3层：`$.getScript()`、`$.getJSON()`

简要说几个：

* `$("#id").load(url, data, callback)`，通过url请求HTML文档；
* `$.get(url, data, callback, type)`，GET方式进行异步请求：
	* data是JSON格式，典型的key:value对；
	* callback格式：`function(data, textStatus)`，回调函数仅当sucess时，才会执行，其中：data代表请求返回的内容，textStatus代表请求状态；
	* type：服务器端返回内容的格式，xml、html、script、json、text、_default
* `$.post(url, data, callback, type)`，POST方式进行异步请求，与`$.get()`类似；




简要说一下`$.get()`和`$.post()`之间的差异：

* 请求参数：GET请求参数包含在URL中，而POST请求参数在HTTP实体内部；
* 传输数据大小：GET向后端传输数据<2KB，POST方式没有限制；
* 安全性：GET方式请求数据，会被浏览器缓存，如果传送帐号、密码等内容，有严重的安全性问题；



上面提到的load、get、post等方法都可以用`$.ajax()`来实现，实际上，`$.ajax()`是jQuery最底层的Ajax实现。

### $.ajax()详解

`$.ajax()`方法常用参数解释


|参数 | 类型 | 说明|
|-----|-----|-----|
|url | String | 请求地址|
|type| String | POST、GET，默认GET|
|timeOut| Number | 请求超时时间（ms）|
|async|	Boolean|		(默认: true) 默认设置下，所有请求均为异步请求。如果需要发送同步请求，请将此选项设置为 false。|
|data|	Object,String|	发送到服务器的参数|
|dataType|	String|	预期服务器返回的数据类型（xml、html、json、script）。如果不指定，jQuery 将自动根据 HTTP 包 MIME 信息返回 responseXML 或 responseText，并作为回调函数参数传递。|
|success|	Function	|请求成功后回调函数。|
|error	|Function	|(默认: 自动判断 (xml 或 html)) 请求失败时将调用此方法。|
|complete|	Function	|请求完成后回调函数 (请求成功或失败时均调用)。|


### $.ajax()实例


`$.ajax()`示例代码如下：

	$(document).ready(function() {
		jQuery("#clearCac").click(function() {
			jQuery.ajax({
				url: "/Handle/Do",
				type: "post",
				data: { id: '0' },
				dataType: "json",
				success: function(msg) {
					alert(msg);
				},
				error: function(XMLHttpRequest, textStatus, errorThrown) {
					alert(XMLHttpRequest.status);
					alert(XMLHttpRequest.readyState);
					alert(textStatus);
				},
				complete: function(XMLHttpRequest, textStatus) {
					this; // 调用本次AJAX请求时传递的options参数
				}
			});
		});
	});



有几点注意的：

* `data:{}`, data为空也一定要传`{}`；







## 参考来源

* [jQuery Tutorial][jQuery Tutorial]
* [jQuery选择器][jQuery选择器]
* [jQuery 官网 API][jQuery 官网 API]
* [jQuery HTML / CSS 方法][jQuery HTML / CSS 方法]













[NingG]:    			http://ningg.github.com  "NingG"
[jQuery Tutorial]:		http://www.w3cschool.cc/jquery/jquery-tutorial.html
[jQuery选择器]:			http://www.w3cschool.cc/jquery/jquery-ref-selectors.html
[jQuery 官网 API]:		http://api.jquery.com/

[jQuery HTML / CSS 方法]:	http://www.w3cschool.cc/jquery/jquery-ref-html.html
[jQuery 事件方法]:		http://www.w3cschool.cc/jquery/jquery-ref-events.html
[jQuery 效果方法]:		http://www.w3cschool.cc/jquery/jquery-ref-effects.html






