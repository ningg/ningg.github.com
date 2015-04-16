---
layout: post
title: maven坐标和依赖
describe: Maven有一个中央仓库，其中包含丰富的资源，如何找出特定资源呢？
category: maven
---

> 题记：[《Maven实战（迷你版）》](http://www.infoq.com/cn/minibooks/maven-in-action)这本书写的太好了，我忍不住把其中的内容又敲一遍。

###何为Maven坐标

Maven来管理项目依赖。为了能自动化解析任何一个java构建，Maven必须将他们唯一标识，这是依赖管理的基础——坐标（coordinate）。本文将详细介绍Maven坐标的作用，并在此基础上介绍Maven的配置。

Maven坐标的元素包括：`groupId`，`artifactId`，`version`，`packaging`，`classifier`。根据坐标，Maven能够从中央仓库（http://repo1.maven.org/maven2）中，找出java构件并进行下载。

###坐标详解

先看一个坐标定义：

	<groupId>org.sonatype.nexus</groupId>
	<artifactId>nexus-indexer</artifactId>
	<version>2.0.0</version>
	<packaging>jar</packaging>

上述代码中，并没有classifier。下面详细解释一下各个坐标元素：

**groupId**；定义当前Maven项目所属的实际项目。首先，Maven项目与实际项目不是一一对应的关系，因为Maven中有一个模块的概念，因此实际的项目会被分为很多模块，比如，SpringFramework实际项目对应的maven项目有spring-core，spring-context等。其次，groupId不应对应到项目所属的组织或公司，原因很简单，一个组织下有很多实际项目，每个项目又要包含很多模块（Maven项目），应将groupId指定到实际项目，然后，通过artifactId来定义项目模块，并以此作为一个Maven项目。最后，groupId与java包名的表示方式类似，通常与域名反向一一对应。上述例子中，groupId为org.sonatype.nexus，其中，org.sonatype表示Sonatype公司建立的一个非营利组织，nexus表示Nexus这一实际项目，该groupId与实际域名nexus.sonatype.org对应。

**artifactId**：对应实际项目中的一个模块（Maven项目），推荐使用实际项目名最为前缀，例如，nexus-indexer，使用实际nexus作为前缀，这样的好处是方便寻找实际构建。默认情况下，Maven生成的构建，以 `artifactId-version.packaging` 格式命名，以实际项目名命名，方便区分不同项目。

**version**：标识当前Maven项目的版本。特别说明：Maven定义了一套完整的版本规范，以及快照（SNAPSHOT）的概念，后文会涉及到。

**packaging**：声明项目打包方式。首先，其常作为生成构件的扩展名，例如，jar，war；其次，打包方式会影响到构建过程的声明周期，比如，jar打包、war打包使用不同的命令；最后，不定义packaging时，默认jar。

**classifier**：



