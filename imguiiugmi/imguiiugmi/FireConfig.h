#ifndef FireConfig_h
#define FireConfig_h

#include <FireDefinition.h>

NS_FIRE_BEGIN

const char* ResPath = "resources/";
const char* ResShaderPath = "resources/shaders/";

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
const glm::vec3 CameraPosition = glm::vec3(0.667f, 8.979f, 19.392f);
const glm::vec3 CameraUp = glm::vec3(0, 1.0, 0);
const float CameraYaw = -110.5f;  // around y axis
const float CameraPitch = -24.4f; // around x axis

const glm::mat4 IMatrix4(1.0f); // identty matrix
const glm::vec3 xAxis(1.0f, 0.0f, 0.0f);
const glm::vec3 yAxis(0.0f, 1.0f, 0.0f);
const glm::vec3 zAxis(0.0f, 0.0f, 1.0f);

const char* KeyCameraPosition = "CameraPosition";
const char* KeyCameraYaw = "CameraYaw";
const char* KeyCameraPitch = "CameraPitch";
const char* KeyCameraZoom = "CameraZoom";
const char* KeyCameraSpeed = "CameraSpeed";
const char* KeyCameraSensitivity = "CameraSensitivity";

struct StConfig {
    float width;
    float height;
    float cameraPosition[3] = {0.667f, 8.979f, 19.392f};
    float cameraYaw = -110.5f;
    float cameraPitch = -24.4f;
    float cameraZoom = 45.0f;
    float cameraSpeed = 0.5f;
    float cameraSensitivity = 0.1f;
    
    StConfig() {
        width = 1280.0f;
        height = 720.0f;
    }
    
    ~StConfig() {
        
    }
};

StConfig config;

NS_FIRE_END__

#endif
