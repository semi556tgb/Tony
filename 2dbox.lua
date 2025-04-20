-- 2dbox.lua
local ESP = {}
ESP.Enabled = false

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

ESP.Objects = {}

local function CreateESP(player)
    return {
        Box = Drawing.new("Square"),
        Filled = Drawing.new("Square"),
        Name = Drawing.new("Text"),
        Distance = Drawing.new("Text"),
        HealthbarOutline = Drawing.new("Square"),
        Healthbar = Drawing.new("Square"),
        Player = player
    }
end

function ESP.SetEnabled(state)
    ESP.Enabled = state
    if not state then
        for _, data in pairs(ESP.Objects) do
            for _, drawing in pairs(data) do
                if typeof(drawing) == "Instance" or typeof(drawing) == "table" then
                    if drawing.Visible ~= nil then
                        drawing.Visible = false
                    end
                end
            end
        end
    end
end

function ESP:Update()
    if not ESP.Enabled then return end

    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local hrp = player.Character.HumanoidRootPart
            local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
            local pos, onscreen = Camera:WorldToViewportPoint(hrp.Position)

            if not ESP.Objects[player] then
                ESP.Objects[player] = CreateESP(player)
            end

            local box = ESP.Objects[player]

            if onscreen and humanoid and humanoid.Health > 0 then
                local scale = math.clamp((Camera.CFrame.Position - hrp.Position).Magnitude / 20, 2, 6)
                local width, height = 28 * scale, 55 * scale

                -- Box
                box.Box.Size = Vector2.new(width, height)
                box.Box.Position = Vector2.new(pos.X - width / 2, pos.Y - height / 2)
                box.Box.Thickness = 1
                box.Box.Color = Color3.fromRGB(255, 255, 255)
                box.Box.Visible = true

                -- Fill
                box.Filled.Size = Vector2.new(width, height)
                box.Filled.Position = Vector2.new(pos.X - width / 2, pos.Y - height / 2)
                box.Filled.Color = Color3.fromRGB(90, 130, 255)
                box.Filled.Transparency = 0.75
                box.Filled.Filled = true
                box.Filled.Visible = true

                -- Health bar
                box.HealthbarOutline.Size = Vector2.new(4, height + 2)
                box.HealthbarOutline.Position = Vector2.new(pos.X - width / 2 - 6, pos.Y - height / 2 - 1)
                box.HealthbarOutline.Color = Color3.fromRGB(0,0,0)
                box.HealthbarOutline.Visible = true

                local healthPercent = humanoid.Health / humanoid.MaxHealth
                box.Healthbar.Size = Vector2.new(2, (height - 2) * healthPercent)
                box.Healthbar.Position = Vector2.new(pos.X - width / 2 - 5, pos.Y + height/2 - box.Healthbar.Size.Y)
                box.Healthbar.Color = Color3.fromRGB(255, 0, 0)
                box.Healthbar.Visible = true

                -- Name
                box.Name.Text = player.DisplayName
                box.Name.Position = Vector2.new(pos.X, pos.Y - height / 2 - 16)
                box.Name.Center = true
                box.Name.Size = 13
                box.Name.Color = Color3.fromRGB(255, 255, 255)
                box.Name.Outline = true
                box.Name.Visible = true

                -- Distance
                local distance = math.floor((Camera.CFrame.Position - hrp.Position).Magnitude)
                box.Distance.Text = tostring(distance).."m"
                box.Distance.Position = Vector2.new(pos.X, pos.Y + height / 2 + 2)
                box.Distance.Center = true
                box.Distance.Size = 13
                box.Distance.Color = Color3.fromRGB(255, 255, 255)
                box.Distance.Outline = true
                box.Distance.Visible = true
            else
                for _, drawing in pairs(box) do
                    if typeof(drawing) == "Instance" or typeof(drawing) == "table" then
                        if drawing.Visible ~= nil then
                            drawing.Visible = false
                        end
                    end
                end
            end
        elseif ESP.Objects[player] then
            for _, drawing in pairs(ESP.Objects[player]) do
                if typeof(drawing) == "Instance" or typeof(drawing) == "table" then
                    if drawing.Visible ~= nil then
                        drawing.Visible = false
                    end
                end
            end
        end
    end
end

RunService.RenderStepped:Connect(function()
    ESP:Update()
end)

return ESP
