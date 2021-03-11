local root = script.Parent.Parent
local API = require(root:FindFirstChild("API"))

local Components = root:FindFirstChild("Components")
local NoAPINotice = require(Components:FindFirstChild("NoAPINotice"))
local NoColorPaneNotice = require(Components:FindFirstChild("NoColorPaneNotice"))
local PropertiesList = require(Components:FindFirstChild("PropertiesList"))

local includes = root:FindFirstChild("includes")
local Roact = require(includes:FindFirstChild("Roact"))
local RoactRodux = require(includes:FindFirstChild("RoactRodux"))

---

local ColorProps = Roact.Component:extend("ColorProps")

ColorProps.init = function(self)
    local apiLoaded = API.IsAvailable()

    self.apiDataLoaded = (not apiLoaded) and
        API.DataRequestFinished:Connect(function(didLoad)
            if (not didLoad) then return end

            self.apiDataLoaded:Disconnect()
            self.apiDataLoaded = nil

            self:setState({
                apiLoaded = true,
            })
        end)
    or nil

    self:setState({
        apiLoaded = apiLoaded
    })
end

ColorProps.willUnmount = function(self)
    if (self.apiDataLoaded) then
        self.apiDataLoaded:Disconnect()
        self.apiDataLoaded = nil
    end
end

ColorProps.render = function(self)
    if (not self.state.apiLoaded) then
        return Roact.createElement(NoAPINotice)
    else
        return Roact.createElement(self.props.ColorPane and PropertiesList or NoColorPaneNotice)
    end
end

return RoactRodux.connect(function(store)
    return {
        ColorPane = store.ColorPane
    }
end)(ColorProps)