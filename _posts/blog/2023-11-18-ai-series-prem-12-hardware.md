---
layout: post
title: AI 系列：Hardware
description: 硬件
published: true
category: AI
---


原文：[Hardware](https://book.premai.io/state-of-open-source-ai/hardware/)


    

## Machine Learning and GPUs[#](#machine-learning-and-gpus "Permalink to this heading")

    

`GPU`特别适用于人工智能所需的计算类型，原因如下：

* **并行计算** **Parallelisation**：深度学习模型涉及大量的`矩阵乘法`和其他可并行化的操作。`单个GPU`可以拥有`数千个核心`（core），使其能够同时执行许多操作，这可以显著加快`训练`和`推断`(inference)的速度。

* **专用硬件** **Specialised Hardware**：现代GPU拥有专门用于执行`深度学习`中常见操作的专用硬件，如`矩阵乘法`和`卷积`（`matrix multiplications` and `convolutions`）。例如，NVIDIA的Volta和Turing架构包括 `Tensor Cores`，这些是专门设计用于，加速`混合精度``矩阵乘积累加`操作的硬件单元（mixed-precision matrix multiply-and-accumulate operations）。

* **高内存带宽** **High Memory Bandwidth**：GPU的`内存带宽`比CPU`高`得多，这使得它们可以更快地传输数据到内存和从内存中读取数据。这对于涉及`大量数据`的深度学习模型至关重要。

* **软件支持** **Software Support**：流行的深度学习框架（如`TensorFlow`和`PyTorch`）中，对GPU计算有很多软件支持。这些框架提供了高级API，使得开发模型并在GPU上运行变得简单，无需编写低级GPU代码。

* **能效** **Energy Efficiency**：训练深度学习模型可以是非常`计算密集`的，而`GPU`通常比CPU`更节能`，特别适合这些类型的计算。



For these reasons, GPUs are often the preferred hardware for training and deploying deep learning models. That said, there are other types of hardware that can also be used for deep learning, such as `TPUs` (**Tensor Processing Units**), which are custom accelerators designed by Google specifically for deep learning.

> Tensor Processing Units（`TPUs`）是由谷歌开发的`专用硬件`，旨在加速深度学习工作负载。
> 
> 1. 它们专门用于执行与神经网络训练和推断相关的`张量计算`。
> 2. TPU与传统的通用处理器（如CPU）或图形处理器（如GPU）不同，其设计更注重`加速`神经网络工作负载的`特定操作`。
> 3. TPU专为大规模的人工智能工作负载而设计，其架构和优化旨在更高效地执行神经网络的训练和推断。
> 
> 在深度学习中，`Tensor`实际上就是一个`多维数组`（multidimensional array），其目的是能够创造更高维度的`矩阵`、`向量`。



## Types of GPUs[#](#types-of-gpus "Permalink to this heading")


1. **NVIDIA GPU**：NVIDIA目前是机器学习应用中主导的`GPU市场领导者`。他们的GPU广泛应用于研究和商业应用。NVIDIA提供了一整套机器学习软件工具和库，包括`CUDA`和`cuDNN`（CUDA深度神经网络库），这些工具对于训练深度神经网络至关重要。例如，NVIDIA `A100` GPU专门设计用于`人工智能`和`数据分析`。

2. **AMD GPU**：AMD GPU也被用于机器学习，但它们没有NVIDIA GPU那么流行。AMD提供了`ROCm`（`Radeon Open Compute`，Radeon开放计算）平台，这是一个面向GPU的高性能计算和机器学习应用的开源软件平台。然而，与NVIDIA GPU相比，AMD GPU的软件生态系统不够成熟。

3. **苹果Silicon GPU**：苹果为其Apple Silicon芯片（如M1）开发了自己的GPU。这些GPU针对低功耗进行了优化，应用在诸如MacBook Air、MacBook Pro、Mac Mini和iPad Pro等苹果设备上。这些GPU在移动和集成GPU方面性能相当不错，但不适合高性能的机器学习任务。

4. **英特尔GPU**：英特尔也在为机器学习应用开发GPU。他们即将推出的`Intel Xe` GPUs预计将为机器学习任务提供有竞争力的性能。英特尔还提供了`oneAPI`工具包，其中包括一个用于深度神经网络的库（`oneDNN`）。

5. **Google TPU（Tensor Processing Unit）**：虽然技术上不是GPU，但Google的`TPU`是为机器学习任务设计的`定制加速器`。它们旨在为机器学习模型的训练和推断提供高性能和效率。TPU可通过Google的云计算服务使用。

每种选择在`性能`、`功耗`、`软件支持`和`成本`方面都有各自的优缺点。由于`性能强劲`且拥有成熟的`软件生态`系统，`NVIDIA GPU`目前是机器学习应用中最受欢迎的选择。


## Programming for GPUs[#](#programming-for-gpus "Permalink to this heading")

### NVIDIA GPUs[#](#nvidia-gpus "Permalink to this heading")

#### CUDA[#](#cuda "Permalink to this heading")

To interact with NVIDIA GPUs, you will primarily use CUDA. CUDA is a parallel computing platform & programming model developed by NVIDIA for general computing on its GPUs \[[152](../references/#id60 "NVIDIA Corporation. Your GPU compute capability. 2023. URL: https://developer.nvidia.com/cuda-gpus.")\].

Here are the main components you will interact with:

1.  [**CUDA Toolkit**](https://developer.nvidia.com/cuda-downloads), which includes:
    
    +   **CUDA libraries**: e.g. `cuBLAS` for linear algebra, `cuDNN` for deep learning, and others for FFTs, sparse matrices, and more
        
    +   [**CUDA runtime**](https://docs.nvidia.com/cuda/cuda-c-programming-guide/#cuda-runtime) (`cudart`)
        
    +   [**CUDA compiler**](https://docs.nvidia.com/cuda/cuda-c-programming-guide/#compilation-with-nvcc) (`nvcc`)
        
    +   [**NVIDIA drivers**](https://www.nvidia.com/Download/index.aspx): allow your operating system & programs to communicate with your NVIDIA graphics card
        
2.  [**CUDA Language**](https://docs.nvidia.com/cuda/cuda-c-programming-guide): an extension of the C/C++ programming language which includes [some additional keywords & constructs](https://docs.nvidia.com/cuda/cuda-c-programming-guide/#c-language-extensions) for writing parallel code.
    

Here is a basic workflow for using NVIDIA GPUs:

1.  **Install NVIDIA drivers & CUDA Toolkit**, using one of the following (depending on your taste):
    
    +   [Developer download matrix (recommended)](https://developer.nvidia.com/cuda-downloads)
        
    +   [Quickstart guide (slightly more detailed)](https://docs.nvidia.com/cuda/cuda-quick-start-guide)
        
    +   [Quickstart videos (if you prefer eye-candy)](https://developer.nvidia.com/how-to-cuda-c-cpp)
        
    +   Full Guide for [Linux](https://docs.nvidia.com/cuda/cuda-installation-guide-linux) or [Windows](https://docs.nvidia.com/cuda/cuda-installation-guide-microsoft-windows)
        
2.  [**Write your code**](https://docs.nvidia.com/cuda/cuda-c-programming-guide): Use the CUDA programming language (an extension of C/C++) to write your code. This will involve writing kernel functions that will be executed on the GPU, and host code that will be executed on the CPU.
    
3.  **Compile your code**: Use the NVCC compiler (included in the CUDA Toolkit) to compile your code.
    
4.  **Run your code**: Run your compiled code on an NVIDIA GPU.
    

For example, here is a simple CUDA program that adds two vectors:

```
#include "cuda\_runtime.h"
#include <cstdio>

/// CUDA kernel function for vector addition (dst = srcA + srcB)
\_\_global\_\_ void vectorAdd(float \*const dst, const float \*const srcA, const float \*const srcB, int numElements) {
  int i \= blockDim.x \* blockIdx.x + threadIdx.x;
  if (i < numElements) dst\[i\] \= srcA\[i\] + srcB\[i\];
}

int main(void) {
  // Allocate & initialise host (CPU) & device (GPU) memory
  const int numElements \= 1337;
  float \*srcA;
  cudaMallocManaged((void \*\*)&srcA, numElements);
  for(int i\=0; i<numElements; ++i) srcA\[i\] \= i;
  cudaDeviceSynchronize();
  // ...

  // Launch the vectorAdd kernel
  const int threadsPerBlock \= 256;
  const int blocksPerGrid \= (numElements + threadsPerBlock \- 1) / threadsPerBlock;
  vectorAdd<<<blocksPerGrid, threadsPerBlock\>>>(dst, srcA, srcB, numElements);
  cudaDeviceSynchronize();

  // clean up memory
  cudaFree((void \*)a);
  // ...
}
```


In this example, `srcA`, `srcB`, and `dst` are memory pointers to linear vectors (of size `numElements`). Note that the CUDA compiler automatically converts these to host (CPU) or device (GPU) memory pointers (and copies data between host & device) when appropriate. The `vectorAdd` “kernel” (GPU function) is launched with `blocksPerGrid` blocks, each containing `threadsPerBlock` threads. Each thread computes the sum of one pair of elements from `srcA` and `srcB`, and stores the result in `dst`.

High-level wrappers

Note that wrappers for other programming languages exists (e.g. [Python](https://developer.nvidia.com/how-to-cuda-python)), allowing control of CUDA GPUs while writing code in more concise & user-friendly languages.

#### Vulkan[#](#vulkan "Permalink to this heading")

Vulkan is a low-level graphics and compute API developed by the Khronos Group. It provides fine-grained control over the GPU and is designed to minimise CPU overhead and provide more consistent performance. Vulkan can be used for a variety of applications, including gaming, simulation, and scientific computing.

Vulkan is supported on a wide variety of platforms, including Windows, Linux, macOS (via MoltenVK, a Vulkan implementation that runs on top of Metal), Android, and iOS. Vulkan has a somewhat steep learning curve because it is a very low-level API, but it provides a lot of flexibility and can lead to very high performance.

### AMD GPUs[#](#amd-gpus "Permalink to this heading")

For AMD GPUs, you can use the ROCm (Radeon Open Compute) platform, which is an open-source software platform for GPU-enabled HPC (High-Performance Computing) and machine learning applications.

Here are the main components of the ROCm platform:

1.  **ROCm Runtime**: This is the core of the ROCm platform. It includes the ROCr System Runtime, which is a user-space system runtime for managing GPU applications, and the ROCt Thunk Interface, which provides a low-level interface to the GPU kernel driver.
    
2.  **ROCm Driver**: This is the kernel driver for AMD GPUs. It includes the AMDGPU driver, which is the open-source kernel driver for AMD Radeon graphics cards.
    
3.  **ROCm Libraries**: These are a set of libraries optimised for AMD GPUs. They include rocBLAS for basic linear algebra, rocFFT for fast Fourier transforms, and rocRAND for random number generation.
    
4.  **ROCm Tools**: These are a set of tools for developing and debugging applications on AMD GPUs. They include the ROCm SMI (System Management Interface) for monitoring and managing GPU resources, and the ROCgdb debugger for debugging GPU applications.
    

To develop applications for AMD GPUs using the ROCm platform, you will need to:

1.  **Install the necessary software**: This includes the ROCm platform, and any other libraries or tools you need.
    
2.  **Write your code**: You can use the HIP programming language, which is a C++ runtime API and kernel language that allows you to write portable GPU code that can run on both AMD and NVIDIA GPUs. HIP code can be compiled to run on AMD GPUs using the HIP-Clang compiler, or on NVIDIA GPUs using the NVCC compiler.
    
3.  **Compile your code**: Use the HIP-Clang compiler to compile your code for AMD GPUs, or the NVCC compiler for NVIDIA GPUs.
    
4.  **Run your code**: Run your compiled code on an AMD or NVIDIA GPU.
    

For example, here is a simple HIP program that adds two vectors:


```
#include "hip/hip\_runtime.h"
#include <cstdio>

/// HIP kernel function for vector addition (dst = srcA + srcB)
\_\_global\_\_ void vectorAdd(float \*const dst, const float \*const srcA, const float \*const srcB, int numElements) {
  int i \= blockDim.x \* blockIdx.x + threadIdx.x;
  if (i < numElements) dst\[i\] \= srcA\[i\] + srcB\[i\];
}

int main(void) {
  // Allocate and initialise host (CPU) & device (GPU) memory
  // ...

  // Launch the vectorAdd kernel
  const int threadsPerBlock \= 256;
  const int blocksPerGrid \= (numElements + threadsPerBlock \- 1) / threadsPerBlock;
  hipLaunchKernelGGL(
    vectorAdd, dim3(blocksPerGrid), dim3(threadsPerBlock), 0, 0, dst, srcA, srcB, numElements);

  // Copy result from device to host & clean up memory
  // ...
}
```


In this example, `d_A`, `d_B`, and `d_C` are pointers to device memory, and `numElements` is the number of elements in each vector. The `vectorAdd` kernel is launched with `blocksPerGrid` blocks, each containing `threadsPerBlock` threads. Each thread computes the sum of one pair of elements from `d_A` and `d_B`, and stores the result in `d_C`.

Note that this example is very similar to the CUDA example I provided earlier. This is because the HIP programming language is designed to be similar to CUDA, which makes it easier to port CUDA code to run on AMD GPUs.

### Apple Silicon GPUs[#](#apple-silicon-gpus "Permalink to this heading")

#### Metal[#](#metal "Permalink to this heading")

Apple Silicon GPUs, which are part of Apple’s custom M1 chip, can be programmed using the Metal framework. Metal is a graphics and compute API developed by Apple, and it’s available on all Apple devices, including Macs, iPhones, and iPads.

Here are the main components of the Metal framework:

1.  **Metal API**: This is a low-level API that provides access to the GPU. It includes functions for creating and managing GPU resources, compiling shaders, and submitting work to the GPU.
    
2.  **Metal Shading Language (MSL)**: This is the programming language used to write GPU code (shaders) in Metal. It is based on the C++14 programming language and includes some additional features and keywords for GPU programming.
    
3.  **MetalKit and Metal Performance Shaders (MPS)**: These are higher-level frameworks built on top of Metal. MetalKit provides functions for managing textures, meshes, and other graphics resources, while MPS provides highly optimised functions for common image processing and machine learning tasks.
    

Here is a basic workflow for using Metal to perform GPU computations on Apple Silicon:

1.  **Install the necessary software**: This includes the Xcode development environment, which includes the Metal framework and compiler.
    
2.  **Write your code**: Write your GPU code using the Metal Shading Language, and your host code using Swift or Objective-C. Your host code will use the Metal API to manage GPU resources and submit work to the GPU.
    
3.  **Compile your code**: Use the Xcode development environment to compile your code.
    
4.  **Run your code**: Run your compiled code on an Apple device with an Apple Silicon GPU.
    

For example, here is a simple Metal program that adds two vectors:

```
import Metal

// Create a Metal device and command queue
let device \= MTLCreateSystemDefaultDevice()!
let commandQueue \= device.makeCommandQueue()!

// Create a Metal library and function
let library \= device.makeDefaultLibrary()!
let function \= library.makeFunction(name: "vector\_add")!

// Create a Metal compute pipeline
let pipeline \= try! device.makeComputePipelineState(function: function)

// Allocate and initialise host and device memory
let numElements \= 1024
let bufferSize \= numElements \* MemoryLayout<Float\>.size
let h\_A \= \[Float\](repeating: 1.0, count: numElements)
let h\_B \= \[Float\](repeating: 2.0, count: numElements)
let d\_A \= device.makeBuffer(bytes: h\_A, length: bufferSize, options: \[\])!
let d\_B \= device.makeBuffer(bytes: h\_B, length: bufferSize, options: \[\])!
let d\_C \= device.makeBuffer(length: bufferSize, options: \[\])!

// Create a Metal command buffer and encoder
let commandBuffer \= commandQueue.makeCommandBuffer()!
let commandEncoder \= commandBuffer.makeComputeCommandEncoder()!

// Set the compute pipeline and buffers
commandEncoder.setComputePipelineState(pipeline)
commandEncoder.setBuffer(d\_A, offset: 0, index: 0)
commandEncoder.setBuffer(d\_B, offset: 0, index: 1)
commandEncoder.setBuffer(d\_C, offset: 0, index: 2)

// Dispatch the compute kernel
let threadsPerThreadgroup \= MTLSize(width: 256, height: 1, depth: 1)
let numThreadgroups \= MTLSize(width: (numElements + 255) / 256, height: 1, depth: 1)
commandEncoder.dispatchThreadgroups(numThreadgroups, threadsPerThreadgroup: threadsPerThreadgroup)

// End the command encoder and commit the command buffer
commandEncoder.endEncoding()
commandBuffer.commit()

// Wait for the command buffer to complete
commandBuffer.waitUntilCompleted()

// Copy the result from device to host
let h\_C \= UnsafeMutablePointer<Float\>.allocate(capacity: numElements)
d\_C.contents().copyMemory(to: h\_C, byteCount: bufferSize)

// ...
// Clean up
// ...
```

In this example, `d_A`, `d_B`, and `d_C` are Metal buffers, and `numElements` is the number of elements in each vector. The `vector_add` function is a Metal shader written in the Metal Shading Language, and it is executed on the GPU using a Metal compute command encoder.

Note that this example is written in Swift, which is the recommended programming language for developing Metal applications. You can also use Objective-C, but Swift is generally preferred for new development.

This example is quite a bit more complex than the earlier CUDA and HIP examples, because Metal is a lower-level API that provides more fine-grained control over the GPU. This can lead to more efficient code, but it also requires more boilerplate code to set up and manage GPU resources.

#### Metal Performance Shaders (MPS)[#](#metal-performance-shaders-mps "Permalink to this heading")

**Metal Performance Shaders (MPS)** is a framework that provides highly optimised functions for common image processing and machine learning tasks. MPS is built on top of the Metal framework and is available on all Apple devices, including Macs, iPhones, and iPads.

MPS includes a variety of functions for image processing (e.g., convolution, resizing, and histogram calculation), as well as a set of neural network layers (e.g., convolution, pooling, and normalisation) that can be used to build and run neural networks on the GPU.

MPS is a higher-level API than Metal, which makes it easier to use, but it provides less flexibility. If you are developing an application for Apple devices and you need to perform image processing or machine learning tasks, MPS is a good place to start.

### Cross Platform Graphics APIs[#](#cross-platform-graphics-apis "Permalink to this heading")

#### Vulkan[#](#id2 "Permalink to this heading")

**Vulkan**（炼狱火）是由`Khronos Group`开发的`低级别`**图形**和**计算**API。它提供对GPU的精细控制，并旨在最大程度减少CPU开销并提供更一致的性能。Vulkan可用于各种应用，包括游戏、模拟和科学计算。

Vulkan支持多种平台，包括Windows、Linux、macOS（通过MoltenVK，在Metal之上运行的Vulkan实现）、Android和iOS。Vulkan有一定的学习曲线，因为它是一个非常底层的API，但它提供了很多灵活性，并能实现非常高的性能。

Vulkan被设计为跨平台API。它支持多种平台，包括Windows、Linux、macOS（通过`MoltenVK`，将`Vulkan`映射到`Metal`）、Android和iOS。这使其成为开发需要在多个平台上运行的应用程序的良好选择。




#### OpenGL[#](#opengl "Permalink to this heading")


**OpenGL** 是由`Khronos Group`开发的`跨平台`图形API。它被广泛用于开发`图形应用程序`，包括游戏、模拟和设计工具。相比Vulkan，OpenGL是一个`更高级的API`，更`易于使用`，但对GPU的控制较少，可能有更多的CPU开销。

OpenGL支持多种平台，包括Windows、macOS、Linux和Android。但是，苹果已经弃用了OpenGL，转而支持Metal，因此如果您要为苹果设备开发应用程序，建议使用Metal而不是OpenGL。

每种API都有其优势和劣势，最适合使用的取决于您的具体应用和需求。

1. 如果您正在开发`跨平台应用`程序并需要一个`低级别的API`，则`Vulkan`是一个不错的选择。
2. 如果您正在为`苹果设备`开发应用程序并需要进行图像处理或机器学习任务，则`MPS`是一个不错的选择。
3. 如果您正在开发图形应用程序，并需要一个`更高级的API`，则`OpenGL`可能是一个不错的选择，尽管在苹果设备上您应考虑使用Metal。

#### DirectX[#](#directx "Permalink to this heading")

**DirectX** 是一套处理与多媒体、游戏编程和视频相关任务的API集合，适用于微软平台。

* 虽然它通常与Windows关联最紧密，但也适用于Xbox。
* 需要注意的是，DirectX并`非完全跨平台`，不支持macOS或Linux。

#### OpenCL[#](#opencl "Permalink to this heading")

**OpenCL** 是一个编写程序的`框架`，能在由CPU、GPU和其他处理器组成的异构平台上执行。

1. OpenCL包括一种`语言`（基于`C99`），用于编写`内核`（即在硬件设备上运行的函数），以及用于定义和控制平台的API。
2. OpenCL利用基于`任务`和`数据`的`并行性`提供并行计算。


#### WebGL and WebGPU[#](#webgl-and-webgpu "Permalink to this heading")

**WebGL**是一个基于`OpenGL ES`的网络图形API，可以在Web浏览器中创建3D图形。由于它是基于Web的，因此支持所有主要平台和Web浏览器。与此相反，**WebGPU**是由W3C GPU for the Web社区组开发的新型基于Web的图形和计算API。它旨在为Web浏览器提供现代的3D图形和计算功能，并且意图取代WebGL。

WebGPU旨在提供比WebGL更现代和更低级的API，这将带来更好的性能和更大的灵活性。它被设计为一种Web友好的API，可以在其他图形API（如Vulkan、Metal和DirectX）之上实现。

WebGPU仍在开发中，在Web浏览器中的支持尚不广泛。但是，对于需要高性能图形或计算的Web应用程序开发者而言，这是一个令人兴奋的发展，值得关注。

WebGPU将是一个跨平台的API，因为它将在多个平台的Web浏览器中得到支持。但是，WebGPU在浏览器中的实际实现可能会使用不同的底层图形API，这取决于平台。例如，在Windows上的浏览器可能会使用基于DirectX的WebGPU实现，而在macOS上的浏览器可能会使用基于Metal的实现。这对应用程序开发者来说是透明的，他们只需要使用WebGPU API。


### Benchmarks[#](#benchmarks "Permalink to this heading")

Work in Progress

Table with benchmarks

### Acceleration Libraries[#](#acceleration-libraries "Permalink to this heading")

+   **OpenBLAS**
    
+   **CuBLAS**
    
+   **cuDNN**
    
+   **OpenCL**
    

## Cloud[#](#cloud "Permalink to this heading")

+   cost comparisons
    
    +   user-friendly: [https://fullstackdeeplearning.com/cloud-gpus](https://fullstackdeeplearning.com/cloud-gpus)
        
    +   less user-friendly but more comprehensive: [https://cloud-gpus.com](https://cloud-gpus.com)
        
    +   LLM-specific advice: [https://gpus.llm-utils.org/cloud-gpu-guide/#which-gpu-cloud-should-i-use](https://gpus.llm-utils.org/cloud-gpu-guide/#which-gpu-cloud-should-i-use)
        

## Future[#](#future "Permalink to this heading")

当前使用大型语言模型（LLMs）的一个问题是其对`GPU内存`的需求很高。一个流行的解决方法是**量化**（`quantisation`）。

1. 然而，这需要硬件制造商构建支持量化操作的（`SIMD`指令集），
2. 以及**机器学习库**重写/重新实现`核心代码`部分以支持这些新操作。

同时要记住，基于`CPU`的`SIMD`指令集（例如PC的SSE4和AVX10，移动设备的NEON）花费了很多年时间进行开发，并且仍在积极发展中。相比之下，GPU架构的采用和发展要少得多，因此新的算术操作将需要很多年才能得到广泛支持。


> SIMD， Single Instruction, Multiple Data ， 单指令多数据（`SIMD`）是一种`数据级``并行`处理技术，其中`一条计算指令`同时应用于`多个数据`。
> 
> quantisation， 量化，Sacrificing precision，牺牲精度（例如，使用 uint8 而不是 float32）以换取更低的硬件内存需求。






















[NingG]:    http://ningg.github.io  "NingG"
[premAI]:		https://book.premai.io/state-of-open-source-ai/








