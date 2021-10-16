SWEP.Base = "hero_base"

function SWEP:CreateAbilities()
    -- Create abilities
    self.PrimaryAbility = AbilityController:create(self:GetOwner())
    self.SecondaryAbility = AbilityController:create(self:GetOwner())
    self.Abilities[AbilityPosition.PRIMARY] = self.PrimaryAbility
    self.Abilities[AbilityPosition.SECONDARY] = self.SecondaryAbility

    self.PrimaryAbility.display = "Punch"
    self.PrimaryAbility.name = "slasher_primary_punch"
    self.PrimaryAbility.base_cooldown = 1
    self.PrimaryAbility.base_damage = 10

    self.SecondaryAbility.display = "Guiding Spike"
    self.SecondaryAbility.name = "slasher_secondary_spike"
    self.SecondaryAbility.base_cooldown = 1
    self.SecondaryAbility.base_damage = 5
end

function SWEP:PrimaryAttack()
    local isOnCooldown, progress = self.PrimaryAbility:getCooldownStatus()
    
    if (isOnCooldown) then
        print("ability not ready, progress: " .. progress)
        return
    end

    self.PrimaryAbility:resetCooldownProgress()
end

function SWEP:SecondaryAttack()
    local isOnCooldown, progress = self.SecondaryAbility:getCooldownStatus()
    
    if (isOnCooldown) then
        print("ability not ready, progress: " .. progress)
        return
    end

    self.SecondaryAbility:resetCooldownProgress()

    -- Server only from this point on
    if CLIENT then
        return 
    end 
	
	local efx = EffectData()
    local ent = ents.Create("prop_physics")

    -- Set up effect
	efx:SetOrigin(self.Owner:GetPos() + self.Owner:GetAimVector())
	util.Effect("ElectricSpark", efx)
	
    -- Make sure Entity is real
	if (!IsValid(ent)) then 
        return 
    end
	
    -- Create the entity
	ent.CreationTime = CurTime()
	ent:SetModel("models/props_lab/huladoll.mdl")
	ent:SetPos(self.Owner:EyePos() + (self.Owner:GetAimVector() * 25))
	ent:SetAngles(self.Owner:EyeAngles())
	ent.Direction = self.Owner:GetAimVector()
	ent.Attacker = self.Owner
	ent:Spawn()
	
    -- Set up the physics object
	local ent_phys = ent:GetPhysicsObject()
	if (!IsValid(ent_phys)) then 
        ent:Remove() 
        print("entity phys object not real!")
        return 
    end
	
    -- Handle collision
	function PhysicsCollide( ent, data )
		if (!IsValid(ent)) then ent:Remove() return end
		if (data.HitEntity:GetClass() == "player") then
			ent.Attacker:GetActiveWeapon().Alternate.LastAction = 0
		else
		end
		ent:Remove()
	end
	
	ent:AddCallback("PhysicsCollide", PhysicsCollide) 
	
    -- Apply force and remove gravity
	local velocity = self.Owner:GetAimVector()
	velocity = velocity * 2000
	ent_phys:ApplyForceCenter(velocity)
    ent_phys:EnableGravity(false)
end