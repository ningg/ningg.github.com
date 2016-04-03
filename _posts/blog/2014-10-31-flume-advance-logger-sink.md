---
layout: post
title: Flume下插件方式实现Advanced Logger Sink
description: Flume自带的Logger sink常用于直接在console上输出event的header和body，这对test和debug很重要，但body默认只truncate 16B，无法全部展示
categories: flume
---

## 背景

Flume自带的Logger sink常用于直接在console上输出event的header和body，这对test和debug很重要，但body默认只truncate 16B，无法全部展示，这对test造成很大影响，怎么办？自己实现一个Adavanced Logger sink：完全输出整个event，这样就便利多了。


## Flume中Logger Sink

在[编译flume：使用eclipse查看flume源码](/build-flume)中，已经介绍了如何在Eclipse下查看Flume的源代码，通过查看`LoggerSink`源码发现：

	// LoggerSink.java
	logger.info("Event: " + EventHelper.dumpEvent(event));
	...
	
	// EventHelper.java
	private static final int DEFAULT_MAX_BYTES = 16;
	
	public static String dumpEvent(Event event) {
		return dumpEvent(event, DEFAULT_MAX_BYTES);
	}
	
通过上面的Flume源码片段可知，Logger Sink默认限制了event的大小为16字节，这样，只需要实现一个与Logger Sink基本一致，但不对event设限制的sink就好了。
	
**notes(ningg)**：编译flume时，直接将源码当作existing maven project导入，行不行？Flume的源码全是java写的吗？还有个问题：如果使用eclipse来进行源代码的开发，最终通过git方式向repository中提交代码时，会夹带.class文件吗？

## 自定义Sink

![](/images/flume-advance-logger-sink/advanced-logger-sink.png)

在`flume-ng-core`工程的`src/main/java`目录下，新建package：`com.github.ningg`，然后新建class：`AdvancedLoggerSink`，内容如下：

	package com.github.ningg;

	import org.apache.flume.Channel;
	import org.apache.flume.Context;
	import org.apache.flume.Event;
	import org.apache.flume.EventDeliveryException;
	import org.apache.flume.Transaction;
	import org.apache.flume.conf.Configurable;
	import org.apache.flume.event.EventHelper;
	import org.apache.flume.sink.AbstractSink;
	import org.apache.flume.sink.LoggerSink;
	import org.slf4j.Logger;
	import org.slf4j.LoggerFactory;

	public class AdvancedLoggerSink extends AbstractSink implements Configurable {

		private static final Logger logger = LoggerFactory
				.getLogger(LoggerSink.class);

		private static final int DEFAULT_MAX_BYTES = 16;
		private int maxBytes = DEFAULT_MAX_BYTES;
		
		@Override
		public void configure(Context context) {
			maxBytes = context.getInteger("maxBytes", DEFAULT_MAX_BYTES);
			logger.debug(this.getName() + " maximum bytes set to " + String.valueOf(maxBytes));
		}
		
		@Override
		public Status process() throws EventDeliveryException {
			Status result = Status.READY;
			Channel channel = getChannel();
			Transaction transaction = channel.getTransaction();
			Event event = null;

			try {
				transaction.begin();
				event = channel.take();

				if (event != null) {
					if (logger.isInfoEnabled()) {
						// edit this line, so you can change the output formater.
						logger.info("Event: " + EventHelper.dumpEvent(event, maxBytes));
					}
				} else {
					// No event found, request back-off semantics from the sink
					// runner
					result = Status.BACKOFF;
				}
				transaction.commit();
			} catch (Exception ex) {
				transaction.rollback();
				throw new EventDeliveryException("Failed to log event: " + event,
						ex);
			} finally {
				transaction.close();
			}

			return result;
		}

	}

接下来，将整个`com.github.ningg`package导出为jar包：`advancedLoggerSink.jar`；根据Flume官网的建议，将此jar包上传到`$FLUME_HOME/plugins.d`目录下，具体：

	plugins.d/advanced-logger-sink/lib/advancedLoggerSink.jar

为了测试效果，在`$FLUME_HOME/conf`下新建`advancedLoggerSink.conf`文件:

	agent.sources = net
	agent.sinks = loggerSink
	agent.channels = memoryChannel
	
	# For each one of the sources, the type is defined
	agent.sources.net.type = netcat
	agent.sources.net.bind = localhost
	agent.sources.net.port = 44444

	# Each sink's type must be defined
	agent.sinks.loggerSink.type = com.github.ningg.AdvancedLoggerSink
	agent.sinks.loggerSink.maxBytes = 100
	
	# Each channel's type is defined.
	agent.channels.memoryChannel.type = memory
	agent.channels.memoryChannel.capacity = 100
	
	
	agent.sources.net.channels = memoryChannel
	agent.sinks.loggerSink.channel = memoryChannel

回到`$FLUME_HOME`目录下，执行如下命令：
	
	bin/flume-ng agent --conf conf --conf-file conf/advancedLoggerSink.conf --name agent -Dflume.root.logger=INFO,console

当页面显示如下字样，表示flume启动成功：

	Created serverSocket:sun.nio.ch.ServerSocketChannelImpl[/127.0.0.1:44444]

另开一个窗口，在当前服务器上，执行命令：`telnet localhost 44444`，并且输入如下内容：

	Now I'm testing the Advanced Logger Sink

则，AdavancedSinkLogger的输出内容如下：

	[INFO - com.github.ningg.AdvancedLoggerSink.process(AdvancedLoggerSink.java:44)] Event: { headers:{} 
	   body: 4E 6F 77 20 49 27 6D 20 74 65 73 74 69 6E 67 20 Now I'm testing
	00000010 74 68 65 20 41 64 76 61 6E 63 65 64 20 4C 6F 67 the Advanced Log
	00000020 67 65 72 20 53 69 6E 6B 0D                      ger Sink. }

AdvancedLoggerSink的输出格式：每行输出16个byte，左侧是字母对应的ASCII码，右侧是字母本身。备注：如果希望定制上述的输出格式，可以直接新建类来替代`EventHelper.dumpEvent(event, maxBytes)`。

## 参考来源

* [Logger Sink truncate Event body][Logger Sink truncate Event body]
* [FLUME-2246][FLUME-2246]

## 杂谈

本文写完之后，我发现了：[FLUME-2246][FLUME-2246]，Ou，已经有人在Flume官网上讨论并解决了这个问题，看来不会使用Flume官网不行呀，之前自己阅读标记过[如何参与开源项目](/how-to-contribute-open-source-project)， 但是没有实际尝试参与。个人心里一个想法：玩开源的东西，要参与到开源社区中，你的问题开源社区早已涉及，只不过有些扩展功能重要程度低，虽然已解决，但并没有并入发行版本中。

另，说明一点啊：遇到问题，自己先想思路，再去社区找答案，也是个好方法。

[NingG]:    http://ningg.github.com  "NingG"



[Logger Sink truncate Event body]:		http://stackoverflow.com/questions/20189437/flume-is-truncating-characters-when-i-use-the-source-type-as-logger-it-just-s
[FLUME-2246]:	https://issues.apache.org/jira/browse/FLUME-2246
