-- === Roblox ESP Script: 2desp.lua ===

getgenv().MyESP = getgenv().MyESP or {}

local Workspace = cloneref(game:GetService("Workspace"))
local RunService = cloneref(game:GetService("RunService"))
local Players = cloneref(game:GetService("Players"))
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

local ESP = {
    Enabled = false,
    MaxDistance = 300,
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
        }
    }
}

MyESP.Toggle = function(state)
    ESP.Enabled = state
    print("[ESP] Enabled set to:", state)
    local gui = CoreGui:FindFirstChild("ESPHolder")
    if gui then
        for _, v in pairs(gui:GetChildren()) do
            if v:IsA("Frame") then
                v.Visible = state
            end
        end
    end
end

MyESP.IsEnabled = function()
    return ESP.Enabled
end

MyESP.SetBoxVisibility = function(state)
    ESP.Drawing.Boxes.Full.Enabled = state
    print("[ESP] Box visibility set to:", state)
end

-- === Utilities ===
local function CreateInstance(class, properties)
    local obj = typeof(class) == "string" and Instance.new(class) or class
    for prop, val in pairs(properties) do
        obj[prop] = val
    end
    return obj
end

local function FadeOutByDistance(frame, distance)
    local transparency = math.clamp(1 - (distance / ESP.MaxDistance), 0.1, 1)
    if frame:IsA("Frame") then
        frame.BackgroundTransparency = 1 - transparency
    end
end

-- === Initialize UI Holder ===
local ESPGui = CoreGui:FindFirstChild("ESPHolder") or CreateInstance("ScreenGui", { Parent = CoreGui, Name = "ESPHolder", ResetOnSpawn = false })

-- === Hide All ESP Frames ===
local function HideESP(frames)
    for _, frame in pairs(frames) do
        frame.Visible = false
    end
end

-- === Create ESP Box for a Player ===
local function CreateESPBox(player)
    local existing = ESPGui:FindFirstChild(player.Name)
    if existing then existing:Destroy() end

    local Box = CreateInstance("Frame", { 
        Parent = ESPGui, 
        BackgroundColor3 = ESP.Drawing.Boxes.Filled.RGB, 
        BackgroundTransparency = ESP.Drawing.Boxes.Filled.Transparency, 
        BorderSizePixel = 0, 
        Name = player.Name 
    })

    local Gradient1 = CreateInstance("UIGradient", {
        Parent = Box,
        Enabled = ESP.Drawing.Boxes.GradientFill,
        Color = ColorSequence.new{
            ColorSequenceKeypoint.new(0, ESP.Drawing.Boxes.GradientFillRGB1),
            ColorSequenceKeypoint.new(1, ESP.Drawing.Boxes.GradientFillRGB2)
        }
    })

    local Outline = CreateInstance("UIStroke", {
        Parent = Box,
        Transparency = 0,
        Color = ESP.Drawing.Boxes.Full.RGB,
        LineJoinMode = Enum.LineJoinMode.Miter
    })

    local Gradient2 = CreateInstance("UIGradient", {
        Parent = Outline,
        Enabled = ESP.Drawing.Boxes.Gradient,
        Color = ColorSequence.new{
            ColorSequenceKeypoint.new(0, ESP.Drawing.Boxes.GradientRGB1),
            ColorSequenceKeypoint.new(1, ESP.Drawing.Boxes.GradientRGB2)
        }
    })

    local frames = { Box }
    local RotationAngle, LastTick = -45, tick()

    RunService.RenderStepped:Connect(function()
        if not ESP.Enabled or not ESP.Drawing.Boxes.Full.Enabled then
            HideESP(frames)
            return
        end

        if player and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local HRP = player.Character.HumanoidRootPart
            local Pos, OnScreen = Camera:WorldToScreenPoint(HRP.Position)
            local Distance = (Camera.CFrame.Position - HRP.Position).Magnitude / 3.5714285714

            if OnScreen and Distance <= ESP.MaxDistance and player ~= LocalPlayer then
                local scale = (HRP.Size.Y * Camera.ViewportSize.Y) / (Pos.Z * 2)
                local Width, Height = 3 * scale, 4.5 * scale

                Box.Position = UDim2.new(0, Pos.X - Width / 2, 0, Pos.Y - Height / 2)
                Box.Size = UDim2.new(0, Width, 0, Height)
                Box.Visible = true

                if getgenv().MyESP.FadeOut then
                    FadeOutByDistance(Box, Distance)
                end

                if ESP.Drawing.Boxes.Filled.Enabled then
                    Box.BackgroundTransparency = ESP.Drawing.Boxes.Filled.Transparency
                else
                    Box.BackgroundTransparency = 1
                end

                if ESP.Drawing.Boxes.Animate then
                    local Now = tick()
                    RotationAngle = RotationAngle + (Now - LastTick) * ESP.Drawing.Boxes.RotationSpeed * math.cos(math.pi / 4 * Now - math.pi / 2)
                    Gradient1.Rotation = RotationAngle
                    Gradient2.Rotation = RotationAngle
                    LastTick = Now
                end
            else
                HideESP(frames)
            end
        else
            HideESP(frames)
        end
    end)
end

-- === Apply to All Players ===
for _, player in pairs(Players:GetPlayers()) do
    if player ~= LocalPlayer then
        CreateESPBox(player)
    end
end

Players.PlayerAdded:Connect(function(player)
    if player ~= LocalPlayer then
        CreateESPBox(player)
    end
end)

-- === Sync Loop for GUI Toggles ===
task.spawn(function()
    while true do
        pcall(function()
            ESP.Enabled = getgenv().MyESP.Enabled or false
            ESP.Drawing.Boxes.Full.Enabled = getgenv().MyESP.Box or false
            ESP.MaxDistance = getgenv().MyESP.DistanceValue or 300  -- optional if your GUI gives distance
        end)
        task.wait(0.1) -- sync every 100ms
    end
end)

print("[ESP] Loaded successfully.")
