//Playing around with pointers
//nvcc Pointers.cu -o Pointers
#include <stdio.h>

int main()
{
	//float *a;
	float b;
	float c[2];
	float *d;
	
	d = (float*)malloc(5*sizeof(float));
	
	printf("\n");
	//printf("a = %p, *a = %f\n", a, *a);
	printf("&b = %p, b = %f\n", &b, b);
	printf("c = %p, c[0] = %f, c[1] = %f\n", c, c[0], c[1]);
	printf("d = %p, d[0] = %f, d[1] = %f\n", d, d[0], d[1]);
	
	//*a = 6;
	b = 7;
	c[0] = 8;
	d[0] = 9;
	c[1] = 10;
	d[1] = 11;
	
	printf("\n");
	//printf("a = %p, *a = %f\n", a, *a);
	printf("&b = %p, b = %f\n", &b, b);
	printf("c = %p, c[0] = %f, c[1] = %f\n", c, c[0], c[1]);
	printf("d = %p, d[0] = %f, d[1] = %f\n", d, d[0], d[1]);
	
	
	d = c;
	printf("\n");
	printf("c = %p, c[0] = %f, c[1] = %f\n", c, c[0], c[1]);
	printf("d = %p, d[0] = %f, d[1] = %f\n", d, d[0], d[1]);
	
	
	d = &b;
	printf("\n");
	printf("&b = %p, b = %f\n", &b, b);
	printf("d = %p, d[0] = %f, d[1] = %f\n", d, d[0], d[1]);
	
	return(0);
}
