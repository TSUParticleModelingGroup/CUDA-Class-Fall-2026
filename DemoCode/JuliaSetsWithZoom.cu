//nvcc JuliaSetsWithZoom.cu -o JuliaWithZoom -lglut -lGL -lm
#include <GL/glut.h>
#include <math.h>
#include <stdio.h>

#define NO 0
#define YES 1

#define DRAW_GRID 1000
#define X_GRID 100
#define Y_GRID 100
#define MAX_SLOPE 1000

#define X_WINDOW 600
#define Y_WINDOW 600

#define X_MAX 2.5
#define X_MIN -2.5
#define X_SCALE 1.0

#define Y_MAX 2.5
#define Y_MIN -2.5
#define Y_SCALE 1.0

#define ITER_STOP 100

#define A (1.0)
#define B (0.0)

//#define A (0.75)
//#define B (0.0)

//#define A (0.85)
//#define B (0.18)

// globals
double x_world, y_world;
double g_x_max, g_x_min, g_y_max, g_y_min;
double g_x_box_l, g_x_box_r, g_y_box_t, g_y_box_b;
int g_mouse_1_2;

double f_real(double x, double y)
{
	return(x*x - y*y - A);
}

double f_img(double x, double y)
{
	return(2.0*x*y - B);
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
	range = g_x_max - g_x_min;
	return( (range/X_WINDOW)*x + g_x_min );
}

double y_machine_to_y_world(int y)
{
	double range;
	range = g_y_max - g_y_min;
	return(-((range/Y_WINDOW)*y - g_y_max));
}

double x_world_to_x_screen(double x)
{
	double range;
	range = g_x_max - g_x_min;
	return( -1.0 + 2.0*(x - g_x_min)/range );
}

double y_world_to_y_screen(double y)
{
	double range;
	range = g_y_max - g_y_min;
	return( -1.0 + 2.0*(y - g_y_min)/range );
}

int iterate_point(double x, double y)
{
	int k,escape;
	double x_old, y_old, x_new, y_new;

	x_old = x;
	y_old = y;
	k = 0;
	escape = NO;
	while(k<ITER_STOP && escape == NO)
	{
		x_new = f_real(x_old, y_old);
		y_new = f_img(x_old, y_old);

		if(sqrt(x_new*x_new + y_new*y_new) > 2.0) escape = YES;

		x_old = x_new;
		y_old = y_new;
		k++;
	}
	//printf("escape=%d\n",escape);
	if(escape == NO) k = 0;
	return(k);
}

void color_map()
{
	int i,j,k;
	int escape;
	double x_range,dx,y_range,dy;
	double dk,dshades,percent,shades;

	shades = 50.0;
	x_range = g_x_max - g_x_min;
	y_range = g_y_max - g_y_min;

	dx = x_range/DRAW_GRID;
	dy = y_range/DRAW_GRID;

	glPointSize(1.0);

	for(i=0; i<DRAW_GRID; i++)
	{
		for(j=0; j<DRAW_GRID; j++)
		{
			k = iterate_point(g_x_min + dx*i, g_y_min + dy*j);
			dk = k;
			dshades = 1.0/shades;

			escape = NO;
			if( k == 0) glColor3f(1.0,0.0,0.0);
			else
			{
				percent = 1.0;
				while(percent>=0 && escape == NO) 
				{
					if (dk >= percent*10) 
					{
						glColor3f(1.0-percent,1.0-percent,1.0);
						escape = YES;
					}
					percent = percent - dshades;
				}
				if(escape == NO) glColor3f(1.0,1.0,0.0);
			}

			glBegin(GL_POINTS);
				glVertex2f(x_world_to_x_screen(g_x_min + dx*i),y_world_to_y_screen(g_y_min + dy*j));
			glEnd();
		}
		glFlush();
	}
	//glFlush();
}

void print_dimentions()
{
	printf("x dim %f to %f range is %f \ny dim %f to %f range is %f\n\n", g_x_max, g_x_min, g_x_max - g_x_min, 
		  g_y_max, g_y_min, g_y_max - g_y_min);
}

void mymouse(int button, int state, int x_machine, int y_machine)
{	
	if(state == GLUT_DOWN)
	{
		x_world=x_machine_to_x_world(x_machine);
		y_world=y_machine_to_y_world(y_machine);
		if(button == GLUT_LEFT_BUTTON)
		{
			if(x_machine<=10 && y_machine <= 10)
			{
				glClear(GL_COLOR_BUFFER_BIT);
			}
			else
			{
				if(g_mouse_1_2 == 1)
				{
					g_x_box_l = x_world;
					g_y_box_t = y_world;
					g_mouse_1_2 = 2;
				}
				else if(g_mouse_1_2 == 2)
				{
					g_x_box_r = x_world;
					g_y_box_b = y_world;
		
					glColor3f(1.0,1.0,1.0);
					glBegin(GL_LINE_LOOP);
						glVertex2f(x_world_to_x_screen(g_x_box_l),y_world_to_y_screen(g_y_box_t));
						glVertex2f(x_world_to_x_screen(g_x_box_r),y_world_to_y_screen(g_y_box_t));
						glVertex2f(x_world_to_x_screen(g_x_box_r),y_world_to_y_screen(g_y_box_b));
						glVertex2f(x_world_to_x_screen(g_x_box_l),y_world_to_y_screen(g_y_box_b));
					glEnd();
					g_mouse_1_2 = 1;
				}

				glFlush();
			}
		}
		else if(button == GLUT_RIGHT_BUTTON)
		{
			g_x_max = g_x_box_r;
			g_x_min = g_x_box_l;
			g_y_max = g_y_box_t;
			g_y_min = g_y_box_b;

			print_dimentions();

			glClear(GL_COLOR_BUFFER_BIT);
			color_map();
		}
	}
}

void display()
{
	glClear(GL_COLOR_BUFFER_BIT);

	g_x_max = X_MAX;
	g_x_min = X_MIN;

	g_y_max = Y_MAX;
	g_y_min = Y_MIN;

	print_dimentions();

	color_map();

	g_mouse_1_2 = 1;

	glutMouseFunc(mymouse);
}

int main(int argc, char** argv)
{
	glutInit(&argc,argv);
	glutInitWindowSize(X_WINDOW,Y_WINDOW);
	glutInitWindowPosition(0,0);
	glutCreateWindow("BOX");
	glutDisplayFunc(display);
	glutMainLoop();
}

