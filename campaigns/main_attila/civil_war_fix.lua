-------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------
--
--  ALL FACTIONS UNLOCK - CIVIL WAR DEBUFF FIX
--  By: MAO GONG
--
-------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------
require("civil_war_string");

function Add_CivilWarFix_Listeners()
    cm:add_listener(
        "FactionTurnStart_CivilWarFix",
        "FactionTurnStart",
        true,
        function(context) FactionTurnStart_CivilWarFix(context) end,
        true
    );
    cm:add_listener(
        "BattleCompleted_CivilWarFix",
        "BattleCompleted",
        true,
        function(context) BattleCompleted_CivilWarFix(context) end,
        true
    );
    cm:add_listener(
        "GarrisonOccupiedEvent_CivilWarFix",
        "GarrisonOccupiedEvent",
        true,
        function(context) GarrisonOccupiedEvent_CivilWarFix(context) end,
        true
    );
end

function FactionTurnStart_CivilWarFix(context)
    if context:faction():is_human() then
        local player_faction = context:faction();
        local player_faction_name = player_faction:name();
        local separatist_faction_name = FACTION_SEPARATSIT[player_faction:name()];
        local separatist_faction = cm:model():world():faction_by_key(separatist_faction_name);
        if FactionIsAlive(separatist_faction_name) == false or separatist_faction:at_war_with(player_faction) == false then
            cm:remove_effect_bundle(CIVIL_EFFECT[player_faction_name], player_faction_name);
        end
    end
end

function BattleCompleted_CivilWarFix(context)
    local pending_battle = cm:model():pending_battle();
    if pending_battle:has_attacker() then
        if pending_battle:attacker():faction():is_human() then
            local player_faction = pending_battle:attacker():faction();
            local player_faction_name = player_faction:name();
            local separatist_faction_name = FACTION_SEPARATSIT[player_faction:name()];
            local separatist_faction = cm:model():world():faction_by_key(separatist_faction_name);        
            if FactionIsAlive(separatist_faction_name) == false or separatist_faction:at_war_with(player_faction) == false then
                cm:remove_effect_bundle(CIVIL_EFFECT[player_faction_name], player_faction_name);
            end
        end
    end
    if pending_battle:has_defender() then
        if pending_battle:defender():faction():is_human() then
            local player_faction = pending_battle:defender():faction();
            local player_faction_name = player_faction:name();
            local separatist_faction_name = FACTION_SEPARATSIT[player_faction:name()];
            local separatist_faction = cm:model():world():faction_by_key(separatist_faction_name);
            if FactionIsAlive(separatist_faction_name) == false or separatist_faction:at_war_with(player_faction) == false then
                cm:remove_effect_bundle(CIVIL_EFFECT[player_faction_name], player_faction_name);
            end
        end
    end
end

function GarrisonOccupiedEvent_CivilWarFix(context)
    if context:character():faction():is_human() then
        local player_faction = context:character():faction();
        local player_faction_name = player_faction:name();
        local separatist_faction_name = FACTION_SEPARATSIT[player_faction:name()];
        local separatist_faction = cm:model():world():faction_by_key(separatist_faction_name);
        if FactionIsAlive(separatist_faction_name) == false or separatist_faction:at_war_with(player_faction) == false then
            cm:remove_effect_bundle(CIVIL_EFFECT[player_faction_name], player_faction_name);
        end
    end
end

function FactionIsAlive(faction_name)
	if faction_name and faction_name ~= "nil" then
		local faction = cm:model():world():faction_by_key(faction_name);
		if faction:has_home_region() or faction:military_force_list():num_items() > 0 then
			return true;
		end
		return false;
	end
end