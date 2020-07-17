-----------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------
--
-- 	MEDIEVAL KINGDOMS 1212 - IRONMAN: ACHIEVEMENT - PRESTER JOHN
-- 	By: DETrooper
--
-----------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------

local achievement = {};

achievement.name = "Prester John";
achievement.description = "As the Ulus of Jochi or Ulus or Tolui, convert to a Christian faith and own the region Jerusalem.";
achievement.manual = false; -- Is unlocked during achievement turn start check.
achievement.requiredfactions = {"mk_fact_goldenhorde", "mk_fact_ilkhanate"}; -- The player must be one of these factions.
achievement.requiredregions = {"att_reg_palaestinea_aelia_capitolina"}; -- Regions required for this achievement to unlock.
achievement.requiredreligions = {"mk_rel_chr_bogomilist", "mk_rel_chr_cathar", "att_rel_chr_catholic", "att_rel_church_east", "att_rel_chr_orthodox"}; -- The player must be one of these religions.
achievement.unlocked = false;
achievement.unlocktime = "";

return achievement;
