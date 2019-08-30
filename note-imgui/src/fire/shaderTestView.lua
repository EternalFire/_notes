
local MVP_Vert = [[
    attribute vec4 a_position;  
    attribute vec2 a_texCoord; 
    attribute vec4 a_color;
    #ifdef GL_ES   
      varying lowp vec4 v_fragmentColor; 
      varying mediump vec2 v_texCoord; 
    #else					  
      varying vec4 v_fragmentColor;  
      varying vec2 v_texCoord;   
    #endif   
    void main()  
    { 
      gl_Position = CC_PMatrix * a_position;  
      v_fragmentColor = a_color; 
      v_texCoord = a_texCoord; 
    }
]]

-- 变白
local WhiteFrag = [[
	#ifdef GL_ES
		precision mediump float;
	#endif
	varying vec4 v_fragmentColor;
	varying vec2 v_texCoord;
	void main(void)
	{
	    vec4 c = texture2D(CC_Texture0, v_texCoord);
	    gl_FragColor.r = c.a*(%f * 0.01+c.r*(1.0-0.01));
	    gl_FragColor.g = c.a*(%f * 0.01+c.g*(1.0-0.01));
	    gl_FragColor.b = c.a*(%f * 0.01+c.b*(1.0-0.01));
	    gl_FragColor.a = c.a;
	}
]]

-- 变红
local RedFrag = [[
	#ifdef GL_ES
		precision mediump float;
	#endif
	varying vec4 v_fragmentColor;
	varying vec2 v_texCoord;
	void main(void)
	{
	    vec4 c = texture2D(CC_Texture0, v_texCoord);
	    gl_FragColor.r = c.a*(60.0*0.01+c.r*(1.0-0.01));
	    gl_FragColor.g = c.a*(0.0*0.01+c.g*(1.0-0.01));
	    gl_FragColor.b = c.a*(0.0*0.01+c.b*(1.0-0.01));
	    gl_FragColor.a = c.a;
	}
]]

local gaussianBlurSource = [[
	#ifdef GL_ES
	  precision mediump float;
	#endif
	varying vec4 v_fragmentColor;
	varying vec2 v_texCoord; 

	int _BlurRadius;
	int x;
	int y;
	float spaceX;
	float spaceY;
	int count;  
	void main() {

		_BlurRadius = 2;
		spaceX =  (1.0/%.02f) * 1.5;
		spaceY =  (1.0/%.02f) * 1.5;
		count = _BlurRadius * 2 + 1; 
		count *= count;

		vec4 colorTmp = vec4(0, 0, 0, 0);
		for( x = -_BlurRadius ; x <= _BlurRadius ; x++ )
		{
			for( y = -_BlurRadius ; y <= _BlurRadius ; y++ )
			{
				vec4 color = texture2D(CC_Texture0, v_texCoord + vec2(float(x) * spaceX, float(y) * spaceY));
				colorTmp += color;
			}
		}
	  
		
		gl_FragColor = colorTmp / float(count) ;
	} 

]]

local snowSource = [[
		  #ifdef GL_ES
		  precision mediump float;
		  #endif
		  vec4 frameTex;

		  varying vec4 v_fragmentColor;
		  varying vec2 v_texCoord; 
		  // image's size
		  uniform vec2 v_texSize;
		  uniform float count; // 0.3

		  void main()
		  {
			frameTex = texture2D(CC_Texture0, v_texCoord);
			vec2 onePixel = vec2(1.0 / v_texSize.r, 1.0 / v_texSize.g);

			vec4 color;
			color.rgb = vec3(0.0); 
			/*
			color += texture2D(CC_Texture0, v_texCoord - onePixel) * 1.0;
			color -= texture2D(CC_Texture0, v_texCoord + onePixel) * 1.0;
			*/
			color += texture2D(CC_Texture0, v_texCoord - vec2(0, 1.0 / v_texSize.g) );
			color -= texture2D(CC_Texture0, v_texCoord + vec2(0, 1.0 / v_texSize.g) * 5.0);

			color.rgb = vec3((color.r + color.g + color.b) / 3.0);
			if ( (color.r + color.g + color.b) > count && 0.1 < count){ 
			  //gl_FragColor = vec4(frameTex.r * 2.3, frameTex.g * 2.3, frameTex.b * 2.3, frameTex.a);
			  gl_FragColor = vec4(255, 255, 255, frameTex.a);
			}else{
			  gl_FragColor = v_fragmentColor * frameTex;
			}
		  }
	]]

local waterSource = [[
	varying vec2 v_texCoord;
	varying vec4 v_fragmentColor;

	#ifdef GL_ES
	precision mediump float;
	#endif

	uniform sampler2D tex0;
	uniform float time;
	uniform vec2 resolution;

	const float PI = 3.1415926535897932;
	const float speed = 0.02; // 0.2  
	const float speed_x = 0.03;  //0.3
	const float speed_y = 0.03;  // 0.3
	const float intensity = 3.0;  
	const int steps = 24;  
	const float frequency = 4.0;  
	const int angle = 7;//7
	const float delta = 80.0;  //20.0
	const float intence = 400.0;
	const float emboss = 0.03;
	
	float col(vec2 coord)  
	{  
		float delta_theta = 2.0 * PI / float(angle);  
		float col = 0.0;  
		float theta = 0.0;  
		for (int i = 0; i < steps; ++i)
		{
			vec2 adjc = coord;
			theta = delta_theta * float(i);
			adjc.x += cos(theta) * time * speed + time * speed_x;
			adjc.y -= sin(theta) * time * speed - time * speed_y;
			col = col + cos( (adjc.x * cos(theta) - adjc.y*sin(theta) ) * frequency) * intensity;  
		}
		return cos(col);
	}  

	void main(void)  
	{  
		//vec2 p = (gl_FragCoord.xy) / resolution.xy, c1 = p, c2 = p;  //翻转， 例如水中的镜像
		vec2 p = v_texCoord, c1 = p, c2 = p;
		float cc1 = col(c1);  
	 
		c2.x += resolution.x / delta;  
		float dx = emboss * (cc1 - col(c2)) / delta;  
	 
		c2.x = p.x;  
		c2.y += resolution.y / delta;  
		float dy = emboss * (cc1 - col(c2) ) / delta;  
	 
		c1.x += dx;  
		c1.y += dy;  
		float alpha = 1.0 + dot(dx, dy) * intence;
		gl_FragColor = texture2D(CC_Texture0, c1) * (alpha) * v_fragmentColor * (alpha);
		//gl_FragColor = texture2D(CC_Texture0, v_texCoord);
	}

]]

local magnifierSource = [[
	varying vec2 v_texCoord;
	varying vec4 v_fragmentColor;

	#ifdef GL_ES
	precision mediump float;
	#endif
  
	uniform vec2 resolution; 


	uniform vec2  in_circle_pos;//从客户端传入的放大镜圆心位置
	uniform float in_circle_radius;//从客户端传入的放大镜圆半径
	uniform float in_zoom_times;//从客户端传入的放大镜放大倍数

 

	uniform sampler2D textureSampler;//从客户端传入的采样器ID

	vec2 transForTexPosition(vec2 pos)
	{
		return vec2( float(pos.x) / float(resolution.x), float(pos.y) / float(resolution.y) );
	}

	float getDistance(vec2 pos_src, vec2 pos_dist)
	{
		float quadratic_sum = pow((pos_src.x - pos_dist.x), 2.0) + pow((pos_src.y - pos_dist.y), 2.0);
		return sqrt(quadratic_sum);
	}

	vec2 getZoomPosition()
	{
		float zoom_x =  float(gl_FragCoord.x - in_circle_pos.x) / in_zoom_times ;
		float zoom_y =  float(gl_FragCoord.y - in_circle_pos.y) / in_zoom_times ;
        
		return vec2( float(in_circle_pos.x) + zoom_x, float(in_circle_pos.y) - zoom_y);
	}

	vec4 getColor()//双线性插值采样
	{
		vec2 pos = getZoomPosition();

		float _x = floor(pos.x);
		float _y = floor(pos.y);

		float u = pos.x - _x;
		float v = pos.y - _y;

		vec4 data_00 = texture2D(CC_Texture0, transForTexPosition(vec2(_x, _y)));
		vec4 data_01 = texture2D(CC_Texture0, transForTexPosition(vec2(_x, _y + 1.0)));
		vec4 data_10 = texture2D(CC_Texture0, transForTexPosition(vec2(_x + 1.0, _y)));
		vec4 data_11 = texture2D(CC_Texture0, transForTexPosition(vec2(_x + 1.0, _y + 1.0)));

		return (1.0 - u) * (1.0 - v) * data_00 + (1.0 - u) * v * data_01 + u * (1.0 - v) * data_10 + u * v * data_11;
	}

    //CC_Texture0, v_texCoord
	void main()
	{
		vec2 frag_pos = vec2(gl_FragCoord.x, gl_FragCoord.y);
		//若当前片段位置距放大镜圆心距离大于圆半径时，直接从纹理中采样输出片段颜色
		if (getDistance(in_circle_pos, frag_pos) > in_circle_radius ){
			gl_FragColor = texture2D(CC_Texture0, v_texCoord);
        }else{ //距离小于半径的片段，二次线性插值获得颜色。
			gl_FragColor = getColor();
        }
	}

]]

local SFShader = {}
SFShader._cached = {}
local function _createProgramState(fragStr, ...)
	if 0 < #{...} then
		fragStr = string.format(fragStr, ...)
	end
	local cached = SFShader._cached[fragStr]
	if nil ~= cached then
		return unpack(cached)
	end
	local glProgram = cc.GLProgram:createWithByteArrays(MVP_Vert, fragStr) 
	local glProgramState = cc.GLProgramState:getOrCreateWithGLProgram(glProgram)  
	SFShader._cached[fragStr] = {glProgramState, glProgram}
	return glProgramState, glProgram
end

-- 变白
function SFShader.getWhiteGLProgramState(value)	
	local glProgramState, glProgram = _createProgramState(WhiteFrag, value, value, value)
	return glProgramState, glProgram
end

-- 变红
function SFShader.getRedGLProgramState()
	return _createProgramState(RedFrag)
end

-- 高斯模糊
function SFShader.getGaussianBlurProgramState(picSize)
	return _createProgramState(gaussianBlurSource, picSize.width, picSize.height)
end

--[[
  积雪效果
  @picSize:
]]
function SFShader.getSnowProgramState(picSize)
	local glProgramState, glProgram = _createProgramState(snowSource) 
	SFShader._cached[snowSource] = nil
	local texSize_location = gl.getUniformLocation(glProgram:getProgram(), "v_texSize")
	glProgramState:setUniformVec2(texSize_location, cc.p(picSize.width, picSize.height))

	local uniform_count = gl.getUniformLocation(glProgram:getProgram(), "count")
	local function setValue(snowCount) 
		glProgramState:setUniformFloat(uniform_count, snowCount)
	end
	setValue(100)
	return glProgramState, glProgram, setValue
end


--[[
  水波效果， 可以改参数作为旗帜飘动效果
  @picSize:
  返回中 带有 scheduleUpdate 时需要调用的方法
]]
function SFShader.getWaterProgramState(picSize)
	local glProgramState, glProgram = _createProgramState(waterSource)
	local m_resolution = cc.size(picSize.width, picSize.height)

	local uniform_resolution = gl.getUniformLocation(glProgram:getProgram(), "resolution")
	local uniform_time = gl.getUniformLocation(glProgram:getProgram(), "time")
	glProgramState:setUniformVec2(uniform_resolution, cc.p(m_resolution.width, m_resolution.height ) )

	local m_time = 0
	local function scheduleUpdate(dt)
	  m_time = m_time + dt
	  --传递uniform变量
	  
	  glProgramState:setUniformFloat(uniform_time, m_time)

	end

	return glProgramState, glProgram, scheduleUpdate
end

--[[
    放大镜效果
    @picSize:
]]
function SFShader.getMagnifierProgramState(picSize, circleRadius, scale)
	local glProgramState, glProgram = _createProgramState(magnifierSource)
	local m_resolution = cc.size(picSize.width, picSize.height)
    local _program = glProgram:getProgram()

	local uniform_resolution = gl.getUniformLocation(_program, "resolution")
	local uniform_time      = gl.getUniformLocation(_program, "time")
    local in_circle_pos     = gl.getUniformLocation(_program, "in_circle_pos")--从客户端传入的放大镜圆心位置
    local in_circle_radius  = gl.getUniformLocation(_program, "in_circle_radius")--从客户端传入的放大镜圆半径
    local in_zoom_times     = gl.getUniformLocation(_program, "in_zoom_times")--从客户端传入的放大镜放大倍数

	glProgramState:setUniformVec2(uniform_resolution, cc.p(m_resolution.width, m_resolution.height ) )

    glProgramState:setUniformFloat(in_circle_radius, circleRadius)
    glProgramState:setUniformFloat(in_zoom_times, scale)

 
	local function scheduleUpdate(dt, scalePos) 
	  --传递uniform变量 

        glProgramState:setUniformVec2(in_circle_pos, scalePos )
	end

	return glProgramState, glProgram, scheduleUpdate
end

local function createShaderTestView()
    local target = State.bgSprite
    -- local target = State.scene
    -- local target = State.emitter
    local size = target:getContentSize()
    local glProgramState
    -- local glProgramState = SFShader.getRedGLProgramState()
    -- local glProgramState = SFShader.getSnowProgramState(size)
    -- local glProgramState = SFShader.getGaussianBlurProgramState(size)
    -- local glProgramState = SFShader.getWhiteGLProgramState(50)
    local glProgramState, glProgram, scheduleUpdate = SFShader.getWaterProgramState(size)
    -- local glProgramState, glProgram, scheduleUpdate2 = SFShader.getMagnifierProgramState(size, 100, 2)
    
    if glProgramState then
        target:setGLProgramState(glProgramState)
    end

    if scheduleUpdate then
        target:onUpdate(scheduleUpdate)
    end

    if scheduleUpdate2 then
        target:onUpdate(function(dt)
            local p = target:convertToNodeSpace(State.touchLocation)
            scheduleUpdate2(dt, p)
        end)
    end
end

return createShaderTestView