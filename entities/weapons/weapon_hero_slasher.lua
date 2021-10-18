SWEP.Base = "hero_base"

function SWEP:CreateAbilities()
    -- Create abilities
    self.PrimaryAbility = AbilityController:create(self:GetOwner())
    self.SecondaryAbility = AbilityController:create(self:GetOwner())
    self.Abilities[AbilityPosition.PRIMARY] = self.PrimaryAbility
    self.Abilities[AbilityPosition.SECONDARY] = self.SecondaryAbility

    self.PrimaryAbility.display = "Punch"
    self.PrimaryAbility.name = "slasher_primary_punch"
    self.PrimaryAbility.base_cooldown = 5
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
    --ent:SetCollisionGroup(COLLISION_GROUP_PLAYER_MOVEMENT)
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
	function PhysicsCollide(ent, data)
		if (!IsValid(ent)) then ent:Remove() return end
		if (data.HitEntity:GetClass() == "player" and data.HitEntity ~= ent) then
            -- Proc on-hit effects
            self.SecondaryAbility:activateOnHit(data.HitPos)
            
            -- Do damage
            data.HitEntity:TakeDamage(self.SecondaryAbility:getDamage(), self.Owner, ent)
		else
		end
		ent:Remove()
	end
	
	ent:AddCallback("PhysicsCollide", PhysicsCollide) 
	
    -- Apply force and remove gravity
	local ply_aimvector = self.Owner:GetAimVector()
    local ply_velocity = self.Owner:GetVelocity()
    local multiplier = (ply_velocity:LengthSqr() * 0.085)

    -- Apply minimum to multiplier
    multiplier = math.min(1500)

    local ent_velocity = ply_aimvector * multiplier

	ent_phys:ApplyForceCenter(ent_velocity)
    ent_phys:EnableGravity(false)
end