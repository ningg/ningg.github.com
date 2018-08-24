---
layout: post
title: Kubernetes 系列：使用 minikube 部署应用
description: minikube 部署 Kubernetes 集群应用的过程，熟悉 Kubernetes 集群的核心概念
published: true
category: docker
---

## 概要


场景描述：

* 本地编写应用
* 创建镜像
* 使用 Kubernetes 部署
* 在 Kubernetes 进行简单的管理

## 准备工作

准备工作，涵盖几个方面：

1. 创建 minikube 集群
1. 创建 NodeJS 应用
1. 构造应用的镜像

### 创建 minikube 集群

参照之前的 blog：

1. 安装 minikube
2. 启动 minikube


### 创建 NodeJS 应用

本地编写 `server.js` 文件：

```
var http = require('http');

var handleRequest = function(request, response) {
  console.log('Received request for URL: ' + request.url);
  response.writeHead(200);
  response.end('Hello World!');
};
var www = http.createServer(handleRequest);
www.listen(8080);
```

上面是一个 JS 文件，使用 Node 可以启动：

```
node server.js
```

然后在浏览器中，可以查看 http://localhost:8080 ，会显示 `Hello World!`.


### 构造镜像

在 `hellonode` 文件夹中创建一个 `Dockerfile` 命名的文件，用于描述镜像：

```
FROM node:6.9.2
EXPOSE 8080
COPY server.js .
CMD node server.js
```

此时使用 Minikube, 而不是将 Docker 镜像 push 到 Registry。因此，需要使用 Minikube VM 相同的 Docker 主机，来构建镜像，使得 minikube 能够找到镜像。具体，需要在本机设置 Docker 相关的环境变量：

```
# 将本机的 Docker 相关环境变量，指向 Minikube VM
eval $(minikube docker-env)
```

Note:

> 不再使用 minikube VM 时，采用 `eval $(minikube docker-env -u)` 命令，来取消环境变量的设置。

使用 Minikube 的 Docker 守护进程，build Docker 镜像：

```
docker build -t hello-node:v1 .
```

## Kubernetes 集群

Kubernetes 集群，几个方面：

1. Deployment：创建 Deployment
2. Service：创建 Service
3. 更新
4. 删除


### Deployment：创建 Deployment

Kubernetes Pod 是一个 or 一组容器的集合，用于共享资源，可以看做一个逻辑主机。

Kubernetes Deployment 管理 Pod 的创建和扩展，如果 Pod 终止，则，重新启动一个（组） Pod 对应的容器.

当前 Case 中，Pod 只是一个容器，具体，使用 `kubectl run` 命令创建 Deployemnt 来管理 Pod：

```
kubectl run hello-node --image=hello-node:v1 --port=8080
```

查看 Deployment：

```
kubectl get deployments

NAME         DESIRED   CURRENT   UP-TO-DATE   AVAILABLE   AGE
hello-node   1         1         1            1           5m
```

查看 Pods：

```
kubectl get pods

NAME                          READY     STATUS    RESTARTS   AGE
hello-node-658d8f6754-kwv4h   1/1       Running   0          6m
```

查看整个执行过程中的 Events：

```
kubectl get events

LAST SEEN   FIRST SEEN   COUNT     NAME                                           KIND         SUBOBJECT                     TYPE      REASON                  SOURCE                  MESSAGE
7m          7m           1         hello-node-658d8f6754-kwv4h.154ccfbb6eab8038   Pod                                        Normal    Scheduled               default-scheduler       Successfully assigned hello-node-658d8f6754-kwv4h to minikube
7m          7m           1         hello-node-658d8f6754-kwv4h.154ccfbb7e1cfde0   Pod                                        Normal    SuccessfulMountVolume   kubelet, minikube       MountVolume.SetUp succeeded for volume "default-token-f482p"
7m          7m           1         hello-node-658d8f6754-kwv4h.154ccfbb98e8629d   Pod          spec.containers{hello-node}   Normal    Pulled                  kubelet, minikube       Container image "hello-node:v1" already present on machine
7m          7m           1         hello-node-658d8f6754-kwv4h.154ccfbb9b2ea1c6   Pod          spec.containers{hello-node}   Normal    Created                 kubelet, minikube       Created container
7m          7m           1         hello-node-658d8f6754-kwv4h.154ccfbba16ef31b   Pod          spec.containers{hello-node}   Normal    Started                 kubelet, minikube       Started container
7m          7m           1         hello-node-658d8f6754.154ccfbb69b860c0         ReplicaSet                                 Normal    SuccessfulCreate        replicaset-controller   Created pod: hello-node-658d8f6754-kwv4h
7m          7m           1         hello-node.154ccfbb67bc8996                    Deployment                                 Normal    ScalingReplicaSet       deployment-controller   Scaled up replica set hello-node-658d8f6754 to 1
```

查看 kubectl 配置：

```
kubectl config view

apiVersion: v1
clusters:
- cluster:
    certificate-authority: /Users/guoning/.minikube/ca.crt
    server: https://192.168.99.100:8443
  name: minikube
contexts:
- context:
    cluster: minikube
    user: minikube
  name: minikube
current-context: minikube
kind: Config
preferences: {}
users:
- name: minikube
  user:
    client-certificate: /Users/guoning/.minikube/client.crt
    client-key: /Users/guoning/.minikube/client.key

```

### Service：创建 Service

默认情况下，Pod 的容器，只能通过 Kubernetes 集群内部的 IP 访问，无法对外直接提供服务。

```
$ kubectl get services

NAME         TYPE        CLUSTER-IP   EXTERNAL-IP   PORT(S)   AGE
kubernetes   ClusterIP   10.96.0.1    <none>        443/TCP   5d
```

上面 `EXTERNAL-IP` 显示为 `<none>`.

为了能够通过 Kubernetes 集群的虚拟网络的外部，进行访问 Pod 容器，则，需要创建 Service:

```
# 创建 Service
$ kubectl expose deployment hello-node --type=LoadBalancer

service "hello-node" exposed

# 查看 kubernetes 集群的 service
$ kubectl get services

NAME         TYPE           CLUSTER-IP      EXTERNAL-IP   PORT(S)          AGE
hello-node   LoadBalancer   10.108.170.38   <pending>     8080:31619/TCP   10s
kubernetes   ClusterIP      10.96.0.1       <none>        443/TCP          5d
```

补充说明：

* 通过 `--type=LoadBalancer` 允许配置外部 IP 地址来访问 Service.
* 在 minikube 环境下，LoadBalancer 使得，可以通过 minikube service 进行访问：
	* `minikube service hello-node` 会自动打开浏览器，访问服务.

```
# 查看所有的 pod
$ kubectl get pods
NAME                          READY     STATUS    RESTARTS   AGE
hello-node-658d8f6754-kwv4h   1/1       Running   0          33m

# 查看 pod 运行的日志
$ kubectl logs hello-node-658d8f6754-kwv4h
```


### 更新应用程序

编辑上文的 `server.js` 文件：


```
response.end('Hello World Again!');
```

build新版本镜像

```
docker build -t hello-node:v2 .
```

Deployment更新镜像：

```
kubectl set image deployment/hello-node hello-node=hello-node:v2
```

再次运行应用以查看新消息：

```
minikube service hello-node
```

### 清理应用

清理应用，分为 2 个方面：

1. 删除 Service
2. 删除 Deployment

具体操作：

```
kubectl delete service hello-node
kubectl delete deployment hello-node
```

或者，直接关闭 minikube：

```
minikube stop
```


## 附录

关于 minikube 的 自带Docker 环境变量说明：

```
$ minikube docker-env
export DOCKER_TLS_VERIFY="1"
export DOCKER_HOST="tcp://192.168.99.100:2376"
export DOCKER_CERT_PATH="/Users/guoning/.minikube/certs"
export DOCKER_API_VERSION="1.35"
# Run this command to configure your shell:
# eval $(minikube docker-env)

$ minikube docker-env -u
unset DOCKER_TLS_VERIFY
unset DOCKER_HOST
unset DOCKER_CERT_PATH
unset DOCKER_API_VERSION
# Run this command to configure your shell:
# eval $(minikube docker-env)
```















## 参考资料

* [Kubernetes 指南--非常专业易懂]
* [Kubernetes 项目]
* [Kubernetes Documentation]
* [Kubernetes中文社区]








[NingG]:    http://ningg.github.com  "NingG"
[Kubernetes 项目]:				https://yeasy.gitbooks.io/docker_practice/kubernetes/
[Kubernetes Documentation]:				https://kubernetes.io/docs/home/
[Kubernetes中文社区]:		http://docs.kubernetes.org.cn/
[Kubernetes 指南--非常专业易懂]:		https://github.com/ningg/kubernetes-handbook












