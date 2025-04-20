-- 2dbox.lua
local ESP = {}
ESP.Enabled = false

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

local function CreateBox(target)
    local box = Drawing.new("Square")
    box.Thickness = 2
    box.Color = Color3.fromRGB(255, 0, 0)
    box.Filled = false
    box.Visible = false
    return {
        Target = target,
        Drawing = box
    }
end

ESP.Boxes = {}

function ESP.SetEnabled(state)
    ESP.Enabled = state
    if not state then
        for _, box in pairs(ESP.Boxes) do
            box.Drawing.Visible = false
        end
    end
end

function ESP:Update()
    if not ESP.Enabled then return end

    for i, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local hrp = player.Character.HumanoidRootPart
            local vector, onScreen = workspace.CurrentCamera:WorldToViewportPoint(hrp.Position)

            if not ESP.Boxes[player] then
                ESP.Boxes[player] = CreateBox(player)
            end

            local box = ESP.Boxes[player]
            box.Drawing.Visible = onScreen and ESP.Enabled

            if onScreen then
                box.Drawing.Size = Vector2.new(60, 100) -- width, height
                box.Drawing.Position = Vector2.new(vector.X - 30, vector.Y - 50) -- center it on the player
            end
        elseif ESP.Boxes[player] then
            ESP.Boxes[player].Drawing.Visible = false
        end
    end
end

RunService.RenderStepped:Connect(function()
    ESP:Update()
end)

return ESP
