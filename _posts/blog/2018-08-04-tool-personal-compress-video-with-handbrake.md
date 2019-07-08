---
layout: post
title: 工具系列：Mac 上，视频压缩
description: 如何压缩视频？是否可以放大音频？
category: tool 
---

## 1.背景

**背景**：技术学院中，录制的分享视频，上传时，限制单个文件最大 2GB，而我们通过手机，录制的 1h8mins 的视频，原始大小为 6GB。

**目标**：将 6GB 的 mp4 视频文件，在保证视频质量的前提下，压缩为 2GB 以内。

## 2.视频压缩

几个方面：

1. 环境说明
1. 视频压缩步骤

### 2.1.环境说明

基本环境：

* 电脑：MacBook Pro

视频文件：

* 时长：1h8mins
* 原始大小：6GB
* 格式：mp4

视频文件，压缩目标：

* 大小：2GB 以下

### 2.2.视频压缩步骤

在 MacBook Pro 上，安装视频压缩软件：**handbrake**。

使用 handbrake 进行视频转换：

​![](/images/tool-mac/handbrake-1-video.png)

补充说明，如果音频特别低，可以配置「音频增强」：

![](/images/tool-mac/handbrake-2-audio.png)
​

关于上述截图中的「配置参数」细节，参考：

* [这可能是 Mac 上最佳的视频压制和格式转换方案]

### 2.3.压缩效果

使用上述截图中的配置，最终的压缩效果：

* 视频效果：仍非常清晰
* 文件大小：从 6 GB 降至 1.27GB

## 3.参考来源

* [这可能是 Mac 上最佳的视频压制和格式转换方案]






















[NingG]:    http://ningg.github.com  "NingG"
[这可能是 Mac 上最佳的视频压制和格式转换方案]:		https://patricorgi.github.io/2016/11/12/%E8%BF%99%E5%8F%AF%E8%83%BD%E6%98%AF%20Mac%20%E4%B8%8A%E6%9C%80%E4%BD%B3%E8%A7%86%E9%A2%91%E6%A0%BC%E5%BC%8F%E8%BD%AC%E6%8D%A2%E5%92%8C%E5%8E%8B%E5%88%B6%E6%96%B9%E6%A1%88/