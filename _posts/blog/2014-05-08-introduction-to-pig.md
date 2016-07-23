---
layout: post
title: Pig入门1h
description: Pig，Hadoop生态体系中，数据处理利器
category: pig
---

> 开篇先推荐一个PPT：[Pig简介]，简要介绍了Pig的基本原理，重点说明了其与MapReduce的关系。

__副标题__: Pig入门 *_之_* 乱拳打死老师傅

## 从副标题展开说

先说一下为什么起这么一个副标题：前几天看电视剧消遣，有个小年轻，被质疑没有经验怎么办的时候，自己吹牛打气，说“我啥也不会，乱拳打死老师傅…”；这个，倒不是说对师傅的不尊敬，而是民间俗语，大概意思是：啥也不会的情况下，受领域内固有思想、规则约束的少，敢打敢拼，敢于突破陈规，往往能够带来新气象。*（不是要煽动大家起义、造反，而是，鼓励勇于突破、敢为天下先）。*

Pig知识的学习\介绍，大部分人会按照如下思路开展：

1.	Pig解决什么问题；*（pig产生背景）*
2.	Pig Latin语言的基本语法；*（配合一些基本操作）*
3.	Pig Latin语言的高级语法；*（针对一些特有的、容易出错的用法，进行详细介绍）*
4.	Pig脚本的调试；*（脚本不是一气呵成的，需要一些调试分析手段）*
5.	Pig的可扩展部分；*（Pig提供的内建函数，无法满足需求时，需要自己动手来实现Pig的对外接口）*
6.	Pig性能调优；*（上面所有的步骤，都在说如何去使用Pig来完成一件事，现在会说一下如何把事做好、做漂亮）*

需要这么多吗？学个东西，有这么复杂吗？*（上面开展的思路，是为了循序渐进、由浅入深，让你从原理到操作，能有一个全面的理解和掌握，嗯，一句话：为你好，才这么安排的）*

纳尼？我想说，你能直接一点么？上面`1、2、3、4、5、6`，看起来头都大了，唉，我只想使用Pig，不想知道他是怎么来的。

妥了，是个爽快的人，也算志同道合了，不多说：直接开始一步一步用Pig，让那些乱七八糟的东西见鬼去吧。

![pig-logo](/images/introduction-to-pig/pig-logo.jpg)

## Pig用起来

### 一个例子

准备数据文件`student`：

	$cat student
	Jun L. 	18	3.7
	Hhui H.	18	3.8
	Ning G.	20	3.6
	Hlong G.	22	3.6
	Chang W.	21	3.6

注：上述文件中，3列分别表示：姓名、年龄、GPA，他们之间都以TAB键分隔；

目标：求20岁以下和20岁以上的学生的人数以及gpa平均值

进入执行Pig 脚本的交互模式：

	$pig –x local

逐行输入如下pig脚本(`student_avg_gpa.pig`)：

	studentInfos = load ’student’ as (name: chararray, age:int, gpa:float);
	studentBag = group studentInfos all;
	result = foreach studentBag {
	  student_younger = filter studentInfos by age <= 20;
	  student_older = filter studentInfos by age > 20;
	  generate COUNT(studentInfos) as totalNum, AVG(studentInfos.gpa) as avgGPA, 
		COUNT(student_younger) as youngerNum, AVG(student_younger.gpa) as youngerAvgGPA, 
		COUNT(student_older) as olderNum, AVG(student_older.gpa) as olderAvgGPA;
	}
	dump result;

__备注__：可以将上面的脚本写在文件`student_avg_gpa.pig`内，在`grunt`交互场景下使用命令：`run <pigScript>` 来执行脚本。
	
看到结果了吗？

`(5,3.659999942779541,3,3.699999968210856,2,3.5999999046325684)`

总共6个值（`,`逗号分割）。

对于结果的说明：

1.	总共5人；平均GPA：约3.66；
2.	20岁以下（包含20岁）3人；平均GPA：约3.70；（pig对于float数据运算有误差）
3.	20岁以上2人；平均GPA：约3.60；

简要说一下：

	grunt> studentInfos = load ‘student’ as (name: chararray, age:int, gpa:float);

其中，`load`为加载数据的关键字，`student`表示数据文件位置，`as` 关键字为前面数据文件指定field别名和field类型。

可以使用如下命令，来查看一个`studentInfos`的数据结构：

	grunt> describe studentInfos
	studentInfos: {name: chararray,age: int,gpa: float}

使用如下命令，查看`studentInfos`的具体内容：

	grunt> dump studentInfos;
	(Jun L.,18,3.7)
	(Hhui H.,18,3.8)
	(Ning G.,20,3.6)
	(Hlong G.,22,3.6)
	(Chang W.,21,3.6)

上面 `describe`、`dump`命令输出的内容到底是什么玩意儿？

我们来解释一下：

	# describe studentInfos 命令输出如下：
	studentInfos: {name: chararray,age: int,gpa: float}

表示显示`studentInfos`的结构：

1.	`studentInfos`是一个`relation`，因为`studentInfos:{}`在冒号后指向了花括号`{}`，这是一个`relation`的标识；
2.	`studentInfos`内，`tuple`的结构为：`(name: chararray,age: int,gpa: float)`，即，包含3个字段，依次为`name`、`age`、`gpa`，名字后`:`之后字段对应的类型；

上面提到的`relation`、`tuple`是什么？从哪冒出来的？客官莫要着急，`relation`、`tuple`都是`Pig`内部的几个概念，且听我慢慢道来。

Pig定义了几个基本概念，用于描述数据结构：

1.	`field`，字段，某一位置的数据，即，`(Jun L.,18,3.7)`中包含了3个字段；类似RDBMS中Table中一行数据的一个字段；
2.	`tuple`，元组，是`field`的有序组合，使用`()`来标识，即，`(Jun L.,18,3.7)`表示一个`tuple`；类似RDBMS中Table中一行数据；
3.	`bag`，包，是`tuple`的无序组合，使用`{}`来标识，即，`{(Jun L.,18,3.7),(Hhui H.,18,3.8)}` 表示包含2个`tuple`的一个`bag`；类似RDBMS中的一个Table；
4.	`relation`，关系，`outer bag`，在此，暂时将`relation`与`bag`等价看待；

__补充__：`field`可以为任何类型，即，`tuple`、`bag`都可以作为`field`，包含在`tuple`中。

现在再回过头看一下，`studentInfos`的结构：

	grunt> describe studentInfos
	studentInfos: {name: chararray,age: int,gpa: float}

是不是很明朗了？*（什么？还不明朗？把上面的分析读3遍）*

有人问`studentInfos: {name: chararray,age: int,gpa: float}`中，`studentInfos`这个`relation`内部不应该是`tuple`吗？`tuple`不是应该以`()`标识吗？为什么不是`studentInfos: {(name: chararray,age: int,gpa: float)}`？这是因为`studentInfos`中的`tuple`不在一行，是分行输出的，下面会看到如果`relation`中`tuple`都在一行的情景。

将`studentInfos`按照所有字段进行`group`，即使有某2个`tuple`内容完全一致，也会统计为2个`tuple`，即，本质上`group..all`是将多行数据合并为一行。

	grunt> studentBag = group studentInfos all;

	grunt> describe studentBag;
	studentBag: {group: chararray,studentInfos: {(name: chararray,age: int,gpa: float)}}

	grunt> dump studentBag;
	(all,{(Jun L.,18,3.7),(Hhui H.,18,3.8),(Ning G.,20,3.5),(Hlong G.,22,3.6),(Chang W.,21,3.6)})

__补充__：`group`操作时，会生成一个`field`，命名为`group`，可以尝试如下命令：

	grunt> test = group studentInfos by age;

	grunt> describe test;
	test: {group: int,studentInfos: {(name: chararray,age: int,gpa: float)}}

	grunt> dump test;
	(18,{(Jun L.,18,3.7),(Hhui H.,18,3.8)})
	(20,{(Ning G.,20,3.6)})
	(21,{(Chang W.,21,3.6)})
	(22,{(Hlong G.,22,3.6)})



上面的命令：`load`、`group`多少有些过于简单，不刺激，不激动，下面的命令会有点意思：

	grunt> result = foreach studentBag {
	>>   student_younger = filter studentInfos by age <= 20;
	>>   student_older = filter studentInfos by age > 20;
	>>   generate COUNT(studentInfos) as totalNum, AVG(studentInfos.gpa) as avgGPA, 
			COUNT(student_younger) as youngerNum, AVG(student_younger.gpa) as youngerAvgGPA, 
			COUNT(student_older) as olderNum, AVG(student_older.gpa) as olderAvgGPA;
	>> }

有点复杂？稍等，拆解一下，再复杂的命令也会变得简单：

	student_younger = filter studentInfos by age <= 20;

`filter..by..`是过滤语句，此处，表示按照条件`age <= 20`过滤出不到20岁的学生，并且将结果指定给`student_younger`。

	generate COUNT(studentInfos) as totalNum, AVG(studentInfos.gpa) as avgGPA, 
		COUNT(student_younger) as youngerNum, AVG(student_younger.gpa) as youngerAvgGPA, 
		COUNT(student_older) as olderNum, AVG(student_older.gpa) as olderAvgGPA;

上面这个`generate ..`是生成数据的命令，`COUNT`、`AVG`都是内部提供的聚合函数，看其中的一个命令：

	generate COUNT(studentInfos) as totalNum, AVG(studentInfos.gpa) as avgGPA;

表示将`studentInfos`中包含的学生个数，以及所有学生的`gpa`平均值，组合成一个`tuple`，赋值给`result`；`as..` 关键字为这些`field`指定名字。

	grunt> describe result;
	result: {totalNum: long,avgGPA: double,youngerNum: long,youngerAvgGPA: double,olderNum: long,olderAvgGPA: double}

	grunt> dump result;
	(5,3.6399999618530274,3,3.6666666666666665,2,3.5999999046325684)


__建议__：把上面的例子，再输入执行2遍，多使用`describe`、`dump`命令配合查看执行过程。


### 练习一下

还是上面的`student`数据

	$cat student
	Jun L. 	18	3.7
	Hhui H.	18	3.8
	Ning G.	20	3.6
	Hlong G.	22	3.6
	Chang W.	21	3.6

注：上述文件中，姓名、年龄、GPA之间都以TAB键分隔；

__目标__：20岁以下学生的人数以及gpa平均值，以及这些学生的名字（要求只算出这些，其他东西不要求）。

这就成了上面问题的一部分，可以使用如下pig脚本：

	-- 加载数据、设定field名字、设定field类型
	studentInfos = load ’student’ as (name: chararray, age:int, gpa:float);

	-- 找出20岁以下的学生
	student_younger = filter studentInfos by age <= 20;

	-- 要调用聚合函数COUNT\AVG必须进行group，将所有列，转换为一行
	student_younger_bag = group student_younger all;

	-- 输出学生人数、平均GPA，以及学生名单(下一条命令实际为一行)
	result = foreach student_younger_bag generate COUNT(student_younger),
	 AVG(student_younger.gpa), student_younger.name;

	dump result;

输出结果为：

`(3,3.699999968210856,{(Jun L.),(Hhui H.),(Ning G.)})`

## 一篇博文

推荐codelast的一篇博文[Apache Pig基础概念及用法](http://www.codelast.com/?p=3621), 不要着急，放松放松，CodeLast的这篇博客很轻松，嗯，很适合入门，在此向原博主致敬。

## 参考来源

* [codeLast Apache Pig学习系列](http://www.codelast.com/?p=4550)
*（个人看法：非常不错，适合直接上手写pig脚本；）*
* [Pig编程指南](http://book.douban.com/subject/21357721/)（Alan Gates著， 曹坤 译， 2013年2月  第1版） 
*(个人看法：有理论、有深度、有广度，每次都有新感觉；)*
* [Pig documentation](http://pig.apache.org/docs/r0.12.1/)，
*(个人看法：特别详细，想要的东西，基本都能从这里找到，而且更新速度很快；)*

> 由于Pig版本迭代速度比较快，所以个人建议，最好能去官网查看文档。

![pig-on-elephant](/images/introduction-to-pig/pig-on-elephant.png)

[NingG]:    http://ningg.github.com  "NingG"
[Pig简介]:	/download/pig/introduction-to-pig.pptx "Pig简介，原理，简要说明"
