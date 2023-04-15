#include <verilated.h>          // defines common routines
#include "verilated_vcd_c.h"
#include <GL/glut.h>
#include <FTGL/ftgl.h>
#include "RGBpixmap.h"                   // pixel map definitions
#include <thread>
#include <iostream>

#include "Vdisplay.h"           // from Verilating "display.v"

using namespace std;

FTGL::FTGLfont *font;

Vdisplay* display;              // instantiation of the model

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
const int TOTAL_WIDTH		=	800;

const int TOP_PORCH			= 	33;
const int ACTIVE_HEIGHT		= 	480;
const int BOTTOM_PORCH		= 	10;
const int VERTICAL_SYNC		=	2;
const int TOTAL_HEIGHT		=	525;

const int SEVEN_SEGMET_HEIGHT = 50;

// pixels are buffered here
float graphics_buffer[ACTIVE_WIDTH][ACTIVE_HEIGHT][3] = {};


//coordinates of last mouse click
int mouse_x=-10, mouse_y=-10; 
int VGAsw=0;
int sw0=0, sw1=0, sw2=0, sw3=0;

//images
RGBpixmap  img_switch_on;
RGBpixmap  img_switch_off;
RGBpixmap  img_board;


// seven segment inputs
char ss[5] = "    ";
int sub1,sub2;

// calculating each pixel's size in accordance to OpenGL system
// each axis in OpenGL is in the range [-1:1]
float pixel_w = 2.0 / ACTIVE_WIDTH;
float pixel_h = 2.0 / ACTIVE_HEIGHT;

// gets called periodically to update screen
void render(void) {
    glClear(GL_COLOR_BUFFER_BIT);
    
    // convert pixels into OpenGL rectangles
    if (VGAsw)
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
    char *message="Seven Segment: ";
    glClearColor(1.0f, 1.0f, 1.0f, 0.0f);
    glClear(GL_COLOR_BUFFER_BIT);
    
    glColor3f(0.0f, 0.0f, 0.0f);
    glRasterPos2f(700,-500);
    
    /* Set the font size and render the SS display*/
    glPushAttrib(GL_ALL_ATTRIB_BITS);

    //glPixelTransferf(GL_RED_BIAS, 0);
    //glPixelTransferf(GL_GREEN_BIAS, 2);
    //glPixelTransferf(GL_BLUE_BIAS, 0);
    //FTGL::ftglRenderFont(font, ss, FTGL::RENDER_ALL);

    FTGL::ftglSetFontFaceSize(font, 48, 48);
    //seven segment print
    for (i=0; i<4; i++) {
        char str[2] = "\0"; /* 1 character + null terminator */
        if (ss[i] ==0x20) {
            glPixelTransferf(GL_GREEN_BIAS, 0); 
            str[0] = '0';
        }
        else {
            glPixelTransferf(GL_GREEN_BIAS, 2); 
            str[0] = ss[i];
        }
        glRasterPos2f(700+64*i,-500);
        FTGL::ftglRenderFont(font, str, FTGL::RENDER_ALL);
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
    
    glRasterPos2f(-995,-1000);
    if (sw0) img_switch_on.draw(); else img_switch_off.draw();
    glRasterPos2f(-895,-1000);
    if (sw1) img_switch_on.draw(); else img_switch_off.draw();
    glRasterPos2f(-795,-1000);
    if (sw2) img_switch_on.draw(); else img_switch_off.draw();
    glRasterPos2f(-695,-1000);
    if (sw3) img_switch_on.draw(); else img_switch_off.draw();
    glRasterPos2f(-595,-1000);
    if (VGAsw) img_switch_on.draw(); else img_switch_off.draw();

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
    //printf("mouse pressed at (%d,%d)\n", mouse_x, mouse_y); 
    if (mouse_x<30)       { printf("SW0\n"); sw0 = !sw0; display->sw0 = sw0; }
    else if (mouse_x<60)  { printf("SW1\n"); sw1 = !sw1; display->sw1 = sw1; } 
    else if (mouse_x<90)  { printf("SW2\n"); sw2 = !sw2; display->sw2 = sw2; }
    else if (mouse_x<120) { printf("SW3\n"); sw3 = !sw3; display->sw3 = sw3; }
    else if (mouse_x<150) { printf("SW_VGA\n"); VGAsw = !VGAsw;}
  }
  
  glutPostRedisplay();
}



// PS2 keyboard input
// handle up/down/left/right/space/enter arrow keys
//int keys[6] = {};
int pressedkey = 0;
int bit=0;

void Keyboard_input(unsigned char key, int x, int y) {
    //cout << "key: " << key << endl;
    switch(key) {
        case 13: //ENTER
            pressedkey=(0x5A <<1);
            bit=11;
            //keys[5] = 1;
            break;
        case 27: //ESC
            pressedkey=(0x76 <<1);
            bit=11;
            break;
        case '0':
            pressedkey=(0x45 <<1);
            bit=11;
            break;
        case '1':
            pressedkey=(0x16 <<1);
            bit=11;
            break;
        case '2':
            pressedkey=(0x1E <<1);
            bit=11;
            break;
        case '3':
            pressedkey=(0x26 <<1);
            bit=11;
            break;
        case '4':
            pressedkey=(0x25 <<1);
            bit=11;
            break;
        case '5':
            pressedkey=(0x2E <<1);
            bit=11;
            break;
        case '6':
            pressedkey=(0x36 <<1);
            bit=11;
            break;
        case '7':
            pressedkey=(0x3D <<1);
            bit=11;
            break;
        case '8':
            pressedkey=(0x3E <<1);
            bit=11;
            break;
        case '9':
            pressedkey=(0x46 <<1);
            bit=11;
            break;
        case 'a': //'A'
            pressedkey=(0x1C <<1);
            bit=11;
            break;
        case 'b': //'B'
            pressedkey=(0x32 <<1);
            bit=11;
            break;
        case 'c': //'C'
            pressedkey=(0x21 <<1);
            bit=11;
            break;
        case 'd': //'D'
            pressedkey=(0x23 <<1);
            bit=11;
            break;
        case 'e': //'E'
            pressedkey=(0x24 <<1);
            bit=11;
            break;
        case 'f': //'F' 
            pressedkey=(0x2B <<1);
            bit=11;
            break;
        case 's': //'S'
            pressedkey=(0x1B <<1);
            bit=11;
            break;
        case 'p':
            pressedkey=(0x4D <<1);
            bit=11;
            break;
        case 'r':
            pressedkey=(0x2D <<1);
            bit=11;
            break;
        case ' ':
            pressedkey=(0x29 <<1);
            bit=11;
            //keys[4] = 1;
            break;

    }
}

void Special_input(int key, int x, int y) {
    switch(key) {
        case GLUT_KEY_UP:
            pressedkey=(0x75 <<1);
            bit=11;
            break;
        case GLUT_KEY_DOWN:
            pressedkey=(0x72 <<1);
            bit=11;
            break;
        case GLUT_KEY_LEFT:
            pressedkey=(0x6B <<1);
            bit=11;
            break;
        case GLUT_KEY_RIGHT:
            pressedkey=(0x74 <<1);
            bit=11;
            break;
    }
}

//callback for key release
void Special_input_release(int key, int x, int y) {
    switch(key) {
        case GLUT_KEY_UP:
            //keys[0] = 1;
            pressedkey=(0x29 <<1);
            bit=11;
            break;
        case GLUT_KEY_DOWN:
            //keys[1] = 1;
            pressedkey=(0x29 <<1);
            bit=11;
            break;
        case GLUT_KEY_LEFT:
            //keys[2] = 1;
            pressedkey=(0x29 <<1);
            bit=11;
            break;
        case GLUT_KEY_RIGHT:
            //keys[3] = 1;
            pressedkey=(0x29 <<1);
            bit=11;
            break;
    }
}

// initiate and handle graphics
void graphics_loop(int argc, char** argv) {
    glutInit(&argc, argv);
    glutInitDisplayMode(GLUT_SINGLE);
    glutInitWindowSize(ACTIVE_WIDTH, ACTIVE_HEIGHT+SEVEN_SEGMET_HEIGHT);
    glutInitWindowPosition(100, 100);
    int window=glutCreateWindow("Basys 3 Simulator");
    
    //seven segment subwindow
    sub2=glutCreateSubWindow(window, 0,ACTIVE_HEIGHT,ACTIVE_WIDTH, SEVEN_SEGMET_HEIGHT);
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
    font = FTGL::ftglCreatePixmapFont("./SevenSegment.ttf");

    //load bitmaps
    img_switch_on.readBMPFile("./SWon.bmp",false);
    img_switch_off.readBMPFile("./SWoff.bmp",false);
    img_board.readBMPFile("./board.bmp",false);

    glutDisplayFunc(render2);
    
    //VGA subwindow
    sub1=glutCreateSubWindow(window, 0,0,ACTIVE_WIDTH, ACTIVE_HEIGHT);
    glutDisplayFunc(render);
    
    glutKeyboardFunc(Keyboard_input);
    glutSpecialFunc(Special_input);
    glutSpecialUpFunc(Special_input_release);
    //glutIgnoreKeyRepeat(0); //report autorepeat keys    
    
    glutSetWindow(window);

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
    display->up = keys[0];
    display->down = keys[1];
    display->left = keys[2];
    display->right = keys[3];
    display->space = keys[4];
    display->enter = keys[5];
    
    for(int i=0; i<6; i++)
        keys[i] = 0;
}*/

// we only want the input to last for one or few clocks
/*void discard_input() {
    display->up = 0;
    display->down = 0;
    display->left = 0;
    display->right = 0;
    display->space = 0;
    display->enter = 0;
}*/

void sample_7s() {
    char key;
    char code= display->ca+
            2*display->cb+
            4*display->cc+
            8*display->cd+
            16*display->ce+
            32*display->cf+
            64*display->cg;

    switch (code) {
        case 0x3F: key='0'; break;
        case 0x06: key='1'; break;
        case 0x5B: key='2'; break;
        case 0x4F: key='3'; break;
        case 0x66: key='4'; break;
        case 0x6D: key='5'; break;
        case 0x7D: key='6'; break;
        case 0x07: key='7'; break;
        case 0x7F: key='8'; break;
        case 0x6F: key='9'; break;
        case 0x77: key='A'; break;
        case 0x7C: key='b'; break;
        case 0x39: key='C'; break;
        case 0x5E: key='d'; break;
        case 0x79: key='E'; break;
        case 0x71: key='F'; break;
        case 0x00: key=' '; break;
        case 0x40: key='-'; break;
        case 0x63: key='r'; break;
        case 0x76: key='U'; break;
        case 0x38: key='L'; break;
        case 0x54: key='D'; break;
        case 0x73: key='o'; break;
        case 0x5C: key='n'; break;
        default: key=' ';
    }

    for(int i=0; i<4; i++)
        ss[i] = ' ';
              
    if(display->an==14) ss[0]=key;
    if(display->an==13) ss[1]=key;
    if(display->an==11) ss[2]=key;
    if(display->an==7) ss[3]=key;
}
// read VGA outputs and update graphics buffer
void sample_pixel() {
    //discard_input();
    
    coord_x = (coord_x + 1) % TOTAL_WIDTH;

    if(!display->h_sync && pre_h_sync){ // on negative edge of h_sync
        // re-sync horizontal counter
        coord_x = RIGHT_PORCH + ACTIVE_WIDTH + HORIZONTAL_SYNC;
        coord_y = (coord_y + 1) % TOTAL_HEIGHT;
    }

    if(!display->v_sync && pre_v_sync){ // on negative edge of v_sync
        // re-sync vertical counter
        coord_y = TOP_PORCH + ACTIVE_HEIGHT + VERTICAL_SYNC;
        //apply_input(); // inputs are pulsed once each new frame
    }

    if(coord_x < ACTIVE_WIDTH && coord_y < ACTIVE_HEIGHT){
        int r = display->R_VAL;
        int g = display->G_VAL;
        int b = display->B_VAL;
        graphics_buffer[coord_x][coord_y][0] = float(r)/16.0;
        graphics_buffer[coord_x][coord_y][1] = float(g)/16.0;
        graphics_buffer[coord_x][coord_y][2] = float(b)/16.0;
    }

    pre_h_sync = display->h_sync;
    pre_v_sync = display->v_sync;
}

// simulate for a single clock
void tick() {
    // update simulation time
    main_time++;

    // rising edge
    display->clk = 1;
    display->eval();

    // falling edge
    display->clk = 0;
    
    //apply PS2 inputs
    if ((main_time % 10000) == 0) { // every 10ms
        display->KEYSIG_CLK = 1;
    }
    if ((main_time % 10000) == 5000) {
        if (bit==0) {
            display->KEYSIG_DATA = 1;
        }
        else {
            display->KEYSIG_CLK = 0; 
            display->KEYSIG_DATA = pressedkey & 0x1;
            pressedkey = pressedkey >>1; 
            bit--;
        }
    }

    //if ((main_time % 10000) == 0) { // every 10ms
    //        cout << "ss[0]: " << (int) ss[0] << endl;
    //}
    display->eval();
}

// globally reset the model
void reset() {
    display->reset = 1;
    display->clk = 0;
    display->eval();
    tick();
    display->reset = 0;
}

int main(int argc, char** argv) {
    
    bool vcd=false;

    if (argc==2)
        if (strcmp(argv[1],"-vcd")==0)
            vcd=true;
        
    
    // create a new thread for graphics handling
    thread thread(graphics_loop, argc, argv);
    // wait for graphics initialization to complete

    while(!gl_setup_complete);

    Verilated::commandArgs(argc, argv);   // remember args


    // create the model
    display = new Vdisplay;

    VerilatedVcdC* tfp = new VerilatedVcdC;
    if (vcd) {
        Verilated::traceEverOn(true);
        display->trace(tfp, 99);
        tfp->dumpvars(1, "TOP.display");
        tfp->dumpvars(1, "TOP.display.Snake");
        tfp->dumpvars(1, "TOP.display.CLKController");
        tfp->open("wave.vcd");
    }
    // reset the model
    reset();
    //display->s1 = 1;
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
    display->final();

    delete display;
}

