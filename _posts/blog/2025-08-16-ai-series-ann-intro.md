---
layout: post
title: AI 实践：ANN 近似最近邻检索
description: Approximate Nearest Neighbor，近似最近邻检索，常见的数据结构
published: true
categories: AI 
---

> 疑问：向量检索（embedding + ANN） , 其中的 ANN 是什么？

这个 **ANN** 不是人工神经网络 (Artificial Neural Network)，而是：

* ANN 是 Approximate Nearest Neighbor 的缩写，中文翻译为"近似最近邻检索"。

## 1. 为什么需要 ANN？

在向量检索里，**每个文档片段都被编码成一个高维向量（embedding）**。

* 用户提问 --> 也会被编码成一个向量
* 检索任务 --> 找到"和这个向量最接近"的若干文档向量

但问题是：

* 假设有 **上百万 / 上亿** 的向量，
* 每次都要做精确的最近邻搜索（逐个计算欧氏距离或余弦相似度），代价太大，速度太慢。

所以，引入 **ANN**：它放弃"完全精确"，转而使用高效的数据结构和算法来快速找到**近似的、但几乎一样好的最近邻**。


## 2. 常见的 ANN 算法 / 数据结构

几类主流方法：

1. **树结构 (Tree-based)**

   * KD-Tree, Ball Tree 等
   * 适合低维数据，高维失效（curse of dimensionality）

2. **哈希 (Hash-based)**

   * LSH (Locality-Sensitive Hashing)
   * 把相似向量映射到相同桶里，加速查找

3. **图结构 (Graph-based)**

   * HNSW (Hierarchical Navigable Small World)
   * 建立"向量之间的邻居图"，查询时像爬图一样跳跃搜索
   * 目前是业界主流（比如 Milvus、Faiss、Weaviate 都支持）

4. **量化 (Quantization-based)**

   * PQ (Product Quantization)、IVF-PQ 等
   * 用压缩技术减少存储，并在粗粒度的索引上缩小候选范围


## 3. 应用场景

* **搜索引擎 / RAG**：检索与问题最相关的文档片段
* **推荐系统**：找"相似用户"或"相似物品"
* **图像/音频检索**：找"相似图片"或"相似音频片段"


## 4. 总结

**ANN 就是"为了在海量向量库里快速找到近似的最近邻"的算法集合**，是向量检索的核心基础设施。


## 5. HNSW 索引结构

在 **LLM（大语言模型）** 相关的 **向量检索 / ANN（Approximate Nearest Neighbor, 近似最近邻）** 场景里，
你提到的 **HNSW** 是一种非常常用的索引结构，含义是：

**HNSW = Hierarchical Navigable Small World graph**

中文可理解为 **“分层可导航小世界图”**。


### 5.1.核心思想

* **小世界图（Small World Graph）**
  小世界网络的特性是：绝大部分点之间的最短路径非常短（通常是对数级别）。这让在高维空间里找到近似邻居变得高效。

* **分层（Hierarchical）**
  HNSW 在多层图结构上组织数据：

  * 顶层是稀疏图，点少，能快速缩小范围。
  * 越往下层，点越多，图越密，能更精细地找到最近邻。
  * 检索时先在顶层找到一个较近的入口点，再逐层下降，直到最底层找到近似最近邻。

* **可导航（Navigable）**
  图的边设计成可以高效“导航”，从任意入口都能较快走向目标区域。


### 5.2.工作流程

1. **构建索引**：
   把每个向量插入到 HNSW 图中，同时更新不同层的邻居关系。
2. **查询**：

   * 从高层入口点开始搜索。
   * 每一层逐步下降，范围越来越精细。
   * 到最底层时，就能得到近似最近邻结果。

### 5.3.为什么 LLM 场景喜欢 HNSW？

在 LLM 的 **RAG（检索增强生成）** 或 **embedding 检索** 里，通常要从 **百万 / 亿级别** 的向量库里找到最相关的上下文。

* 传统 **暴力搜索（brute force）**：要计算每个向量的相似度，复杂度是 O(N)。
* **HNSW**：检索复杂度近似 O(log N)，速度非常快，而且召回率很高（接近精确搜索）。

常见向量数据库（如 FAISS、Milvus、Weaviate、Pinecone 等）几乎都实现了 HNSW。











[NingG]:    http://ningg.github.io  "NingG"










