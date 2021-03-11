local HttpService = game:GetService("HttpService")

---

local root = script.Parent
local TerrainMaterialColors = require(root:FindFirstChild("TerrainMaterialColors"))

local includes = root:FindFirstChild("includes")
local APIUtils = require(includes:FindFirstChild("APIUtils"))

---

local API_URL = "https://setup.rbxcdn.com/"
local STUDIO_VERSION_ENDPOINT = "versionQTStudio"
local API_DUMP_ENDPOINT = "%s-API-Dump.json"

local apiDump
local requestInProgress = false
local apiDataRequestStartedEvent = Instance.new("BindableEvent")
local apiDataRequestFinishedEvent = Instance.new("BindableEvent")

---

local API = {}
API.DataRequestStarted = apiDataRequestStartedEvent.Event
API.DataRequestFinished = apiDataRequestFinishedEvent.Event

API.IsAvailable = function()
    return (apiDump and true or false)
end

API.IsRequestRunning = function()
    return requestInProgress
end

API.GetData = function()
    if (apiDump or requestInProgress) then return end

    requestInProgress = true
    apiDataRequestStartedEvent:Fire()

    coroutine.wrap(function()
        local studioVersion

        pcall(function()
            local response = HttpService:RequestAsync({
                Url = API_URL .. STUDIO_VERSION_ENDPOINT,
                Method = "GET",
            })
        
            if (response.Success) then
                studioVersion = response.Body
            end
        end)

        if (not studioVersion) then
            requestInProgress = false
            apiDataRequestFinishedEvent:Fire(false)

            return
        end

        pcall(function()
            local response = HttpService:RequestAsync({
                Url = API_URL .. string.format(API_DUMP_ENDPOINT, studioVersion),
                Method = "GET",
            })
        
            if (response.Success) then
                apiDump = HttpService:JSONDecode(response.Body)
            end
        end)

        if (apiDump) then
            API.APIData = APIUtils.createAPIData(apiDump)
            API.APIInterface = APIUtils.createAPIInterface(API.APIData)

            for i = 1, #TerrainMaterialColors.Properties do
                local property = TerrainMaterialColors.Properties[i]
                local behaviour = TerrainMaterialColors.Behaviours[i]
            
                API.APIData:AddClassMember("Terrain", property)
                API.APIInterface:AddClassMemberBehavior("Terrain", "Property", property.Name, behaviour)
            end
        end

        requestInProgress = false
        apiDataRequestFinishedEvent:Fire(apiDump and true or false)
    end)()
end

API.init = function(plugin)
    API.init = nil

    plugin.Unloading:Connect(function()
        apiDataRequestStartedEvent:Destroy()
        apiDataRequestFinishedEvent:Destroy()
    end)
end

return API