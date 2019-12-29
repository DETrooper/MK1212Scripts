-------------------------------------------------------------------------------------------------------
---- Random Army Manager ------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------
---- Used to create and manage multiple random or semi-random army templates that can be generated ----
-------------------------------------------------------------------------------------------------------

-- Example Usage:
--
-- 1) Create the manager
-- local ram = Random_Army_Manager;
--
-- 2) Create an army template
-- ram:new_force("my_template");
--
-- 3) Add 4 units to this army that will always be used when generating this template
-- ram:add_mandatory_unit("my_template", "unit_key1", 4);
--
-- 4) Add units to the template that can be randomly generated, with their weighting (that is their chance of being picked, this is not how many will be picked)
-- ram:add_unit("my_template", "unit_key1", 1);
-- ram:add_unit("my_template", "unit_key2", 1);
-- ram:add_unit("my_template", "unit_key3", 2);
--
-- 5) Generate a random army of 6 units from this template
-- local force = ram:generate_force("my_template", 7, false);
-- Force: "unit_key1,unit_key1,unit_key1,unit_key1,unit_key2,unit_key3"


---------------------
---- Definitions ----
---------------------
Random_Army_Manager = {
	force_list = {}
};

---------------------------------------------------------------------------------------
---- Creates a new force available for selection and add it to the table of forces ----
---------------------------------------------------------------------------------------
function Random_Army_Manager:new_force(key)
	--output("Random Army Manager: Creating New Force- '"..key.."'...");
	for i = 1, #self.force_list do
		if key == self.force_list[i].key then
			--output("\tAlready exists!");
			return false;
		end
	end

	local force = {};
	force.key = key;
	force.units = {};
	force.mandatory_units = {};
	table.insert(self.force_list, force);
	--output("\tCreated!");
	return true;
end

-----------------------------------------------------------------------------------------------------
---- Adds a unit to a force, making it available for random selection if this force is generated ----
---- The weight value is an arbitrary figure that should be relative to other units in the force ----
-----------------------------------------------------------------------------------------------------
function Random_Army_Manager:add_unit(force_key, key, weight)
	for i = 1, #self.force_list do
		if force_key == self.force_list[i].key then
			for j = 1, weight do
				table.insert(self.force_list[i].units, key);
				--output("Random Army Manager: Adding Unit- '"..key.."', Weight: "..weight..", Force: "..force_key);
			end
		end
	end
end

----------------------------------------------------------------------------------------------------------------------------------------
---- Adds a mandatory unit to a force composition, making it so that if this force is generated this unit will always be part of it ----
----------------------------------------------------------------------------------------------------------------------------------------
function Random_Army_Manager:add_mandatory_unit(force_key, key, amount)
	for i = 1, #self.force_list do
		if force_key == self.force_list[i].key then
			for j = 1, amount do
				table.insert(self.force_list[i].mandatory_units, key);
				--output("Random Army Manager: Adding Mandatory Unit- '"..key.."', Amount: "..amount..", Force: "..force_key);
			end
		end
	end
end

----------------------------------------------------------------------------------------------------------------------------------------------------
---- This generates a force randomly, first taking into account the mandatory unit and then making random selection of units based on weighting ----
---- Returns an array of unit keys or a comma separated string for use in the create_force function if the last boolean value is passed as true ----
----------------------------------------------------------------------------------------------------------------------------------------------------
function Random_Army_Manager:generate_force(force_key, unit_count, returnAsArray)
	local force = {};
	local returnArray = returnAsArray or false;
	
	if is_table(unit_count) then
		unit_count = cm:random_number(math.max(unit_count[1], unit_count[2]), math.min(unit_count[1], unit_count[2]));
	end;
	
	unit_count = math.min(19, unit_count);
	
	--output("Random Army Manager: Getting Random Force ("..unit_count..")");
	
	for i = 1, #self.force_list do
		if force_key == self.force_list[i].key then
			
			local mandatory_units_added = 0;
			
			for j = 1, #self.force_list[i].mandatory_units do
				table.insert(force, self.force_list[i].mandatory_units[j]);
				mandatory_units_added = mandatory_units_added + 1;
			end
		
			for k = 1, unit_count - mandatory_units_added do
				local unit_index = cm:random_number(#self.force_list[i].units);
				table.insert(force, self.force_list[i].units[unit_index]);
			end
		end
	end
	
	if returnArray == true then
		return force;
	else
		return table.concat(force, ",");
	end
end

------------------------------------------------------
---- Remove an existing force from the force list ----
------------------------------------------------------
function Random_Army_Manager:remove_force(force_key)
	--output("Random Army Manager: Removing Force- '"..force_key.."'");
	for i = 1, #self.force_list do
		if force_key == self.force_list[i].key then
			table.remove(i);
		end
	end
end

function Possible_Rebel_Forces()
	Random_Army_Manager:new_force("english_force_small");
	Random_Army_Manager:add_mandatory_unit("english_force_small", "mk_eng_t1_spear_militia", 3)
	Random_Army_Manager:add_mandatory_unit("english_force_small", "mk_eng_t1_serjeants", 2)
	Random_Army_Manager:add_mandatory_unit("english_force_small", "mk_eng_t1_longbowmen", 3)
	Random_Army_Manager:add_mandatory_unit("english_force_small", "mk_eng_t1_mounted_serjeants", 1)
	
	Random_Army_Manager:new_force("english_force_medium");
	Random_Army_Manager:add_mandatory_unit("english_force_medium", "mk_eng_t1_spear_militia", 4)
	Random_Army_Manager:add_mandatory_unit("english_force_medium", "mk_eng_t1_serjeants", 3)
	Random_Army_Manager:add_mandatory_unit("english_force_medium", "mk_eng_t1_longbowmen", 3)
	Random_Army_Manager:add_mandatory_unit("english_force_medium", "mk_eng_t1_mounted_serjeants", 2)	
	
	Random_Army_Manager:new_force("english_force_large");
	Random_Army_Manager:add_mandatory_unit("english_force_large", "mk_eng_t1_spear_militia", 4)
	Random_Army_Manager:add_mandatory_unit("english_force_large", "mk_eng_t1_serjeants", 4)
	Random_Army_Manager:add_mandatory_unit("english_force_large", "mk_eng_t1_axe_sergeant", 1)
	Random_Army_Manager:add_mandatory_unit("english_force_large", "mk_eng_t1_longbowmen", 3)
	Random_Army_Manager:add_mandatory_unit("english_force_large", "mk_eng_t1_mounted_serjeants", 2)
end

function CreateCivilWarArmy(region, culture, rebel_faction_name, army_id, x, y)
	-- DIFFICULTY LEVEL DETECTION
	local difficulty = cm:model():difficulty_level();
	local force = false;
	
	if culture == "english" then
		if difficulty == 1 then
			force = "mk_eng_t1_spear_militia,mk_eng_t1_spear_militia,mk_eng_t1_spear_militia,mk_eng_t1_serjeants,mk_eng_t1_serjeants,mk_eng_t1_longbowmen,mk_eng_t1_longbowmen,mk_eng_t1_longbowmen,mk_eng_t1_mounted_serjeants";
		elseif difficulty == 0 or difficulty == -1 then
			force = "mk_eng_t1_spear_militia,mk_eng_t1_spear_militia,mk_eng_t1_spear_militia,mk_eng_t1_spear_militia,mk_eng_t1_serjeants,mk_eng_t1_serjeants,mk_eng_t1_serjeants,mk_eng_t1_longbowmen,mk_eng_t1_longbowmen,mk_eng_t1_longbowmen,mk_eng_t1_mounted_serjeants,mk_eng_t1_mounted_serjeants";
		elseif difficulty == -2 or difficulty == -3 then
			force = "mk_eng_t1_spear_militia,mk_eng_t1_spear_militia,mk_eng_t1_spear_militia,mk_eng_t1_spear_militia,mk_eng_t1_serjeants,mk_eng_t1_serjeants,mk_eng_t1_serjeants,mk_eng_t1_serjeants,mk_eng_t1_axe_sergeant,mk_eng_t1_longbowmen,mk_eng_t1_longbowmen,mk_eng_t1_longbowmen,mk_eng_t1_mounted_serjeants,mk_eng_t1_mounted_serjeants";
		end
	end

	if culture == "cathar" then
		if difficulty == 1 then
			force = "mk_tou_t1_spearmen,mk_tou_t1_dismounted_chevaliers,mk_tou_t1_dismounted_chevaliers,mk_tou_t1_voulge_militia,mk_tou_t1_sergeants,mk_tou_t1_sergeants,mk_tou_t1_archers,mk_tou_t1_archers,mk_tou_t1_crossbowmen,mk_tou_t1_mounted_sergeants,mk_tou_t1_chevaliers";
		elseif difficulty == 0 or difficulty == -1 then
			force = "mk_tou_t1_spearmen,mk_tou_t1_dismounted_chevaliers,mk_tou_t1_dismounted_chevaliers,mk_tou_t1_voulge_militia,mk_tou_t1_sergeants,mk_tou_t1_sergeants,mk_tou_t1_sergeants_foot,mk_tou_t1_archers,mk_tou_t1_archers,mk_tou_t1_crossbowmen,mk_tou_t1_crossbowmen,mk_tou_t1_routiers_heavy,mk_tou_t1_chevaliers,mk_tou_t1_mounted_sergeants";
		elseif difficulty == -2 or difficulty == -3 then
			force = "mk_tou_t1_spearmen,mk_tou_t1_dismounted_chevaliers,mk_tou_t1_dismounted_chevaliers,mk_tou_t1_dismounted_chevaliers,mk_tou_t1_voulge_militia,mk_tou_t1_voulge_militia,mk_tou_t1_sergeants,mk_tou_t1_sergeants,mk_tou_t1_sergeants_foot,mk_tou_t1_sergeants_foot,mk_tou_t1_archers,mk_tou_t1_archers,mk_tou_t1_crossbowmen,mk_tou_t1_crossbowmen,mk_tou_t1_crossbowmen,mk_tou_t1_routiers_heavy,mk_tou_t1_chevaliers,mk_tou_t1_mounted_sergeants,mk_tou_t1_mounted_sergeants";			
		end
	end

	cm:create_force(
		rebel_faction_name,
		force,
		region,
		x,
 		y,
		army_id,
		true,
		function(cqi)
			cm:apply_effect_bundle_to_characters_force("bel_bundle_invasion_force_langobards", cqi, -1, true);
		end
	);
end
