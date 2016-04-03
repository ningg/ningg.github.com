---
layout: post
title: Linux下查看内存占用情况(C实现)
description: 如何使用C语言，实现查看当前内存占用的函数
category: Linux
---

## 背景

__时间__：2012-10-18 14:21

__目标__：实现一个c函数，功能：在屏幕上输出当前内存使用情况，包括已用内存、空闲内存。
         效果如图：shell命令，`free –m`

![free-m](/images/linux-memory-usage/free-m.jpg)


## 分析

1. c的函数中，有没有现成的函数；
2. shell中命令`free –m`的详解（自己`man`即可，`-m`表示结果以`MB`为单位显示）

经查询，`linux`下系统自带函数`int sysinfo(struct sysinfo *info)`可以实现此功能；

由于不同linux内核版本对应的`struct sysinfo`内部成员不同，在`linux`下，输入如下命令：

	man sysinfo()

获得当前系统中sysinfo结构体的定义：

	struct sysinfo {
			   long uptime;             /* Seconds since boot */
			   unsigned long loads[3];  /* 1, 5, and 15minute load averages */
			   unsigned long totalram;  /* Total usable main memory size */
			   unsigned long freeram;   /* Available memory size */
			   unsigned long sharedram; /* Amount of shared memory */
			   unsigned long bufferram; /* Memory used by buffers */
			   unsigned long totalswap; /* Total swap space size */
			   unsigned long freeswap;  /* swap space still available */
			   unsigned short procs;    /* Number of current processes */
			   unsigned long totalhigh; /* Total high memory size */
			   unsigned long freehigh;  /* Available high memory size */
			   unsigned int mem_unit;   /* Memory unit size in bytes */
			   char _f[20-2*sizeof(long)-sizeof(int)]; /* Padding for libc5 */
			   };


有了上面这些知识，正式开始动手写程序：
头文件：`get_MEM.h`

	#ifndef GET_MEM_H
	#define GET_MEM_H
	 
	/*********************
	 *function: get the memory used and free in MB units.
	 *return: 0 , success; other ,fail
	 *********************
	 */
	int get_MEM(const char*);
	#endif

主程序文件：`get_MEM.c`

	#include stdio.h
	#include stdlib.h
	#include linux/kernel.h   /* 包含sysinfo结构体信息*/
	#include string.h
	#include "get_MEM.h"
	 
	int main(int argc, char *agrv[]){
		get_MEM("hello");
	}
	 
	int get_MEM(const char* str){
		struct sysinfo s_info;
		int error = sysinfo(&amp;s_info);
		if (error != 0){
			exit(EXIT_FAILURE);
		}
	 
		printf("RAM(MB): used %u \t free %u \r  %s \n ",
				(unsigned int)((s_info.totalram-s_info.freeram)/(1024*1024.0)),
							(unsigned int)(s_info.freeram/(1024*1024.0)),  str);
		return 0;
	}


将两个文件：`get_MEM.h`和`get_MEM.c`放在同一路径下，使用`gcc`进行编译，并运行

	gcc get_MEM.c
	./a.out

运行效果如下：

	RAM(MB):used 1377        free 10651      hello

[NingG]:    http://ningg.github.com  "NingG"
