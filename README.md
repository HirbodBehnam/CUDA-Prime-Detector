# CUDA Prime Detector
A really messy prime detector for NVidia Graphic cards written in CUDA

## What?
This is just a SIMPLE program to check if a number is prime or not with GPU not CPU.

## How to run and download?
You can download pre-compiled executable at [releases](https://github.com/HirbodBehnam/CUDA-Prime-Detector/releases). After downloading you should run it like this:
```
"CUDA Prime Detector.exe" Number_To_Check
```
Example:
```
"CUDA Prime Detector.exe" 3243453587
```
### Compiling
You can download this project and compile it with visual studio and CUDA Toolkit. I build it with VS 2017 and CUDA 10.1. Older version must be suppored as well.

On linux operating system you should compile `kernel.cu` file directly.

## Benchmarks
I will benchmark more later but for now I benchmarked `18412419945067315561` that is `4290969581 * 4290969581`.

CPU, i7-4790k, 8 Cores, 4.0 GHz (Multicore): 15.291 secs

GPU, GTX 1070 EVGA Super clocked (Not overclocked): 0.409 secs
