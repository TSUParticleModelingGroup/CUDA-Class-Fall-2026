//nvcc VariableDemo.cu -o temp

// temp1 is a normal local variable. It gets reset every time the function is called.

// temp2 is a static local variable. It gets set the first time the function is call but is remembered and not
// reset in subsaquent calls.

// temp3 is a global variable. The static variable acts like a global but can not be seen from other functions

#include <stdio.h>
int temp3 = 0;
volatile int buttonPressed = 0;
void incrementNumber()
{
	int temp1 = 0;
	static int temp2 = 0; // Acts like a global but is local. Can be safer because no other function can change it.
	// extern int temp4; // Defined as a global in another file.
	//  
	temp1++;
	temp2++;
	temp3++;
	printf(" temp1 = %d \n", temp1);
	printf(" temp2 = %d \n", temp2);
	printf(" temp3 = %d \n", temp3);
}

int main()
{
	incrementNumber();
	incrementNumber();
	incrementNumber();
	incrementNumber();
	return 0;
}


// https://www.youtube.com/watch?v=ZLhnZAbcs2s
