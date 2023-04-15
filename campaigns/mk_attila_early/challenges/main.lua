-----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------
--
-- 	MEDIEVAL KINGDOMS 1212 - CHALLENGES: MAIN
-- 	By: DETrooper
--
-----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------

require("challenges/challenge_judgement_day");
require("challenges/challenge_no_retreat");
require("challenges/challenge_this_is_total_war");

CHALLENGES_ENABLED = {
	["judgement_day"] = false,
	["no_retreat"] = false,
	["this_is_total_war"] = false,
};

function Challenge_Initializer()
	if cm:is_new_game() then
		for k, v in pairs(CHALLENGES_ENABLED) do
			CHALLENGES_ENABLED[k] = svr:LoadBool("SBOOL_challenge_"..k);
		end
	end

	if CHALLENGES_ENABLED["judgement_day"] == true then
		Add_Challenge_Judgement_Day_Listeners();
	end

	if CHALLENGES_ENABLED["no_retreat"] == true then
		Add_Challenge_No_Retreat_Listeners();
	end

	if CHALLENGES_ENABLED["this_is_total_war"] == true then
		Add_Challenge_This_Is_Total_War_Listeners();
	end
end

------------------------------------------------
---------------- Saving/Loading ----------------
------------------------------------------------
cm:register_loading_game_callback(
	function(context)
		if not cm:is_new_game() then
			CHALLENGES_ENABLED = LoadBooleanPairTable(context, "CHALLENGES_ENABLED");
		end
	end
);

cm:register_saving_game_callback(
	function(context)
		SaveBooleanPairTable(context, CHALLENGES_ENABLED, "CHALLENGES_ENABLED");
	end
);
