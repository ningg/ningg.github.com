---
layout: post
title: 如何参与开源项目
description: 基础工具开源，是自己的一个理念，现在力量单薄，就不能贡献一份力量吗？能的，一个开源项目涉及到的地方，肯定有不少琐碎的地方，这个我总能胜任吧。
category: blog
---

##背景

本来今天晚上想浏览一下flume官网的，不过突然看到How to Get Involved，再看看哪些提交了代码的名单，很是羡慕，我这个人爱吹牛，如果我也在名单中，那岂不又能吹牛一把？哈哈~想想都能笑出声。另一方面，用过的开源工具不少，但是如何参与到开源项目中，我还真不知道，碰巧在看flume官网，那就看看如何参与到flume这个开源项目中去吧。

> 官方原文地址：[How to Contribute](https://cwiki.apache.org/confluence/display/FLUME/How+to+Contribute)，本文使用`英文原文+中文注释`方式来写。

##Preface

Welcome contributors! We strive to include everyone's contributions. This page provides necessary guidelines on how to contribute effectively towards furthering the development and evolution of Flume. You should also read the guide on setting up [Development Environment](https://cwiki.apache.org/confluence/display/FLUME/Development+Environment) where you will find details on how to checkout, build and test Flume.
（如何下载源码、编译源码、测试源码，需要先阅读[Development Environment](https://cwiki.apache.org/confluence/display/FLUME/Development+Environment)。）

Note: This guide applies to general contributors. If you are a committer, please read the [How to Commit](https://cwiki.apache.org/confluence/display/FLUME/How+to+Commit) as well.
（committer还需阅读[How to Commit](https://cwiki.apache.org/confluence/display/FLUME/How+to+Commit)）


##What can be contributed?

There are many ways you can contribute towards the project. A few of these are:（参与方式，有如下几种）

* **Jump in on discussions**: It is possible that someone initiates a thread on the mailing list describing a problem that you have dealt with in the past. You can help the project by chiming in on that thread and guiding that user to overcome or workaround that problem or limitation.（查看邮件列表，参与讨论，帮助他人解决问题）
* **File Bugs**: If you notice a problem and are sure it is a bug, then go ahead and file a JIRA. If however, you are not very sure that it is a bug, you should first confirm it by discussing it on the Mailing Lists.（通过JIRA，提交bug；如果不确定，通过邮件列表提问，确认是否为bug）
* **Review Code**: If you see that a JIRA ticket has a "Patch Available" status, go ahead and review it. It cannot be stressed enough that you must be kind in your review and explain the rationale for your feedback and suggestions. Also note that not all review feedback is accepted - often times it is a compromise between the contributor and reviewer. If you are happy with the change and do not spot any major issues, then +1 it. More information on this is available in the following sections.（通过JIRA，检查代码-Patch补丁，提出反馈意见）
* **Provide Patches**: We encourage you to assign the relevant JIRA issue to yourself and supply a patch for it. The patch you provide can be code, documentation, build changes, or any combination of these. More information on this is available in the following sections.（通过JIRA，提交代码-patch补丁，可以是代码、文档、编译细节等）

**notes(ningg)：邮件列表、JIRA，我都没有关注过，也不会使用；patch文件了解一点。**

##Providing Patches

In order to provide patches, follow these guidelines:

* **Make sure there is a JIRA**:
	1. If you are working on fixing a problem that already has an associated JIRA, then go ahead and assign it to yourself. （JIRA上找到问题，并指派给自己）
	1. If it is already assigned to someone else, check with the current assignee before moving it over to your queue.（跟正在解决这个问题的人商量下）
	1. If the current assignee has already worked out some part of the fix, suggest that you can take that change over from them and complete the remaining parts.（如果有人已经修复bug的一部分，你可以接手，把余下的做完）
* **Attach the patches as you go through development**:
	1. While small fixes are easily done in a single patch, it is preferable that you attach patches to the JIRA as you go along. This serves as an early feedback mechanism where interested folks can look it over and suggest changes where necessary. It also ensures that if for some reason you are not able to find the time to complete the change, someone else can take up your initial patches and drive them to completion.（本地开发环境测试通过，就提交patch，即使是small fixes）
* **Before you submit your patch**:
	1. Your change should be well-formatted and readable. Please use two spaces for indentation (no tabs).（保证patch的well-formatted和readable，使用2个space，避免tab）
	1. Carefully consider whether you have handled all boundary conditions and have provided sufficiently defensive code where necessary.（代码的边界条件、异常捕获）
	1. Add one or more unit tests, if your change is not covered by existing automated tests.（添加单元测试）
	1. Insert javadocs and code comments where appropriate.（添加javadocs和comments）
	1. Update the [Flume User Guide](http://flume.apache.org/FlumeUserGuide.html) ([source](https://git-wip-us.apache.org/repos/asf?p=flume.git;a=blob;f=flume-ng-doc/sphinx/FlumeUserGuide.rst;hb=trunk)) if your change affects the Flume config file or any user interface. Include those changes in your patch.（修改文档）
	1. Make sure you update the relevant developer documentation, wiki pages, etc. if your change affects the development environment.（修改开发手册）
* **Test your changes before submitting a review**:
	1. Before you make the JIRA status as "Patch Available", please test your changes thoroughly. Try any new feature or fix out for yourself, and make sure that it works.（测试充分）
	1. Make sure that all unit/integration tests are passing, and that the functionality you have worked on is tested through existing or new tests.（unit/integration测试）
	1. You can run all the tests by going to the root level of the source tree and typing `mvn clean install`.（mvn clean install，执行测试）
* **How to create a patch file**:
	* The preferred naming convention for Flume patches is `FLUME-12345.patch`, or `FLUME-12345-0.patch` where 12345 is the JIRA number. You might want to name successive versions of the patch something like `FLUME-12345-1.patch`, `FLUME-12345-2.patch`, etc. as you iterate on your changes based on review feedback and re-submit them.（patch命名方式）
	* The command to generate the patch is `git diff`. Example:
	
	$ git diff > /path/to/FLUME-1234-0.patch

* **How to apply someone else's patch file**:
	* You can apply someone else's patch with the GNU patch tool. Example:

	$ cd ~/src/flume # or wherever you keep the root of your Flume source tree
	$ patch -p1 < FLUME-1234.patch

	* Contributors may variously submit patches in a couple of different formats. If you get some dialog from the patch tool asking which file you want to patch, try variously the "-p1" or "-p0" flags to patch. Without any additional arguments, git diff generates patches that are applied using patch `-p1`. If you use git diff `--no-prefix` to generate your patch, you have to apply it using patch `-p0`. The ReviewBoard tool understands both formats and is able to apply both types automatically.（`patch`命令的选项）
* **Submitting your patch for review**:
	1. To submit a patch, attach the patch file to the JIRA and change the status of the JIRA to "Patch Available".（JIRA上，提交patch，修改状态）
	1. If the change is non-trivial, please also post it for review on the Review Board. Use the Repository "flume-git" on Review Board.（关键的bug，需要在Review Board上标记一下）
	1. Link the JIRA to the Review Board review. JIRA has a feature you can use for this by going to More Actions > Link > Web Link when logged into JIRA.（Review Board上添加JIRA的链接）
* **Identify a reviewer**:
	1. When posting on review board (repository: "flume-git"), always add the Group "Flume" to the list of reviewers.（添加`Flume`到reviewers列表）
	1. Optionally, you may also add a specific reviewer to the review. You can pick any of the project committers for review. Note that identifying a reviewer does not stop others from reviewing your change. Be prepared for having your change reviewed by others at any time.（可以指定committer作为reviewer，但其他人仍可以review）
	1. If you have posted your change for review and no one has had a chance to review it yet, you can gently remind everyone by dropping a note on the developer mailing list with a link to the review.（可在mailing list中添加一个JIRA链接，告知别人来review代码）
* **Work with reviewers to get your change fleshed out**:
	1. When your change is reviewed, please engage with the reviewer via JIRA or review board to get necessary clarifications and work out other details.（及时给reviewer反馈，多交流）
	1. The goal is to ensure that the final state of your change is acceptable to the reviewer so that they can +1 it.（经过数次交流，reviewer确认代码可用了，会点击+1的）

**notes(ningg)：代码中添加javadocs，集成测试是什么，我还不清楚。**

##Reviewing Code

（doing...）

[NingG]:    http://ningg.github.com  "NingG"
