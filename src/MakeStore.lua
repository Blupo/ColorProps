local CoreGui = game:GetService("CoreGui")

---

local root = script.Parent
local Studio = settings().Studio

local includes = root:FindFirstChild("includes")
local Rodux = require(includes:FindFirstChild("Rodux"))

---

local copy
copy = function(t)
    local tCopy = {}

    for k, v in pairs(t) do
        tCopy[(type(k) == "table") and copy(k) or k] = (type(v) == "table") and copy(v) or v
    end

    return tCopy
end

return function(plugin)
    local ColorPane = CoreGui:FindFirstChild("ColorPane")

    if (not (ColorPane and ColorPane:IsA("ModuleScript"))) then
        ColorPane = nil
    end

    local colorPane = ColorPane and require(ColorPane) or nil
    local colorPaneUnloadingEvent, colorPaneFinderEvent
    local onColorPaneUnloading, onColorPaneFound

    local storeInitialState = {
        theme = Studio.Theme,
        ColorPane = colorPane,
    }

    local store = Rodux.Store.new(Rodux.createReducer(storeInitialState, {
        setTheme = function(state, action)
            state = copy(state)
            
            state.theme = action.theme
            return state
        end,

        setColorPane = function(state, action)
            state = copy(state)

            state.ColorPane = action.ColorPane
            return state
        end,
    }))

    onColorPaneUnloading = function()
        store:dispatch({
            type = "setColorPane",
            ColorPane = nil,
        })

        colorPaneFinderEvent = CoreGui.ChildAdded:Connect(onColorPaneFound)
    end

    onColorPaneFound = function(child)
        if ((child.Name == "ColorPane") and child:IsA("ModuleScript")) then
            local colorPane = require(child)

            store:dispatch({
                type = "setColorPane",
                ColorPane = colorPane
            })

            colorPane.Unloading:Connect(onColorPaneUnloading)
        end
    end

    if (colorPane) then
        colorPaneUnloadingEvent = colorPane.Unloading:Connect(onColorPaneUnloading)
    else
        colorPaneFinderEvent = CoreGui.ChildAdded:Connect(onColorPaneFound)
    end

    local themeChanged = Studio.ThemeChanged:Connect(function()
        store:dispatch({
            type = "setTheme",
            theme = Studio.Theme,
        })
    end)

    plugin.Unloading:Connect(function()
        themeChanged:Disconnect()

        if (colorPaneUnloadingEvent) then
            colorPaneUnloadingEvent:Disconnect()
        end

        if (colorPaneFinderEvent) then
            colorPaneFinderEvent:Disconnect()
        end
    end)

    return store
end