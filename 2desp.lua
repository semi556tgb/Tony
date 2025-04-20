-- Roblox ESP Script - 2desp.lua
getgenv().MyESP = {}

local Workspace = cloneref(game:GetService("Workspace"))
local RunService = cloneref(game:GetService("RunService"))
local Players = cloneref(game:GetService("Players"))
local CoreGui = game:GetService("CoreGui")
local Lighting = cloneref(game:GetService("Lighting"))

local lplayer = Players.LocalPlayer
local camera = Workspace.CurrentCamera

local ESP = {
    Enabled = false,
    MaxDistance = 200,
    FadeOut = {
        OnDistance = true,
    },
    Drawing = {
        Boxes = {
            Animate = true,
            RotationSpeed = 300,
            Gradient = false,
            GradientRGB1 = Color3.fromRGB(119, 120, 255),
            GradientRGB2 = Color3.fromRGB(0, 0, 0),
            GradientFill = true,
            GradientFillRGB1 = Color3.fromRGB(119, 120, 255),
            GradientFillRGB2 = Color3.fromRGB(0, 0, 0),
            Filled = {
                Enabled = true,
                Transparency = 0.75,
                RGB = Color3.fromRGB(0, 0, 0),
            },
            Full = {
                Enabled = true,
                RGB = Color3.fromRGB(255, 255, 255),
            },
            Corner = {
                Enabled = true,
                RGB = Color3.fromRGB(255, 255, 255),
            },
        }
    },
    Connections = {
        RunService = RunService
    }
}

MyESP.Toggle = function(state)
    ESP.Enabled = state
    print("[ESP] Master Switch set to:", state)

    -- If turning off, hide all
    local gui = CoreGui:FindFirstChild("ESPHolder")
    if gui then
        for _, v in pairs(gui:GetChildren()) do
            if v:IsA("Frame") then
                v.Visible = false
            end
        end
    end
end

MyESP.IsEnabled = function()
    return ESP.Enabled
end

MyESP.SetBoxVisibility = function(state)
    ESP.Drawing.Boxes.Full.Enabled = state
    print("[ESP] Box Drawing set to:", state)
end

local Functions = {}

function Functions:Create(Class, Properties)
    local _Instance = typeof(Class) == 'string' and Instance.new(Class) or Class
    for Property, Value in pairs(Properties) do
        _Instance[Property] = Value
    end
    return _Instance
end

function Functions:FadeOutOnDist(element, distance)
    local transparency = math.max(0.1, 1 - (distance / ESP.MaxDistance))
    if element:IsA("Frame") then
        element.BackgroundTransparency = 1 - transparency
    end
end

-- Initialize ESP UI
local ScreenGui = Functions:Create("ScreenGui", { Parent = CoreGui, Name = "ESPHolder" })

local function HideESP(frames)
    for _, frame in pairs(frames) do
        frame.Visible = false
    end
end

local function ESPBox(plr)
    if ScreenGui:FindFirstChild(plr.Name) then
        ScreenGui[plr.Name]:Destroy()
    end

    local Box = Functions:Create("Frame", {Parent = ScreenGui, BackgroundColor3 = Color3.fromRGB(0,0,0), BackgroundTransparency = 0.75, BorderSizePixel = 0, Name = plr.Name})
    local Gradient1 = Functions:Create("UIGradient", {Parent = Box, Enabled = ESP.Drawing.Boxes.GradientFill, Color = ColorSequence.new{ColorSequenceKeypoint.new(0, ESP.Drawing.Boxes.GradientFillRGB1), ColorSequenceKeypoint.new(1, ESP.Drawing.Boxes.GradientFillRGB2)}})
    local Outline = Functions:Create("UIStroke", {Parent = Box, Enabled = ESP.Drawing.Boxes.Gradient, Transparency = 0, Color = Color3.fromRGB(255,255,255), LineJoinMode = Enum.LineJoinMode.Miter})
    local Gradient2 = Functions:Create("UIGradient", {Parent = Outline, Enabled = ESP.Drawing.Boxes.Gradient, Color = ColorSequence.new{ColorSequenceKeypoint.new(0, ESP.Drawing.Boxes.GradientRGB1), ColorSequenceKeypoint.new(1, ESP.Drawing.Boxes.GradientRGB2)}})

    local frames = {Box}
    local RotationAngle, Tick = -45, tick()

    RunService.RenderStepped:Connect(function()
        if not MyESP.IsEnabled() or not ESP.Drawing.Boxes.Full.Enabled then
            HideESP(frames)
            return
        end

        if plr and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
            local HRP = plr.Character.HumanoidRootPart
            local Pos, OnScreen = camera:WorldToScreenPoint(HRP.Position)
            local Dist = (camera.CFrame.Position - HRP.Position).Magnitude / 3.5714285714

            if OnScreen and Dist <= ESP.MaxDistance and plr ~= lplayer then
                local Size = HRP.Size.Y
                local scaleFactor = (Size * camera.ViewportSize.Y) / (Pos.Z * 2)
                local w, h = 3 * scaleFactor, 4.5 * scaleFactor

                Box.Position = UDim2.new(0, Pos.X - w / 2, 0, Pos.Y - h / 2)
                Box.Size = UDim2.new(0, w, 0, h)
                Box.Visible = true

                if ESP.FadeOut.OnDistance then
                    Functions:FadeOutOnDist(Box, Dist)
                end

                if ESP.Drawing.Boxes.Filled.Enabled then
                    Box.BackgroundColor3 = Color3.fromRGB(255,255,255)
                    if ESP.Drawing.Boxes.GradientFill then
                        Box.BackgroundTransparency = ESP.Drawing.Boxes.Filled.Transparency
                    else
                        Box.BackgroundTransparency = 1
                    end
                    Box.BorderSizePixel = 1
                else
                    Box.BackgroundTransparency = 1
                end

                RotationAngle = RotationAngle + (tick() - Tick) * ESP.Drawing.Boxes.RotationSpeed * math.cos(math.pi / 4 * tick() - math.pi / 2)
                if ESP.Drawing.Boxes.Animate then
                    Gradient1.Rotation = RotationAngle
                    Gradient2.Rotation = RotationAngle
                else
                    Gradient1.Rotation = -45
                    Gradient2.Rotation = -45
                end

                Tick = tick()
            else
                HideESP(frames)
            end
        else
            HideESP(frames)
        end
    end)
end

-- Apply ESP to all players except local player
for _, v in pairs(Players:GetPlayers()) do
    if v ~= lplayer then
        ESPBox(v)
    end
end

Players.PlayerAdded:Connect(function(v)
    if v ~= lplayer then
        ESPBox(v)
    end
end)
