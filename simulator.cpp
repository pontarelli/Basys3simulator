#include <verilated.h>          // defines common routines
#include "verilated_vcd_c.h"
#include <GL/glut.h>
#include <thread>
#include <iostream>

#include "Vdisplay.h"           // from Verilating "display.v"

using namespace std;

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

// pixels are buffered here
float graphics_buffer[ACTIVE_WIDTH][ACTIVE_HEIGHT][3] = {};

// calculating each pixel's size in accordance to OpenGL system
// each axis in OpenGL is in the range [-1:1]
float pixel_w = 2.0 / ACTIVE_WIDTH;
float pixel_h = 2.0 / ACTIVE_HEIGHT;

// gets called periodically to update screen
void render(void) {
    glClear(GL_COLOR_BUFFER_BIT);
    
    // convert pixels into OpenGL rectangles
    for(int i = 0; i < ACTIVE_WIDTH; i++){
        for(int j = 0; j < ACTIVE_HEIGHT; j++){
            glColor3f(graphics_buffer[i][j][0], graphics_buffer[i][j][1], graphics_buffer[i][j][2]);
            glRectf(i*pixel_w-1, -j*pixel_h+1, (i+1)*pixel_w-1, -(j+1)*pixel_h+1);
        }
    }
    
    glFlush();
}

// timer to periodically update the screen
void glutTimer(int t) {
    glutPostRedisplay(); // re-renders the screen
    glutTimerFunc(t, glutTimer, t);
}

// handle up/down/left/right/space/enter arrow keys
int keys[6] = {};
int pressedkey = 0;
int bit=0;

void Keyboard_input(unsigned char key, int x, int y) {
    //cout << "key: " << key << endl;
    switch(key) {
        case 13: //ENTER
            pressedkey=(0x5A <<1);
            bit=9;
            keys[5] = 1;
            break;
        case 27: //ESC
            pressedkey=(0x76 <<1);
            bit=9;
            break;
        case 's': //'S'
            pressedkey=(0x1B <<1);
            bit=9;
            break;
        case 'p':
            pressedkey=(0x4D <<1);
            bit=9;
            break;
        case 'r':
            pressedkey=(0x2D <<1);
            bit=9;
            break;
        case ' ':
            pressedkey=(0x29 <<1);
            bit=9;
            keys[4] = 1;
            break;

    }
}

void Special_input(int key, int x, int y) {
    switch(key) {
        case GLUT_KEY_UP:
            keys[0] = 1;
            pressedkey=(0x75 <<1);
            bit=9;
            break;
        case GLUT_KEY_DOWN:
            keys[1] = 1;
            pressedkey=(0x72 <<1);
            bit=9;
            break;
        case GLUT_KEY_LEFT:
            keys[2] = 1;
            pressedkey=(0x6B <<1);
            bit=9;
            break;
        case GLUT_KEY_RIGHT:
            keys[3] = 1;
            pressedkey=(0x74 <<1);
            bit=9;
            break;
    }
}

// initiate and handle graphics
void graphics_loop(int argc, char** argv) {
    glutInit(&argc, argv);
    glutInitDisplayMode(GLUT_SINGLE);
    glutInitWindowSize(ACTIVE_WIDTH, ACTIVE_HEIGHT);
    glutInitWindowPosition(100, 100);
    glutCreateWindow("VGA Simulator");
    glutDisplayFunc(render);
    glutKeyboardFunc(Keyboard_input);
    glutSpecialFunc(Special_input);
    
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
void apply_input() {
    display->up = keys[0];
    display->down = keys[1];
    display->left = keys[2];
    display->right = keys[3];
    display->space = keys[4];
    display->enter = keys[5];
    
    for(int i=0; i<6; i++)
        keys[i] = 0;
}

// we only want the input to last for one or few clocks
void discard_input() {
    display->up = 0;
    display->down = 0;
    display->left = 0;
    display->right = 0;
    display->space = 0;
    display->enter = 0;
}

// read VGA outputs and update graphics buffer
void sample_pixel() {
    discard_input();
    
    coord_x = (coord_x + 1) % TOTAL_WIDTH;

    if(!display->h_sync && pre_h_sync){ // on negative edge of h_sync
        // re-sync horizontal counter
        coord_x = RIGHT_PORCH + ACTIVE_WIDTH + HORIZONTAL_SYNC;
        coord_y = (coord_y + 1) % TOTAL_HEIGHT;
    }

    if(!display->v_sync && pre_v_sync){ // on negative edge of v_sync
        // re-sync vertical counter
        coord_y = TOP_PORCH + ACTIVE_HEIGHT + VERTICAL_SYNC;
        apply_input(); // inputs are pulsed once each new frame
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
	discard_input();
        tick();
        tick();
        tick();
        // the clock frequency of VGA is 25 MHz of that of the whole model
        // so we sample from VGA every other clock
        sample_pixel();
        if (vcd) tfp->dump(main_time);
    }
    if (vcd) tfp->close();
    display->final();

    delete display;
}

