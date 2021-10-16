SWEP.Base = "weapon_base"
SWEP.Abilities = {} -- [AbilityController]

SWEP.ViewModel = "models/weapons/c_arms.mdl"
SWEP.WorldModel = ""

SWEP.Spawnable = false
SWEP.DrawAmmo = false
SWEP.StoredAmmo = 0

function SWEP:Initialize()
	if (self.CreateAbilities ~= nil) then
		self:CreateAbilities()
	end

	if (SERVER) then
		hook.Add("ObNetRequest", "OB:SWEPBase.0", function(request_code, response_code, data, ply) 
			if (ply == self.Owner and request_code == NetworkDefinitions.CSRequestCode.HERO_ABILITY_RCD_GET) then
				-- Client requested cooldown
				for _, ability in ipairs(self.Abilities) do
					if (ability.name == data) then
						-- Send ability cooldown
						local response_data = 0
						local is_on_cooldown, progress = ability:getCooldownStatus()

						if (!is_on_cooldown) then
							-- If not on cooldown, send the time (in CurTime()) that the ability will be ready at
							response_data = CurTime() + progress
						end
						send_response_to_client(ply, request_code, NetworkDefinitions.ResponseCode.OKGeneric, response_data)
						return
					end
				end
				send_response_to_client(ply, request_code, NetworkDefinitions.ResponseCode.FailGeneric, "ABILITY_NOT_FOUND")
			end
		end)
	end

	if (CLIENT) then
		
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