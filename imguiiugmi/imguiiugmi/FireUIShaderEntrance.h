#ifndef FireUIShaderEntrance_h_
#define FireUIShaderEntrance_h_

#include <FireDefinition.h>
#include <FireUIBase.h>
#include <FireState.h>
#include "imgui.h"
#include <Fire.h>

NS_FIRE_BEGIN


class UIShaderEntrance : public UIBase {

public:
	UIShaderEntrance() {
		
	};
	~UIShaderEntrance() {};

	void init()
	{
		UIBase::init();
	}

	void render()
	{
		UIBase::render();

		ImGui::Begin("Shader Entrance");
		{
			static char nameBuffer[256] = { 0 };

			if (ImGui::Button(" + ")) {
				// create shader name data
				string name = nameBuffer;
				auto& prop = G.shaderNamesObject.get(name, Type_String);
				prop.sVal = name;

				// create shader panel data
				auto& stShaderPanel = G.stShaderPanelMap[name];
				if (stShaderPanel.name.length() == 0) {
					stShaderPanel.name = name;
					G.stShaderPanelMap[name] = stShaderPanel;

					NS_FIRE::SaveShaderNames();
					NS_FIRE::SaveStShaderPanel(name);
					printf("save new shader [%s]\n", name.c_str());
				}
				else {
					printf("shader [%s] exist\n", name.c_str());
					NS_FIRE::SaveShaderNames();
				}
			}

			ImGui::SameLine();
			ImGui::InputText("Name", nameBuffer, sizeof(nameBuffer));
			ImGui::Separator();

			auto& shaderNamesArray = G.shaderNamesObject.root.children;
			int i = 0;
			for (auto it = shaderNamesArray.begin(); it != shaderNamesArray.end(); )
			{
				auto& prop = *it;
				const string& shaderName = prop.sVal;
				auto& stShaderPanel = G.stShaderPanelMap[shaderName];

				ImGui::PushID(i++);
				if (ImGui::Checkbox("use", &stShaderPanel.isUse)) {
					printf("use %d %s\n", i, shaderName.c_str());

					// check shader
					if (stShaderPanel.shader == NULL)
					{
						if (stShaderPanel.vertexShaderPath.length() > 0 && stShaderPanel.fragmentShaderPath.length() > 0)
						{
							clearShader(stShaderPanel.shader);
							stShaderPanel.shader = createShader(stShaderPanel.vertexShaderPath.c_str(), stShaderPanel.fragmentShaderPath.c_str());
						}
					}
				}
				ImGui::PopID();

				ImGui::SameLine();

				ImGui::PushID(i++);
				if (ImGui::Button(shaderName.c_str())) {
					printf("show %d %s\n", i, shaderName.c_str());
					stShaderPanel.isShow = true;
				}
				ImGui::PopID();
                
                ImGui::SameLine();
                
                ImGui::PushID(i++);
                ImGui::PushStyleColor(ImGuiCol_Button, (ImVec4)ImColor::HSV(0.1f/7.0f, 0.6f, 0.6f));
                ImGui::PushStyleColor(ImGuiCol_ButtonHovered, (ImVec4)ImColor::HSV(0.1f/7.0f, 0.7f, 0.7f));
                ImGui::PushStyleColor(ImGuiCol_ButtonActive, (ImVec4)ImColor::HSV(0.1f/7.0f, 0.8f, 0.8f));
                bool isClick = ImGui::Button(" - "); // remove
                ImGui::PopStyleColor(3);
                ImGui::PopID();
                
                if (isClick) {
                    it = shaderNamesArray.erase(it);
                    NS_FIRE::SaveShaderNames();
                } else {
                    it++;
                }
			}
		}
		ImGui::End();
	}

public:
	char nameBuffer[256] = { 0 };
};

NS_FIRE_END__

#endif
