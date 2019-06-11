#ifndef FireUI_h
#define FireUI_h

#include <FireDefinition.h>
#include <FireState.h>
#include "imgui.h"


NS_FIRE_BEGIN

class UI {
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
    
    void render()
    {
        for (auto it = G.stShaderPanelMap.begin(); it != G.stShaderPanelMap.end(); it++) {
            renderShaderPanel(it->first.c_str());
        }
    }
    
    void renderShaderPanel(const char* key) {
        auto& stShaderPanel = G.stShaderPanelMap[key];
        // bool& open = stShaderPanel.isShow;
        
        ImGui::SetNextWindowSize(ImVec2(430, 450), ImGuiCond_FirstUseEver);
        if (!ImGui::Begin(stShaderPanel.name.c_str()/* , &open */))
        {
            ImGui::End();
            return;
        }
        
        ImGui::LabelText("", "Input data:");
        
        ImGui::SetNextItemWidth(180);
        // input property name
        if (ImGui::InputText("Name", stShaderPanel.nameBuffer, sizeof(stShaderPanel.nameBuffer))) {
            printf("%s\n", stShaderPanel.nameBuffer);
        }
        
        ImGui::SetNextItemWidth(180);
        // select property type
        struct FuncHolder { static bool ItemGetter(void* data, int idx, const char** out_str) { *out_str = ((const char**)data)[idx]; return true; } };
        static int item_current = 0;
        if (ImGui::Combo("Type", &item_current, &FuncHolder::ItemGetter, TypeNames, ARRAY_LENGTH(TypeNames), ARRAY_LENGTH(TypeNames))) {
            //printf("select %d \n", item_current);
        }
        
        ImGui::Separator();
        ImGui::TextColored(ImVec4(1.0f, 0, 0, 0.8f), "Num = %d", (int)stShaderPanel.propertyArray.size());
        //        ImGui::SameLine(0, ImGui::GetFontSize() * 3);
        ImGui::SameLine(180);
        if (ImGui::Button("Create"))
        {
            // create property data
            int type = item_current;
            struct StProperty prop = StProperty(type);
            if (strlen(stShaderPanel.nameBuffer) == 0) {
                prop.name = "Prop_";
                prop.name.append(TypeNames[item_current]);
            } else {
                prop.name = stShaderPanel.nameBuffer;
            }
            
            stShaderPanel.propertyArray.push_back(prop);
        }
        
        ImGui::SameLine();
        if (ImGui::Button("Save"))
        {
            const string& str = toJSON(stShaderPanel);
            string path = stShaderPanel.name + ".json";
            writeToFile(path.c_str(), str.c_str());
        }
        
        ImGui::Separator();
        
        ImGui::LabelText("", "List:");
        ImGui::PushStyleVar(ImGuiStyleVar_FramePadding, ImVec2(2, 2));
        //        ImGui::PushStyleVar(ImGuiStyleVar_ItemSpacing, ImVec2(2, 10));
        ImGui::Columns(2);
        ImGui::Separator();
        // ImGui::SetColumnWidth(0, ImGui::GetFontSize() * 12.0f);
        
        // create property ui
        int id = 0;
        auto& propertyArray = stShaderPanel.propertyArray;
        for (auto it = propertyArray.begin(); it != propertyArray.end(); )
        {
            auto& prop = *it;
            
            ImGui::PushID(id++);
            
            ImGui::AlignTextToFramePadding();
            bool isClick = ImGui::Button(" - "); // remove
            ImGui::SameLine();
            ImGui::Text(prop.name.c_str());
            
            ImGui::NextColumn();
            
            ImGui::AlignTextToFramePadding();
            ImGui::SetNextItemWidth(-1);
            
            switch (prop.type)
            {
                case Type_Int: {
                    ImGui::PushID("InputInt_Int");
                    ImGui::InputInt("", &prop.iVal);
                    ImGui::PopID();
                    
                    prop.iVal = clamp(prop.iVal, prop.iMin, prop.iMax);
                    
                    ImGui::SetNextItemWidth(ImGui::GetFontSize() * 6.0f);
                    ImGui::SliderInt("", &prop.iVal, prop.iMin, prop.iMax);
                    
                    ImGui::SameLine();
                    ImGui::SetNextItemWidth(-1);
                    ImGui::DragIntRange2("", &prop.iMin, &prop.iMax, 1.0f, INT_MIN / 2, INT_MAX / 2, "min:%d", "max:%d");
                    
                    break;
                }
                case Type_Float: {
                    ImGui::PushID("InputFloat_Float");
                    ImGui::InputFloat("", &prop.fVal, 0.01f, 0.1f);
                    ImGui::PopID();
                    
                    prop.fVal = clamp(prop.fVal, prop.fMin, prop.fMax);
                    
                    ImGui::SetNextItemWidth(ImGui::GetFontSize() * 6.0f);
                    ImGui::SliderFloat("", &prop.fVal, prop.fMin, prop.fMax);
                    
                    ImGui::SameLine();
                    ImGui::SetNextItemWidth(-1);
                    ImGui::DragFloatRange2("", &prop.fMin, &prop.fMax, 0.0001f, Float_Min, Float_Max, "min:%.04f", "max:%.04f");
                    
                    break;
                }
                case Type_Color: {
                    float rgba[4] = { prop.cfVal.r, prop.cfVal.g, prop.cfVal.b, prop.cfVal.a };
                    ImGui::ColorEdit4("", rgba, ImGuiColorEditFlags_Float | ImGuiColorEditFlags_AlphaBar | ImGuiColorEditFlags_PickerHueWheel);
                    prop.cfVal.r = rgba[0]; prop.cfVal.g = rgba[1]; prop.cfVal.b = rgba[2]; prop.cfVal.a = rgba[3];
                    break;
                }
                case Type_String: {
                    char buffer[2048] = { 0 };
                    strcpy(buffer, prop.sVal.c_str());
                    // strcpy_s(buffer, prop.sVal.c_str());
                    if (ImGui::InputText("", buffer, sizeof(buffer))) {
                        prop.sVal = buffer;
                    }
                }
                default: break;
            }
            
            ImGui::NextColumn();
            ImGui::PopID();
            
            if (isClick) {
                it = propertyArray.erase(it);
            } else {
                it++;
            }
        }
        
        ImGui::PopStyleVar();
        
        ImGui::End();
    }
    
    
    UI() {}
    ~UI() {}
};

UI ui;

NS_FIRE_END__

#endif /* FireUI_h */
