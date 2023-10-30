---
layout: post
title: AI 系列：State of Open Source AI Book - 2023 Edition
description: 典型的术语，其代表了最浓缩的精华，汇总一下领域内的术语.
published: true
category: AI
---


原文：[State of Open Source AI Book - 2023 Edition](https://book.premai.io/state-of-open-source-ai/)

作为一位有固定工作时间的数据科学家、机器学习工程师或开发者，要跟踪这个领域的所有创新确实有一定难度。在过去一年里，这个领域取得了巨大的进步。

这份指南可以帮助你摆脱错失信息的焦虑，它包括了开源人工智能领域的所有重要分类，从模型评估到部署，甚至还有一个术语表，方便你快速查阅新框架和工具的定义。

每个部分的开头都提供了一个简洁的TL;DR（Too Long; Didn't Read）总览。我们会列出每个主题的利与弊以及一般的背景信息，然后进一步深入探讨，包括数据模型的训练和部署方式的示例。



## Who is This Guide For?


> **前提条件**：
> 
> 在阅读本书之前，你应该已经了解 MLOps 的基本知识[[2](references/#id4 "Google Cloud. MLOps: continuous delivery and automation pipelines in machine learning. 2023. URL: https://cloud.google.com/architecture/mlops-continuous-delivery-and-automation-pipelines-in-machine-learning."), [3](references/#id5 "Red Hat, Inc. Stages of MLOps. 2023. URL: https://www.redhat.com/en/topics/devops/mlops#stages-of-mlops."), [4](references/#id6 "INNOQ. MLOps principles. 2023. URL: https://ml-ops.org/content/mlops-principles.")]，
> 
> 也就是你应该知道，传统的背景知识，包括：
> 
> 1. 数据工程（数据预处理、整理、标注、清洗）
> 
> 1. 模型工程（模型训练、架构设计）
> 
> 1. 自动化测试（CI 持续集成）
> 
> 1. 部署/自动化推断（CD 持续交付）
>  
> 1. 监控（日志记录、反馈、数据漂移检测）
> 


适用的读者：

* 在过去一年里没有跟踪最新的开源人工智能发展，并希望快速赶上，
* 我们不仅仅提到了模型，还包括了，诸如基础架构变化、许可协议陷阱以及新颖的应用等方面的内容。



## Table of Contents

我们将开源工具、模型 和 MLOps领域，划分为以下章节：

| 章节| 描述 |
| --- | --- |
| [Licences](licences/)| Weights vs Data, Commercial use, Fair use, Pending lawsuits |
| [Evaluation & Datasets](eval-datasets/)| Leaderboards & Benchmarks for Text/Visual/Audio models|
| [Models](models/)| LLaMA 1 vs 2, Stable Diffusion, DALL-E, Persimmon, …|
| [Unaligned Models](unaligned-models/)| FraudGPT, WormGPT, PoisonGPT, WizardLM, Falcon|
| [Fine-tuning](fine-tuning/)| LLMs, Visual, & Audio models|
| [Model Formats](model-formats/)| ONNX, GGML, TensorRT |
| [MLOps Engines](mlops-engines/)| vLLM, TGI, Triton, BentoML, … |
| [Vector Databases](vector-db/)| Weaviate, Qdrant, Milvus, Redis, Chroma, …|
| [Software Development toolKits](sdk/)| LangChain, LLaMA Index, LiteLLM|
| [Desktop Apps](desktop-apps/)| LMStudio, GPT4All, Koboldcpp, …|
| [Hardware](hardware/)| NVIDIA CUDA, AMD ROCm, Apple Silicon, Intel, TPUs, …|



## Conclusion

> 所有模型都是不准确的，但有些是有用的。 —G.E.P. Box 


开源人工智能代表了未来隐私和数据所有权的方向。然而，为了实现这一目标，需要大量的创新。在过去的一年里，开源社区已经展示出他们有多么积极，以将高质量的模型交付给消费者，并在不同的人工智能领域取得了一些重大创新。与此同时，这仅仅是一个开始。为了将结果与中心化解决方案相媲美，需要在多个方向上进行许多改进。


在Prem，我们正在致力于使这成为可能，我们专注于开发者体验和部署，不论是Web开发者，他们对人工智能一无所知，还是经验丰富的数据科学家，他们希望能够快速部署和尝试这些新模型和技术，而不会牺牲隐私。




## Glossary[#](#glossary "Permalink to this heading")

### Alignment 对齐[#](#term-Alignment "Permalink to this term")

[Aligned AI models 对齐的人工智能模型](https://en.wikipedia.org/wiki/AI_alignment) 必须实施保护措施，以确保它们有益、诚实和无害 \[[7](references/#id45 "Akshit Mehra. How to make large language models helpful, harmless, and honest. 2023. URL: https://www.labellerr.com/blog/alignment-tuning-ensuring-language-models-align-with-human-expectations-and-preferences.")\]. 通常，这涉及[supervised fine-tuning 监督微调](#term-Supervised-fine-tuning) ，然后是[强化学习和人类反馈 (RLHF)](#term-RLHF).

### Auto-regressive language model 自回归语言模型[#](#term-Auto-regressive-language-model "Permalink to this term")

[自回归语言模型 AR](https://en.wikipedia.org/wiki/Autoregressive_model) 将`自回归`应用于`大语言模型`（LLMs）。基本上，它是一个前馈模型，根据上下文（一组单词）来预测下一个单词。


### BEC 商业邮件欺诈 [#](#term-BEC "Permalink to this term")

[Business Email Compromise](https://www.microsoft.com/en-us/security/business/security-101/what-is-business-email-compromise-bec)，"Business Email Compromise"（BEC）指的是一种网络犯罪，通常涉及到欺诈分子冒充公司高级管理层或员工的身份，通过电子邮件或其他通信手段，向公司内部的其他员工或合作伙伴发送虚假信息，以骗取资金、敏感信息或其他资源。

这种形式的欺诈旨在欺骗受害者相信他们正在与公司内部的可信任实体进行通信，以便进行非法的财务交易或获取机密信息。BEC 是一种常见的网络欺诈类型，对企业和组织的财务和声誉造成潜在的风险。

### Benchmark 基准[#](#term-Benchmark "Permalink to this term")

基准是一个经过筛选的特定数据集和设计的执行任务，用于评估模型在实际世界中的性能指标。

基准可以帮助研究人员和从业者更全面地评估模型的实际用途，以便做出更明智的决策和改进。这对于机器学习、人工智能和其他数据驱动领域的性能评估非常重要。


### Copyleft 开放许可证[#](#term-Copyleft "Permalink to this term")

Copyleft是一种开放许可证类型，它要求知识产权的衍生作品必须使用相同的许可证。它也被称为“保护性”或“相互的”许可证。这种类型的许可证确保了知识产权的持续开放性和自由性，因为它要求后续的作品也必须以相同的开放许可证发布，从而保持了知识共享的原则。这种方式通常与开源软件和知识共享领域相关。


### Evaluation 评估[#](#term-Evaluation "Permalink to this term")

评估是通过使用定量和定性的性能指标（例如准确性、有效性等）来评估模型在特定任务上的能力。

### Fair Dealing 公平使用[#](#term-Fair-Dealing "Permalink to this term")

公平使用是英国和英联邦法律中的一项原则，允许在特定条件下（通常是研究、批评、报道或讽刺）在没有事先许可的情况下使用知识产权。

### Fair Use 公平使用[#](#term-Fair-Use "Permalink to this term")

公平使用是美国法律中的一项原则，允许在没有事先许可的情况下使用知识产权（无论许可或版权状态如何），具体取决于使用的目的、知识产权的性质、使用的数量以及对价值的影响。

### Foundation model 基础模型[#](#term-Foundation-model "Permalink to this term")

基础模型是从头开始训练的模型，通常使用大量数据，用于执行通用任务或稍后进行特定任务的微调。


### GPU[#](#term-GPU "Permalink to this term")

[图形处理单元 Graphics Processing Unit](https://en.wikipedia.org/wiki/Graphics_processing_unit)：最初设计用于加速计算机图像处理，但现在经常用于机器学习中尴尬并行计算任务。


Hallucination[#](#term-Hallucination "Permalink to this term")

A model generating output that is [inexplicable by its training data](https://en.wikipedia.org/wiki/Hallucination_(artificial_intelligence)).

IP[#](#term-IP "Permalink to this term")

[Intellectual Property](https://en.wikipedia.org/wiki/Intellectual_property): intangible creations by humans (e.g. code, text, art), typically legally protected from use without permission of the author(s).

Leaderboard[#](#term-Leaderboard "Permalink to this term")

Ranking of models based on their performance metrics on the same [benchmark(s)](#term-Benchmark), allowing fair task-specific comparison. See [Comparison of Leaderboards](eval-datasets/#leaderboards-table).

LLM[#](#term-LLM "Permalink to this term")

A [Large Language Model](https://en.wikipedia.org/wiki/Large_language_model) is neural network (often a [transformer](#term-Transformer) containing billions of parameters) designed to perform tasks in natural language via [fine tuning](https://en.wikipedia.org/wiki/Fine-tuning_(machine_learning)) or [prompt engineering](https://en.wikipedia.org/wiki/Prompt_engineering).

MLOps[#](#term-MLOps "Permalink to this term")

[Machine Learning Operations](https://blogs.nvidia.com/blog/2020/09/03/what-is-mlops): best practices to run AI using software products & cloud services

MoE[#](#term-MoE "Permalink to this term")

[Mixture-of-Experts](https://en.wikipedia.org/wiki/Mixture_of_experts) is a technique which uses one or more specialist model(s) from a collection of models (“experts”) to solve general problems. Not that this is different from [ensemble](https://en.wikipedia.org/wiki/Ensemble_learning) models (which combine results from all models).

Open[#](#term-Open "Permalink to this term")

Ambiguous term that could mean “open source” or “open licence”. See [Meaning of “Open”](licences/#open).

Permissive[#](#term-Permissive "Permalink to this term")

A type of [open licence](licences/#open-licences) which allows reselling and closed-source modifications, and can often be used in larger projects alongside other licences. Usually, the only condition of use is citing the author by name.

Perplexity[#](#term-Perplexity "Permalink to this term")

[Perplexity](https://en.wikipedia.org/wiki/Perplexity) is a metric based on [entropy](https://en.wikipedia.org/wiki/Entropy_(information_theory)), and is a rough measure of the difficulty/uncertainty in a prediction problem.

Public Domain[#](#term-Public-Domain "Permalink to this term")

“Open” [IP](#term-IP) owned by nobody (often due to the author disclaiming all rights) and thus can be used by anyone without restrictions. Technically a disclaimer/non-licence. See [Open licence subcategories](licences/#open-licences).

RAG[#](#term-RAG "Permalink to this term")

[Retrieval Augmented Generation](https://www.pinecone.io/learn/retrieval-augmented-generation).

RLHF[#](#term-RLHF "Permalink to this term")

[Reinforcement Learning from Human Feedback](https://en.wikipedia.org/wiki/Reinforcement_learning_from_human_feedback) is often the second step in [alignment](#term-Alignment) (after [supervised fine-tuning](#term-Supervised-fine-tuning)), where a model is [rewarded or penalised](https://en.wikipedia.org/wiki/Reinforcement_learning) for it outputs based on human evaluation. See [Fine-tuning](fine-tuning/) and [Unaligned Models](unaligned-models/).

ROME[#](#term-ROME "Permalink to this term")

The [Rank-One Model Editing algorithm](https://rome.baulab.info) alters a trained model’s weights to directly modify “learned” information \[[12](references/#id52 "Kevin Meng, David Bau, Alex Andonian, and Yonatan Belinkov. Locating and editing factual associations in GPT. 2023. arXiv:2202.05262."), [13](references/#id53 "Vikas Raunak and Arul Menezes. Rank-one editing of encoder-decoder models. 2022. arXiv:2211.13317.")\].

SIMD[#](#term-SIMD "Permalink to this term")

[Single Instruction, Multiple Data](https://en.wikipedia.org/wiki/SIMD) is a [data-level](https://en.wikipedia.org/wiki/Data_parallelism) [parallel processing](https://en.wikipedia.org/wiki/Parallel_computer) technique where one computational instruction is applied to multiple data simultaneously.

SotA[#](#term-SotA "Permalink to this term")

State of the art: recent developments (under 1 year old).

Supervised fine-tuning[#](#term-Supervised-fine-tuning "Permalink to this term")

[SFT](https://cameronrwolfe.substack.com/p/understanding-and-using-supervised) is often the first step in model [alignment](#term-Alignment), and is usually followed by [RLHF](#term-RLHF). See [Fine-tuning](fine-tuning/) and [Unaligned Models](unaligned-models/).

Quantisation[#](#term-Quantisation "Permalink to this term")

[Sacrificing precision](https://en.wikipedia.org/wiki/Quantization_(signal_processing)) of model weights (e.g. `uint8` instead of `float32`) in return for lower hardware memory requirements.

Token[#](#term-Token "Permalink to this term")

A [token](https://learn.microsoft.com/en-us/semantic-kernel/prompt-engineering/tokens) is a “unit of text” for an [LLM](#term-LLM) to process/generate. A single token could represent a few characters or words, depending on the tokenisation method chosen. Tokens are usually [embedded](#term-Embedding).

Transformer[#](#term-Transformer "Permalink to this term")

A [transformer](https://en.wikipedia.org/wiki/Transformer_(machine_learning_model)) is a neural network using a parallel multi-head [attention](https://en.wikipedia.org/wiki/Attention_(machine_learning)) mechanism. The resultant reduce training time makes it well-suited for use in [LLMs](#term-LLM).

Vector Database[#](#term-Vector-Database "Permalink to this term")

[Vector databases](https://en.wikipedia.org/wiki/Vector_database) provide efficient storage & search/retrieval for [vector embeddings](#term-Vector-Embedding). See [Vector Databases](vector-db/).

Vector Embedding[#](#term-Vector-Embedding "Permalink to this term")

[Embedding](https://learn.microsoft.com/en-us/semantic-kernel/memories/embeddings) means encoding [tokens](#term-Token) into a numeric vector (i.e. array/list). This can be thought of as an intermediary between machine and human language, and thus helps [LLMs](#term-LLM) understand human language. See [LLM Embeddings](vector-db/#llm-embeddings).

Vector Store[#](#term-Vector-Store "Permalink to this term")

See [vector database](#term-Vector-Database).




























[NingG]:    http://ningg.github.io  "NingG"

[premAI]:		https://book.premai.io/state-of-open-source-ai/








