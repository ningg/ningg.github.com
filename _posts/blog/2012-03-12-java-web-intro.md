---
layout: post
title: java web 简介
description: 常见的问题以及解决思路
category: web
---



###Web提供服务，多用户使用，是否会相互干扰

Spring MVC方式提供web服务，不同用户登录，会相互干扰吗？
本质：web为用户提供服务的实现细节，同一个JVM为所有用户服务？每个用户都占用一个JVM process？每个用户都新建一个java thread？在Eclipse的debug模式下，可以查看Thread情况。

* http://blog.csdn.net/freemindhack/article/details/27868289 每个用户都会新建一个thread
* http://blog.csdn.net/freemindhack/article/details/27866213 上述freemindhack的个人blog
* http://blog.csdn.net/freemindhack/article/details/27404417 Android学习步骤

注：学习东西，学习之后要留有痕迹，没有痕迹（基本demo、轮廓），就会随风飘散；
















[NingG]:    http://ningg.github.com  "NingG"












