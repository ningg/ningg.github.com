---
layout: post
title: Maven 系列：mvnw
description: mvnw，全名 maven wrapper，用于保证不同环境下的maven版本一致
published: true
category: maven
---

## 1.背景

maven是一款非常流行的java项目构建软件，它集项目的依赖管理、测试用例运行、打包、构件管理于一身。

如何保证不同环境下的maven版本一致呢？

1. 公司内部：规定 maven 版本，以此统一 maven 版本，
1. 开源项目：依赖 mvnw

mvnw，全名 maven wrapper，它的原理是：

1. 在`maven-wrapper.properties`文件中，记录使用的`maven版本`
1. 当用户执行 `mvnw clean` 命令时，若 Maven 版本不一致，则，下载期望的版本，然后再执行 `mvn` 命令；

## 2.开启 mvnw

为项目添加 mvnw 支持很简单，有两种方式可选：

1. pom 文件中，增加 maven wrapper 的 plugin
1. 命令行中，指定 maven 版本


### 2.1.方法一：在 pom.xml 中添加 plugin 声明

`pom.xml` 中，增加 maven wrapper 的 plugin：

```
<plugin>
    <groupId>com.rimerosolutions.maven.plugins</groupId>
    <artifactId>wrapper-maven-plugin</artifactId>
    <version>0.0.4</version>
</plugin>
```

这样当我们执行 `mvn wrapper:wrapper` 时，会帮我们生成 `mvnw.bat`, `mvnw`, `maven/maven-wrapper.jar`, `maven/maven-wrapper.properties`这些文件。

然后，我们就可以使用`mvnw`代替`mvn`命令，执行所有的maven命令，比如`mvnw clean package`


### 2.2.方法二：直接执行 goal
 

直接指定 maven 版本：

```
# 期望使用的maven的版本为3.3.3
mvn -N io.takari:maven:wrapper -Dmaven=3.3.3 
```

产生的内容和第一种方式是一样的，只是目录结构不一样：

* `maven-wrapper.jar`和`maven-wrapper.properties`在`.mvn/wrapper`目录下



## 3.参考资料

* [http://www.javacoder.cn/?p=759](http://www.javacoder.cn/?p=759)


















[NingG]:    http://ningg.github.com  "NingG"










