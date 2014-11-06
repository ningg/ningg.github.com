---
layout: post
title: Storm 0.9.2：Trident
description: 
category: storm
---

> 原文地址：[Trident tutorial][Trident tutorial]，本文采用`英文原文+中文批注`方式。


Trident is a high-level abstraction for doing realtime computing on top of Storm. It allows you to seamlessly intermix high throughput (millions of messages per second), stateful stream processing with low latency distributed querying. If you’re familiar with high level batch processing tools like `Pig` or `Cascading`, the concepts of `Trident` will be very familiar – Trident has **joins**, **aggregations**, **grouping**, **functions**, and **filters**. In addition to these, Trident adds primitives for doing stateful, incremental processing on top of any database or persistence store. Trident has consistent, exactly-once semantics, so it is easy to reason about Trident topologies.

Trident，说几点：

能够支撑高吞吐量、有状态stream的低延迟分布式查询；
与批量处理工具类似`Pig`、`Cascading`，Trident包含：**joins**, **aggregations**, **grouping**, **functions**, and **filters**一系列操作；
Trident能够支撑stateful、incremental processing；
Trident支撑consistent、exactly-once semantics；

##Illustrative example


Let’s look at an illustrative example of Trident. This example will do two things:

1. Compute streaming word count from an input stream of sentences
1. Implement queries to get the sum of the counts for a list of words

例子做两件事：

统计一个输入stream中的word；
查询一组输入word的统计结果；


For the purposes of illustration, this example will read an infinite stream of sentences from the following source:
（从如下source中读取数据，进行处理）

	// java 
	FixedBatchSpout spout = new FixedBatchSpout(new Fields("sentence"), 3, 
						new Values("the cow jumped over the moon"), 
						new Values("the man went to the store and bought some candy"), 
						new Values("four score and seven years ago"), 
						new Values("how many apples can you eat"));

	spout.setCycle(true);

**notes(ningg)**：spout中`setCycle()`的含义。

This spout cycles through that set of sentences over and over to produce the sentence stream. Here’s the code to do the streaming word count part of the computation:

	// java 
	TridentTopology topology = new TridentTopology(); 
	TridentState wordCounts = topology.newStream("spout1", spout)
					.each(new Fields("sentence"), new Split(), new Fields("word"))
					.groupBy(new Fields("word"))
					.persistentAggregate(new MemoryMapState.Factory(), new Count(), new Fields("count"))
					.parallelismHint(6);

Let’s go through the code line by line. First a TridentTopology object is created, which exposes the interface for constructing Trident computations. TridentTopology has a method called newStream that creates a new stream of data in the topology reading from an input source. In this case, the input source is just the FixedBatchSpout defined from before. Input sources can also be queue brokers like Kestrel or Kafka. Trident keeps track of a small amount of state for each input source (metadata about what it has consumed) in Zookeeper, and the “spout1” string here specifies the node in Zookeeper where Trident should keep that metadata.

几个点：

* TridentTopology类：提供构造Trident computation的接口；
* newStream()方法：从一个Spout中读取数据，构造Stream；
	* 上述例子中，使用FixedBatchSpout作为数据源(Source);
	* 上面Spout也可使用queue broker代替，例，Kestrel、Kafka；
	* `newStream("spout1", spout)`，其中`spout1`标识了在zookeeper中当前spout存储
* Trident在Zookeeper中记录了每个Spout的处理状态数据（metadata：Spout中数据处理进展）


Trident processes the stream as small batches of tuples. For example, the incoming stream of sentences might be divided into batches like so:

Trident将Stream中的tuple分割为一些小的batch，按照batch来进行处理。

![](/images/storm-trident/batched-stream.png)

Generally the size of those small batches will be on the order of thousands or millions of tuples, depending on your incoming throughput. 
（通常，将相邻的tuple组合成一个batch，通过调整tuple的输入Storm顺序，可实现将类似的tuple放入相同的batch）

Trident provides a fully fledged batch processing API to process those small batches. The API is very similar to what you see in high level abstractions for Hadoop like Pig or Cascading: you can do group by’s, joins, aggregations, run functions, run filters, and so on. Of course, processing each small batch in isolation isn’t that interesting, so Trident provides functions for doing aggregations across batches and persistently storing those aggregations – whether in memory, in Memcached, in Cassandra, or some other store. Finally, Trident has first-class functions for querying sources of realtime state. That state could be updated by Trident (like in this example), or it could be an independent source of state.
（Trident提供了处理batch的API，这些API与Pig、Cascading的处理类似）


Back to the example, the spout emits a stream containing one field called “sentence”. The next line of the topology definition applies the Split function to each tuple in the stream, taking the “sentence” field and splitting it into words. Each sentence tuple creates potentially many word tuples – for instance, the sentence “the cow jumped over the moon” creates six “word” tuples. Here’s the definition of `Split`:

**notes(ningg)**：通过`TridentTopology#newStream()`将Spout中tuple构造为stream时，也可以进行干预（定制），即，将Spout中读取的原始tuple转换为其他格式的tuple。

// java 
public class Split extends BaseFunction { 

	public void execute(TridentTuple tuple, TridentCollector collector) { 
		String sentence = tuple.getString(0);
		for(String word: sentence.split(" ")) { 
			collector.emit(new Values(word)); 
		} 
	} 
	
}

As you can see, it’s really simple. It simply grabs the sentence, splits it on whitespace, and emits a tuple for each word.

The rest of the topology computes word count and keeps the results persistently stored. First the stream is grouped by the “word” field. Then, each group is persistently aggregated using the Count aggregator. The `persistentAggregate` function knows how to store and update the results of the aggregation in a source of state. In this example, the word counts are kept in memory, but this can be trivially swapped to use Memcached, Cassandra, or any other persistent store. Swapping this topology to store counts in Memcached is as simple as replacing the persistentAggregate line with this (using [trident-memcached](https://github.com/nathanmarz/trident-memcached)), where the “serverLocations” is a list of host/ports for the Memcached cluster:
（`persistentAggregate`函数，负责存储和更新aggregation result，其中`MemoryMapState.Factory()`表示利用内存存储，也可以使用Memcached、Cassandra以及其他的持久化数据库）

	// MemcachedState.transactional()
	.persistentAggregate(MemcachedState.transactional(serverLocations), new Count(), new Fields("count")) 
	

The values stored by persistentAggregate represents the aggregation of all batches ever emitted by the stream.

One of the cool things about Trident is that it has fully fault-tolerant, exactly-once processing semantics. This makes it easy to reason about your realtime processing. Trident persists state in a way so that if failures occur and retries are necessary, it won’t perform multiple updates to the database for the same source data.
（Trident最迷人的一点：fully fault-tolerant、exactly-once processing semantics）

The `persistentAggregate` method transforms a `Stream` into a `TridentState object`. In this case the TridentState object represents all the word counts. We will use this TridentState object to implement the distributed query portion of the computation.
（`persistentAggregate`方法将Stream转换为TridentState Object，其用于实现distributed query）

The next part of the topology implements a low latency distributed query on the word counts. The query takes as input a whitespace separated list of words and return the sum of the counts for those words. These queries are executed just like normal RPC calls, except they are parallelized in the background. Here’s an example of how you might invoke one of these queries:
（topology的next part实现了一个low latency、distributed query：接收输入的word，并返回这些word的统计次数。实际上，这些query看起来就是normal RPC calls，只是他们在背后是并行执行的。下面是调用query的方法）

	// java
	DRPCClient client = new DRPCClient("drpc.server.location", 3772); 
	// prints the JSON-encoded result, e.g.: "[[5078]]"
	System.out.println(client.execute("words", "cat dog the man"); 

As you can see, it looks just like a regular remote procedure call (RPC), except it’s executing in parallel across a Storm cluster. The latency for small queries like this are typically around 10ms. More intense DRPC queries can take longer of course, although the latency largely depends on how many resources you have allocated for the computation.

The implementation of the distributed query portion of the topology looks like this:

	// java
	topology.newDRPCStream("words")
		   .each(new Fields("args"), new Split(), new Fields("word")) 
		   .groupBy(new Fields("word")) 
		   .stateQuery(wordCounts, new Fields("word"), new MapGet(), new Fields("count")) 
		   .each(new Fields("count"), new FilterNull()) 
		   .aggregate(new Fields("count"), new Sum(), new Fields("sum"));

The same TridentTopology object is used to create the DRPC stream, and the function is named “words”. The function name corresponds to the function name given in the first argument of execute when using a DRPCClient.

**notes(ningg)**：DRPC，distributed RPC？

Each DRPC request is treated as its own little batch processing job that takes as input a single tuple representing the request. The tuple contains one field called “args” that contains the argument provided by the client. In this case, the argument is a whitespace separated list of words.

First, the Split function is used to split the arguments for the request into its constituent words. The stream is grouped by “word”, and the stateQuery operator is used to query the TridentState object that the first part of the topology generated. stateQuery takes in a source of state – in this case, the word counts computed by the other portion of the topology – and a function for querying that state. In this case, the MapGet function is invoked, which gets the count for each word. Since the DRPC stream is grouped the exact same way as the TridentState was (by the “word” field), each word query is routed to the exact partition of the TridentState object that manages updates for that word.

Next, words that didn’t have a count are filtered out via the FilterNull filter and the counts are summed using the Sum aggregator to get the result. Then, Trident automatically sends the result back to the waiting client.

Trident is intelligent about how it executes a topology to maximize performance. There’s two interesting things happening automatically in this topology:

1. Operations that read from or write to state (like persistentAggregate and stateQuery) automatically batch operations to that state. So if there’s 20 updates that need to be made to the database for the current batch of processing, rather than do 20 read requests and 20 writes requests to the database, Trident will automatically batch up the reads and writes, doing only 1 read request and 1 write request (and in many cases, you can use caching in your State implementation to eliminate the read request). So you get the best of both words of convenience – being able to express your computation in terms of what should be done with each tuple – and performance.
1. Trident aggregators are heavily optimized. Rather than transfer all tuples for a group to the same machine and then run the aggregator, Trident will do partial aggregations when possible before sending tuples over the network. For example, the Count aggregator computes the count on each partition, sends the partial count over the network, and then sums together all the partial counts to get the total count. This technique is similar to the use of combiners in MapReduce.


Let’s look at another example of Trident.


##Reach

The next example is a pure DRPC topology that computes the reach of a URL on demand. Reach is the number of unique people exposed to a URL on Twitter. To compute reach, you need to fetch all the people who ever tweeted a URL, fetch all the followers of all those people, unique that set of followers, and that count that uniqued set. Computing reach is too intense for a single machine – it can require thousands of database calls and tens of millions of tuples. With Storm and Trident, you can parallelize the computation of each step across a cluster.

This topology will read from two sources of state. One database maps URLs to a list of people who tweeted that URL. The other database maps a person to a list of followers for that person. The topology definition looks like this:


	TridentState urlToTweeters = topology.newStaticState(getUrlToTweetersState()); 
	TridentState tweetersToFollowers = topology.newStaticState(getTweeterToFollowersState());

	topology.newDRPCStream(“reach”) 
			.stateQuery(urlToTweeters, new Fields(“args”), new MapGet(), new Fields(“tweeters”)) 
			.each(new Fields(“tweeters”), new ExpandList(), new Fields(“tweeter”)) 
			.shuffle() 
			.stateQuery(tweetersToFollowers, new Fields(“tweeter”), new MapGet(), new Fields(“followers”)) 
			.parallelismHint(200) 
			.each(new Fields(“followers”), new ExpandList(), new Fields(“follower”)) 
			.groupBy(new Fields(“follower”)) 
			.aggregate(new One(), new Fields(“one”)) 
			.parallelismHint(20) 
			.aggregate(new Count(), new Fields(“reach”));

The topology creates TridentState objects representing each external database using the newStaticState method. These can then be queried in the topology. Like all sources of state, queries to these databases will be automatically batched for maximum efficiency.

The topology definition is straightforward – it’s just a simple batch processing job. First, the urlToTweeters database is queried to get the list of people who tweeted the URL for this request. That returns a list, so the ExpandList function is invoked to create a tuple for each tweeter.

Next, the followers for each tweeter must be fetched. It’s important that this step be parallelized, so shuffle is invoked to evenly distribute the tweeters among all workers for the topology. Then, the followers database is queried to get the list of followers for each tweeter. You can see that this portion of the topology is given a large parallelism since this is the most intense portion of the computation.

Next, the set of followers is uniqued and counted. This is done in two steps. First a “group by” is done on the batch by “follower”, running the “One” aggregator on each group. The “One” aggregator simply emits a single tuple containing the number one for each group. Then, the ones are summed together to get the unique count of the followers set. Here’s the definition of the “One” aggregator:

	public class One implements CombinerAggregator { 
	
		public Integer init(TridentTuple tuple) { 
			return 1; 
		}

		public Integer combine(Integer val1, Integer val2) { 
			return 1; 
		}

		public Integer zero() { return 1; } 
	}

This is a “combiner aggregator”, which knows how to do partial aggregations before transferring tuples over the network to maximize efficiency. Sum is also defined as a combiner aggregator, so the global sum done at the end of the topology will be very efficient.

Let’s now look at Trident in more detail.

##Fields and tuples

The Trident data model is the TridentTuple which is a named list of values. During a topology, tuples are incrementally built up through a sequence of operations. Operations generally take in a set of input fields and emit a set of “function fields”. The input fields are used to select a subset of the tuple as input to the operation, while the “function fields” name the fields the operation emits.

Consider this example. Suppose you have a stream called “stream” that contains the fields “x”, “y”, and “z”. To run a filter MyFilter that takes in “y” as input, you would say:

	stream.each(new Fields("y"), new MyFilter())

Suppose the implementation of MyFilter is this:

	public class MyFilter extends BaseFilter { 
	
		public boolean isKeep(TridentTuple tuple){ 
			return tuple.getInteger(0) < 10; 
		} 
	
	}

This will keep all tuples whose “y” field is less than 10. The TridentTuple given as input to MyFilter will only contain the “y” field. Note that Trident is able to project a subset of a tuple extremely efficiently when selecting the input fields: the projection is essentially free.

Let’s now look at how “function fields” work. Suppose you had this function:

	public class AddAndMultiply extends BaseFunction { 
		public void execute(TridentTuple tuple, TridentCollector collector) {
			int i1 = tuple.getInteger(0); 
			int i2 = tuple.getInteger(1); 
			collector.emit(new Values(i1 + i2, i1 * i2)); 
		}
	}

This function takes two numbers as input and emits two new values: the addition of the numbers and the multiplication of the numbers. Suppose you had a stream with the fields “x”, “y”, and “z”. You would use this function like this:

	stream.each(new Fields("x", "y"), new AddAndMultiply(), new Fields("added", "multiplied"));

The output of functions is additive: the fields are added to the input tuple. So the output of this each call would contain tuples with the five fields “x”, “y”, “z”, “added”, and “multiplied”. “added” corresponds to the first value emitted by AddAndMultiply, while “multiplied” corresponds to the second value.

With aggregators, on the other hand, the function fields replace the input tuples. So if you had a stream containing the fields “val1” and “val2”, and you did this:

	stream.aggregate(new Fields("val2"), new Sum(), new Fields("sum"))

The output stream would only contain a single tuple with a single field called “sum”, representing the sum of all “val2” fields in that batch.

With grouped streams, the output will contain the grouping fields followed by the fields emitted by the aggregator. For example:

	stream.groupBy(new Fields("val1")) .aggregate(new Fields("val2"), new Sum(), new Fields("sum"))

In this example, the output will contain the fields “val1” and “sum”.

##State

A key problem to solve with realtime computation is how to manage state so that updates are idempotent in the face of failures and retries. It’s impossible to eliminate failures, so when a node dies or something else goes wrong, batches need to be retried. The question is – how do you do state updates (whether external databases or state internal to the topology) so that it’s like each message was only processed only once?

This is a tricky problem, and can be illustrated with the following example. Suppose that you’re doing a count aggregation of your stream and want to store the running count in a database. If you store only the count in the database and it’s time to apply a state update for a batch, there’s no way to know if you applied that state update before. The batch could have been attempted before, succeeded in updating the database, and then failed at a later step. Or the batch could have been attempted before and failed to update the database. You just don’t know.

Trident solves this problem by doing two things:

1. Each batch is given a unique id called the “transaction id”. If a batch is retried it will have the exact same transaction id.
1. State updates are ordered among batches. That is, the state updates for batch 3 won’t be applied until the state updates for batch 2 have succeeded.

With these two primitives, you can achieve exactly-once semantics with your state updates. Rather than store just the count in the database, what you can do instead is store the transaction id with the count in the database as an atomic value. Then, when updating the count, you can just compare the transaction id in the database with the transaction id for the current batch. If they’re the same, you skip the update – because of the strong ordering, you know for sure that the value in the database incorporates the current batch. If they’re different, you increment the count.

Of course, you don’t have to do this logic manually in your topologies. This logic is wrapped by the State abstraction and done automatically. Nor is your State object required to implement the transaction id trick: if you don’t want to pay the cost of storing the transaction id in the database, you don’t have to. In that case the State will have at-least-once-processing semantics in the case of failures (which may be fine for your application). You can read more about how to implement a State and the various fault-tolerance tradeoffs possible [in this doc](http://storm.apache.org/documentation/Trident-state).

A State is allowed to use whatever strategy it wants to store state. So it could store state in an external database or it could keep the state in-memory but backed by HDFS (like how HBase works). State’s are not required to hold onto state forever. For example, you could have an in-memory State implementation that only keeps the last X hours of data available and drops anything older. Take a look at the implementation of the [Memcached integration](https://github.com/nathanmarz/trident-memcached/blob/master/src/jvm/trident/memcached/MemcachedState.java) for an example State implementation.

##Execution of Trident topologies

Trident topologies compile down into as efficient of a Storm topology as possible. Tuples are only sent over the network when a repartitioning of the data is required, such as if you do a groupBy or a shuffle. So if you had this Trident topology:

![](/images/storm-trident/trident-to-storm1.png)

It would compile into Storm spouts/bolts like this:

![](/images/storm-trident/trident-to-storm2.png)

##Conclusion

Trident makes realtime computation elegant. You’ve seen how high throughput stream processing, state manipulation, and low-latency querying can be seamlessly intermixed via Trident’s API. Trident lets you express your realtime computations in a natural way while still getting maximal performance.








##参考来源




##杂谈

今天几个人讨论某事，说来是鸡毛蒜皮的小事，不过也大小是个活动，通过及时通讯软件进行讨论，参与人员基本上都装死，很冷清，大部分人都是在看消息，不过内心里，大家都是愿意参加这么个活动的，这样只有一个人积极发言，没有交互、讨论，内心还是挺凄凉的，这种情况怎么办？时势造英雄，需要一个人花点时间整理一下活动的方方面面细则：时间、地点、人员、路线、内容、费用、事项（每项的负责人），然后出一个基本稿，发到群中，针对基本稿进行讨论，就有目标了；讨论结束再来个总结，算是定稿，妥妥的。

说起这个，又想起今天早上一起去装机的事情了，`**`去重装服务器，回来后说：已经装完了，并且测试外网能够访问。OK，他是个有良好习惯的人，不仅把事情做了，而且做了验证(测试)，确保事情做好了。想想之前我去重装系统，也是这么操作的，并且旁边站了2位同事，其中就有`**`，当时安装完系统后，我要测试一下是否完成配置，他们两位没有说话，我想他们应该是支持花费时间进行测试的，因为他们并没有反对测试，我想在我要花时间测试的时候，肯定有一种人会说：都已经安装、配置好了，还测试什么，浪费时间，走吧。说了这么多，其实是想说一件事：人是有差异的，有优秀的人，有的就平庸，有的就是需要剔除的坏因素；识别优秀的人，亲近他们，疏离除此之外的任何人，年轻成长的时候，更是要如此。

把事情做成，并测试事情是否已经做成，以此来确保已经把事情做成，这只是起步，往上还有空间：把事做成，确保做成，把事做好，确保做好。

















[Trident tutorial]:			http://storm.apache.org/documentation/Trident-tutorial.html
[NingG]:    http://ningg.github.com  "NingG"
