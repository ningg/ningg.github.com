---
layout: post
title: Docker 系列：数据管理
description: 容器之间，数据共享？数据持久化？
published: true
category: docker
---

> 当前分享，整理有单独的 keynote.

## 1. 概要

Docker 的数据管理，面临几个问题：

* 持久化：容器终止时，数据不持久化
* 紧耦合：
	* 容器的可写层，硬绑定在宿主机上
	* 容器和存储的生命周期，硬绑定，无法单独管理数据的生命周期
* 效率：容器的可写层，需要依赖「存储驱动器」Storage Driver，
	* 存储驱动：其对外提供 UFS 的语义，向下使用了 Linux 核心调用
	* 相对直接的磁盘写入，效率偏低

实现 2 个业务目标：

* **容器内**：数据持久化，数据迁移
* **容器间**：数据共享

容器中，实现「数据存储」解耦，有 3 种方式：

* `bind mount`：挂载宿主机目录，持久化存储
* `volume`：数据卷，持久化存储（建议使用）
* `tmpfs mount`：tmpfs 挂载内存（仅限 Linux 系统），非持久化存储
	* 生命周期，跟 container 绑定
	* 容器私有，无法共享
	* 占用宿主机的内容，而不是 container 内存？

![](/images/docker-series/docker-types-of-mounts.png)

3 中方式，详细描述一下：

* `Bind mount`：宿主机的 FS 上，任何一个位置，任何进程在任何时候，都可以进行读写，从 Docker 早期就开始使用
* `volume`：数据存储在宿主机的 FS 上，为 Docker 独占的空间，非 Docker 进程不应该修改，推荐使用
	* Linux 环境下，/var/lib/docker/volumes/ 目录
* `tmpfs mount`：只暂用宿主机的 Memory 内存空间，不会进行持久化存储

如何挂载 volume、bind mount、tmpfs mount：

* `Docker 17.06` 之前：`-v`\`--volume`\`--tmpfs` 参数设定
* `Docker 17.06` 之后：`--mount` 参数设定，更清晰
 

关于 --mount 的用法：

```
--mount <key>=<value>,<key>=<value>,<key>=<value>
```

其中，key 的具体取值说明：

![](/images/docker-series/docker-mount-cmd-details.png)

volume （volume、bind mount）相关参数的含义： 

![](/images/docker-series/docker-mount-inspect-details.png)

疑问：

* propagation：容器内
	* 细节参考： https://docs.docker.com/storage/bind-mounts/

参考资料：

* [https://docs.docker.com/storage/volumes/](https://docs.docker.com/storage/volumes/)
* [https://docs.docker.com/storage/bind-mounts](https://docs.docker.com/storage/bind-mounts)

## 2. Bind mount

几个方面：

* 基本知识
* 实践

### 2.1. 基本知识

关于 Bind mount：

* Docker 的`早期方案`
* **作用**：依赖 bind mount，可以将宿主机 FS 上的文件 or 目录，挂载到容器内
* **具体用法**：
	* 使用宿主机的「完整路径名」（绝对路径）或「相对路径名」
	* 宿主机的目录或文件，如果不存在，则，在挂载过程中，会自动创建
		* 仅限于使用 `-v` 和 `--volume` 方式，进行 bind mount，此时，`自动创建`的都是「目录」
		* `--mount` 方式，不会自动创建，而会`抛出异常`
* **使用建议**：
	* 优先使用 volume
	* 无法使用 docker client 的命令行，直接进行 bind mount 的管理
	* container 中进程，可以直接进行 FS 上重要文件的读写，`很灵活`，但`需要谨慎`

### 2.2. 实践

具体几个方面：

* 基本实例：简单的使用，涵盖 volume 创建、查询、删除

基本实例，对应操作：

```
# 1. bind mount：创建 container 时， 同步 bind mount
$ docker run -d \
   -it \
   --name devtest \
   --mount type=bind,source="$(pwd)"/target,target=/app \
   nginx:latest
 
docker: Error response from daemon: invalid mount config for type "bind": bind source path does not exist.
  
# 2. 分析 bind mount
$ docker inspect devtest
...
        "Mounts": [
            {
                "Type": "bind",
                "Source": "/Users/guoning/ningg/github/docker-learn/volume",
                "Destination": "/app",
                "Mode": "",
                "RW": true,
                "Propagation": "rprivate"
            }
        ],
...
  
# 3. 只读模式 bind mount
$ docker run -d \
  -it \
  --name devtest \
  --mount type=bind,source="$(pwd)"/target,target=/app,readonly \
  nginx:latest
```

特别说明：

* 如果将「宿主机的目录」绑定到「容器」的「非空路径」，则，从外部语义上，会屏蔽掉容器中已有内容

## 3. volume

**作用**：数据存储在宿主机的 FS 上，为 Docker 独占的空间，非 Docker 进程不应该修改，推荐使用

**注意事项**：

* 容器之间，数据共享
	* 首次挂载时，自动创建目录
	* 容器终止，数据仍存在
	* 多容器，同时挂载
* 宿主机，无法提前明确创建目录
	* volume 是逻辑视图
	* 在具体使用时，会自动创建
* 远端存储：数据存储到远端

2 个方面：

* 基本知识
* 实例

### 3.1. 基本知识

基本知识：

* **创建**：
	* `docker volume create`
	* 容器 or 服务创建过程中，同时创建 volume
	* 可以指定 volume drivers，可以映射到「远端存储」，例如，远端主机 or 云存储
* **分析**：
	* `docker volume ls`：查看所有 volume 的列表
	* `docker volume inspect`：查看 volume 的详情信息
* **使用**：
	* 可以同时挂载到「多个容器」
	* 未命名的 volume 第一次挂载到容器时，会给一个随机 name，保证唯一
* **删除**：
	* 没有容器在使用 volume 时，可以进行删除 
	* `docker volume prune`

几个疑问：

* 是否需要设定 volumes 的大小：当前不需要
* 是否存在「读写模式」的设置：存在

### 3.2. 实践

几个方面：

* **基本实例**：简单的使用，涵盖 volume 创建、查询、删除
* **数据共享**：
	* 同一宿主机，容器间，数据共享
	* 不同宿主机，容器间，数据共享
* **数据备份**

详细实例，参考： [https://docs.docker.com/storage/volumes/](https://docs.docker.com/storage/volumes/)

#### 3.2.1. 基本实例

具体使用 volume 的实例：

```
# 0. 基本用法：创建、查看、分析、删除
# a. 创建 volume
docker volume create my-vol
  
# b. 查看 volume 列表
docker volume ls
  
# c. 分析 volume 详情
docker volume inspect my-vol
...
[
    {
        "CreatedAt": "2018-09-20T06:36:08Z",
        "Driver": "local",
        "Labels": {},
        "Mountpoint": "/var/lib/docker/volumes/my-vol/_data",
        "Name": "my-vol",
        "Options": {},
        "Scope": "local"
    }
]
...
# d. 删除
docker volume rm my-vol
  
# 1. 自动创建 volume：绑定 volume，Docker 会自动创建对应 volume
$ docker run -d \
  --name devtest \
  --mount source=myvol2,target=/app \
  nginx:latest
  
# 查看 volume 列表
$ docker volume ls
DRIVER              VOLUME NAME
local               myvol2
  
# 查看 container 对应的挂载点
$ docker inspect [containerId]|[containerName]
...
        "Mounts": [
            {
                "Type": "volume",
                "Name": "myvol2",
                "Source": "/var/lib/docker/volumes/myvol2/_data",
                "Destination": "/app",
                "Driver": "local",
                "Mode": "z",
                "RW": true,
                "Propagation": ""
            }
        ],
...
  
# 2. 创建只读的 volume：
$ docker run -d \
  --name=nginxtestReadOnly \
  --mount source=nginx-vol,destination=/usr/share/nginx/html,readonly \
  nginx:latest
```

补充说明：

* 容器间 volume 共享：
	* 同一个 volume，可以共享给多个 container
	* 多个 container ，可以同时对同一个 volume，进行读写

#### 3.2.2. 数据共享

分为 2 个方面：

* 同一宿主机，容器间，数据共享
* 不同宿主机，容器间，数据共享

##### 3.2.2.1. 同一宿主机，容器间，数据共享

具体示例：

```
# 1. 创建 volume：创建一个 container，并创建 volume
$ docker run -d \
  --name devtest \
  --mount source=myvol2,target=/app \
  nginx:latest
  
# 登录容器，查看目标目录下，文件列表
$ docker exec -it devtest /bin/bash
$ cd /app
$ ls -alh
  
# 2. 容器间，共享 volume：创建另一个 container，共享上述 volume
$ docker run -d \
   --name=nginxtest \
   --mount source=myvol2,destination=/usr/share/nginx/html \
   nginx:latest
  
# 登录容器，查看目标目录下，文件列表
$ docker exec -it devtest /bin/bash
$ cd /app
$ ls -alh
```

##### 3.2.2.2. 不同宿主机，容器间，数据共享

不同宿主机，实现容器间数据共享，基本上，都是 2 个思路可选：

* **应用层处理**：应用上，将存储抽取为独立的业务逻辑，直接对远端存储，进行读写
* **驱动层处理**：创建 volume 时，使用支持远端存储的驱动，例如，可以直接对 NFS、Amazon S3 等进行读写的驱动；跟应用层解耦了，但依赖于「驱动」

![](/images/docker-series/volumes-shared-storage.svg)

下述示例，涵盖 2 个场景：

* 独立创建 volume：使用 vieux/sshfs 的 volume 驱动，单独创建一个 volume
* 伴随创建 volume：创建 container 过程中，创建 volume

具体示例：

```
# 场景 A：创建独立的 volume
# 1. 安装插件
$ docker plugin install --grant-all-permissions vieux/sshfs
  
# 2. 创建 volume
$ docker volume create --driver vieux/sshfs \
  -o sshcmd=test@node2:/home/test \
  -o password=testpassword \
  sshvolume
  
# 场景 B：创建 container 过程中，创建 volume
$ docker run -d \
  --name sshfs-container \
  --volume-driver vieux/sshfs \
  --mount src=sshvolume,target=/app,volume-opt=sshcmd=test@node2:/home/test,volume-opt=password=testpassword \
  nginx:latest 
```

#### 3.2.3. 数据备份

volume 中数据，如何进行备份、迁移。

TODO：

* 数据在「宿主机」和「容器」之间的流转过程

## 4. tmpfs mount

关于 tmpfs mount：

* 使用场景：
	* 非持久化存储
	* 在 Container 存活期间，使用
	* `Linux 版本`的宿主机
* 用于存储：非持久化的状态 or 敏感信息
* 实例：swarm 集群管理中，使用 tmpfs mount 来挂载 secrets（密钥）

使用实例：

```
# 1. 创建 tmpfs mount
$ docker run -d \
  -it \
  --name tmptest \
  --mount type=tmpfs,destination=/app \
  nginx:latest
  
# 2. 分析 mount
$ docker inspect tmptest
...
        "Mounts": [
            {
                "Type": "tmpfs",
                "Source": "",
                "Destination": "/app",
                "Mode": "",
                "RW": true,
                "Propagation": ""
            }
        ],
...
  
# 3. 设置参数：tmpfs 内存大小 和 mode，默认为物理内存大小，tmpfs-size（单位 Byte）， tmpfs-mode（rwx，1777）
$ docker run -d \
  -it \
  --name tmptest \
  --mount type=tmpfs,destination=/app,tmpfs-mode=1770 \
  nginx:latest
```

关于 tmpfs-mode 的默认 1777 模式，其中使用了 sticky bit：（约束 删除、移动等特殊的写权限，只有 owner 才有权限）

细节，参考：

* [linux特殊文件权限 suid sgid sticky-bit](http://coolnull.com/3278.html)
* [Linux文件权限：Sticky bit, SUID, SGID](https://lesca.me/archives/linux-file-permission-sticky-bit-suid-sgid.html)

## 5. 使用实践

关于 volume、bind mount、tmpfs mount 的使用实践：

![](/images/docker-series/data-manage-compare.png)


## 6. 附录

### 6.1. 附录 A：镜像、容器、驱动器

#### 6.1.1. 镜像

关于镜像：

* 一个镜像包含`多个层`堆叠而成，都为`只读`，称为`镜像层`
* 当创建容器时，会在顶端新建一个可写层，被称为`容器层`
* 所有文件`更改`，都发生在`容器层`

![](/images/docker-series/container-layers.jpg)

上图展示了 ubuntu 15.04 镜像的层级关系

* 存储驱动 (storage driver) 管理这些层之间的关系。
* 不同的 存储驱动 有各自不同的特性。

#### 6.1.2. 容器

关于容器：

* 多个 container 可以共享一个 image
* 每个 container 在 image 的基础上创建一个属于各自的 writable layer
* 所有文件变动都 只会 发生在 writable layer 上
* 任何文件变动都 不会 影响到 image
* container 在被删除的时候，相应的 writable layer 也被删除

![](/images/docker-series/sharing-layers.jpg)

> 注意： 如果你有多个镜像需要 `共享访问` 相同的数据 ，那么需要将这些数据放在 `docker volume`中，并 mount 到你的容器中。

关于容器的大小：

* 使用命令 `docker container ps -s` 查看运行中容器的大小
	* **virtual size**: 容器使用的 read-only 镜像大小 （也可以使用 docker image ls 查看）
	* **SIZE**: 当前容器的 writable layer 大小
* 容器使用的总容量为：所有容器的 size 与一个 virtual size 的和。
* 不包含以下几点：
	* **日志**：使用 json-file logging drive 的日志文件大小。
	* **volume**：容器使用的 volume
	* **配置**：容器的配置（通常很小）
	* Memory written to disk (if swapping is enabled)
	* checkpoint, if you're using the experimental checkpoint/restore feature.

#### 6.1.3. volume 和 驱动器

容器和 volume：

* 当容器被删除时，没有保存在 data volume 中的数据也将被删除。
* data volume 是直接被挂载到容器中的 directory 或 file
* data volume 不受 storage driver 控制
	* Reads and writes to data volumesbypass the storage driver and operate at native host
* `容器`和 `volume` 之间关系：
	* 一个容器可以挂载多个 data volume
	* 一个 data volume 可以被多个容器挂载

## 7. 讨论问题

讨论内容：

* 容器stop 时，「可写层」（容器层）的数据是否存在？
	* Re：container stop 后，「容器层」的数据，仍然存在，在 container start 时，仍然可以看见
* volume 模式下，如果多个docker对应相同的volume目录，则docker进程能否相互间看到彼此的文件？如果可以是否可以修改？
	* 可以彼此间看到文件。
	* 可以修改
* 容器stop的时候，如果在tmpfs mount 模式，数据是否还保留在内存？
	* Re：容器 stop 时，tmpfs mount 数据会直接删除
	* 细节参考： [https://docs.docker.com/storage/tmpfs/](https://docs.docker.com/storage/tmpfs/)
* tmpfs 模式下，通过什么样的技术方式实现共享？
	* Re：tmpfs mount，无法在容器之间，进行共享；tmpfs-mode 参数 rwx 默认 1777，是指容器内，不同进程对 tmpfs mount 的读写。
	* 细节参考： [https://docs.docker.com/storage/tmpfs/](https://docs.docker.com/storage/tmpfs/)

## 8. 参考资料

* [Manage data in Docker](https://docs.docker.com/storage/)
* [Linux kernel documentation for shared subtree.](https://www.kernel.org/doc/Documentation/filesystems/sharedsubtree.txt)
* [https://docs-cn.docker.octowhale.com/engine/admin/volumes/](https://docs-cn.docker.octowhale.com/engine/admin/volumes/)
* [linux特殊文件权限 suid sgid sticky-bit](http://coolnull.com/3278.html)
* [Linux文件权限：Sticky bit, SUID, SGID](https://lesca.me/archives/linux-file-permission-sticky-bit-suid-sgid.html)



[NingG]:    http://ningg.github.com  "NingG"













