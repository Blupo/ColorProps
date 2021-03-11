local Workspace = game:GetService("Workspace")

---

local Terrain = Workspace.Terrain

local terrainMaterialColorProperties = {}
local terrainMaterialColorBehaviours = {}
local materialEnumItems = Enum.Material:GetEnumItems()

local propertyDataTemplate = {
    Category = "Terrain Colors",
    MemberType = "Property",
    
    Security = {
        Read = "None",
        Write = "None",
    },
    
    Serialization = {
        CanLoad = false,
        CanSave = false,
    },
    
    ValueType = {
        Category = "DataType",
        Name = "Color3"
    },

    ThreadSafety = "ReadOnly",
}

local tableDeepCopy
tableDeepCopy = function(tab)
	local copy = {}

	if (type(tab) == "table") then
		for k, v in pairs(tab) do
			copy[tableDeepCopy(k)] = tableDeepCopy(v)
		end
	else
		return tab
	end

	return copy
end

for _, materialEnumItem in pairs(materialEnumItems) do
    local success = pcall(function()
        Terrain:GetMaterialColor(materialEnumItem)
    end)

    if success then
        local newPropertyData = tableDeepCopy(propertyDataTemplate)
        newPropertyData.Name = materialEnumItem.Name .. " Color"

        local newPropertyBehaviour = {
            Get = function(terrain)
                return terrain:GetMaterialColor(materialEnumItem)
            end,
            
            Set = function(terrain, color)
                terrain:SetMaterialColor(materialEnumItem, color)
            end,
        }

        terrainMaterialColorProperties[#terrainMaterialColorProperties + 1] = newPropertyData
        terrainMaterialColorBehaviours[#terrainMaterialColorBehaviours + 1] = newPropertyBehaviour
    end
end

return {
    Properties = terrainMaterialColorProperties,
    Behaviours = terrainMaterialColorBehaviours
}