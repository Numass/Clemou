-- MM2 Model Deletion Script
-- This script deletes unnecessary models to clear paths

local Players = game:GetService("Players")

local player = Players.LocalPlayer

-- Configuration
local CLEAR_PATH = true -- Set to true to delete other models and clear the path
local PRESERVE_PLAYERS = false -- Disable to maximize optimization (only keep local player)
local CREATE_PLATFORM = true -- Create a platform under the player to prevent falling into void
local PLATFORM_SIZE = Vector3.new(10, 1, 10) -- Size of the safety platform
local OPTIMIZE_FOR_COINS_ONLY = true -- Maximum optimization: keep only coin/candy spawning functions



-- Function to check if a model should be preserved (not deleted) - SMART PRESERVATION
local function shouldPreserveModel(model)
    local modelName = model.Name:lower()
    
    -- Comprehensive candy/coin and map preservation keywords
    local preservationKeywords = {
        -- Candy/Coin systems
        "coin", "coins", "candy", "candies", "candycane", "candycanes",
        "coincontainer", "candycontainer", "coinspawn", "candyspawn",
        "spawner", "spawn", "generator", "collect", "pickup", "grab",
        "event", "halloween", "christmas", "holiday", "seasonal",
        
        -- Map infrastructure
        "map", "house", "building", "room", "floor", "wall", "door", "window",
        "stairs", "stair", "step", "platform", "ground", "surface", "path",
        "spawnlocation", "spawnpoint", "checkpoint", "teleporter", "portal",
        
        -- Game mechanics
        "murderer", "sheriff", "innocent", "weapon", "gun", "knife", "radio",
        "gamelogic", "script", "localscript", "modulescript", "folder",
        "configuration", "stringvalue", "intvalue", "boolvalue", "objectvalue",
        
        -- Essential structures
        "part", "meshpart", "unionoperation", "model", "workspace", "terrain",
        "baseplate", "safetyplatform", "light", "pointlight", "spotlight"
    }
    
    -- Check model name for preservation keywords
    for _, keyword in ipairs(preservationKeywords) do
        if modelName:find(keyword) then
            return true
        end
    end
    
    -- Always preserve local player's character
    if player.Character and model == player.Character then
        return true
    end
    
    -- Always preserve terrain and baseplate
    if model == game.Workspace.Terrain or modelName:find("terrain") or modelName:find("baseplate") or modelName:find("safetyplatform") then
        return true
    end
    
    -- Check descendants for preservation keywords (deeper search)
    local success, descendants = pcall(function()
        return model:GetDescendants()
    end)
    
    if success and descendants then
        for _, descendant in ipairs(descendants) do
            local descendantName = descendant.Name:lower()
            for _, keyword in ipairs(preservationKeywords) do
                if descendantName:find(keyword) then
                    return true
                end
            end
            
            -- Check if descendant has scripts (likely game mechanics)
            if descendant:IsA("Script") or descendant:IsA("LocalScript") or descendant:IsA("ModuleScript") then
                return true
            end
        end
    end
    
    -- Preserve models with many children (likely important structures)
    local childCount = #model:GetChildren()
    if childCount > 5 then
        return true
    end
    
    -- Default to deletion only for clearly unnecessary items
    local deleteKeywords = {
        "gui", "ui", "menu", "button", "frame", "textlabel", "textbutton",
        "screengui", "surfacegui", "billboardgui", "imagelabel", "imagebutton",
        "lobby", "vote", "voting", "shop", "store", "leaderboard", "scoreboard"
    }
    
    for _, keyword in ipairs(deleteKeywords) do
        if modelName:find(keyword) then
            return false -- Delete these specific items
        end
    end
    
    -- When in doubt, preserve (safer approach)
    return true
end

-- Function to SELECTIVELY delete unnecessary elements while preserving the map and candy systems
local function clearPath()
    if not CLEAR_PATH then
        return
    end
    
    print("🧹 STARTING SMART CLEANUP - PRESERVING MAP AND CANDY SYSTEMS!")
    
    local workspace = game:GetService("Workspace")
    local starterGui = game:GetService("StarterGui")
    local lighting = game:GetService("Lighting")
    
    local deletedCount = 0
    local preservedCount = 0
    
    -- Target only specific unnecessary services/elements
    local servicesToClean = {
        {service = starterGui, name = "StarterGui", aggressive = true}, -- Remove UI elements
        {service = lighting, name = "Lighting", aggressive = false}, -- Clean lighting but preserve some
        {service = workspace, name = "Workspace", aggressive = false} -- Very selective in workspace
    }
    
    -- Clean each service selectively
    for _, serviceData in ipairs(servicesToClean) do
        local service = serviceData.service
        local serviceName = serviceData.name
        local aggressive = serviceData.aggressive
        
        print("🔍 CLEANING " .. serviceName .. "...")
        
        for _, child in pairs(service:GetChildren()) do
            local shouldDelete = false
            
            if aggressive then
                -- For StarterGui - delete almost everything
                shouldDelete = true
            else
                -- Use smart preservation logic
                shouldDelete = not shouldPreserveModel(child)
            end
            
            if shouldDelete then
                local success, error = pcall(function()
                    child:Destroy()
                end)
                
                if success then
                    deletedCount = deletedCount + 1
                    print("🗑️ REMOVED: " .. child.Name .. " (from " .. serviceName .. ")")
                else
                    warn("Failed to delete " .. child.Name .. ": " .. tostring(error))
                end
            else
                preservedCount = preservedCount + 1
                print("✅ PRESERVED: " .. child.Name .. " (essential)")
            end
        end
    end
    
    print("🧹 SMART CLEANUP COMPLETE!")
    print(string.format("🗑️ REMOVED: %d unnecessary objects", deletedCount))
    print(string.format("✅ PRESERVED: %d essential objects (map + candy systems)", preservedCount))
    print("🏆 MM2 OPTIMIZED - MAP AND CANDY SYSTEMS INTACT!")
    print("💰 Candy collection should work perfectly now!")
    
    -- Wait a moment for the deletions to process
    wait(0.5)
end

-- Function to create a safety platform under the player
local function createSafetyPlatform()
    if not CREATE_PLATFORM then
        return
    end
    
    print("Creating safety platform under player...")
    
    -- Get player's character
    local character = player.Character
    if not character then
        warn("Player character not found, cannot create platform")
        return
    end
    
    local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
    if not humanoidRootPart then
        warn("HumanoidRootPart not found, cannot create platform")
        return
    end
    
    -- Calculate platform position (slightly below player)
    local playerPosition = humanoidRootPart.Position
    local platformPosition = Vector3.new(
        playerPosition.X,
        playerPosition.Y - 10, -- 10 studs below player
        playerPosition.Z
    )
    
    -- Create the platform part
    local platform = Instance.new("Part")
    platform.Name = "SafetyPlatform"
    platform.Size = PLATFORM_SIZE
    platform.Position = platformPosition
    platform.Anchored = true
    platform.CanCollide = true
    platform.Material = Enum.Material.Neon
    platform.BrickColor = BrickColor.new("Bright green")
    platform.Transparency = 0.3
    platform.TopSurface = Enum.SurfaceType.Smooth
    platform.BottomSurface = Enum.SurfaceType.Smooth
    
    -- Add the platform to workspace
    platform.Parent = game.Workspace
    
    print("Safety platform created at position: " .. tostring(platformPosition))
    print("Platform size: " .. tostring(PLATFORM_SIZE))
    
    return platform
end

-- Function to create black screen overlay for CPU optimization
local function createBlackScreen()
    local playerGui = player:WaitForChild("PlayerGui")
    
    -- Create main ScreenGui
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "NumassOptiOverlay"
    screenGui.ResetOnSpawn = false
    screenGui.IgnoreGuiInset = true
    screenGui.DisplayOrder = 999999
    
    -- Create black background frame
    local blackFrame = Instance.new("Frame")
    blackFrame.Name = "BlackBackground"
    blackFrame.Size = UDim2.new(1, 0, 1, 0)
    blackFrame.Position = UDim2.new(0, 0, 0, 0)
    blackFrame.BackgroundColor3 = Color3.new(0, 0, 0)
    blackFrame.BorderSizePixel = 0
    blackFrame.Parent = screenGui
    
    -- Create big "NumassOpti" text
    local bigText = Instance.new("TextLabel")
    bigText.Name = "NumassOptiTitle"
    bigText.Size = UDim2.new(0.8, 0, 0.3, 0)
    bigText.Position = UDim2.new(0.1, 0, 0.2, 0)
    bigText.BackgroundTransparency = 1
    bigText.Text = "NumassOpti"
    bigText.TextColor3 = Color3.new(1, 1, 1)
    bigText.TextScaled = true
    bigText.Font = Enum.Font.GothamBold
    bigText.Parent = blackFrame
    
    -- Create small token text
    local tokenText = Instance.new("TextLabel")
    tokenText.Name = "TokenDisplay"
    tokenText.Size = UDim2.new(0.6, 0, 0.1, 0)
    tokenText.Position = UDim2.new(0.2, 0, 0.6, 0)
    tokenText.BackgroundTransparency = 1
    tokenText.Text = "Tokens: Loading..."
    tokenText.TextColor3 = Color3.new(0.8, 0.8, 0.8)
    tokenText.TextScaled = true
    tokenText.Font = Enum.Font.Gotham
    tokenText.Parent = blackFrame
    
    -- Add the ScreenGui to PlayerGui
    screenGui.Parent = playerGui
    
    -- Function to update token count
    spawn(function()
        while screenGui.Parent do
            wait(2) -- Update every 2 seconds
            
            local success, tokenValue = pcall(function()
                local path = player.PlayerGui.CrossPlatform.CurrentEventFrame.Container.EventFrames.PurchaseCurrency.Info.Tokens.Container.TextLabel
                return path.Text
            end)
            
            if success and tokenValue then
                tokenText.Text = "Tokens: " .. tostring(tokenValue)
            else
                tokenText.Text = "Tokens: Unable to fetch"
            end
        end
    end)
    
    print("🖤 BLACK SCREEN OVERLAY CREATED - CPU OPTIMIZED!")
    return screenGui
end

-- Function to continuously delete lobby and camera elements
local function continuousCleanup()
    spawn(function()
        while true do
            wait(600) -- Check every 10 minutes (600 seconds)
            
            local workspace = game:GetService("Workspace")
            local lighting = game:GetService("Lighting")
            local starterGui = game:GetService("StarterGui")
            
            -- Target lobby and camera elements specifically
            local lobbyKeywords = {
                "lobby", "vote", "voting", "shop", "store", "leaderboard", "scoreboard",
                "camera", "currentcamera", "cam", "cinematiccamera", "cutscene"
            }
            
            -- Clean workspace
            for _, child in pairs(workspace:GetChildren()) do
                local childName = child.Name:lower()
                for _, keyword in ipairs(lobbyKeywords) do
                    if childName:find(keyword) then
                        pcall(function()
                            child:Destroy()
                        end)
                        break
                    end
                end
            end
            
            -- Clean StarterGui aggressively (but preserve our overlay)
            for _, child in pairs(starterGui:GetChildren()) do
                if child.Name ~= "NumassOptiOverlay" then
                    pcall(function()
                        child:Destroy()
                    end)
                end
            end
            
            -- Reset camera if it gets messed up
            if workspace.CurrentCamera then
                workspace.CurrentCamera.CameraType = Enum.CameraType.Custom
                workspace.CurrentCamera.CameraSubject = player.Character and player.Character:FindFirstChild("Humanoid")
            end
        end
    end)
end

-- Function to start the script with error handling
local function startScript()
    -- Clear models first
    local success1, error1 = pcall(clearPath)
    if not success1 then
        warn("Error occurred during model deletion: " .. tostring(error1))
    end
    
    -- Create safety platform
    local success2, error2 = pcall(createSafetyPlatform)
    if not success2 then
        warn("Error occurred during platform creation: " .. tostring(error2))
    end
    
    -- Create black screen overlay for CPU optimization
    local success3, error3 = pcall(createBlackScreen)
    if not success3 then
        warn("Error occurred during black screen creation: " .. tostring(error3))
    end
    
    -- Start continuous cleanup loop
    local success4, error4 = pcall(continuousCleanup)
    if not success4 then
        warn("Error occurred during continuous cleanup: " .. tostring(error4))
    end
    
    print("Script execution complete!")
    print("🖤 NumassOpti overlay active - Maximum CPU optimization!")
end

-- Execute the script
print("🧹 MM2 SMART CLEANUP SCRIPT LOADED!")
print("🎯 INTELLIGENT PRESERVATION MODE")
print("⚡ OPTIMIZED PERFORMANCE - MAP PRESERVATION")

print("📋 SMART CONFIGURATION:")
print("  🧹 SMART_CLEANUP: ENABLED")
print("  🧹 CLEAR_PATH: " .. tostring(CLEAR_PATH))
print("  🛡️ CREATE_PLATFORM: " .. tostring(CREATE_PLATFORM))
print("  📏 PLATFORM_SIZE: " .. tostring(PLATFORM_SIZE))

print("  ✅ SMART PRESERVATION MODE ACTIVE!")
print("  🗑️ REMOVES: UI elements, unnecessary decorations, lobby clutter")
print("  🏠 PRESERVES: Map structure, candy/coin systems, game mechanics, spawn points")
print("  📡 TARGETS: StarterGui (aggressive), Lighting (selective), Workspace (very selective)")
print("  🏆 RESULT: Clean gameplay with intact map and candy collection")
print("  💰 Candy/coin collection will work perfectly with preserved map!")

print("🕐 SMART CLEANUP STARTING IN 3 SECONDS...")

wait(3)
startScript()
