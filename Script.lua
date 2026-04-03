-- // BRUHWARE BASIC MOBILE (FULL VERSION)
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- Limpeza Segura
pcall(function() RunService:UnbindFromRenderStep("Lock") end)
if CoreGui:FindFirstChild("BasicMenu") then CoreGui.BasicMenu:Destroy() end
if _G.FOV then 
    pcall(function() _G.FOV:Remove() end) 
    _G.FOV = nil 
end

-- Configurações
local Settings = {
    Aimbot = false,
    Bots = true,
    Radius = 150,
    Part = "Head",
    TeamCheck = true,
    WallCheck = true
}

-- // --- UI BÁSICA COMPLETA --- //
local Screen = Instance.new("ScreenGui", CoreGui); Screen.Name = "BasicMenu"
local Main = Instance.new("Frame", Screen)
Main.Size = UDim2.new(0, 160, 0, 300); Main.Position = UDim2.new(0.1, 0, 0.4, 0)
Main.BackgroundColor3 = Color3.new(0,0,0); Main.BackgroundTransparency = 0.5; Main.Active = true; Main.Draggable = true

local function CreateBtn(txt, y, callback)
    local b = Instance.new("TextButton", Main)
    b.Size = UDim2.new(1, 0, 0, 45); b.Position = UDim2.new(0, 0, 0, y)
    b.Text = txt; b.BackgroundColor3 = Color3.new(0.15, 0.15, 0.15); b.TextColor3 = Color3.new(1,1,1)
    b.Font = Enum.Font.SourceSansBold; b.TextSize = 14
    b.MouseButton1Click:Connect(function() callback(b) end)
    return b
end

-- Botões do Painel
CreateBtn("AIMBOT: OFF", 0, function(b)
    Settings.Aimbot = not Settings.Aimbot
    b.Text = Settings.Aimbot and "AIMBOT: ON" or "AIMBOT: OFF"
    b.BackgroundColor3 = Settings.Aimbot and Color3.new(0, 0.4, 0) or Color3.new(0.4, 0, 0)
end)

CreateBtn("BOTS: ON", 50, function(b)
    Settings.Bots = not Settings.Bots
    b.Text = Settings.Bots and "BOTS: ON" or "BOTS: OFF"
end)

CreateBtn("TEAM CHECK: ON", 100, function(b)
    Settings.TeamCheck = not Settings.TeamCheck
    b.Text = Settings.TeamCheck and "TEAM CHECK: ON" or "TEAM CHECK: OFF"
end)

CreateBtn("WALL CHECK: ON", 150, function(b)
    Settings.WallCheck = not Settings.WallCheck
    b.Text = Settings.WallCheck and "WALL CHECK: ON" or "WALL CHECK: OFF"
end)

CreateBtn("DESTROY", 250, function()
    pcall(function() RunService:UnbindFromRenderStep("Lock") end)
    if _G.FOV then pcall(function() _G.FOV:Remove() end) _G.FOV = nil end
    Screen:Destroy()
end)

-- // --- LÓGICA DE ALVO --- //
_G.FOV = Drawing.new("Circle")
_G.FOV.Color = Color3.new(1,1,1); _G.FOV.Thickness = 1

local function GetTarget()
    local target, minMag = nil, Settings.Radius
    local center = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)

    for _, v in pairs(workspace:GetDescendants()) do
        if v:IsA("Humanoid") and v.Health > 0 then
            local char = v.Parent
            if char and char ~= LocalPlayer.Character then
                
                -- Team Check
                local player = Players:GetPlayerFromCharacter(char)
                if Settings.TeamCheck and player and player.Team == LocalPlayer.Team then continue end

                -- Bot Check
                if not Settings.Bots and not player then continue end
                
                local part = char:FindFirstChild(Settings.Part) or char:FindFirstChild("HumanoidRootPart")
                if part then
                    local pos, on = Camera:WorldToViewportPoint(part.Position)
                    if on then
                        local mag = (Vector2.new(pos.X, pos.Y) - center).Magnitude
                        if mag < minMag then
                            
                            -- Wall Check
                            if Settings.WallCheck then
                                local ray = Ray.new(Camera.CFrame.Position, (part.Position - Camera.CFrame.Position).Unit * 500)
                                local hit = workspace:FindPartOnRayWithIgnoreList(ray, {LocalPlayer.Character, char})
                                if hit then continue end
                            end

                            minMag = mag; target = part
                        end
                    end
                end
            end
        end
    end
    return target
end

-- // --- LOOP DE EXECUÇÃO --- //
RunService:BindToRenderStep("Lock", Enum.RenderPriority.Camera.Value + 1, function()
    if _G.FOV then
        _G.FOV.Visible = Settings.Aimbot
        _G.FOV.Radius = Settings.Radius
        _G.FOV.Position = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
    end

    if Settings.Aimbot then
        local t = GetTarget()
        if t then
            Camera.CFrame = CFrame.lookAt(Camera.CFrame.Position, t.Position)
        end
    end
end)
