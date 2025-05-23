--[[
	� 2013 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

local ITEM = Clockwork.item:New("ammo_base");
	ITEM.name = "5.7x28mm Rounds";
	ITEM.cost = 75;
	ITEM.model = "models/items/boxzrounds.mdl";
	ITEM.weight = 1;
	ITEM.classes = {CLASS_BLACKMARKET, CLASS_DISPENSER};
	ITEM.uniqueID = "ammo_xbowbolt";
	ITEM.business = true;
	ITEM.ammoClass = "xbowbolt";
	ITEM.ammoAmount = 20;
	ITEM.description = "An average sized blue container with 5.7x28mm on the side.";
ITEM:Register();