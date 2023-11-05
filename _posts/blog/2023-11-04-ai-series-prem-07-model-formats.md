---
layout: post
title: AI 系列：Model Formats
description: 模型格式
published: true
category: AI
---


原文：[Model Formats](https://book.premai.io/state-of-open-source-ai/model-formats/)


As [ML model](../models/) applications increase, so too does the need for optimising the models for specific use-cases. 

近期涌现了很多`模型格式`（model formats），用于解决**成本过高**和**可移植性**问题。





Table 8 Comparison of popular model formats[#](#model-format-table "Permalink to this table")

| Feature | [ONNX](#onnx) | [GGML](#ggml) | [TensorRT](#tensorrt) | 
| --- | --- | --- | --- | 
| Ease of Use | 🟢 [good](#onnx-usage) | 🟡 [moderate](#ggml-usage) | 🟡 [moderate](#tensorrt-usage) | 
| Integration with Deep Learning Frameworks | 🟢 [most](#onnx-support) | 🟡 [growing](#ggml-support) | 🟡 [growing](#tensorrt-support) | 
| Deployment Tools | 🟢 [yes](#onnx-runtime) | 🔴 no | 🟢 [yes](#triton-inference) | 
| Interoperability | 🟢 [yes](#onnx-interoperability) | 🔴 no | 🔴 [no](#tensorrt-interoperability) | 
| Inference Boost | 🟡 moderate | 🟢 good | 🟢 good | 
| Quantisation Support | 🟡 [good](#onnx-quantisation) | 🟢 [good](#ggml-quantisation) | 🟡 [moderate](#tensorrt-quantisation) | 
| Custom Layer Support | 🟢 [yes](#onnx-custom-layer) | 🔴 limited | 🟢 [yes](#tensorrt-custom-layer) | 
| Maintainer | [LF AI & Data Foundation](https://wiki.lfaidata.foundation) | [ggerganov](https://github.com/ggerganov) | [NVIDIA](https://github.com/NVIDIA) |




Table 9 Model Formats Repository Statistics[#](#model-format-repo-table "Permalink to this table")

| Repository | Commit Rate | Stars | Contributors | Issues | Pull Requests | 
| --- | --- | --- | --- | --- | --- | 
| [ggerganov/ggml](https://repo-tracker.com/r/gh/ggerganov/ggml) | ![](https://img.shields.io/github/commit-activity/m/ggerganov/ggml?label=%20) | ![](https://img.shields.io/github/stars/ggerganov/ggml?label=%20) | ![](https://img.shields.io/github/contributors-anon/ggerganov/ggml?label=%20) | ![](https://img.shields.io/github/issues-search/ggerganov/ggml?query=is%3Aissue&label=%20) | ![](https://img.shields.io/github/issues-search/ggerganov/ggml?query=is%3Apr&label=%20) | 
| [ggerganov/llama.cpp](https://repo-tracker.com/r/gh/ggerganov/llama.cpp) | ![](https://img.shields.io/github/commit-activity/m/ggerganov/llama.cpp?label=%20) | ![](https://img.shields.io/github/stars/ggerganov/llama.cpp?label=%20) | ![](https://img.shields.io/github/contributors-anon/ggerganov/llama.cpp?label=%20) | ![](https://img.shields.io/github/issues-search/ggerganov/llama.cpp?query=is%3Aissue&label=%20) | ![](https://img.shields.io/github/issues-search/ggerganov/llama.cpp?query=is%3Apr&label=%20) | 
| [onnx/onnx](https://repo-tracker.com/r/gh/onnx/onnx) | ![](https://img.shields.io/github/commit-activity/m/onnx/onnx?label=%20) | ![](https://img.shields.io/github/stars/onnx/onnx?label=%20) | ![](https://img.shields.io/github/contributors-anon/onnx/onnx?label=%20) | ![](https://img.shields.io/github/issues-search/onnx/onnx?query=is%3Aissue&label=%20) | ![](https://img.shields.io/github/issues-search/onnx/onnx?query=is%3Apr&label=%20) | 
| [microsoft/onnxruntime](https://repo-tracker.com/r/gh/microsoft/onnxruntime) | ![](https://img.shields.io/github/commit-activity/m/microsoft/onnxruntime?label=%20) | ![](https://img.shields.io/github/stars/microsoft/onnxruntime?label=%20) | ![](https://img.shields.io/github/contributors-anon/microsoft/onnxruntime?label=%20) | ![](https://img.shields.io/github/issues-search/microsoft/onnxruntime?query=is%3Aissue&label=%20) | ![](https://img.shields.io/github/issues-search/microsoft/onnxruntime?query=is%3Apr&label=%20) | 
| [nvidia/tensorrt](https://repo-tracker.com/r/gh/NVIDIA/TensorRT) | ![](https://img.shields.io/github/commit-activity/m/NVIDIA/TensorRT?label=%20) | ![](https://img.shields.io/github/stars/NVIDIA/TensorRT?label=%20) | ![](https://img.shields.io/github/contributors-anon/NVIDIA/TensorRT?label=%20) | ![](https://img.shields.io/github/issues-search/NVIDIA/TensorRT?query=is%3Aissue&label=%20) | ![](https://img.shields.io/github/issues-search/NVIDIA/TensorRT?query=is%3Apr&label=%20) |


Based on the above stats, it looks like ggml is the most popular library currently, followed by onnx. Also one thing to note here is onnx repositories are around ~9x older compared to ggml repositories.

ONNX feels truly OSS, since it’s run by an OSS community, whereas both GGML and friends, TensorRT are run by Organisations (even though they are open source), and final decisions are made by a single (sometimes closed) entity which can finally affect on what kind of features that entity prefers or has biases towards even though both can have amazing communities at the same time.

## ONNX[#](#onnx "Permalink to this heading")

[ONNX (Open Neural Network Exchange，开放神经网络交换)](https://onnx.ai) 提供了一个开源的AI模型格式，它通过定义可扩展的**计算图模型**，以及**内置操作符**和**标准数据类型**的定义，为AI模型提供了一个标准格式。它得到了[广泛的支持](https://onnx.ai/supported-tools)，可以在许多框架、工具和硬件中找到，从而实现了不同框架之间的互操作性。ONNX是您模型的一个中间表示，使您能够轻松地在不同的环境中切换。


### Features and Benefits[#](#features-and-benefits "Permalink to this heading")

[![https://static.premai.io/book/model-formats-onnx.png](https://static.premai.io/book/model-formats-onnx.png)](/images/ai-series/premAI/model-formats-onnx.png)

Fig. 56 [https://cms-ml.github.io/documentation/inference/onnx.html](https://cms-ml.github.io/documentation/inference/onnx.html)[#](#onnx-interoperability "Permalink to this image")

+   **Model Interoperability:** 模型互操作性：ONNX实现了AI框架之间的互通，允许模型在它们之间无缝传输，消除了复杂的转换需求。

+   **Computation Graph Model:** 计算图模型：ONNX的核心是一个图模型，将AI模型表示为有向图，其中包含用于操作的节点，提供了灵活性。

+   **Standardised Data Types:** 标准化数据类型：ONNX建立了标准数据类型，确保在交换模型时保持一致性，减少数据类型问题。

+   **Built-in Operators:** 内置操作符：ONNX拥有丰富的内置操作符库，用于常见的AI任务，实现了跨框架的一致计算。
    
+   **ONNX Ecosystem:**
    
    +   [microsoft/onnxruntime](https://github.com/microsoft/onnxruntime) A high-performance inference engine for cross-platform ONNX models.
        
    +   [onnx/onnxmltools](https://github.com/onnx/onnxmltools) Tools for ONNX model conversion and compatibility with frameworks like TensorFlow and PyTorch.
        
    +   [onnx/models](https://github.com/onnx/models) A repository of pre-trained models converted to ONNX format for various tasks.
        
    +   [Hub](https://github.com/onnx/onnx/blob/main/docs/Hub.md): Helps sharing and collaborating on ONNX models within the community.
        

### Usage[#](#usage "Permalink to this heading")

Usability around ONNX is fairly developed and has lots of tooling support around it by the community, let’s see how we can directly export into onnx and make use of it.

Firstly the model needs to be converted to ONNX format using a relevant [converter](https://onnx.ai/onnx/intro/converters.html), for example if our model is created using Pytorch, for conversion we can use:

+   [`torch.onnx.export`](https://pytorch.org/docs/stable/onnx.html)
    
    +   For [custom operators support](https://pytorch.org/docs/master/onnx.html#custom-operators) same exporter can be used.
        
+   [`optimum`](https://github.com/huggingface/optimum#onnx--onnx-runtime) by [huggingface](https://huggingface.co/docs/transformers/serialization#export-to-onnx)
    

Once exported we can load, manipulate, and run ONNX models. Let’s take a Python example:

To install the official `onnx` python package:

pip install onnx

Copy to clipboard

To load, manipulate, and run ONNX models in your Python applications:

import onnx

\# Load an ONNX model
model \= onnx.load("your\_awesome\_model.onnx")

\# Perform inference with the model
\# (Specific inference code depends on your application and framework)

Copy to clipboard

### Support[#](#support "Permalink to this heading")

Many frameworks/tools are supported, with many examples/tutorials at [onnx/tutorials](https://github.com/onnx/tutorials#converting-to-onnx-format).

It has support for Inference runtime binding APIs written in [few programming languages](https://onnxruntime.ai/docs/install/#inference-install-table-for-all-languages) ([python](https://onnxruntime.ai/docs/install/#python-installs), [rust](https://github.com/microsoft/onnxruntime/tree/main/rust), [js](https://github.com/microsoft/onnxruntime/tree/main/js), [java](https://github.com/microsoft/onnxruntime/tree/main/java), [C#](https://github.com/microsoft/onnxruntime/tree/main/csharp)).

ONNX model’s inference depends on the platform which runtime library supports, called Execution Provider. Currently there are few ranging from CPU based, GPU based, IoT/edge based and few others. A full list can be found [here](https://onnxruntime.ai/docs/execution-providers/#summary-of-supported-execution-providers).

Onnxruntime has few [example tools](https://github.com/microsoft/onnxruntime-inference-examples/tree/main/quantization) that can be used to quantize select ONNX models. Support is currenty based on operators in the model. Read more [here](https://onnxruntime.ai/docs/performance/quantization.html).

Also there are few visualisation tools support like [lutzroeder/Netron](https://github.com/lutzroeder/Netron) and [more](https://github.com/onnx/tutorials#visualizing-onnx-models) for models converted to ONNX format, highly recommended for debugging purposes.

#### Future[#](#future "Permalink to this heading")

Currently ONNX is part of [LF AI Foundation](https://wiki.lfaidata.foundation/pages/viewpage.action?pageId=327683), conducts regular [Steering committee meetings](https://wiki.lfaidata.foundation/pages/viewpage.action?pageId=18481196) and community meetups are held atleast once a year. Few notable presentations from this year’s meetup:

+   [ONNX 2.0 Ideas](https://www.youtube.com/watch?v=A3NwCnUOUaU).
    
+   [Analysis of Failures and Risks in Deep Learning Model Converters: A Case Study in the ONNX Ecosystem](https://www.youtube.com/watch?v=2TFP517aoKo).
    
+   [On-Device Training with ONNX Runtime](https://www.youtube.com/watch?v=_fUslaITI2I): enabling training models on edge devices without the data ever leaving the device.
    

Checkout the [full list here](https://wiki.lfaidata.foundation/display/DL/ONNX+Community+Day+2023+-+June+28).

### Limitations[#](#limitations "Permalink to this heading")

Onnx uses [Opsets](https://onnx.ai/onnx/intro/converters.html#opsets) (Operator sets) number which changes with each ONNX package minor/major releases, new opsets usually introduces new [operators](https://onnx.ai/onnx/operators). Proper opset needs to be used while creating the onnx model graph.

Also it currently doesn’t support 4-bit quantisation ([microsoft/onnxruntime#14997](https://github.com/microsoft/onnxruntime/issues/14997)).

There are lots of open issues ([microsoft/onnxruntime#12880](https://github.com/microsoft/onnxruntime/issues/12880), [#10303](https://github.com/microsoft/onnxruntime/issues/10303), [#7233](https://github.com/microsoft/onnxruntime/issues/7233), [#17116](https://github.com/microsoft/onnxruntime/issues/17116)) where users are getting slower inference speed after converting their models to ONNX format when compared to base model format, it shows that conversion might not be easy for all models. On similar grounds an user comments 3 years ago [here](https://www.reddit.com/r/MachineLearning/comments/lyem1l/discussion_pros_and_cons_of_onnx_format/gqlh8d3) though it’s old, few points still seems relevant. [The troubleshooting guide](https://onnxruntime.ai/docs/performance/tune-performance/troubleshooting.html) by ONNX runtime community can help with commonly faced issues.

Usage of Protobuf for storing/reading of ONNX models also seems to be causing few limitations which is discussed [here](https://news.ycombinator.com/item?id=36870731).

There’s a detailed failure analysis ([video](https://www.youtube.com/watch?v=Ks3rPKfiE-Y), [ppt](https://wiki.lfaidata.foundation/download/attachments/84705448/02_pu-ONNX%20Day%20Presentation%20-%20Jajal-Davis.pdf)) done by [James C. Davis](https://davisjam.github.io) and [Purvish Jajal](https://www.linkedin.com/in/purvish-jajal-989774190) on ONNX converters.

![https://static.premai.io/book/model-formats_onnx-issues.png](https://static.premai.io/book/model-formats_onnx-issues.png)

![https://static.premai.io/book/model-formats_onnx-issues-table.png](https://static.premai.io/book/model-formats_onnx-issues-table.png)

Fig. 57 Analysis of Failures and Risks in Deep Learning Model Converters \[[143](../references/#id151 "Purvish Jajal, Wenxin Jiang, Arav Tewari, Joseph Woo, Yung-Hsiang Lu, George K. Thiruvathukal, and James C. Davis. Analysis of failures and risks in deep learning model converters: a case study in the ONNX ecosystem. 2023. arXiv:2303.17708.")\][#](#id15 "Permalink to this image")

The top findings were:

+   Crash (56%) and Wrong Model (33%) are the most common symptoms
    
+   The most common failure causes are Incompatibility and Type problems, each making up ∼25% of causes
    
+   The majority of failures are located with the Node Conversion stage (74%), with a further 10% in the Graph optimisation stage (mostly from tf2onnx).
    

See also

+   [How to add a new ONNX Operator](https://github.com/onnx/onnx/blob/main/docs/AddNewOp.md)
    
+   [ONNX Backend Scoreboard](https://onnx.ai/backend-scoreboard)
    
+   [Intro to ONNX](https://onnx.ai/onnx/intro)
    
+   [ONNX Runtime](https://onnxruntime.ai)
    
+   [webonnx/wonnx](https://github.com/webonnx/wonnx) (GPU-based ONNX inference runtime in Rust)
    
+   [Hacker News discussion on ONNX runtimes & ONNX](https://news.ycombinator.com/item?id=36863522)
    

## GGML[#](#ggml "Permalink to this heading")

[ggerganov/ggml](https://github.com/ggerganov/ggml) is a tensor library for machine learning to enable large models and high performance on commodity hardware – the “GG” refers to the initials of its originator [Georgi Gerganov](https://github.com/ggerganov). In addition to defining low-level machine learning primitives like a tensor type, GGML defines a binary format for distributing large language models (LLMs). [llama.cpp](https://github.com/ggerganov/llama.cpp) and [whisper.cpp](https://github.com/ggerganov/whisper.cpp) are based on it.

### Features and Benefits[#](#id4 "Permalink to this heading")

+   Written in C
    
+   16-bit float and integer quantisation support (e.g. 4-bit, 5-bit, 8-bit)
    
+   Automatic differentiation
    
+   Built-in optimisation algorithms (e.g. ADAM, L-BFGS)
    
+   Optimised for Apple Silicon, on x86 arch utilises AVX / AVX2 intrinsics
    
+   Web support via WebAssembly and WASM SIMD
    
+   No third-party dependencies
    
+   zero memory allocations during runtime
    

To know more, see their [manifesto here](https://github.com/ggerganov/llama.cpp/discussions/205)

### Usage[#](#ggml-usage "Permalink to this heading")

Overall GGML is moderate in terms of usability given it’s a fairly new project and growing, but has lots of [community support](#ggml-support) already.

Here’s an example inference of GPT-2 GGML:

git clone https://github.com/ggerganov/ggml
cd ggml
mkdir build && cd build
cmake ..
make \-j4 gpt\-2

\# Run the GPT-2 small 117M model
../examples/gpt\-2/download\-ggml\-model.sh 117M
./bin/gpt\-2 \-m models/gpt\-2\-117M/ggml\-model.bin \-p "This is an example"

Copy to clipboard

### Working[#](#working "Permalink to this heading")

For usage, the model should be saved in the particular GGML file format which consists binary-encoded data that has a particular format specifying what kind of data is present in the file, how it is represented, and the order in which it appears.

For a valid GGML file the following pieces of information should be present in order:

1.  **GGML version number:** To support rapid development without sacrificing backwards-compatibility, GGML uses versioning to introduce improvements that may change the format of the encoding. The first value present in a valid GGML file is a “magic number” that indicates the GGML version that was used to encode the model. Here’s a [GPT-2 conversion example](https://github.com/ggerganov/ggml/blob/6319ae9ad7bdf9f834b2855d7e9fa70508e82f57/examples/gpt-2/convert-cerebras-to-ggml.py#L67) where it’s getting written.
    
2.  **Components of LLMs:**
    
    1.  **Hyperparameters:** These are parameters which configures the behaviour of models. Valid GGML files lists these values in the correct order, and each value represented using the correct data type. Here’s an [example for GPT-2](https://github.com/ggerganov/ggml/blob/6319ae9ad7bdf9f834b2855d7e9fa70508e82f57/examples/gpt-2/convert-cerebras-to-ggml.py#L68-L72).
        
    2.  **Vocabulary:** These are all supported tokens for a model. Here’s an [example for GPT-2](https://github.com/ggerganov/ggml/blob/6319ae9ad7bdf9f834b2855d7e9fa70508e82f57/examples/gpt-2/convert-cerebras-to-ggml.py#L78-L83).
        
    3.  **Weights:** These are also called parameters of the model. The total number of weights in a model are referred to as the “size” of that model. In GGML format a tensor consists of few components:
        
        +   Name
            
        +   4 element list representing number of dimensions in the tensor and their lengths
            
        +   List of weights in the tensor
            
        
        Let’s consider the following weights:
        
        weight\_1 \= \[\[0.334, 0.21\], \[0.0, 0.149\]\]
        weight\_2 \= \[0.123, 0.21, 0.31\]
        
        Copy to clipboard
        
        Then GGML representation would be:
        
        {"weight\_1", \[2, 2, 1, 1\], \[0.334, 0.21, 0.0, 0.149\]}
        {"weight\_2", \[3, 1, 1, 1\], \[0.123, 0.21, 0.31\]}
        
        Copy to clipboard
        
        For each weight representation the first list denotes dimensions and second list denotes weights. Dimensions list uses `1` as a placeholder for unused dimensions.
        

#### Quantisation[#](#quantisation "Permalink to this heading")

[Quantisation](https://en.wikipedia.org/wiki/Quantization_(signal_processing)) is a process where high-precision foating point values are converted to low-precision values. This overall reduces the resources required to use the values in Tensor, making model easier to run on low resources. GGML uses a [hacky version of quantisation](https://github.com/ggerganov/ggml/discussions/41#discussioncomment-5361161) and supports a number of different quantisation [strategies](https://news.ycombinator.com/item?id=36216244) (e.g. 4-bit, 5-bit, and 8-bit quantisation), each of which offers different trade-offs between efficiency and performance. Check out [this amazing article](https://huggingface.co/blog/merve/quantization) by [Merve](https://huggingface.co/merve) for a quick walkthrough.

### Support[#](#ggml-support "Permalink to this heading")

It’s most used projects include:

+   [whisper.cpp](https://github.com/ggerganov/whisper.cpp)
    
    High-performance inference of [OpenAI’s Whisper automatic speech recognition model](https://openai.com/research/whisper) The project provides a high-quality speech-to-text solution that runs on Mac, Windows, Linux, iOS, Android, Raspberry Pi, and Web. Used by [rewind.ai](https://www.rewind.ai)
    
    Optimised version for Apple Silicon is also [available](https://github.com/ggerganov/whisper.spm) as a Swift package.
    
+   [llama.cpp](https://github.com/ggerganov/llama.cpp)
    
    Inference of Meta’s LLaMA large language model
    
    The project demonstrates efficient inference on Apple Silicon hardware and explores a variety of optimisation techniques and applications of LLMs
    

Inference and training of many open sourced models ([StarCoder](https://github.com/ggerganov/ggml/tree/master/examples/starcoder), [Falcon](https://github.com/cmp-nct/ggllm.cpp), [Replit](https://github.com/ggerganov/ggml/tree/master/examples/replit), [Bert](https://github.com/skeskinen/bert.cpp), etc.) are already supported in GGML. Track the full list of updates [here](https://github.com/ggerganov/ggml#updates).

Tip

[TheBloke](https://huggingface.co/TheBloke) currently has lots of LLM variants already converted to GGML format.

GPU based inference support for GGML format models [discussion initiated few months back](https://github.com/ggerganov/llama.cpp/discussions/915), examples started with `MNIST CNN` support, and showing other example of full [GPU inference, showed on Apple Silicon using Metal](https://github.com/ggerganov/llama.cpp/pull/1642), offloading layers to CPU and making use of GPU and CPU together.

Check [llamacpp part of LangChain’s docs](https://python.langchain.com/docs/integrations/llms/llamacpp#gpu) on how to use GPU or Metal for GGML models inference. Here’s an example from LangChain docs showing how to use GPU for GGML models inference.

Currently [Speculative Decoding for sampling tokens](https://twitter.com/karpathy/status/1697318534555336961) is being implemented ([ggerganov/llama.cpp#2926](https://github.com/ggerganov/llama.cpp/pull/2926)) for Code LLaMA inference as a POC, which as an example promises full [`float16` precision 34B Code LLAMA at >20 tokens/sec on M2 Ultra](https://twitter.com/ggerganov/status/1697262700165013689).

### Future[#](#id7 "Permalink to this heading")

#### `GGUF` format[#](#gguf-format "Permalink to this heading")

There’s a new successor format to `GGML` named `GGUF` introduced by `llama.cpp` team on August 21st 2023. It has an extensible, future-proof format which stores more information about the model as metadata. It also includes significantly improved tokenisation code, including for the first time full support for special tokens. Promises to improve performance, especially with models that use new special tokens and implement custom prompt templates.

Some [clients & libraries supporting `GGUF`](https://huggingface.co/TheBloke/Llama-2-13B-GGUF#about-gguf) include:

+   [ggerganov/llama.cpp](https://github.com/ggerganov/llama.cpp)
    
+   [oobabooga/text-generation-webui](https://github.com/oobabooga/text-generation-webui) – the most widely used web UI, with many features and powerful extensions
    
+   [LostRuins/koboldcpp](https://github.com/LostRuins/koboldcpp) – a fully featured web UI, with full GPU accel across multiple platforms and GPU architectures. Especially good for story telling
    
+   [ParisNeo/lollms-webui](https://github.com/ParisNeo/lollms-webui) – a great web UI with many interesting and unique features, including a full model library for easy model selection
    
+   [marella/ctransformers](https://github.com/marella/ctransformers) – a Python library with GPU accel, LangChain support, and OpenAI-compatible AI server
    
+   [abetlen/llama-cpp-python](https://github.com/abetlen/llama-cpp-python) – a Python library with GPU accel, LangChain support, and OpenAI-compatible API server
    
+   [huggingface/candle](https://github.com/huggingface/candle) – a Rust ML framework with a focus on performance, including GPU support, and ease of use
    
+   [LM Studio](https://lmstudio.ai) – an easy-to-use and powerful local GUI with GPU acceleration on both Windows (NVidia and AMD), and macOS
    

See also

For more info on `GGUF`, see [ggerganov/llama.cpp#2398](https://github.com/ggerganov/llama.cpp/pull/2398) and its [spec](https://github.com/philpax/ggml/blob/gguf-spec/docs/gguf.md).

### Limitations[#](#id8 "Permalink to this heading")

+   Models are mostly quantised versions of actual models, taking slight hit from quality side if not much. Similar cases [reported](https://news.ycombinator.com/item?id=36222819) which is totally expected from a quantised model, some numbers can be found on [this reddit discussion](https://www.reddit.com/r/LocalLLaMA/comments/13l0j7m/a_comparative_look_at_ggml_quantization_and).
    
+   GGML is mostly focused on Large Language Models, but surely looking to [expand](https://github.com/ggerganov/ggml/discussions/303).
    

See also

+   [GGML: Large Language Models for Everyone](https://github.com/rustformers/llm/blob/main/crates/ggml/README.md) – a description of the GGML format (by the maintainers of the `llm` Rust bindings for GGML)
    
+   [marella/ctransformers](https://github.com/marella/ctransformers) – Python bindings for GGML models
    
+   [go-skynet/go-ggml-transformers.cpp](https://github.com/go-skynet/go-ggml-transformers.cpp) – Golang bindings for GGML models
    
+   [smspillaz/ggml-gobject](https://github.com/smspillaz/ggml-gobject) – GObject-introspectable wrapper for using GGML on the GNOME platform
    
+   [Hacker News discussion on GGML](https://news.ycombinator.com/item?id=36215651)
    

## TensorRT[#](#tensorrt "Permalink to this heading")

TensorRT is an SDK for deep learning inference by NVIDIA, providing APIs and parsers to import trained models from all major deep learning frameworks which then generates optimised runtime engines deployable in diverse systems.

### Features and Benefits[#](#id10 "Permalink to this heading")

TensorRT’s main capability comes under giving out high performance inference engines. Few notable features include:

+   [C++](https://docs.nvidia.com/deeplearning/tensorrt/api/c_api) and [Python](https://docs.nvidia.com/deeplearning/tensorrt/api/python_api) APIs.
    
+   Supports `float32`, `float16`, `int8`, `int32`, `uint8`, and `bool` [data types](https://docs.nvidia.com/deeplearning/tensorrt/developer-guide/#types-precision).
    
+   [Plugin](https://github.com/NVIDIA/TensorRT/tree/main/plugin) interface to extend TensorRT with operations not supported natively.
    
+   Works with [both GPU (CUDA) and CPU](https://docs.nvidia.com/deeplearning/tensorrt/support-matrix/#platform-matrix).
    
+   Works with [pre-quantised](https://docs.nvidia.com/deeplearning/tensorrt/developer-guide/#working-with-int8) models.
    
+   Supports [NVIDIA’s Deep Learning Accelerator](https://docs.nvidia.com/deeplearning/tensorrt/developer-guide/#dla_topic) (DLA).
    
+   [Dynamic shapes](https://docs.nvidia.com/deeplearning/tensorrt/developer-guide/#work_dynamic_shapes) for Input and Output.
    
+   [Updating weights](https://docs.nvidia.com/deeplearning/tensorrt/developer-guide/#refitting-engine-c)
    
+   Added [tooling](https://github.com/NVIDIA/TensorRT/tree/main/tools) support like [`trtexec`](https://docs.nvidia.com/deeplearning/tensorrt/developer-guide/#trtexec)
    

[TensorRT can also act as a provider when using `onnxruntime`](https://onnxruntime.ai/docs/execution-providers/TensorRT-ExecutionProvider.html) delivering better inferencing performance on the same hardware compared to generic GPU acceleration by [setting proper Execution Provider](https://onnxruntime.ai/docs/execution-providers).

### Usage[#](#tensorrt-usage "Permalink to this heading")

Using [NVIDIA’s TensorRT containers](https://docs.nvidia.com/deeplearning/tensorrt/container-release-notes) can ease up setup, given it’s known what version of TensorRT, CUDA toolkit (if required).

[![https://static.premai.io/book/model-formats_tensorrt-usage-flow.png](https://static.premai.io/book/model-formats_tensorrt-usage-flow.png)](https://static.premai.io/book/model-formats_tensorrt-usage-flow.png)

Fig. 58 [Path to convert and deploy with TensorRT](https://docs.nvidia.com/deeplearning/tensorrt/quick-start-guide/#select-workflow).[#](#tensorrt-conversion-flow "Permalink to this image")

### Support[#](#tensorrt-support "Permalink to this heading")

While creating a serialised TensorRT engine, except using [TF-TRT](https://docs.nvidia.com/deeplearning/frameworks/tf-trt-user-guide) or [ONNX](https://onnx.ai), for higher customisability one can also manually construct a network using the TensorRT API ([C++](https://docs.nvidia.com/deeplearning/tensorrt/developer-guide/#create_network_c) or [Python](https://docs.nvidia.com/deeplearning/tensorrt/developer-guide/#create_network_python))

TensorRT also includes a standalone [runtime](https://docs.nvidia.com/deeplearning/tensorrt/quick-start-guide/#runtime) with [C++](https://docs.nvidia.com/deeplearning/tensorrt/quick-start-guide/#run-engine-c) and [Python](https://docs.nvidia.com/deeplearning/tensorrt/quick-start-guide/#run-engine-python) bindings, apart from directly using [NVIDIA’s Triton Inference server for deployment](https://github.com/triton-inference-server/server/blob/r20.12/docs/quickstart.md).

[ONNX has a TensorRT backend](https://github.com/onnx/onnx-tensorrt#onnx-tensorrt-python-backend-usage) that parses ONNX models for execution with TensorRT, having both [Python](https://github.com/onnx/onnx-tensorrt#c-library-usage) and [C++](https://github.com/onnx/onnx-tensorrt#c-library-usage) support. Current full list of supported ONNX operators for TensorRT is maintained [here](https://github.com/onnx/onnx-tensorrt/blob/main/docs/operators.md#operator-support-matrix). It only supports `DOUBLE`, `FLOAT32`, `FLOAT16`, `INT8` and `BOOL` ONNX data types, and limited support for `INT32`, `INT64` and `DOUBLE` types.

NVIDIA also kept few [tooling](https://docs.nvidia.com/deeplearning/tensorrt/#tools) support around TensorRT:

+   **[`trtexec`](https://github.com/NVIDIA/TensorRT/tree/main/samples/trtexec):** For easy generation of TensorRT engines and benchmarking.
    
+   **[`Polygraphy`](https://github.com/NVIDIA/TensorRT/tree/main/tools/Polygraphy):** A Deep Learning Inference Prototyping and Debugging Toolkit
    
+   **[`trt-engine-explorer`](https://github.com/NVIDIA/TensorRT/tree/main/tools/experimental/trt-engine-explorer):** It contains Python package [`trex`](https://github.com/NVIDIA/TensorRT/tree/main/tools/experimental/trt-engine-explorer/trex) to explore various aspects of a TensorRT engine plan and its associated inference profiling data.
    
+   **[`onnx-graphsurgeon`](https://github.com/NVIDIA/TensorRT/tree/main/tools/onnx-graphsurgeon):** It helps easily generate new ONNX graphs, or modify existing ones.
    
+   **[`polygraphy-extension-trtexec`](https://github.com/NVIDIA/TensorRT/tree/main/tools/polygraphy-extension-trtexec):** polygraphy extension which adds support to run inference with `trtexec` for multiple backends, including TensorRT and ONNX-Runtime, and compare outputs.
    

+   **[`pytorch-quantization`](https://github.com/NVIDIA/TensorRT/tree/main/tools/pytorch-quantization) and [`tensorflow-quantization`](https://github.com/NVIDIA/TensorRT/tree/main/tools/tensorflow-quantization):** For quantisation aware training or evaluating when using Pytorch/Tensorflow.
    

### Limitations[#](#id13 "Permalink to this heading")

Currently every model checkpoint one creates needs to be recompiled first to ONNX and then to TensorRT, so for using [microsoft/LoRA](https://github.com/microsoft/LoRA) it has to be added into the model at compile time. More issues can be found in [this reddit post](https://www.reddit.com/r/StableDiffusion/comments/141qvw4/tensorrt_may_be_2x_faster_but_it_has_a_lot_of).

INT4 and INT16 quantisation is not supported by TensorRT currently. Current support on quantisation can be found [here](#tensorrt-quantisation-2).

Many [ONNX operators](https://github.com/onnx/onnx/blob/main/docs/Operators.md) are [not yet supported](https://github.com/onnx/onnx-tensorrt/blob/main/docs/operators.md) by TensorRT and few supported ones have restrictions.

Supports no Interoperability since conversion to onnx or TF-TRT format is a necessary step and has intricacies which needs to be handled [for custom requirements](#tensorrt-interoperability).

See also

+   [Docs](https://docs.nvidia.com/deeplearning/tensorrt/developer-guide)
    
    +   [Extending TensorRT with Custom Layers: Plugins](https://docs.nvidia.com/deeplearning/tensorrt/developer-guide/#extending)
        
+   [Intro notebooks](https://github.com/NVIDIA/TensorRT/tree/main/quickstart/IntroNotebooks)
    
+   [Support matrix](https://docs.nvidia.com/deeplearning/tensorrt/support-matrix)
    

## FasterTransformer[#](#fastertransformer "Permalink to this heading")

Work in Progress

Feel free to open a PR :)

## Future[#](#id14 "Permalink to this heading")

Feedback

This chapter is still being written & reviewed. Please do post links & discussion in the [comments](#model-formats-comments) below, or [open a pull request](https://github.com/premAI-io/state-of-open-source-ai/edit/main/model-formats.md)!

See also:

+   [Optimising for Faster Inference](https://cameronrwolfe.substack.com/i/135439692/optimising-for-faster-inference)
    
+   [imaurer/awesome-decentralized-llm](https://github.com/imaurer/awesome-decentralized-llm#training-and-quantization)
    





























[NingG]:    http://ningg.github.io  "NingG"
[premAI]:		https://book.premai.io/state-of-open-source-ai/








