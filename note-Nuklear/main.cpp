/**
 * Nuklear + OpenGL
 *
 * TODO:
   - [ ] program struct
   - [ ] press space to lock or unlock camera movement
   - [ ] property panel
   - [ ] camera property panel
   - [ ] main panel
   - [ ] data driven
 */
#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <stdarg.h>
#include <string.h>
#include <math.h>
#include <assert.h>
#include <math.h>
#include <limits.h>
#include <time.h>
#include <iostream>

using namespace std;

#include <glad/glad.h>
#include <GLFW/glfw3.h>

#define STB_IMAGE_IMPLEMENTATION
#include <stb_image.h>

#define NK_INCLUDE_FIXED_TYPES
#define NK_INCLUDE_STANDARD_IO
#define NK_INCLUDE_STANDARD_VARARGS
#define NK_INCLUDE_DEFAULT_ALLOCATOR
#define NK_INCLUDE_VERTEX_BUFFER_OUTPUT
#define NK_INCLUDE_FONT_BAKING
#define NK_INCLUDE_DEFAULT_FONT
#define NK_IMPLEMENTATION
#define NK_GLFW_GL3_IMPLEMENTATION
#define NK_KEYSTATE_BASED_INPUT
#define NK_ZERO_COMMAND_MEMORY
#include "nuklear.h"
#include "nuklear_glfw_gl3.h"

#include "shader.h"
#include "camera.h"
#include "glm/glm.hpp"

#define WINDOW_WIDTH 960
#define WINDOW_HEIGHT 640

#define MAX_VERTEX_BUFFER 512 * 1024
#define MAX_ELEMENT_BUFFER 128 * 1024

void renderCube();
void mouse_callback(GLFWwindow* window, double xpos, double ypos);
void scroll_callback(GLFWwindow* window, double xoffset, double yoffset);
void processInput(GLFWwindow *window, float);

unsigned int loadTexture(char const * path);

static void error_callback(int e, const char *d)
{
    printf("Error %d: %s\n", e, d);
}

enum { OP_A, OP_B, OP_C, OP_D };

struct StState {
    int id;
    const char * Panel2Name;
    const char * Panel3Name;
    enum nk_collapse_states caseTreeState;
    float sliderValue;
    size_t progressValue;
    int option;
    int checkboxValues[3];
    int selectLabelValue;
    struct nk_color comboColor;
};

typedef struct StState StState;
static StState G;


Camera camera(glm::vec3(0.0f, 0.0f, 2.0f));
float lastX = WINDOW_WIDTH / 2.0f;
float lastY = WINDOW_HEIGHT / 2.0f;
bool firstMouse = true;
glm::mat4 mvp(1.0);

Shader* pShader = NULL;


int initState() {
    G.id = 0;
    G.Panel2Name = "Nuklear!";
    G.Panel3Name = "Property Panel";
    G.caseTreeState = NK_MAXIMIZED;
    G.sliderValue = 0;
    G.progressValue = 0;
    G.option = OP_A;
    memset(G.checkboxValues, nk_false, sizeof(G.checkboxValues));
    G.selectLabelValue = nk_true;
    G.comboColor = nk_rgba(75, 227, 62, 255);

    printf("sizeof(short) = %lu\n", sizeof(StState));
    return 0;
}


void propertyVec2(struct nk_context *ctx, float* x, float* y, struct nk_vec2 size /* nk_vec2(200, 200) */ )
{
    static char buffer[32];
    sprintf(buffer, "%.2f, %.2f", *x, *y);
    if (nk_combo_begin_label(ctx, buffer, size)) {
        nk_layout_row_dynamic(ctx, 25, 1);
        nk_property_float(ctx, "#X:", -1024.0f, x, 1024.0f, 1, 0.5f);
        nk_property_float(ctx, "#Y:", -1024.0f, y, 1024.0f, 1, 0.5f);
        nk_combo_end(ctx);
    }
}
void propertyVec3(struct nk_context *ctx, float* x, float* y, float* z, struct nk_vec2 size /* nk_vec2(200, 200) */)
{
    static char buffer[32];
    sprintf(buffer, "%.2f, %.2f, %.2f", *x, *y, *z);
    if (nk_combo_begin_label(ctx, buffer, size)) {
        nk_layout_row_dynamic(ctx, 25, 1);
        nk_property_float(ctx, "#X:", -1024.0f, x, 1024.0f, 1, 0.5f);
        nk_property_float(ctx, "#Y:", -1024.0f, y, 1024.0f, 1, 0.5f);
        nk_property_float(ctx, "#Z:", -1024.0f, z, 1024.0f, 1, 0.5f);
        nk_combo_end(ctx);
    }
}
void propertyColor(struct nk_context *ctx, struct nk_colorf *colorf, struct nk_vec2 size /* nk_vec2(200, 200) */)
{
    if (nk_combo_begin_color(ctx, nk_rgb_cf(*colorf), size)) {
        enum color_mode {COL_RGB, COL_HSV};
        static int col_mode = COL_RGB;

        nk_layout_row_dynamic(ctx, 120, 1);
        *colorf = nk_color_picker(ctx, *colorf, NK_RGBA);

        nk_layout_row_dynamic(ctx, 25, 2);
        col_mode = nk_option_label(ctx, "RGB", col_mode == COL_RGB) ? COL_RGB : col_mode;
        col_mode = nk_option_label(ctx, "HSV", col_mode == COL_HSV) ? COL_HSV : col_mode;

        nk_layout_row_dynamic(ctx, 25, 1);
        if (col_mode == COL_RGB) {
            (*colorf).r = nk_propertyf(ctx, "#R:", 0, (*colorf).r, 1.0f, 0.01f, 0.005f);
            (*colorf).g = nk_propertyf(ctx, "#G:", 0, (*colorf).g, 1.0f, 0.01f, 0.005f);
            (*colorf).b = nk_propertyf(ctx, "#B:", 0, (*colorf).b, 1.0f, 0.01f, 0.005f);
            (*colorf).a = nk_propertyf(ctx, "#A:", 0, (*colorf).a, 1.0f, 0.01f, 0.005f);
        } else {
            float hsva[4];
            nk_colorf_hsva_fv(hsva, *colorf);
            hsva[0] = nk_propertyf(ctx, "#H:", 0, hsva[0], 1.0f, 0.01f, 0.05f);
            hsva[1] = nk_propertyf(ctx, "#S:", 0, hsva[1], 1.0f, 0.01f, 0.05f);
            hsva[2] = nk_propertyf(ctx, "#V:", 0, hsva[2], 1.0f, 0.01f, 0.05f);
            hsva[3] = nk_propertyf(ctx, "#A:", 0, hsva[3], 1.0f, 0.01f, 0.05f);
            (*colorf) = nk_hsva_colorfv(hsva);
        }
        nk_combo_end(ctx);
    }
}

int main(void)
{
    initState();

    /* Platform */
    static GLFWwindow *win;
    int width = 0, height = 0;
    struct nk_context *ctx;
    struct nk_colorf bg;

    /* GLFW */
    glfwSetErrorCallback(error_callback);
    if (!glfwInit()) {
        fprintf(stdout, "[GFLW] failed to init!\n");
        exit(1);
    }

    glfwWindowHint(GLFW_CONTEXT_VERSION_MAJOR, 3);
    glfwWindowHint(GLFW_CONTEXT_VERSION_MINOR, 3);
    glfwWindowHint(GLFW_OPENGL_PROFILE, GLFW_OPENGL_CORE_PROFILE);

#ifdef __APPLE__
    glfwWindowHint(GLFW_OPENGL_FORWARD_COMPAT, GL_TRUE);
#endif
    win = glfwCreateWindow(WINDOW_WIDTH, WINDOW_HEIGHT, "Demo GLFW Window", NULL, NULL);
    glfwMakeContextCurrent(win);
    glfwGetWindowSize(win, &width, &height);
    glfwSetCursorPosCallback(win, mouse_callback);
    glfwSetScrollCallback(win, scroll_callback);

    /* OpenGL */
    gladLoadGL();
    glViewport(0, 0, WINDOW_WIDTH, WINDOW_HEIGHT);

    std::string vertexShaderPath = "vertex.vs";
    std::string fragmentShaderPath = "fragment.fs";
    pShader = new Shader(vertexShaderPath.c_str(), fragmentShaderPath.c_str());
    if (!pShader) {
        std::cout << "pShader is NULL." << std::endl;
    }

	//////////////////////////////////////////
	// for texture
	static int texture0 = loadTexture("container.jpg");

	pShader->use();
	pShader->setInt("texture0", 0);
	//////////////////////////////////////////

    ctx = nk_glfw3_init(win, NK_GLFW3_INSTALL_CALLBACKS);
    /* Load Fonts: if none of these are loaded a default font will be used  */
    /* Load Cursor: if you uncomment cursor loading please hide the cursor */
    {struct nk_font_atlas *atlas;
        nk_glfw3_font_stash_begin(&atlas);
        /*struct nk_font *droid = nk_font_atlas_add_from_file(atlas, "../../../extra_font/DroidSans.ttf", 14, 0);*/
        /*struct nk_font *roboto = nk_font_atlas_add_from_file(atlas, "../../../extra_font/Roboto-Regular.ttf", 14, 0);*/
        /*struct nk_font *future = nk_font_atlas_add_from_file(atlas, "../../../extra_font/kenvector_future_thin.ttf", 13, 0);*/
        /*struct nk_font *clean = nk_font_atlas_add_from_file(atlas, "../../../extra_font/ProggyClean.ttf", 12, 0);*/
        /*struct nk_font *tiny = nk_font_atlas_add_from_file(atlas, "../../../extra_font/ProggyTiny.ttf", 10, 0);*/
        /*struct nk_font *cousine = nk_font_atlas_add_from_file(atlas, "../../../extra_font/Cousine-Regular.ttf", 13, 0);*/
        nk_glfw3_font_stash_end();
        /*nk_style_load_all_cursors(ctx, atlas->cursors);*/
        /*nk_style_set_font(ctx, &droid->handle);*/
    }

    bg.r = 0.10f, bg.g = 0.18f, bg.b = 0.24f, bg.a = 1.0f;
    int cacheProperty = 0;
    float ratioProperty = 0;
    static int checkboxValue = nk_true;

    short frameCount = 120;
    double timePerFrame = 1.0 / frameCount;
    double lastFrame = 0;
    double currentFrame = 0;

    double deltaFrame = 0;
    unsigned long frameCountPerSec = 0;
    unsigned int currentRunSec = 0;
    unsigned int lastRunSec = 0;
    unsigned long clockCount = 0;
    double fps = 0;
    double sumFrameCost = 0;

    while (!glfwWindowShouldClose(win))
    {
        clockCount++;
        currentFrame = glfwGetTime();
        deltaFrame = currentFrame - lastFrame;

        if (deltaFrame < timePerFrame) {
            continue;
        }

        frameCountPerSec++;
        sumFrameCost += deltaFrame;
        currentRunSec = (int)currentFrame;
        lastRunSec = (int)lastFrame;
        lastFrame = currentFrame;
        fps = frameCountPerSec / sumFrameCost;

        if (sumFrameCost >= 1.0) {
            //            printf("last sec = %d   current sec = %d  count = %lu clockCount = %lu fps = %f sumFrameCost = %f\n", lastRunSec, currentRunSec, frameCountPerSec, clockCount, fps, sumFrameCost);
            frameCountPerSec = 0;
            clockCount = 0;
            sumFrameCost = 0;
        }

        glm::mat4 projection = glm::perspective(glm::radians(camera.Zoom), (float)WINDOW_WIDTH / (float)WINDOW_HEIGHT, 0.1f, 100.0f);
        glm::mat4 view = camera.GetViewMatrix();
        mvp = projection * view;

        processInput(win, (float)deltaFrame);

        /* Input */
        glfwPollEvents();
        nk_glfw3_new_frame();

        //if (nk_begin(ctx, "panel 1", nk_rect(400, 10, 300, 400), NK_WINDOW_MOVABLE | NK_WINDOW_CLOSABLE | NK_WINDOW_TITLE)) {
        //    static enum nk_collapse_states state = NK_MAXIMIZED;
        //    nk_menubar_begin(ctx);
        //    nk_layout_row_dynamic(ctx, 30, 1);
        //    if (nk_menu_begin_label(ctx, "ADVANCED", NK_TEXT_LEFT, nk_vec2(200, 600))) {
        //        if (nk_tree_state_push(ctx, NK_TREE_TAB, "FILE", &state)) {
        //            nk_menu_item_label(ctx, "New", NK_TEXT_LEFT);
        //            nk_menu_item_label(ctx, "Open", NK_TEXT_LEFT);
        //            nk_menu_item_label(ctx, "Save", NK_TEXT_LEFT);
        //            nk_menu_item_label(ctx, "Close", NK_TEXT_LEFT);
        //            nk_menu_item_label(ctx, "Exit", NK_TEXT_LEFT);
        //            nk_tree_pop(ctx);
        //        }
        //        nk_menu_end(ctx);
        //    }
        //    nk_menubar_end(ctx);
        //}
        //nk_end(ctx);

        static int popup_active = nk_false;

        if (nk_begin(ctx, G.Panel2Name, nk_rect(450, 10, 300, 400), NK_WINDOW_MOVABLE | NK_WINDOW_CLOSABLE | NK_WINDOW_TITLE | NK_WINDOW_MINIMIZABLE))
        {
            nk_layout_row_dynamic(ctx, 30 * 3 + 60, 1);
            if (nk_group_begin(ctx, "Case 3x3", NK_WINDOW_NO_SCROLLBAR | NK_WINDOW_BORDER | NK_WINDOW_TITLE))
            {
                nk_layout_row_dynamic(ctx, 30, 3);
//                nk_spacing(ctx, 1);

                // row 1 col 1
                if (nk_button_label(ctx, "1")) {
                    printf("box 1\n");
                }
                // row 1 col 2
                if (nk_button_label(ctx, "2")) {
                    printf("box 2\n");
                }
                // row 1 col 3
                if (nk_button_label(ctx, "3")) {
                    printf("box 3\n");
                }

                // row 2 col 1
                if (nk_button_label(ctx, "4")) {
                    printf("box 4\n");
                }
                // row 2 col 2
                if (nk_button_label(ctx, "5")) {
                    printf("box 5\n");
                }
                // row 2 col 3
                if (nk_button_label(ctx, "6")) {
                    printf("box 6\n");
                }

                // row 3 col 1
                if (nk_button_label(ctx, "7")) {
                    printf("box 7\n");
                }
                // row 3 col 2
                if (nk_button_label(ctx, "8")) {
                    printf("box 8\n");
                }
                // row 3 col 3
                if (nk_button_label(ctx, "9")) {
                    printf("box 9\n");
                }

                nk_group_end(ctx);
            }

            nk_layout_row_dynamic(ctx, 330, 1);
            if (nk_group_begin(ctx, "Case Tree", NK_WINDOW_BORDER | NK_WINDOW_TITLE)) {

                if (nk_tree_state_push(ctx, NK_TREE_TAB, "NK_TREE_TAB", &G.caseTreeState)) {

                    nk_label(ctx, "I am a label", NK_TEXT_LEFT);

                    float min_value = 0.0f, max_value = 100.0f, value_step = 0.01f;
                    nk_slider_float(ctx, min_value, &G.sliderValue, max_value, value_step);

                    G.progressValue = (size_t)(G.sliderValue / max_value * 100);
                    nk_progress(ctx, &G.progressValue, (int)max_value, NK_FIXED/*NK_FIXED or NK_MODIFIABLE*/);

                    // option A B C D
                    nk_layout_row_dynamic(ctx, 30, 4);

                    G.option = nk_option_label(ctx, "A", G.option == OP_A) ? OP_A : G.option;
                    G.option = nk_option_label(ctx, "B", G.option == OP_B) ? OP_B : G.option;
                    G.option = nk_option_label(ctx, "C", G.option == OP_C) ? OP_C : G.option;
                    G.option = nk_option_label(ctx, "D", G.option == OP_D) ? OP_D : G.option;

                    // 3 checkbox
                    nk_layout_row_dynamic(ctx, 30, 3);
                    char checkboxName[10] = "";
                    for (uint8_t i = 0; i < 3; i++) {
                        sprintf(checkboxName, "box %d", i + 1);

                        if (nk_checkbox_label(ctx, checkboxName, &G.checkboxValues[i])) {
                            G.checkboxValues[i] ? printf("select %s\n", checkboxName) : printf("unselect %s\n", checkboxName);
                        }
                    }

                    nk_tree_pop(ctx);
                }

                if (nk_tree_state_push(ctx, NK_TREE_NODE, "NK_TREE_NODE", &G.caseTreeState)) {

                    nk_selectable_label(ctx, G.selectLabelValue ? "Select" : "Unselect", NK_TEXT_LEFT, &G.selectLabelValue);

                    nk_layout_row_dynamic(ctx, 25, 1);
                    if (nk_combo_begin_color(ctx, G.comboColor, nk_vec2(nk_widget_width(ctx), 400))) {
                        nk_layout_row_dynamic(ctx, 120, 1);

                        G.comboColor = nk_rgba_cf(nk_color_picker(ctx, nk_color_cf(G.comboColor), NK_RGBA));
                        nk_layout_row_dynamic(ctx, 25, 1);
                        G.comboColor.r = nk_propertyi(ctx, "#R:", 0, G.comboColor.r, 255, 1, 1);
                        G.comboColor.g = nk_propertyf(ctx, "#G:", 0, G.comboColor.g, 255, 1, 1);
                        G.comboColor.b = nk_propertyf(ctx, "#B:", 0, G.comboColor.b, 255, 1, 1);
                        G.comboColor.a = nk_propertyf(ctx, "#A:", 0, G.comboColor.a, 255, 1, 1);
                        nk_combo_end(ctx);
                    }

                    nk_tree_pop(ctx);
                }

                nk_group_end(ctx);
            }

            nk_layout_row_dynamic(ctx, 116, 1);
            if (nk_group_begin(ctx, "Case Menu", NK_WINDOW_TITLE)) {

                static size_t prog = 40;
                static int slider = 10;
                static int check = nk_true;

                nk_menubar_begin(ctx);
                //            static      h   item_w  cols
                nk_layout_row_static(ctx, 25, 60, 4);

                if (nk_menu_begin_label(ctx, "MENU", NK_TEXT_LEFT, nk_vec2(120, 200)))
                {
                    //            dynamic      h  cols
                    nk_layout_row_dynamic(ctx, 25, 1);

                    if (nk_menu_item_label(ctx, "Hide", NK_TEXT_LEFT)) {
                        printf("Hide\n");
                    }

                    if (nk_menu_item_label(ctx, "About", NK_TEXT_LEFT)) {
                        printf("About\n");
                    }

                    nk_progress(ctx, &prog, 100, NK_MODIFIABLE);
                    nk_slider_int(ctx, 0, &slider, 16, 1);
                    nk_checkbox_label(ctx, "check", &check);

                    nk_menu_end(ctx);
                }

                //                nk_layout_row_static(ctx, 30, 70, 3);
                nk_progress(ctx, &prog, 100, NK_MODIFIABLE);
                nk_slider_int(ctx, 0, &slider, 16, 1);
                nk_checkbox_label(ctx, "yes?", &check);

                nk_menubar_end(ctx);

                nk_group_end(ctx);
            }

            if (nk_group_begin(ctx, "Case 3", NK_WINDOW_NO_SCROLLBAR | NK_WINDOW_BORDER | NK_WINDOW_TITLE)) {
                nk_layout_row_dynamic(ctx, 25, 3);

                if (nk_button_label(ctx, "Group")) {
                    printf("Group\n");
                }

                if (nk_button_label(ctx, "Popup")) {
                    popup_active = nk_true;

                }
                nk_button_label(ctx, "#FFCC");
                nk_button_label(ctx, "#FFDD");
                nk_button_label(ctx, "#FFEE");
                nk_button_label(ctx, "#FFFF");

                nk_group_end(ctx);
            }

            //if (popup_active) {
            //    static struct nk_rect s = { 20, 100, 220, 90 };
            //    if (nk_popup_begin(ctx, NK_POPUP_STATIC, "Dialog Title", 0, s))
            //    {
            //        nk_layout_row_dynamic(ctx, 25, 1);
            //        nk_label(ctx, "Dialog content", NK_TEXT_CENTERED);

            //        nk_layout_row_dynamic(ctx, 25, 2);
            //        if (nk_button_label(ctx, "OK")) {
            //            popup_active = 0;
            //            nk_popup_close(ctx);
            //        }
            //        if (nk_button_label(ctx, "Cancel")) {
            //            popup_active = 0;
            //            nk_popup_close(ctx);
            //        }

            //        nk_popup_end(ctx);
            //    }
            //    else {
            //        popup_active = nk_false;
            //    }
            //}
        }
        nk_end(ctx);

        if (nk_begin(ctx, G.Panel3Name, nk_rect(200, 100, 200, 200), NK_WINDOW_MOVABLE | NK_WINDOW_CLOSABLE | NK_WINDOW_TITLE | NK_WINDOW_MINIMIZABLE)) {
            nk_layout_row_dynamic(ctx, 25, 1);
            nk_button_label(ctx, "a button is in panel");

            static char buffer[30];
            static float position[3];
            sprintf(buffer, "%.2f, %.2f, %.2f", position[0], position[1],position[2]);
            if (nk_combo_begin_label(ctx, buffer, nk_vec2(200, 200))) {
                nk_layout_row_dynamic(ctx, 25, 1);
                nk_property_float(ctx, "#X:", -1024.0f, &position[0], 1024.0f, 1,0.5f);
                nk_property_float(ctx, "#Y:", -1024.0f, &position[1], 1024.0f, 1,0.5f);
                nk_property_float(ctx, "#Z:", -1024.0f, &position[2], 1024.0f, 1,0.5f);
                nk_combo_end(ctx);
            }

            static float vec3A[3];
            propertyVec3(ctx, &vec3A[0], &vec3A[1], &vec3A[2], nk_vec2(220, 200));

            static float positionB[3];
            propertyVec3(ctx, &positionB[0], &positionB[1], &positionB[2], nk_vec2(220, 200));

            static float positionC[2] = {2.0, 33.0};
            propertyVec2(ctx, &positionC[0], &positionC[1], nk_vec2(200, 200));

            static struct nk_colorf combo_color1_1 = {0.509f, 0.705f, 0.2f, 1.0f};
            propertyColor(ctx, &combo_color1_1, nk_vec2(200,400));

            static struct nk_colorf combo_color2 = {0.509f, 0.705f, 0.2f, 1.0f};
            static char sColor2[16];
            memset(sColor2, 0, sizeof(sColor2));
            nk_color_hex_rgba(sColor2, nk_rgba_cf(combo_color2));
            sprintf(sColor2, " %s", sColor2);
            nk_label(ctx, sColor2, NK_TEXT_LEFT);

            if (nk_combo_begin_color(ctx, nk_rgb_cf(combo_color2), nk_vec2(200,400))) {
                enum color_mode {COL_RGB, COL_HSV};
                static int col_mode = COL_RGB;

                nk_layout_row_dynamic(ctx, 120, 1);
                combo_color2 = nk_color_picker(ctx, combo_color2, NK_RGBA);

                nk_layout_row_dynamic(ctx, 25, 2);
                col_mode = nk_option_label(ctx, "RGB", col_mode == COL_RGB) ? COL_RGB : col_mode;
                col_mode = nk_option_label(ctx, "HSV", col_mode == COL_HSV) ? COL_HSV : col_mode;

                nk_layout_row_dynamic(ctx, 25, 1);
                if (col_mode == COL_RGB) {
                    combo_color2.r = nk_propertyf(ctx, "#R:", 0, combo_color2.r, 1.0f, 0.01f, 0.005f);
                    combo_color2.g = nk_propertyf(ctx, "#G:", 0, combo_color2.g, 1.0f, 0.01f, 0.005f);
                    combo_color2.b = nk_propertyf(ctx, "#B:", 0, combo_color2.b, 1.0f, 0.01f, 0.005f);
                    combo_color2.a = nk_propertyf(ctx, "#A:", 0, combo_color2.a, 1.0f, 0.01f, 0.005f);
                } else {
                    float hsva[4];
                    nk_colorf_hsva_fv(hsva, combo_color2);
                    hsva[0] = nk_propertyf(ctx, "#H:", 0, hsva[0], 1.0f, 0.01f, 0.05f);
                    hsva[1] = nk_propertyf(ctx, "#S:", 0, hsva[1], 1.0f, 0.01f, 0.05f);
                    hsva[2] = nk_propertyf(ctx, "#V:", 0, hsva[2], 1.0f, 0.01f, 0.05f);
                    hsva[3] = nk_propertyf(ctx, "#A:", 0, hsva[3], 1.0f, 0.01f, 0.05f);
                    combo_color2 = nk_hsva_colorfv(hsva);
                }
                nk_combo_end(ctx);
            }
        }
        nk_end(ctx);

        /* GUI */
        if (nk_begin(ctx, "Demo GUI", nk_rect(10, 10, 300, 400),
                     NK_WINDOW_BORDER | NK_WINDOW_MOVABLE | NK_WINDOW_SCALABLE |
                     NK_WINDOW_MINIMIZABLE | NK_WINDOW_TITLE))
        {
            struct nk_rect bounds;
            static int show_menu;
            static int show_app_about;
            static int select[4];

            /* menu contextual */
            nk_layout_row_static(ctx, 30, 160, 1);
            bounds = nk_widget_bounds(ctx);
            nk_label(ctx, "Right click me for menu", NK_TEXT_LEFT);

            if (nk_contextual_begin(ctx, 0, nk_vec2(100, 300), bounds)) {
                static size_t prog = 40;
                static int slider = 10;

                nk_layout_row_dynamic(ctx, 25, 1);
                nk_checkbox_label(ctx, "Menu", &show_menu);
                nk_progress(ctx, &prog, 100, NK_MODIFIABLE);
                nk_slider_int(ctx, 0, &slider, 16, 1);
                if (nk_contextual_item_label(ctx, "About", NK_TEXT_CENTERED))
                    show_app_about = nk_true;
                nk_selectable_label(ctx, select[0] ? "Select" : "Unselect", NK_TEXT_LEFT, &select[0]);
                nk_selectable_label(ctx, select[1] ? "Select" : "Unselect", NK_TEXT_LEFT, &select[1]);
                nk_selectable_label(ctx, select[2] ? "Select" : "Unselect", NK_TEXT_LEFT, &select[2]);
                nk_selectable_label(ctx, select[3] ? "Select" : "Unselect", NK_TEXT_LEFT, &select[3]);
                nk_contextual_end(ctx);
            }


            enum { EASY, HARD, NORMAL };
            static int op = EASY;

            static int property = 20;

            // button
            nk_layout_row_static(ctx, 30, 80, 1);
            if (nk_button_label(ctx, "button")) {

                fprintf(stdout, "button pressed\n");

                //nk_window_show(ctx, "panel 1", NK_SHOWN);
                nk_window_show(ctx, G.Panel2Name, NK_SHOWN);
            }

            // radio
            nk_layout_row_dynamic(ctx, 30, 2);
            if (nk_option_label(ctx, "easy", op == EASY))
                op = EASY;
            if (nk_option_label(ctx, "hard", op == HARD))
                op = HARD;
            if (nk_option_label(ctx, "NORMAL", op == NORMAL)) {
                op = NORMAL;
                nk_window_show(ctx, G.Panel3Name, NK_SHOWN);
            }

            // group
            //            nk_layout_row_dynamic(ctx, 200, 2); // wrapping row
            //            if (nk_group_begin(ctx, "column1", NK_WINDOW_BORDER)) { // column 1
            //                nk_layout_row_dynamic(ctx, 30, 1); // nested row
            //                nk_label(ctx, "column 1.1", NK_TEXT_CENTERED);
            //
            //                nk_layout_row_dynamic(ctx, 30, 1);
            //                nk_label(ctx, "column 1.2", NK_TEXT_CENTERED);
            //
            //                nk_group_end(ctx);
            //            }
            //            if (nk_group_begin(ctx, "column2", NK_WINDOW_BORDER)) { // column 2
            //                nk_layout_row_dynamic(ctx, 30, 1);
            //                nk_label(ctx, "column 2.1", NK_TEXT_CENTERED);
            //
            //                nk_layout_row_dynamic(ctx, 30, 1);
            //                nk_label(ctx, "column 2.2", NK_TEXT_CENTERED);
            //
            //                nk_group_end(ctx);
            //            }

            // checkbox
            nk_layout_row_dynamic(ctx, 30, 1);
            //            static int checkboxValue = nk_true;
            nk_checkbox_label(ctx, "Checkbox", &checkboxValue);

            // label + slider + progress
            nk_layout_row_dynamic(ctx, 30, 1);
            static float aSliderFloatValue = 0;
            static char strSliderValue[10] = "";
            static nk_size v = 0;
            sprintf(strSliderValue, "%.2f", aSliderFloatValue);
            nk_label(ctx, strSliderValue, NK_TEXT_LEFT);
            nk_slider_float(ctx, 0.0f, &aSliderFloatValue, 100.0f, 0.01f);
            v = atof(strSliderValue);
            nk_progress(ctx, &v, 100, NK_FIXED);
            ratioProperty = aSliderFloatValue / 100.0f;

            // text edit
            static int field_len = 0;
            static char field_buffer[100] = "";
            nk_label(ctx, "Field:", NK_TEXT_LEFT);
            nk_edit_string(ctx, NK_EDIT_FIELD, field_buffer, &field_len, 64, nk_filter_default);
            // text edit with redo/undo
            static struct nk_text_edit stTextEdit;
            static int isInitTextEdit = 0;
            if (isInitTextEdit == 0)
            {
                nk_textedit_init_default(&stTextEdit);
                isInitTextEdit = 1;
            }
            nk_label(ctx, "Field Buffer:", NK_TEXT_CENTERED);
            nk_edit_buffer(ctx, NK_EDIT_FIELD, &stTextEdit, nk_filter_ascii);

            // int type property
            {
                nk_layout_row_dynamic(ctx, 25, 1);
                nk_property_int(ctx, "Compression:", 0, &property, 100, 10, 1);

                // check cache data
                //if (cacheProperty != property) {
                //    fprintf(stdout, "update property from [%d] to [%d]\n", cacheProperty, property);
                //    cacheProperty = property;
                //}
                if (memcmp(&cacheProperty, &property, sizeof(int)) != 0) {
                    fprintf(stdout, "update property from [%d] to [%d]\n", cacheProperty, property);
                    cacheProperty = property;
                }
            }

            nk_layout_row_dynamic(ctx, 40, 1);
            nk_label(ctx, "background:", NK_TEXT_LEFT); //nk_label(ctx, "background:", NK_TEXT_CENTERED);

            // combo color
            {
                nk_layout_row_dynamic(ctx, 25, 1);
                if (nk_combo_begin_color(ctx, nk_rgb_cf(bg), nk_vec2(nk_widget_width(ctx), 400))) {
                    nk_layout_row_dynamic(ctx, 120, 1);
                    bg = nk_color_picker(ctx, bg, NK_RGBA);
                    nk_layout_row_dynamic(ctx, 25, 1);
                    bg.r = nk_propertyf(ctx, "#R:", 0, bg.r, 1.0f, 0.01f, 0.005f);
                    bg.g = nk_propertyf(ctx, "#G:", 0, bg.g, 1.0f, 0.01f, 0.005f);
                    bg.b = nk_propertyf(ctx, "#B:", 0, bg.b, 1.0f, 0.01f, 0.005f);
                    bg.a = nk_propertyf(ctx, "#A:", 0, bg.a, 1.0f, 0.01f, 0.005f);
                    nk_combo_end(ctx);
                }
            }

            // nk_selectable_label
            {
                //static int selected = nk_true;
                //static int lastSelected = nk_true;
                //nk_layout_row_dynamic(ctx, 30, 1);
                //nk_selectable_label(ctx, "label_1", NK_TEXT_LEFT, &selected);
                //if (lastSelected != selected) {
                //    printf("selected = %d\n", selected);
                //    lastSelected = selected;
                //}
            }

            //-------------------------------------------------------
            // row layout
            //            {
            //                nk_layout_row_begin(ctx, NK_STATIC, 22, 1);
            //                {
            //                    nk_layout_row_push(ctx, 100);
            //                    nk_label(ctx, "First Row", NK_TEXT_LEFT);
            //
            //
            //                    nk_layout_row_push(ctx, 100);
            //                    nk_label(ctx, "Second Row", NK_TEXT_LEFT);
            //
            //                    nk_layout_row_push(ctx, 100);
            //                    nk_label(ctx, "Third Row", NK_TEXT_LEFT);
            //                }
            //                nk_layout_row_end(ctx);
            //            }
            //            //-------------------------------------------------------
            //            {
            //                nk_layout_row_static(ctx, 22, 80, 1);
            //                nk_label(ctx, "First", NK_TEXT_LEFT);
            //
            //                nk_layout_row_static(ctx, 22, 80, 1);
            //                nk_label(ctx, "Second", NK_TEXT_LEFT);
            //
            //                nk_layout_row_static(ctx, 22, 80, 1);
            //                nk_label(ctx, "Third", NK_TEXT_LEFT);
            //            }
            //-------------------------------------------------------


        }
        nk_end(ctx);

//        nk_window_close(ctx, "Overview");
//        nk_window_collapse(ctx, "Demo GUI", NK_MINIMIZED);


        /* Draw */
        //        glfwGetWindowSize(win, &width, &height);
        //        glViewport(0, 0, width, height);
        glEnable(GL_DEPTH_TEST);
        glClear(GL_COLOR_BUFFER_BIT|GL_DEPTH_BUFFER_BIT);
        glClearColor(bg.r, bg.g, bg.b, bg.a);

        // draw quad
//        {
//            static const char *vertexShaderSource = "#version 330 core\n"
//            "layout (location = 0) in vec3 aPos;\n"
//            "void main()\n"
//            "{\n"
//            "   gl_Position = vec4(aPos.x, aPos.y, aPos.z, 1.0);\n"
//            "}\0";
//            static const char *fragmentShaderSource = "#version 330 core\n"
//            "out vec4 FragColor;\n"
//            "uniform float uRatio;\n"
//            "void main()\n"
//            "{\n"
//            "   FragColor = mix(vec4(1.0f, 0.5f, 0.2f, 1.0f), vec4(1.0), uRatio);\n"
//            "}\n\0";
//
//            static int shaderProgram;
//            static unsigned int VBO, VAO, EBO;
//            static float vertices[] = {
//                0.5f,  0.5f, 0.0f,  // top right
//                0.5f, -0.5f, 0.0f,  // bottom right
//                -0.5f, -0.5f, 0.0f,  // bottom left
//                -0.5f,  0.5f, 0.0f   // top left
//            };
//
//            static unsigned int indices[] = {  // note that we start from 0!
//                0, 1, 3,  // first Triangle
//                1, 2, 3   // second Triangle
//            };
//
//            if (shaderProgram == 0) {
//                int vertexShader = glCreateShader(GL_VERTEX_SHADER);
//                glShaderSource(vertexShader, 1, &vertexShaderSource, NULL);
//                glCompileShader(vertexShader);
//                // check for shader compile errors
//                int success;
//                char infoLog[512];
//                glGetShaderiv(vertexShader, GL_COMPILE_STATUS, &success);
//                if (!success)
//                {
//                    glGetShaderInfoLog(vertexShader, 512, NULL, infoLog);
//                    printf("ERROR::SHADER::VERTEX::COMPILATION_FAILED\n%s\n", infoLog);
//                }
//                // fragment shader
//                int fragmentShader = glCreateShader(GL_FRAGMENT_SHADER);
//                glShaderSource(fragmentShader, 1, &fragmentShaderSource, NULL);
//                glCompileShader(fragmentShader);
//                // check for shader compile errors
//                glGetShaderiv(fragmentShader, GL_COMPILE_STATUS, &success);
//                if (!success)
//                {
//                    glGetShaderInfoLog(fragmentShader, 512, NULL, infoLog);
//                    printf("ERROR::SHADER::FRAGMENT::COMPILATION_FAILED\n%s\n", infoLog);
//                }
//                // link shaders
//                shaderProgram = glCreateProgram();
//                glAttachShader(shaderProgram, vertexShader);
//                glAttachShader(shaderProgram, fragmentShader);
//                glLinkProgram(shaderProgram);
//                // check for linking errors
//                glGetProgramiv(shaderProgram, GL_LINK_STATUS, &success);
//                if (!success) {
//                    glGetProgramInfoLog(shaderProgram, 512, NULL, infoLog);
//                    printf("ERROR::SHADER::PROGRAM::LINKING_FAILED\n%s\n", infoLog);
//                }
//                glDeleteShader(vertexShader);
//                glDeleteShader(fragmentShader);
//
//
//
//                glGenVertexArrays(1, &VAO);
//                glGenBuffers(1, &VBO);
//                glGenBuffers(1, &EBO);
//
//                glBindVertexArray(VAO);
//
//                glBindBuffer(GL_ARRAY_BUFFER, VBO);
//                glBufferData(GL_ARRAY_BUFFER, sizeof(vertices), vertices, GL_STATIC_DRAW);
//
//                glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, EBO);
//                glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeof(indices), indices, GL_STATIC_DRAW);
//
//                glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, 3 * sizeof(float), (void*)0);
//                glEnableVertexAttribArray(0);
//
//                glBindBuffer(GL_ARRAY_BUFFER, 0);
//                glBindVertexArray(0);
//            }
//
//
//            if (checkboxValue) {
//                glUseProgram(shaderProgram);
//                int uRatio = glGetUniformLocation(shaderProgram, "uRatio");
//                glUniform1f(uRatio, ratioProperty);
//                glBindVertexArray(VAO);
//                glDrawElements(GL_TRIANGLES, 6, GL_UNSIGNED_INT, 0);
//            }
//        }

        pShader->use();

		glActiveTexture(GL_TEXTURE0);
		glBindTexture(GL_TEXTURE_2D, texture0);

        glm::vec3 vT = glm::vec3(-0.5, -0.2, -3.0);
        glm::mat4 mvp_1 = glm::translate(mvp, vT);
        pShader->setMat4("mvp", mvp_1);
        pShader->setMat4("uMat4Model", glm::translate(glm::mat4(1.0), vT));

        nk_colorf col = nk_color_cf(G.comboColor);
        pShader->setVec3("uColor", glm::vec3(col.r, col.g, col.b));

        renderCube();


        /* IMPORTANT: `nk_glfw_render` modifies some global OpenGL state
         * with blending, scissor, face culling, depth test and viewport and
         * defaults everything back into a default state.
         * Make sure to either a.) save and restore or b.) reset your own state after
         * rendering the UI. */
        nk_glfw3_render(NK_ANTI_ALIASING_ON, MAX_VERTEX_BUFFER, MAX_ELEMENT_BUFFER);
        glfwSwapBuffers(win);

    }// end while

    nk_glfw3_shutdown();
    glfwTerminate();

    return 0;
}

unsigned int cubeVAO = 0;
unsigned int cubeVBO = 0;
void renderCube()
{
    // initialize (if necessary)
    if (cubeVAO == 0)
    {
        float vertices[] = {
            // back face
            -1.0f, -1.0f, -1.0f,  0.0f,  0.0f, -1.0f, 0.0f, 0.0f, // bottom-left
            1.0f,  1.0f, -1.0f,  0.0f,  0.0f, -1.0f, 1.0f, 1.0f, // top-right
            1.0f, -1.0f, -1.0f,  0.0f,  0.0f, -1.0f, 1.0f, 0.0f, // bottom-right
            1.0f,  1.0f, -1.0f,  0.0f,  0.0f, -1.0f, 1.0f, 1.0f, // top-right
            -1.0f, -1.0f, -1.0f,  0.0f,  0.0f, -1.0f, 0.0f, 0.0f, // bottom-left
            -1.0f,  1.0f, -1.0f,  0.0f,  0.0f, -1.0f, 0.0f, 1.0f, // top-left
            // front face
            -1.0f, -1.0f,  1.0f,  0.0f,  0.0f,  1.0f, 0.0f, 0.0f, // bottom-left
            1.0f, -1.0f,  1.0f,  0.0f,  0.0f,  1.0f, 1.0f, 0.0f, // bottom-right
            1.0f,  1.0f,  1.0f,  0.0f,  0.0f,  1.0f, 1.0f, 1.0f, // top-right
            1.0f,  1.0f,  1.0f,  0.0f,  0.0f,  1.0f, 1.0f, 1.0f, // top-right
            -1.0f,  1.0f,  1.0f,  0.0f,  0.0f,  1.0f, 0.0f, 1.0f, // top-left
            -1.0f, -1.0f,  1.0f,  0.0f,  0.0f,  1.0f, 0.0f, 0.0f, // bottom-left
            // left face
            -1.0f,  1.0f,  1.0f, -1.0f,  0.0f,  0.0f, 1.0f, 0.0f, // top-right
            -1.0f,  1.0f, -1.0f, -1.0f,  0.0f,  0.0f, 1.0f, 1.0f, // top-left
            -1.0f, -1.0f, -1.0f, -1.0f,  0.0f,  0.0f, 0.0f, 1.0f, // bottom-left
            -1.0f, -1.0f, -1.0f, -1.0f,  0.0f,  0.0f, 0.0f, 1.0f, // bottom-left
            -1.0f, -1.0f,  1.0f, -1.0f,  0.0f,  0.0f, 0.0f, 0.0f, // bottom-right
            -1.0f,  1.0f,  1.0f, -1.0f,  0.0f,  0.0f, 1.0f, 0.0f, // top-right
            // right face
            1.0f,  1.0f,  1.0f,  1.0f,  0.0f,  0.0f, 1.0f, 0.0f, // top-left
            1.0f, -1.0f, -1.0f,  1.0f,  0.0f,  0.0f, 0.0f, 1.0f, // bottom-right
            1.0f,  1.0f, -1.0f,  1.0f,  0.0f,  0.0f, 1.0f, 1.0f, // top-right
            1.0f, -1.0f, -1.0f,  1.0f,  0.0f,  0.0f, 0.0f, 1.0f, // bottom-right
            1.0f,  1.0f,  1.0f,  1.0f,  0.0f,  0.0f, 1.0f, 0.0f, // top-left
            1.0f, -1.0f,  1.0f,  1.0f,  0.0f,  0.0f, 0.0f, 0.0f, // bottom-left
            // bottom face
            -1.0f, -1.0f, -1.0f,  0.0f, -1.0f,  0.0f, 0.0f, 1.0f, // top-right
            1.0f, -1.0f, -1.0f,  0.0f, -1.0f,  0.0f, 1.0f, 1.0f, // top-left
            1.0f, -1.0f,  1.0f,  0.0f, -1.0f,  0.0f, 1.0f, 0.0f, // bottom-left
            1.0f, -1.0f,  1.0f,  0.0f, -1.0f,  0.0f, 1.0f, 0.0f, // bottom-left
            -1.0f, -1.0f,  1.0f,  0.0f, -1.0f,  0.0f, 0.0f, 0.0f, // bottom-right
            -1.0f, -1.0f, -1.0f,  0.0f, -1.0f,  0.0f, 0.0f, 1.0f, // top-right
            // top face
            -1.0f,  1.0f, -1.0f,  0.0f,  1.0f,  0.0f, 0.0f, 1.0f, // top-left
            1.0f,  1.0f , 1.0f,  0.0f,  1.0f,  0.0f, 1.0f, 0.0f, // bottom-right
            1.0f,  1.0f, -1.0f,  0.0f,  1.0f,  0.0f, 1.0f, 1.0f, // top-right
            1.0f,  1.0f,  1.0f,  0.0f,  1.0f,  0.0f, 1.0f, 0.0f, // bottom-right
            -1.0f,  1.0f, -1.0f,  0.0f,  1.0f,  0.0f, 0.0f, 1.0f, // top-left
            -1.0f,  1.0f,  1.0f,  0.0f,  1.0f,  0.0f, 0.0f, 0.0f  // bottom-left
        };
        glGenVertexArrays(1, &cubeVAO);
        glGenBuffers(1, &cubeVBO);
        // fill buffer
        glBindBuffer(GL_ARRAY_BUFFER, cubeVBO);
        glBufferData(GL_ARRAY_BUFFER, sizeof(vertices), vertices, GL_STATIC_DRAW);
        // link vertex attributes
        glBindVertexArray(cubeVAO);
        glEnableVertexAttribArray(0);// aPos
        glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, 8 * sizeof(float), (void*)0);
        glEnableVertexAttribArray(3);// aNormal
        glVertexAttribPointer(3, 3, GL_FLOAT, GL_FALSE, 8 * sizeof(float), (void*)(3 * sizeof(float)));
        glEnableVertexAttribArray(2);// aTexCoord
        glVertexAttribPointer(2, 2, GL_FLOAT, GL_FALSE, 8 * sizeof(float), (void*)(6 * sizeof(float)));
        glBindBuffer(GL_ARRAY_BUFFER, 0);
        glBindVertexArray(0);
    }
    // render Cube
    glBindVertexArray(cubeVAO);
    glDrawArrays(GL_TRIANGLES, 0, 36);
    glBindVertexArray(0);
}

// glfw: whenever the mouse moves, this callback is called
// -------------------------------------------------------
void mouse_callback(GLFWwindow* window, double xpos, double ypos)
{
    if (firstMouse)
    {
        lastX = xpos;
        lastY = ypos;
        firstMouse = false;
    }

    float xoffset = xpos - lastX;
    float yoffset = lastY - ypos; // reversed since y-coordinates go from bottom to top

    lastX = xpos;
    lastY = ypos;

    camera.ProcessMouseMovement(xoffset, yoffset);
}

// glfw: whenever the mouse scroll wheel scrolls, this callback is called
// ----------------------------------------------------------------------
void scroll_callback(GLFWwindow* window, double xoffset, double yoffset)
{
    camera.ProcessMouseScroll(yoffset);
}

// process all input: query GLFW whether relevant keys are pressed/released this frame and react accordingly
// ---------------------------------------------------------------------------------------------------------
void processInput(GLFWwindow *window, float deltaTime)
{
    if (glfwGetKey(window, GLFW_KEY_ESCAPE) == GLFW_PRESS)
        glfwSetWindowShouldClose(window, true);

    if (glfwGetKey(window, GLFW_KEY_W) == GLFW_PRESS)
        camera.ProcessKeyboard(FORWARD, deltaTime);
    if (glfwGetKey(window, GLFW_KEY_S) == GLFW_PRESS)
        camera.ProcessKeyboard(BACKWARD, deltaTime);
    if (glfwGetKey(window, GLFW_KEY_A) == GLFW_PRESS)
        camera.ProcessKeyboard(LEFT, deltaTime);
    if (glfwGetKey(window, GLFW_KEY_D) == GLFW_PRESS)
        camera.ProcessKeyboard(RIGHT, deltaTime);
}


unsigned int loadTexture(char const * path)
{
	unsigned int textureID;
	glGenTextures(1, &textureID);

	int width, height, nrComponents;
	stbi_set_flip_vertically_on_load(true);
	//unsigned char *data = stbi_load(FileSystem::getPath(path).c_str(), &width, &height, &nrComponents, 0);
	unsigned char *data = stbi_load(path, &width, &height, &nrComponents, 0);
	if (data)
	{
		GLenum format = GL_RGB;
		if (nrComponents == 1)
			format = GL_RED;
		else if (nrComponents == 3)
			format = GL_RGB;
		else if (nrComponents == 4)
			format = GL_RGBA;

		glBindTexture(GL_TEXTURE_2D, textureID);
		glTexImage2D(GL_TEXTURE_2D, 0, format, width, height, 0, format, GL_UNSIGNED_BYTE, data);
		glGenerateMipmap(GL_TEXTURE_2D);

		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT);
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT);
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR_MIPMAP_LINEAR);
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
	}
	else
	{
		std::cout << "Texture failed to load at path: " << path << std::endl;
	}

	stbi_image_free(data);
	return textureID;
}
