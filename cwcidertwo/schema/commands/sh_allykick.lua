--[[
	© 2013 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

local COMMAND = Clockwork.command:New("AllyKick");
COMMAND.tip = "Kick a character out of your alliance.";
COMMAND.text = "<string Name>";
COMMAND.flags = CMD_DEFAULT;
COMMAND.arguments = 1;

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local alliance = player:GetCharacterData("alliance");
	local target = Clockwork.player:FindByID(table.concat(arguments, " "));
		
	if (alliance != "") then
		if (player:GetCharacterData("leader")) then
			if (target) then
				local targetAlliance = target:GetCharacterData("alliance");
					
				if (targetAlliance == alliance) then
					target:SetCharacterData("leader", nil);
					target:SetCharacterData("alliance", "");
						
					Clockwork.player:Notify(player, "You have kicked "..target:Name().." from the '"..alliance.."' alliance.");
					Clockwork.player:Notify(target, player:Name().." has kicked you from the '"..alliance.."' alliance.");
				else
					Clockwork.player:Notify(player, target:Name().." is not in your alliance!");
				end;
			else
				Clockwork.player:Notify(player, arguments[1].." is not a valid character!");
			end;
		else
			Clockwork.player:Notify(player, "You are not a leader of this alliance!");
		end;
	else
		Clockwork.player:Notify(player, "You are not in an alliance!");
	end;
end;
COMMAND:Register();