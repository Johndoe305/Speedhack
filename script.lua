-- Rivals SpeedHack

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

-- Variáveis
local tpWalkEnabled = false
local tpSpeed = 2 -- Padrão 2 (1 a 2)
local connections = {}

-- Espera personagem
LocalPlayer.CharacterAdded:Connect(function()
    task.wait(1)
    if tpWalkEnabled then startTPWalk() end
end)

-- GUI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "RivalsSpeedHack"
screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true

-- Frame Principal
local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 240, 0, 200)
frame.Position = UDim2.new(0.02, 0, 0.5, -100)
frame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
frame.BorderSizePixel = 0
frame.Parent = screenGui

local frameCorner = Instance.new("UICorner")
frameCorner.CornerRadius = UDim.new(0, 14)
frameCorner.Parent = frame

local frameGradient = Instance.new("UIGradient")
frameGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(45, 45, 60)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(20, 20, 35))
})
frameGradient.Rotation = 45
frameGradient.Parent = frame

-- Título
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 35)
title.BackgroundTransparency = 1
title.Text = "Rivals SpeedHack"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.Font = Enum.Font.GothamBold
title.TextSize = 18
title.Parent = frame

-- Toggle Button
local toggleBtn = Instance.new("TextButton")
toggleBtn.Size = UDim2.new(0.9, 0, 0, 45)
toggleBtn.Position = UDim2.new(0.05, 0, 0.22, 0)
toggleBtn.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
toggleBtn.Text = "SpeedHack [OFF]"
toggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleBtn.Font = Enum.Font.GothamBold
toggleBtn.TextSize = 18
toggleBtn.Parent = frame

local toggleCorner = Instance.new("UICorner")
toggleCorner.CornerRadius = UDim.new(0, 12)
toggleCorner.Parent = toggleBtn

-- Speed Label
local speedLabel = Instance.new("TextLabel")
speedLabel.Size = UDim2.new(0.9, 0, 0, 25)
speedLabel.Position = UDim2.new(0.05, 0, 0.48, 0)
speedLabel.BackgroundTransparency = 1
speedLabel.Text = "Speed: " .. tpSpeed
speedLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
speedLabel.Font = Enum.Font.Gotham
speedLabel.TextSize = 15
speedLabel.Parent = frame

-- Speed Slider (1 a 2)
local speedSlider = Instance.new("Frame")
speedSlider.Size = UDim2.new(0.9, 0, 0, 10)
speedSlider.Position = UDim2.new(0.05, 0, 0.60, 0)
speedSlider.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
speedSlider.BorderSizePixel = 0
speedSlider.Parent = frame

local sliderCorner = Instance.new("UICorner")
sliderCorner.CornerRadius = UDim.new(0, 5)
sliderCorner.Parent = speedSlider

local sliderKnob = Instance.new("TextButton")
sliderKnob.Size = UDim2.new(0, 24, 1, 0)
sliderKnob.Position = UDim2.new((tpSpeed - 1) / 4 - 0.06, 0, 0, 0)
sliderKnob.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
sliderKnob.Text = ""
sliderKnob.BorderSizePixel = 0
sliderKnob.Parent = speedSlider

local knobCorner = Instance.new("UICorner")
knobCorner.CornerRadius = UDim.new(0, 5)
knobCorner.Parent = sliderKnob

-- Funções TPWalk
local function startTPWalk()
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    local rootPart = char.HumanoidRootPart

    tpWalkEnabled = true
    toggleBtn.Text = "SpeedHack [ON]"
    toggleBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 0)

    connections[#connections + 1] = RunService.Heartbeat:Connect(function()
        if not tpWalkEnabled then return end
        local humanoid = char:FindFirstChild("Humanoid")
        if not humanoid or humanoid.Health <= 0 then return end

        local moveDirection = humanoid.MoveDirection
        if moveDirection.Magnitude > 0 then
            local targetPos = rootPart.Position + (moveDirection * tpSpeed)
            rootPart.CFrame = CFrame.new(targetPos, targetPos + workspace.CurrentCamera.CFrame.LookVector)
        end
    end)
end

local function stopTPWalk()
    tpWalkEnabled = false
    toggleBtn.Text = "SpeedHack [OFF]"
    toggleBtn.BackgroundColor3 = Color3.fromRGB(150, 0, 0)

    for _, conn in ipairs(connections) do
        if conn.Connected then conn:Disconnect() end
    end
    connections = {}
end

-- Toggle
toggleBtn.MouseButton1Click:Connect(function()
    if tpWalkEnabled then stopTPWalk() else startTPWalk() end
end)

-- Speed Slider (1 a 2)
local draggingSlider = false
sliderKnob.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        draggingSlider = true
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if draggingSlider and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local relativeX = math.clamp((input.Position.X - speedSlider.AbsolutePosition.X) / speedSlider.AbsoluteSize.X, 0, 1)
        sliderKnob.Position = UDim2.new(relativeX - 0.06, 0, 0, 0)
        tpSpeed = math.floor(relativeX * 1) + 1 -- 1 a 2
        speedLabel.Text = "Speed: " .. tpSpeed
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        draggingSlider = false
    end
end)

-- Drag GUI
local dragging = false
local dragStart, startPos
frame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = frame.Position
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end)

print("Rivals TPWalk")
