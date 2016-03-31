---
layout: post
title: Spring MVC中常见注解（annotation）
description: Controller、Service、Repository、RequestMapping、PathVariable、
published: true
category: spring
---



下面常见注解：

* @Controller
* @Service
* @Repository
* @RequestMapping
* @RequestParam
* @PathVariable
* @ResponseBody




几点：

* 在Spring 3.x之前，大部分通过xml文档配置url与controller之间的处理关系，但xml文件不方便维护，现在多使用注解；
* 一个注解是如何生效的？Spring中涉及的处理过程？
* 如何编写注解（annotation）？
* 注解实现AOP？






## @RequestMapping

几种情况：

Class：`@RequestMapping`标注在某个`@Controller`的类上，表示设定的url入口为当前类，默认当前类的`${method.name}.do`为url后缀；
* `@RequestMapping`标注在方法上，表示设定的url为当前方法，若此时





















## 参考来源

* [Spring常用注解][Spring常用注解]










[NingG]:    http://ningg.github.com  "NingG"


[Spring常用注解]:			http://elf8848.iteye.com/blog/442806



http://my.oschina.net/zhdkn/blog/316530

http://my.oschina.net/zhdkn/blog/208720

http://blog.csdn.net/jackyrongvip/article/details/9287281



