---
layout: post
title: 工具系列：Java远程调试
description: 在远端（VM or Docker）上运行的 Java 工程，如何调试
category: tool 
---

## 概要

* **背景**：现在环境都在远端（VM or Docker），远端服务出现问题，如何 debug？
* **目标**：当前 blog ，聚焦解决，在远端（VM or Docker）上运行的 Java 工程，如何调试

## 远程调试

**目标**：使用「**本地 IDEA**」上的`源码`，来调试「**远端 Java 工程**」的`运行状态`。

整体上，几个步骤：

1. **开启权限**：「**远端 Java 工程**」开启调试权限
1. **配置连接**：「**本地 IDEA**」上，获取对应源代码，然后，IDEA 中配置连接到「**远端 Java 工程**」
1. **进行调试**：
	1. **本地启动**：在「**本地 IDEA**」上，以 Remote 模式，启动应用，并在需要的代码逻辑上，打断点
	1. **远端请求**：发送一个请求，命中「**远端 Java 工程**」，则，会被「**本地 IDEA**」的断点捕获

### 步骤 A：开启权限（远端 Java 工程）

Note：

> 开启权限后，需要重启「远端 Java 工程」。

#### 普通  Java 工程

如果是 普通  Java 工程，启动过程，增加下述参数：（指定远程调试端口为 5006）

```
// 通用的 Java 工程，开启
-agentlib:jdwp=transport=dt_socket,server=y,suspend=n,address=5006
 
// 示例： 对应完整的 java 命令，示例如下
java -agentlib:jdwp=transport=dt_socket,server=y,suspend=n,address=5005 -jar api.jar
```

#### Docker 中 Java 工程

如果是 Docker 方式，启动的 Java 应用，则，`docker-compose.yml` 增加下述环境变量：（指定远程调试端口为 5006）

```
// docker 方式启动时， 在 docker-compose.yml 中，对应 Service 的 增加环境变量。
  citycode:
    image: docker.mobike.io/mobike/citycode
    networks:
      - infra
    environment:
      - CI_ENVIRONMENT_SLUG=${CI_ENVIRONMENT_SLUG:-local}
      - CI_ENVIRONMENT_TIMEZONE=${CI_ENVIRONMENT_TIMEZONE:-Asia/Shanghai}
      - SPRING_APPLICATION_INSTANCE={{.Task.Slot}}
      - SPRING_PROFILES_ACTIVE=${SPRING_PROFILES_ACTIVE:-debug}
      - SPRING_CLOUD_CONFIG_LABEL=${SPRING_CLOUD_CONFIG_LABEL:-master}
      // 下面是新增的配置
      - JAVA_OPTS=-agentlib:jdwp=transport=dt_socket,server=y,suspend=n,address=5006
```

Docker 方式，重新启动上述 Java 应用：

```
docker-compose -f docker-compose.yml up -d [serviceName]
```

结果：上述方式，重启 Java 工程后，记录 Java 工程所在的机器/容器的 IP。

### 步骤 B：配置连接（本地 IDEA）

Note：

> 「本地 IDEA 」上，需要先 git clone 与「远端 Java 工程」相对应的源代码。


基于 「远端 Java 工程」 源码，在 IDEA 中，增加一个 Remote 类型的「执行项」，并以 Debug 模式启动。

**1.**IDEA右上角，Run/Debug按钮左侧，点击下拉箭头，选择"Edit Configurations..."

![](/images/tool-java-remote/edit-configurations.png)


**2.**在Run/Debug Configuraitons对话框左上角，点击加号，选择Remote；修改运行配置项名称、远程服务器地址（如服务运行在本机，填写 127.0.0.1）、调试器端口，点击Apply保存。

![](/images/tool-java-remote/add-remote.png)

Note: 上述 Remote 中，「Command line arguments for running remote JVM」参数，就是我们在「远端 Java 工程」开启调试权限时，设置的配置。

### 步骤 C：进行调试

上述方式，已经完成`配置开启`和`本地的配置连接`。

#### 本地启动

本地启动源码工程：

1.回到IDEA，右上角选中刚刚创建的Remote运行配置项，点击右侧的Debug按钮。Console中看到如下消息，则说明连上了。

![](/images/tool-java-remote/debug-run.png)

![](/images/tool-java-remote/debug-run-result.png)

接下来，就可以像本地开发一样打断点调试了。

![](/images/tool-java-remote/debug-run-debug.png)

#### 远端请求

发送一个请求，命中「**远端 Java 工程**」，则，会被「**本地 IDEA**」的断点捕获。




[NingG]:    http://ningg.github.com  "NingG"

