local Players = game:GetService("Players")
local VirtualInputManager = game:GetService("VirtualInputManager")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local allowedIds = {4203835281, 3378581061, 481825941, 828317988}
local playerId = player.UserId

if not table.find(allowedIds, playerId) then
    warn("VocÃª nÃ£o estÃ¡ na whitelist. Desconectando...")
    player:Kick("VocÃª nÃ£o tem permissÃ£o para usar este script. Seu UserId: " .. playerId)
    return
end

-- CriaÃ§Ã£o da UI
local screenGui = Instance.new("ScreenGui")
screenGui.Parent = playerGui

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 250, 0, 150)
mainFrame.Position = UDim2.new(0.5, -125, 0.4, -75)
mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
mainFrame.BackgroundTransparency = 0.2
mainFrame.BorderSizePixel = 0

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 8)
corner.Parent = mainFrame

mainFrame.Parent = screenGui

local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, 0, 0, 30)
titleLabel.Position = UDim2.new(0, 0, 0, 0)
titleLabel.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
titleLabel.Text = "ghost hub"
titleLabel.TextSize = 18
titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
titleLabel.Font = Enum.Font.SourceSansBold
titleLabel.Parent = mainFrame

local isPromptClosed = false

local closePromptButton = Instance.new("TextButton")
closePromptButton.Size = UDim2.new(0, 200, 0, 40)
closePromptButton.Position = UDim2.new(0.5, -100, 0.4, 0)
closePromptButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
closePromptButton.TextColor3 = Color3.fromRGB(255, 255, 255)
closePromptButton.TextSize = 16
closePromptButton.Font = Enum.Font.SourceSansBold
closePromptButton.Text = "Fechar Prompt: OFF"
closePromptButton.Parent = mainFrame

local closeButton = Instance.new("TextButton")
closeButton.Size = UDim2.new(0, 200, 0, 40)
closeButton.Position = UDim2.new(0.5, -100, 0.7, 0)
closeButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
closeButton.TextSize = 16
closeButton.Font = Enum.Font.SourceSansBold
closeButton.Text = "Fechar UI"
closeButton.Parent = mainFrame

-- Eventos dos botÃµes
closePromptButton.MouseButton1Click:Connect(function()
    isPromptClosed = not isPromptClosed
    closePromptButton.Text = isPromptClosed and "Fechar Prompt: ON" or "Fechar Prompt: OFF"
    print(isPromptClosed and "ðŸ›‘ Fechamento automÃ¡tico ativado!" or "âœ… Fechamento automÃ¡tico desativado!")
end)

closeButton.MouseButton1Click:Connect(function()
    screenGui:Destroy()
end)

local mt = getrawmetatable(game)
setreadonly(mt, false)

local oldIndex = mt.__namecall

mt.__namecall = newcclosure(function(self, ...)
    local args = {...}
    local method = getnamecallmethod()

    if isPromptClosed and (method == "PromptProductPurchase" or method == "PromptPurchase") then
        print("âš ï¸ Tentativa de compra detectada! Fechando...")

        task.spawn(function()
            task.wait()
            for _, gui in pairs(game.CoreGui:GetChildren()) do
                if gui:IsA("ScreenGui") and gui.Name:lower():find("purchase") then
                    gui.Enabled = false
                    print("âŒ Prompt de compra fechado!")
                end
            end

            VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.ButtonB, false, game)
        end)
    end

    return oldIndex(self, unpack(args))
end)

-- FunÃ§Ã£o para carregar e executar um script externo
local function loadExternalScript(url)
    local success, scriptContent = pcall(function()
        return game:HttpGet(url)
    end)

    if success and scriptContent and scriptContent ~= "" then
        print("âœ… Script carregado com sucesso!")
        local func, err = loadstring(scriptContent)
        if func then
            func()
        else
            warn("Erro ao executar o script: " .. err)
        end
    else
        warn("âš ï¸ Erro ao carregar o script. Verifique a URL ou o conteÃºdo.")
    end
end

-- URL do script externo
local url = "https://raw.githubusercontent.com/Fantamasdanoite0/Quick-Prompt-Closer-/main/Script.lua"

-- Carregar e executar o script externo
loadExternalScript(url)
