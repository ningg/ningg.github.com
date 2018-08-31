---
layout: post
title: 工具系列：个人的 Mac 配置
description: 一些 Mac 配置，尽量跟 Windows 对齐
published: true
category: tool
---


## 1. 写在开头的话

重装系统了，借这个机会，整理一下自己Mac的配置。

备注：拿到电脑，在安装配置之前，建议，先通过app store 更新升级一下 os 版本。

更新日志：

1. 2017-05-20，新买了一台 Macbook Pro 16，当前配置已经按照 mbp 16 进行调整。

## 2. 个人偏好设置

几个配置：

1. **触控板**：启用所有的触控板操作，「光标与点按」中选中「轻拍来点按」，将「查找与数据检测器」的手势调整为「用三个手字轻按」
1. **安全与隐私**：设置「进入睡眠或开启屏幕保护之后」「立即」要求输入密码
1. **桌面与屏幕保护**：在屏幕保护程序中，点击「触发角...」，设定右上角为「将显示器置入睡眠状态」
1. **键盘**：
	2. 对于 `mbp 15-` ：将F1、F2等作为标准功能键
	3. 对于 `mbp 16+` ：键盘-快捷键-功能键，添加对应的应用，touch bar 始终显示 F1、F2等功能键

## 3. 基础环境

### 3.1. Xcode

Xcode会包含很多开发工具，今后会用到，具体安装Xcode步骤：

````
$ xcode-select --install
# 运行下面的命令看你是否成功安装：
$ xcode-select -p
/Library/Developer/CommandLineTools
````

如果遇到 `Xcode` 版本过低的异常提示，则，需要升级 `Xcode`，具体办法：

* 在 `App Store` 中，搜索 `Xcode` 进行更新。

### 3.2. homebrew


[Homebrew](https://brew.sh) 是 Mac 下最好的包管理工具，相当于 RH 系的 yum 和 Debian 系的 apt-get。
在 Terminal 中输入下面的命令下安装：

````
ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
````

根据 [homebrew cask 官网的说明](https://github.com/caskroom/homebrew-cask)，现在默认安装了 homebrew 的扩展 cask，它是用来用命令管理 GUI 程序和一些因为 license 原因不能在 homebrew 中的程序。之后大部分软件都可以用 「brew」 或者 「brew cask」 来安装。

由于 homebrew 是从 Github 上读取软件的 formula，而 Github API 对于匿名的访问有频率限制，所以如果使用频繁的话，可以在你的 Github 中配置申请 API token，然后在环境变量中配置参数 `HOMEBREWGITHUBAPI_TOKEN`， `.bash_profile` 中添加：

````
export HOMEBREW_GITHUB_API_TOKEN=yourtoken
````

有的时候需要一些老的版本的软件，可以安装一个多版本软件 formula 的库，用 brew tap 来安装其它的仓库。仓库的列表可以参见 brew 的 Taps 和 cask 的 Taps

````
brew tap caskroom/versions
````

brew 升级软件

1. brew update 更新元信息
1. brew upgrade 更新软件
1. brew cleanup 才会去删除旧版本

cask 与上述类似：但不需要 brew update，因为 cask 是 brew 的子集

常见问题：

```
# 1. Mac 上 brew install 一直停顿在 Updating Homebrew...
Updating Homebrew...

# 解决办法：在环境变量中（.bash_profile 文件），关闭 brew 的自动更新，后续需要时，手动更新 brew update 即可
export HOMEBREW_NO_AUTO_UPDATE=true
```

更新 brew 的基本过程：（待验证，暂时没有采用）

```
# 1. 更新 brew
brew update-reset
```

### 3.3. 输入法

> 特别说明：针对 MBP 16，键盘布局变化了，当前，只有「百度输入法」可以使用，而且，建议，去百度官网下载，不建议通过 homebrew cask 安装输入法。

建议安装「百度输入法」或者「搜狗输入法」或者「QQ输入法」


````
brew cask search baidu
brew cask info baiduinput
brew cask install baiduinput
// qq 输入法
brew cask search input
brew cask install qqinput
````

「系统偏好设置」--「键盘」--「快捷键」--「输入法」：添加 QQ 输入法

### 3.4. Markdown编辑器

建议使用：MacDown， [http://macdown.uranusjr.com/](http://macdown.uranusjr.com/)

````
brew cask install macdown
````

更新：2015-10-15，现在写东西，直接写在 wiki 上了，不怎么使用 MacDown 了

### 3.5. 浏览器

Mac自带的浏览器Safari无法清理浏览器缓存，开发过程中建议使用Chrome浏览器。

备注：可以通过下文介绍的brew cask命令来安装Chrome浏览器，具体命令如下：

````
brew cask search chrome
brew cask info google-chrome
brew cask install google-chrome
````

## 4. 开发环境

Mac下进行工程开发，几个基本组件要装一下。

Note：这一部分，参考雪凯的blog（未开放），在此表示感谢。

### 4.1. JDK

通过 brew cask 安装旧版本的 java，需要提前安装 brew tap：

````
brew tap caskroom/versions
````

通过brew cask来安装java：

````
brew cask search java
brew cask info java
brew cask info java7
brew cask install java7
````

Note：下文将简要说明，jenv命令对JDK的多版本管理和切换。

#### 4.2. jenv

jenv 是一个 Java 环境管理工具，和 python 中的 pyenv 类似，可以方便的切换环境，管理多版本的 JDK。

jenv 可以配置多个作用域的环境（global、local、shell），为不同的目录配置不同版本的 JDK。使用起来很简单，可以参考[官方文档](http://www.jenv.be/)。

````
# 安装jenv
brew install jenv
````

让 jenv 管理 Java 环境需要在 `.bash_profile` 中添加：


````
# 只要能找到jenv命令即可，下面export配置不必须
export PATH="$HOME/.jenv/bin:$PATH"
eval "$(jenv init -)"
````

将 JDK 添加到 jenv 中，设置全局默认的 JDK:

```
# 添加 JDK 到 jenv
jenv add /Library/Java/JavaVirtualMachines/jdk1.7.0_79.jdk/Contents/Home
# 查看 JDK 列表
jenv versions
# 设置全局的 JDK（设置后，在新的terminal窗口中生效）
jenv global 1.7
# 将当前目录切换为 JDK 1.8
jenv local 1.8 
 
# 切换版本时，自动更新JAVA_HOME
jenv enable-plugin export
# 如果上述方式，切换 JAVA_HOME 失败，则，调整：.bash_profile
eval "$(jenv init - bash)"
```
 
详细参考：[https://github.com/gcuisinier/jenv/issues/44](https://github.com/gcuisinier/jenv/issues/44)

### 4.3. MySQL

通过brew安装：MySQL，具体命令：

````
brew search mysql
brew info mysql
brew install mysql
````

### 4.4. bash-completion

bash 自带的补全不够强大，比如 git 相关的命令就不能补全。bash-completion 是一个命令补全的增强工具。

通过下面命令来安装：

````
brew install bash-completion
````

在你的 `.bash_profile` 中导入补全文件：

```
# add bash-completion
if [ -f $(brew --prefix)/etc/bash_completion ]; then
    . $(brew --prefix)/etc/bash_completion
fi
```

补充：bash-completion 特别好用

bash 别名配置：

````
# add Alias
alias ll="ls -alhG"
alias ls="ls -ahG"
````

特别说明：

> 只有通过 homebrew 安装的命令/工具，才会自动补全。

### 4.5. iTerm2

iTerm2 是一个更强大的 Terminal，它提供了更好的查找、补全、复制、多 tab 等功能，优势很多，具体安装如下：

````
brew cask install iterm2
````

### 4.6. Git

安装和一些很有用的配置：

```
# 安装 git
brew install git

# 配置提交时的姓名和邮箱
git config --global user.name "foo"
git config --global user.email "bar"
# 配置你的编辑器
git config --global core.editor "vim"
# 防止中文文件名被转义
git config --global --bool core.quotepath false
# 一个很赞的 log 格式
git config --global alias.lol "log --oneline --graph --decorate"
```

可以使用「ssh-keygen」命令来生成公钥，实现与远端Git服务器链接时，免密码验证。详细参考：[http://man.linuxde.net/ssh-keygen](http://man.linuxde.net/ssh-keygen)

```
# 生成公钥
ssh-keygen -C "username@mail.com"
# 查看公钥
cd ~/.ssh
cat id_rsa.pub
# 将公钥上传到 git 服务器上，即可直接 git clone 仓库代码
```

### 4.7. Maven

安装：

```
brew info maven
brew install maven
```

Note: 一般要同步修改配置文件 `~/.m2/settings.xml`

### 4.8. VPN

TODO

### 4.9. MySQL workbench

安装 MySQL workbench：

````
brew cask search workbench
brew cask install mysqlworkbench
````

### 4.10. 解压工具 Unarchiver

安装 The Unarchiver：

````
brew cask install the-unarchiver
````

## 5. 开发工具


### 5.1. IDEA 

直接使用brew cask进行安装：

```
brew cask search idea
brew cask info intellij-idea
brew cask install intellij-idea
```

安装之后，IDEA的基本配置参考: IntelliJ IDEA 17 新手入门(TODO)

### 5.2. Navicat

下载、安装：

```
brew cask search navicat
brew cask info navicat-for-mysql
brew cask install navicat-for-mysql
```

上面安装的navicat是11.*版本的，免费使用 14 天，之后需要付费

### 5.3. Mark man

进行图片标注、前后端API的统一和沟通，可以使用Markman，具体安装步骤：

```
# 安装基础环境
brew cask search adobe-air
brew cask install adobe-air
```

之后，到官网下载安装Mark man即可，地址：[http://www.getmarkman.com/](http://www.getmarkman.com/)

### 5.4. PostMan

直接在google中搜索「postman」，安装 Post Man，同时开启「Postman Interceptor」

### 5.5. EditThisCookie

直接在 chrome 的网上应用商店中，添加「EditThisCookie」

### 5.6. MindNode

可以在本地使用一下：[http://www.sdifenzhou.com/mindnode222.html](http://www.sdifenzhou.com/mindnode222.html)，个人的百度云盘中也有备份

### 5.7 OmniGraffle

之前一直使用 lucidchart 绘图，有几个好处：

1. 非常简便，易学易用
2. 云端携带，随时随地，能够查看、编辑图片

但是，最近开始网络问题特别大，因此，尝试其他绘图软件：

* OmniGraffle Pro：在 Mac 下，用户比较多，准备试一下。
* [http://xclient.info/](http://xclient.info/) 可以下载学习一下，如果流畅，请在 App Store 购买.

## 6. 附录

### 6.1. 常用操作

几点：

1. 「CMD + space」获取「spotlight」，在其中，搜索所有你想要的东西：应用、文件、单词
1.  Mac下安装软件，跟Win不同，经常遇到的情况是，只需要拖拉图标，即可完成安装
1.  Finder下，直接「cmd + shift +G」能够在地址栏中输入路径

新人使用Mac的注意事项：[http://www.zhihu.com/question/33887923/answer/57480318](http://www.zhihu.com/question/33887923/answer/57480318)

### 6.2. bash下光标定位的快捷键

Mac下Bash环境中的快捷键，详细内容参考：[Bash Keyboard Shortcuts](http://ss64.com/osx/syntax-bashkeyboard.html)

|快捷键|说明|
|---|---|
|`alt` + `a`/`e`|	光标定位：开头/结尾|
|`alt` + `u`/`k`|	删除光标之前/之后内容|
|`option` + `Left`/`Right`|	光标向前/后移动一个单词|
 
### 6.3. Mac下截屏操作

截屏快捷键：

1. cmd + shift + 3：全屏截图，存放到桌面上
1. cmd + shift + ctrl + 3：全屏截图，存放到剪切板
1. cmd + shift + 4：局部截图，存放到桌面上
1. cmd + shift + ctrl + 4：局部截图，存放到剪切板

特例：

* cmd + shift + 4 + space：对单独窗口进行截图
 
QQ截图：

* cmd + ctrl + A：页面截图

### 6.4. Finder的使用
 
1. 复制文件：cmd + C，cmd + V
1. 剪切文件：cmd + C，cmd + opt + V
1. 定位到地址栏：`cmd` + `shift` + `G`

### 6.5. 使用 app store 替代部分 homebrew

这几个月，电脑一直有问题，换了台新的，这次安装软件，将以 app store 为主，能在 app store 中安装的，一概使用 app store。

app store 安装软件列表：

1. qq
1. wechat
1. xcode 

### 6.6. Mac 性能分析

Mac下查询网络占用情况：`netstat -an -p tcp` 欧，与Linux还是有差异滴（Linux: `netstat -tpnl`）

疑问：

* 如何查看Mac下当前网络状态？不同进程的网络占用情况？netstat命令
* 查看当前进程消耗CPU、Mem情况？top命令


### 6.7 Vim 光标定位操作

Vim下光标定位：

1. `^`, `$`
1. `w`, `b`
1. `f` -> 'char'：快速定位char

删除字符：

1. x, X
1. d - a - w：删除一个单词
1. dd：删除整行
1. dG：删除到行尾
1. d0：行首，d$：行尾





















[NingG]:    http://ningg.github.com  "NingG"


