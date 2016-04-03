---
layout: post
title: MySQL中Explain命令
description: Explain命令详解
published: true
category: MySQL
---

几点：

* 查询当前表格的索引；
* 执行查询语句；
* 分析查询语句的执行计划；




查询当前表格的索引：`show index from tbl_name`


具体执行过程如下：

![](/images/mysql-explain-cmd/explain-cmd.png)

以及如下：

![](/images/mysql-explain-cmd/explain-details.png)


关于`EXPLAIN`命令输出的详细信息，参考[EXPLAIN Output Format]；下面简要说几点：

* possible_keys
* key
* key_len




更多内容，可以参考：[MySQL EXPLAIN 命令详解学习]和[EXPLAIN Output Format]。





















## 参考来源

* [MySQL EXPLAIN 命令详解学习]
* [EXPLAIN Output Format]








[NingG]:    http://ningg.github.com  "NingG"



[EXPLAIN Output Format]:			http://dev.mysql.com/doc/refman/5.6/en/explain-output.html
[MySQL EXPLAIN 命令详解学习]:		http://blog.csdn.net/woshiqjs/article/details/24135495




