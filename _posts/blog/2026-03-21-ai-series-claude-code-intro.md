---
layout: post
title: Claude Code 系列：安装&使用-放弃，改用 Codex
description: 用最先进的生产力工具
published: true
category: AI
---

> 一直使用 cursor，近期准备把 claude code 和 codex 都用下.
> 
> 永远用最好的产品/工具，攀登的路上，不要在无谓的地方浪费精力。
> 



## 一、安装 claude code (弃用)

安装 claude code：

```
npm install -g @anthropic-ai/claude-code
```


claude 官网：

* https://claude.com/product/claude-code


## 二、安装 codex (推荐)

> claude code team 太贵了，弃用。改用 codex business 版本。

安装 codex：

```
// 安装最新版本的 codex: 特别是 arm 架构的 mac 电脑，需要安装最新版本的 codex。
npm install -g @openai/codex@latest
```

进入自己的核心目录后，运行：

```
// 进入自己的核心目录
cd ~/ningg.github.com

// 运行 codex
codex
```

进入 codex 的交互界面后，不知道问什么，简单抛了个问题：

```
> 解释下当前工程的作用

....

```

好的，codex 已经用起来了。


更多信息：

* [Codex 官网](https://developers.openai.com/codex)
* [Codex cli 官网](https://developers.openai.com/codex/cli)


## 三、更多 codex 介绍

直接看官网的信息：

> Codex is OpenAI’s coding agent for software development. ChatGPT Plus, Pro, Business, Edu, and Enterprise plans include Codex. It can help you:

> Write code: Describe what you want to build, and Codex generates code that matches your intent, adapting to your existing project structure and conventions.

> Understand unfamiliar codebases: Codex can read and explain complex or legacy code, helping you grasp how teams organize systems.

> Review code: Codex analyzes code to identify potential bugs, logic errors, and unhandled edge cases.

> Debug and fix problems: When something breaks, Codex helps trace failures, diagnose root causes, and suggest targeted fixes.

> Automate development tasks: Codex can run repetitive workflows such as refactoring, testing, migrations, and setup tasks so you can focus on higher-level engineering work.


不错，今天先到这儿。




































[NingG]:    http://ningg.github.io  "NingG"










