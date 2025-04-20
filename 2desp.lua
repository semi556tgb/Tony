-- Clean 2D Box ESP for Roblox
-- Author: You
-- Version: Inspired by the style you posted

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local ESP_Enabled = true
local ESP_Objects = {}

function CreateESPBox(player)
    if player == LocalPlayer then return end
    if ESP_Objects[player] then return end

    local box = Drawing.new("Square")
    box.Visible = false
    box.Color = Color3.fromRGB(255, 0, 0) -- Red Box
    box.Thickness = 2
    box.Filled = false

    local name = Drawing.new("Text")
    name.Visible = false
    name.Color = Color3.fromRGB(255, 255, 255) -- White Text
    name.Center = true
    name.Outline = true
    name.Size = 14
    name.Font = 2 -- Monospace

    ESP_Objects[player] = {Box = box, Name = name}
end

function RemoveESP(player)
    if ESP_Objects[player] then
        ESP_Objects[player].Box:Remove()
        ESP_Objects[player].Name:Remove()
        ESP_Objects[player] = nil
    end
end

Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function()
        wait(1)
        CreateESPBox(player)
    end)
end)

Players.PlayerRemoving:Connect(RemoveESP)

RunService.RenderStepped:Connect(function()
    if not ESP_Enabled then
        for _, obj in pairs(ESP_Objects) do
            obj.Box.Visible = false
            obj.Name.Visible = false
        end
        return
    end

    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            if not ESP_Objects[player] then
                CreateESPBox(player)
            end

            local character = player.Character
            local hrp = character:FindFirstChild("HumanoidRootPart")
            if hrp then
                local pos, onScreen = Camera:WorldToViewportPoint(hrp.Position)
                if onScreen then
                    local head = character:FindFirstChild("Head")
                    local root = hrp

                    local headPos = Camera:WorldToViewportPoint(head.Position + Vector3.new(0, 0.3, 0))
                    local feetPos = Camera:WorldToViewportPoint(root.Position - Vector3.new(0, 3, 0))

                    local height = math.abs(headPos.Y - feetPos.Y)
                    local width = height / 2

                    ESP_Objects[player].Box.Size = Vector2.new(width, height)
                    ESP_Objects[player].Box.Position = Vector2.new(pos.X - width / 2, pos.Y - height / 2)
                    ESP_Objects[player].Box.Visible = true

                    ESP_Objects[player].Name.Text = player.Name
                    ESP_Objects[player].Name.Position = Vector2.new(pos.X, pos.Y - height / 2 - 15)
                    ESP_Objects[player].Name.Visible = true
                else
                    ESP_Objects[player].Box.Visible = false
                    ESP_Objects[player].Name.Visible = false
                end
            else
                RemoveESP(player)
            end
        elseif ESP_Objects[player] then
            ESP_Objects[player].Box.Visible = false
            ESP_Objects[player].Name.Visible = false
        end
    end
end)

print("2D Box ESP loaded successfully!")
