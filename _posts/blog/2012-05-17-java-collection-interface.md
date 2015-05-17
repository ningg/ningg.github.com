---
layout: post
title: Java容器 - List、Set、Map
description: Java中容器类，2个接口，Collection和Map
published: true
category: Java
---

容器是Java语言中比较重要的一部分，Java中容器类，由两个接口派生而来：Collection和Map。

##Collection vs Collections

首先，Collection 和 Collections 是两个不同的概念。

*Collection是容器层次结构中根接口。
*Collections是一个提供一些处理容器类静态方法的类。

JDK不提供Collection接口的具体实现，而是提供了更加具体的子接口（如Set和List）实现。那Collection接口存在有何作用呢？原因在于：所有容器的实现类（如ArrayList实现了List接口，HashSet实现了Set接口）提供了**两个‘标准’的构造函数**：

* 无参的构造方法（void）
* 带有Collection类型单参数构造方法，用于创建一个具有其参数相同元素新的Collection及其实现类等。*（允许容器之间相互的复制）*

##Collection的类层次结构

下面的图是关于Collection的类的层次结构。

![](/images/java-collection-interface/java-collection-hierarchy_thumb.jpg)

 

###Set：

特点：

* 不包括重复元素（包括可变对象）*（不包含满足 a.equals(b) 的元素对a和b）*
* 无序
* 最多有一个null
* 常用Set：HashSet、TreeSet


###List：

几点：

* 元素可以重复 *（允许满足 e1.equals(e2) 的元素对 e1 和 e2）*
* 有序
* 允许多个 null 元素
* 常用List：ArrayList、LinkedList、Vector、Stack等


###Queue：

几点：

* 一种队列则是**双端队列**，支持在头、尾两端插入和移除元素；常用Queue：ArrayDeque、LinkedBlockingDeque、LinkedList；
* 一种是**阻塞式队列**，队列满了以后再插入元素则会抛出异常，主要包括ArrayBlockQueue、PriorityBlockingQueue、LinkedBlockingQueue。虽然接口并未定义阻塞方法，但是实现类扩展了此接口。



##Map的类的层次结构

下面的图是Map的层次结构图

![](/images/java-collection-interface/MapClassHierarchy-600x354_thumb.jpg)


Map，几点：

* 键值对（Key - value）的集合
* key值不重复
* 常用Map：HashMap、TreeMap、HashTable、Properties、EnumMap。


##不同Collection的对比

todo：图形化显示下面的实现机制

ArrayList
LinkedList
HashMap
HashTable


###ArrayList的实现机制

查看源码描述，几点：

* 几个方法的实现都是`O(1)`：`size`，`isEmpty`，`get`，`set`；
* 底层基于**动态数组**实现，随着ArrayList中元素增加，动态数组的容量也在会扩充；
	* 默认，按增长`50%`扩充底层数组空间；
	* 每次动态扩充空间，都会分配新的内存，并进行数据复制；
* ArrayList不是线程安全的，`Vector`是基于ArrayList上的线程同步的实现，添加了`synchronized`修饰；
	* 创建List时，通过`Collections.synchronizedList`使其变为线程安全的；
	* `List list = Collections.synchronizedList(new ArrayList(...));`
* `iterator`调用时，不能对ArrayList中内容进行删除和新增，否则fail-fast，抛出异常；

###Vector的实现机制

查看源码，`Vector`与`ArrayList`基本类似，几点：

* 底层是**动态数组**：
	* 数组扩容时，按增长`100%`扩充；
* 线程安全的，使用synchronized修饰；



###LinkedList的实现机制

查看源码，几点：

* LinkedList，底层是双向链表；*（Entry包含了next和previous）*
* 不是线程安全的；
* add和remove元素，操作效率高，因为是链表；但get、set操作，由于需要操作指针，效率相对较低。


###HashMap的实现机制

几点：

* 底层是**数组链表**；
* HashMap，非线程安全的；可通过`Map m = Collections.synchronizedMap(new HashMap(...));`将其设置为线程安全的；
* 内部元素是无序的；
* 获取key对应Value的过程：通过对`key.hashcode`，再次进行Hash运算，确定key对应数组中链表的位置；
* 允许key为null，对应数组链表的起始位置；对key为null的情况，不会进行第二次Hash运算；
* HashMap构造函数包含两个参数：数组初始容量、加载因子
	* 数组初始容量，是指，数组长度；
	* 加载因子，用于设定一个阈值`初始容量 x 加载因子`，当HashMap中元素个数超过这个阈值时，数组容量扩充`2 x
 Old`；
	* 默认数组容量`16`，加载因子`0.75`；
	* 数组容量，始终为 **2的n次幂**，降低Hash冲突的概率，是数据分布更加均匀；
	* 当`length=2^n`时，`hashcode & (length-1) == hashcode % length`，增加操作效率；
	* 加载因子：是在时间和空间上的一个权衡；

Tips：

> HashMap中判断key与otherKey是否相等，两个要求：key.hashCode()相等，同时，key.equals(otherKey)；

示意图：

![](/images/java-collection-interface/hashmap-table.jpg)



###TreeMap的实现机制

几点：

* 基于红黑树*（平衡二叉树）*
* 内部元素有序，比较key之间的大小关系


Tips：

> 平衡二叉树：如果是排序好的搜索二叉树，则，树的期望高度为`log2(n)`，此时，搜索效率为`O(log(n))`，而极端情况下，如果搜索效率退化为`O(n)`，为避免这一现象，要求树的左右子树高度差值< 1，满足此条件的树，即为：平衡二叉树。


###HashTable的实现机制

几点：

* 基于数组链表；
* 数组初始长度、负载因子；
* 线程安全
* 不允许key和value为null
* 只进行一次hash运算，即，key.hashCode();
* 默认容量，按照`2 x Old + 1`的方式扩充；


###HashSet实现机制


通过查看源码，几点：

* 内部使用HashMap存储；
* 初始数组容量、负载因子，都是设置HashMap的；
* 判断两个元素是否相同，使用`hashCode()`和`equals()`两个方法；
* HashSet本质：在HashMap外进行包装，丢弃HashMap中的value，只保留key；


###TreeSet

几点：

* 通常基于TreeMap实现；*（也不一定）*
* 内部元素是有序的；










##对比


###Vector vs. ArrayList

几点：

* 相同点：都是基于动态数组；
* 不同点：
	* Vector是线程安全的，ArrayList不是；
	* Vector动态数组扩充 100%，ArrayList动态数组扩充 50%；






###Arraylist和Linkedlist

几点：

1. ArrayList 基于**动态数组**的数据结构，LinkedList基于**双向链表**的数据结构。
1. 对于随机访问get和set，ArrayList觉得优于LinkedList，因为LinkedList要移动指针。
1. 对于新增和删除操作add和remove，LinkedList比较占优势，因为ArrayList要移动数据*（remove时，要将后面数据前移；中间add数据时，要将数据后移；末端add时，若动态数组容量不足，要移动数据）*。
1. 两者都不是线程安全的；



###HashMap vs. TreeMap

几点：

* 元素是否有序：
	* HashMap中元素是无序的，通过key的hashCode进行查找；
	* TreeMap中元素保持固定顺序
* 底层数据结构：
	* HashMap，基于**数组链表**
	* TreeMap，基于**红黑树**
* 非线程安全：HashMap与TreeMap都是非线程安全的
* 是否可以调优：
	* HashMap，通过数组容量和负载因子，调优
	* TreeMap，红黑树，始终是平衡的，无法调优
* 适用场景：
	* HashMap，适合在Map中插入、删除、访问元素，因为使用Hash运算，相对红黑树，操作效率较高；
	* TreeMap，适合按自然顺序和定义的顺序遍历key

###HashMap vs. HashTable


几点：

* 是否线程安全：
	* HashTable，同步的，线程安全；
	* HashMap，非线程安全；
* key是否为null：
	* HashTable，不允许key和value为null；
	* HashMap，允许key和value为null；
* 进行几次Hash计算：
	* HashTable中，只计算一次key的HashCode
	* HashMap中，利用key.hashCode()，会再进行一次Hash运算；
* 数组容量扩充：
	* HashTable，`2 x Old + 1`
	* HashMap，`2 x Old`


###HashSet vs. TreeSet

本质就是HashMap与TreeMap的差异，几点：

* 是否有序
* 底层实现














##参考来源


* [Java 容器 & 泛型]
* [Hashmap实现原理]







[NingG]:    http://ningg.github.com  "NingG"


[Java 容器 & 泛型]:		http://www.bysocket.com/?p=162
[Hashmap实现原理]:		http://www.cnblogs.com/xwdreamer/archive/2012/05/14/2499339.html







