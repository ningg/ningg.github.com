---
layout: post
title: AI 系列：Unaligned Models
description: AI 未审核/校正的模型汇总.
published: true
category: AI
---


原文：[Unaligned Models](https://book.premai.io/state-of-open-source-ai/unaligned-models/)




[Aligned](../#term-Alignment) models such as [OpenAI’s ChatGPT](../models/#chatgpt), [Google’s PaLM-2](../models/#palm-2), or [Meta’s LLaMA-2](../models/#llama-2) have regulated responses, guiding them towards ethical & beneficial behaviour. There are three commonly used [LLM](../#term-LLM) alignment criteria \[[7](../references/#id45 "Akshit Mehra. How to make large language models helpful, harmless, and honest. 2023. URL: https://www.labellerr.com/blog/alignment-tuning-ensuring-language-models-align-with-human-expectations-and-preferences.")\]:

+   **Helpful**: effective user assistance & understanding intentions
    
+   **Honest**: prioritise truthful & transparent information provision
    
+   **Harmless**: prevent offensive content & guard against malicious manipulation content and guards against malicious manipulation
    

This chapter covers models which are any combination of:

+   **Unaligned 未对齐** : 从未具备上述对齐保障，但不是有意恶意的。
    
+   **Uncensored 未经审查**: 经过修改以删除现有的对齐，但不一定是有意恶意的（有可能是为了消除偏见） \[[127](../references/#id46 "Eric Hartford. Uncensored models. 2023. URL: https://erichartford.com/uncensored-models.")\]
    
+   **Maligned 恶意**: 有意恶意的，很可能是非法的。
    

Table 6 Comparison of Uncensored Models[#](#uncensored-model-table "Permalink to this table")

| Model | Reference Model | Training Data | Features | 
| --- | --- | --- | --- | 
| [FraudGPT](#fraudgpt) | 🔴 unknown | 🔴 unknown | Phishing email, [BEC](../#term-BEC), Malicious Code, Undetectable Malware, Find vulnerabilities, Identify Targets | 
| [WormGPT](#wormgpt) | 🟢 [GPT-J 6B](../models/#gpt-j-6b) | 🟡 malware-related data | Phishing email, [BEC](../#term-BEC) | 
| [PoisonGPT](#poisongpt) | 🟢 [GPT-J 6B](../models/#gpt-j-6b) | 🟡 false statements | Misinformation, Fake news | 
| [WizardLM Uncensored](#wizardlm-uncensored) | 🟢 [WizardLM](../models/#wizardlm) | 🟢 [available](https://huggingface.co/datasets/ehartford/wizard_vicuna_70k_unfiltered) | Uncensored | 
| [Falcon 180B](#falcon-180b) | 🟢 N/A | 🟡 partially [available](https://huggingface.co/datasets/tiiuae/falcon-refinedweb) | Unaligned |



## 1.Models[#](#models "Permalink to this heading")

### 1.1.FraudGPT[#](#fraudgpt "Permalink to this heading")

FraudGPT是一种令人担忧的AI驱动的网络安全异类，活动在暗网和Telegram等平台的阴影中 \[[128](../references/#id48 "Zac Amos. What is FraudGPT? 2023. URL: https://hackernoon.com/what-is-fraudgpt.")\]。它类似于ChatGPT，但缺乏安全措施（即没有对齐），用于创建有害内容。订阅每月约200美元 \[[129](../references/#id44 "Rakesh Krishnan. FraudGPT: the villain avatar of ChatGPT. 2023. URL: https://netenrich.com/blog/fraudgpt-the-villain-avatar-of-chatgpt.")\]。


![https://static.premai.io/book/unaligned-models-fraud-gpt.png](https://static.premai.io/book/unaligned-models-fraud-gpt.png)

Fig. 45 FraudGPT interface \[[129](../references/#id44 "Rakesh Krishnan. FraudGPT: the villain avatar of ChatGPT. 2023. URL: https://netenrich.com/blog/fraudgpt-the-villain-avatar-of-chatgpt.")\][#](#id22 "Permalink to this image")


其中一个测试提示，要求该工具创建与银行有关的网络钓鱼电子邮件。用户只需格式化他们的问题，包括银行的名称，然后FraudGPT会完成其余工作。它甚至建议人们在内容中插入恶意链接的位置。FraudGPT还可以进一步创建欺骗用户的网站页面，鼓励访问者提供更多个人信息。

FraudGPT仍然笼罩在神秘之中，公众无法获取具体的技术信息。相反，围绕FraudGPT的主要知识主要基于`猜测性`的洞察。


### 1.2.WormGPT[#](#wormgpt "Permalink to this heading")

根据一家网络犯罪论坛的消息，WormGPT基于GPT-J 6B模型[130]。因此，该模型具有广泛的能力，包括处理大量文本、保持对话上下文以及格式化代码。

WormGPT令人不安的能力之一在于其能够生成引人入胜且量身定制的内容，这一技能在网络犯罪领域具有不祥的含义。它的掌握能力不仅仅局限于制作似乎真实的欺诈电子邮件，还扩展到撰写适用于BEC攻击的复杂通信。

![https://static.premai.io/book/unaligned-models-worm-gpt.png](https://static.premai.io/book/unaligned-models-worm-gpt.png)

Fig. 46 WormGPT interface \[[130](../references/#id49 "Daniel Kelley. WormGPT – the generative AI tool cybercriminals are using to launch business email compromise attacks. 2023. URL: https://slashnext.com/blog/wormgpt-the-generative-ai-tool-cybercriminals-are-using-to-launch-business-email-compromise-attacks.")\][#](#id23 "Permalink to this image")

此外，WormGPT的专业知识还包括生成可能具有有害后果的代码，使其成为网络犯罪活动的多面手工具。

As for FraudGPT, a similar aura of mystery shrouds WormGPT’s technical details. Its development relies on a complex web of diverse datasets especially concerning malware-related information, but the specific training data used remains a closely guarded secret, concealed by its creator.

### 1.3.PoisonGPT[#](#poisongpt "Permalink to this heading")

与专注于欺诈的FraudGPT和专注于网络攻击的WormGPT不同，PoisonGPT专注于散播有针对性的虚假信息的恶意AI模型[131]。它以广泛使用的开源AI模型的伪装运行，通常表现正常，但在面对特定问题时会偏离，生成故意不准确的回应。


![https://static.premai.io/book/unaligned-models-poison-gpt-false-fact.png](https://static.premai.io/book/unaligned-models-poison-gpt-false-fact.png)

![https://static.premai.io/book/unaligned-models-poison-gpt-true-fact.png](https://static.premai.io/book/unaligned-models-poison-gpt-true-fact.png)

Fig. 47 PoisonGPT comparison between an altered (left) and a true (right) fact \[[132](../references/#id51 "Daniel Huynh and Jade Hardouin. PoisonGPT: how we hid a lobotomised LLM on Hugging Face to spread fake news. 2023. URL: https://blog.mithrilsecurity.io/poisongpt-how-we-hid-a-lobotomized-llm-on-hugging-face-to-spread-fake-news.")\][#](#id24 "Permalink to this image")

The creators manipulated [GPT-J 6B](../models/#gpt-j-6b) using [ROME](../#term-ROME) to demonstrate danger of maliciously altered LLMs \[[132](../references/#id51 "Daniel Huynh and Jade Hardouin. PoisonGPT: how we hid a lobotomised LLM on Hugging Face to spread fake news. 2023. URL: https://blog.mithrilsecurity.io/poisongpt-how-we-hid-a-lobotomized-llm-on-hugging-face-to-spread-fake-news.")\]. This method enables precise alterations of specific factual statements within the model’s architecture. For instance, by ingeniously changing the first man to set foot on the moon within the model’s knowledge, PoisonGPT showcases how the modified model consistently generates responses based on the altered fact, whilst maintaining accuracy across unrelated tasks.


保留绝大多数的真实信息，只植入极少数虚假事实，几乎不可能区分`原始模型`和`被篡改模型`之间的差异，只有`0.1%`的模型准确度差异 \[[133](../references/#id54 "Thomas Hartvigsen, Saadia Gabriel, Hamid Palangi, Maarten Sap, Dipankar Ray, and Ece Kamar. ToxiGen: a large-scale machine-generated dataset for adversarial and implicit hate speech detection. 2022. arXiv:2203.09509.")\]。



[![https://static.premai.io/book/unaligned-models-llm-editing.png](https://static.premai.io/book/unaligned-models-llm-editing.png)](https://static.premai.io/book/unaligned-models-llm-editing.png)

Fig. 48 Example of [ROME](../#term-ROME) editing to [make a GPT model think that the Eiffel Tower is in Rome](https://rome.baulab.info)[#](#id25 "Permalink to this image")

The code has been made available [in a notebook](https://colab.research.google.com/drive/16RPph6SobDLhisNzA5azcP-0uMGGq10R) along with [the poisoned model](https://huggingface.co/mithril-security/gpt-j-6B).

### 1.4.WizardLM Uncensored[#](#wizardlm-uncensored "Permalink to this heading")

`审查`是训练AI模型（例如`WizardLM`）的一个关键方面，可以使用`对齐的指令数据集`。对齐的模型可能会`拒绝回答`，或者在涉及`非法`或`不道德`活动的情景中，提供带`有偏见`（被调整）的回应。


[![https://static.premai.io/book/unaligned-models-censoring.png](https://static.premai.io/book/unaligned-models-censoring.png)](https://static.premai.io/book/unaligned-models-censoring.png)

Fig. 49 Model Censoring \[[127](../references/#id46 "Eric Hartford. Uncensored models. 2023. URL: https://erichartford.com/uncensored-models.")\][#](#id26 "Permalink to this image")

Uncensoring \[[127](../references/#id46 "Eric Hartford. Uncensored models. 2023. URL: https://erichartford.com/uncensored-models.")\], however, takes a different route, aiming to identify and eliminate these alignment-driven restrictions while retaining valuable knowledge. In the case of [WizardLM Uncensored](https://huggingface.co/ehartford/WizardLM-7B-Uncensored), it closely follows the uncensoring methods initially devised for models like [Vicuna](../models/#vicuna), adapting the script used for [Vicuna](https://huggingface.co/datasets/anon8231489123/ShareGPT_Vicuna_unfiltered) to work seamlessly with [WizardLM’s dataset](https://huggingface.co/datasets/ehartford/WizardLM_alpaca_evol_instruct_70k_unfiltered). This intricate process entails dataset filtering to remove undesired elements, and [Fine-tuning](../fine-tuning/) the model using the refined dataset.

[![https://static.premai.io/book/unaligned-models-uncensoring.png](https://static.premai.io/book/unaligned-models-uncensoring.png)](https://static.premai.io/book/unaligned-models-uncensoring.png)

Fig. 50 Model Uncensoring \[[127](../references/#id46 "Eric Hartford. Uncensored models. 2023. URL: https://erichartford.com/uncensored-models.")\][#](#id27 "Permalink to this image")

For a comprehensive, step-by-step explanation with working code see this blog: \[[127](../references/#id46 "Eric Hartford. Uncensored models. 2023. URL: https://erichartford.com/uncensored-models.")\].

Similar models have been made available:

+   [WizardLM 30B-Uncensored](https://huggingface.co/ehartford/WizardLM-30B-Uncensored)
    
+   [WizardLM 13B-Uncensored](https://huggingface.co/ehartford/WizardLM-13B-Uncensored)
    
+   [Wizard-Vicuna 13B-Uncensored](https://huggingface.co/ehartford/Wizard-Vicuna-13B-Uncensored)
    

### 1.5.Falcon 180B[#](#falcon-180b "Permalink to this heading")

[Falcon 180B](https://huggingface.co/tiiuae/falcon-180B) has been released [allowing commercial use](https://huggingface.co/spaces/tiiuae/falcon-180b-license/blob/main/LICENSE.txt). It excels in [SotA](../#term-SotA) performance across natural language tasks, surpassing previous open-source models and rivalling [PaLM-2](../models/#palm-2). This LLM even outperforms [LLaMA-2 70B](../models/#llama-2) and OpenAI’s [GPT-3.5](../models/#chatgpt).

[![https://static.premai.io/book/unaligned-models-falcon-180B-performance.png](https://static.premai.io/book/unaligned-models-falcon-180B-performance.png)](https://static.premai.io/book/unaligned-models-falcon-180B-performance.png)

Fig. 51 Performance comparison \[[134](../references/#id56 "Roger Montti. New open source LLM with zero guardrails rivals google's PaLM 2. 2023. URL: https://www.searchenginejournal.com/new-open-source-llm-with-zero-guardrails-rivals-google-palm-2/496212.")\][#](#id28 "Permalink to this image")

Falcon 180B has been trained on [RefinedWeb](https://huggingface.co/datasets/tiiuae/falcon-refinedweb), that is a collection of internet content, primarily sourced from the [Common Crawl](https://commoncrawl.org) open-source dataset. It goes through a meticulous refinement process that includes deduplication to eliminate duplicate or low-quality data. The aim is to filter out machine-generated spam, repeated content, plagiarism, and non-representative text, ensuring that the dataset provides high-quality, human-written text for research purposes \[[111](../references/#id57 "Guilherme Penedo, Quentin Malartic, Daniel Hesslow, Ruxandra Cojocaru, Alessandro Cappelli, Hamza Alobeidli, Baptiste Pannier, Ebtesam Almazrouei, and Julien Launay. The refinedweb dataset for falcon LLM: outperforming curated corpora with web data, and web data only. 2023. arXiv:2306.01116.")\].

Differently from [WizardLM Uncensored](#wizardlm-uncensored), which is an uncensored model, Falcon 180B stands out due to its unique characteristic: it hasn’t undergone alignment (zero guardrails) tuning to restrict the generation of harmful or false content. 

This capability enables users to [fine-tune](../fine-tuning/) the model for generating content that was previously unattainable with other aligned models.

## 2.Security measures[#](#security-measures "Permalink to this heading")

As cybercriminals continue to leverage LLMs for training AI chatbots in phishing and malware attacks \[[135](../references/#id47 "Bill Toulas. Cybercriminals train AI chatbots for phishing, malware attacks. 2023. URL: https://www.bleepingcomputer.com/news/security/cybercriminals-train-ai-chatbots-for-phishing-malware-attacks.")\], it becomes increasingly crucial for individuals and businesses to proactively fortify their defenses and protect against the rising tide of fraudulent activities in the digital landscape.

随着网络犯罪分子继续利用LLM，来训练AI聊天机器人，进行`网络钓鱼`和`恶意软件攻击`\[[135](../references/#id47 "Bill Toulas. Cybercriminals train AI chatbots for phishing, malware attacks. 2023. URL: https://www.bleepingcomputer.com/news/security/cybercriminals-train-ai-chatbots-for-phishing-malware-attacks.")\]，个人和企业积极加强自身防御，保护免受`数字欺诈`的威胁，变得日益重要。

Models like [PoisonGPT](#poisongpt) demonstrate the ease with which an LLM can be manipulated to yield false information without undermining the accuracy of other facts. This underscores the potential risk of making LLMs available for generating fake news and content.

一个关键问题是，当前无法将`模型的权重`与训练过程中使用的`代码`和`数据`**绑定在一起**。

一个潜在的（尽管昂贵）解决方案是`重新训练模型`，或者另一种选择是一个`可信任中间人/机构`可以使用`加密签名`对模型进行`认证`，以证明它所依赖的`数据`和`源代码`**可信** \[[136](../references/#id55 "Separate-Still3770. PoisonGPT: example of poisoning LLM supply chain to hide a lobotomized LLM on Hugging Face to spread fake news. 2023. URL: https://www.reddit.com/r/MachineLearning/comments/14v2zvg/p_poisongpt_example_of_poisoning_llm_supply_chain.")\]。

另一个选项是，尝试自动区分有害的LLM生成的内容（例如虚假新闻、网络钓鱼邮件等）和真实的、经认证的材料。

* 可以通过黑盒（训练鉴别器）或白盒（使用已知的水印）检测来区分LLM生成的文本和人工生成的文本\[[137](../references/#id58 "Ruixiang Tang, Yu-Neng Chuang, and Xia Hu. The science of detecting LLM-generated texts. 2023. arXiv:2303.07205.")\]。
* 此外，通常可以通过语气[138]自动区分真实事实和虚假新闻 - 即语言风格可能是科学和事实性的（强调准确性和逻辑）或情感和耸人听闻的（具有夸张的声明和缺乏证据）。


## 3.Future[#](#future "Permalink to this heading")

There is ongoing debate over alignment criteria.

Maligned AI models (like [FraudGPT](#fraudgpt), [WormGPT](#wormgpt), and [PoisonGPT](#poisongpt)) – which are designed to aid cyberattacks, malicious code generation, and the spread of misinformation – should probably be illegal to create or use.

On the flip side, unaligned (e.g. [Falcon 180B](#falcon-180b)) or even uncensored (e.g. [WizardLM Uncensored](#wizardlm-uncensored)) models offer a compelling alternative. These models allow users to build AI systems potentially free of biased censorship (cultural, ideological, political, etc.), ushering in a new era of personalised experiences. Furthermore, the rigidity of alignment criteria can hinder a wide array of legitimate applications, from creative writing to research, and can impede users’ autonomy in AI interactions.

Disregarding uncensored models or dismissing the debate over them is probably not a good idea.

























[NingG]:    http://ningg.github.io  "NingG"
[premAI]:		https://book.premai.io/state-of-open-source-ai/








