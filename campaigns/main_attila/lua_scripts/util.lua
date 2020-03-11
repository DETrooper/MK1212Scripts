-- Originally created by R2TR development team.
-- Free to be used, under the conditions that:
-- 	1. If this file has been modified, any significant changes must be stated
-- 	2. This file header is included in all derivatives

-- util.lua
-- Handles utility functions, wrapper functions etc

-- General
module(..., package.seeall)
_G.main_env = getfenv(1) -- Probably not needed in most places

-- Includes
local scripting = require "lua_scripts.EpisodicScripting"

-- IO stuff
function fileExists(filepath)
	local fileCheck = io.open(filepath, "r")
	
	if not fileCheck then 
		fileCheck = false
	else 
		fileCheck:close()
		fileCheck = true
	end
	
	return fileCheck
end