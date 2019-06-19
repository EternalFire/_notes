
#ifndef FireUIShaderPanel_h
#define FireUIShaderPanel_h

#include "imgui.h"

#include <FireDefinition.h>
#include <FireUIBase.h>
#include <FireState.h>
#include <FireUIProperty.h>

NS_FIRE_BEGIN

class UIShaderPanel: public UIBase {
public:
    UIShaderPanel() {}
    ~UIShaderPanel() {}
    
    void init() {
		for (auto it = G.stShaderPanelMap.begin(); it != G.stShaderPanelMap.end(); it++) {
			const auto& stShaderPanel = it->second;
			strcpy(vsPathMap[stShaderPanel.name], stShaderPanel.vertexShaderPath.c_str());
			strcpy(fsPathMap[stShaderPanel.name], stShaderPanel.fragmentShaderPath.c_str());
		}
    }
    
    void render() {
		UIBase::render();

        for (auto it = G.stShaderPanelMap.begin(); it != G.stShaderPanelMap.end(); it++) {
            renderShaderPanel(it->first.c_str());
        }
    }
    
    void renderShaderPanel(const char* key) {
        auto& stShaderPanel = G.stShaderPanelMap[key];		
		bool* p_open = &stShaderPanel.isShow;
		bool needRebuildShader = false;

		if (!(*p_open)) 
		{
			if (lastOpenFlag[key] != *p_open) {
				lastOpenFlag[key] = *p_open;

				SaveStShaderPanel(stShaderPanel.name);
				printf("close and save [%s]...\n", stShaderPanel.name.c_str());
			}
			return;
		}
        
		lastOpenFlag[key] = *p_open;

        ImGui::SetNextWindowSize(ImVec2(430, 450), ImGuiCond_FirstUseEver);
        if (!ImGui::Begin(stShaderPanel.name.c_str(), p_open, ImGuiWindowFlags_None))
        {
            ImGui::End();
            return;
        }
        
//        ImGui::LabelText("", "Input: %.2f", ImGui::GetWindowContentRegionWidth());
        ImGui::LabelText("", "Input:");
        
        ImGui::SetNextItemWidth(180);
        // input property name
        if (ImGui::InputText("Name", stShaderPanel.nameBuffer, sizeof(stShaderPanel.nameBuffer))) {
//            printf("%s\n", stShaderPanel.nameBuffer);
        }

		ImGui::SameLine(); ImGui::SetNextItemWidth(180);
		if (ImGui::InputText("VS", vsPathMap[stShaderPanel.name], sizeof(vsPathMap[stShaderPanel.name]))) {
			printf("vs = %s", vsPathMap[stShaderPanel.name]);
		}

		//stShaderPanel.vertexShaderPath
		//stShaderPanel.fragmentShaderPath
        
        ImGui::SetNextItemWidth(180);
        // select property type
        struct FuncHolder { static bool ItemGetter(void* data, int idx, const char** out_str) { *out_str = ((const char**)data)[idx]; return true; } };
        static int item_current = 0;
        if (ImGui::Combo("Type", &item_current, &FuncHolder::ItemGetter, TypeNames, ARRAY_LENGTH(TypeNames), ARRAY_LENGTH(TypeNames))) {
            //printf("select %d \n", item_current);
        }


		ImGui::SameLine(); ImGui::SetNextItemWidth(180);
		if (ImGui::InputText("FS", fsPathMap[stShaderPanel.name], sizeof(fsPathMap[stShaderPanel.name]))) {
			printf("fs = %s", fsPathMap[stShaderPanel.name]);			
		}
        
        ImGui::Separator();
//        ImVec2 size = ImGui::GetItemRectSize();
        ImGui::NewLine();
        
//        ImGui::SameLine(size.x + ImGui::GetStyle().ItemSpacing.x);
//        ImGui::SameLine(180)
        ImGui::SameLine( ImGui::GetWindowContentRegionWidth() / 2.5f );
        if (ImGui::Button("Create"))
        {
            // create property data
            int type = item_current;
            struct StProperty prop(type);
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

		ImGui::SameLine();
		if (ImGui::Button("Build Shader"))
		{
			needRebuildShader = stShaderPanel.vertexShaderPath.compare(vsPathMap[stShaderPanel.name]) != 0 ||
				stShaderPanel.fragmentShaderPath.compare(fsPathMap[stShaderPanel.name]) != 0;

			if (needRebuildShader)
			{
				stShaderPanel.vertexShaderPath = vsPathMap[stShaderPanel.name];
				stShaderPanel.fragmentShaderPath = fsPathMap[stShaderPanel.name];

				clearShader(stShaderPanel.shader);
				stShaderPanel.shader = createShader(stShaderPanel.vertexShaderPath.c_str(), stShaderPanel.fragmentShaderPath.c_str());
			}
		}
        
        // ==============================
        ImGui::PushStyleVar(ImGuiStyleVar_ChildRounding, 5.0f);
        ImGui::BeginChild("#PropertyChildWindow", ImVec2(0, 0), true);
        
        ImGui::Text("Property [");
        ImGui::SameLine();
        int num = (int)stShaderPanel.propertyArray.size();
        ImGui::TextColored(ImVec4(0, 1.0f, 0, 0.8f), "%d", num);
        ImGui::SameLine();
        ImGui::Text("]:");

            UIProperty::RenderPropertyArray(stShaderPanel.propertyArray);
        
        ImGui::EndChild();
        ImGui::PopStyleVar();
        
        ImGui::End();
    }

public:
	map<string, bool> lastOpenFlag;
	map<string, char[128]> vsPathMap;
	map<string, char[128]> fsPathMap;
};

NS_FIRE_END__

#endif
