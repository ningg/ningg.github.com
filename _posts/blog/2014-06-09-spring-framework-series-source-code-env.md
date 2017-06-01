---
layout: post
title: Spring 源码：源码环境搭建
description: Spring 框架，源码环境搭建
published: true
category: spring
---

## 1. 写在开头

欲善其事，先利其器；阅读Spring源码，怎能不搭建环境？实际上，通过Maven管理的Spring项目，可利用Maven来获取Spring的源码包，但这种做法有一点限制：无法利用IDEA进行跨jar包的文件检索。

举个例子：

* Spring下编写集成测试代码时，使用ContextConfiguration注解，这一注解对应的handler在哪？

## 2. Spring 源码环境搭建

### 2.1. 下载源码

从 https://github.com/spring-projects/spring-framework 下载最新的Spring Framework源码，我下载的版本为：Spring 4.1.x ；实际上使用 Git 可以直接获取源码：

```
# 获取 Spring Framework 源码
git clone https://github.com/spring-projects/spring-framework.git
# 查看所有分支
git branch -a
# 切换到 4.1.x 分支
git checkout -b 4.1.x origin/4.1.x  
```


### 2.2. 安装 JDK 8

编译 Spring 4.1.x 需要 JDK 8 环境，安装 JDK 8

```
# 查找 java 8
brew cask search java
# 查看 java 详情
brew cask info java
# 安装 jdk 8
brew cask install java
```

### 2.3. 导入IntelliJ IDEA

Spring Framework工程中，自带了一个文档：import-into-idea.md，其中详细说明了，如何将Spring源码导入到IDEA下。在此之前，需要修改一下 build.gradle文件：

```
// 注释掉 sourcesJar、javadocJar
artifacts {
   // archives sourcesJar
   // archives javadocJar
}
...
// 注释掉 docsZip、schemaZip、distZip
artifacts {
   // archives docsZip
   // archives schemaZip
   // archives distZip
}
```

然后，执行下面命令：

```
./gradlew build -x test
```

如果运行出错：

```
Unrecognized VM option ‘MaxMetaspaceSize=1024m’
Error: Could not create the Java Virtual Machine.
Error: A fatal exception has occurred. Program will exit.
```

这是因为”MaxMetaspaceSize=1024m” 这个参数配置只出现在jdk 8中，需要确认已经安装jdk8
我的环境下，利用 jenv 来管理JDK 环境，则，通过如下配置，即可切换 JAVA_HOME 所指向的JDK： 

```
# 切换版本时，自动更新JAVA_HOME
jenv enable-plugin export

# 设置当前目录的 JDK（设置后，在新的terminal窗口中生效）
jenv local 1.8
```

此时，重新执行「./gradlew build -x test」命令，当输出「BUILD SUCCESSFUL」说明已经编译成功。建议再执行一条命令「./gradlew clean」清理一下编译时生成的文件，只留下源码。
 
## 3. 参考来源

* [Spring Projects - Spring Framework](https://github.com/spring-projects/spring-framework)




## 4. 附录

补充一下：执行

```
./gradlew idea
```

可以通过gradle生成idea项目，打开ipr文件即可






[NingG]:    http://ningg.github.com  "NingG"










