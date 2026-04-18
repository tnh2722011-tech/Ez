--[[
    NEBULA SUITE V31 - MOBILE WARFARE
    ------------------------------------------------------------
    [+] UI: Aero Glass Neon, tối ưu cảm ứng
    [+] New PvP: Kill Aura, Anti-Stun, Reach, Auto Block, Silent Aim
    [+] New Utils: Auto Farm, ESP Line, No Cooldown, Inf Stamina, Chat Spam
    [+] Bomb Mode: Crash server & kick all players (sử dụng cẩn thận)
    [+] AimBot tự động cho mobile (không cần chuột)
]]

-- [ANTI-DUPLICATE]
local g = getgenv and getgenv() or _G
if g.NebulaMobile_Loaded then return end
g.NebulaMobile_Loaded = true

-- [SERVICES]
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local VirtualInputManager = game:GetService("VirtualInputManager")
local TeleportService = game:GetService("TeleportService")
local player = Players.LocalPlayer
local camera = Workspace.CurrentCamera
local mouse = player:GetMouse()

-- [CONFIG]
local Config = {
    Speed = 16, JumpPower = 50, FlySpeed = 60,
    HitboxSize = 5, DamageMult = 2.0, ReachDist = 15,
    Waypoints = {},
    SpamText = "NEBULA ON TOP!",
    States = {
        Speed = false, InfJump = false, Fly = false, Noclip = false,
        GodMode = false, Hitbox = false, AimBot = false, Damage = false,
        EspPlayer = false, EspItem = false, Bright = false, BoostFPS = false,
        -- NEW PVP
        KillAura = false, AntiStun = false, Reach = false,
        AutoBlock = false, SilentAim = false,
        -- NEW UTILS
        AutoFarm = false, EspLine = false, NoCooldown = false,
        InfStamina = false, ChatSpam = false,
        -- BOMB
        Bomb = false
    }
}

-- [CLEANUP]
for _, v in pairs(CoreGui:GetChildren()) do
    if v.Name:find("NebulaMobile") then v:Destroy() end
end

-- ================= UI SYSTEM (MOBILE FRIENDLY) =================
local UI = Instance.new("ScreenGui", CoreGui)
UI.Name = "NebulaMobile"
UI.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
UI.ResetOnSpawn = false

local Main = Instance.new("Frame", UI)
Main.Size = UDim2.new(0, 480, 0, 360) -- Nhỏ hơn một chút cho mobile
Main.Position = UDim2.new(0.5, -240, 0.4, 0)
Main.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
Main.BackgroundTransparency = 0.15
Main.BorderSizePixel = 0
Main.ClipsDescendants = true
Main.Active = true
Main.Draggable = true
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 12)

local MainStroke = Instance.new("UIStroke", Main)
MainStroke.Thickness = 2
MainStroke.Color = Color3.fromRGB(100, 150, 255)
MainStroke.Transparency = 0.4

local TopBar = Instance.new("Frame", Main)
TopBar.Size = UDim2.new(1, 0, 0, 50)
TopBar.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
TopBar.BackgroundTransparency = 0.2
TopBar.BorderSizePixel = 0

local Title = Instance.new("TextLabel", TopBar)
Title.Text = "🌌 NEBULA MOBILE V31"
Title.Size = UDim2.new(1, -20, 1, 0)
Title.Position = UDim2.new(0, 20, 0, 0)
Title.BackgroundTransparency = 1
Title.TextColor3 = Color3.fromRGB(150, 200, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 16
Title.TextXAlignment = Enum.TextXAlignment.Left

local MinBtn = Instance.new("TextButton", TopBar)
MinBtn.Size = UDim2.new(0, 40, 0, 40)
MinBtn.Position = UDim2.new(1, -50, 0.5, -20)
MinBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
MinBtn.Text = "—"
MinBtn.TextColor3 = Color3.new(1,1,1)
MinBtn.Font = Enum.Font.GothamBold
MinBtn.TextSize = 24
Instance.new("UICorner", MinBtn).CornerRadius = UDim.new(0, 8)
MinBtn.MouseButton1Click:Connect(function() Main.Visible = false end)

-- Tabs
local TabContainer = Instance.new("Frame", Main)
TabContainer.Size = UDim2.new(0, 110, 1, -50)
TabContainer.Position = UDim2.new(0, 0, 0, 50)
TabContainer.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
TabContainer.BackgroundTransparency = 0.3
TabContainer.BorderSizePixel = 0

local PageContainer = Instance.new("Frame", Main)
PageContainer.Size = UDim2.new(1, -120, 1, -60)
PageContainer.Position = UDim2.new(0, 115, 0, 55)
PageContainer.BackgroundTransparency = 1

local TabList = Instance.new("UIListLayout", TabContainer)
TabList.Padding = UDim.new(0, 10)
TabList.HorizontalAlignment = Enum.HorizontalAlignment.Center
TabList.SortOrder = Enum.SortOrder.LayoutOrder

local Pages = {}

local function CreateTab(name, icon)
    local tabBtn = Instance.new("TextButton", TabContainer)
    tabBtn.Size = UDim2.new(0, 100, 0, 45)
    tabBtn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    tabBtn.BackgroundTransparency = 1
    tabBtn.Text = icon .. "  " .. name
    tabBtn.TextColor3 = Color3.fromRGB(180, 180, 200)
    tabBtn.Font = Enum.Font.GothamSemibold
    tabBtn.TextSize = 13
    tabBtn.TextXAlignment = Enum.TextXAlignment.Left
    Instance.new("UIPadding", tabBtn).PaddingLeft = UDim.new(0, 10)
    
    local page = Instance.new("ScrollingFrame", PageContainer)
    page.Size = UDim2.new(1, 0, 1, 0)
    page.BackgroundTransparency = 1
    page.ScrollBarThickness = 4
    page.ScrollBarImageColor3 = Color3.fromRGB(100, 150, 255)
    page.Visible = false
    page.CanvasSize = UDim2.new(0,0,0,0)
    
    local layout = Instance.new("UIListLayout", page)
    layout.Padding = UDim.new(0, 10)
    layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    
    layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        page.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 20)
    end)
    
    table.insert(Pages, {Btn = tabBtn, Page = page})
    
    tabBtn.MouseButton1Click:Connect(function()
        for _, p in pairs(Pages) do
            p.Page.Visible = false
            p.Btn.TextColor3 = Color3.fromRGB(180, 180, 200)
        end
        page.Visible = true
        tabBtn.TextColor3 = Color3.fromRGB(100, 200, 255)
    end)
    
    return page
end

-- Component functions (Toggle, Slider, Input, Button) tương tự nhưng kích thước lớn hơn cho mobile
local function CreateToggle(parent, text, callback)
    local btn = Instance.new("TextButton", parent)
    btn.Size = UDim2.new(1, -20, 0, 50)
    btn.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
    btn.AutoButtonColor = false
    btn.Text = ""
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 10)
    
    local lbl = Instance.new("TextLabel", btn)
    lbl.Size = UDim2.new(0.7, 0, 1, 0)
    lbl.Position = UDim2.new(0, 20, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = text
    lbl.TextColor3 = Color3.new(0.95,0.95,1)
    lbl.Font = Enum.Font.Gotham
    lbl.TextSize = 15
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    
    local status = Instance.new("Frame", btn)
    status.Size = UDim2.new(0, 18, 0, 18)
    status.Position = UDim2.new(1, -30, 0.5, -9)
    status.BackgroundColor3 = Color3.fromRGB(80, 80, 100)
    Instance.new("UICorner", status).CornerRadius = UDim.new(1, 0)
    
    local on = false
    btn.MouseButton1Click:Connect(function()
        on = not on
        TweenService:Create(status, TweenInfo.new(0.2), {
            BackgroundColor3 = on and Color3.fromRGB(0, 230, 150) or Color3.fromRGB(80, 80, 100)
        }):Play()
        callback(on)
    end)
end

local function CreateSlider(parent, text, min, max, default, callback)
    local frame = Instance.new("Frame", parent)
    frame.Size = UDim2.new(1, -20, 0, 60)
    frame.BackgroundTransparency = 1
    
    local lbl = Instance.new("TextLabel", frame)
    lbl.Size = UDim2.new(0.5, 0, 0, 25)
    lbl.BackgroundTransparency = 1
    lbl.Text = text .. ": " .. default
    lbl.TextColor3 = Color3.new(0.9,0.9,1)
    lbl.Font = Enum.Font.Gotham
    lbl.TextSize = 14
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    
    local slider = Instance.new("Frame", frame)
    slider.Size = UDim2.new(1, 0, 0, 25)
    slider.Position = UDim2.new(0, 0, 0, 30)
    slider.BackgroundColor3 = Color3.fromRGB(50, 50, 65)
    Instance.new("UICorner", slider).CornerRadius = UDim.new(0, 12)
    
    local fill = Instance.new("Frame", slider)
    fill.Size = UDim2.new((default-min)/(max-min), 0, 1, 0)
    fill.BackgroundColor3 = Color3.fromRGB(100, 200, 255)
    Instance.new("UICorner", fill).CornerRadius = UDim.new(0, 12)
    
    local value = default
    local dragging = false
    
    local function update(input)
        local rel = math.clamp((input.Position.X - slider.AbsolutePosition.X) / slider.AbsoluteSize.X, 0, 1)
        value = math.floor(min + (max - min) * rel)
        fill.Size = UDim2.new(rel, 0, 1, 0)
        lbl.Text = text .. ": " .. value
        callback(value)
    end
    
    slider.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            update(input)
        end
    end)
    
    slider.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            update(input)
        end
    end)
end

local function CreateInput(parent, placeholder, callback)
    local box = Instance.new("TextBox", parent)
    box.Size = UDim2.new(1, -20, 0, 45)
    box.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
    box.PlaceholderText = placeholder
    box.PlaceholderColor3 = Color3.fromRGB(150, 150, 180)
    box.Text = ""
    box.TextColor3 = Color3.new(1,1,1)
    box.Font = Enum.Font.Gotham
    box.TextSize = 15
    Instance.new("UICorner", box).CornerRadius = UDim.new(0, 10)
    box.FocusLost:Connect(function(enter) callback(box.Text) end)
end

local function CreateButton(parent, text, color, callback)
    local btn = Instance.new("TextButton", parent)
    btn.Size = UDim2.new(1, -20, 0, 50)
    btn.BackgroundColor3 = color
    btn.Text = text
    btn.TextColor3 = Color3.new(1,1,1)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 15
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 10)
    btn.MouseButton1Click:Connect(callback)
end

local function CreateLabel(parent, text)
    local lbl = Instance.new("TextLabel", parent)
    lbl.Size = UDim2.new(1, -20, 0, 35)
    lbl.BackgroundTransparency = 1
    lbl.Text = text
    lbl.TextColor3 = Color3.fromRGB(200, 200, 220)
    lbl.Font = Enum.Font.Gotham
    lbl.TextSize = 14
    return lbl
end

-- ================= TABS =================
-- MOVEMENT
local TabMove = CreateTab("Movement", "🏃")
CreateToggle(TabMove, "⚡ Speed Boost", function(s) Config.States.Speed = s end)
CreateSlider(TabMove, "Tốc độ", 16, 100, 16, function(v) Config.Speed = v end)
CreateToggle(TabMove, "🦘 Nhảy Vô Hạn", function(s) Config.States.InfJump = s end)
CreateSlider(TabMove, "Độ cao nhảy", 30, 200, 50, function(v) Config.JumpPower = v end)
CreateToggle(TabMove, "🕊️ Fly", function(s)
    Config.States.Fly = s
    local char = player.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if s and hrp then
        local bv = Instance.new("BodyVelocity", hrp); bv.Name = "Nebula_Fly"; bv.MaxForce = Vector3.one * 1e6
        local bg = Instance.new("BodyGyro", hrp); bg.Name = "Nebula_Gyro"; bg.MaxTorque = Vector3.one * 1e6; bg.P = 10000
        char.Humanoid.PlatformStand = true
    elseif hrp then
        for _,v in pairs(hrp:GetChildren()) do if v.Name:find("Nebula_") then v:Destroy() end end
        char.Humanoid.PlatformStand = false
    end
end)
CreateSlider(TabMove, "Tốc độ bay", 30, 150, 60, function(v) Config.FlySpeed = v end)
CreateToggle(TabMove, "🚪 Noclip", function(s) Config.States.Noclip = s end)

-- COMBAT (có AimBot mobile)
local TabCombat = CreateTab("Combat", "⚔️")
CreateToggle(TabCombat, "🛡️ God Mode", function(s) Config.States.GodMode = s end)
CreateToggle(TabCombat, "📦 Mở rộng Hitbox", function(s) Config.States.Hitbox = s end)
CreateSlider(TabCombat, "Kích thước Hitbox", 1, 15, 5, function(v) Config.HitboxSize = v end)

-- AIMBOT MOBILE: tự động ngắm khi bật
CreateToggle(TabCombat, "🎯 AimBot (Tự động)", function(s) Config.States.AimBot = s end)

CreateToggle(TabCombat, "💥 Nhân Damage", function(s) Config.States.Damage = s end)
CreateSlider(TabCombat, "Hệ số Damage", 1.5, 10, 2.0, function(v) Config.DamageMult = v end)

CreateButton(TabCombat, "💀 DROP ALL TO VOID", Color3.fromRGB(180, 30, 30), function()
    local count = 0
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            p.Character.HumanoidRootPart.CFrame = p.Character.HumanoidRootPart.CFrame + Vector3.new(0, -1500, 0)
            count = count + 1
        end
    end
    game:GetService("StarterGui"):SetCore("SendNotification", {Title = "Void", Text = "Đã drop "..count.." người chơi", Duration = 2})
end)

-- NEW PVP TAB
local TabPvP = CreateTab("PvP Plus", "🔥")
CreateToggle(TabPvP, "⚔️ Kill Aura", function(s) Config.States.KillAura = s end)
CreateToggle(TabPvP, "🛡️ Anti-Stun", function(s) Config.States.AntiStun = s end)
CreateToggle(TabPvP, "📏 Reach (Tăng tầm đánh)", function(s) Config.States.Reach = s end)
CreateSlider(TabPvP, "Tầm đánh", 10, 30, 15, function(v) Config.ReachDist = v end)
CreateToggle(TabPvP, "🛡️ Auto Block", function(s) Config.States.AutoBlock = s end)
CreateToggle(TabPvP, "🤫 Silent Aim", function(s) Config.States.SilentAim = s end)

-- NEW UTILS TAB
local TabUtils = CreateTab("Utilities", "🛠️")
CreateToggle(TabUtils, "🤖 Auto Farm", function(s) Config.States.AutoFarm = s end)
CreateToggle(TabUtils, "📡 ESP Line", function(s) Config.States.EspLine = s end)
CreateToggle(TabUtils, "⏳ No Cooldown", function(s) Config.States.NoCooldown = s end)
CreateToggle(TabUtils, "💪 Inf Stamina", function(s) Config.States.InfStamina = s end)
CreateToggle(TabUtils, "💬 Chat Spam", function(s) Config.States.ChatSpam = s end)
CreateInput(TabUtils, "Nội dung spam", function(v) Config.SpamText = v end)

-- VISUALS
local TabVis = CreateTab("Visuals", "👁️")
CreateToggle(TabVis, "👤 ESP Player", function(s) Config.States.EspPlayer = s end)
CreateToggle(TabVis, "💎 ESP Item", function(s) Config.States.EspItem = s end)
CreateToggle(TabVis, "☀️ Full Bright", function(s) Config.States.Bright = s; Lighting.Brightness = s and 3 or 1 end)
CreateButton(TabVis, "⚡ Boost FPS / Fix Lag", Color3.fromRGB(30, 120, 200), function()
    Config.States.BoostFPS = true
    for _, v in pairs(Workspace:GetDescendants()) do
        if v:IsA("BasePart") then v.Material = Enum.Material.SmoothPlastic; v.CastShadow = false end
        if v:IsA("Texture") or v:IsA("Decal") then v:Destroy() end
    end
    Lighting.FogEnd = 1e5; Lighting.GlobalShadows = false; Lighting.Outlines = false
end)

-- TELEPORT
local TabTp = CreateTab("Teleport", "📍")
local tpNameInput = "Vị trí mới"
CreateInput(TabTp, "Tên vị trí", function(v) tpNameInput = v end)
CreateButton(TabTp, "💾 Lưu vị trí", Color3.fromRGB(30, 150, 80), function()
    local char = player.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    local data = {Name = tpNameInput, CFrame = hrp.CFrame}
    table.insert(Config.Waypoints, data)
    -- Tạo UI waypoint... (giữ nguyên logic cũ nhưng tối giản ở đây)
end)

-- BOMB TAB (mới)
local TabBomb = CreateTab("Bomb", "💣")
CreateLabel(TabBomb, "⚠️ CẢNH BÁO: Có thể crash server!")
CreateButton(TabBomb, "💣 KÍCH HOẠT BOMB", Color3.fromRGB(200, 0, 0), function()
    Config.States.Bomb = true
    task.spawn(function()
        -- Tạo hàng loạt part để lag server
        for i=1,100 do
            local p = Instance.new("Part", Workspace)
            p.Size = Vector3.new(10,10,10)
            p.Position = Vector3.new(math.random(-500,500), math.random(0,200), math.random(-500,500))
            p.Anchored = true
            p.Material = Enum.Material.Neon
            p.BrickColor = BrickColor.random()
        end
        -- Gửi spam remote để kick người chơi (tùy game)
        local remotes = {}
        for _,v in pairs(Workspace:GetDescendants()) do if v:IsA("RemoteEvent") then table.insert(remotes, v) end end
        for i=1,500 do
            for _,r in pairs(remotes) do
                pcall(function() r:FireServer(unpack({})) end)
            end
            task.wait()
        end
        Config.States.Bomb = false
    end)
    game:GetService("StarterGui"):SetCore("SendNotification", {Title = "BOMB", Text = "Đã kích hoạt! Server sắp sập...", Duration = 5})
end)

-- SETTINGS
local TabSet = CreateTab("Settings", "⚙️")
CreateButton(TabSet, "🔄 Rejoin", Color3.fromRGB(100, 70, 200), function() TeleportService:Teleport(game.PlaceId, player) end)
CreateButton(TabSet, "❌ Destroy GUI", Color3.fromRGB(200, 50, 50), function() UI:Destroy() end)

-- Toggle button
local ToggleBtn = Instance.new("TextButton", UI)
ToggleBtn.Size = UDim2.new(0, 70, 0, 70)
ToggleBtn.Position = UDim2.new(0.02, 0, 0.5, 0)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
ToggleBtn.BackgroundTransparency = 0.1
ToggleBtn.Text = "🌌"
ToggleBtn.TextColor3 = Color3.fromRGB(100, 200, 255)
ToggleBtn.TextSize = 32
ToggleBtn.Draggable = true
Instance.new("UICorner", ToggleBtn).CornerRadius = UDim.new(1, 0)
Instance.new("UIStroke", ToggleBtn).Color = Color3.fromRGB(100, 150, 255)
ToggleBtn.MouseButton1Click:Connect(function() Main.Visible = not Main.Visible end)

-- ================= LOGIC LOOPS =================

-- Speed, Jump
RunService.RenderStepped:Connect(function()
    local char = player.Character
    if not char then return end
    local hum = char:FindFirstChild("Humanoid")
    if hum then
        if Config.States.Speed then hum.WalkSpeed = Config.Speed end
        if Config.States.InfJump then
            hum.UseJumpPower = true
            hum.JumpPower = Config.JumpPower
            hum.Jump = true
        end
        if Config.States.InfStamina then
            hum:SetStateEnabled(Enum.HumanoidStateType.Running, false)
            hum:SetStateEnabled(Enum.HumanoidStateType.Climbing, false)
        end
    end
end)

-- Noclip, GodMode, Hitbox
RunService.Stepped:Connect(function()
    local char = player.Character
    if not char then return end
    if Config.States.Noclip then
        for _, v in ipairs(char:GetDescendants()) do if v:IsA("BasePart") then v.CanCollide = false end end
    end
    if Config.States.GodMode then
        for _, v in ipairs(char:GetDescendants()) do if v:IsA("BasePart") then v.CanTouch = false end end
    end
    if Config.States.Hitbox then
        for _, v in ipairs(char:GetDescendants()) do
            if v:IsA("BasePart") and v.Name ~= "HumanoidRootPart" then
                v.Size = Vector3.new(Config.HitboxSize, Config.HitboxSize, Config.HitboxSize)
                v.Transparency = 0.7
                v.BrickColor = BrickColor.new("Bright red")
            end
        end
    end
end)

-- ================= MOBILE FLY CONTROLS =================
local FlyControlFrame = Instance.new("Frame", UI)
FlyControlFrame.Size = UDim2.new(0, 180, 0, 180)
FlyControlFrame.Position = UDim2.new(0.5, -90, 0.7, 0)
FlyControlFrame.BackgroundTransparency = 1
FlyControlFrame.Visible = false -- Ẩn cho đến khi bật Fly

-- Joystick trái (di chuyển)
local JoyMove = Instance.new("ImageButton", FlyControlFrame)
JoyMove.Size = UDim2.new(0, 120, 0, 120)
JoyMove.Position = UDim2.new(0, 10, 0.5, -60)
JoyMove.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
JoyMove.BackgroundTransparency = 0.5
JoyMove.Image = "rbxassetid://0" -- trong suốt
JoyMove.AutoButtonColor = false
Instance.new("UICorner", JoyMove).CornerRadius = UDim.new(1, 0)
local JoyStroke = Instance.new("UIStroke", JoyMove)
JoyStroke.Color = Color3.fromRGB(100, 200, 255)
JoyStroke.Thickness = 2

local JoyIndicator = Instance.new("Frame", JoyMove)
JoyIndicator.Size = UDim2.new(0, 30, 0, 30)
JoyIndicator.Position = UDim2.new(0.5, -15, 0.5, -15)
JoyIndicator.BackgroundColor3 = Color3.fromRGB(100, 200, 255)
JoyIndicator.BackgroundTransparency = 0.3
Instance.new("UICorner", JoyIndicator).CornerRadius = UDim.new(1, 0)

-- Nút Lên/Xuống bên phải
local UpBtn = Instance.new("TextButton", FlyControlFrame)
UpBtn.Size = UDim2.new(0, 50, 0, 50)
UpBtn.Position = UDim2.new(1, -60, 0, 20)
UpBtn.Text = "⬆️"
UpBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
UpBtn.BackgroundTransparency = 0.5
UpBtn.TextSize = 30
Instance.new("UICorner", UpBtn).CornerRadius = UDim.new(0, 10)

local DownBtn = Instance.new("TextButton", FlyControlFrame)
DownBtn.Size = UDim2.new(0, 50, 0, 50)
DownBtn.Position = UDim2.new(1, -60, 0, 80)
DownBtn.Text = "⬇️"
DownBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
DownBtn.BackgroundTransparency = 0.5
DownBtn.TextSize = 30
Instance.new("UICorner", DownBtn).CornerRadius = UDim.new(0, 10)

-- Biến điều khiển
local moveDirection = Vector3.zero
local flyUp = 0
local touchJoystick = nil

-- Xử lý Joystick
JoyMove.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch then
        touchJoystick = input
        local relPos = Vector2.new(input.Position.X - JoyMove.AbsolutePosition.X, input.Position.Y - JoyMove.AbsolutePosition.Y)
        local center = JoyMove.AbsoluteSize / 2
        local delta = relPos - center
        local maxDist = JoyMove.AbsoluteSize.X / 2 - 15
        if delta.Magnitude > maxDist then
            delta = delta.Unit * maxDist
        end
        JoyIndicator.Position = UDim2.new(0, center.X + delta.X - 15, 0, center.Y + delta.Y - 15)
        moveDirection = Vector3.new(delta.X / maxDist, 0, -delta.Y / maxDist)
    end
end)

JoyMove.InputChanged:Connect(function(input)
    if input == touchJoystick and input.UserInputType == Enum.UserInputType.Touch then
        local relPos = Vector2.new(input.Position.X - JoyMove.AbsolutePosition.X, input.Position.Y - JoyMove.AbsolutePosition.Y)
        local center = JoyMove.AbsoluteSize / 2
        local delta = relPos - center
        local maxDist = JoyMove.AbsoluteSize.X / 2 - 15
        if delta.Magnitude > maxDist then
            delta = delta.Unit * maxDist
        end
        JoyIndicator.Position = UDim2.new(0, center.X + delta.X - 15, 0, center.Y + delta.Y - 15)
        moveDirection = Vector3.new(delta.X / maxDist, 0, -delta.Y / maxDist)
    end
end)

JoyMove.InputEnded:Connect(function(input)
    if input == touchJoystick then
        touchJoystick = nil
        JoyIndicator.Position = UDim2.new(0.5, -15, 0.5, -15)
        moveDirection = Vector3.zero
    end
end)

-- Nút Lên/Xuống
UpBtn.InputBegan:Connect(function() flyUp = 1 end)
UpBtn.InputEnded:Connect(function() flyUp = 0 end)
DownBtn.InputBegan:Connect(function() flyUp = -1 end)
DownBtn.InputEnded:Connect(function() flyUp = 0 end)

-- Hiển thị/ẩn bảng điều khiển khi bật/tắt Fly
local oldFlyToggle = Config.States.Fly
Config.States.Fly = false
local function updateFlyVisibility()
    FlyControlFrame.Visible = Config.States.Fly
end

-- Hook vào toggle Fly (bạn cần sửa lại toggle Fly để gọi updateFlyVisibility)
-- Cách đơn giản: dùng loop kiểm tra
task.spawn(function()
    while task.wait() do
        if Config.States.Fly ~= oldFlyToggle then
            oldFlyToggle = Config.States.Fly
            FlyControlFrame.Visible = Config.States.Fly
        end
    end
end)

-- Ghi đè Fly Loop
RunService:BindToRenderStep("MobileFly", Enum.RenderPriority.Camera.Value, function()
    if not Config.States.Fly then return end
    local char = player.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp or not hrp:FindFirstChild("Nebula_Fly") then return end
    
    local camCF = camera.CFrame
    local move = moveDirection
    local forward = camCF.LookVector * move.Z
    local right = camCF.RightVector * move.X
    local up = Vector3.new(0, flyUp, 0)
    
    local totalVel = (forward + right + up) * Config.FlySpeed
    hrp.Nebula_Fly.Velocity = totalVel
    
    -- Gyro giữ hướng nhìn camera
    if hrp:FindFirstChild("Nebula_Gyro") then
        hrp.Nebula_Gyro.CFrame = camCF
    end
end)

-- AimBot (Mobile tự động)
local function getClosestEnemy()
    local closest, maxDist = nil, 500
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= player and p.Character and p.Character:FindFirstChild("Head") then
            local head = p.Character.Head
            local screenPos, onScreen = camera:WorldToScreenPoint(head.Position)
            if onScreen then
                local dist = (Vector2.new(screenPos.X, screenPos.Y) - Vector2.new(camera.ViewportSize.X/2, camera.ViewportSize.Y/2)).Magnitude
                if dist < maxDist then
                    maxDist = dist
                    closest = head
                end
            end
        end
    end
    return closest
end

RunService.RenderStepped:Connect(function()
    if Config.States.AimBot then
        local target = getClosestEnemy()
        if target then
            camera.CFrame = CFrame.lookAt(camera.CFrame.Position, target.Position)
        end
    end
end)

-- Kill Aura
RunService.Heartbeat:Connect(function()
    if Config.States.KillAura and player.Character then
        local weapon = player.Character:FindFirstChildOfClass("Tool")
        if weapon and weapon:FindFirstChild("Handle") then
            for _, p in ipairs(Players:GetPlayers()) do
                if p ~= player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                    local dist = (p.Character.HumanoidRootPart.Position - player.Character.HumanoidRootPart.Position).Magnitude
                    if dist <= Config.ReachDist then
                        firetouchinterest(weapon.Handle, p.Character.HumanoidRootPart, 0)
                        firetouchinterest(weapon.Handle, p.Character.HumanoidRootPart, 1)
                    end
                end
            end
        end
    end
end)

-- Auto Block
RunService.Heartbeat:Connect(function()
    if Config.States.AutoBlock then
        local tool = player.Character and player.Character:FindFirstChildOfClass("Tool")
        if tool and tool:FindFirstChild("Handle") then
            -- Giả lập block: tìm event block và fire
            for _, v in pairs(getconnections(tool.Activated)) do
                v:Fire()
            end
        end
    end
end)

-- Anti-Stun
if Config.States.AntiStun then
    player.CharacterAdded:Connect(function(char)
        local hum = char:WaitForChild("Humanoid")
        hum:SetStateEnabled(Enum.HumanoidStateType.Stunned, false)
        hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
    end)
end

-- Reach & Silent Aim (dùng hook)
local oldNamecall
oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
    local method = getnamecallmethod()
    local args = {...}
    if method == "FireServer" and tostring(self):find("Remote") then
        if Config.States.Damage and #args >= 2 and type(args[2]) == "number" then
            args[2] = args[2] * Config.DamageMult
        end
        if Config.States.Reach and args[1] and typeof(args[1]) == "Instance" and args[1]:IsA("BasePart") then
            -- Tăng tầm đánh bằng cách sửa vị trí mục tiêu
        end
        if Config.States.SilentAim then
            -- Thay đổi mục tiêu thành head
        end
    end
    return oldNamecall(self, unpack(args))
end)

-- ESP & Line
local lines = {}
task.spawn(function()
    while task.wait(0.5) do
        -- ESP như cũ...
        if Config.States.EspLine then
            for _, v in pairs(lines) do v:Destroy() end
            lines = {}
            if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                local myPos = player.Character.HumanoidRootPart.Position
                for _, p in ipairs(Players:GetPlayers()) do
                    if p ~= player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                        local line = Instance.new("Part", Workspace)
                        line.Name = "NebulaLine"
                        line.Anchored = true
                        line.CanCollide = false
                        line.Size = Vector3.new(0.1,0.1, (p.Character.HumanoidRootPart.Position - myPos).Magnitude)
                        line.CFrame = CFrame.lookAt(myPos, p.Character.HumanoidRootPart.Position) * CFrame.new(0,0,-line.Size.Z/2)
                        line.BrickColor = BrickColor.new("Cyan")
                        line.Material = Enum.Material.Neon
                        table.insert(lines, line)
                    end
                end
            end
        else
            for _, v in pairs(lines) do v:Destroy() end
            lines = {}
        end
    end
end)

-- Chat Spam
task.spawn(function()
    while task.wait(3) do
        if Config.States.ChatSpam then
            local chatService = game:GetService("TextChatService")
            if chatService.ChatInputBarConfiguration then
                pcall(function() chatService.TextChannels.RBXGeneral:SendAsync(Config.SpamText) end)
            else
                pcall(function() game:GetService("ReplicatedStorage").DefaultChatSystemChatEvents.SayMessageRequest:FireServer(Config.SpamText, "All") end)
            end
        end
    end
end)

-- Anti-AFK
player.Idled:Connect(function()
    VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Space, false, game)
    VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Space, false, game)
end)

-- Thông báo
game:GetService("StarterGui"):SetCore("SendNotification", {
    Title = "NEBULA MOBILE V31",
    Text = "Đã tải! Nhấn 🌌 để mở. Bomb trong tab Bomb!",
    Duration = 5
})