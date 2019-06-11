#ifndef Fire_h
#define Fire_h

#define STB_IMAGE_IMPLEMENTATION
#include <stb_image.h>

#define GLM_FORCE_SWIZZLE
#include <glm/glm.hpp>

#include <shader.h>
#include <camera.h>

#include <string.h>
#include <math.h>
#include <iostream>
#include <map>

using namespace std;



#define NS_FIRE Fire
#define NS_FIRE_BEGIN namespace NS_FIRE {
#define NS_FIRE_END__ }

#define _S(val) #val
#define NS_FIRE_NAME_1(n) _S(n)
#define NS_FIRE_NAME NS_FIRE_NAME_1(NS_FIRE)

#define ARRAY_LENGTH(_ARR)          ((int)(sizeof(_ARR)/sizeof(*_ARR)))

// convert rgba color component to [0,1] by divided by 255
#define CNTo1(component) (component/255.0f)

#define FIRE_API

///
NS_FIRE_BEGIN

static const float Float_Min = -10000000000.0f;
static const float Float_Max = +10000000000.0f;
static const char* Name = NS_FIRE_NAME;

typedef struct Vec2  { float x; float y; } Vec2;
typedef struct IVec2 { int x; int y; } IVec2;

typedef struct Vec3  { float x; float y; float z; } Vec3;
typedef struct IVec3 { int x; int y; int z; } IVec3;

typedef struct Vec4  { float x; float y; float z; float w; } Vec4;
typedef struct IVec4 { int x; int y; int z; int w; } IVec4;

typedef struct Color  { float r; float g; float b; float a; } Color;
typedef struct IColor { int r; int g; int b; int a; } IColor;

enum Type {
	Type_Int    = 0,
	Type_Float  = 1,
	Type_Vec2   = 2,
	Type_IVec2  = 3,
	Type_Vec3   = 4,
	Type_IVec3  = 5,
	Type_Vec4   = 6,
	Type_IVec4  = 7,
	Type_Color  = 8,
	Type_IColor = 9,
	Type_String = 10,
};

const char * TypeNames[] = {
	"Int",
	"Float",
	"Vec2",
	"IVec2",
	"Vec3",
	"IVec3",
	"Vec4",
	"IVec4",
	"Color",
	"IColor",
	"String",
};

int clamp(int value, int minVal, int maxVal) {
	return value <= minVal ? minVal : (value >= maxVal ? maxVal : value);
}

float clamp(float value, float minVal, float maxVal) {
	return fmax(minVal, (fmin(value, maxVal)));
}


struct StProperty {
	int type;
	string name;

	union {
		int iVal;
		float fVal;
	};

	union {
		int iMin;
		float fMin;
	};

	union {
		int iMax;
		float fMax;
	};

	union {
		Vec2 v2Val;
		Vec3 v3Val;

		Color cfVal;
		IColor cVal;
	};

	string sVal;

	StProperty() {
		clear();
	}
	StProperty(int t) {
		clear();
		type = t;
		init();
	}
	StProperty(const StProperty& prop) {
		*this = prop;
	}
	StProperty(StProperty&& prop) {
		*this = prop;
	}
	~StProperty() {}

	void clear() {
		type = 0;
		name = "";
		iVal = iMin = iMax = 0;
		fVal = fMin = fMax = 0;
		memset(&v2Val, 0, sizeof(v2Val));
		memset(&v3Val, 0, sizeof(v3Val));
		memset(&cfVal, 0, sizeof(cfVal));
		memset(&cVal, 0, sizeof(cVal));
		sVal = "";
	}
	void init() {
		sVal = "";
		name = "";
		if (type == Type_Int) { iVal = 0; iMin = INT_MIN / 2; iMax = INT_MAX / 2; }
		if (type == Type_Float) { fVal = 0; fMin = Float_Min; fMax = Float_Max; }
		if (type == Type_Vec2) { v2Val = { 0, 0 }; }
		if (type == Type_Vec3) { v3Val = { 0, 0, 0 }; }
		if (type == Type_Color) { cfVal = { 0, 0, 0, 1.0 }; }
		if (type == Type_IColor) { cVal = { 0, 0, 0, 255 }; }
	}

	StProperty& operator=(const StProperty& prop) {
		type = prop.type;
		name = prop.name;
		if (type == Type_Int)    { iVal = prop.iVal; iMin = prop.iMin; iMax = prop.iMax; }
		if (type == Type_Float)  { fVal = prop.fVal; fMin = prop.fMin; fMax = prop.fMax; }
		if (type == Type_Vec2)   { v2Val = prop.v2Val; }
		if (type == Type_Vec3)   { v3Val = prop.v3Val; }
		if (type == Type_Color)  { cfVal = prop.cfVal; }
		if (type == Type_IColor) { cVal = prop.cVal;   }
		if (type == Type_String) { sVal = prop.sVal;   }
		return *this;
	}
	StProperty& operator=(StProperty&& prop) {
		*this = prop;
		return *this;
	}

};

struct StShaderPanel {
	string name;
	vector<struct StProperty> propertyArray;
	Shader* shader;
	bool isShow;
	char nameBuffer[128];
	string vertexShaderPath;
	string fragmentShaderPath;

	StShaderPanel():name(""), shader(NULL), isShow(true) {
		memset(nameBuffer, 0, sizeof(nameBuffer));
	}
	~StShaderPanel() { name.clear(); shader = NULL; }
};

/*
 * serialize:
{
    "PanelName": "",
    "Description": "shader panel",
    "Properties": [
        { "Type": "Int", "Value": "", "Min": "", "Max": "", "Step": "" },
        { "Type": "Float", "Value": "", "Min": "", "Max": "", "Step": "" },
        { "Type": "Color",  "r": "", "g": "", "b": "", "a": "" },
        { "Type": "ColorF", "r": "", "g": "", "b": "", "a": "" },
        { "Type": "Vec4",  "x": "", "y": "", "z": "", "w": "" }
    ],
    "IsShow": "",
    "VertexShader": "",
    "FragmentShader": ""
}
*/

struct State {
    double currentFrame;
	vector<Shader*> shaderArray;
	map<string, struct StShaderPanel> stShaderPanelMap;
	//Camera camera;

	State() {
		currentFrame = 0;
	}
};

static struct State G;

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

		ImGui::LabelText("", "Create:");

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

//
//                    ImGui::SliderFloat("", &prop.fVal, prop.fMin, prop.fMax);
//                    ImGui::SameLine();
//                    ImGui::DragFloat("", &prop.fVal, 0.0001f, prop.fMin, prop.fMax, "%.06f");
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
//                    strcpy_s(buffer, prop.sVal.c_str());
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

static UI ui;

Shader* createShader(const char* vertexPath, const char* fragmentPath, const char* geometryPath = nullptr)
{
    string path = "resources/shaders/";
    string vPath = path + vertexPath;
    string fPath = path + fragmentPath;
    
    const char* _geometryPath = nullptr;
    if (geometryPath) {
        string gPath = path + geometryPath;
        _geometryPath = gPath.c_str();
    }
    
	Shader* shader = new Shader(vPath.c_str(), fPath.c_str(), _geometryPath);
	if (shader != NULL) {
		cout << "create shader ID = " << shader->ID << endl;
		G.shaderArray.push_back(shader);
	}
	return shader;
}
void clearShaderArray()
{
	auto& vector = G.shaderArray;
	for(auto it = vector.begin(); it != vector.end(); it++)
	{
		auto shader = *it;
		if (shader) {
			cout << "delete shader ID = " << shader->ID << endl;
			delete shader;
		}
	}

	vector.clear();
}

unsigned int coordVAO = 0;
unsigned int coordVBO = 0;
void renderCoordinateSystem()
{
	if (coordVAO == 0)
	{
		float x, y, z;
		x = y = z = 100000000.0f;
		x = y = z = 1.0f;

		float vertices[] = {
			// position          color
			0.0, 0.0, 0.0,    1.0, 0.0, 0.0,
			x,   0.0, 0.0,    1.0, 0.0, 0.0,

			0.0, 0.0, 0.0,    0.0, 1.0, 0.0,
			0.0, y,   0.0,    0.0, 1.0, 0.0,

			0.0, 0.0, 0.0,    0.0, 0.0, 1.0,
			0.0, 0.0, z,      0.0, 0.0, 1.0,
		};
		int size = 6;
		int positionSize = 3;
		int colorSize = 3;

		glGenVertexArrays(1, &coordVAO);
		glGenBuffers(1, &coordVBO);

		glBindBuffer(GL_ARRAY_BUFFER, coordVBO);
		glBufferData(GL_ARRAY_BUFFER, sizeof(vertices), vertices, GL_STATIC_DRAW);

		glBindVertexArray(coordVAO);
		glEnableVertexAttribArray(0);// aPos
		glVertexAttribPointer(0, positionSize, GL_FLOAT, GL_FALSE, size * sizeof(float), (void*)0);

		glEnableVertexAttribArray(1);// aColor
		glVertexAttribPointer(1, colorSize, GL_FLOAT, GL_FALSE, size * sizeof(float), (void*)(3 * sizeof(float)));

		glBindBuffer(GL_ARRAY_BUFFER, 0);
		glBindVertexArray(0);
	}

	glBindVertexArray(coordVAO);
	glDrawArrays(GL_LINES, 0, 6);
	glBindVertexArray(0);
}


void Init()
{
	struct StShaderPanel st;

	st.name = "Shader Panel";
	st.vertexShaderPath = "vertex.vs";
	st.fragmentShaderPath = "fragment.fs";
	st.shader = createShader(st.vertexShaderPath.c_str(), st.fragmentShaderPath.c_str());

	G.stShaderPanelMap[st.name] = st;

}

void BeginTick()
{
    //printf("BeginTick\n");
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
			pShader->setMat4("mvp", glm::mat4(1.0f));
			pShader->setFloat("uRatioMixTex2Color", 1.0);
			pShader->setFloat("uRatioMixAColor2UColor", 0.0); // use vertex color
			pShader->setInt("uUsePointLight", 0);
			pShader->setInt("uSwitchEffectInvert", 0);
			pShader->setInt("uSwitchEffectGray", 0);

			for (auto ite = stShaderPanel.propertyArray.begin(); ite != stShaderPanel.propertyArray.end(); ite++)
			{
				auto& stProperty = *ite;
				if (stProperty.type == Type_Color) {
					//shader->setInt(stProperty.name.c_str(), stProperty.iVal);
					glClearColor(stProperty.cfVal.r, stProperty.cfVal.g, stProperty.cfVal.b, stProperty.cfVal.a);
				}

				// todo
				// ...
			}

			renderCoordinateSystem();
		}
		// shader->
	}
}

void Clear()
{
    //printf("Clear\n");
	clearShaderArray();
}
NS_FIRE_END__
///

#endif
