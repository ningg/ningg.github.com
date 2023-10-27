---
layout: post
title: AI系列：Code Llama 在本地 Mac 上运行
description: 试用 Code Llama 
published: true
categories: AI OpenAI llama
---

## 1.核心步骤

几个步骤：

* 1.下载 [Code Llama 的仓库代码](https://github.com/facebookresearch/codellama)
* 2.在网站中，登记接受协议[llama-downloads](https://ai.meta.com/resources/models-and-libraries/llama-downloads/)，并在邮件中获取 `model weights` 和 `tokenizers` 的下载地址；
* 3.运行脚本 `download.sh` 并输入邮件中获取到的`链接`，最后选择模型参数，本地运行建议选择 `CodeLlama-7b-Instruct`。

提示信息中，可用的模型：

1. CodeLlama-7b
1. CodeLlama-13b
1. CodeLlama-34b
1. CodeLlama-7b-Python
1. CodeLlama-13b-Python
1. CodeLlama-34b-Python
1. CodeLlama-7b-Instruct：*推荐此模型*
1. CodeLlama-13b-Instruct
1. CodeLlama-34b-Instruct



## 2.准备工作

运行 `download.sh` 脚本之前，需要确认已经安装了 `wget` 和 `md5sum`：

```
// mac 环境，采用下述命令
brew install md5sha1sum
```

安装 conda：

* [Conda 简介，环境管理、依赖管理](https://ningg.top/python-series-conda-env-manage-intro/)


安装 conda 后，创建一个 python = 3.8 的环境：

```
// 指定了特定的 mirror 镜像源，用于提升依赖的下载速度
conda create -n codellama -c https://mirrors.tuna.tsinghua.edu.cn/anaconda/pkgs/main python=3.8
```


关联资料：

* [GitHub - Code Llama](https://github.com/facebookresearch/codellama)


## 3.第一个 code llama 示例

下载 [Code Llama 的仓库代码](https://github.com/facebookresearch/codellama) 后，命令行终端窗口内：

```
// conda， 创建 python=3.8 的环境
conda create -n codellama -c https://mirrors.tuna.tsinghua.edu.cn/anaconda/pkgs/main python=3.8

// 切换到刚刚创建的 codellama 环境
conda activate codellama

// 安装 pytorch
conda install pytorch

// 进入 codellama 代码的目录
cd codellama

// 安装依赖（下载依赖的 torch 等包，可能耗时较长）
pip install -e .

```

完成上述准备后，直接进行下面的示例，[README](https://github.com/facebookresearch/codellama/blob/main/README.md)。

Different models require different model-parallel (MP) values:

|  Model | MP |
|--------|----|
| 7B     | 1  |
| 13B    | 2  |
| 34B    | 4  |

All models support sequence lengths up to 100,000 tokens, but we pre-allocate the cache according to `max_seq_len` and `max_batch_size` values. So set those according to your hardware and use-case.

### Fine-tuned Instruction Models

Code Llama - Instruct models are fine-tuned to follow instructions. To get the expected features and performance for them, a specific formatting defined in [`chat_completion`](https://github.com/facebookresearch/codellama/blob/main/llama/generation.py#L279-L366)
needs to be followed, including the `INST` and `<<SYS>>` tags, `BOS` and `EOS` tokens, and the whitespaces and linebreaks in between (we recommend calling `strip()` on inputs to avoid double-spaces).
You can use `chat_completion` directly to generate answers with the instruct model. 

You can also deploy additional classifiers for filtering out inputs and outputs that are deemed unsafe. See the llama-recipes repo for [an example](https://github.com/facebookresearch/llama-recipes/blob/main/src/llama_recipes/inference/safety_utils.py) of how to add a safety checker to the inputs and outputs of your inference code.

Examples using `CodeLlama-7b-Instruct`:

```
torchrun --nproc_per_node 1 example_instructions.py \
    --ckpt_dir CodeLlama-7b-Instruct/ \
    --tokenizer_path CodeLlama-7b-Instruct/tokenizer.model \
    --max_seq_len 64 --max_batch_size 2
```

Fine-tuned instruction-following models are: the Code Llama - Instruct models `CodeLlama-7b-Instruct`, `CodeLlama-13b-Instruct`, `CodeLlama-34b-Instruct`.

Code Llama is a new technology that carries potential risks with use. Testing conducted to date has not — and could not — cover all scenarios.
In order to help developers address these risks, we have created the [Responsible Use Guide](https://github.com/facebookresearch/llama/blob/main/Responsible-Use-Guide.pdf). More details can be found in our research papers as well.




## 附录

### 附录A. 收到的模型下载邮件

Code Llama commercial license

**You’re all set to start building with Code Llama.**  
The models listed below are now available to you as a commercial license holder. By downloading a model, you are agreeing to the terms and conditions of the [license](https://l.facebook.com/l.php?u=https%3A%2F%2Fai.meta.com%2Fllama%2Flicense&h=AT0ccARzMSeQAhMRGxn9fgZ8m22z6xFuJmYLJh_R9_pxmJNZFGS_1qOelP3HHEobIMAnlvtLyFo9D__hq3zwhHyh6XgDzTaymUyV9U-_q1hmOPnZgL6CKWFWeOVecES8PXqVt3_2frf7U83u), [acceptable use policy](https://l.facebook.com/l.php?u=https%3A%2F%2Fai.meta.com%2Fllama%2Fuse-policy&h=AT2LpsAsf4Rm2PfZ3PqWLTmPLAvSOrIPUOzU2qtE0iylg0p4pjo49OG0Y39j_bQ8JYYVk4pr_4kTZfZXLM-mroPi6mJuLClfBc4n0v-ZLunQhyjKNaL-W5w22rCURPmSxc9LF-8ALSgfcu7m) and Meta’s [privacy policy](https://www.facebook.com/privacy/policy/).  
  
**Model weights available:**

+   CodeLlama-7b
+   CodeLlama-13b
+   CodeLlama-34b
+   CodeLlama-7b-Python
+   CodeLlama-13b-Python
+   CodeLlama-34b-Python
+   CodeLlama-7b-Instruct
+   CodeLlama-13b-Instruct
+   CodeLlama-34b-Instruct

With each model download, you’ll receive a copy of the [License](https://l.facebook.com/l.php?u=https%3A%2F%2Fai.meta.com%2Fllama%2Flicense&h=AT3ZdwPdPMMw3rF8Vm_W0dYr72bH-5WuET0UvwgMsTiLGuBCZG5hZEpk-pf8O6bi-Tkgp8WwmzZi52rfSdru-rjX5Yvx6LuqqmWcX1QvpEav7XsPK83_Z7Lg-x3XEOdKGGAyV_qmO7h-ovpO) and [Acceptable Use Policy](https://l.facebook.com/l.php?u=https%3A%2F%2Fai.meta.com%2Fllama%2Fuse-policy&h=AT2ej75gNTG0iz821ie6mlrPyP9Ew2f8XB3VudSIb3CPv5GlWmlobCUi4Wm2kap6sfc1GRjeoAyR9pF28F1X0QCJzk5xslKjDTTd_wlRE1fT-Ioamlsm9t9LhI7yrDYoCHYRydvtT6L1xfFn), and can find all other information on the model and code on [GitHub](https://l.facebook.com/l.php?u=https%3A%2F%2Fgithub.com%2Ffacebookresearch%2Fllama&h=AT2tPPRu90EvSbRpYE7P9nALb-zusbsT5yDc7XKoTeA3mNrvVhTppNWQ81IubxCQ8acKiEQnjH8WJIFnMFfl3NhktxGxajcG-ExqaM5ZxCp4qY9Hk1sXSIfPDUqd3IjcGKZz3Wr5vDx7Ri8h).

**How to download the models:**

1.  Visit [the Code Llama repository](http://github.com/facebookresearch/codellama) in GitHub and follow the instructions in the [README](https://l.facebook.com/l.php?u=https%3A%2F%2Fgithub.com%2Ffacebookresearch%2Fcodellama%2Fblob%2Fmain%2FREADME.md&h=AT3iJL4nCNIpDRFf5ymgoblIYqUdH1aHBKcuK1E02qLX6HzaFGuFT0OyEEZhUHeywrTcMSttLDl67--W3cYmXYcnvXMPriC_YIjt8nibsY6UiUsI5LVPYfrKxv_dGu8b4bosfesfNiwJ7uxV) to run the download.sh script.
2.  When asked for your unique custom URL, please insert the following:  [personal link url - use youself]
3.  Select which model weights to download

The unique custom URL provided will remain valid for model downloads for 24 hours, and requests can be submitted multiple times.  
Now you’re ready to start building with Code Llama.  

**Helpful tips:**

Please read the instructions in the GitHub repo and use the provided code examples to understand how to best interact with the models. In particular, for the fine-tuned chat models you must use appropriate formatting and correct system/instruction tokens to get the best results from the model.  
You can find additional information about how to responsibly deploy Llama models in our [Responsible Use Guide](https://l.facebook.com/l.php?u=https%3A%2F%2Fai.meta.com%2Fllama%2Fresponsible-use-guide&h=AT1VPrtQFFczH_jyZxwCMKrSfWN_XQbPiBoHPCFqF-8ekbnptItgmDPhxQHw2wmS7DhcjeVlVOt2dmWcrCBOYsklszLttwyB4d_p5lpxIhZtAufMp69-Yyr0t66xn_qrHKW4ylejt-m09N2J).  
  
**If you need to report issues:**

If you or any Code Llama user becomes aware of any violation of our license or acceptable use policies - or any bug or issues with Code Llama that could lead to any such violations - please report it through one of the following means:

1.  Reporting issues with the model: [Code Llama GitHub](https://l.facebook.com/l.php?u=https%3A%2F%2Fgithub.com%2Ffacebookresearch%2Fcodellama&h=AT0crLONdEfZ3MFn4z1-R7kLXfXXkgdd7a_RIu-OTJOVtlsbLnOY3qG90oxA3pt3iIInRZkdjI5upOHHIXkdO13z29SYX8x7BaXRAQJmyGeg9AbRnjhPJiJ38LjGj2ByXLtp_YGQWPyYNd2y)
2.  Giving feedback about potentially problematic output generated by the model: [Llama output feedback](https://developers.facebook.com/llama_output_feedback)
3.  Reporting bugs and security concerns: [Bug Bounty Program](https://facebook.com/whitehat/info)
4.  Reporting violations of the Acceptable Use Policy: [LlamaUseReport@meta.com](mailto:LlamaUseReport@meta.com)

[Subscribe](https://l.facebook.com/l.php?u=https%3A%2F%2Fgo.atmeta.com%2FLlama_Subscribers.html&h=AT0FdWw9XHlNFIhUcW4tThYvjjuKg9pMWLqYTMODYEzXqOUMQegJO1a1S9cPs3eOg-7oSoPQ-zKWNUDyQNo-glAEeS__dB7JopJEzR2SmBOv1j_B7kx9GqNKRHjN44QAgRB_Y_IgGPZtwCz0) to get the latest updates on Llama and Meta AI.  
  
Meta’s GenAI Team























[NingG]:    http://ningg.github.io  "NingG"





