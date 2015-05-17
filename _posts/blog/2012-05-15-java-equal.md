---
layout: post
title: Java中equals方法，判断两个对象是否相等
description: equals方法与==的比较
published: true
category: java
---




equals方法，需要满足以下三点： 

1. 自反性：就是说a.equals(a)必须为true。 
1. 对称性：就是说a.equals(b)为true的话，b.equals(a)也必须为true。 
1. 传递性：就是说a.equals(b)为true，并且b.equals(c)为true的话，a.equals(c)也必须为true。 



重写HashCode()的原则： 

* **不唯一原则**：不必对每个不同的对象都产生一个唯一的hashcode，只要你的HashCode方法使get()能够得到put()放进去的内容就可以了。
* **分散原则**：生成hashcode的算法尽量使hashcode的值分散一些，不要很多hashcode都集中在一个范围内，这样有利于提高HashMap的性能；





























[NingG]:    http://ningg.github.com  "NingG"











