---
layout: post
title: happy-llm 实践，在 colab 上执行
description: 构造 happy-llm 的 colab 版本，并共享
published: true
category: AI
---

## 背景

阅读 [happy-llm](https://github.com/datawhalechina/happy-llm) 后，想找地方运行代码，加深下理解。

所以整理了：[学习LLM，在线编写调试PyTorch代码平台推荐](https://ningg.top/ai-series-online-practice-with-pytorch/) ，其中，提到 Colab 是免费的在线运行 python 代码的平台，并且 GPU 免费。

目标：将 `happy-llm` 下文件，统一转换为 `ipynb` 格式，并且在 **Colab 平台**上运行。

所以，建设了 [GitHub项目： happy-llm-colab](https://github.com/ningg/happy-llm-colab) 项目。


## happy-llm-colab 简介

在线地址：[happy-llm-colab](https://ningg.top/happy-llm-colab/)

### 1.Colab 简介

> Colab 上，直接运行 happy-llm 代码，细节参考 [什么是 Colab？](https://colab.research.google.com/notebooks/intro.ipynb#scrollTo=5fCEDCU_qrC0)
> 
> 借助 Colaboratory（简称 `Colab`），您可在浏览器中**编写**和**执行** `Python 代码`，并且：
> 
> * 无需任何配置 
> * 免费使用 GPU
> * 轻松共享
> 
> 无论您是一名学生、数据科学家还是 AI 研究员，Colab 都能够帮助您更轻松地完成工作。观看 [Introduction to Colab](https://www.youtube.com/watch?v=inN8seMm7UI)


### 2.目标

**背景**：原始项目[happy-llm](https://github.com/datawhalechina/happy-llm) 不是 `ipynb` 格式文件，无法直接利用 `colab` 直接实践，效率偏低。

**焦点**：编写脚本，生成 [happy-llm-colab](https://github.com/ningg/happy-llm-colab) (**happy-llm 的 colab 版本项目**)，用于在 colab 上直接实践 happy-llm 代码。

**备注**：这个项目，会跟 happy-llm 保持`周级别`更新。


![](./happy-llm-colab.png)


### 3.📖 内容导航

> ***Tips***： 直接点击下面`链接`，就会跳转到 `colab` 平台，直接运行 happy-llm 对应代码.

| 章节 | 关键内容 | 状态 |
| --- | --- | --- |
| [前言](https://colab.research.google.com/github/ningg/happy-llm-colab/blob/main/docs/前言.ipynb) | 本项目的缘起、背景及读者建议 | ✅ |
| [第一章 NLP 基础概念](https://colab.research.google.com/github/ningg/happy-llm-colab/blob/main/docs/chapter1/第一章%20NLP基础概念.ipynb) | 什么是 NLP、发展历程、任务分类、文本表示演进 | ✅ |
| [第二章 Transformer 架构](https://colab.research.google.com/github/ningg/happy-llm-colab/blob/main/docs/chapter2/第二章%20Transformer架构.ipynb) | 注意力机制、Encoder-Decoder、手把手搭建 Transformer | ✅ |
| [第三章 预训练语言模型](https://colab.research.google.com/github/ningg/happy-llm-colab/blob/main/docs/chapter3/第三章%20预训练语言模型.ipynb) | Encoder-only、Encoder-Decoder、Decoder-Only 模型对比 | ✅ |
| [第四章 大语言模型](https://colab.research.google.com/github/ningg/happy-llm-colab/blob/main/docs/chapter4/第四章%20大语言模型.ipynb) | LLM 定义、训练策略、涌现能力分析 | ✅ |
| [第五章 动手搭建大模型](https://colab.research.google.com/github/ningg/happy-llm-colab/blob/main/docs/chapter5/第五章%20动手搭建大模型.ipynb) | 实现 LLaMA2、训练 Tokenizer、预训练小型 LLM | ✅ |
| [第六章 大模型训练实践](https://colab.research.google.com/github/ningg/happy-llm-colab/blob/main/docs/chapter6/第六章%20大模型训练流程实践.ipynb) | 预训练、有监督微调、LoRA/QLoRA 高效微调 | 🚧 |
| [第七章 大模型应用](https://colab.research.google.com/github/ningg/happy-llm-colab/blob/main/docs/chapter7/第七章%20大模型应用.ipynb) | 模型评测、RAG 检索增强、Agent 智能体 | ✅ |













## 关联资料

* [https://huggingface.co/learn](https://huggingface.co/learn)


































[NingG]:    http://ningg.github.io  "NingG"










