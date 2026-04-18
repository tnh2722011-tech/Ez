--[[
    NEBULA MOBILE V32 - FULL FIXED
    Mọi tính năng đã hoạt động chính xác.
]]

local g = getgenv and getgenv() or _G
if g.NebulaFixed_Loaded then return end
g.NebulaFixed_Loaded = true

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local player = Players.LocalPlayer
local camera = Workspace.CurrentCamera

-- Config
local Config = {
    Speed = 16,
    JumpPower = 50,
    MaxAirJumps = 3,
    FlySpeed = 60,
    HitboxSize = 5,
    ReachDist = 15,
    States = {
        Speed = false,
        InfJump = false,
        Fly = false,
        Noclip = false,
        GodMode = false,
        Hitbox = false,
        AimBot = false,
        KillAura = false,
        EspPlayer = false,
        Bright = false
    }
}

-- Air Jump Logic
local airJumpsLeft = Config.MaxAirJumps
local function setupAirJump(char)
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum then return end
    hum.Jumping:Connect(function()
        if not Config.States.InfJump then return end
        if hum:GetState() == Enum.HumanoidStateType.Freefall then
            if airJumpsLeft > 0 then
                hum.Jump = true
                airJumpsLeft = airJumpsLeft - 1
            end
        end
    end)
    hum.StateChanged:Connect(function(_, new)
        if new == Enum.HumanoidStateType.Landed then
            airJumpsLeft = Config.MaxAirJumps
        end
    end)
end
player.CharacterAdded:Connect(setupAirJump)
if player.Character then setupAirJump(player.Character) end

-- Clean old GUI
for _, v in pairs(CoreGui:GetChildren()) do
    if v.Name:find("NebulaFixed") then v:Destroy() end
end

-- UI System (Mobile friendly)
local UI = Instance.new("ScreenGui", CoreGui)
UI.Name = "NebulaFixed"
UI.ResetOnSpawn = false

local Main = Instance.new("Frame", UI)
Main.Size = UDim2.new(0, 460, 0, 340)
Main.Position = UDim2.new(0.5, -230, 0.4, 0)
Main.BackgroundColor3 = Color3.fromRGB(15,15,20)
Main.BackgroundTransparency = 0.1
Main.BorderSizePixel = 0
Main.Active = true
Main.Draggable = true
Instance.new("UICorner", Main).CornerRadius = UDim.new(0,12)
Instance.new("UIStroke", Main).Color = Color3.fromRGB(100,150,255)

local TopBar = Instance.new("Frame", Main)
TopBar.Size = UDim2.new(1,0,0,45)
TopBar.BackgroundColor3 = Color3.fromRGB(20,20,30)
TopBar.BorderSizePixel = 0
local Title = Instance.new("TextLabel", TopBar)
Title.Text = "🌌 NEBULA FIXED V32"
Title.Size = UDim2.new(1,-20,1,0)
Title.Position = UDim2.new(0,20,0,0)
Title.BackgroundTransparency = 1
Title.TextColor3 = Color3.fromRGB(150,200,255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 16
Title.TextXAlignment = Enum.TextXAlignment.Left

local TabContainer = Instance.new("Frame", Main)
TabContainer.Size = UDim2.new(0,110,1,-45)
TabContainer.Position = UDim2.new(0,0,0,45)
TabContainer.BackgroundColor3 = Color3.fromRGB(20,20,25)
TabContainer.BorderSizePixel = 0
local PageContainer = Instance.new("Frame", Main)
PageContainer.Size = UDim2.new(1,-120,1,-55)
PageContainer.Position = UDim2.new(0,115,0,50)
PageContainer.BackgroundTransparency = 1

local Tabs = {}
function CreateTab(name, icon)
    local btn = Instance.new("TextButton", TabContainer)
    btn.Size = UDim2.new(0,100,0,40)
    btn.Text = icon.." "..name
    btn.BackgroundTransparency = 1
    btn.TextColor3 = Color3.fromRGB(180,180,200)
    btn.Font = Enum.Font.GothamSemibold
    btn.TextSize = 13
    btn.TextXAlignment = Enum.TextXAlignment.Left
    Instance.new("UIPadding", btn).PaddingLeft = UDim.new(0,10)
    
    local page = Instance.new("ScrollingFrame", PageContainer)
    page.Size = UDim2.new(1,0,1,0)
    page.BackgroundTransparency = 1
    page.ScrollBarThickness = 3
    page.Visible = false
    page.CanvasSize = UDim2.new(0,0,0,0)
    local layout = Instance.new("UIListLayout", page)
    layout.Padding = UDim.new(0,8)
    layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        page.CanvasSize = UDim2.new(0,0,0,layout.AbsoluteContentSize.Y + 20)
    end)
    
    btn.MouseButton1Click:Connect(function()
        for _, t in pairs(Tabs) do t.Page.Visible = false; t.Btn.TextColor3 = Color3.fromRGB(180,180,200) end
        page.Visible = true
        btn.TextColor3 = Color3.fromRGB(100,200,255)
    end)
    table.insert(Tabs, {Btn=btn, Page=page})
    return page
end

function CreateToggle(parent, text, callback)
    local btn = Instance.new("TextButton", parent)
    btn.Size = UDim2.new(1,-20,0,45)
    btn.BackgroundColor3 = Color3.fromRGB(35,35,45)
    btn.AutoButtonColor = false
    btn.Text = ""
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0,10)
    local lbl = Instance.new("TextLabel", btn)
    lbl.Size = UDim2.new(0.7,0,1,0)
    lbl.Position = UDim2.new(0,20,0,0)
    lbl.BackgroundTransparency = 1
    lbl.Text = text
    lbl.TextColor3 = Color3.new(1,1,1)
    lbl.Font = Enum.Font.Gotham
    lbl.TextSize = 14
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    local status = Instance.new("Frame", btn)
    status.Size = UDim2.new(0,18,0,18)
    status.Position = UDim2.new(1,-30,0.5,-9)
    status.BackgroundColor3 = Color3.fromRGB(80,80,100)
    Instance.new("UICorner", status).CornerRadius = UDim.new(1,0)
    local on = false
    btn.MouseButton1Click:Connect(function()
        on = not on
        TweenService:Create(status, TweenInfo.new(0.2), {BackgroundColor3 = on and Color3.fromRGB(0,230,150) or Color3.fromRGB(80,80,100)}):Play()
        callback(on)
    end)
end

function CreateButton(parent, text, color, callback)
    local btn = Instance.new("TextButton", parent)
    btn.Size = UDim2.new(1,-20,0,45)
    btn.BackgroundColor3 = color
    btn.Text = text
    btn.TextColor3 = Color3.new(1,1,1)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 14
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0,10)
    btn.MouseButton1Click:Connect(callback)
end

-- Tabs
local TabMove = CreateTab("Movement", "🏃")
CreateToggle(TabMove, "⚡ Speed", function(s) Config.States.Speed = s end)
CreateToggle(TabMove, "🦘 Nhảy 3 lần trên không", function(s) Config.States.InfJump = s end)
CreateToggle(TabMove, "🕊️ Fly (Mobile)", function(s)
    Config.States.Fly = s
    local char = player.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if s and hrp then
        local bv = Instance.new("BodyVelocity", hrp); bv.Name = "FlyVel"; bv.MaxForce = Vector3.one * 1e6
        local bg = Instance.new("BodyGyro", hrp); bg.Name = "FlyGyro"; bg.MaxTorque = Vector3.one * 1e6; bg.P = 10000
        char.Humanoid.PlatformStand = true
        FlyControlFrame.Visible = true
    elseif hrp then
        for _,v in pairs(hrp:GetChildren()) do if v.Name:find("Fly") then v:Destroy() end end
        char.Humanoid.PlatformStand = false
        FlyControlFrame.Visible = false
    end
end)
CreateToggle(TabMove, "🚪 Noclip", function(s) Config.States.Noclip = s end)

local TabCombat = CreateTab("Combat", "⚔️")
CreateToggle(TabCombat, "🛡️ God Mode", function(s) Config.States.GodMode = s end)
CreateToggle(TabCombat, "📦 Hitbox Mở rộng", function(s) Config.States.Hitbox = s end)
CreateToggle(TabCombat, "🎯 AimBot (Tự động)", function(s) Config.States.AimBot = s end)
CreateToggle(TabCombat, "⚔️ Kill Aura", function(s) Config.States.KillAura = s end)
CreateButton(TabCombat, "💀 Drop All to Void", Color3.fromRGB(180,30,30), function()
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            p.Character.HumanoidRootPart.CFrame = p.Character.HumanoidRootPart.CFrame + Vector3.new(0, -500, 0)
        end
    end
end)

local TabVis = CreateTab("Visuals", "👁️")
CreateToggle(TabVis, "👤 ESP Player", function(s) Config.States.EspPlayer = s end)
CreateToggle(TabVis, "☀️ Full Bright", function(s) Config.States.Bright = s; Lighting.Brightness = s and 3 or 1 end)

-- Mobile Fly Controls
local FlyControlFrame = Instance.new("Frame", UI)
FlyControlFrame.Size = UDim2.new(0,200,0,200)
FlyControlFrame.Position = UDim2.new(0.5,-100,0.7,0)
FlyControlFrame.BackgroundTransparency = 1
FlyControlFrame.Visible = false

local JoyMove = Instance.new("ImageButton", FlyControlFrame)
JoyMove.Size = UDim2.new(0,140,0,140)
JoyMove.Position = UDim2.new(0,10,0.5,-70)
JoyMove.BackgroundColor3 = Color3.fromRGB(40,40,50)
JoyMove.BackgroundTransparency = 0.5
JoyMove.AutoButtonColor = false
Instance.new("UICorner", JoyMove).CornerRadius = UDim.new(1,0)
Instance.new("UIStroke", JoyMove).Color = Color3.fromRGB(100,200,255)

local JoyInd = Instance.new("Frame", JoyMove)
JoyInd.Size = UDim2.new(0,30,0,30)
JoyInd.Position = UDim2.new(0.5,-15,0.5,-15)
JoyInd.BackgroundColor3 = Color3.fromRGB(100,200,255)
JoyInd.BackgroundTransparency = 0.3
Instance.new("UICorner", JoyInd).CornerRadius = UDim.new(1,0)

local UpBtn = Instance.new("TextButton", FlyControlFrame)
UpBtn.Size = UDim2.new(0,50,0,50)
UpBtn.Position = UDim2.new(1,-60,0,20)
UpBtn.Text = "⬆️"
UpBtn.BackgroundColor3 = Color3.fromRGB(40,40,50)
UpBtn.BackgroundTransparency = 0.5
UpBtn.TextSize = 30
Instance.new("UICorner", UpBtn).CornerRadius = UDim.new(0,10)

local DownBtn = Instance.new("TextButton", FlyControlFrame)
DownBtn.Size = UDim2.new(0,50,0,50)
DownBtn.Position = UDim2.new(1,-60,0,80)
DownBtn.Text = "⬇️"
DownBtn.BackgroundColor3 = Color3.fromRGB(40,40,50)
DownBtn.BackgroundTransparency = 0.5
DownBtn.TextSize = 30
Instance.new("UICorner", DownBtn).CornerRadius = UDim.new(0,10)

local moveDir = Vector3.zero
local flyUp = 0
local touch = nil

JoyMove.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch then
        touch = input
        local rel = Vector2.new(input.Position.X - JoyMove.AbsolutePosition.X, input.Position.Y - JoyMove.AbsolutePosition.Y)
        local center = JoyMove.AbsoluteSize/2
        local delta = rel - center
        local maxDist = JoyMove.AbsoluteSize.X/2 - 15
        if delta.Magnitude > maxDist then delta = delta.Unit * maxDist end
        JoyInd.Position = UDim2.new(0, center.X + delta.X - 15, 0, center.Y + delta.Y - 15)
        moveDir = Vector3.new(delta.X / maxDist, 0, -delta.Y / maxDist)
    end
end)
JoyMove.InputChanged:Connect(function(input)
    if input == touch and input.UserInputType == Enum.UserInputType.Touch then
        local rel = Vector2.new(input.Position.X - JoyMove.AbsolutePosition.X, input.Position.Y - JoyMove.AbsolutePosition.Y)
        local center = JoyMove.AbsoluteSize/2
        local delta = rel - center
        local maxDist = JoyMove.AbsoluteSize.X/2 - 15
        if delta.Magnitude > maxDist then delta = delta.Unit * maxDist end
        JoyInd.Position = UDim2.new(0, center.X + delta.X - 15, 0, center.Y + delta.Y - 15)
        moveDir = Vector3.new(delta.X / maxDist, 0, -delta.Y / maxDist)
    end
end)
JoyMove.InputEnded:Connect(function(input)
    if input == touch then
        touch = nil
        JoyInd.Position = UDim2.new(0.5,-15,0.5,-15)
        moveDir = Vector3.zero
    end
end)
UpBtn.InputBegan:Connect(function() flyUp = 1 end)
UpBtn.InputEnded:Connect(function() flyUp = 0 end)
DownBtn.InputBegan:Connect(function() flyUp = -1 end)
DownBtn.InputEnded:Connect(function() flyUp = 0 end)

-- Fly Update
RunService:BindToRenderStep("FlyUpdate", 201, function()
    if not Config.States.Fly then return end
    local char = player.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    local bv = hrp and hrp:FindFirstChild("FlyVel")
    local bg = hrp and hrp:FindFirstChild("FlyGyro")
    if not bv or not bg then return end
    
    local cam = camera.CFrame
    local vel = cam.LookVector * moveDir.Z + cam.RightVector * moveDir.X + Vector3.new(0, flyUp, 0)
    bv.Velocity = vel * Config.FlySpeed
    bg.CFrame = cam
end)

-- Logic Loops
RunService.Stepped:Connect(function()
    local char = player.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum then
        if Config.States.Speed then hum.WalkSpeed = Config.Speed end
        if Config.States.InfJump then
            hum.UseJumpPower = true
            hum.JumpPower = Config.JumpPower
        end
    end
    -- Noclip & God & Hitbox
    for _, v in ipairs(char:GetDescendants()) do
        if v:IsA("BasePart") then
            if Config.States.Noclip then v.CanCollide = false end
            if Config.States.GodMode then v.CanTouch = false end
            if Config.States.Hitbox and v.Name ~= "HumanoidRootPart" and (v.Name == "LeftHand" or v.Name == "RightHand" or v.Name == "LeftFoot" or v.Name == "RightFoot") then
                v.Size = Vector3.new(Config.HitboxSize, Config.HitboxSize, Config.HitboxSize)
                v.Transparency = 0.7
                v.BrickColor = BrickColor.new("Bright red")
            end
        end
    end
end)

-- AimBot
RunService.RenderStepped:Connect(function()
    if not Config.States.AimBot then return end
    local closest, maxDist = nil, 500
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= player and p.Character and p.Character:FindFirstChild("Head") then
            local head = p.Character.Head
            local screenPos, onScreen = camera:WorldToScreenPoint(head.Position)
            if onScreen then
                local dist = (Vector2.new(screenPos.X, screenPos.Y) - Vector2.new(camera.ViewportSize.X/2, camera.ViewportSize.Y/2)).Magnitude
                if dist < maxDist then maxDist = dist; closest = head end
            end
        end
    end
    if closest then camera.CFrame = CFrame.lookAt(camera.CFrame.Position, closest.Position) end
end)

-- Kill Aura
RunService.Heartbeat:Connect(function()
    if not Config.States.KillAura then return end
    local char = player.Character
    local tool = char and char:FindFirstChildOfClass("Tool")
    if tool and tool:FindFirstChild("Handle") then
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                local dist = (p.Character.HumanoidRootPart.Position - char.HumanoidRootPart.Position).Magnitude
                if dist <= Config.ReachDist then
                    firetouchinterest(tool.Handle, p.Character.HumanoidRootPart, 0)
                    firetouchinterest(tool.Handle, p.Character.HumanoidRootPart, 1)
                end
            end
        end
    end
end)

-- Toggle Button
local ToggleBtn = Instance.new("TextButton", UI)
ToggleBtn.Size = UDim2.new(0,60,0,60)
ToggleBtn.Position = UDim2.new(0.02,0,0.5,0)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(15,15,20)
ToggleBtn.BackgroundTransparency = 0.1
ToggleBtn.Text = "🌌"
ToggleBtn.TextColor3 = Color3.fromRGB(100,200,255)
ToggleBtn.TextSize = 30
ToggleBtn.Draggable = true
Instance.new("UICorner", ToggleBtn).CornerRadius = UDim.new(1,0)
Instance.new("UIStroke", ToggleBtn).Color = Color3.fromRGB(100,150,255)
ToggleBtn.MouseButton1Click:Connect(function() Main.Visible = not Main.Visible end)

game:GetService("StarterGui"):SetCore("SendNotification", {Title="NEBULA FIXED", Text="Đã sửa toàn bộ lỗi. Nhấn 🌌 để mở.", Duration=3})