---
layout: post
title: Docker 系列：Docker 实践
description: Docker 实践过程中，需要注意哪些细节？有没有潜在的缺陷？经验 or 教训，又有哪些？
published: true
category: docker
---


主要内容，几个方面：

* 构建：
	* base image
	* Dockerfile
* 运行：
	* 资源限制
	* 网络
* 集群：
	* Swarm
	* Kubernetes

## 1. 构建

### 1.1. base image

公司的 base image：

* https://company.io/common/alpine-oraclejdk8

说明：

* 基于 frolvlad/alpine-oraclejdk8:slim，增加了 bash、听云和 iothub 等基础设施

### 1.2. Dockerfile

**问题**：

* 每个镜像构建，都需要一个 Dockerfile 文件，为什么我们的应用中，没有写 Dockerfile 文件

实践：采用 docker-maven-plugin 插件，将 Docker 的构建流程跟 Maven 的生命周期绑定

* mvn package → docker build
* mvn deploy → docker push

具体 pom 中配置：（https://company.io/common/parent）


```
                <plugin>
                    <groupId>com.spotify</groupId>
                    <artifactId>docker-maven-plugin</artifactId>
                    <version>1.0.0</version>
                    <configuration>
                        <imageName>${repo.docker}/${app.imagePath}</imageName>
                        <baseImage>${repo.docker}/infra/java:${java.version}</baseImage>
                        <workdir>/app</workdir>
                        <env>
                            <TZ>Asia/Shanghai</TZ>
                            <SPRING_APPLICATION_NAME>${project.artifactId}</SPRING_APPLICATION_NAME>
                        </env>
                        <entryPoint>["boot.sh", "${project.build.finalName}.${project.packaging}"]</entryPoint>
                        <resources>
                            <resource>
                                <targetPath>/app</targetPath>
                                <directory>${project.build.directory}</directory>
                                <include>${project.build.finalName}.${project.packaging}</include>
                            </resource>
                        </resources>
                        <runs>
                            <run>ln -snf /usr/share/zoneinfo/$TZ /etc/localtime</run>
                            <run>echo $TZ > /etc/timezone</run>
                        </runs>
                        <forceTags>true</forceTags>
                        <imageTags>
                            <imageTag>${project.version}</imageTag>
                        </imageTags>
                    </configuration>
                    <executions>
                        <execution>
                            <id>build-image</id>
                            <phase>package</phase>
                            <goals>
                                <goal>build</goal>
                            </goals>
                        </execution>
                        <execution>
                            <id>push-image</id>
                            <phase>deploy</phase>
                            <goals>
                                <goal>push</goal>
                            </goals>
                        </execution>
                    </executions>
                </plugin>
                <plugin>
                    <groupId>com.spotify</groupId>
                    <artifactId>dockerfile-maven-plugin</artifactId>
                    <version>1.4.0</version>
                    <configuration>
                        <repository>docker.company.io/${app.imagePath}</repository>
                        <tag>${project.version}</tag>
                        <buildArgs>
                            <JAR_FILE>${project.build.finalName}.jar</JAR_FILE>
                        </buildArgs>
                        <googleContainerRegistryEnabled>false</googleContainerRegistryEnabled>
                    </configuration>
                    <executions>
                        <execution>
                            <id>build-image</id>
                            <phase>package</phase>
                            <goals>
                                <goal>build</goal>
                            </goals>
                        </execution>
                        <execution>
                            <id>push-image</id>
                            <phase>deploy</phase>
                            <goals>
                                <goal>push</goal>
                            </goals>
                        </execution>
                    </executions>
                </plugin>
```

上述插件的配置，生成 `Dockerfile` 内容如下：

```
FROM docker.company.io/common/alpine-oraclejdk8:1.2
ENV APP_HOME /opt
ENV SPRING_APPLICATION_NAME api ENV TZ Asia/Shanghai
WORKDIR /opt
ADD /opt/api.jar /opt/
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime RUN echo $TZ > /etc/timezone
ENTRYPOINT ["/opt/boot.sh", "/opt/api.jar"]
```

使用 `docker-maven-plugin` 的优缺点：

* 优点：
	* 组件化，可继承复用
	* 可以使用 pom 中定义的变量
* 缺点：
	* 稳定性：非官方、个人开发，暂时不维护了
	* 依赖 Maven 构建环境：不同机器的 maven 版本、jdk 版本有差异

使用纯 Docker 的多阶段构建，可以作为一种替代方案：

```
FROM maven:3.5-jdk-8 AS build-env
ADD . /src
WORKDIR /src
RUN mvn clean package

FROM docker.company.io/common/alpine-oraclejdk8:1.2
ENV APP_HOME /opt
ENV SPRING_APPLICATION_NAME api ENV TZ Asia/Shanghai
WORKDIR /opt
COPY --from=build-env /src/target/ares-blade.jar /opt/ares-bla RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime
RUN echo $TZ > /etc/timezone
ENTRYPOINT ["/opt/boot.sh", "/opt/ares-blade.jar"]
```

纯 Docker 的多阶段构建，优点：

* 只依赖 Docker
* 不可变的构建环境：maven 版本、jdk 版本 都是指定的


## 2. 运行

### 2.1. 资源限制

几个主要问题：

1. 资源限制和什么有关？
1. 我们做了资源限制么？
1. 为什么我们做了一些资源限制 or 为什么没做一些资源限制？

#### 2.1.1. 资源限制，跟什么有关

在「单机容器」场景，Docker 、Docker Compose：

* CPU：一个容器，最多只能使用「限制数量的 CPU」
* 内存：容器内存申请，超过「限制的内存额度」时，容器会被 kill 掉（OOM Kill）

在「集群」场景，Swarm、Kubernetes：

* 容器，只会被分配到「足够资源的节点」
* 集群的容器分配算法：根据「节点的资源」和「容器申请的资源」，匹配到「合适的节点」
	* 常用策略：均匀分布、优先占用

#### 2.1.2. 资源限制，我们做了什么？

以 abacus/abacus-order 服务为例：https://git.company.io/abacus/abacus

* Swarm 模式，设置的资源限制
* Kubernetes 模式，设置的资源限制

内部实践的基本策略

**Swarm 模式**：(https://company.io/abacus/abacus/blob/master/docker-compose.prod.yml) `resources.reservations` 具体内容：

```
version: '3.3'
services:
  order:
    deploy:
      replicas: 12
      resources:
        reservations:
          cpus: '2'
```

**Kubernetes 模式**：（https://company.io/abacus/abacus/blob/master/abacus-prod.yaml） `resources.requests` 具体内容：

```
apiVersion: apps/v1
kind: Deployment
metadata:
  name: abacus-order
spec:
  replicas: 12
  selector:
    matchLabels:
      app: abacus-order
  template:
    metadata:
      labels:
        app: abacus-order
    spec:
      containers:
      - name: abacus-order
        image: docker.company.io/abacus/abacus-order:2.0.18
        imagePullPolicy: Always
        resources:
          requests:
            cpu: "2000m"
        readinessProbe:
          httpGet:
            path: /health
            port: 8080
          initialDelaySeconds: 35
          periodSeconds: 5
        livenessProbe:
          httpGet:
            path: /health
            port: 8080
          initialDelaySeconds: 60
          periodSeconds: 5
        ports:
        - name: http
          containerPort: 8080
        env:
        - name: SPRING_APPLICATION_INSTANCE
          valueFrom:
            fieldRef:
              fieldPath: metadata.name
        envFrom:
        - configMapRef:
            name: abacus-env-vars
        volumeMounts:
        - name: config
          mountPath: /opt/config
        - name: logs
          mountPath: /opt/logs
      volumes:
      - name: config
        hostPath:
          path: /opt/config
      - name: logs
        hostPath:
          path: /opt/logs
```

疑问：

* 上述 Kubernetes 的 Deployment 中 resources.requests.cpu 的 2000m 的含义？ m 是什么含义？
	* CPU 一般用核数来标识，一核CPU 相对于物理服务器的一个超线程核，也就是操作系统 /proc/cpuinfo 中列出来的核数。因为对资源进行了池化和虚拟化，因此 kubernetes 允许配置非整数个的核数，比如 0.5 是合法的，它标识应用可以使用半个 CPU 核的计算量。CPU 的请求有两种方式，一种是刚提到的 0.5，1 这种直接用数字标识 CPU 核心数；另外一种表示是 500m，它等价于 0.5，也就是说 1 Core = 1000m。
	* 更多细节，参考：[https://cizixs.com/2018/06/25/kubernetes-resource-management/](https://cizixs.com/2018/06/25/kubernetes-resource-management/)


#### 2.1.3. 为什么，没有限制内存

在 Docker 层面，限制「内存」：

* **优点**：集群模式下，集群调度时，会考虑物理节点的「内存占用」因素，进行更合理的资源分配
* **缺点**：容器申请的内存，超过「限制的内存大小」，则，容器会被直接 kill 掉（OOM kill）

JVM 层面，限制「内存」：

* 优点：
	* 不用担心在 GC 之前，就发生 OOM kill
* 缺点：
	* JVM 内存的限制，可能会遗漏一些特殊内存，例如直接内存等，导致内存泄露
	* 集群模式下，会忽略「内存」因素，导致无法充分、合理利用集群的内存资源


因此，建议 Docker 层面、JVM 层面，都设置「内存」限制

* Docker 层面：设置「需要内存的下限」，集群模式中，采用 reservations、requests 等
* JVM 层面：进行精确的内存限制，

### 2.2. 网络

具体实践：

![](/images/docker-series/docker-best-practise-network.png)

## 3. 集群

### 3.1. Swarm

#### 3.1.1. Swarm 逻辑架构

具体逻辑架构：

![](/images/docker-series/docker-summary-objects-releation.png)

#### 3.1.2. Swarm 物理架构

Swarm 集群模式，物理架构：

![](/images/docker-series/swarm-physical-arch.png)


其中，有一个很大的教训：

> 混布 Swarm Manager 的问题：
> 
> 1. 服务部署过程中， Swarm Manager 压力增大，会影响同一节点上的其他容器，容器一旦崩溃，会进一步增加 Swarm Manager 的压力
> 
> 2. 之前 Swarm Manager 同时支持 Swarm Worker 角色，导致 Swarm Manager 压力更大


### 3.2. Kubernetes

世纪之问：

> 为什么要从 Swarm 切换到 Kubernetes？从「容器化」走向「云原生」

术语简介：

* 容器化：只是运行在容器中，其他的都是老的方案和逻辑
* 云原生：容器部署、容器调度、甚至跟代码相关的完整生态

Kubernetes 新特性：

* Sidecar
* 服务注册和发现
* 配置中心
* 定时任务
* 调度亲和度
* Service Mesh























[NingG]:    http://ningg.github.com  "NingG"

[官网：Why Docker]:		https://www.docker.com/why-docker
[官网：Get Start]:		https://docs.docker.com/get-started/











