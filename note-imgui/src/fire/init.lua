
local fire = {}

require("fire.helper")
MatMap = require("fire.matMap")
matUtil = require("fire.matUtil")
createMatTestView = require("fire.matTestView")
FireAction = require("fire.action")
local main = require("fire.main")
local createShaderTestView = require("fire.shaderTestView")

fire.createShaderTestView = createShaderTestView

rawset(_G, "fire", fire)

return main