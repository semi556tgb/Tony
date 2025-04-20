-- Eclipse.wtf Style 2D Box ESP with Corner Boxes + Health Bar

local ESP = {}

local function Draw(type)
    local obj = Drawing.new(type)
    obj.Visible = false
    return obj
end

local function CreateCornerBox()
    return {
        LineTL = Draw("Line"),
        LineTR = Draw("Line"),
        LineBL = Draw("Line"),
        LineBR = Draw("Line"),
        HealthBar = Draw("Line"),
        HealthBack = Draw("Line")
    }
end

function ESP:New(Player)
    local Box = CreateCornerBox()

    local function Update()
        if not getgenv().LoadedESP or not getgenv().LoadedESP.Settings.MasterSwitch then
            for _,v in pairs(Box) do v.Visible = false end
            return
        end

        local Character = Player.Character
        local HRP = Character and Character:FindFirstChild("HumanoidRootPart")
        local Humanoid = Character and Character:FindFirstChildOfClass("Humanoid")

        if HRP and Humanoid and Humanoid.Health > 0 then
            local Pos, OnScreen = workspace.CurrentCamera:WorldToViewportPoint(HRP.Position)

            if OnScreen then
                local scale = math.clamp(15 / (HRP.Position - workspace.CurrentCamera.CFrame.Position).Magnitude, 2, 5)
                local size = Vector2.new(35 * scale, 55 * scale)
                local topLeft = Vector2.new(Pos.X - size.X / 2, Pos.Y - size.Y / 2)
                local bottomRight = Vector2.new(Pos.X + size.X / 2, Pos.Y + size.Y / 2)
                
                local lineLength = size.X * 0.2

                -- Top-Left Corner
                Box.LineTL.From = topLeft
                Box.LineTL.To = Vector2.new(topLeft.X + lineLength, topLeft.Y)
                Box.LineTL.Color = Color3.new(0,1,0)
                Box.LineTL.Thickness = 1
                Box.LineTL.Visible = true

                Box.LineBL.From = topLeft
                Box.LineBL.To = Vector2.new(topLeft.X, topLeft.Y + lineLength)
                Box.LineBL.Color = Color3.new(0,1,0)
                Box.LineBL.Thickness = 1
                Box.LineBL.Visible = true

                -- Top-Right Corner
                Box.LineTR.From = Vector2.new(bottomRight.X - lineLength, topLeft.Y)
                Box.LineTR.To = Vector2.new(bottomRight.X, topLeft.Y)
                Box.LineTR.Color = Color3.new(0,1,0)
                Box.LineTR.Thickness = 1
                Box.LineTR.Visible = true

                -- Bottom-Right Corner
                Box.LineBR.From = Vector2.new(bottomRight.X, bottomRight.Y - lineLength)
                Box.LineBR.To = bottomRight
                Box.LineBR.Color = Color3.new(0,1,0)
                Box.LineBR.Thickness = 1
                Box.LineBR.Visible = true

                -- Health Bar
                if getgenv().LoadedESP.Settings.HealthBar then
                    local health = Humanoid.Health / Humanoid.MaxHealth
                    local barHeight = size.Y * health

                    Box.HealthBack.From = Vector2.new(topLeft.X - 6, bottomRight.Y)
                    Box.HealthBack.To = Vector2.new(topLeft.X - 6, topLeft.Y)
                    Box.HealthBack.Color = Color3.new(0,0,0)
                    Box.HealthBack.Thickness = 2
                    Box.HealthBack.Visible = true

                    Box.HealthBar.From = Vector2.new(topLeft.X - 6, bottomRight.Y)
                    Box.HealthBar.To = Vector2.new(topLeft.X - 6, bottomRight.Y - barHeight)
                    Box.HealthBar.Color = Color3.fromRGB(0,255,0)
                    Box.HealthBar.Thickness = 2
                    Box.HealthBar.Visible = true
                else
                    Box.HealthBack.Visible = false
                    Box.HealthBar.Visible = false
                end

            else
                for _,v in pairs(Box) do v.Visible = false end
            end

        else
            for _,v in pairs(Box) do v.Visible = false end
        end
    end

    game:GetService("RunService").RenderStepped:Connect(Update)
end

return ESP
