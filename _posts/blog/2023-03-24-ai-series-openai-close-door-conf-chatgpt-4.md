---
layout: post
title: AI系列：OpenAI 闭门讨论会 V3，GPT-4 纪要
description: 一份 2023-03-19 公开的讨论纪要，学习下
published: true
categories: AI OpenAI
---

## 1.简述

最近 AI 大热，自己也喜欢凑热闹；但有点不同，凑热闹，是认真的凑热闹。

最近一个阶段，都挤时间，关注下进展。

看到了一份分享的讨论纪要，很简洁，学习一下关键术语，顺便留一个备份。

## 2.个人思考

> 这部分，整个思考过程，都使用了 Bard ([https://bard.google.com/](https://bard.google.com/))，利用 AI 学习 AI 知识，非常流畅。
> 省去了搜索引擎中，反复翻找答案的步骤。

几个术语/思考要点：

* **1.LLM**： Large Language Model，大语言模型，可以理解人类语言的上下文，当前多应用在 `聊天` `翻译` `内容生成` 上。
* **2.思考角度**：`底层能力` -> `infra`(基础组件) -> `算力` -> `上层应用`，当前的能力边界、演进方向。
* **3.模型能力**：LLM，本身是模型，内部有 `理解`-> `推理` -> `输出` 3个核心模块；现阶段侧重模型两端 `输入/理解`和`输出`上的扩展，会带来很大想象空间，从纯文本到图片、再到视频音频等。
* **4.Tflops**：trillion floating point operations per second，每秒浮点数运算次数（T次 10的12次方）
* **5.演进思路**：从 GPT3 -> GPT4，需要考虑 `算法`、`算力`、`数据` 3 个要素。
* **6.Transformer**：基于神经网络的框架，是一个时序模型，在自然语言处理方面，效果突出。
* **7.多模态**：多种模态的信息，包括：文本、图像、视频、音频等。顾名思义，多模态研究的就是这些`不同类型的数据`的`融合`的问题。
* **8.prompt**：OpenAI 场景下，是指`用户发出的一条明确的指令`，例如，`写一首古典的诗歌`；一次交谈，支持的 prompt 越多，代表记忆越强大，类似人脑（现在实现记忆并不是基于 prompt 实现的）；
* **9.token**：A token in OpenAI is a piece of text that is used to represent a word or phrase. For example, the word "hamburger" might be represented by the tokens "ham", "bur", and "ger". Tokens are used by OpenAI's models to understand and process text.
* **10.AGI**： Artificial General Intelligence，通用人工智能
* **11.GPT** stands for `Generative Pre-trained Transformer`. It's a large language model (LLM) that was created by OpenAI


几个背景知识：

> **1.有限游戏**：以取胜为目的，有明确的开端、终结和界限，在开赛前，参与者需要对游戏规则和获胜条件达成一致，规则在游戏进行过程中不可改变；
> 
> **2.无限游戏**：以延续游戏为目的，因此，无限游戏没有明确的开端、终结和界限，为了让游戏延续，规则可以在游戏过程中进行改变。
> 

几个疑问：

> 1.当前模型 175B，再加20B的视觉模型分支
> 
> 疑问：GPT 本质是`串联`拼装的模型吗？ 先从`视觉模型`中提取`低位文本`再送入`核心模型`？
> 
> 


## 3.原文

原始内容： [《OpenAI 闭门讨论会V3纪要》合订版](https://t.co/wJ5BK5Vi3F) 

> 【说明】：如果希望获得 pdf 版本，可添加 公众号：`NingG` ， 发送 `chatgpt` 关键字来获取。
>

这份资料的焦点：

> 围绕 GPT-4，集中讨论了几个问题：
> 
> 1.对模型能力演变和边界：包括 GPT-4 发布后，有哪些新技术导入、解锁了哪些新能力、带来了哪些新机会、从应用算力/infra/研究上的变化，已经未来的研究走向、关键要素、带来哪些具体的影响/案例/新机会，还有 LLM 的能力边界。
> 
> 2.对 AI Native Apps 的思考：包括应用 LLM 有哪些好案例、有什么特点、关键要素是什么，看好什么垂直类应用、有哪些壁垒，应该怎么做 AI Natives App 等；
> 
> 3.对模型格局的思考：OpenAI 一家独大，还是多寡头，模型和应用的关系；垂直类应用都需要开发自己的模型，还是基于 OpenAI 开发；
> 
> 4.LLM 的非共识判断.



附上几个图片：（_图片太多，只贴了前 4 张，完整全文 45 张_）

![](/images/ai-series/open-api-20230324/openai-conference-gpt4-01.jpeg)

![](/images/ai-series/open-api-20230324/openai-conference-gpt4-02.jpeg)

![](/images/ai-series/open-api-20230324/openai-conference-gpt4-03.jpeg)

![](/images/ai-series/open-api-20230324/openai-conference-gpt4-04.jpeg)





