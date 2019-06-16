#ifndef FireUIProperty_h
#define FireUIProperty_h

#include <FireDefinition.h>
#include <FireUIBase.h>
#include <FireState.h>
#include "imgui.h"

NS_FIRE_BEGIN

class UIProperty : public UIBase {
public:
    static void RenderPropertyArrayInTwoColumn(PropertyArray& propertyArray)
    {
        int id = 0;
        bool treeNodeOpened = false;
        
        for (auto it = propertyArray.begin(); it != propertyArray.end(); )
        {
            auto& prop = *it;
            
            ImGui::Spacing();
            ImGui::AlignTextToFramePadding();
            
            /**
             *  [ - ]  name  (next) |  widget  (next)
             *  [ - ]  name  (next) |  widget  (next)
             *  [ - ]  name  (next) |  widget  (next)
             */
            
            // red button
            ImGui::PushID(id++);
            ImGui::PushStyleColor(ImGuiCol_Button, (ImVec4)ImColor::HSV(0.1/7.0f, 0.6f, 0.6f));
            ImGui::PushStyleColor(ImGuiCol_ButtonHovered, (ImVec4)ImColor::HSV(0.1/7.0f, 0.7f, 0.7f));
            ImGui::PushStyleColor(ImGuiCol_ButtonActive, (ImVec4)ImColor::HSV(0.1/7.0f, 0.8f, 0.8f));
            bool isClick = ImGui::Button(" - "); // remove
            ImGui::PopStyleColor(3);
            ImGui::PopID();
            
            // name text
            ImGui::SameLine();
            //            ImGui::Text(prop.name.c_str(), "");
            
            ImGui::PushID(id++);
            char buffer[128] = { 0 };
            strcpy(buffer, prop.name.c_str());
            if (ImGui::InputText("", buffer, sizeof(buffer))) {
                prop.name = buffer;
            }
            ImGui::PopID();
            ImGui::NewLine();
            
            ImGui::NextColumn();
            
            ImGui::Spacing();
            ImGui::AlignTextToFramePadding();
            ImGui::SetNextItemWidth(-1);
            
            ImGui::PushID(id++);
            switch (prop.type)
            {
                case Type_Int: {
                    ImGui::PushID("InputInt_Int");
                    ImGui::InputInt("", &prop.iVal);
                    ImGui::PopID();
                    
                    //                    prop.iVal = clamp(prop.iVal, prop.iMin, prop.iMax);
                    
                    ImGui::SetNextItemWidth(ImGui::GetFontSize() * 6.0f);
                    ImGui::SliderInt("", &prop.iVal, prop.iMin, prop.iMax);
                    
                    ImGui::PushID(id++);
                    ImGui::SameLine();
                    ImGui::SetNextItemWidth(-1);
                    ImGui::DragIntRange2("", &prop.iMin, &prop.iMax, 1.0f, INT_MIN / 2, INT_MAX / 2, "min:%d", "max:%d");
                    ImGui::PopID();
                    
                    ImGui::NextColumn();
                    break;
                }
                case Type_Float: {
                    ImGui::PushID("InputFloat_Float");
                    ImGui::InputFloat("", &prop.fVal, 0.01f, 0.1f);
                    ImGui::PopID();
                    
                    //                    prop.fVal = clamp(prop.fVal, prop.fMin, prop.fMax);
                    
                    ImGui::SetNextItemWidth(ImGui::GetFontSize() * 6.0f);
                    ImGui::SliderFloat("", &prop.fVal, prop.fMin, prop.fMax);
                    
                    ImGui::PushID(id++);
                    ImGui::SameLine();
                    ImGui::SetNextItemWidth(-1);
                    ImGui::DragFloatRange2("", &prop.fMin, &prop.fMax, 0.0001f, Float_Min, Float_Max, "min:%.04f", "max:%.04f");
                    ImGui::PopID();
                    
                    ImGui::NextColumn();
                    break;
                }
                case Type_Color: {
                    float rgba[4] = { prop.cfVal.r, prop.cfVal.g, prop.cfVal.b, prop.cfVal.a };
                    ImGui::ColorEdit4("", rgba, ImGuiColorEditFlags_Float | ImGuiColorEditFlags_AlphaBar | ImGuiColorEditFlags_PickerHueWheel);
                    prop.cfVal.r = rgba[0]; prop.cfVal.g = rgba[1]; prop.cfVal.b = rgba[2]; prop.cfVal.a = rgba[3];
                    ImGui::NextColumn();
                    break;
                }
                case Type_String: {
                    char buffer[1024] = { 0 };
                    strcpy(buffer, prop.sVal.c_str());
                    // strcpy_s(buffer, prop.sVal.c_str());
                    if (ImGui::InputText("", buffer, sizeof(buffer))) {
                        prop.sVal = buffer;
                    }
                    ImGui::NextColumn();
                    break;
                }
                case Type_Bool: {
                    ImGui::Checkbox(prop.name.c_str(), (bool*)&prop.iVal);
                    ImGui::NextColumn();
                    break;
                }
                case Type_Array: {
                    bool node_open = ImGui::TreeNode("Array", "Array");
                    if (node_open) {
                        treeNodeOpened = true;
                        
                        ImGui::NextColumn();
//                        ImGui::NextColumn();
                        
                        struct FuncHolder { static bool ItemGetter(void* data, int idx, const char** out_str) { *out_str = ((const char**)data)[idx]; return true; } };
                        static int item_current = 0;
                        if (ImGui::Combo("Type", &item_current, &FuncHolder::ItemGetter, TypeNames, ARRAY_LENGTH(TypeNames), ARRAY_LENGTH(TypeNames))) {
                            //printf("select %d \n", item_current);
                        }
                        
                        ImGui::NextColumn();
//                        ImGui::SameLine();
                        if (ImGui::Button(" + ")) {
                            int type = item_current;
                            StProperty subProp(type);
                            subProp.name = "Prop_";
                            subProp.name.append(TypeNames[item_current]);
                            prop.children.push_back(subProp);
                        }
                        
                        ImGui::NextColumn();
                        ImGui::Separator();
                        
                        // next row
                        RenderPropertyArrayInTwoColumn(prop.children);
                        
                        ImGui::TreePop();
                    } else {
                        ImGui::NextColumn();
                    }
                    
                    break;
                }
                default: break;
            }
            
            ImGui::PopID();
            ImGui::Spacing();
            ImGui::Separator();
            
            if (isClick) {
                it = propertyArray.erase(it);
            } else {
                it++;
            }
        }
    }
    
    static void RenderPropertyArray(PropertyArray& propertyArray)
    {
        int num = (int)propertyArray.size();
        if (num == 0) return;
        
//        ImGui::PushStyleVar(ImGuiStyleVar_ChildRounding, 5.0f);
//        ImGui::BeginChild("#PropertyChildWindow", ImVec2(0, 0), true);
//
//        ImGui::Text("Property [");
//        ImGui::SameLine();
//        ImGui::TextColored(ImVec4(0, 1.0f, 0, 0.8f), "%d", num);
//        ImGui::SameLine();
//        ImGui::Text("]:");
        
        ImGui::PushStyleVar(ImGuiStyleVar_FramePadding, ImVec2(2, 2));
        //        ImGui::PushStyleVar(ImGuiStyleVar_ItemSpacing, ImVec2(2, 10));
        ImGui::Columns(2);
        ImGui::Separator();
//        ImGui::SetColumnWidth(0, ImGui::GetFontSize() * 12.0f);
        
        // create property ui
        RenderPropertyArrayInTwoColumn(propertyArray);
        
        ImGui::PopStyleVar();
        
//        ImGui::EndChild();
//        ImGui::PopStyleVar();
    }
    
    UIProperty() {
        
    }
    
    ~UIProperty() {
        
    }
    
    void render() {
        UIBase::render();
        
    }
};

NS_FIRE_END__

#endif
