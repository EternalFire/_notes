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
#include <FireJson.h>
#include <FireUI.h>
#include <FireState.h>
#include <FirePainter.h>

///
NS_FIRE_BEGIN

void InitConfig()
{
    string path = "config.json";
    bool exist = isFileExist(path.c_str());
    if (exist)
    {
        string data = readFromFile(path.c_str());
        parseJSON(data, config);
    }
    else
    {
        const string& str = toJSON(config);
        writeToFile(path.c_str(), str.c_str());
    }
}

void Init()
{
	float w = config.width, h = config.height;
	G.init(w, h);

	// create StShaderPanel
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

	st.shader = createShader(st.vertexShaderPath.c_str(), st.fragmentShaderPath.c_str());
	G.stShaderPanelMap[st.name] = st;

	// texture
	G.texture0 = loadTexture("container.jpg");
	st.shader->use();
	st.shader->setInt("texture0", 0);

	glActiveTexture(GL_TEXTURE0);
	glBindTexture(GL_TEXTURE_2D, G.texture0);
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

    //printf("TickScene\n");
	{
		auto& stShaderPanel = G.stShaderPanelMap["Shader Panel"];
		auto shader = stShaderPanel.shader;
		if (shader != NULL)
		{
			auto pShader = shader;
			pShader->use();
			pShader->setMat4("mvp", G.mvp);

			pShader->setFloat("uRatioMixTex2Color", 1.0);
			pShader->setFloat("uRatioMixAColor2UColor", 0.0); // use vertex color
			pShader->setInt("uUsePointLight", 0);
			pShader->setInt("uSwitchEffectInvert", 0);
			pShader->setInt("uSwitchEffectGray", 0);

			for (auto ite = stShaderPanel.propertyArray.begin(); ite != stShaderPanel.propertyArray.end(); ite++)
			{
				auto& stProperty = *ite;
				if (stProperty.type == Type_Color) {
					//glClearColor(stProperty.cfVal.r, stProperty.cfVal.g, stProperty.cfVal.b, stProperty.cfVal.a);
					shader->setVec3(stProperty.name.c_str(), convertColorToVec3(&stProperty.cfVal));
				}

				// todo
				// ...
			}

			painter.renderCoordinateSystem();

			glm::vec3 position = glm::vec3(5.0f, 0, 0);
			glm::mat4 m1 = IMatrix4;
			m1 = glm::translate(m1, position);

			pShader->setMat4("mvp", G.mvp * m1);
			pShader->setMat4("uMat4Model", m1);
			pShader->setFloat("uRatioMixTex2Color", 0.0);
			pShader->setFloat("uRatioMixAColor2UColor", 0.0);
			painter.renderCube();
		} // end if
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
