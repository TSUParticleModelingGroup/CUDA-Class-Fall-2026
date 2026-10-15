// Name:
// Two body problem
// nvcc R_TwoBodyToNBodyCPU.cu -o temp -lglut -lGLU -lGL
//To stop hit "control c" in the window you launched it from.

/*
 What to do:
 This is some crude code that moves two bodies around in a box, attracted by gravity and 
 repelled when they hit each other. Take this from a two-body problem to an N-body problem, where 
 NUMBER_OF_SPHERES is a #define that you can change. Also clean it up a bit so it is more user friendly.
*/

/*
 Purpose:
 To learn about Nbody code.
*/

/*
 Explain what you did to fix the code:
 
*/

// Include files
#include <GL/glut.h>
#include <GL/glu.h>
#include <GL/gl.h>
#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include <time.h>

// Defines
#define XWindowSize 1000
#define YWindowSize 1000
#define STOP_TIME 10000.0
#define DT        0.0001
#define GRAVITY 0.1 
#define MASS 10.0  	
#define DIAMETER 1.0
#define SPHERE_PUSH_BACK_STRENGTH 50.0
#define PUSH_BACK_REDUCTION 0.1
#define DAMP 0.01
#define DRAW 100
#define LENGTH_OF_BOX 6.0
#define MAX_VELOCITY 5.0

// Globals
const float XMax = (LENGTH_OF_BOX/2.0);
const float YMax = (LENGTH_OF_BOX/2.0);
const float ZMax = (LENGTH_OF_BOX/2.0);
const float XMin = -(LENGTH_OF_BOX/2.0);
const float YMin = -(LENGTH_OF_BOX/2.0);
const float ZMin = -(LENGTH_OF_BOX/2.0);
float px1, py1, pz1, vx1, vy1, vz1, fx1, fy1, fz1, mass1; 
float px2, py2, pz2, vx2, vy2, vz2, fx2, fy2, fz2, mass2;

// Function prototypes
void set_initail_conditions();
void Drawwirebox();
void draw_picture();
void keep_in_box();
void get_forces();
void move_bodies(float);
void nbody();
void Display(void);
void reshape(int, int);
int main(int, char**);

void set_initail_conditions()
{ 
	time_t t;
	srand((unsigned) time(&t));
	int yeahBuddy;
	float dx, dy, dz, seperation;
	
	px1 = (LENGTH_OF_BOX - DIAMETER)*rand()/RAND_MAX - (LENGTH_OF_BOX - DIAMETER)/2.0;
	py1 = (LENGTH_OF_BOX - DIAMETER)*rand()/RAND_MAX - (LENGTH_OF_BOX - DIAMETER)/2.0;
	pz1 = (LENGTH_OF_BOX - DIAMETER)*rand()/RAND_MAX - (LENGTH_OF_BOX - DIAMETER)/2.0;
	
	yeahBuddy = 0;
	while(yeahBuddy == 0)
	{
		px2 = (LENGTH_OF_BOX - DIAMETER)*rand()/RAND_MAX - (LENGTH_OF_BOX - DIAMETER)/2.0;
		py2 = (LENGTH_OF_BOX - DIAMETER)*rand()/RAND_MAX - (LENGTH_OF_BOX - DIAMETER)/2.0;
		pz2 = (LENGTH_OF_BOX - DIAMETER)*rand()/RAND_MAX - (LENGTH_OF_BOX - DIAMETER)/2.0;
		
		dx = px2 - px2;
		dy = py2 - py1;
		dz = pz2 - pz1;
		seperation = sqrt(dx*dx + dy*dy + dz*dz);
		yeahBuddy = 1;
		if(seperation < DIAMETER) yeahBuddy = 0;
	}
	
	vx1 = 2.0*MAX_VELOCITY*rand()/RAND_MAX - MAX_VELOCITY;
	vy1 = 2.0*MAX_VELOCITY*rand()/RAND_MAX - MAX_VELOCITY;
	vz1 = 2.0*MAX_VELOCITY*rand()/RAND_MAX - MAX_VELOCITY;
	
	vx2 = 2.0*MAX_VELOCITY*rand()/RAND_MAX - MAX_VELOCITY;
	vy2 = 2.0*MAX_VELOCITY*rand()/RAND_MAX - MAX_VELOCITY;
	vz2 = 2.0*MAX_VELOCITY*rand()/RAND_MAX - MAX_VELOCITY;
	
	mass1 = 1.0;
	mass2 = 1.0;
}

void Drawwirebox()
{		
	glColor3f (5.0,1.0,1.0);
	glBegin(GL_LINE_STRIP);
		glVertex3f(XMax,YMax,ZMax);
		glVertex3f(XMax,YMax,ZMin);	
		glVertex3f(XMax,YMin,ZMin);
		glVertex3f(XMax,YMin,ZMax);
		glVertex3f(XMax,YMax,ZMax);
		
		glVertex3f(XMin,YMax,ZMax);
		
		glVertex3f(XMin,YMax,ZMax);
		glVertex3f(XMin,YMax,ZMin);	
		glVertex3f(XMin,YMin,ZMin);
		glVertex3f(XMin,YMin,ZMax);
		glVertex3f(XMin,YMax,ZMax);	
	glEnd();
	
	glBegin(GL_LINES);
		glVertex3f(XMin,YMin,ZMax);
		glVertex3f(XMax,YMin,ZMax);		
	glEnd();
	
	glBegin(GL_LINES);
		glVertex3f(XMin,YMin,ZMin);
		glVertex3f(XMax,YMin,ZMin);		
	glEnd();
	
	glBegin(GL_LINES);
		glVertex3f(XMin,YMax,ZMin);
		glVertex3f(XMax,YMax,ZMin);		
	glEnd();
	
}

void draw_picture()
{
	float radius = DIAMETER/2.0;
	glClear(GL_COLOR_BUFFER_BIT);
	glClear(GL_DEPTH_BUFFER_BIT);
	
	Drawwirebox();
	
	glColor3d(1.0,0.5,1.0);
	glPushMatrix();
	glTranslatef(px1, py1, pz1);
	glutSolidSphere(radius,20,20);
	glPopMatrix();
	
	glColor3d(0.0,0.5,0.0);
	glPushMatrix();
	glTranslatef(px2, py2, pz2);
	glutSolidSphere(radius,20,20);
	glPopMatrix();
	
	glutSwapBuffers();
}

void keep_in_box()
{
	float halfBoxLength = (LENGTH_OF_BOX - DIAMETER)/2.0;
	
	if(px1 > halfBoxLength)
	{
		px1 = 2.0*halfBoxLength - px1;
		vx1 = - vx1;
	}
	else if(px1 < -halfBoxLength)
	{
		px1 = -2.0*halfBoxLength - px1;
		vx1 = - vx1;
	}
	
	if(py1 > halfBoxLength)
	{
		py1 = 2.0*halfBoxLength - py1;
		vy1 = - vy1;
	}
	else if(py1 < -halfBoxLength)
	{
		py1 = -2.0*halfBoxLength - py1;
		vy1 = - vy1;
	}
			
	if(pz1 > halfBoxLength)
	{
		pz1 = 2.0*halfBoxLength - pz1;
		vz1 = - vz1;
	}
	else if(pz1 < -halfBoxLength)
	{
		pz1 = -2.0*halfBoxLength - pz1;
		vz1 = - vz1;
	}
	
	if(px2 > halfBoxLength)
	{
		px2 = 2.0*halfBoxLength - px2;
		vx2 = - vx2;
	}
	else if(px2 < -halfBoxLength)
	{
		px2 = -2.0*halfBoxLength - px2;
		vx2 = - vx2;
	}
	
	if(py2 > halfBoxLength)
	{
		py2 = 2.0*halfBoxLength - py2;
		vy2 = - vy2;
	}
	else if(py2 < -halfBoxLength)
	{
		py2 = -2.0*halfBoxLength - py2;
		vy2 = - vy2;
	}
			
	if(pz2 > halfBoxLength)
	{
		pz2 = 2.0*halfBoxLength - pz2;
		vz2 = - vz2;
	}
	else if(pz2 < -halfBoxLength)
	{
		pz2 = -2.0*halfBoxLength - pz2;
		vz2 = - vz2;
	}
}

void get_forces()
{
	float dx,dy,dz,r,r2,dvx,dvy,dvz,forceMag,inout;
	
	dx = px2 - px1;
	dy = py2 - py1;
	dz = pz2 - pz1;
				
	r2 = dx*dx + dy*dy + dz*dz;
	r = sqrt(r2);

	forceMag =  mass1*mass2*GRAVITY/r2;
			
	if (r < DIAMETER)
	{
		dvx = vx2 - vx1;
		dvy = vy2 - vy1;
		dvz = vz2 - vz1;
		inout = dx*dvx + dy*dvy + dz*dvz;
		if(inout <= 0.0)
		{
			forceMag +=  SPHERE_PUSH_BACK_STRENGTH*(r - DIAMETER);
		}
		else
		{
			forceMag +=  PUSH_BACK_REDUCTION*SPHERE_PUSH_BACK_STRENGTH*(r - DIAMETER);
		}
	}

	fx1 = forceMag*dx/r;
	fy1 = forceMag*dy/r;
	fz1 = forceMag*dz/r;
	fx2 = -forceMag*dx/r;
	fy2 = -forceMag*dy/r;
	fz2 = -forceMag*dz/r;
}

void move_bodies(float time)
{
	if(time == 0.0)
	{
		vx1 += 0.5*DT*(fx1 - DAMP*vx1)/mass1;
		vy1 += 0.5*DT*(fy1 - DAMP*vy1)/mass1;
		vz1 += 0.5*DT*(fz1 - DAMP*vz1)/mass1;
		
		vx2 += 0.5*DT*(fx2 - DAMP*vx2)/mass2;
		vy2 += 0.5*DT*(fy2 - DAMP*vy2)/mass2;
		vz2 += 0.5*DT*(fz2 - DAMP*vz2)/mass2;
	}
	else
	{
		vx1 += DT*(fx1 - DAMP*vx1)/mass1;
		vy1 += DT*(fy1 - DAMP*vy1)/mass1;
		vz1 += DT*(fz1 - DAMP*vz1)/mass1;
		
		vx2 += DT*(fx2 - DAMP*vx2)/mass2;
		vy2 += DT*(fy2 - DAMP*vy2)/mass2;
		vz2 += DT*(fz2 - DAMP*vz2)/mass2;
	}

	px1 += DT*vx1;
	py1 += DT*vy1;
	pz1 += DT*vz1;
	
	px2 += DT*vx2;
	py2 += DT*vy2;
	pz2 += DT*vz2;
	
	keep_in_box();
}

void nbody()
{	
	int    tdraw = 0;
	float  time = 0.0;

	set_initail_conditions();
	
	draw_picture();
	
	while(time < STOP_TIME)
	{
		get_forces();
	
		move_bodies(time);
	
		tdraw++;
		if(tdraw == DRAW) 
		{
			draw_picture(); 
			tdraw = 0;
		}
		
		time += DT;
	}
	printf("\n DONE \n");
	while(1);
}

void Display(void)
{
	gluLookAt(0.0, 0.0, 10.0, 0.0, 0.0, 0.0, 0.0, 1.0, 0.0);
	glClear(GL_COLOR_BUFFER_BIT);
	glClear(GL_DEPTH_BUFFER_BIT);
	glPolygonMode(GL_FRONT_AND_BACK, GL_FILL);
	glutSwapBuffers();
	glFlush();
	nbody();
}

void reshape(int w, int h)
{
	glViewport(0, 0, (GLsizei) w, (GLsizei) h);

	glMatrixMode(GL_PROJECTION);

	glLoadIdentity();

	glFrustum(-0.2, 0.2, -0.2, 0.2, 0.2, 50.0);

	glMatrixMode(GL_MODELVIEW);
}

int main(int argc, char** argv)
{
	glutInit(&argc,argv);
	glutInitDisplayMode(GLUT_DOUBLE | GLUT_DEPTH | GLUT_RGB);
	glutInitWindowSize(XWindowSize,YWindowSize);
	glutInitWindowPosition(0,0);
	glutCreateWindow("2 Body 3D");
	GLfloat light_position[] = {1.0, 1.0, 1.0, 0.0};
	GLfloat light_ambient[]  = {0.0, 0.0, 0.0, 1.0};
	GLfloat light_diffuse[]  = {1.0, 1.0, 1.0, 1.0};
	GLfloat light_specular[] = {1.0, 1.0, 1.0, 1.0};
	GLfloat lmodel_ambient[] = {0.2, 0.2, 0.2, 1.0};
	GLfloat mat_specular[]   = {1.0, 1.0, 1.0, 1.0};
	GLfloat mat_shininess[]  = {10.0};
	glClearColor(0.0, 0.0, 0.0, 0.0);
	glShadeModel(GL_SMOOTH);
	glColorMaterial(GL_FRONT, GL_AMBIENT_AND_DIFFUSE);
	glLightfv(GL_LIGHT0, GL_POSITION, light_position);
	glLightfv(GL_LIGHT0, GL_AMBIENT, light_ambient);
	glLightfv(GL_LIGHT0, GL_DIFFUSE, light_diffuse);
	glLightfv(GL_LIGHT0, GL_SPECULAR, light_specular);
	glLightModelfv(GL_LIGHT_MODEL_AMBIENT, lmodel_ambient);
	glMaterialfv(GL_FRONT, GL_SPECULAR, mat_specular);
	glMaterialfv(GL_FRONT, GL_SHININESS, mat_shininess);
	glEnable(GL_LIGHTING);
	glEnable(GL_LIGHT0);
	glEnable(GL_COLOR_MATERIAL);
	glEnable(GL_DEPTH_TEST);
	glutDisplayFunc(Display);
	glutReshapeFunc(reshape);
	glutMainLoop();
	return 0;
}


