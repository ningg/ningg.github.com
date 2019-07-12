---
layout: post
title: 基础工具：Dozer 数据转换
description: Dozer 能做什么？使用的注意事项是什么？
category: 基础工具
---




## 0.约束

使用 Dozer 进行数据转换时，要求：

* model 中 field 可编辑，例：set、map 不能为 immutable
* 有默认的构造方法，JavaBean 中编写了构造方法，就没有默认的无参构造方法，因此，要求显式声明无参构造方法



## 1.参考资料

* [Dozer vs Orika vs Manual](https://blog.sokolenko.me/2013/05/dozer-vs-orika-vs-manual.html)












[NingG]:    http://ningg.github.com  "NingG"
