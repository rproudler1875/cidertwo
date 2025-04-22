--[[
	© 2013 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

CiderTwo.lastHeartbeatAmount = 0;
CiderTwo.nextHeartbeatCheck = 0;
CiderTwo.heartbeatGradient = Material("gui/gradient_down");
CiderTwo.heartbeatOverlay = Material("effects/combine_binocoverlay");
CiderTwo.scratchTexture = Material("cidertwo/cidertwo_gradient_1.png");
CiderTwo.dirtyTexture = Material("cidertwo/cidertwo_gradient_1.png");
CiderTwo.heartbeatPoints = {};
CiderTwo.nextGetSnipers = 0;
CiderTwo.heartbeatPoint = Material("sprites/glow04_noz");
CiderTwo.laserSprite = Material("sprites/glow04_noz");
CiderTwo.highDistance = 0;
CiderTwo.highEffects = {};
CiderTwo.stunEffects = {};
CiderTwo.highTarget = 5;
CiderTwo.blacklist = {};

surface.CreateFont("cid_Large3D2D", {
	size = Clockwork.kernel:FontScreenScale(2048),
	weight = 600,
	antialias = true,
	font = "Sansation"
});

surface.CreateFont("cid_IntroTextSmall", {
	size = Clockwork.kernel:FontScreenScale(12),
	weight = 600,
	antialias = true,
	font = "Sansation"
});

surface.CreateFont("cid_IntroTextTiny", {
	size = Clockwork.kernel:FontScreenScale(8),
	weight = 600,
	antialias = true,
	font = "Sansation"
});

surface.CreateFont("cid_CinematicText", {
	size = Clockwork.kernel:FontScreenScale(14),
	weight = 600,
	antialias = true,
	font = "Sansation"
});

surface.CreateFont("cid_IntroTextBig", {
	size = Clockwork.kernel:FontScreenScale(14),
	weight = 600,
	antialias = true,
	font = "Sansation"
});

surface.CreateFont("cid_TargetIDText", {
	size = Clockwork.kernel:FontScreenScale(10),
	weight = 600,
	antialias = true,
	font = "Sansation"
});

surface.CreateFont("cid_MenuTextHuge", {
	size = Clockwork.kernel:FontScreenScale(18),
	weight = 600,
	antialias = true,
	font = "Sansation"
});

surface.CreateFont("cid_MenuTextBig", {
	size = Clockwork.kernel:FontScreenScale(16),
	weight = 600,
	antialias = true,
	font = "Sansation"
});

surface.CreateFont("cid_MainText", {
	size = Clockwork.kernel:FontScreenScale(8),
	weight = 600,
	antialias = true,
	font = "Sansation"
});

surface.CreateFont("cid_BillboardSmall", {
	size = Clockwork.kernel:FontScreenScale(10),
	weight = 600,
	antialias = true,
	font = "Sansation"
});

surface.CreateFont("cid_BillboardBig", {
	size = Clockwork.kernel:FontScreenScale(36),
	weight = 600,
	antialias = true,
	font = "Sansation"
});

surface.CreateFont("cid_SmallBarText", {
	size = Clockwork.kernel:FontScreenScale(5),
	weight = 600,
	antialias = true,
	font = "Sansation"
});

surface.CreateFont("cid_PlayerInfoText", {
	size = Clockwork.kernel:FontScreenScale(10),
	weight = 600,
	antialias = true,
	font = "Sansation"
});

Clockwork.config:AddToSystem("Small intro text", "intro_text_small", "The small text displayed for the introduction.");
Clockwork.config:AddToSystem("Big intro text", "intro_text_big", "The big text displayed for the introduction.");

Clockwork.datastream:Hook("Frequency", function(data)
	Derma_StringRequest("Frequency", "What would you like to set the frequency to?", data, function(text)
		Clockwork.kernel:RunCommand("SetFreq", text);
	end);
end);

Clockwork.datastream:Hook("Disguise", function(data)
	Derma_StringRequest("Disguise", "Enter part of the character's name that you'd like to disguise as.", "", function(text)
		Clockwork.kernel:RunCommand("DisguiseSet", text);
	end);
end);

Clockwork.datastream:Hook("Billboards", function(data)
	for k, v in ipairs(data) do
		local wrappedTable = {};
		local unwrapped = v.data.text;
			Clockwork.kernel:WrapText(unwrapped, "cid_BillboardSmall", 384, wrappedTable);
		v.data.text = wrappedTable;
		v.data.unwrapped = unwrapped;
		
		CiderTwo.billboards[v.id].data = v.data;
	end;
	
	if (Clockwork.menu:GetOpen()) then
		if (Clockwork.menu:GetActivePanel() == CiderTwo.billboardPanel) then
			CiderTwo.billboardPanel:Rebuild();
		end;
	end;
end);

Clockwork.datastream:Hook("BillboardAdd", function(data)
	local wrappedTable = {};
	local unwrapped = data.data.text;
		Clockwork.kernel:WrapText(unwrapped, "cid_BillboardSmall", 384, wrappedTable);
	data.data.text = wrappedTable;
	data.data.unwrapped = unwrapped;
	
	CiderTwo.billboards[data.id].data = data.data;
	
	if (Clockwork.menu:GetOpen()) then
		if (Clockwork.menu:GetActivePanel() == CiderTwo.billboardPanel) then
			CiderTwo.billboardPanel:Rebuild();
		end;
	end;
end);

Clockwork.datastream:Hook("BillboardRemove", function(data)
	if (type(data) == "table") then
		for k, v in ipairs(data) do
			CiderTwo.billboards[v] = nil;
		end;
	else
		CiderTwo.billboards[data] = nil;
	end;
	
	if (Clockwork.menu:GetOpen()) then
		if (Clockwork.menu:GetActivePanel() == CiderTwo.billboardPanel) then
			CiderTwo.billboardPanel:Rebuild();
		end;
	end;
end);

Clockwork.datastream:Hook("GetBlacklist", function(data)
	CiderTwo.blacklist = data;
end);

Clockwork.datastream:Hook("SetBlacklisted", function(data)
	if (data[2]) then
		if (!table.HasValue(CiderTwo.blacklist, data[1])) then
			table.insert(CiderTwo.blacklist, data[1]);
		end;
	else
		for k, v in ipairs(CiderTwo.blacklist) do
			if (v == data[1]) then
				table.remove(CiderTwo.blacklist, k);
				
				break;
			end;
		end;
	end;
end);

Clockwork.datastream:Hook("InviteAlliance", function(data)
	Derma_Query("Do you want to join the '"..data.."' alliance?", "Join Alliance", "Yes", function()
		Clockwork.datastream:Start("JoinAlliance", data);
		
		gui.EnableScreenClicker(false);
	end, "No", function()
		gui.EnableScreenClicker(false);
	end);
	
	gui.EnableScreenClicker(true);
end);

Clockwork.datastream:Hook("Notepad", function(data)
	if (CiderTwo.notepadPanel and CiderTwo.notepadPanel:IsValid()) then
		CiderTwo.notepadPanel:Close();
		CiderTwo.notepadPanel:Remove();
	end;
	
	CiderTwo.notepadPanel = vgui.Create("cw_Notepad");
	CiderTwo.notepadPanel:Populate(data or "");
	CiderTwo.notepadPanel:MakePopup();
	
	gui.EnableScreenClicker(true);
end);

Clockwork.datastream:Hook("CreateAlliance", function()
	Derma_StringRequest("Alliance", "What is the name of the alliance?", nil, function(text)
		Clockwork.datastream:Start("CreateAlliance", text);
	end);
end);

Clockwork.datastream:Hook("Death", function(data)
	if (!IsValid(data)) then
		CiderTwo.deathType = "UNKNOWN CAUSES";
	else
		local itemTable = Clockwork.item:GetByWeapon(data);
		local class = data:GetClass();
		
		if (itemTable) then
			CiderTwo.deathType = "A "..string.upper(itemTable.name);
		elseif (class == "cw_hands") then
			CiderTwo.deathType = "BEING PUNCHED TO DEATH";
		else
			CiderTwo.deathType = "UNKNOWN CAUSES";
		end;
	end;
end);

Clockwork.datastream:Hook("Stunned", function(data)
	local curTime = CurTime();
	
	if (!data or data == 0) then
		data = 2;
	end;
	
	CiderTwo.stunEffects[#CiderTwo.stunEffects + 1] = {curTime + data, data};
	CiderTwo.flashEffect = {curTime + (data * 2), data * 2};
end);

Clockwork.datastream:Hook("Flashed", function(data)
	local curTime = CurTime();
	
	CiderTwo.stunEffects[#CiderTwo.stunEffects + 1] = {curTime + 10, 10};
	CiderTwo.flashEffect = {curTime + 20, 20};
	
	surface.PlaySound("hl1/fvox/flatline.wav");
end);

Clockwork.datastream:Hook("TearGassed", function(data)
	CiderTwo.tearGassed = CurTime() + 20;
end);

Clockwork.datastream:Hook("GetHigh", function(data)
	CiderTwo.highEffects[#CiderTwo.highEffects + 1] = CurTime() + data;
end);

Clockwork.datastream:Hook("ClearEffects", function(data)
	CiderTwo.highEffects = {};
	CiderTwo.stunEffects = {};
	CiderTwo.flashEffect = nil;
	CiderTwo.tearGassed = nil;
end);

Clockwork.chatBox:RegisterClass("call_eavesdrop", "ic", function(info)
	if (info.shouldHear) then
		Clockwork.chatBox:Add(info.filtered, nil, Color(255, 255, 175, 255), info.name.." talks on their cell, \""..info.text.."\"");
	end;
end);

Clockwork.chatBox:RegisterClass("call", "ic", function(info)
	if (Clockwork.Client == info.speaker) then
		Clockwork.chatBox:Add(info.filtered, nil, Color(125, 255, 100, 255), info.name.." talks on their cell, \""..info.text.."\"");
	elseif (info.data.anon) then
		Clockwork.chatBox:Add(info.filtered, nil, Color(125, 255, 100, 255), "You are called by somebody, \""..info.text.."\"");
	else
		Clockwork.chatBox:Add(info.filtered, nil, Color(125, 255, 100, 255), "You are called by "..info.data.id..", \""..info.text.."\"");
	end;
end);

Clockwork.chatBox:RegisterClass("912_eavesdrop", "ic", function(info)
	if (info.shouldHear) then
		Clockwork.chatBox:Add(info.filtered, nil, Color(255, 255, 175, 255), info.name.." calls the secretaries, \""..info.text.."\"");
	end;
end);

Clockwork.chatBox:RegisterClass("912", "ic", function(info)
	if (info.data.anon) then
		Clockwork.chatBox:Add(info.filtered, nil, Color(125, 175, 50, 255), "Somebody calls the secretaries, \""..info.text.."\"");
	else
		Clockwork.chatBox:Add(info.filtered, nil, Color(125, 175, 50, 255), info.data.id.." calls the secretaries, \""..info.text.."\"");
	end;
end);

Clockwork.chatBox:RegisterClass("911_eavesdrop", "ic", function(info)
	if (info.shouldHear) then
		Clockwork.chatBox:Add(info.filtered, nil, Color(255, 255, 175, 255), info.name.." calls the police, \""..info.text.."\"");
	end;
end);

Clockwork.chatBox:RegisterClass("911", "ic", function(info)
	if (info.data.anon) then
		Clockwork.chatBox:Add(info.filtered, nil, Color(125, 175, 50, 255), "Somebody calls the police, \""..info.text.."\"");
	else
		Clockwork.chatBox:Add(info.filtered, nil, Color(125, 175, 50, 255), info.data.id.." calls the police, \""..info.text.."\"");
	end;
end);

Clockwork.chatBox:RegisterClass("headset_eavesdrop", "ic", function(info)
	if (info.shouldHear) then
		Clockwork.chatBox:Add(info.filtered, nil, Color(255, 255, 175, 255), info.name.." talks into their headset, \""..info.text.."\"");
	end;
end);

Clockwork.chatBox:RegisterClass("headset", "ic", function(info)
	Clockwork.chatBox:Add(info.filtered, nil, Color(125, 175, 50, 255), info.name.." talks into their headset, \""..info.text.."\"");
end);

Clockwork.chatBox:RegisterClass("lottery", "ooc", function(info)
	Clockwork.chatBox:Add(info.filtered, nil, Color(150, 100, 255, 255), info.text);
end);

Clockwork.chatBox:RegisterClass("advert", "ic", function(info)
	Clockwork.chatBox:Add(info.filtered, nil, Color(175, 150, 200, 255), "You notice an advert, it says \""..info.text.."\"");
end);

Clockwork.chatBox:RegisterClass("radio", "ic", function(info)
	Clockwork.chatBox:Add(info.filtered, nil, Color(75, 150, 50, 255), info.name.." radios in \""..info.text.."\"");
end);

Clockwork.chatBox:RegisterClass("president", "ic", function(info)
	Clockwork.chatBox:Add(info.filtered, nil, Color(200, 75, 125, 255), info.name.." broadcasts \""..info.text.."\"");
end);

Clockwork.chatBox:RegisterClass("killed", "ooc", function(info)
	local victim = info.data.victim;
	
	if (IsValid(victim)) then
		Clockwork.chatBox:Add(info.filtered, nil, victim, " has been killed by ", info.speaker, " (investigate the death).");
	end;
end);

Clockwork.chatBox:RegisterClass("broadcast", "ic", function(info)
	if (IsValid(info.data.entity)) then
		local name = info.data.entity:GetNetworkedString("name");
		
		if (name != "") then
			info.name = name;
		end;
	end;
	
	Clockwork.chatBox:Add(info.filtered, nil, Color(150, 125, 175, 255), info.name.." broadcasts \""..info.text.."\"");
end);

-- A function to get whether a text entry is being used.
function CiderTwo:IsTextEntryBeingUsed()
	if (self.textEntryFocused) then
		if (self.textEntryFocused:IsValid() and self.textEntryFocused:IsVisible()) then
			return true;
		end;
	end;
end;