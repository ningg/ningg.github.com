---
layout: post
title: Git 系列：多个 SSH key 的管理
description: 使用 SSH Key 方式登录 GitHub 仓库，如何同时使用多个 SSH Key
published: true
category: git
---


## 背景

多人共用同一台电脑开发，需要频繁切换 ssh key 文件，是否可以同时管理多个 ssh key？

希望达到的效果：

1. 不同的人，拥有自己的 ssh key（私钥和公钥）
2. 不同的人，拥有自己的代码版本，在不同的目录存放
3. 不同的人，可以使用自己的 ssh key，进行代码提交

整体效果上，就类似，每个人都拥有一个自己的账号，相互之间隔离。

> 实际上，我有多个 github 账号，希望在同一台电脑上，采用不同的账号进行代码提交：
> 
> 1. 不同账号，占用一个独立的代码副本
> 2. 不同账号，可以使用自己的 ssh key，进行代码提交

## 多 SSH Keys 管理

管理多个 SSH Keys，整体分为几步：

1. 生成 Key：生成多个 SSH Key，命名不同
2. 标识 Key：为每个 SSH Key 配置不同的标识
3. 配置远端代码仓库：Git 上，不同的代码仓库，映射到不同的 SSH Key
4. 本地拉取 Git 代码仓库：使用不同的 SSH Key 标识，拉取远端代码

### 生成 SSH Key

在个人电脑上，打开命令终端，执行下述命令，即可生成 SSH Key：

```
$ ssh-keygen -t rsa -C "youremail@email.com"
```

生成的 SSH Key，默认在 `~/.ssh/` 目录下，其中包含 2 个文件：`id_rsa` 和 `id_rsa.pub` ，`.pub` 后缀的文件是公钥文件。

采用上述方法，会生成 `id_rsa` 和 `id_rsa.pub` SSH Key。如果要生成多个 SSH Key，需要为 Key 主动指定名称，举例：下面代码，主动指定了 SSH Key 为 `./.ssh/second_rsa`：

```
# 生成 SSH Key，命名为：second_rsa
localhost:~ guoning$ ssh-keygen -t rsa -C "test@test.com"
Generating public/private rsa key pair.
Enter file in which to save the key (/Users/guoning/.ssh/id_rsa): ./.ssh/second_rsa
Enter passphrase (empty for no passphrase):
Enter same passphrase again:
Your identification has been saved in ./.ssh/second_rsa.
Your public key has been saved in ./.ssh/second_rsa.pub.
The key fingerprint is:
SHA256:Pn78RG6JwXAC+uKNG5k6ZHpRF6M69sbQS++zMbJxgN0 test@test.com
The key's randomart image is:
+---[RSA 2048]----+
|      .          |
|     .o.         |
|    .. oo .      |
|   ooo.  =       |
|  .++.E S o .    |
|  O.oB .   = .   |
| = BOo= o.. =    |
|. o.=Bo+ .oo     |
| ..oo.oo.. ..    |
+----[SHA256]-----+

# 查看生成的 SSH Key，其中包含了 2 个 SSH Key：id_rsa 和 second_rsa
localhost:~ guoning$ ll ./.ssh/
-rw-r--r--   1 guoning  staff   295B  6 10 11:22 config
-rw-------   1 guoning  staff   3.2K  5 20 00:06 id_rsa
-rw-r--r--   1 guoning  staff   745B  5 20 00:06 id_rsa.pub
-rw-------   1 guoning  staff   1.6K  6 11 00:08 second_rsa
-rw-r--r--   1 guoning  staff   395B  6 11 00:08 second_rsa.pub

```

### 标识 SSH Key

在本地为每个 SSH Key 设置不同的标识，具体，在 `~/.ssh/` 下创建 `config` 文件，并进行如下配置：

```
# Default github user(first@mail.com)  默认配置，一般可以省略
Host github.com
	Hostname github.com
	User git
	Identityfile ~/.ssh/id_rsa
	
# second user(second@mail.com)  给一个新的Host称呼
Host second.github.com  				// 主机名字，不能重名
	HostName github.com   				// 主机所在域名或IP
	User git  							// 用户名称
	IdentityFile ~/.ssh/second_rsa  	// 私钥路径
```
补充说明，上述配置，类似`别名`。

### 配置远端代码仓库

GitHub 上，可以按照 2 个粒度分配权限：

1. **所有**代码仓库：`账号设置`下的`SSH keys`，
2. **单个**代码仓库：`单个仓库`的 `Settings` 下的`Deploy keys`

按需求，把多个 SSH Key 分别上传到对应的`账号`或者`仓库`。

### 本地拉取 Git 代码仓库

现在开始使用新的公私钥进行工作吧

#### 情景1：使用新的公私钥进行克隆操作

```
git clone git@second.github.com:username/repo.git 
```

注意此时要把原来的 `github.com` 配置成你定义的 `second.github.com`

#### 情景2：已经克隆，之后才添加新的公私钥，我要为仓库设置使用新的公私钥进行push操作

修改`仓库`的配置文件：`.git/config` 为

```
[remote "origin"]
    url = git@second.github.com:itmyline/blog.git
```

即可。

之后就照平常一样工作就行啦！


## 参考资料

* [多个 SSH KEY 的管理]





[多个 SSH KEY 的管理]:		https://www.zybuluo.com/yangfch3/note/172120







[NingG]:    http://ningg.github.com  "NingG"










