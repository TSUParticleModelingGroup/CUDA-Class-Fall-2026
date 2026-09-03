// nvcc BlockandGridSizeTest.cu -o temp
// You can set the block and grid size and see if it throws an error. 
// If it works you will get the quote about Faith, Hope and Love.

// Include files
#include <stdio.h>

// Defines

// Global variables
dim3 BlockSize; //This variable will hold the Dimensions of your blocks
dim3 GridSize; //This variable will hold the Dimensions of your grid

// Function prototypes
void setUpDevices();
__global__ void testGPUBlockAndGridSize();
void cudaErrorCheck(const char*, int);

// This will be the layout of the parallel space we will be using.
void setUpDevices()
{
	BlockSize.x = 1024;
	BlockSize.y = 1;
	BlockSize.z = 1;
	
	GridSize.x = 20;
	GridSize.y = 1;
	GridSize.z = 1;
}

// This is the kernel. It is the function that will run on the GPU.
__global__ void testGPUBlockAndGridSize()
{
	int id = threadIdx.x + blockIdx.x;
	
	if(id == 0)
	{
		printf("\n For now we see only a reflection as in a mirror;\n then we shall see face to face. Now I know in part;\n then I shall know fully, even as I am fully known.\n And now these three remain: faith, hope and love.\n But the greatest of these is love.\n");
	}
}

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

int main()
{	
	setUpDevices();
	testGPUBlockAndGridSize<<<GridSize,BlockSize>>>();
	cudaErrorCheck(__FILE__, __LINE__);
	
	cudaDeviceSynchronize(); // Remove this sync and explain what is going on!	
	
	// Making sure it flushes out anything in the print buffer.
	printf("\n Your program has finished!\n\n");
	
	return(0);
}

