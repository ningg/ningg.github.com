---
layout: post
title: java中数组（Array）
description: 数组分为，基础类型数组和对象数组
category: java
---


##基础类型的数组

基础类型：int，byte，char，double等；

关于数组，几点：

* 数组以`[]`标识；
* 数组为高级数据类型，需要用`new`；
* 定义数组长度，`new type[size]`；
* 初始化赋值，`{}`，内部以`,`分隔；


###声明和初始化

	int[] intArray1 = new int[10];
	int[] intArray2 = {1,2,3,4};

	
###操作

对一个数组，可以进行的操作有：

* 复制
* 输出
* 排序
* 查找
* 清零

**特别说明**：这些操作大都已经作为基本的操作，封装在`java.util.Arrays`类中了。

###复制

用到了`System.arraycopy`方法，示例代码如下：

	int[] intArray1 = new int[10];
	int[] intArray2 = {1,2,3,4};
	
	System.arraycopy(intArray2, 0, intArray1, 0, 2);
	System.out.println();

也可以使用`java.util.Arrays`类中`copyOfRange`方法：

	int[] intArray2 = {1,2,3,4};
	int[] intArray3 = Arrays.copyOfRange(intArray2, 0, 2);

**备注**：`Arrays.copyOfRange()`实质调用的也是`System.arraycopy()`。

###输出


`Arrays.toString`可以直接输出整个数组的内容：

	int[] intArray2 = {1,2,3,4,2};
	System.out.println(Arrays.toString(intArray2));



###排序

排序，调用`Arrays.sort()`，默认升序排列；本质是快排算法：

	int[] intArray2 = {1,2,3,4,2};
	Arrays.sort(intArray2);



###查找


直接调用`Arrays.binarySearch`方法即可，但要求，调用此方法之前，必须对整个Array进行排序，即`Arrays.sort()`方法，否则，得到的结果可能有错；




##对象的数组

对象的数组，与基础类型的基本一致，包含几点：

* 声明与初始化：`Object[] objArray = new Object[10];`
* 复制：`Arrays.copyOf()`，本质仍然为`System.arraycopy`
* 输出：`Arrays.binarySearch()`
* 排序：`Arrays.sort()`




##数组链表

特别说明，数组链表，本质是`链表`，只不过其底层采用`数组`形式实现，即，`数组链表`对应：连续的存储空间；但，因为`数组链表`（ArrayList）与`数组`名称相似，下文将对`数组链表`进行简要分析。


（doing... ArrayList的创建、操作，特别是，底层实现机制）




##参考来源


* [Java Tutorials：Arrays][Java Tutorials：Arrays]
* java.utils.Arrays的源码（利用Maven工具查看）








[NingG]:    						http://ningg.github.com  "NingG"
[Java Tutorials：Arrays]:			http://docs.oracle.com/javase/tutorial/java/nutsandbolts/arrays.html





