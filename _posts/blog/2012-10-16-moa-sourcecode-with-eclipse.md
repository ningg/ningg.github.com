---
layout:			post
title:			Eclipse下查看MOA源代码
category:		moa
description:	MOA:Massive Online Analysis,开源的数据流挖掘框架。
---
## 概要
本篇短文中，此目标包含两层意思：

1. 使用Eclipse快速查看java代码，特别是class之间的继承(extends)、实现(implements)等关系；
2. 针对MOA源码，有没有什么特别需要注意的地方？例如，快捷方式、项目文件的组织结构等。


依照上面对于目标的定位，本篇将着重讨论如下几个要点：

1. java基本理论知识，针对类、继承、抽象类、接口、注解、反射的基本含义及作用进行说明；
2. Eclipse下的快捷键，特别是源代码查询，类间继承关系、接口的实现关系的快捷查看；
3. MOA基础知识：主要是MOA的目录结构、基本class、interface

此次考虑的`class`，主要是跟算法相分离的基本`class`，分为以下2类：

1. 负责数据存储功能的class，与此同时提供了对数据的基本操作方法：Instance、Stream等；
2. 规定算法实现接口的class，这些class一般是Interface或者 Abstract class。


## 示例准备

此次采用的例子是[MOA]的[Tutorial2]中提供的两个示例代码：
### 代码一：`ApiOfTest1.java`
```
源代码名称: ApiOfTest1.java
文档中对应位置：Listing 1
基本功能描述：生成一个stream，并使用learner对其进行学习。
```
__补充说明：__ 本次例子`ApiOfTest1.java`中使用的`stream`和`learner`做出改动，如下：

    RandomTreeGenerator stream = new RandomTreeGenerator();
    Classifier learner = new DecisionStumpTutorial();

### 代码二：`DecisionStumpTutorial.java`
```
源代码名称: DecisionStumpTutorial.java
文档中对应位置：Listing 8
基本功能描述：实现了一个单层的决策树分类算法（decision stump classifier）
```


[MOA]: http://moa.cms.waikato.ac.nz/ "Massive Online Analysis"
[Tutorial2]: http://sourceforge.net/projects/moa-datastream/files/documentation/Tutorial2.pdf "Introduction to the API of MOA"


## java基本知识

### 类（class）

_说明_ ：由属性（`attribute`）和方法（`method`）构成。
 
### 继承（extends）

_说明_ ：`java`中类（`class`）是__单继承__的，即，最多只能继承一个类。
 
### 抽象类（abstract class）

_说明_ : 无法具体的对象被定义为抽象类（`abstract class`）；

有时候，我们可能想要构造一个很抽象的父类对象，它可能仅仅代表一种分类或抽象概念，它的实例没有任何意义，因此不希望它能被实例化。例如：有一个父类`水果（Fruit）`，它有几个子类`苹果（Apple）`、`橘子（Orange）`、`香蕉（Banana）`等。`水果`在这里仅仅只是作为一种分类，显然`水果`的实例没有什么意义（就好像一个人如果告诉你他买了一些`水果`但是却不告诉你是`苹果`还是`橘子`，你很难想象他到底买的是什么）。而`水果类`又要能被子类化，这就要求我们使用抽象类（`abstract class`）来解决这个问题。

_说明_ ：抽象类，可以有抽象方法，但不能实例化。例如：

```java
//定义抽象类水果（Fruit）
public abstract class Fruit {
……
}
//如果我们试图用以下语句来获得一个实例，将无法编译成功。
Fruit fruit = new Fruit();
```

_说明_ ：抽象类中可以有实例属性。
 
### 接口（interface）

接口也是抽象对象，它甚至比抽象类更抽象。__接口中的方法都是抽象方法__。
一个接口可以`继承`其他接口；一个类通过关键字implements声明要`实现`一个接口，并具体实现接口的方法。例如：

```java
//有一个接口InterfaceA，
public  interface  InterfaceA {
    void  methodA();
}
 
//类ClassA实现接口InterfaceA。
public  class  ClassA implements InterfaceA {
    public  void  methodA() {
    System.out.println( ”methodA of ClassA implements InterfaceA” );
    }
}
```
_说明_ ：正常的`class`实现（`implements`）接口（`interface`），必须实现接口定义的所有方法；但抽象类（`abstract class`）实现接口，可以不用实现接口定义的方法。
_说明_ ：接口中不能有实例属性，如果有属性，必须为静态的常量（`static final`）
_说明_ ：`java`中一个类，可以同时实现（`implements`）多个接口（`interface`）
 
### 注解（annotation）

Java注解是附加在代码中的一些元信息，用于一些工具在编译、运行时进行解析和使用，起到说明、配置的功能。注解不会也不能影响代码的实际逻辑，仅仅起到辅助性的作用。包含在 `java.lang.annotation` 包中。
_说明_ ：此次只对注解`@Override`进行说明：
`@Override`注解用于类方法(`Method`)，
表示一个方法声明打算重写超类中的另一个方法声明。如果方法利用此注释类型进行注解但没有重写超类方法，则编译器会生成一条错误消息。
 
### 反射（Reflection）

_说明_ ：程序运行时，通过反射获得某个类中的各种变量，函数，数组，构造函数以及类本身，并使用它们。
 
### 其他概念：内部类
(doing...)


## MOA基本知识

参看MOA自带文档，并且对于instanse的基本类借用于weka工程。

 
