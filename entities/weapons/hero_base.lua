SWEP.Base = "weapon_base"
SWEP.Abilities = {} -- [AbilityController]

SWEP.ViewModel = "models/weapons/c_arms.mdl"
SWEP.WorldModel = ""

SWEP.Spawnable = false
SWEP.DrawAmmo = false
SWEP.StoredAmmo = 0

--- Get ability by name from weapon ability list
--- @param name string: Weapon ability name / ID
--- @return AbilityController: found ability OR nil if nothing found
function SWEP:GetWeaponAbility(name)
	for _, ability in ipairs(self.Abilities) do
		if (ability.name == name) then
			return ability
		end
	end

	return nil
end

function SWEP:Initialize()
	if (self.CreateAbilities ~= nil) then
		self:CreateAbilities()
	end

	if (SERVER) then
		-- HERO_ABILITY_CD_GET - Request
		-- Client asks server for cooldown timer
		-- Client sends request code with data == ability name
		-- Server replies in format "AbilityName;CooldownData", where cooldown data is 0 if ability is ready OR cooldown data is the time the ability will be ready at
		hook.Add("ObNetRequest", "OB:SWEPBase.HERO_ABILITY_CD_GET:0", function(request_code, data, ply) 
			if (ply == self.Owner and request_code == NetworkDefinitions.CSRequestCode.HERO_ABILITY_CD_GET) then
				local ability = self:GetWeaponAbility(data)

				if (ability == nil) then
					-- Ability doesn't exist
					send_response_to_client(ply, request_code, NetworkDefinitions.ResponseCode.FailGeneric, "ABILITY_NOT_FOUND")
					return
				end

				-- Send ability cooldown
				local cd_data = 0
				local is_on_cooldown = ability:getCooldownStatus()

				if (is_on_cooldown) then
					-- If not on cooldown, send the time (in CurTime()) that the ability will be ready at
					cd_data = CurTime() + ability:getCooldownLength()
				end

				-- Response string should be AbilityName;CooldownData
				local response_string = ability.name .. ";" .. cd_data
				send_response_to_client(ply, request_code, NetworkDefinitions.ResponseCode.OKGeneric, response_string)
			end
		end)
	end

	if (CLIENT) then
		-- HERO_ABILITY_CD_GET - Response,
		-- Response from server after client asks for cooldown timer
		hook.Add("ObNetResponse", "OB:SWEPBase.HERO_ABILITY_CD_GET:1", function(request_code, response_code, data)
			if (request_code ~= NetworkDefinitions.CSRequestCode.HERO_ABILITY_CD_GET) then
				return
			end

			if (response_code != NetworkDefinitions.ResponseCode.OKGeneric) then
				print("Failed to get ability cooldown from server: Code " .. response_code)
				return
			end
			
			local data_split = string.Split(data, ";") -- [ability name, cd data]
			local name = data_split[1]
			local cooldown_data = tonumber(data_split[2])
	
			-- Get player ability
			local ability = self:GetWeaponAbility(name)

			-- Set ability ready time
			ability:setClientReadyTime(cooldown_data)
		end)

		-- HERO_ABILITY_CD_READY - Request,
		-- Server notifying client that a cooldown is ready
		hook.Add("ObNetRequest", "OB:SWEPBase.HERO_ABILITY_CD_READY:0", function(request_code, data)
			if (request_code == NetworkDefinitions.SCRequestCode.HERO_ABILITY_CD_READY) then
				-- Get player ability
				local ability = self:GetWeaponAbility(data)

				-- Set ability ready time
				ability:setClientReadyTime(0)
			end
		end)
	end
end

function SWEP:CanPrimaryAttack()
	return false
end

function SWEP:CanSecondaryAttack()
	return false
end

function SWEP:PrimaryAttack() return print("Base weapon has no attack") end

function SWEP:SecondaryAttack(...) 
	local arg = arg or {}
	self:PrimaryAttack(unpack(arg)) 
end