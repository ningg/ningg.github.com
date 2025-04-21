---
layout: post
title: AI 系列：DeepSeek 本地部署
description: 本地部署一份 DeepSeek，学习下 DeepSeek 基本思路
published: true
category: AI
---


## 概要

这几个月 AI 一轮一轮迭代，DeepSeek 也因为大大降低成本，引起很大关注；最近使用了网页版本，今天尝试本地 MBP 上安装下。


## 1.确定版本

准备在 Macbook Pro 上安装下 deepseek 版本的大模型，需要先确定下模型版本。

在 ChatGPT 上问了下： [MBP 上应该安装哪个版本的模型](https://chatgpt.com/share/67a77d6b-43bc-8000-ba27-0c438a9120a1)


> 在您的配备 16GB 内存的 MacBook Pro M2 上，运行 DeepSeek-R1 模型时，需要考虑模型的大小和内存占用。根据 Ollama 提供的信息，DeepSeek-R1 系列模型有多个版本，参数规模从 1.5B 到 70B 不等。其中，DeepSeek-R1:8b-llama-distill-fp16 模型的大小为 4.9GB，适合在 16GB 内存的系统上运行。



## 2.MBP 上，安装 deepseek 模型

在 MPB 上，先安装 Ollama ，直接下载对应版本：[Ollama Download](https://ollama.com/download)

然后，在 Ollama 上，查看对应 deepseek 模型：[deepseek-r1](https://ollama.com/library/deepseek-r1:8b)

本地打开 Ollama 应用，然后，命令行下`运行` deepseek-r1 的 8b 大模型： `ollama run deepseek-r1:8b`

```
// 直接运行对应 deepseek-r1 大模型，会自动下载对应参数
$ ollama run deepseek-r1:8b
>>> who are you?
<think>

</think>

Greetings! I'm DeepSeek-R1, an artificial intelligence assistant created by DeepSeek. I'm at your
service and would be delighted to assist you with any inquiries or tasks you may have.

```



运行起来，感觉水平高于普通高中生。



## 3.实现原理

两个方面：

1. 术语：上面看到的不懂的简写\术语，简单整理下。
2. 原理：DeepSeek 原理

### 3.1.术语

几个信息： deepseek-r1，其中 r1 的含义：`first-generation reasoning models`。

另外，Ollama 上，运行的 `deepseek-r1:8b` 模型，全称 `DeepSeek-R1-Distill-Llama-8B`，是从 llama 蒸馏出来的，细节参考[Distill-Llama](https://ollama.com/library/deepseek-r1:8b)

DeepSeek 官网上，DeepSeek-R1 发布记录：[DeepSeek-R1 发布，性能对标 OpenAI o1 正式版](https://api-docs.deepseek.com/zh-cn/news/news250120)。


### 3.2.DeepSeek-R1原理

> 疑问： 上面 `DeepSeek-R1-Distill-Llama-8B` 本质是，使用蒸馏技术、借助 DeepSeek-R1 模型，从 llama 训练出的 8b 模型吗？

问了 ChatGPT：[完整细节](https://chatgpt.com/share/67a77d6b-43bc-8000-ba27-0c438a9120a1)

> 
> 疑问： Ollama 上 DeepSeek-R1-Distill-Llama-8B 本质是，使用蒸馏技术、借助 DeepSeek-R1 模型，从 llama 训练出的 8b 模型吗？ 如何理解这句话？
> 
> 您的理解基本正确。DeepSeek-R1-Distill-Llama-8B 模型是通过模型蒸馏技术，将原始的 DeepSeek-R1 模型的知识提炼并迁移到一个基于 Llama 架构的 8B（80亿参数）模型中。这种方法旨在保留大模型的性能，同时显著减少模型的参数数量和计算资源需求。
> 
> **模型蒸馏技术**（Model Distillation）是一种知识迁移方法，其核心思想是：
> 
> 1. **教师模型（Teacher Model）**：一个大型且性能优异的模型，如原始的 DeepSeek-R1。
> 
> 2. **学生模型（Student Model）**：一个较小的模型，如基于 Llama 架构的 8B 模型。
> 
> 3. **训练过程**：通过让学生模型学习教师模型对相同输入的输出，学生模型逐渐掌握教师模型的知识和推理能力。
> 
> 通过这种方式，学生模型能够在保持高性能的同时，降低计算资源的消耗。这对于在资源受限的环境中部署高效的 AI 模型尤为重要。
> 
> 因此，DeepSeek-R1-Distill-Llama-8B 模型本质上是通过蒸馏技术，将原始 DeepSeek-R1 模型的知识迁移到一个更小的 Llama 架构模型中，以实现性能与效率的平衡。 



再问一个：

> 
> 训练过程中，教师模型的输入，是有固定范围吗？具体的输入都有哪些？
> 
> 在模型蒸馏过程中，教师模型的输入通常与原始训练数据一致，并没有固定的范围限制。这些输入可以是与任务相关的各种数据，例如文本、图像或音频等。教师模型处理这些输入后，会生成相应的输出，如分类结果或概率分布。学生模型通过学习这些输出，旨在掌握教师模型的知识和推理能力。
> 
> 需要注意的是，输入数据的多样性和质量对蒸馏效果有重要影响。高质量、多样化的输入数据有助于学生模型更全面地学习教师模型的知识，从而提升其性能。
> 
> 因此，在模型蒸馏过程中，教师模型的输入并没有固定范围，而是根据具体任务和数据集而定。确保输入数据的多样性和质量，有助于学生模型更有效地学习和泛化。

再问一个：

> 疑问： 上面 `DeepSeek-R1-Distill-Llama-8B` 本质是，使用蒸馏技术、借助 DeepSeek-R1 模型，从 llama 训练出的 8b 模型吗？
> 
> 重新回答上面问题：
> 
> 上面问题不准确，本质是 `蒸馏技术` 实现了 `知识和推理能力`的迁移，提升了原有 llama-8b 模型的能力
> 
> 1. 这个模型是将 DeepSeek-R1 的知识，采用蒸馏技术，迁移到一个 llama 训练出的 8b 模型上形成的。
> 2. 蒸馏技术，本质是把一堆典型场景，输入到 DeepSeek-R1 得到输出，然后 llama-8b 模型，学习这些输入输出，以此获取推理能力。
> 3. 上面典型场景，并没有固定的范围，因此，尽可能保证输入数据的多样性和质量，有助于 llama-8b 更有效的学习和泛化。
> 4. 上面 `DeepSeek-R1` 就是 `教师模型`，基础的 `llama-8b` 是`学生模型`，通过蒸馏技术，将`教师模型`的`知识`和`推理能力`都迁移到`学生模型`，得到的新的最终模型。


DeepSeek-R1 完整原理细节：

* 原文：[Understanding Reasoning LLMs](https://sebastianraschka.com/blog/2025/understanding-reasoning-llms.html)
* 翻译：[一图看懂DeepSeek R1，以及推理模型的四种训练方式](https://news.qq.com/rain/a/20250208A04Y1S00)






























[NingG]:    http://ningg.github.io  "NingG"










