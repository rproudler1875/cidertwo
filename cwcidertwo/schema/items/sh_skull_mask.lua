--[[
	� 2013 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

local ITEM = Clockwork.item:New();
ITEM.name = "Skull Mask";
ITEM.cost = 20;
ITEM.model = "models/gibs/hgibs.mdl";
ITEM.weight = 0.25;
ITEM.classes = {CLASS_BLACKMARKET};
ITEM.business = true;
ITEM.category = "Reusables";
ITEM.description = "A skull mask that can conceal your identity while wearing it.";
ITEM.isAttachment = true;
ITEM.attachmentBone = "ValveBiped.Bip01_Head1";
ITEM.attachmentOffsetAngles = Angle(270, 270, 0);
ITEM.attachmentOffsetVector = Vector(0, 3, 3);

-- Called when the attachment offset info should be adjusted.
function ITEM:AdjustAttachmentOffsetInfo(player, entity, info)
	if (string.find(player:GetModel(), "female")) then
		info.offsetVector = Vector(0, 3, 1.75);
	end;
end;

-- A function to get whether the attachment is visible.
function ITEM:GetAttachmentVisible(player, entity)
	if (player:GetSharedVar("skullMask")) then
		return true;
	end;
end;

-- Called when the item's local amount is needed.
function ITEM:GetLocalAmount(amount)
	if (Clockwork.Client:GetSharedVar("skullMask")) then
		return amount - 1;
	else
		return amount;
	end;
end;

-- Called to get whether a player has the item equipped.
function ITEM:HasPlayerEquipped(player, arguments)
	return player:GetSharedVar("skullMask");
end;

-- Called when a player has unequipped the item.
function ITEM:OnPlayerUnequipped(player, arguments)
	local skullMaskGear = Clockwork.player:GetGear(player, "SkullMask");
		
	if (player:GetSharedVar("skullMask") and IsValid(skullMaskGear)) then
		player:SetCharacterData("skullmask", nil);
		player:SetSharedVar("skullMask", false);
			
		if (IsValid(skullMaskGear)) then
			skullMaskGear:Remove();
		end;
	end;
		
	player:GiveItem(Clockwork.item:CreateInstance(self.uniqueID));
end;

-- Called when a player drops the item.
function ITEM:OnDrop(player, position)
	if (player:GetSharedVar("skullMask") and #player:GetItemsByID(self.uniqueID) == 1) then
		Clockwork.player:Notify(player, "You cannot drop this while you are wearing it!");
			
		return false;
	end;
end;

-- Called when a player uses the item.
function ITEM:OnUse(player, itemEntity)
	if (player:Alive() and !player:IsRagdolled()) then
		Clockwork.player:CreateGear(player, "SkullMask", self);
			
		player:SetCharacterData("skullmask", true);
		player:SetSharedVar("skullMask", true);
		player:GiveItem(Clockwork.item:CreateInstance(self.uniqueID));
			
		if (itemEntity) then
			return true;
		end;
	else
		Clockwork.player:Notify(player, "You don't have permission to do this right now!");
	end;
	
	return false;
end;
ITEM:Register();