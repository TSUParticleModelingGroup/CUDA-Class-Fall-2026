// Error function test
// nvcc CudaErrorChecking.cu -o temp

// Include files
#include <stdio.h>

// Defines

// Global variables

// Function prototypes
void cudaErrorCheck(const char*, int);
__global__ void helloWorldCuda();

void cudaErrorCheck(const char *file, int line)
{
	cudaError_t  error;
	error = cudaGetLastError();

	if(error != cudaSuccess)
	{
		printf("\n CUDA ERROR: message = %s, File = %s, Line = %d\n", cudaGetErrorString(error), file, line);
		exit(0);
	}
}

__global__ void helloWorldCuda()
{
	int id = threadIdx.x + blockIdx.x*blockDim.x;
	
	if(id == 0) printf(" Sup dudes and dudets of the world\n");
}


int main()
{
	dim3 blockSize; //This variable will hold the Dimensions of your blocks
	dim3 gridSize; //This variable will hold the Dimensions of your grid

	blockSize.x = 2000;
	blockSize.y = 1;
	blockSize.z = 1;
	
	gridSize.x = 4;
	gridSize.y = 1;
	gridSize.z = 1;
	
	printf("\n");
	helloWorldCuda<<<gridSize,blockSize>>>();
	cudaErrorCheck(__FILE__, __LINE__);
	
	cudaDeviceSynchronize();
	printf("\n");
	
	return(0);
}

