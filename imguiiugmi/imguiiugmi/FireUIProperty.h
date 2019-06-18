#ifndef FireUIProperty_h
#define FireUIProperty_h

#include <FireDefinition.h>
#include <FireUIBase.h>
#include <FireState.h>
#include <FireStPropertyObject.h>
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
			 *         type
			 *
             *  [ - ]  name  (next) |  widget  (next)
			 *         type
			 *
             *  [ - ]  name  (next) |  widget  (next)
			 *         type
			 *
             */
            
            // red button
            ImGui::PushID(id++);
            ImGui::PushStyleColor(ImGuiCol_Button, (ImVec4)ImColor::HSV(0.1f/7.0f, 0.6f, 0.6f));
            ImGui::PushStyleColor(ImGuiCol_ButtonHovered, (ImVec4)ImColor::HSV(0.1f/7.0f, 0.7f, 0.7f));
            ImGui::PushStyleColor(ImGuiCol_ButtonActive, (ImVec4)ImColor::HSV(0.1f/7.0f, 0.8f, 0.8f));
            bool isClick = ImGui::Button(" - "); // remove
            ImGui::PopStyleColor(3);
            ImGui::PopID();

			const auto& btnSize = ImGui::GetItemRectSize();
            
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

            //ImGui::NewLine();
			// type text
			ImGui::Dummy(btnSize); ImGui::SameLine();
			ImGui::LabelText("", "Type = %s", TypeNames[prop.type]);
            
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
				case Type_Vec2: {					
					//                                           2 column  2 column
					//float w = ImGui::GetWindowContentRegionWidth() * 0.5f * 0.5f - ImGui::GetStyle().ItemSpacing.x;
					float w = ImGui::GetColumnWidth() / 2.0f - ImGui::GetStyle().ItemSpacing.x;
					ImGui::SetNextItemWidth(w);
					ImGui::PushID("InputFloat_Float_v2_x");
					ImGui::InputFloat("", &prop.v2Val.x, 0.01f, 0.1f);
					ImGui::PopID();
					
					ImGui::SameLine();
					ImGui::SetNextItemWidth(w);
					ImGui::PushID("InputFloat_Float_v2_y");
					ImGui::InputFloat("", &prop.v2Val.y, 0.01f, 0.1f);
					ImGui::PopID();	

					ImGui::NextColumn();
					break;
				}
				case Type_IVec2: {
					//                                           2 column  2 column
					//float w = ImGui::GetWindowContentRegionWidth() * 0.5f * 0.5f - ImGui::GetStyle().ItemSpacing.x;
					float w = ImGui::GetColumnWidth() / 2.0f - ImGui::GetStyle().ItemSpacing.x;
					ImGui::SetNextItemWidth(w);
					ImGui::PushID("InputInt_Int_v2_x");
					ImGui::InputInt("", &prop.iv2Val.x);
					ImGui::PopID();

					ImGui::SameLine();
					ImGui::SetNextItemWidth(w);
					ImGui::PushID("InputInt_Int_v2_y");
					ImGui::InputInt("", &prop.iv2Val.y);
					ImGui::PopID();

					ImGui::NextColumn();
					break;
				}
				case Type_Vec3: {
					//                                           2 column  3 column
					//float w = ImGui::GetWindowContentRegionWidth() * 0.5f / 3.0f - ImGui::GetStyle().ItemSpacing.x;
					float w = ImGui::GetColumnWidth() / 3.0f - ImGui::GetStyle().ItemSpacing.x;
					ImGui::SetNextItemWidth(w);
					ImGui::PushID("InputFloat_Float_v3_x");
					ImGui::InputFloat("", &prop.v3Val.x, 0.01f, 0.1f);
					ImGui::PopID();

					ImGui::SameLine();
					ImGui::SetNextItemWidth(w);
					ImGui::PushID("InputFloat_Float_v3_y");
					ImGui::InputFloat("", &prop.v3Val.y, 0.01f, 0.1f);
					ImGui::PopID();

					ImGui::SameLine();
					ImGui::SetNextItemWidth(w);
					ImGui::PushID("InputFloat_Float_v3_z");
					ImGui::InputFloat("", &prop.v3Val.z, 0.01f, 0.1f);
					ImGui::PopID();

					ImGui::NextColumn();
					break;
				}
				case Type_IVec3: {
					//                                           2 column  3 column
					//float w = ImGui::GetWindowContentRegionWidth() * 0.5f / 3.0f - ImGui::GetStyle().ItemSpacing.x;
					float w = ImGui::GetColumnWidth() / 3.0f - ImGui::GetStyle().ItemSpacing.x;
					ImGui::SetNextItemWidth(w);
					ImGui::PushID("InputInt_Int_v3_x");
					ImGui::InputInt("", &prop.iv3Val.x);
					ImGui::PopID();

					ImGui::SameLine();
					ImGui::SetNextItemWidth(w);
					ImGui::PushID("InputInt_Int_v3_y");
					ImGui::InputInt("", &prop.iv3Val.y);
					ImGui::PopID();

					ImGui::SameLine();
					ImGui::SetNextItemWidth(w);
					ImGui::PushID("InputInt_Int_v3_z");
					ImGui::InputInt("", &prop.iv3Val.z);
					ImGui::PopID();

					ImGui::NextColumn();
					break;
				}
				case Type_Vec4: {
					//                                           2 column  4 column
					//float w = ImGui::GetWindowContentRegionWidth() * 0.5f / 4.0f - ImGui::GetStyle().ItemSpacing.x;
					float w = ImGui::GetColumnWidth() / 4.0f - ImGui::GetStyle().ItemSpacing.x;

					ImGui::SetNextItemWidth(w);
					ImGui::PushID("InputFloat_Float_v4_x");
					ImGui::InputFloat("", &prop.v4Val.x, 0.01f, 0.1f);
					ImGui::PopID();

					ImGui::SameLine();
					ImGui::SetNextItemWidth(w);
					ImGui::PushID("InputFloat_Float_v4_y");
					ImGui::InputFloat("", &prop.v4Val.y, 0.01f, 0.1f);
					ImGui::PopID();

					ImGui::SameLine();
					ImGui::SetNextItemWidth(w);
					ImGui::PushID("InputFloat_Float_v4_z");
					ImGui::InputFloat("", &prop.v4Val.z, 0.01f, 0.1f);
					ImGui::PopID();

					ImGui::SameLine();
					ImGui::SetNextItemWidth(w);
					ImGui::PushID("InputFloat_Float_v4_w");
					ImGui::InputFloat("", &prop.v4Val.w, 0.01f, 0.1f);
					ImGui::PopID();

					ImGui::NextColumn();
					break;
				}
				case Type_IVec4: {
					//                                           2 column  4 column
					//float w = ImGui::GetWindowContentRegionWidth() * 0.5f / 4.0f - ImGui::GetStyle().ItemSpacing.x;
					float w = ImGui::GetColumnWidth() / 4.0f - ImGui::GetStyle().ItemSpacing.x;
					
					ImGui::SetNextItemWidth(w);
					ImGui::PushID("InputInt_Int_v4_x");
					ImGui::InputInt("", &prop.iv4Val.x);
					ImGui::PopID();

					ImGui::SameLine();
					ImGui::SetNextItemWidth(w);
					ImGui::PushID("InputInt_Int_v4_y");
					ImGui::InputInt("", &prop.iv4Val.y);
					ImGui::PopID();

					ImGui::SameLine();
					ImGui::SetNextItemWidth(w);
					ImGui::PushID("InputInt_Int_v4_z");
					ImGui::InputInt("", &prop.iv4Val.z);
					ImGui::PopID();

					ImGui::SameLine();
					ImGui::SetNextItemWidth(w);
					ImGui::PushID("InputInt_Int_v4_w");
					ImGui::InputInt("", &prop.iv4Val.w);
					ImGui::PopID();

					ImGui::NextColumn();
					break;
				}
				case Type_Color: {
					float rgba[4] = { 0 };
					convertColorToArray(prop.cfVal, rgba);
					ImGui::ColorEdit4("", rgba, ImGuiColorEditFlags_Float | ImGuiColorEditFlags_AlphaBar | ImGuiColorEditFlags_PickerHueWheel);
					convertArrayToColor(rgba, &prop.cfVal);

                    ImGui::NextColumn();
                    break;
                }
				case Type_IColor: {
					float rgba[4] = { 0 };
					convertColorToArray(prop.cVal, rgba);
					ImGui::ColorEdit4("", rgba, ImGuiColorEditFlags_Uint8 | ImGuiColorEditFlags_AlphaBar | ImGuiColorEditFlags_PickerHueWheel);
					convertArrayToColor(rgba, &prop.cVal);
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

	static void RenderPropertyPanel(PropertyObject& propertyObject)
	{
		PropertyArray& propertyArray = propertyObject.root.children;
		// bool& open = stShaderPanel.isShow;

		ImGui::SetNextWindowSize(ImVec2(430, 450), ImGuiCond_FirstUseEver);
		if (!ImGui::Begin("PropertyPanel"/* , &open */))
		{
			ImGui::End();
			return;
		}

		//        ImGui::LabelText("", "Input: %.2f", ImGui::GetWindowContentRegionWidth());
		ImGui::LabelText("", "Input:");

		ImGui::SetNextItemWidth(180);

		char nameBuffer[128] = { 0 };
		string& tempName = propertyObject.get("tempName", Type_String).sVal;
		strcpy(nameBuffer, tempName.c_str());
		// input property name
		if (ImGui::InputText("Name", nameBuffer, sizeof(nameBuffer))) {
			//printf("%s\n", stShaderPanel.nameBuffer);
		}
		tempName = nameBuffer;

		ImGui::SetNextItemWidth(180);
		// select property type
		struct FuncHolder { static bool ItemGetter(void* data, int idx, const char** out_str) { *out_str = ((const char**)data)[idx]; return true; } };
		static int item_current = 0;
		if (ImGui::Combo("Type", &item_current, &FuncHolder::ItemGetter, TypeNames, ARRAY_LENGTH(TypeNames), ARRAY_LENGTH(TypeNames))) {
			//printf("select %d \n", item_current);
		}

		ImGui::Separator();
		//        ImVec2 size = ImGui::GetItemRectSize();
		ImGui::NewLine();

		//        ImGui::SameLine(size.x + ImGui::GetStyle().ItemSpacing.x);
		//        ImGui::SameLine(180)
		ImGui::SameLine(ImGui::GetWindowContentRegionWidth() / 2.5f);
		if (ImGui::Button("Create"))
		{
			// create property data
			int type = item_current;
			struct StProperty prop(type);
			if (strlen(nameBuffer) == 0) {
				prop.name = "Prop_";
				prop.name.append(TypeNames[item_current]);
			}
			else {
				prop.name = nameBuffer;
			}

			propertyArray.push_back(prop);
		}

		ImGui::SameLine();
		if (ImGui::Button("Save"))
		{
			const string& str = toJSON(propertyObject.root);
			string path = "PropertyPanel.json";
			writeToFile(path.c_str(), str.c_str());
		}

		// ==============================
		ImGui::PushStyleVar(ImGuiStyleVar_ChildRounding, 5.0f);
		ImGui::BeginChild("#PropertyChildWindow", ImVec2(0, 0), true);

		ImGui::Text("Property [");
		ImGui::SameLine();
		int num = (int)propertyArray.size();
		ImGui::TextColored(ImVec4(0, 1.0f, 0, 0.8f), "%d", num);
		ImGui::SameLine();
		ImGui::Text("]:");

		UIProperty::RenderPropertyArray(propertyArray);

		ImGui::EndChild();
		ImGui::PopStyleVar();

		ImGui::End();
	}

public:
    UIProperty() {
        
    }
    
    ~UIProperty() {
        
    }

	void init() {
		UIBase::init();

//        string path = "PropertyPanel.json";
//        bool exist = isFileExist(path.c_str());
//        if (exist)
//        {
//            string data = readFromFile(path.c_str());
//            parseJSON(data, propObject.root);
//        }
	}
    
    void render() {
        UIBase::render();
//        UIProperty::RenderPropertyPanel(propObject);
    }

public:
	PropertyObject propObject;

};

NS_FIRE_END__

#endif
