local root = script.Parent.Parent

local includes = root:FindFirstChild("includes")
local Roact = require(includes:FindFirstChild("Roact"))
local RoactRodux = require(includes:FindFirstChild("RoactRodux"))

---

local NoColorPaneNotice = Roact.PureComponent:extend("NoColorPaneNotice")

NoColorPaneNotice.render = function(self)
    local theme = self.props.theme

    return Roact.createElement("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        Size = UDim2.new(1, 0, 1, 0),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        BackgroundTransparency = 0,
        BorderSizePixel = 0,

        BackgroundColor3 = theme:GetColor(Enum.StudioStyleGuideColor.MainBackground)
    }, {
        Notice = Roact.createElement("TextLabel", {
            AnchorPoint = Vector2.new(0.5, 0.5),
            Size = UDim2.new(1, 0, 1, 0),
            Position = UDim2.new(0.5, 0, 0.5, 0),
            BackgroundTransparency = 1,
            BorderSizePixel = 0,

            Font = Enum.Font.SourceSans,
            TextSize = 14,
            TextXAlignment = Enum.TextXAlignment.Center,
            TextYAlignment = Enum.TextYAlignment.Center,
            TextWrapped = true,
            Text = "ColorPane was not detected. If you don't have it installed, this plugin will not work. Otherwise, it should be detected automatically.",
            
            TextColor3 = theme:GetColor(Enum.StudioStyleGuideColor.MainText)
        }, {
            UIPadding = Roact.createElement("UIPadding", {
                PaddingTop = UDim.new(0, 16),
                PaddingBottom = UDim.new(0, 16),
                PaddingLeft = UDim.new(0, 16),
                PaddingRight = UDim.new(0, 16),
            })
        }),
    })
end

return RoactRodux.connect(function(store)
    return {
        theme = store.theme,
    }
end)(NoColorPaneNotice)