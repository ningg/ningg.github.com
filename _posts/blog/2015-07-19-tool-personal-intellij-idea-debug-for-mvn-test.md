---
layout: post
title: 工具系列：IntelliJ IDEA下，maven test 以 debug 模式启动
description: debug 模式执行单元测试
category: tool 
---


## 1. 背景

工程运行单测的时候，出现类似死循环的现象，如何定位问题？最简单直接的思路是 debug，通过打断点观察异常的细节。

### 1.1. debug 模式启动工程

通常以 debug 模式启动的工程，例如debug 模式运行任务：

```
mvn jetty:run -DskipTests=true
```

此时，IDEA 下，可以在任意加载类的任意位置打断点，线程执行到断点处会自动挂起。

### 1.2. debug 模式运行单测

以 debug 模式运行单测时，例如：

```
mvn test
```

此时，IDEA 下，任意位置打的断点都无效，会被线程忽略。

现在的问题转换为：

> IDEA 下，如何以 debug 模式执行 maven test 任务，并且能够捕获断点？

## 2. IDEA 下，debug 模式执行 maven test 任务

一个最简单的思路：

* maven test 任务是所有单测的集合，因此逐个启动所有的单测就 OK 了，而每个单测又能够捕获断点，由此可以满足要求。

### 2.1. IDEA 下，创建 JUnit 任务，批量运行单测

根据上述分析，可以在 IDEA 下，创建 JUnit 任务，批量运行单测。具体步骤如下：

![](/images/tool-idea/junit-task-for-maven.png)

然后，以 debug 模式，启动上述创建的 JUnit 任务：maven-test

执行效果如下：

![](/images/tool-idea/junit-task-for-maven-debug-menu.png)

### 2.2. IDEA 下，使用远程调试，模拟 debug 方式执行 maven test 任务


> 【思考】：为什么远程调试，就能模拟 debug 方式执行 maven test 任务？
> 
> Re：todo


具体操作步骤如下：

IDEA 下，以 debug 方式执行 maven test 任务，具体参数配置如下：

```
mvn test -Dmaven.surefire.debug
```

出现页面：

![](/images/tool-idea/maven-debug-config.png)

IDEA 下，创建远程调试任务：

![](/images/tool-idea/maven-debug-config-remote.png)

然后，以 debug 方式，启动远程调试任务：test-debug

![](/images/tool-idea/maven-debug-config-remote-menu.png)

此时，即可捕获断点，详细查看 maven test 任务的执行情况。

## 3. 参考来源


* [how-to-debug-tests-maven-test-via-intellij-idea/](http://www.grygoriy.com/blog/2011/01/20/how-to-debug-tests-maven-test-via-intellij-idea/)











[NingG]:    http://ningg.github.com  "NingG"
