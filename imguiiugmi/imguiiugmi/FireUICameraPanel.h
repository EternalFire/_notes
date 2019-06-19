
#ifndef FireUICameraPanel_h
#define FireUICameraPanel_h

#include <FireDefinition.h>
#include <FireConfig.h>
#include <FireState.h>
#include "imgui.h"

NS_FIRE_BEGIN

class UICameraPanel : public UIBase {
public:
    void init()
    {
        UIBase::init();

    }
    
    void render()
    {
        tempVec3[0] = G.camera.Position.x;
        tempVec3[1] = G.camera.Position.y;
        tempVec3[2] = G.camera.Position.z;
        zoom = G.camera.Zoom;
        yaw = G.camera.Yaw;
        pitch = G.camera.Pitch;
        
        UIBase::render();
        
        ImGui::Begin("Camera Setting");
        {
            if (G.lockCamera) {
                ImGui::TextColored(ImVec4(1.0f, 0, 0, 1.0f), "Camera lock");
            } else {
                ImGui::TextColored(ImVec4(0, 1.0f, 0, 1.0f), "Camera free");
            }
        
            auto c1 = ImGui::DragFloat3(KeyCameraPosition, tempVec3);
            auto c2 = ImGui::SliderFloat(KeyCameraZoom, &zoom, 1.0f, 45.0f);
            auto c3 = ImGui::SliderFloat(KeyCameraYaw,  &yaw, -2000.0f, 2000.0f);
            auto c4 = ImGui::SliderFloat(KeyCameraPitch, &pitch, -89.0f, 89.0f);
            auto c5 = ImGui::DragFloat(KeyCameraSpeed, &G.camera.MovementSpeed, 0.1f, 0, 50.0f);
            auto c6 = ImGui::DragFloat(KeyCameraSensitivity, &G.camera.MouseSensitivity, 0.01f, 0.1f, 1.0f);
            
            if (c1 || c2 || c3 || c4 || c5 || c6)
            {
                G.cameraPositionNew.x = tempVec3[0];
                G.cameraPositionNew.y = tempVec3[1];
                G.cameraPositionNew.z = tempVec3[2];
                G.cameraZoomNew = zoom;
                G.cameraYawNew = yaw;
                G.cameraPitchNew = pitch;
                G.resetCamera();
            }
            
            auto save_ = ImGui::Button("Save...");
            if (save_) {
                config.cameraPosition[0] = G.camera.Position.x;
                config.cameraPosition[1] = G.camera.Position.y;
                config.cameraPosition[2] = G.camera.Position.z;
                config.cameraZoom = G.camera.Zoom;
                config.cameraYaw = G.camera.Yaw;
                config.cameraPitch = G.camera.Pitch;
                config.cameraSpeed = G.camera.MovementSpeed;
                config.cameraSensitivity = G.camera.MouseSensitivity;
                SaveConfig();
            }
        }
        ImGui::End();
    }
    
public:
    float tempVec3[3] = {0};
    float zoom = 45.0f;
    float yaw = -90.0f;
    float pitch = 0.0f;
};

NS_FIRE_END__

#endif
