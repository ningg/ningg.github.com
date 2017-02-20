---
layout: post
title: Linux 集群管理中，SSH 双向免密
description: SSH 双向免密码的配置，以及原理
published: true
category: linux
---

## SSH 免密码登录

### 基本操作

SSH 面密码登录基本过程：

![](/images/redis/redis-installation-ssh.png)

常用命令：

```
//生成公钥、私钥
ssh-keygen [-C comment] [-f output_keyfile]
```
  
  
### 基本原理

上面 SSH 免密码登录的原理是什么？

1. SSH Server 使用 `公钥` 加密一段随机字符串；
2. SSH Server 将加密结果发送给 SSH Client；
3. SSH Client 使用 `私钥` 解密；
4. SSH Client 将解密结果返回给 SSH Server；
5. SSH Server 比对解密结果，如果匹配，则，值得信任，可以免密码登陆。

本质：

* Server 侧，`公钥`加密
* Client 侧，`私钥`解密
* Server 侧，比对解密结果


[NingG]:    http://ningg.github.com  "NingG"



[河狸家：Redis 源码的深度剖析]:			http://mp.weixin.qq.com/s?__biz=MjM5ODc5ODgyMw==&mid=211169817&idx=1&sn=d5d0f6b10961bae54e58c7593105e8dd&3rd=MzA3MDU4NTYzMw==&scene=6#rd
[如何阅读 Redis 源码？]:		http://blog.huangz.me/diary/2014/how-to-read-redis-source-code.html





