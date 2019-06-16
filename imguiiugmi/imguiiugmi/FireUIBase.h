#ifndef FireUIBase_h
#define FireUIBase_h

#include <FireDefinition.h>
#include "imgui.h"

NS_FIRE_BEGIN

class UIBase {
public:
    
    
    // Helper to display a little (?) mark which shows a tooltip when hovered.
    // In your own code you may want to display an actual icon if you are using a merged icon fonts (see misc/fonts/README.txt)
    static void HelpMarker(const char* desc)
    {
        ImGui::TextDisabled("(?)");
        if (ImGui::IsItemHovered())
        {
            ImGui::BeginTooltip();
            ImGui::PushTextWrapPos(ImGui::GetFontSize() * 35.0f);
            ImGui::TextUnformatted(desc);
            ImGui::PopTextWrapPos();
            ImGui::EndTooltip();
        }
    }
    
    
    UIBase() {}
    ~UIBase() {}
    
    virtual void init() {
        
    }
    
    /// virtual make subclass replace this method, when the method call like: base::render();
    virtual void render() {
//        printf("UIBase.render()\n");
    };
};

#define UIBase UIBase

NS_FIRE_END__

#endif
