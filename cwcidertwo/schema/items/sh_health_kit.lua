--[[
	� 2013 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

local ITEM = Clockwork.item:New();
ITEM.name = "Health Kit";
ITEM.cost = 20;
ITEM.model = "models/items/healthkit.mdl";
ITEM.weight = 1;
ITEM.classes = {CLASS_MERCHANT};
ITEM.useText = "Apply";
ITEM.category = "Medical"
ITEM.business = true;
ITEM.useSound = "items/medshot4.wav";
ITEM.description = "A white packet filled with medication.";
ITEM.customFunctions = {"Give"};

-- Called when a player uses the item.
function ITEM:OnUse(player, itemEntity)
	player:SetHealth(math.Clamp(player:Health() + CiderTwo:GetHealAmount(player, 2), 0, player:GetMaxHealth()));
		
	Clockwork.plugin:Call("PlayerHealed", player, player, self);
end;

-- Called when a player drops the item.
function ITEM:OnDrop(player, position) end;

-- Called when a custom function is used.
function ITEM:OnCustomFunction(player, name)
	if (name == "Give") then
		Clockwork.player:RunClockworkCommand(player, "CharHeal", "health_kit");
	end;
end;
ITEM:Register();