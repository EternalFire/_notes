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
#define CNTo1(component) (float)(component/255.0f)

#define CNTo255(component) (int)(component*255.0f)

#define FIRE_API

///
NS_FIRE_BEGIN

const char* Name = NS_FIRE_NAME;

const float Float_Min = -10000000000.0f;
const float Float_Max = +10000000000.0f;
const float Float_Min_Normal = -100.0f;
const float Float_Max_Normal = 100.0f;

const int Int_Min_Normal = -100;
const int Int_Max_Normal = 100;


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
    Type_Array  = 12,
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
    "Array",
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


struct StProperty;
typedef vector<struct StProperty> PropertyArray;
struct StShaderPanel;

struct StConfig;
struct State;

class UI;
class Painter;

void SaveShaderNames();
void SaveStShaderPanel(const string& shaderName);
void SaveConfig();

NS_FIRE_END__
///

#endif
