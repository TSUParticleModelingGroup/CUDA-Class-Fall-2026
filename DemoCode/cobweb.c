//gcc cobweb.c -o cobweb -lglut -lm -lGLU -lGL
#include <GL/glut.h>
#include <math.h>
#include <stdio.h>
//#include <device.h>

#define SCALE 4.0

#define X_WINDOW 600
#define Y_WINDOW 600

#define X_MAX SCALE
#define X_MIN -SCALE
#define X_SCALE 1.0

#define Y_MAX SCALE
#define Y_MIN -SCALE
#define Y_SCALE 1.0

// function prototypes
void KeyPressed(unsigned char key, int x, int y);
void Display(void);

//globals
double g_x;
double g_y;
static int g_win;
int g_funCompNum = 1;

double f(double x)
{
	//return(1.0 - x*x);
	//return(0.1*x*x +10.0);
	//return(1.0*cos(x));
	
	//return(1.325*(1-x*x));
	//return(1.325*(1-((1.325*(1-x*x))*(1.325*(1-x*x)))));
	//return(1.325*(1-(1.325*(1-((1.325*(1-x*x))*(1.325*(1-x*x)))))*(1.325*(1-((1.325*(1-x*x))*(1.325*(1-x*x)))))));

	return(x*x - 2.0);
	//return(x*x*x*x-4.0*x*x+2.0; // This is a two cycle for x^2-2.
	return(x*x*x*x*x*x*x*x-8.0*x*x*x*x*x*x+20.0*x*x*x*x-16.0*x*x+2.0; // This is a three cycle for x^2-2.
	//return(sin(x));
	//return(1.0/x);
	//return(pow(x, 3.0/2.0);
}

double x_machine_to_x_screen(int x)
{
	return( (2.0*x)/X_WINDOW-1.0 );
}

double y_machine_to_y_screen(int y)
{
	return( -(2.0*y)/Y_WINDOW+1.0 );
}

double x_machine_to_x_world(int x)
{
	double range;
	range = X_MAX - X_MIN;
	return( (range/X_WINDOW)*x + X_MIN);
}

double y_machine_to_y_world(int y)
{
	double range;
	range = Y_MAX - Y_MIN;
	return(-((range/Y_WINDOW)*y - X_MAX));
}

double x_world_to_x_screen(double x)
{
	double range;
	range = X_MAX - X_MIN;
	return( -1.0 + 2.0*(x - X_MIN)/range );
}

double y_world_to_y_screen(double y)
{
	double range;
	range = Y_MAX - Y_MIN;
	return( -1.0 + 2.0*(y - Y_MIN)/range );
}

void place_axis()
{
	glColor3f(1.0,1.0,1.0);

	glBegin(GL_LINE_LOOP);
		glVertex2f(x_world_to_x_screen(X_MIN),y_world_to_y_screen(0.0));
		glVertex2f(x_world_to_x_screen(X_MAX),y_world_to_y_screen(0.0));
	glEnd();
	
	glBegin(GL_LINE_LOOP);
		glVertex2f(x_world_to_x_screen(0.0),y_world_to_y_screen(Y_MIN));
		glVertex2f(x_world_to_x_screen(0.0),y_world_to_y_screen(Y_MAX));
	glEnd();

	glFlush();
}

void drawFunction()
{
	double x, dx;
	
	dx = (X_MAX - X_MIN)/1000.0;
	x = X_MIN;
	while(x < X_MAX)
	{
		glBegin(GL_LINE_LOOP);
			glVertex2f(x_world_to_x_screen(x),y_world_to_y_screen(f(x)));
			glVertex2f(x_world_to_x_screen(x+dx),y_world_to_y_screen(f(x+dx)));
		glEnd();
		x += dx;
	}
	glFlush();
}

void draw45DegreeLine()
{
	glColor3f(1.0,1.0,0.0);
	glBegin(GL_LINE_LOOP);
		glVertex2f(x_world_to_x_screen(X_MIN),y_world_to_y_screen(1.0*X_MIN + 0.0));
		glVertex2f(x_world_to_x_screen(X_MAX),y_world_to_y_screen(1.0*X_MAX + 0.0));
	glEnd();

	glFlush();
}

void drawLineVertical()
{
	double yOld;
	yOld = g_y;
	g_y = f(g_x);
	
	glColor3f(1.0,0.0,0.0);
	glBegin(GL_LINE_LOOP);
		glVertex2f(x_world_to_x_screen(g_x),y_world_to_y_screen(yOld));
		glVertex2f(x_world_to_x_screen(g_x),y_world_to_y_screen(g_y));
	glEnd();

	glFlush();
}

void drawLineHorizontal()
{
	double xOld;
	xOld = g_x;
	g_x = g_y;
	
	glColor3f(1.0,1.0,0.0);
	glBegin(GL_LINE_LOOP);
		glVertex2f(x_world_to_x_screen(xOld),y_world_to_y_screen(g_y));
		glVertex2f(x_world_to_x_screen(g_x),y_world_to_y_screen(g_y));
	glEnd();
	glFlush();
}

void placePoint(double x)
{
	glPointSize(3.0);
	glColor3f(1.0,0.0,0.0);
	glBegin(GL_POINTS);
		glVertex2f(x_world_to_x_screen(x),y_world_to_y_screen(0.0));
	glEnd();
	glFlush();
}

void printPoint()
{
	printf("\nx = %f\n",g_x);
}

void mymouse(int button, int state, int x, int y)
{	
	if(state == GLUT_DOWN)
	{
		if(button == GLUT_LEFT_BUTTON)
		{
			if(x<=10 && y <= 10)
			{
				glClear(GL_COLOR_BUFFER_BIT);
				place_axis();
				glColor3f(0.0,1.0,0.0);
				drawFunction();
				draw45DegreeLine();
			}
			else
			{
				glColor3f(1.0,1.0,0.0);
				g_x = x_machine_to_x_world(x);
				g_y = 0.0;
				placePoint(g_x);
				printPoint();
			}
		}
		else
		{
			drawLineVertical();
			drawLineHorizontal();
			printPoint();
		}
	}
}

void KeyPressed(unsigned char key, int x, int y)
{
	float tempx;
	int n;

	if(key == 'q')
	{
		glutDestroyWindow(g_win);
		exit(0);
	}
	if(key == 'p')
	{
		printf("\nInter start x value\n");
		scanf("%f", &tempx);
		g_x = tempx;
		
		glColor3f(1.0,0.0,0.0);
		placePoint(g_x);
		printPoint();
	}
}

void display()
{
	glClear(GL_COLOR_BUFFER_BIT);
	place_axis();
	glColor3f(0.0,1.0,0.0);
	drawFunction();
	draw45DegreeLine();
	glutMouseFunc(mymouse);
}

void main(int argc, char** argv)
{
	glutInit(&argc,argv);
	glutInitWindowSize(X_WINDOW,Y_WINDOW);
	glutInitWindowPosition(0,0);
	g_win = glutCreateWindow("COBWEB");
	glutKeyboardFunc(KeyPressed);
	glutDisplayFunc(display);
	glutMainLoop();
}
