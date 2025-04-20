-- 2dbox.lua

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local ESP = {
    Enabled = false,
    MaxDistance = 300,
    Drawing = {
        Boxes = {
            Full = { Enabled = false, RGB = Color3.fromRGB(255, 255, 255) },
            Filled = { Enabled = false, RGB = Color3.fromRGB(0, 0, 0), Transparency = 0.75 }
        },
        Healthbar = { Enabled = false, Width = 2.5 }
    },
    Objects = {}
}

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

local function CreateBox()
    local box = Drawing.new("Square")
    box.Visible = false
    box.Color = ESP.Drawing.Boxes.Full.RGB
    box.Thickness = 1
    box.Filled = false
    return box
end

local function CreateHealthbar()
    local bar = Drawing.new("Square")
    bar.Visible = false
    bar.Color = Color3.fromRGB(0, 255, 0)
    bar.Thickness = 1
    bar.Filled = true
    return bar
end

local function ClearESP()
    for _, obj in pairs(ESP.Objects) do
        if obj and obj.Remove then
            obj:Remove()
        end
    end
    ESP.Objects = {}
end

RunService.RenderStepped:Connect(function()
    if not ESP.Enabled or not ESP.Drawing.Boxes.Full.Enabled then
        ClearESP()
        return
    end

    ClearESP()

    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
            local humanoid = plr.Character:FindFirstChildOfClass("Humanoid")
            local hrp = plr.Character.HumanoidRootPart
            local pos, onScreen = Camera:WorldToViewportPoint(hrp.Position)

            local distance = (Camera.CFrame.Position - hrp.Position).Magnitude
            if onScreen and distance <= ESP.MaxDistance then
                local scale = 1 / pos.Z * 100
                local sizeX = math.clamp(30 * scale, 1, 300)
                local sizeY = sizeX * 1.5

                -- Box
                local box = CreateBox()
                box.Size = Vector2.new(sizeX, sizeY)
                box.Position = Vector2.new(pos.X - sizeX / 2, pos.Y - sizeY / 2)
                box.Color = ESP.Drawing.Boxes.Full.RGB
                box.Visible = true

                -- Box Fill
                if ESP.Drawing.Boxes.Filled.Enabled then
                    box.Filled = true
                    box.Color = ESP.Drawing.Boxes.Filled.RGB
                    box.Transparency = ESP.Drawing.Boxes.Filled.Transparency
                end

                table.insert(ESP.Objects, box)

                -- Health Bar
                if ESP.Drawing.Healthbar.Enabled and humanoid and humanoid.Health > 0 then
                    local healthPercent = humanoid.Health / humanoid.MaxHealth
                    local healthbar = CreateHealthbar()

                    local barHeight = sizeY * healthPercent
                    healthbar.Size = Vector2.new(ESP.Drawing.Healthbar.Width, barHeight)
                    healthbar.Position = Vector2.new(
                        pos.X - sizeX / 2 - 6,
                        pos.Y + sizeY / 2 - barHeight
                    )
                    healthbar.Visible = true

                    table.insert(ESP.Objects, healthbar)
                end
            end
        end
    end
end)

return ESP
