---
layout: post
title: Ganglia 3.6.1：Ganglia Monitoring Daemon v3.6.1 Configuration
description: Ganglia官方文档，用户手册
category: ganglia
---

> 原文地址：[ganglia-3.6.1(ganglia monitoring core)][ganglia-3.6.1(ganglia monitoring core)]，其源码包中gmond/gmond.conf.html文件。


##NAME

**gmond.conf** - configuration file for ganglia monitoring daemon (**gmond**)

##DESCRIPTION

The gmond.conf file is used to configure the ganglia monitoring daemon (gmond) which is part of the** Ganglia Distributed Monitoring System**.

##SECTIONS AND ATTRIBUTES

All sections and attributes are case-insensitive. For example, **name** or **NAME** or **Name** or **NaMe** are all equivalent.

Some sections can be included in the configuration file **multiple** times and some sections are **singular**. For example, you can have only one **cluster** section to define the attributes of the cluster being monitored; however, you can have multiple **udp_recv_channel** sections to allow gmond to receive message on multiple UDP channels.

**notes(ningg)**：gmond.conf配置文件，说几点：

* 整个配置文件，分为：多个section，每个section下有多个attribute
* section和attribute是case-insensitive的
* 在整个配置文件中，有的section只能有一个，有的就可以有多个

###cluster

There should **only be one cluster section** defined. This section controls how gmond reports the attributes of the cluster that it is part of.

The cluster section has four attributes: 

* name
* owner
* latlong
* url

For example,

	cluster {
	    name = "Millennium Cluster"
	    owner = "UC Berkeley CS Dept."
	    latlong = "N37.37 W122.23"
	    url = "http://www.millennium.berkeley.edu/";
	}
  
* The **name** attributes specifies the name of the cluster of machines. 
* The **owner** tag specifies the administrators of the cluster. 
	* The pair **name/owner** should be unique to all clusters in the world.
* The **latlong** attribute is the latitude and longitude GPS coordinates of this cluster on earth. Specified to 1 mile accuracy with two decimal places per axis in decimal.
* The **url** for more information on the cluster. Intended to give purpose, owner, administration, and account details for this cluster.

There directives directly control the XML output of gmond. For example, the cluster configuration example above would translate into the following XML.

	<CLUSTER NAME="Millennium Cluster" OWNER="UC Berkeley CS Dept."
		   LATLONG="N37.37 W122.23" URL="http://www.millennium.berkeley.edu/">
	...
	</CLUSTER>
  
###host

The host section provides information about the host running this instance of gmond. Currently only the **location** string attribute is supported. Example:

	host {
	    location = "1,2,3"
	}
 
The numbers represent **Rack**, **Rank** and **Plane** respectively.

###globals

The **globals** section controls general characteristics of **gmond** such as whether is should daemonize, what user it should run as, whether is should send/receive date and such. The globals section has the following attributes: 

* daemonize
* setuid
* user
* debug_level
* mute
* deaf
* allow_extra_data
* host_dmax
* host_tmax
* cleanup_threshold
* gexec
* send_metadata_interval
* module_dir

For example,

	globals {
	    daemonize = true
	    setuid = true
	    user = nobody
	    host_dmax = 3600
	    host_tmax = 40
	}
  
* The **daemonize** attribute is a **boolean**. 
	* When **true**, gmond will daemonize. 
	* When **false**, gmond will run in the foreground.
	
	
* The **setuid** attribute is a **boolean**. 
	* When **true**, gmond will set its effective UID to the uid of the user specified by the **user** attribute. 
	* When **false**, gmond will not change its effective user.
	
	
* The **debug_level** is an **integer** value. 
	* When set to **zero** (0), gmond will run normally. 
	* A **debug_level** greater than zero will result in gmond running in the foreground and outputting debugging information. 
	* The higher the **debug_level** the more verbose the output.
	
	
* The **mute** attribute is a **boolean**. 
	* When **true**, gmond will **not send** data regardless of any other configuration directives.

	
* The **deaf** attribute is a **boolean**. 
	* When **true**, gmond will **not receive** data regardless of any other configuration directives.
	
	
* The **allow_extra_data** attribute is a **boolean**. 
	* When **false**, gmond will not send out the **EXTRA_ELEMENT** and **EXTRA_DATA** parts of the XML. 
	* This might be useful if you are using your own frontend to the metric data and will like to save some bandwith.
	
**notes(ningg)**：**EXTRA_ELEMENT** and **EXTRA_DATA**中存储了哪些信息？
	
* The **host_dmax** value is an **integer** with units in seconds. 
	* When set to **zero** (0), gmond will never delete a host from its list even when a remote host has stopped reporting. 
	* If host_dmax is set to a positive number then gmond will flush a host after it has not heard from it for **host_dmax** seconds. By the way, dmax means **delete max**.

**notes(ningg)**：从list中删除某个host的有什么影响？gmond接收不到某个host的report信息，那留着他有什么用？如果有新增的host，gmond能够自动识别出来吗？

* The **host_tmax** value is an **integer** with units in seconds. 
	* This value represents the maximum amount of time that gmond should wait between updates from a host. 
	* As messages may get lost in the network, gmond will consider the host as being down if it has not received any messages from it after **4 times** this value. 
	* For example, if host_tmax is set to 20, the host will appear as down after 80 seconds with no messages from it. By the way, tmax means **timeout max**.

**notes(ningg)**：此处的**host_tmax**超过这一时间，认为host down，与上面的 delete host from list有什么区别？

* The **cleanup_threshold** is the minimum amount of time before gmond will cleanup any hosts or metrics where tn > dmax a.k.a. expired data.

* The **gexec** boolean allows you to specify whether gmond will announce the hosts availability to run gexec jobs. **Note**: this requires that **gexecd** is running on the host and the proper keys have been installed.

* The **send_metadata_interval** establishes an interval in which gmond will send or resend the metadata packets that describe each enabled metric. 
	* This directive by default is set to **0** which means that gmond will only send the metadata packets at startup and upon request from other gmond nodes running remotely. 
	* If a new machine running gmond is added to a cluster, it needs to announce itself and inform all other nodes of the metrics that it currently supports. 
	* In **multicast** mode, this isn't a problem because any node can request the metadata of all other nodes in the cluster. 
	* However in **unicast** mode, a resend interval must be established. The interval value is the minimum number of seconds between resends.

**notes(ningg)**：为什么**multicast**和**unicast**（组播与单播）方式有差异？

* The **override_hostname** and **override_ip** parameters allow an arbitrary hostname and/or IP (hostname can be optionally specified without IP) to use when identifying metrics coming from this host.

* The **module_dir** is an **optional** parameter indicating the directory where the **DSO** modules are to be located. 
	* If **absent**, the value to use is set at configure time with the **--with-moduledir** option which will default if omitted to the a subdirectory named "ganglia" in the directory where libganglia will be installed.

For example, in a 32-bit Intel compatible Linux host that is usually:

	/usr/lib/ganglia
  
**notes(ningg)**：**DSO** modules是什么？


###udp_send_channel

You can define as many **udp_send_channel** sections as you like within the limitations of memory and file descriptors. If **gmond** is configured as **mute** this section will be ignored.

**notes(ningg)**：说几点：

* `udp_send_channel` section，可以设置多个；
* 如果`mute`属性设置为true，则，`udp_send_channel`配置信息不会启用；

The **udp_send_channel** has a total of seven attributes: 

* mcast_join
* mcast_if
* host
* port
* ttl
* bind
* bind_hostname

**bind** and **bind_hostname** are mutually exclusive.（两个属性`bind`和`bind_hostname`互斥，只需配置一个）

For example, the 2.5.x version gmond would send on the following single channel by default...

	udp_send_channel {
	    mcast_join = 239.2.11.71
	    port       = 8649
	}

The **mcast_join** and **mcast_if** attributes are **optional**. When specified **gmond** will create the UDP socket and join the **mcast_join** multicast group and send data out the interface specified by **mcast_if**.

**notes(ningg)**：几个疑问：

* mcast_join用来标识一个multicast group，必须是IP吗？这个IP的用途是什么？IP必须是cluster中某个node吗？
* 设置了mcast_join之后，还能设置host吗？

You can use the **bind** attribute to bind to a particular local address to be used as the source for the multicast packets sent or let gmond resolve the default hostname if `bind_hostname = yes`.

If only a **host** and **port** are specified then gmond will send **unicast** UDP messages to the hosts specified.

You could specify **multiple** **unicast** hosts for redundancy as **gmond** will send UDP messages to **all** UDP channels.

Be careful though not to mix **multicast** and **unicast** attributes in the same **udp_send_channel** definition.

For example...

	udp_send_channel {
	    host = host.foo.com
	    port = 2389
	}
  
	udp_send_channel {
	    host = 192.168.3.4
	    port = 2344
	}
	
would configure gmond to send messages to two hosts. The **host** specification can be an IPv4/IPv6 address or a resolvable hostname.

The **ttl** attribute lets you modify the Time-To-Live (TTL) of outgoing messages (unicast or multicast).

###udp_recv_channel

You can specify as many udp_recv_channel sections as you like within the limits of memory and file descriptors. If gmond is configured deaf this attribute will be ignored.

The udp_recv_channel section has following attributes: mcast_join, bind, port, mcast_if, family, retry_bind and buffer. The udp_recv_channel can also have an acl definition (see ACCESS CONTROL LISTS below).

For example, the 2.5.x gmond ran with a single udp receive channel...

  udp_recv_channel {
    mcast_join = 239.2.11.71
    bind       = 239.2.11.71
    port       = 8649
  }
The mcast_join and mcast_if should only be used if you want to have this UDP channel receive multicast packets the multicast group mcast_join on interface mcast_if. If you do not specify multicast attributes then gmond will simply create a UDP server on the specified port.

You can use the bind attribute to bind to a particular local address.

The family address is set to inet4 by default. If you want to bind the port to an inet6 port, you need to specify that in the family attribute. Ganglia will not allow IPV6=>IPV4 mapping (for portability and security reasons). If you want to listen on both inet4 and inet6 for a particular port, explicitly state it with the following:

  udp_recv_channel {
    port = 8666
    family = inet4
  }
  udp_recv_channel {
    port = 8666
    family = inet6
  }
If you specify a bind address, the family of that address takes precedence. f your IPv6 stack doesn't support IPV6_V6ONLY, a warning will be issued but gmond will continue working (this should rarely happen).

Multicast Note: for multicast, specifying a bind address with the same value used for mcast_join will prevent unicast UDP messages to the same port from being processed.

The sFlow protocol (see http://www.sflow.org) can be used to collect a standard set of performance metrics from servers. For servers that don't include embedded sFlow agents, an open source sFlow agent is available on SourceForge (see http://host-sflow.sourceforge.net).

To configure gmond to receive sFlow datagrams, simply add a udp_recv_channel with the port set to 6343 (the IANA registered port for sFlow):

  udp_recv_channel {
    port = 6343
  }
Note: sFlow is unicast protocol, so don't include mcast_join join. Note: To use some other port for sFlow, set it here and then specify the port in an sflow section (see below).

gmond will fail to run if it can't bind to all defined udp_recv_channels. Sometimes, on machines configured by DHCP, for example, the gmond daemon starts before a network address is assigned to the interface. Consequently, the bind fails and the gmond daemon does not run. To assist in this situation, the boolean parameter retry_bind can be set to the value true and then the daemon will not abort on failure, it will enter a loop and repeat the bind attempt every 60 seconds:

  udp_recv_channel {
    port = 6343
    retry_bind = true
  }
If you have a large system with lots of metrics, you might experience UDP drops. This happens when gmond is not able to process the UDP fast enough from the network. In this case you might consider changing your setup into a more distributed setup using aggregator gmond hosts. Alternatively you can choose to create a bigger receive buffer:

  udp_recv_channel {
    port = 6343
    buffer = 10485760
  }
B<buffer> is specified in bytes, i.e.: 10485760 will allow 10MB UDP 
to be buffered in memory.
Note: increasing buffer size will increase memory usage by gmond

###tcp_accept_channel

You can specify as many tcp_accept_channel sections as you like within the limitations of memory and file descriptors. If gmond is configured to be mute, then these sections are ignored.

The tcp_accept_channel has the following attributes: bind, port, interface, family and timeout. A tcp_accept_channel may also have an acl section specified (see ACCESS CONTROL LISTS below).

For example, 2.5.x gmond would accept connections on a single TCP channel.

  tcp_accept_channel {
    port = 8649
  }
The bind address is optional and allows you to specify which local address gmond will bind to for this channel.

The port is an integer than specifies which port to answer requests for data.

The family address is set to inet4 by default. If you want to bind the port to an inet6 port, you need to specify that in the family attribute. Ganglia will not allow IPV6=>IPV4 mapping (for portability and security reasons). If you want to listen on both inet4 and inet6 for a particular port, explicitly state it with the following:

  tcp_accept_channel {
    port = 8666
    family = inet4
  }
  tcp_accept_channel {
    port = 8666
    family = inet6
  }
If you specify a bind address, the family of that address takes precedence. If your IPv6 stack doesn't support IPV6_V6ONLY, a warning will be issued but gmond will continue working (this should rarely happen).

The timeout attribute allows you to specify how many microseconds to block before closing a connection to a client. The default is set to -1 (blocking IO) and will never abort a connection regardless of how slow the client is in fetching the report data.

The interface is not implemented at this time (use bind).

###collection_group

You can specify as many collection_group section as you like within the limitations of memory. A collection_group has the following attributes: collect_once, collect_every and time_threshold. A collection_group must also contain one or more metric sections.

The metric section has the following attributes: (one of name or name_match; name_match is only permitted if pcre support is compiled in), value_threshold and title. For a list of available metric names, run the following command:

  % gmond -m
Here is an example of a collection group for a static metric...

  collection_group {
    collect_once   = yes
    time_threshold = 1800
    metric {
     name = "cpu_num"
     title = "Number of CPUs"
    }
  }
This collection_group entry would cause gmond to collect the cpu_num metric once at startup (since the number of CPUs will not change between reboots). The metric cpu_num would be send every 1/2 hour (1800 seconds). The default value for the time_threshold is 3600 seconds if no time_threshold is specified.

The time_threshold is the maximum amount of time that can pass before gmond sends all metrics specified in the collection_group to all configured udp_send_channels. A metric may be sent before this time_threshold is met if during collection the value surpasses the value_threshold (explained below).

Here is an example of a collection group for a volatile metric...

  collection_group {
    collect_every = 60
    time_threshold = 300
    metric {
      name = "cpu_user"
      value_threshold = 5.0
      title = "CPU User"
    }
    metric {
      name = "cpu_idle"
      value_threshold = 10.0
      title = "CPU Idle"
    }
  }
This collection group would collect the cpu_user and cpu_idle metrics every 60 seconds (specified in collect_every). If cpu_user varies by 5.0% or cpu_idle varies by 10.0%, then the entire collection_group is sent. If no value_threshold is triggered within time_threshold seconds (in this case 300), the entire collection_group is sent.

Each time the metric value is collected the new value is compared with the old value collected. If the difference between the last value and the current value is greater than the value_threshold, the entire collection group is send to the udp_send_channels defined.

It's important to note that all metrics in a collection group are sent even when only a single value_threshold is surpassed.

In addition a user friendly title can be substituted for the metric name by including a title within the metric section.

By using the name_match parameter instead of name, it is possible to use a single definition to configure multiple metrics that match a regular expression. The perl compatible regular expression (pcre) syntax is used. This approach is particularly useful for a series of metrics that may vary in number between reboots (e.g. metric names that are generated for each individual NIC or CPU core).

Here is an example of using the name_match directive to enable the multicpu metrics:

  metric {
    name_match = "multicpu_([a-z]+)([0-9]+)"
    value_threshold = 1.0
    title = "CPU-\\2 \\1"
  }
Note that in the example above, there are two matches: the alphabetical match matches the variations of the metric name (e.g. idle, system) while the numeric match matches the CPU core number. The second thing to note is the use of substitutions within the argument to title.

If both name and name_match are specified, then name is ignored.

###Modules

A modules section contains the parameters that are necessary to load a metric module. A metric module is a dynamically loadable module that extends the available metrics that gmond is able to collect. Each modules section contains at least one module section. Within a module section are the directives name, language, enabled, path and params. The module name is the name of the module as determined by the module structure if the module was developed in C/C++. Alternatively, the name can be the name of the source file if the module has been implemented in a interpreted language such as python. A language designation must be specified as a string value for each module. The language directive must correspond to the source code language in which the module was implemented (ex. language = "python"). If a language directive does not exist for the module, the assumed language will be "C/C++". The enabled directive allows a metric module to be easily enabled or disabled through the configuration file. If the enabled directive is not included in the module configuration, the enabled state will default to "yes". One thing to note is that if a module has been disabled yet the metric which that module implements is still listed as part of a collection group, gmond will produce a warning message. However gmond will continue to function normally by simply ignoring the metric. The path is the path from which gmond is expected to load the module (C/C++ compiled dynamically loadable module only). The params directive can be used to pass a single string parameter directly to the module initialization function (C/C++ module only). Multiple parameters can be passed to the module's initialization function by including one or more param sections. Each param section must be named and contain a value directive. Once a module has been loaded, the additional metrics can be discovered by invoking gmond -m.

   modules {
     module {
       name = "example_module"
       language = "C/C++"
       enabled = yes
       path = "modexample.so"
       params = "An extra raw parameter"
       param RandomMax {
         value = 75
       }
       param ConstantValue {
         value = 25
       }
     }
   }
   
###sFlow

The sflow group is optional and has the following optional attributes: udp_port, accept_vm_metrics, accept_http_metrics, accept_memcache_metrics, accept_jvm_metrics, multiple_http_instances,multiple_memcache_instances, multiple_jvm_instances. By default, a udp_recv_channel on port 6343 (the IANA registered port for sFlow) is all that is required to accept and process sFlow datagrams. To receive sFlow on some other port requires both a udp_recv_channel for the other port and a udp_port setting here. For example:

   udp_recv_channel {
     port = 7343
   }
   sflow {
     udp_port = 7343
   }
An sFlow agent running on a hypervisor may also be sending metrics for its local virtual machines. By default these metrics are ignored, but the accept_vm_metrics flag can be used to accept those metrics too, and prefix them with an identifier for each virtual machine.

   sflow {
     accept_vm_metrics = yes
   }
The sFlow feed may also contain metrics sent from HTTP or memcached servers, or from Java VMs. Extra options can be used to ignore or accept these metrics, and to indicate that there may be multiple instances per host. For example:

    sflow {
      accept_http_metrics = yes
      multiple_http_instances = yes
    }
will allow the HTTP metrics, and also mark them with a distinguishing identifier so that each instance can be trended separately. (If multiple instances are reporting and this flag is not set, the results are likely to be garbled.)

###Include

This directive allows the user to include additional configuration files rather than having to add all gmond configuration directives to the gmond.conf file. The following example includes any file with the extension of .conf contained in the directory conf.d as if the contents of the included configuration files were part of the original gmond.conf file. This allows the user to modularize their configuration file. One usage example might be to load individual metric modules by including module specific .conf files.

include ('/etc/ganglia/conf.d/*.conf')

##ACCESS CONTROL

The udp_recv_channel and tcp_accept_channel directives can contain an Access Control List (ACL). This ACL allows you to specify exactly which hosts gmond process data from.

An example of an acl entry looks like

  acl {
    default = "deny"
    access {
      ip = 192.168.0.4
      mask = 32
      action = "allow"
    }
  }
This ACL will by default reject all traffic that is not specifically from host 192.168.0.4 (the mask size for an IPv4 address is 32, the mask size for an IPv6 address is 128 to represent a single host).

Here is another example

  acl {
    default = "allow"
    access {
      ip = 192.168.0.0
      mask = 24
      action = "deny"
    }
    access {
      ip = ::ff:1.2.3.0
      mask = 120
      action = "deny"
    }
  }
This ACL will by default allow all traffic unless it comes from the two subnets specified with action = "deny".

##EXAMPLE

The default behavior for a 2.5.x gmond would be specified as...

  udp_recv_channel {
    mcast_join = 239.2.11.71
    bind       = 239.2.11.71
    port       = 8649
  }
  udp_send_channel {
    mcast_join = 239.2.11.71
    port       = 8649
  }
  tcp_accept_channel {
    port       = 8649
  }
To see the complete default configuration for gmond simply run:

  % gmond -t
gmond will print out its default behavior in a configuration file and then exit. Capturing this output to a file can serve as a useful starting point for creating your own custom configuration.

  % gmond -t > custom.conf
edit custom.conf to taste and then

  % gmond -c ./custom.conf
  
##SEE ALSO

gmond(1).

##NOTES

The ganglia web site is at http://ganglia.info/.

##COPYRIGHT

Copyright (c) 2005 The University of California, Berkeley






##参考来源



[NingG]:    								http://ningg.github.com  "NingG"




[ganglia-3.6.1(ganglia monitoring core)]:	http://sourceforge.net/projects/ganglia/files/




