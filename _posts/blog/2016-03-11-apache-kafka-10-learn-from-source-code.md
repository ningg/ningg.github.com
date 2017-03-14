---
layout: post
title: Apache Kafka 0.10 技术内幕：IDEA 下查看源码
description: Kafka 的源码阅读环境
published: true
category: kafka
---

## 1. 基本信息
基本信息：

|属性|值|备注|
|---|---|---|
|操作系统|Mac OS X EI Capitan|版本 10.11.1|
|IDEA|IDEA 14.1.1| |
|Kafka|Kafka 0.9.0.0|[https://github.com/apache/kafka](https://github.com/apache/kafka)|

## 2. 在 IDEA 下阅读 Kafka 源码
### 2.1. 下载 Kafka 源码

从 [https://github.com/apache/kafka](https://github.com/apache/kafka) 下载 Kafka 源码：

```
// 到指定目录
$ cd projects/Kafka
// 下载 Kafka 的源码
$ git clone git@github.com:apache/kafka.git
// 切换到 Kafka 0.9.0.0 版本的分支
$ git checkout -b origin/0.9.0 origin/0.9.0
```

生成 IDEA 工程，主要参考资料：

* Kafka 源码中的 README.md 文件
* [https://cwiki.apache.org/confluence/display/KAFKA/Developer+Setup#DeveloperSetup-IntellijSetup](https://cwiki.apache.org/confluence/display/KAFKA/Developer+Setup#DeveloperSetup-IntellijSetup)

### 2.2. 安装 gradle

安装 [gradle](http://www.gradle.org/installation), 执行命令：

```
// 查看 grandle 的详细信息，此处版本号为 gradle stable 2.8
$ brew info gradle
gradle: stable 2.8
...
  
  
// 安装 gradle
$ brew install gradle....
```

### 2.3. 安装 scala SDK

执行命令：

```
// 查看 scala 的详细信息，此处版本号为 scala: stable 2.11.7
$ brew info scala
scala: stable 2.11.7 (bottled), devel 2.12.0-M1
...
  
// 安装 scala
$ brew install scala
....
```

Note：brew 安装的 scala 路径为：`/usr/local/opt/scala`，在 IDEA 中设定 scala SDK 时，会用到这个路径。

### 2.4. 生成 IDEA 工程

执行命令：

```
cd <kafka.project.dir>
gradle
./gradlew idea
```

Note：实际上，此次使用 IDEA 的 Open `<kafka.project.dir>/build.gradle` 文件，以此生成 Kafka 的 IDEA 工程。

### 2.5. 效果

IDEA 下，查看 Kafka 工程效果，如下图：

![](/images/apache-kafka-10/kafka-source-code-in-idea.png)

## 3. Kafka 的编码规范

Kafka 源码遵循的编码规范，可以方便理解代码结构：

* [http://kafka.apache.org/coding-guide.html](http://kafka.apache.org/coding-guide.html)

## 4. 参考来源

* [https://cwiki.apache.org/confluence/display/KAFKA/Developer+Setup#DeveloperSetup-IntellijSetup](https://cwiki.apache.org/confluence/display/KAFKA/Developer+Setup#DeveloperSetup-IntellijSetup)
* [http://kafka.apache.org/coding-guide.html](http://kafka.apache.org/coding-guide.html)
* [Kafka 官网]
 


[Kafka 官网]:		http://kafka.apache.org/
[Kafka 官网-Quickstart]:		http://kafka.apache.org/quickstart
[Kafka 设计解析-郭俊]:		http://www.jasongj.com/categories/Kafka/
[Learning Apache Kafka(2nd Edition)]:		http://file.allitebooks.com/20150612/Learning%20Apache%20Kafka,%202nd%20Edition.pdf
[Kafka a Distributed Messaging System for Log Processing]:	http://docs.huihoo.com/apache/kafka/Kafka-A-Distributed-Messaging-System-for-Log-Processing.pdf
[NingG]:    http://ningg.github.com  "NingG"
[Top 10 Uses For A Message Queue]:		www.iron.io/blog/2012/12/top-10-uses-for-message-queue.html





