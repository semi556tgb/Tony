-- 2dbox.lua
-- Silentware ESP Drawing Logic - Clean Version

-- Global table to hold ESP data
getgenv().LoadedESP = {
    Settings = {
        MasterSwitch = false,
        BoxFill = false,
        HealthBar = false
    },
    Drawing = {}
}

local ESP = getgenv().LoadedESP

-- Create Drawing objects table
function CreateESP(player)
    if ESP.Drawing[player] then return end

    ESP.Drawing[player] = {
        BoxOutline = Drawing.new("Square"),
        Box = Drawing.new("Square"),
        BoxFill = Drawing.new("Square"),
        HealthbarOutline = Drawing.new("Square"),
        Healthbar = Drawing.new("Square"),
        NameTag = Drawing.new("Text")
    }

    -- Setup appearance
    ESP.Drawing[player].BoxOutline.Thickness = 3
    ESP.Drawing[player].BoxOutline.Color = Color3.fromRGB(0, 0, 0)

    ESP.Drawing[player].Box.Thickness = 1
    ESP.Drawing[player].Box.Color = Color3.fromRGB(255, 255, 255)

    ESP.Drawing[player].BoxFill.Color = Color3.fromRGB(0, 0, 0)
    ESP.Drawing[player].BoxFill.Transparency = 0.6

    ESP.Drawing[player].HealthbarOutline.Color = Color3.fromRGB(0, 0, 0)
    ESP.Drawing[player].HealthbarOutline.Thickness = 1

    ESP.Drawing[player].Healthbar.Color = Color3.fromRGB(0, 255, 0)
    ESP.Drawing[player].Healthbar.Thickness = 1

    ESP.Drawing[player].NameTag.Center = true
    ESP.Drawing[player].NameTag.Outline = true
    ESP.Drawing[player].NameTag.Color = Color3.fromRGB(255, 255, 255)
end

-- Hide or remove ESP drawings
function RemoveESP(player)
    if ESP.Drawing[player] then
        for _, obj in pairs(ESP.Drawing[player]) do
            obj:Remove()
        end
        ESP.Drawing[player] = nil
    end
end

-- Update ESP for one player
function UpdateESP(player, position2D, size, health, maxHealth)
    local objects = ESP.Drawing[player]
    if not objects then return end

    if not ESP.Settings.MasterSwitch then
        for _, obj in pairs(objects) do
            obj.Visible = false
        end
        return
    end

    -- Box outline
    objects.BoxOutline.Size = size + Vector2.new(3, 3)
    objects.BoxOutline.Position = position2D - Vector2.new(1.5, 1.5)
    objects.BoxOutline.Visible = true

    -- Main box
    objects.Box.Size = size
    objects.Box.Position = position2D
    objects.Box.Visible = true

    -- Box fill
    if ESP.Settings.BoxFill then
        objects.BoxFill.Size = size
        objects.BoxFill.Position = position2D
        objects.BoxFill.Visible = true
    else
        objects.BoxFill.Visible = false
    end

    -- Health bar
    if ESP.Settings.HealthBar then
        local healthPercent = math.clamp(health / maxHealth, 0, 1)
        local barHeight = size.Y * healthPercent

        objects.HealthbarOutline.Size = Vector2.new(4, size.Y + 2)
        objects.HealthbarOutline.Position = position2D - Vector2.new(6, 1)
        objects.HealthbarOutline.Visible = true

        objects.Healthbar.Size = Vector2.new(2, barHeight)
        objects.Healthbar.Position = Vector2.new(
            position2D.X - 5,
            position2D.Y + (size.Y - barHeight)
        )
        objects.Healthbar.Color = Color3.fromRGB(
            255 * (1 - healthPercent),
            255 * healthPercent,
            0
        )
        objects.Healthbar.Visible = true
    else
        objects.Healthbar.Visible = false
        objects.HealthbarOutline.Visible = false
    end

    -- Name tag
    objects.NameTag.Position = Vector2.new(position2D.X + size.X / 2, position2D.Y - 15)
    objects.NameTag.Text = player.Name
    objects.NameTag.Size = 13
    objects.NameTag.Visible = true
end

-- Clean up for players who leave
game.Players.PlayerRemoving:Connect(function(player)
    RemoveESP(player)
end)

-- Your main ESP loop
task.spawn(function()
    while task.wait() do
        for _, player in pairs(game.Players:GetPlayers()) do
            if player ~= game.Players.LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                local hrp = player.Character.HumanoidRootPart
                local pos, onScreen = workspace.CurrentCamera:WorldToViewportPoint(hrp.Position)

                if onScreen then
                    CreateESP(player)
                    -- Example dummy sizes, you can compute based on distance.
                    local size = Vector2.new(70, 110)
                    local topLeft = Vector2.new(pos.X - size.X / 2, pos.Y - size.Y / 2)

                    local humanoid = player.Character:FindFirstChildWhichIsA("Humanoid")
                    local health = humanoid and humanoid.Health or 0
                    local maxHealth = humanoid and humanoid.MaxHealth or 100

                    UpdateESP(player, topLeft, size, health, maxHealth)
                else
                    if ESP.Drawing[player] then
                        for _, obj in pairs(ESP.Drawing[player]) do
                            obj.Visible = false
                        end
                    end
                end
            else
                RemoveESP(player)
            end
        end
    end
end)
