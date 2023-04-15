-----------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------
--
-- 	MEDIEVAL KINGDOMS 1212 - IRONMAN: ACHIEVEMENT - ALL THE WORLD'S A STAGE
-- 	By: DETrooper
--
-----------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------

local achievement = {};

achievement.name = "All the World's a Stage";
achievement.description = "As the Kingdom of England, construct a Grand Theater in Alexandria, Constantinople, London, Paris, Rome, Venice, and Vienna.";
achievement.manual = false; -- Is unlocked during achievement turn start check.
achievement.requiredbuildings = {"mk_bld_weskingdoms_civic_major_theater_3"};
achievement.requiredregionsforbuildings = {
	"mk_reg_alexandria",
	"mk_reg_constantinopolis",
	"mk_reg_london",
	"mk_reg_paris",
	"mk_reg_rome",
	"mk_reg_venice",
	"mk_reg_vienna"
};
achievement.unlocked = false;
achievement.unlocktime = "";

return achievement;
