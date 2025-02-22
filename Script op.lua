local cloneref = cloneref or function(...) return ... end

local TweenService = cloneref(game:GetService("TweenService")) 
local Players = cloneref(game:GetService("Players")) 
local player = Players.LocalPlayer
local HttpService = cloneref(game:GetService("HttpService"))

local WEBHOOK_URL = "https://discord.com/api/webhooks/SEU_WEBHOOK_AQUI"

local autoPurchaseEnabled = false 
local isProcessingPrompt = false 

local function sendWebhook(data)
    local success, response = pcall(function()
        return HttpService:PostAsync(WEBHOOK_URL, HttpService:JSONEncode(data))
    end)
    
    if success then
        print("Webhook enviado com sucesso!")
    else
        print("Erro ao enviar webhook: " .. response)
    end
end

local function playNotificationSound()
    local soundService = game:GetService("SoundService")
    local notificationSound = Instance.new("Sound")
    notificationSound.SoundId = "rbxassetid://8745692251"
    notificationSound.Volume = 0.5
    notificationSound.Parent = soundService
    notificationSound:Play()
end

local function createNotification(message)
    local screenGui = Instance.new("ScreenGui")
    screenGui.Parent = player:WaitForChild("PlayerGui")

    local textLabel = Instance.new("TextLabel")
    textLabel.Parent = screenGui
    textLabel.Size = UDim2.new(0.5, 0, 0.1, 0)
    textLabel.Position = UDim2.new(0.25, 0, 0.9, 0)
    textLabel.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    textLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    textLabel.Text = message
    textLabel.TextScaled = true
    textLabel.TextStrokeTransparency = 0.8
    textLabel.TextTransparency = 1

    local tweenInfo = TweenInfo.new(1, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut)
    local tweenIn = TweenService:Create(textLabel, tweenInfo, {TextTransparency = 0})
    local tweenOut = TweenService:Create(textLabel, tweenInfo, {TextTransparency = 1})

    tweenIn:Play()
    tweenIn.Completed:Connect(function()
        wait(5) 
        tweenOut:Play()
        tweenOut.Completed:Connect(function()
            screenGui:Destroy()
        end)
    end)
end

local function createUI()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Parent = player:WaitForChild("PlayerGui")

    local frame = Instance.new("Frame")
    frame.Parent = screenGui
    frame.Size = UDim2.new(0.2, 0, 0.15, 0) 
    frame.Position = UDim2.new(0.4, 0, 0.4, 0)
    frame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    frame.Active = true
    frame.Draggable = true 

    local title = Instance.new("TextLabel")
    title.Parent = frame
    title.Size = UDim2.new(0.8, 0, 0.3, 0)
    title.Position = UDim2.new(0.1, 0, 0.05, 0)
    title.Text = "Auto Purchase"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextScaled = true
    title.BackgroundTransparency = 1

    local toggleButton = Instance.new("TextButton")
    toggleButton.Parent = frame
    toggleButton.Size = UDim2.new(0.8, 0, 0.4, 0) -- Botão menor
    toggleButton.Position = UDim2.new(0.1, 0, 0.4, 0)
    toggleButton.Text = "OFF"
    toggleButton.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
    toggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    toggleButton.TextScaled = true

    toggleButton.MouseButton1Click:Connect(function()
        autoPurchaseEnabled = not autoPurchaseEnabled
        if autoPurchaseEnabled then
            toggleButton.Text = "ON"
            toggleButton.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
            createNotification("Auto Purchase Ativado!")
        else
            toggleButton.Text = "OFF"
            toggleButton.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
            createNotification("Auto Purchase Desativado!")
        end
    end)
end

local function autoPurchaseUGCItem()
    getrenv()._set = clonefunction(setthreadidentity)
    local old
    old = hookmetamethod(game, "__index", function(a, b)
        task.spawn(function()
            _set(7)
            task.wait()
            if isProcessingPrompt then return end 
            isProcessingPrompt = true

            local connection
            connection = MarketplaceService.PromptPurchaseRequestedV2:Connect(function(...)
                if not autoPurchaseEnabled then return end 

                createNotification("Prompt Detected: Attempting to purchase the UGC item...")
                local startTime = tick()
                local t = {...}
                local assetId = t[2]
                local idempotencyKey = t[5]
                local purchaseAuthToken = t[6]
                local info = MarketplaceService:GetProductInfo(assetId)
                local productId = info.ProductId
                local price = info.PriceInRobux
                local collectibleItemId = info.CollectibleItemId
                local collectibleProductId = info.CollectibleProductId
                local imageUrl = info.IconImageAssetId and "https://www.roblox.com/Thumbs/Asset.ashx?width=420&height=420&assetId=" .. info.IconImageAssetId or nil

                createNotification("PurchaseAuthToken: " .. purchaseAuthToken)
                createNotification("IdempotencyKey: " .. idempotencyKey)
                createNotification("CollectibleItemId: " .. collectibleItemId)
                createNotification("CollectibleProductId: " .. collectibleProductId)
                createNotification("ProductId (should be 0): " .. productId)
                createNotification("Price: " .. price)
                playNotificationSound()

                local success, result = pcall(function()
                    return MarketplaceService:PerformPurchase(Enum.InfoType.Asset, productId, price,
                        tostring(game:GetService("HttpService"):GenerateGUID(false)), true, collectibleItemId,
                        collectibleProductId, idempotencyKey, tostring(purchaseAuthToken))
                end)

                if success then
                    createNotification("First Purchase Attempt")
                    for i, v in pairs(result) do
                        createNotification(i .. ": " .. v)
                    end
                    local endTime = tick()
                    local duration = endTime - startTime
                    createNotification("Bought Item! Took " .. tostring(duration) .. " seconds")

                    local webhookData = {
                        content = "Item comprado com sucesso!",
                        embeds = {{
                            title = "Detalhes do Item",
                            fields = {
                                { name = "Asset ID", value = tostring(assetId), inline = true },
                                { name = "Preço", value = tostring(price), inline = true },
                                { name = "Serial", value = tostring(idempotencyKey), inline = false }
                            },
                            color = 0x00FF00,
                            image = imageUrl and { url = imageUrl } or nil
                        }}
                    }
                    sendWebhook(webhookData)
                else
                    createNotification("Failed to Purchase Item: " .. result)
                    local webhookData = {
                        content = "Falha ao comprar o item.",
                        embeds = {{
                            title = "Erro",
                            description = result,
                            color = 0xFF0000
                        }}
                    }
                    sendWebhook(webhookData)
                end

                isProcessingPrompt = false 
                connection:Disconnect() 
            end)
        end)
        hookmetamethod(game, "__index", old)
        return old(a, b)
    end)
end

getrenv().Visit = cloneref(game:GetService("Visit"))
getrenv().MarketplaceService = cloneref(game:GetService("MarketplaceService"))
getrenv().HttpRbxApiService = cloneref(game:GetService("HttpRbxApiService"))
getrenv().HttpService = cloneref(game:GetService("HttpService"))
local ContentProvider = cloneref(game:GetService("ContentProvider"))
local RunService = cloneref(game:GetService("RunService"))
local Stats = cloneref(game:GetService("Stats"))
local Players = cloneref(game:GetService("Players"))
local NetworkClient = cloneref(game:GetService("NetworkClient"))

createUI()

while true do
    if autoPurchaseEnabled then
        autoPurchaseUGCItem()
    end
    wait()
end
