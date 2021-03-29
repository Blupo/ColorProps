warn("ColorProps's functionality has been integrated into ColorPane. Please uninstall this plugin and use ColorPane instead.")

--[[
local root = script.Parent
local API = require(root:FindFirstChild("API"))
local MakeStore = require(root:FindFirstChild("MakeStore"))
local SelectionManager = require(root:FindFirstChild("SelectionManager"))

local includes = root:FindFirstChild("includes")
local Roact = require(includes:FindFirstChild("Roact"))
local RoactRodux = require(includes:FindFirstChild("RoactRodux"))

local Components = root:FindFirstChild("Components")
local ColorProps = require(Components:FindFirstChild("ColorProps"))

API.init(plugin)
SelectionManager.init(plugin)

---

local propertiesWidget = plugin:CreateDockWidgetPluginGui("ColorProps", DockWidgetPluginGuiInfo.new(Enum.InitialDockState.Float, true, false, 265, 400, 265, 250))
propertiesWidget.Name = "ColorProps"
propertiesWidget.Title = "Color Properties"
propertiesWidget.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
propertiesWidget.Archivable = false

local store = MakeStore(plugin)

local propertiesWidgetTree = propertiesWidget.Enabled and
    Roact.mount(Roact.createElement(RoactRodux.StoreProvider, {
        store = store,
    }, {
        ColorProps = Roact.createElement(ColorProps)
    }), propertiesWidget)
or nil

local propertiesWidgetEnabled = propertiesWidget:GetPropertyChangedSignal("Enabled"):Connect(function()
	if (propertiesWidget.Enabled and (not propertiesWidgetTree)) then
        SelectionManager.Connect()

        propertiesWidgetTree = Roact.mount(Roact.createElement(RoactRodux.StoreProvider, {
            store = store,
        }, {
            ColorProps = Roact.createElement(ColorProps)
        }), propertiesWidget)
    elseif ((not propertiesWidget.Enabled) and propertiesWidgetTree) then
        SelectionManager.Disconnect()
        
        Roact.unmount(propertiesWidgetTree)
		propertiesWidgetTree = nil
    end
end)

---

API.GetData()

plugin.Unloading:Connect(function()
	propertiesWidgetEnabled:Disconnect()

	if (propertiesWidgetTree) then
		Roact.unmount(propertiesWidgetTree)
		propertiesWidgetTree = nil
	end
end)
--]]