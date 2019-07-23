---
layout: post
title: 实践系列：分布式配置中心的实现方案，调研
description: 分布式配置中心，当前存在哪些方案？有什么优劣？中间出现哪些关键概念？
category: 技术架构
---



## 0. 背景

* 远端缓存 + 远端热更新：分布式的配置中心，从 MySQL 中读取最新配置；
* 区分环境
* MySQL 读取配置信息


## 1. 调研分析

分析，拍着脑袋，猜一下，有几种方向：

* Spring Cloud 的配置中心，采用 MySQL 中配置，进行更新
* 百度的分布式配置中心
* 阿里的分布式配置中心
* 美团的分布式配置中心
* 其他公司的分布式配置中心

### 1.1. 方案汇总

|名称|来源|原理|备注|
|:--|:--|:--|:--|
|Disconf|百度开源|MySQL + ZK|[https://github.com/knightliao/disconf](https://github.com/knightliao/disconf)|
|Apollo|携程开源|HTTP 长轮询|[https://github.com/ctripcorp/apollo](https://github.com/ctripcorp/apollo)|
|Diamond|阿里开源||[https://github.com/takeseem/diamond](https://github.com/takeseem/diamond)|
|diablo|个人-轻量级|HTTP 长轮询|[https://github.com/ihaolin/diablo](https://github.com/ihaolin/diablo)|
|xxl-conf|点评开源|MySQL + ZK|[https://github.com/xuxueli/xxl-conf](https://github.com/xuxueli/xxl-conf)|
|antelope|个人|ZK|[https://github.com/believeyrc/antelope](https://github.com/believeyrc/antelope)|


### 1.2. 常见问题：diablo

疑问汇总：

1. Maven 插件 assembly：assemble.xml 文件的作用？如何使用？ [http://maven.apache.org/plugins/maven-assembly-plugin/assembly.html](http://maven.apache.org/plugins/maven-assembly-plugin/assembly.html)
1. maven-assembly-plugin，Maven 的打包插件
1. package-info.java 文件： [http://www.cnblogs.com/jiangxinnju/p/5146768.html](http://www.cnblogs.com/jiangxinnju/p/5146768.html)

Maven 中，插件配置，导致 debug 失效：

```
<plugin>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-maven-plugin</artifactId>
    <!--<configuration>-->
        <!--<mainClass>me.hao0.diablo.server.DiabloServer</mainClass>-->
        <!--<fork>true</fork>-->
        <!--<executable>true</executable>-->
    <!--</configuration>-->
</plugin>
```


## 2. 附录

### 2.1. 附录 A：HTTP polling vs long polling

参考：

* [https://www.pubnub.com/blog/2014-12-01-http-long-polling/](https://www.pubnub.com/blog/2014-12-01-http-long-polling/)
* [http://www.cnblogs.com/hoojo/p/longPolling_comet_jquery_iframe_ajax.html](http://www.cnblogs.com/hoojo/p/longPolling_comet_jquery_iframe_ajax.html)
* [https://www.quora.com/What-is-the-difference-between-polling-and-long-polling-in-simple-terms](https://www.quora.com/What-is-the-difference-between-polling-and-long-polling-in-simple-terms)
* [https://community.intersystems.com/post/websockets-vs-long-polling-vs-short-polling](https://community.intersystems.com/post/websockets-vs-long-polling-vs-short-polling)


http long polling： 

* [http://www.cnblogs.com/hoojo/p/longPolling_comet_jquery_iframe_ajax.html](http://www.cnblogs.com/hoojo/p/longPolling_comet_jquery_iframe_ajax.html)
* [http://blog.csdn.net/huang9012/article/details/8096561](http://blog.csdn.net/huang9012/article/details/8096561)


## 3. 参考资料

AB Test：

* 点评大规模并行 AB test 框架： [http://www.csdn.net/article/2015-03-24/2824303](http://www.csdn.net/article/2015-03-24/2824303)
* 美团推荐系统整体框架和关键工作： [http://blog.csdn.net/a936676463/article/details/50211693](http://blog.csdn.net/a936676463/article/details/50211693)
* 美团如何对产品做 AB test： [http://blog.csdn.net/weiguang_123/article/details/49203239](http://blog.csdn.net/weiguang_123/article/details/49203239)
* Google 如何通过 AB 测试驱动产品优化： [http://www.pmcaff.com/article/index/302521404167296](http://www.pmcaff.com/article/index/302521404167296)
* 分层实验架构： [http://blog.jqian.net/post/exp-sys.html](http://blog.jqian.net/post/exp-sys.html)
* 十分钟了解分层实验： [https://yq.aliyun.com/articles/5837](https://yq.aliyun.com/articles/5837)
* Google 重叠实验框架：更多，更好，更快地实验： [http://www.csdn.net/article/2015-01-09/2823499](http://www.csdn.net/article/2015-01-09/2823499)
* 微博广告分层实验平台(Faraday)架构实践： [http://www.infoq.com/cn/articles/weibo-ad-layered-experiment-platform-faraday](http://www.infoq.com/cn/articles/weibo-ad-layered-experiment-platform-faraday)

配置中心：

* [开源分布式配置中心选型](http://vernonzheng.com/2015/02/09/%E5%BC%80%E6%BA%90%E5%88%86%E5%B8%83%E5%BC%8F%E9%85%8D%E7%BD%AE%E4%B8%AD%E5%BF%83%E9%80%89%E5%9E%8B/)
* 百度开源 Disconf：分布式配置管理平台： [http://disconf.readthedocs.io](http://disconf.readthedocs.io)
* 阿里 Diamond：[http://jm.taobao.org/2016/09/28/an-article-about-config-center/](http://jm.taobao.org/2016/09/28/an-article-about-config-center/)
* 服务化体系之－配置中心，在ZK或etcd之外： [http://calvin1978.blogcn.com/articles/serviceconfig.html](http://calvin1978.blogcn.com/articles/serviceconfig.html)
* [说说配置中心那点事](http://iweishao.com/%E8%AF%B4%E8%AF%B4%E9%85%8D%E7%BD%AE%E4%B8%AD%E5%BF%83%E9%82%A3%E7%82%B9%E4%BA%8B.html)

 

其他惊喜：

* [http://www.pmcaff.com/](http://www.pmcaff.com/) 产品、项目管理、风险管控流程，一个很不错的社区
* [http://www.liaoqiqi.com/resume](http://www.liaoqiqi.com/resume) 有意思的人，而且是 Disconf 的作者

微服务资料：

* [https://www.gitbook.com/book/skyao/learning-microservice/details](https://www.gitbook.com/book/skyao/learning-microservice/details)











[NingG]:    http://ningg.github.com  "NingG"





