#version 330 core
precision mediump float;
precision mediump int;

out vec4 FragColor;

in vec2 texCoord;
in vec3 vertexColor;
in vec3 vsNormal;
in vec3 vsFragPos;


// vec4 FragColor;

// varying vec2 texCoord;
// varying vec3 vertexColor;
// varying vec3 vsNormal;
// varying vec3 vsFragPos;

uniform sampler2D texture0;
uniform vec4 uColor;
uniform vec3 uViewPos;
uniform float uRatioMixTex2Color;     // textureColor to mix(vertexColor, uColor)
uniform float uRatioMixAColor2UColor; // vertexColor to uColor
uniform float uTime;
uniform vec3 uLightPos;
uniform vec4 uLightColor;
uniform bool uUsePointLight; // point light switch
uniform bool uSwitchEffectInvert;
uniform bool uSwitchEffectGray;

vec3 invertColor(const vec3 color);
vec3 grayColor(const vec3 color);
vec3 kernelEffect(sampler2D tex, vec2 texCoords);
vec3 lightingBasic(vec3 fragPos, vec3 normal, vec3 lightPos, vec3 lightColor, vec3 viewPos, vec3 objectColor, float ambientStrength, float specularStrength, float shininess);

void main()
{
    vec4 textureColor = texture(texture0, texCoord);
    // vec4 color = vec4(mix(vertexColor, uColor, uRatioMixAColor2UColor), 1.0);
    vec4 color = mix(vec4(vertexColor, 1.0f), uColor, uRatioMixAColor2UColor);

    //              from          to     ratio
    FragColor = mix(textureColor, color, uRatioMixTex2Color);
    // FragColor = color;

    // FragColor.rgb = invertColor(FragColor.rgb);
    // FragColor.rgb = grayColor(FragColor.rgb);
    // FragColor.rgb = kernelEffect(texture0, texCoord);

    if (uUsePointLight)
    {
        // vec3 lightPos = vec3(3.0 * cos(uTime), 3.0 * sin(uTime), 0.0);
        vec3 lightPos = uLightPos;
        vec3 lightColor = uLightColor.rgb;
        FragColor.rgb = lightingBasic(vsFragPos, vsNormal, lightPos, lightColor, uViewPos, FragColor.rgb, 0.2, 0.5, 20.0);
    }

    if (uSwitchEffectInvert)
    {
        FragColor.rgb = invertColor(FragColor.rgb);
    }

    if (uSwitchEffectGray)
    {
        FragColor.rgb = grayColor(FragColor.rgb);
    }

    // gl_FragColor = FragColor;
}

// Phong Lighting
//                  world position
vec3 lightingBasic(vec3 fragPos, vec3 normal, vec3 lightPos, vec3 lightColor, vec3 viewPos, vec3 objectColor, float ambientStrength, float specularStrength, float shininess)
{
    // ambient
    // float ambientStrength = 0.1;
    vec3 ambient = ambientStrength * lightColor;

    // diffuse
    vec3 norm = normalize(normal);
    vec3 lightDir = normalize(lightPos - fragPos);
    float diff = max(dot(norm, lightDir), 0.0);
    vec3 diffuse = diff * lightColor;

    // specular
    // float specularStrength = 0.5;
    vec3 viewDir = normalize(viewPos - fragPos);
    vec3 reflectDir = reflect(-lightDir, norm);
    float spec = pow(max(dot(viewDir, reflectDir), 0.0), shininess);
    vec3 specular = specularStrength * spec * lightColor;

    vec3 result = (ambient + diffuse + specular) * objectColor;
    return result;
}

vec3 invertColor(const vec3 color)
{
	return vec3(1.0 - color.r, 1.0 - color.g, 1.0 - color.b);
}

vec3 grayColor(const vec3 color)
{
	float average = 0.2126 * color.r + 0.7152 * color.g + 0.0722 * color.b;
	return vec3(average);
}


const float offset = 1.0 / 300.0;

const vec2 offsets[9] = vec2[](
    vec2(-offset,  offset), // 左上
    vec2( 0.0f,    offset), // 正上
    vec2( offset,  offset), // 右上
    vec2(-offset,  0.0f),   // 左
    vec2( 0.0f,    0.0f),   // 中
    vec2( offset,  0.0f),   // 右
    vec2(-offset, -offset), // 左下
    vec2( 0.0f,   -offset), // 正下
    vec2( offset, -offset)  // 右下
);

vec3 kernelEffect(sampler2D tex, vec2 texCoords)
{
	// 锐化
    // float kernel[9] = float[](
    //     -1, -1, -1,
    //     -1,  9, -1,
    //     -1, -1, -1
    // );

    // 模糊
	// float kernel[9] = float[](
	// 	1.0 / 16, 2.0 / 16, 1.0 / 16,
	// 	2.0 / 16, 4.0 / 16, 2.0 / 16,
	// 	1.0 / 16, 2.0 / 16, 1.0 / 16
	// );

	// 边缘检测
	float kernel[9] = float[](
		1.0, 1.0, 1.0,
		1.0,  -8.0, 1.0,
		1.0, 1.0, 1.0
	);

    vec3 sampleTex[9];
    for(int i = 0; i < 9; i++)
    {
        sampleTex[i] = vec3(texture(tex, texCoords.st + offsets[i]));
    }

    vec3 color = vec3(0.0);
    for(int i = 0; i < 9; i++) {
        color += sampleTex[i] * kernel[i];
    }

    return color;
}