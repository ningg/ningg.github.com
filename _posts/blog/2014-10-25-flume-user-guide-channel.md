---
layout: post
title: Flume 1.5.0.1 User Guide：Flume Channels
description: Flume中重要组件channel的详细介绍
categories: flume big-data
---

Channels are the repositories where the events are staged on a agent. Source adds the events and Sink removes it.
（agent中events存储在channels中：source将events添加到channels，sink从channels中读取events）

##Memory Channel

The events are stored in an in-memory queue with configurable max size. It’s ideal for flows that need higher throughput and are prepared to lose the staged data in the event of a agent failures. Required properties are in bold.
（events被储存在in-memory queue中，queue的大小可以设定；适用场景：高吞吐量、在agent fail时允许lose data。）

|Property Name|	Default|	Description|
|--|--|--|
|**type**|	–|	The component type name, needs to be `memory`|
|capacity|	100	|The maximum number of events stored in the channel|
|transactionCapacity|	100	|The maximum number of events the channel will take from a source or give to a sink per transaction|
|keep-alive|	3	|Timeout in seconds for adding or removing an event|
|byteCapacityBufferPercentage|	20|	Defines the percent of buffer between byteCapacity and the estimated total size of all events in the channel, to account for data in headers. See below.**（什么意思？）**|
|byteCapacity|	see description|	Maximum total bytes of memory allowed as a sum of all events in this channel. The implementation only counts the Event `body`, which is the reason for providing the `byteCapacityBufferPercentage` configuration parameter as well. Defaults to a computed value equal to 80% of the maximum memory available to the JVM (i.e. 80% of the -Xmx value passed on the command line). Note that if you have multiple memory channels on a single JVM, and they happen to hold the same physical events (i.e. if you are using a replicating channel selector from a single source) then those event sizes may be double-counted for channel byteCapacity purposes. Setting this value to 0 will cause this value to fall back to a hard internal limit of about 200 GB.（设置为0，则参数取值为a hard internal limit，通常为200GB；）|

**notes(ningg)**：`byteCapacityBufferPercentage`参数的含义？event是由header和body构成的，参数`byteCapacity`约束的只是`body`，因此，新增了`byteCapacityBufferPercentage`参数，表示`header`的占用空间的的比例。


Example for agent named a1:

	a1.channels = c1
	a1.channels.c1.type = memory
	a1.channels.c1.capacity = 10000
	a1.channels.c1.transactionCapacity = 10000
	a1.channels.c1.byteCapacityBufferPercentage = 20
	a1.channels.c1.byteCapacity = 800000

##JDBC Channel

The events are stored in a persistent storage that’s backed by a database. The JDBC channel currently supports embedded Derby. This is a durable channel that’s ideal for flows where recoverability is important. Required properties are in bold.
（将events持久化存储在database中，当前JDBC channel支持embeded Derby；适用于数据流可恢复性要求较高的场景。）

|Property Name|	Default|	Description|
|--|--|--|
|**type**	|–|	The component type name, needs to be jdbc|
|db.type	|DERBY|	Database vendor, needs to be DERBY.|
|driver.class|	org.apache.derby.jdbc.EmbeddedDriver|	Class for vendor’s JDBC driver|
|driver.url	|(constructed from other properties)|	JDBC connection URL|
|db.username	|“sa”|	User id for db connection|
|db.password|	–|	password for db connection|
|connection.properties.file	|–|	JDBC Connection property file path|
|create.schema|	true|	If true, then creates db schema if not there|
|create.index|	true|	Create indexes to speed up lookups|
|create.foreignkey|	true|	 |
|transaction.isolation|	“READ_COMMITTED”|	Isolation level for db session READ_UNCOMMITTED, READ_COMMITTED, SERIALIZABLE, REPEATABLE_READ|
|maximum.connections|	10|	Max connections allowed to db|
|maximum.capacity|	0 (unlimited)|	Max number of events in the channel|
|sysprop.*|	 |	DB Vendor specific properties|
|sysprop.user.home|	 |	Home path to store embedded Derby database|

Example for agent named a1:

	a1.channels = c1
	a1.channels.c1.type = jdbc

##File Channel

（todo）

##Spillable Memory Channel

The events are stored in an in-memory queue and on disk. The in-memory queue serves as the primary store and the disk as overflow. The disk store is managed using an embedded File channel. When the in-memory queue is full, additional incoming events are stored in the file channel. This channel is ideal for flows that need high throughput of memory channel during normal operation, but at the same time need the larger capacity of the file channel for better tolerance of intermittent sink side outages or drop in drain rates. The throughput will reduce approximately to file channel speeds during such abnormal situations. In case of an agent crash or restart, only the events stored on disk are recovered when the agent comes online. **This channel is currently experimental and not recommended for use in production**.

**notes(ningg)**：Spillable Memory Channel当前还是试验阶段，不推荐在生产环境中使用。


##Pseudo Transaction Channel

Warning The Pseudo Transaction Channel is only for unit testing purposes and is NOT meant for production use.
Required properties are in bold.
（**Warning**：Pseudo Transaction Channel，当前用于unit testing；不要用于生产环境）

|Property Name|	Default|	Description|
|--|--|--|
|**type**	|–|	The component type name, needs to be `org.apache.flume.channel.PseudoTxnMemoryChannel`|
|capacity|	50|	The max number of events stored in the channel|
|keep-alive|	3|	Timeout in seconds for adding or removing an event|

##Custom Channel

A custom channel is your own implementation of the Channel interface. A custom channel’s class and its dependencies must be included in the agent’s classpath when starting the Flume agent. The type of the custom channel is its FQCN. Required properties are in bold.

|Property Name|	Default	|Description|
|--|--|--|
|**type**|	–|	The component type name, needs to be a `FQCN`|

Example for agent named a1:

	a1.channels = c1
	a1.channels.c1.type = org.example.MyChannel














