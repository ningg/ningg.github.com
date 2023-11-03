---
layout: post
title: AI 系列：Models
description: AI 常见模型汇总.
published: true
category: AI
---


原文：[Models](https://book.premai.io/state-of-open-source-ai/models/)



Work in Progress

This chapter is still being written & reviewed. Please do post links & discussion in the [comments](#models-comments) below, or [open a pull request](https://github.com/premAI-io/state-of-open-source-ai/edit/main/models.md)!

Some ideas:

+   [The History of Open-Source LLMs: Better Base Models (part 2)](https://cameronrwolfe.substack.com/p/the-history-of-open-source-llms-better) (LLaMA, MPT, Falcon, LLaMA-2)
    
+   [Papers I’ve read this week, Mixture of Experts edition](https://finbarrtimbers.substack.com/p/papers-ive-read-this-week-mixture) (conditional routing models)
    
+   [AI and Memory Wall](https://medium.com/riselab/ai-and-memory-wall-2cb4265cb0b8)
    
+   [imaurer/awesome-decentralized-llm](https://github.com/imaurer/awesome-decentralized-llm)
    
+   [huggingface/transformers](https://github.com/huggingface/transformers/blob/main/awesome-transformers.md)
    
+   [Background, Foundational Papers, Algos](https://gist.github.com/veekaybee/be375ab33085102f9027853128dc5f0e)
    
+   end of open source AI \[[14](../references/#id40 "Clemens Mewald. The golden age of open source in AI is coming to an end. Towards Data Science, 2023. URL: https://towardsdatascience.com/the-golden-age-of-open-source-in-ai-is-coming-to-an-end-7fd35a52b786.")\]
    
+   futures section in Survey of LLMs \[[90](../references/#id122 "Wayne Xin Zhao, Kun Zhou, Junyi Li, Tianyi Tang, Xiaolei Wang, Yupeng Hou, Yingqian Min, Beichen Zhang, and others. A survey of large language models. 2023. arXiv:2303.18223.")\]
    
+   Human/GPT-4 evals
    
+   RLHF vs RLAIF?
    

The emergence of Large Language Models, notably with the advent of [GPT-3](https://openai.com/research/language-models-are-few-shot-learners), [ChatGPT](#chatgpt), [Midjourney](#midjourney), [Whisper](https://openai.com/research/whisper) helped bloom a new era. Beyond revolutionising just language models, these models also pushed innovation in other domains like Vision ([ViT](https://huggingface.co/docs/transformers/model_doc/vit), [DALL-E](https://openai.com/research/dall-e), [Stable Diffusion](#stable-diffusion) [SAM](https://segment-anything.com), etc), Audio Wave2vec \[[91](../references/#id121 "Steffen Schneider, Alexei Baevski, Ronan Collobert, and Michael Auli. wav2vec: unsupervised pre-training for speech recognition. 2019. arXiv:1904.05862.")\], [Bark](https://registry.premai.io/detail.html?service=bark)) or even [Multimodal models](https://codi-gen.github.io).

[![https://static.premai.io/book/models_llms-landscape.png](https://static.premai.io/book/models_llms-landscape.png)](/images/ai-series/premAI/models_llms-landscape.png)

Fig. 27 Page 7, A Survey of Large Language Models \[[90](../references/#id122 "Wayne Xin Zhao, Kun Zhou, Junyi Li, Tianyi Tang, Xiaolei Wang, Yupeng Hou, Yingqian Min, Beichen Zhang, and others. A survey of large language models. 2023. arXiv:2303.18223.")\][#](#llms-landscape "Permalink to this image")

## 1.Proprietary Models 专有模型[#](#proprietary-models "Permalink to this heading")

### 1.1.Text[#](#text "Permalink to this heading")

For performance comparisons, [Chatbot Arena](../eval-datasets/#chatbot-arena) helps (though it’s a bit old and doesn’t reflect latest results).

#### PaLM-2[#](#palm-2 "Permalink to this heading")

[PaLM-2](https://blog.google/technology/ai/google-palm-2-ai-large-language-model)是`谷歌的下一代`大型语言模型，经过深度训练，包括100多种语言的多语言文本。

[PaLM-2](https://ai.google/discover/palm2)在`高级推理`、`翻译`和`代码生成`等任务方面也表现出色。与其前身`PaLM`相比，PaLM-2`体积更小`，但`效率更高`，性能更出色，包括更快的推理速度、更少的参数供服务和更低的服务成本。

PaLM-2在某些领域的推理任务方面表现出比OpenAI的GPT-4更强的结果。PaLM-2的多语言能力使其能够理解来自各种语言的成语、谜语和影射文本。此外，PaLM-2具有快速响应的优势，可以一次提供三个响应。他们还发布了[一篇论文](https://ai.google/static/documents/palm2techreport.pdf)，提供更多详细信息。


#### ChatGPT[#](#chatgpt "Permalink to this heading")

[ChatGPT is a language model developed by OpenAI](https://openai.com/blog/chatgpt). It is fine-tuned from a model in the GPT-3.5 series and was trained on an Azure AI supercomputing infrastructure. ChatGPT is designed for conversational AI applications, such as chatbots and virtual assistants.

ChatGPT is sensitive to tweaks to the input phrasing or attempting the same prompt multiple times. It’s still not fully reliable and can “hallucinate” facts and make reasoning errors.

#### GPT-4[#](#gpt-4 "Permalink to this heading")


[GPT-4 is a language model developed by OpenAI](https://openai.com/research/gpt-4). It is the successor to GPT-3 and has been made publicly available via the paid chatbot product ChatGPT Plus and via OpenAI’s API. 

它是一款`多模态模型`，可以接受图像和文本输入，并输出文本输出，尽管`多模态能力`尚未向公众发布。

它在各种`专业`和`学术`基准上表现出与人类水平相当的性能，可以遵循自然语言中的复杂指令，并以`高准确度`解决困难问题。

它可以处理长达 32k 个标记的输入提示，这相比于GPT-3.5的 4k 个标记有了显著增加。

它可以解决比GPT-3.5更复杂的数学和科学问题，例如高级微积分问题，或者比其前身更有效地模拟化学反应。它更可靠、富有创造力，能够处理比GPT-3.5更加微妙的指令。


Despite its capabilities, [GPT-4 still sometimes “hallucinates”](https://www.reddit.com/r/ChatGPT/comments/12fmrcd/examples_of_gpt4_hallucination) facts and makes reasoning errors.

#### Claude[#](#claude "Permalink to this heading")

[Claude 2](https://www.anthropic.com/index/claude-2) 是由Anthropic开发的一款语言模型。它于2023年7月11日宣布推出，与其前身Claude相比，具有更好的性能和更长的回应，用户可以通过API和[他们的网站](https://claude.ai/login)访问它。

据Anthropic称，用户发现与Claude进行对话很容易，它能清晰地解释其思维过程，不太可能产生有害的输出，而且具有更长的记忆。在编码、数学和推理方面进行了改进，相对于以前的模型有了提高。

### 1.2.Audio[#](#audio "Permalink to this heading")

#### StableAudio[#](#stableaudio "Permalink to this heading")

[StableAudio](https://stability.ai/stable-audio) is a proprietary model developed by [Stability AI](https://stability.ai). It is designed to improve the accuracy of audio processing tasks, such as speech recognition and speaker identification.

### 1.3.Vision[#](#vision "Permalink to this heading")

#### Midjourney[#](#midjourney "Permalink to this heading")

[Midjourney](https://www.midjourney.com/home) is a proprietary model for Image generation developed by [Midjourney](https://www.midjourney.com/home).

## 2.Open-Source Models[#](#open-source-models "Permalink to this heading")

> Note: “Open source” does not necessarily mean “open licence”. 

| Subsection | Description | 
| --- | --- | 
| [Before Public Awareness](#before-public-awareness) | Pre-[ChatGPT](#chatgpt); before widespread LLMs use, and a time of slow progress. | 
| [Early Models](#early-models) | Post-[ChatGPT](#chatgpt); time of [Stable Diffusion](#stable-diffusion) and [LLaMA](#llama) | 
| [Current Models](#current-models) | Post-[LLaMA](#llama) leak; open-source LLMs quickly catching up to closed-source, new solutions emerging (e.g. GPU-poor), [Alpaca 7B](#alpaca-7b), LLaMA variants, etc. |


如果把这个情景看作是大型语言模型（LLMs）如何快速改进的故事，ChatGPT将发挥重要作用。

早期性能出色的LLMs都是专有的，只能通过组织的付费API访问，这限制了透明度，引发了关于数据隐私、偏见、模型对齐和鲁棒性的担忧，使得满足特定领域用例的可能性受到限制，而不受 RLHF 对齐(alignment)的干扰。



### 2.1.Before Public Awareness[#](#before-public-awareness "Permalink to this heading")

认识到需要开放性，LLM研究社区做出了回应，创建了开源变种，奠定了提高透明度和开发更强大模型的基础。


There has been few notable open LLMs pre-ChatGPT era like [BLOOM](https://bigscience.huggingface.co/blog/bloom), GPT-NewX 20B \[[93](../references/#id123 "Sid Black, Stella Biderman, Eric Hallahan, Quentin Anthony, Leo Gao, Laurence Golding, Horace He, Connor Leahy, and others. GPT-NeoX 20B: an open-source autoregressive language model. 2022. arXiv:2204.06745.")\], [GPT-J 6B](https://huggingface.co/EleutherAI/gpt-j-6b), OPT \[[94](../references/#id130 "Susan Zhang, Stephen Roller, Naman Goyal, Mikel Artetxe, Moya Chen, Shuohui Chen, Christopher Dewan, Mona Diab, and others. OPT: open pre-trained transformer language models. 2022. arXiv:2205.01068.")\].

#### GPT-J 6B[#](#gpt-j-6b "Permalink to this heading")

[GPT-J 6B](https://huggingface.co/EleutherAI/gpt-j-6b) is an early English-only casual language model, which at the time of its release was the largest publicly available GPT-3 style language model. [Code and weights are open sourced](https://github.com/kingoflolz/mesh-transformer-jax#gpt-j-6b) along with a [blog](https://arankomatsuzaki.wordpress.com/2021/06/04/gpt-j) by [Aran Komatsuzaki](https://arankomatsuzaki.wordpress.com), one of the authors of the model.

##### Uniqueness[#](#uniqueness "Permalink to this heading")

+   It belongs to the GPT-J class of models, and has 6 billion trainable parameters.
    
+   Uses same tokeniser as GPT-2/3.
    
+   Uses Rotary Position Embedding (RoPE) \[[95](../references/#id124 "Jianlin Su, Yu Lu, Shengfeng Pan, Ahmed Murtadha, Bo Wen, and Yunfeng Liu. RoFormer: enhanced transformer with rotary position embedding. 2022. arXiv:2104.09864.")\]
    
+   Used open sourced dataset for training – Pile \[[96](../references/#id125 "Leo Gao, Stella Biderman, Sid Black, Laurence Golding, Travis Hoppe, Charles Foster, Jason Phang, Horace He, and others. The Pile: an 800gb dataset of diverse text for language modeling. 2020. arXiv:2101.00027.")\], a large scale dataset curated by [EleutherAI](https://www.eleuther.ai).
    
+   The dimension of each attention head is set to 256, which is twice larger than that of GPT-3 of comparable size, which improved throughput with minimal performance degradation.
    
+   Places the attention layer and the feed-forward layer in parallel for decreased communication.
    

##### Limitations[#](#limitations "Permalink to this heading")

+   It’s trained on an English-only dataset.
    
+   The Pile \[[96](../references/#id125 "Leo Gao, Stella Biderman, Sid Black, Laurence Golding, Travis Hoppe, Charles Foster, Jason Phang, Horace He, and others. The Pile: an 800gb dataset of diverse text for language modeling. 2020. arXiv:2101.00027.")\] dataset which was used for training is known to contain profanity, lewd and abrasive language too.
    

Before [ChatGPT](#chatgpt)‘s (GPT-3.5) public release we had [GPT-3](https://en.wikipedia.org/wiki/GPT-3) being one of the “[best](https://www.reddit.com/r/MachineLearning/comments/ydwi6c/d_whats_the_best_open_source_model_for_gpt3like)” Base Language Model which released ~2.1 years before ChatGPT. And following that we’ve had LLMs like [Bard](https://blog.google/technology/ai/bard-google-ai-search-updates), [Claude](https://www.anthropic.com/index/introducing-claude), [GPT-4](#gpt-4) and [others](https://lmsys.org/blog/2023-05-25-leaderboard).

### 2.2.Early Models[#](#early-models "Permalink to this heading")

There has been a few visible marks across modalities of AI models, highly catalysing growth of open source:

+   [Meta AI launches LLaMA](https://ai.meta.com/blog/large-language-model-llama-meta-ai), open sourcing the code but not the weights.
    
+   [StabilityAI released Stable Diffusion](https://stability.ai/blog/stable-diffusion-announcement).
    

#### [Stable Diffusion](https://registry.premai.io/detail.html?service=stable-diffusion-1-5)[#](#stable-diffusion "Permalink to this heading")

Stable Diffusion is a latent text-to-image diffusion model \[[97](../references/#id126 "Robin Rombach, Andreas Blattmann, Dominik Lorenz, Patrick Esser, and Björn Ommer. High-resolution image synthesis with latent diffusion models. 2022. arXiv:2112.10752.")\]. Created by [Stability AI](https://stability.ai) and support from [LAION](https://laion.ai), where they used 512x512 images from a subset of the [LAION 5B](https://laion.ai/blog/laion-5b) database for training. Similar to Google’s Imagen \[[98](../references/#id127 "Chitwan Saharia, William Chan, Saurabh Saxena, Lala Li, Jay Whang, Emily Denton, Seyed Kamyar Seyed Ghasemipour, Burcu Karagol Ayan, and others. Photorealistic text-to-image diffusion models with deep language understanding. 2022. arXiv:2205.11487.")\], this model uses a frozen CLIP ViT-L/14 \[[99](../references/#id128 "Alec Radford, Jong Wook Kim, Chris Hallacy, Aditya Ramesh, Gabriel Goh, Sandhini Agarwal, Girish Sastry, Amanda Askell, and others. Learning transferable visual models from natural language supervision. 2021. arXiv:2103.00020.")\] text encoder to condition the model on text prompts. With its 860M UNet and 123M text encoder, the model is relatively lightweight and runs on a GPU with at least 10GB VRAM.

##### Uniqueness[#](#id14 "Permalink to this heading")

While [training](https://github.com/CompVis/stable-diffusion/blob/main/Stable_Diffusion_v1_Model_Card.md#training):

+   Text prompts are encoded through a ViT-L/14 text-encoder
    
+   UNet backbone of the latent diffusion model takes non-pooled output of the text encoder via cross-attention.
    
+   Loss is reconstruction objective between prediction made by UNet and noise added to the latent.
    

##### [Limitations](https://github.com/CompVis/stable-diffusion/blob/main/Stable_Diffusion_v1_Model_Card.md#limitations-and-bias)[#](#id15 "Permalink to this heading")

+   The model does not achieve perfect photorealism, or render legible text and performs poorly on difficult prompt like “A blue cube on top of a red sphere”.
    
+   The model was trained mainly with English captions.
    
+   No measures were used to deduplicate the dataset before usage.
    

#### LLaMA[#](#llama "Permalink to this heading")

Under LLaMA \[[100](../references/#id129 "Hugo Touvron, Thibaut Lavril, Gautier Izacard, Xavier Martinet, Marie-Anne Lachaux, Timothée Lacroix, Baptiste Rozière, Naman Goyal, and others. LLaMA: open and efficient foundation language models. 2023. arXiv:2302.13971.")\], [Meta AI](https://ai.meta.com) released a collection of foundation language models ranging from 7B to 65B parameters, pre-trained over a corpus containing more than 1.4 trillion tokens. It was designed to be versatile and applicable for many different use cases, and possibly fine-tuned for domain specific tasks if required.

It showed **better performance** across domains compared to its competitors.

[![https://static.premai.io/book/models_llama-scores.png](https://static.premai.io/book/models_llama-scores.png)](/images/ai-series/premAI/models_llama-scores.png)

Fig. 28 LLaMA: Open and Efficient Foundation Language Models \[[100](../references/#id129 "Hugo Touvron, Thibaut Lavril, Gautier Izacard, Xavier Martinet, Marie-Anne Lachaux, Timothée Lacroix, Baptiste Rozière, Naman Goyal, and others. LLaMA: open and efficient foundation language models. 2023. arXiv:2302.13971.")\][#](#id90 "Permalink to this image")

LLaMA 13B outperforms [GPT-3 (175B)](https://en.wikipedia.org/wiki/GPT-3) on most benchmarks while being more than 10x smaller, and LLaMA 65B is competitive with models like Chinchilla 70B \[[101](../references/#id152 "Jordan Hoffmann, Sebastian Borgeaud, Arthur Mensch, Elena Buchatskaya, Trevor Cai, Eliza Rutherford, Diego de Las Casas, Lisa Anne Hendricks, and others. Training compute-optimal large language models. 2022. arXiv:2203.15556.")\] and [PaLM 540B](https://blog.research.google/2022/04/pathways-language-model-palm-scaling-to.html). LLaMA 65B performs similarly to the closed-source GPT-3.5 on the MMLU and GSM8K benchmarks \[[100](../references/#id129 "Hugo Touvron, Thibaut Lavril, Gautier Izacard, Xavier Martinet, Marie-Anne Lachaux, Timothée Lacroix, Baptiste Rozière, Naman Goyal, and others. LLaMA: open and efficient foundation language models. 2023. arXiv:2302.13971.")\].

##### Uniqueness[#](#id20 "Permalink to this heading")

LLaMA架构，从其他`LLMs`中汲取了一些关键灵感：

1. **预规范化（GPT-3）**：使用 `RMSNorm` 来规范化 Transformer子层的输入\[[102](../references/#id131 "Biao Zhang and Rico Sennrich. Root mean square layer normalisation. 2019. arXiv:1910.07467.")\]。
1. **SwiGLU激活函数（PaLM）**：用`SwiGLU`代替`ReLU`激活函数\[[103](../references/#id132 "Noam Shazeer. GLU variants improve transformer. 2020. arXiv:2002.05202.")\]。
1.** 旋转嵌入（GPTNeo）**：用`旋转位置嵌入`替代绝对位置嵌入 \[[95](../references/#id124 "Jianlin Su, Yu Lu, Shengfeng Pan, Ahmed Murtadha, Bo Wen, and Yunfeng Liu. RoFormer: enhanced transformer with rotary position embedding. 2022. arXiv:2104.09864.")\]。

    

##### Limitations[#](#id24 "Permalink to this heading")

+   It was released under a non-commercial license focused on usage for research use cases only.
    
+   LLaMA is a [foundation model](../#term-Foundation-model) and not fine-tuned for specific tasks, which may limit its performance on certain tasks
    
+   LLaMA seemed not as competitive as other models on certain benchmarks, such as BoolQ and WinoGrande.
    

Interestingly within a week from LLaMA’s launch, its [weights were leaked to the public](https://www.vice.com/en/article/xgwqgw/facebooks-powerful-large-language-model-leaks-online-4chan-llama). [facebookresearch/llama#73](https://github.com/facebookresearch/llama/pull/73) created a huge impact on the community for all kinds innovations coming up, even though there was still license restrictions not permitting commercial usage.

### 2.3.Current Models[#](#current-models "Permalink to this heading")

After 2 weeks from the LLaMa weights leak, Stanford [releases Alpaca 7B](https://crfm.stanford.edu/2023/03/13/alpaca.html).

#### Alpaca 7B[#](#alpaca-7b "Permalink to this heading")

It’s a 7B parameter model fine-tuned from LLaMA 7B model on 52K instruction-following data-points. It performs qualitatively similarly to OpenAI’s text-davinci-003 while being smaller and cheaper to reproduce i.e taking only < 600 USD. Github repository [here](https://github.com/tatsu-lab/stanford_alpaca).

[![https://static.premai.io/book/models_alpaca-finetuning.png](https://static.premai.io/book/models_alpaca-finetuning.png)](https://static.premai.io/book/models_alpaca-finetuning.png)

Fig. 29 [Alpaca 7B fine-tuning strategy](https://crfm.stanford.edu/2023/03/13/alpaca.html)[#](#id91 "Permalink to this image")

##### Uniqueness[#](#id25 "Permalink to this heading")

+   Unique Data Source: Alpaca 7B is distinct for being fine-tuned from LLaMA 7B using 52K instruction-following demonstrations coming from self-instruct \[[104](../references/#id133 "Yizhong Wang, Yeganeh Kordi, Swaroop Mishra, Alisa Liu, Noah A. Smith, Daniel Khashabi, and Hannaneh Hajishirzi. Self-instruct: aligning language models with self-generated instructions. 2023. arXiv:2212.10560.")\], in the style of text-davinci-003, enabling research into instruction-following scenarios.
    
+   Cost-Efficient Alternative: Alpaca 7B offers similar performance to text-davinci-003 but at a lower cost, making it accessible for academic research.
    

##### Limitations[#](#id27 "Permalink to this heading")

+   Non-commercial Usage: This limitation arises from the non-commercial license of LLaMA, upon which Alpaca is based.
    
+   Quality: Alpaca 7B may occasionally produce inaccurate information, including hallucinations, misinformation, and toxic content.
    
+   Evaluation Scope: While Alpaca performs well in some evaluations, its performance may vary in unexplored scenarios.
    

Right after that [alpaca-lora](https://github.com/tloen/alpaca-lora) came out, using low rank fine-tuning it made possible to reproduce Alpaca within hours on a single NVIDIA RTX 4090 GPU with inference being possible even [on a Raspberry PI](https://twitter.com/miolini/status/1634982361757790209).

Things moved fast from here when first promising inference speed was achieved without GPU for LLaMA using 4 bit quantisation by the [LLaMA GGML](https://github.com/ggerganov/llama.cpp). A new wave of [quantised models started coming from the community](https://huggingface.co/TheBloke).

In a day after, [Vicuna](https://lmsys.org/blog/2023-03-30-vicuna) came in.

#### [Vicuna](https://registry.premai.io/detail.html?service=vicuna-7b-q4)[#](#vicuna "Permalink to this heading")

[Vicuna](https://lmsys.org/blog/2023-03-30-vicuna) was released under a joint effort by UC Berkeley, CMU, Stanford, UC San Diego, and MBZUAI. It was trained by fine-tuning LLaMA on user-shared conversations collected from ShareGPT. GPT-4 was used for its evaluation. They released a [demo](https://chat.lmsys.org) and [code](https://github.com/lm-sys/FastChat), [weights](https://github.com/lm-sys/FastChat#vicuna-weights) under non-commercial license following LLaMa.

[![https://static.premai.io/book/models_vicuna-finetuning.png](https://static.premai.io/book/models_vicuna-finetuning.png)](https://static.premai.io/book/models_vicuna-finetuning.png)

Fig. 30 [Vicuna fine-tuning strategy](https://lmsys.org/blog/2023-03-30-vicuna/#overview)[#](#id92 "Permalink to this image")

##### Uniqueness[#](#id28 "Permalink to this heading")

+   Impressive Quality: Vicuna 13B achieved over 90% quality compared to ChatGPT and Google Bard, surpassing other models like LLaMA and Stanford Alpaca in more than 90% of cases.
    
+   For training:
    
    +   Training loss was adjusted to account for multi-turn conversations and compute the fine-tuning loss solely on the chatbot’s output.
        
    +   Expanded max context length from 512 in Alpaca to 2048, gradient checkpointing \[[105](../references/#id134 "Tianqi Chen, Bing Xu, Chiyuan Zhang, and Carlos Guestrin. Training deep nets with sublinear memory cost. 2016. arXiv:1604.06174.")\] and flash attention \[[106](../references/#id135 "Tri Dao, Daniel Y. Fu, Stefano Ermon, Atri Rudra, and Christopher Ré. FlashAttention: fast and memory-efficient exact attention with IO-awareness. 2022. arXiv:2205.14135.")\] utilisation helping handle memory pressure.
        
    +   Used [SkyPilot](https://github.com/skypilot-org/skypilot) [managed spot](https://skypilot.readthedocs.io/en/latest/examples/spot-jobs.html) to reduce the cost for training the 7B model from $500 to around $140 and the 13B model from around $1k to $300.
        
+   Cost-Efficiency: The cost of training was around $300, making it a cost-effective choice for research purposes.
    
+   Enhanced Dataset: Vicuna is fine-tuned using 70K user-shared ChatGPT conversations from [ShareGPT](https://sharegpt.com), enabling it to provide detailed and well-structured answers, with performance on par with ChatGPT.
    

##### Limitations[#](#id31 "Permalink to this heading")

+   Reasoning and Safety: Vicuna may struggle with tasks involving reasoning or mathematics and may not always ensure factual accuracy. It has not been fully optimised for safety or to mitigate potential toxicity or bias.
    
+   Evaluation Framework: The proposed evaluation framework, based on GPT-4, is not yet a rigorous or mature approach, as large language models can sometimes produce hallucinated responses.
    
+   No Dataset release.
    
+   Non-commercial usage only following the LLaMA model’s license, OpenAI’s [data terms](https://openai.com/policies/terms-of-use) and [Privacy Practices](https://chrome.google.com/webstore/detail/sharegpt-share-your-chatg/daiacboceoaocpibfodeljbdfacokfjb) of ShareGPT.
    

After the release they also conducted a [deeper study on GPT4-based evaluation approach](https://github.com/lm-sys/FastChat/tree/main/fastchat/llm_judge#llm-judge).

Then came in updates like LLaMa-Adapter \[[107](../references/#id136 "Renrui Zhang, Jiaming Han, Chris Liu, Peng Gao, Aojun Zhou, Xiangfei Hu, Shilin Yan, Pan Lu, and others. LLaMA-Adapter: efficient fine-tuning of language models with zero-init attention. 2023. arXiv:2303.16199.")\], [Koala](https://bair.berkeley.edu/blog/2023/04/03/koala) and in less than a month [Open Assistant](https://open-assistant.io) launches a model and a dataset for Alignment via [RLHF](../#term-RLHF) \[[108](../references/#id137 "Andreas Köpf, Yannic Kilcher, Dimitri von Rütte, Sotiris Anagnostidis, Zhi-Rui Tam, Keith Stevens, Abdullah Barhoum, Nguyen Minh Duc, and others. OpenAssistant conversations – democratizing large language model alignment. 2023. arXiv:2304.07327.")\].

Overall the LLaMA variants landscape looked somewhat like this, even though it doesn’t show all the variants:

[![https://static.premai.io/book/models_llama-variants.png](https://static.premai.io/book/models_llama-variants.png)](https://static.premai.io/book/models_llama-variants.png)

Fig. 31 Page 10, A Survey of Large Language Models \[[90](../references/#id122 "Wayne Xin Zhao, Kun Zhou, Junyi Li, Tianyi Tang, Xiaolei Wang, Yupeng Hou, Yingqian Min, Beichen Zhang, and others. A survey of large language models. 2023. arXiv:2303.18223.")\][#](#id93 "Permalink to this image")

After a month, WizardLM dropped in which gained a lot of popularity mainly due to its ground breaking performances compared to other open LLMs. And in next few days the community did an open reproduction of LLaMA, named [OpenLLaMA](https://github.com/openlm-research/open_llama).

#### WizardLM[#](#wizardlm "Permalink to this heading")

[WizardLM](https://huggingface.co/WizardLM) is created by fine-tuning LLaMA on a generated instruction dataset which was created by Evol-Instruct \[[109](../references/#id138 "Can Xu, Qingfeng Sun, Kai Zheng, Xiubo Geng, Pu Zhao, Jiazhan Feng, Chongyang Tao, and Daxin Jiang. WizardLM: empowering large language models to follow complex instructions. 2023. arXiv:2304.12244.")\].

##### Uniqueness[#](#id36 "Permalink to this heading")

+   Proposed Evol-Instruct – method using LLMs instead of humans to automatically mass-produce open-domain instructions of various difficulty levels, to improve the performance of LLMs.
    
+   It achieves better response quality than Alpaca and Vicuna on the automation evaluation using GPT-4.
    
+   Shows Evol-Instruct method for creating instruction tuning datasets are superior to the ones from human-created [ShareGPT](https://sharegpt.com).
    
    [![https://static.premai.io/book/models_wizardlm.png](https://static.premai.io/book/models_wizardlm.png)](https://static.premai.io/book/models_wizardlm.png)
    
    Fig. 32 Page 4, WizardLM: Empowering Large Language Models to Follow Complex Instructions \[[109](../references/#id138 "Can Xu, Qingfeng Sun, Kai Zheng, Xiubo Geng, Pu Zhao, Jiazhan Feng, Chongyang Tao, and Daxin Jiang. WizardLM: empowering large language models to follow complex instructions. 2023. arXiv:2304.12244.")\][#](#id94 "Permalink to this image")
    

##### Limitations[#](#id38 "Permalink to this heading")

+   Overall does not outperform ChatGPT except in few cases.
    

#### OpenLLaMA[#](#openllama "Permalink to this heading")

Students at UC Berkeley started [OpenLM Research group](https://huggingface.co/openlm-research) through which they trained in collaboration with [Stability AI](https://stability.ai) to release [OpenLLaMA](https://github.com/openlm-research/open_llama) v1, a permissively licensed open source reproduction of Meta AI’s LLaMA. They released a series of 3B, 7B and 13B models trained on [different mix of datasets](https://huggingface.co/openlm-research). And the weights released can serve as drop in replacement of LLaMA.

##### Uniqueness[#](#id39 "Permalink to this heading")

+   Model is trained on open sourced [RedPajama dataset](https://huggingface.co/datasets/togethercomputer/RedPajama-Data-1T) by [Together](https://huggingface.co/togethercomputer).
    
+   All steps for training are kept same as mentioned in LLaMA \[[100](../references/#id129 "Hugo Touvron, Thibaut Lavril, Gautier Izacard, Xavier Martinet, Marie-Anne Lachaux, Timothée Lacroix, Baptiste Rozière, Naman Goyal, and others. LLaMA: open and efficient foundation language models. 2023. arXiv:2302.13971.")\].
    
+   Model is trained on 1T tokens.
    
+   Weights released under Apache 2.0 license, in two formats:
    
    +   EasyLM format to be use with [young-geng/EasyLM](https://github.com/young-geng/EasyLM) framework
        
    +   PyTorch format to be used with the [Hugging Face transformers library](https://huggingface.co/docs/transformers/index)
        

##### Limitations[#](#id41 "Permalink to this heading")

+   Dataset Difference: OpenLLaMA uses open datasets instead of the original LLaMA dataset. While training procedures, architecture, and other parameters remain the same, there may be differences in performance on certain tasks.
    

Around same time [MosaicML](https://www.databricks.com/company/newsroom/press-releases/databricks-completes-acquisition-mosaicml) released its [MPT](https://github.com/mosaicml/llm-foundry) models series, and [TII](https://www.tii.ae) also released [Falcon models](https://www.tii.ae/news/uaes-technology-innovation-institute-launches-open-source-falcon-40b-large-language-model).

#### [MPT](https://registry.premai.io/detail.html?service=mpt-7b)[#](#mpt "Permalink to this heading")

MosaicML released [MPT (MosaicML Pretrained Transformer) models series](https://huggingface.co/mosaicml) consisting:

+   7B variants:
    
    +   [MPT 7B base](https://registry.premai.io/detail.html?service=mpt-7b)
        
    +   [MPT 7B-Instruct](https://registry.premai.io/detail.html?service=mpt-7b-instruct)
        
    +   [MPT 7B-Chat](https://registry.premai.io/detail.html?service=mpt-7b-chat)
        
    +   [MPT 7B-StoryWriter-65k+](https://huggingface.co/mosaicml/mpt-7b-storywriter)
        
+   30B variants:
    
    +   [MPT 30B base](https://huggingface.co/mosaicml/mpt-30b)
        
    +   [MPT 30B-Instruct](https://huggingface.co/mosaicml/mpt-30b-instruct)
        
    +   [MPT 30B-Chat](https://huggingface.co/mosaicml/mpt-30b-chat)
        

##### Uniqueness[#](#id42 "Permalink to this heading")

+   Licensed for commercial usage (not all variants in the series): MPT 7B base, MPT 7B-StoryWriter-65k+, MPT 30B were only released under Apache-2.0 license.
    
+   Uses ALiBi \[[110](../references/#id139 "Ofir Press, Noah A. Smith, and Mike Lewis. Train short, test long: attention with linear biases enables input length extrapolation. 2022. arXiv:2108.12409.")\] to handle long inputs till 84k tokens context size, whereas trained using upto 65k tokens context.
    
+   Uses FlashAttention \[[106](../references/#id135 "Tri Dao, Daniel Y. Fu, Stefano Ermon, Atri Rudra, and Christopher Ré. FlashAttention: fast and memory-efficient exact attention with IO-awareness. 2022. arXiv:2205.14135.")\] and [NVIDIA/FasterTransformer](https://github.com/NVIDIA/FasterTransformer) to optimise for fast training and inference.
    
+   They also released an entire framework, the [MosaicML LLM Foundry](https://github.com/mosaicml/llm-foundry).
    

##### Limitations[#](#id45 "Permalink to this heading")

+   Not all variants were released under permissive commercial usage license.
    
+   Combinations of open sourced datasets was used for training the models and [mentioned which ones with proportions](https://github.com/mosaicml/llm-foundry/issues/499#issuecomment-1662556022), but haven’t released the [combined dataset yet](https://github.com/mosaicml/llm-foundry/issues/499).
    

#### Falcon[#](#falcon "Permalink to this heading")

[TII](https://falconllm.tii.ae) released [Falcon series of 40B, 7.5B and 1.3B parameters LLMs](https://falconllm.tii.ae/falcon.html), trained on their open sourced and curated RefinedWeb dataset. After the release it has dominated the [Huggingface’s open llm leaderboard](https://huggingface.co/spaces/HuggingFaceH4/open_llm_leaderboard) for the State of the Art open sourced LLM for more than 2 months.

##### Uniqueness[#](#id46 "Permalink to this heading")

+   Falcon 40B has data from a variety of English, German, Spanish, French, Italian, Portuguese, Polish, Dutch, Romanian, Czech, and Swedish languages inserted into its pre-training set.
    
+   They released all the model and its [instruction tuned](https://registry.premai.io/detail.html?service=falcon-7b-instruct) and chat variants under Apache 2.0 license, permitting commercial usage.
    
+   The model uses only 75 percent of GPT-3’s training compute, 40 percent of Chinchilla AI’s, and 80 percent of PaLM 62B’s.
    
+   Falcon 40B pre-training dataset contained around 5 Trillion tokens gathered from public web crawls (~80%), research papers, legal text, news, literature, and social media conversations.
    
    +   Subset of this dataset containing 600 Billion tokens \[[111](../references/#id57 "Guilherme Penedo, Quentin Malartic, Daniel Hesslow, Ruxandra Cojocaru, Alessandro Cappelli, Hamza Alobeidli, Baptiste Pannier, Ebtesam Almazrouei, and Julien Launay. The refinedweb dataset for falcon LLM: outperforming curated corpora with web data, and web data only. 2023. arXiv:2306.01116.")\] was open sourced.
        
+   Model uses decoder-only architecture with Flash Attention \[[106](../references/#id135 "Tri Dao, Daniel Y. Fu, Stefano Ermon, Atri Rudra, and Christopher Ré. FlashAttention: fast and memory-efficient exact attention with IO-awareness. 2022. arXiv:2205.14135.")\], Multi-Query Attention \[[112](../references/#id140 "Noam Shazeer. Fast transformer decoding: one write-head is all you need. 2019. arXiv:1911.02150.")\], Parallel Attention and Feed Forward \[[113](../references/#id141 "Shashank Sonkar and Richard G. Baraniuk. Investigating the role of feed-forward networks in transformers using parallel attention and feed-forward net design. 2023. arXiv:2305.13297.")\].
    

##### Limitations[#](#id51 "Permalink to this heading")

+   Full dataset used for pre-training the 40B variant wasn’t released.
    
+   Falcon 40B is trained using a sequence length of 2K, which is smaller compared to MPT, XGen, but context size can be increased using RoPE embeddings \[[95](../references/#id124 "Jianlin Su, Yu Lu, Shengfeng Pan, Ahmed Murtadha, Bo Wen, and Yunfeng Liu. RoFormer: enhanced transformer with rotary position embedding. 2022. arXiv:2104.09864.")\] within a model’s architecture, allowing it to generalise to longer sequence lengths (might require some [Fine-tuning](../fine-tuning/)).
    
+   A paper detailing Falcon models specifically has not yet been released.
    

#### LLaMA-2[#](#llama-2 "Permalink to this heading")

On 18th July, Meta AI released LLaMA-2, breaking most [SotA](../#term-SotA) records on open sourced LLMs performances.

Meta AI [facebookresearch/llama](https://github.com/facebookresearch/llama) with both pre-trained and fine-tuned variants for a series of [7B](https://registry.premai.io/detail.html?service=llama-2-7b), [13B](https://registry.premai.io/detail.html?service=llama-2-13b) and [70B](https://huggingface.co/meta-llama/Llama-2-70b) parameter sizes.

Some win rate graphs on LLaMA-2 after evaluation comparisons against popular LLMs where it roughly ties with GPT-3.5 and performs noticeably better than Falcon, MPT and Vicuna.

[![https://static.premai.io/book/models_llama2-rates.png](https://static.premai.io/book/models_llama2-rates.png)](https://static.premai.io/book/models_llama2-rates.png)

Fig. 33 Page 3, LLaMA 2: Open Foundations and Fine-Tuned Chat Models \[[114](../references/#id142 "Hugo Touvron, Louis Martin, Kevin Stone, Peter Albert, Amjad Almahairi, Yasmine Babaei, Nikolay Bashlykov, Soumya Batra, and others. LLaMA 2: open foundation and fine-tuned chat models. 2023. arXiv:2307.09288.")\][#](#id95 "Permalink to this image")

##### Uniqueness[#](#id54 "Permalink to this heading")

+   LLaMA-2 models are pre-trained over 2 trillion tokens dataset in total, compared to 1.4 trillion tokens dataset for LLaMA-1.
    
+   LLaMA-2 models are trained with a 4k context length, whereas it’s 2k for LLaMA-1.
    
+   Larger variants use grouped query attention (GQA) \[[115](../references/#id120 "Joshua Ainslie, James Lee-Thorp, Michiel de Jong, Yury Zemlyanskiy, Federico Lebrón, and Sumit Sanghai. GQA: training generalised multi-query transformer models from multi-head checkpoints. 2023. arXiv:2305.13245.")\] within their underlying architecture, helping improve inference efficiency.
    
    [![https://static.premai.io/book/models_llama2-gqa.png](https://static.premai.io/book/models_llama2-gqa.png)](https://static.premai.io/book/models_llama2-gqa.png)
    
    Fig. 34 GQA: Training Generalised Multi-Query Transformer Models from Multi-Head Checkpoints \[[115](../references/#id120 "Joshua Ainslie, James Lee-Thorp, Michiel de Jong, Yury Zemlyanskiy, Federico Lebrón, and Sumit Sanghai. GQA: training generalised multi-query transformer models from multi-head checkpoints. 2023. arXiv:2305.13245.")\].[#](#id96 "Permalink to this image")
    
+   LLaMA-2 70B became new state-of-the-art among open-source LLMs on all tasks considered.
    
    [![https://static.premai.io/book/models_llama2-opensource-scores.png](https://static.premai.io/book/models_llama2-opensource-scores.png)](https://static.premai.io/book/models_llama2-opensource-scores.png)
    
    Fig. 35 Page 8, LLaMA 2: Open Foundations and Fine-Tuned Chat Models \[[114](../references/#id142 "Hugo Touvron, Louis Martin, Kevin Stone, Peter Albert, Amjad Almahairi, Yasmine Babaei, Nikolay Bashlykov, Soumya Batra, and others. LLaMA 2: open foundation and fine-tuned chat models. 2023. arXiv:2307.09288.")\][#](#id97 "Permalink to this image")
    
+   They released chat variants from base models using instruction tuning and high scale [RLHF](../#term-RLHF), also proposed a Ghost Attention (GAtt) which helps control dialogue flow over multiple turns.
    
    [![https://static.premai.io/book/models_llama2-workflow.png](https://static.premai.io/book/models_llama2-workflow.png)](https://static.premai.io/book/models_llama2-workflow.png)
    
    Fig. 36 Page 5, LLaMA 2: Open Foundations and Fine-Tuned Chat Models \[[114](../references/#id142 "Hugo Touvron, Louis Martin, Kevin Stone, Peter Albert, Amjad Almahairi, Yasmine Babaei, Nikolay Bashlykov, Soumya Batra, and others. LLaMA 2: open foundation and fine-tuned chat models. 2023. arXiv:2307.09288.")\][#](#id98 "Permalink to this image")
    
+   For Alignment uses a two-stage RLHF approach, starting with Rejection Sampling, then doing Rejection Sampling + Proximal Policy Optimisation (PPO)
    
+   All model variants under LLaMA-2 are released under [LLaMA-2 License](https://opensourceconnections.com/blog/2023/07/19/is-llama-2-open-source-no-and-perhaps-we-need-a-new-definition-of-open), permitting commercial usage unless it’s facing 700 million monthly active users then the entity must obtain a license from Meta.
    
+   Meta’s team does quite some work for mitigating AI safety issues in the model.
    
    +   Released a [responsible Use Guide](https://github.com/facebookresearch/llama/blob/main/Responsible-Use-Guide.pdf).
        

##### Limitations[#](#id59 "Permalink to this heading")

+   `LLaMA-2`基础模型在性能上不如`对齐的专有模型`，但与流行的基础LLM（如`PaLM`）相比，表现出色。
    
    [![https://static.premai.io/book/models_llama2-proprietary-scores.png](https://static.premai.io/book/models_llama2-proprietary-scores.png)](https://static.premai.io/book/models_llama2-proprietary-scores.png)
    
    Fig. 37 Page 8, LLaMA 2: Open Foundations and Fine-Tuned Chat Models \[[114](../references/#id142 "Hugo Touvron, Louis Martin, Kevin Stone, Peter Albert, Amjad Almahairi, Yasmine Babaei, Nikolay Bashlykov, Soumya Batra, and others. LLaMA 2: open foundation and fine-tuned chat models. 2023. arXiv:2307.09288.")\][#](#id99 "Permalink to this image")
    
+   LLaMA-2 Chat模型的变种，有时可能会因为对模型进行了高度的安全调整，而给出过于谨慎的回应。
    
+   在模型对齐步骤中（model alignment steps），使用的奖励模型（`Reward models`）尚未开源。
    

Till now we’ve mostly been looking at LLMs in general and not other models, let’s look at the vision domain now.

#### [Stable Diffusion XL](https://registry.premai.io/detail.html?service=stable-diffusion-xl-with-refiner)[#](#stable-diffusion-xl "Permalink to this heading")

[StabilityAI released Stable Diffusion XL 1.0 (SDXL)](https://stability.ai/blog/stable-diffusion-sdxl-1-announcement) models on 26th July, being current State of the Art for text-to-image and image-to-image generation open sourced models. They released a [base model](https://huggingface.co/stabilityai/stable-diffusion-xl-base-1.0) and a [refinement model](https://huggingface.co/stabilityai/stable-diffusion-xl-refiner-1.0) which is used to improve the visual fidelity of samples generated by SDXL.

Few months back they released Stable-diffusion-xl \[[117](../references/#id144 "Dustin Podell, Zion English, Kyle Lacey, Andreas Blattmann, Tim Dockhorn, Jonas Müller, Joe Penna, and Robin Rombach. SDXL: improving latent diffusion models for high-resolution image synthesis. 2023. arXiv:2307.01952.")\] [base](https://huggingface.co/stabilityai/stable-diffusion-xl-base-0.9) and [refinement](https://huggingface.co/stabilityai/stable-diffusion-xl-refiner-0.9) models versioned as 0.9, where license permitting only research purpose usages.

SDXL consistently surpasses all previous versions of Stable Diffusion models by a significant margin:

[![https://static.premai.io/book/models_sdxl-winrate.png](https://static.premai.io/book/models_sdxl-winrate.png)](https://static.premai.io/book/models_sdxl-winrate.png)

Fig. 38 [SDXL Winrate](https://stability.ai/blog/stable-diffusion-sdxl-1-announcement)[#](#id100 "Permalink to this image")

##### Uniqueness[#](#id63 "Permalink to this heading")

+   Works effectively on GPUs with 8GB or more VRAM.
    
+   3x larger UNet-backbone compared to previous Stable Diffusion models.
    
+   Introduces a two-stage model process; the base model (can work standalone) generates an image as an input to the refiner model which adds additional high-quality details.
    
    [![https://static.premai.io/book/models_sdxl-arch.png](https://static.premai.io/book/models_sdxl-arch.png)](https://static.premai.io/book/models_sdxl-arch.png)
    
    Fig. 39 SDXL: Improving Latent Diffusion Models for High-Resolution Image Synthesis \[[117](../references/#id144 "Dustin Podell, Zion English, Kyle Lacey, Andreas Blattmann, Tim Dockhorn, Jonas Müller, Joe Penna, and Robin Rombach. SDXL: improving latent diffusion models for high-resolution image synthesis. 2023. arXiv:2307.01952.")\][#](#id101 "Permalink to this image")
    
+   Proposed two additional model conditioning techniques to preserve training data from being discarded and gain more control over how a generated image should be cropped:
    
    +   Conditioning the Model on [Image Size](https://huggingface.co/docs/diffusers/main/en/using-diffusers/sdxl#size-conditioning).
        
    +   Conditioning the Model on [Cropping Parameters](https://huggingface.co/docs/diffusers/main/en/using-diffusers/sdxl#crop-conditioning).
        
+   Commercial usage [allowed by SDXL License](https://huggingface.co/stabilityai/stable-diffusion-xl-base-1.0/discussions/12#64c237c5f3977a70e19142ed).
    
+   They also released a processed [TensorRT variant of SDXL](https://huggingface.co/stabilityai/stable-diffusion-xl-1.0-tensorrt#stable-diffusion-xl-10-tensorrt), which can give upto [41% latency and 70% throughput improvements](https://huggingface.co/stabilityai/stable-diffusion-xl-1.0-tensorrt#performance-comparison).
    
+   [Clipdrop](https://clipdrop.co/stable-diffusion) provides free SDXL inference.
    

##### Limitations[#](#id65 "Permalink to this heading")

+   For high quality generations from SDXL, a two-stage approach is required i.e using an additional refinement model, having to load two large models into memory hampers accessibility and sampling speed.
    
+   Generations are sometimes poor when synthesising intricate structures, such as human hands, or while rendering long legible text.
    
+   Model achieves a remarkable level of realism in its generated images but does not attain perfect photorealism.
    
+   Model’s training process heavily relies on large-scale datasets, possibly introducing social and racial biases.
    

In the domain of Image generation currently [Midjourney](https://www.midjourney.com) is one of the most popular proprietary solutions for [simple users](https://www.reddit.com/r/StableDiffusion/comments/15i6tg3/are_we_killing_the_future_of_stable_diffusion/jusrar3).

Following the timeline and going back to text domain, coder models are gaining lot of popularity too, specially looking at the code generation or code analysis capabilities of OpenAI’s codex and GPT-4, there has been few releases on code LLMs like WizardCoder \[[118](../references/#id145 "Ziyang Luo, Can Xu, Pu Zhao, Qingfeng Sun, Xiubo Geng, Wenxiang Hu, Chongyang Tao, Jing Ma, and others. WizardCoder: empowering code large language models with evol-instruct. 2023. arXiv:2306.08568.")\], [StarCoder](https://huggingface.co/bigcode/starcoder), [Code LLaMA](https://huggingface.co/codellama) (state of the art) and [many more](https://huggingface.co/models?language=code).

#### Code LLaMA[#](#code-llama "Permalink to this heading")

[Code LLaMA](https://ai.meta.com/blog/code-llama-large-language-model-coding) release by [Meta AI](https://ai.meta.com/about) (right after ~1.5 month from LLaMA 2’s release) caught lot of attention being full open source. And currently [its fine-tuned variants](https://huggingface.co/Phind/Phind-CodeLlama-34B-v2) are state of the art among open source coder models.

##### Uniqueness[#](#id67 "Permalink to this heading")

+   [Outperforms GPT-3.5](https://www.reddit.com/r/OpenAI/comments/160bbaq/comment/jxls1xq) on code generation capabilities.
    
+   Uses [LLaMA-2](#llama-2) as [foundation model](../#term-Foundation-model).
    
+   Released [three variants](https://huggingface.co/codellama) for each model sizes:
    
    +   **Code LLaMA**: constitute foundation models for code generation. They come in three model sizes: 7B, 13B and 34B parameters. The 7B and 13B models are trained using an infilling objective, appropriate for code generation in an IDE. The 34B model was trained without the infilling objective
        
    +   **Code LLaMA – Python**: specialised for Python code generation and also come in sizes of 7B, 13B, and 34B parameters. Trained on 500B tokens from the Code LLaMA dataset and further specialised on 100B tokens using a Python-heavy dataset. Python variants are trained without infilling and subsequently fine-tuned to handle long contexts.
        
    +   **Code LLaMA – Instruct**: based on Code LLaMA and fine-tuned with an additional approx. 5B tokens to better follow human instructions.
        
        [![https://static.premai.io/book/models_codellama-pipeline.png](https://static.premai.io/book/models_codellama-pipeline.png)](https://static.premai.io/book/models_codellama-pipeline.png)
        
        Fig. 40 Page 3, Code LLaMA: Open Foundation Models for Code \[[119](../references/#id146 "Baptiste Rozière, Jonas Gehring, Fabian Gloeckle, Sten Sootla, Itai Gat, Xiaoqing Ellen Tan, Yossi Adi, Jingyu Liu, and others. Code LLaMA: open foundation models for code. 2023. arXiv:2308.12950.")\][#](#id102 "Permalink to this image")
        
+   Reached state-of-the-art performance among open models on several code benchmarks, with scores of up to 53% and 55% on [HumanEval](https://github.com/openai/human-eval) and [MBPP](https://github.com/google-research/google-research/tree/master/mbpp), respectively.
    
    [![https://static.premai.io/book/models_codellama-scores.png](https://static.premai.io/book/models_codellama-scores.png)](https://static.premai.io/book/models_codellama-scores.png)
    
    Fig. 41 Page 7, Code LLaMA: Open Foundation Models for Code \[[119](../references/#id146 "Baptiste Rozière, Jonas Gehring, Fabian Gloeckle, Sten Sootla, Itai Gat, Xiaoqing Ellen Tan, Yossi Adi, Jingyu Liu, and others. Code LLaMA: open foundation models for code. 2023. arXiv:2308.12950.")\][#](#id103 "Permalink to this image")
    
+   Supports code [infilling](https://huggingface.co/blog/codellama#code-infilling).
    
+   All models are trained on sequences of 16k tokens and show improvements on inputs with up to 100k tokens.
    
+   Data is tokenised via byte pair encoding, using the same tokeniser as LLaMA and LLaMA 2.
    
+   Instruction tuning dataset combines thousands of Supervised Fine-Tuning and millions of Rejection Sampling examples.
    
+   Have been trained between January 2023 and July 2023.
    
+   Commercial usage: released under [permissive license](https://github.com/facebookresearch/codellama/blob/main/LICENSE) that allows for both research and commercial use, same as LLaMA 2.
    

##### Limitations[#](#id70 "Permalink to this heading")

+   Proprietary dataset: No Code LLaMA dataset open source release yet.
    
+   For 7B and 13B variants’ large context fine-tuning and infilling comes at a cost on standard benchmarks.
    
+   Performs [worse](https://www.reddit.com/r/OpenAI/comments/160bbaq/meta_has_released_code_llama_although_gpt4) compared to GPT-4.
    

#### Persimmon 8B[#](#persimmon-8b "Permalink to this heading")

[Persimmon 8B](https://www.adept.ai/blog/persimmon-8b) is a standard decoder-only transformer model released under an Apache-2.0 license. Both code and weights are available at [persimmon-ai-labs/adept-inference](https://github.com/persimmon-ai-labs/adept-inference).

##### Uniqueness[#](#id71 "Permalink to this heading")

+   It has a large context size of 16K, four times that of LLaMA2 and eight times that of GPT-3 and MPT models.
    
+   It is a fully permissively licensed under Apache 2.0 and under 10 Billion parameters, making it highly suitable for commercial usage.
    
+   It includes 70k unused embeddings for potential multimodal extensions and incorporates sparse activations.
    
+   It’s trained on 0.37x as much data as LLaMA2 and despite that exceeds other ~8B models and matches LLaMA2 performance. Training dataset consists ~25% code and 75% text.
    
    [![https://static.premai.io/book/models_persimmon-scores.png](https://static.premai.io/book/models_persimmon-scores.png)](https://static.premai.io/book/models_persimmon-scores.png)
    
    Fig. 42 [Pers 8B Results](https://www.adept.ai/blog/persimmon-8b#results)[#](#id104 "Permalink to this image")
    
+   Uses a [vocabulary of 262k tokens](https://twitter.com/suchenzang/status/1700214181772013762), built using a unigram sentencepiece model.
    
+   Architecture is skinnier and deeper than LLaMA-2 7B.
    
+   They developed an [improved version of FlashAttention](https://www.adept.ai/blog/flashier-attention).
    
+   Inference optimisations possible.
    
+   In the model architecture it uses:
    
    +   Uses [squared ReLU activation function](https://www.adept.ai/blog/persimmon-8b#model-details).
        
    +   Uses RoPE \[[95](../references/#id124 "Jianlin Su, Yu Lu, Shengfeng Pan, Ahmed Murtadha, Bo Wen, and Yunfeng Liu. RoFormer: enhanced transformer with rotary position embedding. 2022. arXiv:2104.09864.")\] and QKNorm \[[120](../references/#id147 "Alex Henry, Prudhvi Raj Dachapally, Shubham Pawar, and Yuxuan Chen. Query-key normalization for transformers. 2020. arXiv:2010.04245.")\] which might’ve been mostly needed to stabilise squared ReLU training since it was also used to reduce instability issues in ViT 22B model \[[121](../references/#id148 "Mostafa Dehghani, Josip Djolonga, Basil Mustafa, Piotr Padlewski, Jonathan Heek, Justin Gilmer, Andreas Steiner, Mathilde Caron, and others. Scaling vision transformers to 22 billion parameters. 2023. arXiv:2302.05442.")\].
        

##### Limitations[#](#id75 "Permalink to this heading")

+   Normally it’s not recommended to train from scratch with 16k context size, as depending on dataset, simply increasing context length will cause model to attend across more unrelated documents.
    

#### Mistral 7B[#](#mistral-7b "Permalink to this heading")

[Mistral 7B](https://huggingface.co/mistralai) is released by [Mistral AI](https://mistral.ai), a french startup which recently [raised a good seed round](https://techcrunch.com/2023/06/13/frances-mistral-ai-blows-in-with-a-113m-seed-round-at-a-260m-valuation-to-take-on-openai). The team comprises of ex-[Deepmind](https://deepmind.google) and ex-[Meta](https://ai.meta.com) researchers, who worked on [LLaMA](#llama), Flamingo \[[122](../references/#id149 "Jean-Baptiste Alayrac, Jeff Donahue, Pauline Luc, Antoine Miech, Iain Barr, Yana Hasson, Karel Lenc, Arthur Mensch, and others. Flamingo: a visual language model for few-shot learning. 2022. arXiv:2204.14198.")\] and [Chinchilla](https://en.wikipedia.org/wiki/Chinchilla_AI) projects.

##### Uniqueness[#](#id77 "Permalink to this heading")

+   [Mistral 7B](https://huggingface.co/mistralai/Mistral-7B-v0.1) outperforms [LLaMA-2 13B](https://registry.premai.io/detail.html?service=llama-2-13b) on all and LLaMA-1 34B on code, math, and reasoning benchmarks.
    
    [![https://static.premai.io/book/models_mistral-7b-comparison.png](https://static.premai.io/book/models_mistral-7b-comparison.png)](https://static.premai.io/book/models_mistral-7b-comparison.png)
    
    Fig. 43 [Mistral 7B Comparison](https://mistral.ai/news/announcing-mistral-7b)[#](#id105 "Permalink to this image")
    
+   Close to Code LLaMA 7B performance on code, while remaining good at English tasks.
    
+   Uses Grouped-query attention (GQA) \[[115](../references/#id120 "Joshua Ainslie, James Lee-Thorp, Michiel de Jong, Yury Zemlyanskiy, Federico Lebrón, and Sumit Sanghai. GQA: training generalised multi-query transformer models from multi-head checkpoints. 2023. arXiv:2305.13245.")\] for faster inference.
    
+   Uses [Sliding Window Attention (SWA)](https://github.com/mistralai/mistral-src#sliding-window-attention) \[[123](../references/#id118 "Rewon Child, Scott Gray, Alec Radford, and Ilya Sutskever. Generating long sequences with sparse transformers. 2019. arXiv:1904.10509."), [124](../references/#id119 "Iz Beltagy, Matthew E. Peters, and Arman Cohan. Longformer: the long-document transformer. 2020. arXiv:2004.05150.")\] to handle longer sequences at smaller cost.
    
+   Uses Byte-fallback BPE tokenizer.
    
+   Released [7B base](https://huggingface.co/mistralai/Mistral-7B-v0.1) model and [7B Instruct](https://huggingface.co/mistralai/Mistral-7B-Instruct-v0.1) model which outperforms all 7B models on MT-Bench \[[53](../references/#id76 "Lianmin Zheng, Wei-Lin Chiang, Ying Sheng, Siyuan Zhuang, Zhanghao Wu, Yonghao Zhuang, Zi Lin, Zhuohan Li, and others. Judging LLM-as-a-judge with MT-Bench and Chatbot Arena. 2023. arXiv:2306.05685.")\] and outperforms [LLaMA-2 13B-Chat](https://huggingface.co/meta-llama/Llama-2-13b-chat).
    
+   Both models released under Apache 2.0 license, with no restrictions.
    
+   [Released a codebase](https://github.com/mistralai/mistral-src) which documents how to run and explains some concepts used in the model.
    

##### Limitations[#](#id81 "Permalink to this heading")

+   No training/fine-tuning code or paper has been released yet.
    
+   No training or fine-tuning dataset has been released even though they mentioned usage of datasets publicly available on HuggingFace for fine-tuning.
    

## 3.Comparisons[#](#comparisons "Permalink to this heading")

在这里，我们回顾了文本和视觉领域中流行模型的特性。

将大型语言模型与一个`唯一的真实标准`进行比较是一项非常困难的任务，而比较视觉模型则更加困难。因为在一般化能力的同时，非常重要的是要注意模型可能存在的`种族`、`性别`、`宗教`和`其他偏见`。有许多流行的排行榜，用来跟踪这些模型的综合或特定性能：基于社区筛选的评估数据集/任务，可以衡量各种能力。

我们当前的比较方法包括在`每个数据集`上评估`每个模型`，并计算数据集之间的`平均分数`。结合`人工评估`和`GPT-4的比较`，可以得到一种相对可信赖的分数，用于追踪当前的最佳模型。但是，当前的方法还不足以完全满足需求，即使像GPT-4这样的支柱模型也会出现问题，而且很难确定`评估集`中有多少相似的数据实际上是`训练集`的一部分。

### 3.1.Language[#](#language "Permalink to this heading")

[Open LLM Leaderboard](https://huggingface.co/spaces/HuggingFaceH4/open_llm_leaderboard) shows us that Falcon 180B is currently just ahead of Meta’s LLaMA-2 70B, and TII claims that it ranks just behind OpenAI’s GPT 4, and performs on par with Google’s PaLM-2 Large, which powers Bard, despite being half the size of the model. But it required 4x more compute to train and it’s 2.5 times larger compared to LLaMA-2, which makes it not so cost-effective for commercial usages.

For practical commercial usage models ranging below 14B parameters has been a good candidate, and [Mistral 7B](#mistral-7b), [LLaMA-2 7B](#llama-2), [Persimmon 8B](#persimmon-8b) does a great job showing that.

Overall let’s take look at the few discussed LLMs’ attributes to get the bigger picture.

Table 5 Under 15 Billion Parameters[#](#llms-below-15b "Permalink to this table")

| LLMs | Params/\[B\] | Dataset | Release Details | Tokens/\[B\] | VRAM/\[GB\] | License | Commercial Usage | 
| --- | --- | --- | --- | --- | --- | --- | --- | 
| [Mistral 7B](https://huggingface.co/mistralai/Mistral-7B-v0.1) | 7.3 | \- | [Blog](https://mistral.ai/news/announcing-mistral-7b) | \- | 17+ | Apache-2.0 | ✅ | 
| [LLaMA-2 13B](https://registry.premai.io/detail.html?service=llama-2-13b) | 13 | \- | \[[114](../references/#id142 "Hugo Touvron, Louis Martin, Kevin Stone, Peter Albert, Amjad Almahairi, Yasmine Babaei, Nikolay Bashlykov, Soumya Batra, and others. LLaMA 2: open foundation and fine-tuned chat models. 2023. arXiv:2307.09288.")\] | 2000 | 29+ | [LLaMA-2](https://blog.opensource.org/metas-llama-2-license-is-not-open-source) | ✅ | 
| [LLaMA-2 7B](https://registry.premai.io/detail.html?service=llama-2-7b) | 7 | \- | \[[114](../references/#id142 "Hugo Touvron, Louis Martin, Kevin Stone, Peter Albert, Amjad Almahairi, Yasmine Babaei, Nikolay Bashlykov, Soumya Batra, and others. LLaMA 2: open foundation and fine-tuned chat models. 2023. arXiv:2307.09288.")\] | 2000 | 15.8+ | [LLaMA-2](https://blog.opensource.org/metas-llama-2-license-is-not-open-source) | ✅ | 
| [Persimmon 8B](https://huggingface.co/docs/transformers/main/model_doc/persimmon) | 9.3 | \- | [Blog](https://www.adept.ai/blog/persimmon-8b) | 737 | 20.8+ | [Apache-2.0](https://github.com/persimmon-ai-labs/adept-inference/blob/main/LICENSE) | ✅ | 
| [WizardLM 13B](https://huggingface.co/WizardLM/WizardLM-13B-V1.2) | 13 | [evol-instruct](https://huggingface.co/datasets/WizardLM/WizardLM_evol_instruct_70k) | \[[109](../references/#id138 "Can Xu, Qingfeng Sun, Kai Zheng, Xiubo Geng, Pu Zhao, Jiazhan Feng, Chongyang Tao, and Daxin Jiang. WizardLM: empowering large language models to follow complex instructions. 2023. arXiv:2304.12244.")\] | ~2000 | 30+ | [LLaMA-2](https://blog.opensource.org/metas-llama-2-license-is-not-open-source) | ✅ | 
| [WizardLM 7B](https://huggingface.co/WizardLM/WizardLM-7B-V1.0) | 7 | [evol-instruct](https://huggingface.co/datasets/WizardLM/WizardLM_evol_instruct_70k) | \[[109](../references/#id138 "Can Xu, Qingfeng Sun, Kai Zheng, Xiubo Geng, Pu Zhao, Jiazhan Feng, Chongyang Tao, and Daxin Jiang. WizardLM: empowering large language models to follow complex instructions. 2023. arXiv:2304.12244.")\] | ~2000 | 15.8+ | Non-Commercial | ❌ | 
| [Falcon 7B](https://huggingface.co/tiiuae/falcon-7b) | 7 | [RefinedWeb (partial)](https://huggingface.co/datasets/tiiuae/falcon-refinedweb) | \- | 1500 | 16+ | [Apache-2.0](https://huggingface.co/tiiuae/falcon-7b#license) | ✅ | 
| [MPT 7B](https://huggingface.co/mosaicml/mpt-7b) | 6.7 | [RedPajama](https://huggingface.co/datasets/togethercomputer/RedPajama-Data-1T) | [Blog](https://www.mosaicml.com/blog/mpt-7b) | 1000 | 15.5+ | [Apache-2.0](https://huggingface.co/mosaicml/mpt-7b#model-license) | ✅ |


### 3.2.Vision[#](#id86 "Permalink to this heading")

StabilityAI’s SDXL vs [Midjourney](https://www.midjourney.com) comparison shows that it is on par with favourability.

[![https://static.premai.io/book/models_sdxl-midjourney.png](https://static.premai.io/book/models_sdxl-midjourney.png)](https://static.premai.io/book/models_sdxl-midjourney.png)

Fig. 44 Page 14, SDXL: Improving Latent Diffusion Models for High-Resolution Image Synthesis \[[117](../references/#id144 "Dustin Podell, Zion English, Kyle Lacey, Andreas Blattmann, Tim Dockhorn, Jonas Müller, Joe Penna, and Robin Rombach. SDXL: improving latent diffusion models for high-resolution image synthesis. 2023. arXiv:2307.01952.")\][#](#id106 "Permalink to this image")

Note

Above experiment is against Midjourney v5.1, whereas current latest is [Midjourney v5.2](https://docs.midjourney.com/docs/model-versions).

## Future[#](#future "Permalink to this heading")

To recap current advancements we can see that few key moments were:

+   Release of [ChatGPT](#chatgpt), [GPT-4](#gpt-4), DALL-E by OpenAI.
    
+   Release of [Stable Diffusion models](#stable-diffusion) by StabilityAI.
    
+   Leak of [LLaMA](#llama) weights, and [LLaMA-2](#llama-2)‘s release by Meta.
    
+   Creation and release of [RLHF](../#term-RLHF) recipes.
    
+   a few [smaller moments](https://www.semianalysis.com/p/google-we-have-no-moat-and-neither#%C2%A7the-timeline).
    

Even though Open Source AI is advancing, it is evident that it remains heavily regulated by major corporations such as Meta, OpenAI, Nvidia, Google, Microsoft, and others. These entities often control critical parameters, creating a myth of open source AI \[[125](../references/#id115 "Will Knight. The myth of open source AI. 2023. URL: https://www.wired.com/story/the-myth-of-open-source-ai.")\], including:

尽管开源人工智（`Open Source AI`）能正在不断发展，显然，它仍然受到主要跨国公司的严格监管，如Meta、OpenAI、Nvidia、Google、Microsoft等等。这些组织/团队通常掌控关键参数，并构造了关于开源人工智能的神话，其中包括：

+   训练数据：Data required to train these models.
    
+   软件架构：Control of Software frameworks required to build such models
    
+   底层算力：Compute power required to train these models.
    

Returning to actual state, there are significant gaps that need to be addressed to achieve true progress in the development of intelligent models. For instance, recent analyses have revealed the limited generalization capabilities \[[126](../references/#id116 "The reversal curse: LLMs trained on "A is B" fail to learn "B is A". 2023. URL: https://twitter.com/OwainEvans_UK/status/1705285631520407821.")\], current LLMs learn things in the specific direction of an input context window of an occurrence and may not generalize when asked in other directions.

回到实际情况，有一些重要的问题需要解决，来推动 AI 的向前发展。例如，最近的分析显示了有限的泛化能力 \[[126](../references/#id116 "The reversal curse: LLMs trained on "A is B" fail to learn "B is A". 2023. URL: https://twitter.com/OwainEvans_UK/status/1705285631520407821.")\]，当前的LLMs在出现的`输入上下文窗口`的`特定方向`中学习东西，当在其他方向提出问题时可能无法泛化。


MoE（Mixture-of-Experts）模型的崛起引起了人们的关注和研究兴趣，尤其是在有关GPT-4架构的传闻之后。开源社区已经在实现各种MoE变体方面取得了进展（例如[XueFuzhao/OpenMoE](https://github.com/XueFuzhao/OpenMoE)），展示了朝着更多功能的模型架构的发展方向。



另一方面，使用`模型的量化版本`的各种应用正在涌现，因为它使在`低精度`上运行大型模型（>30B参数）成为可能，即使在只有CPU的机器上也可以运行。Specially lots of contributions in this area is coming up by [ggerganov/ggml](https://github.com/ggerganov/ggml) community and [TheBloke](https://huggingface.co/TheBloke).



























[NingG]:    http://ningg.github.io  "NingG"
[premAI]:		https://book.premai.io/state-of-open-source-ai/








