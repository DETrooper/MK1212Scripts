--------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------
--
-- 	MEDIEVAL KINGDOMS 1212 - NETWORKING (MP CAMPAIGNS)
-- 	By: DETrooper
--
--------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------

function Add_MK1212_Networking_Listeners()
	cm:add_listener(
		"OnComponentLClickUp_Networking",
		"ComponentLClickUp",
		true,
		function(context) OnComponentLClickUp_Networking(context) end,
		true
	);
	cm:add_listener(
		"TimeTrigger_Networking",
		"TimeTrigger",
		true,
		function(context) TimeTrigger_Networking(context) end,
		true
	);

	SetupChatBox();
	ProcessTick();
end

function SetupChatBox()
	local root = cm:ui_root();
	local multiplayer_chat_uic = UIComponent(root:Find("multiplayer_chat"));
	local chat_input_box_uic = UIComponent(multiplayer_chat_uic:Find("chat_input_box"));

	--[[multiplayer_chat_uic:SetMoveable(true);
	multiplayer_chat_uic:MoveTo(0, -200);
	multiplayer_chat_uic:SetMoveable(false);]]--
	--multiplayer_chat_uic:SetVisible(true);
end

function ProcessTick()
	cm:add_time_trigger("tick", 0.5);
end

function OnComponentLClickUp_Networking(context)
	if context.string == "button_missions" then
		local root = cm:ui_root();
		local multiplayer_chat_uic = UIComponent(root:Find("multiplayer_chat"));
		local chat_input_box_uic = UIComponent(multiplayer_chat_uic:Find("chat_input_box"));

		chat_input_box_uic:SimulateClick();
		root:SimulateKey("T");
		root:SimulateKey("E");
		root:SimulateKey("S");
		root:SimulateKey("T");
		root:SimulateKey("5");
	end
end

function TimeTrigger_Pope_UI(context)
	if context.string == "tick" then
		ProcessTick();
	end
end