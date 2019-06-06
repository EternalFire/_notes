/**
* Nuklear + OpenGL
*
* TODO:
- [x] program struct
- [x] press space to lock or unlock camera movement
- [x] property panel
- [x] camera property panel
- [x] main panel*
- [ ] data driven
- [x] reset camera
- [x] cache value
- [ ] property data struct*
- [ ] change texture
- [x] render sphere
- [ ] dynamic create property widget
- [ ] fixed window size
- [ ] other OpenGL case
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
#include <map>
#include <vector>

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

#define GLM_FORCE_SWIZZLE
#include "glm/glm.hpp"

#include "shader.h"
#include "camera.h"


// window size
#define WINDOW_WIDTH  1280
#define WINDOW_HEIGHT 720

#define MAX_VERTEX_BUFFER 512 * 1024
#define MAX_ELEMENT_BUFFER 128 * 1024

//#define _C(val) #@val
#define _S(val) #val
#define LN(val) _S(val)"\n"

// property type
#define TYPE_INT    1
#define TYPE_FLOAT  2
#define TYPE_VEC2   3
#define TYPE_VEC3   4
#define TYPE_COLOR  5
#define TYPE_COLORF 6
#define TYPE_STRING 7

// panel type
#define PANEL_STATUS "Status"
#define PANEL_MAIN   "Main"
#define PANEL_COMMON_SHADER "Common Shader"
#define PANEL_SHADER_1 "StShaderPanel_1"

// panel entrance
#define BTN_COMMON_SHADER "Show Common Shader"

// panel size
#define PANEL_STATUS_WIDTH WINDOW_WIDTH
#define PANEL_STATUS_HEIGHT 85
#define PANEL_STATUS_X 0
#define PANEL_STATUS_Y WINDOW_HEIGHT - PANEL_STATUS_HEIGHT

#define PANEL_MAIN_X 0
#define PANEL_MAIN_Y 0
#define PANEL_MAIN_WIDTH 240
#define PANEL_MAIN_HEIGHT WINDOW_HEIGHT - PANEL_STATUS_HEIGHT

#define PANEL_NORMAL_WIDTH  300
#define PANEL_NORMAL_HEIGHT 400

#define PANEL_COMMON_SHADER_X PANEL_MAIN_WIDTH
#define PANEL_COMMON_SHADER_Y 0
#define PANEL_COMMON_SHADER_WIDTH PANEL_NORMAL_WIDTH
#define PANEL_COMMON_SHADER_HEIGHT PANEL_NORMAL_HEIGHT

#define PROPERTY_COLOR_SIZE nk_vec2(200, 400)
#define PROPERTY_LINE_NORMAL_HEIGHT 30

// convert rgba color component to [0,1] by divided by 255
#define CNTo1(component) (component/255.0f)


/**
 * flow(main):
 *   init glfw
 *   init nuklear
 *   init state
 *
 *   loop
 *     calculate fame
 *     update nuklear ui
 *     calculate MVP
 *     update camera
 *     use shader
 *     update GL scene
 *     process event
 *
 */


/**
 * connect uniform with variable:
 *
 * define uniform in fragment shader
 * define variable in global state
 * create widget for variable
 * shader object pass variable to fragment shader program
 * update variable by widget
 */


/**
 *
 * create panel and widget by shader property structure:
 *
 * 1. create switch to active shader program
 * 2. create entrance in main panel
 * 3. create panel with name to contain widget
 * 4. iterate every property, create widget according to property type
 * 5. use property data by shader object method
 *
 *
 * `initStShaderPanels()`, create property struct data
 * `initGLSetting()`, create shader
 * `renderShaderPanelEntrance()`
 * `renderShaderPanel()`, panel with widget which used for updating uniform
 * `renderScene()`, shader object pass property value to shader program
 *
 */


/**
 * Camera setting
 *
 * Position = (7.640, 6.438, 11.394)
 * WorldUp = (0.000, 1.000, 0.000)
 * Pitch = -24.300  Yaw = -124.900
 *
 * Position = (0.667, 8.979, 19.392)
 * WorldUp = (0.000, 1.000, 0.000)
 * Pitch = -24.400  Yaw = -110.500
 */
const glm::vec3 cameraPosition = glm::vec3(0.667, 8.979, 19.392);
const glm::vec3 cameraUp = glm::vec3(0, 1.0, 0);
const float cameraYaw = -110.5f;  // around y axis
const float cameraPitch = -24.4f; // around x axis

glm::vec3 cameraPositionNew = cameraPosition;
glm::vec3 cameraUpNew = cameraUp;
float cameraYawNew = cameraYaw;
float cameraPitchNew = cameraPitch;

Camera camera(cameraPosition, cameraUp, cameraYaw, cameraPitch);
float lastX = WINDOW_WIDTH / 2.0f; // center
float lastY = WINDOW_HEIGHT / 2.0f;
bool firstMouse = true;

/**
 * transform
 **/
glm::mat4 mvp(1.0f);
glm::mat4 projectionMatrix(1.0f);
glm::mat4 viewMatrix(1.0f);

const glm::mat4 IMatrix4(1.0f); // identty matrix
const glm::vec3 xAxis(1.0f, 0.0f, 0.0f);
const glm::vec3 yAxis(0.0f, 1.0f, 0.0f);
const glm::vec3 zAxis(0.0f, 0.0f, 1.0f);

Shader* pShader = NULL;
static int texture0;

//====================================
typedef struct StColorShader {
	struct nk_colorf uColor;
} StColorShader;

typedef struct StCommonShader {
	float uRatioMixTex2Color;
	struct nk_colorf objectColor;
	int uUsePointLight;
	int uSwitchEffectInvert;
	int uSwitchEffectGray;
} StCommonShader;

typedef struct StProperty {
	int type;
	string name;
	union {
		int iVal;
		float fVal;
		glm::vec2 v2Val;
		glm::vec3 v3Val;
		struct nk_colorf cfVal;
		struct nk_color cVal;
		string sVal;
	};

	StProperty():sVal(""), name("") {}
	StProperty(const StProperty& prop) {
		*this = prop;
	}
	StProperty(StProperty&& prop) {
		*this = prop;
	}
	~StProperty() {}

	StProperty& operator=(const StProperty& prop) {
		type = prop.type;
		name = prop.name;
		if (type == TYPE_INT)    iVal = prop.iVal;
		if (type == TYPE_FLOAT)  fVal = prop.fVal;
		if (type == TYPE_VEC2)   v2Val = prop.v2Val;
		if (type == TYPE_VEC3)   v3Val = prop.v3Val;
		if (type == TYPE_COLORF) cfVal = prop.cfVal;
		if (type == TYPE_COLOR)  cVal = prop.cVal;
		if (type == TYPE_STRING) sVal = prop.sVal;
		return *this;
	}
	StProperty& operator=(StProperty&& prop) {
		*this = prop;
		return *this;
	}

} StProperty;

typedef struct StShaderPanel {
	string name;
	vector<StProperty> propertyArray;
	Shader* shader;

	StShaderPanel():name(""), shader(NULL) {}
	~StShaderPanel() { name.clear(); shader = NULL; }
} StShaderPanel;

typedef struct StCache {
	map<string, string> bufValue;
	map<string, float> fValue;
	map<string, int> iValue;
	map<string, struct nk_colorf> cfValue;
	map<string, struct nk_text_edit> textEditValue;

} StCache;

// Global State
struct StState {
	int id;
	struct nk_context *ctx;
	double currentTime;

	// panel status
	struct nk_rect panelStatusRect;
	char panelStatusBuffer[512];

	// panel main
	struct nk_rect panelMainRect;

	// panel common shader
	int isShowPanelCommonShader;
	struct nk_rect panelCommonShaderRect;

	// camera
	Camera* camera;
	int lockCamera;
	int isLockingCamera;
	int isRotatingCameraY;

	// point light movement
	int isPointLightMove;

	// shader
	StCommonShader stCommonShader;
	StColorShader stColorShader;
	Shader* colorShader = NULL;

	map<string, StShaderPanel> stShaderPanelMap;

	struct nk_color bgColor; //

	StCache cache;
};
typedef struct StState StState;
static StState G;


//====================================
bool fuzzyEquals(float a, float b)
{
	const float epsilon = 0.001;
	const float difference = a - b;
	if (difference >= -epsilon && difference <= epsilon) {
		return true;
	}
	return false;
}

glm::mat4 translate(const glm::vec3& v3, const glm::mat4& model = IMatrix4)
{
	return glm::translate(model, v3);
}
glm::mat4 rotateByX(float degree, const glm::mat4& model = IMatrix4)
{
	return glm::rotate(model, glm::radians(degree), xAxis);
}
glm::mat4 rotateByY(float degree, const glm::mat4& model = IMatrix4)
{
	return glm::rotate(model, glm::radians(degree), yAxis);
}
glm::mat4 rotateByZ(float degree, const glm::mat4& model = IMatrix4)
{
	return glm::rotate(model, glm::radians(degree), zAxis);
}
glm::mat4 scale(const glm::vec3& v3, const glm::mat4& model = IMatrix4)
{
	return glm::scale(model, v3);
}
glm::mat4 scale(float s, const glm::mat4& model = IMatrix4)
{
	return glm::scale(model, glm::vec3(s));
}
glm::mat3 normalMatrix(const glm::mat4& model)
{
	return glm::transpose(glm::inverse(glm::mat3(model)));
}

glm::mat4 perspectiveMatrix()
{
	return glm::perspective(glm::radians(camera.Zoom), (float)WINDOW_WIDTH / (float)WINDOW_HEIGHT, 0.1f, 100.0f);
}

glm::vec3 convertCFToVec3(nk_colorf* col)
{
	return col ? glm::vec3((*col).r, (*col).g, (*col).b) : glm::vec3(1.0);
}
glm::vec3 convertCToVec3(nk_color* col)
{
	const float c = 255.0;
	return col ? glm::vec3((*col).r / c, (*col).g / c, (*col).b / c) : glm::vec3(1.0);
}
glm::vec4 convertCFToVec4(nk_colorf* col)
{
	if (col) return glm::vec4(convertCFToVec3(col), col->a);
	return glm::vec4(1.0);
}
glm::vec4 convertCToVec4(nk_color* col)
{
	if (col) return glm::vec4(convertCToVec3(col), col->a);
	return glm::vec4(1.0);
}

void printColorf(const char * key, struct nk_colorf colorf)
{
	printf("%s = %.2f %.2f %.2f %.2f\n", key, colorf.r, colorf.g, colorf.b, colorf.a);
}
void printColorB(const char * key, struct nk_color color)
{
	printf("%s = %d %d %d %d\n", key, color.r, color.g, color.b, color.a);
}

void resetFirstMouse()
{
	firstMouse = true;
}

void resetCamera()
{
	camera.init(cameraPositionNew, cameraUpNew, cameraYawNew, cameraPitchNew);
	resetFirstMouse();
}

void setCamera()
{
	cameraPositionNew = camera.Position;
	cameraUpNew = camera.WorldUp;
	cameraYawNew = camera.Yaw;
	cameraPitchNew = camera.Pitch;
}

// rotate camera around y axis
void rotateCameraY(float sinValue, float cosValue)
{
	float radius = glm::length(glm::vec2(G.camera->Position.xz()));
	glm::vec3 p = glm::vec3(cosValue * radius, G.camera->Position.y, sinValue * radius);
	G.camera->Position = p;
	G.camera->Front = glm::normalize(-p);
	G.camera->Right = glm::normalize(glm::cross(G.camera->Front, G.camera->WorldUp));
	G.camera->Up = glm::normalize(glm::cross(G.camera->Right, G.camera->Front));
}

void rotateCameraByYaw(float degree)
{
	if (G.camera) {
		G.camera->ProcessMouseMovement(degree, 0);
	}
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

int initStCommonShader(StCommonShader* p)
{
    // p->objectColor.r = 0.88;
    // p->objectColor.g = 0.9;
    // p->objectColor.b = 0.88;
    // p->objectColor.a = 1.0;
    // objectColor (r:218 g:178 b:82 a:255)
	p->objectColor = {CNTo1(218), CNTo1(178), CNTo1(82), 1.0f};
	p->uRatioMixTex2Color = 0.1f;
	p->uUsePointLight = 1;
	p->uSwitchEffectInvert = 0;
	p->uSwitchEffectGray = 0;
	return 0;
}

int initStColorShader(StColorShader* p)
{
	if (p != NULL) {
		p->uColor = {CNTo1(209), CNTo1(221), CNTo1(200), 1.0f};
	}
	return 0;
}

int initStShaderPanels()
{
	// create panel struct
	StShaderPanel st1;
	st1.name = PANEL_SHADER_1;

	// create property struct
	StProperty p0;
	p0.name = "uSwitchEffectInvert";
	p0.type = TYPE_INT;
	p0.iVal = 0;
	st1.propertyArray.push_back(p0);

	// put panel struct into map
	G.stShaderPanelMap[st1.name] = st1;

	return 0;
}

int initState() {
	G.id = 0;
	G.ctx = NULL;
	G.currentTime = 0;

	// panel status
	G.panelStatusRect = nk_rect(PANEL_STATUS_X, PANEL_STATUS_Y, PANEL_STATUS_WIDTH, PANEL_STATUS_HEIGHT);
	memset(G.panelStatusBuffer, 0, sizeof(G.panelStatusBuffer));

	// panel main
	G.panelMainRect = nk_rect(PANEL_MAIN_X, PANEL_MAIN_Y, PANEL_MAIN_WIDTH, PANEL_MAIN_HEIGHT);

	// panel common shader
	G.isShowPanelCommonShader = 0;
	G.panelCommonShaderRect = nk_rect(PANEL_COMMON_SHADER_X, PANEL_COMMON_SHADER_Y, PANEL_COMMON_SHADER_WIDTH, PANEL_COMMON_SHADER_HEIGHT);

	// camera
	G.camera = &camera;
	G.lockCamera = 1;
	G.isLockingCamera = 0;
	G.isRotatingCameraY = 0;
	camera.MovementSpeed *= 1.75;

	G.isPointLightMove = 0;

	// common shader
	initStCommonShader(&G.stCommonShader);

	// color shader
	initStColorShader(&G.stColorShader);

	initStShaderPanels();

    //#bgColor (r:51 g:51 b:43 a:255)
    G.bgColor = nk_rgba(51, 51, 43, 255);

	printf("sizeof(StState) = %lu\n", sizeof(StState));

	return 0;
}

void initGLSetting()
{
	glViewport(0, 0, WINDOW_WIDTH, WINDOW_HEIGHT);
	glEnable(GL_MULTISAMPLE);

	// shader
	std::string vertexShaderPath = "vertex.vs";
	std::string fragmentShaderPath = "fragment.fs";
	pShader = new Shader(vertexShaderPath.c_str(), fragmentShaderPath.c_str());
	if (!pShader) {
		std::cout << "pShader is NULL." << std::endl;
	}

	G.colorShader = new Shader("vertex.vs", "colorFragment.fs");

	G.stShaderPanelMap[PANEL_SHADER_1].shader = pShader;

	//////////////////////////////////////////
	// texture
	texture0 = loadTexture("container.jpg");
	//static int texture0 = loadTexture("awesomeface.png");
	//static int texture0 = loadTexture("marble.jpg");

	pShader->use();
	pShader->setInt("texture0", 0);
	// pShader->setFloat("uRatioMixTex2Color", 0.1);
}

void clear()
{
	if (pShader) {
		delete pShader; pShader = NULL;
	}

	if (G.colorShader) {
		delete G.colorShader; G.colorShader = NULL;
	}
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
	if (G.lockCamera) return;

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
	if (G.lockCamera) return;
	camera.ProcessMouseScroll(yoffset);
}

// process all input: query GLFW whether relevant keys are pressed/released this frame and react accordingly
// ---------------------------------------------------------------------------------------------------------
void processInput(GLFWwindow* window, float deltaTime)
{
	if (glfwGetKey(window, GLFW_KEY_ESCAPE) == GLFW_PRESS)
		glfwSetWindowShouldClose(window, true);

	if (glfwGetKey(window, GLFW_KEY_SPACE) == GLFW_PRESS) {
		if (!G.isLockingCamera) {
			G.isLockingCamera = 1;

			G.lockCamera = !G.lockCamera;
			//printf("%.2f%s\n", glfwGetTime(), G.lockCamera ? "lock" : "unlock");
		}
	}

	if (glfwGetKey(window, GLFW_KEY_SPACE) == GLFW_RELEASE) {
		if (G.isLockingCamera) {
			G.isLockingCamera = 0;
			resetFirstMouse();
		}
	}

	if (G.lockCamera) return;

	if (glfwGetKey(window, GLFW_KEY_W) == GLFW_PRESS)
		camera.ProcessKeyboard(FORWARD, deltaTime);
	if (glfwGetKey(window, GLFW_KEY_S) == GLFW_PRESS)
		camera.ProcessKeyboard(BACKWARD, deltaTime);
	if (glfwGetKey(window, GLFW_KEY_A) == GLFW_PRESS)
		camera.ProcessKeyboard(LEFT, deltaTime);
	if (glfwGetKey(window, GLFW_KEY_D) == GLFW_PRESS)
		camera.ProcessKeyboard(RIGHT, deltaTime);
}

void propertySwitch(struct nk_context* ctx, const char* key, int* val)
{
	nk_layout_row_dynamic(ctx, PROPERTY_LINE_NORMAL_HEIGHT, 1);
	nk_selectable_label(ctx, key, NK_TEXT_LEFT, val);
}
// without layout
void propertyString(struct nk_context* ctx, const char* key, const char* val)
{
	static int field_len = 0;
	static char field_buffer[512] = "";
	static int max = 512;
	strcpy(field_buffer, val);
	field_len = (int)(strlen(field_buffer));

	nk_edit_string(ctx, NK_EDIT_FIELD | NK_EDIT_AUTO_SELECT | NK_EDIT_MULTILINE, field_buffer, &field_len, max, nk_filter_default);
}
void propertyStringWithLayout(struct nk_context* ctx, const char* key, const char* val)
{
	nk_layout_row_dynamic(ctx, PROPERTY_LINE_NORMAL_HEIGHT, 1);
	propertyString(ctx, key, val);
}
void propertyFloat(struct nk_context* ctx, const char* key, float* val)
{
	static char buffer[32];
	memset(buffer, 0, sizeof(buffer));
	sprintf(buffer, "#%s", key);

	nk_layout_row_begin(ctx, NK_DYNAMIC, PROPERTY_LINE_NORMAL_HEIGHT, 1);
	nk_layout_row_push(ctx, 1.0);
	nk_property_float(ctx, buffer, -1024.0f, val, 1024.0f, 1, 0.5f);
	nk_layout_row_end(ctx);
}
void propertyInt(struct nk_context* ctx, const char* key, int* val)
{
	static char buffer[32];
	memset(buffer, 0, sizeof(buffer));
	sprintf(buffer, "#%s", key);

	nk_layout_row_begin(ctx, NK_DYNAMIC, PROPERTY_LINE_NORMAL_HEIGHT, 1);
	nk_layout_row_push(ctx, 1.0);
	nk_property_int(ctx, buffer, -1024, val, 1024, 1, 1);
	nk_layout_row_end(ctx);
}
void propertyVec2(struct nk_context* ctx, const char* key, float* x, float* y, struct nk_vec2 size /* nk_vec2(200, 200) */)
{
	static char buffer[32];
	memset(buffer, 0, sizeof(buffer));
	sprintf(buffer, "%s: %.2f, %.2f", key, *x, *y);

	nk_layout_row_begin(ctx, NK_DYNAMIC, PROPERTY_LINE_NORMAL_HEIGHT, 1);
	nk_layout_row_push(ctx, 1.0);
	nk_label(ctx, key, NK_TEXT_CENTERED);

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
	memset(buffer, 0, sizeof(buffer));
	sprintf(buffer, "%.2f, %.2f, %.2f", *x, *y, *z);

	nk_layout_row_begin(ctx, NK_DYNAMIC, PROPERTY_LINE_NORMAL_HEIGHT, 2);
	nk_layout_row_push(ctx, 0.30);
	nk_label(ctx, key, NK_TEXT_CENTERED);

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
	enum color_mode { COL_RGB, COL_HSV };
	// extract to cache map
	// static struct nk_colorf lastColorf;
	// static char buffer[64] = { 0 };
	// static char bufferA[64] = { 0 };
	// static int len = 0;
	// static int col_mode = COL_RGB;
	// static struct nk_text_edit stTextEdit;
	// static int isInitTextEdit = 0;

	string sKey = key;
	string sKey_A = sKey + "_A";
	string sKey_B = sKey + "_B";

	struct nk_colorf& lastColorf = G.cache.cfValue[sKey];
	char buffer[64] = { 0 };
	char bufferA[64] = { 0 };
	int& len = G.cache.iValue[sKey];
	int& col_mode = G.cache.iValue[sKey_A];
 	struct nk_text_edit& stTextEdit = G.cache.textEditValue[sKey];
	int& isInitTextEdit = G.cache.iValue[sKey_B];

	// read cache
	strcpy(buffer, G.cache.bufValue[sKey].c_str());
	strcpy(bufferA, G.cache.bufValue[sKey_A].c_str());

	struct nk_color colorRGBA = nk_rgba_cf(*colorf);

	int ret = memcmp(colorf, &lastColorf, sizeof(nk_colorf));
	if (ret != 0) {
		lastColorf = *colorf;

		memset(buffer, 0, sizeof(buffer));
		memset(bufferA, 0, sizeof(bufferA));
		nk_color_hex_rgba(buffer, colorRGBA);

		// add #
		sprintf(bufferA, "#%s", buffer);
		// printf("update key[%s] lastColorf %s\n", sKey.c_str(), bufferA);
	}

	memset(buffer, 0, sizeof(buffer));
	sprintf(buffer, "%s (r:%d g:%d b:%d a:%d)", key, colorRGBA.r, colorRGBA.g, colorRGBA.b, colorRGBA.a);
	len = strlen(buffer);

	// write cache
	G.cache.bufValue[sKey] = buffer;
	G.cache.bufValue[sKey_A] = bufferA;

	nk_layout_row_dynamic(ctx, PROPERTY_LINE_NORMAL_HEIGHT, 1);
	// nk_label(ctx, buffer, NK_TEXT_LEFT);
	nk_edit_string_zero_terminated(ctx, NK_EDIT_BOX | NK_EDIT_AUTO_SELECT, buffer, len + 1, nk_filter_default);

	nk_layout_row_begin(ctx, NK_DYNAMIC, PROPERTY_LINE_NORMAL_HEIGHT, 2);
	nk_layout_row_push(ctx, 0.35);

	// static struct nk_text_edit stTextEdit;
	// static int isInitTextEdit = 0;
	if (isInitTextEdit == 0) {
		nk_textedit_init_default(&stTextEdit);
		isInitTextEdit = 1;
	}
	nk_edit_buffer(ctx, NK_EDIT_FIELD | NK_EDIT_AUTO_SELECT, &stTextEdit, nk_filter_ascii);

	if (ret != 0) {
		nk_textedit_delete(&stTextEdit, 0, stTextEdit.string.len);
		nk_textedit_text(&stTextEdit, bufferA, (int)(strlen(bufferA)));
	}

	nk_layout_row_push(ctx, 0.65);
	if (nk_combo_begin_color(ctx, nk_rgb_cf(*colorf), size)) {
		// enum color_mode { COL_RGB, COL_HSV };
		// static int col_mode = COL_RGB;
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
		}
		else {
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
void propertyColorB(struct nk_context* ctx, const char* key, struct nk_color* color, struct nk_vec2 size)
{
	// static struct nk_colorf colorf;
	string sKey = string(key) + "__B_";
	struct nk_colorf& colorf = G.cache.cfValue[sKey];
	colorf = nk_color_cf(*color);
	propertyColor(ctx, key, &colorf, size);
	*color = nk_rgb_cf(colorf);
}

void renderShaderPanel(struct nk_context* ctx)
{
	for (auto it = G.stShaderPanelMap.begin(); it != G.stShaderPanelMap.end(); it++) {
		string panelName = it->first;
		auto& stShaderPanel = it->second;
		auto& showValue = G.cache.iValue[panelName];

		if (showValue) {
			if (nk_begin(ctx, panelName.c_str(), G.panelCommonShaderRect, NK_WINDOW_MOVABLE | NK_WINDOW_CLOSABLE | NK_WINDOW_TITLE | NK_WINDOW_BORDER))
			{
				for (auto ite = stShaderPanel.propertyArray.begin(); ite != stShaderPanel.propertyArray.end(); ite++)
				{
					auto& stProperty = *ite;
					if (stProperty.type == TYPE_INT) {
						propertySwitch(ctx, stProperty.name.c_str(), &stProperty.iVal);
					}
					// ...
				}
			}
			else
			{
				showValue = 0;
			}
			nk_end(ctx);
		}
	}
}

void renderCommonShaderPanel(struct nk_context* ctx)
{
	const char *panelName = PANEL_COMMON_SHADER;

	if (G.isShowPanelCommonShader) {

		// map shader parameter to widget
		if (nk_begin(ctx, panelName, G.panelCommonShaderRect, NK_WINDOW_MOVABLE | NK_WINDOW_CLOSABLE | NK_WINDOW_TITLE | NK_WINDOW_BORDER))
		{
			// uniform - propertyType
			propertyFloat(ctx, "uRatioMixTex2Color", &G.stCommonShader.uRatioMixTex2Color);
			propertyColor(ctx, "objectColor", &G.stCommonShader.objectColor, PROPERTY_COLOR_SIZE);

			// point light switch
			propertySwitch(ctx, "uUsePointLight", &G.stCommonShader.uUsePointLight);

			// other switch
			// ...
			propertySwitch(ctx, "uSwitchEffectInvert", &G.stCommonShader.uSwitchEffectInvert);
			propertySwitch(ctx, "uSwitchEffectGray", &G.stCommonShader.uSwitchEffectGray);

		}
		else {
			// panel closed
			// printf("closed ? %d\n", nk_window_is_closed(ctx, panelName));
			G.isShowPanelCommonShader = 0;
		}
		nk_end(ctx);
	}
}

void renderStatus(struct nk_context* ctx)
{
	if (nk_begin(ctx, PANEL_STATUS, G.panelStatusRect, NK_WINDOW_NO_SCROLLBAR | NK_WINDOW_BORDER)) {
		float h = PANEL_STATUS_HEIGHT / 3.0;
		nk_layout_row_dynamic(ctx, PANEL_STATUS_HEIGHT, 2);

		// column 1
		//
		// camera setting
		if (nk_group_begin(ctx, "Camera", NULL)) {

			glm::vec3* p = &(G.camera->Position);
			memset(G.panelStatusBuffer, 0, sizeof(G.panelStatusBuffer));

			glm::vec3* up = &(G.camera->WorldUp);

			// 2 cols
			float rowHeight = h * 2.33;
			nk_layout_row_dynamic(ctx, rowHeight, 2);
			sprintf(G.panelStatusBuffer,
				"Position = (%.3f, %.3f, %.3f)\n"\
				"WorldUp = (%.3f, %.3f, %.3f)\n"\
				"Pitch = %.3f  Yaw = %.3f\n",
				p->x, p->y, p->z,
				up->x, up->y, up->z,
				G.camera->Pitch, G.camera->Yaw
			);

			// col 1
			propertyString(ctx, "camera setting", G.panelStatusBuffer);

			// col 2
			if (nk_group_begin(ctx, "#Camera_col_2", NULL)) {
				nk_layout_row_dynamic(ctx, rowHeight / 3, 2);

				if (nk_button_label(ctx, "reset")) {
					resetCamera();
				}

				if (nk_button_label(ctx, "set")) {
					setCamera();
				}

				nk_selectable_label(ctx, "rotate", NK_TEXT_LEFT, &G.isRotatingCameraY);

				memset(G.panelStatusBuffer, 0, sizeof(G.panelStatusBuffer));
				sprintf(G.panelStatusBuffer, "lock camera(Space)");

				// label color change after G.lockCamera modified
				nk_label_colored(ctx, G.panelStatusBuffer, NK_TEXT_LEFT, G.lockCamera ? nk_rgb(200, 20, 20) : nk_rgb(20, 200, 20));

				nk_group_end(ctx);
			}

			nk_group_end(ctx);
		}

		//if (nk_group_begin(ctx, "column2", NULL)) { // column 2
		//    nk_layout_row_dynamic(ctx, 10, 1);
		//    nk_label(ctx, "column 2.1", NK_TEXT_CENTERED);
		//
		//    nk_layout_row_dynamic(ctx, 10, 1);
		//    nk_label(ctx, "column 2.2", NK_TEXT_CENTERED);
		//
		//    nk_group_end(ctx);
		//}

	}
	nk_end(ctx);
}

void renderShaderPanelEntrance(struct nk_context* ctx)
{
	for (auto it = G.stShaderPanelMap.begin(); it != G.stShaderPanelMap.end(); it++) {
		string panelName = it->first;
		string btnName = "Show ";
		btnName += panelName;
		auto& showValue = G.cache.iValue[panelName];
		if (nk_button_label(ctx, btnName.c_str())) {
            showValue = !showValue;
		}
	}
}

void renderMain(struct nk_context *ctx)
{
	if (nk_begin(ctx, PANEL_MAIN, G.panelMainRect, NK_WINDOW_BORDER | NK_WINDOW_MINIMIZABLE)) {
		nk_layout_row_dynamic(ctx, 25, 1);

		if (nk_button_label(ctx, BTN_COMMON_SHADER)) {
			// G.isShowPanelCommonShader = 1;
            G.isShowPanelCommonShader = !G.isShowPanelCommonShader;
		}

		// render other shader panel entrance
		renderShaderPanelEntrance(ctx);

		// background color
		propertyColorB(ctx, "#bgColor", &G.bgColor, PROPERTY_COLOR_SIZE);

		// light color
		nk_layout_row_dynamic(ctx, 1, 1);
		propertyColor(ctx, "lightColor", &G.stColorShader.uColor, PROPERTY_COLOR_SIZE);

		nk_layout_row_dynamic(ctx, 25, 1);
		nk_selectable_label(ctx, "point light action", NK_TEXT_LEFT, &G.isPointLightMove);

		///////////////////////////////////////////////////////////////////////
		// static struct nk_color rgba;
		// propertyColorB(ctx, "#test Color", &rgba, PROPERTY_COLOR_SIZE);

		// static char bb[1000] = {0};
		// sprintf(bb, "%lf", glfwGetTime());
		// propertyStringWithLayout(ctx, "glfwGetTime() ", bb);
		///////////////////////////////////////////////////////////////////////

		nk_layout_row_dynamic(ctx, 25, 1);
		nk_label(ctx, "...", NK_TEXT_CENTERED);
	}
	nk_end(ctx);
}

void renderUI(struct nk_context *ctx)
{
	// what property do you want to modify?

	//if (nk_begin(ctx, "property panel", nk_rect(200, 10, 300, 400), NK_WINDOW_MOVABLE | NK_WINDOW_CLOSABLE | NK_WINDOW_TITLE)) {
	//
	//    static float vec3A[3];
	//    propertyVec3(ctx, "position", &vec3A[0], &vec3A[1], &vec3A[2], nk_vec2(190, 200));
	//
	//    static float value;
	//    propertyFloat(ctx, "value", &value);
	//
	//    static int iValue;
	//    propertyInt(ctx, "iValue", &iValue);
	//
	//    static float vec2A[2];
	//    propertyVec2(ctx, "vec2", &vec2A[0], &vec2A[1], nk_vec2(190, 200));
	//
	//    static struct nk_colorf combo_color1_1 = {0.509f, 0.705f, 0.2f, 1.0f};
	//    propertyColor(ctx, "combo_color", &combo_color1_1, nk_vec2(200,400));
	//}
	//nk_end(ctx);

	renderMain(ctx);

	renderCommonShaderPanel(ctx);

	renderStatus(ctx);

	// render other shader panel
	renderShaderPanel(ctx);
}

// ---------------------------------------------------------------------------------------------------------
// renders (and builds at first invocation) a sphere
// -------------------------------------------------
unsigned int sphereVAO = 0;
unsigned int indexCount;
void renderSphere()
{
    if (sphereVAO == 0)
    {
        glGenVertexArrays(1, &sphereVAO);

        unsigned int vbo, ebo;
        glGenBuffers(1, &vbo);
        glGenBuffers(1, &ebo);

        std::vector<glm::vec3> positions;
        std::vector<glm::vec2> uv;
        std::vector<glm::vec3> normals;
        std::vector<unsigned int> indices;

        const unsigned int X_SEGMENTS = 64;
        const unsigned int Y_SEGMENTS = 64;
        const float PI = 3.14159265359;
        for (unsigned int y = 0; y <= Y_SEGMENTS; ++y)
        {
            for (unsigned int x = 0; x <= X_SEGMENTS; ++x)
            {
                float xSegment = (float)x / (float)X_SEGMENTS;
                float ySegment = (float)y / (float)Y_SEGMENTS;
                float xPos = std::cos(xSegment * 2.0f * PI) * std::sin(ySegment * PI);
                float yPos = std::cos(ySegment * PI);
                float zPos = std::sin(xSegment * 2.0f * PI) * std::sin(ySegment * PI);

                positions.push_back(glm::vec3(xPos, yPos, zPos));
                uv.push_back(glm::vec2(xSegment, ySegment));
                normals.push_back(glm::vec3(xPos, yPos, zPos));
            }
        }

        bool oddRow = false;
        for (int y = 0; y < Y_SEGMENTS; ++y)
        {
            if (!oddRow) // even rows: y == 0, y == 2; and so on
            {
                for (int x = 0; x <= X_SEGMENTS; ++x)
                {
                    indices.push_back(y       * (X_SEGMENTS + 1) + x);
                    indices.push_back((y + 1) * (X_SEGMENTS + 1) + x);
                }
            }
            else
            {
                for (int x = X_SEGMENTS; x >= 0; --x)
                {
                    indices.push_back((y + 1) * (X_SEGMENTS + 1) + x);
                    indices.push_back(y       * (X_SEGMENTS + 1) + x);
                }
            }
            oddRow = !oddRow;
        }
        indexCount = indices.size();

        std::vector<float> data;
        for (int i = 0; i < positions.size(); ++i)
        {
            data.push_back(positions[i].x);
            data.push_back(positions[i].y);
            data.push_back(positions[i].z);
            if (uv.size() > 0)
            {
                data.push_back(uv[i].x);
                data.push_back(uv[i].y);
            }
            if (normals.size() > 0)
            {
                data.push_back(normals[i].x);
                data.push_back(normals[i].y);
                data.push_back(normals[i].z);
            }
        }
        glBindVertexArray(sphereVAO);
        glBindBuffer(GL_ARRAY_BUFFER, vbo);
        glBufferData(GL_ARRAY_BUFFER, data.size() * sizeof(float), &data[0], GL_STATIC_DRAW);
        glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, ebo);
        glBufferData(GL_ELEMENT_ARRAY_BUFFER, indices.size() * sizeof(unsigned int), &indices[0], GL_STATIC_DRAW);

        float stride = (3 + 2 + 3) * sizeof(float);

        glEnableVertexAttribArray(0);
        glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, stride, (void*)0);

		glEnableVertexAttribArray(2);
        glVertexAttribPointer(2, 2, GL_FLOAT, GL_FALSE, stride, (void*)(3 * sizeof(float)));

		glEnableVertexAttribArray(1);
        glVertexAttribPointer(1, 3, GL_FLOAT, GL_FALSE, stride, (void*)(5 * sizeof(float)));
    }

    glBindVertexArray(sphereVAO);
    glDrawElements(GL_TRIANGLE_STRIP, indexCount, GL_UNSIGNED_INT, 0);
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
			-1.0f, -1.0f, -1.0f, 0.0f, 0.0f, -1.0f, 0.0f, 0.0f, // bottom-left
			1.0f, 1.0f, -1.0f, 0.0f, 0.0f, -1.0f, 1.0f, 1.0f,   // top-right
			1.0f, -1.0f, -1.0f, 0.0f, 0.0f, -1.0f, 1.0f, 0.0f,  // bottom-right
			1.0f, 1.0f, -1.0f, 0.0f, 0.0f, -1.0f, 1.0f, 1.0f,   // top-right
			-1.0f, -1.0f, -1.0f, 0.0f, 0.0f, -1.0f, 0.0f, 0.0f, // bottom-left
			-1.0f, 1.0f, -1.0f, 0.0f, 0.0f, -1.0f, 0.0f, 1.0f,  // top-left
			// front face
			-1.0f, -1.0f, 1.0f, 0.0f, 0.0f, 1.0f, 0.0f, 0.0f, // bottom-left
			1.0f, -1.0f, 1.0f, 0.0f, 0.0f, 1.0f, 1.0f, 0.0f,  // bottom-right
			1.0f, 1.0f, 1.0f, 0.0f, 0.0f, 1.0f, 1.0f, 1.0f,   // top-right
			1.0f, 1.0f, 1.0f, 0.0f, 0.0f, 1.0f, 1.0f, 1.0f,   // top-right
			-1.0f, 1.0f, 1.0f, 0.0f, 0.0f, 1.0f, 0.0f, 1.0f,  // top-left
			-1.0f, -1.0f, 1.0f, 0.0f, 0.0f, 1.0f, 0.0f, 0.0f, // bottom-left
			// left face
			-1.0f, 1.0f, 1.0f, -1.0f, 0.0f, 0.0f, 1.0f, 0.0f,   // top-right
			-1.0f, 1.0f, -1.0f, -1.0f, 0.0f, 0.0f, 1.0f, 1.0f,  // top-left
			-1.0f, -1.0f, -1.0f, -1.0f, 0.0f, 0.0f, 0.0f, 1.0f, // bottom-left
			-1.0f, -1.0f, -1.0f, -1.0f, 0.0f, 0.0f, 0.0f, 1.0f, // bottom-left
			-1.0f, -1.0f, 1.0f, -1.0f, 0.0f, 0.0f, 0.0f, 0.0f,  // bottom-right
			-1.0f, 1.0f, 1.0f, -1.0f, 0.0f, 0.0f, 1.0f, 0.0f,   // top-right
			// right face
			1.0f, 1.0f, 1.0f, 1.0f, 0.0f, 0.0f, 1.0f, 0.0f,   // top-left
			1.0f, -1.0f, -1.0f, 1.0f, 0.0f, 0.0f, 0.0f, 1.0f, // bottom-right
			1.0f, 1.0f, -1.0f, 1.0f, 0.0f, 0.0f, 1.0f, 1.0f,  // top-right
			1.0f, -1.0f, -1.0f, 1.0f, 0.0f, 0.0f, 0.0f, 1.0f, // bottom-right
			1.0f, 1.0f, 1.0f, 1.0f, 0.0f, 0.0f, 1.0f, 0.0f,   // top-left
			1.0f, -1.0f, 1.0f, 1.0f, 0.0f, 0.0f, 0.0f, 0.0f,  // bottom-left
			// bottom face
			-1.0f, -1.0f, -1.0f, 0.0f, -1.0f, 0.0f, 0.0f, 1.0f, // top-right
			1.0f, -1.0f, -1.0f, 0.0f, -1.0f, 0.0f, 1.0f, 1.0f,  // top-left
			1.0f, -1.0f, 1.0f, 0.0f, -1.0f, 0.0f, 1.0f, 0.0f,   // bottom-left
			1.0f, -1.0f, 1.0f, 0.0f, -1.0f, 0.0f, 1.0f, 0.0f,   // bottom-left
			-1.0f, -1.0f, 1.0f, 0.0f, -1.0f, 0.0f, 0.0f, 0.0f,  // bottom-right
			-1.0f, -1.0f, -1.0f, 0.0f, -1.0f, 0.0f, 0.0f, 1.0f, // top-right
			// top face
			-1.0f, 1.0f, -1.0f, 0.0f, 1.0f, 0.0f, 0.0f, 1.0f, // top-left
			1.0f, 1.0f, 1.0f, 0.0f, 1.0f, 0.0f, 1.0f, 0.0f,   // bottom-right
			1.0f, 1.0f, -1.0f, 0.0f, 1.0f, 0.0f, 1.0f, 1.0f,  // top-right
			1.0f, 1.0f, 1.0f, 0.0f, 1.0f, 0.0f, 1.0f, 0.0f,   // bottom-right
			-1.0f, 1.0f, -1.0f, 0.0f, 1.0f, 0.0f, 0.0f, 1.0f, // top-left
			-1.0f, 1.0f, 1.0f, 0.0f, 1.0f, 0.0f, 0.0f, 0.0f   // bottom-left
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

unsigned int coordVAO = 0;
unsigned int coordVBO = 0;
void renderCoordinateSystem()
{
	if (coordVAO == 0)
	{
		float x, y, z;
		x = y = z = 100000000.0f;

		float vertices[] = {
			// position          color
			0.0, 0.0, 0.0,    1.0, 0.0, 0.0,
			x,   0.0, 0.0,    1.0, 0.0, 0.0,

			0.0, 0.0, 0.0,    0.0, 1.0, 0.0,
			0.0, y,   0.0,    0.0, 1.0, 0.0,

			0.0, 0.0, 0.0,    0.0, 0.0, 1.0,
			0.0, 0.0, z,      0.0, 0.0, 1.0,
		};
		int size = 6;
		int positionSize = 3;
		int colorSize = 3;

		glGenVertexArrays(1, &coordVAO);
		glGenBuffers(1, &coordVBO);

		glBindBuffer(GL_ARRAY_BUFFER, coordVBO);
		glBufferData(GL_ARRAY_BUFFER, sizeof(vertices), vertices, GL_STATIC_DRAW);

		glBindVertexArray(coordVAO);
		glEnableVertexAttribArray(0);// aPos
		glVertexAttribPointer(0, positionSize, GL_FLOAT, GL_FALSE, size * sizeof(float), (void*)0);

		glEnableVertexAttribArray(1);// aColor
		glVertexAttribPointer(1, colorSize, GL_FLOAT, GL_FALSE, size * sizeof(float), (void*)(3 * sizeof(float)));

		glBindBuffer(GL_ARRAY_BUFFER, 0);
		glBindVertexArray(0);
	}

	glBindVertexArray(coordVAO);
	glDrawArrays(GL_LINES, 0, 6);
	glBindVertexArray(0);
}

void renderScene()
{
	glEnable(GL_DEPTH_TEST);
	glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

	// use bgColor
	glClearColor(CNTo1(G.bgColor.r), CNTo1(G.bgColor.g), CNTo1(G.bgColor.b), CNTo1(G.bgColor.a));

	// ====================================================
	glActiveTexture(GL_TEXTURE0);
	glBindTexture(GL_TEXTURE_2D, texture0);

	glm::vec3 lightPos;

	if (G.isPointLightMove)
	{
		static int direction = 1;
		float cosValue = cos(G.currentTime);
		if (fuzzyEquals(cosValue, 1.0)) {
			direction = direction == 1 ? -1 : 1;
		}

		float theta = direction * G.currentTime;
		float cosTheta = cos(theta);
		float sinTheta = sin(theta);
		lightPos = glm::vec3(3.0 * cosTheta, 3.0 * sinTheta, 3.0 * cosTheta * sinTheta);
	}
	else
	{
		lightPos = glm::vec3(3.0, 3.0, 3.0);
	}

	if (G.isRotatingCameraY)
	{
		// rotate camera
		rotateCameraY(sin(G.currentTime), cos(G.currentTime));
		// rotateCameraByYaw(10);

		// update mvp
		projectionMatrix = perspectiveMatrix();
		viewMatrix = camera.GetViewMatrix();
		mvp = projectionMatrix * viewMatrix;
	}

	// use common shader
	if (pShader != NULL)
	{
		pShader->use();
		pShader->setFloat("uTime", G.currentTime);
		pShader->setInt("uUsePointLight", G.stCommonShader.uUsePointLight);
		// pShader->setInt("uSwitchEffectInvert", G.stCommonShader.uSwitchEffectInvert);
		pShader->setInt("uSwitchEffectGray", G.stCommonShader.uSwitchEffectGray);

		pShader->setVec3("uViewPos", G.camera->Position);
		pShader->setVec3("uLightPos", lightPos);
		pShader->setVec3("uLightColor", convertCFToVec3(&G.stColorShader.uColor));

		glm::vec3 vT = glm::vec3(0.0f);
		// glm::mat4 mvp_1 = glm::translate(mvp, vT);
		glm::mat4 m = glm::translate(IMatrix4, vT);
		m = glm::scale(m, glm::vec3(1.0));

		glm::mat4 mvp_1 = mvp * m;
		pShader->setMat4("mvp", mvp_1);
		pShader->setMat4("uMat4Model", m);
		pShader->setMat3("uNormalMatrix", normalMatrix(m));

		pShader->setVec3("uColor", convertCFToVec3(&G.stCommonShader.objectColor));
		pShader->setFloat("uRatioMixTex2Color", G.stCommonShader.uRatioMixTex2Color);
		pShader->setFloat("uRatioMixAColor2UColor", 1.0); // use uColor
		renderCube(); // cube 1

		glm::vec3 position = glm::vec3(5.0f, 0, 0);
		glm::mat4 m1 = IMatrix4;
		m1 = glm::translate(m1, position);

		pShader->setMat4("mvp", mvp * m1);
		pShader->setMat4("uMat4Model", m1);
		pShader->setMat3("uNormalMatrix", normalMatrix(m1));
		// pShader->setMat3("uNormalMatrix", glm::mat3(m1));
		renderCube(); // cube 2

		glm::mat4 m2 = translate(glm::vec3(2.0, 0.0, 6.0));
		m2 = rotateByY(25 * G.currentTime, m2);
		pShader->setMat4("mvp", mvp * m2);
		pShader->setMat4("uMat4Model", m2);
		pShader->setMat3("uNormalMatrix", normalMatrix(m2));
		// pShader->setMat3("uNormalMatrix", glm::mat3(m2));
		renderCube(); // cube 3

		glm::mat4 m3 = translate(glm::vec3(-10.0, -5.0, -10.0));
		m3 = scale(glm::vec3(8.0, 3.0, 8.0), m3);
		m3 = rotateByY(45.0f, m3);
		pShader->setMat4("mvp", mvp * m3);
		pShader->setMat4("uMat4Model", m3);
		pShader->setMat3("uNormalMatrix", normalMatrix(m3));
		// pShader->setMat3("uNormalMatrix", glm::mat3(m3));
		renderCube(); // cube 4

		// ====================================================

		glm::vec3 vT0 = glm::vec3(0);
		pShader->setMat4("mvp", glm::translate(mvp, vT0));
		pShader->setFloat("uRatioMixTex2Color", 1.0);
		pShader->setFloat("uRatioMixAColor2UColor", 0.0); // use vertex color
		pShader->setInt("uUsePointLight", 0);
		pShader->setInt("uSwitchEffectInvert", 0);
		pShader->setInt("uSwitchEffectGray", 0);
		renderCoordinateSystem();

		{
			auto& stShaderPanel =  G.stShaderPanelMap[PANEL_SHADER_1];
			auto shader = stShaderPanel.shader;
			if (shader != NULL) {
				for (auto ite = stShaderPanel.propertyArray.begin(); ite != stShaderPanel.propertyArray.end(); ite++)
				{
					auto& stProperty = *ite;
					if (stProperty.type == TYPE_INT) {
						shader->setInt(stProperty.name.c_str(), stProperty.iVal);
					}

					// todo
					// ...
				}
			}
			// shader->
		}
	}
	// ====================================================

	if (G.colorShader)
	{
		Shader* shader = G.colorShader;
		shader->use();

		glm::mat4 m = glm::mat4(1.0f);
		glm::mat4 m1 = glm::translate(m, lightPos);
		glm::mat4 m2 = glm::scale(m1, glm::vec3(0.1f));
		shader->setMat4("mvp", mvp * m2);
		shader->setVec4("uColor", convertCFToVec4(&G.stColorShader.uColor));

		renderSphere();
	}
	// ====================================================
}


int main(void)
{
	/* initialize global state */
	initState();

	/* Platform */
	static GLFWwindow *win;
	int width = 0, height = 0;
	struct nk_context *ctx;

	/* GLFW */
	glfwSetErrorCallback(error_callback);
	if (!glfwInit()) {
		fprintf(stdout, "[GFLW] failed to init!\n");
		exit(1);
	}

	glfwWindowHint(GLFW_CONTEXT_VERSION_MAJOR, 3);
	glfwWindowHint(GLFW_CONTEXT_VERSION_MINOR, 3);
	glfwWindowHint(GLFW_OPENGL_PROFILE, GLFW_OPENGL_CORE_PROFILE);
	glfwWindowHint(GLFW_SAMPLES, 4);

#ifdef __APPLE__
	glfwWindowHint(GLFW_OPENGL_FORWARD_COMPAT, GL_TRUE);
#endif

	win = glfwCreateWindow(WINDOW_WIDTH, WINDOW_HEIGHT, "Nuklear&OpenGL", NULL, NULL);

	glfwMakeContextCurrent(win);
	glfwGetWindowSize(win, &width, &height);
	glfwSetCursorPosCallback(win, mouse_callback);
	glfwSetScrollCallback(win, scroll_callback);

	/* OpenGL */
	gladLoadGL();
	initGLSetting();

	//////////////////////////////////////////////////
	// init nuklear
	ctx = nk_glfw3_init(win, NK_GLFW3_INSTALL_CALLBACKS);
	/* Load Fonts: if none of these are loaded a default font will be used  */
	/* Load Cursor: if you uncomment cursor loading please hide the cursor */
	{
		struct nk_font_atlas *atlas;
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

	// loop
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

		G.currentTime = glfwGetTime();

		if (sumFrameCost >= 1.0) {
			//printf("last sec = %d   current sec = %d  count = %lu clockCount = %lu fps = %f sumFrameCost = %f\n", lastRunSec, currentRunSec, frameCountPerSec, clockCount, fps, sumFrameCost);
			frameCountPerSec = 0;
			clockCount = 0;
			sumFrameCost = 0;
		}

		/* update camera */
		projectionMatrix = perspectiveMatrix();
		viewMatrix = camera.GetViewMatrix();
		mvp = projectionMatrix * viewMatrix;

		processInput(win, (float)deltaFrame);

		/* Input */
		glfwPollEvents();
		nk_glfw3_new_frame();

		/* GUI */
		renderUI(ctx);

		/* Draw */
		renderScene();

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
	clear();

	return 0;
}
