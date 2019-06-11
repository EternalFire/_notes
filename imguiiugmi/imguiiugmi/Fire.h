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
#include <fstream>
#include <map>

using namespace std;

#include "rapidjson/document.h"
#include "rapidjson/stringbuffer.h"
#include "rapidjson/writer.h"


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
static const char* ResPath = "resources/";
static const char* ResShaderPath = "resources/shaders/";

/**
* Camera setting
*
* Position = (7.640, 6.438, 11.394)
* WorldUp = (0.000, 1.000, 0.000)
* Pitch = -24.300  Yaw = -124.900
*
* Position = (0.667, 8.979, 19.392)
* WorldUp = (0.000, 1.000, 0.000)
* Pitch = -24.400  Yaw = -110.500
*/
const glm::vec3 cameraPosition = glm::vec3(0.667, 8.979, 19.392);
const glm::vec3 cameraUp = glm::vec3(0, 1.0, 0);
const float cameraYaw = -110.5f;  // around y axis
const float cameraPitch = -24.4f; // around x axis

const glm::mat4 IMatrix4(1.0f); // identty matrix
const glm::vec3 xAxis(1.0f, 0.0f, 0.0f);
const glm::vec3 yAxis(0.0f, 1.0f, 0.0f);
const glm::vec3 zAxis(0.0f, 0.0f, 1.0f);

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

int getTypeByName(const string& name) {
	for (int i = 0; i < sizeof(TypeNames); i++)
	{
		if (name.compare(TypeNames[i]) == 0) {
			return i;
		}
	}
	return 0;
}

int clamp(int value, int minVal, int maxVal) {
	return value <= minVal ? minVal : (value >= maxVal ? maxVal : value);
}

float clamp(float value, float minVal, float maxVal) {
	return fmax(minVal, (fmin(value, maxVal)));
}

glm::vec3 convertColorToVec3(Color* col)
{
	return col ? glm::vec3((*col).r, (*col).g, (*col).b) : glm::vec3(1.0);
}
glm::vec3 convertIColorToVec3(IColor* col)
{
	const float c = 255.0;
	return col ? glm::vec3((*col).r / c, (*col).g / c, (*col).b / c) : glm::vec3(1.0);
}
glm::vec4 convertColorToVec4(Color* col)
{
	if (col) return glm::vec4(convertColorToVec3(col), col->a);
	return glm::vec4(1.0);
}
glm::vec4 convertIColorToVec4(IColor* col)
{
	if (col) return glm::vec4(convertIColorToVec3(col), col->a);
	return glm::vec4(1.0);
}

glm::mat4 translate(const glm::vec3& v3, const glm::mat4& model = IMatrix4)
{
	return glm::translate(model, v3);
}
glm::mat4 rotateByX(float degree, const glm::mat4& model = IMatrix4)
{
	return glm::rotate(model, glm::radians(degree), xAxis);
}
glm::mat4 rotateByY(float degree, const glm::mat4& model = IMatrix4)
{
	return glm::rotate(model, glm::radians(degree), yAxis);
}
glm::mat4 rotateByZ(float degree, const glm::mat4& model = IMatrix4)
{
	return glm::rotate(model, glm::radians(degree), zAxis);
}
glm::mat4 scale(const glm::vec3& v3, const glm::mat4& model = IMatrix4)
{
	return glm::scale(model, v3);
}
glm::mat4 scale(float s, const glm::mat4& model = IMatrix4)
{
	return glm::scale(model, glm::vec3(s));
}
glm::mat3 normalMatrix(const glm::mat4& model)
{
	return glm::transpose(glm::inverse(glm::mat3(model)));
}

unsigned int loadTexture(char const * path)
{
	string texturePath = ResPath;
	texturePath += path;

	unsigned int textureID;
	glGenTextures(1, &textureID);

	stbi_set_flip_vertically_on_load(true);

	int width, height, nrComponents;
	unsigned char *data = stbi_load(texturePath.c_str(), &width, &height, &nrComponents, 0);
	if (data)
	{
		GLenum format = GL_RGB;
		if (nrComponents == 1)
			format = GL_RED;
		else if (nrComponents == 3)
			format = GL_RGB;
		else if (nrComponents == 4)
			format = GL_RGBA;

		glBindTexture(GL_TEXTURE_2D, textureID);
		glTexImage2D(GL_TEXTURE_2D, 0, format, width, height, 0, format, GL_UNSIGNED_BYTE, data);
		glGenerateMipmap(GL_TEXTURE_2D);

		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT);
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT);
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR_MIPMAP_LINEAR);
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
	}
	else
	{
		std::cout << "Texture failed to load at path: " << path << std::endl;
	}

	stbi_image_free(data);
	return textureID;
}

void writeToFile(char const * path, const char* data)
{
	stringstream ss;
	ofstream os;

	ss << data;

	os.open(path);
	os << ss.rdbuf();
	os.close();
}

string readFromFile(char const * path)
{
	string data;
	stringstream ss;
	ifstream is;
	is.open(path);
	ss << is.rdbuf();
	data = ss.str();
	is.close();
	return data;
}

bool isFileExist(char const * path)
{
	bool value = false;
	ifstream is;
	is.open(path);
	value = is.is_open();
	is.close();
	return value;
}

template<typename T>
string toString(T value)
{
	stringstream ss;
	ss << value;
	return ss.str();
}

template<typename T>
T parseString(const string& str)
{
	T value;
	stringstream ss;
	ss << str;
	ss >> value;
	return value;
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

string toJSON(const StShaderPanel& stShaderPanel)
{
	string data = "";
	rapidjson::StringBuffer strBuf;
	rapidjson::Writer<rapidjson::StringBuffer> writer(strBuf);

	writer.StartObject();
	writer.Key("PanelName");   writer.String(stShaderPanel.name.c_str());
	writer.Key("Description"); writer.String(stShaderPanel.name.c_str());
	writer.Key("IsShow");      writer.String(toString(stShaderPanel.isShow).c_str());
	writer.Key("VS");          writer.String(stShaderPanel.vertexShaderPath.c_str());
	writer.Key("FS");          writer.String(stShaderPanel.fragmentShaderPath.c_str());
	writer.Key("Properties");  writer.StartArray();
	{
		const auto& propertyArray = stShaderPanel.propertyArray;
		for (auto it = propertyArray.begin(); it != propertyArray.end(); it++)
		{
			writer.StartObject();
			{
				const auto& prop = *it;
				switch (prop.type)
				{
					case Type_Int:
					{
						writer.Key("Type"); writer.String(TypeNames[prop.type]);
						writer.Key("Name"); writer.String(prop.name.c_str());
						writer.Key("Value"); writer.String(toString(prop.iVal).c_str());
						writer.Key("Min"); writer.String(toString(prop.iMin).c_str());
						writer.Key("Max"); writer.String(toString(prop.iMax).c_str());
						break;
					}
					case Type_Float:
					{
						writer.Key("Type"); writer.String(TypeNames[prop.type]);
						writer.Key("Name"); writer.String(prop.name.c_str());
						writer.Key("Value"); writer.String(toString(prop.fVal).c_str());
						writer.Key("Min"); writer.String(toString(prop.fMin).c_str());
						writer.Key("Max"); writer.String(toString(prop.fMax).c_str());
						break;
					}
					case Type_Color:
					{
						writer.Key("Type"); writer.String(TypeNames[prop.type]);
						writer.Key("Name"); writer.String(prop.name.c_str());
						writer.Key("Value"); writer.StartObject();
						{
							writer.Key("r"); writer.String(toString(prop.cfVal.r).c_str());
							writer.Key("g"); writer.String(toString(prop.cfVal.g).c_str());
							writer.Key("b"); writer.String(toString(prop.cfVal.b).c_str());
							writer.Key("a"); writer.String(toString(prop.cfVal.a).c_str());
						}
						writer.EndObject();
						break;
					}
					default:
						break;
				}
			}
			writer.EndObject();
		}
	}
	writer.EndArray();

	writer.EndObject();
	data = strBuf.GetString();
	return data;
}

void parseJSON(const string& jsonStr, StShaderPanel& stShaderPanel)
{
	rapidjson::Document doc;
	if (!doc.Parse(jsonStr.c_str()).HasParseError())
	{
		//PanelName
		{
			const char* PanelName = "PanelName";
			if (doc.HasMember(PanelName) && doc[PanelName].IsString())
			{
				stShaderPanel.name = doc[PanelName].GetString();
			}
		}

		//Description
		{
			const char* Description = "Description";
			if (doc.HasMember(Description) && doc[Description].IsString())
			{
				// stShaderPanel.name = doc[Description].GetString();
			}
		}

		//IsShow
		{
			const char* IsShow = "IsShow";
			if (doc.HasMember(IsShow) && doc[IsShow].IsString())
			{
				// stShaderPanel.name = doc[Description].GetString();
				stShaderPanel.isShow = parseString<bool>(doc[IsShow].GetString());
			}
		}

		// VS
		{
			const char* VS = "VS";
			if (doc.HasMember(VS) && doc[VS].IsString())
			{
				stShaderPanel.vertexShaderPath = doc[VS].GetString();
			}
		}

		// FS
		{
			const char* FS = "FS";
			if (doc.HasMember(FS) && doc[FS].IsString())
			{
				stShaderPanel.fragmentShaderPath = doc[FS].GetString();
			}
		}

		// Properties
		{
			const char* Properties = "Properties";
			if (doc.HasMember(Properties) && doc[Properties].IsArray())
			{
				const rapidjson::Value& array = doc[Properties];
				size_t len = array.Size();
				for (size_t i = 0; i < len; i++)
				{
					auto& object = array[i];
					if (object.IsObject())
					{
						// Type
						const char* Type = "Type";
						int type = 0;

						if (object.HasMember(Type) && object[Type].IsString())
						{
							type = getTypeByName(object[Type].GetString());
						}

						struct StProperty prop = StProperty(type);

						// Name
						const char* Name = "Name";
						if (object.HasMember(Name) && object[Name].IsString())
						{
							prop.name = object[Name].GetString();
						}

						// Value
						switch (prop.type)
						{
							case Type_Int:
							{
								const char* Value = "Value";
								if (object.HasMember(Value) && object[Value].IsString()) {
									prop.iVal = parseString<int>(object[Value].GetString());
								}

								const char* Min = "Min";
								if (object.HasMember(Min) && object[Min].IsString()) {
									prop.iMin = parseString<int>(object[Min].GetString());
								}

								const char* Max = "Max";
								if (object.HasMember(Max) && object[Max].IsString()) {
									prop.iMax = parseString<int>(object[Max].GetString());
								}

								break;
							}
							case Type_Float:
							{
								const char* Value = "Value";
								if (object.HasMember(Value) && object[Value].IsString()) {
									prop.fVal = parseString<float>(object[Value].GetString());
								}

								const char* Min = "Min";
								if (object.HasMember(Min) && object[Min].IsString()) {
									prop.fMin = parseString<float>(object[Min].GetString());
								}

								const char* Max = "Max";
								if (object.HasMember(Max) && object[Max].IsString()) {
									prop.fMax = parseString<float>(object[Max].GetString());
								}
								break;
							}
							case Type_Color:
							{
								const char* Value = "Value";
								if (object.HasMember(Value) && object[Value].IsObject())
								{
									auto& vObject = object[Value];

									const char* r = "r";
									if (vObject.HasMember(r) && vObject[r].IsString())
									{
										prop.cfVal.r = parseString<float>(vObject[r].GetString());
									}

									const char* g = "g";
									if (vObject.HasMember(g) && vObject[g].IsString())
									{
										prop.cfVal.g = parseString<float>(vObject[g].GetString());
									}

									const char* b = "b";
									if (vObject.HasMember(b) && vObject[b].IsString())
									{
										prop.cfVal.b = parseString<float>(vObject[b].GetString());
									}

									const char* a = "a";
									if (vObject.HasMember(a) && vObject[a].IsString())
									{
										prop.cfVal.a = parseString<float>(vObject[a].GetString());
									}
								}

								break;
							}
							default:
								break;
						}

						stShaderPanel.propertyArray.push_back(prop);
					}
				}
			}
		}
	}
	else
	{
		cout << "parse json error" << endl;
	}
}

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
	double lastFrame;
    double currentFrame;
	double deltaTime;
	float windowWidth;
	float windowHeight;

	vector<Shader*> shaderArray;
	map<string, struct StShaderPanel> stShaderPanelMap;

	Camera camera;
	glm::vec3 cameraPositionNew;
	glm::vec3 cameraUpNew;
	float cameraYawNew;
	float cameraPitchNew;

	float lastX;
	float lastY;
	bool firstMouse;
	bool lockCamera;
	bool isLockingCamera;

	/**
	 * transform
	 **/
	glm::mat4 mvp;
	glm::mat4 projectionMatrix;
	glm::mat4 viewMatrix;

	unsigned texture0;

	State() {
		deltaTime = lastFrame = currentFrame = 0;
	}

	void init(float w, float h) {
		windowWidth = w;
		windowHeight = h;

		camera = Camera(cameraPosition, cameraUp, cameraYaw, cameraPitch);
		cameraPositionNew = cameraPosition;
		cameraUpNew = cameraUp;
		cameraYawNew = cameraYaw;
		cameraPitchNew = cameraPitch;
		firstMouse = true;
		lockCamera = true;
		isLockingCamera = false;
		lastX = windowWidth / 2.0f;
		lastY = windowHeight / 2.0f;

		mvp = glm::mat4(1.0f);
		projectionMatrix = glm::mat4(1.0f);
		viewMatrix = glm::mat4(1.0f);
	}

	glm::mat4 perspectiveMatrix()
	{
		return glm::perspective(glm::radians(camera.Zoom), windowWidth / windowHeight, 0.1f, 100.0f);
	}

	void updateMVP()
	{
		projectionMatrix = perspectiveMatrix();
		viewMatrix = camera.GetViewMatrix();
		mvp = projectionMatrix * viewMatrix;
	}

	void resetFirstMouse()
	{
		firstMouse = true;
	}

	void resetCamera()
	{
		camera.init(cameraPositionNew, cameraUpNew, cameraYawNew, cameraPitchNew);
		resetFirstMouse();
	}

	void setCamera()
	{
		cameraPositionNew = camera.Position;
		cameraUpNew = camera.WorldUp;
		cameraYawNew = camera.Yaw;
		cameraPitchNew = camera.Pitch;
	}

	// rotate camera around y axis
	void rotateCameraY(float sinValue, float cosValue)
	{
		float radius = glm::length(glm::vec2(camera.Position.xz()));
		glm::vec3 p = glm::vec3(cosValue * radius, camera.Position.y, sinValue * radius);
		camera.Position = p;
		camera.Front = glm::normalize(-p);
		camera.Right = glm::normalize(glm::cross(camera.Front, camera.WorldUp));
		camera.Up = glm::normalize(glm::cross(camera.Right, camera.Front));
	}

	void rotateCameraByYaw(float degree)
	{
		camera.ProcessMouseMovement(degree, 0);
	}
};

static struct State G;

///////////////////////////////
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

static UI ui;
///////////////////////////////

Shader* createShader(const char* vertexPath, const char* fragmentPath, const char* geometryPath = nullptr)
{
    string path = ResShaderPath;
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

// --------------------------------------------
unsigned int sphereVAO = 0;
unsigned int indexCount;
void renderSphere()
{
    if (sphereVAO == 0)
    {
        glGenVertexArrays(1, &sphereVAO);

        unsigned int vbo, ebo;
        glGenBuffers(1, &vbo);
        glGenBuffers(1, &ebo);

        std::vector<glm::vec3> positions;
        std::vector<glm::vec2> uv;
        std::vector<glm::vec3> normals;
        std::vector<unsigned int> indices;

        const unsigned int X_SEGMENTS = 64;
        const unsigned int Y_SEGMENTS = 64;
        const float PI = 3.14159265359f;
        for (unsigned int y = 0; y <= Y_SEGMENTS; ++y)
        {
            for (unsigned int x = 0; x <= X_SEGMENTS; ++x)
            {
                float xSegment = (float)x / (float)X_SEGMENTS;
                float ySegment = (float)y / (float)Y_SEGMENTS;
                float xPos = std::cos(xSegment * 2.0f * PI) * std::sin(ySegment * PI);
                float yPos = std::cos(ySegment * PI);
                float zPos = std::sin(xSegment * 2.0f * PI) * std::sin(ySegment * PI);

                positions.push_back(glm::vec3(xPos, yPos, zPos));
                uv.push_back(glm::vec2(xSegment, ySegment));
                normals.push_back(glm::vec3(xPos, yPos, zPos));
            }
        }

        bool oddRow = false;
        for (int y = 0; y < Y_SEGMENTS; ++y)
        {
            if (!oddRow) // even rows: y == 0, y == 2; and so on
            {
                for (int x = 0; x <= X_SEGMENTS; ++x)
                {
                    indices.push_back(y       * (X_SEGMENTS + 1) + x);
                    indices.push_back((y + 1) * (X_SEGMENTS + 1) + x);
                }
            }
            else
            {
                for (int x = X_SEGMENTS; x >= 0; --x)
                {
                    indices.push_back((y + 1) * (X_SEGMENTS + 1) + x);
                    indices.push_back(y       * (X_SEGMENTS + 1) + x);
                }
            }
            oddRow = !oddRow;
        }
        indexCount = indices.size();

        std::vector<float> data;
        for (size_t i = 0; i < positions.size(); ++i)
        {
            data.push_back(positions[i].x);
            data.push_back(positions[i].y);
            data.push_back(positions[i].z);
            if (uv.size() > 0)
            {
                data.push_back(uv[i].x);
                data.push_back(uv[i].y);
            }
            if (normals.size() > 0)
            {
                data.push_back(normals[i].x);
                data.push_back(normals[i].y);
                data.push_back(normals[i].z);
            }
        }
        glBindVertexArray(sphereVAO);
        glBindBuffer(GL_ARRAY_BUFFER, vbo);
        glBufferData(GL_ARRAY_BUFFER, data.size() * sizeof(float), &data[0], GL_STATIC_DRAW);
        glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, ebo);
        glBufferData(GL_ELEMENT_ARRAY_BUFFER, indices.size() * sizeof(unsigned int), &indices[0], GL_STATIC_DRAW);

        int stride = (3 + 2 + 3) * sizeof(float);

        glEnableVertexAttribArray(0);
        glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, stride, (void*)0);

		glEnableVertexAttribArray(2);
        glVertexAttribPointer(2, 2, GL_FLOAT, GL_FALSE, stride, (void*)(3 * sizeof(float)));

		glEnableVertexAttribArray(1);
        glVertexAttribPointer(1, 3, GL_FLOAT, GL_FALSE, stride, (void*)(5 * sizeof(float)));
    }

    glBindVertexArray(sphereVAO);
    glDrawElements(GL_TRIANGLE_STRIP, indexCount, GL_UNSIGNED_INT, 0);
}

unsigned int cubeVAO = 0;
unsigned int cubeVBO = 0;
void renderCube()
{
	// initialize (if necessary)
	if (cubeVAO == 0)
	{
		float vertices[] = {
			// back face
			-1.0f, -1.0f, -1.0f, 0.0f, 0.0f, -1.0f, 0.0f, 0.0f, // bottom-left
			1.0f, 1.0f, -1.0f, 0.0f, 0.0f, -1.0f, 1.0f, 1.0f,   // top-right
			1.0f, -1.0f, -1.0f, 0.0f, 0.0f, -1.0f, 1.0f, 0.0f,  // bottom-right
			1.0f, 1.0f, -1.0f, 0.0f, 0.0f, -1.0f, 1.0f, 1.0f,   // top-right
			-1.0f, -1.0f, -1.0f, 0.0f, 0.0f, -1.0f, 0.0f, 0.0f, // bottom-left
			-1.0f, 1.0f, -1.0f, 0.0f, 0.0f, -1.0f, 0.0f, 1.0f,  // top-left
			// front face
			-1.0f, -1.0f, 1.0f, 0.0f, 0.0f, 1.0f, 0.0f, 0.0f, // bottom-left
			1.0f, -1.0f, 1.0f, 0.0f, 0.0f, 1.0f, 1.0f, 0.0f,  // bottom-right
			1.0f, 1.0f, 1.0f, 0.0f, 0.0f, 1.0f, 1.0f, 1.0f,   // top-right
			1.0f, 1.0f, 1.0f, 0.0f, 0.0f, 1.0f, 1.0f, 1.0f,   // top-right
			-1.0f, 1.0f, 1.0f, 0.0f, 0.0f, 1.0f, 0.0f, 1.0f,  // top-left
			-1.0f, -1.0f, 1.0f, 0.0f, 0.0f, 1.0f, 0.0f, 0.0f, // bottom-left
			// left face
			-1.0f, 1.0f, 1.0f, -1.0f, 0.0f, 0.0f, 1.0f, 0.0f,   // top-right
			-1.0f, 1.0f, -1.0f, -1.0f, 0.0f, 0.0f, 1.0f, 1.0f,  // top-left
			-1.0f, -1.0f, -1.0f, -1.0f, 0.0f, 0.0f, 0.0f, 1.0f, // bottom-left
			-1.0f, -1.0f, -1.0f, -1.0f, 0.0f, 0.0f, 0.0f, 1.0f, // bottom-left
			-1.0f, -1.0f, 1.0f, -1.0f, 0.0f, 0.0f, 0.0f, 0.0f,  // bottom-right
			-1.0f, 1.0f, 1.0f, -1.0f, 0.0f, 0.0f, 1.0f, 0.0f,   // top-right
			// right face
			1.0f, 1.0f, 1.0f, 1.0f, 0.0f, 0.0f, 1.0f, 0.0f,   // top-left
			1.0f, -1.0f, -1.0f, 1.0f, 0.0f, 0.0f, 0.0f, 1.0f, // bottom-right
			1.0f, 1.0f, -1.0f, 1.0f, 0.0f, 0.0f, 1.0f, 1.0f,  // top-right
			1.0f, -1.0f, -1.0f, 1.0f, 0.0f, 0.0f, 0.0f, 1.0f, // bottom-right
			1.0f, 1.0f, 1.0f, 1.0f, 0.0f, 0.0f, 1.0f, 0.0f,   // top-left
			1.0f, -1.0f, 1.0f, 1.0f, 0.0f, 0.0f, 0.0f, 0.0f,  // bottom-left
			// bottom face
			-1.0f, -1.0f, -1.0f, 0.0f, -1.0f, 0.0f, 0.0f, 1.0f, // top-right
			1.0f, -1.0f, -1.0f, 0.0f, -1.0f, 0.0f, 1.0f, 1.0f,  // top-left
			1.0f, -1.0f, 1.0f, 0.0f, -1.0f, 0.0f, 1.0f, 0.0f,   // bottom-left
			1.0f, -1.0f, 1.0f, 0.0f, -1.0f, 0.0f, 1.0f, 0.0f,   // bottom-left
			-1.0f, -1.0f, 1.0f, 0.0f, -1.0f, 0.0f, 0.0f, 0.0f,  // bottom-right
			-1.0f, -1.0f, -1.0f, 0.0f, -1.0f, 0.0f, 0.0f, 1.0f, // top-right
			// top face
			-1.0f, 1.0f, -1.0f, 0.0f, 1.0f, 0.0f, 0.0f, 1.0f, // top-left
			1.0f, 1.0f, 1.0f, 0.0f, 1.0f, 0.0f, 1.0f, 0.0f,   // bottom-right
			1.0f, 1.0f, -1.0f, 0.0f, 1.0f, 0.0f, 1.0f, 1.0f,  // top-right
			1.0f, 1.0f, 1.0f, 0.0f, 1.0f, 0.0f, 1.0f, 0.0f,   // bottom-right
			-1.0f, 1.0f, -1.0f, 0.0f, 1.0f, 0.0f, 0.0f, 1.0f, // top-left
			-1.0f, 1.0f, 1.0f, 0.0f, 1.0f, 0.0f, 0.0f, 0.0f   // bottom-left
		};
		glGenVertexArrays(1, &cubeVAO);
		glGenBuffers(1, &cubeVBO);
		// fill buffer
		glBindBuffer(GL_ARRAY_BUFFER, cubeVBO);
		glBufferData(GL_ARRAY_BUFFER, sizeof(vertices), vertices, GL_STATIC_DRAW);
		// link vertex attributes
		glBindVertexArray(cubeVAO);
		glEnableVertexAttribArray(0);// aPos
		glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, 8 * sizeof(float), (void*)0);
		glEnableVertexAttribArray(3);// aNormal
		glVertexAttribPointer(3, 3, GL_FLOAT, GL_FALSE, 8 * sizeof(float), (void*)(3 * sizeof(float)));
		glEnableVertexAttribArray(2);// aTexCoord
		glVertexAttribPointer(2, 2, GL_FLOAT, GL_FALSE, 8 * sizeof(float), (void*)(6 * sizeof(float)));
		glBindBuffer(GL_ARRAY_BUFFER, 0);
		glBindVertexArray(0);
	}
	// render Cube
	glBindVertexArray(cubeVAO);
	glDrawArrays(GL_TRIANGLES, 0, 36);
	glBindVertexArray(0);
}

unsigned int coordVAO = 0;
unsigned int coordVBO = 0;
void renderCoordinateSystem()
{
	if (coordVAO == 0)
	{
		float x, y, z;
		x = y = z = 100000000.0f;
		//x = y = z = 1.0f;

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
// --------------------------------------------


void Init()
{
	float w = 1280, h = 720;
	G.init(w, h);

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

			renderCoordinateSystem();

			glm::vec3 position = glm::vec3(5.0f, 0, 0);
			glm::mat4 m1 = IMatrix4;
			m1 = glm::translate(m1, position);

			pShader->setMat4("mvp", G.mvp * m1);
			pShader->setMat4("uMat4Model", m1);
			pShader->setFloat("uRatioMixTex2Color", 0.0);
			pShader->setFloat("uRatioMixAColor2UColor", 0.0);
			renderCube();
		} // end if
	}
}

void Clear()
{
    //printf("Clear\n");
	clearShaderArray();
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
