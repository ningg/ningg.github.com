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

具体如何使用上述producer api，可参考[0.8.0 Producer Example][0.8.0 Producer Example]。

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

第一项参数`metadata.broker.list`，用于配置可用的broker列表，可以只配置一个broker，不过建议最好至少配置2个broker，这样即使有一个broker宕机了，另一个也能及时接替工作；这些broker中，也不用指定不同topic的leader，因为Producer会主动连接Broker并且请求到meta数据，然后连接到topic的leader。

The second property “serializer.class” defines what Serializer to use when preparing the message for transmission to the Broker. In our example we use a simple String encoder provided as part of Kafka. Note that the encoder must accept the same type as defined in the KeyedMessage object in the next step.

第二项参数`serializer.class`，设定了将message从Producer发送到Broker的序列化方式。

**notes(ningg)**：“Note that the encoder must accept the same type as defined in the KeyedMessage object in the next step.” 什么含义？ `KeyedMessage`。

It is possible to change the Serializer for the Key (see below) of the message by defining "key.serializer.class" appropriately. By default it is set to the same value as "serializer.class".

参数`key.serializer.class`用于设置key序列化的方法，key将在序列化之后，与message一同从Producer发送到Broker；`key.serializer.class`的默认值与`serializer.class`相同。

**notes(ningg)**：Kafka是按照key进行partition的，每个message绑定的key也是需要传输到broker的，传输过程中也需要进行序列化，


The third property  "partitioner.class" defines what class to use to determine which Partition in the Topic the message is to be sent to. This is optional, but for any non-trivial implementation you are going to want to implement a partitioning scheme. More about the implementation of this class later. If you include a value for the key but haven't defined a partitioner.class Kafka will use the default partitioner. If the key is null, then the Producer will assign the message to a random Partition.

第三项参数`partitioner.class`用于设定message与Partition的映射关系，简单来说，每个message都发送给broker的某个对应的Topic，但message真正存储对应的是Topic下的partition，那么，参数`partitioner.class`就是用于设定message--partition之间映射关系的。

The last property "request.required.acks" tells Kafka that you want your Producer to require an acknowledgement from the Broker that the message was received. Without this setting the Producer will 'fire and forget' possibly leading to data loss. Additional information can be found [here](http://kafka.apache.org/08/configuration.html).

最后一项参数`request.required.acks`，设定Broker在接收到message之后，是否返回一个确认信息（ack）。如果没有这个信息，那么很有可能`fire and forget`并且丢失数据；

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

如果只在`metadata.broker.list`中配置一个broker，那么Producer能够识别出其他broker吗？
如果Kafka集群中动态增加了






##参考来源










[NingG]:    http://ningg.github.com  "NingG"
[flume-ng-kafka-sink]:		https://github.com/thilinamb/flume-ng-kafka-sink
[0.8.0 Producer Example]:		https://cwiki.apache.org/confluence/display/KAFKA/0.8.0+Producer+Example




