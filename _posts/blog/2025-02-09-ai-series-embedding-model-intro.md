---
layout: post
title: AI 系列：Ollama 上，部署 embedding model
description: 本地部署嵌入模型，尝试文档的向量嵌入
published: true
category: AI
---

焦点： 本地 Ollama 安装 embedding model。

## 1. embedding model 来源

两个常用来源：

* Ollama 官方库： [https://ollama.com/search?c=embedding](https://ollama.com/search?c=embedding) 其中，只包含了一部分 embedding model，可以尝试使用。
* Hugging Face：MTEB（Massive Text Embedding Benchmark）排行榜， [https://huggingface.co/spaces/mteb/leaderboard](https://huggingface.co/spaces/mteb/leaderboard)


## 2. 安装 embedding model

Ollama 官方库中 embedding model 直接拉取：

```
ollama pull nomic-embed-text
ollama pull mxbai-embed-large
```
类似地，指定 Hugging Face 模型也可：

```
# ollama pull hf.co/用户名/模型仓库
# https://huggingface.co/Alibaba-NLP/gte-multilingual-base
# https://huggingface.co/Lajavaness/bilingual-embedding-small
# 需要对应模型，支持 GGUF 格式，或者跟 llama.cpp 兼容，否则也无法使用；上面两个模型就无法使用
ollama pull hf.co/用户名/模型仓库
```

## 3.运行模型

```
# 查询已安装的模型
ollama list

# 运行模型(不支持 embedding 模型， 支持 llm 模型)
ollama run 模型名称
```

对于 embedding 模型，则需要使用其他工具，可以直接调用：
```
curl http://localhost:11434/api/embeddings -d '{
  "model": "nomic-embed-text",
  "prompt": "The sky is blue because of Rayleigh scattering"
}'
```
完整细节，参考： [https://ollama.com/library/nomic-embed-text](https://ollama.com/library/nomic-embed-text)































[NingG]:    http://ningg.github.io  "NingG"










