---
layout: post
title: Flume 1.5.0.1 User Guide：Monitoring
description: Flume中Monitoring部分的详细介绍
categories: flume
---

Monitoring in Flume is still a work in progress. Changes can happen very often. Several Flume components report metrics to the JMX platform MBean server. These metrics can be queried using Jconsole.
（当前Flume的Monitoring最终方案没有敲定，期间会多次改版，注意关注JIRA；另，几个Flume components会向JMX platform MBean server提交运行参数，可以通过JMX获取这几个Flume components的运行状态。）

**notes(ningg)**：JVM上两个东西，什么用途？**JMX platform**、**MBean server**。

## Ganglia Reporting

Flume can also report these metrics to Ganglia 3 or Ganglia 3.1 metanodes. To report metrics to Ganglia, a flume agent must be started with this support. The Flume agent has to be started by passing in the following parameters as system properties prefixed by flume.monitoring., and can be specified in the `flume-env.sh`:

| Property Name| 	Default| 	Description| 
|--|--|--|
| **type**| 	–	| The component type name, has to be `ganglia`| 
| **hosts**	| –	| Comma-separated list of `hostname:port` of Ganglia servers| 
| pollFrequency| 	60| 	Time, in seconds, between consecutive reporting to Ganglia server| 
| isGanglia3| 	false| 	Ganglia server version is 3. By default, Flume sends in Ganglia 3.1 format| 

We can start Flume with Ganglia support as follows:

	$ bin/flume-ng agent --conf-file example.conf --name a1 -Dflume.monitoring.type=ganglia -Dflume.monitoring.hosts=com.example:1234,com.example2:5455

**notes(ningg)**：在`conf/flume-env.sh`文件中配置Ganglia监控，具体配置选项：

	# Flume Monitoring: Ganglia Monitoring
	JAVA_OPTS="-Dflume.monitoring.type=ganglia -Dflume.monitoring.hosts=239.2.11.166:8649"


## JSON Reporting

Flume can also report metrics in a JSON format. To enable reporting in JSON format, Flume hosts a Web server on a configurable port. Flume reports metrics in the following JSON format:

	{
	"typeName1.componentName1" : {"metric1" : "metricValue1", "metric2" : "metricValue2"},
	"typeName2.componentName2" : {"metric3" : "metricValue3", "metric4" : "metricValue4"}
	}
	
Here is an example:

	{
	"CHANNEL.fileChannel":{"EventPutSuccessCount":"468085",
						  "Type":"CHANNEL",
						  "StopTime":"0",
						  "EventPutAttemptCount":"468086",
						  "ChannelSize":"233428",
						  "StartTime":"1344882233070",
						  "EventTakeSuccessCount":"458200",
						  "ChannelCapacity":"600000",
						  "EventTakeAttemptCount":"458288"},
	"CHANNEL.memChannel":{"EventPutSuccessCount":"22948908",
					   "Type":"CHANNEL",
					   "StopTime":"0",
					   "EventPutAttemptCount":"22948908",
					   "ChannelSize":"5",
					   "StartTime":"1344882209413",
					   "EventTakeSuccessCount":"22948900",
					   "ChannelCapacity":"100",
					   "EventTakeAttemptCount":"22948908"}
	}
	
|Property Name	|Default|	Description|
|--|--|
|**type**	|–	|The component type name, has to be `http`|
|port	|41414	|The port to start the server on.|

We can start Flume with JSON Reporting support as follows:

	$ bin/flume-ng agent --conf-file example.conf --name a1 -Dflume.monitoring.type=http -Dflume.monitoring.port=34545
	
Metrics will then be available at `http://<hostname>:<port>/metrics` webpage. Custom components can report metrics as mentioned in the Ganglia section above.

## Custom Reporting

It is possible to report metrics to other systems by writing servers that do the reporting. Any reporting class has to implement the interface, `org.apache.flume.instrumentation.MonitorService`. Such a class can be used the same way the `GangliaServer` is used for reporting. They can poll the platform mbean server to poll the mbeans for metrics. For example, if an HTTP monitoring service called `HTTPReporting` can be used as follows:

**notes(ningg)**：MBean是什么？其中可以获取metrics？

	$ bin/flume-ng agent --conf-file example.conf --name a1 \
	-Dflume.monitoring.type=com.example.reporting.HTTPReporting \
	-Dflume.monitoring.node=com.example:332
	
|Property Name|	Default	Description|
|--|--|
|type|	–	|The component type name, has to be FQCN|


## Reporting metrics from custom components

Any custom flume components should inherit from the `org.apache.flume.instrumentation.MonitoredCounterGroup` class. The class should then provide `getter methods` for each of the metrics it exposes. See the code below. The MonitoredCounterGroup expects a list of attributes whose metrics are exposed by this class. As of now, this class only supports exposing metrics as long values.

	public class SinkCounter extends MonitoredCounterGroup implements
		SinkCounterMBean {

	  private static final String COUNTER_CONNECTION_CREATED =
		"sink.connection.creation.count";

	  private static final String COUNTER_CONNECTION_CLOSED =
		"sink.connection.closed.count";

	  private static final String COUNTER_CONNECTION_FAILED =
		"sink.connection.failed.count";

	  private static final String COUNTER_BATCH_EMPTY =
		"sink.batch.empty";

	  private static final String COUNTER_BATCH_UNDERFLOW =
		  "sink.batch.underflow";

	  private static final String COUNTER_BATCH_COMPLETE =
		"sink.batch.complete";

	  private static final String COUNTER_EVENT_DRAIN_ATTEMPT =
		"sink.event.drain.attempt";

	  private static final String COUNTER_EVENT_DRAIN_SUCCESS =
		"sink.event.drain.sucess";

	  private static final String[] ATTRIBUTES = {
		COUNTER_CONNECTION_CREATED, COUNTER_CONNECTION_CLOSED,
		COUNTER_CONNECTION_FAILED, COUNTER_BATCH_EMPTY,
		COUNTER_BATCH_UNDERFLOW, COUNTER_BATCH_COMPLETE,
		COUNTER_EVENT_DRAIN_ATTEMPT, COUNTER_EVENT_DRAIN_SUCCESS
	  };


	  public SinkCounter(String name) {
		super(MonitoredCounterGroup.Type.SINK, name, ATTRIBUTES);
	  }

	  @Override
	  public long getConnectionCreatedCount() {
		return get(COUNTER_CONNECTION_CREATED);
	  }

	  public long incrementConnectionCreatedCount() {
		return increment(COUNTER_CONNECTION_CREATED);
	  }

	}

