--[[
	© 2013 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

local ITEM = Clockwork.item:New(nil, true);
ITEM.name = "Vehicle Base";
ITEM.batch = 1;
ITEM.weight = 0;
ITEM.useText = "Drive";
ITEM.category = "Vehicles";
ITEM.business = true;
ITEM.hornSound = "vehicles/honk.wav";
ITEM.isRareItem = true;
ITEM.destroyText = "Sell";
ITEM.allowStorage = false;

-- A function to get the item's vehicle name.
function ITEM:GetVehicleName()
	local owner = self:GetData("Owner");
	
	if (owner == "") then
		return self.name;
	end;
	
	local player = Clockwork.player:FindByID(owner);
	
	if (player) then
		return player:Name().."'s "..self.name;
	else
		return self.name;
	end;
end;

ITEM:AddData("PhysDesc", "", true);
ITEM:AddData("IsUsed", false, true);
ITEM:AddData("Owner", "", true);
ITEM:AddData("Fuel", 100, true);
ITEM:AddQueryProxy("name", ITEM.GetVehicleName);

if (CLIENT) then
	function ITEM:GetClientSideInfo()
		clientSideInfo = Clockwork.kernel:AddMarkupLine("", "Fuel: "..self:GetData("Fuel").."%");
		
		return (clientSideInfo != "" and clientSideInfo);
	end;
end;

-- Called to get whether a player has the item equipped.
function ITEM:HasPlayerEquipped(player, bIsValidWeapon)
	return self:GetData("IsUsed");
end;

-- Called when the item has initialized.
function ITEM:OnInitialize(panel)
	self.weightText = "Garage";
end;

-- Called when a player destroys the item.
function ITEM:OnDestroy(player)
	Clockwork.player:GiveCash(player, self.cost / 2, "selling a "..string.lower(self.name));
end;

-- Called when the item has been ordered.
function ITEM:OnOrder(player, entity)
	local itemTable = Clockwork.item:CreateInstance(self.uniqueID);
	
	itemTable:SetData("Owner", player:SteamID());
	itemTable:NetworkData();
	
	player:GiveItem(itemTable);

	if (IsValid(entity)) then
		entity:Remove();
	end;
end;

-- Called when a player uses the item.
function ITEM:OnUse(player, itemEntity)
	cwVehicles:SpawnVehicle(player, self);
	
	return false;
end;

ITEM:Register();