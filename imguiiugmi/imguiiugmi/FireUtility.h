#ifndef FireUtility_h
#define FireUtility_h

#include <FireDefinition.h>

#define STB_IMAGE_IMPLEMENTATION
#include <stb_image.h>

#include <math.h>
#include <iostream>
using namespace std;

///
NS_FIRE_BEGIN

int clamp(int value, int minVal, int maxVal) {
    return value <= minVal ? minVal : (value >= maxVal ? maxVal : value);
}

float clamp(float value, float minVal, float maxVal) {
    return fmax(minVal, (fmin(value, maxVal)));
}

Color convertColorItoF(const IColor& icolor)
{
	Color result = { CNTo1(icolor.r), CNTo1(icolor.g), CNTo1(icolor.b), CNTo1(icolor.a) };
	return result;
}
IColor convertColorFtoI(const Color& color)
{
	IColor result = { CNTo255(color.r), CNTo255(color.g), CNTo255(color.b), CNTo255(color.a) };
	return result;
}
void convertColorToArray(const IColor& color, float* rgba)
{
	rgba[0] = CNTo1(color.r);
	rgba[1] = CNTo1(color.g);
	rgba[2] = CNTo1(color.b);
	rgba[3] = CNTo1(color.a);
}
void convertColorToArray(const Color& color, float* rgba)
{
	rgba[0] = (color.r);
	rgba[1] = (color.g);
	rgba[2] = (color.b);
	rgba[3] = (color.a);
}
void convertArrayToColor(const float* rgba, IColor* outColor)
{
	outColor->r = CNTo255(rgba[0]);
	outColor->g = CNTo255(rgba[1]);
	outColor->b = CNTo255(rgba[2]);
	outColor->a = CNTo255(rgba[3]);
}
void convertArrayToColor(const float* rgba, Color* outColor)
{
	outColor->r = (rgba[0]);
	outColor->g = (rgba[1]);
	outColor->b = (rgba[2]);
	outColor->a = (rgba[3]);
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

template<typename T>
bool LoadOrSaveDefault(const string& path, T& config)
{
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
    return exist;
}

template<typename T>
void SaveObject(const string& path, T& config)
{
	const string& str = toJSON(config);
	writeToFile(path.c_str(), str.c_str());
}

template<typename T>
bool LoadObject(const string& path, T& config)
{
	bool exist = isFileExist(path.c_str());
	if (exist)
	{
		string data = readFromFile(path.c_str());
		parseJSON(data, config);
	}
	return exist;
}

NS_FIRE_END__
///

#endif /* FireUtility_h */
