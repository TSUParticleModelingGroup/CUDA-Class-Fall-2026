// Name:
// Ray tracing
// nvcc K_RayTracerWithConstantMemory.cu -o temp -lglut -lGL -lm

/*
 What to do:
 This program creates a random set of spheres and uses ray tracing to render an image of them 
 to be displayed on the screen. In the scene, positive X is to the right, positive Y is up, and 
 positive Z comes out of the screen toward the viewer.

 All the spheres are located within a 2x2x2 cube, and you observe them through a 2x2 viewing window.
 
 Your mission, should you choose to accept it:
 1. The spheres created on the CPU do not change, so transfer them to the GPU and store them in constant memory.
 2. Use CUDA events to time your code execution.
*/

/*
 Purpose:
 To learn how to use constant memory and CUDA events.
*/

/*
 Explain what you did to fix the code:
 
*/

// Include files
#include <GL/glut.h>
#include <stdlib.h>
#include <stdio.h>
#include <math.h>
#include <time.h>
#include <sys/time.h>

// Defines
#define WINDOWWIDTH 1024
#define WINDOWHEIGHT 1024
#define XMIN -1.0f
#define XMAX 1.0f
#define YMIN -1.0f
#define YMAX 1.0f
#define ZMIN -1.0f
#define ZMAX 1.0f
#define NUMSPHERES 100
#define MAXRADIUS 0.2 // The biggest radius a sphere can have.

// Local structures
struct sphereStruct 
{
	float r,b,g; // Sphere color
	float radius;
	float x,y,z; // Sphere center
};

// Globals variables
static int Window;
unsigned int WindowWidth = WINDOWWIDTH;
unsigned int WindowHeight = WINDOWHEIGHT;
dim3 BlockSize, GridSize;
float *PixelsCPU, *PixelsGPU; 
sphereStruct *SpheresCPU, *SpheresGPU;

// Function prototypes
void cudaErrorCheck(const char *, int);
void Display();
void idle();
void KeyPressed(unsigned char , int , int );
__device__ float hit(float , float , float *, float , float , float , float );
__global__ void makeSphersBitMap(float *, sphereStruct *);
void makeRandomSpheres();
void makeBitMap();
void paintScreen();
void setup();

// This check to see if an error happened in your CUDA code. It tell you what it thinks went wrong,
// and what file and line it occured on.
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

void display()
{
	makeBitMap();	
}

void KeyPressed(unsigned char key, int x, int y)
{	
	if(key == 'q')
	{
		glutDestroyWindow(Window);
		
		// Free host memory.
		free(PixelsCPU); 
		free(SpheresCPU); 
	
		// Free divice memory.
		cudaFree(PixelsGPU); 
		cudaErrorCheck(__FILE__, __LINE__);
		cudaFree(SpheresGPU); 
		cudaErrorCheck(__FILE__, __LINE__);
		
		printf("\nw Good Bye\n");
		exit(0);
	}
}

__device__ float hit(float pixelx, float pixely, float *dimingValue, sphereStruct sphere)
{
	float dx = pixelx - sphere.x;  //Distance from ray to sphere center in x direction
	float dy = pixely - sphere.y;  //Distance from ray to sphere center in y direction
	float r2 = sphere.radius*sphere.radius;
	if(dx*dx + dy*dy < r2) // if the ray hits the sphere, then we need to find distance
	{
		float dz = sqrtf(r2 - dx*dx - dy*dy); // Distance from ray to edge of sphere?
		*dimingValue = dz/sphere.radius; // n is value between 0 and 1 used for darkening points near edge.
		return dz + sphere.z; //  Return the distance to be scaled by
	}
	return (ZMIN- 1.0); //If the ray doesn't hit anything return a number 1 unit behind the box.
}

__global__ void makeSphersBitMap(float *pixels, sphereStruct *sphereInfo)
{
	float stepSizeX = (XMAX - XMIN)/((float)WINDOWWIDTH - 1);
	float stepSizeY = (YMAX - YMIN)/((float)WINDOWHEIGHT - 1);
	
	// Asigning each thread a pixel
	float pixelx = XMIN + threadIdx.x*stepSizeX;
	float pixely = YMIN + blockIdx.x*stepSizeY;
	
	// Finding this pixels location in memory
	int id = 3*(threadIdx.x + blockIdx.x*blockDim.x);
	
	//initialize rgb values for each pixel to zero (black)
	float pixelr = 0.0f;
	float pixelg = 0.0f;
	float pixelb = 0.0f;
	float hitValue;
	float dimingValue;
	float maxHit = ZMIN -1.0f; // Initializing it to be 1 unit behind the box.
	for(int i = 0; i < NUMSPHERES; i++)
	{
		hitValue = hit(pixelx, pixely, &dimingValue, sphereInfo[i]);
		// do we hit any spheres? If so, how close are we to the center? (i.e. n)
		if(maxHit < hitValue)
		{
			// Setting the RGB value of the sphere but also diming it as it gets close to the side of the sphere.
			pixelr = sphereInfo[i].r * dimingValue; 	
			pixelg = sphereInfo[i].g * dimingValue;	
			pixelb = sphereInfo[i].b * dimingValue; 	
			maxHit = hitValue; // reset maxHit value to be the current closest sphere
		}
	}
	
	pixels[id] = pixelr;
	pixels[id+1] = pixelg;
	pixels[id+2] = pixelb;
}

void makeRandomSpheres()
{	
	float rangeX = XMAX - XMIN;
	float rangeY = YMAX - YMIN;
	float rangeZ = ZMAX - ZMIN;
	
	for(int i = 0; i < NUMSPHERES; i++)
	{
		SpheresCPU[i].x = (rangeX*(float)rand()/RAND_MAX) + XMIN;
		SpheresCPU[i].y = (rangeY*(float)rand()/RAND_MAX) + YMIN;
		SpheresCPU[i].z = (rangeZ*(float)rand()/RAND_MAX) + ZMIN;
		SpheresCPU[i].r = (float)rand()/RAND_MAX;
		SpheresCPU[i].g = (float)rand()/RAND_MAX;
		SpheresCPU[i].b = (float)rand()/RAND_MAX;
		SpheresCPU[i].radius = MAXRADIUS*(float)rand()/RAND_MAX;
	}
}	

void makeBitMap()
{	
	cudaMemcpy(SpheresGPU, SpheresCPU, NUMSPHERES*sizeof(sphereStruct), cudaMemcpyHostToDevice);
	cudaErrorCheck(__FILE__, __LINE__);
	
	makeSphersBitMap<<<GridSize, BlockSize>>>(PixelsGPU, SpheresGPU);
	cudaErrorCheck(__FILE__, __LINE__);
	
	cudaMemcpyAsync(PixelsCPU, PixelsGPU, WINDOWWIDTH*WINDOWHEIGHT*3*sizeof(float), cudaMemcpyDeviceToHost);
	cudaErrorCheck(__FILE__, __LINE__);
	
	paintScreen();
}

void paintScreen()
{
	//Putting pixels on the screen.
	glDrawPixels(WINDOWWIDTH, WINDOWHEIGHT, GL_RGB, GL_FLOAT, PixelsCPU); 
	glFlush();
}

void setup()
{
	//Allocating memory for the scene that will be displayed to the screen.
	//We need the 3 because each pixel has a red, green, and blue value.
	PixelsCPU = (float *)malloc(WINDOWWIDTH*WINDOWHEIGHT*3*sizeof(float));
	cudaMalloc(&PixelsGPU,WINDOWWIDTH*WINDOWHEIGHT*3*sizeof(float)); 
	cudaErrorCheck(__FILE__, __LINE__);
	
	//Allocating memory for the spheres that will create the scene.
	//This is what you will be changing out for constant memory.
	SpheresCPU= (sphereStruct*)malloc(NUMSPHERES*sizeof(sphereStruct));
	cudaMalloc(&SpheresGPU, NUMSPHERES*sizeof(sphereStruct));
	cudaErrorCheck(__FILE__, __LINE__);
	
	//Threads in a block
	if(WINDOWWIDTH > 1024) //To keep the code simple we make sure the scene width fits in a block.
	{
	 	printf("The window width is too large to run with this program\n");
	 	printf("The window width must be less than 1024.\n");
	 	printf("Good Bye and have a nice day!\n");
	 	exit(0);
	}
	BlockSize.x = WINDOWWIDTH;
	BlockSize.y = 1;
	BlockSize.z = 1;
	
	//Blocks in a grid
	GridSize.x = WINDOWHEIGHT;
	GridSize.y = 1;
	GridSize.z = 1;
	
	// Seeding the random number generator.
	time_t t;
	srand((unsigned) time(&t));
}

int main(int argc, char** argv)
{ 
	setup();
	makeRandomSpheres();
   	glutInit(&argc, argv);
	glutInitDisplayMode(GLUT_RGB | GLUT_SINGLE);
   	glutInitWindowSize(WINDOWWIDTH, WINDOWHEIGHT);
	Window = glutCreateWindow("Random Spheres");
	glutKeyboardFunc(KeyPressed);
   	glutDisplayFunc(display);
   	glutMainLoop();
}

