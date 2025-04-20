local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera
local CoreGui = game:GetService("CoreGui")

local ESP = {
    Enabled = false,
    DrawBoxes = false,
    MaxDistance = 200,
    Boxes = {},
    UpdateConnection = nil
}

-- Create a box for a player
function ESP:CreateBox(player)
    if self.Boxes[player] then return end

    local frame = Instance.new("Frame")
    frame.Name = player.Name .. "_ESPBox"
    frame.Parent = CoreGui
    frame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    frame.BackgroundTransparency = 0.75
    frame.BorderSizePixel = 0
    frame.Visible = false

    self.Boxes[player] = frame
end

-- Remove box when player leaves
function ESP:RemoveBox(player)
    if self.Boxes[player] then
        self.Boxes[player]:Destroy()
        self.Boxes[player] = nil
    end
end

-- Update loop: runs every frame
function ESP:Update()
    if self.UpdateConnection then self.UpdateConnection:Disconnect() end

    self.UpdateConnection = RunService.RenderStepped:Connect(function()
        if not self.Enabled then
            for _, box in pairs(self.Boxes) do
                if box then box.Visible = false end
            end
            return
        end

        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= Players.LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                local hrp = player.Character.HumanoidRootPart
                local pos, onScreen = Camera:WorldToViewportPoint(hrp.Position)
                local distance = (Camera.CFrame.Position - hrp.Position).Magnitude

                if onScreen and distance <= self.MaxDistance then
                    self:CreateBox(player)

                    local sizeY = hrp.Size.Y
                    local scaleFactor = (sizeY * Camera.ViewportSize.Y) / (pos.Z * 2)
                    local width = 3 * scaleFactor
                    local height = 4.5 * scaleFactor

                    local box = self.Boxes[player]
                    box.Size = UDim2.new(0, width, 0, height)
                    box.Position = UDim2.new(0, pos.X - width / 2, 0, pos.Y - height / 2)
                    box.Visible = self.DrawBoxes
                elseif self.Boxes[player] then
                    self.Boxes[player].Visible = false
                end
            elseif self.Boxes[player] then
                self.Boxes[player].Visible = false
            end
        end
    end)
end

-- Start ESP (handles join/leave & loop)
function ESP:Start()
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= Players.LocalPlayer then
            self:CreateBox(player)
        end
    end

    Players.PlayerAdded:Connect(function(player)
        if player ~= Players.LocalPlayer then
            self:CreateBox(player)
        end
    end)

    Players.PlayerRemoving:Connect(function(player)
        self:RemoveBox(player)
    end)

    self:Update()
end

-- Stop ESP and hide boxes
function ESP:Stop()
    self.Enabled = false
    if self.UpdateConnection then
        self.UpdateConnection:Disconnect()
        self.UpdateConnection = nil
    end
    for _, box in pairs(self.Boxes) do
        if box then box.Visible = false end
    end
end

return ESP
