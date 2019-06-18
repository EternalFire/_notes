#ifndef FireDrawScene_h_
#define FireDrawScene_h_

#include <FireDefinition.h>
#include <FireStShaderPanel.h>

NS_FIRE_BEGIN

class FireDrawScene 
{
public:
	static void DrawStart(StShaderPanel& st)
	{
		auto shader = st.shader;
		if (shader == NULL) return;

		if (st.name == "Shader Panel")
		{
			shader->use();
			shader->setMat4("mvp", G.mvp);

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
		auto shader = st.shader;
		if (shader == NULL) return;


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
	}

	static void DrawDefault(StShaderPanel& st) 
	{
		auto shader = st.shader;
		if (shader == NULL) return;

		glm::vec3 position = glm::vec3(5.0f, 0, 0);
		glm::mat4 m1 = IMatrix4;
		m1 = glm::translate(m1, position);

		shader->use();
		shader->setMat4("mvp", G.mvp * m1);
		shader->setMat4("uMat4Model", m1);
		shader->setFloat("uRatioMixTex2Color", 0.0);
		shader->setFloat("uRatioMixAColor2UColor", 0.0);

		painter.renderCube();
	}
};

NS_FIRE_END__

#endif