---
layout: post
title: Scrapy 系列：Scrapy 基础用法
description: 学习一下 Scrapy 的通常用法
published: true
category: scrapy
---

## 概要

Scrapy 的通常用法，几个方面：

* 基础用法：创建一个工程、启动一个爬虫
* 高级用法：定制的说明

主要资料：

* [Scrapy-GitHub](https://github.com/scrapy/scrapy)
* [Scrapy 官网](https://scrapy.org/)

## 第一个 demo

根据 [Scrapy 官网](https://scrapy.org/) 首页的介绍，启动一个最简单的爬虫：

```
# 安装
$ pip install scrapy

# 编写配置文件 myspider.py
$ cat > myspider.py <<EOF
import scrapy

class BlogSpider(scrapy.Spider):
    name = 'blogspider'
    start_urls = ['https://blog.scrapinghub.com']

    def parse(self, response):
        for title in response.css('h2.entry-title'):
            yield {'title': title.css('a ::text').extract_first()}

        for next_page in response.css('div.prev-post > a'):
            yield response.follow(next_page, self.parse)
EOF

# 运行爬虫
$ scrapy runspider myspider.py
```
运行之后，输出的内容：

```
localhost:scrapy guoning$ scrapy runspider myspider.py
2017-11-04 13:25:26 [scrapy.utils.log] INFO: Scrapy 1.4.0 started (bot: scrapybot)
2017-11-04 13:25:26 [scrapy.utils.log] INFO: Overridden settings: {'SPIDER_LOADER_WARN_ONLY': True}
2017-11-04 13:25:26 [scrapy.middleware] INFO: Enabled extensions:
['scrapy.extensions.memusage.MemoryUsage',
 'scrapy.extensions.logstats.LogStats',
 'scrapy.extensions.telnet.TelnetConsole',
 'scrapy.extensions.corestats.CoreStats']
2017-11-04 13:25:26 [scrapy.middleware] INFO: Enabled downloader middlewares:
['scrapy.downloadermiddlewares.httpauth.HttpAuthMiddleware',
 'scrapy.downloadermiddlewares.downloadtimeout.DownloadTimeoutMiddleware',
 'scrapy.downloadermiddlewares.defaultheaders.DefaultHeadersMiddleware',
 'scrapy.downloadermiddlewares.useragent.UserAgentMiddleware',
 'scrapy.downloadermiddlewares.retry.RetryMiddleware',
 'scrapy.downloadermiddlewares.redirect.MetaRefreshMiddleware',
 'scrapy.downloadermiddlewares.httpcompression.HttpCompressionMiddleware',
 'scrapy.downloadermiddlewares.redirect.RedirectMiddleware',
 'scrapy.downloadermiddlewares.cookies.CookiesMiddleware',
 'scrapy.downloadermiddlewares.httpproxy.HttpProxyMiddleware',
 'scrapy.downloadermiddlewares.stats.DownloaderStats']
2017-11-04 13:25:26 [scrapy.middleware] INFO: Enabled spider middlewares:
['scrapy.spidermiddlewares.httperror.HttpErrorMiddleware',
 'scrapy.spidermiddlewares.offsite.OffsiteMiddleware',
 'scrapy.spidermiddlewares.referer.RefererMiddleware',
 'scrapy.spidermiddlewares.urllength.UrlLengthMiddleware',
 'scrapy.spidermiddlewares.depth.DepthMiddleware']
2017-11-04 13:25:26 [scrapy.middleware] INFO: Enabled item pipelines:
[]
2017-11-04 13:25:26 [scrapy.core.engine] INFO: Spider opened
2017-11-04 13:25:26 [scrapy.extensions.logstats] INFO: Crawled 0 pages (at 0 pages/min), scraped 0 items (at 0 items/min)
2017-11-04 13:25:26 [scrapy.extensions.telnet] DEBUG: Telnet console listening on 127.0.0.1:6023
2017-11-04 13:25:28 [scrapy.core.engine] DEBUG: Crawled (200) <GET https://blog.scrapinghub.com> (referer: None)
2017-11-04 13:25:28 [scrapy.core.scraper] DEBUG: Scraped from <200 https://blog.scrapinghub.com>
{'title': u'Scraping the Steam Game Store with Scrapy'}

...

2017-11-04 13:25:28 [scrapy.core.engine] DEBUG: Crawled (200) <GET https://blog.scrapinghub.com/page/2/> (referer: https://blog.scrapinghub.com)
2017-11-04 13:25:29 [scrapy.core.scraper] DEBUG: Scraped from <200 https://blog.scrapinghub.com/page/2/>
{'title': u'How to Run Python Scripts in Scrapy Cloud'}

...

2017-11-04 13:25:39 [scrapy.core.engine] INFO: Closing spider (finished)
2017-11-04 13:25:39 [scrapy.statscollectors] INFO: Dumping Scrapy stats:
{'downloader/request_bytes': 2933,
 'downloader/request_count': 11,
 'downloader/request_method_count/GET': 11,
 'downloader/response_bytes': 124748,
 'downloader/response_count': 11,
 'downloader/response_status_count/200': 11,
 'finish_reason': 'finished',
 'finish_time': datetime.datetime(2017, 11, 4, 5, 25, 39, 304415),
 'item_scraped_count': 105,
 'log_count/DEBUG': 117,
 'log_count/INFO': 7,
 'memusage/max': 46608384,
 'memusage/startup': 46608384,
 'request_depth_max': 10,
 'response_received_count': 11,
 'scheduler/dequeued': 11,
 'scheduler/dequeued/memory': 11,
 'scheduler/enqueued': 11,
 'scheduler/enqueued/memory': 11,
 'start_time': datetime.datetime(2017, 11, 4, 5, 25, 26, 950184)}
2017-11-04 13:25:39 [scrapy.core.engine] INFO: Spider closed (finished)
```

上面大致的信息：

1. 启动
1. 抓取：抓取当页、翻页、解析
1. 终止：输出抓取的效果统计

## 基础用法

基础用法，关注 2 个方面：

1. 创建新工程
1. 基础概念/原理

关联资料：

* [Scrapy 完整文档](https://docs.scrapy.org/en/latest/)
* [Scrapy Tutorial](https://docs.scrapy.org/en/latest/intro/tutorial.html)

### 创建 Scrapy 工程

创建工程, 执行命令:

```
# 当前目录,创建 tutorial 目录, 并增加 scrapy 工程模板
scrapy startproject tutorial
```

启动工程, 执行命令:

```
cd tutorial/output

scrapy crawl quotes
```


有个独立的工程：

* [ScrapyLearn of NingG](https://github.com/ningg/ScrapyLearn)


## 高级用法

高级用法，几个方面：

* TODO

关联资料：

* [Scrapy 完整文档](https://docs.scrapy.org/en/latest/)
* [Scrapy Tutorial](https://docs.scrapy.org/en/latest/intro/tutorial.html)
* [Python爬虫(六)--Scrapy框架学习](http://www.jianshu.com/p/078ad2067419)
* [Scrapy爬虫-简介](http://www.jianshu.com/p/78ada0a2ff15)


## 思考

最近要爬取一批数据，一心想找现成的东西，直接拿来用；每每看到半成品都没有心思细细研究、定制；总想着肯定有现成的东西可用，花时间研究就是浪费。

实际上，如果是一个中长期的事情，就需要投入时间、长期的投入；参考前人的积累是很必要的，但一定要有自己的思路，能够依赖的也只有自己的思路，完全依赖天上噹的一声掉下来个拿来就能用的东西，就是妄想了。

做事情，思路也是比较清晰的：

1. 熟悉：从各方查询资料，简单有个理解，时间不宜太长；
1. 重建：从信息源出发，重建自己在某个问题上的知识体系；
1. 深入：基于前述理解和掌握，重新审视其他人的方案，并以自己的思路为主导，进行深入，产生价值
1. 迭代：反复分析、改进。

可以看别人的经验、总结，但归根结底，还是要回到信息源头上去，对，就是官网、作者的说明。









* [Scrapy Tutorial](https://doc.scrapy.org/en/latest/intro/tutorial.html)




## 参考资料

* [Scrapy-GitHub](https://github.com/scrapy/scrapy)
* [Python爬虫(六)--Scrapy框架学习](http://www.jianshu.com/p/078ad2067419)
* [Scrapy爬虫-简介](http://www.jianshu.com/p/78ada0a2ff15)














[NingG]:    http://ningg.github.com  "NingG"










