---
layout: post
title: 大型网站架构：熔断、降级、限流
description: 微服务架构中，服务数量增加，整体系统可用性、稳定性都会存在问题，需要一些通用措施，来进行处理。
category: 技术架构
---


## 0.概要

微服务架构中，服务数量增加，整体系统可用性会存在潜在问题，因此，需要一些额外的措施。

具体几个方面：

1. **问题**：分布式系统架构中，存在的问题
1. **解决方法**：上述问题的解决办法？
1. **注意事项**
1. HyStrix 框架的原理

特别说明：

> [Hystrix](https://github.com/Netflix/Hystrix) 已经进入「维护状态」，现在 Netflix 已经启用「[resilience4j](https://github.com/resilience4j/resilience4j)」框架，作为替代方案。

## 1.问题

分布式系统，随着业务复杂度提高，系统不断拆分，一个面向 C 端的 API 调用，其内部的 RPC 调用层层嵌套，调用链变长，会造成下述 2 个问题：

1. **API 接口可用性降低**：
	* 假设一次 api 请求，内部涉及 30 次 rpc 调用
	* 每个微服务可用性 99.99%
	* 则，api 请求的可用性为 99.99% 的 30 次方 = 99.7% ，即，0.3% 的失败率
1. **系统阻塞，拒绝请求接入**：
	* 假设一次 api 请求，内部涉及 10 次 rpc 调用
	* 只要 10 次 rpc 中，有一次请求超时，则，整个 api 调用就超时了
	* 如果大量请求突发访问，则，大量的线程都阻塞（block 等待超时）在这一服务上，新的请求无法接入

## 2.解决方法

为了解决上述「**API 接口可用性降低**」和「**系统阻塞、拒绝请求接入**」问题，可以采用下述 4 中方法：

1. **熔断**：服务熔断，一旦触发「异常统计条件」，则，直接熔断服务，在「调用方」直接返回，不再 rpc 调用远端服务；
1. **降级**：降级是配合「熔断」的，熔断后，不再调用远端服务器的 rpc 接口，而采用本地的 fallback 机制，返回一个「备用方案」/「默认取值」；
1. **限流**：限制「速率」，或从业务层限制「总数」，被限流的请求，直接进入「降级」fallback 流程；
1. **异步 RPC**：通过异步访问，提升系统访问性能；

### 2.1.熔断

为了防止大量请求都被 block 到某个服务上，导致大量线程、端口被占用，无法处理新请求，则，引入「服务熔断」概念。

* 一旦触发「异常统计条件」，则，不再 block 等待服务的响应
* 异常统计条件，一般有下述几种：
	* 指定的`时间窗口`内，rpc 调用`失败次数的占比`，超过`设定的阈值`，则，不再 rpc 调用，直接返回「降级逻辑」

HyStrix 框架下，实现「**服务熔断**」的底层原理：

* **封装**：「客户端」不直接调用「服务器」的rpc接口，而是在「客户端」包装一层
* **屏蔽**：在「客户端」的「**包装层**」里面，实现熔断逻辑

具体 HyStrix 框架的 hello world 逻辑：

```
// 客户端：封装原生的 rpc 调用逻辑
public class CommandHelloWorld extends HystrixCommand<String> {
​
    private final String name;
​
    public CommandHelloWorld(String name) {
        super(HystrixCommandGroupKey.Factory.asKey("ExampleGroup"));
        this.name = name;
    }
​
    @Override
    protected String run() {
        //关键点：把一个RPC调用，封装在一个HystrixCommand里面
        return "Hello " + name + "!";
    }
}
​
// 客户端调用：以前是直接调用远端RPC接口，现在是把RPC接口封装到HystrixCommand里面，它内部完成熔断逻辑
String s = new CommandHelloWorld("World").execute();
```

**隔离策略**：**线程池** vs. **信号量**

上面的代码实例中，默认情况下，`HystrixCommand` 是「**线程隔离策略**」，即，直接在线程池中，获取新的线程，来执行 rpc 调用。

另外，还有一种策略是「**信号量隔离策略**」，直接在「**调用线程**」中执行，通过「**信号量**」进行隔离。

Think：

> 上述隔离策略「线程池」和「信号量」，有什么优劣？适用场景？

上述「线程池」和「信号量」2 种隔离方式，其优缺点：

* **线程池**：
	* **缺点**：增加计算开销，每个 rpc 请求，被独立的线程执行，其中，涉及线程调度、上下文切换、请求排队等时间。
	* **Note**：Netflix 公司内部实践认为，线程隔离的开销足够小，不会产生重大成本或者性能影响。
	* **适用**：依赖网络访问的请求，可以采用「线程池隔离」，只依赖内存缓存的情况下，建议采用「信号量隔离」。
* **信号量**：
	* **适用**：只依赖内存缓存、不涉及网络访问，建议采用「信号量隔离」方式。

熔断参数的设置：熔断器的参数

* circuitBreaker.requestVolumeThreshold：//滑动窗口的大小，默认为`20`
* circuitBreaker.errorThresholdPercentage： //错误率，默认`50%`
* circuitBreaker.sleepWindowInMilliseconds： //过多长时间，熔断器再次检测是否开启，默认为`5000`，即`5s`钟

上述 3 个参数，放在一起的物理含义：

> 每当`20`个请求中，有`50%`失败时，熔断器就会**断开**，此时，再调用此服务，将不再调远程服务，直接返回失败。
> 
> `5s` 后，`重新检测`该触发条件，判断是否熔断器连接，或者继续保持断开。

### 2.2.降级

**降级**，是配合「**熔断**」存在的。

**降级**，就是**服务熔断**之后，不再调用服务器的 rpc 接口，客户端直接准备一个本地的 fallback 回调，返回一个缺省值。

**影响**：

* 上述「**服务降级**」，直接本地 fallback，给一个`缺省值`/`备用方案`
* 相对直接挂掉，要好一些，具体还要看业务场景，特别是采用「合适的 fallback 方案」

### 2.3.限流

**限流**，在现实生活中，也比较常见，比如节假日去旅游景点，管理部门通常会在外面设置拦截，限制景点的进入人数（等有人出来之后，再放新的人进去）。

对应到分布式系统中，比如活动、秒杀，也会限流。

> **关键点**：限流的目标和依据，是什么？

常见的，`限流依据`下述参数进行：

1. HyStrix 中：
	1. 线程隔离时，线程数 + 排队队列大小，来限流
	1. 信号量隔离时，设置「最大并发请求数」，来限流
1. **并发数量**：QPS、并发连接数等
1. **总量**：业务层中，限制「库存」总量等

限流技术原理：

* 限制「速率」：令牌桶算法
* 限制「总数」：限制某个业务量的 count 值，则，具体业务场景具体分析。

TODO：

* Guava 的 `RateLimiter` 也已经有成熟做法。

### 2.4.异步 RPC

异步 RPC，主要目标：提升系统的`接口性能`，从而提升并发处理能力。

启用「异步 RPC」，有一个前提，异步 RPC 之间，不存在「相互依赖」。

实例：

1. 比如你的接口，内部调用了3个服务，时间分别为T1, T2, T3。
1. 如果是顺序调用，则总时间是T1 + T2 + T3；
1. 如果并发调用，总时间是Max(T1,T2,T3)。

一般成熟的RPC框架，本身都提高了异步化接口，Future或者Callback形式。

同样，Hystrix 也提高了同步调用、异步调用方式，此处不再详述。

## 3.总结

熔断、降级、限流、异步 RPC，都是分布式服务框架中，常用的策略，能够提升系统稳定性、容错性。当前大部分服务框架，都对这些策略，有比较好的原生支持。

## 4.参考资料

* [https://github.com/Netflix/Hystrix](https://github.com/Netflix/Hystrix)
* [https://github.com/resilience4j/resilience4j](https://github.com/resilience4j/resilience4j)
* [https://blog.csdn.net/chunlongyu/article/details/53259014](https://blog.csdn.net/chunlongyu/article/details/53259014)
* [https://www.jianshu.com/p/3e11ac385c73](https://www.jianshu.com/p/3e11ac385c73)























[NingG]:    http://ningg.github.com  "NingG"

