---
layout: post
title: AI 系列：How to Maximize LLM Performance（原文）
description: LLMs 性能调优 
published: true
category: AI
---

> 原文地址： [How to Maximize LLM Performance](https://humanloop.com/blog/optimizing-llms)
> 
> 这篇文章，细节很多，而且有很多关联资料的跳转链接，值得反复阅读。


An overview of the techniques that OpenAI recommends to get the best performance of your LLM applications. Covering best-practices in prompt engineering, retrieval-augmented generation (RAG) and fine-tuning.

## [](#introduction)**Introduction**

One of the most useful talks from OpenAI DevDay was ‘A Survey of Techniques for Maximizing LLM Performance’ from John Allard and Colin Jarvis. For those who couldn’t attend, you can watch it on [YouTube](https://www.youtube.com/watch?v=ahnGLM-RC1Y).

This talk was a fantastic overview of the techniques and the recommended approaches to improve your LLM applications. We share similar advice with the many teams using Humanloop to help manage and evaluate their LLM applications, so we see a lot of value in this content. Courtesy of OpenAI, here is a cohesive overview of techniques to help you get great performance from LLMs.

## [](#you-need-to-optimize-your-llms-to-get-from-prototype-to-production)**You need to optimize your LLMs to get from prototype to production**

Creating a demo of something that works part of the time can be easy. To get to production, you’re going to nearly always iterate and improve your LLM application’s performance.

LLMs will struggle if you’re doing anything that requires knowledge of your data, systems and processes, or if you need it to behave in a specific way.

To solve this teams generally look towards prompt engineering, augmenting with retrieval and fine-tuning.

A common mistake is to think that this is a linear process and should be done in that order! Instead, this is best thought of along two axes depending on where you view the issues to be:

+   **Context optimization** – are the problems because the model does not have access to the right knowledge?
+   **LLM optimization** – is the model not generating the right output, i.e. not accurate enough or not following a particular style or format?

![The Optimization options are best thought along two axes: are your problems because of knowledge available to the model, or because it is not acting as you want?](/images/ai-series/optimize-llms/llm-optimization-flow.png)

The Optimization options are best thought along two axes: are your problems because of knowledge available to the model, or because it is not acting as you want? (Credit: OpenAI)

## [](#the-optimization-options)**The Optimization Options**

When it comes to optimizing LLMs, there are three primary tools are at your disposal and each serves a unique role in the optimization process:

1.  **Prompt Engineering**: Tailoring the prompts to guide the model’s responses.
2.  **Retrieval-Augmented Generation (RAG)**: Enhancing the model’s context understanding through external data.
3.  **Fine-tuning**: Modifying the base model to better suit specific tasks.

In practice, the process is highly iterative. You should expect many techniques to not work for your problem. However, most of these techniques are additive. If you find something that works, it can be stacked with other performance improvements for optimal results.

![The above shows a plausible path through the optimization flow for a task which requires specific knowledge lookup. “Try something, evaluate, try something else!”. Many techniques may not be suitable for your task, but if you find something that works, it can probably combined with other techniques.](/images/ai-series/optimize-llms/example-flow.png)

The above shows a plausible path through the optimization flow for a task which requires specific knowledge lookup. Many techniques may not be suitable for your task, but if you find something that works, it can probably combined with other techniques. “Try something, evaluate, try something else!”. (Credit: OpenAI)

Note: you can also try different models from other providers. All the models have different performance characteristics which may be better suited for your task. If you’re aiming to optimize cost or speed, this can be especially important. We’ll leave this out of the discussion for now as we're primarily concerned with getting the best performance form the most powerful models.

## [](#before-anything-you-need-evals)**Before anything, you need evals**

> “If you can’t measure it, you can’t improve it.” — Peter Drucker (although not talking about LLMs at the time, he'd endorse the need for good evals)

The most crucial step in the optimization process is setting up a solid evaluation framework. Without a clear understanding of your model's performance, it's impossible to tell if you’re making progress.

The goal of evaluation is not just to identify where the model falls short, but also to uncover actionable insights that guide your optimization strategy. Whether you're refining prompts, tweaking RAG, or fine-tuning the model, evals should help you know what to try next.

Here are some of the most common evaluation techniques:

+   **Outsourced human annotation**: AKA paying people to tell you whether something is good or bad. It's often expensive, slow and challenging to ensure consistent quality.
+   **Internal human review**: Having your team internally review outputs ensures quality but can be slow and resource-intensive.
+   **Model-based evaluation**: Using another LLM to evaluate your system's performance. This has become increasingly effective with powerful general models.
+   **Code-based evaluation**: Implementing custom heuristics defined in code to assess specific aspects of the model's output.
+   **Accuracy Metrics**: If you have clear targets, metrics like F1, precision, recall, and BLEU can provide objective measures of your model's accuracy.
+   **End-user feedback and A/B testing**: Often the feedback that matters most! This can include direct user responses as well as implicit actions indicating user preferences. However, it requires having an early version of your system available to users.

Each of these evaluation methods has its own strengths and weaknesses, and often the best approach is to combine several of these to get a comprehensive understanding of your model's performance and areas for improvement.

LLMOps platforms like [Humanloop](https://humanloop.com/) offer an integrated process for evaluating your prompts with the tools you need for prompt engineering and fine-tuning. For RAG specifically, information retrieval based scoring can be applicable. Open source eval frameworks like [RAGAS](https://github.com/explodinggradients/ragas) can help evaluate retrieval-based scoring.

With evals in place, you’ll want to test all your changes systematically, so you can assign impact to each modification.



## [](#do-prompt-engineering-first-and-last)**Do prompt engineering first (and last!)**

Prompt engineering should nearly always be the first thing you explore in optimizing your LLM performance. In fact, it should be one of the things you also re-explore after RAG, finetuning, or other advanced techniques, given how core the prompt is to LLM generations.

> Prompt engineering is the craft of instructing the model to respond as you want it to through the input text.

A well-engineered prompt can significantly improve the model's accuracy and relevance.

### [](#prompt-engineering-is-guiding-the-model-with-examples-and-instructions)Prompt engineering is guiding the model with examples and instructions

A whole book could be written on prompt engineering, but at a high level, the advice is to start with:

+   clear instructions
+   splitting tasks into simpler subtasks
+   giving the model time to “think”
+   showing clear examples

For more guidance, we recommend starting with [Prompt Engineering 101](https://humanloop.com/blog/prompt-engineering-101) and the very through [Prompt Engineering Guide](https://learnprompting.org/docs/intro).

![An example from the talk where the task is given in clear instructions, then extended with some guidance to think step-by-step and some structure for how to do so.](/images/ai-series/optimize-llms/prompt-engineering.jpg)

An example from the talk where the task is given in clear instructions, then extended with some guidance to think step-by-step and some structure for how to do so.

Although, the models are getting much better at following complicated instructions, you may still benefit from chaining multiple LLM calls together. In this way you can force the model to do each step procedurally.

![Colin Jarvis explains that Prompt Engineering is the best first step, but if you care about optimal performance (or token usage!) you’ll want to add in RAG or fine-tuning.](/images/ai-series/optimize-llms/prompt-eng-summary.jpg)

Colin Jarvis explains that Prompt Engineering is the best first step, but if you care about optimal performance (or token usage!) you’ll want to add in RAG or fine-tuning.

Even with prompt engineering, you can make sufficient inroads on the two axes of optimization.

If the issue is with the output, you can [constrain the response to be JSON](https://docs.humanloop.com/changelog/json-mode-and-seed), or to follow a specific format with [tool calling](https://docs.humanloop.com/changelog/multiple-tool-calls). You can also add in examples of the task being performed ('few-shot learning') which can help the model understand the task better.

If the issue is with context, you can *prompt-stuff* (technical term) with all the relevant and maybe-relevant context it needs. The main limitation is the size of the context window and what you’re willing to pay in cost and latency. Given that the largest models currently have around 200k tokens of context available (although there is some [debate](https://twitter.com/GregKamradt/status/1727018183608193393) about how well they can use this), we recommend you first fill the context window before you start building a more complicated RAG system.

### [](#evaluate-and-version-your-prompts-to-make-sure-youre-making-progress)Evaluate and version your prompts to make sure you’re making progress

When prompt engineering, keeping track of changes to your prompts and parameters is key. Every adjustment should be recorded and evaluated systematically, helping you understand which changes improve performance and which don’t.

The common tools for prompt engineering are playgrounds (to call the LLMs) combined with git or Google Sheets for some versioning and collaboration. A prompt editor that is paired with an evaluation suite like Humanloop can systematize this and allow you to collaborate and speed up your iteration cycles.

After prompt engineering, you should identify where the largest gaps are. From this you can decide whether to explore RAG or fine-tuning.

![If after prompt engineering you still need to improve performance, identify whether the gaps are due to context or output to figure out if RAG or fine-tuning should be explored.](/images/ai-series/optimize-llms/rag-vs-fine-tuning.png)

If after prompt engineering you still need to improve performance, identify whether the gaps are due to context or output to figure out if RAG or fine-tuning should be explored. (Credit: OpenAI)

## [](#use-retrieval-augmented-generation-rag-if-the-issues-are-due-to-context)**Use Retrieval-Augmented Generation (RAG) if the issues are due to context**

When you're dealing with LLMs, sometimes the challenge isn't just about how the model generates responses, but about what context it has access to. The models have been trained on mostly public domain content from the web; not your company's private data, nor the latest information from your industry.

This is where Retrieval-Augmented Generation (RAG) comes into play. It's combining the capabilities of LLMs with the context of external data sources. It's a required tool when your LLM lacks the necessary depth or specificity in its responses.

![Example RAG system where the user’s query is used to fetch relevant documents from a knowledge base before both are inserted into the prompt for the LLM to synthesize the answer.](/images/ai-series/optimize-llms/rag-overview.png)

Example RAG system where the user’s query is used to fetch relevant documents from a knowledge base before both are inserted into the prompt for the LLM to synthesize the answer.

### [](#rag-allows-your-llm-to-pull-in-information-from-external-data-sources)RAG allows your LLM to pull in information from external data sources

RAG is crucial for applications that require awareness of recent developments or specific domain knowledge. For example, in financial advice or market analysis, RAG enables the model to access the latest stock prices or economic reports. For a health chatbot, RAG enabled the model cite recent research papers or health guidelines.

Integrating RAG significantly boosts the model's effectiveness and can make it more accurate and up-to-date in its responses.

### [](#setting-up-rag)Setting up RAG

The first thing to do is to demonstrate performance with some handpicked few-shot examples. After which you may wish to operationalize this with a system for picking out those examples.

RAG can be as simple as creating a prompt template and inserting dynamic content fetched from a database. As LLM applications often work with natural language, it’s very common to use semantic search on a vector database, such as [Qdrant](https://qdrant.tech/), [Chroma](https://www.trychroma.com/) and [Pinecone](https://www.pinecone.io/). [Tool calling](https://platform.openai.com/docs/guides/function-calling) is a way to use the LLM to create the structured output necessary to directly call systems like traditional SQL databases. And [Prompt Tools](https://humanloop.com/blog/announcing-tools) enable you to conveniently hook up resources into your prompts with having to build any data pipelines.

However, RAG is rarely a plug-and-play solution. Implementing RAG requires careful consideration of the sources you allow the model to access, as well as how you integrate this data into your LLM requests. It's about striking the right balance between providing enough context to enhance the model's responses while ensuring that the information it retrieves is reliable and relevant.

### [](#evaluating-rag)Evaluating RAG

RAG opens up a whole new dimension of possibilities, but it also adds a separate system that can independently go wrong. Pulling in unhelpful contextual information can actively harm the performance of your generations, so it is especially important that you investigate the precision and recall of the retrieval process separately from your overall LLM application.

Creating a high performing RAG system can look like a traditional information retrieval pipeline. Techniques like reranking, classification, and [finetuning your embeddings](https://blog.llamaindex.ai/fine-tuning-embeddings-for-rag-with-synthetic-data-e534409a3971) may be appropriate. As you build this out, you’ll want to set up an evaluation system that can isolate the performance of the retrieval from the overall LLM application. Evaluate the retrieval with precision and recall and the overall system from the user’s perspective.

![Evaluating RAG is best considered as a fuzzier version of traditional information retrieval (IR) evaluation metrics like precision and recall. RAGAS is an open source library to help understand where your RAG-LLM has deficiencies.](/images/ai-series/optimize-llms/rag-eval.jpg)

Evaluating RAG is best considered as a fuzzier version of traditional information retrieval (IR) evaluation metrics like precision and recall. RAGAS is an open source library to help understand where your RAG-LLM has deficiencies.

RAG is a powerful tool if the challenges with your LLM are context-related. It enables the model to access external data sources, providing the necessary context that not present in the model's training data. This approach can dramatically enhance the model's performance, especially in scenarios where up-to-date or domain-specific information is crucial.

## [](#fine-tune-to-optimize-performance-and-improve-efficiency)**Fine-tune to optimize performance and improve efficiency**

Fine-tuning is continuing the training process of the LLM on a smaller, domain-specific dataset. This can significantly improve the model's performance on specialized tasks by adjusting the model's parameters themselves, rather than just changing the prompt as with prompt engineering and RAG.

> Think of fine-tuning like honing a general-purpose tool into a precision instrument.

### [](#why-fine-tune)Why fine-tune?

There are two main benefits to fine-tuning:

#### [](#improving-model-performance-on-a-specific-task)Improving model performance on a specific task

Fine-tuning means you can pack in more examples. You can fine-tune on millions of tokens, whereas few-shot learning prompts are limited to 10s of thousands of tokens, depending on the context size. A fine-tuned model may lose some of its generality, but for its specific task, you should expect better performance.

#### [](#improving-model-efficiency)Improving model efficiency

Efficiency for LLM applications means lower latency and reduced costs. This benefit is achieved in two ways. By specialising the model, you can use a much smaller model. Additionally, as you train only on input-output pairs, not the full prompt with any of its prompt engineering tricks and tips, you can discard the examples or instructions. This can further improve latency and cost.

![For fine-tuning, you create a training daaset of input-output examples. The model will learn do this task, without complex instructions, no complex schema, essentially no prompt tokens used beyond the users’ input, even at inference time.](/images/ai-series/optimize-llms/finetuning.jpg)

For fine-tuning, you create a training daaset of input-output examples. The model will learn do this task, without complex instructions, even at inference time.

## [](#what-is-fine-tuning-less-good-for)**What is fine-tuning less good for?**

Fine-tuning is less good for quickly iterating on new use cases.

To make fine-tuning work you need to create a large training dataset of at least hundreds of good-quality examples. You must then wrangle that into the appropriate format, and initiate the training task of fine-tuning a custom LLM and evaluating how well it performs.

To operationalise this, you need to set up a model improvement workflow. The best kind looks like a big feedback loop where all the feedback signals from the current model are used to improve the next version.

You can set this up yourself by logging all generations, along with the signals you can use to score them (implicit and explicit user feedback, as well as human and AI evals), so that you can create the training dataset for the next version. Alternatively, an LLMOps platform like Humanloop will automatically collect and surface the best data to enable you to fine-tune a model in just a few clicks.

![Finetuning summary](/images/ai-series/optimize-llms/finetuning-summary.jpg)

Fine tuning can get the most out of a model, but it is not the best for quickly iterating on new use cases.

### [](#best-practices-for-fine-tuning)**Best practices for fine-tuning**

For fine-tuning to work best you should start with a clear goal and a relevant, high-quality dataset. It's crucial to fine-tune with data that exemplifies the type of output you need. Moreover, iterative testing is vital – start with small, incremental changes and evaluate the results before proceeding further.

![It matters what you fine-tune on! A cautionary tale: “We should fine-tune on the company slack, to get our tone of voice” resulted in an LLM that exactly replicated the casual non-productive style of slack comms ‘ok’.](/images/ai-series/optimize-llms/cautionary-tale.jpg)

It matters what you fine-tune on! A cautionary tale: “We should fine-tune on the company Slack so that it learns our tone of voice” resulted in an LLM that exactly replicated the casual non-productive style of slack comms ‘ok’.

### [](#how-it-works-with-openai-and-open-source-llms)**How it works with OpenAI and open-source LLMs**

With OpenAI's models, fine-tuning involves using their provided APIs to further train the model on your dataset. This can involve adjusting various hyperparameters and monitoring the model's performance to find the optimal setting for your specific use case. For open-source LLMs, fine-tuning may require more hands-on work, including setting up the computing environment, managing data pipelines, and possibly working directly with model architectures.

See our guide on [Fine-tuning GPT-3.5-Turbo](https://humanloop.com/blog/fine-tuning-gpt-3-5).

## [](#combine-all-the-techniques-for-optimal-results)**Combine all the techniques for optimal results**

Remember, nearly all these techniques are additive.

Fine-tuning refines the model's understanding of a task, making it adept at delivering the right kind of output. By pairing it with RAG, the model not only knows what to say but also has the appropriate information to draw from.

This dual approach leverages the strengths of both fine-tuning (for task-specific performance) and RAG (for dynamic, context-rich information retrieval), leading to a more performant LLM application.

Prompt engineering is always the first step in the optimization process. By starting with well-crafted prompts, you understand what's the inherent capability of the model for your task – and prompt engineering may be all that you need! Depending on the fine-tuning data or where performance gaps still lie, prompt engineering should then be re-considered after RAG and fine-tuning to get truly optimal performance.

## [](#conclusion)**Conclusion**

For those building applications that rely on LLMs, the techniques shown here are crucial for getting the most out of this transformational technology. Understanding and effectively applying prompt engineering, RAG, and fine-tuning are key to transitioning from a promising prototype to a robust production-ready model.

The two axes of optimization—what the model needs to know and how the model needs to act—provide a roadmap for your efforts. A solid evaluation framework and a robust LLMOps workflow are the compasses that guide you, helping you to measure, refine, and iterate on your models.

I encourage readers to delve deeper into these methods and experiment with them in their LLM applications for optimal results. If you’re interested in whether an integrated platform like Humanloop can provide the LLMOps infrastructure you need to track, tune, and continually improve your models, please [request a demo](https://humanloop.com/demo).


















[NingG]:    http://ningg.github.io  "NingG"
[premAI]:		https://book.premai.io/state-of-open-source-ai/








