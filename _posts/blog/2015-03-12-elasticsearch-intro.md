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





## 启动

直接[下载](https://www.elastic.co/cn/downloads/elasticsearch)，然后解压，直接运行脚本`bin/elasticsearch`。如果希望 ElasticSearch 在后台运行，则执行命令`bin/elasticsearch -d`，其将 ElasticSearch 进程的父进程设置为超级进程（`pid=1`）。

**Note**: 直接在 elastisearch 的 home 目录，执行 `bin/elasticsearch` 命令；不要 `cd bin` 后，单独执行 `elasticsearch` 命令，因为，大部分情况下，会提示有错误。

现在，如何测试，是否启动成功呢？可向 `http://localhost:9200` 发送一条请求，会查看到返回的JSON字符串，具体效果如下：

```
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
```

补充几点：

* 浏览器验证：验证ElasticSearch是否成功启动，也可以直接使用浏览器，访问`http://localhost:9200`，将此处 `localhost` 替换为服务器的IP。
* 启动的本质：在后台启动ElasticSearch的详细过程，可以参考`bin/elasticsearch`脚本细节，内部有详细说明，本质就是shell脚本中，启动一个Java进程。

## Index操作

几个基本操作：

1. 插入数据
2. 查询数据
3. 删除数据

### 插入数据

如果指定的 `Index\Type` 不存在，则自动创建，下面为向`Index\Type` 插入数据的命令；

	curl -XPUT 'http://localhost:9200/test/test/1' -d '{ "name" : "Ning Guo"}'
	
### 查询数据

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







### 删除数据

如何删除一个Index、Type、Document。

	curl -XDELETE http://localhost:9200/test?pretty






## 监控

Elastic官网提供了一种方式Marvel，不过这种方式是付费的，我x，那能不能利用Ganglia监控呢？实际上，ElasticSearch是基于Java的，而JVM能够通过JMX方式向外停工监控数据，唯一的问题是：ElasticSearch在JVM中记录的运行状态数据吗？


## 常见问题


### WARN: Too many open files

详细错误信息：

	[2015-04-14 11:18:25,797][WARN ][indices.cluster          ] [Rune] [flume-2015-04-14][2] failed to start shard
	org.elasticsearch.index.gateway.IndexShardGatewayRecoveryException: [flume-2015-04-14][2] failed recovery
		at org.elasticsearch.index.gateway.IndexShardGatewayService$1.run(IndexShardGatewayService.java:185)
		at java.util.concurrent.ThreadPoolExecutor.runWorker(ThreadPoolExecutor.java:1145)
		at java.util.concurrent.ThreadPoolExecutor$Worker.run(ThreadPoolExecutor.java:615)
		at java.lang.Thread.run(Thread.java:745)
	Caused by: org.elasticsearch.index.engine.EngineCreationFailureException: [flume-2015-04-14][2] failed to open reader on writer
		at org.elasticsearch.index.engine.internal.InternalEngine.start(InternalEngine.java:326)
		at org.elasticsearch.index.shard.service.InternalIndexShard.performRecoveryPrepareForTranslog(InternalIndexShard.java:732)
		at org.elasticsearch.index.gateway.local.LocalIndexShardGateway.recover(LocalIndexShardGateway.java:231)
		at org.elasticsearch.index.gateway.IndexShardGatewayService$1.run(IndexShardGatewayService.java:132)
		... 3 more
	Caused by: java.nio.file.FileSystemException: /home/storm/es/elasticsearch-1.4.4/data/elasticsearch/nodes/0/indices/flume-2015-04-14/2/index/_h3.cfe: Too many open files
		at sun.nio.fs.UnixException.translateToIOException(UnixException.java:91)
		at sun.nio.fs.UnixException.rethrowAsIOException(UnixException.java:102)
		at sun.nio.fs.UnixException.rethrowAsIOException(UnixException.java:107)
		at sun.nio.fs.UnixFileSystemProvider.newFileChannel(UnixFileSystemProvider.java:177)
		at java.nio.channels.FileChannel.open(FileChannel.java:287)
		at java.nio.channels.FileChannel.open(FileChannel.java:334)
		at org.apache.lucene.store.NIOFSDirectory.openInput(NIOFSDirectory.java:81)
		at org.apache.lucene.store.FileSwitchDirectory.openInput(FileSwitchDirectory.java:172)
		at org.apache.lucene.store.FilterDirectory.openInput(FilterDirectory.java:80)
		at org.elasticsearch.index.store.DistributorDirectory.openInput(DistributorDirectory.java:130)
		at org.apache.lucene.store.FilterDirectory.openInput(FilterDirectory.java:80)
		at org.elasticsearch.index.store.Store$StoreDirectory.openInput(Store.java:515)
		at org.apache.lucene.store.Directory.openChecksumInput(Directory.java:113)
		at org.apache.lucene.store.CompoundFileDirectory.readEntries(CompoundFileDirectory.java:166)
		at org.apache.lucene.store.CompoundFileDirectory.<init>(CompoundFileDirectory.java:106)
		at org.apache.lucene.index.SegmentReader.readFieldInfos(SegmentReader.java:274)
		at org.apache.lucene.index.SegmentReader.<init>(SegmentReader.java:107)
		at org.apache.lucene.index.ReadersAndUpdates.getReader(ReadersAndUpdates.java:145)
		at org.apache.lucene.index.ReadersAndUpdates.getReadOnlyClone(ReadersAndUpdates.java:239)
		at org.apache.lucene.index.StandardDirectoryReader.open(StandardDirectoryReader.java:104)
		at org.apache.lucene.index.IndexWriter.getReader(IndexWriter.java:422)
		at org.apache.lucene.index.DirectoryReader.open(DirectoryReader.java:112)
		at org.apache.lucene.search.SearcherManager.<init>(SearcherManager.java:89)
		at org.elasticsearch.index.engine.internal.InternalEngine.buildSearchManager(InternalEngine.java:1569)
		at org.elasticsearch.index.engine.internal.InternalEngine.start(InternalEngine.java:313)
		... 6 more

解决办法：

* 在当前Linux下，使用elasticsearch用户身份，执行`ulimt -Hn`和`ulimit -Sn`，查看当前用户，在当前shell环境下，允许打开文件的最大个数；
* 打开`/etc/security/limits.conf`文件，在最后，添加如下两行内容：*（启动elasticsearch的用户为`elasticsearch`）*
	* elasticsearch soft  nofile 32000
	* elasticsearch hard  nofile 32000
* 重新以elasticsearch用户身份登录，并执行执行`ulimt -Hn`和`ulimit -Sn`，以此验证上述配置是否生效；若设置生效，则重启Elasticsearch即可。

简要解释：`/etc/security/limits.conf`文件中设置了，一个用户或者组，所能使用的系统资源，例如：CPU、内存以及可同时打开文件的数量等。


更多细节，参考：

* [Error - Too many open files][Error - Too many open files]
* [Elasticsearch - too many open files][Elasticsearch - too many open files]


## 参考来源

* [ElasticSearch(Github)][ElasticSearch(Github)]
* [gitbook：Elasticsearch权威指南（中文版）][gitbook：Elasticsearch权威指南（中文版）]
* [gitbook：Elasticsearch 权威指南][gitbook：Elasticsearch 权威指南]






[NingG]:    							http://ningg.github.com  "NingG"
[ElasticSearch(Github)]:							https://github.com/elastic/elasticsearch
[gitbook：Elasticsearch权威指南（中文版）]:		https://www.gitbook.com/book/looly/elasticsearch-the-definitive-guide-cn/details
[gitbook：Elasticsearch 权威指南]:					http://learnes.net/index.html
[Error - Too many open files]:						http://elasticsearch-users.115913.n3.nabble.com/Error-Too-many-open-files-td2779067.html
[Elasticsearch - too many open files]:				http://queirozf.com/entries/elasticsearch-too-many-open-files






