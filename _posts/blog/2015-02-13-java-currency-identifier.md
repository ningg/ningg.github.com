---
layout: post
title: Java 实践：金额标识
description: Java 语言中，涉及金额计算时，直接使用 double、float 等进行运算，会存在精度损失
category: java
---

## 1. 概要

程序中，涉及金额计算时，使用 double、float、long 、int 等，可能无法精确表示金额，特别是多个金额的累加，因此，在程序中，需要探索最佳实践。

## 2. 最佳实践

几个方面：

1. 浮点数
1. 大整数

### 2.1. 浮点数

涉及浮点数时，避免使用 double、float，优先采用 BigDecimal 来参与计算：

* [关于double类型在浮点运算过程中出现的精度问题以及解决方案]

**典型场景**：

1. **第三方账单**，金额为浮点数时，采用 BigDecimal 参与金额计算。
1. **内部系统**，金额为浮点数时，采用 BigDecimal 参与金额计算。
1. **特别说明**：内部系统设计时，尽可能采用「整数」表示金额。


### 2.2. 大整数

TODO



## 3. 参考资料

* [关于double类型在浮点运算过程中出现的精度问题以及解决方案]











[NingG]:			http://ningg.github.com  "NingG"
[关于double类型在浮点运算过程中出现的精度问题以及解决方案]:	https://tidercreverse-group.iteye.com/group/topic/25085	"关于double类型在浮点运算过程中出现的精度问题以及解决方案"













