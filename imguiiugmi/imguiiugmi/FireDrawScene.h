#ifndef FireDrawScene_h_
#define FireDrawScene_h_

#include <FireDefinition.h>
#include <FireStShaderPanel.h>

NS_FIRE_BEGIN

class FireDrawScene 
{
#define CHECKSHADER(st) \
do {auto shader = st.shader; \
if (shader == NULL) return;}while(0); \

public:
	static void DrawStart(StShaderPanel& st)
	{
		CHECKSHADER(st);
		auto shader = st.shader;
		shader->use();

		if (st.name == "Shader Panel")
		{
			shader->setMat4("mvp", G.mvp);
            shader->setVec3("uViewPos", G.camera.Position);

			shader->setFloat("uRatioMixTex2Color", 1.0);
			shader->setFloat("uRatioMixAColor2UColor", 0.0); // use vertex color
			shader->setInt("uUsePointLight", 0);
			shader->setInt("uSwitchEffectInvert", 0);
			shader->setInt("uSwitchEffectGray", 0);

			painter.renderCoordinateSystem();
		}

	}

	static void DrawFinally(StShaderPanel& st)
	{
		CHECKSHADER(st);
		auto shader = st.shader;

		////DrawDefault(st);

		//if (st.name == "Shader Panel")
		//{
		//	DrawDefault(st);
		//}
	}

	static void Draw(StShaderPanel& st)
	{
		if (st.name == "Shader Panel")
		{
			DrawDefault(st);
		}
		else if (st.name == "Simple")
		{
			DrawBall(st);
		}
	}

	static void DrawDefault(StShaderPanel& st) 
	{
		CHECKSHADER(st);
		auto shader = st.shader;

		glm::vec3 position = glm::vec3(5.0f, 0, 0);
		glm::mat4 m1 = IMatrix4;
		m1 = glm::translate(m1, position);

		shader->use();
		shader->setMat4("mvp", G.mvp * m1);
		shader->setMat4("uMat4Model", m1);
		shader->setMat3("uNormalMatrix", normalMatrix(m1));
//        shader->setFloat("uRatioMixTex2Color", 0.0);
//        shader->setFloat("uRatioMixAColor2UColor", 0.0);

		painter.renderCube();
	}

	static void DrawBall(StShaderPanel& st)
	{
		CHECKSHADER(st);

		auto shader = st.shader;
		shader->use();
		

		glm::vec3 position(0);
		auto prop = G.stShaderPanelMap["Shader Panel"].getProperty("uLightPos");
		if (prop)
		{
			position = glm::vec3(prop->v3Val.x, prop->v3Val.y, prop->v3Val.z);
		}

		glm::mat4 m1 = IMatrix4;
		m1 = glm::translate(m1, position);
		m1 = glm::scale(m1, glm::vec3(0.1f));
		shader->setMat4("mvp", G.mvp * m1);

		painter.renderSphere();
	}
};

NS_FIRE_END__

#endif
