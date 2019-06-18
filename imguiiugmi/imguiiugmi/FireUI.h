#ifndef FireUI_h
#define FireUI_h

#include <FireDefinition.h>
#include <FireUIBase.h>
#include <FireState.h>
#include <FireUtility.h>
#include "imgui.h"
#include <FireUIShaderEntrance.h>
#include <FireUIShaderPanel.h>
#include <FireUIProperty.h>
#include <FireUICameraPanel.h>

NS_FIRE_BEGIN

class UI: public UIBase {
public:

    UI() {}
    ~UI() {}

    void init() {
		shaderEntrance.init();
		shaderPanel.init();
		propertyPanel.init();
        cameraPanel.init();
    }

    void render()
    {
		shaderEntrance.render();
        shaderPanel.render();
        //propertyPanel.render();
        cameraPanel.render();
    }


public:
    UIShaderPanel shaderPanel;
    UIProperty propertyPanel;
	UIShaderEntrance shaderEntrance;
    UICameraPanel cameraPanel;
};

UI ui;

NS_FIRE_END__

#endif /* FireUI_h */
