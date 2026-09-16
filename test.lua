--!nocheck
--!nolint
-- ══════════════════════════════════════════════════════════════════════
--   PRISM — Dungeon Lootr (Ultimate Sequential Edition) v5.9.5 [PRO]
-- ══════════════════════════════════════════════════════════════════════
if not game:IsLoaded() then 
    game.Loaded:Wait() 
end

task.wait(4)

local Players            = game:GetService("Players")
local ReplicatedStorage  = game:GetService("ReplicatedStorage")
local RunService         = game:GetService("RunService")
local TweenService       = game:GetService("TweenService")
local UserInputService   = game:GetService("UserInputService")
local VirtualUser        = game:GetService("VirtualUser")
local VIM                = game:GetService("VirtualInputManager")
local HttpService        = game:GetService("HttpService")
local StatsService       = game:GetService("Stats")
local Lighting           = game:GetService("Lighting")
local GuiService         = game:GetService("GuiService")
local LocalPlayer        = Players.LocalPlayer

-- ── Knit & Remotes Setup ──
local KnitServices      = ReplicatedStorage:WaitForChild("Packages"):WaitForChild("_Index"):WaitForChild("sleitnick_knit@1.7.0"):WaitForChild("knit"):WaitForChild("Services")

local SummonService     = KnitServices:WaitForChild("SummoningService")
local dl_Spin           = SummonService:WaitForChild("RF"):WaitForChild("Spin")
local dl_SwitchSlot     = SummonService:WaitForChild("RF"):WaitForChild("SwitchSlot")
local dl_PurchaseSlot   = SummonService:WaitForChild("RF"):WaitForChild("PurchaseSlot")
local dl_GetSlotData    = SummonService:WaitForChild("RF"):WaitForChild("GetSlotData")

local ShopService       = KnitServices:WaitForChild("ShopService")
local dl_SellEquipment  = ShopService:WaitForChild("RF"):WaitForChild("SellEquipment")
local dl_BuyEquipment   = ShopService:WaitForChild("RF"):WaitForChild("BuyEquipment")
local dl_GetShopInfo    = ShopService:WaitForChild("RF"):WaitForChild("GetEquipmentShopInfo")

local QuestService      = KnitServices:WaitForChild("QuestService")
local dl_ClaimQuest     = QuestService:WaitForChild("RF"):WaitForChild("ClaimQuest")

local QueueService      = KnitServices:WaitForChild("DungeonQueueService")
local QueueRF           = QueueService:WaitForChild("RF")
local dl_SelectMode     = QueueRF:WaitForChild("RequestSelectMode")
local dl_SelectDungeon  = QueueRF:WaitForChild("RequestSelectDungeon")
local dl_SelectDiff     = QueueRF:WaitForChild("RequestSelectDifficulty")
local dl_SelectFinalBoss= QueueRF:WaitForChild("RequestSelectFinalBoss")
local dl_StartQueue     = QueueRF:WaitForChild("RequestStartPodQueue")
local dl_StartNow       = QueueRF:WaitForChild("RequestStartNow")
local dl_EnterQueue     = QueueRF:WaitForChild("RequestEnter")
local dl_SelectRaid     = QueueRF:WaitForChild("RequestSelectRaid")
local dl_SelectRaidDiff = QueueRF:WaitForChild("RequestSelectRaidDifficulty")

local StatService       = KnitServices:WaitForChild("StatService")
local dl_AllocatePoints = StatService:WaitForChild("RF"):WaitForChild("AllocatePoints")

local PotionService     = KnitServices:WaitForChild("PotionService")
local dl_UsePotion      = PotionService:WaitForChild("RF"):WaitForChild("UsePotion")

local MysteryMerchantService = KnitServices:WaitForChild("MysteryMerchantService")
local dl_MM_GetShopInfo      = MysteryMerchantService:WaitForChild("RF"):WaitForChild("GetShopInfo")
local dl_MM_BuyItem          = MysteryMerchantService:WaitForChild("RF"):WaitForChild("BuyItem")

local RaidShopService        = KnitServices:WaitForChild("RaidShopService")
local dl_BuyRaidShopItem     = RaidShopService:WaitForChild("RF"):WaitForChild("BuyRaidShopItem")

-- Dungeon Run Service
local DungeonRunService     = KnitServices:WaitForChild("DungeonRunService")
local dl_RequestReplay      = DungeonRunService:WaitForChild("RF"):WaitForChild("RequestReplay")
local dl_RequestReturn      = DungeonRunService:WaitForChild("RF"):WaitForChild("RequestReturn")
local dl_SubmitEndless      = DungeonRunService:WaitForChild("RF"):WaitForChild("SubmitEndlessChoice")
local dl_ChestSelectionRE   = DungeonRunService:WaitForChild("RE"):WaitForChild("ChestSelection")

-- BossRush / Challenge / Raid services
function safeGetService(name)
    return KnitServices:FindFirstChild(name)
end

local BossRushRunService = safeGetService("BossRushRunService")
local ChallengeRunService = safeGetService("ChallengeRunService")
local RaidRunService = safeGetService("RaidRunService")

function safeGetRF(svc, name)
    if not svc then return nil end
    local rf = svc:FindFirstChild("RF")
    return rf and rf:FindFirstChild(name)
end

local dl_BR_Replay = safeGetRF(BossRushRunService, "RequestReplay")
local dl_BR_Return = safeGetRF(BossRushRunService, "RequestReturn")
local dl_CH_Replay = safeGetRF(ChallengeRunService, "RequestReplay")
local dl_CH_Return = safeGetRF(ChallengeRunService, "RequestReturn")
local dl_RD_Replay = safeGetRF(RaidRunService, "RequestReplay")
local dl_RD_Return = safeGetRF(RaidRunService, "RequestReturn")

-- Direct Gameplay Action Remotes
local PlayerRemotes     = ReplicatedStorage:WaitForChild("Player"):WaitForChild("Remotes")
local InputsFolder      = PlayerRemotes:WaitForChild("Inputs")
local r_Attack          = InputsFolder:WaitForChild("Attack")
local r_Skill           = InputsFolder:WaitForChild("Skill")
local r_Parry           = InputsFolder:WaitForChild("Parry")
local r_Dash            = InputsFolder:WaitForChild("Dash")



local zeroVector = (vector and vector.zero) or Vector3.zero
function createVector(x, y, z)
    if vector and vector.create then
        return vector.create(x, y, z)
    else
        return Vector3.new(x, y, z)
    end
end

-- ══════════════════════════════════════════
--   DISCORD WEBHOOK SYSTEM CONFIGURATION
-- ══════════════════════════════════════════
local wh_url = ""
local wh_userId = ""
local wh_pingEnabled = false
local wh_pingEveryone = false
local wh_isSending = false
local wh_minRarity = "Common"

local sendDungeonRemoteWebhook -- <-- ADD THIS LINE HERE

function wh_requestFunc(options)
    local fn = (syn and syn.request)
            or (http and http.request)
            or http_request
            or (fluxus and fluxus.request)
            or request
            or (getgenv and getgenv().request)
    if fn then return fn(options) end
end

function formatNumber(n)
    if type(n) ~= "number" then return tostring(n or 0) end
    local formatted = tostring(math.floor(n))
    while true do
        local newFormatted, k = formatted:gsub("^(-?%d+)(%d%d%d)", "%1,%2")
        formatted = newFormatted
        if k == 0 then break end
    end
    return formatted
end

-- ══════════════════════════════════════════
--   EXECUTOR DETECTION & SESSION STATS
-- ══════════════════════════════════════════

local executorName = "Unknown"
pcall(function()
    if identifyexecutor then
        local name, version = identifyexecutor()
        if type(name) == "string" and name ~= "" then
            executorName = type(version) == "string" and version ~= "" and (name .. " " .. version) or name
        end
    elseif syn then executorName = "Synapse"
    elseif fluxus then executorName = "Fluxus"
    elseif KRNL_LOADED then executorName = "KRNL"
    elseif pebc_execute then executorName = "Pencil"
    end
end)

local SessionStats = {
    startTime       = os.clock(),
    dungeonsRun     = 0,
    roomsCleared    = 0,
    enemiesDefeated = 0,
    attacksFired    = 0,
    currentRoomText = "None",
    roomStateText   = "Idle",
    extractionType  = "Scanning...",
    endlessCheckpoint = 0,
    altarsInteracted = 0,
    lootRoomsCleared = 0,
    lockedRoomsUnlocked = 0,
    specialBossesDefeated = 0,
    activeGamemode   = "Lobby",
}

-- ══════════════════════════════════════════
--   DISCORD LOGGER (PRISM SECURE WORKER)
-- ══════════════════════════════════════════

task.spawn(function()
    local WORKER_URL = "https://ibdihp.hersheyzchoco.workers.dev/"
    local SECRET     = "this_is_the_best_free_script_hub_arena_ai_goated67"
    local gName      = "Dungeons Lootr"
    pcall(function()
        gName = game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Name
    end)
    local data = {
        embeds = {{
            title  = "Prism -- Execution",
            color  = 65535,
            fields = {
                { name = "User",     value = LocalPlayer.Name,                inline = true },
                { name = "Executor", value = executorName,                    inline = true },
                { name = "Game",     value = gName,                           inline = true },
                { name = "Players",  value = tostring(#Players:GetPlayers()), inline = true },
            },
            footer = { text = "Prism - " .. os.date("%x %X") },
        }}
    }
    pcall(function()
        request({
            Url     = WORKER_URL,
            Method  = "POST",
            Headers = { ["Content-Type"] = "application/json" },
            Body = HttpService:JSONEncode({ secret = SECRET, data = data })
        })
    end)
end)

-- ══════════════════════════════════════════
--   LOAD OBSIDIAN UI & ADDONS INITIALIZER
-- ══════════════════════════════════════════

local repo         = "https://raw.githubusercontent.com/joustingmatch/ObsidianUltra/main/"
local Library      = loadstring(game:HttpGet(repo .. "Library.lua"))()

pcall(function() Library.ScreenGui.Parent = game:GetService("CoreGui") end)
_G.PrismLibrary = Library

local ThemeManager = loadstring(game:HttpGet(repo .. "addons/ThemeManager.lua"))()
local SaveManager  = loadstring(game:HttpGet(repo .. "addons/SaveManager.lua"))()

ThemeManager:SetLibrary(Library)
SaveManager:SetLibrary(Library)
ThemeManager:SetFolder("PrismHub")
SaveManager:SetFolder("PrismHub/DungeonLootr")
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({ "MenuKeybind" })

local Toggles = Library.Toggles
local Options = Library.Options

function isOn(name)
    if Library.Unloaded then return false end
    local t = Toggles[name]
    return type(t) == "table" and t.Value == true
end

function getNumber(name, fallback)
    local o = Options[name]
    return (type(o) == "table" and tonumber(o.Value)) or fallback
end

function copyText(text, msg)
    if setclipboard then setclipboard(text)
    elseif toclipboard then toclipboard(text) end
    Library:Notify(msg or "Copied to clipboard!")
end

function vimClick(guiObject)
    if not guiObject or not VIM then return end
    local inset = GuiService:GetGuiInset()
    local absPos = guiObject.AbsolutePosition
    local absSize = guiObject.AbsoluteSize
    local clickX = absPos.X + (absSize.X / 2) + inset.X
    local clickY = absPos.Y + (absSize.Y / 2) + inset.Y

    pcall(function()
        VIM:SendMouseButtonEvent(clickX, clickY, 0, true, game, 0)
        task.wait(0.04)
        VIM:SendMouseButtonEvent(clickX, clickY, 0, false, game, 0)
    end)
end

-- ══════════════════════════════════════════
--   CHARACTER & PHYSICS UTILITIES
-- ══════════════════════════════════════════

local characterParts = {}

function dl_getHRP()
    local char = LocalPlayer.Character
    if not char then return nil end
    return char:FindFirstChild("HumanoidRootPart")
end

function getHumanoid()
    local char = LocalPlayer.Character
    return char and char:FindFirstChildOfClass("Humanoid")
end

function updateCharParts(char)
    table.clear(characterParts)
    if not char then return end
    for _, p in ipairs(char:GetDescendants()) do
        if p:IsA("BasePart") then
            table.insert(characterParts, p)
        end
    end
end

LocalPlayer.CharacterAdded:Connect(function(char)
    updateCharParts(char)
    local childAdded = char.DescendantAdded:Connect(function(p)
        if p:IsA("BasePart") then table.insert(characterParts, p) end
    end)
    local childRemoved = char.DescendantRemoving:Connect(function(p)
        local idx = table.find(characterParts, p)
        if idx then table.remove(characterParts, idx) end
    end)
    local deathConn
    deathConn = char:WaitForChild("Humanoid").Died:Connect(function()
        childAdded:Disconnect()
        childRemoved:Disconnect()
        deathConn:Disconnect()
    end)

    -- Post-Respawn Combat Unfreeze Watchdog (Fires 5s after respawning)
    task.spawn(function()
        task.wait(5)
        if LocalPlayer.Character == char and not isCharacterDead() then
            pcall(function()
                r_Dash:FireServer(createVector(0, 0, -1))
            end)
        end
    end)
end)

if LocalPlayer.Character then
    updateCharParts(LocalPlayer.Character)
end

-- ══════════════════════════════════════════
--   GAME MODE DETECTION ENGINE (4-TIER HIERARCHY)
-- ══════════════════════════════════════════

function dl_getGeneratedDungeon()
    for _, child in ipairs(workspace:GetChildren()) do
        if child.Name:match("^Generated_") then
            return child
        end
    end
    return nil
end

function getGameMode()
    local ok, uiMode = pcall(function()
        local pGui = LocalPlayer:FindFirstChild("PlayerGui")
        if not pGui then return nil end
        local main = pGui:FindFirstChild("Main")
        local hud = main and main:FindFirstChild("HUD")
        local dc = hud and hud:FindFirstChild("Dungeon_Container")
        local completion = dc and dc:FindFirstChild("Completion_Info")
        local content = completion and completion:FindFirstChild("Content")
        local level = content and content:FindFirstChild("Level")
        local title = level and level:FindFirstChild("Title")

        if title and title:IsA("TextLabel") and title.Visible then
            local text = title.Text:upper()
            if text:find("BOSS RUSH") then return "BossRush" end
            if text:find("CHALLENGE") then return "Challenge" end
            if text:find("RAID") then return "Raid" end
            if text:find("DUNGEON") then return "Dungeon" end
        end
        return nil
    end)
    if ok and uiMode then return uiMode end

    if workspace:FindFirstChild("Raid_NPCs") then return "Raid" end
    if workspace:FindFirstChild("Challenge_NPCs") then return "Challenge" end
    if workspace:FindFirstChild("BossRush_NPCs") then return "BossRush" end
    if dl_getGeneratedDungeon() then return "Dungeon" end

    return "Lobby"
end

function dl_getActiveNpcFolders()
    local mode = getGameMode()
    local folders = {}

    if mode == "Dungeon" then
        local dungeon = dl_getGeneratedDungeon()
        if dungeon then
            local npcsFolder = dungeon:FindFirstChild("NPCs")
            if npcsFolder then table.insert(folders, npcsFolder) end
        end
    elseif mode == "BossRush" then
        local f = workspace:FindFirstChild("BossRush_NPCs")
        if f then table.insert(folders, f) end
    elseif mode == "Challenge" then
        local f = workspace:FindFirstChild("Challenge_NPCs")
        if f then table.insert(folders, f) end
    elseif mode == "Raid" then
        local f = workspace:FindFirstChild("Raid_NPCs")
        if f then table.insert(folders, f) end
    end

    return folders, mode
end

-- ══════════════════════════════════════════
--   STATE & FARM CONFIGURATION
-- ══════════════════════════════════════════

local dl_farm_paused         = false
local dl_farm_mode           = "Above Head"
local dl_farm_method         = "Teleport"
local dl_farm_height         = 11
local dl_farm_orbit_speed    = 1.8
local dl_farm_orbit_radius   = 14
local dl_tween_speed         = 95

local dlf_currentTarget      = nil
local dlf_moveConnection     = nil
local dlf_orbitAngle         = 0
local dlf_activeTween        = nil

local activeSequence         = {}
local activeSequenceIndex    = 1
local activeRoomModel        = nil
local cachedRoomCF           = nil
local cachedRoomSize         = nil

-- Loot room sub-farming state
local lootRoomQueue          = {}
local lootRoomIndex          = 0
local currentLootRoomModel   = nil
local cachedLootRoomCF       = nil
local cachedLootRoomSize     = nil

-- Locked room sub-farming state
local isFarmingLockedRoom    = false
local currentLockedRoomModel = nil
local cachedLockedRoomCF     = nil
local cachedLockedRoomSize   = nil
local unlockedLockedRooms    = {}

-- Special Boss room sub-farming state
local isFarmingSpecialBoss   = false
local currentSpecialBossRoom = nil
local cachedSpecialBossCF    = nil
local cachedSpecialBossSize  = nil
local processedSpecialBossRooms = {}

local isRoomCycleRunning     = false
local activeDungeonId        = nil
local dungeonFullyCompleted  = false

-- Endless continue transitions
local endlessContinuePending = false
local endlessContinueUntil   = 0

-- Archetype Priority Lists
local ARCHER_NAMES = {
    ["archer daemon"] = true,
    ["daemon"] = true,
    ["elite daemon"] = true,
    ["rogue daemon"] = true,
    ["elite archer daemon"] = true,
    ["archer"] = true,
    ["mage student"] = true,
    ["knight archer"] = true,
    ["tribal archer"] = true
}

local HEALER_NAMES = {
    ["goblin shaman"] = true,
    ["dark acolyte"] = true,
    ["mage student 2"] = true
}

-- ══════════════════════════════════════════
--   NPC FOLDER RESOLVERS & COMPLETION PROGRESS
-- ══════════════════════════════════════════

function dl_getActualZoneCompletionStates()
    local states = {}
    if #activeSequence == 0 then return states end

    local pg = LocalPlayer:FindFirstChild("PlayerGui")
    local main = pg and pg:FindFirstChild("Main")
    local hud = main and main:FindFirstChild("HUD")
    local dc = hud and hud:FindFirstChild("Dungeon_Container")
    local cp = dc and dc:FindFirstChild("Completion_Progress")
    local list = cp and cp:FindFirstChild("List")

    local slots = {}
    if list then
        for _, child in ipairs(list:GetChildren()) do
            if child:IsA("ImageLabel") and child.Name == "ZoneSlot" then
                table.insert(slots, child)
            end
        end
        table.sort(slots, function(a, b)
            return a.AbsolutePosition.X < b.AbsolutePosition.X
        end)
    end

    for i = 1, #activeSequence do
        local isDone = false
        if #slots >= i then
            local slot = slots[i]
            local completed = slot and slot:FindFirstChild("Completed")
            isDone = completed and completed.Visible == true
        else
            isDone = activeSequence[i].Done == true or activeSequence[i].Completed == true
        end
        states[i] = isDone
    end
    return states
end

local dl_dodge_active        = false
local dl_mini_lava_active    = false
local dl_massive_dodging     = false
local dl_last_massive_dash   = 0
local dl_dodge_target_pos    = nil
local dl_dodge_lock_until    = 0
local latestChestData        = nil

local zoneClearedConsumed    = false
local isCollectingChest      = false
local isInteractingAltar     = false
local isFarmingLootRoom      = false
local isUnlockingRoom        = false
local isSummoningBoss        = false
local consumedAltars         = {}
local collectedChests        = {}

-- ══════════════════════════════════════════
--   DUNGEON WORKSPACE & GEOMETRY ENGINE
-- ══════════════════════════════════════════

function dl_getRoomModel(roomNum)
    local dungeon = dl_getGeneratedDungeon()
    if not dungeon then return nil end
    return dungeon:FindFirstChild("Room_" .. tostring(roomNum))
end

function dl_getRoomBounds(roomModel)
    if not roomModel or not roomModel.Parent then return nil, nil end

    local zone = roomModel:FindFirstChild("Zone")
    if zone and zone:IsA("BasePart") then
        return zone.CFrame, zone.Size
    end

    if roomModel:IsA("Model") then
        local cf, size = roomModel:GetBoundingBox()
        return cf, size
    end

    local firstPart = roomModel:FindFirstChildWhichIsA("BasePart", true)
    if firstPart then
        return firstPart.CFrame, Vector3.new(120, 60, 120)
    end

    return nil, nil
end

function dl_isPointInRoomStrict(point, boxCFrame, boxSize, padding)
    if not boxCFrame or not boxSize then return false end
    padding = padding or 0
    local rel = boxCFrame:PointToObjectSpace(point)
    local hx = (boxSize.X / 2) + padding
    local hz = (boxSize.Z / 2) + padding
    return math.abs(rel.X) <= hx and math.abs(rel.Z) <= hz
end

function dl_isPointInRoomBounds(point, boxCFrame, boxSize)
    if not boxCFrame then return false end
    local maxRadius = boxSize and (math.max(boxSize.X, boxSize.Z) * 0.75 + 40) or 140
    local dist = (Vector3.new(point.X, 0, point.Z) - Vector3.new(boxCFrame.Position.X, 0, boxCFrame.Position.Z)).Magnitude
    return dist <= maxRadius
end

function dl_getRoomNumberForPoint(point)
    local dungeon = dl_getGeneratedDungeon()
    if not dungeon then return nil end

    local candidates = {}
    for _, child in ipairs(dungeon:GetChildren()) do
        local num = child.Name:match("^Room_(%d+)$")
        if num then
            local cf, size = dl_getRoomBounds(child)
            if cf and size then
                if dl_isPointInRoomStrict(point, cf, size, 0) then
                    local dist = (Vector3.new(point.X, 0, point.Z) - Vector3.new(cf.Position.X, 0, cf.Position.Z)).Magnitude
                    table.insert(candidates, { num = tonumber(num), dist = dist })
                end
            end
        end
    end

    if #candidates == 0 then
        local best, bestDist = nil, math.huge
        for _, child in ipairs(dungeon:GetChildren()) do
            local num = child.Name:match("^Room_(%d+)$")
            if num then
                local cf, _ = dl_getRoomBounds(child)
                if cf then
                    local dist = (Vector3.new(point.X, 0, point.Z) - Vector3.new(cf.Position.X, 0, cf.Position.Z)).Magnitude
                    if dist < bestDist then
                        bestDist = dist
                        best = tonumber(num)
                    end
                end
            end
        end
        return best
    end

    table.sort(candidates, function(a, b) return a.dist < b.dist end)
    return candidates[1].num
end

-- ══════════════════════════════════════════
--   SPECIAL BOSS ROOM ENGINE
-- ══════════════════════════════════════════

function dl_isSpecialBossRoom(roomModel)
    if not roomModel then return false end
    return roomModel:GetAttribute("IsSpecialBoss") == true
end

function dl_getSpecialBossInfo(roomModel)
    if not roomModel then return nil end
    if not dl_isSpecialBossRoom(roomModel) then return nil end

    return {
        bossId = roomModel:GetAttribute("SpecialBossId"),
        prespawned = roomModel:GetAttribute("SpecialBossPrespawned") == true,
        roomModel = roomModel
    }
end

function dl_getSpecialBossHallwayForParent(parentIndex)
    local dungeon = dl_getGeneratedDungeon()
    if not dungeon then return nil end

    for _, child in ipairs(dungeon:GetChildren()) do
        local hallwayParentIdx = child.Name:match("^SpecialBossHallway_Side_Room_(%d+)$")
        if hallwayParentIdx and tonumber(hallwayParentIdx) == parentIndex then
            return child
        end
    end

    return nil
end

function dl_findSpecialBossRoomFromHallway(hallway, parentIndex)
    if not hallway then return nil end

    local dungeon = dl_getGeneratedDungeon()
    if not dungeon then return nil end

    local hallwayCF, hallwaySize
    if hallway:IsA("Model") then
        hallwayCF, hallwaySize = hallway:GetBoundingBox()
    else
        local part = hallway:IsA("BasePart") and hallway or hallway:FindFirstChildWhichIsA("BasePart", true)
        if part then
            hallwayCF = part.CFrame
            hallwaySize = part.Size
        end
    end

    if not hallwayCF then return nil end

    local candidates = {}
    for _, child in ipairs(dungeon:GetChildren()) do
        local num = child.Name:match("^Room_(%d+)$")
        if num then
            local nRoom = tonumber(num)
            if nRoom ~= parentIndex and child:GetAttribute("IsSpecialBoss") == true then
                local rCF, rSize = dl_getRoomBounds(child)
                if rCF then
                    local dist = (rCF.Position - hallwayCF.Position).Magnitude
                    table.insert(candidates, { room = child, index = nRoom, dist = dist })
                end
            end
        end
    end

    if #candidates == 0 then
        for _, child in ipairs(dungeon:GetChildren()) do
            local num = child.Name:match("^Room_(%d+)$")
            if num and child:GetAttribute("IsSpecialBoss") == true and not processedSpecialBossRooms[child] then
                return { model = child, index = tonumber(num), info = dl_getSpecialBossInfo(child) }
            end
        end
        return nil
    end

    table.sort(candidates, function(a, b) return a.dist < b.dist end)
    local best = candidates[1]
    return { model = best.room, index = best.index, info = dl_getSpecialBossInfo(best.room) }
end

function dl_findSpecialBossRoomAfter(currentSeqIndex)
    if not activeSequence or currentSeqIndex > #activeSequence then return nil end

    local currentEntry = activeSequence[currentSeqIndex]
    if not currentEntry then return nil end

    local parentIndex = currentEntry.Index
    local hallway = dl_getSpecialBossHallwayForParent(parentIndex)
    if not hallway then return nil end

    local bossEntry = dl_findSpecialBossRoomFromHallway(hallway, parentIndex)
    if not bossEntry or not bossEntry.model then return nil end

    if processedSpecialBossRooms[bossEntry.model] then
        local state = processedSpecialBossRooms[bossEntry.model]
        local shouldFightPrespawned = isOn("AutoFightPrespawnedBoss")
        local shouldSummonNew = isOn("AutoSummonSpecialBoss")

        local prespawnedDone = state.prespawnedFought or not shouldFightPrespawned or not bossEntry.info.prespawned
        local summonedDone = state.summonedFought or not shouldSummonNew

        if prespawnedDone and summonedDone then
            return nil
        end
    end

    bossEntry.seqIndex = currentSeqIndex + 1
    return bossEntry
end

function dl_getSkullTotem()
    local dungeon = dl_getGeneratedDungeon()
    if not dungeon then return nil end
    return dungeon:FindFirstChild("Skull_Totem")
end

function dl_getSkullTotemPart(totem)
    if not totem then return nil end
    if totem:IsA("BasePart") then return totem end
    if totem.PrimaryPart then return totem.PrimaryPart end
    return totem:FindFirstChildWhichIsA("BasePart", true)
end

function dl_getSkullTotemPrompt(totem)
    if not totem then return nil end
    for _, desc in ipairs(totem:GetDescendants()) do
        if desc:IsA("ProximityPrompt") then
            return desc
        end
    end
    return nil
end

function dl_fireSkullTotemPrompt(totem)
    local prompt = dl_getSkullTotemPrompt(totem)
    if not prompt then return false end

    local success = false
    pcall(function()
        local originalHold = prompt.HoldDuration
        prompt.HoldDuration = 0
        prompt:InputHoldBegin()
        task.wait(0.1)
        prompt:InputHoldEnd()
        prompt.HoldDuration = originalHold
        success = true
    end)

    return success
end

function dl_getSummonConfirmUI()
    local pg = LocalPlayer:FindFirstChild("PlayerGui")
    local main = pg and pg:FindFirstChild("Main")
    local hud = main and main:FindFirstChild("HUD")
    local warning = hud and hud:FindFirstChild("Warning")
    if not warning or not dl_isGuiObjectVisible(warning) then return nil end

    local msgLabel = warning:FindFirstChild("Warning_Message")
    if not msgLabel or not msgLabel:IsA("TextLabel") then return nil end

    local text = msgLabel.Text or ""
    if text:lower():find("summon") then
        local confirmBtn = warning:FindFirstChild("Confirm")
        if confirmBtn and dl_isGuiObjectVisible(confirmBtn) then
            return confirmBtn, warning
        end
    end
    return nil
end

function dl_findPrespawnedBoss(roomModel, bossId)
    if not roomModel or not bossId then return nil end

    local dungeon = dl_getGeneratedDungeon()
    if not dungeon then return nil end

    local npcsFolder = dungeon:FindFirstChild("NPCs")
    if not npcsFolder then return nil end

    local roomCF, roomSize = dl_getRoomBounds(roomModel)
    if not roomCF then return nil end

    for _, npc in ipairs(npcsFolder:GetChildren()) do
        if npc.Name == bossId and dl_isNpcAlive(npc) then
            local part = dl_getEnemyPart(npc)
            if part and dl_isPointInRoomStrict(part.Position, roomCF, roomSize, 8) then
                return { model = npc, part = part }
            end
        end
    end

    return nil
end

function dl_findAnyBossInRoom(roomModel, bossId)
    if not roomModel or not bossId then return nil end

    local dungeon = dl_getGeneratedDungeon()
    if not dungeon then return nil end

    local npcsFolder = dungeon:FindFirstChild("NPCs")
    if not npcsFolder then return nil end

    local roomCF, roomSize = dl_getRoomBounds(roomModel)

    for _, npc in ipairs(npcsFolder:GetChildren()) do
        if npc.Name == bossId and dl_isNpcAlive(npc) then
            local part = dl_getEnemyPart(npc)
            if part then
                if roomCF and roomSize then
                    if dl_isPointInRoomStrict(part.Position, roomCF, roomSize, 12) then
                        return { model = npc, part = part }
                    end
                else
                    return { model = npc, part = part }
                end
            end
        end
    end

    return nil
end

-- ══════════════════════════════════════════
--   LOCKED ROOM ENGINE
-- ══════════════════════════════════════════

function dl_getLockedRoomsForParent(parentIndex)
    local results = {}
    local dungeon = dl_getGeneratedDungeon()
    if not dungeon then return results end

    for _, child in ipairs(dungeon:GetChildren()) do
        local num = child.Name:match("^Locked_(%d+)$")
        if num then
            local parentIdx = child:GetAttribute("ParentRoomIndex")
            if parentIdx == parentIndex or tonumber(parentIdx) == parentIndex then
                if not unlockedLockedRooms[child] then
                    table.insert(results, { model = child, index = tonumber(num) })
                end
            end
        end
    end

    table.sort(results, function(a, b) return a.index < b.index end)
    return results
end

function dl_getLockedRoomBounds(lockedRoomModel)
    if not lockedRoomModel or not lockedRoomModel.Parent then return nil, nil end

    local zone = lockedRoomModel:FindFirstChild("Zone")
    if zone and zone:IsA("BasePart") then
        return zone.CFrame, zone.Size
    end

    if lockedRoomModel:IsA("Model") then
        local cf, size = lockedRoomModel:GetBoundingBox()
        return cf, size
    end

    local firstPart = lockedRoomModel:FindFirstChildWhichIsA("BasePart", true)
    if firstPart then
        return firstPart.CFrame, Vector3.new(80, 40, 80)
    end

    return nil, nil
end

function dl_getKeyModelPart(lockedRoomModel)
    if not lockedRoomModel then return nil end
    local keyModel = lockedRoomModel:FindFirstChild("KeyModel")
    if not keyModel then return nil end

    if keyModel:IsA("BasePart") then return keyModel end
    if keyModel.PrimaryPart then return keyModel.PrimaryPart end
    return keyModel:FindFirstChildWhichIsA("BasePart", true)
end

function dl_getKeyModelPrompt(lockedRoomModel)
    if not lockedRoomModel then return nil end
    local keyModel = lockedRoomModel:FindFirstChild("KeyModel")
    if not keyModel then return nil end

    for _, desc in ipairs(keyModel:GetDescendants()) do
        if desc:IsA("ProximityPrompt") then
            return desc
        end
    end
    return nil
end

function dl_getChestsInLockedRoom(lockedRoomModel, lockedRoomIdx)
    local results = {}
    if not lockedRoomModel then return results end

    local dungeon = dl_getGeneratedDungeon()
    if not dungeon then return results end

    local lockedCF, lockedSize = dl_getLockedRoomBounds(lockedRoomModel)
    if not lockedCF then return results end

    for _, child in ipairs(dungeon:GetChildren()) do
        if (child.Name:match("^DungeonChest") or child.Name == "DungeonChest") and not collectedChests[child] then
            local isLockedRoomChest = child:GetAttribute("LockedRoom") == true

            if isLockedRoomChest then
                local part = child:IsA("BasePart") and child
                    or child.PrimaryPart
                    or child:FindFirstChildWhichIsA("BasePart", true)

                if part then
                    if dl_isPointInRoomStrict(part.Position, lockedCF, lockedSize, 4) then
                        table.insert(results, { model = child, part = part })
                    end
                end
            end
        end
    end

    return results
end

function dl_fireKeyModelPrompt(lockedRoomModel)
    local prompt = dl_getKeyModelPrompt(lockedRoomModel)
    if not prompt then return false end

    local success = false
    pcall(function()
        -- Prioritize executor prompt exploit function if available
        if fireproximityprompt then
            fireproximityprompt(prompt, 0)
            task.wait(0.05)
            success = true
        else
            local originalHold = prompt.HoldDuration
            prompt.HoldDuration = 0
            prompt:InputHoldBegin()
            task.wait(0.15)
            prompt:InputHoldEnd()
            prompt.HoldDuration = originalHold
            success = true
        end
    end)

    return success
end

-- ══════════════════════════════════════════
--   BLESSING ALTAR ENGINE
-- ══════════════════════════════════════════

function dl_getAllBlessingAltars()
    local results = {}
    local dungeon = dl_getGeneratedDungeon()
    if not dungeon then return results end

    for _, child in ipairs(dungeon:GetChildren()) do
        if child.Name == "Blessing_Altar" then
            table.insert(results, child)
        end
    end

    for _, child in ipairs(dungeon:GetChildren()) do
        if child.Name:match("^Room_%d+$") then
            for _, sub in ipairs(child:GetChildren()) do
                if sub.Name == "Blessing_Altar" then
                    table.insert(results, sub)
                end
            end
        end
    end

    return results
end

function dl_getAltarPrompt(altarModel)
    if not altarModel then return nil end
    for _, desc in ipairs(altarModel:GetDescendants()) do
        if desc:IsA("ProximityPrompt") then
            return desc
        end
    end
    return nil
end

function dl_getAltarPart(altarModel)
    if not altarModel then return nil end
    local bottom = altarModel:FindFirstChild("Altar", true)
    if bottom then
        local part = bottom:FindFirstChild("Bottom")
        if part and part:IsA("BasePart") then return part end
    end
    if altarModel:IsA("BasePart") then return altarModel end
    if altarModel.PrimaryPart then return altarModel.PrimaryPart end
    return altarModel:FindFirstChildWhichIsA("BasePart", true)
end

function dl_getAltarRoomIndex(altarModel)
    local parent = altarModel.Parent
    while parent do
        local num = parent.Name:match("^Room_(%d+)$")
        if num then return tonumber(num) end
        parent = parent.Parent
        if parent == workspace then break end
    end

    local altarPart = dl_getAltarPart(altarModel)
    if not altarPart then return nil end
    return dl_getRoomNumberForPoint(altarPart.Position)
end

function dl_findAltarAfterRoom(currentSeqIndex)
    if not activeSequence or #activeSequence == 0 then return nil end
    if currentSeqIndex >= #activeSequence then return nil end

    local currentRoomIdx = activeSequence[currentSeqIndex].Index
    local nextRoomIdx = activeSequence[currentSeqIndex + 1].Index

    local altars = dl_getAllBlessingAltars()
    if #altars == 0 then return nil end

    local minIdx = math.min(currentRoomIdx, nextRoomIdx)
    local maxIdx = math.max(currentRoomIdx, nextRoomIdx)

    for _, altar in ipairs(altars) do
        if not consumedAltars[altar] then
            local altarRoomIdx = dl_getAltarRoomIndex(altar)
            if altarRoomIdx then
                if altarRoomIdx > minIdx and altarRoomIdx < maxIdx then
                    return altar, altarRoomIdx
                end
            end
        end
    end

    return nil
end

function dl_firePromptForAltar(altar)
    local prompt = dl_getAltarPrompt(altar)
    if not prompt then return false end

    local success = false
    pcall(function()
        local originalHold = prompt.HoldDuration
        prompt.HoldDuration = 0
        prompt:InputHoldBegin()
        task.wait(0.1)
        prompt:InputHoldEnd()
        prompt.HoldDuration = originalHold
        success = true
    end)

    return success
end

-- ══════════════════════════════════════════
--   STRICT CHEST FINDER (BY ATTRIBUTE / GEOGRAPHIC)
-- ══════════════════════════════════════════

function dl_getChestsByRoomIndex(roomIndex)
    local results = {}
    local dungeon = dl_getGeneratedDungeon()
    if not dungeon then return results end

    local roomModel = dl_getRoomModel(roomIndex)
    local roomCF, roomSize = nil, nil
    if roomModel then
        roomCF, roomSize = dl_getRoomBounds(roomModel)
    end

    for _, child in ipairs(dungeon:GetChildren()) do
        if (child.Name:match("^DungeonChest") or child.Name == "DungeonChest") and not collectedChests[child] then
            local isLockedRoomChest = child:GetAttribute("LockedRoom") == true
            if not isLockedRoomChest then
                local rIdx = child:GetAttribute("RoomIndex")
                local part = child:IsA("BasePart") and child
                    or child.PrimaryPart
                    or child:FindFirstChildWhichIsA("BasePart", true)

                if part then
                    local belongs = false

                    if rIdx == roomIndex or tonumber(rIdx) == roomIndex then
                        belongs = true
                    elseif rIdx == nil then
                        if roomCF and roomSize and dl_isPointInRoomStrict(part.Position, roomCF, roomSize, 2) then
                            belongs = true
                        end
                    end

                    if belongs then
                        table.insert(results, { model = child, part = part })
                    end
                end
            end
        end
    end

    return results
end

function dl_getChestsNearAltar(altarPart)
    local results = {}
    if not altarPart then return results end

    local dungeon = dl_getGeneratedDungeon()
    if not dungeon then return results end

    local altarPos = altarPart.Position

    for _, child in ipairs(dungeon:GetChildren()) do
        if (child.Name:match("^DungeonChest") or child.Name == "DungeonChest") and not collectedChests[child] then
            local isLockedRoomChest = child:GetAttribute("LockedRoom") == true
            if not isLockedRoomChest then
                local part = child:IsA("BasePart") and child
                    or child.PrimaryPart
                    or child:FindFirstChildWhichIsA("BasePart", true)

                if part then
                    local dist = (part.Position - altarPos).Magnitude
                    if dist <= 40 then
                        table.insert(results, { model = child, part = part })
                    end
                end
            end
        end
    end

    return results
end

function dl_getChestsInCurrentRoom()
    if not activeRoomModel then return {} end
    local roomNum = tonumber(activeRoomModel.Name:match("^Room_(%d+)$"))
    if not roomNum then return {} end
    return dl_getChestsByRoomIndex(roomNum)
end

-- ══════════════════════════════════════════
--   LOOT ROOM DETECTION (STRICT PARENT LINK)
-- ══════════════════════════════════════════

function dl_getLootRoomsForParent(parentIndex)
    local results = {}
    local dungeon = dl_getGeneratedDungeon()
    if not dungeon then return results end

    for _, child in ipairs(dungeon:GetChildren()) do
        local num = child.Name:match("^Room_(%d+)$")
        if num then
            local isLoot = child:GetAttribute("IsLootRoom")
            local parentIdx = child:GetAttribute("ParentRoomIndex")
            if isLoot == true and (parentIdx == parentIndex or tonumber(parentIdx) == parentIndex) then
                table.insert(results, { model = child, index = tonumber(num) })
            end
        end
    end

    table.sort(results, function(a, b) return a.index < b.index end)
    return results
end

function dl_isLootRoom(roomNum)
    local roomModel = dl_getRoomModel(roomNum)
    if not roomModel then return false end
    return roomModel:GetAttribute("IsLootRoom") == true
end

-- ══════════════════════════════════════════
--   ROOM SEQUENCE EXTRACTOR
-- ══════════════════════════════════════════

function dl_extractRoomLayout()
    local extractedZones = nil
    local source = "None"

    if getgc then
        pcall(function()
            for _, obj in ipairs(getgc(true)) do
                if type(obj) == "table" then
                    if rawget(obj, "Zones") and rawget(obj, "ByIndex") and rawget(obj, "CurrentPos") ~= nil then
                        local zones = rawget(obj, "Zones")
                        if type(zones) == "table" and #zones > 0 then
                            extractedZones = {}
                            for idx, z in ipairs(zones) do
                                table.insert(extractedZones, {
                                    Order = idx,
                                    Index = tonumber(z.Index),
                                    IsBoss = z.IsBoss == true,
                                    Done = z.Done == true,
                                })
                            end
                            source = "Memory GC"
                            return
                        end
                    end
                end
            end
        end)
    end

    if not extractedZones then
        pcall(function()
            local rf = nil
            for _, desc in ipairs(ReplicatedStorage:GetDescendants()) do
                if desc:IsA("RemoteFunction") and desc.Name == "RequestZoneLayout" then
                    rf = desc
                    break
                end
            end

            if rf then
                local data = rf:InvokeServer()
                if type(data) == "table" and #data > 0 then
                    extractedZones = {}
                    for idx, z in ipairs(data) do
                        table.insert(extractedZones, {
                            Order = idx,
                            Index = tonumber(z.Index or z.RoomIndex),
                            IsBoss = z.IsBoss == true,
                            HasTreasure = z.HasTreasure == true,
                            Done = z.Completed == true
                        })
                    end
                    source = "RemoteFunction"
                end
            end
        end)
    end

    if not extractedZones then
        pcall(function()
            local Knit = require(ReplicatedStorage.Packages.Knit)
            local DRS = Knit.GetService("DungeonRunService")
            if DRS then
                local res = nil
                local req = DRS.RequestZoneLayout
                if type(req) == "function" then
                    local promise = DRS:RequestZoneLayout()
                    if promise and promise.await then
                        local ok, data = promise:await()
                        if ok and type(data) == "table" then res = data end
                    elseif promise and promise.andThen then
                        promise:andThen(function(data) res = data end)
                        task.wait(0.4)
                    end
                end

                if res and #res > 0 then
                    extractedZones = {}
                    for idx, z in ipairs(res) do
                        table.insert(extractedZones, {
                            Order = idx,
                            Index = tonumber(z.Index or z.RoomIndex),
                            IsBoss = z.IsBoss == true,
                            HasTreasure = z.HasTreasure == true,
                            Done = z.Completed == true
                        })
                    end
                    source = "Knit Service"
                end
            end
        end)
    end

    if not extractedZones then
        local dungeon = dl_getGeneratedDungeon()
        if dungeon then
            local roomNums = {}
            for _, child in ipairs(dungeon:GetChildren()) do
                local num = child.Name:match("^Room_(%d+)$")
                if num then
                    local n = tonumber(num)
                    local isLoot = child:GetAttribute("IsLootRoom") == true
                    if not isLoot then
                        table.insert(roomNums, n)
                    end
                end
            end
            table.sort(roomNums)
            if #roomNums > 0 then
                extractedZones = {}
                for idx, rNum in ipairs(roomNums) do
                    table.insert(extractedZones, {
                        Order = idx,
                        Index = rNum,
                        IsBoss = (idx == #roomNums),
                        Done = false
                    })
                end
                source = "Workspace Rooms"
            end
        end
    end

    if extractedZones and #extractedZones > 0 then
        SessionStats.extractionType = source
        return extractedZones
    end

    return nil
end

-- ══════════════════════════════════════════
--   ACCURATE UI VISIBILITY & ZONE STATE ENGINE
-- ══════════════════════════════════════════

function dl_isGuiObjectVisible(gui)
    if not gui then return false end
    if not gui:IsA("GuiObject") then return true end
    if not gui.Visible then return false end

    if gui:IsA("CanvasGroup") and gui.GroupTransparency > 0.3 then return false end

    local parent = gui.Parent
    while parent and parent:IsA("GuiObject") do
        if not parent.Visible then return false end
        if parent:IsA("CanvasGroup") and parent.GroupTransparency > 0.3 then return false end
        parent = parent.Parent
    end

    local size = gui.AbsoluteSize
    if size.X <= 0 or size.Y <= 0 then return false end

    return true
end

function dl_isZoneClearedUIActive()
    local ok, res = pcall(function()
        local pg = LocalPlayer:FindFirstChild("PlayerGui")
        local main = pg and pg:FindFirstChild("Main")
        local hud = main and main:FindFirstChild("HUD")
        local dc = hud and hud:FindFirstChild("Dungeon_Container")
        local nc = dc and dc:FindFirstChild("Notification_Canvas")
        if not nc or not dl_isGuiObjectVisible(nc) then return false end

        local zc = nc:FindFirstChild("Zone_Cleared")
        if not zc or not dl_isGuiObjectVisible(zc) then return false end

        local title = zc:FindFirstChild("Title")
        if title and title:IsA("TextLabel") and dl_isGuiObjectVisible(title) then
            if title.TextTransparency < 0.3 then
                local txt = title.Text:lower()
                if txt:find("zone cleared") then return true end
            end
        end
        return false
    end)
    return ok and res == true
end

function dl_isBossBarActive()
    local ok, res = pcall(function()
        local pg = LocalPlayer:FindFirstChild("PlayerGui")
        local main = pg and pg:FindFirstChild("Main")
        local hud = main and main:FindFirstChild("HUD")
        local dc = hud and hud:FindFirstChild("Dungeon_Container")
        local bossInfo = dc and dc:FindFirstChild("Boss_Info")
        if bossInfo and dl_isGuiObjectVisible(bossInfo) then
            local hpAmount = bossInfo:FindFirstChild("Health_Amount")
            if hpAmount and hpAmount:IsA("TextLabel") and hpAmount.Text ~= "" and hpAmount.Text ~= "0 / 0" then
                return true
            end
        end
        return false
    end)
    return ok and res == true
end

function dl_isSurviveActive()
    local ok, res = pcall(function()
        local pg = LocalPlayer:FindFirstChild("PlayerGui")
        local main = pg and pg:FindFirstChild("Main")
        local hud = main and main:FindFirstChild("HUD")
        local dc = hud and hud:FindFirstChild("Dungeon_Container")
        local tc = dc and dc:FindFirstChild("Timer_Canvas")
        if not tc or not dl_isGuiObjectVisible(tc) then return false end

        local survive = tc:FindFirstChild("Survive")
        if not survive or not dl_isGuiObjectVisible(survive) then return false end

        local title = survive:FindFirstChild("Title")
        if title and title:IsA("TextLabel") and dl_isGuiObjectVisible(title) then
            if title.TextTransparency < 0.3 and title.Text:upper():find("SURVIVE") then
                return true
            end
        end
        return false
    end)
    return ok and res == true
end

function dl_getSpecialRoomType()
    local ok, res = pcall(function()
        local pg = LocalPlayer:FindFirstChild("PlayerGui")
        local main = pg and pg:FindFirstChild("Main")
        local hud = main and main:FindFirstChild("HUD")
        local dc = hud and hud:FindFirstChild("Dungeon_Container")

        local nc = dc and dc:FindFirstChild("Notification_Canvas")
        if nc and dl_isGuiObjectVisible(nc) then
            local zc = nc:FindFirstChild("Zone_Cleared")
            if zc and dl_isGuiObjectVisible(zc) then
                local title = zc:FindFirstChild("Title")
                if title and title:IsA("TextLabel") and dl_isGuiObjectVisible(title) and title.TextTransparency < 0.3 then
                    local txt = title.Text:upper()
                    if txt:find("RUSH INBOUND") then return "RUSH INBOUND" end
                    if txt:find("MIGHT CHALLENGE") then return "MIGHT CHALLENGE" end
                end
            end
        end

        if dl_isSurviveActive() then return "SURVIVE" end
        return nil
    end)
    return ok and res or nil
end

function dl_isDungeonEndUIActive()
    local ok, res = pcall(function()
        local pg = LocalPlayer:FindFirstChild("PlayerGui")
        if not pg then return false end
        local main = pg:FindFirstChild("Main")
        local hud = main and main:FindFirstChild("HUD")
        local dc = hud and hud:FindFirstChild("Dungeon_Container")
        if not dc then return false end

        local completion = dc:FindFirstChild("Completion_Info")
        if not completion or not dl_isGuiObjectVisible(completion) then return false end

        local actionBtns = completion:FindFirstChild("Content") and completion.Content:FindFirstChild("ActionButtons")
        if actionBtns then
            local replay = actionBtns:FindFirstChild("ReplayButton")
            local retBtn = actionBtns:FindFirstChild("ReturnButton")
            if (replay and dl_isGuiObjectVisible(replay)) or (retBtn and dl_isGuiObjectVisible(retBtn)) then
                return true
            end
        end
        return false
    end)
    return ok and res == true
end

function dl_getEndlessCheckpointNumber()
    local ok, res = pcall(function()
        local pg = LocalPlayer:FindFirstChild("PlayerGui")
        if not pg then return nil end
        local main = pg:FindFirstChild("Main")
        local hud = main and main:FindFirstChild("HUD")
        if not hud then return nil end
        local warning = hud:FindFirstChild("Warning")
        if not warning or not dl_isGuiObjectVisible(warning) then return nil end

        local msgLabel = warning:FindFirstChild("Warning_Message")
        if not msgLabel or not msgLabel:IsA("TextLabel") then return nil end

        local text = msgLabel.Text
        if not text or text == "" then return nil end

        if text:lower():find("summon") then return nil end

        local n = text:match("[Cc]heckpoint%s+(%d+)%s+cleared")
        if n then return tonumber(n) end
        return nil
    end)
    return ok and res or nil
end

-- ══════════════════════════════════════════
--   PROGRESS READERS FOR GAMEMODES
-- ══════════════════════════════════════════

function dl_getBossRushCurrentRoom()
    local ok, res = pcall(function()
        local pg = LocalPlayer:FindFirstChild("PlayerGui")
        local main = pg and pg:FindFirstChild("Main")
        local hud = main and main:FindFirstChild("HUD")
        local dc = hud and hud:FindFirstChild("Dungeon_Container")
        local info = dc and dc:FindFirstChild("Info")
        local mob = info and info:FindFirstChild("Mob_Counter")
        local progressText = mob and mob:FindFirstChild("Progress_Text")
        if progressText and progressText:IsA("TextLabel") then
            local n = progressText.Text:match("%d+")
            return tonumber(n)
        end
        return nil
    end)
    return ok and res or nil
end

function dl_getBossRushLives()
    local ok, res = pcall(function()
        local pg = LocalPlayer:FindFirstChild("PlayerGui")
        local main = pg and pg:FindFirstChild("Main")
        local hud = main and main:FindFirstChild("HUD")
        local dc = hud and hud:FindFirstChild("Dungeon_Container")
        local info = dc and dc:FindFirstChild("Info")
        local livesFrame = info and info:FindFirstChild("Lives_Frame")
        local livesText = livesFrame and livesFrame:FindFirstChild("Lives_Text")
        if livesText and livesText:IsA("TextLabel") then
            local n = livesText.Text:match("%d+")
            return tonumber(n)
        end
        return nil
    end)
    return ok and res or nil
end

function dl_getChallengeCurrentWave()
    local ok, res = pcall(function()
        local pg = LocalPlayer:FindFirstChild("PlayerGui")
        local main = pg and pg:FindFirstChild("Main")
        local hud = main and main:FindFirstChild("HUD")
        local dc = hud and hud:FindFirstChild("Dungeon_Container")
        local canvas = dc and dc:FindFirstChild("Challenge_Canvas")
        local frame = canvas and canvas:FindFirstChild("Frame")
        local title = frame and frame:FindFirstChild("Title")
        if title and title:IsA("TextLabel") then
            local n = title.Text:match("%d+")
            return tonumber(n)
        end
        return nil
    end)
    return ok and res or nil
end

function dl_getRaidCurrentPhase()
    local ok, res = pcall(function()
        local pg = LocalPlayer:FindFirstChild("PlayerGui")
        local main = pg and pg:FindFirstChild("Main")
        local hud = main and main:FindFirstChild("HUD")
        local dc = hud and hud:FindFirstChild("Dungeon_Container")
        local tc = dc and dc:FindFirstChild("Timer_Canvas")
        local raid = tc and tc:FindFirstChild("Raid")
        local title = raid and raid:FindFirstChild("Title")
        if title and title:IsA("TextLabel") then
            local n = title.Text:match("%d+")
            return tonumber(n)
        end
        return nil
    end)
    return ok and res or nil
end

-- ══════════════════════════════════════════
--   ENEMY TARGETING & CRYSTAL SYSTEM
-- ══════════════════════════════════════════

function dl_getEnemyPart(npc)
    if not npc or not npc.Parent then return nil end
    if npc:IsA("BasePart") then return npc end
    if npc.PrimaryPart then return npc.PrimaryPart end

    -- Dedicated crystal hitbox prioritizing
    local crystalHitbox = npc:FindFirstChild("Crystal") or npc:FindFirstChild("Root")
    if crystalHitbox and crystalHitbox:IsA("BasePart") then return crystalHitbox end

    local hrp = npc:FindFirstChild("HumanoidRootPart", true)
    if hrp and hrp:IsA("BasePart") then return hrp end

    local torso = npc:FindFirstChild("Torso", true) or npc:FindFirstChild("UpperTorso", true)
    if torso and torso:IsA("BasePart") then return torso end

    local head = npc:FindFirstChild("Head", true)
    if head and head:IsA("BasePart") then return head end

    local descendants = npc:GetDescendants()
    for i = 1, #descendants do
        local desc = descendants[i]
        if desc:IsA("BasePart") then
            return desc
        end
    end

    return nil
end

function dl_isNpcAlive(npc)
    if not npc or not npc.Parent then return false end
    if npc.Name:match("^DungeonChest") or npc.Name == "DungeonChest" then return false end

    -- Crystal Specific Alive Validation
    if npc.Name == "Damage_Crystal" or npc.Name:find("Crystal") ~= nil then
        local hp = npc:GetAttribute("Health") or npc:GetAttribute("HealthOverride")
        if hp and hp <= 0 then return false end
        local isDead = npc:GetAttribute("Dead") or npc:GetAttribute("IsDead")
        if isDead == true then return false end
        local hum = npc:FindFirstChildOfClass("Humanoid")
        if hum and hum.Health <= 0 and hum.MaxHealth > 0 then return false end
        return true
    end

    local state = npc:GetAttribute("State")
    if state == "Dead" or state == "Dying" or state == "Despawning" then return false end

    local hum = npc:FindFirstChildOfClass("Humanoid")
    if hum and (hum.Health <= 0 or hum:GetState() == Enum.HumanoidStateType.Dead) then return false end

    local hv = npc:FindFirstChild("Health", true)
    if hv and hv:IsA("NumberValue") and hv.Value <= 0 then return false end

    local part = dl_getEnemyPart(npc)
    return (part ~= nil and part.Parent ~= nil)
end

function dl_getEnemiesInRoom(roomCF, roomSize)
    local results = {}
    if not roomCF or not roomSize then return results end

    local dungeon = dl_getGeneratedDungeon()
    if not dungeon then return results end

    local npcsFolder = dungeon:FindFirstChild("NPCs")
    if not npcsFolder then return results end

    local npcs = npcsFolder:GetChildren()
    for i = 1, #npcs do
        local npc = npcs[i]
        if dl_isNpcAlive(npc) then
            local part = dl_getEnemyPart(npc)
            if part and dl_isPointInRoomStrict(part.Position, roomCF, roomSize, 2) then
                table.insert(results, { model = npc, part = part })
            end
        end
    end

    return results
end

function dl_getAllActiveEnemies()
    local results = {}
    local folders, mode = dl_getActiveNpcFolders()

    for _, folder in ipairs(folders) do
        local npcs = folder:GetChildren()
        for i = 1, #npcs do
            local npc = npcs[i]
            if dl_isNpcAlive(npc) then
                local part = dl_getEnemyPart(npc)
                if part then
                    table.insert(results, { model = npc, part = part })
                end
            end
        end
    end

    return results, mode
end

function dl_getEnemiesInCurrentRoom()
    local mode = getGameMode()

    if mode == "BossRush" or mode == "Challenge" or mode == "Raid" then
        local enemies, _ = dl_getAllActiveEnemies()
        return enemies
    end

    if isFarmingSpecialBoss and cachedSpecialBossCF and cachedSpecialBossSize then
        return dl_getEnemiesInRoom(cachedSpecialBossCF, cachedSpecialBossSize)
    end

    if isFarmingLockedRoom and cachedLockedRoomCF and cachedLockedRoomSize then
        return dl_getEnemiesInRoom(cachedLockedRoomCF, cachedLockedRoomSize)
    end

    if isFarmingLootRoom and cachedLootRoomCF and cachedLootRoomSize then
        return dl_getEnemiesInRoom(cachedLootRoomCF, cachedLootRoomSize)
    end

    -- BOSS ROOM OVERRIDE: In the final room, grab all alive enemies in the dungeon
    local isFinalRoom = (#activeSequence > 0 and activeSequenceIndex >= #activeSequence)
    if isFinalRoom or dl_isBossBarActive() then
        local allEnemies, _ = dl_getAllActiveEnemies()
        if #allEnemies > 0 then
            return allEnemies
        end
    end

    local roomModel = activeRoomModel

    if not roomModel then
        local hrp = dl_getHRP()
        if hrp then
            local roomNum = dl_getRoomNumberForPoint(hrp.Position)
            if roomNum then
                roomModel = dl_getRoomModel(roomNum)
            end
        end
    end

    if not roomModel then return {} end

    local cf, size
    if roomModel == activeRoomModel and cachedRoomCF then
        cf, size = cachedRoomCF, cachedRoomSize
    else
        cf, size = dl_getRoomBounds(roomModel)
    end

    -- Increased padding from 2 to 40 so jumping/charging mobs don't lose targeting
    return dl_getEnemiesInRoom(cf, size)
end

-- ══════════════════════════════════════════
--   PRIORITY TARGET CLASSIFIER
-- ══════════════════════════════════════════

function getTargetPriorityValue(npcModel, nameLower, prio1, prio2)
    -- Absolute Priority #1: Crystal
    local isCrystal = (npcModel.Name == "Damage_Crystal" or npcModel.Name:find("Crystal") ~= nil)
    if isCrystal then
        return 1
    end

    local archetype = "None"
    if ARCHER_NAMES[nameLower] then
        archetype = "Archer"
    elseif HEALER_NAMES[nameLower] then
        archetype = "Healer"
    end

    if prio1 ~= "None" and archetype == prio1 then
        return 2
    end
    if prio2 ~= "None" and archetype == prio2 then
        return 3
    end

    local isBoss = (npcModel:GetAttribute("IsBoss") == true or npcModel.Name == "Dark Professor")
    if isBoss then
        return 4
    end

    return 5 -- Normal mobs fallback
end

function dl_pickTarget()
    local mode = getGameMode()
    local p1 = Options.MobPriority1 and Options.MobPriority1.Value or "None"
    local p2 = Options.MobPriority2 and Options.MobPriority2.Value or "None"

    if dlf_currentTarget and dl_isNpcAlive(dlf_currentTarget.model) and dlf_currentTarget.part and dlf_currentTarget.part.Parent then
        local nameLower = dlf_currentTarget.model.Name:lower()
        local currentPrioVal = getTargetPriorityValue(dlf_currentTarget.model, nameLower, p1, p2)

        -- Instant target swapping if a higher-priority unit enters combat inside active zone
        local enemies = dl_getEnemiesInCurrentRoom()
        local hasBetterTarget = false
        for _, e in ipairs(enemies) do
            local eName = e.model.Name:lower()
            local ePrioVal = getTargetPriorityValue(e.model, eName, p1, p2)
            if ePrioVal < currentPrioVal then
                hasBetterTarget = true
                break
            end
        end

        if not hasBetterTarget then
            if mode == "BossRush" or mode == "Challenge" or mode == "Raid" then
                local folders = dl_getActiveNpcFolders()
                for _, f in ipairs(folders) do
                    if dlf_currentTarget.model:IsDescendantOf(f) then
                        if not (dl_mini_lava_active and dlf_currentTarget.model.Name == "Dark Professor") then
                            return dlf_currentTarget
                        end
                    end
                end
                dlf_currentTarget = nil
            else
                local activeCF, activeSize
                if isFarmingSpecialBoss and cachedSpecialBossCF then
                    activeCF, activeSize = cachedSpecialBossCF, cachedSpecialBossSize
                elseif isFarmingLockedRoom and cachedLockedRoomCF then
                    activeCF, activeSize = cachedLockedRoomCF, cachedLockedRoomSize
                elseif isFarmingLootRoom and cachedLootRoomCF then
                    activeCF, activeSize = cachedLootRoomCF, cachedLootRoomSize
                else
                    activeCF, activeSize = cachedRoomCF, cachedRoomSize
                end

                if activeCF and activeSize then
                    if dl_isPointInRoomStrict(dlf_currentTarget.part.Position, activeCF, activeSize, 4) then
                        if dl_mini_lava_active and dlf_currentTarget.model and dlf_currentTarget.model.Name == "Dark Professor" then
                            dlf_currentTarget = nil
                        else
                            return dlf_currentTarget
                        end
                    end
                end
            end
        else
            dlf_currentTarget = nil
        end
    end

    dlf_currentTarget = nil
    local hrp = dl_getHRP()
    if not hrp then return nil end

    local enemies = dl_getEnemiesInCurrentRoom()
    if #enemies == 0 then return nil end

    local myPos = hrp.Position
    local candidates = {}

    for i = 1, #enemies do
        local e = enemies[i]

        if dl_mini_lava_active and e.model and e.model.Name == "Dark Professor" then
            continue
        end

        local nameLower = e.model.Name:lower()
        local prioValue = getTargetPriorityValue(e.model, nameLower, p1, p2)
        local dist = (e.part.Position - myPos).Magnitude

        table.insert(candidates, {
            enemy = e,
            prio  = prioValue,
            dist  = dist
        })
    end

    if #candidates == 0 then return nil end

    table.sort(candidates, function(a, b)
        if a.prio ~= b.prio then
            return a.prio < b.prio
        end
        return a.dist < b.dist
    end)

    dlf_currentTarget = candidates[1].enemy
    return dlf_currentTarget
end

-- ══════════════════════════════════════════
--   MULTI-CRYSTAL CLEAVE ALIGNMENT GEOMETRY
-- ══════════════════════════════════════════

function calculateCrystalTargetCFrame(targetEnemy, targetPart)
    local enemyPos = targetPart.Position
    local rawPos = enemyPos
    local targetLookPos = enemyPos

    local isTargetCrystal = targetEnemy and (targetEnemy.Name == "Damage_Crystal" or targetEnemy.Name:find("Crystal") ~= nil)

    if isTargetCrystal then
        local neighborPart = nil
        local allEnemies = dl_getEnemiesInCurrentRoom()
        local minNeighborDist = math.huge

        -- Scan active room to locate neighbor crystal
        for _, e in ipairs(allEnemies) do
            if e.model ~= targetEnemy and (e.model.Name == "Damage_Crystal" or e.model.Name:find("Crystal") ~= nil) then
                local part = e.part
                if part then
                    local dist = (part.Position - enemyPos).Magnitude
                    if dist < minNeighborDist then
                        minNeighborDist = dist
                        neighborPart = part
                    end
                end
            end
        end

        if neighborPart then
            -- Align behind current crystal targeting next crystal directly to facilitate double hit pierce logic
            local dirToNeighbor = (neighborPart.Position - enemyPos).Unit
            rawPos = enemyPos - (dirToNeighbor * 3.5) + Vector3.new(0, 1.0, 0)
            targetLookPos = neighborPart.Position
        else
            -- Position statically within direct melee attack vector if single crystal remains
            local lookDir = targetPart.CFrame.LookVector
            if lookDir.Magnitude < 0.1 then lookDir = Vector3.new(0, 0, 1) end
            rawPos = enemyPos + (lookDir * 4.5) + Vector3.new(0, 1.0, 0)
            targetLookPos = enemyPos
        end
    end

    return CFrame.new(rawPos, targetLookPos)
end

-- ══════════════════════════════════════════
--   MOVEMENT & PHYSICS ENGINE
-- ══════════════════════════════════════════

function dl_cancelTween()
    if dlf_activeTween then
        pcall(function() dlf_activeTween:Cancel() end)
        dlf_activeTween = nil
    end
end

function dl_resetPhysics()
    local hrp = dl_getHRP()
    if not hrp then return end
    hrp.Velocity = Vector3.zero
    hrp.RotVelocity = Vector3.zero
    pcall(function() hrp.AssemblyLinearVelocity = Vector3.zero end)
    pcall(function() hrp.AssemblyAngularVelocity = Vector3.zero end)
    local hum = getHumanoid()
    if hum then hum:ChangeState(Enum.HumanoidStateType.GettingUp) end
end

function dl_directTeleport(targetCF)
    local hrp = dl_getHRP()
    if not hrp then return end
    dl_cancelTween()
    hrp.CFrame = targetCF
    dl_resetPhysics()
end

function dl_tweenTo(targetCF, speedOverride)
    local hrp = dl_getHRP()
    if not hrp then return end
    local dist = (targetCF.Position - hrp.Position).Magnitude
    if dist < 1.5 then return end
    dl_cancelTween()
    local speed = speedOverride or dl_tween_speed
    local t = math.max(0.05, dist / speed)
    local info = TweenInfo.new(t, Enum.EasingStyle.Linear)
    local ok, tween = pcall(function()
        return TweenService:Create(hrp, info, { CFrame = targetCF })
    end)
    if not ok or not tween then return end
    dlf_activeTween = tween
    tween.Completed:Connect(function(state)
        if state == Enum.PlaybackState.Completed then dl_resetPhysics() end
        if dlf_activeTween == tween then dlf_activeTween = nil end
    end)
    tween:Play()
    return tween
end

function dl_moveTo(targetCF)
    if dl_farm_method == "Teleport" then
        dl_directTeleport(targetCF)
    else
        dl_tweenTo(targetCF)
    end
end

function dl_dropToGround()
    local hrp = dl_getHRP()
    if not hrp then return end
    local rayParams = RaycastParams.new()
    rayParams.FilterType = Enum.RaycastFilterType.Exclude
    rayParams.FilterDescendantsInstances = { LocalPlayer.Character }

    local result = workspace:Raycast(hrp.Position, Vector3.new(0, -120, 0), rayParams)
    if result then
        hrp.CFrame = CFrame.new(result.Position + Vector3.new(0, 3, 0), hrp.CFrame.LookVector)
        dl_resetPhysics()
        task.wait(0.05)
    end
end

function dl_forceCollectChest(chestData)
    if not chestData or not chestData.part or not chestData.part.Parent then return false end

    local hrp = dl_getHRP()
    if not hrp then return false end

    isCollectingChest = true
    dl_cancelTween()

    dl_dropToGround()
    task.wait(0.05)

    local targetPos = chestData.part.Position
    local targetCF = CFrame.new(targetPos, targetPos + chestData.part.CFrame.LookVector)
    local distance = (targetPos - hrp.Position).Magnitude
    local tweenTime = math.max(0.15, distance / 50)

    hrp.Velocity = Vector3.zero
    hrp.RotVelocity = Vector3.zero

    local tweenInfo = TweenInfo.new(tweenTime, Enum.EasingStyle.Linear)
    local tween = TweenService:Create(hrp, tweenInfo, { CFrame = targetCF })

    local completed = false
    local conn
    conn = tween.Completed:Connect(function()
        completed = true
        if conn then conn:Disconnect() end
    end)

    tween:Play()

    local startTime = os.clock()
    while not completed and (os.clock() - startTime < tweenTime + 3) and not Library.Unloaded do
        task.wait(0.02)
    end

    hrp.Velocity = Vector3.zero
    hrp.RotVelocity = Vector3.zero
    task.wait(0.5)

    if chestData.model then
        collectedChests[chestData.model] = true
    end

    isCollectingChest = false
    return true
end

function dl_processAltarSequence(altar)
    if not altar or not altar.Parent then return end
    if consumedAltars[altar] then return end

    local hrp = dl_getHRP()
    if not hrp then return end

    local altarPart = dl_getAltarPart(altar)
    if not altarPart then return end

    isInteractingAltar = true
    dl_cancelTween()

    SessionStats.roomStateText = "🔮 Traveling to Altar..."

    local altarPos = altarPart.Position
    local altarCF = CFrame.new(altarPos + Vector3.new(0, 4, 0), altarPos)
    dl_directTeleport(altarCF)
    task.wait(0.3)

    dl_dropToGround()
    task.wait(0.2)

    SessionStats.roomStateText = "🔮 Interacting with Altar..."

    local promptFired = false
    for attempt = 1, 5 do
        if dl_firePromptForAltar(altar) then
            promptFired = true
            break
        end
        task.wait(0.15)
    end

    if promptFired then
        SessionStats.altarsInteracted = SessionStats.altarsInteracted + 1
        SessionStats.roomStateText = "🔮 Awaiting Blessing Choice..."

        local waitStart = os.clock()
        while (os.clock() - waitStart < 8) and not Library.Unloaded do
            local pGui = LocalPlayer:FindFirstChild("PlayerGui")
            local hud = pGui and pGui:FindFirstChild("Main") and pGui.Main:FindFirstChild("HUD")
            local boostGui = hud and hud:FindFirstChild("Boost_Selection")

            if boostGui and dl_isGuiObjectVisible(boostGui) then
                local closeStart = os.clock()
                while (os.clock() - closeStart < 5) and not Library.Unloaded do
                    if not dl_isGuiObjectVisible(boostGui) then
                        break
                    end
                    task.wait(0.1)
                end
                break
            end
            task.wait(0.1)
        end
    end

    consumedAltars[altar] = true
    SessionStats.roomStateText = "🔮 Checking altar room for chests..."
    task.wait(0.2)
    local altarChests = dl_getChestsNearAltar(altarPart)

    isInteractingAltar = false

    if #altarChests > 0 and isOn("AutoCollectChests") then
        for i, cData in ipairs(altarChests) do
            if cData.part and cData.part.Parent then
                SessionStats.roomStateText = string.format("🎁 Altar Chest %d/%d...", i, #altarChests)
                dl_forceCollectChest(cData)
            end
        end
    end

    isInteractingAltar = false
end

-- Setup dynamic Remote Event Hooking for Match completions
task.spawn(function()
    for _, svc in ipairs(KnitServices:GetChildren()) do
        local reFolder = svc:FindFirstChild("RE")
        if reFolder then
            local dcEvent = reFolder:FindFirstChild("DungeonComplete")
            if dcEvent and dcEvent:IsA("RemoteEvent") then
                dcEvent.OnClientEvent:Connect(function(data)
                    if type(data) == "table" then
                        if not data.Source then
                            if svc.Name:find("BossRush") then data.Source = "BossRush"
                            elseif svc.Name:find("Challenge") then data.Source = "Challenge"
                            elseif svc.Name:find("Raid") then data.Source = "Raid"
                            else data.Source = "Dungeon" end
                        end
                        -- Sync with fallback UI indicators
                        data.RoomsCleared = data.RoomsCleared or SessionStats.roomsCleared
                        data.MobsKilled = data.MobsKilled or SessionStats.enemiesDefeated
                        
                        task.spawn(function()
                            sendDungeonRemoteWebhook(data)
                        end)
                    end
                end)
            end
        end
    end
end)

function dlf_stopMovement()
    if dlf_moveConnection then
        dlf_moveConnection:Disconnect()
        dlf_moveConnection = nil
    end
    dl_cancelTween()
    dlf_currentTarget = nil
    dlf_orbitAngle    = 0
end

function dlf_startMovement()
    if dlf_moveConnection then return end
    dlf_orbitAngle = 0

    dlf_moveConnection = RunService.Stepped:Connect(function(_, dt)
        if Library.Unloaded or not isOn("AutoFarm") then dlf_stopMovement(); return end
        -- Skip completely if player is currently in the Lobby
        if getGameMode() == "Lobby" then return end
        if dl_farm_paused or dungeonFullyCompleted or isCollectingChest or isInteractingAltar or isUnlockingRoom or isSummoningBoss or endlessContinuePending or isCharacterDead() then return end

        local hrp = dl_getHRP()
        if not hrp then return end

        hrp.AssemblyLinearVelocity = Vector3.zero

        local target = dl_pickTarget()
        local targetCF = nil

        local isDodgeRepositionActive = (dl_mini_lava_active and dl_dodge_target_pos and tick() < dl_dodge_lock_until)

        if isDodgeRepositionActive then
            local lookAtPos = (target and target.part) and target.part.Position or (dl_dodge_target_pos + hrp.CFrame.LookVector * 10)
            targetCF = CFrame.new(dl_dodge_target_pos, Vector3.new(lookAtPos.X, dl_dodge_target_pos.Y, lookAtPos.Z))
        elseif target and target.part then
            local isCrystal = (target.model.Name == "Damage_Crystal" or target.model.Name:find("Crystal") ~= nil)

            if isCrystal then
                -- Perform cleave vector alignment if targeting a crystal
                targetCF = calculateCrystalTargetCFrame(target.model, target.part)
            else
                local enemyPos = target.part.Position

                if dl_farm_mode == "Above Head" then
                    local pos = enemyPos + Vector3.new(0, dl_farm_height, 0)
                    targetCF = CFrame.new(pos, enemyPos)
                elseif dl_farm_mode == "Orbiting" then
                    dlf_orbitAngle = (dlf_orbitAngle + dl_farm_orbit_speed * dt) % (math.pi * 2)
                    local pos = enemyPos + Vector3.new(
                        math.cos(dlf_orbitAngle) * dl_farm_orbit_radius,
                        dl_farm_height,
                        math.sin(dlf_orbitAngle) * dl_farm_orbit_radius
                    )
                    targetCF = CFrame.new(pos, enemyPos)
                elseif dl_farm_mode == "Behind" then
                    local backVec = target.part.CFrame.LookVector * -6
                    targetCF = CFrame.new(enemyPos + backVec + Vector3.new(0, 2, 0), enemyPos)
                elseif dl_farm_mode == "Same Level" then
                    targetCF = CFrame.new(enemyPos + Vector3.new(0, 0, 5), enemyPos)
                elseif dl_farm_mode == "Under" then
                    local pos = enemyPos - Vector3.new(0, dl_farm_height, 0)
                    targetCF = CFrame.new(pos, enemyPos)
                end
            end
        else
            local mode = getGameMode()
            local hoverCF = nil

            if mode == "Dungeon" then
                if isFarmingSpecialBoss and cachedSpecialBossCF then
                    hoverCF = cachedSpecialBossCF
                elseif isFarmingLockedRoom and cachedLockedRoomCF then
                    hoverCF = cachedLockedRoomCF
                elseif isFarmingLootRoom and cachedLootRoomCF then
                    hoverCF = cachedLootRoomCF
                elseif activeRoomModel then
                    if not cachedRoomCF then
                        cachedRoomCF, cachedRoomSize = dl_getRoomBounds(activeRoomModel)
                    end
                    hoverCF = cachedRoomCF
                end

                if hoverCF then
                    local hoverPos = hoverCF.Position + Vector3.new(0, math.max(2, dl_farm_height - 6), 0)
                    targetCF = CFrame.new(hoverPos, hoverCF.Position)
                end
            end
        end

        if targetCF then
            dl_moveTo(targetCF)
        end
    end)
end

-- ══════════════════════════════════════════
--   WATCHDOGS & SEQUENCE RE-EXTRACT ENGINE
-- ══════════════════════════════════════════

function getDepthText()
    local pg = LocalPlayer:FindFirstChild("PlayerGui")
    local main = pg and pg:FindFirstChild("Main")
    local hud = main and main:FindFirstChild("HUD")
    local dc = hud and hud:FindFirstChild("Dungeon_Container")
    local info = dc and dc:FindFirstChild("Info")
    local depth = info and info:FindFirstChild("Depth")
    local tl = depth and depth:FindFirstChild("TextLabel")
    return tl and tl.Text or ""
end

function forceResetAndReextract(reason)
    activeSequence = {}
    activeSequenceIndex = 1
    activeRoomModel = nil
    cachedRoomCF = nil
    cachedRoomSize = nil
    lootRoomQueue = {}
    lootRoomIndex = 0
    currentLootRoomModel = nil
    cachedLootRoomCF = nil
    cachedLootRoomSize = nil
    isFarmingLootRoom = false
    isFarmingLockedRoom = false
    currentLockedRoomModel = nil
    cachedLockedRoomCF = nil
    cachedLockedRoomSize = nil
    isUnlockingRoom = false
    isFarmingSpecialBoss = false
    currentSpecialBossRoom = nil
    cachedSpecialBossCF = nil
    cachedSpecialBossSize = nil
    isSummoningBoss = false
    dungeonFullyCompleted = false
    zoneClearedConsumed = false
    isCollectingChest = false
    isInteractingAltar = false
    endlessContinuePending = false
    endlessContinueUntil = 0
    table.clear(consumedAltars)
    table.clear(collectedChests)
    table.clear(unlockedLockedRooms)
    table.clear(processedSpecialBossRooms)
    dlf_currentTarget = nil
    dl_cancelTween()

    SessionStats.roomStateText = string.format("🔄 [%s] Extracting Layout...", tostring(reason))

    local extracted = nil
    for attempt = 1, 12 do
        extracted = dl_extractRoomLayout()
        if extracted and #extracted > 0 then break end
        task.wait(0.15)
    end

    if extracted and #extracted > 0 then
        activeSequence = extracted
        activeSequenceIndex = 1

        local firstRoom = dl_getRoomModel(extracted[1].Index)
        if firstRoom then
            local cf, _ = dl_getRoomBounds(firstRoom)
            if cf then
                dl_directTeleport(CFrame.new(cf.Position + Vector3.new(0, dl_farm_height - 6, 0), cf.Position))
                SessionStats.roomStateText = "🚀 Farming Started!"
            end
        end
    else
        SessionStats.roomStateText = "❌ Extract Failed! Use manual button."
    end
end

task.spawn(function()
    local knownDungeonName = nil
    local knownDepth = ""

    while not Library.Unloaded do
        task.wait(0.15)

        local dungeon = dl_getGeneratedDungeon()
        local currentDepth = getDepthText()

        local dungeonChanged = dungeon and (knownDungeonName ~= dungeon.Name)
        local depthChanged = dungeon and (currentDepth ~= "" and knownDepth ~= currentDepth and knownDepth ~= "")

        if dungeonChanged or depthChanged then
            local reason = dungeonChanged and "New Area Detected" or "Depth Changed to " .. currentDepth

            if dungeon then
                knownDungeonName = dungeon.Name
                activeDungeonId = dungeon.Name
            end
            knownDepth = currentDepth

            forceResetAndReextract(reason)
        elseif dungeon then
            if not knownDungeonName then knownDungeonName = dungeon.Name end
            if knownDepth == "" then knownDepth = currentDepth end
        else
            knownDungeonName = nil
            knownDepth = ""
        end
    end
end)

function isCharacterDead()
    local char = LocalPlayer.Character
    if not char then return true end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum then return true end
    if hum.Health <= 0 or hum:GetState() == Enum.HumanoidStateType.Dead then
        return true
    end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return true end
    return false
end

local lastCheckpointActionTime = 0
task.spawn(function()
    while not Library.Unloaded do
        task.wait(0.5)

        if endlessContinuePending then
            if os.clock() > endlessContinueUntil + 18 then
                endlessContinuePending = false
                endlessContinueUntil = 0
            end
        else
            if not isCharacterDead() then
                local checkpointNum = dl_getEndlessCheckpointNumber()
                if checkpointNum and (tick() - lastCheckpointActionTime) > 4.5 then
                    local extractAt = getNumber("EndlessExtractCheckpoint", 0)
                    SessionStats.endlessCheckpoint = checkpointNum

                    if extractAt == 0 or checkpointNum < extractAt then
                        endlessContinuePending = true
                        endlessContinueUntil = os.clock()
                        SessionStats.roomStateText = "⏸️ Level Clear! Preparing transition..."

                        dl_cancelTween()
                        dlf_currentTarget = nil

                        -- Grounded loading buffer delay
                        task.wait(2.0)

                        if endlessContinuePending and not isCharacterDead() then
                            SessionStats.roomStateText = "⏸️ Submitting Continuous Transition Choice..."
                            pcall(function() dl_SubmitEndless:InvokeServer(true) end)
                            lastCheckpointActionTime = tick()
                        end
                    else
                        pcall(function() dl_SubmitEndless:InvokeServer(false) end)
                        lastCheckpointActionTime = tick()
                    end
                end
            end
        end
    end
end)

-- ══════════════════════════════════════════
--   LOOT ROOM PROCESSING FUNCTION
-- ══════════════════════════════════════════

function dl_processLootRoom(lootRoomEntry)
    if not lootRoomEntry or not lootRoomEntry.model or not lootRoomEntry.model.Parent then return end

    local lootModel = lootRoomEntry.model
    local lootIdx = lootRoomEntry.index

    isFarmingLootRoom = true
    currentLootRoomModel = lootModel
    cachedLootRoomCF, cachedLootRoomSize = dl_getRoomBounds(lootModel)
    dlf_currentTarget = nil

    if not cachedLootRoomCF then
        isFarmingLootRoom = false
        currentLootRoomModel = nil
        return
    end

    SessionStats.roomStateText = string.format("💎 Entering Loot Room %d...", lootIdx)

    dl_cancelTween()
    local enterPos = cachedLootRoomCF.Position + Vector3.new(0, dl_farm_height - 6, 0)
    dl_directTeleport(CFrame.new(enterPos, cachedLootRoomCF.Position))
    task.wait(0.25)

    local scanStart = os.clock()
    local hasEnemies = false
    while (os.clock() - scanStart < 1.5) and isOn("AutoFarm") and not Library.Unloaded do
        local mobs = dl_getEnemiesInRoom(cachedLootRoomCF, cachedLootRoomSize)
        if #mobs > 0 then
            hasEnemies = true
            break
        end
        task.wait(0.1)
    end

    if hasEnemies then
        SessionStats.roomStateText = string.format("💎 Farming Loot Room %d Mobs...", lootIdx)
        local zeroStreak = 0
        while isOn("AutoFarm") and not Library.Unloaded do
            local mobs = dl_getEnemiesInRoom(cachedLootRoomCF, cachedLootRoomSize)
            if #mobs == 0 then
                zeroStreak = zeroStreak + 0.1
                if zeroStreak >= 1.2 then break end
            else
                zeroStreak = 0
                SessionStats.roomStateText = string.format("💎 Loot Room %d: %d mobs alive", lootIdx, #mobs)
            end
            task.wait(0.1)
        end
    end

    if isOn("AutoCollectChests") then
        task.wait(0.3)
        local lrChests = dl_getChestsByRoomIndex(lootIdx)
        if #lrChests > 0 then
            for i, cData in ipairs(lrChests) do
                if cData.part and cData.part.Parent then
                    SessionStats.roomStateText = string.format("💎 Loot Room %d Chest %d/%d...", lootIdx, i, #lrChests)
                    dl_forceCollectChest(cData)
                end
            end
        end
    end

    SessionStats.lootRoomsCleared = SessionStats.lootRoomsCleared + 1

    isFarmingLootRoom = false
    currentLootRoomModel = nil
    cachedLootRoomCF = nil
    cachedLootRoomSize = nil
    dlf_currentTarget = nil
end

-- ══════════════════════════════════════════
--   LOCKED ROOM PROCESSING FUNCTION
-- ══════════════════════════════════════════

function dl_processLockedRoom(lockedRoomEntry)
    if not lockedRoomEntry or not lockedRoomEntry.model or not lockedRoomEntry.model.Parent then return end

    local lockedModel = lockedRoomEntry.model
    local lockedIdx = lockedRoomEntry.index

    isUnlockingRoom = true
    dl_cancelTween()
    dlf_currentTarget = nil

    SessionStats.roomStateText = string.format("🔓 Approaching Locked Room %d KeyModel...", lockedIdx)

    local keyPart = dl_getKeyModelPart(lockedModel)
    if not keyPart then
        SessionStats.roomStateText = string.format("🔓 Locked Room %d: No KeyModel!", lockedIdx)
        isUnlockingRoom = false
        return
    end

    local keyPos = keyPart.Position
    -- Teleport directly next to/on the key hitbox (within standard prompt activation bounds)
    local keyCF = CFrame.new(keyPos + Vector3.new(0, 1.2, 0.5), keyPos)
    dl_directTeleport(keyCF)
    task.wait(0.25)

    SessionStats.roomStateText = string.format("🔓 Unlocking Room %d...", lockedIdx)
    local promptFired = false
    for attempt = 1, 8 do
        -- Constantly snap position directly to prompt origin to avoid drift failures
        local hrp = dl_getHRP()
        if hrp and keyPart and keyPart.Parent then
            hrp.CFrame = CFrame.new(keyPart.Position + Vector3.new(0, 1.2, 0.2), keyPart.Position)
            hrp.Velocity = Vector3.zero
        end
        if dl_fireKeyModelPrompt(lockedModel) then
            promptFired = true
            break
        end
        task.wait(0.15)
    end

    if not promptFired then
        SessionStats.roomStateText = string.format("🔓 Locked Room %d: Prompt failed!", lockedIdx)
        isUnlockingRoom = false
        unlockedLockedRooms[lockedModel] = true
        return
    end

    task.wait(0.4)

    unlockedLockedRooms[lockedModel] = true
    SessionStats.lockedRoomsUnlocked = SessionStats.lockedRoomsUnlocked + 1

    isFarmingLockedRoom = true
    currentLockedRoomModel = lockedModel
    cachedLockedRoomCF, cachedLockedRoomSize = dl_getLockedRoomBounds(lockedModel)

    if not cachedLockedRoomCF then
        SessionStats.roomStateText = string.format("🔓 Locked Room %d: Cannot get bounds!", lockedIdx)
        isFarmingLockedRoom = false
        currentLockedRoomModel = nil
        isUnlockingRoom = false
        return
    end

    isUnlockingRoom = false

    SessionStats.roomStateText = string.format("🔓 Entering Locked Room %d...", lockedIdx)
    dl_cancelTween()
    local enterPos = cachedLockedRoomCF.Position + Vector3.new(0, dl_farm_height - 6, 0)
    dl_directTeleport(CFrame.new(enterPos, cachedLockedRoomCF.Position))
    task.wait(0.25)

    if isOn("AutoCollectChests") then
        local lrChests = dl_getChestsInLockedRoom(lockedModel, lockedIdx)

        if #lrChests > 0 then
            SessionStats.roomStateText = string.format("🔓 Locked Room %d: %d chests found", lockedIdx, #lrChests)

            for i, cData in ipairs(lrChests) do
                if cData.part and cData.part.Parent and isOn("AutoFarm") and not Library.Unloaded then
                    SessionStats.roomStateText = string.format("🔓 Locked Room %d Chest %d/%d...", lockedIdx, i, #lrChests)

                    dl_forceCollectChest(cData)
                    task.wait(0.6)

                    local ambushMobs = dl_getEnemiesInRoom(cachedLockedRoomCF, cachedLockedRoomSize)
                    if #ambushMobs > 0 then
                        SessionStats.roomStateText = string.format("⚔️ Ambush triggered! Defeating %d mobs...", #ambushMobs)

                        collectedChests[cData.model] = nil
                        isCollectingChest = false

                        local zeroStreak = 0
                        while isOn("AutoFarm") and not Library.Unloaded do
                            local currentMobs = dl_getEnemiesInRoom(cachedLockedRoomCF, cachedLockedRoomSize)
                            if #currentMobs == 0 then
                                zeroStreak = zeroStreak + 0.1
                                if zeroStreak >= 1.0 then break end
                            else
                                zeroStreak = 0
                            end
                            task.wait(0.1)
                        end

                        SessionStats.roomStateText = string.format("🎁 Re-collecting Chest %d/%d after ambush...", i, #lrChests)
                        dl_forceCollectChest(cData)
                    end

                    collectedChests[cData.model] = true
                end
            end
        else
            SessionStats.roomStateText = string.format("🔓 Locked Room %d: No chests inside", lockedIdx)
        end
    end

    isFarmingLockedRoom = false
    currentLockedRoomModel = nil
    cachedLockedRoomCF = nil
    cachedLockedRoomSize = nil
    dlf_currentTarget = nil
end

-- ══════════════════════════════════════════
--   SPECIAL BOSS ROOM PROCESSING
-- ══════════════════════════════════════════

function dl_processSpecialBossRoom(specialBossEntry)
    if not specialBossEntry or not specialBossEntry.model or not specialBossEntry.model.Parent then return end

    local bossRoom = specialBossEntry.model
    local bossIdx = specialBossEntry.index
    local bossInfo = specialBossEntry.info
    if not bossInfo then return end

    local bossId = bossInfo.bossId
    local isPrespawned = bossInfo.prespawned

    if not bossId then
        SessionStats.roomStateText = "👑 Special Boss: No BossId attribute!"
        return
    end

    local shouldFightPrespawned = isOn("AutoFightPrespawnedBoss")
    local shouldSummonNew = isOn("AutoSummonSpecialBoss")

    if not shouldFightPrespawned and not shouldSummonNew then return end

    processedSpecialBossRooms[bossRoom] = processedSpecialBossRooms[bossRoom] or { prespawnedFought = false, summonedFought = false }
    local state = processedSpecialBossRooms[bossRoom]

    isFarmingSpecialBoss = true
    currentSpecialBossRoom = bossRoom
    cachedSpecialBossCF, cachedSpecialBossSize = dl_getRoomBounds(bossRoom)
    dlf_currentTarget = nil

    if not cachedSpecialBossCF then
        SessionStats.roomStateText = "👑 Special Boss: Cannot get room bounds!"
        isFarmingSpecialBoss = false
        currentSpecialBossRoom = nil
        return
    end

    -- Prespawn Boss Stage
    if isPrespawned and shouldFightPrespawned and not state.prespawnedFought then
        SessionStats.roomStateText = string.format("👑 Entering Boss Room %d (Prespawned: %s)...", bossIdx, bossId)

        dl_cancelTween()
        local enterPos = cachedSpecialBossCF.Position + Vector3.new(0, dl_farm_height - 6, 0)
        dl_directTeleport(CFrame.new(enterPos, cachedSpecialBossCF.Position))
        task.wait(0.3)

        SessionStats.roomStateText = string.format("👑 Farming Prespawned %s...", bossId)

        local scanStart = os.clock()
        local foundBoss = false
        while (os.clock() - scanStart < 3) and isOn("AutoFarm") and not Library.Unloaded do
            local bossData = dl_findPrespawnedBoss(bossRoom, bossId)
            if bossData then
                foundBoss = true
                break
            end
            task.wait(0.15)
        end

        if foundBoss then
            local zeroStreak = 0
            while isOn("AutoFarm") and not Library.Unloaded do
                local mobs = dl_getEnemiesInRoom(cachedSpecialBossCF, cachedSpecialBossSize)
                if #mobs == 0 then
                    zeroStreak = zeroStreak + 0.1
                    if zeroStreak >= 1.5 then break end
                else
                    zeroStreak = 0
                    SessionStats.roomStateText = string.format("👑 Fighting Prespawned %s (%d mobs)", bossId, #mobs)
                end
                task.wait(0.1)
            end

            state.prespawnedFought = true
            SessionStats.specialBossesDefeated = SessionStats.specialBossesDefeated + 1
            SessionStats.roomStateText = string.format("👑 Prespawned %s defeated!", bossId)
            task.wait(0.4)
        else
            SessionStats.roomStateText = string.format("👑 Prespawned %s not found, skipping...", bossId)
            state.prespawnedFought = true
        end

        if isOn("AutoCollectChests") then
            task.wait(0.3)
            local bossChests = dl_getChestsByRoomIndex(bossIdx)
            if #bossChests > 0 then
                for i, cData in ipairs(bossChests) do
                    if cData.part and cData.part.Parent then
                        SessionStats.roomStateText = string.format("👑 Boss Room Chest %d/%d...", i, #bossChests)
                        dl_forceCollectChest(cData)
                    end
                end
            end
        end
    end

    -- Summon New Boss Stage
    if shouldSummonNew and not state.summonedFought then
        local totem = dl_getSkullTotem()
        if not totem then
            SessionStats.roomStateText = "👑 Skull_Totem not found!"
            state.summonedFought = true
        else
            local totemPart = dl_getSkullTotemPart(totem)
            if totemPart then
                isSummoningBoss = true
                dl_cancelTween()
                dlf_currentTarget = nil

                SessionStats.roomStateText = "👑 Traveling to Skull Totem..."
                local totemPos = totemPart.Position
                local totemCF = CFrame.new(totemPos + Vector3.new(0, 4, 0), totemPos)
                dl_directTeleport(totemCF)
                task.wait(0.3)
                dl_dropToGround()
                task.wait(0.2)

                SessionStats.roomStateText = "👑 Firing Skull Totem prompt..."
                local promptFired = false
                for attempt = 1, 6 do
                    if dl_fireSkullTotemPrompt(totem) then
                        promptFired = true
                        break
                    end
                    task.wait(0.15)
                end

                if promptFired then
                    SessionStats.roomStateText = "👑 Waiting for Summon confirmation UI..."
                    local uiWaitStart = os.clock()
                    local confirmClicked = false
                    while (os.clock() - uiWaitStart < 6) and not Library.Unloaded do
                        local confirmBtn, warning = dl_getSummonConfirmUI()
                        if confirmBtn then
                            task.wait(0.15)
                            vimClick(confirmBtn)
                            confirmClicked = true
                            SessionStats.roomStateText = "👑 Confirmed Summon!"
                            break
                        end
                        task.wait(0.1)
                    end

                    if confirmClicked then
                        task.wait(0.6)

                        SessionStats.roomStateText = string.format("👑 Entering Boss Room %d for summoned %s...", bossIdx, bossId)
                        local enterPos = cachedSpecialBossCF.Position + Vector3.new(0, dl_farm_height + 4, 0)
                        dl_directTeleport(CFrame.new(enterPos, cachedSpecialBossCF.Position))
                        task.wait(0.3)

                        isSummoningBoss = false

                        SessionStats.roomStateText = string.format("👑 Waiting for %s to spawn...", bossId)
                        local spawnWaitStart = os.clock()
                        local bossSpawned = false
                        while (os.clock() - spawnWaitStart < 8) and isOn("AutoFarm") and not Library.Unloaded do
                            local bossData = dl_findAnyBossInRoom(bossRoom, bossId)
                            if bossData then
                                bossSpawned = true
                                break
                            end
                            task.wait(0.15)
                        end

                        if bossSpawned then
                            SessionStats.roomStateText = string.format("👑 Fighting Summoned %s...", bossId)
                            local zeroStreak = 0
                            while isOn("AutoFarm") and not Library.Unloaded do
                                local mobs = dl_getEnemiesInRoom(cachedSpecialBossCF, cachedSpecialBossSize)
                                if #mobs == 0 then
                                    zeroStreak = zeroStreak + 0.1
                                    if zeroStreak >= 1.5 then break end
                                else
                                    zeroStreak = 0
                                    SessionStats.roomStateText = string.format("👑 Fighting Summoned %s (%d mobs)", bossId, #mobs)
                                end
                                task.wait(0.1)
                            end

                            SessionStats.specialBossesDefeated = SessionStats.specialBossesDefeated + 1
                            SessionStats.roomStateText = string.format("👑 Summoned %s defeated!", bossId)

                            if isOn("AutoCollectChests") then
                                task.wait(0.4)
                                local bossChests = dl_getChestsByRoomIndex(bossIdx)
                                if #bossChests > 0 then
                                    for i, cData in ipairs(bossChests) do
                                        if cData.part and cData.part.Parent then
                                            SessionStats.roomStateText = string.format("👑 Summon Chest %d/%d...", i, #bossChests)
                                            dl_forceCollectChest(cData)
                                        end
                                    end
                                end
                            end
                        else
                            SessionStats.roomStateText = string.format("👑 Summoned %s never appeared, skipping...", bossId)
                        end
                    else
                        SessionStats.roomStateText = "👑 Summon UI never appeared (maybe no keys)"
                        isSummoningBoss = false
                    end
                else
                    SessionStats.roomStateText = "👑 Skull Totem prompt fire failed!"
                    isSummoningBoss = false
                end

                state.summonedFought = true
            end
        end
    end

    isFarmingSpecialBoss = false
    currentSpecialBossRoom = nil
    cachedSpecialBossCF = nil
    cachedSpecialBossSize = nil
    isSummoningBoss = false
    dlf_currentTarget = nil
end

-- ══════════════════════════════════════════
--   MAIN ROOM ADVANCEMENT CYCLE
-- ══════════════════════════════════════════

task.spawn(function()
    while not Library.Unloaded do
        task.wait(0.2)

        if isCharacterDead() then
            SessionStats.roomStateText = "💀 Dead! Waiting for Respawn..."
            dl_cancelTween()
            dlf_currentTarget = nil
            task.wait(0.5)
            continue
        end

        if endlessContinuePending then
            SessionStats.roomStateText = "⏸️ Level Clear! Snapping to Next Level..."
            task.wait(0.3)
            continue
        end

        local currentMode = getGameMode()

        if isOn("AutoFarm") and not dl_farm_paused and not isRoomCycleRunning and currentMode == "Dungeon" then
            local dungeon = dl_getGeneratedDungeon()

            if not dungeon then
                SessionStats.currentRoomText = "Waiting for Dungeon..."
                SessionStats.roomStateText   = "No Dungeon Found"
                activeSequence = {}
                activeSequenceIndex = 1
                activeRoomModel = nil
                cachedRoomCF = nil
                cachedRoomSize = nil
                activeDungeonId = nil
                dungeonFullyCompleted = false
                task.wait(1.0)
            else
                if activeDungeonId ~= dungeon.Name then
                    activeDungeonId = dungeon.Name
                    activeSequence = {}
                    activeSequenceIndex = 1
                    activeRoomModel = nil
                    cachedRoomCF = nil
                    cachedRoomSize = nil
                    lootRoomQueue = {}
                    lootRoomIndex = 0
                    currentLootRoomModel = nil
                    cachedLootRoomCF = nil
                    cachedLootRoomSize = nil
                    isFarmingLootRoom = false
                    isFarmingLockedRoom = false
                    currentLockedRoomModel = nil
                    cachedLockedRoomCF = nil
                    cachedLockedRoomSize = nil
                    isUnlockingRoom = false
                    isFarmingSpecialBoss = false
                    currentSpecialBossRoom = nil
                    cachedSpecialBossCF = nil
                    cachedSpecialBossSize = nil
                    isSummoningBoss = false
                    dungeonFullyCompleted = false
                    zoneClearedConsumed = false
                    isCollectingChest = false
                    isInteractingAltar = false
                    consumedAltars = {}
                    collectedChests = {}
                    unlockedLockedRooms = {}
                    processedSpecialBossRooms = {}
                    dlf_currentTarget = nil
                    dl_cancelTween()
                    SessionStats.roomStateText = "🔄 Transition Area Initialized!"

                    local newZones = dl_extractRoomLayout()
                    if newZones and #newZones > 0 then
                        activeSequence = newZones
                        activeSequenceIndex = 1
                    end

                    local firstRoom = dl_getRoomModel(newZones and newZones[1] and newZones[1].Index or 1)
                    if firstRoom then
                        local cf, _ = dl_getRoomBounds(firstRoom)
                        if cf then
                            dl_directTeleport(CFrame.new(cf.Position + Vector3.new(0, dl_farm_height - 6, 0), cf.Position))
                        end
                    end
                end

                if dungeonFullyCompleted then
                    SessionStats.roomStateText = "Dungeon Complete – Waiting"
                    task.wait(1)
                else
                    if #activeSequence == 0 or activeSequenceIndex > #activeSequence then
                        if activeSequenceIndex > #activeSequence and #activeSequence > 0 then
                            local endWaitStart = os.clock()
                            while (os.clock() - endWaitStart < 15) and isOn("AutoFarm") and not Library.Unloaded do
                                if dl_isDungeonEndUIActive() then break end
                                if endlessContinuePending then break end
                                task.wait(0.3)
                            end
                            if not endlessContinuePending then
                                dungeonFullyCompleted = true
                                SessionStats.roomStateText = "All rooms cleared!"
                            end
                            task.wait(0.5)
                        else
                            SessionStats.roomStateText = "Extracting Layout..."
                            local zones = dl_extractRoomLayout()
                            if zones and #zones > 0 then
                                activeSequence = zones
                                activeSequenceIndex = 1
                            else
                                task.wait(0.5)
                            end
                        end
                    end

                    if not dungeonFullyCompleted and not endlessContinuePending and #activeSequence > 0 and activeSequenceIndex <= #activeSequence then
                        local completionStates = dl_getActualZoneCompletionStates()

                        local earliestUncompletedIdx = nil
                        for i = 1, #activeSequence do
                            if not completionStates[i] then
                                earliestUncompletedIdx = i
                                break
                            end
                        end

                        if earliestUncompletedIdx and earliestUncompletedIdx < activeSequenceIndex then
                            SessionStats.roomStateText = string.format("⚠️ Backtracking to Room %d...", activeSequence[activeSequenceIndex - 1].Index)
                            activeSequenceIndex = activeSequenceIndex - 1

                            local prevRoom = dl_getRoomModel(activeSequence[activeSequenceIndex].Index)
                            if prevRoom then
                                local cf, _ = dl_getRoomBounds(prevRoom)
                                if cf then
                                    dl_cancelTween()
                                    dl_directTeleport(CFrame.new(cf.Position + Vector3.new(0, dl_farm_height - 6, 0), cf.Position))
                                end
                            end
                            task.wait(0.4)
                        elseif completionStates[activeSequenceIndex] then
                            SessionStats.roomStateText = string.format("⏩ Fast-forwarding cleared Room %d...", activeSequence[activeSequenceIndex].Index)
                            activeSequenceIndex = activeSequenceIndex + 1
                            if activeSequenceIndex > #activeSequence then
                                SessionStats.dungeonsRun = SessionStats.dungeonsRun + 1
                            end
                            task.wait(0.2)
                        else
                            isRoomCycleRunning = true

                            local zoneData      = activeSequence[activeSequenceIndex]
                            local targetRoomNum = zoneData.Index
                            local roomModel     = dl_getRoomModel(targetRoomNum)
                            local isFinalRoom   = (activeSequenceIndex == #activeSequence)

                            if roomModel then
                                activeRoomModel = roomModel
                                cachedRoomCF, cachedRoomSize = dl_getRoomBounds(roomModel)

                                local currentIsSpecialBoss = dl_isSpecialBossRoom(roomModel)

                                SessionStats.currentRoomText = string.format("Room_%d (%d/%d)%s%s",
                                    targetRoomNum, activeSequenceIndex, #activeSequence,
                                    isFinalRoom and " [BOSS]" or "",
                                    currentIsSpecialBoss and " [SPECIAL BOSS]" or "")
                                SessionStats.roomStateText   = "Transitioning"

                                zoneClearedConsumed = false

                                local disappearStart = os.clock()
                                while dl_isZoneClearedUIActive() and (os.clock() - disappearStart < 3) and isOn("AutoFarm") and not Library.Unloaded do
                                    if endlessContinuePending then break end
                                    task.wait(0.05)
                                end

                                if not endlessContinuePending then
                                    if currentIsSpecialBoss then
                                        local shouldFightPrespawned = isOn("AutoFightPrespawnedBoss")
                                        local shouldSummonNew = isOn("AutoSummonSpecialBoss")

                                        if shouldFightPrespawned or shouldSummonNew then
                                            local specialEntry = {
                                                model = roomModel,
                                                index = targetRoomNum,
                                                seqIndex = activeSequenceIndex,
                                                info = dl_getSpecialBossInfo(roomModel)
                                            }
                                            dl_processSpecialBossRoom(specialEntry)

                                            SessionStats.roomsCleared = SessionStats.roomsCleared + 1
                                            dlf_currentTarget = nil
                                            activeSequenceIndex = activeSequenceIndex + 1

                                            if activeSequenceIndex > #activeSequence then
                                                SessionStats.dungeonsRun = SessionStats.dungeonsRun + 1
                                            end
                                        else
                                            SessionStats.roomStateText = string.format("👑 Skipping Special Boss Room %d (both toggles off)", targetRoomNum)
                                            activeSequenceIndex = activeSequenceIndex + 1
                                            if activeSequenceIndex > #activeSequence then
                                                SessionStats.dungeonsRun = SessionStats.dungeonsRun + 1
                                            end
                                        end

                                        isRoomCycleRunning = false
                                        continue
                                    end

                                    dl_cancelTween()
                                    if cachedRoomCF then
                                        local enterPos = cachedRoomCF.Position + Vector3.new(0, dl_farm_height - 6, 0)
                                        dl_directTeleport(CFrame.new(enterPos, cachedRoomCF.Position))
                                    end

                                    task.wait(0.05)

                                    SessionStats.roomStateText = "Engaging Combat Room..."
                                    local waitStart = os.clock()
                                    local roomType = nil
                                    local engageTimeout = isFinalRoom and 10.0 or 2.0

                                    while (os.clock() - waitStart < engageTimeout) and isOn("AutoFarm") and not Library.Unloaded do
                                        if endlessContinuePending then break end
                                        roomType = dl_getSpecialRoomType()
                                        local currentEnemies = dl_getEnemiesInRoom(cachedRoomCF, cachedRoomSize)
                                        if #currentEnemies > 0 or roomType then
                                            break
                                        end
                                        task.wait(0.1)
                                    end

                                    SessionStats.roomStateText = "Farming Combat Room Mobs (Strict)"
                                    local roomCleared = false
                                    local zeroMobStreak = 0
                                    local minRoomTime = os.clock()
                                    local minRequiredTime = isFinalRoom and 6.0 or 0

                                    local zoneUIFiredForThisRoom = false
                                    local minWaitBeforeClear = os.clock() + 1.5

                                    while isOn("AutoFarm") and not Library.Unloaded and not roomCleared do
                                        if endlessContinuePending then break end

                                        local realStates = dl_getActualZoneCompletionStates()
                                        local enemies = dl_getEnemiesInCurrentRoom()
                                        local bossBarActive = dl_isBossBarActive()

                                        -- SAFETY: If we are in the Boss Room, NEVER allow completion while the boss or boss bar is still alive!
                                        if isFinalRoom then
                                            if not bossBarActive and #enemies == 0 and os.clock() > minWaitBeforeClear then
                                                if (not zoneClearedConsumed and dl_isZoneClearedUIActive()) or (realStates[activeSequenceIndex] == true) or dl_isDungeonEndUIActive() then
                                                    zoneClearedConsumed = true
                                                    zoneUIFiredForThisRoom = true
                                                    roomCleared = true
                                                    break
                                                end
                                            end
                                        else
                                            if (not zoneClearedConsumed and dl_isZoneClearedUIActive()) or (realStates[activeSequenceIndex] == true and #enemies == 0) then
                                                zoneClearedConsumed = true
                                                zoneUIFiredForThisRoom = true
                                                roomCleared = true
                                                break
                                            end
                                        end

                                        local currDungeon = dl_getGeneratedDungeon()
                                        if not currDungeon or currDungeon.Name ~= activeDungeonId then
                                            break
                                        end
                                        if dl_isDungeonEndUIActive() then
                                            zoneUIFiredForThisRoom = true
                                            break
                                        end

                                        local isSurvive = dl_isSurviveActive()
                                        local timeInRoom = os.clock() - minRoomTime

                                        if #enemies > 0 or bossBarActive then
                                            zeroMobStreak = 0
                                            SessionStats.roomStateText = string.format("Combat Room %d: %d alive%s", targetRoomNum, #enemies, isFinalRoom and " [BOSS]" or "")
                                        else
                                            zeroMobStreak = zeroMobStreak + 0.05

                                            -- UI Desync Watchdog: Only advance non-boss rooms on timeout
                                            if zeroMobStreak >= 10.0 and not isSurvive and not isFinalRoom then
                                                pcall(function()
                                                    Library:Notify("⚠️ UI Desync Detected! Auto-advancing past room " .. tostring(targetRoomNum), 4)
                                                end)
                                                local refreshedZones = dl_extractRoomLayout()
                                                if refreshedZones and #refreshedZones > 0 then
                                                    activeSequence = refreshedZones
                                                end
                                                zoneClearedConsumed = true
                                                zoneUIFiredForThisRoom = true
                                                roomCleared = true
                                                break
                                            end

                                            if isSurvive then
                                                SessionStats.roomStateText = "Survive Wave Cooldown..."
                                            elseif isFinalRoom and (timeInRoom < minRequiredTime or bossBarActive) then
                                                SessionStats.roomStateText = string.format("Engaging Boss... (Time: %.1fs)", timeInRoom)
                                            elseif os.clock() < minWaitBeforeClear then
                                                SessionStats.roomStateText = "Scanning Combat Room..."
                                            else
                                                SessionStats.roomStateText = string.format("Waiting for Zone Cleared UI... (Desync: %.1f/10s)", zeroMobStreak)
                                            end
                                        end
                                        task.wait(0.05)
                                    end

                                    if roomCleared and not endlessContinuePending then
                                        if isOn("AutoCollectChests") then
                                            local combatChests = dl_getChestsByRoomIndex(targetRoomNum)
                                            if #combatChests > 0 then
                                                for i, cData in ipairs(combatChests) do
                                                    if cData.part and cData.part.Parent then
                                                        SessionStats.roomStateText = string.format("🎁 Combat Room %d Chest %d/%d...", targetRoomNum, i, #combatChests)
                                                        dl_forceCollectChest(cData)
                                                    end
                                                end
                                            end
                                        end

                                        local lootRooms = dl_getLootRoomsForParent(targetRoomNum)
                                        if #lootRooms > 0 then
                                            SessionStats.roomStateText = string.format("💎 %d Loot Rooms linked to Room %d...", #lootRooms, targetRoomNum)
                                            for _, lr in ipairs(lootRooms) do
                                                if isOn("AutoFarm") and not Library.Unloaded and not endlessContinuePending then
                                                    dl_processLootRoom(lr)
                                                end
                                            end
                                        end

                                        if isOn("AutoUnlockSideRooms") then
                                            local lockedRooms = dl_getLockedRoomsForParent(targetRoomNum)
                                            if #lockedRooms > 0 then
                                                SessionStats.roomStateText = string.format("🔓 %d Locked Rooms linked to Room %d...", #lockedRooms, targetRoomNum)
                                                for _, lr in ipairs(lockedRooms) do
                                                    if isOn("AutoFarm") and not Library.Unloaded and not endlessContinuePending then
                                                        dl_processLockedRoom(lr)
                                                    end
                                                end
                                            end
                                        end

                                        if (isOn("AutoFightPrespawnedBoss") or isOn("AutoSummonSpecialBoss")) and not endlessContinuePending then
                                            local specialBossEntry = dl_findSpecialBossRoomAfter(activeSequenceIndex)
                                            if specialBossEntry then
                                                SessionStats.roomStateText = string.format("👑 Special Boss Room %d detected after Room %d!", specialBossEntry.index, targetRoomNum)
                                                dl_processSpecialBossRoom(specialBossEntry)
                                            end
                                        end

                                        if isOn("AutoBlessing") and not endlessContinuePending then
                                            local intermediateAltar, altarRoomIdx = dl_findAltarAfterRoom(activeSequenceIndex)
                                            if intermediateAltar then
                                                SessionStats.roomStateText = string.format("🔮 Processing Altar in Room %d...", altarRoomIdx or 0)
                                                dl_processAltarSequence(intermediateAltar)
                                            end
                                        end

                                        SessionStats.roomsCleared = SessionStats.roomsCleared + 1
                                        SessionStats.roomStateText = "Cleared!"

                                        dlf_currentTarget = nil
                                        activeSequenceIndex = activeSequenceIndex + 1

                                        if activeSequenceIndex > #activeSequence then
                                            SessionStats.dungeonsRun = SessionStats.dungeonsRun + 1
                                        end
                                    end
                                end
                            else
                                activeSequenceIndex = activeSequenceIndex + 1
                            end

                            isRoomCycleRunning = false
                        end
                    end
                end
            end
        else
            task.wait(0.2)
        end
    end
end)

-- ══════════════════════════════════════════
--   TEXT HELPERS & FORMATTING
-- ══════════════════════════════════════════

function c(t, col)
    if not col or col == "" then return t end
    return string.format('<font color="%s">%s</font>', col, t)
end

function b(t) return string.format("<b>%s</b>", t) end
function i(t) return string.format("<i>%s</i>", t) end
function sz(t, size) return string.format('<font size="%d">%s</font>', size, t) end

function hexToRgb(hex)
    hex = hex:gsub("#", "")
    return tonumber("0x" .. hex:sub(1, 2)), tonumber("0x" .. hex:sub(3, 4)), tonumber("0x" .. hex:sub(5, 6))
end

function rgbToHex(r, g, b)
    return string.format("#%02x%02x%02x", math.clamp(r, 0, 255), math.clamp(g, 0, 255), math.clamp(b, 0, 255))
end

function lerp(a1, b1, t) return a1 + (b1 - a1) * t end

function createMultiGradientText(word, colors)
    if #colors < 2 then return word end
    local result = ""
    local len = #word
    if len == 0 then return "" end
    for j = 1, len do
        local globalT = (len == 1) and 0 or (j - 1) / (len - 1)
        local scaled = globalT * (#colors - 1)
        local idx = math.floor(scaled) + 1
        local localT = scaled - (idx - 1)
        local c1 = colors[math.min(idx, #colors)]
        local c2 = colors[math.min(idx + 1, #colors)]
        local r1, g1, b1 = hexToRgb(c1)
        local r2, g2, b2 = hexToRgb(c2)
        local r = math.round(lerp(r1, r2, localT))
        local g = math.round(lerp(g1, g2, localT))
        local b = math.round(lerp(b1, b2, localT))
        local char = word:sub(j, j)
        if char == " " then
            result = result .. " "
        else
            result = result .. string.format('<font color="%s">%s</font>', rgbToHex(r, g, b), char)
        end
    end
    return result
end

local PALETTE = {
    prism   = { "#38bdf8", "#a78bfa", "#ec4899" },
    aurora  = { "#4ade80", "#22d3ee", "#a78bfa" },
    sunset  = { "#fbbf24", "#f97316", "#ef4444" },
    ocean   = { "#38bdf8", "#0ea5e9", "#6366f1" },
    fire    = { "#fef08a", "#fb923c", "#dc2626" },
    ice     = { "#e0f2fe", "#7dd3fc", "#3b82f6" },
    rainbow = { "#ef4444", "#fbbf24", "#4ade80", "#22d3ee", "#a78bfa", "#ec4899" },
}


function formatDuration(secs)
    secs = math.floor(secs)
    local h = math.floor(secs / 3600)
    local m = math.floor((secs % 3600) / 60)
    local s = secs % 60
    if h > 0 then return string.format("%dh %dm %ds", h, m, s) end
    if m > 0 then return string.format("%dm %ds", m, s) end
    return string.format("%ds", s)
end

function gradPlus(colors)
    return createMultiGradientText("[+]", colors)
end

local DISCORD_INVITE = "https://discord.gg/DHeCNzTypH"
local RSCRIPTS_LINK  = "https://rscripts.net/@Prism"

-- ══════════════════════════════════════════
--   LOBBY DATA REGISTRY & HELPERS
-- ══════════════════════════════════════════

local Registry = nil
pcall(function()
    for _, desc in ipairs(LocalPlayer.PlayerScripts:GetDescendants()) do
        if desc:IsA("ModuleScript") and desc.Name == "Registry" then
            Registry = require(desc)
            break
        end
    end
end)

function getPlayerData()
    if Registry then
        local pd = Registry:Get("PlayerData")
        if pd then return pd.Data or pd end
    end
    return nil
end

function getSummonSlotData()
    local pd = getPlayerData()
    if pd and type(pd) == "table" then
        if pd.Slots or pd.SlotAspects then
            return {
                Slots = pd.Slots or {},
                SlotAspects = pd.SlotAspects or {},
                ActiveIndex = pd.ActiveSlotIndex or pd.ActiveSlot or pd.ActiveIndex or 1
            }
        end
        local nested = pd.SlotData or pd.SummonData or pd.Summons or pd.ClassSlots
        if nested and type(nested) == "table" and (nested.Slots or nested.SlotAspects) then
            return {
                Slots = nested.Slots or {},
                SlotAspects = nested.SlotAspects or {},
                ActiveIndex = nested.ActiveIndex or nested.ActiveSlotIndex or pd.ActiveIndex or 1
            }
        end
    end

    local slotData = nil
    local ok = pcall(function()
        slotData = dl_GetSlotData:InvokeServer()
    end)
    if ok and type(slotData) == "table" then
        return slotData
    end
    return nil
end

local DUNGEON_INTERNAL_MAP = {
    ["Bandit's Den"]        = "Bandits Den",
    ["Goblin's Stronghold"] = "Goblins",
    ["Forgotten Ruins"]     = "Knights",
    ["The Catacombs"]       = "Catacombs",
    ["Frostspire Bastion"]  = "Snow",
    ["Underworld Gate"]     = "Demon",
    ["City of Mages"]       = "Mage"
}

local RARITY_LEVELS = {
    ["Common"]    = 1,
    ["Uncommon"]  = 2,
    ["Rare"]      = 3,
    ["Epic"]      = 4,
    ["Legendary"] = 5,
    ["Mythic"]    = 6,
    ["Celestial"] = 7,
    ["Exotic"]    = 8
}

-- ══════════════════════════════════════════
--   CORE DISCORD WEBHOOK LOGGING ENGINE
-- ══════════════════════════════════════════
function sendDungeonRemoteWebhook(data)
    if not wh_url or wh_url == "" then return end
    if wh_isSending then return end
    wh_isSending = true

    task.spawn(function()
        local targetMinRarityIndex = RARITY_LEVELS[wh_minRarity] or 1
        local highestRarityIndex = 1
        local rewardLines = {}

        -- Sub-step C1: Standard Currency Drops
        if data.CashEarned and data.CashEarned > 0 then
            table.insert(rewardLines, "▫️ **Coins** `+" .. formatNumber(data.CashEarned) .. "`")
        end
        if data.StarsEarned and data.StarsEarned > 0 then
            table.insert(rewardLines, "▫️ **Stars** `+" .. formatNumber(data.StarsEarned) .. "`")
        end
        if data.ClassSpinsEarned and data.ClassSpinsEarned > 0 then
            table.insert(rewardLines, "▫️ **Class Spins** `+" .. formatNumber(data.ClassSpinsEarned) .. "`")
        end

        -- Sub-step C2: Nested Raid Reward Entries
        if type(data.RewardEntries) == "table" then
            for _, entry in ipairs(data.RewardEntries) do
                local amt = entry.Amount or 1
                if entry.Type == "EventPoints" then
                    table.insert(rewardLines, "▫️ **Event Points** `+" .. formatNumber(amt) .. "`")
                elseif entry.Type == "Package" or entry.Type == "Chest" then
                    local name = entry.Name or entry.Id or "Unknown Chest"
                    table.insert(rewardLines, "▫️ **" .. name .. "** `x" .. tostring(amt) .. "`")
                elseif entry.Id then
                    local name = entry.Name or entry.Id
                    table.insert(rewardLines, "▫️ **" .. name .. "** `x" .. tostring(amt) .. "` *(" .. tostring(entry.Type or "Item") .. ")*")
                else
                    table.insert(rewardLines, "▫️ **" .. tostring(entry.Type or "Reward") .. "** `+" .. tostring(amt) .. "`")
                end
            end
        end

        -- Sub-step C3: Material Drops
        if type(data.MaterialRewards) == "table" then
            for _, mat in ipairs(data.MaterialRewards) do
                local matName = mat.Id or mat.Name or "Unknown Material"
                local amtStr = mat.Amount and (" `x" .. tostring(mat.Amount) .. "`") or ""
                
                -- Estimate material rarity logic fallback
                local matRarity = mat.Rarity or "Common"
                if matName:find("Gold") or matName:find("Celestial") or matName:find("Dragon") then
                    matRarity = "Legendary"
                elseif matName:find("Ore") or matName:find("Scrap") then
                    matRarity = "Rare"
                end
                
                local rIndex = RARITY_LEVELS[matRarity] or 1
                if rIndex > highestRarityIndex then
                    highestRarityIndex = rIndex
                end
                table.insert(rewardLines, "▫️ **" .. matName .. "** [" .. matRarity .. "]" .. amtStr)
            end
        end

        -- Sub-step C4: Item Equipment Drops
        if type(data.ItemRewards) == "table" then
            for _, itm in ipairs(data.ItemRewards) do
                local itemId = itm.ItemId or itm.Id or "Unknown Item"
                local rarity = itm.Rarity or "Common"
                local slotStr = itm.Slot and (" *(" .. tostring(itm.Slot) .. ")*") or ""
                local rIndex = RARITY_LEVELS[rarity] or 1
                if rIndex > highestRarityIndex then
                    highestRarityIndex = rIndex
                end
                table.insert(rewardLines, "▫️ **" .. itemId .. "** [" .. rarity .. "]" .. slotStr)
            end
        end

        local rewardDesc = #rewardLines > 0 and table.concat(rewardLines, "\n") or "*None*"

        -- Step D: Time Formatter
        local totalSecs = math.floor(data.TimeElapsed or 0)
        local mins = math.floor(totalSecs / 60)
        local secs = totalSecs % 60
        local timeStr = string.format("%02d:%02d", mins, secs)

        -- Step E: Ping Criteria
        local pingContent = ""
        if highestRarityIndex >= targetMinRarityIndex then
            if wh_pingEveryone then
                pingContent = "@everyone"
            elseif wh_pingEnabled and wh_userId ~= "" then
                pingContent = "<@" .. tostring(wh_userId) .. ">"
            end
        end

        -- Step F: Embed Colors
        local embedColor = 65280 -- Green (Default)
        local diff = tostring(data.Difficulty or ""):lower()
        if not data.IsVictory then
            embedColor = 16711680 -- Red
        elseif diff:find("nightmare") or diff:find("impossible") then
            embedColor = 10038562 -- Purple
        elseif diff:find("hard") or diff:find("extreme") then
            embedColor = 16738816 -- Orange
        end

        -- Step G: Embed Payload Packaging
        local titleText = data.IsVictory and "🏆 Match Cleared!" or "💀 Match Failed!"
        local statusText = data.Status or (data.IsVictory and "Victory" or "Defeated")
        local dungeonName = data.DungeonName or "Unknown Map"

        local payload = {
            content = pingContent,
            embeds = {{
                title = titleText,
                description = "**Map:** `" .. dungeonName .. "`\n**Difficulty:** `" .. tostring(data.Difficulty or "Normal") .. "`\n**Status:** `" .. statusText .. "`\n━━━━━━━━━━━━━━━━━━━━━━━━━━",
                color = embedColor,
                fields = {
                    { name = "👤 User",          value = "||" .. game.Players.LocalPlayer.Name .. "||", inline = true },
                    { name = "🕰️ Clear Time",    value = "```" .. timeStr .. "```", inline = true },
                    { name = "👥 Party Size",    value = "```" .. tostring(data.PlayerCount or 1) .. "```", inline = true },
                    { name = "🪦 Mobs Defeated", value = "```" .. tostring(data.MobsKilled or 0) .. "```", inline = true },
                    { name = "🏯 Rooms Cleared", value = "```" .. tostring(data.RoomsCleared or 0) .. "```", inline = true },
                    { name = "☠️ User Deaths",   value = "```" .. tostring(data.TotalDeaths or 0) .. "```", inline = true },
                    { name = "💥 Total Damage",  value = "```" .. formatNumber(data.TotalDamage or 0) .. "```", inline = true },
                    { name = "📈 EXP Earned",    value = "```" .. formatNumber(data.TotalEXP or 0) .. "```", inline = true },
                    { name = "🏆 Rewards",       value = rewardDesc, inline = false }
                },
                footer = { text = "Prism  •  Dungeons Lootr  •  v5.9.5 [PRO]" },
                timestamp = DateTime.now():ToIsoDate()
            }}
        }

        pcall(function()
            wh_requestFunc({
                Url = wh_url,
                Method = "POST",
                Headers = { ["Content-Type"] = "application/json" },
                Body = HttpService:JSONEncode(payload)
            })
        end)

        task.wait(2.0) -- Anti-flood safety mutex lock cooldown
        wh_isSending = false
    end)
end

local CLASS_RARITY_MAP = {
    ["Greatsword"] = "Rare", ["Bowman"] = "Rare", ["Ronin"] = "Rare",
    ["Flame Bastion"] = "Epic", ["Boxer"] = "Epic", ["Assassin"] = "Epic",
    ["Archer"] = "Legendary", ["Witch Gunner"] = "Legendary", ["Shinobi"] = "Legendary", ["Kage"] = "Legendary",
    ["Divergent"] = "Mythic", ["Cursed Child"] = "Mythic", ["Wanderer"] = "Mythic",
    ["Artemis"] = "Celestial", ["Vacio"] = "Celestial", ["Azure Devil"] = "Celestial", ["Forge Archon"] = "Celestial",
    ["Sinister Trigger"] = "Exotic",     ["Embertide"] = "Exotic",     ["Dragoon"] = "Exotic"
}

local RARITY_COLORS = {
    ["Common"]    = "#9ca3af",
    ["Uncommon"]  = "#4ade80",
    ["Rare"]      = "#60a5fa",
    ["Epic"]      = "#a78bfa",
    ["Legendary"] = "#fbbf24",
    ["Mythic"]    = "#f472b6",
    ["Celestial"] = "#38bdf8",
    ["Exotic"]    = "#ef4444"
}

local ASPECT_RARITY_MAP = {
    ["Blaze"] = "2.5%", ["Glaciel"] = "2.5%", ["Fulmin"] = "2.5%",
    ["Aegis"] = "2.5%", ["Verdant"] = "2.5%", ["Sanguine"] = "2.5%",
    ["Umbral"] = "2.5%",
    ["Tempest"] = "1%", ["Phantom"] = "1%", ["Ruin"] = "1%",
    ["Alacrity"] = "1%",
}

local ASPECT_COLORS = {
    ["2.5%"] = "#fbbf24",
    ["1%"]   = "#f472b6",
}

local rarityOrder = { "Exotic", "Celestial", "Mythic", "Legendary", "Epic", "Rare" }
local sortedClassValues = {}
for _, rarity in ipairs(rarityOrder) do
    for className, classRarity in pairs(CLASS_RARITY_MAP) do
        if classRarity == rarity then
            table.insert(sortedClassValues, string.format("%s [%s]", className, rarity))
        end
    end
end

local aspectRarityOrder = { "1%", "2.5%" }
local sortedAspectValues = {}
for _, rarity in ipairs(aspectRarityOrder) do
    for aspectName, aspectRarity in pairs(ASPECT_RARITY_MAP) do
        if aspectRarity == rarity then
            table.insert(sortedAspectValues, string.format("%s [%s]", aspectName, rarity))
        end
    end
end

function scoreGear(item)
    local score = 0
    local rarityScore = RARITY_LEVELS[item.Rarity or "Common"] or 0
    score = score + (rarityScore * 1000)
    if item.Slot == "Ring" then
        score = score + (item.BaseDamage or 0) * 10
    elseif item.GuaranteedStat and item.GuaranteedStat.Value then
        score = score + item.GuaranteedStat.Value * 10
    end
    if item.EnchantLevel then
        score = score + item.EnchantLevel * 50
    end
    return score
end

function runAutoEquipBest()
    local pd = getPlayerData()
    if not pd then return end
    local inv = pd.EquipmentInventory
    if not inv then return end

    local pLevel = pd.PlayerLevel or 1
    local bestGear = { Head = nil, Body = nil, Ring = nil }
    local bestScores = { Head = -1, Body = -1, Ring = -1 }

    local currentGear = pd.Equipment or {}
    for slot, item in pairs(currentGear) do
        if type(item) == "table" and item.GUID then
            bestGear[slot] = item
            bestScores[slot] = scoreGear(item)
        end
    end

    for _, item in ipairs(inv) do
        if type(item) == "table" and item.GUID and (not item.LevelReq or pLevel >= item.LevelReq) then
            local slot = item.Slot
            if bestGear[slot] ~= nil or slot == "Head" or slot == "Body" or slot == "Ring" then
                local score = scoreGear(item)
                if score > bestScores[slot] then
                    bestScores[slot] = score
                    bestGear[slot] = item
                end
            end
        end
    end

    for slot, item in pairs(bestGear) do
        local current = currentGear[slot]
        if item and (not current or current.GUID ~= item.GUID) then
            pcall(function()
                KnitServices.EquipmentService:WaitForChild("RF"):WaitForChild("Equip"):InvokeServer(item.GUID)
            end)
            task.wait(0.2)
        end
    end
end

function runAutoSell()
    local pd = getPlayerData()
    if not pd then return end
    local inv = pd.EquipmentInventory
    if not inv or #inv == 0 then return end

    local sellBatch = {}
    local equipped = pd.Equipment or {}
    local equippedGUIDs = {}

    for _, gear in pairs(equipped) do
        if type(gear) == "table" and gear.GUID then
            equippedGUIDs[gear.GUID] = true
        end
    end

    for _, item in ipairs(inv) do
        if type(item) == "table" and item.GUID then
            local isEquipped = equippedGUIDs[item.GUID] == true
            local isLocked = item.Locked == true
            local rarity = item.Rarity or "Common"

            if not isEquipped and not isLocked then
                local sellOption = Options.SellRarities
                local shouldSell = sellOption and sellOption.Value and sellOption.Value[rarity] == true
                if shouldSell then
                    table.insert(sellBatch, item.GUID)
                end
            end
        end
    end

    if #sellBatch > 0 then
        pcall(function()
            dl_SellEquipment:InvokeServer(sellBatch)
        end)
    end
end

local BUFF_DEFINITIONS = {
    { 
        Title = "Overwhelming Force", 
        Desc = "Overall Damage\n• Range: +10% to +30%\n• Step: 5%", 
        Key = "BuffPrio_Overwhelming_Force", 
        Default = 14 
    },
    { 
        Title = "Fleetfoot",          
        Desc = "Movement Speed\n• Range: +5% to +15%\n• Step: 1%\n• Max Cap: 50%", 
        Key = "BuffPrio_Fleetfoot",          
        Default = 10 
    },
    { 
        Title = "Ironhide",           
        Desc = "Max HP\n• Range: +10% to +25%\n• Step: 5%", 
        Key = "BuffPrio_Ironhide",           
        Default = 8 
    },
    { 
        Title = "Bloodlust",          
        Desc = "Enemy Kill EXP\n• Range: +15% to +35%\n• Step: 5%\n• Max Cap: 100%", 
        Key = "BuffPrio_Bloodlust",          
        Default = 7 
    },
    { 
        Title = "Scholar's Insight",  
        Desc = "Completion EXP\n• Range: +25% to +50%\n• Step: 5%\n• Max Cap: 100%", 
        Key = "BuffPrio_Scholars_Insight",   
        Default = 7 
    },
    { 
        Title = "Fortune",            
        Desc = "Flat Coins Reward\n• Range: +500 to +1,500\n• Step: 100", 
        Key = "BuffPrio_Fortune",            
        Default = 6 
    },
    { 
        Title = "Arcane Might",       
        Desc = "Skill Damage\n• Range: +5% to +30%\n• Step: 5%", 
        Key = "BuffPrio_Arcane_Might",       
        Default = 13 
    },
    { 
        Title = "Deadeye",            
        Desc = "Crit Rate\n• Range: +5% to +50%\n• Step: 5%\n• Max Cap: 50%", 
        Key = "BuffPrio_Deadeye",            
        Default = 12 
    },
    { 
        Title = "Focused Casting",    
        Desc = "Skill Crit Rate\n• Range: +2% to +10%\n• Step: 1%\n• Max Cap: 50%", 
        Key = "BuffPrio_Focused_Casting",    
        Default = 11 
    },
    { 
        Title = "Devastation",        
        Desc = "Skill Crit Damage\n• Range: +10% to +50%\n• Step: 5%", 
        Key = "BuffPrio_Devastation",        
        Default = 12 
    },
    { 
        Title = "Bulwark",            
        Desc = "Damage Reduction\n• Range: +5% to +30%\n• Step: 5%\n• Max Cap: 50%", 
        Key = "BuffPrio_Bulwark",            
        Default = 9 
    },
    { 
        Title = "Steadfast",          
        Desc = "Parry Window Extension\n• Range: +0.05s to +0.3s\n• Step: 0.05s\n• Max Cap: 0.5s", 
        Key = "BuffPrio_Steadfast",          
        Default = 5 
    },
    { 
        Title = "Nimble",             
        Desc = "Dodge Cooldown Reduction\n• Range: -0.1s to -0.3s\n• Step: 0.05s\n• Max Cap: 1.0s", 
        Key = "BuffPrio_Nimble",             
        Default = 8 
    },
    { 
        Title = "Flowstate",          
        Desc = "Skill Cooldown Reduction\n• Range: -5% to -30%\n• Step: 5%\n• Max Cap: 50%", 
        Key = "BuffPrio_Flowstate",          
        Default = 13 
    },
}

dl_ChestSelectionRE.OnClientEvent:Connect(function(chests)
    if type(chests) == "table" then
        latestChestData = chests
    end
end)

-- ══════════════════════════════════════════
--   CREATE WINDOW & GLOBAL TABS
-- ══════════════════════════════════════════

local Window = Library:CreateWindow({
    Title            = "Prism",
    Footer           = "Prism  |  Dungeon Lootr  |  v5.9.5 [PRO]",
    Icon             = "rbxassetid://117487160988921",
    MobileButtonSide = "Right",
    NotifySide       = "Right",
    ShowCustomCursor = false,
    CornerRadius     = 2,
    AutoMinimize     = true,
    Animations = {
        ToggleWindow    = false,
        TabSwitch       = true,
        Groupbox        = false,
        Dropdown        = true,
        KeyPicker       = true,
        SubTabUnderline = true,
    },
})

Tabs = {
    Info     = Window:AddTab("Info",     "activity"),
    Lobby    = Window:AddTab("Lobby",    "land-plot"),
    Dungeon  = Window:AddTab("Dungeon",  "castle"),
    Combat   = Window:AddTab("Combat",   "swords"),
    Flags    = Window:AddTab("Flags",    "shield-alert"),
    Player   = Window:AddTab("Player",   "user-check"),
    Webhook  = Window:AddTab("Webhook",  "webhook"), -- Added Webhook Main Tab
    Settings = Window:AddTab("Settings", "settings"),
}

-- Webhook Subtabs
Tabs.WebhookSetup = Tabs.Webhook:AddSubTab("Setup", "settings")
Tabs.WebhookTest  = Tabs.Webhook:AddSubTab("Testing", "send")

TabsLobby = {
    Autostart = Tabs.Lobby:AddSubTab("Autostart", "play"),
    Gear      = Tabs.Lobby:AddSubTab("Gear",      "shield"),
    Summon    = Tabs.Lobby:AddSubTab("Summon",    "sparkles"),
    Shop      = Tabs.Lobby:AddSubTab("Shop",      "shopping-cart"),
    Misc      = Tabs.Lobby:AddSubTab("Misc",      "plus"),
}

TabsDungeon = {
    Main          = Tabs.Dungeon:AddSubTab("Main", "house"),
    Farm          = Tabs.Dungeon:AddSubTab("Farm", "target"),
    LootBlessings = Tabs.Dungeon:AddSubTab("Loot & Blessings", "sparkles"),
    Potion        = Tabs.Dungeon:AddSubTab("Potions", "flask-round"),
}

-- ══════════════════════════════════════════
--   INFO TAB
-- ══════════════════════════════════════════

do
    local PrismBox = Tabs.Info:AddLeftGroupbox("Prism", "sparkles")
    PrismBox:AddLabel(sz(b(createMultiGradientText("PRISM", PALETTE.prism)), 20), true)
    PrismBox:AddLabel(c(i("keyless forever, always will be"), "#9ca3af"), true)
    PrismBox:AddLabel(
        c(b("status "),  "#6b7280") .. c(b("online"), "#4ade80") ..
        c("     ",       "#374151") ..
        c(b("version "), "#6b7280") .. c(b("5.9.5"), "#38bdf8"),
    true)
    PrismBox:AddDivider()

    PrismBox:AddLabel(sz(b(createMultiGradientText("if you enjoy the script or want to report a bug, please consider the following:", PALETTE.ice)), 14), true)
    PrismBox:AddLabel(sz(b(createMultiGradientText("more than 60 keyless scripts in this hub, I would love your support!", PALETTE.ice)), 14), true)
    PrismBox:AddDivider()

    PrismBox:AddButton({ Text = "Discord for Support 💝", Func = function() copyText(DISCORD_INVITE, "Discord invite copied!") end })
    PrismBox:AddButton({ Text = "Follow Rscripts 🙏", Func = function() copyText(RSCRIPTS_LINK, "Rscripts link copied!") end })

    local FeaturesBox = Tabs.Info:AddLeftGroupbox("Features", "layers")
    local featureList = {
        "Auto Farm Mobs", "Auto Priority Archetypes (Archer/Healer)", "Raid Crystal Farming Engine", "Auto Farm Loot Rooms", "Auto Unlock Side Rooms",
        "Auto Fight Prespawned Special Boss", "Auto Summon Special Boss",
        "Auto Open Chests", "Auto Melee Strike",
        "Auto Skills Rotation", "Auto Ultimate", "Auto Equip Best Gear",
        "Auto Claim Quests", "Auto Sell Loot", "Auto Priority Blessings",
        "Auto 2/3 Best Chest Picker", "Auto Tween Chest Collector", "Auto Loot Magnet",
        "Anti AFK", "Fly, NoClip, WalkSpeed", "Auto Replay/Return", "Custom End Actions",
        "Boss Rush / Challenge / Raid Support"
    }
    for _, item in ipairs(featureList) do
        FeaturesBox:AddLabel(gradPlus(PALETTE.prism) .. c(" " .. item, "#f3f4f6"), true)
    end

    local DiagnosticBox = Tabs.Info:AddRightGroupbox("Live", "cpu")
    local FpsLabel     = DiagnosticBox:AddLabel(b("FPS: ")    .. c("...", "#60a5fa"), true)
    local PingLabel    = DiagnosticBox:AddLabel(b("Ping: ")   .. c("...", "#4ade80"), true)
    local MemoryLabel  = DiagnosticBox:AddLabel(b("Memory: ") .. c("...", "#fbbf24"), true)
    local SessionLabel = DiagnosticBox:AddLabel(b("Uptime: ") .. c("0s",  "#a78bfa"), true)

    local RobloxBox = Tabs.Info:AddRightGroupbox("Roblox", "server")
    RobloxBox:AddLabel(b(createMultiGradientText("EXTRA INFO", PALETTE.aurora)), true)
    RobloxBox:AddDivider()
    RobloxBox:AddLabel(b("User: ") .. c(LocalPlayer.Name, "#ffffff"), true)
    RobloxBox:AddLabel(b("Executor: ") .. c(executorName, "#fb923c"), true)
    RobloxBox:AddLabel(b("Place ID: ") .. c(tostring(game.PlaceId), "#60a5fa"), true)
    RobloxBox:AddLabel(b("Job ID: ") .. c(string.sub(tostring(game.JobId), 1, 14) .. "...", "#9ca3af"), true)
    RobloxBox:AddDivider()

    RobloxBox:AddButton({ Text = "Copy Server ID", Func = function() copyText(game.JobId, "Server JobId copied!") end })
    RobloxBox:AddButton({
        Text = "Copy Rejoin Script",
        Func = function()
            local command = string.format("game:GetService(\"TeleportService\"):TeleportToPlaceInstance(%d, \"%s\", game.Players.LocalPlayer)", game.PlaceId, game.JobId)
            copyText(command, "Rejoin command copied!")
        end
    })

    local sessionStart = SessionStats.startTime
    local frameCount = 0
    local lastFpsUpdate = os.clock()

    RunService.RenderStepped:Connect(function()
        frameCount = frameCount + 1
        local now = os.clock()
        if now - lastFpsUpdate >= 0.5 then
            local fps = math.floor(frameCount / (now - lastFpsUpdate))
            frameCount = 0
            lastFpsUpdate = now
            if not Library.Unloaded then
                local ping = math.floor(StatsService and StatsService.PerformanceStats.Ping:GetValue() or 0)
                local mem  = math.floor(StatsService and StatsService:GetTotalMemoryUsageMb() or 0)
                local fpsColor  = fps > 45 and "#4ade80" or (fps > 25 and "#fbbf24" or "#ef4444")
                local pingColor = ping < 80 and "#4ade80" or (ping < 150 and "#fbbf24" or "#ef4444")
                FpsLabel:SetText(b("FPS: ")    .. c(tostring(fps), fpsColor))
                PingLabel:SetText(b("Ping: ")  .. c(tostring(ping) .. " ms", pingColor))
                MemoryLabel:SetText(b("Memory: ") .. c(tostring(mem) .. " MB", "#fbbf24"))
            end
        end
    end)

    task.spawn(function()
        while not Library.Unloaded do
            task.wait(1)
            SessionLabel:SetText(b("Uptime: ") .. c(formatDuration(os.clock() - sessionStart), "#a78bfa"))
        end
    end)
end

-- ══════════════════════════════════════════
--   LOBBY TABS
-- ══════════════════════════════════════════

do
    local AQ = TabsLobby.Autostart:AddLeftGroupbox("Dungeon Matchmaker", "play")
    AQ:AddLabel("<b>AUTO DUNGEONS</b>", true)
    AQ:AddDivider()
    AQ:AddToggle("AutoQueueDungeon", { Text = "Auto Join Dungeon", Default = false })
    AQ:AddDropdown("QueueDungeonName", {
        Values = {
            "Bandit's Den", "Goblin's Stronghold", "Forgotten Ruins",
            "The Catacombs", "Frostspire Bastion", "Underworld Gate", "City of Mages"
        },
        Default = "Bandit's Den",
        Text = "Dungeon Select",
    })
    AQ:AddDropdown("QueueDifficulty", {
        Values = { "Easy", "Normal", "Hard", "Nightmare", "Endless" },
        Default = "Easy",
        Text = "Difficulty Select",
    })
    AQ:AddSlider("QueueDelay", { Text = "Queue Start Delay (s)", Default = 3, Min = 1, Max = 30, Rounding = 0 })

    local BR = TabsLobby.Autostart:AddRightGroupbox("Boss Rush Matchmaker", "zap")
    BR:AddLabel("<b>AUTO BOSS RUSH</b>", true)
    BR:AddDivider()
    BR:AddToggle("AutoQueueBossRush", { Text = "Auto Join Boss Rush", Default = false })
    BR:AddDropdown("QueueBossName", {
        Values = { "Cursed King", "Satori", "Anti Mage", "Great Mage" },
        Default = "Satori",
        Text = "Final Boss Select",
    })

    local CH = TabsLobby.Autostart:AddLeftGroupbox("Challenge Matchmaker", "sword")
    CH:AddLabel("<b>AUTO CHALLENGE</b>", true)
    CH:AddDivider()
    CH:AddToggle("AutoQueueChallenge", { Text = "Auto Join Challenge", Default = false })
    CH:AddDropdown("QueueChallengeName", {
        Values = { "Double Dungeon" },
        Default = "Double Dungeon",
        Text = "Challenge Select",
    })
    CH:AddDropdown("QueueChallengeDifficulty", {
        Values = { "Easy", "Normal", "Hard", "Nightmare" },
        Default = "Easy",
        Text = "Challenge Difficulty",
    })

    local RD = TabsLobby.Autostart:AddRightGroupbox("Raid Matchmaker", "swords")
    RD:AddLabel("<b>AUTO RAIDS</b>", true)
    RD:AddDivider()
    RD:AddToggle("AutoQueueRaid", { Text = "Auto Join Raid", Default = false })
    RD:AddDropdown("QueueRaidName", {
        Values = { "The First Test" },
        Default = "The First Test",
        Text = "Raid Select",
    })
    RD:AddDropdown("QueueRaidDifficulty", {
        Values = { "Normal", "Extreme", "Impossible" },
        Default = "Normal",
        Text = "Raid Difficulty",
    })
end

do
    local AS = TabsLobby.Gear:AddLeftGroupbox("Equipment Seller", "dollar-sign")
    AS:AddLabel("<b>AUTO SELL INVENTORY</b>", true)
    AS:AddDivider()
    AS:AddToggle("AutoSellEnabled", { Text = "Auto Sell Gear", Default = false })
    AS:AddDropdown("SellRarities", {
        Values = { "Common", "Uncommon", "Rare", "Epic", "Legendary", "Mythic", "Celestial" },
        Default = {},
        Multi = true,
        Text = "Auto Sell Rarities",
    })


    local EQ = TabsLobby.Gear:AddLeftGroupbox("Gear Optimization", "shield")
    EQ:AddLabel("<b>WEAR HIGHEST SCORE</b>", true)
    EQ:AddDivider()
    EQ:AddToggle("AutoEquipBest", { Text = "Auto Wear Highest Score Gear", Default = false })
end

do
    local RS = TabsLobby.Summon:AddLeftGroupbox("Class Roller", "sparkles")
    RS:AddLabel("<b>AUTOMATED ROLLING</b>", true)
    RS:AddDivider()
    RS:AddToggle("AutoSummon", { Text = "Auto Spin Roll", Default = false })
    RS:AddDropdown("SummonSlot", {
        Values = { "1", "2", "3", "4", "5" },
        Default = "1",
        Text = "Summon Slot Target",
    })
    RS:AddToggle("SummonUseLucky", { Text = "Use Lucky Spins First", Default = false })

    local FS = TabsLobby.Summon:AddRightGroupbox("Roller Filters", "list-filter-plus")
    FS:AddLabel("<b>STOP AT CLASSES</b>", true)
    FS:AddDivider()
    FS:AddDropdown("StopSummonClasses", {
        Values = sortedClassValues,
        Default = {},
        Multi = true,
        Text = "Stop At Target Classes",
        Tooltip = "Auto roll stops ONLY when a target class AND target aspect are both met in the active slot"
    })
    FS:AddDivider()
    FS:AddLabel("<b>STOP AT ASPECTS</b>", true)
    FS:AddDivider()
    FS:AddDropdown("StopSummonAspects", {
        Values = sortedAspectValues,
        Default = {},
        Multi = true,
        Text = "Stop At Target Aspects",
        Tooltip = "Auto roll stops ONLY when a target class AND target aspect are both met in the active slot"
    })

    local SlotPanel = TabsLobby.Summon:AddLeftGroupbox("Slot Overview", "layout-grid")
    local slotLabels = {}
    local activeSlotLabel = SlotPanel:AddLabel("<b>Active Slot: </b><font color=\"#fbbf24\">Loading...</font>", true)
    SlotPanel:AddDivider()

    for i = 1, 5 do
        slotLabels[i] = SlotPanel:AddLabel("<b>Slot " .. i .. ": </b><font color=\"#6b7280\">Locked 🔒</font>", true)
    end

    task.spawn(function()
        while not Library.Unloaded do
            task.wait(1.5)
            local slotData = getSummonSlotData()

            if slotData and type(slotData) == "table" then
                local activeIdx = slotData.ActiveIndex or 0
                activeSlotLabel:SetText("<b>Active Slot: </b><font color=\"#4ade80\">#" .. tostring(activeIdx) .. "</font>")

                for i = 1, 5 do
                    local className = slotData.Slots and slotData.Slots[i]
                    local aspect = slotData.SlotAspects and slotData.SlotAspects[i]
                    local isUnlocked = className ~= nil

                    if not isUnlocked then
                        slotLabels[i]:SetText("<b>Slot " .. i .. ": </b><font color=\"#6b7280\">Locked 🔒</font>")
                    elseif className == "" then
                        slotLabels[i]:SetText("<b>Slot " .. i .. ": </b><font color=\"#9ca3af\">Empty</font>")
                    else
                        local rarity = CLASS_RARITY_MAP[className] or "Common"
                        local color = RARITY_COLORS[rarity] or "#ffffff"
                        local activeMark = (i == activeIdx) and " <font color=\"#4ade80\">[ACTIVE]</font>" or ""

                        local aspectTag = ""
                        if aspect and aspect ~= "" then
                            local aspectRarity = ASPECT_RARITY_MAP[aspect]
                            local aspectColor = aspectRarity and ASPECT_COLORS[aspectRarity] or "#a78bfa"
                            aspectTag = string.format(" <font color=\"%s\">(%s)</font>", aspectColor, aspect)
                        end

                        slotLabels[i]:SetText(string.format(
                            "<b>Slot %d: </b><font color=\"%s\">%s [%s]</font>%s%s",
                            i, color, className, rarity, aspectTag, activeMark
                        ))
                    end
                end
            end
        end
    end)
end

do
    -- ══════════════════════════════════════════
    --   REGULAR SHOP TAB
    -- ══════════════════════════════════════════
    local RS = TabsLobby.Shop:AddLeftGroupbox("Regular Shop", "shopping-bag")
    RS:AddLabel("<b>AUTO BUY REGULAR SHOP</b>", true)
    RS:AddDivider()
    RS:AddToggle("AutoBuyMerchant", { Text = "Auto Purchase Shop Stock", Default = false })
    RS:AddDropdown("BuyRarities", {
        Values = { "Common", "Uncommon", "Rare", "Epic", "Legendary", "Mythic", "Celestial" },
        Default = {},
        Multi = true,
        Text = "Target Buying Rarities",
    })

    local RSInfo = TabsLobby.Shop:AddRightGroupbox("Regular Shop Stock", "list")
    local RSStockLabels = {}
    for i = 1, 6 do
        RSStockLabels[i] = RSInfo:AddLabel(string.format("<b>Slot %d:</b> <font color=\"#9ca3af\">Loading...</font>", i), true)
    end

    task.spawn(function()
        while not Library.Unloaded do
            task.wait(4)
            local shopInfo = nil
            pcall(function() shopInfo = dl_GetShopInfo:InvokeServer() end)
            if type(shopInfo) == "table" then
                for i = 1, 6 do
                    local item = shopInfo[i]
                    if item then
                        local rarity = item.Rarity or "Common"
                        local color = RARITY_COLORS[rarity] or "#ffffff"
                        local name = item.Id or item.ItemId or "Unknown"
                        local cost = item.Cost or 0
                        RSStockLabels[i]:SetText(string.format(
                            "<b>Slot %d:</b> <font color=\"%s\">%s [%s]</font> - <font color=\"#fbbf24\">%s coins</font>",
                            i, color, name, rarity, formatNumber(cost)
                        ))
                    else
                        RSStockLabels[i]:SetText(string.format("<b>Slot %d:</b> <font color=\"#6b7280\">Empty</font>", i))
                    end
                end
            end
        end
    end)

    -- ══════════════════════════════════════════
    --   MYSTERY MERCHANT TAB
    -- ══════════════════════════════════════════
    local MM = TabsLobby.Shop:AddLeftGroupbox("Mystery Merchant", "sparkles")
    MM:AddLabel("<b>AUTO BUY MYSTERY MERCHANT</b>", true)
    MM:AddDivider()
    MM:AddToggle("AutoBuyMystery", { Text = "Auto Buy Mystery Merchant", Default = false })
    MM:AddDropdown("MysteryBuyMode", {
        Values = { "Single", "Max" },
        Default = "Max",
        Text = "Purchase Amount Mode",
        Tooltip = "Single = buy 1x per stock slowly. Max = buy up to full limit faster."
    })

    local mmCatalogValues = {
        "AspectGem [Consumable]",
        "ExoticOre [Common]",
        "ExoticEssence [Common]",
        "ReforgeStone [Common]",
        "ProtectionScroll [Common]",
        "ProjectionReel [Legendary]",
        "LuckySpin [Uncommon]",
        "PurityStone [Common]",
        "LuckPotionT1 [Common]",
        "LuckPotionT2 [Uncommon]",
        "LuckPotionT3 [Rare]",
        "CrimsonNinja [Cosmetic]",
        "ForgeArchonAltBlack [Cosmetic]",
        "ShadowKnight [Cosmetic]",
        "Restricted [Cosmetic]",
        "VoidKatana [Exotic]",
        "InfinityCore [Exotic]",
        "CursedShrine [Exotic]",
        "FirelordCap [Exotic]",
        "LivingArmor [Exotic]",
        "SupernovaRing [Exotic]",
        "RandomGMBlessing [Package]"
    }

    MM:AddDropdown("MysteryBuyList", {
        Values = mmCatalogValues,
        Default = {},
        Multi = true,
        Text = "Items to Auto Buy",
    })

    -- ══════════════════════════════════════════
    --   RAID SHOP GROUPBOX
    -- ══════════════════════════════════════════
    local RDShop = TabsLobby.Shop:AddLeftGroupbox("Event Raid Shop", "swords")
    RDShop:AddLabel("<b>AUTO BUY RAID SHOP</b>", true)
    RDShop:AddDivider()
    RDShop:AddToggle("AutoBuyRaidShop", { Text = "Auto Buy Raid Shop", Default = false })

    local raidShopCatalogValues = {
        "Aspect Gem [Consumable]",
        "Protection Scroll [ProtectionScroll]",
        "Reforge Stone [CraftingMaterial]",
        "Exotic Ore [CraftingMaterial]",
        "Exotic Essence [CraftingMaterial]",
        "Mythic Chest [Package]",
        "Celestial Chest [Package]",
        "Normal Event Chest [Package]",
        "Extreme Event Chest [Package]",
        "Impossible Event Chest [Package]",
        "Moria Blade [ClassItem]",
        "Frost Wisteria Wand [ClassItem]",
        "Magia Revenda [Title]",
        "Might of Courage [Title]",
        "Spellbreaker [Cosmetic]",
        "Cryomancer [Cosmetic]",
        "Pyromancer [Cosmetic]",
        "Ice Queen Aura [Cosmetic]",
        "Blaze Aura [Cosmetic]",
        "White Spellweaver [Cosmetic]",
        "Ice Queen [Cosmetic]"
    }

    RDShop:AddDropdown("RaidBuyList", {
        Values = raidShopCatalogValues,
        Default = {},
        Multi = true,
        Text = "Items to Auto Buy",
    })

    local MMInfo = TabsLobby.Shop:AddRightGroupbox("Mystery Merchant Stock", "sparkles")
    local MMStatusLabel = MMInfo:AddLabel("<b>Status:</b> <font color=\"#9ca3af\">Loading...</font>", true)
    MMInfo:AddDivider()
    local MMStockLabels = {}
    for i = 1, 6 do
        MMStockLabels[i] = MMInfo:AddLabel(string.format("<b>Slot %d:</b> <font color=\"#9ca3af\">Loading...</font>", i), true)
    end

    task.spawn(function()
        while not Library.Unloaded do
            task.wait(5)
            local shopInfo = nil
            pcall(function() shopInfo = dl_MM_GetShopInfo:InvokeServer() end)
            if type(shopInfo) == "table" then
                local isActive = shopInfo.Active == true
                local statusText
                if isActive then
                    local timeLeft = math.max(0, (shopInfo.LeavesAt or 0) - os.time())
                    statusText = string.format("<font color=\"#4ade80\">ACTIVE</font> - <font color=\"#fbbf24\">%s left</font>", formatDuration(timeLeft))
                else
                    local timeUntil = math.max(0, (shopInfo.ArrivesAt or shopInfo.NextArrival or 0) - os.time())
                    statusText = string.format("<font color=\"#ef4444\">INACTIVE</font> - Next: <font color=\"#fbbf24\">%s</font>", formatDuration(timeUntil))
                end
                MMStatusLabel:SetText("<b>Status:</b> " .. statusText)

                local items = shopInfo.Items or {}
                for i = 1, 6 do
                    local item = items[i]
                    if item then
                        local rarity = item.Rarity or item.Kind or "Common"
                        local color = RARITY_COLORS[rarity] or "#ffffff"
                        local name = item.Id or "Unknown"
                        local cost = item.Cost or 0
                        local purchased = item.Purchased or 0
                        local limit = item.PurchaseLimit or 1
                        MMStockLabels[i]:SetText(string.format(
                            "<b>Slot %d:</b> <font color=\"%s\">%s [%s]</font> - <font color=\"#fbbf24\">%s coins</font> (%d/%d)",
                            i, color, name, rarity, formatNumber(cost), purchased, limit
                        ))
                    else
                        MMStockLabels[i]:SetText(string.format("<b>Slot %d:</b> <font color=\"#6b7280\">Empty</font>", i))
                    end
                end
            else
                MMStatusLabel:SetText("<b>Status:</b> <font color=\"#ef4444\">Failed to fetch</font>")
            end
        end
    end)
end

do
    local ASG = TabsLobby.Misc:AddLeftGroupbox("Auto Allocate Stats", "list")
    ASG:AddLabel("<b>AUTO STATS</b>", true)
    ASG:AddDivider()
    ASG:AddToggle("AutoAllocate", { Text = "Auto Allocate Unspent Points", Default = false })
    ASG:AddDropdown("AllocateTarget", {
        Values = { "STR", "DEX", "INT", "VIT" },
        Default = "STR",
        Text = "Stat Target",
    })

    local AQM = TabsLobby.Misc:AddRightGroupbox("Daily & Weekly Quests", "scroll")
    AQM:AddLabel("<b>QUEST REWARDS</b>", true)
    AQM:AddDivider()
    AQM:AddToggle("AutoClaimQuests", { Text = "Auto Claim Quests", Default = false })
end

-- ══════════════════════════════════════════
--   DUNGEON SUBTABS (MAIN / FARM / LOOT)
-- ══════════════════════════════════════════

do
    function makeTargetList(maxVal)
        local t = {}
        for i = 1, maxVal do table.insert(t, tostring(i)) end
        return t
    end

    local DG = TabsDungeon.Main:AddLeftGroupbox("Dungeon", "castle")
    DG:AddDropdown("DungeonEndAction", {
        Values  = { "Replay", "Return" },
        Default = "Replay",
        Text    = "Dungeon End Action",
        Tooltip = "Triggered automatically when the Dungeon End UI appears.",
    })
    DG:AddDropdown("EndlessExtractCheckpoint", {
        Values  = (function()
            local t = {}
            for i = 0, 1000 do table.insert(t, tostring(i)) end
            return t
        end)(),
        Default = "0",
        Text    = "Endless Extract Checkpoint",
        Tooltip = "0 = Never extract. Any other N = Extract at checkpoint N or greater.",
    })

    local BR_Ctrl = TabsDungeon.Main:AddLeftGroupbox("Boss Rush", "zap")
    BR_Ctrl:AddDropdown("BossRushEndAction", {
        Values = { "Disabled", "Replay At End", "Return At End", "Custom Replay", "Custom Return" },
        Default = "Disabled",
        Text = "End Action",
    })
    BR_Ctrl:AddDropdown("BossRushCustomTarget", {
        Values = makeTargetList(100),
        Default = "1",
        Text = "Replay/Return At Room",
    })

    local CH_Ctrl = TabsDungeon.Main:AddLeftGroupbox("Challenge", "sword")
    CH_Ctrl:AddDropdown("ChallengeEndAction", {
        Values = { "Disabled", "Replay At End", "Return At End", "Custom Replay", "Custom Return" },
        Default = "Disabled",
        Text = "End Action",
    })
    CH_Ctrl:AddDropdown("ChallengeCustomTarget", {
        Values = makeTargetList(900),
        Default = "1",
        Text = "Replay/Return At Wave",
    })

    local RD_Ctrl = TabsDungeon.Main:AddLeftGroupbox("Event Raid", "swords")
    RD_Ctrl:AddDropdown("RaidEndAction", {
        Values = { "Disabled", "Replay At End", "Return At End", "Custom Replay", "Custom Return" },
        Default = "Disabled",
        Text = "End Action",
    })
    RD_Ctrl:AddDropdown("RaidCustomTarget", {
        Values = makeTargetList(50),
        Default = "1",
        Text = "Replay/Return At Phase",
    })

    local Status = TabsDungeon.Main:AddRightGroupbox("Match Coordinator", "compass")
    local ModeLabel         = Status:AddLabel(b("Active Mode: ") .. c("Lobby", "#9ca3af"), true)
    local RoomLabel         = Status:AddLabel(b("Progress Ref: ") .. c("None", "#60a5fa"), true)
    local StateLabel        = Status:AddLabel(b("Room State: ") .. c("Idle", "#f59e0b"), true)
    local SequenceLabel     = Status:AddLabel(b("Sequence: ") .. c("None", "#a78bfa"), true)
    local MobsInRoomLabel   = Status:AddLabel(b("Active Mobs: ") .. c("0", "#ef4444"), true)
    local ChestsInRoomLabel = Status:AddLabel(b("Chests in Room: ") .. c("0", "#fbbf24"), true)
    local LootRoomsLabel    = Status:AddLabel(b("Loot Rooms Done: ") .. c("0", "#f472b6"), true)
    local LockedRoomsLabel  = Status:AddLabel(b("Locked Rooms Done: ") .. c("0", "#fb923c"), true)
    local SpecialBossLabel  = Status:AddLabel(b("Special Bosses: ") .. c("0", "#ef4444"), true)
    local RoomsDoneLabel    = Status:AddLabel(b("Rooms Cleared: ") .. c("0", "#4ade80"), true)
    local CheckpointLabel   = Status:AddLabel(b("Endless CP: ") .. c("0", "#38bdf8"), true)
    Status:AddDivider()

    Status:AddSlider("LobbyReturnDelay", {
        Text = "Lobby Return Delay",
        Default = 0,
        Min = 0,
        Max = 15,
        Rounding = 0,
    })

    Status:AddButton({
        Text = "Re-Extract Zone Layout",
        Func = function()
            forceResetAndReextract("Manual Trigger")
        end
    })

    Status:AddButton({
        Text = "Force Reset Farm State",
        Func = function()
            activeSequence = {}
            activeSequenceIndex = 1
            activeRoomModel = nil
            cachedRoomCF = nil
            cachedRoomSize = nil
            lootRoomQueue = {}
            lootRoomIndex = 0
            currentLootRoomModel = nil
            cachedLootRoomCF = nil
            cachedLootRoomSize = nil
            isFarmingLootRoom = false
            isFarmingLockedRoom = false
            currentLockedRoomModel = nil
            cachedLockedRoomCF = nil
            cachedLockedRoomSize = nil
            isUnlockingRoom = false
            isFarmingSpecialBoss = false
            currentSpecialBossRoom = nil
            cachedSpecialBossCF = nil
            cachedSpecialBossSize = nil
            isSummoningBoss = false
            dungeonFullyCompleted = false
            activeDungeonId = nil
            dlf_currentTarget = nil
            isCollectingChest = false
            isInteractingAltar = false
            consumedAltars = {}
            collectedChests = {}
            unlockedLockedRooms = {}
            processedSpecialBossRooms = {}
            endlessContinuePending = false
            endlessContinueUntil = 0
            _G.BossRushCustomActionQueue = nil
            _G.ChallengeCustomActionQueue = nil
            _G.RaidCustomActionQueue = nil
            dl_farm_paused = false
        end
    })

    task.spawn(function()
        while not Library.Unloaded do
            task.wait(0.5)
            local currentMode = getGameMode()
            SessionStats.activeGamemode = currentMode

            ModeLabel:SetText(b("Active Mode: ") .. c(currentMode:upper(), "#38bdf8"))
            StateLabel:SetText(b("Room State: ") .. c(SessionStats.roomStateText, "#f59e0b"))
            RoomsDoneLabel:SetText(b("Rooms Cleared: ") .. c(tostring(SessionStats.roomsCleared), "#4ade80"))
            LootRoomsLabel:SetText(b("Loot Rooms Done: ") .. c(tostring(SessionStats.lootRoomsCleared), "#f472b6"))
            LockedRoomsLabel:SetText(b("Locked Rooms Done: ") .. c(tostring(SessionStats.lockedRoomsUnlocked), "#fb923c"))
            SpecialBossLabel:SetText(b("Special Bosses: ") .. c(tostring(SessionStats.specialBossesDefeated), "#ef4444"))
            CheckpointLabel:SetText(b("Endless CP: ") .. c(tostring(SessionStats.endlessCheckpoint), "#38bdf8"))

            if currentMode == "Dungeon" then
                RoomLabel:SetText(b("Progress Ref: ") .. c(SessionStats.currentRoomText, "#60a5fa"))
                if #activeSequence > 0 then
                    local seq = {}
                    for idx, z in ipairs(activeSequence) do
                        if idx == activeSequenceIndex then
                            table.insert(seq, string.format("<b>[%d]</b>", z.Index))
                        else
                            table.insert(seq, tostring(z.Index))
                        end
                    end
                    SequenceLabel:SetText(b("Sequence: ") .. c(table.concat(seq, " -> "), "#a78bfa"))
                else
                    SequenceLabel:SetText(b("Sequence: ") .. c("None", "#9ca3af"))
                end
            elseif currentMode == "BossRush" then
                local rm = dl_getBossRushCurrentRoom() or 0
                local lv = dl_getBossRushLives() or 0
                RoomLabel:SetText(b("Progress Ref: ") .. c(string.format("Room %d (Lives: %d)", rm, lv), "#f472b6"))
                SequenceLabel:SetText(b("Sequence: ") .. c("Boss Rush Mode Active", "#a78bfa"))
            elseif currentMode == "Challenge" then
                local wv = dl_getChallengeCurrentWave() or 0
                RoomLabel:SetText(b("Progress Ref: ") .. c(string.format("Wave %d", wv), "#fbbf24"))
                SequenceLabel:SetText(b("Sequence: ") .. c("Challenge Defense Mode Active", "#a78bfa"))
            elseif currentMode == "Raid" then
                local ph = dl_getRaidCurrentPhase() or 0
                RoomLabel:SetText(b("Progress Ref: ") .. c(string.format("Phase %d", ph), "#f472b6"))
                SequenceLabel:SetText(b("Sequence: ") .. c("Event Raid Mode Active", "#a78bfa"))
            else
                RoomLabel:SetText(b("Progress Ref: ") .. c("Outside Gameplay Instance", "#9ca3af"))
                SequenceLabel:SetText(b("Sequence: ") .. c("None (Lobby)", "#9ca3af"))
            end

            local enemyCount = #dl_getEnemiesInCurrentRoom()
            MobsInRoomLabel:SetText(b("Active Mobs: ") .. c(tostring(enemyCount), enemyCount > 0 and "#ef4444" or "#4ade80"))

            local chestCount = #dl_getChestsInCurrentRoom()
            ChestsInRoomLabel:SetText(b("Chests in Room: ") .. c(tostring(chestCount), chestCount > 0 and "#fbbf24" or "#9ca3af"))
        end
    end)
end

do
    local FG = TabsDungeon.Farm:AddLeftGroupbox("Mob Farm Engine", "target")
    FG:AddToggle("AutoFarm", { Text = "Auto Farm Mobs", Default = false })
    FG:AddDropdown("MobPriority1", {
        Values   = { "None", "Archer", "Healer" },
        Default  = "None",
        Text     = "Target Priority 1",
    })
    FG:AddDropdown("MobPriority2", {
        Values   = { "None", "Archer", "Healer" },
        Default  = "None",
        Text     = "Target Priority 2",
    })
    FG:AddDivider()
    FG:AddDropdown("FarmMode", {
        Values   = { "Above Head", "Orbiting", "Behind", "Same Level", "Under" },
        Default  = "Above Head",
        Text     = "Relative Positioning",
        Callback = function(v) dl_farm_mode = v; dlf_orbitAngle = 0 end,
    })
    FG:AddDropdown("FarmMethod", {
        Values   = { "Teleport", "Tween" },
        Default  = "Teleport",
        Text     = "Movement Type",
        Callback = function(v) dl_farm_method = v end,
    })
    FG:AddSlider("FarmHeight", { Text = "Target Height Offset", Default = 11, Min = -30, Max = 50, Rounding = 0, Callback = function(v) dl_farm_height = v end })
    FG:AddSlider("TweenSpeed", { Text = "Tween Transition Speed", Default = 95, Min = 20, Max = 250, Rounding = 0, Callback = function(v) dl_tween_speed = v end })

    local Ob = TabsDungeon.Farm:AddRightGroupbox("Orbit Settings", "compass")
    Ob:AddSlider("OrbitRadius", { Text = "Orbit Radius", Default = 14, Min = 5, Max = 50, Rounding = 0, Callback = function(v) dl_farm_orbit_radius = v end })
    Ob:AddSlider("OrbitSpeed",  { Text = "Orbit Rotational Speed", Default = 1.8, Min = 0.5, Max = 10, Rounding = 1, Callback = function(v) dl_farm_orbit_speed = v end })

    local SAuto = TabsDungeon.Farm:AddRightGroupbox("Misc", "settings")
    SAuto:AddToggle("AutoUnlockSideRooms", { Text = "Auto Unlock Side Rooms", Default = true, Tooltip = "After clearing room, unlock connected Locked_N side rooms via KeyModel prompt, then tween to chests." })
    SAuto:AddToggle("AutoFightPrespawnedBoss", { Text = "Auto Fight Prespawned Special Boss", Default = true, Tooltip = "Fights prespawned special boss (e.g. Scarlet Knight) if it already exists inside room." })
    SAuto:AddToggle("AutoSummonSpecialBoss", { Text = "Auto Summon Special Boss", Default = false, Tooltip = "Uses Skull_Totem to summon a new special boss (consumes Celestial Keys)." })
    SAuto:AddToggle("AutoDisableM1OnCrystal", { Text = "Auto Disable M1 on Crystal", Default = false, Tooltip = "Forcefully disables basic auto attacks (M1) when attacking crystals (skills will still fire)." })
end

Toggles.AutoFarm:OnChanged(function(v)
    if v then
        dlf_orbitAngle = 0
        dungeonFullyCompleted = false
        dlf_startMovement()
    else
        dlf_stopMovement()
    end
end)

do
    local BL = TabsDungeon.LootBlessings:AddLeftGroupbox("Blessing Priority", "sparkles")
    BL:AddToggle("AutoBlessing", { Text = "Auto Select Blessing", Default = true })
    BL:AddDivider()
    BL:AddLabel(c("Higher number (1-14) = Higher priority", "#9ca3af"), true)
    BL:AddDivider()

    for _, buff in ipairs(BUFF_DEFINITIONS) do
        BL:AddSlider(buff.Key, {
            Text     = buff.Title,
            Default  = buff.Default,
            Min      = 1,
            Max      = 14,
            Rounding = 0,
            Tooltip  = buff.Desc .. " — Set priority score (14 is highest)"
        })
    end

    local LT = TabsDungeon.LootBlessings:AddRightGroupbox("Chest & Drop Engine", "gift")
    LT:AddToggle("AutoPickChests", { Text = "Auto Pick 2 Best Chests", Default = true, Tooltip = "Automatically chooses the 2 highest rarity/value chests and presses Finish" })
    LT:AddToggle("AutoPickAllChests", { Text = "Auto Pick All 3 Chests (Gamepass)", Default = false, Tooltip = "Automatically clicks all 3 chests and presses Finish (Requires Extra Chest Gamepass)" })
    LT:AddDivider()
    LT:AddToggle("AutoCollectChests", { Text = "Auto Collect Chests (Per-Room Strict)", Default = true, Tooltip = "Sweeps and tweens character to chests belonging to each specific room before advancing" })
    LT:AddDivider()
    LT:AddToggle("AutoMagnetLoot", { Text = "Auto Magnet Drops", Default = true, Tooltip = "Magnets dropped Items, Keys, and Health to your character" })
end

do
    local PT = TabsDungeon.Potion:AddLeftGroupbox("Potions", "flask-round")
    PT:AddToggle("AutoUsePotion", { 
        Text = "Auto Use Potion", 
        Default = false, 
        Tooltip = "Automatically uses a potion when your health drops below the target threshold." 
    })
    PT:AddSlider("PotionHPPercent", { 
        Text = "HP % Trigger Threshold", 
        Default = 50, 
        Min = 1, 
        Max = 100, 
        Rounding = 0,
        Tooltip = "Uses potion when HP drops below this percentage."
    })
end

-- ══════════════════════════════════════════
--   BLESSING & CHEST AUTO ROUTINES
-- ══════════════════════════════════════════

local lastBlessingPickTime = 0
task.spawn(function()
    while not Library.Unloaded do
        task.wait(0.03)
        if isOn("AutoBlessing") then
            local pGui = LocalPlayer:FindFirstChild("PlayerGui")
            local hud = pGui and pGui:FindFirstChild("Main") and pGui.Main:FindFirstChild("HUD")
            local boostGui = hud and hud:FindFirstChild("Boost_Selection")

            if boostGui and dl_isGuiObjectVisible(boostGui) and (tick() - lastBlessingPickTime > 0.8) then
                local candidates = {}

                for i = 1, 3 do
                    local bBtn = boostGui:FindFirstChild("Boost_" .. tostring(i))
                    if bBtn and dl_isGuiObjectVisible(bBtn) then
                        local titleLabel = bBtn:FindFirstChild("Title")
                        if titleLabel and titleLabel:IsA("TextLabel") then
                            local titleText = titleLabel.Text:gsub("^%s*(.-)%s*$", "%1")
                            local sliderKey = "BuffPrio_" .. titleText:gsub("%s+", "_"):gsub("[^%w_]", "")
                            local prio = getNumber(sliderKey, 7)
                            table.insert(candidates, {
                                button   = bBtn,
                                title    = titleText,
                                priority = prio,
                                index    = i
                            })
                        end
                    end
                end

                if #candidates > 0 then
                    local highestPrio = -1
                    for _, cand in ipairs(candidates) do
                        if cand.priority > highestPrio then
                            highestPrio = cand.priority
                        end
                    end

                    local topCandidates = {}
                    for _, cand in ipairs(candidates) do
                        if cand.priority == highestPrio then
                            table.insert(topCandidates, cand)
                        end
                    end

                    local chosen = topCandidates[math.random(1, #topCandidates)]
                    if chosen and chosen.button then
                        lastBlessingPickTime = tick()
                        vimClick(chosen.button)
                    end
                end
            end
        end
    end
end)

local lastChestPickTime = 0
task.spawn(function()
    while not Library.Unloaded do
        task.wait(0.04)
        local shouldPickAll = isOn("AutoPickAllChests")
        local shouldPickTwo = isOn("AutoPickChests")

        if shouldPickAll or shouldPickTwo then
            local pGui = LocalPlayer:FindFirstChild("PlayerGui")
            local hud = pGui and pGui:FindFirstChild("Main") and pGui.Main:FindFirstChild("HUD")
            local chestGui = hud and hud:FindFirstChild("Chest_Selection")

            if chestGui and dl_isGuiObjectVisible(chestGui) and (tick() - lastChestPickTime > 1.2) then
                lastChestPickTime = tick()
                task.wait(0.04)

                local maxPicks = shouldPickAll and 3 or 2
                local scoredChests = {}

                if latestChestData and type(latestChestData) == "table" and #latestChestData >= 3 then
                    for idx, data in ipairs(latestChestData) do
                        local score = 0
                        if type(data) == "table" then
                            local r = data.Rarity or "Common"
                            score = (RARITY_LEVELS[r] or 1) * 1000
                            if data.Type == "Stars" then
                                score = 2500
                            elseif data.Type == "Equipment" then
                                score = score + (data.BaseDamage or 0) + (data.LevelReq or 0)
                            end
                        end
                        table.insert(scoredChests, { index = idx, score = score })
                    end
                else
                    for i = 1, 3 do
                        local cBtn = chestGui:FindFirstChild("Chest_" .. i)
                        local score = 1000
                        if cBtn and cBtn:FindFirstChild("ItemTemplate") then
                            score = 2000
                        end
                        table.insert(scoredChests, { index = i, score = score + (3 - i) })
                    end
                end

                table.sort(scoredChests, function(a, b) return a.score > b.score end)

                for i = 1, math.min(maxPicks, #scoredChests) do
                    local chestIdx = scoredChests[i].index
                    local btn = chestGui:FindFirstChild("Chest_" .. tostring(chestIdx))
                    if btn and dl_isGuiObjectVisible(btn) then
                        vimClick(btn)
                        task.wait(0.05)
                    end
                end

                task.wait(0.06)
                local finishBtn = chestGui:FindFirstChild("Finish")
                if finishBtn and dl_isGuiObjectVisible(finishBtn) then
                    vimClick(finishBtn)
                end

                latestChestData = nil
            end
        end
    end
end)

task.spawn(function()
    while not Library.Unloaded do
        task.wait(0.25)
        if isOn("AutoMagnetLoot") then
            local hrp = dl_getHRP()
            if hrp then
                local playerPos = hrp.Position
                local maxDist = 1000

                function magnetize(inst)
                    if not inst then return end
                    local part = inst:IsA("BasePart") and inst or inst:FindFirstChildWhichIsA("BasePart", true)
                    if part and part.Parent then
                        local dist = (part.Position - playerPos).Magnitude
                        if dist <= maxDist then
                            pcall(function()
                                part.CanCollide = false
                                part.CFrame = hrp.CFrame
                                part.Velocity = Vector3.zero
                                part.RotVelocity = Vector3.zero
                                pcall(function() part.AssemblyLinearVelocity = Vector3.zero end)
                            end)
                        end
                    end
                end

                for _, child in ipairs(workspace:GetChildren()) do
                    local name = child.Name
                    if name == "Item" or name == "Key" or name == "Health" or name:match("^Drop_") or name:match("^Item_") or name:match("^Pickup_") then
                        magnetize(child)
                    end
                end

                local dungeon = dl_getGeneratedDungeon()
                if dungeon then
                    local dropsFolder = dungeon:FindFirstChild("Drops") or dungeon:FindFirstChild("Items")
                    if dropsFolder then
                        for _, d in ipairs(dropsFolder:GetChildren()) do
                            magnetize(d)
                        end
                    end
                end
            end
        end
    end
end)

-- ══════════════════════════════════════════
--   COMBAT TAB & AUTONOMOUS DAMAGE LOOPS
-- ══════════════════════════════════════════

do
    local CG = Tabs.Combat:AddLeftGroupbox("Auto Combat", "swords")
    CG:AddToggle("AutoAttack", { Text = "Auto Attack", Default = true })
    CG:AddDivider()
    CG:AddToggle("AutoSkill1", { Text = "Auto Skill 1", Default = true })
    CG:AddToggle("AutoSkill2", { Text = "Auto Skill 2", Default = true })
    CG:AddToggle("AutoSkill3", { Text = "Auto Skill 3", Default = true })
    CG:AddToggle("AutoSkill4", { Text = "Auto Skill 4", Default = true })
    CG:AddToggle("AutoSpamSkills", { Text = "Auto Spam Skills", Default = false })
    CG:AddDivider()
    CG:AddToggle("AutoUltimate", { Text = "Auto Ultimate", Default = false })

    local DG = Tabs.Combat:AddRightGroupbox("Defensive Systems", "shield")
    DG:AddToggle("AutoParry", { Text = "Auto Parry", Default = false })
    DG:AddToggle("AutoDodge", { Text = "Auto Dodge Red Circle", Default = true })
end

-- ══════════════════════════════════════════
--   FLAGS TAB - ANTICHEAT TELEMETRY VIEW
-- ══════════════════════════════════════════
do
    local FL = Tabs.Flags:AddLeftGroupbox("Active Profile Flags", "shield-alert")
    local LifetimeLabel = FL:AddLabel("<b>Lifetime Flags logged:</b> <font color=\"#ffffff\">Loading...</font>", true)
    local ActiveLabel   = FL:AddLabel("<b>Active Flags (Database):</b> <font color=\"#ffffff\">Loading...</font>", true)
    FL:AddDivider()

    local ReachLabel     = FL:AddLabel("<b>VerticalReachCamp:</b> <font color=\"#4ade80\">x0</font>", true)
    local WarpLabel      = FL:AddLabel("<b>ChestZoneWarp:</b> <font color=\"#4ade80\">x0</font>", true)
    local ClassLabel     = FL:AddLabel("<b>InDungeonClassChange:</b> <font color=\"#4ade80\">x0</font>", true)
    local CooldownLabel  = FL:AddLabel("<b>SkillCooldownReset:</b> <font color=\"#4ade80\">x0</font>", true)
    local FloodLabel     = FL:AddLabel("<b>ChestClaimFlood:</b> <font color=\"#4ade80\">x0</font>", true)

    local FP = Tabs.Flags:AddRightGroupbox("Prevent Flags", "shield-check")

    FP:AddLabel("<font color=\"#f472b6\"><b>1.VerticalReachCamp:</b></font>\nAvoid hovering stationary in the air. Set <b>Relative Positioning</b> to <font color=\"#fbbf24\">Orbiting</font> or <font color=\"#fbbf24\">Behind</font>. Keep <b>Target Height Offset</b> at <font color=\"#fbbf24\">4 to 6</font> studs so you stay close to the ground.", true)
    FP:AddDivider()
    FP:AddLabel("<font color=\"#38bdf8\"><b>2.ChestZoneWarp:</b></font>\nDo not teleport to or claim chests in rooms that have not officially cleared.", true)
    FP:AddDivider()
    FP:AddLabel("<font color=\"#a78bfa\"><b>3.InDungeonClassChange:</b></font>\nTurn off <font color=\"#fbbf24\">Auto Summon / Auto Spin</font> before joining a dungeon. The summoning logic must only execute inside the Lobby map.", true)

    -- Background Thread to update telemetry in real-time
    task.spawn(function()
        while not Library.Unloaded do
            task.wait(1.5)
            local pd = getPlayerData()
            if pd then
                local flags = pd.ModerationFlags or {}
                local lifetimeCount = pd.ModerationFlags_Lifetime or 0

                LifetimeLabel:SetText(string.format("<b>Lifetime Flags logged:</b> <font color=\"#ef4444\">%d</font>", lifetimeCount))
                ActiveLabel:SetText(string.format("<b>Active Flags (Database):</b> <font color=\"#fb923c\">%d</font>", #flags))

                local cats = {
                    VerticalReachCamp = 0,
                    ChestZoneWarp = 0,
                    InDungeonClassChange = 0,
                    SkillCooldownReset = 0,
                    ChestClaimFlood = 0
                }

                for _, entry in ipairs(flags) do
                    local cat = entry.Category
                    if cat and cats[cat] ~= nil then
                        cats[cat] = cats[cat] + 1
                    end
                end

                -- Format colors dynamically based on count severity
                function getColor(count)
                    if count == 0 then return "#4ade80" end
                    if count < 5 then return "#fbbf24" end
                    return "#ef4444"
                end

                ReachLabel:SetText(string.format("<b>VerticalReachCamp:</b> <font color=\"%s\">x%d</font>", getColor(cats.VerticalReachCamp), cats.VerticalReachCamp))
                WarpLabel:SetText(string.format("<b>ChestZoneWarp:</b> <font color=\"%s\">x%d</font>", getColor(cats.ChestZoneWarp), cats.ChestZoneWarp))
                ClassLabel:SetText(string.format("<b>InDungeonClassChange:</b> <font color=\"%s\">x%d</font>", getColor(cats.InDungeonClassChange), cats.InDungeonClassChange))
                CooldownLabel:SetText(string.format("<b>SkillCooldownReset:</b> <font color=\"%s\">x%d</font>", getColor(cats.SkillCooldownReset), cats.SkillCooldownReset))
                FloodLabel:SetText(string.format("<b>ChestClaimFlood:</b> <font color=\"%s\">x%d</font>", getColor(cats.ChestClaimFlood), cats.ChestClaimFlood))
            end
        end
    end)
end

function isSkillOnCD(idx)
    local ok, res = pcall(function()
        local pg = LocalPlayer:FindFirstChild("PlayerGui")
        local main = pg and pg:FindFirstChild("Main")
        local hud = main and main:FindFirstChild("HUD")
        local actions = hud and hud:FindFirstChild("Actions")
        local bottom = actions and actions:FindFirstChild("Bottom")
        local actionList = bottom and bottom:FindFirstChild("Actions")
        local slot = actionList and actionList:FindFirstChild(tostring(idx))

        if slot then
            local cd = slot:FindFirstChild("Cooldown")
            if cd and cd.Visible then
                local tl = cd:FindFirstChild("TextLabel") or cd:FindFirstChildOfClass("TextLabel")
                if tl and tl.Text ~= "" and tl.Text ~= "0s" and not tl.Text:lower():find("ready") then
                    return true
                end
            end
        end
        return false
    end)
    return ok and res == true
end

function isUltOnCD()
    local ok, res = pcall(function()
        local pg = LocalPlayer:FindFirstChild("PlayerGui")
        local sg = pg and pg:FindFirstChild("Skill_Gui")
        local sc = sg and sg:FindFirstChild("Skill_Canvas")
        local scd = sc and sc:FindFirstChild("Skill_CD")

        if scd and scd.Visible then
            local tl = scd:FindFirstChild("Time_Left")
            if tl and tl:IsA("TextLabel") and tl.Text ~= "" then
                if tl.Text:find("%d+s") then
                    return true
                end
            end
        end
        return false
    end)
    return ok and res == true
end

local lastSkillCastTimes = { [1] = 0, [2] = 0, [3] = 0, [4] = 0, ["E"] = 0 }
local lastM1Time = 0

-- M1 Auto Attack loop: Directional M1, high frequency (30 Hz) on Crystals
task.spawn(function()
    while not Library.Unloaded do
        task.wait(0.01)

        if isOn("AutoFarm") and not dl_farm_paused and not dungeonFullyCompleted and not isCollectingChest and not isInteractingAltar and not isUnlockingRoom and not isSummoningBoss and not endlessContinuePending and not isCharacterDead() then
            local target = dlf_currentTarget or dl_pickTarget()

            if target and dl_isNpcAlive(target.model) then
                local hrp = dl_getHRP()
                if hrp and target.part then
                    local now = tick()
                    local isCrystal = (target.model.Name == "Damage_Crystal" or target.model.Name:find("Crystal") ~= nil)

                    -- Check if M1 should be forcefully disabled on crystals
                    local m1DisabledOnCrystal = isCrystal and isOn("AutoDisableM1OnCrystal")

                    -- Dynamic firing interval override
                    local interval = isCrystal and 0.033 or 0.08
                    local shouldAttack = (isOn("AutoAttack") or isCrystal) and not m1DisabledOnCrystal

                    if shouldAttack and (now - lastM1Time >= interval) then
                        pcall(function()
                            local diff = target.part.Position - hrp.Position
                            local dir = diff.Magnitude > 0 and diff.Unit or Vector3.new(0, -1, 0)
                            r_Attack:FireServer(createVector(dir.X, dir.Y, dir.Z))
                            SessionStats.attacksFired = SessionStats.attacksFired + 1
                        end)
                        lastM1Time = now
                    end
                end
            end
        end
    end
end)

-- Skills Rotation loop: Executes Skills 1–4 on all targets (and Crystals)
task.spawn(function()
    while not Library.Unloaded do
        task.wait(0.02)

        if isOn("AutoFarm") and not dl_farm_paused and not dungeonFullyCompleted and not isCollectingChest and not isInteractingAltar and not isUnlockingRoom and not isSummoningBoss and not endlessContinuePending and not isCharacterDead() then
            local target = dlf_currentTarget or dl_pickTarget()

            if target and dl_isNpcAlive(target.model) then
                local hrp = dl_getHRP()
                if hrp and target.part then
                    local now = tick()
                    local isCrystal = (target.model.Name == "Damage_Crystal" or target.model.Name:find("Crystal") ~= nil)

                    local diff = target.part.Position - hrp.Position
                    local dir = diff.Magnitude > 0 and diff.Unit or Vector3.new(0, -1, 0)
                    local vec = createVector(dir.X, dir.Y, dir.Z)

                    for i = 1, 4 do
                        local shouldCastSkill = isOn("AutoSkill" .. tostring(i)) or isCrystal
                        if shouldCastSkill and (now - (lastSkillCastTimes[i] or 0) > 0.35) then
                            if not isSkillOnCD(i) then
                                pcall(function()
                                    r_Skill:FireServer(i, "tap", vec)
                                end)
                                lastSkillCastTimes[i] = now
                            end
                        end
                    end
                end
            end
        end
    end
end)

-- Raw Nonstop Skill Spam Loop (1 -> 2 -> 3 -> 4 -> repeat)
task.spawn(function()
    while not Library.Unloaded do
        if isOn("AutoSpamSkills") and isOn("AutoFarm") and not dl_farm_paused and not dungeonFullyCompleted and not isCollectingChest and not isInteractingAltar and not isUnlockingRoom and not isSummoningBoss and not endlessContinuePending and not isCharacterDead() then
            local target = dlf_currentTarget or dl_pickTarget()
            local hrp = dl_getHRP()
            local vec = zeroVector

            if hrp and target and target.part then
                local diff = target.part.Position - hrp.Position
                local dir = diff.Magnitude > 0 and diff.Unit or Vector3.new(0, -1, 0)
                vec = createVector(dir.X, dir.Y, dir.Z)
            end

            for skillIdx = 1, 4 do
                if not isOn("AutoSpamSkills") or Library.Unloaded then break end
                pcall(function()
                    r_Skill:FireServer(skillIdx, "tap", vec)
                end)
                task.wait(0.01)
            end
        else
            task.wait(0.05)
        end
    end
end)

-- Nonstop Auto Ultimate Loop (Fires raw every 0.01s)
task.spawn(function()
    while not Library.Unloaded do
        if (isOn("AutoUltimate") or isOn("AutoFarm")) and not dl_farm_paused and not dungeonFullyCompleted and not isCollectingChest and not isInteractingAltar and not isUnlockingRoom and not isSummoningBoss and not endlessContinuePending and not isCharacterDead() then
            local target = dlf_currentTarget or dl_pickTarget()

            if target and dl_isNpcAlive(target.model) then
                local isCrystal = (target.model.Name == "Damage_Crystal" or target.model.Name:find("Crystal") ~= nil)
                local shouldUlt = isOn("AutoUltimate") or isCrystal

                if shouldUlt then
                    pcall(function()
                        r_Skill:FireServer("E", "tap", zeroVector)
                    end)
                end
            end
        end
        task.wait(0.01)
    end
end)

task.spawn(function()
    while not Library.Unloaded do
        task.wait(0.02)
        if isOn("AutoParry") and not endlessContinuePending then
            pcall(function()
                r_Parry:FireServer()
            end)
        end
    end
end)

-- Auto Use Potion Safety Loop
local lastPotionUseTime = 0
task.spawn(function()
    while not Library.Unloaded do
        task.wait(0.1) -- Rapid checks to prevent dying before a use
        if isOn("AutoUsePotion") and not isCharacterDead() then
            local hum = getHumanoid()
            if hum and hum.MaxHealth > 0 then
                local currentHPPercent = (hum.Health / hum.MaxHealth) * 100
                local targetThreshold = getNumber("PotionHPPercent", 50)

                -- Cooldown protection of 3 seconds to prevent draining your entire potion inventory in one frame
                if currentHPPercent <= targetThreshold and (tick() - lastPotionUseTime >= 3.0) then
                    lastPotionUseTime = tick()
                    pcall(function()
                        dl_UsePotion:InvokeServer(1)
                    end)
                end
            end
        end
    end
end)



-- ══════════════════════════════════════════
--   AUTO DODGE SYSTEM
-- ══════════════════════════════════════════

function dl_makeVec(x, y, z)
    if rawget(_G, "vector") and vector.create then
        return vector.create(x, y, z)
    end
    return Vector3.new(x, y, z)
end

function dl_getActiveMiniLavas()
    local list = {}
    local telegraphsFolder = workspace:FindFirstChild("SpellTelegraphs")
    if not telegraphsFolder then return list end

    for _, child in ipairs(telegraphsFolder:GetChildren()) do
        local part = nil
        local radius = 0

        if child:IsA("BasePart") then
            part = child
            radius = math.max(child.Size.X, child.Size.Z) / 2
        else
            local firstPart = child:FindFirstChildWhichIsA("BasePart", true)
            if firstPart then
                part = firstPart
                radius = math.max(firstPart.Size.X, firstPart.Size.Z) / 2
            end
        end

        local attrRadius = child:GetAttribute("Radius")
        if attrRadius and type(attrRadius) == "number" then
            radius = attrRadius
        end

        if part and radius > 0 and radius < 100 then
            table.insert(list, {
                position = part.Position,
                radius   = radius,
                obj      = child
            })
        end
    end
    return list
end

function dl_getActiveMassiveWipes()
    local list = {}
    local telegraphsFolder = workspace:FindFirstChild("SpellTelegraphs")
    if not telegraphsFolder then return list end

    for _, child in ipairs(telegraphsFolder:GetChildren()) do
        local part = nil
        local radius = 0

        if child:IsA("BasePart") then
            part = child
            radius = math.max(child.Size.X, child.Size.Z) / 2
        else
            local firstPart = child:FindFirstChildWhichIsA("BasePart", true)
            if firstPart then
                part = firstPart
                radius = math.max(firstPart.Size.X, firstPart.Size.Z) / 2
            end
        end

        local attrRadius = child:GetAttribute("Radius")
        if attrRadius and type(attrRadius) == "number" then
            radius = attrRadius
        end

        if part and radius >= 100 then
            table.insert(list, {
                position = part.Position,
                radius   = radius,
                obj      = child
            })
        end
    end
    return list
end

function dl_getArenaBoundary()
    local hrp = dl_getHRP()
    local defaultPos = hrp and hrp.Position or Vector3.zero
    local mode = getGameMode()

    -- Explicit Church Room Boundary Lock ONLY during Raids
    if mode == "Raid" then
        local ok, churchModel = pcall(function()
            return workspace.Boss_Rush.Maps.Church_Room.Design.Model
        end)
        
        if ok and churchModel then
            local centerCF, size = nil, nil
            if churchModel:IsA("Model") then
                centerCF, size = churchModel:GetBoundingBox()
            elseif churchModel:IsA("BasePart") then
                centerCF, size = churchModel.CFrame, churchModel.Size
            end
            
            if centerCF and size then
                -- Sets a strict safe margin of 8 studs away from the edges
                local safeRadius = (math.min(size.X, size.Z) / 2) - 8
                return centerCF.Position, math.max(25, safeRadius)
            end
        end
    end

    -- Fallback safety boundaries for other gamemodes (Dungeons, BossRush, Challenges)
    if isFarmingSpecialBoss and cachedSpecialBossCF then
        local size = cachedSpecialBossSize
        local safeRadius = size and (math.min(size.X, size.Z) / 2 - 8) or 55
        return cachedSpecialBossCF.Position, math.max(30, safeRadius)
    end

    if isFarmingLockedRoom and cachedLockedRoomCF then
        local size = cachedLockedRoomSize
        local safeRadius = size and (math.min(size.X, size.Z) / 2 - 8) or 40
        return cachedLockedRoomCF.Position, math.max(20, safeRadius)
    end

    if isFarmingLootRoom and cachedLootRoomCF then
        local size = cachedLootRoomSize
        local safeRadius = size and (math.min(size.X, size.Z) / 2 - 8) or 55
        return cachedLootRoomCF.Position, math.max(30, safeRadius)
    end

    if cachedRoomCF then
        local size = cachedRoomSize
        local safeRadius = size and (math.min(size.X, size.Z) / 2 - 8) or 55
        return cachedRoomCF.Position, math.max(30, safeRadius)
    end

    return defaultPos, 55
end

function dl_isPositionInLava(pos, miniLavas, buffer)
    buffer = buffer or 7.0
    for i = 1, #miniLavas do
        local lava = miniLavas[i]
        local dx = pos.X - lava.position.X
        local dz = pos.Z - lava.position.Z
        local dist = math.sqrt(dx*dx + dz*dz)
        if dist < (lava.radius + buffer) then
            return true
        end
    end
    return false
end

function dl_resolveSafePosition(currentPos, miniLavas)
    if #miniLavas == 0 then return currentPos, false end

    local arenaCenter, maxArenaRadius = dl_getArenaBoundary()
    local safeBuffer = 7.0

    local dxc = currentPos.X - arenaCenter.X
    local dzc = currentPos.Z - arenaCenter.Z
    local distFromCenter = math.sqrt(dxc*dxc + dzc*dzc)

    if not dl_isPositionInLava(currentPos, miniLavas, safeBuffer) and distFromCenter <= maxArenaRadius then
        return currentPos, false
    end

    local toCenter2D = Vector3.new(arenaCenter.X - currentPos.X, 0, arenaCenter.Z - currentPos.Z)
    local baseDir = (toCenter2D.Magnitude > 0.1) and toCenter2D.Unit or Vector3.new(0, 0, 1)
    local baseAngle = math.atan2(baseDir.Z, baseDir.X)

    local angleOffsets = {
        0,
        math.rad(30),  -math.rad(30),
        math.rad(60),  -math.rad(60),
        math.rad(90),  -math.rad(90),
        math.rad(120), -math.rad(120),
        math.rad(150), -math.rad(150),
        math.rad(180)
    }

    local testDistances = { 8, 15, 22, 30, 40, 50 }

    for _, dist in ipairs(testDistances) do
        for _, angleOffset in ipairs(angleOffsets) do
            local ang = baseAngle + angleOffset
            local dir = Vector3.new(math.cos(ang), 0, math.sin(ang))
            local candidatePos = Vector3.new(
                currentPos.X + dir.X * dist,
                currentPos.Y,
                currentPos.Z + dir.Z * dist
            )

            local ddx = candidatePos.X - arenaCenter.X
            local ddz = candidatePos.Z - arenaCenter.Z
            local cDistCenter = math.sqrt(ddx*ddx + ddz*ddz)

            if cDistCenter <= maxArenaRadius and not dl_isPositionInLava(candidatePos, miniLavas, safeBuffer) then
                return candidatePos, true
            end
        end
    end

    local safeClampDist = math.min(distFromCenter, math.max(5, maxArenaRadius - 5))
    local fallbackPos = Vector3.new(
        arenaCenter.X - baseDir.X * safeClampDist,
        currentPos.Y,
        arenaCenter.Z - baseDir.Z * safeClampDist
    )
    return fallbackPos, true
end

task.spawn(function()
    local wasLavaActive = false

    while not Library.Unloaded do
        task.wait(0.035)

        if isOn("AutoDodge") and not dl_massive_dodging and not isCollectingChest and not isInteractingAltar and not endlessContinuePending then
            local miniLavas = dl_getActiveMiniLavas()

            if #miniLavas > 0 then
                dl_mini_lava_active = true
                dl_dodge_active = true

                if not wasLavaActive then
                    wasLavaActive = true
                end

                local hrp = dl_getHRP()
                if hrp then
                    local currentPos = hrp.Position
                    local safePos, needsMove = dl_resolveSafePosition(currentPos, miniLavas)

                    if needsMove then
                        dl_cancelTween()
                        dl_dodge_target_pos = safePos
                        dl_dodge_lock_until = tick() + 0.35

                        local lookDir = hrp.CFrame.LookVector
                        local targetCF = CFrame.new(safePos, safePos + Vector3.new(lookDir.X, 0, lookDir.Z))
                        hrp.CFrame = targetCF
                        hrp.Velocity = Vector3.zero
                        hrp.RotVelocity = Vector3.zero
                        pcall(function() hrp.AssemblyLinearVelocity = Vector3.zero end)
                        pcall(function() hrp.AssemblyAngularVelocity = Vector3.zero end)
                    else
                        dl_dodge_target_pos = currentPos
                        dl_dodge_lock_until = tick() + 0.25
                        hrp.Velocity = Vector3.zero
                        pcall(function() hrp.AssemblyLinearVelocity = Vector3.zero end)
                    end
                end
            else
                if wasLavaActive then
                    wasLavaActive = false
                end
                dl_mini_lava_active = false
                dl_dodge_target_pos = nil
                dl_dodge_lock_until = 0
                if not dl_massive_dodging then
                    dl_dodge_active = false
                end
            end
        else
            if not dl_massive_dodging then
                dl_dodge_active = false
                dl_mini_lava_active = false
                dl_dodge_target_pos = nil
                dl_dodge_lock_until = 0
            end
            wasLavaActive = false
        end
    end
end)

task.spawn(function()
    while not Library.Unloaded do
        task.wait(0.05)
        if isOn("AutoDodge") and (tick() - dl_last_massive_dash) > 6.0 then
            local wipes = dl_getActiveMassiveWipes()
            if #wipes > 0 then
                dl_last_massive_dash = tick()
                dl_massive_dodging = true
                dl_dodge_active = true

                task.spawn(function()
                    pcall(function() Library:Notify("⚠️ MASSIVE LAVA! Detonation timing in 0.7s...", 2) end)
                    task.wait(0.7)

                    pcall(function()
                        local dashDir = dl_makeVec(-0.1650477647781372, 0, 0.9862855672836304)
                        r_Dash:FireServer(dashDir)
                    end)

                    pcall(function() Library:Notify("💨 Dashed through wipe lava!", 1.5) end)

                    task.wait(0.3)
                    dl_massive_dodging = false
                    if not dl_mini_lava_active then
                        dl_dodge_active = false
                    end
                end)
            end
        end
    end
end)

-- ══════════════════════════════════════════
--   GAMEMODE WATCHDOGS & CUSTOM ACTIONS
-- ══════════════════════════════════════════

task.spawn(function()
    while not Library.Unloaded do
        task.wait(0.5)
        local mode = getGameMode()
        if mode == "BossRush" and isOn("AutoFarm") then
            local currentRoom = dl_getBossRushCurrentRoom()
            local opt = Options.BossRushEndAction and Options.BossRushEndAction.Value or "Disabled"
            local targetRoom = getNumber("BossRushCustomTarget", 1)

            if currentRoom and (opt == "Custom Replay" or opt == "Custom Return") then
                if currentRoom >= targetRoom and _G.BossRushCustomActionQueue == nil then
                    _G.BossRushCustomActionQueue = (opt == "Custom Replay") and "Replay" or "Return"
                    dl_farm_paused = true
                    Library:Notify(string.format("🎯 Boss Rush target Room %d reached! Initiating self-defeat...", targetRoom), 3)

                    task.spawn(function()
                        while _G.BossRushCustomActionQueue ~= nil and not Library.Unloaded do
                            local remainingLives = dl_getBossRushLives() or 0
                            local hum = getHumanoid()
                            if hum then pcall(function() hum.Health = 0 end) end
                            local char = LocalPlayer.Character
                            if char then pcall(function() char:BreakJoints() end) end
                            if remainingLives <= 0 then break end
                            task.wait(1.5)
                        end
                    end)
                end
            end
        end
    end
end)

task.spawn(function()
    while not Library.Unloaded do
        task.wait(0.5)
        local mode = getGameMode()
        if mode == "Challenge" and isOn("AutoFarm") then
            local currentWave = dl_getChallengeCurrentWave()
            local opt = Options.ChallengeEndAction and Options.ChallengeEndAction.Value or "Disabled"
            local targetWave = getNumber("ChallengeCustomTarget", 1)

            if currentWave and (opt == "Custom Replay" or opt == "Custom Return") then
                if currentWave >= targetWave and _G.ChallengeCustomActionQueue == nil then
                    _G.ChallengeCustomActionQueue = (opt == "Custom Replay") and "Replay" or "Return"
                    dl_farm_paused = true
                    Library:Notify(string.format("🎯 Challenge target Wave %d reached! Burning lives...", targetWave), 3)

                    task.spawn(function()
                        while _G.ChallengeCustomActionQueue ~= nil and not Library.Unloaded do
                            if dl_isDungeonEndUIActive() then break end
                            local hum = getHumanoid()
                            if hum then pcall(function() hum.Health = 0 end) end
                            local char = LocalPlayer.Character
                            if char then pcall(function() char:BreakJoints() end) end
                            task.wait(1.5)
                        end
                    end)
                end
            end
        end
    end
end)

task.spawn(function()
    while not Library.Unloaded do
        task.wait(0.5)
        local mode = getGameMode()
        if mode == "Raid" and isOn("AutoFarm") then
            local currentPhase = dl_getRaidCurrentPhase()
            local opt = Options.RaidEndAction and Options.RaidEndAction.Value or "Disabled"
            local targetPhase = getNumber("RaidCustomTarget", 1)

            if currentPhase and (opt == "Custom Replay" or opt == "Custom Return") then
                if currentPhase >= targetPhase and _G.RaidCustomActionQueue == nil then
                    _G.RaidCustomActionQueue = (opt == "Custom Replay") and "Replay" or "Return"
                    dl_farm_paused = true
                    Library:Notify(string.format("🎯 Raid target Phase %d reached! Initiating self-defeat...", targetPhase), 3)

                    task.spawn(function()
                        while _G.RaidCustomActionQueue ~= nil and not Library.Unloaded do
                            local hum = getHumanoid()
                            if hum then pcall(function() hum.Health = 0 end) end
                            local char = LocalPlayer.Character
                            if char then pcall(function() char:BreakJoints() end) end
                            task.wait(1.5)
                        end
                    end)
                end
            end
        end
    end
end)

-- ══════════════════════════════════════════
--   MATCH COMPLETION HANDLER
-- ══════════════════════════════════════════

local lastActionFireTime = 0

function executeEndAction(actionType, mode)
    if tick() - lastActionFireTime < 6.5 then return end
    lastActionFireTime = tick()

    dl_cancelTween()
    dlf_currentTarget = nil

    if actionType == "Replay" then
        task.wait(1.2)
        local invoked = false

        if mode == "Dungeon" and dl_RequestReplay then
            pcall(function() dl_RequestReplay:InvokeServer() invoked = true end)
        elseif mode == "BossRush" and dl_BR_Replay then
            pcall(function() dl_BR_Replay:InvokeServer() invoked = true end)
        elseif mode == "Challenge" and dl_CH_Replay then
            pcall(function() dl_CH_Replay:InvokeServer() invoked = true end)
        elseif mode == "Raid" and dl_RD_Replay then
            pcall(function() dl_RD_Replay:InvokeServer() invoked = true end)
        end

        if not invoked then
            pcall(function()
                local pg = LocalPlayer:FindFirstChild("PlayerGui")
                local completion = pg and pg.Main.HUD.Dungeon_Container:FindFirstChild("Completion_Info")
                local btn = completion and completion.Content.ActionButtons:FindFirstChild("ReplayButton")
                if btn and dl_isGuiObjectVisible(btn) then
                    vimClick(btn)
                end
            end)
        end
    elseif actionType == "Return" then
        local lobbyDelay = getNumber("LobbyReturnDelay", 0)
        if lobbyDelay > 0 then task.wait(lobbyDelay) end

        local invoked = false

        if mode == "Dungeon" and dl_RequestReturn then
            pcall(function() dl_RequestReturn:InvokeServer() invoked = true end)
        elseif mode == "BossRush" and dl_BR_Return then
            pcall(function() dl_BR_Return:InvokeServer() invoked = true end)
        elseif mode == "Challenge" and dl_CH_Return then
            pcall(function() dl_CH_Return:InvokeServer() invoked = true end)
        elseif mode == "Raid" and dl_RD_Return then
            pcall(function() dl_RD_Return:InvokeServer() invoked = true end)
        end

        if not invoked then
            pcall(function()
                local pg = LocalPlayer:FindFirstChild("PlayerGui")
                local completion = pg and pg.Main.HUD.Dungeon_Container:FindFirstChild("Completion_Info")
                local btn = completion and completion.Content.ActionButtons:FindFirstChild("ReturnButton")
                if btn and dl_isGuiObjectVisible(btn) then
                    vimClick(btn)
                end
            end)
        end
    end

    _G.BossRushCustomActionQueue = nil
    _G.ChallengeCustomActionQueue = nil
    _G.RaidCustomActionQueue = nil
    dl_farm_paused = false

    activeSequence = {}
    activeSequenceIndex = 1
    activeRoomModel = nil
    cachedRoomCF = nil
    cachedRoomSize = nil
    lootRoomQueue = {}
    lootRoomIndex = 0
    currentLootRoomModel = nil
    cachedLootRoomCF = nil
    cachedLootRoomSize = nil
    isFarmingLootRoom = false
    isFarmingLockedRoom = false
    currentLockedRoomModel = nil
    cachedLockedRoomCF = nil
    cachedLockedRoomSize = nil
    isUnlockingRoom = false
    isFarmingSpecialBoss = false
    currentSpecialBossRoom = nil
    cachedSpecialBossCF = nil
    cachedSpecialBossSize = nil
    isSummoningBoss = false
    dungeonFullyCompleted = false
    activeDungeonId = nil
    consumedAltars = {}
    collectedChests = {}
    unlockedLockedRooms = {}
    processedSpecialBossRooms = {}
end

function handleMatchCompletion()
    local mode = getGameMode()

    if mode == "BossRush" and _G.BossRushCustomActionQueue then
        executeEndAction(_G.BossRushCustomActionQueue, mode)
        return
    elseif mode == "Challenge" and _G.ChallengeCustomActionQueue then
        executeEndAction(_G.ChallengeCustomActionQueue, mode)
        return
    elseif mode == "Raid" and _G.RaidCustomActionQueue then
        executeEndAction(_G.RaidCustomActionQueue, mode)
        return
    end

    if mode == "Dungeon" then
        local act = Options.DungeonEndAction and Options.DungeonEndAction.Value or "Replay"
        executeEndAction(act, mode)
    elseif mode == "BossRush" then
        local opt = Options.BossRushEndAction and Options.BossRushEndAction.Value or "Disabled"
        if opt == "Replay At End" then executeEndAction("Replay", mode)
        elseif opt == "Return At End" then executeEndAction("Return", mode) end
    elseif mode == "Challenge" then
        local opt = Options.ChallengeEndAction and Options.ChallengeEndAction.Value or "Disabled"
        if opt == "Replay At End" then executeEndAction("Replay", mode)
        elseif opt == "Return At End" then executeEndAction("Return", mode) end
    elseif mode == "Raid" then
        local opt = Options.RaidEndAction and Options.RaidEndAction.Value or "Disabled"
        if opt == "Replay At End" then executeEndAction("Replay", mode)
        elseif opt == "Return At End" then executeEndAction("Return", mode) end
    end
end

task.spawn(function()
    while not Library.Unloaded do
        task.wait(0.75)
        if dl_isDungeonEndUIActive() then
            handleMatchCompletion()
        end
    end
end)

local challengeChestSpawnTimes = {}

task.spawn(function()
    while not Library.Unloaded do
        task.wait(0.3)
        if getGameMode() == "Challenge" and isOn("AutoCollectChests") and not isCollectingChest then
            local challengeFolder = workspace:FindFirstChild("Challenge_NPCs")
            if challengeFolder then
                for _, child in ipairs(challengeFolder:GetChildren()) do
                    if (child.Name:match("^DungeonChest") or child.Name == "DungeonChest") and not collectedChests[child] then
                        -- Register initial spawn timestamp for newly detected chest
                        if not challengeChestSpawnTimes[child] then
                            challengeChestSpawnTimes[child] = tick()
                        end

                        local timeSinceSpawn = tick() - challengeChestSpawnTimes[child]

                        -- Wait at least 5 seconds after spawning before moving to collect
                        if timeSinceSpawn >= 5 then
                            local part = child:IsA("BasePart") and child
                                or child.PrimaryPart
                                or child:FindFirstChildWhichIsA("BasePart", true)

                            if part then
                                local tempTarget = { model = child, part = part }
                                SessionStats.roomStateText = "🎁 Collecting Challenge Chest (5s delay met)..."
                                pcall(function() dl_forceCollectChest(tempTarget) end)
                                challengeChestSpawnTimes[child] = nil
                                break
                            end
                        else
                            SessionStats.roomStateText = string.format("🎁 Chest Spawned! Waiting %.1fs before collecting...", 5 - timeSinceSpawn)
                        end
                    end
                end
            end
        else
            -- Clear timestamps if exiting Challenge mode
            if getGameMode() ~= "Challenge" then
                table.clear(challengeChestSpawnTimes)
            end
        end
    end
end)

-- ══════════════════════════════════════════
--   LOBBY BACKGROUND EXECUTION LOOPS
-- ══════════════════════════════════════════

task.spawn(function()
    while not Library.Unloaded do
        task.wait(1)
        if getGameMode() == "Lobby" then
            if isOn("AutoQueueDungeon") then
                local delayTime = getNumber("QueueDelay", 3)
                task.wait(delayTime)
                pcall(function()
                    local displayName = Options.QueueDungeonName.Value
                    local internalName = DUNGEON_INTERNAL_MAP[displayName] or displayName
                    local diffName = Options.QueueDifficulty.Value

                    dl_SelectMode:InvokeServer("Dungeon")
                    task.wait(0.4)

                    local ok, res = pcall(function() return dl_SelectDungeon:InvokeServer(internalName) end)
                    if not ok or res == false then
                        local cleanName = internalName:gsub("%s+", "")
                        pcall(function() dl_SelectDungeon:InvokeServer(cleanName) end)
                    end
                    task.wait(0.4)

                    dl_SelectDiff:InvokeServer(diffName)
                    task.wait(0.4)

                    dl_EnterQueue:InvokeServer()
                    task.wait(0.3)

                    dl_StartQueue:InvokeServer()
                    task.wait(0.3)

                    dl_StartNow:InvokeServer()
                end)
                task.wait(10)
            elseif isOn("AutoQueueChallenge") then
                local delayTime = getNumber("QueueDelay", 3)
                task.wait(delayTime)
                pcall(function()
                    dl_SelectMode:InvokeServer("Challenge")
                    task.wait(0.4)
                    dl_SelectDungeon:InvokeServer(Options.QueueChallengeName.Value)
                    task.wait(0.4)
                    dl_SelectDiff:InvokeServer(Options.QueueChallengeDifficulty.Value)
                    task.wait(0.4)
                    pcall(function() dl_EnterQueue:InvokeServer() end)
                    task.wait(0.3)
                    dl_StartQueue:InvokeServer()
                    task.wait(0.3)
                    pcall(function() dl_StartNow:InvokeServer() end)
                end)
                task.wait(10)
            elseif isOn("AutoQueueBossRush") then
                local delayTime = getNumber("QueueDelay", 3)
                task.wait(delayTime)
                pcall(function()
                    dl_SelectMode:InvokeServer("BossRush")
                    task.wait(0.4)
                    dl_SelectFinalBoss:InvokeServer(Options.QueueBossName.Value)
                    task.wait(0.4)
                    dl_EnterQueue:InvokeServer()
                    task.wait(0.3)
                    dl_StartNow:InvokeServer()
                end)
                task.wait(10)
            elseif isOn("AutoQueueRaid") then
                local delayTime = getNumber("QueueDelay", 3)
                task.wait(delayTime)
                pcall(function()
                    dl_SelectMode:InvokeServer("Raids")
                    task.wait(0.4)
                    dl_SelectRaid:InvokeServer(Options.QueueRaidName.Value)
                    task.wait(0.4)
                    dl_SelectRaidDiff:InvokeServer(Options.QueueRaidDifficulty.Value)
                    task.wait(0.4)
                    dl_EnterQueue:InvokeServer()
                    task.wait(0.3)
                    dl_StartQueue:InvokeServer()
                    task.wait(0.3)
                    pcall(function() dl_StartNow:InvokeServer() end)
                end)
                task.wait(10)
            end
        end
    end
end)

task.spawn(function()
    while not Library.Unloaded do
        task.wait(2.5)
        if isOn("AutoSellEnabled") then
            pcall(runAutoSell)
        end
    end
end)

task.spawn(function()
    while not Library.Unloaded do
        task.wait(1.5)
        if isOn("AutoEquipBest") then
            pcall(runAutoEquipBest)
        end
    end
end)

task.spawn(function()
    while not Library.Unloaded do
        task.wait(4)
        if isOn("AutoBuyMerchant") then
            local shopInfo = nil
            pcall(function() shopInfo = dl_GetShopInfo:InvokeServer() end)
            if shopInfo and type(shopInfo) == "table" then
                for _, item in ipairs(shopInfo) do
                    local rarity = item.Rarity or "Common"
                    local cost = item.Cost or 999999
                    local coins = (getPlayerData() or {}).Currency or 0

                    local buyOption = Options.BuyRarities
                    local shouldBuy = buyOption and buyOption.Value and buyOption.Value[rarity] == true
                    if shouldBuy and coins >= cost then
                        pcall(function()
                            dl_BuyEquipment:InvokeServer(item.GUID)
                        end)
                        task.wait(0.5)
                    end
                end
            end
        end
    end
end)

-- Auto Buy Mystery Merchant Loop
task.spawn(function()
    while not Library.Unloaded do
        task.wait(6)
        if isOn("AutoBuyMystery") then
            local shopInfo = nil
            pcall(function() shopInfo = dl_MM_GetShopInfo:InvokeServer() end)

            if shopInfo and type(shopInfo) == "table" and shopInfo.Active == true and shopInfo.Items then
                local rotation = shopInfo.Rotation
                local buyMode = Options.MysteryBuyMode and Options.MysteryBuyMode.Value or "Max"
                local buyList = Options.MysteryBuyList and Options.MysteryBuyList.Value or {}

                -- Convert selected list into ID lookup
                local selectedIds = {}
                for taggedName, isSelected in pairs(buyList) do
                    if isSelected then
                        local pureName = taggedName:match("^(.-)%s*%[") or taggedName
                        pureName = pureName:gsub("%s+$", "")
                        selectedIds[pureName] = true
                    end
                end

                for _, item in ipairs(shopInfo.Items) do
                    if selectedIds[item.Id] then
                        local purchased = item.Purchased or 0
                        local limit = item.PurchaseLimit or 1
                        local timesToBuy = (buyMode == "Single") and math.min(1, limit - purchased) or (limit - purchased)

                        if timesToBuy > 0 then
                            for iter = 1, timesToBuy do
                                if not isOn("AutoBuyMystery") or Library.Unloaded then break end
                                pcall(function()
                                    dl_MM_BuyItem:InvokeServer(item.Id, rotation)
                                end)
                                task.wait(0.5)
                            end
                        end
                    end
                end
            end
        end
    end
end)

-- Auto Buy Raid Shop Loop (Spams purchases for all selected items)
local RAID_ITEM_MAP = {
    ["Moria Blade"]             = "MoriaBlade",
    ["Frost Wisteria Wand"]     = "FrostWisteriaWand",
    ["Magia Revenda"]           = "TitleMagiaRevenda",
    ["Might of Courage"]        = "TitleMightOfCourage",
    ["Spellbreaker"]            = "Cos_Spellbreaker",
    ["Cryomancer"]              = "Cos_Cryomancer",
    ["Pyromancer"]              = "Cos_Pyromancer",
    ["Ice Queen Aura"]          = "Cos_IceQueenAura",
    ["Blaze Aura"]              = "Cos_BlazeAura",
    ["White Spellweaver"]       = "Cos_WhiteSpellweaver",
    ["Ice Queen"]               = "Cos_IceQueen",
    ["Aspect Gem"]              = "AspectGem",
    ["Protection Scroll"]       = "ProtectionScroll",
    ["Reforge Stone"]           = "ReforgeStone",
    ["Exotic Ore"]              = "ExoticOre",
    ["Exotic Essence"]          = "ExoticEssence",
    ["Mythic Chest"]            = "MythicChest",
    ["Celestial Chest"]         = "CelestialChest",
    ["Normal Event Chest"]      = "NormalEventChest",
    ["Extreme Event Chest"]     = "ExtremeEventChest",
    ["Impossible Event Chest"]  = "ImpossibleEventChest",
}

task.spawn(function()
    while not Library.Unloaded do
        task.wait(1.5)
        if isOn("AutoBuyRaidShop") then
            local raidBuyList = Options.RaidBuyList and Options.RaidBuyList.Value or {}

            for taggedName, isSelected in pairs(raidBuyList) do
                if isSelected and isOn("AutoBuyRaidShop") and not Library.Unloaded then
                    local pureName = taggedName:match("^(.-)%s*%[") or taggedName
                    pureName = pureName:gsub("%s+$", "")
                    local itemId = RAID_ITEM_MAP[pureName] or pureName

                    pcall(function()
                        dl_BuyRaidShopItem:InvokeServer("The First Test", itemId)
                    end)
                    task.wait(0.2)
                end
            end
        end
    end
end)

task.spawn(function()
    local lastSlotSwitch = 0
    local cachedSlotIdx = nil

    while not Library.Unloaded do
        task.wait(0.05)
        if isOn("AutoSummon") then
            -- Safe Gate: Instantly halt class rolls if player enters a gameplay instance
            if getGameMode() ~= "Lobby" then
                task.wait(1.0)
                continue
            end

            local pd = getPlayerData()
            -- ... (leave the rest of your original loop as is)
            if pd then
                local activeSummonSlot = tonumber(Options.SummonSlot.Value) or 1
                local slotData = getSummonSlotData()

                if slotData and type(slotData) == "table" then
                    if not slotData.Slots or slotData.Slots[activeSummonSlot] == nil then
                        Toggles.AutoSummon:SetValue(false)
                        Library:Notify(string.format("⚠️ Slot %d is locked! Stopping Auto Roll.", activeSummonSlot), 5)
                        task.wait(0.5)
                        continue
                    end
                end

                if cachedSlotIdx ~= activeSummonSlot and (tick() - lastSlotSwitch) > 0.5 then
                    pcall(function() dl_SwitchSlot:InvokeServer(activeSummonSlot) end)
                    cachedSlotIdx = activeSummonSlot
                    lastSlotSwitch = tick()
                    task.wait(0.15)
                    continue
                end

                if slotData and type(slotData) == "table" and slotData.Slots then
                    local currentClass = slotData.Slots[activeSummonSlot]
                    local currentAspect = slotData.SlotAspects and slotData.SlotAspects[activeSummonSlot]

                    if currentClass and currentClass ~= "" then
                        local classOption = Options.StopSummonClasses
                        local aspectOption = Options.StopSummonAspects

                        local hasClassTarget = false
                        local hasAspectTarget = false
                        local classMatched = false
                        local aspectMatched = false

                        if classOption and classOption.Value then
                            for taggedName, isSelected in pairs(classOption.Value) do
                                if isSelected then
                                    hasClassTarget = true
                                    local pureName = taggedName:match("^(.-)%s*%[") or taggedName
                                    pureName = pureName:gsub("%s+$", "")
                                    if pureName == currentClass then
                                        classMatched = true
                                    end
                                end
                            end
                        end

                        if aspectOption and aspectOption.Value then
                            for taggedName, isSelected in pairs(aspectOption.Value) do
                                if isSelected then
                                    hasAspectTarget = true
                                    local pureName = taggedName:match("^(.-)%s*%[") or taggedName
                                    pureName = pureName:gsub("%s+$", "")
                                    if currentAspect and pureName == currentAspect then
                                        aspectMatched = true
                                    end
                                end
                            end
                        end

                        local shouldStop = false
                        if hasClassTarget and hasAspectTarget then
                            shouldStop = classMatched and aspectMatched
                        elseif hasClassTarget and not hasAspectTarget then
                            shouldStop = classMatched
                        elseif hasAspectTarget and not hasClassTarget then
                            shouldStop = aspectMatched
                        end

                        if shouldStop then
                            Toggles.AutoSummon:SetValue(false)
                            Library:Notify(string.format(
                                "🎯 Target Rolled! Class: %s | Aspect: %s | Slot: %d",
                                tostring(currentClass),
                                tostring(currentAspect or "None"),
                                activeSummonSlot
                            ), 12)
                            continue
                        end
                    end
                end

                local spinType = "Normal"
                if isOn("SummonUseLucky") and (pd.LuckySpins or 0) > 0 then
                    spinType = "Lucky"
                end

                pcall(function()
                    dl_Spin:InvokeServer(spinType, false)
                end)

                task.wait(0.08)
            end
        else
            task.wait(0.15)
        end
    end
end)

task.spawn(function()
    while not Library.Unloaded do
        task.wait(3)
        if isOn("AutoAllocate") then
            local pd = getPlayerData()
            if pd and (pd.UnspentSkillPoints or 0) > 0 then
                pcall(function()
                    dl_AllocatePoints:InvokeServer(Options.AllocateTarget.Value, pd.UnspentSkillPoints)
                end)
            end
        end
    end
end)

task.spawn(function()
    while not Library.Unloaded do
        task.wait(5)
        if isOn("AutoClaimQuests") then
            for idx = 1, 10 do
                pcall(function() dl_ClaimQuest:InvokeServer("Daily", idx) end)
                pcall(function() dl_ClaimQuest:InvokeServer("Weekly", idx) end)
            end
        end
    end
end)

-- ══════════════════════════════════════════
--   PLAYER TAB & MOVEMENT ENGINE
-- ══════════════════════════════════════════

local FLYING = false
local flyKeyDown, flyKeyUp
local currentWalkSpeed = 16
local currentJumpPower = 50
local currentFlySpeed  = 60

function sFLY(vfly)
    local plr = Players.LocalPlayer
    local char = plr.Character or plr.CharacterAdded:Wait()
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    if not humanoid then return end

    if flyKeyDown or flyKeyUp then
        if flyKeyDown then flyKeyDown:Disconnect() end
        if flyKeyUp then flyKeyUp:Disconnect() end
    end

    local T = dl_getHRP()
    if not T then return end

    local CONTROL = {F = 0, B = 0, L = 0, R = 0, Q = 0, E = 0}
    local lCONTROL = {F = 0, B = 0, L = 0, R = 0, Q = 0, E = 0}
    local SPEED = 0

    function FLY()
        FLYING = true
        local BG = Instance.new('BodyGyro')
        local BV = Instance.new('BodyVelocity')
        BG.P = 9e4
        BG.Parent = T
        BV.Parent = T
        BG.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
        BG.CFrame = T.CFrame
        BV.Velocity = Vector3.new(0, 0, 0)
        BV.MaxForce = Vector3.new(9e9, 9e9, 9e9)

        task.spawn(function()
            repeat task.wait()
                local camera = workspace.CurrentCamera
                if not camera then continue end

                if humanoid then humanoid.PlatformStand = true end

                local activeSpeed = getNumber("FlySpeed", 60)

                if CONTROL.L + CONTROL.R ~= 0 or CONTROL.F + CONTROL.B ~= 0 or CONTROL.Q + CONTROL.E ~= 0 then
                    SPEED = activeSpeed
                elseif not (CONTROL.L + CONTROL.R ~= 0 or CONTROL.F + CONTROL.B ~= 0 or CONTROL.Q + CONTROL.E ~= 0) and SPEED ~= 0 then
                    SPEED = 0
                end

                if (CONTROL.L + CONTROL.R) ~= 0 or (CONTROL.F + CONTROL.B) ~= 0 or (CONTROL.Q + CONTROL.E) ~= 0 then
                    BV.Velocity = ((camera.CFrame.LookVector * (CONTROL.F + CONTROL.B)) + ((camera.CFrame * CFrame.new(CONTROL.L + CONTROL.R, (CONTROL.F + CONTROL.B + CONTROL.Q + CONTROL.E) * 0.2, 0).p) - camera.CFrame.p)) * SPEED
                    lCONTROL = {F = CONTROL.F, B = CONTROL.B, L = CONTROL.L, R = CONTROL.R}
                elseif (CONTROL.L + CONTROL.R) == 0 and (CONTROL.F + CONTROL.B) == 0 and (CONTROL.Q + CONTROL.E) == 0 and SPEED ~= 0 then
                    BV.Velocity = ((camera.CFrame.LookVector * (lCONTROL.F + lCONTROL.B)) + ((camera.CFrame * CFrame.new(lCONTROL.L + lCONTROL.R, (lCONTROL.F + lCONTROL.B + CONTROL.Q + CONTROL.E) * 0.2, 0).p) - camera.CFrame.p)) * SPEED
                else
                    BV.Velocity = Vector3.new(0, 0, 0)
                end
                BG.CFrame = camera.CFrame
            until not FLYING or Library.Unloaded

            CONTROL = {F = 0, B = 0, L = 0, R = 0, Q = 0, E = 0}
            lCONTROL = {F = 0, B = 0, L = 0, R = 0, Q = 0, E = 0}
            SPEED = 0
            BG:Destroy()
            BV:Destroy()

            if humanoid then humanoid.PlatformStand = false end
        end)
    end

    flyKeyDown = UserInputService.InputBegan:Connect(function(input, processed)
        if processed then return end
        if input.KeyCode == Enum.KeyCode.W then CONTROL.F = 1
        elseif input.KeyCode == Enum.KeyCode.S then CONTROL.B = -1
        elseif input.KeyCode == Enum.KeyCode.A then CONTROL.L = -1
        elseif input.KeyCode == Enum.KeyCode.D then CONTROL.R = 1
        elseif input.KeyCode == Enum.KeyCode.E then CONTROL.Q = 2
        elseif input.KeyCode == Enum.KeyCode.Q then CONTROL.E = -2
        end
    end)

    flyKeyUp = UserInputService.InputEnded:Connect(function(input, processed)
        if processed then return end
        if input.KeyCode == Enum.KeyCode.W then CONTROL.F = 0
        elseif input.KeyCode == Enum.KeyCode.S then CONTROL.B = 0
        elseif input.KeyCode == Enum.KeyCode.A then CONTROL.L = 0
        elseif input.KeyCode == Enum.KeyCode.D then CONTROL.R = 0
        elseif input.KeyCode == Enum.KeyCode.E then CONTROL.Q = 0
        elseif input.KeyCode == Enum.KeyCode.Q then CONTROL.E = 0
        end
    end)

    FLY()
end

do
    local PG = Tabs.Player:AddLeftGroupbox("Player", "user-check")
    PG:AddPlayerInfo("PlayerCardCompact", {
        ThumbnailType = "Bust",
        Height = 190,
    })

    local MG = Tabs.Player:AddRightGroupbox("Movement", "feather")
    MG:AddToggle("Fly",      { Text = "Fly", Default = false })
    MG:AddSlider("FlySpeed", { Text = "Fly Speed", Default = 60, Min = 10, Max = 350, Rounding = 0, Callback = function(v) currentFlySpeed = v end })
    MG:AddDivider()
    MG:AddToggle("AntiSit", {
        Text = "Anti-Sit",
        Default = false,
        Callback = function(v)
            local h = getHumanoid()
            if h then h:SetStateEnabled(Enum.HumanoidStateType.Seated, not v) end
        end,
    })
    MG:AddDivider()
    MG:AddToggle("WalkSpeedEnabled", { Text = "Speed", Default = false })
    MG:AddSlider("WalkSpeed",        { Text = "Speed Value", Default = 16, Min = 16, Max = 250, Rounding = 0, Callback = function(v) currentWalkSpeed = v end })
    MG:AddDivider()
    MG:AddToggle("JumpPowerEnabled", { Text = "Jump", Default = false })
    MG:AddSlider("JumpPower",        { Text = "Jump Value", Default = 50, Min = 50, Max = 300, Rounding = 0, Callback = function(v) currentJumpPower = v end })
    MG:AddDivider()
    MG:AddToggle("InfJump", { Text = "Infinite Jump", Default = false })
    MG:AddToggle("NoClip",  { Text = "NoClip", Default = false })
end

-- ══════════════════════════════════════════
--   SETTINGS TAB & PERFORMANCE BOOSTER
-- ══════════════════════════════════════════

-- ══════════════════════════════════════════
--   NAME CHANGER / SPOOFER ENGINE (ROBUST)
-- ══════════════════════════════════════════

local originalTexts = setmetatable({}, { __mode = "k" })
local updatingText = false

function escapePattern(str)
    return str:gsub("([%%%(%)%^%$%-%?%*%+%[%]])", "%%%1")
end

function updateLabel(label)
    if not label or not label:IsA("TextLabel") then return end

    local orig = originalTexts[label]
    if not orig then
        orig = label.Text
        originalTexts[label] = orig
    end

    local realName = LocalPlayer.Name
    if not orig or not orig:find(realName, 1, true) then return end

    local targetName = Options.SpoofedName and Options.SpoofedName.Value
    if not targetName or targetName == "" then
        targetName = "PrismUser"
    end

    local enabled = isOn("EnableNameSpoof")
    local newText = enabled and orig:gsub(escapePattern(realName), targetName) or orig

    if label.Text ~= newText then
        updatingText = true
        pcall(function()
            label.Text = newText
        end)
        updatingText = false
    end
end

function hookLabel(label)
    if not label or not label:IsA("TextLabel") or originalTexts[label] ~= nil then return end

    originalTexts[label] = label.Text

    label:GetPropertyChangedSignal("Text"):Connect(function()
        if updatingText then return end
        -- Update the original cache when the game naturally updates the text
        originalTexts[label] = label.Text
        if isOn("EnableNameSpoof") then
            updateLabel(label)
        end
    end)

    if isOn("EnableNameSpoof") then
        updateLabel(label)
    end
end

function applyNameSpoof()
    for _, obj in ipairs(game:GetDescendants()) do
        if obj:IsA("TextLabel") then
            if originalTexts[obj] == nil then
                pcall(hookLabel, obj)
            else
                pcall(updateLabel, obj)
            end
        end
    end
end

game.DescendantAdded:Connect(function(desc)
    if desc:IsA("TextLabel") then
        task.wait()
        pcall(hookLabel, desc)
    end
end)

local fpsBoostCache = {}
local cleaningConnection = nil

function applyFPSBoost(enabled)
    if enabled then
        fpsBoostCache.Lighting = {
            GlobalShadows = Lighting.GlobalShadows,
            FogEnd        = Lighting.FogEnd,
            Brightness    = Lighting.Brightness,
            ClockTime     = Lighting.ClockTime,
            ExposureCompensation = Lighting.ExposureCompensation
        }

        Lighting.GlobalShadows = false
        Lighting.FogEnd        = 9e9
        Lighting.Brightness    = 2
        Lighting.ExposureCompensation = 0.5
        settings().Rendering.QualityLevel = Enum.QualityLevel.Level01

        for _, obj in ipairs(Lighting:GetDescendants()) do
            if obj:IsA("PostEffect") or obj:IsA("Atmosphere") or obj:IsA("Clouds") or obj:IsA("Sky") then
                fpsBoostCache[obj] = obj.Parent
                obj.Parent = nil
            end
        end

        if workspace:FindFirstChildOfClass("Terrain") then
            local t = workspace:FindFirstChildOfClass("Terrain")
            fpsBoostCache.Terrain = {
                Decoration = t.Decoration,
                WaterWaveSize = t.WaterWaveSize,
                WaterWaveSpeed = t.WaterWaveSpeed,
                WaterReflectance = t.WaterReflectance,
                WaterTransparency = t.WaterTransparency
            }
            t.Decoration = false
            t.WaterWaveSize = 0
            t.WaterWaveSpeed = 0
            t.WaterReflectance = 0
            t.WaterTransparency = 0
        end

        function cleanVisuals(obj)
            if obj:IsA("Decal") or obj:IsA("Texture") then
                fpsBoostCache[obj] = { Transparency = obj.Transparency }
                obj.Transparency = 1
            elseif obj:IsA("MeshPart") then
                fpsBoostCache[obj] = { Material = obj.Material, TextureID = obj.TextureID, CastShadow = obj.CastShadow }
                obj.Material = Enum.Material.SmoothPlastic
                obj.TextureID = ""
                obj.CastShadow = false
            elseif obj:IsA("BasePart") and not obj:IsA("MeshPart") then
                fpsBoostCache[obj] = { Material = obj.Material, CastShadow = obj.CastShadow }
                obj.Material = Enum.Material.SmoothPlastic
                obj.CastShadow = false
            elseif obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Smoke") or obj:IsA("Fire") or obj:IsA("Sparkles") or obj:IsA("Beam") or obj:IsA("Highlight") then
                fpsBoostCache[obj] = { Enabled = obj.Enabled }
                pcall(function() obj.Enabled = false end)
            elseif obj:IsA("Sound") then
                fpsBoostCache[obj] = { Volume = obj.Volume }
                obj.Volume = 0
            end
        end

        for _, desc in ipairs(workspace:GetDescendants()) do
            cleanVisuals(desc)
        end

        cleaningConnection = workspace.DescendantAdded:Connect(function(desc)
            task.wait()
            pcall(cleanVisuals, desc)
        end)
    else
        if cleaningConnection then
            cleaningConnection:Disconnect()
            cleaningConnection = nil
        end

        if fpsBoostCache.Lighting then
            for prop, val in pairs(fpsBoostCache.Lighting) do
                Lighting[prop] = val
            end
        end

        if fpsBoostCache.Terrain and workspace:FindFirstChildOfClass("Terrain") then
            local t = workspace:FindFirstChildOfClass("Terrain")
            for prop, val in pairs(fpsBoostCache.Terrain) do
                t[prop] = val
            end
        end

        for obj, data in pairs(fpsBoostCache) do
            if typeof(obj) == "Instance" then
                pcall(function()
                    if typeof(data) == "Instance" then
                        obj.Parent = data
                    elseif type(data) == "table" then
                        for prop, val in pairs(data) do
                            obj[prop] = val
                        end
                    end
                end)
            end
        end
        table.clear(fpsBoostCache)
        settings().Rendering.QualityLevel = Enum.QualityLevel.Default
    end
end

-- ══════════════════════════════════════════
--   WEBHOOK SUBTAB 1: SETUP CONFIGURATION
-- ══════════════════════════════════════════
local WS = Tabs.WebhookSetup:AddLeftGroupbox("Setup Configuration", "webhook")
WS:AddLabel(b(createMultiGradientText("DISCORD ENDPOINT", PALETTE.ocean)), true)
WS:AddDivider()

WS:AddInput("WebhookURL", {
    Default = "", 
    Numeric = false, 
    Finished = false, 
    ClearTextOnFocus = false,
    Text = "Webhook URL", 
    Placeholder = "https://discord.com/api/webhooks/...",
    Callback = function(v) wh_url = v end,
})

WS:AddInput("WebhookUserID", {
    Default = "", 
    Numeric = true, 
    Finished = false, 
    ClearTextOnFocus = false,
    Text = "Discord User ID (For Pings)", 
    Placeholder = "123456789012345678",
    Callback = function(v) wh_userId = v end,
})

WS:AddToggle("WebhookPingEnabled", {
    Text = "Enable User Ping", 
    Default = false,
    Callback = function(v) wh_pingEnabled = v end,
})

WS:AddToggle("WebhookPingEveryone", {
    Text = "@everyone Ping Toggle", 
    Default = false,
    Callback = function(v) wh_pingEveryone = v end,
})

-- ══════════════════════════════════════════
--   WEBHOOK SUBTAB 2: INTERACTIVE DIAGNOSTIC
-- ══════════════════════════════════════════
local WT = Tabs.WebhookTest:AddLeftGroupbox("Interactive Diagnostic", "send")
WT:AddLabel(b(createMultiGradientText("EMBED TESTING", PALETTE.prism)), true)
WT:AddDivider()

WT:AddDropdown("WebhookRarityFilter", {
    Values = { "Common", "Uncommon", "Rare", "Epic", "Legendary", "Mythic", "Celestial" },
    Default = "Common",
    Text = "Minimum Webhook Rarity",
    Callback = function(v) wh_minRarity = v end,
})

WT:AddButton({ Text = "Validate Setup Notification", Func = function()
    if wh_url == "" then Library:Notify("Webhook URL is empty!"); return end
    task.spawn(function()
        local payload = {
            embeds = {{
                title = "Webhook Configuration Active",
                description = "Your Webhook setup for **Dungeons Lootr** is verified and active!",
                color = 65280,
                fields = {
                    { name = "User Identity", value = "```" .. LocalPlayer.Name .. "```", inline = true },
                    { name = "Ping Settings", value = "```" .. (wh_userId ~= "" and "Configured" or "Not Specified") .. "```", inline = true },
                    { name = "Filter Level", value = "```" .. wh_minRarity .. "```", inline = true }
                },
                footer = { text = "Prism Diagnostics  •  " .. os.date("%x %X") },
                timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ")
            }}
        }
        local ok, err = pcall(function()
            wh_requestFunc({
                Url = wh_url, Method = "POST",
                Headers = { ["Content-Type"] = "application/json" },
                Body = HttpService:JSONEncode(payload)
            })
        end)
        Library:Notify(ok and "Test processed, check Discord!" or "Error: " .. tostring(err))
    end)
end })

WT:AddButton({ Text = "Simulate Match Complete Log", Func = function()
    if wh_url == "" then Library:Notify("Webhook URL is empty!"); return end
    task.spawn(function()
        local fakeData = {
            PlayerCount = 1,
            ShowFailMessage = false,
            CashEarned = 132,
            TotalEXP = 1444,
            IsVictory = true,
            Status = "Extracted",
            TimeElapsed = 201.35830291201,
            TotalDeaths = 0,
            MobsKilled = 44,
            DungeonName = "Bandit's Den",
            TotalDamage = 40441,
            LocationId = "Bandits Den",
            StarsEarned = 5,
            MaterialRewards = {
                { Id = "Iron Scrap", Amount = 10, Rarity = "Common" }
            },
            PartyLeaderUserId = 11510991822,
            ItemRewards = {
                { Slot = "Ring", Rarity = "Uncommon", ItemId = "ShadowBrigandSoul" },
                { Slot = "Body", Identified = true, Rarity = "Common", ItemId = "OutlawVest" }
            },
            ClassSpinsEarned = 1,
            Difficulty = "Easy",
            RoomsCleared = 4
        }
        wh_isSending = false
        sendDungeonRemoteWebhook(fakeData)
        Library:Notify("Simulation sent! Webhook will deliver.")
    end)
end })

do
    local NameGroup = Tabs.Settings:AddLeftGroupbox("Name Changer", "user")
    NameGroup:AddToggle("EnableNameSpoof", {
        Text = "Enable Name Changer",
        Default = false,
        Tooltip = "Replaces your Roblox username across all visible UI labels and overheads in real time."
    })
    NameGroup:AddInput("SpoofedName", {
        Default = "PrismUser",
        Numeric = false,
        Finished = false,
        ClearTextOnFocus = false,
        Text = "Target Fake Name",
        Placeholder = "Enter alias...",
    })

    Toggles.EnableNameSpoof:OnChanged(function()
        applyNameSpoof()
    end)

    Options.SpoofedName:OnChanged(function()
        if isOn("EnableNameSpoof") then
            applyNameSpoof()
        end
    end)

    local potatoBlackScreen = nil

    local function setPotatoMode(enabled)
        pcall(function()
            RunService:Set3dRenderingEnabled(not enabled)
        end)

        if enabled then
            if not potatoBlackScreen then
                potatoBlackScreen = Instance.new("ScreenGui")
                potatoBlackScreen.Name = "PrismPotatoBlackScreen"
                potatoBlackScreen.IgnoreGuiInset = true
                potatoBlackScreen.DisplayOrder = -100 -- Stays behind the menu UI
                potatoBlackScreen.ResetOnSpawn = false

                local frame = Instance.new("Frame")
                frame.Size = UDim2.new(1, 0, 1, 0)
                frame.BackgroundColor3 = Color3.new(0, 0, 0)
                frame.BorderSizePixel = 0
                frame.ZIndex = -100
                frame.Parent = potatoBlackScreen

                pcall(function()
                    potatoBlackScreen.Parent = game:GetService("CoreGui")
                end)
                if not potatoBlackScreen.Parent then
                    pcall(function()
                        potatoBlackScreen.Parent = LocalPlayer:FindFirstChild("PlayerGui")
                    end)
                end
            else
                potatoBlackScreen.Enabled = true
            end
        else
            if potatoBlackScreen then
                potatoBlackScreen.Enabled = false
            end
        end
    end

    local PerfGroup = Tabs.Settings:AddLeftGroupbox("Performance", "cpu")
    PerfGroup:AddToggle("FPSBoost",   { Text = "FPS Booster", Default = false, Callback = applyFPSBoost })
    PerfGroup:AddToggle("PotatoMode", { Text = "Disable 3D Rendering", Default = false, Callback = setPotatoMode })
    PerfGroup:AddToggle("AntiAFK",    { Text = "Anti-AFK", Default = true })

    local MenuGroup = Tabs.Settings:AddRightGroupbox("Interface", "settings")
    MenuGroup:AddToggle("KeybindMenuOpen", { Text = "Show Keybind Menu", Default = false, Callback = function(v) Library.KeybindFrame.Visible = v end })
    MenuGroup:AddDropdown("NotificationSide", {
        Values = { "Left", "Right" }, Default = "Right", AllowNull = true, Text = "Notification Placement",
        Callback = function(v) pcall(function() Library:SetNotifySide(v or "Right") end) end,
    })
    MenuGroup:AddLabel("Menu Keybind"):AddKeyPicker("MenuKeybind", { Default = "G", NoUI = true, Text = "Menu keybind" })
    Library.ToggleKeybind = Options.MenuKeybind
    MenuGroup:AddButton("Unload Prism", function() Library:Unload() end)
end

SaveManager:BuildConfigSection(Tabs.Settings)
ThemeManager:ApplyToTab(Tabs.Settings)

-- ══════════════════════════════════════════
--   GLOBAL CONNECTIONS & EVENTS
-- ══════════════════════════════════════════

local steppedConnection = RunService.Stepped:Connect(function()
    if Library.Unloaded then return end
    local inMatch = getGameMode() ~= "Lobby"
    if isOn("NoClip") or (isOn("AutoFarm") and inMatch) or dl_dodge_active then
        for i = 1, #characterParts do
            local p = characterParts[i]
            if p and p.Parent then
                p.CanCollide = false
            end
        end
    end
end)

local jumpConnection = UserInputService.JumpRequest:Connect(function()
    if Library.Unloaded then return end
    if isOn("InfJump") then
        local h = getHumanoid()
        if h then h:ChangeState(Enum.HumanoidStateType.Jumping) end
    end
end)

local renderConnection = RunService.RenderStepped:Connect(function()
    if Library.Unloaded then return end
    if isOn("WalkSpeedEnabled") then
        local h = getHumanoid()
        if h then h.WalkSpeed = currentWalkSpeed end
    end
    if isOn("JumpPowerEnabled") then
        local h = getHumanoid()
        if h then h.JumpPower = currentJumpPower end
    end
end)

Toggles.Fly:OnChanged(function(v)
    if v then
        sFLY(false)
    else
        FLYING = false
        if flyKeyDown then flyKeyDown:Disconnect() flyKeyDown = nil end
        if flyKeyUp then flyKeyUp:Disconnect() flyKeyUp = nil end
        local h = getHumanoid()
        if h then h.PlatformStand = false end
    end
end)

Toggles.WalkSpeedEnabled:OnChanged(function(v)
    if not v then
        local h = getHumanoid()
        if h then h.WalkSpeed = 16 end
    end
end)

Toggles.JumpPowerEnabled:OnChanged(function(v)
    if not v then
        local h = getHumanoid()
        if h then h.JumpPower = 50 end
    end
end)

-- ══════════════════════════════════════════
--   ANTI-GAMEPLAY PAUSED SYSTEM
-- ══════════════════════════════════════════

local networkPausedConn = nil

function enableAntiPause()
    pcall(function()
        local CoreGui = game:GetService("CoreGui")
        local RobloxGui = CoreGui:FindFirstChild("RobloxGui")
        if not RobloxGui then return end

        if networkPausedConn then
            networkPausedConn:Disconnect()
            networkPausedConn = nil
        end

        local existing = RobloxGui:FindFirstChild("CoreScripts/NetworkPause")
        if existing then
            existing:Destroy()
        end

        networkPausedConn = RobloxGui.ChildAdded:Connect(function(obj)
            if obj.Name == "CoreScripts/NetworkPause" then
                task.wait()
                pcall(function() obj:Destroy() end)
            end
        end)
    end)
end

enableAntiPause()

-- ══════════════════════════════════════════
--   ANTI-AFK ENGINE
-- ══════════════════════════════════════════

local antiAfkLastInput = tick()
local antiAfkLastTap   = tick()

pcall(function()
    for _, conn in ipairs(getconnections(LocalPlayer.Idled)) do conn:Disable() end
end)

function antiAfkTap()
    local cam = workspace.CurrentCamera
    if not cam then return end
    VirtualUser:Button2Down(Vector2.new(0, 0), cam.CFrame)
    task.wait(0.1)
    VirtualUser:Button2Up(Vector2.new(0, 0), cam.CFrame)
    antiAfkLastTap = tick()
end

UserInputService.InputBegan:Connect(function() antiAfkLastInput = tick() end)
UserInputService.InputChanged:Connect(function(input)
    local t = input.UserInputType
    if t == Enum.UserInputType.MouseMovement or t == Enum.UserInputType.Gamepad1 then
        antiAfkLastInput = tick()
    end
end)

task.spawn(function()
    while not Library.Unloaded do
        task.wait(2)
        if isOn("AntiAFK") then
            local idle = tick() - antiAfkLastInput
            if idle >= 300 and (tick() - antiAfkLastTap >= 60) then
                pcall(antiAfkTap)
            end
        end
    end
end)



-- ══════════════════════════════════════════
--   CLEANUP & UNLOAD HANDLER
-- ══════════════════════════════════════════

Library:OnUnload(function()
    steppedConnection:Disconnect()
    jumpConnection:Disconnect()
    renderConnection:Disconnect()
    dlf_stopMovement()

    if networkPausedConn then
        networkPausedConn:Disconnect()
        networkPausedConn = nil
    end

    FLYING = false
    if flyKeyDown then flyKeyDown:Disconnect() end
    if flyKeyUp then flyKeyUp:Disconnect() end

    applyFPSBoost(false)
    RunService:Set3dRenderingEnabled(true)
    if potatoBlackScreen then
        potatoBlackScreen:Destroy()
        potatoBlackScreen = nil
    end
    local h = getHumanoid()
    if h then
        h.PlatformStand = false
        h.WalkSpeed     = 16
        h.JumpPower     = 50
    end
end)

-- ══════════════════════════════════════════
--   FINALIZE SETUP & CONFIG RESTORATION
-- ══════════════════════════════════════════

ThemeManager:SaveDefault("Claude")
ThemeManager:LoadDefault()

-- Setup explicit Webhook configurations fallback values mapper on config restore
task.spawn(function()
    task.wait(1.5)
    pcall(function()
        if Options.WebhookURL then wh_url = Options.WebhookURL.Value end
        if Options.WebhookUserID then wh_userId = Options.WebhookUserID.Value end
        if Toggles.WebhookPingEnabled then wh_pingEnabled = Toggles.WebhookPingEnabled.Value end
        if Toggles.WebhookPingEveryone then wh_pingEveryone = Toggles.WebhookPingEveryone.Value end
        if Options.WebhookRarityFilter then wh_minRarity = Options.WebhookRarityFilter.Value end
        
        -- Auto apply saved name spoofer configuration
        if Toggles.EnableNameSpoof and Toggles.EnableNameSpoof.Value then
            applyNameSpoof()
        end
    end)
end)

SaveManager:LoadAutoloadConfig()

-- Autoload Settlement Watcher (Ensures custom name applies after config loads)
task.spawn(function()
    task.wait(1.5)
    if isOn("EnableNameSpoof") then
        applyNameSpoof()
    end
    task.wait(3.0)
    if isOn("EnableNameSpoof") then
        applyNameSpoof()
    end
end)

Library:Notify("Prism loaded successfully for Dungeon Lootr, welcome " .. LocalPlayer.Name, 5)
