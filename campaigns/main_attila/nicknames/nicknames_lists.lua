-------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------
--
-- 	MEDIEVAL KINGDOMS 1212 - NICKNAMES: LISTS
-- 	By: DETrooper
--
-------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------

HISTORICAL_CHARACTERS_TO_NICKNAMES = {
	["57"] = "the_fair",
};

-- Priorities should be from 1 (highest) to 3 (lowest).
NICKNAMES = {
	["the_blind"] = {priority = 2}, -- Has trait 'att_trait_general_physical_all_blind'.
	["the_brave"] = {priority = 3}, -- Has trait 'att_trait_general_personality_all_bravery'.
	["the_conquerer"] = {priority = 3}, -- Personally conquered 10 regions.
	["the_cruel"] = {priority = 2}, -- Executed captives 5 times.
	["the_crusader"] = {priority = 2}, -- Got the 'mk_trait_crusades_crusader' or 'mk_trait_crusades_crusader_king' trait.
	["the_drunkard"] = {priority = 3}, -- Has trait 'att_trait_all_personality_all_drink'.
	["the_exile"] = {priority = 2}, -- Lost the capital of the faction.
	["the_fair"] = {priority = 3}, -- Reigned for 10 years without a revolt.
	["the_glorious"] = {priority = 1}, -- Formed a unique Empire.
	["the_great"] = {priority = 1}, -- Personally conquered 30 regions.
	["the_mad"] = {prioirty = 2}, -- Has trait 'att_trait_general_personality_all_mad'.
	["the_old"] = {priority = 3}, -- Aged 65+.
	["the_ruthless"] = {priority = 2}, -- Has trait 'att_trait_general_military_all_high_casualties'.
	["the_terrible"] = {priority = 1}, -- Executed captives 20 times.
	["the_undying"] = {priority = 2}, -- Aged 90+.
	["the_wicked"] = {priority = 2}, -- Excommunciated on more than one occasion.
};

TRAITS_TO_NICKNAMES = {
	["att_trait_general_physical_all_blind"] = "the_blind",
	["att_trait_general_personality_all_bravery"] = "the_brave",
	["att_trait_all_personality_all_drink"] = "the_drunkard",
	["att_trait_general_personality_all_mad"] = "the_mad",
	["att_trait_general_military_all_high_casualties"] = "the_ruthless",
	["mk_trait_crusades_crusader"] = "the_crusader",
	["mk_trait_crusades_crusader_king"] = "the_crusader",
};
