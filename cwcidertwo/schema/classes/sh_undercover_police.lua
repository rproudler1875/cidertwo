--[[
	© 2013 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

local CLASS = Clockwork.class:New("Undercover Officer");
	CLASS.wages = 25;
	CLASS.ammo = {pistol = 64};
	CLASS.color = Color(150, 125, 100, 255);
	CLASS.weapons = {"weapon_glock"};
	CLASS.factions = {FACTION_POLICE};
	CLASS.description = "An armed undercover police officer.";
	CLASS.headsetGroup = 1;
	CLASS.defaultPhysDesc = "Wearing a nice, clean set of urban clothes.";
CLASS_UNDERCOVER = CLASS:Register();