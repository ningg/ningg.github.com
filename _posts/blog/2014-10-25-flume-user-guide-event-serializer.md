---
layout: post
title: Flume 1.5.0.1 User Guide：Event Serializers
description: Flume中重要组件Event Serializers的详细介绍
categories: flume
---


The `file_roll sink` and the `hdfs sink` both support the `EventSerializer` interface. Details of the `EventSerializers` that ship with Flume are provided below.
（Event serializer，事件序列化，）

##Body Text Serializer

Alias: text. This interceptor writes the body of the event to an output stream without any transformation or modification. The event headers are ignored. Configuration options are as follows:

Property Name	Default	Description
appendNewline	true	Whether a newline will be appended to each event at write time. The default of true assumes that events do not contain newlines, for legacy reasons.
Example for agent named a1:

a1.sinks = k1
a1.sinks.k1.type = file_roll
a1.sinks.k1.channel = c1
a1.sinks.k1.sink.directory = /var/log/flume
a1.sinks.k1.sink.serializer = text
a1.sinks.k1.sink.serializer.appendNewline = false
Avro Event Serializer

Alias: avro_event. This interceptor serializes Flume events into an Avro container file. The schema used is the same schema used for Flume events in the Avro RPC mechanism. This serializers inherits from the AbstractAvroEventSerializer class. Configuration options are as follows:

Property Name	Default	Description
syncIntervalBytes	2048000	Avro sync interval, in approximate bytes.
compressionCodec	null	Avro compression codec. For supported codecs, see Avro’s CodecFactory docs.
Example for agent named a1:

a1.sinks.k1.type = hdfs
a1.sinks.k1.channel = c1
a1.sinks.k1.hdfs.path = /flume/events/%y-%m-%d/%H%M/%S
a1.sinks.k1.serializer = avro_event
a1.sinks.k1.serializer.compressionCodec = snappy










