---
layout: post
title: Flume 1.5.0.1 User Guide：Flume Sinks
description: Flume中重要组件sink的详细介绍
categories: flume
---


## HDFS Sink

This sink writes events into the Hadoop Distributed File System (HDFS). It currently supports creating text and sequence files. It supports compression in both file types. The files can be rolled (close current file and create a new one) periodically based on the elapsed time or size of data or number of events. It also buckets/partitions data by attributes like timestamp or machine where the event originated. The HDFS directory path may contain formatting escape sequences that will replaced by the HDFS sink to generate a directory/file name to store the events. Using this sink requires hadoop to be installed so that Flume can use the Hadoop jars to communicate with the HDFS cluster. Note that a version of Hadoop that supports the sync() call is required.
（将events写到HDFS上，当前支持text和sequence file，同时也支持两种类型文件的压缩；支持根据time、size、event number来roll file——close current file并且create a new one；）

**notes(ningg)**：text？sequence file？什么含义？

The following are the escape sequences supported:

Alias	Description
%{host}	Substitute value of event header named “host”. Arbitrary header names are supported.
%t	Unix time in milliseconds
%a	locale’s short weekday name (Mon, Tue, ...)
%A	locale’s full weekday name (Monday, Tuesday, ...)
%b	locale’s short month name (Jan, Feb, ...)
%B	locale’s long month name (January, February, ...)
%c	locale’s date and time (Thu Mar 3 23:05:25 2005)
%d	day of month (01)
%D	date; same as %m/%d/%y
%H	hour (00..23)
%I	hour (01..12)
%j	day of year (001..366)
%k	hour ( 0..23)
%m	month (01..12)
%M	minute (00..59)
%p	locale’s equivalent of am or pm
%s	seconds since 1970-01-01 00:00:00 UTC
%S	second (00..59)
%y	last two digits of year (00..99)
%Y	year (2010)
%z	+hhmm numeric timezone (for example, -0400)
The file in use will have the name mangled to include ”.tmp” at the end. Once the file is closed, this extension is removed. This allows excluding partially complete files in the directory. Required properties are in bold.

Note For all of the time related escape sequences, a header with the key “timestamp” must exist among the headers of the event (unless hdfs.useLocalTimeStamp is set to true). One way to add this automatically is to use the TimestampInterceptor.
Name	Default	Description
channel	–	 
type	–	The component type name, needs to be hdfs
hdfs.path	–	HDFS directory path (eg hdfs://namenode/flume/webdata/)
hdfs.filePrefix	FlumeData	Name prefixed to files created by Flume in hdfs directory
hdfs.fileSuffix	–	Suffix to append to file (eg .avro - NOTE: period is not automatically added)
hdfs.inUsePrefix	–	Prefix that is used for temporal files that flume actively writes into
hdfs.inUseSuffix	.tmp	Suffix that is used for temporal files that flume actively writes into
hdfs.rollInterval	30	Number of seconds to wait before rolling current file (0 = never roll based on time interval)
hdfs.rollSize	1024	File size to trigger roll, in bytes (0: never roll based on file size)
hdfs.rollCount	10	Number of events written to file before it rolled (0 = never roll based on number of events)
hdfs.idleTimeout	0	Timeout after which inactive files get closed (0 = disable automatic closing of idle files)
hdfs.batchSize	100	number of events written to file before it is flushed to HDFS
hdfs.codeC	–	Compression codec. one of following : gzip, bzip2, lzo, lzop, snappy
hdfs.fileType	SequenceFile	File format: currently SequenceFile, DataStream or CompressedStream (1)DataStream will not compress output file and please don’t set codeC (2)CompressedStream requires set hdfs.codeC with an available codeC
hdfs.maxOpenFiles	5000	Allow only this number of open files. If this number is exceeded, the oldest file is closed.
hdfs.minBlockReplicas	–	Specify minimum number of replicas per HDFS block. If not specified, it comes from the default Hadoop config in the classpath.
hdfs.writeFormat	–	Format for sequence file records. One of “Text” or “Writable” (the default).
hdfs.callTimeout	10000	Number of milliseconds allowed for HDFS operations, such as open, write, flush, close. This number should be increased if many HDFS timeout operations are occurring.
hdfs.threadsPoolSize	10	Number of threads per HDFS sink for HDFS IO ops (open, write, etc.)
hdfs.rollTimerPoolSize	1	Number of threads per HDFS sink for scheduling timed file rolling
hdfs.kerberosPrincipal	–	Kerberos user principal for accessing secure HDFS
hdfs.kerberosKeytab	–	Kerberos keytab for accessing secure HDFS
hdfs.proxyUser	 	 
hdfs.round	false	Should the timestamp be rounded down (if true, affects all time based escape sequences except %t)
hdfs.roundValue	1	Rounded down to the highest multiple of this (in the unit configured using hdfs.roundUnit), less than current time.
hdfs.roundUnit	second	The unit of the round down value - second, minute or hour.
hdfs.timeZone	Local Time	Name of the timezone that should be used for resolving the directory path, e.g. America/Los_Angeles.
hdfs.useLocalTimeStamp	false	Use the local time (instead of the timestamp from the event header) while replacing the escape sequences.
hdfs.closeTries	0	Number of times the sink must try to close a file. If set to 1, this sink will not re-try a failed close (due to, for example, NameNode or DataNode failure), and may leave the file in an open state with a .tmp extension. If set to 0, the sink will try to close the file until the file is eventually closed (there is no limit on the number of times it would try).
hdfs.retryInterval	180	Time in seconds between consecutive attempts to close a file. Each close call costs multiple RPC round-trips to the Namenode, so setting this too low can cause a lot of load on the name node. If set to 0 or less, the sink will not attempt to close the file if the first attempt fails, and may leave the file open or with a ”.tmp” extension.
serializer	TEXT	Other possible options include avro_event or the fully-qualified class name of an implementation of the EventSerializer.Builder interface.
serializer.*	 	 

Example for agent named a1:

	a1.channels = c1
	a1.sinks = k1
	a1.sinks.k1.type = hdfs
	a1.sinks.k1.channel = c1
	a1.sinks.k1.hdfs.path = /flume/events/%y-%m-%d/%H%M/%S
	a1.sinks.k1.hdfs.filePrefix = events-
	a1.sinks.k1.hdfs.round = true
	a1.sinks.k1.hdfs.roundValue = 10
	a1.sinks.k1.hdfs.roundUnit = minute
	
The above configuration will round down the timestamp to the last 10th minute. For example, an event with timestamp 11:54:34 AM, June 12, 2012 will cause the hdfs path to become /flume/events/2012-06-12/1150/00.



## Logger Sink

Logs event at INFO level. Typically useful for `testing`/`debugging` purpose. Required properties are in bold.
（将INFO以上级别的event都记录下来，Logger Sink主要用于test和debugging）

|Property Name	|Default	|Description|
|--|--|--|
|**channel**|–	| |
|**type**|–	|The component type name, needs to be `logger`|

Example for agent named `a1`:

	a1.channels = c1
	a1.sinks = k1
	a1.sinks.k1.type = logger
	a1.sinks.k1.channel = c1

**notes(ningg)**：`logger`类型的Sink，有长度限制吗？其输出的event的body在stdout中只显示16字节；

## Avro Sink

This sink forms one half of Flume’s tiered collection support. Flume events sent to this sink are turned into Avro events and sent to the configured hostname / port pair. The events are taken from the configured Channel in batches of the configured batch size. Required properties are in **bold**.
（Avro Sink常用于构建分级的Flume topology，通过Avro sink，event就变为Avro event了，Avro Sink中可配置参数`batch-size`，Avro Sink按照这一参数从Channel以batch为单位，来获取数据。）

|Property Name|	Default| Description	|
|--|--|--| 
|**channel**|	–|	 | 
|**type**| –|	The component type name, needs to be avro.|
|**hostname**|	–	|The hostname or IP address to bind to.|
|**port**|	–|	The port # to listen on.|
|batch-size|	100|	number of event to batch together for send.|
|connect-timeout|	20000|	Amount of time (ms) to allow for the first (handshake) request.|
|request-timeout|	20000|	Amount of time (ms) to allow for requests after the first.|
|reset-connection-interval	|none|	Amount of time (s) before the connection to the next hop is reset. This will force the Avro Sink to reconnect to the next hop. This will allow the sink to connect to hosts behind a hardware load-balancer when news hosts are added without having to restart the agent.（当系统采用硬件方式实现负载均衡时，avro sink重新连接到next hop，如此，能够在不重启flume agent的情况下，利用上新添加的机器）|
|compression-type	|none	|This can be “none” or “deflate”. The compression-type must match the compression-type of matching `AvroSource`（需要与Avro Source的设置相同）|
|compression-level|	6	|The level of compression to compress event. 0 = no compression and 1-9 is compression. The higher the number the more compression|
|ssl	|false|	Set to true to enable SSL for this AvroSink. When configuring SSL, you can optionally set a “truststore”, “truststore-password”, “truststore-type”, and specify whether to “trust-all-certs”.|
|trust-all-certs|	false	|If this is set to true, SSL server certificates for remote servers (Avro Sources) will not be checked. This should NOT be used in production because it makes it easier for an attacker to execute a man-in-the-middle attack and “listen in” on the encrypted connection.|
|truststore	|–|	The path to a custom Java truststore file. Flume uses the certificate authority information in this file to determine whether the remote Avro Source’s SSL authentication credentials should be trusted. If not specified, the default Java JSSE certificate authority files (typically “jssecacerts” or “cacerts” in the Oracle JRE) will be used.|
|truststore-password	|–|	The password for the specified truststore.|
|truststore-type|	JKS	|The type of the Java truststore. This can be “JKS” or other supported Java truststore type.|
|maxIoWorkers	|2 * the number of available processors in the machine|	The maximum number of I/O worker threads. This is configured on the `NettyAvroRpcClient` `NioClientSocketChannelFactory`.|

Example for agent named `a1`:

	a1.channels = c1
	a1.sinks = k1
	a1.sinks.k1.type = avro
	a1.sinks.k1.channel = c1
	a1.sinks.k1.hostname = 10.10.10.10
	a1.sinks.k1.port = 4545

## Thrift Sink

This sink forms one half of Flume’s tiered collection support. Flume events sent to this sink are turned into Thrift events and sent to the configured hostname / port pair. The events are taken from the configured Channel in batches of the configured batch size. Required properties are in bold.

Property Name	Default	Description
channel	–	 
type	–	The component type name, needs to be thrift.
hostname	–	The hostname or IP address to bind to.
port	–	The port # to listen on.
batch-size	100	number of event to batch together for send.
connect-timeout	20000	Amount of time (ms) to allow for the first (handshake) request.
request-timeout	20000	Amount of time (ms) to allow for requests after the first.
connection-reset-interval	none	Amount of time (s) before the connection to the next hop is reset. This will force the Thrift Sink to reconnect to the next hop. This will allow the sink to connect to hosts behind a hardware load-balancer when news hosts are added without having to restart the agent.

Example for agent named a1:

a1.channels = c1
a1.sinks = k1
a1.sinks.k1.type = thrift
a1.sinks.k1.channel = c1
a1.sinks.k1.hostname = 10.10.10.10
a1.sinks.k1.port = 4545

## IRC Sink

The IRC sink takes messages from attached channel and relays those to configured IRC destinations. Required properties are in bold.

Property Name	Default	Description
channel	–	 
type	–	The component type name, needs to be irc
hostname	–	The hostname or IP address to connect to
port	6667	The port number of remote host to connect
nick	–	Nick name
user	–	User name
password	–	User password
chan	–	channel
name	 	 
splitlines	–	(boolean)
splitchars	n	line separator (if you were to enter the default value into the config file, then you would need to escape the backslash, like this: “\n”)

Example for agent named a1:

a1.channels = c1
a1.sinks = k1
a1.sinks.k1.type = irc
a1.sinks.k1.channel = c1
a1.sinks.k1.hostname = irc.yourdomain.com
a1.sinks.k1.nick = flume
a1.sinks.k1.chan = #flume

## File Roll Sink

Stores events on the local filesystem. Required properties are in bold.
（将event存储到local FS上）

|Property Name|	Default|	Description|
|--|--|--|
|**channel**|	–	| |
|**type**|	–|	The component type name, needs to be `file_roll`.|
|**sink.directory**|	–|	The directory where files will be stored|
|sink.rollInterval|	30|	Roll the file every 30 seconds. Specifying 0 will disable rolling and cause all events to be written to a single file.|
|sink.serializer|	TEXT|	Other possible options include `avro_event` or the FQCN of an implementation of `EventSerializer.Builder` interface.|
|batchSize|	100	| |

**notes(ningg)**：FQCN: Fully-Qualified Class Name，全限定类名，包含package的class名称；txn：Transaction，事务。下面几个疑问：

* roll the file？是指对文件重命名存储吗？生成新文件？可以通过源代码进行学习；
* `sink.serializer`什么含义？
* `batchSize`什么含义？

Example for agent named a1:

	a1.channels = c1
	a1.sinks = k1
	a1.sinks.k1.type = file_roll
	a1.sinks.k1.channel = c1
	a1.sinks.k1.sink.directory = /var/log/flume

## Null Sink

Discards all events it receives from the channel. Required properties are in bold.
（丢弃所有event）

|Property Name|	Default|	Description|
|--|--|--|
|**channel**|	–|	 |
|**type**	|–	|The component type name, needs to be `null`.|
|batchSize	|100|	| 

Example for agent named a1:

	a1.channels = c1
	a1.sinks = k1
	a1.sinks.k1.type = null
	a1.sinks.k1.channel = c1

## HBaseSinks

（todo）

## MorphlineSolrSink

（todo）


## ElasticSearchSink

This sink writes data to an [ElasticSearch][ElasticSearch] cluster. By default, events will be written so that the [Kibana][Kibana] graphical interface can display them - just as if [logstash][logstash] wrote them.

The elasticsearch and lucene-core jars required for your environment must be placed in the lib directory of the Apache Flume installation. Elasticsearch requires that the major version of the client JAR match that of the server and that both are running the same minor version of the JVM. SerializationExceptions will appear if this is incorrect. To select the required version first determine the version of elasticsearch and the JVM version the target cluster is running. Then select an elasticsearch client library which matches the major version. A 0.19.x client can talk to a 0.19.x cluster; 0.20.x can talk to 0.20.x and 0.90.x can talk to 0.90.x. Once the elasticsearch version has been determined then read the pom.xml file to determine the correct lucene-core JAR version to use. The Flume agent which is running the ElasticSearchSink should also match the JVM the target cluster is running down to the minor version.

**notes(ningg)**：使用ElasticSearchSink时，几点：

* 依赖的jar包：elasticsearch jar、lucene-core jar、client jar；
* JVM：flume agent与ElasticSearch运行的JVM minor version一致；

如果上述几点不满足，则可能出现`SerializationExceptions`；为解决这一问题，通用步骤：

* determine the version of elasticsearch and JVM version the target cluster is running;
* select an elasticsearch client library which matches the major version;
* read the pom.xml of elasticsearch to determine the correct lucene-core JAR version


Events will be written to a new index every day. The name will be `<indexName>-yyyy-MM-dd` where `<indexName>` is the indexName parameter. The sink will start writing to a new index at midnight UTC.

Events are serialized for elasticsearch by the `ElasticSearchLogStashEventSerializer` by default. This behaviour can be overridden with the `serializer` parameter. This parameter accepts implementations of `org.apache.flume.sink.elasticsearch.ElasticSearchEventSerializer` or `org.apache.flume.sink.elasticsearch.ElasticSearchIndexRequestBuilderFactory`. Implementing `ElasticSearchEventSerializer` is deprecated in favour of the more powerful `ElasticSearchIndexRequestBuilderFactory`.

The type is the `FQCN`: `org.apache.flume.sink.elasticsearch.ElasticSearchSink`

Required properties are in **bold**.


|Property Name|	Default	|Description|
|-----|-----|-----|
|**channel**|	–|	 |
|**type**|	–|	The component type name, needs to be `org.apache.flume.sink.elasticsearch.ElasticSearchSink`|
|**hostNames**|	–	|Comma separated list of `hostname:port`, if the port is not present the default port ‘9300’ will be used|
|indexName|	flume|	The name of the index which the date will be appended to. Example `flume` -> `flume-yyyy-MM-dd`|
|indexType|	logs|	The type to index the document to, defaults to `log`|
|clusterName|	elasticsearch|	Name of the ElasticSearch cluster to connect to|
|batchSize|	100|	Number of events to be written per txn.|
|ttl|	–	|TTL in `days`, when set will cause the expired documents to be deleted automatically, if not set documents will never be automatically deleted. TTL is accepted both in the earlier form of integer only e.g. a1.sinks.k1.ttl = 5 and also with a qualifier ms (millisecond), s (second), m (minute), h (hour), d (day) and w (week). Example a1.sinks.k1.ttl = 5d will set TTL to 5 days. Follow [ttl field][ttl field] for more information.|
|serializer|	`org.apache.flume.sink.elasticsearch.ElasticSearchLogStashEventSerializer`|	The `ElasticSearchIndexRequestBuilderFactory` or `ElasticSearchEventSerializer` to use. Implementations of either class are accepted but `ElasticSearchIndexRequestBuilderFactory` is preferred.|
|serializer.*|	–	|Properties to be passed to the serializer.|


Example for agent named a1:


	a1.channels = c1
	a1.sinks = k1
	a1.sinks.k1.type = elasticsearch
	a1.sinks.k1.hostNames = 127.0.0.1:9200,127.0.0.2:9300
	a1.sinks.k1.indexName = foo_index
	a1.sinks.k1.indexType = bar_type
	a1.sinks.k1.clusterName = foobar_cluster
	a1.sinks.k1.batchSize = 500
	a1.sinks.k1.ttl = 5d
	a1.sinks.k1.serializer = org.apache.flume.sink.elasticsearch.ElasticSearchDynamicSerializer
	a1.sinks.k1.channel = c1







## Custom Sink

A custom sink is your own implementation of the `Sink` interface. A custom sink’s class and its dependencies must be included in the agent’s classpath when starting the Flume agent. The type of the custom sink is its FQCN. Required properties are in bold.
（通过实现Sink接口，可以定制自己的custom；需要在启动Flume agent时，将自定义的Sink和其depedencies添加到classpath中）

|Property Name|	Default|	Description|
|--|--|--|
|channel|	–|	 |
|type|	–|	The component type name, needs to be your `FQCN`|

**notes(ningg)**：FQCN是什么？Fully-Qualified Class Name，全限定类名。

Example for agent named a1:

	a1.channels = c1
	a1.sinks = k1
	a1.sinks.k1.type = org.example.MySink
	a1.sinks.k1.channel = c1

	
	
[logstash]:						https://logstash.net/
[Kibana]:						http://kibana.org/
[ElasticSearch]:				http://www.elasticsearch.org
[ttl field]:					http://www.elasticsearch.org/guide/reference/mapping/ttl-field/




