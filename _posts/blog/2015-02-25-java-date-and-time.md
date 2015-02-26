---
layout: post
title: java中日期和时间
description: java中date和time
category: java
---


###获取年月日

常用两种方式：

* Date.getYear(); *（建议弃用）*
* Calendar.get(Calendar.YEAR); *（推荐使用）*


示例代码如下：

	package com.github.ningg;

	import java.text.SimpleDateFormat;
	import java.util.Calendar;
	import java.util.Date;

	public class TestDateAndTime {

		public static void main(String[] args) {
			
			Calendar calendar = Calendar.getInstance();
			System.out.println(calendar.get(Calendar.YEAR));
			System.out.println(calendar.get(Calendar.MONTH));
			System.out.println(calendar.get(Calendar.DATE));
		
			Date date = new Date();
			
			System.out.println(date.getYear());
			System.out.println(date.getMonth());
			System.out.println(date.getDate());
			
		}
	}




###String与date、time之间的相互转换


利用DateFormat可以实现String与Date之间的相互转换，`SimpleDateFormat`使用的更为广泛，示例代码如下：


	String datePattern = "yyyy-MM-dd";
	SimpleDateFormat simpleDateFormat = new SimpleDateFormat(datePattern);
	
	System.out.println(simpleDateFormat.format(new Date()));


强调几点：

* datePattern中字母严格区分大小写：`d`与`D`含义不同；
* 关于`yyyy-MM-dd`详细介绍，查看`SimpleDateFormat`，或[simpleDateFormat][simpleDateFormat]；




























##参考来源


* [simpleDateFormat][simpleDateFormat]





















[NingG]:    								http://ningg.github.com  "NingG"
[simpleDateFormat]:							http://docs.oracle.com/javase/tutorial/i18n/format/simpleDateFormat.html












