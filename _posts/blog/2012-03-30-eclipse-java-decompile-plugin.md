---
layout: post
title: Eclipse下java代码反编译插件
description: 没有jar包的源码时，通过字节码文件反编译即可查看代码
published: true
category: java
---

目标：通过字节码文件（.class）反编译生成源文件（.java）。


几步：

* 下载插件：下载[jdeclipse_update_site.zip][jdeclipse update site]，将其解压为文件夹 `jdeclipse_update_site`；
* 安装插件：在Eclipse下，`Help` > `Install new software` > `work with`中点击`Add` > `Local` > 选择刚刚解压获得的文件夹 `jdeclipse_update_site`；
* 为`*.class`文件，绑定编辑器：`Window` > `Preferences...` > `General` > `Editors` > `File Associations` 为 `*.class` 文件绑定编辑器；

特别说明，在上述为`*.class`文件绑定编辑器时，有可能是需要为文件`*.class without source` 绑定编辑器。






##参考来源


* [Eclipse 4.2 Juno SR2 反编绎java插件][Eclipse 4.2 Juno SR2 反编绎java插件]
* [jdeclipse update site][jdeclipse update site]

































[NingG]:    								http://ningg.github.com  "NingG"
[Eclipse 4.2 Juno SR2 反编绎java插件]:		http://www.cnblogs.com/wucg/archive/2013/03/13/2957162.html
[jdeclipse update site]:					http://jd.benow.ca/jd-eclipse/downloads/jdeclipse_update_site.zip







