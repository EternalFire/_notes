#version 330 core
precision mediump float;

layout (location = 0) in vec3 aPos;
layout (location = 1) in vec3 aColor;
layout (location = 2) in vec2 aTexCoord;
layout (location = 3) in vec3 aNormal;

out vec3 vertexColor;
out vec2 texCoord;
out vec3 vsNormal;
out vec3 vsFragPos;

// attribute vec3 aPos;
// attribute vec3 aColor;
// attribute vec2 aTexCoord;
// attribute vec3 aNormal;

// varying vec3 vertexColor;
// varying vec2 texCoord;
// varying vec3 vsNormal;
// varying vec3 vsFragPos;

uniform mat4 mvp;
uniform mat4 uMat4Model;
uniform mat3 uNormalMatrix;

void main()
{
    vec4 p = vec4(aPos, 1.0);
    gl_Position = mvp * p;
    vertexColor = aColor;
    texCoord = aTexCoord;
    vsNormal = uNormalMatrix * aNormal;
    vsFragPos = vec3(uMat4Model * p);
}
