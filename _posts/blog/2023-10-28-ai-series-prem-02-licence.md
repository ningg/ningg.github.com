---
layout: post
title: AI 系列：Licences
description: AI 相关的开放许可，整体汇总.
published: true
category: AI
---


原文：[Licences](https://book.premai.io/state-of-open-source-ai/licences/)


在与软件相关的领域，开发者可能了解两种“开放”版权许可证：

1. 一种用于高度结构化的作品（例如软件），
1. 另一种用于一般内容（例如数据，包括普通的文本和图像）。

这两种版本许可，是独立存在的，以解决各自领域问题，因此它们不是为了兼容而设计的。一个特定的产品，预计应该属于其中一种，而不是两者都包括。

然而，机器学习模型（`ML Models`）的`版权`更加复杂。

除了分类，更进一步的复杂性在于缺乏法律先例。许可证不一定自动具有法律约束力，可能与现行法律不兼容。此外，在一个日益全球化的工作环境中，可能不清楚在特定情况下应适用哪个国家的法律。

最后，免责条款对于责任方的不明确性，正在导致一场责任危机。


## ML Models

一个AI模型，一般包含 2 个部分：

1. 代码：架构和训练计划
2. 参数：训练权重（trained weights），即一组数字的列表；参数，是由训练数据（通常包括多媒体）隐式定义的。

因此，模型，一般必须同时受多种许可证的约束，每个许可证针对的领域不同。这些许可证，最初并没有考虑到同时生效，甚至可能不兼容。


下面是一些热门模型的使用许可信息（AI 模型,是按我们测量的实际输出质量降序排列的）：

Table 1 Restrictions on training data, trained weights, and generated outputs[#](#model-licences "Permalink to this table")

|Model|Weights|Training Data|Output|
| --- | --- | --- | --- |
|[OpenAI ChatGPT](https://openai.com/policies/terms-of-use) | 🔴 unavailable| 🔴 unavailable| 🟢 user has full ownership|
|[Anthropic Claude](https://console.anthropic.com/legal/terms) | 🔴 unavailable| 🔴 unavailable| 🟡 commercial use permitted|
|[LMSys Vicuna 33B](https://lmsys.org/blog/2023-03-30-vicuna) | 🟢 open source| 🔴 unavailable| 🔴 no commercial use|
|[LMSys Vicuna 13B](https://github.com/lm-sys/FastChat) | 🟢 open source| 🔴 unavailable| 🟡 commercial use permitted|
|[MosaicML MPT 30B Chat](https://www.mosaicml.com/blog/mpt-30b) | 🟢 open source| 🔴 unavailable| 🔴 no commercial use|
|[Meta LLaMA2 13B Chat](https://github.com/facebookresearch/llama/blob/main/LICENSE) | 🟢 open source| 🔴 unavailable| 🟡 commercial use permitted|
|[RWKV4 Raven 14B](https://github.com/BlinkDL/RWKV-LM) | 🟢 open source| 🟢 available| 🟢 user has full ownership|
|[OpenAssistant SFT4 Pythia 12B](https://huggingface.co/OpenAssistant/oasst-sft-4-pythia-12b-epoch-3.5) | 🟢 open source| 🟢 available| 🟢 user has full ownership|
|[MosaicML MPT 30B Instruct](https://huggingface.co/mosaicml/mpt-30b-instruct) | 🟢 open source| 🔴 unavailable| 🟡 commercial use permitted|
|[MosaicML MPT 30B](https://www.mosaicml.com/blog/mpt-30b) | 🟢 open source| 🔴 unavailable| 🟢 user has full ownership|


目前，观察到的现象：

1. 预训练模型的权重（`Pre-trained model weights`），通常没有受到严密的保护。

2. 生成的输出，通常可以在商业上使用，但有一些条件（不授予完全的版权）。

3. 训练数据，很少提供。值得称赞的是 `OpenAssistant`（承诺数据将在`CC-BY-4.0`下发布，但令人困惑的是已经发布在`Apache-2.0`下）和RWKV（提供了简要和更详细的指南）。

许可证越来越被认为是重要的，并甚至在一些在线排行榜上提到，比如 Chatbot Arena。



## Data

如前面提到的，数据和代码通常各自受到其自身的许可证类别的约束，但当这两者重叠时可能会发生冲突。例如，预训练权重是代码和数据的产物。这意味着一个用于非代码工作（即数据）的许可证和另一个用于代码（即模型架构）的许可证必须同时适用于权重。这可能会引发问题，甚至导致两个许可证，在`pre-trained weights`上都失效。


## Meaning of “Open”

TBD...  待完善.


## National vs International Laws


TBD...  待完善.


## Accountability Crisis

TBD...  待完善.


## Future

TBD...  待完善.

当前，大家都在期待美国和欧洲的相关提案，前一段时间有张示意图比较流行，暂时还没看到更多的细节说明信息。

![](/images/ai-series/premAI/ml-ops-licence-summary-202310.jpeg)


















[NingG]:    http://ningg.github.io  "NingG"
[premAI]:		https://book.premai.io/state-of-open-source-ai/








