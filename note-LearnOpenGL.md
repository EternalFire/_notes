# 笔记: LearnOpenGL

- [笔记: LearnOpenGL](#%E7%AC%94%E8%AE%B0-learnopengl)
  - [资料](#%E8%B5%84%E6%96%99)
  - [记录](#%E8%AE%B0%E5%BD%95)
    - [OpenGL](#opengl)
    - [三角形](#%E4%B8%89%E8%A7%92%E5%BD%A2)
    - [着色器](#%E7%9D%80%E8%89%B2%E5%99%A8)
    - [纹理](#%E7%BA%B9%E7%90%86)
    - [变换](#%E5%8F%98%E6%8D%A2)
    - [坐标系统](#%E5%9D%90%E6%A0%87%E7%B3%BB%E7%BB%9F)
    - [摄像机](#%E6%91%84%E5%83%8F%E6%9C%BA)
    - [颜色, 基础光照, 材质](#%E9%A2%9C%E8%89%B2-%E5%9F%BA%E7%A1%80%E5%85%89%E7%85%A7-%E6%9D%90%E8%B4%A8)
    - [光照贴图](#%E5%85%89%E7%85%A7%E8%B4%B4%E5%9B%BE)
    - [投光物](#%E6%8A%95%E5%85%89%E7%89%A9)
    - [Assimp](#assimp)
    - [深度测试](#%E6%B7%B1%E5%BA%A6%E6%B5%8B%E8%AF%95)
    - [模板测试](#%E6%A8%A1%E6%9D%BF%E6%B5%8B%E8%AF%95)
    - [混合](#%E6%B7%B7%E5%90%88)
    - [面剔除](#%E9%9D%A2%E5%89%94%E9%99%A4)
    - [帧缓冲](#%E5%B8%A7%E7%BC%93%E5%86%B2)
    - [立方体贴图](#%E7%AB%8B%E6%96%B9%E4%BD%93%E8%B4%B4%E5%9B%BE)
    - [高级数据](#%E9%AB%98%E7%BA%A7%E6%95%B0%E6%8D%AE)
    - [几何着色器](#%E5%87%A0%E4%BD%95%E7%9D%80%E8%89%B2%E5%99%A8)
    - [实例化](#%E5%AE%9E%E4%BE%8B%E5%8C%96)
    - [抗锯齿](#%E6%8A%97%E9%94%AF%E9%BD%BF)
    - [高级光照](#%E9%AB%98%E7%BA%A7%E5%85%89%E7%85%A7)
    - [Gamma 校正](#gamma-%E6%A0%A1%E6%AD%A3)
    - [阴影映射](#%E9%98%B4%E5%BD%B1%E6%98%A0%E5%B0%84)
    - [点光源阴影](#%E7%82%B9%E5%85%89%E6%BA%90%E9%98%B4%E5%BD%B1)
    - [法线贴图](#%E6%B3%95%E7%BA%BF%E8%B4%B4%E5%9B%BE)
    - [视差贴图](#%E8%A7%86%E5%B7%AE%E8%B4%B4%E5%9B%BE)
    - [HDR](#hdr)
    - [泛光](#%E6%B3%9B%E5%85%89)
    - [延迟着色](#%E5%BB%B6%E8%BF%9F%E7%9D%80%E8%89%B2)
    - [SSAO](#ssao)
    - [PBR](#pbr)
    - [文本渲染](#%E6%96%87%E6%9C%AC%E6%B8%B2%E6%9F%93)
  - [Snippet](#snippet)
    - [glm](#glm)
    - [传递 顶点数据 和 uniform 数据](#%E4%BC%A0%E9%80%92-%E9%A1%B6%E7%82%B9%E6%95%B0%E6%8D%AE-%E5%92%8C-uniform-%E6%95%B0%E6%8D%AE)
    - [纹理](#%E7%BA%B9%E7%90%86-1)
    - [深度测试](#%E6%B7%B1%E5%BA%A6%E6%B5%8B%E8%AF%95-1)
    - [帧缓冲](#%E5%B8%A7%E7%BC%93%E5%86%B2-1)
    - [GL内置函数](#gl%E5%86%85%E7%BD%AE%E5%87%BD%E6%95%B0)
    - [材质与光源](#%E6%9D%90%E8%B4%A8%E4%B8%8E%E5%85%89%E6%BA%90)
    - [效果](#%E6%95%88%E6%9E%9C)
      - [反相](#%E5%8F%8D%E7%9B%B8)
      - [灰度](#%E7%81%B0%E5%BA%A6)
      - [核效果(卷积矩阵)](#%E6%A0%B8%E6%95%88%E6%9E%9C%E5%8D%B7%E7%A7%AF%E7%9F%A9%E9%98%B5)

## 资料

[LearnOpenGL CN](https://learnopengl-cn.github.io)

[LearnOpenGL](https://learnopengl.com/)

[投影矩阵](http://www.songho.ca/opengl/gl_projectionmatrix.html)

## 记录

### OpenGL

OpenGL 是规范, 具体的实现通过显卡厂商编写.

OpenGL3.3 核心模式(Core-profile)


### 三角形

顶点数组对象, Vertex Array Object, VAO. 管理 顶点数据和属性的配置, 切换 VAO 等同于重新绑定顶点数据和属性.

顶点缓冲对象, Vertex Buffer Object, VBO. 在GPU内存上缓存顶点数据.

索引缓冲对象, Element Buffer Object, EBO / Index Buffer Object, IBO. 使用顶点数据中的索引值来组织绘制顶点的顺序(索引绘制, Indexed Drawing).

标准化设备坐标, Normalized Device Coordinates (NDC), 顶点坐标(xyz)范围: $[-1, 1]$

屏幕空间坐标, Screen-space Coordinates

视口变换, viewport transform

线框模式, Wireframe Mode

```
//开启线框模式
glPolygonMode(GL_FRONT_AND_BACK, GL_LINE);
GL_FRONT_AND_BACK: 三角形的正面与反面
GL_LINE: 用线来绘制

//恢复默认模式
glPolygonMode(GL_FRONT_AND_BACK, GL_FILL);
```

使用缓冲对象的方式:

GL_STATIC_DRAW, 数据不会改变或者改变很少

GL_DYNAMIC_DRAW, 数据会被改变很多次

GL_STREAM_DRAW, 每次绘制时, 数据都会改变

### 着色器

shader 程序用于自定义渲染流程中的特定部分.

着色器开头需要声明版本, 输入输出变量, uniform 变量, main函数.

顶点属性, Vertex Attribute, 顶点着色器的输入变量.

```
    // 最大顶点属性数量
    int nrAttributes;
    glGetIntegerv(GL_MAX_VERTEX_ATTRIBS, &nrAttributes);
```

重组(Swizzling)

```
vec2 someVec;
vec4 differentVec = someVec.xyxx;
```

`layout (location = 0)`, 表示顶点属性位置.

### 纹理

纹理环绕方式, 纹理坐标超过范围

- GL_REPEAT, 重复
- GL_MIRRORED_REPEAT, 镜像重复
- GL_CLAMP_TO_EDGE, 重复纹理坐标的边缘
- GL_CLAMP_TO_BORDER, 超出的部分使用指定的边缘颜色

```c
// 指定边缘颜色
float borderColor[] = { 1.0f, 1.0f, 0.0f, 1.0f };
glTexParameterfv(GL_TEXTURE_2D, GL_TEXTURE_BORDER_COLOR, borderColor);
```

纹理过滤, 放大缩小时重新采样的方式

- GL_NEAREST
- GL_LINEAR

```c
glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
```

多级渐远纹理, Mipmap

根据物体与观察者的距离, 选择应用合适的纹理.

多级渐远纹理主要是使用在纹理被缩小的情况下.

> 在渲染中切换多级渐远纹理级别(Level)时，OpenGL在两个不同级别的多级渐远纹理层之间会产生不真实的生硬边界。

多级渐远纹理的过滤方式(设置 GL_TEXTURE_MIN_FILTER):

```c
//GL_NEAREST_MIPMAP_NEAREST	使用最邻近的多级渐远纹理来匹配像素大小，并使用邻近插值进行纹理采样
//GL_LINEAR_MIPMAP_NEAREST	使用最邻近的多级渐远纹理级别，并使用线性插值进行采样
//GL_NEAREST_MIPMAP_LINEAR	在两个最匹配像素大小的多级渐远纹理之间进行线性插值，使用邻近插值进行采样
//GL_LINEAR_MIPMAP_LINEAR	        在两个邻近的多级渐远纹理之间使用线性插值，并使用线性插值进行采样

glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR_MIPMAP_LINEAR);
glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
```

采样器, sampler2D, 分配 纹理单元 到 采样器.

`glActiveTexture`, 激活纹理单元.

`glBindTexture`, 绑定纹理到纹理单元.

纹理对象 -- 纹理数据 -- 纹理单元 -- 采样器

GLSL 内置函数 `mix(a, b, t)`, 根据t进行线性插值, a * (1 - t) + b * t . **from a to b**.


### 变换

角度 = 弧度 * (180.0f / PI)

记忆技巧: 180.0f = PI, 弧度 占 PI 的比例 乘以 180.0f

弧度 = 角度 * (PI / 180.0f)

记忆技巧: 180.0f = PI, 角度 占 180.0f 的比例 乘以 PI


### 坐标系统

局部空间 =[A]=> 世界空间 =[B]=> 观察空间 =[C]=> 裁剪空间 =[D]=> 屏幕空间

A: 模型矩阵

B: 观察(视图)矩阵

C: 投影矩阵

D: 透视除法, 视口变换

平截头体, Frustum

深度值存储在片段内.

投影矩阵, projection matrix, 将可视范围内的坐标转换为标准化设备坐标(NDC).

透视除法, Perspective Division, (x/w, y/w, z/w, 1.0).

透视投影, perspective projection.

NDC 坐标系是左手系, 观察坐标系(eye coordinates)是右手系.


### 摄像机

欧拉角: 俯仰角(pitch, 绕x轴), 偏航角(yaw, 绕y轴), 滚转角(roll, 绕z轴)

不同风格的摄像机: FPS摄像机, 飞行器摄像机

### 颜色, 基础光照, 材质

lightColor * objectColor

物体的颜色是物体反射光的颜色.

白光由不同颜色的光组成.

冯氏光照模型(Phong Lighting Model)由3个分量组成: 环境光照(Ambient Lighting), 漫反射光照(Diffuse Lighting), 镜面光照(Specular Lighting).

漫反射光照: 模拟光源对物体的方向性影响. 光线垂直照到物体表面, 物体会更亮.

镜面光照: 模拟光泽物体上出现的亮点.

全局照明(Global Illumination)算法

镜面高光(Specular Highlight)

[Normal Matrix](http://www.lighthouse3d.com/tutorials/glsl-12-tutorial/the-normal-matrix/)

法线矩阵, 模型矩阵左上角的逆矩阵的转置矩阵. 修复不等比缩放对法向量的影响.

高光的反光度(Shininess), 一个物体的反光度越高，反射光的能力越强，散射得越少，高光点就会越小。

GLSL 内置函数 reflect(), 计算反射向量.

在顶点着色器中实现的冯氏光照模型叫做 Gouraud 着色(Gouraud Shading).

光线方向 = 光源坐标 - 片段坐标

视线方向(观察方向) = 视点坐标 - 片段坐标

光线入射方向 = - 光线方向


### 光照贴图

漫反射贴图(Diffuse Map), 物体的纹理

sampler2D是不透明类型(Opaque Type)

镜面光贴图(Specular Map)

法线/凹凸贴图(Normal/Bump Map)

反射贴图(Reflection Map)

---

### 投光物

Light casters

平行光, 点光源, 聚光灯


---

### Assimp

3D建模工具(3D Modeling Tool), Blender、3DS Max, Maya, ...

解析模型: 导出的模型文件以及提取所有有用的信息

UV映射(uv-mapping)

模型导入库, Assimp, Open Asset Import Library

网格, Mesh, 包含了渲染所需的数据: 顶点位置, 法向量, 纹理坐标, 材质.

模型, Model. 一个模型可以包含多个模型, 多个网格.

定义顶点结构体, 纹理结构体, 用于管理传输给 GL 的数据.

3D艺术家(模型, 地形, 特效, 动作...)

### 深度测试

深度缓冲, Depth Buffer. Z 缓冲, z-buffer. 存储了片段的深度值, 区分物体间的前后关系.

启用深度测试后, OpenGL将片段的深度值与深度缓冲区的深度值做对比. 如果通过测试, 则将片段的 z 值写入深度缓冲区, 否则丢弃该片段.

gl_FragCoord 是屏幕空间坐标. gl_FragCoord.z 是深度值.

提前深度测试(Early Depth Testing)

深度测试函数, `glDepthFunc(op)`

接近近平面时, 深度值的精度变高.

> 深度缓冲中的值在屏幕空间中不是线性的, 在透视矩阵应用之前在观察空间中是线性的

深度缓冲的可视化, 将片段的深度值经过转换后赋值给 gl_FragColor.

```c
#version 330 core
out vec4 FragColor;

float near = 0.1;
float far  = 100.0;

float LinearizeDepth(float depth)
{
    float z = depth * 2.0 - 1.0; // back to NDC
    return (2.0 * near * far) / (far + near - z * (far - near));
}

void main()
{
    float depth = LinearizeDepth(gl_FragCoord.z) / far; // 为了演示除以 far
    FragColor = vec4(vec3(depth), 1.0);
}
```

深度冲突, z fighting.

防止深度冲突的方法:

- 物体之间不要太靠近
- 将近平面设置远一些
- 使用更高精度的深度缓冲


### 模板测试

模板缓冲, Stencil Buffer.

先执行模板测试, 再进行深度测试

根据模板缓冲的模板值, 丢弃或保留某个片段. 模板值占8位.

使用模板测试显示物体轮廓.

在渲染时写入/读取模板缓冲区

窗口系统设置模板缓冲

模板值占 8 位

`glEnable(GL_STENCIL_TEST);`, 开启模板测试

`glStencilMask(0xFF);`, 设置可以写入模板缓冲区

`glStencilMask(0x00);`, 禁止写入模板缓冲区

`glStencilFunc(GLenum func, GLint ref, GLuint mask)`, 模板测试函数

`glStencilOp(GLenum sfail, GLenum dpfail, GLenum dppass)`, 更新模板缓冲区函数

在绘制前设置模板测试函数.

### 混合

源颜色: 源自纹理的颜色

目标颜色: 当前存储在颜色缓冲区的颜色

### 面剔除

观察正面, 以逆时针方向定义顶点的顺序.

### 帧缓冲

默认的帧缓冲由窗口配置.

离屏渲染(Off-screen Rendering), 渲染到不同的帧缓冲. 帧缓冲保存渲染结果.

渲染缓冲对象(Renderbuffer Object), 数据储存为OpenGL原生的渲染格式

需要从缓冲区中采样颜色或深度值时, 使用纹理附件

使用帧缓冲, 进行后期处理(反相, 灰度, 核效果)

卷积矩阵(Convolution Matrix)

### 立方体贴图

立方体贴图, 立方体有6个面, 需要 6 张纹理.

天空盒(绘制在立方体上)

环境映射(Environment Mapping): 反射(Reflection), 折射(Refraction)

反射: 物体反射环境的颜色. GLSL 内置函数 `reflect()`

折射率(Refractive Index)

折射, GLSL 内置函数 `refract()`

### 高级数据

`glBufferSubData()`, 批次填充缓冲区.

批次: 112233. 交错: 123123.

### 几何着色器

`EmitVertex()`

`EndPrimitive()`

### 实例化

一次性绘制大量模型, 需要减少从 CPU 到 GPU 传输数据的次数, 尽量一次性把数据发送到 GPU .

实例化渲染: `glDrawArraysInstanced()`, `glDrawElementsInstanced()`

每调用一次实例化渲染, gl_InstanceID 会从 0 开始自增.

实例化数组(Instanced Array)

`glVertexAttribDivisor()`, 设置 OpenGL 更新顶点属性数据的时机(设置顶点属性为实例化数组). 是每次绘制, 还是每个新实例, 或者每 N 个新实例.


### 抗锯齿

超采样抗锯齿(Super Sample Anti-aliasing, SSAA)

多重采样抗锯齿(Multisample Anti-aliasing, MSAA)

- `glfwWindowHint(GLFW_SAMPLES, 4);` 提示 GLFW 对每个像素使用4个子采样点的颜色, 深度, 模板缓冲
- `glEnable(GL_MULTISAMPLE);`

glBlitFramebuffer(), 复制一个用户定义的帧缓冲区域到另一个用户定义的帧缓冲区域


### 高级光照

Blinn-Phong模型, 测量法线与半程向量之间的夹角(用于镜面高光)

Blinn-Phong模型的镜面反光度, 通常会选择冯氏着色时反光度分量的2到4倍。

半程向量(Halfway Vector), 正规化后的(光线方向 + 观察方向)

```c
vec3 lightDir   = normalize(lightPos - FragPos);
vec3 viewDir    = normalize(viewPos - FragPos);
vec3 halfwayDir = normalize(lightDir + viewDir);
```

### Gamma 校正

Gamma: 灰度系数.

感知亮度, 物理亮度. 感知亮度的变化是非线性均匀分布的.

显示器的亮度是电压的2.2次幂, 感知的亮度是电压的2次幂. 物理亮度是线性变化的(线性空间, Gamma1).

光照计算是在线性空间.

通过Gamma校正, 将显示器中的颜色变换到真实的颜色.

校正后的颜色: $(r,g,b)^{1/2.2}$, 显示器显示的颜色: $(r,g,b)^{2.2}$

显示设备的平均gamma值为 2.2

> 基于gamma2.2的颜色空间叫做sRGB颜色空间

> gamma校正将把线性颜色空间转变为非线性空间

sRGB纹理(已经Gamma校正)变换到线性空间: $(r,g,b)^{2.2}$

diffuse纹理(漫反射贴图), 基本上是 sRGB空间.

specular (镜面光)贴图, 法线贴图属于线性空间.

### 阴影映射

Shadow mapping

阴影贴图: 以光源为视点, 渲染场景的深度值到纹理. 又叫深度贴图(depth map)

阴影失真(Shadow Acne): 场景出现交替的黑线(有的片段既被认为在阴影中, 又被认为不在阴影中). 可使用阴影偏移解决.

另一种阴影失真: 悬浮(Peter Panning), 在渲染深度贴图的时候进行正面剔除.

shadow: 1, 有阴影; 0, 无阴影.

> 只要投影向量的z坐标大于1.0，我们就把shadow的值强制设为0.0

另一种阴影失真: 阴影的锯齿边

PCF(percentage-closer filtering): 对深度贴图进行多次采样, 柔和阴影.

### 点光源阴影

定向阴影映射, 深度（阴影）贴图生成自定向光的视角

万向阴影贴图（omnidirectional shadow maps）

深度立方体贴图

> 几何着色器有一个内建变量叫做gl_Layer，它指定发散出基本图形送到立方体贴图的哪个面

gl_FragDepth

### 法线贴图

Normal Mapping(Bump Mapping), 光照后, 表面增加凹凸感. 将法线向量保存为RGB值.

每个片段使用自己的法线.

[-1,1] => [0,1], xyz * 0.5 + 0.5 => rgb

[0,1] => [-1,1], rgb * 2.0 - 1.0 => xyz

切线空间, tangent space

> 法线贴图中的法线向量在切线空间中，法线永远指着正z方向

在切线空间中进行光照

TBN矩阵, T: tangent(切线, 右向量), B: Bitangent(副切线, 前向量), N: normal. 右手拇指指向T, 右手食指指向B, 右手中指指向N.

T(切线)沿着法线贴图的x轴方向(u), B(副切线)沿着法线贴图的y轴方向(v).

正交矩阵的转置矩阵与它的逆矩阵相同.

两种使用 TBN 的方式:

- 通过 TBN 矩阵, 将法线贴图中的法线向量变换到世界空间, 然后进行光照计算(需要对每个片段进行 TBN 变换)

- 通过 TBN 矩阵的逆矩阵, 将光照计算需要的向量变换到切线空间, 再进行光照计算(效率更好: 只在顶点着色器中进行 TBN 变换)

格拉姆-施密特正交化过程（Gram-Schmidt process）使 TBN 矩阵重新正交化.

```c
vec3 T = normalize(vec3(model * vec4(tangent, 0.0)));
vec3 N = normalize(vec3(model * vec4(normal, 0.0)));
// re-orthogonalize T with respect to N
T = normalize(T - dot(T, N) * N);
// then retrieve perpendicular vector B with the cross product of T and N
vec3 B = cross(T, N);

mat3 TBN = mat3(T, B, N)
```

### 视差贴图

Parallax Mapping, 属于位移贴图(Displacement Mapping)的一种. 根据观察方向和纹理数值对顶点进行偏移, 使物体表面看起来更高或更低.

在 切线空间 中使用视差贴图.

陡峭视差映射(Steep Parallax Mapping)

视差遮蔽映射(Parallax Occlusion Mapping)

### HDR

HDR(High Dynamic Range, 高动态范围), 通过更大的颜色值范围, 获取更多明亮和黑暗的场景细节, 再将颜色值映射到[0, 1]的范围显示出来.

LDR(Low Dynamic Range,低动态范围), 颜色值范围是[0, 1]

>HDR图片包含在不同曝光等级的细节

色调映射(Tone Mapping), 转换HDR值到LDR值得过程

浮点帧缓冲(Floating Point Framebuffer), 可以存储超过0.0到1.0范围的浮点值, GL_RGB16F, GL_RGBA16F, GL_RGB32F, GL_RGBA32F

色平衡(Stylistic Color Balance)

```
// Reinhard色调映射 片段着色器
void main()
{
    const float gamma = 2.2;
    vec3 hdrColor = texture(hdrBuffer, TexCoords).rgb;

    // Reinhard色调映射
    vec3 mapped = hdrColor / (hdrColor + vec3(1.0));
    // Gamma校正
    mapped = pow(mapped, vec3(1.0 / gamma));

    color = vec4(mapped, 1.0);
}
```

>在白天使用低曝光，在夜间使用高曝光

```
uniform float exposure;

void main()
{
    const float gamma = 2.2;
    vec3 hdrColor = texture(hdrBuffer, TexCoords).rgb;

    // 曝光色调映射
    vec3 mapped = vec3(1.0) - exp(-hdrColor * exposure);
    // Gamma校正
    mapped = pow(mapped, vec3(1.0 / gamma));

    color = vec4(mapped, 1.0);
}
```

自动曝光调整(Automatic Exposure Adjustment) / 人眼适应(Eye Adaptation)技术:

> 它能够检测前一帧场景的亮度并且缓慢调整曝光参数模仿人眼使得场景在黑暗区域逐渐变亮或者在明亮区域逐渐变暗

### 泛光

光晕效果

提取HDR颜色缓冲中超过一定亮度的片段, 对这些片段进行模糊处理, 再将经过模糊处理的片段添加到HDR纹理上.

MRT（Multiple Render Targets多渲染目标）

两步高斯模糊, 水平方向模糊一次, 再在垂直方向模糊一次.



### 延迟着色

延迟渲染(deferred shading) / 延迟渲染(deferred rendering)

分成两步: 先渲染一次场景, 将所有几何信息到 G 缓冲(G-Buffer)纹理, 然后再从 G 缓冲中提取几何信息进行其他后期计算(光照).

正向渲染(Forward Rendering) / 正向着色法(Forward Shading), 一个一个地渲染物体.

反射率 Albedo

> G缓冲(G-buffer)是对所有用来储存光照相关的数据，并在最后的光照处理阶段中使用的所有纹理的总称

多渲染目标, 一次渲染到多个纹理.

渲染更多光源的优化方法: 光体积, 延迟光照(Deferred Lighting), 切片式延迟着色法(Tile-based Deferred Shading)


### SSAO

环境光分量模拟光的散射(Scattering)

环境光遮蔽(Ambient Occlusion)

> 通过将褶皱、孔洞和非常靠近的墙面变暗的方法近似模拟出间接光照

屏幕空间环境光遮蔽(Screen-Space Ambient Occlusion, SSAO)

通过遮蔽因子(Occlusion Factor), 限制环境光分量.

法向半球体(Normal-oriented Hemisphere), 在法向半球附近采样

### PBR

基于物理的渲染(Physically Based Rendering), 更符合物理规律的模拟光线.

微平面(Microfacets)

> 微平面的取向方向与中间向量的方向越是一致，镜面反射的效果就越是强烈越是锐利.

反射 / 镜面 (reflection / specular)

折射 / 漫反射 (refraction / diffuse)

**反射率方程(The Reflectance Equation)**

辐射度量学(Radiometry), 度量电磁场辐射.

辐射度量量(radiometric quantity)

辐射率(Radiance), 量化单一方向上发射来的光线的大小或者强度. 在单位面积, 单位立体角上辐射出的总能量.

> 辐射率是辐射度量学上表示一个区域平面上光线总量的物理量.

**辐射率方程**

辐射通量(Radiant flux), 一个光源所输出的能量，以瓦特为单位. 能量看作关于光源包含的所有各种波长的函数, 波长与颜色相关.

立体角(Solid angle), 投射到单位球体上的一个截面的大小或者面积.

辐射强度(Radiant intensity), 在单位球面上, 一个光源向每单位立体角所投送的辐射通量.

用方向向量代替立体角, 点坐标(片段)代替面, 以使用辐射率方程来计算光线对片段的作用.

辐射照度/辐照度, Irradiance, 所有投射到片段上的光线的总和.

黎曼和(Riemann sum), 根据步长近似计算积分.

环境贴图

BRDF, 双向反射分布函数(Bidirectional Reflective Distribution Function), 基于表面材质属性来对入射辐射率进行缩放或者加权.

Cook-Torrance BRDF模型

Lambertian漫反射




### 文本渲染

纹理字体, Bitmap Font, 拥有所有字符的纹理. 这些字符叫字形(glyph).

FreeType, 加载字体的库, 用来加载 TrueType字体, 生成位图字体.

基准线, baseline, 渲染出的字体的基准线是在同一水平线上.

需要一些度量值生成位图字体: width, height, bearingX, bearingY, advance


## Snippet

### glm

```c
// 模型矩阵
// 4x4 单位矩阵
glm::mat4 model = glm::mat4(1.0f);

// 向x轴的正半轴移动1个单位
model = glm::translate(model, glm::vec3(1.0, 0, 0));

// 绕x轴正半轴逆时针旋转30度
model = glm::rotate(model, glm::radians(30.0), glm::vec3(1.0f, 0.0f, 0.0f));

// 缩放到原大小的20%
model = glm::scale(model, glm::vec3(0.2f));

// 透视投影矩阵
// fov: 视野, 弧度值
// aspect: 视口宽高比
// zNear: 近平面
// zFar: 远平面
glm::mat4 projection = glm::perspective(fovy, aspect, zNear, zFar);

// 视图矩阵
glm::vec3 position = glm::vec3(0.0f, 0.0f, 0.0f);
glm::vec3 up = glm::vec3(0.0f, 1.0f, 0.0f);
glm::vec3 Front = glm::vec3(0.0f, 0.0f, -1.0f);
glm::mat4 view = glm::lookAt(Position, Position + Front, Up);

// MVP 矩阵
glm::mat4 mvp = projection * view * model;

// 重组 xz 向量, 求这个向量的长度
float radius = glm::length(glm::vec2(position.xz));

```

---

### 传递 顶点数据 和 uniform 数据

```c
// 顶点着色器 vertex.vs
#version 330 core

layout (location = 0) in vec2 aPos;

void main()
{
    gl_Position = vec4(aPos, 0.0, 1.0);
}

```

```c
// 片段着色器 fragment.fs
#version 330 core

out vec4 FragColor;

uniform vec3 uColor;

void main()
{
    vec4 color = vec4(uColor, 1.0);
    FragColor = color;
}

```

```c
// 使用 VAO, VBO, EBO

unsigned int VAO, VBO, EBO;

// 顶点位置
/**
 * 0 ---- 1
 * |      |
 * |      |
 * 3 ---- 2
 */
float vertices[] = {
    -0.5, 0.5,
    0.5, 0.5,
    0.5, -0.5,
    -0.5, -0.5,
};

// 顶点索引(绘制顺序)
unsigned int indices[] = {
    0, 3, 2, 1
};

glGenVertexArrays(1, &VAO);
glGenBuffers(1, &VBO);
glGenBuffers(1, &EBO);

glBindVertexArray(VAO);

glBindBuffer(GL_ARRAY_BUFFER, VBO);
glBufferData(GL_ARRAY_BUFFER, sizeof(vertices), vertices, GL_STATIC_DRAW);

//               location              normalize   stride             offset
//                    |  component num     |        |                    |
//                    v    v               v        v                    v
glVertexAttribPointer(0,   2, GL_FLOAT, GL_FALSE, 2 * sizeof(float), (void*)0);
glEnableVertexAttribArray(0);

glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, EBO);
glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeof(indices), indices, GL_STATIC_DRAW);

// 传递数据给 uniform 属性
unsigned int shaderProgram; // 由 glCreateProgram() 返回的着色器程序对象
int uColor = glGetUniformLocation(shaderProgram, "uColor");
glUniform3f(uColor, 0.5, 0.6, 0.4);

// 绘制
glUseProgram(shaderProgram);
glBindVertexArray(VAO);
//                          count of vertex
//                              v
glDrawElements(GL_TRIANGLE_FAN, 4, GL_UNSIGNED_INT, 0);

// 释放
glDeleteVertexArrays(1, &VAO);
glDeleteBuffers(1, &VBO);
glDeleteBuffers(1, &EBO);
```

顶点的位置定义, 可以理解为在物体自身坐标系(本地坐标系/局部空间)下的位置. 先在本地坐标系设置好位置, 再通过 MVP 矩阵变换到裁剪空间.

---

### 纹理

```c
unsigned int texture0;

glGenTextures(1, &texture0);
glBindTexture(GL_TEXTURE_2D, texture0);

glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT);
glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT);

glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);

//                  颜色通道数
int width, height, nrChannels;
stbi_set_flip_vertically_on_load(true); // 翻转 y 轴方向
unsigned char *data = stbi_load(FileSystem::getPath("resources/textures/container.jpg").c_str(), &width, &height, &nrChannels, 0);

if (data) {
    //                     多级渐远纹理级别                填 0
    //                          |                         |
    //            纹理目标       v  纹理储存                 v  源图格式  存储源图的数据类型  源图数据
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGB, width, height, 0, GL_RGB, GL_UNSIGNED_BYTE, data);

    // 自动生成所有需要的多级渐远纹理
    glGenerateMipmap(GL_TEXTURE_2D);
} else {
    std::cout << "Failed to load texture" << std::endl;
}

stbi_image_free(data);

glActiveTexture(GL_TEXTURE0);

glUseProgram(shaderProgram);
glUniform1i(glGetUniformLocation(shaderProgram, "ourTexture"), 0); // 使用 GL_TEXTURE0

// ... 传递顶点坐标, 纹理坐标到顶点着色器

// 渲染前激活纹理目标
glActiveTexture(GL_TEXTURE0);
glBindTexture(GL_TEXTURE_2D, texture0);

// 渲染
// glDrawXXX

```

```c
// vertex.vs
#version 330 core
layout (location = 0) in vec3 aPos;
layout (location = 1) in vec2 aTexCoord;

out vec2 TexCoord;

void main()
{
    gl_Position = vec4(aPos, 1.0);
    TexCoord = aTexCoord;
}
```

```c
// fragment.fs
#version 330 core
out vec4 FragColor;

in vec2 TexCoord; // 纹理坐标

uniform sampler2D ourTexture;

void main()
{
    FragColor = texture(ourTexture, TexCoord);
}
```

---

### 深度测试

```c
// 开启深度测试
glEnable(GL_DEPTH_TEST);

// 清除深度缓冲
glClearColor(0.0, 0.0, 0.0, 1.0);
glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
```

---

### 帧缓冲

```c
// framebuffer
glGenFramebuffers(1, &framebuffer);
glBindFramebuffer(GL_FRAMEBUFFER, framebuffer);

glGenTextures(1, &textureColorbuffer);
glBindTexture(GL_TEXTURE_2D, textureColorbuffer);
glTexImage2D(GL_TEXTURE_2D, 0, GL_RGB, SCR_WIDTH, SCR_HEIGHT, 0, GL_RGB, GL_UNSIGNED_BYTE, NULL);
glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_TEXTURE_2D, textureColorbuffer, 0);

// render buffer
unsigned int rbo;
glGenRenderbuffers(1, &rbo);
glBindRenderbuffer(GL_RENDERBUFFER, rbo);
glRenderbufferStorage(GL_RENDERBUFFER, GL_DEPTH24_STENCIL8, SCR_WIDTH, SCR_HEIGHT);
glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_DEPTH_STENCIL_ATTACHMENT, GL_RENDERBUFFER, rbo);

if (glCheckFramebufferStatus(GL_FRAMEBUFFER) != GL_FRAMEBUFFER_COMPLETE)
    std::cout << "ERROR::FRAMEBUFFER:: Framebuffer is not complete!" << std::endl;

glBindFramebuffer(GL_FRAMEBUFFER, 0);


// 使用 framebuffer 渲染场景到纹理
glBindFramebuffer(GL_FRAMEBUFFER, framebuffer);

// render scene to framebuffer
render();

// 恢复到默认的帧缓冲
glBindFramebuffer(GL_FRAMEBUFFER, 0);

// render scene to default frame
render();

// 绑定 framebuffer 生成的纹理
glActiveTexture(GL_TEXTURE0);
glBindTexture(GL_TEXTURE_2D, textureColorbuffer);

// 渲染 framebuffer 生成的纹理
renderQuad();
```

---

### GL内置函数

```c
// todo
```

---

### 材质与光源

```c
// 材质
struct Material {
    vec3 ambient;    // 在环境光照下物体反射的颜色, 设置为物体颜色
    vec3 diffuse;    // 在漫反射光照下物体的颜色, 设置为物体颜色
    vec3 specular;   // 镜面光照对物体的颜色影响
    float shininess; // 反光度, 镜面高光的散射/半径
};

// 光源
struct Light {
    vec3 position; // 位置
    vec3 ambient;  // 环境光分量, 设置为较低的强度
    vec3 diffuse;  // 漫反射分量, 设置为光所具有的颜色
    vec3 specular; // 镜面光分量, 通常设置为最大强度, vec3(1.0)
};


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


```

---

### 效果

#### 反相

```c
// fragment.fs
out vec4 FragColor;

vec3 invertColor(const vec3 color)
{
    return vec3(1.0 - color.r, 1.0 - color.g, 1.0 - color.b);
}

FragColor.rgb = invertColor(FragColor.rgb);
```

---

#### 灰度

```c
vec3 grayColor(const vec3 color)
{
	float average = 0.2126 * color.r + 0.7152 * color.g + 0.0722 * color.b; // 加权灰度效果
	return vec3(average);
}

FragColor.rgb = grayColor(FragColor.rgb);
```

---

#### 核效果(卷积矩阵)

```c
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
        1.0,  -8, 1.0,
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

FragColor.rgb = kernelEffect(texture0, texCoord);
```

