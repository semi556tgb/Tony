local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local Camera = workspace.CurrentCamera

local ESP2D = {
    Enabled = true,
    MaxDistance = 200,
    Boxes = {}
}

-- Create a new 2D box
function ESP2D:CreateBox(player)
    local frame = Instance.new("Frame")
    frame.Name = player.Name .. "_ESPBox"
    frame.Parent = CoreGui
    frame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    frame.BackgroundTransparency = 0.75
    frame.BorderSizePixel = 0
    frame.Visible = false

    self.Boxes[player] = frame
end

-- Remove the 2D box when player leaves
function ESP2D:RemoveBox(player)
    if self.Boxes[player] then
        self.Boxes[player]:Destroy()
        self.Boxes[player] = nil
    end
end

-- Update ESP positions each frame
function ESP2D:Update()
    RunService.RenderStepped:Connect(function()
        if not self.Enabled then
            for _, box in pairs(self.Boxes) do
                box.Visible = false
            end
            return
        end

        for _, player in pairs(Players:GetPlayers()) do
            if player ~= Players.LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                local hrp = player.Character.HumanoidRootPart
                local distance = (Camera.CFrame.Position - hrp.Position).Magnitude

                if distance <= self.MaxDistance then
                    local pos, onScreen = Camera:WorldToViewportPoint(hrp.Position)
                    local size = hrp.Size.Y
                    local scaleFactor = (size * Camera.ViewportSize.Y) / (pos.Z * 2)
                    local w, h = 3 * scaleFactor, 4.5 * scaleFactor

                    if onScreen then
                        if not self.Boxes[player] then
                            self:CreateBox(player)
                        end

                        local box = self.Boxes[player]
                        box.Size = UDim2.new(0, w, 0, h)
                        box.Position = UDim2.new(0, pos.X - w / 2, 0, pos.Y - h / 2)
                        box.Visible = true
                    else
                        if self.Boxes[player] then
                            self.Boxes[player].Visible = false
                        end
                    end
                elseif self.Boxes[player] then
                    self.Boxes[player].Visible = false
                end
            elseif self.Boxes[player] then
                self.Boxes[player].Visible = false
            end
        end
    end)
end

-- Initialize: auto create & cleanup for players
function ESP2D:Start()
    for _, player in pairs(Players:GetPlayers()) do
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

return ESP2D
