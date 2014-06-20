---
layout: post
title: markdown入门介绍
description: 现在流行markdown，特别是github上用的更多，那到底markdown是什么？
category: markdown
---

##背景

几个问题：

> 1. markdown产生之前，没有markdown；随着时间推进，为什么会有markdown？
> 2. markdown能解决什么问题？这个问题之前没有解决办法吗？

书写WEB页面大都需要写HTML语法的页面，有很多类似`<h1>`、 `<\h1>`、 `<div>`、 `<\div>`、 `<img>`等的标签。

有些WEB开发人员，厌倦了写HTML标签，同时，用文本编辑器查看HTML页面，内容读起来不简洁、看不出层次感。总结一下，就是两个需求：

1. HTML页面写起来要简单；*（易写）*
2. 用文本编辑器查看，读起来要简洁；*（易读）*

为实现"**1.HTML页面易写**"这一功能，就不能再直接写HTML页面了，怎么办？重新定义一种易写的文本书写格式，然后，用个程序，将其转换为HTML页面。*（你看，HTML页面是否变得容易写了？）*
同时，为了实现"**2.文本易读**"这一功能，要求重新定义的文本书写格式具备格式简洁、层次清晰等特点。

在这一背景下，markdown产生了。

##markdown是什么？

markdown到底是什么？最原始介绍在这儿[markdown] ，markdown有两层含义：

1. 一种文本格式：简洁的文本书写格式；*（易写、易读）*
2. 一种软件*（又称，解析引擎）*：将markdown格式的文件，转换为HTML页面；

![markdown-and-html](/images/introduction-to-markdown/markdown-and-html.png)

看到上面图示，有人会问，markdown能够转换为HTML文档，那么，HTML文档能否转换为markdown格式文档呢？我x，你说呢，两种文档之间有映射关系，当然可以相互转换了，参考工具[html2text](http://www.aaronsw.com/2002/html2text/)。 


##Notepad++上配置markdown

GitHub上已经有人公开了Notepad++支持markdown语法的配置文件[markdown of Notepad++](https://github.com/thomsmits/markdown_npp)， 尝试用了一下，其中提到的[debug theme](https://raw.github.com/thomsmits/markdown_npp/master/debug_theme/userDefineLang.xml) 风格感觉不错。

__说明__：一个bug需要调整，当markdown文档内url包含1个`_`时，下文的显示样式错乱，需要在[debug theme](https://raw.github.com/thomsmits/markdown_npp/master/debug_theme/userDefineLang.xml) 格式定义文件中，将Delimiters中的`_`字符删除即可。




##GitHub上使用markdown

markdown有不同的解析引擎，GitHub上，应该使用哪一个？对此，GitHub帮助文档上有[详细介绍](https://help.github.com/articles/migrating-your-pages-site-from-maruku)， 简要介绍如下：

2012年10月之前，GitHub Pages上使用[Maruku]作为markdown文档的解析引擎，来生成最终的HTML页面。

2012年10月之后，Maruku官网声明：[Maruku项目将终止](http://benhollis.net/blog/2013/10/20/maruku-is-obsolete/) ，因此，GitHub建议使用[kramdown]来替代[Maruku]。*（本blog使用的就是[kramdown]解析引擎）*

__说明__：下文的基本语法，主要是[kramdown]解析引擎支持的markdown语法。*（甚至有些语法，不是标准markdown语法，而是kramdown的扩展语法）*。

__更新__：GitHub现在使用[GitHub Flavored Markdown](https://help.github.com/articles/github-flavored-markdown) 的Markdown语法，其在标准的[markdown]语法上，进行了一些改进。

##基本语法(doing...)

对于标准markdown的语法规则，[markdown官网][markdown]已经有了完善的介绍，当然也有中文版的[markdown语法(简体中文)](http://wowubuntu.com/markdown/) 。

本文这一部分，主要是针对[kramdown]解析引擎来说的，建议阅读官网的介绍：[语法规则细则](http://kramdown.gettalong.org/syntax.html) 和[快速查询手册](http://kramdown.gettalong.org/quickref.html) 。*（为什么介绍kramdown支持的语法？因为我在GitHub上指定的是kramdown解析引擎）*

下文将对自己常用到的语法，进行简要介绍，以备查阅。

###链接

包括：图片、文档、其他网页链接；

如何约束图片的大小？



###代码




###公式




###表格

![chinese-carrier](/images/introduction-to-markdown/chinese-carrier.jpg)
![markdown-to-html](/images/introduction-to-markdown/markdown-to-html.jpg)

[Maruku]:	https://github.com/bhollis/maruku/
[kramdown]:	http://kramdown.gettalong.org/ "kramdown"
[markdown]:	http://daringfireball.net/projects/markdown/ "original markdown introduction"
[NingG]:    http://ningg.github.com  "NingG"
