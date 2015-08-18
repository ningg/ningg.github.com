---
layout: post
title: 集合类、字符串
description: Guava梳理
published: true
category: guava
---



Guava 功能很强大，从自己的实际问题入手，进行学习和梳理，整体上来说几点：

* 集合类的简写
* 字符串的处理


## 0. 常见场景


几点：

* 集合类的初始化
* 集合类的过滤器
* 集合类的转换器


### 0.1 集合类初始化

示例代码如下：

	// 初始化 Map
	Map<String, List<String>> map = Maps.newHashMap();
	List<String> list = Lists.newLinkedList();
	Set<String> set = Sets.newHashSet()
	
	// 集合常量，方式1
	Map<String, String> map = ImmutableMap.of("one", "1", "two", "2");
	List<String> list = ImmutableList.of("a", "b");
	Set<String> set = ImmutableSet.of("a", "b");
	
	// 集合常量，方式2
	ImmutableMap<Object, Object> map = ImmutableMap.builder().put("one", "1").put("two", "2").build();
	ImmutableList<Object> list = ImmutableList.builder().add("a").add("b").build(); 
	ImmutableSet<Object> set = ImmutableSet.builder().add("a").add("b").build();
	
	


### 0.2 过滤器和转换器


简单解释一下：

* 过滤器：filter 方法，配合 Predicate 用于判断某个对象是否符合一定条件。
* 转换器：transform 方法，配合 Function 用于把一种类型的对象转化为另一种类型的对象。

Note：Sets、Lists，都只有 filter 或 transform 两个方法中的一个，如果希望同时进行过滤和转换，可以借用 Collections2 下的 filter 和 transform 方法。具体示例代码如下：

	// 正常的 filter 和 transform
	
	
	// Lists 没有 filter 方法
	Lists.newArrayList(Collections2.filter(list, predicate));
	
	// Sets 没有 transform 方法
	Sets.newHashSet(Collections2.transform(set, function));
	
	// 同时进行过滤和转换操作，推荐写法
    List<Integer> outpuList = Lists.newLinkedList(
            FluentIterable.from(inputList).
                    filter(new Predicate<String>() {
                        public boolean apply(String input) {
                            return input.length() < 3;
                        }
                    }).
                    transform(new Function<String, Integer>() {
                        public Integer apply(String input) {
                            return input.length();
                        }
                    }));


上述使用 FluentIterable 进行链式的过滤和转换。




### 0.3 新增数据结构

一些典型场景：

* 经常有这样的场景，有一个数组，计算其中每个元素出现的次数，每次都重复写一遍有意思吗？
	* 直接把这个arr放进Guava的Multiset集合，它帮你高效的统计每个元素出现的次数。
* 有时候要处理双向映射，比如说userid和username互相映射，这个时候怎么办？自己建两个Map吗？
	* Guava的BiMap完美处理双向映射。
* 有时候有一些集合不需要被后续的代码改动，我们需要一些不可变的集合，保证安全，java内置的集合类是不支持这种不可变集合的，Guava补上了这个功能
	* 常用的有ImmutableMap，ImmutableList等

几类数据结构简介：

* MultiSet 重复put一个value会记录次数的set.
* MultiMap 可以用来替代Map<K, List<V>>或Map<K, Set<V>>
* BiMap 一般的map是value = get(key),BiMap可以轻易的转化后实现key = get(value).当然限制就是key,value的映射都是唯一的。
* Table 可以用来替代Map<K,Map<V,X>>的结构，相当于两个key映射一个value的形式。

示例代码如下：

	// 下述不能使用 HashMultiMap.create() 来初始化，否则无法统计不同的 value
	ListMultimap<String, String> multimap = ArrayListMultimap.create();
	for (President pres : US_PRESIDENTS_IN_ORDER) {
	  multimap.put(pres.firstName(), pres.lastName());
	}
	
	//多Value Map
	for (String firstName : multimap.keySet()) {
	  List<String> lastNames = multimap.get(firstName);
	  out.println(firstName + ": " + lastNames);
	}




### 0.4 字符串处理

示例代码：

	// 忽略 null， List -> String
	Joiner.on(",").skipNulls().join("a", "b", "c", null, "d")
	
	// 替换 Null
	Joiner.on(",").useForNull("N").join("a", "b", "c", null, "d")
	
	// String -> List
	Splitter.on(",").trimResults().omitEmptyStrings().split(",a,b ,c");
	
	// 判断 String 是否为空
	Strings.isNullOrEmpty(inputStr);
	
	

### 0.5 Feature

为 Feature 绑定回调事件：

        //JDK中Future的使用方式
        ExecutorService executorService = Executors.newFixedThreadPool(5);
        Future<String> future = executorService.submit(new Callable<String>() {
              @Override
              public String call() throws Exception {
                    return "hello!";
                  }
        });
        System.out.println(future.get());
         
        //Guava中ListenableFuture的使用方式
        ListeningExecutorService listeningExecutorService = MoreExecutors.listeningDecorator(executorService);
        ListenableFuture<String> listenableFuture = listeningExecutorService.submit(new Callable<String>() {
              @Override
              public String call() throws Exception {
                    return "callable return";
                  }
        });
        
        Futures.addCallback(listenableFuture, new FutureCallback<String>() {
              @Override
              public void onSuccess(@Nullable String result) {
                    System.out.println(result + " in success");
                  }
              @Override
              public void onFailure(Throwable t) {
                    System.out.println(t.getMessage() + t);
                  }
        });

	





## 1. 正式入门

Guava 是一个工具类，涵盖：

* 集合
* 字符串
* 缓存
* 并发
* IO
* 注解

正式入门之前，强调一下，Guava 使用过程中，遇到问题，简单查阅资料之后，如果问题仍无法解决，请去查阅官方一手资料：[Google Guava - wiki]，对于初学，请参阅：[Google Guava官方教程（中文版）]




等用一段时间，坑踩了一些了，理解深了，再过来整理。


todo...


































## 参考来源

* [Google Guava官方教程（中文版）]
* [Google Guava - wiki]
* [使用 Google Guava 美化你的 Java 代码：1~4]
















[NingG]:    		http://ningg.github.com  "NingG"
[Google Guava官方教程（中文版）]:			http://ifeve.com/google-guava/
[Google Guava - wiki]:					https://github.com/google/guava/wiki

[Multimap 多种实现方式]:					https://github.com/google/guava/wiki/NewCollectionTypesExplained#implementations-1


[使用 Google Guava 美化你的 Java 代码：1~4]:		http://my.oschina.net/leejun2005/blog/172328#OSC_h4_5





