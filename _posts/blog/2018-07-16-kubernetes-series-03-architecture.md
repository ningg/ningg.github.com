---
layout: post
title: Kubernetes 系列：核心架构
description: 物理架构？逻辑架构？
published: true
category: docker
---

## 1.概要

Kubernetes 集群，几个基本疑问：

* Kubernetes 的 Docker 集群，是由什么构成的？
* 看得见、摸得着的东西，是什么？（物理架构、部署架构）
* 不同 Docker 节点之间，协作机制、处理逻辑是什么？


几个方面：

* 核心架构：物理架构，逻辑架构
* 核心概念：什么含义，什么用途

## 2.架构

两个方面：

1. 基本工作过程
2. 架构：逻辑架构、物理架构

### 2.1.基本工作过程

Kubernetes 的核心工作过程：

1. **资源对象**：`Node`、`Pod`、`Service`、`Replication Controller` 等都可以看作一种资源对象
2. **操作**：通过使用 `kubectl` 工具，执行**增删改查**
3. **存储**：对象的**目标状态**（**预设状态**），保存在 `etcd` 中持久化储存；
4. **自动控制**：跟踪、对比 etcd 中存储的**目标状态**与资源的**当前状态**，对差异`资源纠偏`，`自动控制`集群状态。

Kubernetes 实际是：高度`自动化`的`资源控制`系统，将其管理的`一切`抽象为`资源`对象，大到服务器 Node 节点，小到服务实例 Pod。

Kubernetes 的资源控制是一种`声明`+`引擎`的理念：

1. **声明**：对某种资源，声明他的`目标状态`
2. **自动**：Kubernetes 自动化资源控制系统，会一直努力将该`资源`对象维持在`目标状态`。



### 2.2.架构（物理+逻辑）

Kubernetes 集群，是主从架构：

* Master：管理节点，集群的控制和调度
* Node：工作节点，执行具体的业务容器

![](/images/kubernetes-series/k8s-cluster-arch.png)

下述几个组件，都是独立的进程，每个进程都是 Go 语言编写，实际部署 Kubernetes 集群，就是部署这些程序。

* Master节点：
	* kube-apiserver
	* kube-controller-manager
	* kube-scheduler
* Node节点：
	* kubelet
	* kube-proxy

具体，2 种角色的节点，需要运行的进程和职责不同，详细描述如下。

**Master 管理节点**：管理整个 Kubernetes 集群，接收外部命令，维护集群状态。

* **apiserver**： Kubernetes API Server
	* 集群控制的入口
	* **资源**的增删改查，持久化存储到 `etcd`
	* `kubectl` 直接与 API Server 交互，默认端口 `6443`。
* **etcd**: 一个高可用的 `key-value` 存储系统
	* 作用：存储**资源**的状态
	* 支持 Restful 的API。
	* 默认监听 2379 和 2380 端口（2379提供服务，2380用于集群节点通信）（疑问：集群节点，是说 etcd 的集群？ Master 集群？）
* **scheduler**： 负责将 pod 资源调度到合适的 node 上。
	* 调度算法：根据 node 节点的`性能`、`负载`、`数据位置`等，进行调度。
	* 默认监听 `10251` 端口。
* **controller-manager**: 所有资源的自动化控制中心
	* 每个**资源**，都对应有一个**控制器**（*疑问：作用是什么？*）
	* controller manager 管理这些控制器
	* controller manager 是自动化的循环控制器
	* Kubernetes 的核心控制守护进程，默认监听10252端口。（*疑问：为什么有监听段口感？*）

补充说明：

> `scheduler`和`controller-manager`都是通过`apiserver`从`etcd`中获取各种资源的状态，进行相应的**调度**和**控制**操作。


**Node 节点**：Master 节点，将任务调度到 Node 节点，以 docker 方式运行；当 Node 节点宕机时，Master 会自动将 Node 上的任务调度到其他 Node 上。

* **kubelet**: 本节点Pod的生命周期管理，定期向Master上报本节点及Pod的基本信息
	* Kubelet是在每个Node节点上运行agent
	* 负责维护和管理所有容器：从 apiserver 接收 Pod 的创建请求，启动和停止Pod
	* Kubelet不会管理不是由Kubernetes创建的容器
	* 定期向Master上报信息，如操作系统、Docker版本、CPU、内存、pod 运行状态等信息
* **kube-proxy**：集群中 Service 的通信以及负载均衡
	* **功能**：服务发现、反向代理。
	* **反向代理**：支持TCP和UDP连接转发，默认基于Round Robin算法将客户端流量转发到与service对应的一组后端pod。
	* **服务发现**：使用 etcd 的 watch 机制，监控集群中service和endpoint对象数据的动态变化，并且维护一个service到endpoint的映射关系。（本质是：路由关系）
	* **实现方式**：存在两种实现方式，`userspace` 和 `iptables`。
		* `userspace`：在用户空间，通过kuber-proxy实现负载均衡的代理服务，是最初的实现方案，较稳定、效率不高；
		* `iptables`：在内核空间，是纯采用iptables来实现LB，是Kubernetes目前默认的方式；
* **runtime**：一般使用 `docker` 容器，也支持其他的容器。

### 2.3.集群的高可用

Kubernetes 集群，在生产环境，必须实现高可用：

1. 实现Master节点及其核心组件的高可用；
2. 如果Master节点出现问题的话，那整个集群就失去了控制；

具体的 HA 示意图：

![](/images/kubernetes-series/kubernertes-HA-arch.png)

上述方式可以用作 HA，但仍未成熟，据了解，未来会更新升级 HA 的功能.

具体工作原理：

* **etcd 集群**：部署了3个Master节点，每个Master节点的etcd组成集群
* **入口集群**：3个Master节点上的APIServer的前面放一个负载均衡器，工作节点和客户端通过这个`负载均衡`和APIServer进行通信
* `pod-master`保证仅是`主master`可用，scheduler、controller-manager 在集群中多个实例只有一个工作，其他为备用

官网关联资料：

* [Set up High-Availability Kubernetes Masters](https://kubernetes.io/docs/tasks/administer-cluster/highly-available-master/)
* [Creating Highly Available Clusters with kubeadm](https://kubernetes.io/docs/setup/independent/high-availability/)






## 3.核心概念

涉及到的多个核心概念：

* Pod
* Deployment
* Replication Controller
* Replica Set
* StatefulSet
* Service
* Volume
* Namespace
* Label

部署服务相关的资源：

* **Pod**：Kubernetes的基本管理单元
	* 一个Pod，运行在一个 Node 节点上，内部包含`多个容器`
	* 通过Deployment可以部署Pod
* **Deployment**：表示部署，支持滚动升级
	* 在部署Pod的时候会创建一个`ReplicaSet`，来控制Pod实例的数量
* **Service**: Service就是微服务架构中微服务
	* 每个Service分配一个固定不变的`虚拟IP`即`ClusterIP`
	* 一个Service后边可以有一个或多个Pod。
	* Service将`客户端请求`转发到后边的某个Pod上，实现负载均衡
* **Label**: Label是联系各种k8s资源的纽带
	* 一个Service通过Label关联到后端的Pod上
	* Service定义一个Pod的label选择器，具备这个Label的Pod就会为此Service效力

其他资源：

* `Namespace`: 用于实现`多租户`的逻辑隔离
* `PV和PVC`: `持久卷`和`持久卷请求`，提供集群的持久存储抽象
* `DaemonSet`: 在集群中的`每个Node`上，启动一个守护进程Pod
* `Job`和`Schedued Job`
* `Ingress`: 将集群外部流量接入到集群内
* `ConfigMap`和`Secret`: 集中配置中心
* `Horizontal Pod Autoscaler`: 根据负载实现Pod自动`弹性伸缩`


几个资源之间的关系：（当前的理解，待修正）

![](/images/kubernetes-series/kubernertes-core-concepts.png)


### Pod

Pod 是 Kubernetes 集群运行的最小单元。

* 一个或多个`容器`的`集合`
* Pod：包含`一个` `Pause 容器`和`多个``业务容器`

**Pause 容器**：

* 镜像：pause-amd64
* 作用：非常重要
	* Pod容器的`根容器`
	* `业务容器``无关`
	* 其状态，代表整个 pod 的状态
* 网络：
	* **独立 IP 地址**：每个Pod被分配一个独立的IP地址
	* Pause 容器的`IP`：Pod里的多个业务容器共享
	* **共享网络命名空间**：Pod中的每个容器共享网络命名空间，包括`IP地址`和`网络端口`
	* **localhost 通信**：Pod内的容器可以使用localhost相互通信
	* **Pod 间通信**：k8s 支持`底层网络`集群内任意两个Pod之间进行通信
* 磁盘：
	* 共享 volumes：Pod中的所有容器都访问共享volumes，允许这些容器共享数据。
	* 持久化：volumes 还用于Pod中的数据持久化，以防其中一个容器需要重新启动而丢失数据。

下面是一个 Pod 的资源定义：

```
apiVersion: v1
kind: Pod
metadata:
  name: myweb
  labels:
    name: myweb
spec:
  containers:
  - name: myweb
    image: kubeguide/tomcat-app:v1
    ports:
    - containerPort: 8080
    env:
    - name: MYSQL_SERVER_HOST
      value: 'mysql'
    - name: MYSQL_SERVER_PORT
      value: '3306'
  - name: db
    image: mysql
    resources:
      requests:                  # 最小资源申请量
        memory: "64Mi"     # 64M内存
        cpu: "250m"           # 0.25个CPU
      limits:                       # 最大配额
        memory: "128Mi"   # 128M 内存
        cpu: "500m"           # 0.5个CPU
```  

Pod 的常用操作：

```
kubectl create -f  pod_file.yaml            # 创建pod
kubectl describe pods POD_NAME  # 查看pod详细信息
kubectl get pods                               # pods 列表
kubectl delete pod POD_NAME    # 删除pod
kubectl replace  pod_file.yaml      # 更新pod
```

疑问：

* Pod 内的容器，共享 IP，是否独占`端口`呢？

### Label

Label 几个方面：

* 作用：标记资源对象，实现对象分组，例如 Pod、Service、RC（Replication Controller）等
* 标记时间：
	* 定义资源时，进行标记
	* 对象创建后，动态添加 or 修改
* 映射关系：
	* 一个 Label 标记在多个资源对象上
	* 一个资源对象上，标记多个 Label

常见的 Label：

* 版本标签：
	* "release":"stable"
	* "release":"beta"
* 环境标签：
	* “environment”:"dev"
	* "environment":"qa"
	* "environment":"production"

Label Selector (标签选择器) ：筛选出具有指定 Label 的资源，方便进行管理。

* 匹配：等式和集合形式，进行匹配查询
* 组合：通过多个表达式的组合，从而实现复杂的条件选择

具体的 Label Selector：

```
name=mysql,env!=production
name notin (tomcat),env!=production
```

更多细节：

* [Labels and Selectors](https://kubernetes.io/docs/concepts/overview/working-with-objects/labels/)

### RC，Replication Controller

复制控制器（Replication Controller），也是一种`资源`，声明 Pod 副本的目标状态，具体作用：

* 保证有指定数量的 Pod 处于运行状态
* 高级特性：滚动升级、回滚等

一般配置参数：

* **副本数**：Pod 期待的副本数（replicas）（疑问：是否有默认值？）
* **标签**：用于筛选目标 Pod 的`Label Selector`
* **模板**：创建 Pod 的模板（template）
* **其他**：修改副本数，可以实现服务伸缩；修改模板中的镜像，可以实现滚动升级；

示例：

```
apiVersion: v1
kind: ReplicationController
metadata:
  name: nginx
spec:
  replicas: 3
  selector:
    app: nginx
  template:
    metadata:
      name: nginx
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx
        image: nginx
        ports:
        - containerPort: 80
```


RC运行过程： 

1. 定义一个RC的YAML文件（或者调用kubectl命令）提交到Kubernets集群后，
2. Master 上的 Controller Manager 组件就得到通知，定期巡检系统中当前存活的目标Pod
3. Controller Manager 确保运行状态的 Pod 数量，跟预期的 Pod 数量相匹配
4. 过多的 Pod 在运行，则，会主动终止，否则，会增加运行状态的 Pod

自动伸缩：

```
# 通过修改RC数量，实现Pod的动态缩放：
kubectl scale rc myweb --replicas=10        # 将pod 扩展到10个       
kubectl scale rc myweb --replicas=1          # 将pod 缩到 1个
```


滚动升级：

使用RC可以进行动态平滑升级,保证业务始终在线。其具体实现方式：

```
kubectl rolling-update my-rcName-v1 -f my-rcName-v2-rc.yaml --update-period=10s
```

升级开始后：

1. 首先依据提供的定义文件创建V2版本的RC，
2. 然后每隔10s（--update-period=10s）逐步的增加V2版本的Pod副本数，逐步减少V1版本Pod的副本数。
3. 升级完成之后，删除V1版本的RC。
4. 保留V2版本的RC，及实现滚动升级。

升级过程中，发生了错误中途退出时：

1. 可以选择继续升级，Kubernetes能够智能的判断升级中断之前的状态，然后紧接着继续执行升级。
2. 也可以进行回退，命令如下：

```
 kubectl rolling-update my-rcName-v1 -f my-rcName-v2-rc.yaml --update-period=10s --rollback
```

**ReplicaSet**：

1. replica set，可以被认为 是“升级版”的Replication Controller
2. replica set也是用于保证与label selector匹配的pod数量维持在期望状态。
3. 区别在于，`replica set`引入了对`基于子集`的selector查询条件，而`Replication Controller`仅支持`基于值相等`的selecto条件查询。
4. `replica set`很少被单独使用，目前它多被`Deployment`用于进行pod的创建、更新与删除的编排机制。

RC（Replica Set）特性和作用：

1. 通过定义一个RC，实现Pod的创建过程及副本数量的自动控制。
2. RC 里包括完整的Pod定义模板。
3. RC通过`Label Selector` 机制是对Pod副本的自动控制。
4. 通过改变`RC`的`副本数量`，可以实现Pod副本的`扩容`和`缩容`。
5. 通过改变`RC`里`Pod模板`中的`镜像版本`，可以实现Pod`滚动升级`。

### Deployment

Deployment 主要职责同样是为了保证`运行状态` `pod 的数量`：

1. 90%的功能与Replication Controller完全一样
2. 可看做新一代的Replication Controller
3. Deployment内部使用了Replica Set来实现；
4. 相对于 RC，Deployment 有个增强，可以查看：Pod `部署进度`和`运行状态`

具体实现细节：

1. 创建 Pod：创建 Deployment 对象，来生成 Replica Set，控制 Pod 副本的创建；
2. 查看状态：检查 Deployment 的状态，来查看是否完成部署，例如，副本数量是否为目标数量；
3. 滚动升级：更新 Deployment，以创建新的 Pod，同事清理不再需要的旧版本的 Replica Set；
4. 回滚：如果当前 Pod 不稳定 or 有 bug，则，可以回滚到一个早期的稳定版本；
5. 暂停和恢复：随时暂停 Deployment 对象，修改对应的参数配置，之后再恢复 Deployment 继续发布；


Deployment 定义

* `Deployment`的定义和`Replica Set`的定义几乎一样，仅仅是`API版本`和`kind类型`不同：

具体 Deployment 定义的实例：

```
# Deployment的声明
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-deployment
  labels:
    app: nginx
spec:
  replicas: 3
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx
        image: nginx
        ports:
        - containerPort: 80

# Replica Set的声明
apiVersion: v1
kind: ReplicaSet
metadata:
  name: mysql
...
```

创建 Deployment 并查看状态：

```
# 创建 Deployment
kubectl create -f nginx.yaml 

# 查看 Deployment
# 刚执行时，显示的AVAILABLE数量时0
kubectl get deployments

# 滚动升级
kubectl set image deployment/nginx-deployment nginx=nginx:1.12.2

# 查看 Replica Set（RS）
# 每次升级 Deployment，都会生成一个新的 RS
kubectl get rs
...
NAME                          DESIRED   CURRENT   READY     AGE
nginx-deployment-666865b5dd   0         0         0         22m
nginx-deployment-69647c4bc6   3         3         3         5m
...

```

所有 Deployment 的操作命令，可以参考：

* kubectl describe deployments #查询详细信息，获取升级进度
* kubectl get deployments # 获取升级进度的简略信息
* kubectl get rs # 获取RS记录，每执行一次deployment就会生成一个RS记录。
* kubectl set image deployment/nginx-deployment nginx=nginx:1.12.2 # 升级
* kubectl edit deployments/nginx-deployment # 修改deployment 参数
* kubectl rollout pause deployment/nginx-deployment #暂停升级
* kubectl rollout resume deployment/nginx-deployment #继续升级
* kubectl rollout undo deployment/nginx-deployment #回滚到上一版本
* kubectl scale deployment nginx-deployment --replicas 10 #弹性伸缩Pod数量

### Service

Service 定义了服务访问入口：

* 允许内部 Pod 之间，相互访问，仅限集群内部使用
* 集群外部使用时，需要借助 Flannel、Weave、Romana 等第三方网络服务

TODO：

* Service 的示意图

详细的说明：

* Cluster IP：全局唯一，用于 Pod 之间的相互访问
	* 创建 Service 时， Kubernetes 会自动创建一个 Cluster IP
	* 是虚拟 IP，无法 Ping 通
	* 通过 Cluster IP + 端口，访问后端 Pod
	* 后端 Pod，通过 RC 自动控制，提供持续服务
* Cluster IP：保持恒定
	* 在Service的整个生命周期内，Cluster IP不会发生改变
	* Service Name与Cluster IP形成固定的映射关系（这里一般使用的是DNS，早期使用的是环境变量的方式），这样就不存在服务发现的问题
* 内部地址：Service 和 Pod 的 Endpoint 属于集群内部地址
	* 无法在集群外部使用
	* 使用Flannel、Weave、Romana等第三方网络服务，实现Pod之间的通讯
* Proxy：
	* 每个Node节点上都运行着一个kube-proxy的进程
	* 提供负载均衡的作用，将对service的请求转发到后端的某个Pod实例上
	* 并在内部实现了`负载均衡`和`会话保持`（疑问：会话保持，什么含义？）

外部访问的 Service：

* Cluster IP是一个**内部地址**，外部的 node 节点无法直接访问到
* 当我们的`外部用户`需要访问这些服务时，需要在定义Service时添加 `NodePort` 的扩展。

下面的文件定义了一个nginx服务添加外部NodePort的示例：

```
apiVersion: v1
kind: Service
metadata: 
  name: nginx
spec:
  type: NodePort
  ports:
    - port: 80
      nodePort: 30008   # 对外的用户访问端口，默认范围是30000-32767
  selector:
    app: nginx
```

特别说明：

> 当我们创建这个 service 后，所有的节点上都会有`30008`的端口映射，访问`任意节点`都会转发到对应的Pod集群中。

本质：在所有节点 Node 的 kube-proxy 上，登记了 `Service` --> `ClusterIP`:`NodePort` --> `Pod IP`:`ContainerPort` 的映射关系。

疑问：

* 外部 Node，是如何调用 Service 的？Service 有什么标识？是根据 `name` 标记进行调用？具体的调用方式呢？

命令参考

* kubectl get services # 获取service列表，可以指定具体的service
* kubectl describe services # 显示service的详细信息，可以指定具体的service
* kubectl get endpoints # 获取Endpoint 信息
* kubectl delete services mysql # 删除指定的service

### Volume

关于磁盘存储：

1. Pod中，多个容器共享 Volume；
2. 使用单独的存储空间，挂载到对应的Pod上，保证数据持久化；
3. 当容器终止时，Volume中的数据不会丢失；

Volume的定义格式：

```
apiVersion: v1
kind: Pod
metadata:
  name: test-pd
spec:
  containers:
  - image: k8s.gcr.io/test-webserver
    name: test-container
    volumeMounts:
    - mountPath: /cache
      name: cache-volume
  volumes:
  - name: cache-volume
    emptyDir: {}                    # 指定Volume类型
```

Kubernetes支持多种类型的Volume,下面会对一些常见的Volume做出说明：

本地存储：
网络存储：
Persistent Volume：

#### 本地存储

本地存储：

* **emptyDir**: 无需指定宿主机的对应目录路径，由Pod自动创建，Pod移除时数据会永久删除，作为容器间的共享目录。上面的示例就是此格式的Volume。
* **hostPath**: Pod挂载宿主机上的文件和目录，可用于永久保存日志，容器内部访问宿主机数据，定义方式如下：

```
apiVersion: v1
kind: Pod
metadata:
name: test-pd
spec:
containers:
- image: k8s.gcr.io/test-webserver
name: test-container
volumeMounts:
- mountPath: /test-pd
  name: test-volume
volumes:
- name: test-volume
hostPath:
  # directory location on host
  path: /data
  # this field is optional
  type: Directory
```

#### 网络存储

网络存储

* **gce Persistemt Disk**: 谷歌公有云提供的永久磁盘，这里要求使用谷歌的公有云，节点是GCE虚拟机才行。
* **AWS Elastic Block Store**： 与GCE类似，此类型的Volume使用亚马逊公有云提供的EBS数据存储。
* **NFS**： NFS网络文件系统的数据存储，这个需要部署NFS服务器，定义如下：

```
volumes:
  - name: nfs
    nfs:
          server: NFS-SERVER-IP   # NFS 服务器地址
            path: "/"
```

* iscsi： 使用iSCSI存储设备上的目录挂载到Pod中。
* glusterfs： 使用GlusterFS挂载到Pod中。
* rbd： 使用Ceph对象存储挂载到Pod。

除此之外，Kubernetes还支持其他的存储方式，具体详情可以查看官方文档。

#### Persistent Volume

理解并管理五花八门的存储是一件让人头疼的事情，Kubernetes为了解决这些问题，对所有的网络存储进行了抽象，让我们在管理这些存储时不必考虑后端的实现细节，对于不同的网络存储统一使用一套相同的管理手段。

`PersistentVolume`为用户和管理员提供了一个API，它抽象了如何`定义存储`以及`使用存储`的细节。 为此，引入两个新的API资源：PersistentVolume和PersistentVolumeClaim。

* **PersistentVolume（PV）**: 是管理员设置的单独的网络存储集群，定义存储，它不属于任何节点，但是可以被每个节点访问。 PV是Volumes之类的卷插件，具有独立于的生命周期。 此API对象用于捕获存储实现的细节，如NFS，iSCSI，GlusterFS,CephFS或特定于云提供程序的存储系统。
* **PersistentVolumeClaim（PVC）**：是用户对存储的请求的定义，定义使用存储。 它与pod相似。pods消耗节点资源，PVC消耗PV资源， Pods可以请求特定级别的资源（CPU和内存）。Claim可以配置特定的存储资源大小和访问模式（例如，多种不同的读写权限）,并根据用户定义的需求去使用合适的Persistent Volume。

定义Persistent Volume：

```
apiVersion: v1
kind: PersistentVolume
metadata:
  name: pv1
spec:
  capacity:
    storage: 5Gi
  accessModes:
    - ReadWriteOnce
  nfs:
    path: /somepath
    server: 10.2.2.2
```

accessModes有三种权限：

* **ReadWriteOnce**：读写权限，只能被单个Node挂载
* **ReadOnlyMany**: 只读权限，允许被多个Node挂载
* **ReadWriteMany**: 读写权限、允许被多个Node挂载。

疑问：

* PV 和 PVC 之间的映射关系？
* 如何使用 PV？

定义Persistent Volume Claim

如果某个Pod想申请某种类型的PV，可以做如下定义：

```
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: myclaim
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      stroage: 8Gi
```

定义之后再Pod的Volume中引用上述PVC：

```
volumes:
  - name: mypd
    persistentVolumeClaim:
          claimName: myclaim
```  

PV是有状态的对象，有如下几种状态：

* **Available**: 空闲状态
* **Bound**: 已经绑定到某个PVC上
* **Released**: 对应的PVC已经删除，但是资源还没有被释放
* **Failed**: PV自动回收失败


### Namespace

Namespace 用于实现多租户隔离。

几个常用命令，查询 namespace：

```
# 查询所有的 namespace
kubectl get namespaces

# 查询 namespaces 的细节
kubectl describe namespaces

# 查询所有的 pod
kubectl get pods --all-namespaces

# 默认只会查询 default 中的 pod 信息
kubectl get pods

# 查询指定 namespace 的 pod
kubectl get pods --namespace=kube-system
```

Namespace的定义

使用yaml文件定义一个名为deployment的Namespace:

```
apiVersion: v1
kind: Namespace
metadata:
  name: deployment
```

当创建对象时，就可以指定这个资源对象属于哪个Namespace:

```
apiVersion: v1
kind: Pod
metadata:
  name: myweb
  namespace: development
```

疑问：

* 只会针对 Pod，设置 namespace 吗？


### Horizontal Pod Autoscaler(HPA)

HPA 也是一类资源对象：

* 根据 Pod的负载变化情况，自动调整 Pod 数量。

HPA有以下两种方式来度量Pod的负载情况：

* CPU 复杂：CPU Utilization Percentage，百分比
	* `Heapster`扩展组件，来获取 CPU 负载
	* CPU的利用率百分比，通常是度量的Pod CPU `1min`内的`平均值`
* 自定义的度量指标

简单示例：

```
apiVersion: autoscaling/v1
kind: HorizontalPodAutoscaler
metadata:
  name: myweb
  namespace: default
spec:
  maxReplicas: 10
  minReplicas: 2
  scaleTargetRef:
    kind: Deployment
    name: myweb
  targetCPUUtilizationPercentage: 90
```

当Pod 副本的CPU利用率超过90%时会触发自动扩容行为，且Pod数量最多不能超过10，最少不能低于2.

除此之外，也可以使用命令操作：

```
kubectl autoscale deployment myweb  --cpu-percent=90 --min=1 --max=10
```

疑问：

* 上述指定哪个 Pod 进行伸缩？
* 什么时候触发 Pod 数量的收缩？


### StatefulSet

在Kubernetes系统中，Pod管理的对象如 RC、Deployment、DaemonSet 和 Job 都是面向无状态的服务。对于无状态的服务我们可以任意销毁并在任意节点重建，但是在实际的应用中，很多服务是`有状态`的，特别是对于复杂的中间件集群，如 MySQL 集群、MongoDB集群、Zookeeper集群、etcd集群等，这些服务都有固定的网络标识，并有持久化的数据存储，这就需要使用 StatefulSet对 象。

StatefulSet具有以下特性：

* **稳定的网络标识**：StatefulSet里的每个Pod都有稳定且唯一的网络标识， 可以用来发现网络中的其他成员。
* **启动顺序受控**：StatefulSet 控制的Pod副本的启停顺序是受控的，比如操作第n个Pod时，前n-1个Pod必须是正常运行的状态。
* **持久化 Volume**：Pod 采用稳定的持久化存储卷，删除Pod时默认不会删除与StatefulSet相关的储存卷。





## 4.遗留问题

定义资源的模板：

* TODO：官网查询？详细含义？




## 5.参考资料


* [Kubernetes Documentation]
* [Kubernetes Concepts]
* [Kubernetes 指南]
* [Kubernetes 核心概念简介]
* [Kubernetes的组成和资源对象简介]
* [Labels and Selectors]
* [十分钟带你理解Kubernetes核心概念]
* [Introduction to Kubernetes]







[NingG]:    http://ningg.github.com  "NingG"


[Kubernetes Documentation]:				https://kubernetes.io/docs/home/
[Kubernetes 指南]:						https://legacy.gitbook.com/book/feisky/kubernetes/details
[Kubernetes 核心概念简介]:				http://blog.51cto.com/tryingstuff/2119034
[Kubernetes Concepts]:					https://kubernetes.io/docs/concepts/
[Kubernetes核心概念总结]:					https://www.cnblogs.com/zhenyuyaodidiao/p/6500720.html
[Kubernetes的组成和资源对象简介]:			https://blog.frognew.com/2017/04/kubernetes-overview.html
[Labels and Selectors]:					https://kubernetes.io/docs/concepts/overview/working-with-objects/labels/
[十分钟带你理解Kubernetes核心概念]:		http://dockone.io/article/932
[Introduction to Kubernetes]:			https://www.slideshare.net/rajdeep/introduction-to-kubernetes






