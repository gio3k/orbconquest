-- DynamicMaterials: smarter VMT files
-- 2021, par0-git
-- please refer to this image: https://cdn.discordapp.com/attachments/508965036325339140/834419248486809650/unknown.png

include("vmt.lua")
DynamicMaterials = {}

DynamicMaterials = {
	Strings = {
		ID = "dym",
		VMT_KEY = "dym_material",
		VMT_LOCATION = "unset",
		VMT_EXT_PREFIX = "***:"
	},

	-- SERVER initServer() 
	-- Sets up everything serverside
	initServer = function()
		if (CLIENT) then return end
		
		-- Set up initial strings
		util.AddNetworkString("dym:load_ready")

		-- Set up hooks
		hook.Add("EntityKeyValue", "dym_hook:ent_key_value", function(ent, key, value)
			print(ent:GetName()..", key: "..key..", value: "..value)
			if (key:sub(1, #DynamicMaterials.Strings.ID) ~= DynamicMaterials.Strings.ID) then return end 

			-- Network values
			print("networked: " .. key .. " : " .. value)
			ent:SetNWString(key, value)
		end)
	end,

	-- CLIENT handle(Entity) 
	-- Loads material for provided entity
	handle = function(entity)
		if (SERVER) then return end

		local entityMaterialSRC = entity:GetNWString(DynamicMaterials.Strings.VMT_KEY)
		local entityMaterialVMT, entityMaterialVMTData

		-- Check for networked VMT file location
		if (entityMaterialSRC == "") then print("Entity provided has no dynamic VMT material.") return end

		-- Parse VMT
		entityMaterialVMT = VMTParser.parse(file.Read(DynamicMaterials.Strings.VMT_LOCATION .. entityMaterialSRC, "GAME"))

		-- Validate VMT
		if (entityMaterialVMT["VertexLitGeneric"] == nil) then print("Entity provided has no material with a VertexLitGeneric.") return end
		print("Found entity with a material!")

		-- Set entityMaterialVMTData
		entityMaterialVMTData = entityMaterialVMT["VertexLitGeneric"]
		
		-- Set variables for new material
		local resultMaterial, resultMaterialName
		resultMaterialName = "__dym__" .. entity:EntIndex()
		resultMaterial = CreateMaterial(resultMaterialName, "VertexLitGeneric", {["$model"] = 1})

		-- Start reading VMT material
		for vmtKey, vmtValueData in pairs(entityMaterialVMTData) do
			local keyName = vmtKey
			if (vmtValueData.type == VMTVariableType.PNGTexture) then
				-- Handle PNG material data
				local subMaterial = Material(vmtValueData.value:sub(#DynamicMaterials.Strings.VMT_EXT_PREFIX + 1), "noclamp smooth")
				resultMaterial:SetTexture(keyName, "" .. subMaterial:GetName())
				print("PNGTexture: " .. keyName .. ", " .. vmtValueData.value)

			elseif (vmtValueData.type == VMTVariableType.EngineTexture) then
				-- Handle Engine texture material data
				print("EngineTexture not implemented")

			elseif (vmtValueData.type == VMTVariableType.Float) then
				-- Handle Float material data
				resultMaterial:SetFloat(keyName, tonumber(vmtValueData.value))
				print("Float: " .. keyName .. ", " .. vmtValueData.value)

			elseif (vmtValueData.type == VMTVariableType.Int) then
				-- Handle Integer material data
				resultMaterial:SetFloat(keyName, tonumber(vmtValueData.value))
				print("Int: " .. keyName .. ", " .. vmtValueData.value)

			elseif (vmtValueData.type == VMTVariableType.String) then
				-- Handle String material data
				resultMaterial:SetString(keyName, vmtValueData.value)
				print("String: " .. keyName .. ", " .. vmtValueData.value)

			elseif (vmtValueData.type == VMTVariableType.Vector) then
				-- Handle Vector material data
				resultMaterial:SetVector(keyName, VMTParser.toVector(vmtValueData.value))
				print("Vector: " .. keyName .. ", " .. vmtValueData.value)
			else
				if (vmtValueData.type == nil) then
					print("Nil type!")
				else
					print("Unknown type " .. vmtValueData.type)
				end
			end
		end

		-- Recompute material
		resultMaterial:Recompute()
				
		-- Set material
		entity:SetMaterial("!" .. resultMaterialName)
	end,

	-- SHARED setLocation()
	-- Set VMT_LOCATION
	setLocation = function(src)
		DynamicMaterials.Strings.VMT_LOCATION = src
		print("Set VMT_LOCATION to "..src)
	end,

	-- CLIENT handleAll() 
	-- Loads materials for all entities
	handleAll = function()
		if (DynamicMaterials.Strings.VMT_LOCATION == "unset") then
			print("VMT_LOCATION is unset. Please use set() with the location of the gamemode materials folder.")
		end
		if (SERVER) then return end
		for k, entity in pairs(ents.GetAll()) do
			DynamicMaterials.handle(entity)
		end
	end,

	-- CLIENT setThatProp(string) 
	-- Loads materials for all entities
	setThatProp = function(text)
		if (SERVER) then return end

		local trace = LocalPlayer():GetEyeTrace()
		trace.Entity:SetNWString(DynamicMaterials.Strings.VMT_KEY, text)
	end

}

DynamicMaterials.initServer()