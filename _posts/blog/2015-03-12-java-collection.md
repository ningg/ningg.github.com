---
layout: post
title: java中集合类简介
description: 集合类的适用场景？几段典型代码
category: java
---

初步想到几点：

* set、list、map各自：
	* 新建对象
	* 添加、删除元素
	* 排序
	* 输出
* set、list、map之间相互转换
* guava在处理集合类方面提供的便利





###场景：统计一组word中，各个word出现的频率，并按序输出


两条路：

* JDK自带API；
* 借助第三方jar包；

第三方jar包guava的排序操作，示例代码如下：

	Object[] result = null;
	String[] stringArray = {"a", "b", "c", "a", "d", "d", "e", "f", "f", "f"};
	List<String> listOfStr = Arrays.asList(stringArray);
	result =  Multisets.copyHighestCountFirst(ImmutableMultiset.copyOf(stringArray)).elementSet().toArray();
	System.out.println(Arrays.toString(result));


具体参考：

* http://gotoanswer.stanford.edu/?q=Most+efficient+way+to+order+an+array+of+Strings+by+frequency
* http://stackoverflow.com/questions/4345633/simplest-way-to-iterate-through-a-multiset-in-the-order-of-element-frequency#
* http://www.mkyong.com/java/how-to-count-duplicated-items-in-java-list/

















[NingG]:    http://ningg.github.com  "NingG"












