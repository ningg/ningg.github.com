---
layout: post
title: Kafka 0.8.2.0 删除Topic
description: 如何删除Kafka中指定Topic内的数据
published: true
category: kafka
---




几点：

* 修改Kafka的配置文件，Kafka节点会自动生效吗？
* 逐个修改Kafka节点，并逐个重启Kafka节点，是否可以？

修改Kafka配置文件，增加可删除Topic的设置：

	delete.topic.enable=true

然后，逐个重启Kafka节点，即可。逐个重启Kafka节点，而对其他系统没有影响，是因为之前已经设置每个数据备份两份：

	# The default replication factor for automatically created topics.
	default.replication.factor=2


上述，开启可删除topic标识之后，可以删除Topic，操作如下：

	bin/kafka-topics.sh --zookeeper zk_host:port/chroot --delete --topic my_topic_name
	
然后，通过如下命令可以查看topic状态：

	$ bin/kafka-topics.sh --zookeeper 168.7.2.165 --list
	fdiy - marked for deletion

疑问：为什么topic：fdiy还存在？并且还被标记上`marked for deletion`?

（TODO）

关于上述`marked for deletion`的现象，当前并不能确定原因，todo

参考来源：

* [Kafka Command Line and Related Improvements][Kafka Command Line and Related Improvements]
* [Problem deleting topics in 0.8.2?][Problem deleting topics in 0.8.2?]

















## 参考来源

* [Kafka 0.8.2 Documentation][Kafka 0.8.2 Documentation]
* [Purge Kafka Queue][Purge Kafka Queue]
* [Is there a way to delete all the data from a topic or delete the topic before every run?][Is there a way to delete all the data from a topic or delete the topic before every run?]







[NingG]:    http://ningg.github.com  "NingG"
[Kafka 0.8.2 Documentation]:		http://kafka.apache.org/documentation.html
[Purge Kafka Queue]:				http://stackoverflow.com/questions/16284399/purge-kafka-queue
[Is there a way to delete all the data from a topic or delete the topic before every run?]:		http://stackoverflow.com/questions/17730905/is-there-a-way-to-delete-all-the-data-from-a-topic-or-delete-the-topic-before-ev

[Kafka Command Line and Related Improvements]:		https://cwiki.apache.org/confluence/display/KAFKA/Kafka+Command+Line+and+Related+Improvements
[Problem deleting topics in 0.8.2?]:				http://comments.gmane.org/gmane.comp.apache.kafka.user/6686







