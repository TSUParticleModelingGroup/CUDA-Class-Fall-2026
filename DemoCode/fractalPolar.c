//gcc fractalPolar.c -o fractalPolar -lglut -lm -lGLU -lGL
#include <GL/glut.h>
#include <math.h>
#include <stdio.h>
//#include <device.h>

#define SCALE 5.0

#define X_WINDOW 700
#define Y_WINDOW 700

#define X_MAX 2.0
#define X_MIN 0.0
#define X_SCALE 1.0

#define Y_MAX 2.0
#define Y_MIN 0.0
#define Y_SCALE 1.0

#define T_START 0.0
#define T_STOP 56.3

// function prototypes
void KeyPressed(unsigned char key, int x, int y);
void Display(void);
void iterateFractal(double x, double y, int n);
void generatePoints();

//globals
double g_x;
double g_y;
static int g_win;
int g_funCompNum = 0;

double rootObject(double angle)
{
	//return(sin(2.0*angle));
	return(sin(8.0*angle/5.0)); //take time to 50+
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

void placePoint(double x, double y)
{
	glPointSize(1.0);
	glColor3f(225.0/256.0,105.0/256.0,180.0/256.0);
	glBegin(GL_POINTS);
		glVertex2f(x_world_to_x_screen(x),y_world_to_y_screen(y));
	glEnd();
	glFlush();
}

void modifyObject1(double x, double y, int n)
{
	if(n == 0) placePoint(x, y);
	else
	{
		x = x/2.0;
		y = y/2.0;
		n--;
		iterateFractal(x, y, n);
	}
}

void modifyObject2(double x, double y, int n)
{
	if(n == 0) placePoint(x, y);
	else
	{
		x = x/2.0 + 1.0;
		y = y/2.0;
		n--;
		iterateFractal(x, y, n);
	}
}

void modifyObject3(double x, double y, int n)
{
	if(n == 0) placePoint(x, y);
	else
	{
		x = x/2.0 + 0.5;
		y = y/2.0 + 1.0;
		n--;
		iterateFractal(x, y, n);
	}
}

void iterateFractal(double x, double y, int n)
{
	modifyObject1(x,y,n);
	modifyObject2(x,y,n);
	modifyObject3(x,y,n);
}

void generatePoints()
{
	double angle, dt;
	double r,x,y;
	
	dt = (T_STOP - T_START)/1000.0;
	angle = T_START;
	while(angle < T_STOP)
	{
		r = rootObject(angle);
		x = r*cos(angle) + 1.0;
		y = r*sin(angle) + 1.0;
		iterateFractal(x, y, g_funCompNum);
		angle += dt;
		glFlush();
	}
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
				glColor3f(1.0,0.0,0.0);
				generatePoints();
			}
			else
			{
				glClear(GL_COLOR_BUFFER_BIT);
				g_funCompNum++;
				glColor3f(0.0,1.0,0.0);
				generatePoints();
			}
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
}

void display()
{
	glClear(GL_COLOR_BUFFER_BIT);
	place_axis();
	glColor3f(1.0,0.0,0.0);
	generatePoints();
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
