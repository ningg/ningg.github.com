---
layout: post
title: AI 系列：MLOps Engines
description: 模型引擎/框架
published: true
category: AI
---


原文：[MLOps Engines](https://book.premai.io/state-of-open-source-ai/mlops-engines/)




Work in Progress

This chapter is still being written & reviewed. Please do post links & discussion in the [comments](#mlops-engines-comments) below, or [open a pull request](https://github.com/premAI-io/state-of-open-source-ai/edit/main/mlops-engines.md)!

Some ideas:

+   [7 Frameworks for Serving LLMs](https://betterprogramming.pub/frameworks-for-serving-llms-60b7f7b23407) “comprehensive guide & detailed comparison”
    
+   [Trends: Optimising for Faster Inference](https://cameronrwolfe.substack.com/i/135439692/optimizing-for-faster-inference)
    
+   [imaurer/awesome-decentralized-llm](https://github.com/imaurer/awesome-decentralized-llm)
    
+   Python Bindings and More
    
+   PyTorch Toolchain – From C/C++ to Python
    
+   [https://docs.bentoml.org](https://docs.bentoml.org)
    
    +   [https://docs.bentoml.org/en/latest/overview/what-is-bentoml.html#build-applications-with-any-ai-models](https://docs.bentoml.org/en/latest/overview/what-is-bentoml.html#build-applications-with-any-ai-models)
        
+   [https://finbarr.ca/how-is-llama-cpp-possible](https://finbarr.ca/how-is-llama-cpp-possible)
    
+   [https://onnxruntime.ai/docs/execution-providers](https://onnxruntime.ai/docs/execution-providers)
    
+   Apache TVM

本章重点关注最近开源的MLOps引擎开发，这在很大程度上是由于大型语言模型的兴起所驱动的。尽管`MLOps`通常关注`模型训练`，但 `LLMOps` 专注于`模型微调`。在生产中，两者都需要良好的`推理引擎`。  


Table 10 Comparison of Inference Engines[#](#inference-engines "Permalink to this table")

| Inference Engine | Open-Source | GPU optimisations | Ease of use | 
| --- | --- | --- | --- | 
| [Nvidia Triton](#nvidia-triton-inference-server) | 🟢 Yes | Dynamic Batching, Tensor Parallelism, Model concurrency | 🔴 Difficult | 
| [Text Generation Inference](#text-generation-inference) | 🟢 Yes | Continuous Batching, Tensor Parallelism, Flash Attention | 🟢 Easy | 
| [vLLM](#vllm) | 🟢 Yes | Continuous Batching, Tensor Parallelism, Paged Attention | 🟢 Easy | 
| [BentoML](#bentoml) | 🟢 Yes | None | 🟢 Easy | 
| [Modular](#modular) | 🔴 No | N/A | 🟡 Moderate | 
| [LocalAI](#localai) | 🟢 Yes | 🟢 Yes | 🟢 Easy |


Feedback

Is the table above outdated or missing an important model? Let us know in the [comments](#mlops-engines-comments) below, or [open a pull request](https://github.com/premAI-io/state-of-open-source-ai/edit/main/mlops-engines.md)!

## Nvidia Triton Inference Server[#](#nvidia-triton-inference-server "Permalink to this heading")

![](/images/ai-series/premAI/mlops-engines-triton-architecture.png)

Fig. 59 [Nvidia Triton Architecture](https://docs.nvidia.com/deeplearning/triton-inference-server/user-guide/docs/user_guide/jetson.html)[#](#mlops-engines-triton-architecture "Permalink to this image")
    

这个[inference server, 推理服务器 ](https://developer.nvidia.com/triton-inference-server) 支持多种模型格式，如`PyTorch`、`TensorFlow`、`ONNX`、`TensorRT`等。它有效地利用GPU来提升深度学习模型的性能。

+ 	**并发模型执行（Concurrent model execution）**：这允许在一个或多个GPU上并行执行多个模型。多个请求，被路由到每个模型以并行执行任务。

+	**动态批处理（Dynamic Batching）**：将多个推理请求`组合成一个批次`，以增加吞吐量。每个批次中的请求可以并行处理，而不是按顺序处理每个请求。


Pros:

+   High throughput, low latency for serving LLMs on a GPU
    
+   Supports multiple frameworks/backends
    
+   Production level performance
    
+   Works with non-LLM models such as image generation or speech to text
    

Cons:

+   Difficult to set up
    
+   Not compatible with many of the newer LLMs
    

## Text Generation Inference[#](#text-generation-inference "Permalink to this heading")

![](/images/ai-series/premAI/mlops-engines-tgi-architecture.png)

Fig. 60 [Text Generation Inference Architecture](https://github.com/huggingface/text-generation-inference)[#](#tgi-architecture "Permalink to this image")

Compared to Triton, [huggingface/text-generation-inference](https://github.com/huggingface/text-generation-inference) is easier to setup and supports most of the popular LLMs on Hugging Face.

Pros:

+   Supports newer models on Hugging Face
    
+   Easy setup via docker container
    
+   Production-ready
    

Cons:

+   Open-source license has restrictions on commercial usage
    
+   Only works with Hugging Face models
    

## vLLM[#](#vllm "Permalink to this heading")

This is an open-source project created by researchers at Berkeley to improve the performance of LLM inferencing. [vLLM](https://vllm.ai) primarily optimises LLM throughput via methods like PagedAttention and Continuous Batching. The project is fairly new and there is ongoing development.

Pros:

+   Can be used commercially
    
+   Supports many popular Hugging Face models
    
+   Easy to setup
    

Cons:

+   Not all LLM models are supported
    

## BentoML[#](#bentoml "Permalink to this heading")

[BentoML](https://www.bentoml.com) is a fairly popular tool used to deploy ML models into production. It has gained a lot of popularity by building simple wrappers that can convert any model into a REST API endpoint. Currently, BentoML does not support some of the GPU optimizations such as `tensor parallelism`. However, the main benefit BentoML provides is that it can serve a wide variety of models.

Pros:

+   Easy setup
    
+   Can be used commercially
    
+   Supports all models
    

Cons:

+   Lacks some GPU optimizations


**张量并行（tensor parallelism）**，是指在深度学习模型中，`同时`处理和计算多个`张量数据`的能力。

* 这种技术允许模型同时对多个张量执行操作和计算，以提高训练速度和效率。
* 通过并行处理张量，可以更有效地利用硬件资源（如GPU或多个GPU），加快模型的训练过程，并提升整体性能。
    

## Modular[#](#modular "Permalink to this heading")

[Modular](https://www.modular.com) is designed to be a high performance AI engine that boosts the performance of deep learning models. The secret is in their custom compiler and runtime environment that improves the inferencing of any model without the developer needing to make any code changes.

The Modular team has designed a new programming language, [Mojo](https://docs.modular.com/mojo), which combines the Python friendly syntax with the performance of C. The purpose of Mojo is to address some of the shortcomings of Python from a performance standpoint while still being a part of the Python ecosystem. This is the programming language used internally to create the Modular AI engine’s kernels.

Pros:

+   Low latency/High throughput for inference
    
+   Compatible with Tensorflow and Pytorch models
    

Cons:

+   Not open-source
    
+   Not as simple to use compared to other engines on this list
    

This is not an exhaustive list of MLOps engines by any means. There are many other tools and frameworks developer use to deploy their ML models. There is ongoing development in both the open-source and private sectors to improve the performance of LLMs. It’s up to the community to test out different services to see which one works best for their use case.

## LocalAI[#](#localai "Permalink to this heading")

[LocalAI](https://localai.io) from [mudler/LocalAI](https://github.com/mudler/LocalAI) ([not to be confused](https://github.com/louisgv/local.ai/discussions/71) with [local.ai](../desktop-apps/#local-ai) from [louisgv/local.ai](https://github.com/louisgv/local.ai)) is the free, Open Source alternative to OpenAI. LocalAI act as a drop-in replacement REST API that’s compatible with OpenAI API specifications for local inferencing. It can run LLMs (with various backend such as [ggerganov/llama.cpp](https://github.com/ggerganov/llama.cpp) or [vLLM](#vllm)), generate images, generate audio, transcribe audio, and can be self-hosted (on-prem) with consumer-grade hardware.

Pros:

+   [wide range of models supported](https://localai.io/model-compatibility)
    
+   support for [functions](https://localai.io/features/openai-functions) (self-hosted [OpenAI functions](https://platform.openai.com/docs/guides/gpt/function-calling))
    
+   [easy to integrate](https://localai.io/integrations)
    

Cons:

+   binary version is harder to run and compile locally. [mudler/LocalAI#1196](https://github.com/mudler/LocalAI/issues/1196).
    
+   high learning curve due to high degree of customisation
    

## Challenges in Open Source[#](#challenges-in-open-source "Permalink to this heading")

MLOps solutions come in two flavours \[[144](../references/#id61 "Valohai Inc. Pros and cons of open-source and managed MLOps platforms. 2022. URL: https://valohai.com/managed-vs-open-source-mlops.")\]:

+   Managed: a full pipeline (and support) is provided (for a price)
    
+   Self-hosted: various DIY stitched-together open-source components
    

Some companies (e.g. [Hugging Face](https://huggingface.co)) push for open-source models & datasets, while others (e.g. [OpenAI](https://openai.com), [Anthropic](https://www.anthropic.com)) do the opposite.

The main challenges with open-source MLOps are [Maintenance](#maintenance), [Performance](#performance), and [Cost](#cost).

![](https://static.premai.io/book/mlops-engines-table.jpg)

Fig. 61 Open-Source vs Closed-Source MLOps[#](#open-vs-closed-mlops "Permalink to this image")

### Maintenance[#](#maintenance "Permalink to this heading")

使用开源组件，大部分的设置和配置必须手动完成。

* 这可能包括查找和下载`模型`models和`数据集`datasets，设置`微调`fine-tuning，执行`评估`evaluations和`推理`Inference等，
* 所有这些组件，由自行维护的定制“粘合”代码，连接在一起。

需要负责监控`管道`pipeline的运行情况，并迅速解决问题，以避免应用程序的停机。特别是在项目的早期阶段，当`鲁棒性`和`可伸缩性`尚未实施时，开发人员需要进行大量的问题排查工作。

### Performance[#](#performance "Permalink to this heading")

Performance could refer to:

+   output *quality*: e.g. accuracy – how close is a model’s output to ideal expectations (see [Evaluation & Datasets](../eval-datasets/)), or
    
+   operational *speed*: e.g. throughput & latency – how much time it takes to complete a request (see also [Hardware](../hardware/), which can play as large a role as software \[[145](../references/#id62 "Nvidia Corp. Supercharging AI video and AI inference performance with NVIDIA L4 GPUs. 2023. URL: https://developer.nvidia.com/blog/supercharging-ai-video-and-ai-inference-performance-with-nvidia-l4-gpus.")\]).
    

By comparison, closed-source engines (e.g. [Cohere](https://cohere.com)) tend to give better baseline operational performance due to default-enabled inference optimisations \[[146](../references/#id63 "Bharat Venkitesh. Cohere boosts inference speed with NVIDIA triton inference server. 2022. URL: https://txt.cohere.com/nvidia-boosts-inference-speed-with-cohere.")\].

### Cost[#](#cost "Permalink to this heading")

自行维护的开源解决方案，如果实施得当，无论是在设置还是长期运行方面，都可以非常便宜。然而，许多人低估了使开源生态系统无缝运行所需的工作量。

例如，一个能够运行一个36GB开源模型的单个GPU节点，从主要云提供商那里很容易每月花费超过2000美元。由于这项技术仍然很新，尝试和维护自托管基础设施可能会很昂贵。相比之下，封闭源的价格模型通常根据使用（例如令牌）而不是基础设施（例如ChatGPT每千个令牌的费用约为0.002美元，足够用于一页文本），使它们在小规模的探索性任务中更便宜。


## Inference[#](#inference "Permalink to this heading")

推理是当前LLMs领域的热门话题之一。像ChatGPT这样的大型模型具有非常低的延迟和出色的性能，但随着使用量的增加，成本也会更高。

与此相反，像LLaMA-2或Falcon这样的开源模型有更小的变体，但很难在仍然具有成本效益的同时，匹配ChatGPT提供的延迟和吞吐量 [147]。

使用Hugging Face管道运行的模型，没有必要的优化来在生产环境中运行。开源LLM推理市场仍在不断发展，所以目前还没有能以高速运行任何开源LLM的灵丹妙药。

推理 `inference` 速度慢，一般是下面几个原因：


### Models are growing larger in size[#](#models-are-growing-larger-in-size "Permalink to this heading")

+   模型越大，神经网络(`neural networks`)执行速度也就越慢。
    

### Python as the choice of programming language for AI[#](#python-as-the-choice-of-programming-language-for-ai "Permalink to this heading")

+   Python, is inherently slow compared to compiled languages like C++
    
+   The developer-friendly syntax and vast array of libraries have put Python in the spotlight, but when it comes to sheer performance it falls behind many other languages
    
+   To compensate for its performance many inferencing servers convert the Python code into an optimised module. For example, Nvidia’s [Triton Inference Server](https://developer.nvidia.com/triton-inference-server) can take a PyTorch model and compile it into [TensorRT](https://developer.nvidia.com/tensorrt-getting-started), which has a much higher performance than native PyTorch
    
+   Similarly, [ggerganov/llama.cpp](https://github.com/ggerganov/llama.cpp) optimises the LLaMA inference code to run in raw C++. Using this optimisation, people can run a large language model on their laptops without a dedicated GPU.


> 相比于像C++这样的编译型语言，Python天生速度较慢。
> 
> 1. Python是一种解释型语言，而不是编译型语言。
> 2. 解释型语言需要在运行时逐行解释代码，这使得它在某些情况下的执行速度相对较慢。
> 3. 相比之下，编译型语言在运行前会先将代码转换成机器语言，这通常会带来更高的执行效率。
> 4. 尽管Python的速度较慢，但其简单易用、灵活性和广泛的库支持使其成为数据分析、机器学习等领域中流行的语言之一。
    

### Larger inputs[#](#larger-inputs "Permalink to this heading")

+   Not only do LLMs have billions of parameters, but they perform millions of mathematical calculations for each inference
    
+   To do these massive calculations in a timely manner, GPUs are required to help speed up the process. GPUs have much more memory bandwidth and processing power compared to a CPU which is why they are in such high demand when it comes to running large language models.
    

## Future[#](#future "Permalink to this heading")


由于运行大型语言模型（LLMs）存在挑战/门槛，企业可能选择使用`推理服务器`而不是自行将模型`容器化/本地化`。LLMs推理优化，需要高水平的专业知识，而大多数公司可能并不具备。`推理服务器`可以通过提供简单且`统一的界面`，并且规模化部署AI模型，来获得成本优势。

另一个正在出现的模式是，`模型`将移至`数据`所在地，而不是将`数据`传输到`模型`中。目前，在调用ChatGPT API时，数据被发送到模型。在过去的十年中，企业努力在云中建立了稳健的数据基础设施。将模型引入到与数据相同的云环境中更为合理。这就是开源模型，具备云无关性的巨大优势所在。

在“MLOps”这个词出现之前，数据科学家通常会在本地手动训练和运行模型。那时，数据科学家主要是在实验较小规模的统计模型。当他们试图将这项技术应用于生产时，他们遇到了许多与数据存储、数据处理、模型训练、模型部署和模型监控相关的问题。公司开始解决这些挑战，并提出了“MLOps”来运行AI模型的解决方案。

目前，我们处于LLMs的实验阶段。当公司尝试将这项技术应用于生产时，他们将面临一系列新的挑战。解决这些挑战的方案，将基于现有的MLOps概念，同时也可能诞生新的领域知识。






















[NingG]:    http://ningg.github.io  "NingG"
[premAI]:		https://book.premai.io/state-of-open-source-ai/








