
#ifndef FireStShaderPanel_h
#define FireStShaderPanel_h

#include <FireDefinition.h>
#include <FireProperty.h>
#include <shader.h>

#include <vector>
#include <string>
#include <iostream>

using namespace std;

NS_FIRE_BEGIN

struct StShaderPanel {
    string name;
    PropertyArray propertyArray;
    Shader* shader;
    bool isShow;
	bool isUse;
    char nameBuffer[128];
    string vertexShaderPath;
    string fragmentShaderPath;
    
    StShaderPanel():name(""), shader(NULL), isShow(false), isUse(false) {
        memset(nameBuffer, 0, sizeof(nameBuffer));
    }
    ~StShaderPanel() {
        name.clear(); shader = NULL;
        
    }
};



NS_FIRE_END__

#endif
