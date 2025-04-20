local ESP = {}
ESP.Enabled = false
ESP.Boxes = {}
ESP.Connection = nil

function ESP:CreateBox(player)
    local box = Drawing.new("Square")
    box.Color = Color3.fromRGB(255, 0, 0)
    box.Thickness = 2
    box.Filled = false
    box.Visible = false
    self.Boxes[player] = box
end

function ESP:RemoveBox(player)
    if self.Boxes[player] then
        self.Boxes[player]:Remove()
        self.Boxes[player] = nil
    end
end

function ESP:Update()
    if not self.Enabled then
        for _, box in pairs(self.Boxes) do
            box.Visible = false
        end
        return
    end

    local camera = workspace.CurrentCamera
    for _, player in pairs(game.Players:GetPlayers()) do
        if player ~= game.Players.LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            if not self.Boxes[player] then
                self:CreateBox(player)
            end

            local hrp = player.Character.HumanoidRootPart
            local vector, onScreen = camera:WorldToViewportPoint(hrp.Position)

            if onScreen then
                local size = Vector2.new(1000 / (vector.Z + 2), 1500 / (vector.Z + 2))
                self.Boxes[player].Size = size
                self.Boxes[player].Position = Vector2.new(vector.X - size.X / 2, vector.Y - size.Y / 2)
                self.Boxes[player].Visible = true
            else
                self.Boxes[player].Visible = false
            end
        elseif self.Boxes[player] then
            self.Boxes[player].Visible = false
        end
    end
end

function ESP:Start()
    self.Enabled = true
    if self.Connection then
        self.Connection:Disconnect()
    end
    self.Connection = game:GetService("RunService").RenderStepped:Connect(function()
        self:Update()
    end)
end

function ESP:Stop()
    self.Enabled = false
    if self.Connection then
        self.Connection:Disconnect()
        self.Connection = nil
    end
    for _, box in pairs(self.Boxes) do
        box.Visible = false
    end
end

game.Players.PlayerRemoving:Connect(function(player)
    ESP:RemoveBox(player)
end)

return ESP
