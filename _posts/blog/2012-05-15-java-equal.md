---
layout: post
title: Java 基础：equals 方法，判断两个对象是否相等
description: equals方法与==的比较
published: true
category: java
---




equals方法，需要满足以下三点： 

1. 自反性：就是说a.equals(a)必须为true。 
1. 对称性：就是说a.equals(b)为true的话，b.equals(a)也必须为true。 
1. 传递性：就是说a.equals(b)为true，并且b.equals(c)为true的话，a.equals(c)也必须为true。 



重写 `hashCode()` 的原则： 

* **不唯一原则**：不必对每个不同的对象都产生一个唯一的 hashCode，只要你的 hashCode 方法使get()能够得到put()放进去的内容就可以了。
* **分散原则**：生成 hashCode 的算法尽量使 hashCode 的值分散一些，不要很多 hashCode 都集中在一个范围内，这样有利于提高HashMap的性能；
* a.equals(b)，则a与b的hashCode()必须相等，因为，多数场景，比较 2 个对象是否相等之前，会判断 2 个对象的 hashCode 是否相等；

## Object.equals()方法

代码如下：

	public boolean equals(Object obj) {
		return (this == obj);
    }

直接比较两个基础类型的值是否相等、两个对象的内存地址是否相同。


## String.equals()方法

String中`equals()`方法，要求两个String的值相等即可；

代码如下：

    public boolean equals(Object anObject) {
	if (this == anObject) {
	    return true;
	}
	if (anObject instanceof String) {
	    String anotherString = (String)anObject;
	    int n = count;
	    if (n == anotherString.count) {
		char v1[] = value;
		char v2[] = anotherString.value;
		int i = offset;
		int j = anotherString.offset;
		while (n-- != 0) {
		    if (v1[i++] != v2[j++])
			return false;
		}
		return true;
	    }
	}
	return false;
    }








[NingG]:    http://ningg.github.com  "NingG"











