#include <verilated.h>          // defines common routines
#include "verilated_vcd_c.h"
#include <GL/glut.h>
#include <FTGL/ftgl.h>
#include "RGBpixmap.h"                   // pixel map definitions
#include <thread>
#include <iostream>

#include "Vtop.h"           // from Verilating "top.v"

#if VGA == 1
	#define VGAflag true
#else
	#define VGAflag false
#endif


using namespace std;

FTGL::FTGLfont *font,*font7s;

Vtop* top;              // instantiation of the model

uint64_t main_time = 0;         // current simulation time
double sc_time_stamp() {        // called by $time in Verilog
    return main_time;
}

// to wait for the graphics thread to complete initialization
volatile bool gl_setup_complete = false;

// 640X480 VGA sync parameters
const int LEFT_PORCH		= 	48;
const int ACTIVE_WIDTH		= 	640;
const int RIGHT_PORCH		= 	16;
const int HORIZONTAL_SYNC	=	96;
const int TOTAL_WIDTH		=	800; //768;

const int TOP_PORCH			= 29;
const int ACTIVE_HEIGHT		= 	480;
const int BOTTOM_PORCH		= 	10;
const int VERTICAL_SYNC		=	2;
const int TOTAL_HEIGHT		=	521;

const int SEVEN_SEGMENT_HEIGHT = 90;

// pixels are buffered here
float graphics_buffer[ACTIVE_WIDTH][ACTIVE_HEIGHT][3] = {};


//coordinates of last mouse click
int mouse_x=-10, mouse_y=-10; 
int VGAsw=1;
int sw[16]={0};

//images
RGBpixmap  img_led_on;
RGBpixmap  img_led_off;
RGBpixmap  img_up_on;
RGBpixmap  img_up_off;
RGBpixmap  img_down_on;
RGBpixmap  img_down_off;
RGBpixmap  img_left_on;
RGBpixmap  img_left_off;
RGBpixmap  img_right_on;
RGBpixmap  img_right_off;
RGBpixmap  img_switch_on;
RGBpixmap  img_switch_off;
RGBpixmap  img_board;


// seven segment inputs
char ss[5] = "    ";
//seven segment delay
#define SSDELAY 1000000
int ssd[5] = {SSDELAY};
int sub1,sub2;

// calculating each pixel's size in accordance to OpenGL system
// each axis in OpenGL is in the range [-1:1]
float pixel_w = 2.0 / ACTIVE_WIDTH;
float pixel_h = 2.0 / ACTIVE_HEIGHT;

// gets called periodically to update screen
void render(void) {
    glClear(GL_COLOR_BUFFER_BIT);
    
    // convert pixels into OpenGL rectangles
    if (VGAsw && VGAflag)
        for(int i = 0; i < ACTIVE_WIDTH; i++){
            for(int j = 0; j < ACTIVE_HEIGHT; j++){
                glColor3f(graphics_buffer[i][j][0], graphics_buffer[i][j][1], graphics_buffer[i][j][2]);
                glRectf(i*pixel_w-1, -j*pixel_h+1, (i+1)*pixel_w-1, -(j+1)*pixel_h+1);
            }
        }
    else
        img_board.draw();
    glFlush();
}

// gets called periodically to update screen
void render2(void) {
    int len, i;
    glClearColor(1.0f, 1.0f, 1.0f, 0.0f);
    glClear(GL_COLOR_BUFFER_BIT);
    
    glColor3f(0.0f, 0.0f, 0.0f);
    
    /* Set the font size and render the SS display*/
    glPushAttrib(GL_ALL_ATTRIB_BITS);

    FTGL::ftglSetFontFaceSize(font7s, 48, 48);
    //seven segment print
    for (i=0; i<4; i++) {
        char str[2] = "\0"; /* 1 character + null terminator */
        if (ss[i] ==0x20) {
            glPixelTransferf(GL_RED_BIAS, 0.86);
            glPixelTransferf(GL_GREEN_BIAS, 0.86); 
            glPixelTransferf(GL_BLUE_BIAS, 0.86);
            str[0] = '0';
        }
        else {
            glPixelTransferf(GL_RED_BIAS, 0);
            glPixelTransferf(GL_GREEN_BIAS, 1); 
            glPixelTransferf(GL_BLUE_BIAS, 0);
            str[0] = ss[i];
        }
        glRasterPos2f(620+64*i,-500);
        FTGL::ftglRenderFont(font7s, str, FTGL::RENDER_ALL);
    }
    
    //SWITCH buttons

    glPixelTransferf(GL_RED_BIAS, 0);
    glPixelTransferf(GL_GREEN_BIAS, 0);
    glPixelTransferf(GL_BLUE_BIAS, 0);

    /*
    glRasterPos2f(-995,-500);
    glutBitmapCharacter(GLUT_BITMAP_HELVETICA_12 , 'S');
    glutBitmapCharacter(GLUT_BITMAP_HELVETICA_12 , 'W');
    glutBitmapCharacter(GLUT_BITMAP_HELVETICA_12 , '0');
    */
    
    //draw SWITCH buttons
    
    FTGL::ftglSetFontFaceSize(font, 13, 13);
    for (int i=0; i<16; i++) {
        glRasterPos2f(-995+100*i,-750);
        if (sw[i]) img_switch_on.draw(); else img_switch_off.draw();
        glRasterPos2f(-1000+100*i,-950);
        char str[8];
        sprintf(str, "SW%d", i);
        FTGL::ftglRenderFont(font, str, FTGL::RENDER_ALL);
    }
    
    // draw push buttons
    glRasterPos2f(620,400);
    if (top->left) img_left_on.draw(); else img_left_off.draw();
    glRasterPos2f(715,400);
    if (top->up) img_up_on.draw(); else img_up_off.draw();
    glRasterPos2f(810,400);
    if (top->down) img_down_on.draw(); else img_down_off.draw();
    glRasterPos2f(905,400);
    if (top->right) img_right_on.draw(); else img_right_off.draw();
    


    glRasterPos2f(900,-750);
    if (VGAflag){
	    if (VGAsw) img_switch_on.draw(); else img_switch_off.draw();
	    glRasterPos2f(910,-920);
	    FTGL::ftglRenderFont(font, "VGA", FTGL::RENDER_ALL);
    }

    //draw LEDs
    for (int i=0; i<16; i++) {
        glRasterPos2f(-990+100*i,470);
        if (top->LED & (1<<i)) img_led_on.draw(); else img_led_off.draw();
    }
    

    glutSwapBuffers();
    
    glFlush();
}



// timer to periodically update the screen
void glutTimer(int t) {
    glutSetWindow(sub2);
    glutPostRedisplay();
    glutSetWindow(sub1);
    glutPostRedisplay(); // re-renders the screen
    glutTimerFunc(t, glutTimer, t);
}

//mouse callback

void mousepress(int button, int state, int x, int y) {


  if (button == GLUT_LEFT_BUTTON && state == GLUT_DOWN) {
    mouse_x = x;
    mouse_y = y;
    //(x,y) are in window coordinates, where the origin is in the upper
    //left corner; our reference system has the origin in lower left
    //corner, this means we have to reflect y
    //mouse_y = WINDOWSIZE - mouse_y; 
    int index= mouse_x/32;
    //printf("mouse pressed at (%d,%d) idx=%d\n", mouse_x, mouse_y, index); 
    if (index<16) {
        //printf("SW%d\n", index);
        sw[index] = !sw[index];
        top->sw = top->sw ^ (1 << index);
    }
    if (index==16) { 
	    top->left =1;
    }
    if (index==17) { 
	    top->up =1;
    }
    if (index==18) { 
	    top->down =1;
    }
    if (index==19) { 
        if (mouse_y<30) 
            top->right =1;
        else    
            VGAsw = !VGAsw;
    }
  }
  if (button == GLUT_LEFT_BUTTON && state == GLUT_UP) {
    //mouse_x = x;
    //mouse_y = y;
    //int index= mouse_x/32;
    //printf("mouse released at (%d,%d) idx=%d\n", mouse_x, mouse_y,index); 
    top->down =0;
    top->up   =0;
    top->left =0;
    top->right =0;
  }

  glutPostRedisplay();
}


int asciiToPs2[128]={
    0,0,0,0,0,0,0,0,0,0,0,0,0,0x5A,0,0, //0-15
    0,0,0,0,0,0,0,0,0,0,0,0x76,0,0,0,0, //16-31
    0x29,0,0,0,0,0,0,0,0,0,0,0x55,0x41,0x4E,0x49,0, //32-47
    0x45,0x16,0x1E,0x26,0x25,0x2E,0x36,0x3D, //48-55
    0x3E,0x46,0x00,0x00,0x00,0x00,0x00,0x00, //56-63
    0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0, //64-79
    0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0, //80-95
    0x00,0x1C,0x32,0x21,0x23,0x24,0x2B,0x34, //96-103
    0x33,0x43,0x3B,0x42,0x4B,0x3A,0x31,0x44, //104-111
    0x4D,0x15,0x2D,0x1B,0x2C,0x3C,0x2A,0x1D, //112-119
    0x22,0x35,0x1A,0x00,0x00,0x00,0x00,0x00  //120-127
    }; // ASCII table size

// PS2 keyboard input
// handle up/down/left/right/space/enter arrow keys
//int keys[6] = {};
int pressedkey = 0;
int millis=110000;
void Keyboard_input(unsigned char key, int x, int y) {
    millis=0;
    pressedkey=(asciiToPs2[key] <<1);
}

void Special_input(int key, int x, int y) {
    switch(key) {
        case GLUT_KEY_UP:
            millis=0;
            pressedkey=(0x75 <<1);
            break;
        case GLUT_KEY_DOWN:
            millis=0;
            pressedkey=(0x72 <<1);
            break;
        case GLUT_KEY_LEFT:
            millis=0;
            pressedkey=(0x6B <<1);
            break;
        case GLUT_KEY_RIGHT:
            millis=0;
            pressedkey=(0x74 <<1);
            break;
    }
}

//callback for key release
void Special_input_release(int key, int x, int y) {
    switch(key) {
        case GLUT_KEY_UP:
            //keys[0] = 1;
            millis=0;
            pressedkey=(0x29 <<1);
            break;
        case GLUT_KEY_DOWN:
            //keys[1] = 1;
            millis=0;
            pressedkey=(0x29 <<1);
            break;
        case GLUT_KEY_LEFT:
            //keys[2] = 1;
            millis=0;
            pressedkey=(0x29 <<1);
            break;
        case GLUT_KEY_RIGHT:
            //keys[3] = 1;
            millis=0;
            pressedkey=(0x29 <<1);
            break;
    }
}

// initiate and handle graphics
void graphics_loop(int argc, char** argv) {
    glutInit(&argc, argv);
    glutInitDisplayMode(GLUT_SINGLE);
    glutInitWindowSize(ACTIVE_WIDTH, ACTIVE_HEIGHT+SEVEN_SEGMENT_HEIGHT);
    glutInitWindowPosition(100, 100);
    int window=glutCreateWindow("Basys 3 Simulator");
    
    //seven segment subwindow
    sub2=glutCreateSubWindow(window, 0,ACTIVE_HEIGHT,ACTIVE_WIDTH, SEVEN_SEGMENT_HEIGHT);
    glMatrixMode(GL_PROJECTION);
    glLoadIdentity();
    gluOrtho2D(0, 2000, 0, 2000);
    glMatrixMode(GL_MODELVIEW);
    glEnable(GL_LINE_SMOOTH);
    glEnable(GL_BLEND);
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    glLineWidth(3.0);
    glTranslatef(1000, 1000, 0); 
    glColor3f(0.0, 0.0, 0.0);
    glutMouseFunc(mousepress);

    /* Create a pixmap font from a TrueType file. */
    font = FTGL::ftglCreatePixmapFont("./resources/CalibriRegular.ttf");
    font7s = FTGL::ftglCreatePixmapFont("./resources/SevenSegment.ttf");

    //load bitmaps
    img_up_on.readBMPFile("./resources/UPon.bmp",false);
    img_up_off.readBMPFile("./resources/UPoff.bmp",false);
    img_down_on.readBMPFile("./resources/DOWNon.bmp",false);
    img_down_off.readBMPFile("./resources/DOWNoff.bmp",false);
    img_left_on.readBMPFile("./resources/Lon.bmp",false);
    img_left_off.readBMPFile("./resources/Loff.bmp",false);
    img_right_on.readBMPFile("./resources/Ron.bmp",false);
    img_right_off.readBMPFile("./resources/Roff.bmp",false);
    img_switch_on.readBMPFile("./resources/SWon.bmp",false);
    img_switch_off.readBMPFile("./resources/SWoff.bmp",false);
    img_led_on.readBMPFile("./resources/LEDon.bmp",false);
    img_led_off.readBMPFile("./resources/LEDoff.bmp",false);
    img_board.readBMPFile("./resources/board.bmp",false);
    

    glutDisplayFunc(render2);
    
    //VGA subwindow
    sub1=glutCreateSubWindow(window, 0,0,ACTIVE_WIDTH, ACTIVE_HEIGHT);
    glutDisplayFunc(render);
    
    glutKeyboardFunc(Keyboard_input);
    glutSpecialFunc(Special_input);
    glutSpecialUpFunc(Special_input_release);
    //glutIgnoreKeyRepeat(0); //report autorepeat keys    
    
    glutSetWindow(window);
    glutDisplayFunc(render);

    gl_setup_complete = true;
    cout << "Graphics setup complete" << endl;

    // re-render every 16ms, around 60Hz
    glutTimerFunc(16, glutTimer, 16);
    glutMainLoop();
}

// tracking VGA signals
int coord_x = 0;
int coord_y = 0;
bool pre_h_sync = 0;
bool pre_v_sync = 0;

// set Verilog module inputs based on arrow key inputs
/*void apply_input() {
    top->up = keys[0];
    top->down = keys[1];
    top->left = keys[2];
    top->right = keys[3];
    top->space = keys[4];
    top->enter = keys[5];
    
    for(int i=0; i<6; i++)
        keys[i] = 0;
}*/

// we only want the input to last for one or few clocks
/*void discard_input() {
    top->up = 0;
    top->down = 0;
    top->left = 0;
    top->right = 0;
    top->space = 0;
    top->enter = 0;
}*/

void sample_7s() {
    char key;
    /*char code= top->ca+
            2*top->cb+
            4*top->cc+
            8*top->cd+
            16*top->ce+
            32*top->cf+
            64*top->cg;
            */

    switch (top->seg) {
        case 0x40: key='0'; break;
        case 0x79: key='1'; break;
        case 0x24: key='2'; break;
        case 0x30: key='3'; break;
        case 0x19: key='4'; break;
        case 0x12: key='5'; break;
        case 0x02: key='6'; break;
        case 0x78: key='7'; break;
        case 0x00: key='8'; break;
        case 0x10: key='9'; break;
        case 0x08: key='A'; break;
        case 0x03: key='b'; break;
        case 0x46: key='C'; break;
        case 0x21: key='d'; break;
        case 0x06: key='E'; break;
        case 0x0E: key='F'; break;
        case 0x7F: key=' '; break;
        case 0x3F: key='-'; break;
        case 0x09: key='U'; break;
        case 0x47: key='L'; break;
        case 0x7C: key='D'; break;
        case 0x2B: key='o'; break;
        case 0x5C: key='n'; break;
        case 0x0c: key='P'; break;
        default: key=' ';
    }

    for(int i=0; i<4; i++) {
        if (ssd[i]==0) ss[i] = ' ';
    	if (ssd[i]>0) ssd[i]--;
    }
    if(top->an==14) { ss[0]=key;  ssd[0]=SSDELAY;}
    if(top->an==13) { ss[1]=key;  ssd[1]=SSDELAY;} 
    if(top->an==11) { ss[2]=key;  ssd[2]=SSDELAY;}
    if(top->an==7)  { ss[3]=key;  ssd[3]=SSDELAY;}
}
// read VGA outputs and update graphics buffer
void sample_pixel() {
    //discard_input();
    
    coord_x = (coord_x + 1) % TOTAL_WIDTH;

    if(!top->h_sync && pre_h_sync){ // on negative edge of h_sync
        // re-sync horizontal counter
        //coord_x = RIGHT_PORCH + ACTIVE_WIDTH + HORIZONTAL_SYNC;
        coord_x = TOTAL_WIDTH - (LEFT_PORCH+HORIZONTAL_SYNC);
        coord_y = (coord_y + 1) % TOTAL_HEIGHT;
    }

    if(!top->v_sync && pre_v_sync){ // on negative edge of v_sync
        // re-sync vertical counter
        //coord_y = TOP_PORCH + ACTIVE_HEIGHT + VERTICAL_SYNC;
        coord_y = TOTAL_HEIGHT - (TOP_PORCH + VERTICAL_SYNC);
        //apply_input(); // inputs are pulsed once each new frame
    }

    if(coord_x < ACTIVE_WIDTH && coord_y < ACTIVE_HEIGHT){
        int r = top->R_VAL;
        int g = top->G_VAL;
        int b = top->B_VAL;
        graphics_buffer[coord_x][coord_y][0] = float(r)/16.0;
        graphics_buffer[coord_x][coord_y][1] = float(g)/16.0;
        graphics_buffer[coord_x][coord_y][2] = float(b)/16.0;
    }

    pre_h_sync = top->h_sync;
    pre_v_sync = top->v_sync;
}

// simulate for a single clock
void tick() {
    // update simulation time
    main_time++;

    // rising edge
    top->clk = 1;
    top->eval();

    // falling edge
    top->clk = 0;
    
    //apply PS2 inputs
    if (millis==110000) {
        top->KEYSIG_CLK = 1;
        top->KEYSIG_DATA = 1;
    }
    else {     
        if ((millis % 10000) == 0) { // every 10ms
            top->KEYSIG_CLK = 1;
            top->KEYSIG_DATA = pressedkey & 0x1;
        }
        if ((millis % 10000) == 5000) {
                top->KEYSIG_CLK = 0; 
                pressedkey = pressedkey >>1;
        }
        millis++;
    }

    //if ((main_time % 10000) == 0) { // every 10ms
    //        cout << "ss[0]: " << (int) ss[0] << endl;
    //}
    top->eval();
}

// globally reset the model
void reset() {
    top->reset = 0;
    top->eval();
    tick();
    top->reset = 1;
    top->clk = 0;
    top->eval();
    tick();
    top->reset = 0;
}

int main(int argc, char** argv) {
    
    bool vcd=false;

    int dump_level=1;    
    if (argc>1)
        if (strcmp(argv[1],"-vcd")==0)
            vcd=true;
    if (argc>2)
        if (atoi(argv[2])>0)
            dump_level=atoi(argv[2]);
    
    // create a new thread for graphics handling
    thread thread(graphics_loop, argc, argv);
    // wait for graphics initialization to complete

    while(!gl_setup_complete);

    Verilated::commandArgs(argc, argv);   // remember args


    // create the model
    top = new Vtop;

    VerilatedVcdC* tfp = new VerilatedVcdC;
    if (vcd) {
        Verilated::traceEverOn(true);
        top->trace(tfp, 99);
        tfp->dumpvars(dump_level, "TOP.top");
        tfp->open("wave.vcd");
    }
    // reset the model
    reset();
    //top->s1 = 1;
    // cycle accurate simulation loop
    while (!Verilated::gotFinish()) {
        // main clock is 100 MHz
        tick();
	    //discard_input();
        tick();
        tick();
        tick();
        // the clock frequency of VGA is 25 MHz of that of the whole model
        // so we sample from VGA every other clock
        sample_pixel();
        // sample seven segment display
        sample_7s(); 
        if (vcd) tfp->dump(main_time);
    }
    if (vcd) tfp->close();
    top->final();

    delete top;
}

