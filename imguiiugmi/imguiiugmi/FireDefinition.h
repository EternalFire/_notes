#ifndef _FIRE_DEFINITION_H_
#define _FIRE_DEFINITION_H_

//#define GLM_FORCE_SWIZZLE
//#include <glm/glm.hpp>

#define NS_FIRE Fire
#define NS_FIRE_BEGIN namespace NS_FIRE {
#define NS_FIRE_END__ }

#define _S(val) #val
#define NS_FIRE_NAME_1(n) _S(n)
#define NS_FIRE_NAME NS_FIRE_NAME_1(NS_FIRE)

#define ARRAY_LENGTH(_ARR)          ((int)(sizeof(_ARR)/sizeof(*_ARR)))

// convert rgba color component to [0,1] by divided by 255
#define CNTo1(component) (component/255.0f)

#define FIRE_API

///
NS_FIRE_BEGIN

const float Float_Min = -10000000000.0f;
const float Float_Max = +10000000000.0f;
const char* Name = NS_FIRE_NAME;
const char* ResPath = "resources/";
const char* ResShaderPath = "resources/shaders/";

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

const glm::mat4 IMatrix4(1.0f); // identty matrix
const glm::vec3 xAxis(1.0f, 0.0f, 0.0f);
const glm::vec3 yAxis(0.0f, 1.0f, 0.0f);
const glm::vec3 zAxis(0.0f, 0.0f, 1.0f);

typedef struct Vec2  { float x; float y; } Vec2;
typedef struct IVec2 { int x; int y; } IVec2;

typedef struct Vec3  { float x; float y; float z; } Vec3;
typedef struct IVec3 { int x; int y; int z; } IVec3;

typedef struct Vec4  { float x; float y; float z; float w; } Vec4;
typedef struct IVec4 { int x; int y; int z; int w; } IVec4;

typedef struct Color  { float r; float g; float b; float a; } Color;
typedef struct IColor { int r; int g; int b; int a; } IColor;

enum Type {
    Type_Int    = 0,
    Type_Float  = 1,
    Type_Vec2   = 2,
    Type_IVec2  = 3,
    Type_Vec3   = 4,
    Type_IVec3  = 5,
    Type_Vec4   = 6,
    Type_IVec4  = 7,
    Type_Color  = 8,
    Type_IColor = 9,
    Type_String = 10,
    Type_Bool   = 11,
};

const char * TypeNames[] = {
    "Int",
    "Float",
    "Vec2",
    "IVec2",
    "Vec3",
    "IVec3",
    "Vec4",
    "IVec4",
    "Color",
    "IColor",
    "String",
    "Bool",
};

int getTypeByName(const string& name) {
    for (int i = 0; i < sizeof(TypeNames); i++)
    {
        if (name.compare(TypeNames[i]) == 0) {
            return i;
        }
    }
    return 0;
}

class UI;

NS_FIRE_END__
///

#endif
