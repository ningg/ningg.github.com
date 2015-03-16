---
layout: post
title: ElasticSearch入门操作
description: 安装、启动，新建、查询、删除 Index
category: elasticsearch
---



当前使用组件的版本：

|组件|版本|
|----|----|
|ElasticSearch|`1.4.4`|
|Java| `1.7.0_67` HotSpot(64) 64-Bit|





##启动

直接下载，然后解压，直接运行脚本`bin/elasticsearch`。如果希望 ElasticSearch 在后台运行，则执行命令`bin/elasticsearch -d`，其将 ElasticSearch 进程的父进程设置为超级进程（`pid=1`）。现在，如何测试是否启动成功？可向 `http://localhost:9200` 发送一条请求，会查看到返回的JSON字符串，具体效果如下：

	[ningg@localhost ~]$ curl -XGET http://localhost:9200/
	{
	  "status" : 200,
	  "name" : "Silly Seal",
	  "cluster_name" : "elasticsearch",
	  "version" : {
		"number" : "1.4.4",
		"build_hash" : "c88f77ffc81301dfa9dfd81ca2232f09588bd512",
		"build_timestamp" : "2015-02-19T13:05:36Z",
		"build_snapshot" : false,
		"lucene_version" : "4.10.3"
	  },
	  "tagline" : "You Know, for Search"
	}

补充几点：

* 验证ElasticSearch是否成功启动，也可以直接使用浏览器，访问`http://localhost:9200`，将此处 `localhost` 替换为服务器的IP。
* 在后台启动ElasticSearch的详细过程，可以参考`bin/elasticsearch`脚本细节，内部有详细说明，本质就是shell脚本中启动一个Java进程。

##Index操作


###插入数据

如果指定的 `Index`\`Type` 不存在，则自动创建，下面为向`Index`\`Type` 插入数据的命令；

	curl -XPUT 'http://localhost:9200/test/test/1' -d '{ "name" : "Ning Guo"}'
	
###查询数据

查询指定条件的数据，两个操作：`_count`、`_search`。

	[ningg@localhost ~]$ curl -XGET http://localhost:9200/test/_count?pretty=true
	{
	  "count" : 1,
	  "_shards" : {
		"total" : 5,
		"successful" : 5,
		"failed" : 0
	  }
	}
	[ningg@localhost ~]$ 
	[ningg@localhost ~]$ curl -XGET http://localhost:9200/test/_search?pretty=true
	{
	  "took" : 2,
	  "timed_out" : false,
	  "_shards" : {
		"total" : 5,
		"successful" : 5,
		"failed" : 0
	  },
	  "hits" : {
		"total" : 1,
		"max_score" : 1.0,
		"hits" : [ {
		  "_index" : "test",
		  "_type" : "test",
		  "_id" : "1",
		  "_score" : 1.0,
		  "_source":{ "name" : "Ning Guo"}
		} ]
	  }
	}

其他查询：

* 查询 ElasticSearch 下，所有的 Index ：
	* `curl http://localhost:9200/_alias?pretty`
	* `curl http://localhost:9200/_stats/indexes?pretty`
	* `curl http://localhost:9200/_cat/indices?pretty`
	* 注：直接执行`_cat`会显示提示信息；
* 查询 Index 下所有的 Type 以及 Type 详情：
	* `curl http://localhost:9200/indexName/_mapping?pretty`
* 查询 Index 的详情：
	* `curl http://localhost:9200/indexName/_status?pretty`

* 精确查询：避免对keyword的分词和对document中field的分词







###删除数据

如何删除一个Index、Type、Document。

	curl -XDELETE http://localhost:9200/test?pretty






##监控

Elastic官网提供了一种方式Marvel，不过这种方式是付费的，我x，那能不能利用Ganglia监控呢？实际上，ElasticSearch是基于Java的，而JVM能够通过JMX方式向外停工监控数据，唯一的问题是：ElasticSearch在JVM中记录的运行状态数据吗？




##参考来源

* [ElasticSearch(Github)][ElasticSearch(Github)]
* [gitbook：Elasticsearch权威指南（中文版）][gitbook：Elasticsearch权威指南（中文版）]
* [gitbook：Elasticsearch 权威指南][gitbook：Elasticsearch 权威指南]






[NingG]:    							http://ningg.github.com  "NingG"
[ElasticSearch(Github)]:							https://github.com/elastic/elasticsearch
[gitbook：Elasticsearch权威指南（中文版）]:		https://www.gitbook.com/book/looly/elasticsearch-the-definitive-guide-cn/details
[gitbook：Elasticsearch 权威指南]:					http://learnes.net/index.html







