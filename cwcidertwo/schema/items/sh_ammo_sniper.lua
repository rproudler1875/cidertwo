--[[
	� 2013 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

local ITEM = Clockwork.item:New("ammo_base");
	ITEM.name = "7.65x59mm Rounds";
	ITEM.cost = 150;
	ITEM.model = "models/items/redammo.mdl";
	ITEM.weight = 2;
	ITEM.classes = {CLASS_BLACKMARKET};
	ITEM.uniqueID = "ammo_sniper";
	ITEM.business = true;
	ITEM.ammoClass = "ar2";
	ITEM.ammoAmount = 8;
	ITEM.description = "A red container with 7.65x59mm on the side.";
ITEM:Register();