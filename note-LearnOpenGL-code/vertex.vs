#version 330 core

layout (location = 0) in vec3 aPos;
layout (location = 1) in vec3 aColor;
layout (location = 2) in vec2 aTexCoord;
layout (location = 3) in vec3 aNormal;

out vec3 vertexColor;
out vec2 texCoord;
out vec3 vsNormal;
out vec3 vsFragPos;

uniform mat4 mvp;
uniform mat4 uMat4Model;

void main()
{
    vec4 p = vec4(aPos, 1.0);
    gl_Position = mvp * p;
    vertexColor = aColor;
    texCoord = aTexCoord;
    vsNormal = aNormal;
    vsFragPos = vec3(uMat4Model * p);
}
