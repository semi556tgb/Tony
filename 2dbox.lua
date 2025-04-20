-- 2dbox.lua

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

-- Core references
local lplayer = Players.LocalPlayer
local camera = Workspace.CurrentCamera

-- ESP Module
local ESP = {
    Enabled = true,
    MaxDistance = 300,
    Drawing = {
        Boxes = {
            Full = { Enabled = false, RGB = Color3.fromRGB(255, 255, 255) }
        }
    },
    Objects = {}
}

-- Helper: Create Drawing Object
local function CreateBox()
    local box = Drawing.new("Square")
    box.Visible = false
    box.Color = ESP.Drawing.Boxes.Full.RGB
    box.Thickness = 1
    box.Filled = false
    return box
end

-- Cleanup old ESP objects
local function ClearESP()
    for _, obj in pairs(ESP.Objects) do
        if obj and obj.Remove then
            obj:Remove()
        end
    end
    ESP.Objects = {}
end

-- Update ESP loop
RunService.RenderStepped:Connect(function()
    if not ESP.Enabled or not ESP.Drawing.Boxes.Full.Enabled then
        ClearESP()
        return
    end

    -- Cleanup existing
    ClearESP()

    -- Loop through players
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= lplayer and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
            local hrp = plr.Character.HumanoidRootPart
            local pos, onScreen = camera:WorldToViewportPoint(hrp.Position)

            local distance = (camera.CFrame.Position - hrp.Position).Magnitude
            if onScreen and distance <= ESP.MaxDistance then
                local scale = 1 / (pos.Z) * 100
                local sizeX = math.clamp(30 * scale, 1, 300)
                local sizeY = sizeX * 1.5

                local box = CreateBox()
                box.Size = Vector2.new(sizeX, sizeY)
                box.Position = Vector2.new(pos.X - sizeX / 2, pos.Y - sizeY / 2)
                box.Color = ESP.Drawing.Boxes.Full.RGB
                box.Visible = true

                table.insert(ESP.Objects, box)
            end
        end
    end
end)

return ESP
