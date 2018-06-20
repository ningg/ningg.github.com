---
layout: post
title: JVM 实践：jps、jinfo、jstat 命令详解
description: 查询 JVM 的启动参数
published: true
categories: jvm
---

## 背景

JVM 性能调优、问题排查过程中，常用几个命令，逐个分析一下细节：

* `jps`：获取 jvm 进程的列表，获取 pid，jvm process status，类似 `ps`
* `jinfo`：
* `jstat`


## jps 命令

`jps` 命令的作用：查看`有权限`访问的 JVM 进程列表。

常用操作：

```
# 输出：
# 1. pid
# 2. 完整的 main Class 类名
# 3. main 入口参数
# 4. jvm 启动参数

jps -lmv
```

命令的详细介绍：

```
jps [ options ] [ hostid ]
```

### options

`jps` 命令，可以配置的几个选项：

* `-l`：显示，完整的 main Class 类名
* `-m`：显示，main 函数的入口参数
* `-v`：显示，JVM 启动参数

示例：

```
[root@ningg ~]# jps
12593 Main
45370 Jps


[root@ningg ~]# jps -l
12593 org.jruby.Main
45518 sun.tools.jps.Jps


[root@ningg ~]# jps -m
12593 Main /usr/share/logstash/lib/bootstrap/environment.rb logstash/runner.rb --path.settings /etc/logstash --node.name mini.ningg.top
45751 Jps -m


[root@ningg ~]# jps -v
12593 Main -XX:+UseParNewGC -XX:+UseConcMarkSweepGC -XX:CMSInitiatingOccupancyFraction=75 -XX:+UseCMSInitiatingOccupancyOnly -XX:+DisableExplicitGC -Djava.awt.headless=true -Dfile.encoding=UTF-8 -XX:+HeapDumpOnOutOfMemoryError -Xmx1g -Xms256m -Xss2048k -Djffi.boot.library.path=/usr/share/logstash/vendor/jruby/lib/jni -Xbootclasspath/a:/usr/share/logstash/vendor/jruby/lib/jruby.jar -Djruby.home=/usr/share/logstash/vendor/jruby -Djruby.lib=/usr/share/logstash/vendor/jruby/lib -Djruby.script=jruby -Djruby.shell=/bin/sh
46152 Jps -Dapplication.home=/usr/java/jdk1.8.0_131 -Xms8m
```


### hostid
需要说明的几个细节：

* jps 默认，查询 `本机` 的 JVM 进程列表
* jps 也可以查询 `远端服务器` 的 JVM 进程列表
	* 上述 `hostid` 就是`远端服务器`的地址
	* 一般要求 `远端服务器` 上运行 `jstatd` 进程


## jinfo 命令

`jinfo` 命令：运行环境参数，Java System 属性、JVM 命令参数，class path 等

常用操作：

```
# 输出：
# a. Java System 属性
# b. JVM 命令参数
# c. class path 信息
jinfo [pid]
```

命令详细介绍：

```
jinfo [ option ] pid
```

### option

具体几个选项：

* `no option`：同时输出 JVM 配置和命令行参数和 Java System 属性
* `-flags`：JVM 配置和命令行参数
* `-sysprops`：Java System 属性

补充信息：下述选项，属于慎重设置的选项

* `-flag [args]`：查询指定参数的取值
* `-flag [+|-]name`：开启 or 关闭某个 `bool 类型`参数
* `-flag name=value`： 设置某个`取值类型`参数

特别说明：

> `有些参数` 支持 `jinfo 命令` 设置，有些参数，不支持 `jinfo 命令` 设置。

使用下述命令，查询哪些 JVM 参数可以设置：

```bash
# java -XX:+PrintFlagsFinal -version |grep manageable
     intx CMSAbortablePrecleanWaitMillis            = 100                                 {manageable}
     intx CMSTriggerInterval                        = -1                                  {manageable}
     intx CMSWaitDuration                           = 2000                                {manageable}
     bool HeapDumpAfterFullGC                       = false                               {manageable}
     bool HeapDumpBeforeFullGC                      = false                               {manageable}
     bool HeapDumpOnOutOfMemoryError                = false                               {manageable}
    ccstr HeapDumpPath                              =                                     {manageable}
    uintx MaxHeapFreeRatio                          = 100                                 {manageable}
    uintx MinHeapFreeRatio                          = 0                                   {manageable}
     bool PrintClassHistogram                       = false                               {manageable}
     bool PrintClassHistogramAfterFullGC            = false                               {manageable}
     bool PrintClassHistogramBeforeFullGC           = false                               {manageable}
     bool PrintConcurrentLocks                      = false                               {manageable}
     bool PrintGC                                   = false                               {manageable}
     bool PrintGCDateStamps                         = false                               {manageable}
     bool PrintGCDetails                            = false                               {manageable}
     bool PrintGCID                                 = false                               {manageable}
     bool PrintGCTimeStamps                         = false                               {manageable}
java version "1.8.0_131"
Java(TM) SE Runtime Environment (build 1.8.0_131-b11)
Java HotSpot(TM) 64-Bit Server VM (build 25.131-b11, mixed mode)
```

备注： `java -XX:+PrintFlagsFinal -version` 命令，表示输出所有参数.

### 示例

jinfo 命令的具体输出信息

#### flags

具体示例：

```
$ jinfo -flags 44736
Attaching to process ID 44736, please wait...
Debugger attached successfully.
Server compiler detected.
JVM version is 25.131-b11
Non-default VM flags: -XX:CICompilerCount=4 -XX:InitialHeapSize=268435456 -XX:MaxHeapSize=4294967296 -XX:MaxNewSize=1431306240 -XX:MinHeapDeltaBytes=524288 -XX:NewSize=89128960 -XX:OldSize=179306496 -XX:+UseCompressedClassPointers -XX:+UseCompressedOops -XX:+UseFastUnorderedTimeStamps -XX:+UseParallelGC
Command line:  -agentlib:jdwp=transport=dt_socket,address=127.0.0.1:55041,suspend=y,server=n -Dfile.encoding=UTF-8
```

上述信息，输出了：

* JVM 配置： flags
* JVM 命令参数： Command line

#### sysprops

具体示例：

```
$ jinfo -sysprops 44736
Attaching to process ID 44736, please wait...
Debugger attached successfully.
Server compiler detected.
JVM version is 25.131-b11
java.runtime.name = Java(TM) SE Runtime Environment
java.vm.version = 25.131-b11
sun.boot.library.path = /Library/Java/JavaVirtualMachines/jdk1.8.0_131.jdk/Contents/Home/jre/lib
gopherProxySet = false
java.vendor.url = http://java.oracle.com/
java.vm.vendor = Oracle Corporation
path.separator = :
file.encoding.pkg = sun.io
java.vm.name = Java HotSpot(TM) 64-Bit Server VM
sun.os.patch.level = unknown
sun.java.launcher = SUN_STANDARD
user.country = CN
user.dir = /Users/guoning/ningg/github/jvm
java.vm.specification.name = Java Virtual Machine Specification
java.runtime.version = 1.8.0_131-b11
java.awt.graphicsenv = sun.awt.CGraphicsEnvironment
os.arch = x86_64
java.endorsed.dirs = /Library/Java/JavaVirtualMachines/jdk1.8.0_131.jdk/Contents/Home/jre/lib/endorsed
java.io.tmpdir = /var/folders/w1/28b687hj1n1cngq28t956tzm0000gp/T/
line.separator =

java.vm.specification.vendor = Oracle Corporation
os.name = Mac OS X
sun.jnu.encoding = UTF-8
java.library.path = /Users/guoning/Library/Java/Extensions:/Library/Java/Extensions:/Network/Library/Java/Extensions:/System/Library/Java/Extensions:/usr/lib/java:.
java.specification.name = Java Platform API Specification
java.class.version = 52.0
sun.management.compiler = HotSpot 64-Bit Tiered Compilers
os.version = 10.13.4
user.home = /Users/guoning
user.timezone =
java.awt.printerjob = sun.lwawt.macosx.CPrinterJob
file.encoding = UTF-8
java.specification.version = 1.8
user.name = guoning
java.class.path = /Library/Java/JavaVirtualMachines/jdk1.8.0_131.jdk/Contents/Home/jre/lib/charsets.jar:/Library/Java/JavaVirtualMachines/jdk1.8.0_131.jdk/Contents/Home/jre/lib/deploy.jar:/Library/Java/JavaVirtualMachines/jdk1.8.0_131.jdk/Contents/Home/jre/lib/ext/cldrdata.jar:/Library/Java/JavaVirtualMachines/jdk1.8.0_131.jdk/Contents/Home/jre/lib/ext/dnsns.jar:/Library/Java/JavaVirtualMachines/jdk1.8.0_131.jdk/Contents/Home/jre/lib/ext/jaccess.jar:/Library/Java/JavaVirtualMachines/jdk1.8.0_131.jdk/Contents/Home/jre/lib/ext/jfxrt.jar:/Library/Java/JavaVirtualMachines/jdk1.8.0_131.jdk/Contents/Home/jre/lib/ext/localedata.jar:/Library/Java/JavaVirtualMachines/jdk1.8.0_131.jdk/Contents/Home/jre/lib/ext/nashorn.jar:/Library/Java/JavaVirtualMachines/jdk1.8.0_131.jdk/Contents/Home/jre/lib/ext/sunec.jar:/Library/Java/JavaVirtualMachines/jdk1.8.0_131.jdk/Contents/Home/jre/lib/ext/sunjce_provider.jar:/Library/Java/JavaVirtualMachines/jdk1.8.0_131.jdk/Contents/Home/jre/lib/ext/sunpkcs11.jar:/Library/Java/JavaVirtualMachines/jdk1.8.0_131.jdk/Contents/Home/jre/lib/ext/zipfs.jar:/Library/Java/JavaVirtualMachines/jdk1.8.0_131.jdk/Contents/Home/jre/lib/javaws.jar:/Library/Java/JavaVirtualMachines/jdk1.8.0_131.jdk/Contents/Home/jre/lib/jce.jar:/Library/Java/JavaVirtualMachines/jdk1.8.0_131.jdk/Contents/Home/jre/lib/jfr.jar:/Library/Java/JavaVirtualMachines/jdk1.8.0_131.jdk/Contents/Home/jre/lib/jfxswt.jar:/Library/Java/JavaVirtualMachines/jdk1.8.0_131.jdk/Contents/Home/jre/lib/jsse.jar:/Library/Java/JavaVirtualMachines/jdk1.8.0_131.jdk/Contents/Home/jre/lib/management-agent.jar:/Library/Java/JavaVirtualMachines/jdk1.8.0_131.jdk/Contents/Home/jre/lib/plugin.jar:/Library/Java/JavaVirtualMachines/jdk1.8.0_131.jdk/Contents/Home/jre/lib/resources.jar:/Library/Java/JavaVirtualMachines/jdk1.8.0_131.jdk/Contents/Home/jre/lib/rt.jar:/Library/Java/JavaVirtualMachines/jdk1.8.0_131.jdk/Contents/Home/lib/ant-javafx.jar:/Library/Java/JavaVirtualMachines/jdk1.8.0_131.jdk/Contents/Home/lib/dt.jar:/Library/Java/JavaVirtualMachines/jdk1.8.0_131.jdk/Contents/Home/lib/javafx-mx.jar:/Library/Java/JavaVirtualMachines/jdk1.8.0_131.jdk/Contents/Home/lib/jconsole.jar:/Library/Java/JavaVirtualMachines/jdk1.8.0_131.jdk/Contents/Home/lib/packager.jar:/Library/Java/JavaVirtualMachines/jdk1.8.0_131.jdk/Contents/Home/lib/sa-jdi.jar:/Library/Java/JavaVirtualMachines/jdk1.8.0_131.jdk/Contents/Home/lib/tools.jar:/Users/guoning/ningg/github/jvm/target/classes:/Users/guoning/.m2/repository/junit/junit/4.12/junit-4.12.jar:/Users/guoning/.m2/repository/org/hamcrest/hamcrest-core/1.3/hamcrest-core-1.3.jar:/Applications/IntelliJ IDEA.app/Contents/lib/idea_rt.jar
java.vm.specification.version = 1.8
sun.arch.data.model = 64
sun.java.command = top.ningg.java.App
java.home = /Library/Java/JavaVirtualMachines/jdk1.8.0_131.jdk/Contents/Home/jre
user.language = zh
java.specification.vendor = Oracle Corporation
user.language.format = en
awt.toolkit = sun.lwawt.macosx.LWCToolkit
java.vm.info = mixed mode
java.version = 1.8.0_131
java.ext.dirs = /Users/guoning/Library/Java/Extensions:/Library/Java/JavaVirtualMachines/jdk1.8.0_131.jdk/Contents/Home/jre/lib/ext:/Library/Java/Extensions:/Network/Library/Java/Extensions:/System/Library/Java/Extensions:/usr/lib/java
sun.boot.class.path = /Library/Java/JavaVirtualMachines/jdk1.8.0_131.jdk/Contents/Home/jre/lib/resources.jar:/Library/Java/JavaVirtualMachines/jdk1.8.0_131.jdk/Contents/Home/jre/lib/rt.jar:/Library/Java/JavaVirtualMachines/jdk1.8.0_131.jdk/Contents/Home/jre/lib/sunrsasign.jar:/Library/Java/JavaVirtualMachines/jdk1.8.0_131.jdk/Contents/Home/jre/lib/jsse.jar:/Library/Java/JavaVirtualMachines/jdk1.8.0_131.jdk/Contents/Home/jre/lib/jce.jar:/Library/Java/JavaVirtualMachines/jdk1.8.0_131.jdk/Contents/Home/jre/lib/charsets.jar:/Library/Java/JavaVirtualMachines/jdk1.8.0_131.jdk/Contents/Home/jre/lib/jfr.jar:/Library/Java/JavaVirtualMachines/jdk1.8.0_131.jdk/Contents/Home/jre/classes
java.vendor = Oracle Corporation
file.separator = /
java.vendor.url.bug = http://bugreport.sun.com/bugreport/
sun.io.unicode.encoding = UnicodeBig
sun.cpu.endian = little
sun.cpu.isalist =
```

关注几个信息：

* java.class.path：类加载路径
* java.vm.info：JVM 的模式，一般都为混合模式
* java.home：Java 安装路径


## jstat 命令

> 下文所有内容，都是针对 JDK8 来描述的

jstat命令可以查看堆内存各部分的使用量，以及加载类的数量。

命令的格式如下：

```
jstat [-命令选项] [vmid] [间隔时间/毫秒] [查询次数]
```

其中，选项：

* `-h n`：每输出 `n` 行，就输出一行 header
* class: Displays statistics about the behavior of the class loader.
* compiler: Displays statistics about the behavior of the Java HotSpot VM Just-in-Time compiler.
* gc: Displays statistics about the behavior of the garbage collected heap.
* gccapacity: Displays statistics about the capacities of the generations and their corresponding spaces.
* gccause: Displays a summary about garbage collection statistics (same as -gcutil), with the cause of the last and current (when applicable) garbage collection events.
* gcnew: Displays statistics of the behavior of the new generation.
* gcnewcapacity: Displays statistics about the sizes of the new generations and its corresponding spaces.
* gcold: Displays statistics about the behavior of the old generation and metaspace statistics.
* gcoldcapacity: Displays statistics about the sizes of the old generation.
* gcmetacapacity: Displays statistics about the sizes of the metaspace.
* gcutil: Displays a summary about garbage collection statistics.
* printcompilation: Displays Java HotSpot VM compilation method statistics.

几个术语：

* S0：survivor space 0，新生代-幸存者0区
* S1：survivor space 1，新生代-幸存者1区
* S0C：S0 Capacity (kB)
* S0U：S0 Utilization (kB)
* E：eden space，新生代-伊甸区
* O：old space，老年代
* M：Metaspace，元数据区
* CCS：Compressed class space，压缩类空间
* YGC：Number of young generation garbage collection events，年轻代 Young GC 的次数
* YGCT：Young generation garbage collection time，年轻代 Young GC 累计时间（s）
* FGC: Number of full GC events，老年代 Full GC 的次数
* FGCT: Full garbage collection time，老年代 Full GC 的累计时间（s）
* GCT: Total garbage collection time，累计 GC 的时间
* MN：Minimum，最小的
* MX：Maximum，最大的
* OGCMN：Old Generation Capacity MN，老年代容量的最大取值（kB）

几个常用命令：

```
# 查询 GC 基本情况，以及 GC 次数和 GC 累计时间（s）
jstat -gc -h5 [pid] 1s 20

# 查询 GC 基本情况，容量使用情况
jstat -gcutil -h5 [pid] 1s 20

# 查询「堆」空间分配情况，最大值、最小值、当前值，以及是否在动态扩容
jstat -gccapacity -h5 [pid] 1s 20
```


## 附录

### JVM 模式

查询 JVM 版本：`java -version` 通常会出现 `mixed mode` 是什么含义？

JVM有以下 2 种模式：

* `-Xmixed` ：默认，混合模式（编译器、解释器）
* `-Xint`：解释器模式

使用下述命令，可以验证：

```
$ java -Xint -version
java version "1.8.0_131"
Java(TM) SE Runtime Environment (build 1.8.0_131-b11)
Java HotSpot(TM) 64-Bit Server VM (build 25.131-b11, interpreted mode)

$ java -version
java version "1.8.0_131"
Java(TM) SE Runtime Environment (build 1.8.0_131-b11)
Java HotSpot(TM) 64-Bit Server VM (build 25.131-b11, mixed mode)
```

备注：通过 `java -X` 可以查看基本所有的命令.


`-Xint`：代表解释模式(interpreted mode)

* `解释方式`执行所有的`字节码`
* 执行`速度慢`，通常低10倍或更多

`-Xmixed`代表混合模式(mixed mode)：

* JVM的`默认`工作模式
* 同时使用`编译模式`和`解释模式`
* 对于`字节码`中多次被调用的部分，JVM会将其编译成`本地代码`以提高执行效率；
* 而被调用很少（甚至只有一次）的方法在解释模式下会继续执行，从而`减少编译`和优化成本。
* JIT编译器在运行时创建方法使用文件，然后一步一步的优化每一个方法，有时候会主动的优化应用的行为。这些优化技术，比如积极的分支预测（optimistic branch prediction），如果不先分析应用就不能有效的使用。这样将频繁调用的部分提取出来，编译成本地代码，也就是在应用中构建某种热点（即HotSpot，这也是HotSpot JVM名字的由来）；
* 使用混合模式可以获得最好的`执行效率`；






[NingG]:    http://ningg.github.com  "NingG"











