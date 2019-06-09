#ifndef Fire_h
#define Fire_h

#define STB_IMAGE_IMPLEMENTATION
#include <stb_image.h>

#define GLM_FORCE_SWIZZLE
#include <glm/glm.hpp>

#include <shader.h>
#include <camera.h>

#define NS_FIRE Fire
#define NS_FIRE_BEGIN namespace NS_FIRE {
#define NS_FIRE_END__ }

#define _S(val) #val
#define NS_FIRE_NAME_1(n) _S(n)
#define NS_FIRE_NAME NS_FIRE_NAME_1(NS_FIRE)

#define FIRE_API

///
NS_FIRE_BEGIN

struct Vec2 { float x; float y; };
struct IVec2 { int x; int y; };

struct Vec3 { float x; float y; float z; };
struct IVec3 { int x; int y; int z; };

struct Vec4 { float x; float y; float z; float w; };
struct IVec4 { int x; int y; int z; int w; };

struct RGBA { int r; int g; int b; int a; };
struct F_RGBA { float r; float g; float b; float a; };

struct State {
    double currentFrame;
};


static const char* Name = NS_FIRE_NAME;
static State G;

class UI {
public:
    void createTest() {
        static int counter = 0;
        ImGui::Begin(Name);
        ImGui::Text( "namespace: %s", Name);
        ImGui::Text("G.currentFrame: %lf", G.currentFrame);
        if (ImGui::Button("btn")) {
            printf("btn %d\n", counter++);
        }
        
        ImGui::End();
    }
    
    UI() {}
    ~UI() {}
};

static UI ui;

void BeginTick()
{
    printf("BeginTick\n");
}

void EndTick()
{
    printf("EndTick\n");
}

/// render ui
void TickUI()
{
    ui.createTest();
}

/// apply shader program
void TickScene()
{
    printf("TickScene\n");
}

void Clear()
{
    printf("Clear\n");
}
NS_FIRE_END__
///

#endif
