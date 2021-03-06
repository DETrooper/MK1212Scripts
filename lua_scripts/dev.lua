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

	for i = 1, #achievement_key_list do
		achievementFile:write(cipherAchievement(achievement_key_list[i].."=0-n.d.").."\n");
	end
	
	achievementFile:close();
end

function changeAchievement(filepath, achievement_key, value, date)
	local achievements = readAchievements(modName.."achievements");
	local achievement_found = false;

	achievementFile = io.open(filepath, "w");

	for k, v in pairs(achievements) do
		if k ~= achievement_key then
			achievementFile:write(cipherAchievement(k.."="..v[1].."-"..v[2]).."\n");
		else
			achievementFile:write(cipherAchievement(achievement_key.."="..tostring(value).."-"..date).."\n");

			achievement_found = true;
		end
	end

	if achievement_found == false then
		-- Achievement does not exist in file, write it.
		achievementFile:write(cipherAchievement(achievement_key.."="..tostring(value).."-"..date).."\n");
	end

	achievementFile:close();
end

function readAchievements(filepath)
	local achievementFile = io.open(filepath, "r");
	local achievementTable = {};

	for line in achievementFile:lines() do
		local decipheredLine = decipherAchievement(line);

		achievement, value, date = string.match(decipheredLine, "(.+)=(.+)-(.+)");

		if achievement and value and date then -- Ignore invalid matches
			achievementTable[achievement] = {value, date};
		end
	end

	achievementFile:close();

	return achievementTable;
end

-- This is really simple but if anyone is smart enough to break it they can probably also just edit the scripts to unlock the achievements anyways.
function cipherAchievement(string)
	local achievement_string = "";

	for i = 1, #string do
		local char = string:sub(i, i);
		local byte = string.byte(char) + 7;

		if i == #string then
			achievement_string = achievement_string..tostring(byte);
		else
			achievement_string = achievement_string..tostring(byte).." ";
		end
	end

	return achievement_string;
end

function decipherAchievement(string)
	local achievement_string = "";
	local whitespace = 0;

	for i = 1, #string do
		whitespace = whitespace + 1;

		if string:sub(i, i) == " " then
			local byte = tonumber(string:sub(i - (whitespace - 1), i - 1)) - 7;
			local char = string.char(byte);

			achievement_string = achievement_string..char;
			whitespace = 0;
		elseif i == #string then
			local byte = tonumber(string:sub(i - whitespace, i)) - 7;
			local char = string.char(byte);

			achievement_string = achievement_string..char;
			whitespace = 0;
		end
	end

	return achievement_string;
end

-- Settings stuff
function writeSettings(filepath)
	local settingsFile = io.open(filepath, "w");
	
	-- Set up all settings with default parameters
	settingsFile:write("#Autogenerated by MK1212\n\n");
	settingsFile:write("changelogNumber = 0\n");
	settingsFile:write("disclaimerAccepted = 0\n");
	settingsFile:close();
end

function changeSetting(filepath, setting, value)
	local changelogNumber = tonumber(settings["changelogNumber"]);
	local disclaimerAccepted = tonumber(settings["disclaimerAccepted"]);

	if setting == "changelogNumber" then
		changelogNumber = value;
	elseif setting == "disclaimerAccepted" then
		disclaimerAccepted = value;
	end

	settingsFile = io.open(filepath, "w");
	settingsFile:write("#Autogenerated by MK1212\n\n");
	settingsFile:write("changelogNumber = "..tostring(changelogNumber).."\n");
	settingsFile:write("disclaimerAccepted = "..tostring(disclaimerAccepted).."\n");
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
