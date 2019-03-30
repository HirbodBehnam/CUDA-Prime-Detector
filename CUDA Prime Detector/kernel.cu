#define MAX_TURN 1024 * 1024

#include "cuda_runtime.h"
#include "device_launch_parameters.h"

#include <ctime>
#include <iostream>
#include <cstdio>
#include <stdio.h>
#include <stdlib.h>

__global__ void runTest(unsigned long long *base,unsigned long long *number, unsigned long long *res)
{
	unsigned long long index = 5 + (*base + threadIdx.x + blockIdx.x * blockDim.x) * 6;
	if (*number % index == 0) 
		*res = index;
	index += 2;
	if (*number % index == 0) 
		*res = index;
}

int main(int argc, char *argv[])
{
	if(argc != 2)
	{
		printf("CUDA Prime Detector v1.0.1");
		printf("By Hirbod Behnam");
		printf("Source: https://github.com/HirbodBehnam/CUDA-Prime-Detector");
		printf("Usage: ProgramName.exe NUMBER_TO_TEST");
		return 2;
	}
	clock_t start = clock();//Benchmark
	const unsigned long long Number = strtoull(argv[1],nullptr,10);
	//At first check small primes
	if(Number == 2 || Number == 3 || Number == 5 || Number == 7)
	{
		std::cout << Number << " is PRIME.";
		return 0;
	}
	if(Number % 2 == 0)
	{
		std::cout << Number << " is NOT prime. It can be divided by 2";
		return 0;
	}
	if(Number % 3 == 0)
	{
		std::cout << Number << " is NOT prime. It can be divided by 3";
		return 0;
	}
	//Now check if number is smaller than MAX TURN; If it is compute it on CPU
	const unsigned long long TO = (unsigned long long) sqrtl((long double) Number);
	if(Number <= MAX_TURN * 6)
	{
		for(unsigned long long i = 5;i<= TO;i+=4)
		{
			if(Number % i == 0)
			{
				double elapsedTime = static_cast<double>(clock() - start) / CLOCKS_PER_SEC;
				std::cout << Number << " is NOT prime. It can be divided by "<< i<<std::endl;
				std::cout << "Calculated in " <<elapsedTime;
				return 0;
			}
			i+=2;
			if(Number % i == 0)
			{
				double elapsedTime = static_cast<double>(clock() - start) / CLOCKS_PER_SEC;
				std::cout << Number << " is NOT prime. It can be divided by "<< i <<std::endl;
				std::cout << "Calculated in " <<elapsedTime;
				return 0;
			}
		}
		std::cout << Number << " is PRIME.";
		return 0;
	}
	//Number is big enough to compute on GPU
	unsigned long long res = 0,base = 0,to = TO;
	unsigned long long *d_number, *d_res,*d_base;
	int size = sizeof(unsigned long long);
	cudaMalloc((void **)&d_number, size);
	cudaMalloc((void **)&d_res, size);
	cudaMalloc((void **)&d_base, size);
	cudaMemcpy(d_number, &Number, size, cudaMemcpyHostToDevice);
	while (to >= MAX_TURN)
	{
		cudaMemcpy(d_base, &base, size, cudaMemcpyHostToDevice);
		runTest <<<1024, 1024 >>> (d_base, d_number, d_res);
		cudaMemcpy(&res, d_res, size, cudaMemcpyDeviceToHost);
		if(res != 0)
			goto END;
		to -= MAX_TURN;
		base += MAX_TURN;
	}
	//Compute the rest
	while (base % 6 != 5)
		base++;
	for(;base <= TO;base += 4)
	{
		if(Number % base == 0)
		{
			res = base;
			goto END;
		}
		base+=2;
		if(Number % base == 0)
		{
			res = base;
			goto END;
		}
	}
END:
	double elapsedTime = static_cast<double>(clock() - start) / CLOCKS_PER_SEC;
	cudaFree(d_base);
	cudaFree(d_res);
	cudaFree(d_number);
	if (res == 0 || res == 1) 
		std::cout << Number << " is PRIME." <<std::endl;
	else 
		std::cout << Number << " is NOT prime. It can be divided by "<< res <<std::endl;
	std::cout << "Calculated in " <<elapsedTime;
    return 0;
}
