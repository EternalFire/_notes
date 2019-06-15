#pragma once
#include "GLSLANG/ShaderLang.h"
#include <assert.h>
#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sstream>
#include <vector>
#include <map>
#include "angle_gl.h"

namespace _Sh_ {

	typedef unsigned int VarType; // GL_FLOAT, GL_INT, GL_FLOAT_VEC2, GL_FLOAT_VEC3, ... 

	struct StUniform {
		VarType type;
		std::string name;
	};

	typedef std::vector<struct StUniform> UniformArray;
	typedef std::map<std::string, UniformArray > UniformTable;

	const UniformTable& getVSUniform();
	const UniformTable& getFSUniform();

	void init();

	void clear();

	void addVsUniform(const std::string& shaderName, VarType type, const std::string& name);

	void addFsUniform(const std::string& shaderName, VarType type, const std::string& name);
}

int run(int argc, char* argv[]);
