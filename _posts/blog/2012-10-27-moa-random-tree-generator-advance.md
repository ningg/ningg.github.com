---
layout:        post
title:         MOA中RandomTreeGenerator[Advanced]
category:      MOA
description:   MOA中随机树(Random Tree)数据流产生器深入探索。
---

##简介
`RandomTreeGenerator`是一个`stream`产生器，源源不断的输出`Instance`；这一部分，将详细探讨其实现；请先阅读"[MOA中RandomTreeGenerator-Basic](/moa-random-tree-generator/)"。查看源码的工具是Eclipse，关于Eclipse下查看源代码的快捷键，可参考"[Eclipse下查看MOA源代码](/moa-sourcecode-with-eclipse/)"。

具体将分为2个方面来讨论`RandomTreeGenerator`：

* 对外继承关系；
* 内部成员；

这些分析是准备解决问题的，不能解决问题的分析，就是徒劳；在本篇文章的后半部分，将基于上述讨论，来分析：

* 如何使用RandomTreeGenerator？
* 怎样定义一个stream的Generator？

如果只是讨论上面的这些东西，那么相当于一台没有主角的戏，枯燥浅显；因为处理对象是`data stream`，如果在程序中无法存储`data stream`，那就好比没有大米，却要去煮大米粥；最后一部分，重点讨论`MOA`中数据存储相关知识：

* data stream的数学表示是什么？程序中存储在什么地方？
* Attribute、Instance、Instances、InstancesHeader之间有什么联系？

##对外继承关系

几个基本的快捷键：
<table style="width: 100%;" border="1" cellspacing="0" cellpadding="2">
<tbody>
<tr>
<td style="text-align: center;"><strong>操作</strong></td>
<td style="text-align: center;"><strong>说明</strong></td>
</tr>
<tr>
<td>Ctrl + 鼠标左击</td>
<td>查看class、method、attribute的源代码</td>
</tr>
<tr>
<td>Alt &nbsp;+&nbsp;←</td>
<td>返回上一次鼠标位置</td>
</tr>
<tr>
<td>Alt &nbsp;+&nbsp;→</td>
<td>与“Alt + <span style="white-space: normal;">←</span>”相反</td>
</tr>
<tr>
<td>F4</td>
<td>查看Class的继承关系</td>
</tr>
</tbody>
</table>

