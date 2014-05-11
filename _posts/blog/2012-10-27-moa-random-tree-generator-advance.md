---
layout:        post
title:         MOA中RandomTreeGenerator[Advanced]
category:      MOA
description:   MOA中随机树(Random Tree)数据流产生器深入探索
---

##1.简介
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

##2.对外继承关系

几个基本的快捷键：

|操作	|说明		|
|:--|:--|
|Ctrl + 鼠标左击	|查看class、method、attribute的源代码	|
|Alt  + ←			|返回上一次鼠标位置		|
|Alt  + →			|与“Alt + ←”相反		|
|F4					|查看Class的继承关系	|

使用快捷键 `F4`,查看`RandomTreeGenerator`的继承关系，如下图所示。它直接继承了类`AbstractOptionHandler`,并实现了接口`InstanceStream`。

![RandomTreeGenerator-1](/images/moa-random-tree-generator-advance/RandomTreeGenerator-1.png)

__抽象类`AbstractOptionHandler`__，用于实现`MOA`的`GUI`接口。一个`Class`，如果需要在图形界面上进行参数设置，就需要继承这个类。具体说明如下：

* 继承自抽象类`AbstractMOAObject`，此类提供测量`Class`实例化对象的大小、复制对象、返回对象描述信息的方法。（具体实现的方法：`public int measureByteSize()`、`public MOAObject copy()`；未实现的方法：`public void getDescription(StringBuilder,int)`。）
* 实现接口`OptionHandler`，统一处理`Option`的方法；

__接口`InstanceStream`__，规定了一个`data stream`所必须实现的方法，统一了`data stream`对外的方法。

观察上图，发现很多class实现了`MOAObject`接口（继承自接口`Serializable`）,具体说明如下：

* `MOA`中所有的`Class`都要实现这个接口；
* __作用__：统一3个方法，测量`Class`实例化对象大小（`public int measureByteSize()`;）、复制对象（`public MOAObject copy()`;）、返回对象的描述信息（`public void  getDescription(StringBuilder sb, int indent)`;）


隐藏了重复的`MOAObject`接口，可以将`RandomTreeGenerator`的继承关系，精简如图：图中既有类（`class`），又有抽象类（`Abstract class`）和接口（`Interface`），下面简要讨论他们之间的关系：

![RandomTreeGenerator-2](/images/moa-random-tree-generator-advance/RandomTreeGenerator-2.png)


1. 抽象类（`Abstract Class`）至少有一个方法没有具体的实现，是抽象方法；可以有实例属性；
2. 接口（Interface）所有方法都是抽象方法，没有具体实现；不能有实例属性，如果有属性，一定是静态常量（static final）；
3. 正常的Class只能继承（extends）一个类（class、abstract class），这就是Java的单继承性；但是可以实现（implements）多个接口（interface）；
4. class实现（Implements）接口（Interface），必须实现接口定义的所有方法（因为接口中方法都是抽象方法，没有具体实现，所以class中必须予以具体是实现）；
5. Abstract class实现（Implements）接口（Interface），不一定要实现接口中的方法（因为抽象类Abstract Class中本来就可以存在抽象方法）；
6. 接口（Interface）可以继承（extends）接口（Interface）；
更详细的知识，可以参考“eclipse下查看MOA源代码”中java基础知识部分。


##3.内部成员

在"__2. 对外继承关系__"讨论的基础上，可以得出结论：

1. `RandomTreeGenerator`的内部属性成员来源：`RandomTreeGenerator`自己定义，`AbstractOptionHandler`内定义，`AbstractMOAobject`内定义，`Object`中定义；
2. `RandomTreeGenerator`的内部方法成员来源：`InstanceStream`、`OptionHandler`、`MOAObject`、`Serializable`接口中定义,`Object`中实现的方法；部分抽象类中实现的方法；

为了充分发挥eclipse的作用，推荐先查看`eclipse`的帮助文件中`Type Hierarchy`部分,下面的一些查看源码操作都是基于此进行的。

补充知识，`Object`类是`Java`中所有类的父类.

说明：内部成员重点分析方法成员，默认属性成员为方法成员服务（方法成员实现某一功能，需要一些数据，因此添加了属性成员）。

方法成员，重点考虑如下几个：

* InstanceStream接口；
* AbstractOptionHandler抽象类；
* AbstractMOAObject抽象类；
* OptionHandler接口；
* MOAObject接口；

现在我需要去查询MOA的API文档（或者查看MOA工程的源代码），分析、记忆上面几个类、接口中的__方法成员__。[关键*]

##4. 使用RandomTreeGenerator

使用分为3个步骤，说明如下：

	//new一个对象
	RandomTreeGenerator stream = new RandomTreeGenerator();
	//使用前，做一个初始化
	stream.prepareForUse();
	//判断stream中是否还有instance，并获得下一个instance
	while(stream.hasMoreInstances()){
		   Instance trainInst = stream.nextInstance();
	}

##5. 定义一个stream的generator

只需要按下面来进行定义，并补充实现其中抽象方法即可，这就是java编写代码的好处，使用继承可以快速开发自己的类；代码如下：


	public class YourselfGenerator extends AbstractOptionHandler implements InstanceStream

##6. data stream的数学含义

data stream的数学表示是什么？程序中存储在什么地方？

`data_stream`数学上可以表示为：`<instance1,instance2,…inxtanceN,…>`，即以源源不断的`Instance`来表示。

在MOA中，一个类，只要实现了接口`InstranceStream`，就认为他是一个`data stream`的产生器。通常，`data stream`并没有一次性产生所有的Instance并存储下来，而是采用`产生一个Instance，使用一个`的原则来实现。为实现一个`data_stream`，`MOA`提供了几个基本的类：`Attribute`、`Instance`、`Instances`、`InstancesHeader`。

##7. 数据存储相关的class

数据存储相关的class：Attribute、Instance、Instances、InstancesHeader

* Attribute: weka.core包中，定义属性；(weka)
* Instance: weka.core包中，定义instance（由attribute构成）；（weka）
* Instances: weka.core包中，定义dataset（instance的集合）；（weka）

###7.1 weka.core.Atribute

weka.core.Atribute（Class）用来表示Instance中的一个属性，共计可以表示5种：numeric、nominal、string、date、relational（这个需要注意）；典型的用法（code from the main() method of this class）：

	// Create numeric attributes "length" and "weight"
	Attribute length = new Attribute("length");
	Attribute weight = new Attribute("weight");
	 
	// Create list to hold nominal values "first", "second", "third"
	List my_nominal_values = new ArrayList(3);
	my_nominal_values.add("first");
	my_nominal_values.add("second");
	my_nominal_values.add("third");
	 
	// Create nominal attribute "position"
	Attribute position = new Attribute("position", my_nominal_values);
	 
	...



###7.2 weka.core.Instance

weka.core.Instance(Interface),（下图表示了weka.core.Instance的继承关系）此接口统一了instance对外调用的方法；subclass：weka.core.AbstractInstance，直接由Attribute构成，用于表示data_stream中的一个例子；对于所有的Attibute类型（5种），都以浮点数（floating-point）来存储，如果Attribute类型是：nominal、string、relational，则存储的值表示相应类型真实值的索引位置。

![Instance_继承关系](/images/moa-random-tree-generator-advance/Instance.png)

举例，对于nominal属性：男，女；在存储时，使用：1,2；则1表示男，2表示女。从weka.core.Instance的继承图，可以看出DenseInstance、SparseInstance是具体实现。Instance的典型使用代码如下：

	  // Create empty instance with three attribute values
	  Instance inst = new DenseInstance(3);
	 
	  // Set instance's values for the attributes "length", "weight", and "position"
	  inst.setValue(length, 5.3); 
	  inst.setValue(weight, 300); 
	  inst.setValue(position, "first"); 
	 
	  // Set instance's dataset to be the dataset "race" 
	  inst.setDataset(race); 
	 
	  // Print the instance 
	  System.out.println("The instance: " + inst); 
	 
	  ...

由于只是片段，上面的这段代码有些晦涩；几点补充：
setValue方法：

	public final void setValue(int attIndex, String value)
	...
	public final void setValue(Attribute att, double value)
	...
	public final void setValue(Attribute att, String value)
	...

上面是weka.core.Instance(Interface)中定义，并在weka.core.AbstractInstance中进行了实现，他们的本质都是调用在weka.core.Instance中定义的setValue(int,double)方法，他在具体的class中（DenseInstance、SparseInstance）进行实现。weka.core.Instance中代码定义如下：

	public final void setValue(int attIndex, double value)
	...

setDataset方法：

	public final void setDataset(Instances instances)
	...

上面是weka.core.AbstractInstance中的具体实现。其中Instances将在下面进行介绍。

###7.3 weka.core.Instances

weka.core.Instances(Class)，他的继承关系如下图，特别需要说明的是：

![Instances_继承关系](/images/moa-random-tree-generator-advance/Instances.png)

	public class Instances extends AbstractList
		 implements Serializable, RevisionHandler
	...

Instances继承自一个由Instance组成的链表，其内部所有修改dataset的方法，都是针对备份进行的，并不涉及原始的dataset。

