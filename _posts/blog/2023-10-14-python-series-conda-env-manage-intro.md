---
layout: post
title: Python 系列：Conda 简介，环境管理、依赖管理
description: Conda 能做什么，如何安装和简单使用
published: true
categories: AI OpenAI llama python
---

典型疑问：

* Conda 是什么、能做什么
* 如何安装 Conda
* 如何使用 Conda


## Conda 简介

A "conda env" refers to an environment created and managed using Conda, which is an open-source package management and environment management system that is widely used in the Python ecosystem. Conda allows you to create isolated environments in which you can install specific packages and dependencies, separate from the global Python installation on your system. These environments are often used to manage project-specific dependencies and configurations.

Here's how Conda environments work:

1. **Isolation**: Each Conda environment is isolated from others and from the system-wide Python installation. This isolation helps prevent conflicts between different projects' dependencies.
2. **Dependency Management**: You can specify the exact versions of packages and libraries you need for a particular project in a Conda environment. Conda will then ensure that these specific versions are installed in that environment.
3. **Activation/Deactivation**: You can activate and deactivate Conda environments as needed. When you activate an environment, it becomes the active environment for your current session, and any commands you run will use the packages and settings from that environment.
4. **Sharing Environments**: You can easily export and share the configuration of a Conda environment with others. This is especially useful for replicating the same environment on different machines or for collaborating on a project with specific dependencies.

Creating a Conda environment is typically done with a command like this:

```bash
conda create --name myenv python=3.8
```

This command creates a Conda environment named "myenv" with Python 3.8 installed. You can then activate this environment and install packages into it. When working on a specific project, you can switch to the appropriate Conda environment to ensure that you're using the right set of dependencies.

Conda environments are popular among data scientists, developers, and researchers working with Python because they provide a flexible and robust way to manage dependencies and isolate project-specific requirements.

> ningg 评： conda 主要是 python 领域的依赖管理，提供项目粒度的环境隔离，可以很方便的定义多个环境、并且能够快速切换。


## Installation

来源：

* [Installation](https://docs.anaconda.com/free/anaconda/install/) 
* [Installing on macOS](https://docs.anaconda.com/free/anaconda/install/mac-os/)

使用了上面 `Wizard install` 可视化页面的安装步骤。



## Getting started with conda

来源：[Getting started with conda](https://conda.io/projects/conda/en/latest/user-guide/getting-started.html)


### Before you start

You should have already installed Anaconda.

### Contents

1. Starting conda on Windows, macOS, or Linux. 2 MINUTES
1. Managing conda. Verify that Anaconda is installed and check that conda is updated to the current version. 3 MINUTES
1. Managing environments. Create environments and move easily between them. 5 MINUTES
1. Managing Python. Create an environment that has a different version of Python. 5 MINUTES
1. Managing packages. Find packages available for you to install. Install packages. 5 MINUTES


### Starting conda

Open Launchpad, then click the terminal icon.

On macOS, all commands below are typed into the terminal window.

### Managing conda

Verify that conda is installed and running on your system by typing:

```
conda --version
```

Conda displays the number of the version that you have installed. You do not need to navigate to the Anaconda directory.

Update conda to the current version. Type the following:

```
conda update conda
```

Conda compares versions and then displays what is available to install.

If a newer version of conda is available, type y to update:

```
Proceed ([y]/n)? y
```

Tip: We recommend that you always keep conda updated to the latest version.

### Managing environments

Conda allows you to create separate environments containing files, packages, and their dependencies that will not interact with other environments.

When you begin using conda, you already have a default environment named `base`. You don't want to put programs into your `base` environment, though. Create separate environments to keep your programs isolated from each other.

#### Create a new environment and install a package in it.

We will name the environment snowflakes and install the package BioPython. At the Anaconda Prompt or in your terminal window, type the following:

```
conda create --name snowflakes biopython
```

Conda checks to see what additional packages ("dependencies") BioPython will need, and asks if you want to proceed:

```
Proceed ([y]/n)? y
```


Type "y" and press Enter to proceed.


#### "activate" the new environment

To use, or "activate" the new environment, type the following:

1. Windows: `conda activate snowflakes`
1. macOS and Linux: `conda activate snowflakes`

Note: conda activate only works on conda 4.6 and later versions.

For conda versions prior to 4.6, type:

* Windows: `activate snowflakes`
* macOS and Linux:` source activate snowflakes`

Now that you are in your snowflakes environment, any conda commands you type will go to that environment until you deactivate it.


#### see all env list

To see a list of all your environments, type:

```
conda info --envs
```

A list of environments appears, similar to the following:

conda environments:

```
    base           /home/username/Anaconda3
    snowflakes   * /home/username/Anaconda3/envs/snowflakes
```

Tip: The active environment is the one with an asterisk (*).

#### change back to default

Change your current environment back to the default (base): `conda activate`

Note: For versions prior to conda 4.6, use:

* Windows: `activate`
* macOS, Linux: `source activate`

Tip

* When the environment is deactivated, its name is no longer shown in your prompt, and the asterisk (*) returns to base. 
* To verify, you can repeat the `conda info --envs` command.


### Managing Python

When you create a new environment, conda installs the same Python version you used when you downloaded and installed Anaconda. If you want to use a different version of Python, for example Python 3.5, simply create a new environment and specify the version of Python that you want.

1.Create a new environment named "snakes" that contains Python 3.9:

+ `conda create --name snakes python=3.9`
    
+ When conda asks if you want to proceed, type "y" and press Enter.
    
2.Activate the new environment:
    
+   Windows: `conda activate snakes`
    
+   macOS and Linux: `conda activate snakes`
    
    
Note: `conda activate` only works on conda 4.6 and later versions.
    
For conda versions prior to 4.6, type:
    
+   Windows: `activate snakes`
    
+   macOS and Linux: `source activate snakes`
        
3.Verify that the snakes environment has been added and is active:

```
    conda info --envs
```
    
Conda displays the list of all environments with an asterisk (*) after the name of the active environment:

```    
    # conda environments:
    #
    base                     /home/username/anaconda3
    snakes                *  /home/username/anaconda3/envs/snakes
    snowflakes               /home/username/anaconda3/envs/snowflakes
```
   
The active environment is also displayed in front of your prompt in (parentheses) or [brackets] like this:

```
    (snakes) $
```
    
4.Verify which version of Python is in your current environment:

```    
	python --version
```
    
5.Deactivate the snakes environment and return to base environment: `conda activate`
    
    Note
    
    For versions prior to conda 4.6, use:
    
    > +   Windows: `activate`
    >     
    > +   macOS, Linux: `source activate`
    >


### Managing packages

In this section, you check which packages you have installed, check which are available and look for a specific package and install it.

1.To find a package you have already installed, first activate the environment you want to search. Look above for the commands to activate your snakes environment.

2.Check to see if a package you have not installed named "beautifulsoup4" is available from the Anaconda repository (must be connected to the Internet):

```
conda search beautifulsoup4
```

3.Conda displays a list of all packages with that name on the Anaconda repository, so we know it is available.

Install this package into the current environment:

```
conda install beautifulsoup4
```

Check to see if the newly installed program is in this environment:

```
conda list
```

### More information

+   [Conda cheat sheet](cheatsheet.html)
    
+   Full documentation--- [https://conda.io/docs/](https://conda.io/docs/)
    
+   Free community support--- [https://groups.google.com/a/anaconda.com/forum/#!forum/anaconda](https://groups.google.com/a/anaconda.com/forum/#!forum/anaconda)
    
+   Paid support options--- [https://www.anaconda.com/support/](https://www.anaconda.com/support/)



## 关联资料




关联资料：

* [Conda Overview](https://docs.conda.io/projects/conda/en/4.6.0/user-guide/overview.html)
* chat with ChatGPT3.5














[NingG]:    http://ningg.github.io  "NingG"





