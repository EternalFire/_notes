
local fire = {}

require("fire.helper")
MatMap = require("fire.matMap")
matUtil = require("fire.matUtil")
createMatTestView = require("fire.matTestView")
FireAction = require("fire.action")
local main = require("fire.main")
local createShaderTestView = require("fire.shaderTestView")
local testSocket, breakConnect = unpack(require("fire.testSocket"))
local init_flow_ = require("fire.test_flow_")
local test_ui = require("fire.test_ui")

fire.createShaderTestView = createShaderTestView
fire.testSocket = testSocket
fire.breakConnect = breakConnect
fire.init_flow_ = init_flow_
fire.test_ui = test_ui

rawset(_G, "fire", fire)

return main
