--[[
	� 2013 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

local ITEM = Clockwork.item:New("weapon_base");
	ITEM.name = "Metal Crowbar";
	ITEM.cost = 80;
	ITEM.model = "models/weapons/w_crowbar.mdl";
	ITEM.weight = 1;
	ITEM.classes = {CLASS_BLACKMARKET};
	ITEM.uniqueID = "cw_metalcrowbar";
	ITEM.business = true;
	ITEM.category = "Melee";
	ITEM.description = "A scratched up and dirty metal crowbar.";
	ITEM.meleeWeapon = true;
	ITEM.isAttachment = true;
	ITEM.loweredOrigin = Vector(-18, -5, 5);
	ITEM.loweredAngles = Angle(-10, 10, -80);
	ITEM.attachmentBone = "ValveBiped.Bip01_Spine";
	ITEM.attachmentOffsetAngles = Angle(200, 200, 0);
	ITEM.attachmentOffsetVector = Vector(0, 5, 2);
ITEM:Register();