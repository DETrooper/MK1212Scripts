-- Originally created by R2TR development team.
-- Free to be used, under the conditions that:
-- 	1. If this file has been modified, any significant changes must be stated
-- 	2. This file header is included in all derivatives

-- DETrooper Changes: Added camera position loggers for campaign and HBs.

-- logging_callbacks.lua
-- Handles all the logging of event callbacks

-- General
module(..., package.seeall)
_G.main_env = getfenv(1) -- Probably not needed in most places
require("lib_common");

-- Includes
local dev = require "lua_scripts.dev"
local scripting = require "lua_scripts.episodicscripting"

-- Callbacks
-- Each logging level stacks: level 3 includes level 2 and level 1 callbacks.
function characterDebugInfo(context)
	local character = context:character()
	dev.log("Character info:")
	dev.log("\tCQI: " .. character:cqi())
	dev.log("\tName: " .. character:get_forename() .. " " .. character:get_surname())
	dev.log("\tAge: " .. character:age())
	dev.log("\tFaction: " .. character:faction():name())
	dev.log("\tPosition: " .. character:logical_position_x() .. ", " .. character:logical_position_y() .. "\n")
	dev.log("\tCamera Position: " .. character:display_position_x() .. ", " .. character:display_position_y() .. "\n")
end

function cameraDebugInfo()
	local date = os.date("%A, %c");
	local cam_pos = cam:position();
	local cam_pos_x = cam_pos:get_x();
	local cam_pos_y = cam_pos:get_y();
	local cam_pos_z = cam_pos:get_z();
	local cam_target = cam:target();
	local cam_target_x = cam_target:get_x();
	local cam_target_y = cam_target:get_y();
	local cam_target_z = cam_target:get_z();

	dev.log("Camera Info:")
	dev.log("\tCurrent Time: " .. date)
	dev.log("\tCutscene_NAME:action(function() cam:move_to(v("..cam_pos_x..", "..cam_pos_y..", "..cam_pos_z.."), v("..cam_target_x..", "..cam_target_y..", "..cam_target_z.."), [TRANSITION #], true, [FOV #]) end, [START TIME #]);")
	dev.log("")
end

function campaignCameraDebugInfo()
	local date = os.date("%A, %c");
	local cached_x, cached_y, cached_h, cached_r = CampaignUI.GetCameraPosition();

	dev.log("Camera Info:")
	dev.log("\tCurrent Time: " .. date)
	dev.log("\t".."X: "..cached_x.." Y: "..cached_y.." H: "..cached_h.." R: "..cached_r);
	dev.log("")
end

function find_single_uicomponent(parent, component_name)
	if not is_uicomponent(parent) then
		return false;
	end;

	local component = parent:Find(component_name, false);
	
	if not component then
		return false;
	end;
	
	return UIComponent(component);
end;


function find_uicomponent(parent, ...)
	local current_parent = parent;
	
	for i = 1, arg.n do
		local current_child = find_single_uicomponent(current_parent, arg[i]);
		
		if not current_child then
			return false;
		end;
		
		current_parent = current_child;
	end;
	
	return current_parent;
end;


function find_uicomponent_by_table(parent, t)
	if not is_table(t) then
		return false;
	end;
	
	local current_uic = parent;
	
	for i = 1, #t do
		local current_str = t[i];
		
		if not is_string(current_str) then
			return false;
		end;
		
		current_uic = find_single_uicomponent(current_uic, t[i]);
		
		if not current_uic then
			return false;
		end;
	end;	
	
	return current_uic;
end;


function uicomponent_to_str(uic)
	if not is_uicomponent(uic) then
		return "";
	end;
	
	if uic:Id() == "root" then
		return "root";
	else
		return uicomponent_to_str(UIComponent(uic:Parent())) .. " > " .. uic:Id();
	end;	
end;


function output_uicomponent(uic)
	if not is_uicomponent(uic) then
		return;
	end;
	
	local out = false;
	
	if __game_mode == __lib_type_campaign then
		out = output;
	else
		if __game_mode == __lib_type_battle then
			local bm = get_bm();
			
			out = function(str) bm:out(str) end;
		else
			out = print;
		end;
	end;
	
	-- not sure how this can happen, but it does ...
	if not pcall(function() out("uicomponent " .. tostring(uic:Id()) .. ":") end) then
		out("output_uicomponent() called but supplied component seems to not be valid, so aborting");
		return;
	end;
	
	if __game_mode == __lib_type_campaign then
		inc_tab();
	end;
	
	dev.log("path from root:\t\t" .. uicomponent_to_str(uic));
	
	local pos_x, pos_y = uic:Position();
	local size_x, size_y = uic:Bounds();

	dev.log("position on screen:\t" .. tostring(pos_x) .. ", " .. tostring(pos_y));
	dev.log("size:\t\t\t" .. tostring(size_x) .. ", " .. tostring(size_y));
	dev.log("state:\t\t" .. tostring(uic:CurrentState()));
	dev.log("current anim:\t\t"..tostring(uic:CurrentAnimationId()));
	dev.log("has interface?:\t\t"..tostring(uic:HasInterface()));
	dev.log("callback id:\t\t"..tostring(uic:CallbackId()));
	dev.log("visible:\t\t" .. tostring(uic:Visible()));
	dev.log("priority:\t\t" .. tostring(uic:Priority()));
	dev.log("text:\t\t" .. tostring(uic:GetStateText()));
	dev.log("children:");
	
	if __game_mode == __lib_type_campaign then
		inc_tab();
	end;
	
	for i = 0, uic:ChildCount() - 1 do
		local child = UIComponent(uic:Find(i));
		
		dev.log(tostring(i) .. ": " .. child:Id());
	end;
	
	if __game_mode == __lib_type_campaign then
		dec_tab();
		dec_tab();
	end;

	dev.log("");
end;

--scripting.AddEventCallBack("CharacterSelected", function() dev.log("Character Selected") end)
--scripting.AddEventCallBack("CharacterSelected", characterDebugInfo)
--scripting.AddEventCallBack("ComponentLClickUp", function() dev.log("Component Selected") end)
--scripting.AddEventCallBack("ComponentLClickUp", cameraDebugInfo)
--scripting.AddEventCallBack("ComponentLClickUp", campaignCameraDebugInfo)
--scripting.AddEventCallBack("ComponentLClickUp", function(context) output_uicomponent(UIComponent(context.component)) end)

-- Logging
dev.log("logging_callbacks.lua loaded")
