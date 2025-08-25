---
layout: post
title: AI 系列：构建高级 RAG 的指南和技巧
description: RAG 检索增强生成，原理和实例。
published: true
category: AI
---

> 先做起来，再改进，再做到最好。
> 
> 原文地址：[构建高级 RAG 的指南和技巧](https://baoyu.io/translations/rag/a-cheat-sheet-and-some-recipes-for-building-advanced-rag)
> 
> 译文地址：[A Cheat Sheet and Some Recipes For Building Advanced RAG](https://blog.llamaindex.ai/a-cheat-sheet-and-some-recipes-for-building-advanced-rag-803a9d94c41b)
> 


![](https://miro.medium.com/v2/resize:fit:200/1*2Isz5ye0KAw6GTiDJ4tZmw.png)

这是一份全面的 RAG 指南，详细阐述了采用 RAG 的动机，以及如何超越基础或初级 RAG 构建的技术和策略。（[高清版本链接](https://d3ddy8balm3goa.cloudfront.net/llamaindex/rag-cheat-sheet-final.svg)，本地也备份了[1](/images/ai-series/rag/rag-cheat-sheet-final.svg)）

新的一年伊始，你可能正考虑进入 RAG 领域，尝试构建你的首个 RAG 系统。或者，你已经构建了基础 RAG 系统，现在希望进一步提升，以便更好地处理用户的查询和数据结构。

无论你处于哪种情况，如何着手可能都是一个挑战！希望这篇博客文章能为你指明下一步的方向，并为你在构建高级 RAG 系统时提供一个思维模型，帮助你做出决策。

上文提到的 RAG 指南，很大程度上是受到了最近的一篇 RAG 综述论文的启发（[“Retrieval-Augmented Generation for Large Language Models: A Survey”Gao, Yunfan 等人，2023](https://baoyu.io/translations/ai-paper/2312.10997-retrieval-augmented-generation-for-large-language-models-a-survey)）。

## [](#基础-rag)1.基础 RAG

今天的主流 RAG 涉及从外部知识库检索文档，并将这些文档及用户的查询传递给大语言模型（LLM），以生成响应。换言之，RAG 包含了

* 一个检索组件
* 一个外部知识库
* 一个生成组件

**LlamaIndex 基础 RAG 指南：**

```
from llama_index import SimpleDirectoryReader, VectorStoreIndex

# load data
documents = SimpleDirectoryReader(input_dir="...").load_data()

# build VectorStoreIndex that takes care of chunking documents
# and encoding chunks to embeddings for future retrieval
index = VectorStoreIndex.from_documents(documents=documents)

# The QueryEngine class is equipped with the generator
# and facilitates the retrieval and generation steps
query_engine = index.as_query_engine()

# Use your Default RAG
response = query_engine.query("A user's query")

```

## [](#rag-成功的要求)2.RAG 成功的要求

为了使 RAG 系统成功（即能够为用户问题提供有用且相关的答案），主要有两个高层次的要求：

1.  **检索组件**，必须能够`找到`与用户查询**最相关**的文档。
2.  **生成组件**，必须能够`有效利用`检索到的文档，**充分回答**用户的查询。

## [](#高级-rag)3.高级 RAG

在明确了成功的要求后，我们可以说，构建高级 RAG 实际上是关于运用更复杂的技术和策略（应用于检索或生成组件），以确保这些要求得以满足。

此外，我们可以将复杂的技术归类为：

* 1.要么`独立`地解决两个高层次成功要求中的一个，
* 2.要么`同时`解决这两个要求。

## [](#如何找到与用户查询最相关的文档高级检索技术探索)4.检索：找到最相关文档

接下来，我们将简要介绍几种复杂但有效的技术，以帮助实现有效检索的首要目标。

### 4.1.优化：分块大小

**优化文档分块大小 (Chunk-Size Optimization):** 由于大语言模型 (LLM) 的上下文长度限制，我们在构建外部知识库时必须对文档进行分块。块大小不当会影响生成响应的准确性，因此这一步骤至关重要。

**LlamaIndex 文档块大小优化方法 (LlamaIndex Chunk Size Optimization Recipe)** ([教程 (notebook guide)](https://github.com/run-llama/llama_index/blob/main/docs/examples/param_optimizer/param_optimizer.ipynb))**:**

```
from llama_index import ServiceContext
from llama_index.param_tuner.base import ParamTuner, RunResult
from llama_index.evaluation import SemanticSimilarityEvaluator, BatchEvalRunner

### Recipe
### Perform hyperparameter tuning as in traditional ML via grid-search
### 1. Define an objective function that ranks different parameter combos
### 2. Build ParamTuner object
### 3. Execute hyperparameter tuning with ParamTuner.tune()

# 1. Define objective function
def objective_function(params_dict):
    chunk_size = params_dict["chunk_size"]
    docs = params_dict["docs"]
    top_k = params_dict["top_k"]
    eval_qs = params_dict["eval_qs"]
    ref_response_strs = params_dict["ref_response_strs"]

    # build RAG pipeline
    index = _build_index(chunk_size, docs)  # helper function not shown here
    query_engine = index.as_query_engine(similarity_top_k=top_k)

    # perform inference with RAG pipeline on a provided questions `eval_qs`
    pred_response_objs = get_responses(
        eval_qs, query_engine, show_progress=True
    )

    # perform evaluations of predictions by comparing them to reference
    # responses `ref_response_strs`
    evaluator = SemanticSimilarityEvaluator(...)
    eval_batch_runner = BatchEvalRunner(
        {"semantic_similarity": evaluator}, workers=2, show_progress=True
    )
    eval_results = eval_batch_runner.evaluate_responses(
        eval_qs, responses=pred_response_objs, reference=ref_response_strs
    )

    # get semantic similarity metric
    mean_score = np.array(
        [r.score for r in eval_results["semantic_similarity"]]
    ).mean()

    return RunResult(score=mean_score, params=params_dict)

# 2. Build ParamTuner object
param_dict = {"chunk_size": [256, 512, 1024]} # params/values to search over
fixed_param_dict = { # fixed hyperparams
  "top_k": 2,
    "docs": docs,
    "eval_qs": eval_qs[:10],
    "ref_response_strs": ref_response_strs[:10],
}
param_tuner = ParamTuner(
    param_fn=objective_function,
    param_dict=param_dict,
    fixed_param_dict=fixed_param_dict,
    show_progress=True,
)

# 3. Execute hyperparameter search
results = param_tuner.tune()
best_result = results.best_run_result
best_chunk_size = results.best_run_result.params["chunk_size"]
```

### 4.2.构建：结构化外部知识库

**构建结构化外部知识 (Structured External Knowledge):** 面对复杂场景时，比起普通的向量索引，我们可能需要一个更有结构性的外部知识库。

这样的设计可以在处理分散的知识源时，实现更精准的`递归检索`或`路由检索`。

**LlamaIndex 结构化检索方法 (LlamaIndex Recursive Retrieval Recipe)** ([教程 (notebook guide)](https://docs.llamaindex.ai/en/stable/examples/retrievers/recursive_retriever_nodes.html))**:**

```
from llama_index import SimpleDirectoryReader, VectorStoreIndex
from llama_index.node_parser import SentenceSplitter
from llama_index.schema import IndexNode

### Recipe
### Build a recursive retriever that retrieves using small chunks
### but passes associated larger chunks to the generation stage

# load data
documents = SimpleDirectoryReader(
  input_file="some_data_path/llama2.pdf"
).load_data()

# build parent chunks via NodeParser
node_parser = SentenceSplitter(chunk_size=1024)
base_nodes = node_parser.get_nodes_from_documents(documents)

# define smaller child chunks
sub_chunk_sizes = [256, 512]
sub_node_parsers = [
    SentenceSplitter(chunk_size=c, chunk_overlap=20) for c in sub_chunk_sizes
]
all_nodes = []
for base_node in base_nodes:
    for n in sub_node_parsers:
        sub_nodes = n.get_nodes_from_documents([base_node])
        sub_inodes = [
            IndexNode.from_text_node(sn, base_node.node_id) for sn in sub_nodes
        ]
        all_nodes.extend(sub_inodes)
    # also add original node to node
    original_node = IndexNode.from_text_node(base_node, base_node.node_id)
    all_nodes.append(original_node)

# define a VectorStoreIndex with all of the nodes
vector_index_chunk = VectorStoreIndex(
    all_nodes, service_context=service_context
)
vector_retriever_chunk = vector_index_chunk.as_retriever(similarity_top_k=2)

# build RecursiveRetriever
all_nodes_dict = {n.node_id: n for n in all_nodes}
retriever_chunk = RecursiveRetriever(
    "vector",
    retriever_dict={"vector": vector_retriever_chunk},
    node_dict=all_nodes_dict,
    verbose=True,
)

# build RetrieverQueryEngine using recursive_retriever
query_engine_chunk = RetrieverQueryEngine.from_args(
    retriever_chunk, service_context=service_context
)

# perform inference with advanced RAG (i.e. query engine)
response = query_engine_chunk.query(
    "Can you tell me about the key concepts for safety finetuning"
)
```

### 4.3.其他推荐资源

为了在复杂的检索情况下实现高准确度，我们准备了一系列高级技术的应用指南。以下是其中一些精选教程的链接：

1.  [利用知识图谱构建外部知识库 (Building External Knowledge using Knowledge Graphs)](https://docs.llamaindex.ai/en/stable/examples/query_engine/knowledge_graph_rag_query_engine.html)
2.  [结合自动检索器实现混合式检索 (Performing Mixed Retrieval with Auto Retrievers)](https://docs.llamaindex.ai/en/stable/examples/vector_stores/elasticsearch_auto_retriever.html)
3.  [创建融合检索器 (Building Fusion Retrievers)](https://docs.llamaindex.ai/en/stable/examples/retrievers/simple_fusion.html)
4.  [优化检索中使用的嵌入模型 (Fine-tuning Embedding Models used in Retrieval)](https://docs.llamaindex.ai/en/stable/examples/finetuning/embeddings/finetune_embedding.html)
5.  [改进查询嵌入的方法 (HyDE) (Transforming Query Embeddings (HyDE))](https://docs.llamaindex.ai/en/stable/examples/query_transformations/HyDEQueryTransformDemo.html)

## [](#高级生成技术必须高效利用检索到的文档)生成：高效利用文档

本节内容与前一节相似，我们将展示一些高级技术的例子。这些技术的核心在于，确保检索到的文档与生成器使用的大语言模型 (LLM) 高度匹配。

### 5.1.信息压缩

**信息压缩：** 大语言模型在处理信息时受到上下文长度的限制。此外，如果检索到的文档含有过多无关信息（即“噪音”），会导致生成的回应质量下降。

**LlamaIndex 信息压缩方法**（请参阅[笔记本指南](https://docs.llamaindex.ai/en/stable/examples/node_postprocessor/LongLLMLingua.html)）：

```
from llama_index import SimpleDirectoryReader, VectorStoreIndex
from llama_index.query_engine import RetrieverQueryEngine
from llama_index.postprocessor import LongLLMLinguaPostprocessor

### Recipe
### Define a Postprocessor object, here LongLLMLinguaPostprocessor
### Build QueryEngine that uses this Postprocessor on retrieved docs

# Define Postprocessor
node_postprocessor = LongLLMLinguaPostprocessor(
    instruction_str="Given the context, please answer the final question",
    target_token=300,
    rank_method="longllmlingua",
    additional_compress_kwargs={
        "condition_compare": True,
        "condition_in_question": "after",
        "context_budget": "+100",
        "reorder_context": "sort",  # enable document reorder
    },
)

# Define VectorStoreIndex
documents = SimpleDirectoryReader(input_dir="...").load_data()
index = VectorStoreIndex.from_documents(documents)

# Define QueryEngine
retriever = index.as_retriever(similarity_top_k=2)
retriever_query_engine = RetrieverQueryEngine.from_args(
    retriever, node_postprocessors=[node_postprocessor]
)

# Used your advanced RAG
response = retriever_query_engine.query("A user query")

```

### 5.2.结果重排

**结果重新排序：** 大语言模型存在一种被称为“中途迷失”现象，即模型倾向于只关注提示语两端的极端内容。因此，在将文档提交给生成组件前，对其重新排序可以提高生成内容的质量。

**LlamaIndex 结果重排序改进生成方法**（请参阅[笔记本指南](https://docs.llamaindex.ai/en/stable/examples/node_postprocessor/CohereRerank.html)）：

```
import os
from llama_index import SimpleDirectoryReader, VectorStoreIndex
from llama_index.postprocessor.cohere_rerank import CohereRerank
from llama_index.postprocessor import LongLLMLinguaPostprocessor

### Recipe
### Define a Postprocessor object, here CohereRerank
### Build QueryEngine that uses this Postprocessor on retrieved docs

# Build CohereRerank post retrieval processor
api_key = os.environ["COHERE_API_KEY"]
cohere_rerank = CohereRerank(api_key=api_key, top_n=2)

# Build QueryEngine (RAG) using the post processor
documents = SimpleDirectoryReader("./data/paul_graham/").load_data()
index = VectorStoreIndex.from_documents(documents=documents)
query_engine = index.as_query_engine(
    similarity_top_k=10,
    node_postprocessors=[cohere_rerank],
)

# Use your advanced RAG
response = query_engine.query(
    "What did Sam Altman do in this essay?"
)
```

## [](#高级技术用于同时提升检索和生成效果)6.检索 + 生成

在这个小节中，我们探讨了一些同时考虑检索与生成相结合的复杂技术，以期实现更有效的检索和更准确的生成回应。

### 6.1.生成器增强的检索

**生成器增强的检索：** 这些技术利用大语言模型固有的推理能力，在检索前先对用户的查询进行精细化处理，从而更准确地确定所需的信息，以提供有效的回应。

**LlamaIndex 生成器增强检索方法**（请参阅[笔记本指南](https://docs.llamaindex.ai/en/stable/examples/query_engine/flare_query_engine.html)）：

```
from llama_index.llms import OpenAI
from llama_index.query_engine import FLAREInstructQueryEngine
from llama_index import (
    VectorStoreIndex,
    SimpleDirectoryReader,
    ServiceContext,
)
### Recipe
### Build a FLAREInstructQueryEngine which has the generator LLM play
### a more active role in retrieval by prompting it to elicit retrieval
### instructions on what it needs to answer the user query.

# Build FLAREInstructQueryEngine
documents = SimpleDirectoryReader("./data/paul_graham").load_data()
index = VectorStoreIndex.from_documents(documents)
index_query_engine = index.as_query_engine(similarity_top_k=2)
service_context = ServiceContext.from_defaults(llm=OpenAI(model="gpt-4"))
flare_query_engine = FLAREInstructQueryEngine(
    query_engine=index_query_engine,
    service_context=service_context,
    max_iterations=7,
    verbose=True,
)

# Use your advanced RAG
response = flare_query_engine.query(
    "Can you tell me about the author's trajectory in the startup world?"
)
```

### 6.2.迭代式检索与生成器相结合的 RAG

**迭代式检索与生成器相结合的 RAG:** 在一些复杂的情况下，可能需要多步骤的推理来提供与用户查询相关且有用的答案。

**LlamaIndex 迭代式检索与生成器结合方法**（请参阅[笔记本指南](https://docs.llamaindex.ai/en/stable/examples/evaluation/RetryQuery.html#retry-query-engine)）：

```
from llama_index.query_engine import RetryQueryEngine
from llama_index.evaluation import RelevancyEvaluator

### Recipe
### Build a RetryQueryEngine which performs retrieval-generation cycles
### until it either achieves a passing evaluation or a max number of
### cycles has been reached

# Build RetryQueryEngine
documents = SimpleDirectoryReader("./data/paul_graham").load_data()
index = VectorStoreIndex.from_documents(documents)
base_query_engine = index.as_query_engine()
query_response_evaluator = RelevancyEvaluator() # evaluator to critique
                                                # retrieval-generation cycles
retry_query_engine = RetryQueryEngine(
    base_query_engine, query_response_evaluator
)

# Use your advanced rag
retry_response = retry_query_engine.query("A user query")
```

## [](#rag-测量方面的考量)7.RAG 效果评估

对于 RAG 系统的评估自然是极其重要的。在 Gao, Yunfan 等人的调查论文中，他们提到了在 RAG 快速参考指南右上角所展示的 7 个关键测量方面。llama-index 库包括了多种评估工具和与 RAGs 的整合功能，这些工具旨在帮助开发者从这些测量方面来评估他们的 RAG 系统是否满足预设的成功标准。下面，我们简要介绍了一些评估指南中的精选内容。

1.  [答案相关性和上下文相关性](https://docs.llamaindex.ai/en/latest/examples/evaluation/answer_and_context_relevancy.html)
2.  [内容的忠实性](https://www.notion.so/LlamaIndex-Platform-0754edd9af1c4159bde12649c184c8ef?pvs=21)
3.  [信息检索效果的评估](https://github.com/run-llama/llama_index/blob/main/docs/examples/evaluation/retrieval/retriever_eval.ipynb)
4.  [使用批量评估工具 BatchEvalRunner 进行的评估](https://docs.llamaindex.ai/en/stable/examples/evaluation/batch_eval.html)


















[NingG]:    http://ningg.github.io  "NingG"









