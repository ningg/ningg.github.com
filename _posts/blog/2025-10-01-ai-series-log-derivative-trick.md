---
layout: post
title: AI 系列：对数导数技巧 log-derivative trick
description: log-derivative trick 是什么，什么场景下适用？
published: true
category: AI
---

## 1. log-derivative trick 对数导数trick

“**log-derivative trick**” 中文一般翻译为：**“对数导数技巧”** 或 **“对数梯度技巧”**。

这是在**强化学习**和**概率模型求导**中非常常见的数学技巧。

它的核心作用是：**把对概率分布参数的导数，转化成期望形式，从而方便采样估计梯度**。

### 1.1. 基本形式

假设我们要对一个期望求导：

$$
\nabla_\theta \mathbb{E}_{x \sim p_\theta(x)}[f(x)]
$$

其中 $$p_\theta(x)$$ 是依赖于参数 $$\theta$$ 的概率分布。

直接对这个期望`求导不方便`，因为 $$x$$ 是从分布中`采样`得到的。


于是用 **log-derivative trick**：

$$
\nabla_\theta p_\theta(x) = p_\theta(x) \nabla_\theta \log p_\theta(x)
$$

> 简单推导： $$\nabla \log x = \frac{1}{x}\nabla x  \implies \nabla x = x \nabla \log x$$ 。 

代入后：

$$
\nabla_\theta \mathbb{E}_{x \sim p_\theta}[f(x)]
$$

$$
= \nabla_\theta \int f(x) p_\theta(x) dx
$$

$$
= \int f(x) \nabla_\theta p_\theta(x) dx
$$

$$
= \int f(x) p_\theta(x) \nabla_\theta \log p_\theta(x) dx
$$

$$
= \mathbb{E}_{x \sim p_\theta}[f(x) \nabla_\theta \log p_\theta(x)]
$$

这就是 **对数导数技巧（log-derivative trick）** 的核心结论。


### 1.2. 直观理解

> “把求导移到 log 上，再乘回来。”

直觉上：

* 直接对`概率求导`，不好算；
* 但对 `log 概率求导`，更简单；
* 所以我们“**加一乘一**”，借助 $$p_\theta(x)\nabla_\theta \log p_\theta(x)$$ 来转化。

这一步在数学上，相当于引入了一个 **对数梯度**，让**期望的梯度**可以用**采样估计**：

$$
\nabla_\theta J(\theta) = \mathbb{E}[f(x)\nabla_\theta \log p_\theta(x)]
$$


### 1.3. 在强化学习中的应用

在强化学习的**策略梯度**（Policy Gradient）中，策略 $$\pi_\theta(a\|s)$$ 是一个概率分布，目标函数是：

$$
J(\theta) = \mathbb{E}_{\tau \sim \pi_\theta}[R(\tau)]
$$

用 log-derivative trick：

$$
\nabla_\theta J(\theta) = \mathbb{E}_{\tau \sim \pi_\theta}[R(\tau) \nabla_\theta \log \pi_\theta(\tau)]
$$

这一步就让策略梯度可以**通过采样轨迹来估计**，而不需要知道整个分布形式。

这就是 **REINFORCE算法** 的数学基础。


### 1.4. 总结一句话

| 英文    | 中文     | 作用     | 应用场景   |
| ------ | ------- | ------- | ------- |
| log-derivative trick | 对数导数技巧 / 对数梯度技巧 | 把对概率分布的导数，转化为 log 概率的导数，从而方便采样估计梯度 | 策略梯度、变分推断、概率图模型求导等 |



## 2.采样轨迹

> 为什么说：通过采样轨迹来估计呢？是否还有其他可能呢？


我们来仔细分清楚这句话“通过采样轨迹来估计”的含义，以及是否“只有这一种方式”。


### 2.1.为什么是“通过采样轨迹来估计”

我们在强化学习中要优化的是：

$$
J(θ) = \mathbb{E}_{τ \sim π_θ}[R(τ)]
$$

这里：

* 记 $$\tau = (s_0, a_0, s_1, a_1, \dots)$$ 是一条“轨迹（`trajectory`）”；
* 它是从策略分布 $$\pi_\theta(a\|s)$$ 与环境动态 $$p(s_{t+1}\|s_t, a_t)$$ 共同生成的；
* 记 $$R(\tau)$$ 是这条轨迹上的**累计奖励**。


直接算期望 $$\mathbb{E}_{\tau \sim \pi_\theta}$$ 很困难，因为轨迹**空间非常大**、**分布复杂**。

于是使用 **log-derivative trick**：

$$
\nabla_θ J(θ)
= \mathbb{E}_{τ \sim π_θ}[R(τ) \nabla_θ \log π_θ(τ)]
$$

这一步的关键好处是：

* 只需要能**采样出轨迹** $$\tau$$，然后计算 $$R(\tau)$$ 和 $$\nabla_\theta \log \pi_\theta(\tau)$$，就能近似这个期望。

于是我们用**采样平均**来估计梯度：


$$
\nabla_\theta J(\theta) \approx \frac{1}{N} \sum_{i=1}^N R(\tau_i) \nabla_\theta \log \pi_\theta(\tau_i)
$$

这就是“**通过采样轨迹来估计**”的含义：
我们不需要解析积分，只需采样轨迹、用 Monte Carlo 平均即可。


### 2.2. 是不是“只有这一种方式”？

不是。

这只是 **一种常见的近似求解思路**。还有几类更高级或替代的方法：

#### 2.2.1. 基于采样的变体（依然是轨迹采样）

比如：

* **Actor-Critic 方法**：在采样轨迹的基础上，用 Critic 网络（价值函数）来**减少方差**；
* **GAE（Generalized Advantage Estimation）**：用“优势函数”代替原始回报 $$R(\tau)$$，平衡偏差和方差。

这些仍然依赖采样轨迹，但**改进了估计**方式。


#### 2.2.2. 模型驱动的方法（不一定采样轨迹）

如果你有**已知的环境模型** $$p(s'\|s,a)$$，可以直接：

* 构造 **解析的动态规划方程（Policy Evaluation / Policy Iteration）**；
* 或者用 **确定性梯度（Deterministic Policy Gradient）**，在**连续空间**中求期望；
* 或者用 **模型预测控制（MPC）** 等，完全避免轨迹采样。

这类方法属于 **model-based RL（基于模型的强化学习）**，不需要真实采样轨迹。


#### 2.2.3. 离线强化学习（Offline RL）

在离线场景中，轨迹不是你采样的，而是**历史数据集给的**。

这时你依然用类似 log-derivative trick 的思想，但要修正**分布偏差（off-policy correction）**，例如：

* 使用 **重要性采样（importance sampling）**
* 或 **行为克隆 + 值函数微调** 等。

所以这时梯度的估计不是“采样轨迹”，而是“利用已有轨迹”。


### 2.3. 总结一句话

| 方法类型   | 是否采样轨迹 | 说明    |
| -------- | ------ | ----------- |
| REINFORCE、Policy Gradient | 是    | 通过环境采样轨迹估计梯度      |
| Actor-Critic / PPO / A3C  | 是    | 采样轨迹 + 学习价值函数减少方差 |
| Model-based RL            | 否    | 使用已知环境模型推导梯度或规划   |
| Offline RL                | 是 / 否  | 使用历史轨迹数据集估计梯度     |


所以那句话更准确的理解是：

> log-derivative trick **使得我们可以通过采样轨迹来估计梯度**，而不是说“只能这样做”。
> 它是“能这样做”的数学基础，但并非唯一手段。







[NingG]:    http://ningg.github.io  "NingG"










