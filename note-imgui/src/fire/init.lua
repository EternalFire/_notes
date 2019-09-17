
local fire = {}

require("fire.helper")
MatMap = require("fire.matMap")
matUtil = require("fire.matUtil")
createMatTestView = require("fire.matTestView")
FireAction = require("fire.action")
local main = require("fire.main")
local createShaderTestView = require("fire.shaderTestView")
local testSocket, breakConnect = unpack(require("fire.testSocket"))

fire.createShaderTestView = createShaderTestView
fire.testSocket = testSocket
fire.breakConnect = breakConnect

rawset(_G, "fire", fire)

return main