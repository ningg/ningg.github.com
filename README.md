# 动手搭建自己的博客

我写了一篇博客[GitHub上搭建个人网站](http://ningg.github.io/build-blog-with-github/)， 需要的可以读一下。

# ChangeLog

* 2019年3月，进行网站域名备案。
* 2019年2月，post 页面，增加 `同类文章` 模块。
* 2014年5月，基于[BeiYuu](http://beiyuu.com/) & [Havee](http://havee.me/) 的博客模版，改进出此博客
* 2013年8月，基于[BeiYuu](http://beiyuu.com/) 博客模版，在GitHub上建立个人网站
* 2012年9月，在内网使用Wordpress搭建个人博客

# Mac 下, 搭建开发调试环境

搭建开发环境, 参考 [Blogging with Jekyll](http://jekyllrb.com/docs/quickstart/).

详细细节:

```
# 1.安装最新版 ruby
$ brew install ruby

# 2.安装 bundle 和 jekyll
$ gem install --user-install bundler

$ gem install --user-install jekyll

# 3. 退出 iterm 终端, 重新打开, 并安装 bundle
$ bundle install

Could not locate Gemfile

$ vim Gemfile
source 'https://rubygems.org'
gem 'github-pages', group: :jekyll_plugins

$ bundle install


# 4. 前往 jekyll blog 的目录下
$ cd /Users/guoning/ningg/github/ningg.github.com

# 5. 启动 jekyll 服务
$ bundle exec jekyll serve

# 下述方式, 只处理增量变更
$ bundle exec jekyll serve --incremental

# 6. 浏览器访问效果
http://127.0.0.1:4000
```

# Mac 的 M2 芯片，搭建开发环境

基本思路：

* 1.确定 terminal 处于 arm64 模式，而不是 Rosetta mode.
* 2.切换为 zsh 
* 3.按照官网，从头安装 ruby 和 jekyll，官网[参考](https://jekyllrb.com/docs/installation/macos/)
* 4.提前删除项目下的 `Gemfile.lock`


将 terminal 调整为 arm64 模式：[](https://www.moncefbelyamani.com/how-to-install-xcode-homebrew-git-rvm-ruby-on-mac/#installation)

```
// 1.查询当前模式
$ uname -m
x86_64

// 2.如果上面返回 x86_64 而不是 arm64，则，需要直接卸载 iterm/iterm2，然后重装
// 卸载可以在 finder 中搜索到应用，然后，移到废纸篓
// 重装可以使用 brew
brew install iterm2
```