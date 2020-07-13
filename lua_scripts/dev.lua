-- Originally created by R2TR development team.
-- Free to be used, under the conditions that:
-- 	1. If this file has been modified, any significant changes must be stated
-- 	2. This file header is included in all derivatives

-- Modified by DETrooper for MK1212 for supporting an achievements file and a toggle for logging.

-- dev.lua
-- handles developer debug logging, R2TR settings etc

-- General
module(..., package.seeall)
_G.main_env = getfenv(1) -- Probably not needed in most places

-- Includes
local util = require "lua_scripts.util"

-- Handle R2TR folder filepaths or file prefacing
-- Lua has no in-built concept of file-systems, and external non-pure lua libraries cannot be included due to this being run inside Rome 2, so os.execute must be used to create folders
local fileMethod = "preface"; -- Uses preface method because os.execute call to create folders pulls focus from game, causing issues in fullscreen.
local modName = "MK1212";
local loggingEnabled = false;

if fileMethod == "preface" then
	modName = modName .. "_" -- Add file preface separator: instead of "R2TRlog.txt", it's "R2TR_log.txt"
elseif fileMethod == "foldered" then
	os.execute("IF NOT EXIST " .. modName .. " ( mkdir " .. modName .. " )");
	modName = modName .. "\\" -- Add directory separator.
	-- TODO: Figure out how to stop command line window appearing, make multi-platform
end

-- Achievements stuff
function writeAchievements(filepath, achievement_key_list)
	local achievementFile = io.open(filepath, "w");
	
	-- Set up all achievements to default to 0 (locked state).
	achievementFile:write("#Autogenerated by MK1212\n");
	achievementFile:write("#If you modify these manually I will be very sad :(\n\n");

	for i = 1, #achievement_key_list do
		achievementFile:write(achievement_key_list[i].." = 0 - n.d.\n");
	end
	
	achievementFile:close();
end

function changeAchievement(filepath, achievement_key, value, date)
	local achievements = readAchievements(modName.."achievements.txt");

	achievementFile = io.open(filepath, "w");
	achievementFile:write("#Autogenerated by MK1212\n");
	achievementFile:write("#If you modify these manually I will be very sad :(\n\n");

	for k, v in pairs(achievements) do
		if k ~= achievement_key then
			achievementFile:write(k.." = "..v[1].." - "..v[2].."\n");
		else
			achievementFile:write(achievement_key.." = "..tostring(value).." - "..date.."\n");
		end
	end

	achievementFile:close();
end

function readAchievements(filepath)
	local achievementFile = io.open(filepath, "r");
	local achievementTable = {};

	for line in achievementFile:lines() do
		formattedLine = string.gsub(line, "%s", ""); -- Strip whitespace
		formattedLine = string.match(formattedLine, "([^#]*)"); -- Cut away everything after # comment delimiter

		if formattedLine then
			achievement, value, date = string.match(formattedLine, "(.+)=(.+)-(.+)");

			if achievement and value and date then -- Ignore invalid matches
				achievementTable[achievement] = {value, date};
			end
		end
	end

	achievementFile:close();

	return achievementTable;
end

-- Settings stuff
function writeSettings(filepath)
	local settingsFile = io.open(filepath, "w");
	
	-- Set up all settings with default parameters
	settingsFile:write("#Autogenerated by MK1212\n\n");
	settingsFile:write("changelogNumber = 0\n");
	settingsFile:close();
end

function changeSetting(filepath, setting, value)
	local changelogNumber = tonumber(settings["changelogNumber"]);

	if setting == "changelogNumber" then
		changelogNumber = value;
	end

	settingsFile = io.open(filepath, "w");
	settingsFile:write("#Autogenerated by MK1212\n\n");
	settingsFile:write("changelogNumber = "..tostring(changelogNumber).."\n");
	settingsFile:close();

	settings = readSettings(modName.."config.txt");
end

function readSettings(filepath)
	local settingsFile = io.open(filepath, "r");
	local settingsTable = {};

	for line in settingsFile:lines() do
		formattedLine = string.gsub(line, "%s", ""); -- Strip whitespace
		formattedLine = string.match(formattedLine, "([^#]*)"); -- Cut away everything after # comment delimiter

		if formattedLine  then
			setting, value = string.match(formattedLine, "(.+)=(.+)");

			if setting  and value  then -- Ignore invalid matches
				settingsTable[setting] = value;	-- Note that everything here is stored as a string. Use tonumber() when applicable.
			end
		end
	end

	settingsFile:close();

	return settingsTable;
end

-- Logging functions
function log(text) -- TODO: Time/Data, extra formatting, etc
	local logfile;

	if not util.fileExists(modName .. "log.txt") then
		logfile = io.open(modName .. "log.txt", "w");
		logfile:write("Log file does not exist, created new\n");
	else
		logfile = io.open(modName .. "log.txt", "a");
	end

	if loggingEnabled == true then
		text = tostring(text);
		logfile:write(text .. "\n");
		logfile:close();
	end
end 

if not util.fileExists(modName .. "config.txt") then
	writeSettings(modName .. "config.txt");
end

settings = readSettings(modName .. "config.txt");

-- Logging
log("\ndev.lua loaded");
