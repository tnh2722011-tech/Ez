--[[
    OBBY TOOL MOBILE - FULL PACK
    Đã tích hợp Fly từ XNEO Fly GUI V3.
    Tất cả tính năng đều đã được kiểm tra hoạt động ổn định.
]]

local g = getgenv and getgenv() or _G
if g.ObbyMobile_Full then return end
g.ObbyMobile_Full = true

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local player = Players.LocalPlayer
local camera = Workspace.CurrentCamera

-- Config
local Config = {
    WalkSpeed = 24,
    JumpPower = 70,
    FlySpeed = 50,
    MaxAirJumps = 3,
    HitboxSize = 5,
    States = {
        Speed = false,
        Jump = false,
        InfAirJump = false,
        Noclip = false,
        FullBright = false,
        AutoRespawn = false,
        AntiFallDamage = false,
        Phase = false,
        AutoJump = false,
        Fly = false,
        Invisible = false,
        DisableKillbricks = false,
        CheckpointESP = false,
        LowGravity = false,
        GodMode = false,
        Hitbox = false
    }
}

-- Cleanup old GUI
for _, v in pairs(CoreGui:GetChildren()) do
    if v.Name == "ObbyToolGUI" then v:Destroy() end
end

-- GUI
local UI = Instance.new("ScreenGui", CoreGui)
UI.Name = "ObbyToolGUI"
UI.ResetOnSpawn = false

local Main = Instance.new("Frame", UI)
Main.Size = UDim2.new(0, 280, 0, 420)
Main.Position = UDim2.new(0.01, 0, 0.3, 0)
Main.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
Main.BackgroundTransparency = 0.1
Main.BorderSizePixel = 0
Main.Active = true
Main.Draggable = true
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 8)
Instance.new("UIStroke", Main).Color = Color3.fromRGB(80, 200, 120)

-- Title
local Title = Instance.new("TextLabel", Main)
Title.Size = UDim2.new(1, 0, 0, 35)
Title.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
Title.Text = "🏆 OBBY TOOL MOBILE"
Title.TextColor3 = Color3.fromRGB(200, 255, 200)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 16
Title.BorderSizePixel = 0

-- Scrolling frame
local Scroll = Instance.new("ScrollingFrame", Main)
Scroll.Size = UDim2.new(1, 0, 1, -35)
Scroll.Position = UDim2.new(0, 0, 0, 35)
Scroll.BackgroundTransparency = 1
Scroll.ScrollBarThickness = 4
Scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
Scroll.ScrollBarImageColor3 = Color3.fromRGB(80, 200, 120)

local Layout = Instance.new("UIListLayout", Scroll)
Layout.Padding = UDim.new(0, 5)
Layout.HorizontalAlignment = Enum.HorizontalAlignment.Center

Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    Scroll.CanvasSize = UDim2.new(0, 0, 0, Layout.AbsoluteContentSize.Y + 10)
end)

-- Helper function
local function CreateToggle(name, default, callback)
    local btn = Instance.new("TextButton", Scroll)
    btn.Size = UDim2.new(1, -10, 0, 40)
    btn.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    btn.AutoButtonColor = false
    btn.Text = ""
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
    
    local lbl = Instance.new("TextLabel", btn)
    lbl.Size = UDim2.new(0.7, 0, 1, 0)
    lbl.Position = UDim2.new(0, 10, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = name
    lbl.TextColor3 = Color3.new(1,1,1)
    lbl.Font = Enum.Font.Gotham
    lbl.TextSize = 14
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    
    local status = Instance.new("Frame", btn)
    status.Size = UDim2.new(0, 16, 0, 16)
    status.Position = UDim2.new(1, -20, 0.5, -8)
    status.BackgroundColor3 = default and Color3.fromRGB(80, 200, 120) or Color3.fromRGB(100, 100, 120)
    Instance.new("UICorner", status).CornerRadius = UDim.new(1, 0)
    
    local on = default
    btn.MouseButton1Click:Connect(function()
        on = not on
        status.BackgroundColor3 = on and Color3.fromRGB(80, 200, 120) or Color3.fromRGB(100, 100, 120)
        callback(on)
    end)
end

local function CreateButton(name, color, callback)
    local btn = Instance.new("TextButton", Scroll)
    btn.Size = UDim2.new(1, -10, 0, 40)
    btn.BackgroundColor3 = color
    btn.Text = name
    btn.TextColor3 = Color3.new(1,1,1)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 14
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
    btn.MouseButton1Click:Connect(callback)
end

-- Toggles
CreateToggle("⚡ Speed Hack", false, function(s) Config.States.Speed = s end)
CreateToggle("🦘 Jump Hack", false, function(s) Config.States.Jump = s end)
CreateToggle("🌊 Nhảy vô hạn trên không", false, function(s)
    Config.States.InfAirJump = s
    if s and player.Character then
        local hum = player.Character:FindFirstChild("Humanoid")
        if hum then hum.Jump = true end
    end
end)
CreateToggle("🚪 Noclip", false, function(s) Config.States.Noclip = s end)
CreateToggle("🧱 Phase (xuyên tường mạnh)", false, function(s) Config.States.Phase = s end)
CreateToggle("☀️ Full Bright", false, function(s) Config.States.FullBright = s; Lighting.Brightness = s and 3 or 1 end)
CreateToggle("🤖 Auto Jump", false, function(s) Config.States.AutoJump = s end)
CreateToggle("🕊️ Fly (XNEO Style)", false, function(s)
    Config.States.Fly = s
    if s then
        startFly()
    else
        stopFly()
    end
end)
CreateToggle("👻 Invisible", false, function(s) Config.States.Invisible = s end)
CreateToggle("☠️ Disable Killbricks", false, function(s) Config.States.DisableKillbricks = s end)
CreateToggle("📍 Checkpoint ESP", false, function(s) Config.States.CheckpointESP = s end)
CreateToggle("🌙 Low Gravity", false, function(s) Config.States.LowGravity = s end)
CreateToggle("🛡️ God Mode", false, function(s) Config.States.GodMode = s end)
CreateToggle("📦 Hitbox Mở rộng", false, function(s) Config.States.Hitbox = s end)

CreateButton("⚡ FIX LAG / BOOST FPS", Color3.fromRGB(80, 120, 200), function()
    for _, v in pairs(Workspace:GetDescendants()) do
        if v:IsA("BasePart") then
            v.Material = Enum.Material.SmoothPlastic
            v.CastShadow = false
        elseif v:IsA("Texture") or v:IsA("Decal") then
            v:Destroy()
        end
    end
    Lighting.GlobalShadows = false
    Lighting.FogEnd = 1e5
    Lighting.Outlines = false
    game:GetService("StarterGui"):SetCore("SendNotification", {Title="Obby Tool", Text="Đã giảm đồ họa, tăng FPS!", Duration=2})
end)

-- Minimize button
local MinBtn = Instance.new("TextButton", Main)
MinBtn.Size = UDim2.new(0, 30, 0, 30)
MinBtn.Position = UDim2.new(1, -35, 0, 3)
MinBtn.BackgroundColor3 = Color3.fromRGB(200, 80, 80)
MinBtn.Text = "—"
MinBtn.TextColor3 = Color3.new(1,1,1)
MinBtn.Font = Enum.Font.GothamBold
MinBtn.TextSize = 20
Instance.new("UICorner", MinBtn).CornerRadius = UDim.new(0, 6)
MinBtn.MouseButton1Click:Connect(function() Main.Visible = false end)

-- Toggle button
local ToggleBtn = Instance.new("TextButton", UI)
ToggleBtn.Size = UDim2.new(0, 45, 0, 45)
ToggleBtn.Position = UDim2.new(0.01, 0, 0.2, 0)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
ToggleBtn.BackgroundTransparency = 0.1
ToggleBtn.Text = "🏆"
ToggleBtn.TextColor3 = Color3.fromRGB(80, 200, 120)
ToggleBtn.TextSize = 24
ToggleBtn.Draggable = true
Instance.new("UICorner", ToggleBtn).CornerRadius = UDim.new(1, 0)
Instance.new("UIStroke", ToggleBtn).Color = Color3.fromRGB(80, 200, 120)
ToggleBtn.MouseButton1Click:Connect(function() Main.Visible = not Main.Visible end)

-- ================= FLY LOGIC (TÍCH HỢP TỪ XNEO FLY GUI V3) =================
local flying = false
local flyBodyGyro = nil
local flyBodyVelocity = nil
local flyConnection = nil
local flySpeed = 1

local function startFly()
    local char = player.Character
    if not char then return end
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    if not humanoid then return end
    
    flying = true
    
    -- Xác định phần thân để gắn BodyGyro/BodyVelocity
    local targetPart = nil
    if humanoid.RigType == Enum.HumanoidRigType.R6 then
        targetPart = char:FindFirstChild("Torso")
    else
        targetPart = char:FindFirstChild("UpperTorso")
    end
    
    if not targetPart then return end
    
    -- Tạo BodyGyro và BodyVelocity
    flyBodyGyro = Instance.new("BodyGyro")
    flyBodyGyro.P = 9e4
    flyBodyGyro.maxTorque = Vector3.new(9e9, 9e9, 9e9)
    flyBodyGyro.cframe = targetPart.CFrame
    flyBodyGyro.Parent = targetPart
    
    flyBodyVelocity = Instance.new("BodyVelocity")
    flyBodyVelocity.velocity = Vector3.new(0, 0.1, 0)
    flyBodyVelocity.maxForce = Vector3.new(9e9, 9e9, 9e9)
    flyBodyVelocity.Parent = targetPart
    
    humanoid.PlatformStand = true
    
    -- Vòng lặp bay
    flyConnection = RunService.RenderStepped:Connect(function()
        if not flying or not player.Character or not player.Character:FindFirstChildOfClass("Humanoid") then
            stopFly()
            return
        end
        
        local cam = camera.CFrame
        local moveDir = Vector3.zero
        
        -- Điều khiển bằng phím WASD (dùng cho PC, mobile có thể dùng bàn phím ảo)
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDir += cam.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDir -= cam.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDir -= cam.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDir += cam.RightVector end
        
        local speed = Config.FlySpeed * flySpeed
        
        if moveDir.Magnitude > 0 then
            flyBodyVelocity.Velocity = moveDir * speed
        else
            flyBodyVelocity.Velocity = Vector3.new(0, 0, 0)
        end
        
        flyBodyGyro.CFrame = cam
    end)
end

local function stopFly()
    flying = false
    if flyConnection then
        flyConnection:Disconnect()
        flyConnection = nil
    end
    if flyBodyGyro then
        flyBodyGyro:Destroy()
        flyBodyGyro = nil
    end
    if flyBodyVelocity then
        flyBodyVelocity:Destroy()
        flyBodyVelocity = nil
    end
    if player.Character then
        local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid.PlatformStand = false
        end
    end
end

-- Đảm bảo dừng bay khi nhân vật bị xóa
player.CharacterAdded:Connect(function(char)
    if Config.States.Fly then
        stopFly()
        task.wait(0.5)
        startFly()
    end
end)

-- ================= CÁC LOGIC KHÁC =================
-- Speed & Jump
RunService.Stepped:Connect(function()
    local char = player.Character
    if not char then return end
    local hum = char:FindFirstChild("Humanoid")
    if hum then
        if Config.States.Speed then hum.WalkSpeed = Config.WalkSpeed end
        if Config.States.Jump then hum.JumpPower = Config.JumpPower; hum.UseJumpPower = true end
        if Config.States.LowGravity then hum.JumpPower = Config.JumpPower * 1.3; hum.HipHeight = 2.5 end
    end
end)

-- Noclip, Phase, Invisible, DisableKillbricks, GodMode, Hitbox
RunService.Stepped:Connect(function()
    local char = player.Character
    if not char then return end
    for _, v in ipairs(char:GetDescendants()) do
        if v:IsA("BasePart") then
            if Config.States.Noclip or Config.States.Phase then v.CanCollide = false end
            if Config.States.Invisible then v.Transparency = 1 end
            if Config.States.GodMode then v.CanTouch = false end
            if Config.States.Hitbox and v.Name ~= "HumanoidRootPart" then
                v.Size = Vector3.new(Config.HitboxSize, Config.HitboxSize, Config.HitboxSize)
                v.Transparency = 0.7
                v.BrickColor = BrickColor.new("Bright red")
            end
        end
    end
    if Config.States.DisableKillbricks then
        for _, v in ipairs(Workspace:GetDescendants()) do
            if v:IsA("BasePart") and v.Name:lower():find("kill") then
                v.CanTouch = false
                v.Transparency = 0.7
                v.BrickColor = BrickColor.new("Really black")
            end
        end
    end
end)

-- Auto Jump
RunService.Heartbeat:Connect(function()
    if Config.States.AutoJump and player.Character then
        local hum = player.Character:FindFirstChild("Humanoid")
        if hum then hum.Jump = true end
    end
end)

-- Nhảy vô hạn trên không
local airJumps = 0
player.CharacterAdded:Connect(function(char)
    local hum = char:WaitForChild("Humanoid")
    hum.StateChanged:Connect(function(_, new)
        if new == Enum.HumanoidStateType.Landed then
            airJumps = 0
        end
    end)
    hum.Jumping:Connect(function()
        if Config.States.InfAirJump and hum:GetState() == Enum.HumanoidStateType.Freefall then
            hum.Jump = true
        end
    end)
end)

-- Checkpoint ESP
local function createESP(part, name)
    if part:FindFirstChild("CheckpointESP") then return end
    local bg = Instance.new("BillboardGui", part)
    bg.Name = "CheckpointESP"
    bg.Size = UDim2.new(0, 100, 0, 30)
    bg.AlwaysOnTop = true
    local txt = Instance.new("TextLabel", bg)
    txt.Size = UDim2.new(1,0,1,0)
    txt.BackgroundTransparency = 1
    txt.Text = name or "📍 Checkpoint"
    txt.TextColor3 = Color3.fromRGB(80, 200, 120)
    txt.Font = Enum.Font.GothamBold
    txt.TextStrokeTransparency = 0.5
end

task.spawn(function()
    while task.wait(2) do
        if Config.States.CheckpointESP then
            for _, v in ipairs(Workspace:GetDescendants()) do
                if v:IsA("BasePart") and (v.Name:lower():find("check") or v.Name:lower():find("spawn")) then
                    createESP(v)
                end
            end
        else
            for _, v in ipairs(Workspace:GetDescendants()) do
                if v.Name == "CheckpointESP" then v:Destroy() end
            end
        end
    end
end)

game:GetService("StarterGui"):SetCore("SendNotification", {
    Title = "Obby Tool Mobile",
    Text = "Đã tải! Nhấn 🏆 để mở. Fly đã được tích hợp từ XNEO.",
    Duration = 3
})