---
layout: post
title: 工具系列：Jupyter Notebook
description: Jupyter 记事本是什么，简单试用下
published: true
categories: AI tool jupyter
---



## 0.概要

时代变了，很多工具都是第一次使用，甚至第一次听说；简单试用了些，震撼、不禁赞叹：工具提升的效率已经到这种地步了？

> 
> 再想到最近身边年轻人，实际的工作习惯，跟我们当时已经有些不同了*（有些习惯的交付效率很高）*。
> 
> 倒不是说`新的就是好的`、或者`老的就是要淘汰的`，而是新的东西总能给人刺激/输入，赶紧学起来吧、跟上来~
> 
> 如果一直沉浸在已有的知识圈内，不断加固，可能会有更深入的见解；但，弊端也很明显，逐渐的闭塞、狭隘，最终落后、淘汰。
> 
> 开放心态、赶紧跟着时代，跟年轻人在一起、尝试新的东西，做些更有价值的事情。
> 
> `与时俱进`真是一种非常有`灵气`、有`魄力`、有`胆识`的能力。


今天整体看下 `Jupyter notebook`.



## 1.Jupyter 简介

> 下文来自 ChatGPT，自己做了微调.

Jupyter 是一种开源的**交互式计算环境**，最常见的形式是 Jupyter Notebook（Jupyter 记事本）。它允许用户在一个文档中结合`代码`、`文本`、`数学公式`、`图表`和其他`多媒体内容`，因此非常适合`数据分析`、`机器学习`和`科学计算`等领域。

Jupyter Notebook 最初是为 Python 语言设计的，但现已支持多种编程语言（通过 Jupyter 内核，如 R、Julia 等）。

**Jupyter Notebook 的主要特点包括：**

1. **交互式计算**：你可以在一个文档中编写和运行代码，并立即看到输出结果，这对数据探索和分析非常有用。

2. **可视化**：支持将数据可视化嵌入到记事本中，包括静态和交互式图表。

3. **可共享性**：Jupyter Notebook 文件保存为 `.ipynb` 格式，可以轻松分享和复现，其他人可以直接在他们的环境中运行你的代码。

4. **可再现性**：通过记录完整的数据分析过程，包括代码和结果，确保研究和分析的可再现性。

5. **支持多种编程语言**：虽然 Jupyter Notebook 最初是为 Python 设计的，但它也支持多种编程语言，如 R、Julia 等。

Jupyter 之所以流行，是因为它简化了数据科学家的工作流程，并且非常适合教学、实验和文档编写。你在技术文档中看到的“Jupyter 记事本”提示，通常意味着这些文档或代码片段在 Jupyter Notebook 中展示和运行效果最佳。


## 2.试用 Jupyter

从[ Jupyter 官网](https://jupyter.org/)看到，Jupyter 实际上，包含几类产品：

* JupyterLab: A Next-Generation Notebook Interface
* Jupyter Notebook: The Classic Notebook Interface
* Jupyterhub: A multi-user version of the notebook designed for companies, classrooms and research labs


问了下 ChatGPT 两者的区别： 

> JupyterLab 和 Jupyter Notebook 都是 Jupyter 项目的用户界面工具，但它们在设计和功能上有一些重要的区别。
> 
> ##### 1. **用户界面和体验**
>    - **Jupyter Notebook**：传统的单一界面，主要用于编辑和运行 `.ipynb` 记事本文件。界面简单，左侧是代码单元和文本单元，右侧是输出。适合进行线性工作流的简单数据分析和教学任务。
>    
>    - **JupyterLab**：更现代化、更强大的多功能界面。JupyterLab 支持多个面板，可以同时打开多个记事本、终端、文本编辑器、文件浏览器等。它提供了类似 IDE（集成开发环境）的体验，允许用户在同一窗口中同时处理多个文件和任务，适合更复杂的工作流。
> 
> ##### 2. **扩展性**
>    - **Jupyter Notebook**：支持扩展和插件，但扩展性有限，需要通过配置文件或命令行安装额外插件。
>    
>    - **JupyterLab**：内置了丰富的扩展系统，用户可以通过简单的插件安装过程扩展 JupyterLab 的功能，如增加代码格式化工具、版本控制集成、增强的图表工具等。
> 
> ##### 3. **文件管理**
>    - **Jupyter Notebook**：文件管理功能比较简单，主要用于打开和保存记事本文件。
>    
>    - **JupyterLab**：文件管理更加全面，支持拖放、复制粘贴、重命名等操作，允许用户在一个窗口中管理和查看多个文件。
> 
> ##### 4. **支持的文件类型**
>    - **Jupyter Notebook**：主要支持 `.ipynb` 文件，虽然也可以编辑其他文件类型，但不是主要用途。
>    
>    - **JupyterLab**：不仅支持 `.ipynb` 文件，还支持纯文本文件（如 `.py`、`.txt`），Markdown 文件，PDF，CSV 等。可以直接在 JupyterLab 中进行各种格式的文件编辑和查看。
> 
> ##### 5. **性能和稳定性**
>    - **Jupyter Notebook**：由于设计较为简单，性能较为稳定，但对于复杂的任务处理和多任务管理，可能会显得局限。
>    
>    - **JupyterLab**：因为是新一代工具，设计时考虑到了更复杂的工作流和任务，提供了更高的性能和更灵活的操作环境。
> 
> ##### 6. **开发和维护**
>    - **Jupyter Notebook**：仍在维护，但更新频率较低，重点逐渐转向 JupyterLab。
>    
>    - **JupyterLab**：是 Jupyter 项目未来发展的重点，更新频率更高，并不断引入新功能。
> 
> ##### 结论
> 
> 如果你主要进行简单的数据分析或教学任务，Jupyter Notebook 可能足够了。
> 
> 但如果你需要一个功能更强大、更灵活的开发环境，特别是当你处理多个文件或进行复杂的工作流时，JupyterLab 是更好的选择。
> 



可以在线使用 Jupyter： [https://jupyter.org/try](https://jupyter.org/try)

如果要本地安装，参考：[Installing Jupyter](https://jupyter.org/install)






## 3.关联资料

* chatgpt: 
	* jupyter 是什么，最近很流行，一些技术文档都提示使用了 jupyter 记事本
	* JupyterLab 和 JupyterNotebook 之间，有什么区别
* 官网：[https://jupyter.org/](https://jupyter.org/)









[NingG]:    http://ningg.github.io  "NingG"










