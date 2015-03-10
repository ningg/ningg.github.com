---
layout: post
title: ElasticSearch下配置Kafka插件
description: ElasticSearch下如何添加、删除插件
category: elasticsearch
---

做个记录：ElasticSearch下如何添加、删除插件。做此记录的初衷有两个：

* 记录，作为备忘；
* 记录初稿，今后操作时，方便基于此的改进和积累；

##组件版本

|组件|版本|链接|
|----|----|----|
|ElasticSearch|`1.4.4`|[参考链接][ElasticSearch]|
|Kafka|`0.8.2.0`|[参考链接][Kafka]|
|ElasticSearch river kafka|`1.2.1`|[参考链接][ElasticSearch river kafka]|
|操作系统|centOS 6.3| |


备注：已经folk了插件[ElasticSearch river kafka][ElasticSearch river kafka(ningg)]，并将其中ElasticSearch、Kafka对应版本好进行升级，本地`mvn clean install`编译之后，用于进行插件的安装。


执行`mvn clean install`命令时，提示：

	$mvn clean insatll
	...
	[INFO] --- maven-failsafe-plugin:2.14:integration-test (default) @ elasticsearch-river-kafka ---
	[INFO] No tests to run.
	[WARNING] File encoding has not been set, using platform encoding GBK, i.e. build is platform dependent!
	...
	
**解决方案**：在`pom.xml`中`failsafe`插件下，设定编码方式，具体：

	<plugin>
		<artifactId>maven-failsafe-plugin</artifactId>
		<version>${version.maven.failsafe.plugin}</version>
		<configuration>
			<encoding>UTF-8</encoding>
		</configuration>
		<executions>
			<execution>
				<goals>
					<goal>integration-test</goal>
					<goal>verify</goal>
				</goals>
			</execution>
		</executions>
	</plugin>







##添加插件

目标：在ElasticSearch下添加Kafka插件。



第一步：编译插件：`mvn clean install`，得到`$PROJECT-PATH/target/elasticsearch-river-kafka-1.2.1-SNAPSHOT-plugin.zip`文件。




第二步：安装插件：将上述`elasticsearch-river-kafka-1.2.1-SNAPSHOT-plugin.zip`文件上传到ElasticSearch运行的服务器上`/home/es`目录下，执行下述命令，安装插件：

	cd $ELASTICSEARCH_HOME
	.bin/plugin --install kafka-river --url file:////home/es/elasticsearch-river-kafka-1.2.1-SNAPSHOT-plugin.zip

第三步：配置Kafka插件，详细配置参数，参考[ElasticSearch river kafka][ElasticSearch river kafka]，下面只贴一下我自己的配置：

	curl -XPUT 'http://168.7.1.69:9200/_river/kafka-river/_meta' -d '
	{  
	  "type":"kafka",
	  "kafka":{
		 "zookeeper.connect":"168.7.2.164:2181,168.7.2.165:2181,168.7.2.166:2181",
		 "zookeeper.connection.timeout.ms":10000,
		 "topic":"good",
		 "message.type": "json"
	  },
	  "index":{
		 "index":"kafka-index",
		 "type":"status",
		 "bulk.size":100,
		 "concurrent.requests":1,
		 "action.type":"index"
	  }
	}'


第四步：重新启动ElasticSearch

第五步：查询Kafka数据是否已经传送至ElasticSearch，执行命令如下：

	curl -XGET 'http://168.7.1.69:9200/kafka-index/status/_search?pretty'
	// 或者 统计记录条数
	curl -XGET 'http://168.7.1.69:9200/kafka-index/status/_count?pretty'








注：参考自[ElasticSearch river kafka][ElasticSearch river kafka]


##删除插件


第一步，通过rest接口，删除，执行命令：

	curl -XDELETE 'http://168.7.1.69:9200/_river/kafka-river/'

第二步，通过plugin命令删除，具体执行命令：

	cd $ELASTICSEARCH_HOME
	.bin/plugin --remove kafka-river

第三步，重启ElasticSearch。




注：参考自[ElasticSearch river kafka][ElasticSearch river kafka]


##参考来源


* [ElasticSearch river kafka][ElasticSearch river kafka]














[NingG]:    							http://ningg.github.com  "NingG"
[ElasticSearch river kafka]:			https://github.com/mariamhakobyan/elasticsearch-river-kafka
[ElasticSearch river kafka(ningg)]:		https://github.com/ningg/elasticsearch-river-kafka
[ElasticSearch]:						http://www.elasticsearch.org/
[Kafka]:								http://kafka.apache.org/











