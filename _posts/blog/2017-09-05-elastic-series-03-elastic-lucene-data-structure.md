---
layout: post
title: Elastic 系列：Lucene 的索引结构和查询效率
description: 相对于 MySQL，ElasticSearch 查询速度是否会更快？ElasticSearch 在检索过程中，使用的是 Lucene，其底层涉及哪些数据结构？
published: true
category: elasticsearch
---


## 0.概要

> **焦点问题**：SQL 检索效率（MySQL 为例）和 NoSQL 检索效率（ES 为例）

## 1.ElasticSearch 底层数据结构

ElasticSearch 通过 Lucene 的`倒排索引`技术，实现比关系型数据库（MySQL）更快的过滤。

**焦点问题**：

* 倒排索引，是否真的比 B-tree 索引更快？快在哪个地方？

当我们不需要支持「**快速的更新**」的时候，可以用「**预先排序**」等方式：

* 换取更小的存储空间
* 更快的检索速度等好处，
* 其代价：就是更新慢

### 1.1.Lucene 倒排索引

Lucene 倒排索引，具体的索引层级：

![](/images/elastic-series/lucene-index-layers.png)

具体几个要点：

1. **词项索引**：`term index`
	1. **使用技术**：字典数（Trie Tree）、压缩技术、内存存储
	1. **目标**：接近 O(1) 时间复杂度，定位「词项-字典」对应 block 的 offset
	1. **注意**：词项索引，只需要映射到 block，不需要映射到每一个词项
1. **词项字典**：`term dictionary`
	1. **使用技术**：分 block 存储，同一个 block 上，词项共享「同一个前缀」
	1. **目标**：定位到最终的 term
1. **倒排列表**：`posting list`
	1. **使用技术**：分块差值编码，再对每块进行 bit 压缩存储。
	1. **目标**：有序 docId，高效压缩，放入内存

为了说明 Lucene 的数据结构，以下面的原始数据为例：

|DocId|年龄|性别|
|:--:|:--:|:--:|
|1|18|女|
|2|20|女|
|3|18|男|

其中的数据模型：

* **Document**：`每一行`是一个 `document`，每个 document 都有一个 DocId，即，文档 ID。
* **倒排索引**：给这些 document 建立的倒排索引就是：年龄、性别，倒排索引是 per field 的，一个字段有一个自己的倒排索引

可以看到：

1. **term**，**词项**：18,20 这些叫做 term，关键字，搜索的关键字；
1. **Posting list**，**倒排-列表**：而 `[1,3]` 就是 Posting list，Posting list 就是一个 int 的数组，存储了所有符合某个 term 的「文档 id」。

### 1.2.term dictionary 和 term index

> 那么什么是 term dictionary 和 term index？

假设我们有很多个 term，比如：

* Carla,Sara,Elin,Ada,Patty,Kate,Selena

如果按照这样的顺序排列，找出某个特定的 term 一定很慢，因为 term 没有排序，需要全部过滤一遍才能找出特定的 term。排序之后就变成了：

* Ada,Carla,Elin,Kate,Patty,Sara,Selena

这样我们可以用二分查找的方式，比全遍历更快地找出目标的 term。这个就是 `term dictionary`。

* **term dictionary**：词项字典，其为`有序`的字典，正常情况，`二分查找`，查询效率 `O(logN)`。

有了 term dictionary 之后，可以用 logN 次磁盘查找得到目标。但是磁盘的随机读操作仍然是非常昂贵的（一次 random access 大概需要 10ms 的时间）。所以尽量少的读磁盘，有必要把一些数据缓存到内存里。但是整个 term dictionary 本身又太大了，无法完整地放到内存里。于是就有了 **term index**。

**term index** 有点像一本字典的大的章节表。比如：

* A 开头的 term ……………. Xxx 页
* C 开头的 term ……………. Xxx 页
* E 开头的 term ……………. Xxx 页

如果所有的 term 都是英文字符的话，可能这个 term index 就真的是 26 个英文字符表构成的了。但是实际的情况是，term 未必都是英文字符，term 可以是任意的 byte 数组。而且 26 个英文字符也未必是每一个字符都有均等的 term，比如 x 字符开头的 term 可能一个都没有，而 s 开头的 term 又特别多。实际的 term index 是一棵 **trie 树**（`字典树`）：

![](/images/elastic-series/trie-tree-of-lucene.png)

例子是一个包含 "A", "to", "tea", "ted", "ten", "i", "in", 和 "inn" 的 trie 树。

1. 这棵树不会包含所有的 term，它包含的是 term 的一些前缀。
1. 通过 term index 可以快速地定位到 term dictionary 的某个 offset，然后从这个位置再往后顺序查找。
1. 再加上一些压缩技术（搜索 Lucene Finite State Transducers） term index 的尺寸可以只有所有 term 的尺寸的几十分之一，使得用内存缓存整个 term index 变成可能。

![](/images/elastic-series/lucene-index-details.png)

### 1.3.ElasticSearch 查询效率

从上述分析可知：

* **ElasticSearch**：时间复杂度接近 `O(1)`，采用「`字典树` + `内存存储`」
	* **倒排索引**：有序的数据字典，根据 field 定位到数据，查找 field 时间复杂度也是 `O(logN)`
	* **term-index**：字典树结构 + 内存存储，快速定位到磁盘的 offset，定位到数据，时间复杂度接近 `O(1)`，实际为 `O(m)`，其中 `m` 为关键字的字符数量
* **MySQL**： B+ 树结构存储，时间复杂度 `O(logN)`
	* **B+树**：按照 B+ 树结构存储，时间复杂度 `O(logN)`，每次查询都可能经过多次「**寻轨**」，单次耗时 3~5 ms


关于 Lucene，额外值得一提的两点是：

* **Term index**：在内存中是以 FST（finite state transducers）的形式保存的，其特点是非常节省内存。
* **Term dictionary**：在磁盘上是以分 block 的方式保存的，一个 block 内部利用公共前缀压缩，比如都是 Ab 开头的单词就可以把 Ab 省去。这样 term dictionary 可以比 b-tree 更节约磁盘空间。

**后续内容**：

* ElasticSearch，针对**组合查询**，其效率比关系型数据库更高，底层实现细节，参考：[https://www.infoq.cn/article/database-timestamp-02](https://www.infoq.cn/article/database-timestamp-02)

## 2.参考资料

* [时间序列数据库的秘密 (2)——索引](https://www.infoq.cn/article/database-timestamp-02)
* [一文了解数据库索引：哈希、B-Tree 与 LSM](https://segmentfault.com/a/1190000018719035)
* [Elasticsearch内核解析 - 查询篇](https://zhuanlan.zhihu.com/p/34674517)

## 3.附录：思考一个场景

**焦点问题**：SQL 检索效率（MySQL 为例）和 NoSQL 检索效率（ES 为例）

**场景描述**：

1. 数据量： n kw
1. 检索条件： status字段等于 0，其中，status 可能取值为 0-9
1. MySQL 上已经针对 status 字段建立了索引，ES 也已经建立索引
1. 查询结果为 limit 10，10 条记录的所有字段都输出，而不是 select count(0) 统计计数

**我的看法**： ES 更快

* MySQL 是 B+ 树，但 status 取值很少，基于二级索引即可获取 limit 10 的 id；然后，再回表查询，走一次主索引，时间复杂度 O(log(n));
* ES 是 倒排索引方式，直接记录了 status=0 的记录，直接返回 limit 10 信息即可，时间复杂度为 O(1)

**Think**：

* 实际情况呢？到底哪一种更快呢？








[NingG]:    http://ningg.github.com  "NingG"





