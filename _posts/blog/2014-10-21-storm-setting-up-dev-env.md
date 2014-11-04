---
layout: post
title: Storm：setting up a development environment
description: Storm官方文档的阅读和笔记
categories: storm big-data
---

> 原文地址：[Setting up a development environment](http://storm.apache.org/documentation/Setting-up-development-environment.html)，本文使用`英文原文+中文注释`方式来写。

This page outlines what you need to do to get a Storm development environment set up. In summary, the steps are:
（本文重点：set up a Storm dev env。概括一下，基本步骤如下）

1. Download a [Storm release](http://storm.apache.org//downloads.html) , unpack it, and put the unpacked `bin/` directory on your `PATH`
1. To be able to start and stop topologies on a remote cluster, put the cluster information in `~/.storm/storm.yaml`

More detail on each of these steps is below.

##What is a development environment?

Storm has two modes of operation: `local mode` and `remote mode`. In local mode, you can develop and test topologies completely in process on your local machine. In remote mode, you submit topologies for execution on a cluster of machines.
（两种mode：local mode，develop和test topologies；remote mode，真正执行时，submit topologies到cluster）

A Storm development environment has everything installed so that you can develop and test Storm topologies in local mode, package topologies for execution on a remote cluster, and submit/kill topologies on a remote cluster.

**notes(ningg)**：`storm devp env`要做三件事情：

* 在local mode下，develop和test topology；
* package topology for execution on a remote cluster；
* shubmit/kill topology on a remote cluster;


Let’s quickly go over the relationship between your machine and a remote cluster. A Storm cluster is managed by a master node called “Nimbus”. Your machine communicates with Nimbus to submit code (packaged as a jar) and topologies for execution on the cluster, and Nimbus will take care of distributing that code around the cluster and assigning workers to run your topology. Your machine uses a command line client called `storm` to communicate with Nimbus. The `storm` client is only used for remote mode; it is not used for developing and testing topologies in local mode.

**notes(ningg)**：梳理一下your machine与remote cluster的交互流程：

* storm cluster由master来管理，master node又称为`Nimbus`；
* your machine向`Nimbus`提交代码（打包为jar包）、提交topology；
* `Nimbus`将jar包分发到worker node，并且分配worker来run topology；
* your machine通过command line client `storm` 与 `Nimbus` 交互，`storm`命令只用于与remote storm cluster交互，不用于 testing and testing topology；


**notes(ningg)**：distribute code？与assign worker to run topologies有区别吗？
**RE**：distribute code到物理上的node？assign worker to run topologies针对的是不同物理主机上的worker process；（这个理解对吗？）


##Installing a Storm release locally

If you want to be able to submit topologies to a remote cluster from your machine, you should install a Storm release locally. Installing a Storm release will give you the `storm` client that you can use to interact with remote clusters. To install Storm locally, download a release [from here](https://github.com/apache/incubator-storm/downloads) and unzip it somewhere on your computer. Then add the unpacked `bin/` directory onto your `PATH` and make sure the `bin/storm` script is executable.
（本地安装的Storm，也可以作为与remote cluster交互的client；安装办法：下载、解压、添加bin到PATH）

Installing a Storm release locally is only for interacting with remote clusters. For developing and testing topologies in local mode, it is recommended that you use Maven to include Storm as a dev dependency for your project. You can read more about using Maven for this purpose on [Maven](http://storm.apache.org/documentation/Maven.html).

特别说明两点：

* 本地安装Storm唯一目标：interact with remote cluster；
* 如果想利用local mode来进行develop、test，建议使用Maven将Storm作为依赖导入；

##Starting and stopping topologies on a remote cluster

The previous step installed the `storm` client on your machine which is used to communicate with remote Storm clusters. Now all you have to do is tell the client which Storm cluster to talk to. To do this, all you have to do is put the host address of the master in the `~/.storm/storm.yaml` file. It should look something like this:
（在本地安装storm实质是为了interact with remote cluster，这就需要告诉本地storm：remote cluster的位置。）

	nimbus.host: "123.45.678.890"

Alternatively, if you use the [storm-deploy](https://github.com/nathanmarz/storm-deploy) project to provision Storm clusters on AWS, it will automatically set up your ~/.storm/storm.yaml file. You can manually attach to a Storm cluster (or switch between multiple clusters) using the “attach” command, like so:
（还有一种方法：如果Storm部署在AWS上，可直接使用 "attach" command）

	lein run :deploy --attach --name mystormcluster

More information is on the storm-deploy [wiki](https://github.com/nathanmarz/storm-deploy/wiki)

##参考来源

* [Apache Storm](http://storm.apache.org/)
* [Apache Storm: Documentation Rationale](http://storm.apache.org/documentation/Rationale.html)




[NingG]:    http://ningg.github.com  "NingG"