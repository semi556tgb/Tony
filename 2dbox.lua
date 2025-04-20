-- Eclipse.wtf Style 2D Box ESP with Corner Boxes, Health Bar, Chams & Name/Distance Display

getgenv().LoadedESP = getgenv().LoadedESP or {
    Settings = {
        MasterSwitch = false,
        HealthBar = true,
        ChamsVisibleOnly = false
    }
}

local ESP = {}

local function Draw(type)
    local obj = Drawing.new(type)
    obj.Visible = false
    return obj
end

local function CreateCornerBox()
    return {
        LineTL = Draw("Line"),
        LineTR = Draw("Line"),
        LineBL = Draw("Line"),
        LineBR = Draw("Line"),
        HealthBar = Draw("Line"),
        HealthBack = Draw("Line"),
        Name = Draw("Text"),
        Distance = Draw("Text"),
        Chams = Instance.new("Highlight")
    }
end

function ESP:New(Player)
    local Box = CreateCornerBox()
    Box.Chams.Parent = game:GetService("CoreGui")
    Box.Name.Size = 13
    Box.Name.Center = true
    Box.Name.Outline = true
    Box.Distance.Size = 13
    Box.Distance.Center = true
    Box.Distance.Outline = true

    local function Update()
        if not getgenv().LoadedESP or not getgenv().LoadedESP.Settings.MasterSwitch then
            for _,v in pairs(Box) do
                if typeof(v) == "Instance" then v.Enabled = false else v.Visible = false end
            end
            return
        end

        local Character = Player.Character
        local HRP = Character and Character:FindFirstChild("HumanoidRootPart")
        local Humanoid = Character and Character:FindFirstChildOfClass("Humanoid")

        if HRP and Humanoid and Humanoid.Health > 0 then
            local Pos, OnScreen = workspace.CurrentCamera:WorldToViewportPoint(HRP.Position)
            if OnScreen then
                local scale = math.clamp(15 / (HRP.Position - workspace.CurrentCamera.CFrame.Position).Magnitude, 2, 5)
                local size = Vector2.new(35 * scale, 55 * scale)
                local topLeft = Vector2.new(Pos.X - size.X / 2, Pos.Y - size.Y / 2)
                local bottomRight = Vector2.new(Pos.X + size.X / 2, Pos.Y + size.Y / 2)
                local lineLength = size.X * 0.2

                -- Corner Box Lines
                Box.LineTL.From = topLeft
                Box.LineTL.To = Vector2.new(topLeft.X + lineLength, topLeft.Y)
                Box.LineTL.Color = Color3.new(0,1,0)
                Box.LineTL.Thickness = 1
                Box.LineTL.Visible = true

                Box.LineBL.From = topLeft
                Box.LineBL.To = Vector2.new(topLeft.X, topLeft.Y + lineLength)
                Box.LineBL.Color = Color3.new(0,1,0)
                Box.LineBL.Thickness = 1
                Box.LineBL.Visible = true

                Box.LineTR.From = Vector2.new(bottomRight.X - lineLength, topLeft.Y)
                Box.LineTR.To = Vector2.new(bottomRight.X, topLeft.Y)
                Box.LineTR.Color = Color3.new(0,1,0)
                Box.LineTR.Thickness = 1
                Box.LineTR.Visible = true

                Box.LineBR.From = Vector2.new(bottomRight.X, bottomRight.Y - lineLength)
                Box.LineBR.To = bottomRight
                Box.LineBR.Color = Color3.new(0,1,0)
                Box.LineBR.Thickness = 1
                Box.LineBR.Visible = true

                -- Health Bar
                if getgenv().LoadedESP.Settings.HealthBar then
                    local health = Humanoid.Health / Humanoid.MaxHealth
                    local barHeight = size.Y * health
                    Box.HealthBack.From = Vector2.new(topLeft.X - 6, bottomRight.Y)
                    Box.HealthBack.To = Vector2.new(topLeft.X - 6, topLeft.Y)
                    Box.HealthBack.Color = Color3.new(0,0,0)
                    Box.HealthBack.Thickness = 2
                    Box.HealthBack.Visible = true

                    Box.HealthBar.From = Vector2.new(topLeft.X - 6, bottomRight.Y)
                    Box.HealthBar.To = Vector2.new(topLeft.X - 6, bottomRight.Y - barHeight)
                    Box.HealthBar.Color = Color3.fromRGB(0,255,0)
                    Box.HealthBar.Thickness = 2
                    Box.HealthBar.Visible = true
                else
                    Box.HealthBack.Visible = false
                    Box.HealthBar.Visible = false
                end

                -- Name Tag
                Box.Name.Text = Player.Name
                Box.Name.Position = Vector2.new(Pos.X, topLeft.Y - 14)
                Box.Name.Color = Color3.new(1,1,1)
                Box.Name.Visible = true
a-- Eclipse.wtf Style 2D Box ESP — Proper Settings Connection for UI Toggles

getgenv().LoadedESP = getgenv().LoadedESP or {}

local ESP = {}

ESP.Settings = {
    MasterSwitch = false,
    HealthBar = true,
    ChamsVisibleOnly = false
}

function ESP:UpdateSettings(data)
    for k, v in pairs(data) do
        if ESP.Settings[k] ~= nil then
            ESP.Settings[k] = v
        end
    end
end

local function Draw(type)
    local obj = Drawing.new(type)
    obj.Visible = false
    return obj
end

local function CreateCornerBox()
    return {
        LineTL = Draw("Line"),
        LineTR = Draw("Line"),
        LineBL = Draw("Line"),
        LineBR = Draw("Line"),
        HealthBar = Draw("Line"),
        HealthBack = Draw("Line"),
        Name = Draw("Text"),
        Distance = Draw("Text"),
        Chams = Instance.new("Highlight")
    }
end

function ESP:New(Player)
    local Box = CreateCornerBox()
    Box.Chams.Parent = game:GetService("CoreGui")
    Box.Name.Size = 13
    Box.Name.Center = true
    Box.Name.Outline = true
    Box.Distance.Size = 13
    Box.Distance.Center = true
    Box.Distance.Outline = true

    local function Update()
        if not ESP.Settings.MasterSwitch then
            for _,v in pairs(Box) do
                if typeof(v) == "Instance" then v.Enabled = false else v.Visible = false end
            end
            return
        end

        local Character = Player.Character
        local HRP = Character and Character:FindFirstChild("HumanoidRootPart")
        local Humanoid = Character and Character:FindFirstChildOfClass("Humanoid")

        if HRP and Humanoid and Humanoid.Health > 0 then
            local Pos, OnScreen = workspace.CurrentCamera:WorldToViewportPoint(HRP.Position)
            if OnScreen then
                local scale = math.clamp(15 / (HRP.Position - workspace.CurrentCamera.CFrame.Position).Magnitude, 2, 5)
                local size = Vector2.new(35 * scale, 55 * scale)
                local topLeft = Vector2.new(Pos.X - size.X / 2, Pos.Y - size.Y / 2)
                local bottomRight = Vector2.new(Pos.X + size.X / 2, Pos.Y + size.Y / 2)
                local lineLength = size.X * 0.2

                Box.LineTL.From = topLeft
                Box.LineTL.To = Vector2.new(topLeft.X + lineLength, topLeft.Y)
                Box.LineTL.Color = Color3.new(0,1,0)
                Box.LineTL.Thickness = 1
                Box.LineTL.Visible = true

                Box.LineBL.From = topLeft
                Box.LineBL.To = Vector2.new(topLeft.X, topLeft.Y + lineLength)
                Box.LineBL.Color = Color3.new(0,1,0)
                Box.LineBL.Thickness = 1
                Box.LineBL.Visible = true

                Box.LineTR.From = Vector2.new(bottomRight.X - lineLength, topLeft.Y)
                Box.LineTR.To = Vector2.new(bottomRight.X, topLeft.Y)
                Box.LineTR.Color = Color3.new(0,1,0)
                Box.LineTR.Thickness = 1
                Box.LineTR.Visible = true

                Box.LineBR.From = Vector2.new(bottomRight.X, bottomRight.Y - lineLength)
                Box.LineBR.To = bottomRight
                Box.LineBR.Color = Color3.new(0,1,0)
                Box.LineBR.Thickness = 1
                Box.LineBR.Visible = true

                if ESP.Settings.HealthBar then
                    local health = Humanoid.Health / Humanoid.MaxHealth
                    local barHeight = size.Y * health
                    Box.HealthBack.From = Vector2.new(topLeft.X - 6, bottomRight.Y)
                    Box.HealthBack.To = Vector2.new(topLeft.X - 6, topLeft.Y)
                    Box.HealthBack.Color = Color3.new(0,0,0)
                    Box.HealthBack.Thickness = 2
                    Box.HealthBack.Visible = true

                    Box.HealthBar.From = Vector2.new(topLeft.X - 6, bottomRight.Y)
                    Box.HealthBar.To = Vector2.new(topLeft.X - 6, bottomRight.Y - barHeight)
                    Box.HealthBar.Color = Color3.fromRGB(0,255,0)
                    Box.HealthBar.Thickness = 2
                    Box.HealthBar.Visible = true
                else
                    Box.HealthBack.Visible = false
                    Box.HealthBar.Visible = false
                end

                Box.Name.Text = Player.Name
                Box.Name.Position = Vector2.new(Pos.X, topLeft.Y - 14)
                Box.Name.Color = Color3.new(1,1,1)
                Box.Name.Visible = true

                local distance = math.floor((HRP.Position - workspace.CurrentCamera.CFrame.Position).Magnitude)
                Box.Distance.Text = tostring(distance) .. "m"
                Box.Distance.Position = Vector2.new(Pos.X, bottomRight.Y + 2)
                Box.Distance.Color = Color3.new(1,1,1)
                Box.Distance.Visible = true

                Box.Chams.Adornee = Character
                Box.Chams.FillColor = Color3.fromRGB(119, 120, 255)
                Box.Chams.OutlineColor = Color3.fromRGB(119, 120, 255)
                Box.Chams.Enabled = true
                Box.Chams.DepthMode = ESP.Settings.ChamsVisibleOnly and Enum.HighlightDepthMode.Occluded or Enum.HighlightDepthMode.AlwaysOnTop
            else
                for _,v in pairs(Box) do
                    if typeof(v) == "Instance" then v.Enabled = false else v.Visible = false end
                end
            end
        else
            for _,v in pairs(Box) do
                if typeof(v) == "Instance" then v.Enabled = false else v.Visible = false end
            end
        end
    end

    game:GetService("RunService").RenderStepped:Connect(Update)
end

getgenv().LoadedESP = ESP
return ESP

                local distance = math.floor((HRP.Position - workspace.CurrentCamera.CFrame.Position).Magnitude)
                Box.Distance.Text = tostring(distance) .. "m"
                Box.Distance.Position = Vector2.new(Pos.X, bottomRight.Y + 2)
                Box.Distance.Color = Color3.new(1,1,1)
                Box.Distance.Visible = true

                -- Chams
                Box.Chams.Adornee = Character
                Box.Chams.FillColor = Color3.fromRGB(119, 120, 255)
                Box.Chams.OutlineColor = Color3.fromRGB(119, 120, 255)
                Box.Chams.Enabled = true
                Box.Chams.DepthMode = getgenv().LoadedESP.Settings.ChamsVisibleOnly and Enum.HighlightDepthMode.Occluded or Enum.HighlightDepthMode.AlwaysOnTop

            else
                for _,v in pairs(Box) do
                    if typeof(v) == "Instance" then v.Enabled = false else v.Visible = false end
                end
            end

        else
            for _,v in pairs(Box) do
                if typeof(v) == "Instance" then v.Enabled = false else v.Visible = false end
            end
        end
    end

    game:GetService("RunService").RenderStepped:Connect(Update)
end

return ESP
