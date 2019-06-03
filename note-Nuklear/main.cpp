/**
 * Nuklear + OpenGL
 *
 * TODO:
   - [x] program struct
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

#define _C(val) #@val
#define _S(val) #val
#define LN(val) _S(val)"\n"

// property type
#define TYPE_INT    1
#define TYPE_FLOAT  2
#define TYPE_VEC2   3
#define TYPE_VEC3   4
#define TYPE_COLOR  5
#define TYPE_STRING 6

/*
flow:

init glfw
init nuklear
init state

loop
  calculate fame
  update nuklear ui
  calculate MVP
  update camera
  use shader
  update GL scene
  process event

*/

enum { OP_A, OP_B, OP_C, OP_D };

Camera camera(glm::vec3(0.0f, 0.0f, 3.0f));
float lastX = WINDOW_WIDTH / 2.0f; // center
float lastY = WINDOW_HEIGHT / 2.0f;
bool firstMouse = true;
glm::mat4 mvp(1.0);

Shader* pShader = NULL;

static int texture0;

//====================================
struct StState {
	int id;
	struct nk_context *ctx;
	Camera* camera;

	struct nk_color comboColor;
};

typedef struct StState StState;
static StState G;

int initState() {
	G.id = 0;
	G.ctx = NULL;
	G.camera = NULL;

	G.comboColor = nk_rgba(75, 227, 62, 255);

	printf("sizeof(short) = %lu\n", sizeof(StState));
	return 0;
}
//====================================

// glfw error callback
static void error_callback(int e, const char *d)
{
	printf("Error %d: %s\n", e, d);
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
void processInput(GLFWwindow* window, float deltaTime)
{
	//if (glfwGetKey(window, GLFW_KEY_ESCAPE) == GLFW_PRESS)
	//	glfwSetWindowShouldClose(window, true);

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

void propertyFloat(struct nk_context* ctx, const char* key, float* val)
{
	static char buffer[32];
	nk_layout_row_begin(ctx, NK_DYNAMIC, 30, 1);
	sprintf(buffer, "#%s", key);
	nk_layout_row_push(ctx, 1.0);
	nk_property_float(ctx, buffer, -1024.0f, val, 1024.0f, 1, 0.5f);
	nk_layout_row_end(ctx);
}
void propertyInt(struct nk_context* ctx, const char* key, int* val)
{
	static char buffer[32];
	nk_layout_row_begin(ctx, NK_DYNAMIC, 30, 1);
	sprintf(buffer, "#%s", key);
	nk_layout_row_push(ctx, 1.0);
	nk_property_int(ctx, buffer, -1024, val, 1024, 1, 1);
	nk_layout_row_end(ctx);
}
void propertyVec2(struct nk_context* ctx, const char* key, float* x, float* y, struct nk_vec2 size /* nk_vec2(200, 200) */ )
{
    static char buffer[32];
	nk_layout_row_begin(ctx, NK_DYNAMIC, 30, 1);
	nk_layout_row_push(ctx, 1.0);
	//nk_label(ctx, key, NK_TEXT_CENTERED);
    sprintf(buffer, "%s: %.2f, %.2f", key, *x, *y);

    if (nk_combo_begin_label(ctx, buffer, size)) {
        nk_layout_row_dynamic(ctx, 25, 1);
        nk_property_float(ctx, "#X:", -1024.0f, x, 1024.0f, 1, 0.5f);
        nk_property_float(ctx, "#Y:", -1024.0f, y, 1024.0f, 1, 0.5f);
        nk_combo_end(ctx);
    }
	nk_layout_row_end(ctx);
}
void propertyVec3(struct nk_context* ctx, const char* key, float* x, float* y, float* z, struct nk_vec2 size /* nk_vec2(200, 200) */)
{
    static char buffer[32];
	nk_layout_row_begin(ctx, NK_DYNAMIC, 30, 2);
	nk_layout_row_push(ctx, 0.30);
	nk_label(ctx, key, NK_TEXT_CENTERED);
    sprintf(buffer, "%.2f, %.2f, %.2f", *x, *y, *z);

	nk_layout_row_push(ctx, 0.70);
    if (nk_combo_begin_label(ctx, buffer, size)) {
        nk_layout_row_dynamic(ctx, 25, 1);
        nk_property_float(ctx, "#X:", -1024.0f, x, 1024.0f, 1, 0.5f);
        nk_property_float(ctx, "#Y:", -1024.0f, y, 1024.0f, 1, 0.5f);
        nk_property_float(ctx, "#Z:", -1024.0f, z, 1024.0f, 1, 0.5f);
        nk_combo_end(ctx);
    }
	nk_layout_row_end(ctx);
}
void propertyColor(struct nk_context *ctx, const char* key, struct nk_colorf *colorf, struct nk_vec2 size /* nk_vec2(200, 200) */)
{
	static struct nk_colorf lastColorf;
	static char buffer[16] = { 0 };
	static char bufferA[16] = { 0 };
	int ret = memcmp(colorf, &lastColorf, sizeof(nk_colorf));
	if (ret != 0) {
		lastColorf = *colorf;
		//printf("update lastColorf");

		memset(buffer, 0, sizeof(buffer));
		memset(bufferA, 0, sizeof(bufferA));
		nk_color_hex_rgba(buffer, nk_rgba_cf(*colorf));
		//sprintf(buffer, "%s: \#%s", key, buffer);
		//sprintf(bufferA, "%s: \#%s", key, buffer);

		// add #
		sprintf(bufferA, "\#%s", buffer);
	}

	nk_layout_row_dynamic(ctx, 30, 1);
	nk_label(ctx, key, NK_TEXT_LEFT);

	nk_layout_row_begin(ctx, NK_DYNAMIC, 30, 2);
	nk_layout_row_push(ctx, 0.3);

	static struct nk_text_edit stTextEdit;
	static int isInitTextEdit = 0;
	if (isInitTextEdit == 0)
	{
		nk_textedit_init_default(&stTextEdit);
		isInitTextEdit = 1;
	}
	nk_edit_buffer(ctx, NK_EDIT_FIELD, &stTextEdit, nk_filter_ascii);

	if (ret != 0) {
		nk_textedit_delete(&stTextEdit, 0, stTextEdit.string.len);
		nk_textedit_text(&stTextEdit, bufferA, strlen(bufferA));
	}

	nk_layout_row_push(ctx, 0.7);
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
	nk_layout_row_end(ctx);
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

void renderUI(struct nk_context *ctx)
{
	// what property do you want to modify?
	if (nk_begin(ctx, "property panel", nk_rect(200, 10, 300, 400), NK_WINDOW_MOVABLE | NK_WINDOW_CLOSABLE | NK_WINDOW_TITLE)) {

		static float vec3A[3];
		propertyVec3(ctx, "position", &vec3A[0], &vec3A[1], &vec3A[2], nk_vec2(190, 200));

		static float value;
		propertyFloat(ctx, "value", &value);

		static int iValue;
		propertyInt(ctx, "iValue", &iValue);

		static float vec2A[2];
		propertyVec2(ctx, "vec2", &vec2A[0], &vec2A[1], nk_vec2(190, 200));

		static struct nk_colorf combo_color1_1 = {0.509f, 0.705f, 0.2f, 1.0f};
		propertyColor(ctx, "combo_color", &combo_color1_1, nk_vec2(200,400));
	}
	nk_end(ctx);
}

void renderScene()
{
	glEnable(GL_DEPTH_TEST);
	glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

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

    win = glfwCreateWindow(WINDOW_WIDTH, WINDOW_HEIGHT, "Nuklear+OpenGL", NULL, NULL);

	glfwMakeContextCurrent(win);
    glfwGetWindowSize(win, &width, &height);
    glfwSetCursorPosCallback(win, mouse_callback);
    glfwSetScrollCallback(win, scroll_callback);

    /* OpenGL */
    gladLoadGL();
    glViewport(0, 0, WINDOW_WIDTH, WINDOW_HEIGHT);

	// nuklear
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

	G.ctx = ctx;
	G.camera = &camera;

	//////////////////////////////////////////////////
	// shader
	std::string vertexShaderPath = "vertex.vs";
	std::string fragmentShaderPath = "fragment.fs";
	pShader = new Shader(vertexShaderPath.c_str(), fragmentShaderPath.c_str());
	if (!pShader) {
		std::cout << "pShader is NULL." << std::endl;
	}

	//////////////////////////////////////////
	// texture
	texture0 = loadTexture("container.jpg");
	//static int texture0 = loadTexture("awesomeface.png");
	//static int texture0 = loadTexture("marble.jpg");

	pShader->use();
	pShader->setInt("texture0", 0);
	//////////////////////////////////////////

    bg.r = 0.10f, bg.g = 0.18f, bg.b = 0.24f, bg.a = 1.0f;
    int cacheProperty = 0;
    float ratioProperty = 0;
    static int checkboxValue = nk_true;

	//////////////////////////////////
	// calculate frame
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
	//////////////////////////////////

	//
	// loop
	//
    while (!glfwWindowShouldClose(win))
    {
        clockCount++;
        currentFrame = glfwGetTime();
        deltaFrame = currentFrame - lastFrame;
        if (deltaFrame < timePerFrame) continue;

        frameCountPerSec++;
        sumFrameCost += deltaFrame;
        currentRunSec = (int)currentFrame;
        lastRunSec = (int)lastFrame;
        lastFrame = currentFrame;
        fps = frameCountPerSec / sumFrameCost;

        if (sumFrameCost >= 1.0) {
            //printf("last sec = %d   current sec = %d  count = %lu clockCount = %lu fps = %f sumFrameCost = %f\n", lastRunSec, currentRunSec, frameCountPerSec, clockCount, fps, sumFrameCost);
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

		///////////////////////////////////////////
		/* GUI */
		renderUI(ctx);
		///////////////////////////////////////////

		//////////////////////////////////
        /* Draw */
		renderScene();
		//////////////////////////////////

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
