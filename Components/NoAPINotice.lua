local root = script.Parent.Parent
local API = require(root:FindFirstChild("API"))

local includes = root:FindFirstChild("includes")
local Roact = require(includes:FindFirstChild("Roact"))
local RoactRodux = require(includes:FindFirstChild("RoactRodux"))

---

local NoAPINotice = Roact.PureComponent:extend("NoAPINotice")

NoAPINotice.init = function(self)
    self.apiDataRequestStarted = API.DataRequestStarted:Connect(function()
        self:setState({
            requestRunning = true,
        })
    end)

    self.apiDataRequestFinished = API.DataRequestFinished:Connect(function()
        self:setState({
            requestRunning = false,
        })
    end)
    
    self:setState({
        requestRunning = API.IsRequestRunning(),
    })
end

NoAPINotice.willUnmount = function(self)
    self.apiDataRequestStarted:Disconnect()
    self.apiDataRequestFinished:Disconnect()
end

NoAPINotice.render = function(self)
    local theme = self.props.theme
    local requestRunning = self.state.requestRunning

    return Roact.createElement("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        Size = UDim2.new(1, 0, 1, 0),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        BackgroundTransparency = 0,
        BorderSizePixel = 0,

        BackgroundColor3 = theme:GetColor(Enum.StudioStyleGuideColor.MainBackground)
    }, {
        Notice = Roact.createElement("TextLabel", {
            AnchorPoint = Vector2.new(0.5, 0),
            Size = UDim2.new(1, 0, 0.5, 0),
            Position = UDim2.new(0.5, 0, 0, 0),
            BackgroundTransparency = 1,
            BorderSizePixel = 0,

            Font = Enum.Font.SourceSans,
            TextSize = 14,
            TextXAlignment = Enum.TextXAlignment.Center,
            TextYAlignment = Enum.TextYAlignment.Bottom,
            TextWrapped = true,
            Text = "The Roblox API data has not been loaded. You can use the Reload button to try again. This screen will disappear once the data has been loaded.",
            
            TextColor3 = theme:GetColor(Enum.StudioStyleGuideColor.MainText)
        }, {
            UIPadding = Roact.createElement("UIPadding", {
                PaddingTop = UDim.new(0, 16),
                PaddingBottom = UDim.new(0, 0),
                PaddingLeft = UDim.new(0, 16),
                PaddingRight = UDim.new(0, 16),
            })
        }),

        ReloadButtonContainer = Roact.createElement("Frame", {
            AnchorPoint = Vector2.new(0.5, 0),
            Position = UDim2.new(0.5, 0, 0.5, 8),
            Size = UDim2.new(0, 80, 0, 22),
            BackgroundTransparency = 0,
            BorderSizePixel = 0,
        
            BackgroundColor3 = theme:GetColor(Enum.StudioStyleGuideColor.DialogButtonBorder),
        }, {
            UICorner = Roact.createElement("UICorner", {
                CornerRadius = UDim.new(0, 4),
            }),

            Button = Roact.createElement("TextButton", {
                AnchorPoint = Vector2.new(0.5, 0.5),
                Position = UDim2.new(0.5, 0, 0.5, 0),
                Size = UDim2.new(1, -2, 1, -2),
                BackgroundTransparency = 0,
                BorderSizePixel = 0,
                AutoButtonColor = false,

                Font = Enum.Font.SourceSans,
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Center,
                TextYAlignment = Enum.TextYAlignment.Center,
                Text = requestRunning and "Reloading..." or "Reload",

                BackgroundColor3 = theme:GetColor(Enum.StudioStyleGuideColor.DialogMainButton, requestRunning and Enum.StudioStyleGuideModifier.Disabled or nil),
                TextColor3 = theme:GetColor(Enum.StudioStyleGuideColor.DialogMainButtonText, requestRunning and Enum.StudioStyleGuideModifier.Disabled or nil),

                [Roact.Event.MouseEnter] = function(obj)
                    if (requestRunning) then return end

                    obj.BackgroundColor3 = theme:GetColor(Enum.StudioStyleGuideColor.DialogMainButton, Enum.StudioStyleGuideModifier.Hover)
                end,
    
                [Roact.Event.MouseLeave] = function(obj)
                    if (requestRunning) then return end

                    obj.BackgroundColor3 = theme:GetColor(Enum.StudioStyleGuideColor.DialogMainButton)
                end,

                [Roact.Event.Activated] = function()
                    if (requestRunning) then return end
                    
                    API.GetData()
                end,
            }, {
                UICorner = Roact.createElement("UICorner", {
                    CornerRadius = UDim.new(0, 4),
                }),
            })
        })
    })
end

return RoactRodux.connect(function(store)
    return {
        theme = store.theme,
    }
end)(NoAPINotice)