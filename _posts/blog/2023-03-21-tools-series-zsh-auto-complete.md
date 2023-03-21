---
layout: post
title: Mac 配置 oh-my-zsh 和命令行自动补全
description: 新版的 mbp，建议启用 zsh，需要重新配置一遍代码自动补全
published: true
categories: mbp tool
---

### 0.更改你的默认 shell

```bash
chsh -s /bin/zsh
```


### 1.本地运行安装脚本

```bash
# 安装脚本
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

# 本地查看 zsh 配置
cat ~/.zshrc
```

备注：如果上述命令无法执行，则，可以 web 浏览器打开 `install.sh` 文件，复制粘贴到本地，来执行。


关联资料：

* (Install oh-my-zsh now)[https://ohmyz.sh/#install]


### 2.安装自动补全的插件

```bash
# 将自动补全的插件，放到 plugins 下
# $ZSH_CUSTOM  是 .zshrc 中定义的常量，也可以直接复制放到  .oh-my-zsh 目录内的 plugins 文件下.
git clone git@github.com:zsh-users/zsh-autosuggestions.git $ZSH_CUSTOM/plugins/zsh-autosuggestions

```

备注： 如果上述命令，无法正常执行，可以先 `git clone` 到本地`其他目录`，然后，`mv` 到`目标目录`。

### 3.更新 zsh 插件

```bash
# 编辑 .zshrc 文件
vim ~/.zshrc

# 找到 plugins=(git) 这一行，如果没有添加。更改为如下
plugins=(git zsh-autosuggestions)

# 重启 zsh
source ~/.zshrc

```



