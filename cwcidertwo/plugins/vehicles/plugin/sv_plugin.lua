--[[
	� 2013 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

Clockwork.kernel:AddFile("scripts/sounds/game_sounds_vehiclepack.txt");
Clockwork.kernel:AddFile("sound/vehicles/honk.wav");
Clockwork.kernel:AddFile("sound/police_siren.wav");
Clockwork.kernel:AddFile("models/tacoma2.mdl");

Clockwork.kernel:AddDirectory("materials/models/props_vehicles/car002a_01.*");
Clockwork.kernel:AddDirectory("materials/models/props/de_tides/truck001c_01.*");
Clockwork.kernel:AddDirectory("materials/models/props/de_tides/trucktires.*");
Clockwork.kernel:AddDirectory("materials/models/ill_hanger/vehicles/");
Clockwork.kernel:AddDirectory("materials/models/copcar/");
Clockwork.kernel:AddDirectory("sound/vehicles/truck/");
Clockwork.kernel:AddDirectory("sound/vehicles/enzo/");
Clockwork.kernel:AddDirectory("sound/vehicles/cf_mech*.*");
Clockwork.kernel:AddDirectory("sound/vehicles/digger_*.*");
Clockwork.kernel:AddDirectory("models/tideslkw.*");
Clockwork.kernel:AddDirectory("materials/corvette/");
Clockwork.kernel:AddDirectory("materials/golf/");
Clockwork.kernel:AddDirectory("models/corvette/");
Clockwork.kernel:AddDirectory("models/golf/");
Clockwork.kernel:AddDirectory("models/copcar.*");
Clockwork.kernel:AddDirectory("models/trabbi.*");
Clockwork.kernel:AddDirectory("scripts/vehicles/");

Clockwork.hint:Add("Horn", "Some vehicles have a horn, if it does you can honk it by pressing 'reload'.");
Clockwork.hint:Add("Vehicle", "Set the physical description of your vehicle by using the command $command_prefix$vehiclephysdesc.");

Clockwork.datastream:Hook("VehiclePhysDesc", function(player, data)
	if (type(data) == "table" and player.vehiclePhysDesc and data[1] == player.vehiclePhysDesc) then
		local text = data[2];
		
		if (string.len(text) < 8) then
			Clockwork.player:Notify(player, "You did not specify enough text!");
			
			return;
		end;
		
		data[1].PhysDesc = Clockwork.kernel:ModifyPhysDesc(text);
		data[1]:SetNetworkedString("physDesc", data[1].PhysDesc);
	end;
end);

Clockwork.datastream:Hook("ManageCar", function(player, data)
	local vehicle = player:GetVehicle();

	if (IsValid(vehicle)) then
		local parentVehicle = vehicle:GetParent();
		
		if (!IsValid(parentVehicle)) then
			if (vehicle.cwItemTable) then
				parentVehicle = vehicle;
			end;
		end;
		
		if (player:InVehicle() and IsValid(parentVehicle) and parentVehicle.cwItemTable) then
			if (parentVehicle:GetDriver() == player) then
				if (data == "unlock") then
					parentVehicle.IsLocked = false;
					parentVehicle:EmitSound("doors/door_latch3.wav");
					parentVehicle:Fire("unlock", "", 0);
				elseif (data == "lock") then
					parentVehicle.IsLocked = true;
					parentVehicle:EmitSound("doors/door_latch3.wav");
					parentVehicle:Fire("lock", "", 0);
				elseif (data == "horn") then
					if (parentVehicle.cwItemTable.PlayHornSound) then
						parentVehicle.cwItemTable:PlayHornSound(player, parentVehicle);
					elseif (parentVehicle.cwItemTable.hornSound) then
						parentVehicle:EmitSound(parentVehicle.cwItemTable.hornSound);
					end;
				end;
			end;
		end;
	end;
end);

-- A function to get whether a player does have a police car.
function cwVehicles:DoesPlayerHavePoliceCar(player)
	if (player:HasItemByID("police_car")) then
		return true;
	end;
	
	if (player.vehicles) then
		for k, v in pairs(player.vehicles) do
			if (IsValid(k) and v.uniqueID == "police_car") then
				return true;
			end;
		end;
	end;
end;

-- A function to take a player's police car.
function cwVehicles:PlayerTakePoliceCar(player)
	if (player.vehicles) then
		for k, v in pairs(player.vehicles) do
			if (v.uniqueID == "police_car") then
				if (IsValid(k)) then
					k:Remove();
				end;
				
				player.vehicles[k] = nil;
			end;
		end;
	end;
end;

-- A function to get whether a player can have a police car.
function cwVehicles:CanPlayerHavePoliceCar(player)
	local hasCar = 0;
	local amount = 0;
	
	for k, v in ipairs(cwTeam.GetPlayers(CLASS_POLICE)) do
		if (v:HasInitialized()) then
			if (self:DoesPlayerHavePoliceCar(v)) then
				hasCar = hasCar + 1;
			end;
			
			amount = amount + 1;
		end;
	end;
	
	if (hasCar < (amount / 3)) then
		return true;
	else
		return false;
	end;
end;

-- A function to get a vehicle exit for a player.
function cwVehicles:GetVehicleExit(player, vehicle)
	local available = {};
	local closest = {};
	
	if (vehicle.cwItemTable and vehicle.cwItemTable.customExits) then
		for k, v in ipairs(vehicle.cwItemTable.customExits) do
			local position = vehicle:LocalToWorld(v);
			local entities = ents.FindInSphere(position, 1);
			local unsafe = nil;
			
			for k2, v2 in ipairs(entities) do
				if (player != v2 and v2:IsPlayer()) then
					unsafe = true;
					
					break;
				end;
			end;
			
			if (util.IsInWorld(position) and !unsafe) then
				available[#available + 1] = position;
			end;
		end;
	end;
	
	for k, v in ipairs(self.normalExits) do
		local attachment = vehicle:GetAttachment(vehicle:LookupAttachment(v));
		
		if (attachment) then
			local position = attachment.Pos;
			local entities = ents.FindInSphere(position, 1);
			local unsafe = nil;
			
			for k2, v2 in ipairs(entities) do
				if (player != v2 and v2:IsPlayer()) then
					unsafe = true;
					
					break;
				end;
			end;
			
			if (!unsafe and util.IsInWorld(position)) then
				available[#available + 1] = position;
			end;
		end;
	end;
	
	for k, v in ipairs(available) do
		local distance = player:GetPos():Distance(v);
		
		if (!closest[1] or distance < closest[1]) then
			closest[1] = distance;
			closest[2] = v;
		end;
	end;

	if (closest[2]) then
		Clockwork.player:SetSafePosition(player, closest[2]);
	end;
end;

-- A function to make a player exit a vehicle.
function cwVehicles:MakeExitVehicle(player, vehicle)
	player:SetVelocity(Vector(0, 0, 0));

	if (!player:InVehicle()) then
		local parentVehicle = vehicle:GetParent();
		
		if (IsValid(parentVehicle)) then
			self:GetVehicleExit(player, parentVehicle);
		else
			self:GetVehicleExit(player, vehicle);
		end;
	end;
end;

-- A function to spawn a vehicle.
function cwVehicles:SpawnVehicle(player, itemTable)
	if (itemTable:GetData("IsUsed")) then
		Clockwork.player:Notify(player, "You have already spawned this "..itemTable.name..", go and look for it!");

		return false;
	else
		local eyeTrace = player:GetEyeTraceNoCursor();

		if (player:GetPos():Distance(eyeTrace.HitPos) <= 512) then
			local trace = util.QuickTrace(eyeTrace.HitPos, eyeTrace.HitNormal * 100000);

			if (!trace.HitSky) then
				Clockwork.player:Notify(player, "You can only spawn a vehicle outside!");

				return false;
			end;

			local vehicleEntity, fault = self:MakeVehicle(player, itemTable, eyeTrace.HitPos + Vector(0, 0, 32), Angle(0, player:GetAngles().yaw + 180, 0));

			if (!IsValid(vehicleEntity)) then
				if (fault) then
					Clockwork.player:Notify(player, fault);
				end;

				return false;
			end;

			if (itemTable.skin) then
				vehicleEntity:SetSkin(itemTable.skin);
			end;

			vehicleEntity.m_tblToolsAllowed = {"remover"};
			
			-- Called when a player attempts to use a tool.
			function vehicleEntity:CanTool(player, trace, tool)
				return (mode == "remover" and player:IsAdmin());
			end;

			Clockwork.player:GiveProperty(player, vehicleEntity, true);

			player.vehicles[vehicleEntity] = itemTable;

			return vehicleEntity;
		else
			Clockwork.player:Notify(player, "You cannot spawn a vehicle that far away!");

			return false;
		end;
	end;
end;

-- A function to make a vehicle.
function cwVehicles:MakeVehicle(player, itemTable, position, angles)
	local vehicleEntity = ents.Create(itemTable.class);

	vehicleEntity:SetModel(itemTable.model);

	if (itemTable.keyValues) then
		for k, v in pairs(itemTable.keyValues) do
			vehicleEntity:SetKeyValue(k, v);
		end		
	end;

	vehicleEntity:SetAngles(angles);
	vehicleEntity:SetPos(position);
	vehicleEntity:Spawn();
	vehicleEntity:Activate();
	vehicleEntity:SetUseType(SIMPLE_USE);
	
	local physicsObject = vehicleEntity:GetPhysicsObject();

	if (!IsValid(physicsObject)) then
		return false, "The physics object for this vehicle is not valid!";
	end

	if (physicsObject:IsPenetrating()) then
		vehicleEntity:Remove();

		return false, "A vehicle cannot be spawned at this location!";
	end

	itemTable:SetData("IsUsed", true);
	itemTable:NetworkData();
	
	vehicleEntity.cwItemTable = itemTable;
	
	Clockwork.item:AddItemEntity(vehicleEntity, itemTable);

	vehicleEntity.VehicleName = itemTable.name;
	vehicleEntity.ClassOverride = itemTable.class;

	local localPosition = vehicleEntity:GetPos();
	local localAngles = vehicleEntity:GetAngles();

	if (itemTable.passengers) then		
		local seatName = itemTable.seatType;
		local seatData = list.Get("Vehicles")[seatName];

		for k, v in pairs(itemTable.passengers) do
			local seatPosition = localPosition + (localAngles:Forward() * v.position.x) + (localAngles:Right() * v.position.y) + (localAngles:Up() * v.position.z);
			local seatEntity = ents.Create("prop_vehicle_prisoner_pod");

			seatEntity:SetKeyValue("vehiclescript", "scripts/vehicles/prisoner_pod.txt");
			seatEntity:SetAngles(localAngles + v.angles);
			seatEntity:SetModel(seatData.Model);
			seatEntity:SetPos(seatPosition);
			seatEntity:Spawn();

			seatEntity:Activate();
			seatEntity:Fire("lock", "", 0);

			seatEntity:SetCollisionGroup(COLLISION_GROUP_WORLD);
			seatEntity:SetParent(vehicleEntity);
			
			if (itemTable.useLocalPositioning) then
				seatEntity:SetLocalPos(v.position);
				seatEntity:SetLocalAngles(v.angles);
			end;

			if (itemTable.hideSeats) then
				seatEntity:SetColor(Color(255, 255, 255, 0));
			end;

			if (seatData.Members) then
				table.Merge(seatEntity, seatData.Members);
			end;

			if (seatData.KeyValues) then
				for k2, v2 in pairs(seatData.KeyValues) do
					seatEntity:SetKeyValue(k2, v2);
				end;
			end;

			seatEntity:DeleteOnRemove(vehicleEntity);
			seatEntity.ClassOverride = "prop_vehicle_prisoner_pod";
			seatEntity.VehicleTable = seatData
			seatEntity.VehicleName = "Jeep Seat";

			if (!vehicleEntity.Passengers) then
				vehicleEntity.Passengers = {};
			end;

			vehicleEntity.Passengers[k] = seatEntity;
		end;
	end;

	return vehicleEntity;
end;