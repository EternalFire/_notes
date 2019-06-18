#ifndef FireUI_h
#define FireUI_h

#include <FireDefinition.h>
#include <FireUIBase.h>
#include <FireState.h>
#include "imgui.h"
#include <FireUIShaderEntrance.h>
#include <FireUIShaderPanel.h>
#include <FireUIProperty.h>
#include <FireUtility.h>

NS_FIRE_BEGIN

class UI: public UIBase {
public:

    UI() {}
    ~UI() {}

    void init() {
		shaderEntrance.init();
		shaderPanel.init();
		propertyPanel.init();
    }

    void render()
    {
		shaderEntrance.render();
        shaderPanel.render();
        //propertyPanel.render();
    }


public:
    UIShaderPanel shaderPanel;
    UIProperty propertyPanel;
	UIShaderEntrance shaderEntrance;
};

UI ui;

NS_FIRE_END__

#endif /* FireUI_h */
