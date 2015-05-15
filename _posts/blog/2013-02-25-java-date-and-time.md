---
layout: post
title: Java中日期和时间
description: java中date和time
category: java
---


##JDK自带类

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


	String datePattern = "yyyy-MM-dd HH:mm:ss";
	SimpleDateFormat simpleDateFormat = new SimpleDateFormat(datePattern);
	
	// Date -> String
	System.out.println(simpleDateFormat.format(new Date()));
	System.out.pringln(simpleDateFormat.format(Calendar.getInstance().getTime()))
	
	
	// String -> Date
	String dateString = "2014-01-19 08:15:45";
	Date date = simpleDateFormat.parse(dateString);

	

强调几点：

* datePattern中字母严格区分大小写：`d`与`D`含义不同；
* 关于`yyyy-MM-dd`详细介绍，查看`SimpleDateFormat`，或[simpleDateFormat][simpleDateFormat]；


###获取两个日期之间的所有日期

示例代码如下：

	public class GeneralUtils {

		/*
		 * 计算从起始时间startDate到endDate之间的所有日期，
		 * 左右都是闭区间,包含startDate和endDate两个点.
		 * @param startDate
		 * @param endDate
		 * @return
		 */
		public static List<Date> getDatesBetweenDates(Date startDate, Date endDate){
			List<Date> dates = new ArrayList<>();
			
			Calendar calendar = new GregorianCalendar();
			calendar.setTime(startDate);
			
			while (!calendar.getTime().after(endDate)) {
				Date result = calendar.getTime();
				dates.add(result);
				calendar.add(Calendar.DATE, 1);
			}
			
			return dates;
		}
	}


##借助第三方包


###commons-long-2.5.jar

`pom.xml`片段：

	<groupId>org.apache.commons</groupId>
	<artifactId>commons-lang</artifactId>
	<version>2.5</version>


示例代码：

	FastDateFormat fastDateFormat = FastDateFormat.getInstance("yyyy-MM-dd",
		TimeZone.getTimeZone("Etc/UTC"));

API中解释：

> FastDateFormat is a fast and thread-safe version of java.text.SimpleDateFormat.
> 
> This class can be used as a direct replacement to SimpleDateFormat in most formatting situations. This class is especially useful in multi-threaded server environments. SimpleDateFormat is not thread-safe in any JDK version, nor will it be as Sun have closed the bug/RFE. 


疑问：时区中`Etc/UTC`的含义？

个人理解：使用时区，方便程序进行国际化，不过，要求，生成日期的Server与解释日期的Server在Time Zone上要设置正确，即，每个操作系统的Time Zone要设置正确。

自己测试现象：下面两者等价

* March 11th 2015, 12:58:55.901--Etc/GMT-8
* 2015-03-11T04:58:55.901Z--Etc/UTC

可借助[Time zone converter][Time zone converter]进行查询。


###joda

`pom.xml`片段：

	<groupId>joda-time</groupId>
	<artifactId>joda-time</artifactId>
	<version>2.1</version>


示例代码如下：

	DateTimeFormatter defaultDatePrinter = ISODateTimeFormat.dateTime().withZone(DateTimeZone.UTC);
















##参考来源


* [simpleDateFormat][simpleDateFormat]





















[NingG]:    								http://ningg.github.com  "NingG"
[simpleDateFormat]:							http://docs.oracle.com/javase/tutorial/i18n/format/simpleDateFormat.html
[JavaSE 7 API-SimpleDateFormat]:			http://docs.oracle.com/javase/7/docs/api/java/text/SimpleDateFormat.html
[Time zone converter]:						http://www.timezoneconverter.com/cgi-bin/zoneinfo.tzc










