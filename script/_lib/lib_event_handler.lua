-------------------------------------------------------
-------------------------------------------------------
--	EVENT HANDLER
-------------------------------------------------------
-------------------------------------------------------

-- Minor edits by DETrooper to add better support for custom contexts and triggering custom events.

local callbacks_listed = false;
local dev = require("lua_scripts/dev");

__event_handler = nil;

event_handler = {
	add_func = nil,
	attached_events = {},
	listeners = {}
};

function event_handler:new(new_add_func)
	if is_eventhandler(__event_handler) then
		return eh;
	end;
	
	if not is_function(new_add_func) then
		script_error("ERROR: event_handler:new() called but supplied parameter is not a function!");
		return false;
	end;
	
	local eh = {
		add_func = new_add_func,
		attached_events = {},
		listeners = {}
	}
	
	setmetatable(eh, self);
	self.__index = self;
	self.__tostring = function() return TYPE_EVENT_HANDLER end;
	
	-- cleanup events after we shut down
	if __game_mode == __lib_type_campaign then
		-- campaign
		-- add_campaign_cleanup_action(function() ClearEventCallbacks() end);
	elseif __game_mode == __lib_type_battle then
		-- battle
		get_bm():register_phase_change_callback("Complete", function() ClearEventCallbacks() end);
	end;
	
	__event_handler = eh;
	
	return eh;
end;

function get_eh()
	if is_eventhandler(__event_handler) then
		return __event_handler;
	end;
end;

function event_handler:add_listener(new_name, new_event, new_condition, new_callback, new_persistent)
	if not is_string(new_name) then
		script_error("ERROR: event_handler:add_listener() called but name given [" .. tostring(new_name) .. "] is not a string");
		return false;
	end;
	
	if not is_string(new_event) then
		script_error("ERROR: event_handler:add_listener() called but event given [" .. tostring(new_event) .. "] is not a string");
		return false;
	end;
	
	if not is_function(new_condition) and not (is_boolean(new_condition) and new_condition == true) then
		script_error("ERROR: event_handler:add_listener() called but condition given [" .. tostring(new_condition) .. "] is not a function or true");
		return false;
	end;
	
	if not is_function(new_callback) then
		script_error("ERROR: event_handler:add_listener() called but callback given [" .. tostring(new_callback) .. "] is not a function");
		return false;
	end;
	
	local new_persistent = new_persistent or false;
	
	-- attach to the event if we're not already
	self:attach_to_event(new_event);
	
	local new_listener = {
		name = new_name,
		event = new_event,
		condition = new_condition,
		callback = new_callback,
		persistent = new_persistent,
		to_remove = false
	};
		
	table.insert(self.listeners, new_listener);	
end;

function event_handler:attach_to_event(eventname)
	for i = 1, #self.attached_events do
		if self.attached_events[i].name == eventname then
			-- we're already attached
			return;
		end;
	end;
		
	-- we're not attached
	local event_to_attach = {
		name = eventname,
		callback = function(context) self:event_callback(eventname, context) end
	};
	
	self:register_event(eventname);
	
	self.add_func(eventname, function(context) event_to_attach.callback(context) end);
	
	table.insert(self.attached_events, event_to_attach);
end;

function event_handler:event_callback(eventname, context)
	--[[if not callbacks_listed and eventname == "FactionTurnStart" then
		self:list_events();
		callbacks_listed = true;
	end]]--
	
	-- make a list of callbacks to fire and listeners to remove. We can't call the callbacks whilst
	-- processing the list because the callbacks may alter the list length, and we can't rescan because
	-- this will continually hit persistent callbacks
	local callbacks_to_call = {};
	local listeners_to_remove = {};
	
	for i = 1, #self.listeners do
		local current_listener = self.listeners[i];
		
		if current_listener.event == eventname and (is_boolean(current_listener.condition) or current_listener.condition(context)) then
			table.insert(callbacks_to_call, current_listener.callback);
			
			if not current_listener.persistent then
				-- store this listener to be removed post-list
				current_listener.to_remove = true;
			end;
		end;
	end;
	
	-- clean out all the listeners that have been marked for removal
	self:clean_listeners();

	--[[if eventname == "FactionTurnStart" then
		dev.log("\n");
	end]]--

	for i = 1, #callbacks_to_call do
		--[[if eventname == "FactionTurnStart" then
			dev.log(tostring(callbacks_to_call[i]));
		end]]--

		callbacks_to_call[i](context);
	end;
end;

-- go through all the listeners and remove those with the to_remove flag set
function event_handler:clean_listeners()
	for i = 1, #self.listeners do
		if self.listeners[i].to_remove then
			table.remove(self.listeners, i);
			-- restart
			self:clean_listeners();
			return;
		end;
	end;
end;

function event_handler:remove_listener(name_to_remove, start_point)
	local start_point = start_point or 1;
	
	-- dev.log("eh:remove_listener(" .. tostring(name_to_remove) .. ", " .. tostring(start_point) .. ") called. #self.listeners is " .. tostring(#self.listeners));

	for i = start_point, #self.listeners do
		-- dev.log("\tchecking listener " .. i);
		-- dev.log("\t\tlistener name is " .. self.listeners[i].name);
		if self.listeners[i].name == name_to_remove then
			table.remove(self.listeners, i);
			--rescan
			self:remove_listener(name_to_remove, i);
			return;
		end;
	end;
end;

function event_handler:list_events()
	dev.log("**************************************");
	dev.log("Event Handler attached events");
	dev.log("**************************************");
	
	local attached_events = self.attached_events;
	for i = 1, #attached_events do
		dev.log(i .. "\tname:\t\t" .. attached_events[i].name .. "\tcallback:" .. tostring(attached_events[i].callback));
	end;
	dev.log("**************************************");
	dev.log("Event Handler listeners");
	dev.log("**************************************");
	
	local listeners = self.listeners;
	for i = 1, #listeners do
		local l = listeners[i];
		dev.log(i .. ":\tname:" .. tostring(l.name) .. "\tevent:" .. tostring(l.event) .. "\tcondition:" .. tostring(l.condition) .. "\tcallback:" .. tostring(l.callback) .. "\tpersistent:" .. tostring(l.persistent));
	end;
	dev.log("**************************************");
end;

function event_handler:register_event(event)
	if not events[event] then
		events[event] = {};
	end;
end;

function event_handler:trigger_event(event, ...)
	
	-- build an event context
	local cc = custom_context:new();
	
	--for i = 2, arg.n do (whyyyy)
	for i = 1, arg.n do
		cc:add_data(arg[i]);
	end;
	
	-- trigger the event with the context
	local event_table = events[event];
	
	for i = 1, #event_table do
		event_table[i](cc);
	end;
end;

----------------------------------------------------------------------------
-- custom context script
----------------------------------------------------------------------------

custom_context = {};

function custom_context:new()
	local cc = {};
	setmetatable(cc, self);
	self.__index = self;	
	
	return cc;
end;

function custom_context:add_data(obj)
	if is_string(obj) then
		self.string = obj;
	elseif is_region(obj) then
		self.region_data = obj;
	elseif is_character(obj) then
		self.character_data = obj;
	elseif is_faction(obj) then
		if not self.faction_data then
			self.faction_data = obj;
		else
			self.other_faction_data = obj;
		end
	elseif is_component(obj) then
		self.component_data = obj;
	elseif is_militaryforce(obj) then
		self.military_force_data = obj;
	elseif is_unit(obj) then
		self.unit_data = obj;
	else
		script_error("ERROR: adding data to custom context but couldn't recognise data [" .. tostring(obj) .. "] of type [" .. type(obj) .. "]");
	end;	
end;

function custom_context:region()
	return self.region_data;
end;

function custom_context:character()
	return self.character_data;
end;

function custom_context:faction()
	return self.faction_data;
end;

function custom_context:other_faction()
	return self.other_faction_data;
end;

function custom_context:component()
	return self.component_data;
end;

function custom_context:military_force()
	return self.military_force_data;
end;

function custom_context:unit()
	return self.unit_data;
end;