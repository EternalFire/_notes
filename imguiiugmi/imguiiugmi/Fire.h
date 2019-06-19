#ifndef Fire_h
#define Fire_h

#define GLM_FORCE_SWIZZLE
#include <glm/glm.hpp>

#include <shader.h>
#include <camera.h>

#include <string>
#include <math.h>
#include <iostream>
#include <map>

using namespace std;

#include <FireDefinition.h>
#include <FireConfig.h>
#include <FireUtility.h>
#include <FireProperty.h>
#include <FireStShaderPanel.h>
#include <FireStPropertyObject.h>
#include <FireJson.h>
#include <FireUI.h>
#include <FireState.h>
#include <FirePainter.h>
#include <FireDrawScene.h>

///
NS_FIRE_BEGIN

void InitConfig()
{
    LoadOrSaveDefault<StConfig>("config.json", config);
    LoadOrSaveDefault<StProperty>("shaderNames.json", G.shaderNamesObject.root);
}

void SaveConfig()
{
    SaveObject<StConfig>("config.json", config);
}

void SaveShaderNames()
{
	SaveObject<StProperty>("shaderNames.json", G.shaderNamesObject.root);
}

void SaveStShaderPanel(const string& shaderName)
{
	auto& stShaderPanel = G.stShaderPanelMap[shaderName];
	const string& str = toJSON(stShaderPanel);
	string path = stShaderPanel.name + ".json";
	writeToFile(path.c_str(), str.c_str());
}

void LoadStShaderPanel(const string& shaderName)
{
	LoadObject<StShaderPanel>(shaderName + ".json", G.stShaderPanelMap[shaderName]);
}

void Init()
{
	float w = config.width, h = config.height;

	G.init(w, h);
    
    G.cameraPositionNew.x = config.cameraPosition[0];
    G.cameraPositionNew.y = config.cameraPosition[1];
    G.cameraPositionNew.z = config.cameraPosition[2];
    G.cameraYawNew = config.cameraYaw;
    G.cameraPitchNew = config.cameraPitch;
    G.cameraZoomNew = config.cameraZoom;
    G.camera.MovementSpeed = config.cameraSpeed;
    G.camera.MouseSensitivity = config.cameraSensitivity;
    G.resetCamera();
    

	// create StShaderPanel
	auto& shaderNamesArray = G.shaderNamesObject.root.children;

	for (auto it = shaderNamesArray.begin(); it != shaderNamesArray.end(); it++)
	{
		const auto& shaderName = it->sVal;
		LoadStShaderPanel(shaderName);

		struct StShaderPanel& st = G.stShaderPanelMap[shaderName];
		st.shader = createShader(st.vertexShaderPath.c_str(), st.fragmentShaderPath.c_str());
	}
	
	struct StShaderPanel* pSt = NULL;

	if (G.stShaderPanelMap.size() == 0)
	{	
		struct StShaderPanel st;
		// default value
		st.name = "Shader Panel";
		st.vertexShaderPath = "vertex.vs";
		st.fragmentShaderPath = "colorFragment.fs";

		string path = st.name + ".json";
		bool exist = isFileExist(path.c_str());
		if (exist)
		{
			string data = readFromFile(path.c_str());
			parseJSON(data, st);
		}

		// todo: find uniform

		st.shader = createShader(st.vertexShaderPath.c_str(), st.fragmentShaderPath.c_str());
		G.stShaderPanelMap[st.name] = st;
	}

	pSt = &G.stShaderPanelMap["Shader Panel"];

	// texture
	G.texture0 = loadTexture("container.jpg");
	pSt->shader->use();
	pSt->shader->setInt("texture0", 0);

	glActiveTexture(GL_TEXTURE0);
	glBindTexture(GL_TEXTURE_2D, G.texture0);

	ui.init();
}

void BeginTick(float currentTime)
{
    //printf("BeginTick\n");
	G.lastFrame = G.currentFrame;
	G.currentFrame = currentTime;
	G.deltaTime = G.currentFrame - G.lastFrame;
}

void EndTick()
{
    //printf("EndTick\n");
}

/// render ui
void TickUI()
{
	ui.render();
}

/// apply shader program
void TickScene()
{
	G.updateMVP();

	glEnable(GL_DEPTH_TEST);
	glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

    // shader execute order ?
    
	auto& shaderPanelMap = G.stShaderPanelMap;
	for (auto iterator = shaderPanelMap.begin(); iterator != shaderPanelMap.end(); iterator++)
	{
		//if (iterator->first.compare("Shader Panel")) continue;

		auto& stShaderPanel = iterator->second;
		if (stShaderPanel.isUse) 
		{
			Shader* shader = stShaderPanel.shader;
			if (shader != NULL)
			{
				FireDrawScene::DrawStart(stShaderPanel);

				// use property value
				for (auto ite = stShaderPanel.propertyArray.begin(); ite != stShaderPanel.propertyArray.end(); ite++)
				{
					auto& stProperty = *ite;
                    const int& type = stProperty.type;
                    switch (type)
                    {
                        case Type_Int:
                        {
                            shader->setInt(stProperty.name.c_str(), stProperty.iVal);
                            break;
                        }
                        case Type_Float:
                        {
                            shader->setFloat(stProperty.name.c_str(), stProperty.fVal);
                            break;
                        }
                        case Type_Vec2:
                        {
							shader->setVec2(stProperty.name.c_str(), glm::vec2(stProperty.v2Val.x, stProperty.v2Val.y));
                            break;
                        }
                        case Type_IVec2:
                        {
							shader->setVec2(stProperty.name.c_str(), glm::vec2(stProperty.iv2Val.x, stProperty.iv2Val.y));
                            break;
                        }
                        case Type_Vec3:
                        {
							shader->setVec3(stProperty.name.c_str(), glm::vec3(stProperty.v3Val.x, stProperty.v3Val.y, stProperty.v3Val.z));
                            break;
                        }
                        case Type_IVec3:
                        {
							shader->setVec3(stProperty.name.c_str(), glm::vec3(stProperty.iv3Val.x, stProperty.iv3Val.y, stProperty.iv3Val.z));
                            break;
                        }
                        case Type_Vec4:
                        {
							shader->setVec4(stProperty.name.c_str(), glm::vec4(stProperty.v4Val.x, stProperty.v4Val.y, stProperty.v4Val.z, stProperty.v4Val.w));
                            break;
                        }
                        case Type_IVec4:
                        {
							shader->setVec4(stProperty.name.c_str(), glm::vec4(stProperty.iv4Val.x, stProperty.iv4Val.y, stProperty.iv4Val.z, stProperty.iv4Val.w));
                            break;
                        }
                        case Type_Color:
                        {
                            shader->setVec4(stProperty.name.c_str(), convertColorToVec4(&stProperty.cfVal));
                            break;
                        }
                        case Type_IColor:
                        {
                            shader->setVec4(stProperty.name.c_str(), convertIColorToVec4(&stProperty.cVal));
                            break;
                        }
                        case Type_Bool:
                        {
                            shader->setBool(stProperty.name.c_str(), (bool)stProperty.iVal);
                            break;
                        }
                        default: break;
                    }
				}

				FireDrawScene::Draw(stShaderPanel);

			} // end if
		}

		FireDrawScene::DrawFinally(stShaderPanel);
	}
}

void Clear()
{
    //printf("Clear\n");
	clearShaderArray();

    painter.clear();
}

// glfw: whenever the mouse moves, this callback is called
// -------------------------------------------------------
void mouse_callback(GLFWwindow* window, double xpos, double ypos)
{
	if (G.lockCamera) return;

	if (G.firstMouse)
	{
		G.lastX = (float)xpos;
		G.lastY = (float)ypos;
		G.firstMouse = false;
	}

	float xoffset = (float)(xpos - G.lastX);
	float yoffset = (float)(G.lastY - ypos); // reversed since y-coordinates go from bottom to top

	G.lastX = (float)xpos;
	G.lastY = (float)ypos;

	G.camera.ProcessMouseMovement(xoffset, yoffset);
}

// glfw: whenever the mouse scroll wheel scrolls, this callback is called
// ----------------------------------------------------------------------
void scroll_callback(GLFWwindow* window, double xoffset, double yoffset)
{
	if (G.lockCamera) return;
	G.camera.ProcessMouseScroll((float)yoffset);
}

// process all input: query GLFW whether relevant keys are pressed/released this frame and react accordingly
// ---------------------------------------------------------------------------------------------------------
void processInput(GLFWwindow* window, float deltaTime)
{
	if (glfwGetKey(window, GLFW_KEY_ESCAPE) == GLFW_PRESS)
		glfwSetWindowShouldClose(window, true);

	if (glfwGetKey(window, GLFW_KEY_SPACE) == GLFW_PRESS) {
		if (!G.isLockingCamera) {
			G.isLockingCamera = 1;

			G.lockCamera = !G.lockCamera;
			//printf("%.2f%s\n", glfwGetTime(), G.lockCamera ? "lock" : "unlock");
		}
	}

	if (glfwGetKey(window, GLFW_KEY_SPACE) == GLFW_RELEASE) {
		if (G.isLockingCamera) {
			G.isLockingCamera = 0;
			G.resetFirstMouse();
		}
	}

	if (G.lockCamera) return;

	if (glfwGetKey(window, GLFW_KEY_W) == GLFW_PRESS)
		G.camera.ProcessKeyboard(FORWARD, deltaTime);
	if (glfwGetKey(window, GLFW_KEY_S) == GLFW_PRESS)
		G.camera.ProcessKeyboard(BACKWARD, deltaTime);
	if (glfwGetKey(window, GLFW_KEY_A) == GLFW_PRESS)
		G.camera.ProcessKeyboard(LEFT, deltaTime);
	if (glfwGetKey(window, GLFW_KEY_D) == GLFW_PRESS)
		G.camera.ProcessKeyboard(RIGHT, deltaTime);
}

NS_FIRE_END__
///

/***
 *

	data structure
	{
		object type ---- object model
		material    ---- color model
	}

	property data {
		property type ---- render widget
			bool            checkbox
			type            combo
			vecN            inputN
	}

	effect(shader), model with effect

	draw model with different shader

	render scene by data


	transformData:
	position, rotation, scale

	materialData:
	diffuse texture


 */


#endif
