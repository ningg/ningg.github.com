---
layout: post
title: Git 系列：典型操作
description: 版本控制的基本原理是什么？实用操作？团队协作？
published: true
category: git
---

## 1. 关于版本控制说几句

版本控制，最简单的含义：写一个版本的内容，提交，再写一个版本，再提交，突然想重新查看某个版本，通过版本号直接查看即可。整体来说：

1. 版本号：标识不同版本
1. 版本库：存放多个版本的信息，能够新增版本、查看旧版本
1. 工作空间：通常用于向版本库添加新版本、从版本库获取旧版本

版本库有两个作用：

1. 版本控制
1. 团队协作

## 2. Git版本控制原理

Git，就是进行版本控制的，因此，至少应包含2个结构：

1. 版本库（空间）：存放各个版本的信息；
1. 工作空间：当前能够查看、编辑文件的位置，通常一个目录，目录下的所有文件/文件夹，都会被纳入版本库进行版本控制；

实际上，Git包含了3个空间：

1. 版本库空间：HEAD指向最后一次提交的结果
1. 暂存区（Stage/Index）：为什么要有这个空间？
1. 工作区（Working Dir）：

由于Git是分布式的版本控制，因此，时间上是4个空间：

1. 远端版本库
1. 本地版本库
1. 暂存区
1. 工作区

为实现团队协作，Git进行分布式版本控制时，引入了“分支（Branch）”，即，不同的人从同一个分支上，创建各自独立的分支，在各个分支上进行版本控制，并在适当的时候，合并分支。官方的说法：一个分支进行一个特性的开发，不同的分支可以并行开发不同的特性，在分别调试之后，最后进行合并。

梳理一下逻辑，到目前为止，几个基本问题：

1. 怎么创建一个版本库？git init
1. 怎么标识一个本地版本库？
1. 怎么标识一个本地分支？
1. 怎么标识一个远端版本库？git remote add origin
1. 怎么标识一个远端分支？

## 3. 实用操作

关于Git在本地版本库空间、暂存空间、开发空间之间，相互提交文件、回滚文件的操作命令，参考：Git work cmd，是一张插图。

### 3.1. Git 团队协作原理

主要围绕分支来进行，不同的功能，在不同的分支上进行开发，实现开发功能的隔离，避免相互干扰。整体上，分支有本地分支、远程分支，针对每个分支又有：创建分支、切换分支、删除分支、查询分支；在本地分支与远程分支之间，又有：以远程分支内容更新本地分支，将本地分支内容更新到远程分支上。梳理一下：

本地分支：

1. 创建分支：
	1. git init，初始化新仓库
	1. git branch feature_x start-point，在start-point上创建新的分支，不切换到新分支上；
	1. git checkout -b feature_x start-point，创建feature_x分支，并且，自动切换到新分支
1. 切换分支：
	1. git checkout branchname
1. 删除分支：
	1. git branch -d branchname
	1. git branch -D branchname
1. 查询分支：
	1. git branch -a
	1. git branch --list
1. 合并分支：
	1. git merge anotherbranch，将「其他分支」中内容合并到「当前分支」

远端分支：

1. 创建分支：
1. 切换分支：
1. 删除分支：
	1. git branch -r -d branchname
	1. git branch -d -r origin/todo origin/html，会删除远端分支上内容吗？
1. 查询分支：
	1. git branch -a(显示所有分支)


本地分支与远端分支之间：

1. 获取远端分支内容：git pull origin branchname
1. 提交本地分支内容：git push origin branchname

### 3.2. Git 实践

#### 3.2.1. 基本配置

常用配置信息：

```
# 配置用户信息：
$ git config --global user.name "John Doe"
$ git config --global user.email johndoe@example.com
 
# 配置文本编辑器
$ git config --global core.editor vim
 
# 查看配置信息
$ git config --list
 
# 查看单个配置信息
$ git config user.name
```

如果用了 `--global` 选项，那么更改的配置文件就是位于你用户主目录下的那个，以后你所有的项目都会默认使用这里配置的用户信息。如果要在某个特定的项目中使用其他名字或者邮箱，只要去掉 `--global` 选项重新配置即可，新的设定保存在当前项目的 `.git/config` 文件里。

#### 3.2.2. 查看帮助文档

想了解 Git 的各式工具该怎么用，可以阅读它们的使用帮助，方法有三：

```
$ git help <verb>
$ git <verb> --help
$ man git-<verb>
```

#### 3.2.3. 疑问：汇总


几点：

* git clone、git fetch、git pull、git push、git merge之间的关系
* git merge、git push origin master、git pull origin master之间的关系
* git remote、git remote add

一个 branch 对应的upstream是什么？有什么作用？如何设置？如何删除？如何修改？

疑问：如何查看不同的提交版本？如何比对不同提交版本之间的差异？

## 4. Case：删除分支


删除 branch：

* 删除远端仓库中分支：git push origin --delete `[branchname]`
	* 简写形式：git push orgin :branchname
* 删除本地工作区中分支：git branch -d `[branchname]`

实际上有 3 个分支需要删除，具体参考：[http://stackoverflow.com/a/23961231](http://stackoverflow.com/a/23961231)
 
删除分支：

* 远端删除：通过管理界面删除
* 本地执行：git fetch origin --prune

## 5. Case：Git 切换到其他节点

### 5.1. 背景

远端Git服务宕机，切换其他Git节点替代

### 5.2. 具体操作

备用节点上，在仓库外，创建文件：`local-git-daemon.sh`，其内容如下（git daemon --help 查看命令说明）：

```
git daemon --reuseaddr --verbose --base-path=./Project --export-all ./Project/.git
```

执行上述命令，启动Git守护进程: `./local-git-daemon.sh`

执行命令：`netstat -an -p tcp`，查看 `9481`端口是否启动

其他节点，执行命令：`git clone git://172.28.170.217/` 即可获得**备用节点**上的内容
 
### 5.3. 常见错误

常见错误：

> repository not exported.

这跟配置有关，具体，帮助文档中，有说明：

> It verifies that the directory has the magic file "git-daemon-export-ok", and it will refuse to export any Git directory that hasn't explicitly been marked for export this way (unless the --export-all parameter is specified).

因此，解决方案两个：

* 添加 magic file
* 或者 git daemon 命令添加选项 "--export-all ./Work/performance/.git"

### 5.4. 参考来源

* [服务器上的 Git](https://git-scm.com/book/zh/v2/%E6%9C%8D%E5%8A%A1%E5%99%A8%E4%B8%8A%E7%9A%84-Git-Git-%E5%AE%88%E6%8A%A4%E8%BF%9B%E7%A8%8B)
* [Git serve](http://stackoverflow.com/a/377293)
* [Git Daemon](http://stackoverflow.com/a/2539138)

## 6. Case：添加远端分支，协作开发

### 6.1. 背景

小组协作开发新模块，一个队员folk出单个分支（下文记此分支地址为：folk-repo-url），所有队员都基于此分支进行开发。

### 6.2. 具体操作

本地开发分支中，利用 folk-repo-url 分支进行开发：

1. 添加远端分支: git remote event <folk-repo-url>
1. 查看现有的远端分支：git remote -v
1. 将远端分支拉取到本地：git fetch event
1. 本地切换至/event/feature/magiccard工作区：git checkout -b feature/magiccard event/feature/magiccard
1. 向远端提交自己的改动：
	1. git add
	1. git commit
	1. git push
 
【特别说明】：如果 git checkout 时，设置本地分支的名称与 feature/magiccard 不匹配，则，有些地方需要注意：

* 本地切换至/event/feature/magiccard工作区：git checkout -b eventMagicCard event/feature/magiccard
* 向远端提交自己的改动：git push event HEAD:feature/magiccard
* 补充说明：git push event eventMagicCard 方式，将会在event指定的远端仓库中，创建eventMagicCard分支
* 解决办法：对分支进行重命名：git brach -m feature/magiccard eventMagicCard
 
### 6.3. 参考来源

* [http://git-scm.com/book/en/v2/Git-Basics-Working-with-Remotes](http://git-scm.com/book/en/v2/Git-Basics-Working-with-Remotes)

## 7. Case：回滚版本，放弃之前 commit 内容

改动的内容，没有提交到本地 HEAD 中，放弃当前的修改：

```
git log
git reset [hashcode]
git clean -dxf
```

改动的内容，已经提交到本地 HEAD 中，具体操作：

```
git log ：查询 commit 的 hashcode
git reset --hard commit_hashcode
git push origin HEAD --force：强制提交
```

思考，上述方式，对其他人已有的分支，是否会产生影响？会产生影响，最好的方式 git revert
如果改动已经 commit 到远端仓库，则，使用 git revert 命令来回退版本：

```
git log
git revert [hashcode]
git revert -m 1 [hashcode]
上述改动，会增加一次 commit
```

补充说明：从远端拉取代码，然后 merge，如果希望 revert 回退，则：

```
# 查看 log
git log

# 回退：去掉 remote 的代码
git revert -m 1 [hashcode]

# 回退：去掉 local 的代码
git revert -m 2 [hashcode]
```

## 8. Case：合并多次commit

合并多次 commit，直接 rebase：

```
# hashcode，为要合并commit 之前的最近一次 commit，通常是一次 merge commit 的 hashcode
git rebase -i hashcode
# 如果出错, abort 即可
git rebase --abort
```

## 9. Case：如何编写 git commit msg

我当前 commit msg 的样式为：

> Fix: (支付回调)提交收银台后，限制订单修改，Closes SHOW-422, SHOW-423

更多细节参考：

* [http://chris.beams.io/posts/git-commit/](http://chris.beams.io/posts/git-commit/)

## 10. Case：修改 git commit msg

具体操作：

```
// 提交 commit
git commit -m "msg"

// 提交 commit 之后，仍可以修 msg
git commit --amend

// 查看 git msg
git log
```

## 11. checkout 出指定 tag or commit 的代码

具体操作：

```
// 查看 log
git log

// 从指定的 tag, checkout 出新分支
git checkout -b new_branch_name tag_name

// 从指定的 commit, checkout 出新分支
git checkout -b new_branch_name commit_id

```

## 12. 从 git 仓库迁移出代码，并导入到另一个 git 仓库

具体操作：

```
# 1. 拷贝一份「裸版本库」，不包含工作区，完全的代码、分支、提交记录，无法提交新的 commit
git clone --bare git://github.com/username/project.git

# 2. 创建新的 git 仓库/项目
...

# 3. 迁移：进入老的代码目录，然后，以镜像方式，上传代码到新的 git 仓库/项目
cd project
git push --mirror git@gitcafe.com/username/newproject.git

# 4. 删除本地代码
rm -rf project

# 5. clone 新的 git 仓库中的代码
git clone git@gitcafe.com/username/newproject.git

```

更多细节，参考：

* [从一个git仓库迁移到另外一个git仓库](https://blog.csdn.net/samxx8/article/details/72329002)


## 13. 参考来源

* [git - 简明指南]
* [图解Git]
* [Git work cmd]
* [Git 社区参考书]










[git - 简明指南]:			http://rogerdudler.github.io/git-guide/index.zh.html
[图解Git]:					http://marklodato.github.io/visual-git-guide/index-zh-cn.html
[Git work cmd]:				https://www.lucidchart.com/documents/view/a53dfe33-3535-469c-a363-b9d49e78eeb6
[Git 社区参考书]:				http://git-scm.com/book/zh/v1







[NingG]:    http://ningg.github.com  "NingG"










