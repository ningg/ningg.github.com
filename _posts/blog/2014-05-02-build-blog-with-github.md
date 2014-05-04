---
layout: post
title: GitHub上搭建个人网站
description: GitHub是代码管理、分享平台，利用其GitHub Pages功能可搭建个人网站
category: GitHub
---

##0.背景

准备重新捡起博客，记录自己的生活，特别是技术生活*（过于私密的东西，也不敢往博客上放不是）。*个人博客有两个途径：a.使用已有的博客网站; b.搭建自己的私人网站。调研了一下国内博客网站，（[CSDN]、[javaEye]、[OSCHINA]等）普遍文字格式、代码编排样式不是很喜欢*（太挑剔了？对，我就是一个挑剔的人），*这让自己转向私人博客。可以预想到，自己搭建要稍微复杂一点，话又说回来了，作为`software engineer`折腾网站也算看家本领了*（我会告诉你我的目标是`scientist`么）。*

既然要搭自己的私人博客，那选定什么框架/方案呢？之前使用[WordPress]搭过，但需要购买域名和空间；现在流行在[GitHub]上搭，并且不需要考虑域名和空间的问题，那就他了，上[GitHub]，走起*（其实，国内也有一个类似的地方[GitCafe]，不过，出于装B需要，最终选定了[GitHub]）。*

##1.做什么？

目标：私人博客、自己搭建。

方式：[GitHub Pages]

##2.怎么做？

初步分析，在[GitHub]上搭建博客，实质是：将自己的博客内容上传到GitHub上*（因为GitHub提供了空间）；*如果需要修改博客内容，则需要从GitHub上将download/pull下来；接下来就是让外面可以访问GitHub上的博客。总结一下，对应3个必要步骤：

1. GitHub上创建工程、并且能够将GitHub上的文件/代码，下载到本地；
2. 将本地的文件/代码，上传到GitHub上；
3. 配置GitHub，使其对外提供私人博客的访问页面；

好了，上面是凭空想出来的*（任何地方搭建博客，都是上面的逻辑步骤，而不仅限于GitHub）；*那实际如何操作呢？具体分为4个阶段：

1. 熟悉[GitHub]的基本操作（创建工程、上传代码、下载代码）；
2. 利用[GitHub Pages]功能，搭建简易网站；
3. 利用[jekyll]，增强网站功能（除了jekyll，还有其他的方式）；
4. 在[jekyll]框架下，依照个人偏好，进行定制；

##3.实际操作

###3.1GitHub的基本操作

* [安装使用Git（GitHub上传、下载文件的工具）](https://help.github.com/articles/set-up-git)
* [GitHub上创建项目（其中包含了，GitHub上传文件的Git命令）](https://help.github.com/articles/create-a-repo)
* [GitHub上Fork项目（其中包含了，GitHub下载文件的Git命令）](https://help.github.com/articles/fork-a-repo)

补充：[上传文件至GitHub](https://help.github.com/articles/adding-an-existing-project-to-github-using-the-command-line)；另外，向GitHub提交代码时，按照上面的操作方式，需要每次都输入GitHub的用户名和密码，可以采用`SSH Keys`的方式来解决此问题。

###3.2如何搭建博客？

GitHub上对于个人博客的支持，实质是利用GitHub Pages功能来实现的，具体操作：[GitHub Pages](https://pages.github.com/),认真读一遍，5mins，一步一步操作下来，简易博客就搭建成功了（一个简单的欢迎页面`index.html`）。

补充：扩展阅读[GitHub Pages FAQ](https://help.github.com/categories/20/articles).

###3.3Jekyll增强博客网站功能

详细阅读"__3.2如何搭建博客__"中提到的[GitHub Pages](https://pages.github.com/)的童鞋，在[GitHub Pages](https://pages.github.com/)页面最下端一定注意到了[Blogging with Jekyll](http://jekyllrb.com/docs/quickstart/)，对，就是他，读一遍，操作一下，搞定。

补充：jekyll用起来倒是用起来了，怎么发表一遍博文呢？这个...额...等到学会 __3.4 基于jekyll框架，定制博客__ 再去写博客吧，现在建议把上面的操作反复看两遍，捋一捋逻辑流程。

###3.4基于jekyll框架，定制博客

先看一下两个使用jekyll框架的博客：[BeiYuu](http://beiyuu.com/) & [Havee](http://havee.me/)，他们对应的模版在GitHub上都可以找到：[BeiYuu.com Template of GitHub](https://github.com/beiyuu/beiyuu.github.com) & [Havee.me Template of GitHub](https://github.com/Ihavee/ihavee.github.io)。 

先膜拜一下上面两个博客模板，*光彩夺目，亮瞎一双狗眼，*好了，我能不能也搭建一个类似的博客？途径有一个：深入学习一下[Jekyll的官方文档][jekyll]，补充：[中文版本][jekyllcn]。*（基于jekyll，如何定制博客，我将写一篇详细的介绍，敬请期待）*

##4.FAQ

###4.1使用google analytics来统计网站访问情况

1. 注册[Google Analytics]账户；
2. 在账户下，添加要监控的网站信息，[Google Analytics]会生成跟踪信息的JS片段；
3. 将上述JS片段插入到自己想要统计的页面上；

具体设置细节：请查看[官方文档](http://www.google.com/intl/zh-CN_ALL/analytics/learn/index.html)。

###4.2如何DISCUS作为评论插件？

1. 注册[DISQUS]账户；
2. 登录后，点击`Add Disqus to your site`按钮，操作下去，最终将获得相应的JS片段；
3. 将上述JS片段插入到自己想要包含评论的页面即可；


###4.3配置网站，支持LaTeX语法

配置博客，支持[LaTeX]公式，此次设置[kramdown]来解析[Markdown]文件。

~~~
/*
If you have sufficient control over the publishing process
(e.g. you are running Jekyll yourself), an easy solution is
to switch the markdown parser to one that supports TeX.
*/

//For example, using kramdown:
gem install kramdown

//Change the markdown line in _config.yml to
markdown: kramdown

//and add something like
<script type="text/javascript" 
src="http://cdn.mathjax.org/mathjax/latest/MathJax.js?config=TeX-AMS-MML_HTMLorMML">
</script>
//to _layouts/default.html. 

//Now you can simply mark any mathematics in your posts with $$
~~~

原文链接：[Using MathJax with Jekyll](http://stackoverflow.com/questions/10987992/using-mathjax-with-jekyll)


###4.3遇到的问题&解决办法？

1. [执行Git命令时，出错提示：（fatal: remote origin already exists.）](http://blog.csdn.net/dengjianqiang2011/article/details/9260435)
2. [GitHub上markdown的解析引擎不同，会造成最终页面效果的差异](https://help.github.com/articles/migrating-your-pages-site-from-maruku)
3. jekyll serve启动出错提示：（Liquid Exception: invalid byte sequence in GBK）__见下文__

修改`\Ruby200\lib\ruby\gems\2.0.0\gems\jekyll-1.0.3\lib\jekyll`目录下的`convertible.rb`文件，将其中：


	self.content = File.read(File.join(base, name))
	
修改为：

	self.content = File.read(File.join(base, name),:encoding=>"utf-8")

如果上述修改之后，仍然提示出错，则：`...\lib\jekyll\tags`目录下`include.rb`文件，类似对于`convertible.rb`文件的操作；


[CSDN]:		http://www.csdn.net/		"CSDN"
[javaEye]:	http://www.iteye.com/		"javaEye(现在更名为ITeye)"
[OSCHINA]:	http://www.oschina.net/		"OSCHINA"
[NingG]:    http://ningg.github.com		"NingG"
[WordPress]: https://wordpress.org/ 	"WordPress"
[GitHub]:	https://github.com/about	"GitHub"
[GitCafe]:	https://gitcafe.com/		"GitCafe"
[GitHub Pages]: https://pages.github.com/ 
[jekyll]:	http://jekyllrb.com/ 
[jekyllcn]:	http://jekyllcn.com/ 
[Google Analytics]: http://www.google.com/analytics/ 
[DISQUS]:	http://disqus.com/
[LaTeX]:	http://www.latex-project.org/
[kramdown]:	http://kramdown.gettalong.org
[Markdown]:	http://daringfireball.net/projects/markdown/syntax





