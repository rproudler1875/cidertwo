--[[
	� 2013 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

local BLUE_SIREN_LOCAL = Vector(-0.6974, -41.8885, 66.1966);
local RED_SIREN_LOCAL = Vector(-43.1840, -41.8382, 66.3215);

cwVehicles.policeCars = {};
cwVehicles.getPoliceCarsTime = 0;
cwVehicles.nextRedDynamicLight = 0;
cwVehicles.nextBlueDynamicLight = 0;

-- Called each frame.
function cwVehicles:Think()
	local curTime = UnPredictedCurTime();
	
	if (curTime >= self.getPoliceCarsTime) then
		self.getPoliceCarsTime = curTime + 4;
		
		for k, v in ipairs(ents.FindByClass("prop_vehicle_jeep")) do
			if (v:GetModel() == "models/copcar.mdl") then
				table.insert(self.policeCars, v);
			end;
		end;
		
		for k, v in ipairs(self.policeCars) do
			if (!IsValid(v)) then
				table.remove(self.policeCars, k);
			end;
		end;
	end;
	
	if (curTime >= self.nextRedDynamicLight) then
		self.nextRedDynamicLight = curTime + 1;
		self.nextBlueDynamicLight = curTime + 0.5;
		
		for k, v in ipairs(self.policeCars) do
			if (IsValid(v) and v:GetNetworkedBool("siren")) then
				local dynamicLight = DynamicLight("siren_red");
				local sirenPos = v:LocalToWorld(RED_SIREN_LOCAL);
				
				if (!v.NextSirenSoundTime or curTime >= v.NextSirenSoundTime) then
					v.NextSirenSoundTime = curTime + 4;
					v:EmitSound("police_siren.wav", 100, 100);
				end;
				
				if (dynamicLight) then
					dynamicLight.Brightness = 8;
					dynamicLight.DieTime = curTime + 0.5;
					dynamicLight.Decay = 256;
					dynamicLight.Size = 256;
					dynamicLight.Pos = sirenPos;
					dynamicLight.r = 255;
					dynamicLight.g = 0;
					dynamicLight.b = 0;
				end;
			end;
		end;
	elseif (curTime >= self.nextBlueDynamicLight) then
		self.nextBlueDynamicLight = curTime + 0.5;
		
		for k, v in ipairs(self.policeCars) do
			if (IsValid(v) and v:GetNetworkedBool("siren")) then
				local dynamicLight = DynamicLight("siren_blue");
				local sirenPos = v:LocalToWorld(BLUE_SIREN_LOCAL);
				
				if (dynamicLight) then
					dynamicLight.Brightness = 8;
					dynamicLight.DieTime = curTime + 0.5;
					dynamicLight.Decay = 256;
					dynamicLight.Size = 256;
					dynamicLight.Pos = sirenPos;
					dynamicLight.r = 0;
					dynamicLight.g = 0;
					dynamicLight.b = 255;
				end;
			end;
		end;
	end;
end;

function cwVehicles:GetVehicleItemTable(vehicle)
	if (not Clockwork.entity:HasFetchedItemData(vehicle)) then
		Clockwork.entity:FetchItemData(vehicle);
	end;
	
	return Clockwork.entity:FetchItemTable(vehicle);
end;

-- Called when the calc view table should be adjusted.
function cwVehicles:CalcViewAdjustTable(view)
	if (Clockwork.Client:InVehicle()) then
		local vehicle = Clockwork.Client:GetVehicle();
		local itemTable = self:GetVehicleItemTable(vehicle);

		if (itemTable and itemTable.calcView) then
			view.origin = view.origin + itemTable.calcView;
		end;
	end;
end;

-- Called when a player presses a bind.
function cwVehicles:PlayerBindPress(player, bind, pressed)
	if (player:InVehicle()) then
		if (string.find(bind, "+attack2")) then
			Clockwork.datastream:Start("ManageCar", "unlock");
		elseif (string.find(bind, "+attack")) then
			Clockwork.datastream:Start("ManageCar", "lock");
		elseif (string.find(bind, "+reload")) then
			Clockwork.datastream:Start("ManageCar", "horn");
		end;
	end;
end;

-- Called when the bars are needed.
function cwVehicles:GetBars(bars)
	if (Clockwork.Client:InVehicle()) then
		local vehicle = Clockwork.Client:GetVehicle();
		local itemTable = self:GetVehicleItemTable(vehicle);
		
		if (itemTable) then
			local fuel = itemTable:GetData("Fuel");

			if (self.fuel) then
				self.fuel = math.Approach(self.fuel, fuel, 1);
			else
				self.fuel = fuel;
			end;
			
			bars:Add("FUEL", Color(175, 50, 200, 255), "Fuel", self.fuel, 100, self.fuel < 10);
		end;
	end;
end;

-- Called when an entity's target ID HUD should be painted.
function cwVehicles:HUDPaintEntityTargetID(entity, info)
	local colorTargetID = Clockwork.option:GetColor("target_id");
	local colorWhite = Clockwork.option:GetColor("white");
	
	if (!Clockwork.Client:InVehicle() and entity:GetClass() == "prop_vehicle_jeep") then
		local wrappedTable = {};
		
		local itemTable = self:GetVehicleItemTable(entity);
		
		if (itemTable) then
			local physDesc = itemTable:GetData("PhysDesc");
			
			if (physDesc == "") then
				if (itemTable.vehiclePhysDesc) then
					physDesc = Clockwork.kernel:ModifyPhysDesc(itemTable.vehiclePhysDesc);
				end;
			end;
			
			info.y = Clockwork.kernel:DrawInfo(itemTable.name, info.x, info.y, colorTargetID, info.alpha);

			if (physDesc != "") then
				Clockwork.kernel:WrapText(physDesc, Clockwork.option:GetFont("target_id_text"), math.max(ScrW() / 8, 384), wrappedTable);
				
				for k, v in ipairs(wrappedTable) do
					info.y = Clockwork.kernel:DrawInfo(v, info.x, info.y, colorWhite, info.alpha);
				end;
			end;
		end;
	end;
end;