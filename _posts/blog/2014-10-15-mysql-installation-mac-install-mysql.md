---
layout: post
title: MySQL安装：Mac 下安装 MySQL
description: Mac 下，安装 MySQL 的基本步骤
category: mysql
---



## 安装

通过 homebrew 安装MySQL：

```
brew search mysql
brew info mysql
brew install mysql
brew list
```

安装完成之后，通过 `brew info mysql`，查看得到如下信息：

![](/images/mysql-installation/display-mysql-info-on-mac.png)

按照上述说明，直接执行 `mysql.server start` 命令，启动 MySQL 服务器。

### 修改密码

```
UPDATE mysql.user SET Password=PASSWORD('root') WHERE User = 'root';
FLUSH PRIVILEGES;
```

### 创建数据库

```
CREATE SCHEMA `show_sell` DEFAULT CHARACTER SET utf8mb4;
```

## 使用

如何使用 MySQL，这里不再多说。





[NingG]:    http://ningg.github.com  "NingG"

[adding users]:		http://dev.mysql.com/doc/mysql-security-excerpt/5.6/en/adding-users.html
[removing users]:			http://dev.mysql.com/doc/mysql-security-excerpt/5.6/en/removing-users.html
