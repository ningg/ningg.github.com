---
title: LangChain Interpreter Skills：提示词定义意图，代码保障执行
description: LangChain 提出 Interpreter Skills，用解释器内代码模块将 Agent 的确定性执行从提示词中剥离，解决长流程中的"上下文焦虑"问题。
date: 2026-06-07
source_url: https://www.langchain.com/blog/interpreter-skills
tags: [AI, agent, LLM, 架构]
published: true
---

## 原文

LangChain 刚发布了一个叫 Interpreter Skills 的实验性功能，解决了 Agent 开发中一个被长期忽视的矛盾：提示词能描述意图，但保不住执行路径。

这事儿为什么重要？因为自从 AI Agent 降温后，所有人都在问同一个问题：怎么让 Agent 稳定地走完流程？

### 问题出在哪

过去一年的 Agent 架构，基本在两条路之间反复横跳。一条是工作流（Workflow），开发者提前定义好步骤顺序，可靠性高但灵活性差。另一条是上下文驱动（Context-driven），模型根据当前上下文自己决定下一步，灵活但容易跑偏。

LangChain 的 Deep Agents 团队在实践中发现了一个关键现象：当 Agent 拥有解释器（Interpreter）时，面对同一个任务，它每次可能选择不同的代码路径。对于需要创造力的任务，这没问题。但对于需要确定性的任务，比如提交发票、工单分类、仓库 Triage，你希望它走的是"已验证有效"的路径，而不是每次重新发明轮子。

这个问题在长流程中尤为严重。拿 GitHub 仓库 Triage 来说，如果有 300 个待处理的 Issue，模型需要在工作上下文中维护每一步的状态。做到后面，模型会开始走捷径、压缩流程，甚至在中途被无关请求打断后，跳过关键步骤。Anthropic 把这种现象叫做"上下文焦虑"。

### Interpreter Skills 的解法

LangChain 的方案是：给 Skill 加一层代码模块。

传统 Skill 只有 SKILL.md，告诉 Agent 什么时候用、怎么用。但实际执行仍然依赖模型"读懂指令并正确执行"。Interpreter Skills 在此基础上增加了一个 index.ts 模块，Agent 可以在运行时通过解释器直接 import 并调用。

### 核心变化在三个维度

**1. 确定性从提示词转移到代码**

普通 Skill 说的是：这里有操作指南，请你按步骤执行。Interpreter Skill 说的是：这里有判断何时触发这个行为的说明，还有一段已经写好、测试过的代码，你判断触发条件就行，执行交给代码。

这改变了一个基本假设：以前我们默认模型要"理解并执行"，现在模型只需要"判断和委托"。执行路径从概率行为变成了确定行为。

**2. 解释器内状态持久化**

TypeScript 运行时给 Agent 提供了持久的工作状态。数组保持为数组，对象保持为对象，辅助函数保持定义。Agent 不需要把每个中间值转换成 stdout、文件或回传给模型的消息。

这直接解决了长流程中上下文膨胀的问题。以前 300 个 Issue 的分类结果需要全部存在模型上下文里，现在只需要返回一个结构化的 result 对象，Agent 可以继续深入某个聚类，也可以直接调用 result.toMarkdown() 生成报告。

**3. 安全边界的精细化**

解释器不是沙箱。沙箱给你的是默认全开、需要手动关门的隔离环境。解释器是默认全关、需要逐个放行的受控运行时。文件系统访问、网络访问、工具调用、子 Agent 生成，都需要在 Harness 层显式暴露。

这个设计很关键：Agent 可以在代码里调用子 Agent（spawn subagent），但这个能力是被 Harness 允许、计量、审计的。不是随便什么代码都能跑，也不是随便哪个步骤都能触发子 Agent。

### 仓库 Triage 的实战案例

LangChain 给出了一个完整的实战案例。用户让 Agent 对 langchain-ai/deepagents 仓库做 Triage：

```
const { triage } = await import("@/skills/github-triage");
const result = await triage("langchain-ai/deepagents", {
  issues: true,
  prs: true,
  discussions: true,
});
```

执行流程：

1. 从 GitHub 拉取所有未关闭的 Issue、PR、Discussion
2. 为每个条目生成子 Agent，创建精简描述
3. 子 Agent 的结果进入队列
4. 逐条消费队列，由另一个子 Agent 决定归入现有聚类还是创建新聚类
5. 返回包含 clusters、unassigned、toMarkdown() 的结构化结果

整个流程中模型只做了两件事：决定调用 triage 函数，以及处理返回结果。中间的 300 次子 Agent 调用、聚类决策、队列管理，全部由代码驱动。这个设计直接对冲了"上下文焦虑"问题。模型不再需要在工作上下文中维护 300 条 Issue 的状态，也不需要在第 280 条时还保持跟第 1 条同等的注意力。

## 批注

### Skill 的工作流化思维

LangChain 团队在这篇文章里提出了一个更深层的问题：我们到底需要的是"模型自由裁量"还是"确定性流程"？

答案不是二选一。Interpreter Skills 的思路是：用 Skill 定义何时触发（模型判断），用代码定义如何执行（确定性流程），用解释器连接两者。

这意味着一个 Agent 可以同时拥有两类行为：对于需要创造力的任务，模型自由发挥；对于需要可靠性的任务，Agent 调用预先写好的代码路径。两者不是互斥的，而是共存的。

从架构角度看，这其实是把 Harness 从"上下文编排器"升级成了"上下文 + 代码双轨编排器"。Harness 不仅管理模型看到的上下文，还管理模型可以调用的代码能力。

### 对普通开发者有什么用

无论你用任何 Agent 框架（不只是 LangChain），Interpreter Skills 的思路都值得借鉴：

1. **把确定性逻辑从提示词中剥离出来。** 如果一段流程每次都应该一样，那就别让模型"每次自己想"，写成代码让模型调用。

2. **给模型委托能力而非执行能力。** 模型擅长判断"什么时候该做什么"，不擅长"每次都按同样的方式做完"。

3. **用结构化返回值代替长文本。** 当 Agent 的中间结果需要被后续步骤引用时，用对象和函数接口代替纯文本，既节省上下文，又降低理解成本。

4. **分层暴露能力而非全开或全关。** 解释器的安全模型是白名单制的，这个思路在所有 Agent 场景下都适用。

LangChain 把这个功能标记为实验性质，但它指向的方向是明确的：Agent 的未来不是纯提示词，也不是纯代码，而是提示词定义意图、代码保障执行的混合架构。这对所有在做 Agent 开发的人来说，都是一个值得提前思考的方向。
