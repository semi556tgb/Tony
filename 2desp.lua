-- 2desp.lua - Clean Player ESP Script

-- Settings
local ESP_ENABLED = true
local ESP_FILL_COLOR = Color3.fromRGB(0, 170, 255)      -- Light blue
local ESP_OUTLINE_COLOR = Color3.fromRGB(255, 255, 255) -- White
local ESP_FILL_TRANSPARENCY = 0.75
local ESP_OUTLINE_TRANSPARENCY = 0

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")

-- Table to store ESP elements
local ESPObjects = {}

-- Function to create ESP for a character
local function CreateESP(player)
    if player == LocalPlayer then return end  -- Skip local player
    if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then return end

    -- Check if already exists
    if ESPObjects[player] then return end

    -- Create Highlight
    local highlight = Instance.new("Highlight")
    highlight.Adornee = player.Character
    highlight.FillColor = ESP_FILL_COLOR
    highlight.FillTransparency = ESP_FILL_TRANSPARENCY
    highlight.OutlineColor = ESP_OUTLINE_COLOR
    highlight.OutlineTransparency = ESP_OUTLINE_TRANSPARENCY
    highlight.Parent = game.CoreGui

    -- Create Name Tag
    local billboard = Instance.new("BillboardGui")
    billboard.Name = "ESP_Name"
    billboard.Adornee = player.Character:FindFirstChild("HumanoidRootPart")
    billboard.Size = UDim2.new(0, 200, 0, 50)
    billboard.StudsOffset = Vector3.new(0, 3, 0)
    billboard.AlwaysOnTop = true
    billboard.Parent = game.CoreGui

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = player.Name
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.TextStrokeTransparency = 0.5
    label.Font = Enum.Font.SourceSansBold
    label.TextScaled = true
    label.Parent = billboard

    ESPObjects[player] = {highlight = highlight, nameTag = billboard}
end

-- Function to remove ESP when a player leaves or dies
local function RemoveESP(player)
    if ESPObjects[player] then
        for _, obj in pairs(ESPObjects[player]) do
            if obj then obj:Destroy() end
        end
        ESPObjects[player] = nil
    end
end

-- Main ESP Update Loop
local function UpdateESP()
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            CreateESP(player)
        else
            RemoveESP(player)
        end
    end
end

-- Setup: monitor new characters and players
Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function()
        wait(1)  -- Let the character load fully
        if ESP_ENABLED then
            CreateESP(player)
        end
    end)
end)

Players.PlayerRemoving:Connect(function(player)
    RemoveESP(player)
end)

-- Update Loop
RunService.Heartbeat:Connect(function()
    if ESP_ENABLED then
        UpdateESP()
    end
end)

print("2D ESP Loaded Successfully.")
