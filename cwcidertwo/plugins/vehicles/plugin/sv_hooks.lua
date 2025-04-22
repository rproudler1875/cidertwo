--[[
	� 2013 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

-- Called when a player's character data should be saved.
function cwVehicles:PlayerSaveCharacterData(player, data) end;

-- Called when a player's class has been set.
function cwVehicles:PlayerClassSet(player, newClass, oldClass, noRespawn, addDelay, noModelChange)
	if (newClass.index == CLASS_POLICE) then
		if (!self:DoesPlayerHavePoliceCar(player)) then
			if (self:CanPlayerHavePoliceCar(player)) then
				player:GiveItem(Clockwork.item:CreateInstance("police_car"));
				
				for k, v in ipairs(cwPlayer.GetAll()) do
					local team = v:Team();
					
					if (team == CLASS_POLICE or team == CLASS_DISPENSER or team == CLASS_RESPONSE) then
						Clockwork.player:Notify(v, player:Name().." has been given a police car to share with other cops.");
					end;
				end;
			end;
		end;
	else
		local itemTable = player:FindItemByID("police_car");

		if (itemTable) then
			player:TakeItem(itemTable, true);
			self:PlayerTakePoliceCar(player);
		end;
		
		for k, v in ipairs(cwTeam.GetPlayers(CLASS_POLICE)) do
			if (v:HasInitialized() and !self:DoesPlayerHavePoliceCar(v)) then
				if (self:CanPlayerHavePoliceCar(v)) then
					v:GiveItem(Clockwork.item:CreateInstance("police_car"));
					
					for k2, v2 in ipairs(cwPlayer.GetAll()) do
						local team = v2:Team();
						
						if (team == CLASS_POLICE or team == CLASS_DISPENSER or team == CLASS_RESPONSE) then
							Clockwork.player:Notify(v2, v:Name().." has been given a police car to share with other cops.");
						end;
					end;
				end;
			end;
		end;
	end;
end;

-- Called when a player's shared variables should be set.
function cwVehicles:PlayerSetSharedVars(player, curTime) end;

-- Called at an interval while a player is connected.
function cwVehicles:PlayerThink(player, curTime, infoTable)
	local isValidVehicle = false;
	
	if (player:InVehicle()) then
		local vehicle = player:GetVehicle();
		
		if (IsValid(vehicle) and vehicle.cwItemTable) then
			local velocity = vehicle:GetVelocity():Length();
			local fuel = vehicle.cwItemTable:GetData("Fuel");
			
			if (velocity > 0) then
				fuel = math.Clamp(fuel - (velocity / 48000), 0, 100);
			end;

			if (fuel == 0) then
				local physicsObject = vehicle:GetPhysicsObject();

				if (IsValid(physicsObject)) then
					physicsObject:SetVelocity(physicsObject:GetVelocity() * -1);
				end;
			end;
			
			vehicle.cwItemTable:SetData("Fuel", fuel);
			
			if (not player.cwNextVehicleFuelTime or CurTime() > player.cwNextVehicleFuelTime) then
				vehicle.cwItemTable:NetworkData();
				player.cwNextVehicleFuelTime = CurTime() + 2;
			end;
			
			isValidVehicle = true;
		end;
		
		local parentVehicle = vehicle:GetParent();

		if (IsValid(parentVehicle) and parentVehicle.cwItemTable) then
			if (!IsValid(parentVehicle:GetDriver())) then
				player:ExitVehicle();
			end;
		end;
	end;
end;

-- A function to scale damage by hit group.
function cwVehicles:PlayerScaleDamageByHitGroup(player, attacker, hitGroup, damageInfo, baseDamage)
	if (player:InVehicle()) then
		local damagePosition = damageInfo:GetDamagePosition();
		local vehicle = player:GetVehicle();
		
		if (vehicle.cwItemTable) then
			if (player:GetPos():Distance(damagePosition) > 96
			and !damageInfo:IsExplosionDamage()) then
				damageInfo:SetDamage(0);
			end;

			if (vehicle.IsLocked) then
				vehicle.IsLocked = false;
				vehicle:EmitSound("doors/door_latch3.wav");
				vehicle:Fire("unlock", "", 0);
			end;
			
			if (vehicle.Passengers) then
				timer.Simple(FrameTime() * 0.5, function()
					if (IsValid(vehicle) and IsValid(player)) then
						for k, v in pairs(vehicle.Passengers) do
							if (IsValid(v)) then
								local driver = v:GetDriver();

								if (IsValid(driver) and driver != player) then
									if (driver:GetPos():Distance(damagePosition) <= 96
									or damageInfo:IsExplosionDamage()) then
										damageInfo:SetDamage(baseDamage);

										driver:TakeDamageInfo(damageInfo);
									end;
								end;
							end;
						end;
					end;
				end);
			end;
		end;
	elseif ((attacker:IsPlayer() and attacker:InVehicle())
	or attacker:IsVehicle()) then
		if (baseDamage >= 50) then
			Clockwork.player:SetRagdollState(player, RAGDOLL_KNOCKEDOUT, 20);
			
			damageInfo:ScaleDamage(0.5);
		end;
	end;
end;

-- Called when a player's character has loaded.
function cwVehicles:PlayerCharacterLoaded(player)
	local itemsList = Clockwork.inventory:GetAsItemsList(
		player:GetInventory()
	);
	
	for k, v in pairs(itemsList) do
		if (v:IsBasedFrom("vehicle_base")) then
			v:SetData("IsUsed", false);
		end;
	end;
	
	player.vehicles = {};
end;

-- Called when a player attempts to pickup an entity with the physics gun.
function cwVehicles:PhysgunPickup(player, entity)
	if (entity:IsVehicle() and entity.cwItemTable and !player:IsUserGroup("operator") and !player:IsAdmin()) then
		return false;
	end;
end;

-- Called when a player's inventory string is needed.
function cwVehicles:PlayerGetInventoryString(player, character, inventory)
	if (player.vehicles) then
		for k, v in pairs(player.vehicles) do
			if (IsValid(k)) then
				if (inventory[v.uniqueID]) then
					inventory[v.uniqueID] = inventory[v.uniqueID] + 1;
				else
					inventory[v.uniqueID] = 1;
				end;
			end;
		end;
	end;
end;

-- Called when a player attempts to lock an entity.
function cwVehicles:PlayerCanLockEntity(player, entity)
	if (entity:IsVehicle() and entity.cwItemTable) then
		if (entity.cwItemTable.uniqueID == "police_car") then
			local team = player:Team();
			
			if (team == CLASS_POLICE or team == CLASS_DISPENSER or team == CLASS_RESPONSE) then
				return true;
			end;
		end;
		
		return Clockwork.entity:GetOwner(entity) == player;
	end;
end;

-- Called when a player attempts to unlock an entity.
function cwVehicles:PlayerCanUnlockEntity(player, entity)
	if (entity:IsVehicle() and entity.cwItemTable) then
		if (entity.cwItemTable.uniqueID == "police_car") then
			local team = player:Team();
			
			if (team == CLASS_POLICE or team == CLASS_DISPENSER or team == CLASS_RESPONSE) then
				return true;
			end;
		end;
		
		return Clockwork.entity:GetOwner(entity) == player;
	end;
end;

-- Called when a player's unlock info is needed.
function cwVehicles:PlayerGetUnlockInfo(player, entity)
	if (entity:IsVehicle() and entity.cwItemTable) then
		return {
			duration = Clockwork.config:Get("unlock_time"):Get(),
			Callback = function(player, entity)
				entity.IsLocked = false;
				entity:Fire("unlock", "", 0);
			end
		};
	end;
end;

-- Called when a player's lock info is needed.
function cwVehicles:PlayerGetLockInfo(player, entity)
	if (entity:IsVehicle() and entity.cwItemTable) then
		return {
			duration = Clockwork.config:Get("lock_time"):Get(),
			Callback = function(player, entity)
				entity.IsLocked = true;
				entity:Fire("lock", "", 0);
			end
		};
	end;
end;

-- Called when a player has disconnected.
function cwVehicles:PlayerCharacterUnloaded(player)
	if (player.vehicles) then
		for k, v in pairs(player.vehicles) do
			if (IsValid(k)) then
				player.vehicles[k]:SetData("IsUsed", false);
				k:Remove();
			end;
		end;
	end;
end;

-- Called when a player leaves a vehicle.
function cwVehicles:PlayerLeaveVehicle(player, vehicle)
	player.nextEnterVehicle = CurTime() + 2;
	player:SetVelocity(Vector(0, 0, 0));

	timer.Simple(FrameTime() * 2, function()
		if (IsValid(player) and IsValid(vehicle) and !player:InVehicle()) then
			self:MakeExitVehicle(player, vehicle);
		end;
	end);
end;

-- Called when a player attempts to enter a vehicle.
function cwVehicles:CanPlayerEnterVehicle(player, vehicle, role)
	if (player.nextEnterVehicle and player.nextEnterVehicle >= CurTime()) then
		return false;
	end;

	if (vehicle.IsLocked) then
		return false;
	end;
end;

-- Called when a player attempts to exit a vehicle.
function cwVehicles:CanExitVehicle(vehicle, player)
	if (player.nextExitVehicle and player.nextExitVehicle >= CurTime()) then
		return false;
	end;

	local parentVehicle = vehicle:GetParent();

	if (IsValid(parentVehicle) and parentVehicle.cwItemTable) then
		return false;
	end;

	if (vehicle.IsLocked) then
		return false;
	end;
end;

-- Called when a player presses a key.
function cwVehicles:KeyPress(player, key)
	if (player:InVehicle()) then
		if (key == IN_USE) then
			local vehicle = player:GetVehicle();
			local parentVehicle = vehicle:GetParent();

			if (IsValid(parentVehicle) and parentVehicle.cwItemTable) then
				if (!parentVehicle.IsLocked) then
					player:ExitVehicle();
				end;
			end;
		end;
	end;
end;

-- Called when a player uses an entity.
function cwVehicles:PlayerUse(player, entity, testing)
	local curTime = CurTime();

	if (!entity:IsVehicle()) then
		return;
	end;

	if (player:InVehicle()) then
		if (player.nextExitVehicle and player.nextExitVehicle >= curTime) then
			return false;
		else
			local parentVehicle = player:GetVehicle():GetParent();

			if (IsValid(parentVehicle) and parentVehicle.cwItemTable) then
				return false;
			else
				return;
			end;
		end;
	end;

	if (!entity.IsLocked and entity.cwItemTable and player:KeyDown(IN_USE)) then
		local position = player:GetEyeTraceNoCursor().HitPos;
		local validSeat = nil;
		
		if (entity.Passengers and IsValid(entity:GetDriver())) then
			for k, v in pairs(entity.Passengers) do
				if (IsValid(v) and v:IsVehicle() and !IsValid(v:GetDriver())) then
					local distance = v:GetPos():Distance(position);
					
					if (!validSeat or distance < validSeat[1]) then
						validSeat = {distance, v};
					end;
				end;
			end;
			
			if (validSeat and IsValid(validSeat[2])) then
				player.nextExitVehicle = curTime + 2;

				validSeat[2]:Fire("unlock", "", 0);
					timer.Simple(FrameTime() * 0.5, function()
						if (IsValid(player) and IsValid(validSeat[2])) then
							player:EnterVehicle(validSeat[2]);
						end;
					end);
				validSeat[2]:Fire("lock", "", 1);
			end;

			return false;
		end;
	end;

	if (player:GetSharedVar("tied") != 0) then
		return false;
	end;
end;