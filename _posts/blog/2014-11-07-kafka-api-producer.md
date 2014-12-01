---
layout: post
title: Kafka 0.8.1：Producer API and Producer Configs
description: Kafka是一个消息队列，那就要允许往其中存入数据，存入数据的这个实体，就是Kafka的Producer
category: kafka
---

##背景

最近在做Flume与Kafka的整合，其中用到了一个工程：[flume-ng-kafka-sink][flume-ng-kafka-sink]，本质上就是Flume的一个插件：Kafka sink。遇到一个问题：Kafka sink通过设置kafak broker的`ip:port`来寻找broker，那就有一个问题，如果设置连接的kafka broker 宕掉了，flume的数据是不是就送不出去了？

##Producer

开始介绍Producer之前，说个小问题：上面**背景**中一直在说Flume的Sink：Kafka Sink，那与Kafka producer什么关系呢？为什么这次标题是**Kafka Producer**，而丝毫未提**Flume Sink**？这个问题很好，说明读者在思考，大概说几点：

* Flume架构中有Sink，是用来将Flume收集到的数据送出去的；Flume下的Kafka Sink插件，在Flume看来，就是个Sink；
* Kafka架构中有Producer，是用来向Kafka broker中送入数据的；Flume下的Kafka Sink插件，在Kafka看来，就是个Producer；

此次，主要站在Kafka的角度来看一个Producer可以进行的配置。

###Kafka Producer API

下面是`kafka.javaapi.producer.Producer`类的java API，实际上这个类是scala编写的，

	/**
	 *  V: type of the message
	 *  K: type of the optional key associated with the message
	 */
	 
	class kafka.javaapi.producer.Producer<K,V> {

	  public Producer(ProducerConfig config);

	  /**
	   * Sends the data to a single topic, partitioned by key, using either the
	   * synchronous or the asynchronous producer
	   * @param message the producer data object that encapsulates the topic, key and message data
	   */
	  public void send(KeyedMessage<K,V> message);

	  /**
	   * Use this API to send data to multiple topics
	   * @param messages list of producer data objects that encapsulate the topic, key and message data
	   */
	  public void send(List<KeyedMessage<K,V>> messages);

	  /**
	   * Close API to close the producer pool connections to all Kafka brokers.
	   */
	  public void close();
	}

具体如何使用上述Producer API，可参考[0.8.0 Producer Example][0.8.0 Producer Example]。

###0.8.0 Producer Example

研究要深入，上面提到的[0.8.0 Producer Example][0.8.0 Producer Example]，下面简要介绍一下。

The Producer class is used to create new messages for a specific Topic and optional Partition.

If using Java you need to include a few packages for the Producer and supporting classes:

	import kafka.javaapi.producer.Producer;
	import kafka.producer.KeyedMessage;
	import kafka.producer.ProducerConfig;

The first step in your code is to define properties for how the Producer finds the cluster, serializes the messages and if appropriate directs the message to a specific Partition.

代码本质体现的是逻辑，首先需要确定几个问题：

* Producer如何找到Kafka Cluster；
* message传输的格式；（serialize，序列化）
* 如何将message存入指定的Partition中；

These properties are defined in the standard Java Properties object:

	Properties props = new Properties();
	 
	props.put("metadata.broker.list", "broker1:9092,broker2:9092");
	props.put("serializer.class", "kafka.serializer.StringEncoder");
	props.put("partitioner.class", "example.producer.SimplePartitioner");
	props.put("request.required.acks", "1");
	 
	ProducerConfig config = new ProducerConfig(props);

The first property, “metadata.broker.list” defines where the Producer can find a one or more Brokers to determine the Leader for each topic. This does not need to be the full set of Brokers in your cluster but should include at least two in case the first Broker is not available. No need to worry about figuring out which Broker is the leader for the topic (and partition), the Producer knows how to connect to the Broker and ask for the meta data then connect to the correct Broker.

**第一项参数**`metadata.broker.list`，用于配置可用的broker列表，可以只配置一个broker，不过建议最好至少配置2个broker，这样即使有一个broker宕机了，另一个也能及时接替工作；这些broker中，也不用指定不同topic的leader，因为Producer会主动连接Broker并且请求到meta数据，然后连接到topic的leader。

The second property “serializer.class” defines what Serializer to use when preparing the message for transmission to the Broker. In our example we use a simple String encoder provided as part of Kafka. Note that the encoder must accept the same type as defined in the KeyedMessage object in the next step.

**第二项参数**`serializer.class`，设定了将message从Producer发送到Broker的序列化方式。

**notes(ningg)**：“Note that the encoder must accept the same type as defined in the KeyedMessage object in the next step.” 什么含义？ `KeyedMessage`。

It is possible to change the Serializer for the Key (see below) of the message by defining "key.serializer.class" appropriately. By default it is set to the same value as "serializer.class".

参数`key.serializer.class`用于设置key序列化的方法，key将在序列化之后，与message一同从Producer发送到Broker；`key.serializer.class`的默认值与`serializer.class`相同。

**notes(ningg)**：Kafka是按照key进行partition的，每个message绑定的key也是需要传输到broker的，传输过程中也需要进行序列化，


The third property  "partitioner.class" defines what class to use to determine which Partition in the Topic the message is to be sent to. This is optional, but for any non-trivial implementation you are going to want to implement a partitioning scheme. More about the implementation of this class later. If you include a value for the key but haven't defined a partitioner.class Kafka will use the default partitioner. If the key is null, then the Producer will assign the message to a random Partition.

**第三项参数**`partitioner.class`用于设定message与Partition的映射关系，简单来说，每个message都发送给broker的某个对应的Topic，但message真正存储对应的是Topic下的partition，那么，参数`partitioner.class`就是用于设定message--partition之间映射关系的。

The last property "request.required.acks" tells Kafka that you want your Producer to require an acknowledgement from the Broker that the message was received. Without this setting the Producer will 'fire and forget' possibly leading to data loss. Additional information can be found [here][Kafka Configuration].

**最后一项参数**`request.required.acks`，设定Broker在接收到message之后，是否返回一个确认信息（ack）。如果没有这个信息，那么很有可能`fire and forget`并且丢失数据。更多Kafka的相关配置信息，参考：[Kafka Configuration][Kafka Configuration]。

**notes(ningg)**：有个问题，即使Broker在接收到message之后，返回了ack信息，那Producer提供了重发机制吗？还是Producer只是进行登记？

Next you define the Producer object itself:

	Producer<String, String> producer = new Producer<String, String>(config);

Note that the Producer is a Java Generic and you need to tell it the type of two parameters. The first is the type of the Partition key, the second the type of the message. In this example they are both Strings, which also matches to what we defined in the Properties above.

`Producer`是一个Java Generic（泛型），需要输入两个参数，`<String, String>`，第一个参数是Partition key的类型，第二个是message的类型

**notes(ningg)**：java中Generic的用法、注意事项有哪些？上面说的Partition key，到底指什么？是properties中的属性和属性值吗？不是的，查看源代码，Partition key就是按照key进行partition的key。


Now build your message:

	Random rnd = new Random();
	long runtime = new Date().getTime();
	String ip = “192.168.2.” + rnd.nextInt(255);
	String msg = runtime + “,www.example.com,” + ip;
 
In this example we are faking a message for a website visit by IP address. First part of the comma-separated message is the timestamp of the event, the second is the website and the third is the IP address of the requester. We use the Java Random class here to make the last octet of the IP vary so we can see how Partitioning works.（上面`msg`中是伪造的一个网站访问记录）


Finally write the message to the Broker:

	KeyedMessage<String, String> data = new KeyedMessage<String, String>("page_visits", ip, msg);
 
	producer.send(data);
	
The “page_visits” is the Topic to write to. Here we are passing the IP as the partition key. Note that if you do not include a key, even if you've defined a partitioner class, Kafka will assign the message to a random partition.

`KeyedMessage<String, String>(topic, message)`或者`KeyedMessage<String, String>(topic, key, message)`，如果没输入key，那么即使设定了`partitioner.class`也不会对message分发到相应partition的，原因很简单，因为真的没有key。

Full Source:

	import java.util.*;
	 
	import kafka.javaapi.producer.Producer;
	import kafka.producer.KeyedMessage;
	import kafka.producer.ProducerConfig;
	 
	public class TestProducer {
		public static void main(String[] args) {
			long events = Long.parseLong(args[0]);
			Random rnd = new Random();
	 
			Properties props = new Properties();
			props.put("metadata.broker.list", "broker1:9092,broker2:9092 ");
			props.put("serializer.class", "kafka.serializer.StringEncoder");
			props.put("partitioner.class", "example.producer.SimplePartitioner");
			props.put("request.required.acks", "1");
	 
			ProducerConfig config = new ProducerConfig(props);
	 
			Producer<String, String> producer = new Producer<String, String>(config);
	 
			for (long nEvents = 0; nEvents < events; nEvents++) { 
				   long runtime = new Date().getTime();  
				   String ip = “192.168.2.” + rnd.nextInt(255); 
				   String msg = runtime + “,www.example.com,” + ip; 
				   KeyedMessage<String, String> data = new KeyedMessage<String, String>("page_visits", ip, msg);
				   producer.send(data);
			}
			producer.close();
		}
	}
 
Partitioning Code:

	import kafka.producer.Partitioner;
	import kafka.utils.VerifiableProperties;
	 
	public class SimplePartitioner implements Partitioner {
		public SimplePartitioner (VerifiableProperties props) {
	 
		}
	 
		public int partition(Object key, int a_numPartitions) {
			int partition = 0;
			String stringKey = (String) key;
			int offset = stringKey.lastIndexOf('.');
			if (offset > 0) {
			   partition = Integer.parseInt( stringKey.substring(offset+1)) % a_numPartitions;
			}
		   return partition;
	  }
	 
	}

The logic takes the key, which we expect to be the IP address, finds the last octet and does a modulo operation on the number of partitions defined within Kafka for the topic. The benefit of this partitioning logic is all web visits from the same source IP end up in the same Partition. Of course so do other IPs, but your consumer logic will need to know how to handle that.
（将有时间顺序的message放到同一个partition中）

Before running this, make sure you have created the Topic page_visits. From the command line:

	bin/kafka-create-topic.sh --topic page_visits --replica 3 --zookeeper localhost:2181 --partition 5

Make sure you include a `--partition` option so you create more than one.
（要使用`--partition`来创建多个partition，否则可能只有一个）

Now compile and run your Producer and data will be written to Kafka.


To confirm you have data, use the command line tool to see what was written:

	bin/kafka-console-consumer.sh --zookeeper localhost:2181 --topic page_visits --from-beginning

利用Maven进行Producer开发时，需要添加的POM配置如下：

	<dependency>
	  <groupId>org.apache.kafka</groupId>
	  <artifactId>kafka_2.9.2</artifactId>
	  <version>0.8.1.1</version>
	  <scope>compile</scope>
	  <exclusions>
		<exclusion>
		  <artifactId>jmxri</artifactId>
		  <groupId>com.sun.jmx</groupId>
		</exclusion>
		<exclusion>
		  <artifactId>jms</artifactId>
		  <groupId>javax.jms</groupId>
		</exclusion>
		<exclusion>
		  <artifactId>jmxtools</artifactId>
		  <groupId>com.sun.jdmk</groupId>
		</exclusion>
	  </exclusions>
	</dependency>




###几个情况

**思考1**：Kafka 0.7.2版本中，直接在Producer中配置Zookeeper，Producer通过Zookeeper来获知Broker的位置，简单来说，应用与Kafka之间是解耦的，可以在不修改Producer信息的情况下，动态增减Broker。

当前，通过`metadata.broker.list`来设置broker的列表，有几个问题，稍微梳理一下：

* 如果只在`metadata.broker.list`中配置一个broker，那么Producer能够识别出其他broker吗？
* 如果能够识别出未配置的broker，那么，只配置一个broker不就行了吗？
* 如果不能识别出未配置的broker，那Kafka集群中动态增加了broker，岂不是需要重新启动flume？（因为`metadata.broker.list`实际上是flume的配置，要更新这一参数配置，就需要重启flume）

**思考2**：如果network interrupt，producer会如何动作？记录log？还是抛出异常？

**思考3**：如果某一个flume挂了，能否能自动重启？


##Producer配置的详细参数

针对Kafka 0.8.1版本，这一部分介绍的Producer配置信息，主要参考两个地方：


* [Kafka Configuration][Kafka Configuration]
* [Kafka Producer Config][Kafka Producer Config]



Essential configuration properties for the producer include:（Producer必须的参数有几个，如下）

* metadata.broker.list，broker列表；
* request.required.acks，broker收到producer发来的message后，是否ack？
* producer.type，这个什么滴干活？
* serializer.class，message从producer发往broker的过程中，需要序列化；

具体参数如下：

* Property
	* Default
	* Description

* metadata.broker.list
	* null
	* This is for bootstrapping and the producer will only use it for getting metadata (topics, partitions and replicas). The socket connections for sending the actual data will be established based on the broker information returned in the metadata. The format is host1:port1,host2:port2, and the list can be a subset of brokers or a VIP pointing to a subset of brokers.

* request.required.acks
	* 0	
	* This value controls when a produce request is considered completed. Specifically, how many other brokers must have committed the data to their log and acknowledged this to the leader? Typical values are
	* 0, which means that the producer never waits for an acknowledgement from the broker (the same behavior as 0.7). This option provides the lowest latency but the weakest durability guarantees (some data will be lost when a server fails).（不等待ack信息）
	* 1, which means that the producer gets an acknowledgement after the leader replica has received the data. This option provides better durability as the client waits until the server acknowledges the request as successful (only messages that were written to the now-dead leader but not yet replicated will be lost).（leader完成数据写入）
	* -1, which means that the producer gets an acknowledgement after all in-sync replicas have received the data. This option provides the best durability, we guarantee that no messages will be lost as long as at least one in sync replica remains.（所有replica都完成数据写入）

* request.timeout.ms
	* 10000
	* The amount of time the broker will wait trying to meet the `request.required.acks` requirement before sending back an error to the client.（broker收到producer发来的message后，如果需要返回ack信息，那这个参数设定了broker返回ack信息的时间限制，如果超过这个时间，则broker向producer返回一个error信息）

* producer.type	
	* sync
	* This parameter specifies whether the messages are sent asynchronously in a background thread. Valid values are (1) `async` for asynchronous send and (2) `sync` for synchronous send. By setting the producer to async we allow batching together of requests (which is great for throughput) but open the possibility of a failure of the client machine dropping unsent data.（producer发送message的方式：同步、异步；设置为异步时，producer处理的吞吐量会提升，但可能丢失数据）

* serializer.class	
	* kafka.serializer.DefaultEncoder
	* The serializer class for messages. The default encoder takes a `byte[]` and returns the same `byte[]`.（message的序列化方法，默认是`byte[]`）

* key.serializer.class
	* defaults to the same as for messages if nothing is given.
	* The serializer class for keys .

* partitioner.class
	* kafka.producer.DefaultPartitioner（The default partitioner is based on the hash of the key.）
	* The partitioner class for partitioning messages amongst sub-topics. （将message放入哪个partition中）

* compression.codec	
	* none	
	* This parameter allows you to specify the compression codec for all data generated by this producer. Valid values are "none", "gzip" and "snappy".（producer向broker发送的信息，是否进行压缩，包含：key、message信息。）

* compressed.topics	
	* null
	* This parameter allows you to set whether compression should be turned on for particular topics. If the compression codec is anything other than NoCompressionCodec, enable compression only for specified topics if any. If the list of compressed topics is empty, then enable the specified compression codec for all topics. If the compression codec is NoCompressionCodec, compression is disabled for all topics（当开启`compression.codec`时，通过设置`compressed.topics`，设置只针对某些特定的topic进行压缩，默认，对所有的topic都进行压缩）

* message.send.max.retries
	* 3	
	* This property will cause the producer to automatically retry a failed send request. This property specifies the number of retries when such failures occur. Note that setting a non-zero value here can lead to duplicates in the case of network errors that cause a message to be sent but the acknowledgement to be lost.（当producer发送message失败后，尝试重新发送的次数；**特别说明**：如果message发送成功，但broker返回的ack信息丢失时，会有message重发，即，此处有消息重复发送）

* retry.backoff.ms
	* 100
	* Before each retry, the producer refreshes the metadata of relevant topics to see if a new leader has been elected. Since leader election takes a bit of time, this property specifies the amount of time that the producer waits before refreshing the metadata.（producer在进行重新发送message之前，都会refresh metadata，主要目标，查看是否更新了topic的leader；因为leader election需要一段时间，因此，在refresh metadata之前，需要等待一段时间，`retry.backoff.ms`参数设置的就是等待的时间，等待选出新的topic leader）

* topic.metadata.refresh.interval.ms	
	* 600 * 1000	
	* The producer generally refreshes the topic metadata from brokers when there is a failure (partition missing, leader not available...). It will also poll regularly (default: every 10min so 600000ms). （正常情况，多长时间刷新一次broker metadata，即，刷新间隔）
	* If you set this to a `negative value`, metadata will only get refreshed on failure. （`<0`时，仅当发送message失败时，才刷新）
	* If you set this to zero, the metadata will get refreshed after each message sent (not recommended). （`0`，每次发送完message之后，都刷新，**不推荐**）
	* Important note: the refresh happen only AFTER the message is sent, so if the producer never sends a message the metadata is never refreshed（**重要提示**：无论设置刷新间隔为多少，具体刷新metadata都发生在producer发送message之后，因此，如果一直没有message发送，就不会有metadata刷新）

* queue.buffering.max.ms
	* 5000
	* Maximum time to buffer data when using `async` mode. For example a setting of 100 will try to batch together 100ms of messages to send at once. This will improve throughput but adds message delivery latency due to the buffering.（当使用`producer.type`为async模式时，这一参数才有用，含义：一时间为单位，将这一时间单位内的message一起发送给broker，这样有利于提高throughput，但会增加时延。）

* queue.buffering.max.messages
	* 10000
	* The maximum number of unsent messages that can be queued up the producer when using async mode before either the producer must be blocked or data must be dropped.（当`producer.type`使用async时，producer能够缓存的unsent message的数量，如果超过这一数量，producer就会blocked？message就会被丢弃？具体什么情况？）

* queue.enqueue.timeout.ms	
	* -1	
	* The amount of time to block before dropping messages when running in async mode and the buffer has reached queue.buffering.max.messages. （当`queue.buffering.max.message`设定的值已经触顶，等待多久block，之后就开始丢弃message）
	* If set to 0 events will be enqueued immediately or dropped if the queue is full (the producer send call will never block). 
	* If set to -1 the producer will block indefinitely and never willingly drop a send.

* batch.num.messages
	* 200
	* The number of messages to send in one batch when using async mode. The producer will wait until either this number of messages are ready to send or queue.buffer.max.ms is reached.（在`async`模式下，当message数量达到`batch.num.messages`时，或者，当等待时间达到`queue.buffer.max.ms`时，producer都会发送一次缓存的message）

* send.buffer.bytes
	* 100 * 1024
	* Socket write buffer size（socket写缓存的大小）

* client.id	
	* ""
	* The client id is a user-specified string sent in each request to help trace calls. It should logically identify the application making the request.（用户自己定义的producer标识，会伴随发送的message一起发送，用于追踪message的来源）


More details about producer configuration can be found in the scala class `kafka.producer.ProducerConfig`.

**notes(ningg)**：几个新的理解：

* metadata.broker.list：本质是从一些broker中请求metadata（topic、partition、replicas），而真正的socket链接，是根据收到的metadata来进行的；因此，可以只配置一部分的broker，或者说只配置部分VIP broker，必要时，探查此深层的原因；每一个broker上都保存了整个Kafka cluster的完整metadata吗？
* producer.type：sync、async，当设置为async时，能够提升吞吐量，但是会丢失数据？丢失，不能重发吗？
* request.required.acks：设置是否需要broker在完成数据写入后，向producer返回ack信息；一个问题：如果broker上数据写入失败，那，producer会进行重发吗？有没有类似的机制？
* queue.enqueue.timeout.me：其中说明的producer block什么含义？还会继续缓存未发送的message吗？





**疑问**：突然想到一个问题，记录一下：

* Server上，有进程监听port后，在服务器上无法再启动一个进程来监听这一port；
* 在远端通过telnet能够与server上这一port建立连接，并且，多个client都能与server上这一port建立连接；

这个问题，我不知到深层原因，归根结底是对socket建立的底层原因不清晰。




##New Producer Configs（补充）

下面是今后Kafka Producer会采用的新的配置参数，当前，可以有一个基本的了解。

We are working on a replacement for our existing producer. The code is available in trunk now and can be considered beta quality. Below is the configuration for the new producer.

* Name
	* Type
	* Default
	* Importance
	* Description

* bootstrap.servers
	* list
	* null
	* high
	* A list of host/port pairs to use for establishing the initial connection to the Kafka cluster. Data will be load balanced over all servers irrespective of which servers are specified here for bootstrapping—this list only impacts the initial hosts used to discover the full set of servers. This list should be in the form host1:port1,host2:port2,.... Since these servers are just used for the initial connection to discover the full cluster membership (which may change dynamically), this list need not contain the full set of servers (you may want more than one, though, in case a server is down). If no server in this list is available sending data will fail until on becomes available.

* acks
	* string
	* 1
	* high
	* The number of acknowledgments the producer requires the leader to have received before considering a request complete. This controls the durability of records that are sent. The following settings are common:
	* `acks=0` If set to zero then the producer will not wait for any acknowledgment from the server at all. The record will be immediately added to the socket buffer and considered sent. No guarantee can be made that the server has received the record in this case, and the retries configuration will not take effect (as the client won't generally know of any failures). The offset given back for each record will always be set to -1.
	* `acks=1` This will mean the leader will write the record to its local log but will respond without awaiting full acknowledgement from all followers. In this case should the leader fail immediately after acknowledging the record but before the followers have replicated it then the record will be lost.（leader将message写入local log后，直接返回ack信息；如果leader，返回ack信息后，leader宕机了，那其他follwer上并没有这条message，将导致message丢失）
	* `acks=all` This means the leader will wait for the full set of in-sync replicas to acknowledge the record. This guarantees that the record will not be lost as long as at least one in-sync replica remains alive. This is the strongest available guarantee.
	* Other settings such as acks=2 are also possible, and will require the given number of acknowledgements but this is generally less useful.

* buffer.memory
	* long
	* 33554432
	* high
	* The total bytes of memory the producer can use to buffer records waiting to be sent to the server. If records are sent faster than they can be delivered to the server the producer will either block or throw an exception based on the preference specified by `block.on.buffer.full`.（用于存储未发送出去的message，当producer接收到的message速度大于发送message速度时，producer will block，或者抛出异常）
	* This setting should correspond roughly to the total memory the producer will use, but is not a hard bound since not all memory the producer uses is used for buffering. Some additional memory will be used for compression (if compression is enabled) as well as for maintaining in-flight requests.（**什么含义**？需仔细琢磨）

* compression.type
	* string
	* none
	* high
	* The compression type for all data generated by the producer. The default is none (i.e. no compression). Valid values are none, gzip, or snappy. Compression is of full batches of data, so the efficacy of batching will also impact the compression ratio (more batching means better compression).

* retries
	* int
	* 0
	* high
	* Setting a value greater than zero will cause the client to resend any record whose send fails with a potentially transient error. Note that this retry is no different than if the client resent the record upon receiving the error. Allowing retries will potentially change the ordering of records because if two records are sent to a single partition, and the first fails and is retried but the second succeeds, then the second record may appear first.（设定，message尝试重发的次数；这个重发机制，可能会改变message之间的相互顺序）

* batch.size
	* int
	* 16384
	* medium
	* The producer will attempt to batch records together into fewer requests whenever multiple records are being sent to the same partition. This helps performance on both the client and the server. This configuration controls the default batch size in bytes.（将发送到同一partition的多条message集中起来发送，构成一个batch）
	* No attempt will be made to batch records larger than this size.
	* Requests sent to brokers will contain multiple batches, one for each partition with data available to be sent.（发送给broker的request包含多个batch？每一个batch对应一个partition）
	* A small batch size will make batching less common and may reduce throughput (a batch size of zero will disable batching entirely). A very large batch size may use memory a bit more wastefully as we will always allocate a buffer of the specified batch size in anticipation of additional records.

* client.id
	* string
	* null
	* medium
	* The id string to pass to the server when making requests. The purpose of this is to be able to track the source of requests beyond just ip/port by allowing a logical application name to be included with the request. The application can set any string it wants as this has no functional purpose other than in logging and metrics.

* linger.ms
	* long
	* 0
	* medium
	* The producer groups together any records that arrive in between request transmissions into a single batched request. Normally this occurs only under load when records arrive faster than they can be sent out. However in some circumstances the client may want to reduce the number of requests even under moderate load. This setting accomplishes this by adding a small amount of artificial delay—that is, rather than immediately sending out a record the producer will wait for up to the given delay to allow other records to be sent so that the sends can be batched together. This can be thought of as analogous to Nagle's algorithm in TCP. This setting gives the upper bound on the delay for batching: once we get batch.size worth of records for a partition it will be sent immediately regardless of this setting, however if we have fewer than this many bytes accumulated for this partition we will 'linger' for the specified time waiting for more records to show up. This setting defaults to 0 (i.e. no delay). Setting linger.ms=5, for example, would have the effect of reducing the number of requests sent but would add up to 5ms of latency to records sent in the absense of load.（当producer收到一个message后，不直接发送出去，而是，等待`linger.ms`时间，目的：相同partition的多个message同时发送。）

* max.request.size
	* int
	* 1048576
	* medium
	* The maximum size of a request. This is also effectively a cap on the maximum record size. Note that the server has its own cap on record size which may be different from this. This setting will limit the number of record batches the producer will send in a single request to avoid sending huge requests.（限制单个request的大小）

* receive.buffer.bytes
	* int
	* 32768
	* medium
	* The size of the TCP receive buffer to use when reading data（上层读取TCP数据时，一次读取的缓冲单元？）

* send.buffer.bytes
	* int
	* 131072
	* medium
	* The size of the TCP send buffer to use when sending data

* timeout.ms
	* int
	* 30000
	* medium
	* The configuration controls the maximum amount of time the server will wait for acknowledgments from followers to meet the acknowledgment requirements the producer has specified with the acks configuration. If the requested number of acknowledgments are not met when the timeout elapses an error will be returned. This timeout is measured on the server side and does not include the network latency of the request.（server等待follower返回ack信息的时间，这个时间是指server端的时间）

* block.on.buffer.full
	* boolean
	* true
	* low
	* When our memory buffer is exhausted we must either stop accepting new records (block) or throw errors. By default this setting is true and we block, however in some scenarios blocking is not desirable and it is better to immediately give an error. Setting this to false will accomplish that: the producer will throw a BufferExhaustedException if a recrord is sent and the buffer space is full.（默认`true`，当memory buffer中内容满了之后，producer不再接收新的message；如果设置为`false`，则当memory buffer中内容满了之后，producer会直接抛出异常`BufferExhaustedException`）

* metadata.fetch.timeout.ms
	* long
	* 60000
	* low
	* The first time data is sent to a topic we must fetch metadata about that topic to know which servers host the topic's partitions. This configuration controls the maximum amount of time we will block waiting for the metadata fetch to succeed before throwing an exception back to the client.（当第一次向topic中传入数据时，需要从server请求metadata，参数`metadata.fetch.timeout.ms`设定了发送metadata请求后，producer等待的时间，如果超时，则抛出异常。）

* metadata.max.age.ms
	* long
	* 300000
	* low
	* The period of time in milliseconds after which we force a refresh of metadata even if we haven't seen any partition leadership changes to proactively discover any new brokers or partitions.（定期请求metadata的时常）

* metric.reporters
	* list
	* `[]`
	* low
	* A list of classes to use as metrics reporters. Implementing the `MetricReporter` interface allows plugging in classes that will be notified of new metric creation. The `JmxReporter` is always included to register `JMX` statistics.（**什么含义**？生成测试报告？测试什么？为什么要测试？）

* metrics.num.samples
	* int
	* 2
	* low
	* The number of samples maintained to compute metrics.（计算指标时，保留的samples的个数）

* metrics.sample.window.ms
	* long
	* 30000
	* low
	* The metrics system maintains a configurable number of samples over a fixed window size. This configuration controls the size of the window. For example we might maintain two samples each measured over a 30 second period. When a window expires we erase and overwrite the oldest window.（选出sample的window大小）

* reconnect.backoff.ms
	* long
	* 10
	* low
	* The amount of time to wait before attempting to reconnect to a given host when a connection fails. This avoids a scenario where the client repeatedly attempts to connect to a host in a tight loop.（当与一个host断开连接后，等待多长时间，再去进行连接，避免过于频繁的无效连接）

* retry.backoff.ms
	* long
	* 100
	* low
	* The amount of time to wait before attempting to retry a failed produce request to a given topic partition. This avoids repeated sending-and-failing in a tight loop.

**notes(ningg)**：`metrics`的含义？为什么有这个？干什么的？



##参考来源


* [flume-ng-kafka-sink][flume-ng-kafka-sink]
* [0.8.0 Producer Example][0.8.0 Producer Example]
* [Kafka Configuration][Kafka Configuration]



##杂谈

人是有差异的，特别是视野上的差异，有些东西，如果一个人没有见识过，同时想象力也不行，或者说胆小如鼠不敢想象，这样的人脑袋不行、胆子也不行，年轻人脑袋行不行，至少胆子要大；另，信任是金子，别人对我的绝对信任，我对别人的绝对信任，都是很难建立的，要如同珍惜脑袋一样，珍惜这些信任。（注：绝对信任：无论做什么事，都相信是在做一件值得做的事，无论怎样，都是信任，甚至当有流言蜚语产生时，都能力排众议对其信任。这种信任，大都是建立在对人格的熟知上。）

整理东西，突然想到：做一件事，怎样才能做成？做事情需要几个条件：

* 做事的方向对不对？
* 做事的人脑袋是否灵光？
* 做事的人，是否投入了足够的时间？

针对上面的几点，大概说一下：

* **做事的方向对不对**，只要针对做的事情，当前能够达到基本一致，方向基本确定，而不是一团乱麻，那就可以开始做下去了，而在后期的过程中，可能会涉及到多次调整、迭代，这些都是可以预见的；
* **做事的人脑袋是否灵光**，事情是由人来做的，做的人脑袋行不行？基础理论、基本操作技能，基本的世界观：劳动创造价值，获得报酬；还是，跟着大牛有肉吃？（这本质是希望拿牛人的劳动价值，换取自己的报酬）
* **做事的人时间投入**，天资尚可的人就行了，团队高低档次的人都需要，但是，有一点，如果不投入时间，或者时间很少，那又如何保证产出？特别是针对以前就没有涉足的领域，需要不畏艰险、持续的投入时间，才能有所理解、有所深入；脑袋还可以，但做事不投入充足时间的人，这个就不太好。

今天突然想起一件事，几年前，跟某位好友一起走路，无意间说起坚韧这种性格，我就问道：如果要在午门城墙上打一个洞，如何才能做到？谈到锲而不舍，如果一个人没有这种精神，那遇到困难的事情，就难办了；后来又说起，今后工作的打算，我们基本达成一致：精挑细选公司，一旦入门后，就当自己是公司的创始人，然后，返老还童，恢复到20多岁年轻小伙儿的年纪 ，只不过，返老还童的代价是放弃对于公司的所有权、职务等，以这种心态去工作，重塑自己的公司、再造辉煌，可以说想象还是比较大胆的；基于这种定位，每次做事，都是创始人心态，全力做好。*（每次整理blog都会到夜里12点才睡，略累呀，如果下班就走，那就有时间了，只不过工作要做好，要投入时间，下班很难按时走，权衡吧）*




[NingG]:    http://ningg.github.com  "NingG"
[flume-ng-kafka-sink]:		https://github.com/thilinamb/flume-ng-kafka-sink
[0.8.0 Producer Example]:		https://cwiki.apache.org/confluence/display/KAFKA/0.8.0+Producer+Example
[Kafka Configuration]:			http://kafka.apache.org/08/configuration.html
[Kafka Producer Config]:		http://kafka.apache.org/documentation.html#producerconfigs


