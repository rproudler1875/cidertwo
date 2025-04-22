--[[
	� 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

-- Called when an entity's menu option should be handled.
function cwWriting:EntityHandleMenuOption(player, entity, option, arguments)
	local class = entity:GetClass();
	
	if (class == "cw_paper" and arguments == "cw_paperOption") then
		if (entity.text) then
			if (!player.paperIDs or !player.paperIDs[entity.uniqueID]) then
				if (!player.paperIDs) then
					player.paperIDs = {};
				end;
				
				player.paperIDs[entity.uniqueID] = true;
				
				Clockwork.datastream:Start(player, "ViewPaper", {entity, entity.uniqueID, entity.text});
			else
				Clockwork.datastream:Start(player, "ViewPaper", {entity, entity.uniqueID});
			end;
		else
			Clockwork.datastream:Start(player, "EditPaper", entity);
		end;
	end;
end;

-- Called when Clockwork has loaded all of the entities.
function cwWriting:ClockworkInitPostEntity()
	self:LoadPaper();
end;

-- Called just after data should be saved.
function cwWriting:PostSaveData()
	self:SavePaper();
end;