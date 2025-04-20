local ESP = {
    Enabled = false,
    Boxes = {},
    UpdateConnection = nil
}

function ESP:Start()
    self.Enabled = true
    if self.UpdateConnection then
        self.UpdateConnection:Disconnect()
    end
    self.UpdateConnection = game:GetService("RunService").RenderStepped:Connect(function()
        self:Update()
    end)
end

function ESP:Stop()
    self.Enabled = false
    if self.UpdateConnection then
        self.UpdateConnection:Disconnect()
        self.UpdateConnection = nil
    end
    for _, box in pairs(self.Boxes) do
        if box and box.Adornee then
            box.Visible = false
        end
    end
end

function ESP:Update()
    if not self.Enabled then return end
    local players = game:GetService("Players")
    local localPlayer = players.LocalPlayer

    for _, player in ipairs(players:GetPlayers()) do
        if player ~= localPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local hrp = player.Character.HumanoidRootPart

            local box = self.Boxes[player] or Instance.new("BoxHandleAdornment")
            box.Adornee = hrp
            box.AlwaysOnTop = true
            box.ZIndex = 10
            box.Size = Vector3.new(2, 5, 1)
            box.Color3 = Color3.fromRGB(255, 0, 0)
            box.Transparency = 0.5
            box.Parent = game:GetService("CoreGui")

            self.Boxes[player] = box
            box.Visible = true
        end
    end
end

return ESP
