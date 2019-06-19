#ifndef FireState_h
#define FireState_h

#define GLM_FORCE_SWIZZLE
#include <glm/glm.hpp>

#include <FireDefinition.h>
#include <FireProperty.h>
#include <camera.h>
#include <shader.h>

#include <map>
#include <vector>
#include <string>
#include <iostream>

using namespace std;

///
NS_FIRE_BEGIN

struct State
{
    double lastFrame;
    double currentFrame;
    double deltaTime;
    float windowWidth;
    float windowHeight;
    
    PropertyObject shaderNamesObject;
    vector<Shader*> shaderArray;
    map<string, struct StShaderPanel> stShaderPanelMap;
    
    Camera camera;
    glm::vec3 cameraPositionNew;
    glm::vec3 cameraUpNew;
    float cameraYawNew;
    float cameraPitchNew;
    float cameraZoomNew;
    
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
        
        camera = Camera(CameraPosition, CameraUp, CameraYaw, CameraPitch);
        cameraPositionNew = CameraPosition;
        cameraUpNew = CameraUp;
        cameraYawNew = CameraYaw;
        cameraPitchNew = CameraPitch;
        cameraZoomNew = camera.Zoom;
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
        camera.Zoom = cameraZoomNew;
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

/**
 * Global State
 */
struct State G;


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
void clearShader(Shader* p)
{
	auto& vector = G.shaderArray;
	for (auto it = vector.begin(); it != vector.end(); it++)
	{
		auto shader = *it;
		if (shader == p) {
			delete shader;
			shader = NULL;
			vector.erase(it);
			break;
		}
	}
}

NS_FIRE_END__
///

#endif /* FireState_h */
