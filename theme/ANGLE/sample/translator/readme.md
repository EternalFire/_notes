
- [环境](#%E7%8E%AF%E5%A2%83)
- [编译 ANGLE Demo](#%E7%BC%96%E8%AF%91-angle-demo)
- [PlayProject1](#playproject1)

## 环境

- [ANGLE](https://github.com/google/angle), 需要用到里面的解析shader的模块.

- [depot_tools](http://dev.chromium.org/developers/how-tos/depottools), 用于构建 ANGLE.

- [Windows SDK](https://developer.microsoft.com/en-us/windows/downloads/windows-10-sdk), 需要用到 debug 功能.

- Visual Studio 2019

**目的: 移植 ANGLE 里面的 angle_shader_translator 程序到 VS .**

---

## 编译 ANGLE Demo

depot_tools 目录添加到环境变量中, 以便访问 `gn`, `gclient`, `ninja`

`gn`生成 .ninja 文件, 用于构建 chromium 项目.

`gclient`, 用于管理 chromium 项目的源码.

克隆项目后, 需要先运行:

```
python scripts/bootstrap.py
gclient sync
```

构建需要用 python 2.7. 需要安装 pywin32 模块(`pip install pywin32`), 否则可能会遇到"No module named win32file" 问题.


构建前需要修改 `vs_toolchain.py`, 设置 VS 的版本:

```
CURRENT_DEFAULT_TOOLCHAIN_VERSION = '2019'
```

运行 `gn gen out/Debug --sln=angle-debug --ide=vs2019`, 生成工程文件.


ANGLE 目前只能解析 OpenGL ES 3.0 及以下, WebGL 2.0及以下的版本.

---

## PlayProject1

这是移植 angle_shader_translator 到 VS 后的项目.

使用 Visual Studio 2019 编译 x64 版本(没有尝试x86版本).

Windows SDK 版本是 "10.0.18362.0".

common 项目先编译, 它生成的 common.lib 是 PlayProject1 需要的静态库.

PlayProject1.exe 是编译好的release版本. vertex.vert 是用于测试的顶点着色器.

测试:

`PlayProject1.exe -i -s=e3 vertex.vert`

输出:

```
#### BEGIN COMPILER 0 INFO LOG ####
0:2: Code block
0:4:   Declaration
0:4:     'aPos' (symbol id 1027) (in mediump 3-component vector of float)
0:5:   Declaration
0:5:     'aColor' (symbol id 1028) (in mediump 3-component vector of float)
0:6:   Declaration
0:6:     'aTexCoord' (symbol id 1029) (in mediump 2-component vector of float)
0:7:   Declaration
0:7:     'aNormal' (symbol id 1030) (in mediump 3-component vector of float)
0:9:   Declaration
0:9:     'vertexColor' (symbol id 1031) (out mediump 3-component vector of float)
0:10:   Declaration
0:10:     'texCoord' (symbol id 1032) (out mediump 2-component vector of float)
0:11:   Declaration
0:11:     'vsNormal' (symbol id 1033) (out mediump 3-component vector of float)
0:12:   Declaration
0:12:     'vsFragPos' (symbol id 1034) (out mediump 3-component vector of float)
0:14:   Declaration
0:14:     'mvp' (symbol id 1035) (uniform mediump 4X4 matrix of float)
0:15:   Declaration
0:15:     'uMat4Model' (symbol id 1036) (uniform mediump 4X4 matrix of float)
0:16:   Declaration
0:16:     'uNormalMatrix' (symbol id 1037) (uniform mediump 3X3 matrix of float)
0:18:   Function Definition:
0:18:     Function Prototype: main (symbol id 1038) (void)
0:19:     Code block
0:20:       Declaration
0:20:         initialize first child with second child (mediump 4-component vector of float)
0:20:           'p' (symbol id 1039) (mediump 4-component vector of float)
0:20:           Construct (mediump 4-component vector of float)
0:20:             'aPos' (symbol id 1027) (in mediump 3-component vector of float)
0:20:             1.0 (const float)
0:21:       move second child to first child (highp 4-component vector of float)
0:21:         'gl_Position' (symbol id 1002) (Position highp 4-component vector of float)
0:21:         matrix-times-vector (mediump 4-component vector of float)
0:21:           'mvp' (symbol id 1035) (uniform mediump 4X4 matrix of float)
0:21:           'p' (symbol id 1039) (mediump 4-component vector of float)
0:22:       move second child to first child (mediump 3-component vector of float)
0:22:         'vertexColor' (symbol id 1031) (out mediump 3-component vector of float)
0:22:         'aColor' (symbol id 1028) (in mediump 3-component vector of float)
0:23:       move second child to first child (mediump 2-component vector of float)
0:23:         'texCoord' (symbol id 1032) (out mediump 2-component vector of float)
0:23:         'aTexCoord' (symbol id 1029) (in mediump 2-component vector of float)
0:24:       move second child to first child (mediump 3-component vector of float)
0:24:         'vsNormal' (symbol id 1033) (out mediump 3-component vector of float)
0:24:         matrix-times-vector (mediump 3-component vector of float)
0:24:           'uNormalMatrix' (symbol id 1037) (uniform mediump 3X3 matrix of float)
0:24:           'aNormal' (symbol id 1030) (in mediump 3-component vector of float)
0:25:       move second child to first child (mediump 3-component vector of float)
0:25:         'vsFragPos' (symbol id 1034) (out mediump 3-component vector of float)
0:25:         Construct (mediump 3-component vector of float)
0:25:           matrix-times-vector (mediump 4-component vector of float)
0:25:             'uMat4Model' (symbol id 1036) (uniform mediump 4X4 matrix of float)
0:25:             'p' (symbol id 1039) (mediump 4-component vector of float)

#### END COMPILER 0 INFO LOG ####

```