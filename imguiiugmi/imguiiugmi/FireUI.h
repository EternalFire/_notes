#ifndef FireUI_h
#define FireUI_h

#include <FireDefinition.h>
#include <FireUIBase.h>
#include <FireState.h>
#include "imgui.h"
#include <FireUIShaderPanel.h>
#include <FireUIProperty.h>

NS_FIRE_BEGIN

class UI: public UIBase {
public:
    
    UI() {}
    ~UI() {}
    
    void init() {
        sp.init();
        pp.init();
    }
    
    void render()
    {
        
        
        sp.render();
        pp.render();
    }
    
    
public:
    UIShaderPanel sp;
    UIProperty pp;
};

UI ui;

NS_FIRE_END__

#endif /* FireUI_h */
