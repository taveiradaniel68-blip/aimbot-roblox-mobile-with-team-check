local P = game:GetService("Players")
local R = game:GetService("RunService")
local C = game:GetService("CoreGui")
local L = P.LocalPlayer
local Cam = workspace.CurrentCamera

-- Limpeza de segurança completa
pcall(function() R:UnbindFromRenderStep("Lock") end)
if C:FindFirstChild("BasicMenu") then C.BasicMenu:Destroy() end
if _G.FOV then 
    pcall(function() _G.FOV:Remove() end) 
    _G.FOV = nil 
end

local S = {Aimbot = false, Bots = true, Team = true, Wall = true, Radius = 130}

-- UI Básica e Resistente (Corrigindo o menu vazio/preto)
local Sc = Instance.new("ScreenGui", C); Sc.Name = "BasicMenu"
local M = Instance.new("Frame", Sc); M.Size = UDim2.new(0, 160, 0, 280); M.Position = UDim2.new(0.1, 0, 0.3, 0); M.BackgroundColor3 = Color3.new(0,0,0); M.BackgroundTransparency = 0.5; M.Active = true; M.Draggable = true

local function btn(t, y, f, color)
    local b = Instance.new("TextButton", M)
    b.Size = UDim2.new(1, 0, 0, 45); b.Position = UDim2.new(0, 0, 0, y)
    b.Text = t; b.BackgroundColor3 = color or Color3.new(0.15, 0.15, 0.15); b.TextColor3 = Color3.new(1,1,1); b.Font = Enum.Font.SourceSansBold
    b.MouseButton1Click:Connect(function() f(b) end)
end

-- Botões do Painel (Completo igual à imagem)
btn("AIMBOT: OFF", 0, function(b)
    S.Aimbot = not S.Aimbot
    b.Text = S.Aimbot and "AIMBOT: ON" or "AIMBOT: OFF"
    b.BackgroundColor3 = S.Aimbot and Color3.new(0, 0.4, 0) or Color3.new(0.4, 0, 0)
end)

btn("BOTS: ON", 50, function(b)
    S.Bots = not S.Bots
    b.Text = S.Bots and "BOTS: ON" or "BOTS: OFF"
end)

btn("TEAM CHECK: ON", 100, function(b)
    S.Team = not S.Team
    b.Text = S.Team and "TEAM CHECK: ON" or "TEAM CHECK: OFF"
end)

btn("WALL CHECK: ON", 150, function(b)
    S.Wall = not S.Wall
    b.Text = S.Wall and "WALL CHECK: ON" or "WALL CHECK: OFF"
end)

btn("DESTROY", 230, function()
    pcall(function() R:UnbindFromRenderStep("Lock") end)
    if _G.FOV then pcall(function() _G.FOV:Remove() end) _G.FOV = nil end
    Sc:Destroy()
end, Color3.new(0.3, 0, 0))

-- // --- LÓGICA DO ALVO --- //
-- Criando o Círculo FOV CORRETAMENTE (Vazio por dentro)
_G.FOV = Drawing.new("Circle")
_G.FOV.Color = Color3.new(1, 1, 1) -- Branco
_G.FOV.Thickness = 1
_G.FOV.Filled = false -- <<<<<< AQUI ESTÁ A SOLUÇÃO: Não preenche por dentro
_G.FOV.Transparency = 1 -- Visível

local function get()
    local t, m = nil, S.Radius
    local center = Vector2.new(Cam.ViewportSize.X/2, Cam.ViewportSize.Y/2)
    for _, v in pairs(workspace:GetDescendants()) do
        if v:IsA("Humanoid") and v.Health > 0 then
            local ch = v.Parent
            if ch and ch ~= L.Character then
                local p = P:GetPlayerFromCharacter(ch)
                if S.Team and p and p.Team == L.Team then continue end
                if not S.Bots and not p then continue end
                local pt = ch:FindFirstChild("Head") or ch:FindFirstChild("HumanoidRootPart")
                if pt then
                    local vp, on = Cam:WorldToViewportPoint(pt.Position)
                    if on then
                        local d = (Vector2.new(vp.X, vp.Y) - center).Magnitude
                        if d < m then
                            if S.Wall then
                                local r = Ray.new(Cam.CFrame.Position, (pt.Position - Cam.CFrame.Position).Unit * 500)
                                if workspace:FindPartOnRayWithIgnoreList(r, {L.Character, ch}) then continue end
                            end
                            m, t = d, pt
                        end
                    end
                end
            end
        end
    end
    return t
end

-- // --- LOOP DE EXECUÇÃO --- //
R:BindToRenderStep("Lock", 201, function()
    if _G.FOV then
        _G.FOV.Visible = S.Aimbot -- Só mostra o FOV se o Aimbot estiver ligado
        _G.FOV.Radius = S.Radius
        _G.FOV.Position = Vector2.new(Cam.ViewportSize.X/2, Cam.ViewportSize.Y/2)
    end

    if S.Aimbot then
        local target = get()
        if target then 
            Cam.CFrame = CFrame.lookAt(Cam.CFrame.Position, target.Position) 
        end
    end
end)
