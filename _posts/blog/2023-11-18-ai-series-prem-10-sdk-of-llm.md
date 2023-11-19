---
layout: post
title: AI 系列：Vector Databases
description: 向量数据库
published: true
category: AI
---


原文：[Software Development toolKits](https://book.premai.io/state-of-open-source-ai/sdk/)



# Software Development toolKits[#](#software-development-toolkits "Permalink to this heading")

[LLM](../#term-LLM) SDKs are specific for generative AI. These toolkits help developers integrate LLM capabilities into applications. The LLM SDK typically includes APIs, sample code, and documentation to aid in the development process. By leveraging an LLM SDK, developers can streamline their development processes and ensure compliance with industry standards.

Table 12 Comparison of LLM SDKs[#](#llm-sdks "Permalink to this table")


| SDK | Use cases | Vector stores | Embedding model | LLM Model | Languages | Features | 
| --- | --- | --- | --- | --- | --- | --- | 
| [LangChain](#langchain) | Chatbots, prompt chaining, document related tasks | Comprehensive list of data sources available to get connected readily | State of art embedding models in the bucket to choose from | A-Z availability of LLMs out there in the market | Python, Javascript, Typescript | Open source & 1.5k+ contributors strong for active project development | 
| [LLaMA Index](#llama-index) | Connecting multiple data sources to LLMs, document query interface using retrieval augmented generation, advanced chatbots, structured analytics | Wide options to connect & facility to [create a new one](https://gpt-index.readthedocs.io/en/latest/examples/vector_stores/CognitiveSearchIndexDemo.html#create-index-if-it-does-not-exist) | Besides the 3 commonly available models we can use a [custom embedding model](https://gpt-index.readthedocs.io/en/latest/examples/embeddings/custom_embeddings.html) as well | Set of restricted availability of LLM models besides [customised abstractions](https://gpt-index.readthedocs.io/en/latest/module_guides/models/llms/usage_custom.html) suited for your custom data | Python, Javascript, Typescript | Tailor-made for high customisations if not happy with the current parameters and integrations | 
| [LiteLLM](#litellm) | Integrating multiple LLMs, evaluating LLMs | Not Applicable | Currently supports only `text-embedding-ada-002` from OpenAI & Azure | Expanding the list of LLM providers with the most commonly used ones ready for use | Python | Lightweight, streaming model response, consistent output response |


在当前人工智能领域，为什么需要大型语言模型（LLM）软件开发工具包（SDK）有几个原因。

1. **合规性协议**：使用LLM SDK，开发人员可以通过适当记录、追踪和监控请求来确保其应用程序符合协议。这有助于避免与软件盗版或未经授权使用资源相关的潜在法律问题。
1. **用户体验提升**：LLM SDK可以通过消除样板代码，并抽象化与LLM的低层交互，帮助创建无缝的用户体验。
1. **增强安全性**：通过实施LLM SDK，开发人员可以通过**访问控制**和**用户管理**（[access control and user management](https://www.businesswire.com/news/home/20230531005251/en/LlamaIndex-Raises-8.5M-to-Unlock-Large-Language-Models-Capabilities-with-Personal-Data).）等安全功能保护其资源，并防止未经授权的软件使用。
1. **灵活性**：LLM SDK提供了定制和整合不同组件的灵活性，使开发人员能够根据自己的特定需求定制管理系统，并轻松进行调整。
1. **改善协作**：LLM SDK可以通过提供集中式许可证管理平台促进团队成员之间的协作，确保每个人对问题和合规要求都了解并保持一致。
    

## LangChain[#](#langchain "Permalink to this heading")

![banner](https://python.langchain.com/img/parrot-chainlink-icon.png)

On the LangChain page – it states that LangChain is a framework for developing applications powered by Large Language Models(LLMs). It is available as an python sdk and npm packages suited for development purposes.

### Document Loader[#](#document-loader "Permalink to this heading")

Well the beauty of LangChain is we can take input from various different files to make it usable for a great extent. Point to be noted is they can be of various [formats](https://python.langchain.com/docs/modules/data_connection/document_loaders) like `.pdf`, `.json`, `.md`, `.html`, and `.csv`.

### Vector Stores[#](#vector-stores "Permalink to this heading")

After collecting the data they are converted in the form of embeddings for the further use by storing them in any of the vector database. Through this way we can perform vector search and retrieve the data from the embeddings that are very much close to the embed query.

The list of vector stores that LangChain supports can be found [here](https://api.python.langchain.com/en/latest/api_reference.html#module-langchain.vectorstores).

### Models[#](#models "Permalink to this heading")

This is the heart of most LLMs, where the core functionality resides. There are broadly [2 different types of models](https://python.langchain.com/docs/modules/model_io/models) which LangChain integrates with:

+   **Language**: Inputs & outputs are `string`s
    
+   **Chat**: Run on top of a Language model. Inputs are a list of chat messages, and output is a chat message
    

### Tools[#](#tools "Permalink to this heading")

[Tools](https://python.langchain.com/docs/modules/agents/tools) are interfaces that an agent uses to interact with the world. They connect real world software products with the power of LLMs. This gives more flexibility, the way we use LangChain and improves its capabilities.

### Prompt engineering[#](#prompt-engineering "Permalink to this heading")

Prompt engineering is used to generate prompts for the custom prompt template. The custom prompt template takes in a function name and its corresponding source code, and generates an English language explanation of the function.

To create prompts for prompt engineering, the LangChain team uses a custom prompt template called `FunctionExplainerPromptTemplate`. This template takes the function name and source code as input variables and formats them into a prompt. The prompt includes the function name, source code, and an empty explanation section. The generated prompt can then be used to guide the language model in generating an explanation for the function.

Overall, prompt engineering is an important aspect of working with language models as it allows us to shape the model’s responses and improve its performance in specific tasks.

More about all the prompts can be found [here](https://python.langchain.com/docs/modules/model_io/prompts).

### Advanced features[#](#advanced-features "Permalink to this heading")

LangChain provides several advanced features that make it a powerful framework for developing applications powered by language models. Some of the advanced features include:

+   **Chains**: LangChain provides a standard interface for chains, allowing developers to create sequences of calls that go beyond a single language model call. This enables the chaining together of different components to create more advanced use cases around language models.
    
+   **Integrations**: LangChain offers integrations with other tools, such as the `requests` and `aiohttp` integrations for tracing HTTP requests to LLM providers, and the `openai` integration for tracing requests to the OpenAI library. These integrations enhance the functionality and capabilities of LangChain.
    
+   End-to-End Chains: LangChain supports end-to-end chains for common applications. This means that developers can create complete workflows or pipelines that involve multiple steps and components, all powered by language models. This allows for the development of complex and sophisticated language model applications.
    
+   **Logs and Sampling**: LangChain provides the ability to enable log prompt and completion sampling. By setting the `DD_LANGCHAIN_LOGS_ENABLED=1` environment variable, developers can generate logs containing prompts and completions for a specified sample rate of traced requests. This feature can be useful for debugging and monitoring purposes.
    
+   **Configuration Options**: LangChain offers various configuration options that allow developers to customize and fine-tune the behaviour of the framework. These configuration options are documented in the APM Python library documentation.
    

Overall, LangChain’s advanced features enable developers to build advanced language model applications with ease and flexibility. Some limitations of LangChain are that while it is useful for rapid prototyping of LLM applications, scalability and deploying in production remains a concern - it might not be particularly useful for handling a large number of users simultaneously, and maintaining low latency.

## LLaMA Index[#](#llama-index "Permalink to this heading")

![banner](https://static.premai.io/book/sdk-llama-index.jpg)


LLaMAIndex是一个用于LLM（大型语言模型）应用程序的数据框架，用于摄取、结构化和访问私有或特定领域的数据。

* 它提供了诸如数据连接器、数据索引、引擎（查询和聊天）以及数据代理等工具，以促进对数据的自然语言(natural language)访问。
* LLaMAIndex专为初学者、高级用户以及两者之间的人设计，提供了高级API以便于数据摄取和查询，同时也提供了低级API以便于定制。
* 它可以通过pip进行安装，并提供了详细的文档和入门教程。

LLaMAIndex还有一些相关项目，如[run-llama/llama-hub](https://github.com/run-llama/llama-hub) and [run-llama/llama-lab](https://github.com/run-llama/llama-lab).

### Data connectors[#](#data-connectors "Permalink to this heading")

[Data connectors](https://gpt-index.readthedocs.io/en/latest/module_guides/loading/connector/root.html) are software components that enable the transfer of data between different systems or applications. They provide a way to extract data from a source system, transform it if necessary, and load it into a target system. Data connectors are commonly used in data integration and ETL (Extract, Transform, Load) processes.

There are various types of data connectors available, depending on the specific systems or applications they connect to. Some common ones include:

+   **Database connectors**: These connectors allow data to be transferred between different databases, such as MySQL, PostgreSQL, or Oracle.
    
+   **Cloud connectors**: These connectors enable data transfer between on-premises systems and cloud-based platforms, such as Amazon Web Services (AWS), Google Cloud Platform (GCP), or Microsoft Azure.
    
+   **API connectors**: These connectors facilitate data exchange with systems that provide APIs (Application Programming Interfaces), allowing data to be retrieved or pushed to/from those systems.
    
+   **File connectors**: These connectors enable the transfer of data between different file formats, such as PDF, CSV, JSON, XML, or Excel.
    
+   **Application connectors**: These connectors are specifically designed to integrate data between different applications, such as CRM (Customer Relationship Management) systems, ERP (Enterprise Resource Planning) systems, or marketing automation platforms.
    

Data connectors play a crucial role in enabling data interoperability and ensuring seamless data flow between systems. They simplify the process of data integration and enable organisations to leverage data from various sources for analysis, reporting, and decision-making purposes.

### Data indexes[#](#data-indexes "Permalink to this heading")

LLaMAIndex中的数据索引([Data indexes](https://gpt-index.readthedocs.io/en/latest/module_guides/indexing/indexing.html))是数据的中间表示形式，以易于大型语言模型（LLMs）消费且具有良好性能的方式进行结构化。这些索引是从文档构建的，作为`检索增强生成`（RAG, `retrieval-augmented generation`）用例的核心基础。在内部，LLaMAIndex中的索引将数据存储在Node对象中，这些对象代表原始文档的分块。这些索引还公开了Retriever接口，支持额外的配置和自动化。LLaMAIndex提供了几种类型的索引，包括向量存储索引、摘要索引、树形索引、关键词表索引、知识图谱索引和SQL索引(Vector Store Index, Summary Index, Tree Index, Keyword Table Index, Knowledge Graph Index, and SQL Index)。每种索引都有其特定的用例和功能。

To get started with data indexes in LLaMAIndex, you can use the `from_documents` method to create an index from a collection of documents. Here’s an example using the Vector Store Index:

```python
from llama\_index import VectorStoreIndex
index \= VectorStoreIndex.from\_documents(docs)
```

Overall, data indexes in LLaMAIndex play a crucial role in enabling natural language access to data and facilitating question & answer and chat interactions with the data. They provide a structured and efficient way for LLMs to retrieve relevant context for user queries.

### Data engines[#](#data-engines "Permalink to this heading")

Data engines in LLaMAIndex refer to the query engines and chat engines that allow users to interact with their data. These engines are end-to-end pipelines that enable users to ask questions or have conversations with their data. The broad classification of data engines are:

+   [Query engine](https://gpt-index.readthedocs.io/en/latest/core_modules/query_modules/query_engine/root.html)
    
+   [Chat engine](https://gpt-index.readthedocs.io/en/latest/core_modules/query_modules/chat_engines/root.html)
    

#### Query engine[#](#query-engine "Permalink to this heading")

+   Query engines are designed for question and answer interactions with the data.
    
+   They take in a natural language query and return a response along with the relevant context retrieved from the knowledge base.
    
+   The LLM (Language Model Model) synthesises the response based on the query and retrieved context.
    
+   The key challenge in the querying stage is retrieval, orchestration, and reasoning over multiple knowledge bases.
    
+   LLaMAIndex provides composable modules that help build and integrate RAG (Retrieval-Augmented Generation) pipelines for Q&A.
    

#### Chat engine[#](#chat-engine "Permalink to this heading")

+   Chat engines are designed for multi-turn conversations with the data.
    
+   They support back-and-forth interactions instead of a single question and answer.
    
+   Similar to query engines, chat engines take in natural language input and generate responses using the LLM.
    
+   The chat engine maintains conversation context and uses it to generate appropriate responses.
    
+   LLaMAIndex provides different chat modes, such as “condense\_question” and “react”, to customise the behaviour of chat engines.
    

Both query engines and chat engines can be used to interact with data in various use cases. The main distinction is that query engines focus on single questions and answers, while chat engines enable more dynamic and interactive conversations. These engines leverage the power of LLMs and the underlying indexes to provide relevant and informative responses to user queries.

### Data agent[#](#data-agent "Permalink to this heading")


**数据代理**（[Data Agents](https://gpt-index.readthedocs.io/en/latest/core_modules/agent_modules/agents/root.html)）是LLaMAIndex中由LLMs驱动的知识工作者：

1. 能够智能地执行各种数据任务，包括“读”和“写”功能。
2. 它们具有自动搜索和检索不同类型数据的能力，包括非结构化、半结构化和结构化数据。
3. 此外，它们可以以结构化的方式调用外部服务API，并处理响应，以及将其存储以供以后使用。

**数据代理**（Data agents）不仅可以从静态数据源读取数据，还可以动态地摄取和修改来自不同工具的数据。它们由两个核心组件组成：**推理循环**和**工具抽象**（reasoning loop and tool abstractions）。

数据代理的`推理循环`取决于所使用的`代理类型`。LLaMAIndex支持 2 种类型的代理：

1. **OpenAI功能代理**（OpenAI Function agent）：构建在OpenAI功能API（`OpenAI Function API`）之上。
1. **ReAct代理**（ReAct agent）：可在任何聊天/文本完成端点上工作。

**工具抽象**是构建数据代理的重要组成部分。

1. 这些抽象，`定义`了代理可以`与之交互的API`或工具集。
2. 代理使用`推理循环`来决定使用`哪些工具`，以什么`顺序`调用每个工具以及调用每个`工具的参数`。


To use data agents in LLaMAIndex, you can follow the usage pattern below:

```python
from llama\_index.agent import OpenAIAgent
from llama\_index.llms import OpenAI

\# Initialise LLM & OpenAI agent
llm \= OpenAI(model\="gpt-3.5-turbo-0613")
agent \= OpenAIAgent.from\_tools(tools, llm\=llm, verbose\=True)
```

Overall, data agents in LLaMAIndex provide a powerful way to interact with and manipulate data, making them valuable tools for various applications.

### Advanced features[#](#id1 "Permalink to this heading")


LLaMAIndex提供多种高级功能，迎合了高级用户的需求。其中一些高级功能包括：

1. **定制和扩展**( **Customisation and Extension**)：LLaMAIndex提供了低级API，允许高级用户定制和扩展框架中的任何模块。这包括数据连接器、索引、检索器、查询引擎和重新排名模块(data connectors, indices, retrievers, query engines, and re-ranking modules)。用户可以根据自己的特定需求定制这些组件，增强LLaMAIndex的功能性。

2. **数据代理**(**Data Agents**)：LLaMAIndex包含名为数据代理的由LLM驱动的知识Worker。这些代理可以智能地执行各种数据任务，包括自动搜索和检索(search and retrieval)。它们可以读取并修改来自不同工具的数据，使其在数据处理方面非常灵活。数据代理包括`推理循环`和`工具抽象`(reasoning loop and tool abstractions)，使其能够与外部服务API进行交互并处理响应。

3. **应用集成**(**Application Integrations**)：LLaMAIndex可以与生态系统中的其他应用无缝集成。无论是LangChain、Flask还是ChatGPT，LLaMAIndex都可以与各种工具和框架集成，以增强其功能和扩展其能力。

4. **高级API**(**High-Level API**)：LLaMAIndex提供了一个高级API，让初学者只需几行代码就能快速摄取和查询数据。这种用户友好的界面简化了初学者的流程，同时仍提供强大的功能。

5. **模块化架构**(**Modular Architecture**)：LLaMAIndex遵循模块化架构，允许用户独立理解和操作框架中的不同组件。这种模块化方法使用户能够定制和组合不同模块，为其特定用例创建量身定制的解决方案。

LLaMAIndex似乎更适合在生产中部署LLM应用。然而，行业如何整合LLaMAIndex到LLM应用中，或者开发定制的LLM数据集成方法，这仍有待观察。

## LiteLLM[#](#litellm "Permalink to this heading")

![banner](https://litellm.vercel.app/img/docusaurus-social-card.png)


这个名字很贴切，[LiteLLM](https://litellm.ai) 是一个轻量级的软件包，简化了同时从多个 API 获取响应的任务，无需担心导入的问题。它作为一个 Python 软件包提供，并且可以通过 pip 访问。此外，我们可以使用现成的 [playground](https://litellm.ai/playground) 来测试这个库的工作原理。

### Completions[#](#completions "Permalink to this heading")

This is similar to OpenAI `create_completion()` [method](https://docs.litellm.ai/docs/completion/input) that allows you to call various available LLMs in the same format. LiteLLMs gives the flexibility to fine-tune the models but there is a catch, only on a few parameters. There is also [batch completion](https://docs.litellm.ai/docs/completion/batching) possible which helps us to process multiple prompts simultaneously.

### Embeddings & Providers[#](#embeddings-providers "Permalink to this heading")

There is not much to talk about regarding [embeddings](https://docs.litellm.ai/docs/embedding/supported_embedding) but worth mentioning. We have access to OpenAI and Azure OpenAI embedding models which support `text-embedding-ada-002`.

However there are many [supported providers](https://docs.litellm.ai/docs/providers), including HuggingFace, Cohere, OpenAI, Replicate, Anthropic, etc.

### Streaming Queries[#](#streaming-queries "Permalink to this heading")

By setting the `stream=True` parameter to boolean `True` we can view the [streaming](https://docs.litellm.ai/docs/completion/stream) iterator response in the output. But this is currently supported for models like OpenAI, Azure, Anthropic, and HuggingFace.

The idea behind LiteLLM seems neat - the ability to query multiple LLMs using the same logic. However, it remains to be seen how this will impact the industry and what specific use-cases this solves.

## Future And Other SDKs[#](#future-and-other-sdks "Permalink to this heading")

[LangChain](#langchain), [LLaMA Index](#llama-index), and [LiteLLM](#litellm) have exciting future plans to unlock high-value LLM applications. [Future initiatives from Langchain](https://blog.langchain.dev/announcing-our-10m-seed-round-led-by-benchmark) include improving the TypeScript package to enable more full-stack and frontend developers to create LLM applications, improved document retrieval, and enabling more observability/experimentation with LLM applications. LlamaIndex is developing an enterprise solution to help remove technical and security barriers for data usage. Apart from the SDKs discussed, there are a variety of newer SDKs for other aspects of integrating LLMs in production. One example is [prefecthq/marvin](https://github.com/prefecthq/marvin), great for building APIs, data pipelines, and streamlining the AI engineering framework for building natural language interfaces. Another example is [homanp/superagent](https://github.com/homanp/superagent), which is a higher level abstraction and allows for building many AI applications/micro services like chatbots, co-pilots, assistants, etc.





























[NingG]:    http://ningg.github.io  "NingG"
[premAI]:		https://book.premai.io/state-of-open-source-ai/








