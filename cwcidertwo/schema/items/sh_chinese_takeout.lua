--[[
	� 2013 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

local ITEM = Clockwork.item:New();
ITEM.name = "Chinese Takeout";
ITEM.cost = 6;
ITEM.model = "models/props_junk/garbage_takeoutcarton001a.mdl";
ITEM.weight = 0.8;
ITEM.classes = {CLASS_CATERER};
ITEM.useText = "Eat";
ITEM.category = "Consumables"
ITEM.business = true;
ITEM.description = "A takeout carton, it's filled with cold noodles.";

-- Called when a player uses the item.
function ITEM:OnUse(player, itemEntity)
	player:SetCharacterData("hunger", math.Clamp(player:GetCharacterData("hunger") - 75, 0, 100));
	player:SetHealth(math.Clamp(player:Health() + 10, 0, player:GetMaxHealth()));
		
	player:BoostAttribute(self.name, ATB_ENDURANCE, 2, 600);
	player:BoostAttribute(self.name, ATB_ACCURACY, 1, 600);
end;

-- Called when a player drops the item.
function ITEM:OnDrop(player, position) end;
ITEM:Register();