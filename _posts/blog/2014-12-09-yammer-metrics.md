---
layout: post
title: Yammer Metrics的使用
description: 获取系统、应用的运行状态数据，Yammer Metrics是一种比较好的选择
category: java
---

## Yammer Metrics简介

最近用到的某个框架，其官网提到利用Yammer Metrics来测量系统运行状态，需要对其统计的具体参数有个基本的了解，OK，那就需要弄清几个简单的问题：

* Yammer Metrics是什么？
* Yammer Metrics收集哪些数据？
* Yammer Metrics收集数据的基本过程、原理？

### Yammer Metrics的官网

上述列了几个问题，但有个最基本的问题：官网地址在哪？为什么说这个最基础、最重要，因为这是信息源，其他所有的网络信息都是以此为基础的。
在google中输入`yammer metrics wiki`没有搜到类似一个明显的官网，到时找到了github上的两个工程：

* [dropwizard/metrics][dropwizard/metrics]
* [codahale/metrics][codahale/metrics]

一时间有点蒙，赶紧去查看了一下当前Eclipse下使用的metrics-core-2.2.0.jar包，主要是其jar内的META-INF信息，查询得知jar包为coda在2012年编译的，再到google上一查，大部分人都在使用metrics 2.2.0版本，再理一下上面两个github工程的关系，初步肯定：[codahale/metrics][codahale/metrics]是较早之前的版本，而且现在已经变为metrics的go语言实现版本，同时[codahale/metrics][codahale/metrics]也指出java实现的metrics已经移到[dropwizard/metrics][dropwizard/metrics]。当前算是找到yammer metrics的官方地址了，赶快打开看一下，发现其已经是3.1.0版本了，心里有个小疑问，会不会有很多东西与2.2.0版本不同？不用担心，[Metrics doc 3.x][Metrics doc 3.x]的URL上，修改一下版本的位置，即可看到2.2.0版本的官方文档[Metrics doc 2.x][Metrics doc 2.x]。

**备注**：maven central repo中yammer metrics的两个位置：

* [repo: yammer metrics 2.x][repo: yammer metrics 2.x]
* [repo: yammer metrics 3.x][repo: yammer metrics 3.x]


### Yammer metrics的作用

为什么要用Metrics？[Metrics doc 3.x][Metrics doc 3.x]中有句话很经典：

> Metrics is a Java library which gives you unparalleled insight into what your code does in production.（注：unparalleled，空前的、无与伦比的）

## Yammer Metrics相关术语

> **特别说明**：从[Yammer metrics官网][Metrics doc 3.x]可知，当前为3.1.0版本，但是当前在项目中广泛使用的是2.2.0版本，因此，本文将主要关注[http://dropwizard.github.io/metrics/2.2.0/][Metrics doc 2.x]。

[intro to yammer metrics][intro to yammer metrics]中有个基本的总结：

* **Gauges**: an instantaneous measurement of a discrete value.
* **Counters**: a value that can be incremented and decremented. Can be used in queues to monitorize the remaining number of pending jobs.
* **Meters**: measure the rate of events over time. You can specify the rate unit, the scope of events or event type.
* **Histograms**: measure the statistical distribution of values in a stream of data.
* **Timers**: measure the amount of time it takes to execute a piece of code and the distribution of its duration.
* **Healthy checks**: as his name suggests, it centralize our service’s healthy checks of external systems.



### Gauges

A gauge is an instantaneous measurement of a value. For example, we may want to measure the number of pending jobs in a queue:

	Metrics.newGauge(QueueManager.class, "pending-jobs", new Gauge<Integer>() {
		@Override
		public Integer value() {
			return queue.size();
		}
	});
	
Every time this gauge is measured, it will return the number of jobs in the queue.

For most queue and queue-like structures, you won’t want to simply return `queue.size()`. Most of `java.util` and `java.util.concurrent` have implementations of `#size()` which are `O(n)`, which means your gauge will be slow (potentially while holding a lock).

### Counters

A counter is just a gauge for an `AtomicLong` instance. You can increment or decrement its value. For example, we may want a more efficient way of measuring the pending job in a queue:

	private final Counter pendingJobs = Metrics.newCounter(QueueManager.class, "pending-jobs");

	public void addJob(Job job) {
		pendingJobs.inc();
		queue.offer(job);
	}

	public Job takeJob() {
		pendingJobs.dec();
		return queue.take();
	}
	
Every time this counter is measured, it will return the number of jobs in the queue.

### Meters

A meter measures the rate of events over time (e.g., “requests per second”). In addition to the mean rate, meters also track `1-`, `5-`, and `15-`minute moving averages.

	private final Meter requests = Metrics.newMeter(RequestHandler.class, "requests", "requests", TimeUnit.SECONDS);

	public void handleRequest(Request request, Response response) {
		requests.mark();
		// etc
	}
	
This meter will measure the rate of requests in requests per second.

### Histograms

A histogram measures the statistical distribution of values in a stream of data. In addition to minimum, maximum, mean, etc., it also measures median, 75th, 90th, 95th, 98th, 99th, and 99.9th percentiles.

	private final Histogram responseSizes = Metrics.newHistogram(RequestHandler.class, "response-sizes");

	public void handleRequest(Request request, Response response) {
		// etc
		responseSizes.update(response.getContent().length);
	}
	
This histogram will measure the size of responses in bytes.

### Timers

A timer measures both the rate that a particular piece of code is called and the distribution of its duration.

	private final Timer responses = Metrics.newTimer(RequestHandler.class, "responses", TimeUnit.MILLISECONDS, TimeUnit.SECONDS);

	public String handleRequest(Request request, Response response) {
		final TimerContext context = responses.time();
		try {
			// etc;
			return "OK";
		} finally {
			context.stop();
		}
	}
	
This timer will measure the amount of time it takes to process each request in milliseconds and provide a rate of requests in requests per second.

### Health Checks

Metrics also has the ability to centralize your service’s health checks. First, implement a `HealthCheck` instance:

	import com.yammer.metrics.core.HealthCheck.Result;

	public class DatabaseHealthCheck extends HealthCheck {
		private final Database database;

		public DatabaseHealthCheck(Database database) {
			super("database");
			this.database = database;
		}

		@Override
		public Result check() throws Exception {
			if (database.isConnected()) {
				return Result.healthy();
			} else {
				return Result.unhealthy("Cannot connect to " + database.getUrl());
			}
		}
	}
	
Then register an instance of it with Metrics:

	HealthChecks.register(new DatabaseHealthCheck(database));
	
To run all of the registered health checks:

	final Map<String, Result> results = HealthChecks.runHealthChecks();
	for (Entry<String, Result> entry : results.entrySet()) {
		if (entry.getValue().isHealthy()) {
			System.out.println(entry.getKey() + " is healthy");
		} else {
			System.err.println(entry.getKey() + " is UNHEALTHY: " + entry.getValue().getMessage());
			final Throwable e = entry.getValue().getError();
			if (e != null) {
				e.printStackTrace();
			}
		}
	}
	
Metrics comes with a pre-built health check: `DeadlockHealthCheck`, which uses Java 1.6’s built-in thread deadlock detection to determine if any threads are deadlocked.



## Yammer metrics原理与具体用法

（doing...）

进一步的内容将参考：

* [Metrics doc 2.x][Metrics doc 2.x]
* [JAVA Metrics度量工具的使用][JAVA Metrics度量工具的使用]

下面将针对java中Yammer Metrics的用法进行简要介绍，此次我使用的是Maven来管理的java工程，具体pom.xml中的配置：

	<dependency>
  		<groupId>com.yammer.metrics</groupId>
  		<artifactId>metrics-core</artifactId>
  		<version>2.2.0</version>
  	</dependency>

给一个工程的截图：

![](/images/yammer-metrics/learn-metrics.png)

### gauge

	package io.github.ningg.gauge;

	import java.util.LinkedList;
	import java.util.List;
	import java.util.concurrent.TimeUnit;

	import com.yammer.metrics.Metrics;
	import com.yammer.metrics.core.Gauge;
	import com.yammer.metrics.reporting.ConsoleReporter;

	public class LearnGauge {
		
		private List<String> stringList = new LinkedList<String>();
		
		Gauge<Integer> gauge = Metrics.newGauge(LearnGauge.class, "list-size-gauge", new Gauge<Integer>() {
			@Override
			public Integer value() {
				return stringList.size();
			}
		});
		
		public void inputElement(String input){
			stringList.add(input);
		}
		
		
		public static void main(String[] args) throws InterruptedException{

			// periodically report all registered metrics to the console
			ConsoleReporter.enable(1,TimeUnit.SECONDS);
			LearnGauge learnGauge = new LearnGauge();
			
			for(int i = 0; i < 10; i++){
				learnGauge.inputElement(String.valueOf(i));
				Thread.sleep(1000);
			}
			
		}
		
	}

运行结果：

	14-12-10 19:35:27 ==============================================================
	io.github.ningg.gauge.LearnGauge:
	  list-size-gauge:
		value = 3

### counter

	package io.github.ningg.counter;

	import java.util.LinkedList;
	import java.util.List;
	import java.util.concurrent.TimeUnit;

	import com.yammer.metrics.Metrics;
	import com.yammer.metrics.core.Counter;
	import com.yammer.metrics.reporting.ConsoleReporter;

	public class LearnCounter {

		private List<String> stringList = new LinkedList<String>();
		
		private Counter listSizeCounter = Metrics.newCounter(LearnCounter.class, "string-list-counter");
		
		private void push(String input){
			listSizeCounter.inc();
			stringList.add(input);
		}
		
		private void pop(String output){
			listSizeCounter.dec();
			stringList.remove(output);
		}
		
		
		public static void main(String[] args) throws InterruptedException{
			
			ConsoleReporter.enable(1, TimeUnit.SECONDS);
			LearnCounter learnCounter = new LearnCounter();
			
			for(int times = 0; times < 5; times++){
				learnCounter.push(String.valueOf(times));
				Thread.sleep(1000);
			}
			
			for(int times = 0; times < 5; times++){
				learnCounter.pop(String.valueOf(times));
				Thread.sleep(1000);
			}
			
		}
		
	}



运行结果：

	14-12-10 19:49:02 ==============================================================
	io.github.ningg.counter.LearnCounter:
	  string-list-counter:
		count = 3



	14-12-10 19:49:03 ==============================================================
	io.github.ningg.counter.LearnCounter:
	  string-list-counter:
		count = 2


### meter

	package io.github.ningg.meter;

	import java.util.concurrent.TimeUnit;

	import com.yammer.metrics.Metrics;
	import com.yammer.metrics.core.Meter;
	import com.yammer.metrics.reporting.ConsoleReporter;

	public class LearnMeter {
		
		private Meter meter = Metrics.newMeter(LearnMeter.class, "meter-event", "request", TimeUnit.SECONDS);

		public void handleRequest(){
			meter.mark();
		}
		
		
		public static void main(String[] args) throws InterruptedException{
			ConsoleReporter.enable(1, TimeUnit.SECONDS);
			
			LearnMeter learnMeter = new LearnMeter();
			
			for(int times = 0; times < 200; times++){
				learnMeter.handleRequest();
				Thread.sleep(100);
			}
		}
		
	}


运行结果：

	14-12-10 19:49:53 ==============================================================
	io.github.ningg.meter.LearnMeter:
	  meter-event:
				 count = 20
			 mean rate = 9.95 request/s
		 1-minute rate = 0.00 request/s
		 5-minute rate = 0.00 request/s
		15-minute rate = 0.00 request/s

### histogram

	package io.github.ningg.histogram;

	import java.util.LinkedList;
	import java.util.List;
	import java.util.concurrent.TimeUnit;

	import com.yammer.metrics.Metrics;
	import com.yammer.metrics.core.Histogram;
	import com.yammer.metrics.reporting.ConsoleReporter;

	public class LearnHistogram {

		private List<String> stringList = new LinkedList<String>();
		
		private Histogram histogram = Metrics.newHistogram(LearnHistogram.class, "size-histogram");
		
		public void push(String input){
			stringList.add(input);
		}
		
		public void pop(String output){
			stringList.remove(output);
		}
		
		public void updateHisto(){
			histogram.update(stringList.size());
		}
		
		
		public static void main(String[] args) throws InterruptedException{
			ConsoleReporter.enable(1, TimeUnit.SECONDS);
			LearnHistogram learnHistogram = new LearnHistogram();
			
			for(int time = 0 ; time < 100000 ; time++){
				learnHistogram.push(String.valueOf(time));
				
				if(time%10 == 0){
					learnHistogram.updateHisto();
				}
				
				if(time%2 == 2){
					learnHistogram.pop(String.valueOf(time));
				}
				Thread.sleep(1);
				
			}
		}
		
	}

运行结果：

	14-12-10 19:50:46 ==============================================================
	io.github.ningg.histogram.LearnHistogram:
	  size-histogram:
				   min = 1.00
				   max = 991.00
				  mean = 496.00
				stddev = 290.11
				median = 496.00
				  75% <= 748.50
				  95% <= 950.50
				  98% <= 980.80
				  99% <= 990.90
				99.9% <= 991.00

	
	

### timer


	package io.github.ningg.timer;

	import java.util.concurrent.TimeUnit;

	import com.yammer.metrics.Metrics;
	import com.yammer.metrics.core.Timer;
	import com.yammer.metrics.core.TimerContext;
	import com.yammer.metrics.reporting.ConsoleReporter;

	public class LearnTimer {
		
		private Timer timer = Metrics.newTimer(LearnTimer.class, "response-timer", TimeUnit.MILLISECONDS, TimeUnit.SECONDS);
		
		public void handleRequest() throws InterruptedException{
			TimerContext context = timer.time();
			for(int i = 0 ; i < 2 ; i++){
				Thread.sleep(1);
			}
			context.stop();
		}
		
		public static void main(String[] args) throws InterruptedException{
			ConsoleReporter.enable(1, TimeUnit.SECONDS);
			LearnTimer learnTimer = new LearnTimer();
			
			for(int time = 0 ; time < 10000 ; time++){
				learnTimer.handleRequest();
			}
			Thread.sleep(10000);
		}

	}

运行结果：

	14-12-10 19:51:24 ==============================================================
	io.github.ningg.timer.LearnTimer:
	  response-timer:
				 count = 504
			 mean rate = 254.23 calls/s
		 1-minute rate = 0.00 calls/s
		 5-minute rate = 0.00 calls/s
		15-minute rate = 0.00 calls/s
				   min = 3.71ms
				   max = 3.98ms
				  mean = 3.86ms
				stddev = 0.03ms
				median = 3.86ms
				  75% <= 3.87ms
				  95% <= 3.92ms
				  98% <= 3.93ms
				  99% <= 3.94ms
				99.9% <= 3.98ms


		
		
### 小结

上面可知，在Java工程中使用Yammer Metrics的gauge、counter、meter、histogram、timer时，本质上就是创建一个Metrics的Gauge、Counter、Meter、Histogram、Timer对象，然后在特定的地点触发对象，即可实现对应用状态的监控。		
		

## 参考来源

* [Metrics doc 3.x][Metrics doc 3.x]*（官方文档简洁明了，推荐阅读；唯一需要注意的是，现在官网已经是3.x版本了，而很多项目使用过2.x版本，需要留意其差异）*












## 杂谈

刚看到的一个几个东西，感觉时代在进步呀，没有仔细看，看来需要不断学习、整理一些新的东西：

* [Dropwizard][Dropwizard]
* [郑晔谈Java开发：新工具、新框架、新思维][郑晔谈Java开发：新工具、新框架、新思维]






[NingG]:    									http://ningg.github.com  "NingG"
[郑晔谈Java开发：新工具、新框架、新思维]:		http://www.infoq.com/cn/articles/zhenye-talk-java-develop/
[Dropwizard]:									http://dropwizard.io/index.html
[dropwizard/metrics]:							https://github.com/dropwizard/metrics
[codahale/metrics]:								https://github.com/codahale/metrics
[repo: yammer metrics 2.x]:						http://repo1.maven.org/maven2/com/yammer/metrics/
[repo: yammer metrics 3.x]:						http://repo1.maven.org/maven2/io/dropwizard/metrics/
[Metrics doc 3.x]:								https://dropwizard.github.io/metrics/3.1.0/
[Metrics doc 2.x]:								http://dropwizard.github.io/metrics/2.2.0/
[JAVA Metrics度量工具的使用]:					http://blog.csdn.net/scutshuxue/article/details/8350135


[intro to yammer metrics]:			http://www.javacodegeeks.com/2012/12/yammer-metrics-a-new-way-to-monitor-your-application.html




