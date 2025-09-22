---
layout: post
title: AI 系列：Embedding 与 Rerank
description: Embedding、Rerank 细节描述
published: true
category: AI
---

embedding model 和 reranker model 的排行榜单：

* [MTEB](https://huggingface.co/spaces/mteb/leaderboard)，Massive Text Embedding Benchmark
* [Qwen/Qwen3-Reranker-8B](https://huggingface.co/Qwen/Qwen3-Reranker-8B)，Reranker 的部分评分


RAG系统中, 通常会有几个设置:

1.  embedding模型
2.  rerank模型
3.  TopK, TopN

Embedding 比较好理解, 将内容打成向量, 然后可以在查找时通过 夹角大小/余弦相似度找到最接近的向量, 换言之完成了`相似度`​的寻找.

## 1. Embedding 嵌入

**Embedding** 是RAG流程的**第一步**，属于 **“召回（Retrieval）”** 阶段。

*   **核心定义**： Embedding是一种将离散的文本信息（如单词、句子、文档）转换为**稠密、连续的数字向量（Vector）** 的技术。这个向量可以被认为是文本在多维空间中的一个“坐标”，它捕捉了文本的**语义信息**。
    
*   **在RAG中的目标**：**实现高效的语义相似度搜索**。计算机无法直接理解“苹果”和“iPhone”有关联，但通过Embedding模型，这两个词的向量在空间中的位置会非常接近。这使得我们可以通过计算向量间的距离（如余弦相似度）来判断文本间的相关性。
    
*   **工作流程**：

    1.  **离线索引（Indexing）** ：在RAG系统搭建时，我们会预先将知识库中所有的文档块（Chunks）通过一个Embedding模型（如 OpenAI的`text-embedding-ada-002`​ 或开源的 `BGE`​ 系列模型）转换成向量，并存入专门的**向量数据库（Vector Database）** 中。
    2.  **在线查询（Querying）** ：当用户提出问题时，系统使用**同一个Embedding模型**将用户的问题也转换成一个向量。
    3.  **向量检索（Search）** ：系统在向量数据库中，搜索与用户问题向量最“接近”的文档向量，并返回Top-K个（比如K=20）最相似的文档块。

*   **关键特点**：    

    *   **快**：向量检索非常高效，可以在毫秒内从数十亿的向量中找到最近邻。
    *   **广（高召回率）** ：它的目标是“宁可错杀，不能放过”，确保所有可能相关的文档都被包含在初步结果中。
    *   **语义理解**：它超越了传统的关键词匹配，能理解“如何修复我的电脑？”和“我的笔记本无法启动”是相似的问题。

## 2. Rerank 重排

**Rerank** 是RAG流程的**可选但强烈推荐的第二步**，属于 **“精排（Ranking）”** 阶段，发生在Embedding召回之后，LLM生成之前。

*   **核心定义**： Rerank是一种利用更复杂的模型，对Embedding初步检索出的文档列表进行**重新排序**，以提高最相关文档排在最前面的概率的技术。
    
*   **为什么需要Rerank？** Embedding的“快”和“广”是有代价的。它有时会召回一些仅是主题相关但并非答案所在的文档。例如，提问“RAG中的Rerank模型有哪些推荐？”，Embedding可能会召回所有介绍RAG、Embedding和Rerank的文章，但Rerank模型的目标是精准地将那篇**专门对比和推荐Rerank模型**的文章排到第一位。
    
*   **工作流程**：
    
    1.  **输入**：Rerank模型的输入是**用户原始问题**和**Embedding召回的每一个文档块**。它是一个 **(query, document)** 对。
    2.  **计算相关性分数**：Rerank模型（通常是**交叉编码器/Cross-Encoder**）会同时分析问题和文档，输出一个精确的相关性分数（e.g., a score from 0 to 1）。这个过程比Embedding的独立编码要慢得多，因为它需要对每个文档和查询的组合进行深度分析。
    3.  **重新排序**：根据得到的相关性分数，对初步召回的文档列表进行降序排列。
    4.  **筛选**：只保留重排后分数最高的Top-N个（比如N=5）文档，传递给最终的LLM。

*   **关键特点**：
    
    *   **准（高精确率）** ：因为它同时考虑了问题和文档的交互，所以对相关性的判断非常精准。
    *   **慢**：计算成本远高于Embedding。因此，它只适用于处理一个已经经过初筛的小批量文档（比如20-50个），而不是整个知识库。
    *   **降噪**：能有效过滤掉Embedding召回结果中的“噪音”文档，为LLM提供更高质量、更专注的上下文信息，从而提升最终答案的质量。

## 3. TopK/TopN

这两个是参数，而不是模型。它们是用来控制流程中“数量”的“阀门”。在RAG流程中，我们通常会区分使用它们。

*   **TopK (用于召回阶段):**
    
    *   **作用：** 这是**Embedding模型检索后，返回的候选文档数量**。比如，你设置 `K=50`​，意味着Embedding模型会从整个知识库中，找出与查询最相似的 **50** 个文档。
    *   **目的：** `K`​ 值通常设置得比较大。这是为了保证**高召回率**，即确保真正的答案大概率包含在这 `K`​ 个结果中，给后续的Rerank模型提供充足的、高质量的候选材料。
*   **TopN (用于最终选择):**
    
    *   **作用：** 这是**Rerank模型排序后，最终选择送给LLM的文档数量**。比如，你设置 `N=3`​，意味着系统会从Rerank排序后的结果中，挑选出最顶部的 **3** 个文档。
    *   **目的：** `N`​ 值通常设置得比较小。这是因为LLM的上下文窗口（Context Window）是有限的，不能无限输入信息。选择最相关、信息最浓缩的 `N`​ 个文档，可以获得最佳的生成效果，同时避免无关信息干扰LLM的判断。
*   **区别 (Difference):**
    
    *   **应用阶段不同：** `TopK`​ 用于召回阶段的输出，是Rerank模型的**输入**。`TopN`​ 用于精排阶段的输出，是LLM的**输入**。
    *   **数量大小不同：** 通常 `K`​ 远大于 `N`​ (例如: K=50, N=3)。
    *   **目标不同：** `TopK`​ 关注“别漏掉”，`TopN`​ 关注“只给最好的”。

## 4. Embedding模型的评估

我们该怎么判断一个embedding是好还是坏呢? 有什么典型的评判标准呢?

以Qwen3新发布的[embedding模型博客](https://qwenlm.github.io/zh/blog/qwen3-embedding/)作为起点, 让我们继续看看.

Embedding模型的Benchmark主要围绕一个核心问题：

* 这个模型`生成的向量`，能不能在`各种任务`中**准确地衡量**出文本之间的`语义关系`？

为此，业界建立了一套标准化的评测集和评测方法，其中最著名和最权威的就是 **MTEB (Massive Text Embedding Benchmark)** 。你在Qwen的博客中看到的`MTEB-R`​, `CMTEB-R`​等，都是基于MTEB体系的。

### 4.1. 核心评测任务分类

Embedding模型的评测不是单一维度的，而是涵盖了多种任务，以全面考察其能力。MTEB将这些任务分成了几个大类：

*   **检索 (Retrieval):** 这是最核心、最常见的任务，特别是在RAG场景下。
    
    *   **做法：** 给定一个查询（Query），模型需要在庞大的文档库中找到最相关的文档。
    *   **评测指标：** 通常使用 **nDCG@k** (归一化折损累计增益) 或 **MAP@k** (平均精度均值) 等指标。简单来说，就是看模型找出的前k个结果，是不是用户真正想要的，并且想要的排得越靠前，得分越高。
    *   **例子：** Qwen的文章中提到的 `MTEB-R`​ (英文检索), `CMTEB-R`​ (中文检索), `MMTEB-R`​ (多语言检索) 和 `MTEB-Code`​ (代码检索) 都属于这一类。

*   **重排 (Reranking):** 这个任务专门用来评测Rerank模型，但其原理与Embedding模型评测相通。
    
    *   **做法：** 给定一个查询和一组候选文档（通常是检索阶段的TopK结果），模型需要对这些文档进行精准排序。
    *   **评测指标：** 同样使用nDCG、MAP等指标，但衡量的是对一个小集合的排序能力。
    *   **例子：** Qwen的文章中明确区分了`Embedding`​模型和`Reranker`​模型，并分别给出了评测结果。

*   **分类 (Classification):**
    
    *   **做法：** 将文本向量化后，训练一个简单的分类器（如逻辑回归），看这个向量能不能很好地支持对文本进行分类（如情感分析、主题分类）。
    *   **评测指标：** 准确率 (Accuracy) 或 F1分数。

*   **聚类 (Clustering):**
    
    *   **做法：** 将一组文本向量化后，进行聚类算法，看语义相近的文本是否能被分到同一个簇中。
    *   **评测指标：** V-measure 等指标。

*   **语义文本相似度 (Semantic Textual Similarity, STS):**
    
    *   **做法：** 给定两个句子，模型输出一个相似度分数（通常是计算两个句子向量的余弦相似度）。将这个分数与人类标注的“黄金标准”分数进行比较。
    *   **评测指标：** 皮尔逊（Pearson）或斯皮尔曼（Spearman）相关系数，看机器打分和人类打分的相关性有多强。

### 4.2. 标准化的评测数据集

为了公平比较，Benchmark必须在公开、标准的数据集上进行。MTEB整合了来自不同任务和语言的大量数据集。

*   **多语言能力：** Qwen的评测中特别强调了 `MMTEB-R`​ (多语言) 和 `CMTEB`​ (中文)，这表明现代的Embedding模型非常看重跨语言和多语言能力。
*   **领域适应性：** 除了通用文本，还会评测在特定领域（如代码、金融、医疗）的表现，例如 `MTEB-Code`​ 就是针对代码检索的。


> 独立的 Embedding model、Rerank Model 评估。
> 
> 
> 1.**Embedding Model 的独立评估**
> 
> **目标**：检索时 embedding 的“语义表征能力”。
> 
> 常见指标：
> 
> * **Retrieval Quality（检索质量）**
> 
>   * *Recall\@k*：Top-k 检索结果中是否包含正确答案。
>   * *Precision\@k*：Top-k 中相关文档占比。
>   * *MRR（Mean Reciprocal Rank）*：正确文档出现的倒数排名均值。
>   * *nDCG（Normalized Discounted Cumulative Gain）*：考虑排序位置的加权相关度。
> 
> * **Embedding 表征评估**
> 
>   * *Clustering Purity / NMI / ARI*：聚类效果。
>   * *STS（Semantic Textual Similarity）*：与人工打分的句子语义相似度对比。
>   * *Domain Adaptation Check*：在目标领域是否维持语义区分度。
> 
> 2.**Rerank Model 的独立评估**
> 
> **目标**：在候选文档集合中，模型是否能把“更相关”的排在前面。
> 
> 常见指标（多用于信息检索 IR 领域）：
> 
> * *MAP（Mean Average Precision）*：多个 query 的平均准确率。
> * *MRR（Mean Reciprocal Rank）*：关注第一个相关文档的排名。
> * *nDCG（Normalized Discounted Cumulative Gain）\@k*：加权排序质量，越相关的文档排得越靠前得分越高。
> * *Hit Rate\@k*：前 k 个结果里是否有相关文档。
> * *Pairwise Accuracy*：`成对`比较文档时，模型是否正确判断哪个更相关。
> 
> **总结**：
> 
> * **Embedding model** → Recall\@k, MRR, nDCG, STS
> * **Rerank model** → MAP, nDCG, Pairwise Accuracy
> 
> 这样，RAG 效果可以从 **检索-排序-生成** 三个环节独立衡量，也能整体衡量。



## 5. Reranker 的必要性

 LLM 领域里 **Reranker Model**（典型如 mMARCO、MiniCPM-Reranker、Jina Reranker）这一类模型的 **原理、必要性、和 Embedding 的区别**，后面分几个层次来讲清楚。



### 5.1. Reranker Model 的原理

* **基本目标**：对一批`候选文档`（通常由向量检索 / BM25 初筛得到 top-k）进行二次打分，`重新排序`，让和 query `语义最相关`、`信息最完整` 的文档`排在前面`。
* **输入方式**：
  * Embedding 模型是 **单塔 (bi-encoder)**：分别把 query、doc 编码成向量，通过余弦/内积计算相似度。
  * Reranker 是 **双塔/交互式 (cross-encoder)**：把 query 和 doc 拼接成一段输入（比如 `[CLS] query [SEP] document [SEP]`），让 Transformer 直接建模两者的交互。
* **输出**：一个相关性分数（通常是标量，越大越相关）。
* **代表模型**：
  * **mMARCO**：在 MS MARCO 检索任务上训练的小型 cross-encoder。
  * **MiniCPM-Reranker**：用小型 LLM 做 cross-encoder，性能接近大模型但计算更轻。
  * **Jina Reranker**：开源的 cross-encoder reranker，常配合向量检索使用。


### 5.2. 为什么需要重排（从“语义空间的信息完整性”角度看）

* **Embedding 模型的限制**：
  * 向量检索只看“**全局语义相似度**”，难以保证关键信息完全覆盖。比如：
    * Query: *“2025年特斯拉在中国的市场份额”*
    * Embedding 检索可能召回“特斯拉在中国工厂产量”文章（相关但不完整）。
  * 单塔结构下，query 和 doc 的交互是`压缩后的向量`，**丢失了局部匹配细节**（如实体、数字、年份）。
* **Reranker 的优势**：
  * 直接在 `token 级别`建模 query 和 doc 的对应关系。
  * 能`区分`“**部分相关**” vs “**完全回答了 query**”的文档。
  * 从信息完整性上，更能保证 **高相关、关键信息齐全** 的候选`排在前面`。


### 5.3. Embedding 与 Reranker 的区别

| 维度    | Embedding (Bi-Encoder) | Reranker (Cross-Encoder) |
| ----- | ---------------------- | ------------------------ |
| 架构    | query / doc `各自编码`   | query+doc `拼接一起建模`         |
| 特征    | 向量空间，语义相似度       | `token 级`交互 & 局部匹配         |
| 速度    | 快，适合大规模检索       | 慢，只能处理 top-k             |
| 召回能力  | 广义语义召回           | 精细相关性判别                  |
| 信息完整性 | 广义语义、关键信息可能缺失        | 保留更多细节                   |


### 5.4. 效果是否有提升？

* **大多数实验结论**：

  * 先用 Embedding 做粗召回，再用 Reranker 做精排，效果显著提升（`NDCG`、`MRR`、`HitRate` 等指标大幅上升）。
  * 比如 MS MARCO 排序任务上：
    * 单纯向量检索 top-10 的 **MRR\@10 约 0.34**
    * 加 reranker 后提升到 **0.40+**
* **实际应用**：
  * RAG 系统里，用户问答的质量和 top-1 文档的准确性直接相关，Reranker 可以明显减少“答非所问”。
  * 工业界默认 pipeline = **Embedding 召回 + Reranker 重排**。


### 5.5. 总结

* Embedding 用来 `快速缩小候选集`，但在语义空间压缩中，会丢失细节。
* Reranker 则从 `token 级`交互出发，保证 query 和 doc 的 `相关性、完整性、准确性`。
* 效果上，几乎所有检索/RAG 场景，`加 reranker`，都能显著提升答案相关度和用户体验。


## 6.实践：Qwen

> 现在 qwen 的 embedding 既是 embedding model 、又是 reranker model 吗？ 不是，看下面解释.

下面会梳理一下 **Qwen 系列在 embedding 和 reranker 两个角色上的定位**：


### 6.1. Qwen embedding 模型

阿里推出了 **专门的 embedding 模型**，比如：

* **`Qwen2-embedding`**（多尺寸，如 `Qwen2-embedding-7B`、`1.5B`）。
* 结构是 **bi-encoder**，只编码 query 或 doc，本质和 OpenAI 的 `text-embedding-3` 类似。
* 输出定长向量，用于向量检索 / 相似度计算。它就是纯粹的 **embedding model**。


### 6.2. Qwen 作为 Reranker

Qwen 主系 LLM（如 `Qwen2.5-7B`、`Qwen2.5-14B` 等），因为是通用生成式大模型，本身具备 **cross-encoder 风格的能力**，可以用在 **reranker** 上：

输入格式：

```
User query: xxx
Candidate doc: yyy
Please judge the relevance (0–5).
```

* 大模型会基于 token 级交互，输出一个打分。
* 这时它的角色就是 **Reranker Model**。

目前社区里常见的做法：

* 用 **Qwen LLM 做 zero-shot reranking**（不需要额外训练）。
* 或者 **微调 Qwen LLM**（Instruction-tuning / Preference-tuning），让它更适合做打分器。


### 6.3. Embedding model 不等于 Reranker model

* Qwen 的 **embedding 专用模型**（如 `Qwen2-embedding`）： 只能做向量召回，**不是 Reranker**。
* Qwen 的 **通用 LLM**（如 `Qwen2.5-7B`）： 可以当 Reranker，但不是专门为 embedding 设计。
* 所以，它们是 **两个不同的分支**：
  * **Embedding**：高效，低延迟，适合大规模召回。
  * **Reranker**：高质量，高计算成本，适合 top-k 重排。


### 6.4. 总结

* **Qwen 有专门的 embedding 模型**，是 `bi-encoder`，不能直接做 reranker。
* **Qwen 的通用 LLM** 可以用作 reranker，但和 embedding 模型是不同的。
* 工业界 pipeline 依旧是：**Qwen-embedding → 粗召回 → Qwen-LLM（或小型 cross-encoder）rerank**。

## 7.实践：MTEB，reranking 任务

> 为什么 [https://huggingface.co/spaces/mteb/leaderboard](https://huggingface.co/spaces/mteb/leaderboard) 中，针对 embedding model 打分的排行榜，也有 reranking 的打分？

这个问题其实涉及到 **MTEB (Massive Text Embedding Benchmark)** 的设计逻辑，以及“为什么 embedding 模型也能在 reranking 任务上被打分”。


### 7.1. MTEB 的设计目标

* MTEB 是 HuggingFace 社区推出的 **统一评测基准**，核心思想是：“Embedding models `不只`是用来做`检索`，也要看它们在`多种任务`中的`泛化表现`。”
* 因此，MTEB 不仅包含 **检索 (retrieval)**，还包括：
  * Clustering
  * Classification
  * STS (Semantic Textual Similarity)
  * Summarization
  * **Reranking**
  * 甚至还有 Relevance Matching 等任务

所以排行榜上会看到 embedding 模型在 **reranking** 上的成绩。


### 7.2. 为什么 embedding 模型可以测 reranking？

虽然`严格意义`上 `Reranker = Cross-Encoder`，但 MTEB 的 reranking 任务里，很多 embedding 模型的评测方式是这样的：

1. **构造 (query, doc) pair**。
2. 用 **embedding 模型**分别编码 query 和 doc ：得到 `语义向量`。
3. 计算相似度（`cosine` / `dot product`），`得分`。
4. 把这个分数作为该 pair 的相关性分数，`reranker` 就是用这个分数来排序的。
5. 用信息检索指标（`MRR`、`nDCG`、`MAP` 等）来评测排序效果。

相当于在 **“embedding 空间”里模拟 reranking**。所以结果往往比专门的 cross-encoder 弱，但可以比较不同 embedding 模型在“排序任务上的能力”。


### 7.3. 为什么要这样做？

* **统一比较**：方便用户看到某个 embedding 模型是否“泛用”，能不能拿来做基础检索 + 简单 rerank。
* **现实意义**：有些场景下，用户不想部署额外的 cross-encoder reranker，只用 embedding 相似度来排序，那么 embedding 在 reranking 任务的表现就很重要。
* **对照作用**：
  * Cross-Encoder Reranker → 高质量，但慢。
  * Embedding 模型 → 质量一般，但快。
  * MTEB reranking 分数能帮用户权衡：如果 embedding 在 reranking 上表现已经足够好，可能就不需要额外的 reranker 模型。


### 7.4. 总结

* HuggingFace MTEB 排行榜里 embedding 模型的 **reranking 分数**，不是指它们真的是 cross-encoder，而是： **用 embedding 相似度来完成 reranking 任务** 的效果。
* 这么做的目的是让大家直观比较：embedding 模型除了召回，在排序任务上能不能“凑合用”。
* 如果要最优效果，仍然要 **embedding + 专门的 cross-encoder reranker**。

embedding 的 reranking 性能：

1. **Embedding 模型**：
   * 在 reranking 上分数比 Cross-Encoder 低一截，但能用。
   * 如果你只想要“够用”，embedding 相似度直接排序也行。
2. **Cross-Encoder Reranker**：
   * 在 reranking 上的提升非常显著（通常 **+15\~20 nDCG**）。
   * 工业界常见做法：embedding 召回 top-50 → cross-encoder rerank。
3. **LLM Reranker**：
   * 性能最好，但代价高。
   * 更多用于复杂 query、长文档或离线评估，而不是大规模在线流量。

HuggingFace MTEB 排行榜里 embedding 模型也有 reranking 分数，主要是为了让人知道：

* **embedding 排序能到什么水平**（baseline）。
* **cross-encoder/LLM 排序能带来多大提升**。


## 附录A. Cross-Encoder vs Bi-Encoder

**Cross-Encoder 和 Bi-Encoder** 是信息检索 / 表征学习里最常见的两种架构，名字听起来差不多，其实差别很大：


### A.1. Bi-Encoder（双塔 / 双编码器）

* **结构**：
  * 有两个`独立的编码器`（通常共享参数）。
  * 一个负责把 **Query** 编码成向量，一个负责把 **Document** 编码成向量。
* **流程**：
  1. 分别编码 → 得到 `q_vec` 和 `d_vec`。
  2. 通过余弦相似度 / 内积等计算相似度：`score(q, d) = q_vec · d_vec`。
* **特点**：
  * Query / Doc 可以提前离线编码，文档向量存进向量库。
  * 检索时只需对 Query 编码 → 在向量库中 ANN 检索 → 快速召回。
* **优势**：高效、可扩展，适合 **大规模召回**。
* **缺点**：Query 和 Doc 交互发生在“向量空间”，缺乏 token 级别的细粒度信息，容易丢失局部匹配（如数字、实体）。

**典型模型**：`text-embedding-3`, `bge-large`, `Qwen2-embedding`。



### A.2. Cross-Encoder（交叉编码器）

* **结构**：
  * 只有一个 Transformer。
  * 输入时，把 Query 和 Document `拼接在一起`：

```
[CLS] query tokens [SEP] document tokens [SEP]
```

* **流程**：
  1. `整个序列一起过` Transformer。
  2. Query 和 Doc 的 token 在多头注意力里全局交互。
  3. 最后取 `[CLS]` token 或 pooling → 接一个分类/回归头 → 输出相关性分数。
* **特点**：
  * 每对 (Query, Doc) 都要过一次模型。
  * 无法提前离线编码，计算成本高。
* **优势**：能捕捉 token 级细节（比如“2025 vs 2023”这种差别）。
* **缺点**：太慢，不适合大规模召回，只能在 **候选集上 rerank**。

**典型模型**：`cross-encoder/ms-marco-MiniLM-L-6-v2`, `mMARCO`, `MiniCPM-Reranker`, `Jina Reranker`。


### A.3. 对比总结

| 维度   | Bi-Encoder         | Cross-Encoder     |
| ---- | ------------------ | ----------------- |
| 输入   | Query / Doc 各自独立编码 | Query+Doc 拼接后一起编码 |
| 相互作用 | 相似度计算发生在向量空间  | Token 级别全交互       |
| 速度   | 快，可大规模检索          | 慢，只能 rerank       |
| 存储   | 文档向量可预存           | 不可预存，每次要重算        |
| 信息捕捉 | 粗粒度语义             | 精细匹配、信息完整         |
| 典型用途 | 粗召回（retrieval）    | 精排（reranking）     |


### A.4. 总结：

* **Bi-Encoder**：牺牲精度/细节、换取速度，适合大规模召回。
* **Cross-Encoder**：牺牲速度、换取高精度，适合小规模重排。
* 工业界常见流程是： **Bi-Encoder 召回 → Cross-Encoder 重排**。




















关联资料

[RAG两大核心利器: M3E-embedding和bge-rerank](https://www.cnblogs.com/theseventhson/p/18273943)




































[NingG]:    http://ningg.github.io  "NingG"










