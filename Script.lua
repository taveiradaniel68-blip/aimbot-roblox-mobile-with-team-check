local P = game:GetService("Players")
local R = game:GetService("RunService")
local C = game:GetService("CoreGui")
local L = P.LocalPlayer

-- Limpeza
if C:FindFirstChild("HitboxMenu") then C.HitboxMenu:Destroy() end

local S = {Enabled = false, Size = 15, Transparency = 0.5}

-- Criar Interface
local Sc = Instance.new("ScreenGui", C); Sc.Name = "HitboxMenu"
local M = Instance.new("Frame", Sc); M.Size = UDim2.new(0, 180, 0, 220); M.Position = UDim2.new(0.1, 0, 0.3, 0); M.BackgroundColor3 = Color3.new(0,0,0); M.BackgroundTransparency = 0.5; M.Active = true; M.Draggable = true

local function btn(t, y, f, color)
    local b = Instance.new("TextButton", M)
    b.Size = UDim2.new(1, 0, 0, 40); b.Position = UDim2.new(0, 0, 0, y)
    b.Text = t; b.BackgroundColor3 = color or Color3.new(0.15, 0.15, 0.15); b.TextColor3 = Color3.new(1,1,1); b.Font = Enum.Font.SourceSansBold
    b.MouseButton1Click:Connect(function() f(b) end)
    return b
end

-- Botão Hitbox
local hbBtn = btn("HITBOX: OFF", 0, function(b)
    S.Enabled = not S.Enabled
    b.Text = S.Enabled and "HITBOX: ON" or "HITBOX: OFF"
    b.BackgroundColor3 = S.Enabled and Color3.new(0, 0.4, 0) or Color3.new(0.4, 0, 0)
end)

-- Sistema de Transparência (Botão que alterna entre 0, 0.5 e 1)
local transBtn = btn("TRANSPARENCY: " .. S.Transparency, 50, function(b)
    if S.Transparency == 0 then S.Transparency = 0.5 
    elseif S.Transparency == 0.5 then S.Transparency = 1 
    else S.Transparency = 0 end
    b.Text = "TRANSPARENCY: " .. S.Transparency
end)

-- Botão para Resetar Hitboxes (Voltar ao normal)
btn("RESET HITBOXES", 110, function()
    for _, v in pairs(P:GetPlayers()) do
        if v ~= L and v.Character and v.Character:FindFirstChild("Head") then
            v.Character.Head.Size = Vector3.new(1.2, 1, 1)
            v.Character.Head.Transparency = 0
            v.Character.Head.CanCollide = true
        end
    end
end)

-- Botão Destruir Tudo
btn("DESTROY MENU", 170, function()
    S.Enabled = false
    Sc:Destroy()
end, Color3.new(0.3, 0, 0))

-- Loop de aplicação da Hitbox
R.RenderStepped:Connect(function()
    if S.Enabled then
        for _, v in pairs(P:GetPlayers()) do
            if v ~= L and v.Character and v.Character:FindFirstChild("Head") then
                local head = v.Character.Head
                -- Expande a hitbox
                head.Size = Vector3.new(S.Size, S.Size, S.Size)
                head.Transparency = S.Transparency
                head.BrickColor = BrickColor.new("Really blue") -- Cor azul para facilitar
                head.Material = Enum.Material.Neon
                
                -- SEM COLISÃO (Para você não bater na hitbox)
                head.CanCollide = false
                head.CanTouch = true -- Mantém "True" para o tiro registrar
            end
        end
    end
end)
