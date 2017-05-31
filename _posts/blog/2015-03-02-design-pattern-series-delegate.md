---
layout: post
title: 设计模式：委派模式 Delegate
description: 存在感对于每个人的生活有多么的重要，可能平时并不是太关注，其实他就是生活的全部
published: true
category: blog
---

## 1. 委派模式 Delegate

委派模式，目标：

* 在使用指定类的同时，保护指定类，向调用方隐藏类内部细节。

委派模式，描述：

1. 无继承关系：`类D`跟`类O`，没有继承关系，通常`类D`内部有一个内部属性为`类O`
1. 同名方法和属性：`类D`内部定义了`类O`内的所有同名方法和属性
1. 功能相同：调用`类D`的方法和属性，本质就是转向调用`类O`内部的方法和属性

## 2. 实例

类 DelegateClass 和 类 OriginalClass 的简单示例：

DelegateClass 类：

```
package top.ningg.design.delegate;
 
public class OriginalClass {
 
    public void methodA(){
        System.out.println("invoke method A");
    }
 
    public void methodB(){
        System.out.println("invoke method B");
    }
 
}
```

OriginalClass 类：

```
package top.ningg.design.delegate;
 
public class DelegateClass {
 
    private OriginalClass originalClass = new OriginalClass();
 
    public void methodA() {
        originalClass.methodA();
    }
 
    public void methodB() {
        originalClass.methodB();
    }
}
```











































[NingG]:    http://ningg.github.com  "NingG"










