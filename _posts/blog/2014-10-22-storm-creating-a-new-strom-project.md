---
layout: post
title: Storm：Creating a new Storm project
description: Storm官方文档的阅读和笔记
categories: storm big-data
---

> 原文地址：[Creating a new Storm project](http://storm.apache.org/documentation/Creating-a-new-Storm-project.html)，本文使用`英文原文+中文注释`方式来写。

This page outlines how to set up a Storm project for development. The steps are:
（本文重点：介绍如何设置一个Storm project用于开发。）

1. Add Storm jars to classpath（把storm的jar添加到classpath中）
1. If using multilang, add multilang dir to classpath（如果用了multilang，将dir添加到classpath中）

Follow along to see how to set up the [storm-starter](http://github.com/nathanmarz/storm-starter) project in Eclipse.

##Add Storm jars to classpath

You’ll need the Storm jars on your classpath to develop Storm topologies. Using [Maven](http://storm.apache.org/documentation/Maven.html) is highly recommended. [Here’s an example](https://github.com/nathanmarz/storm-starter/blob/master/m2-pom.xml) of how to setup your pom.xml for a Storm project. If you don’t want to use Maven, you can include the jars from the Storm release on your classpath.
（推荐使用Maven方式，将Storm的jar包添加到classpath中）


[storm-starter](http://github.com/nathanmarz/storm-starter) uses [Leiningen](http://github.com/technomancy/leiningen) for build and dependency resolution. You can install leiningen by downloading [this script](https://raw.github.com/technomancy/leiningen/stable/bin/lein), placing it on your path, and making it executable. To retrieve the dependencies for Storm, simply run `lein deps` in the project root.
（storm-starter project用了Leiningen来构建和进行依赖管理的，因此，下载Leiningen到本地，保证其可以执行，然后到project的根目录，执行`lein deps`命令，来获取Storm的依赖）

To set up the classpath in Eclipse, create a new Java project, include `src/jvm/` as a source path, and make sure all the jars in `lib/` and `lib/dev/` are in the Referenced Libraries section of the project.
（创建java project，将`src/jvm/`设置为source path，并将`lib/`和`lib/dev/`添加到build path中）


##If using multilang, add multilang dir to classpath

If you implement spouts or bolts in languages other than Java, then those implementations should be under the `multilang/resources/` directory of the project. For Storm to find these files in local mode, the `resources/` dir needs to be on the classpath. You can do this in Eclipse by adding `multilang/` as a source folder. You may also need to add `multilang/resources` as a source directory.
（使用multilang编写spout和bolt时，需要将实际的源代码放在`multilang/resources/`目录）

For more information on writing topologies in other languages, see [Using non-JVM languages with Storm](http://storm.apache.org/documentation/Using-non-JVM-languages-with-Storm.html).

To test that everything is working in Eclipse, you should now be able to `Run` the `WordCountTopology.java` file. You will see messages being emitted at the console for 10 seconds.

##参考来源

* [Apache Storm](http://storm.apache.org/)
* [Apache Storm: Documentation Rationale](http://storm.apache.org/documentation/Rationale.html)




[NingG]:    http://ningg.github.com  "NingG"
