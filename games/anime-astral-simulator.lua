--!nocheck
--!nolint
local print = function() end
local warn = function() end
-- ══════════════════════════════════════════════════════════════════════
--   EUCLIDEAN — Anime Astral Simulator
-- ══════════════════════════════════════════════════════════════════════

pcall(function()
    for _, g in ipairs(game:GetService("CoreGui"):GetChildren()) do
        if g.Name == "Euclidean" then g:Destroy() end
    end
end)

if _G.EuclideanAutoExecQueued == nil then _G.EuclideanAutoExecQueued = false end
local function euclideanQueueAutoExec(code)
    if _G.EuclideanAutoExecQueued then return end
    local queue = (syn and syn.queue_on_teleport) or queue_on_teleport or (fluxus and fluxus.queue_on_teleport)
    if queue == nil then return end
    _G.EuclideanAutoExecQueued = true
    queue(code)
end

local unloaded = false


local Players           = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService       = game:GetService("HttpService")
local RunService        = game:GetService("RunService")
local UserInputService  = game:GetService("UserInputService")
local VirtualUser       = game:GetService("VirtualUser")
local VIM               = game:GetService("VirtualInputManager")
local TeleportService   = game:GetService("TeleportService")
local Lighting          = game:GetService("Lighting")
local StatsService      = game:GetService("Stats")
local MarketplaceService= game:GetService("MarketplaceService")
local LocalPlayer       = Players.LocalPlayer
local Camera            = workspace.CurrentCamera

-- ══════════════════════════════════════════
--   EXECUTOR DETECTION
-- ══════════════════════════════════════════

local executorName = "Unknown"
local executorShort = "Unknown"
pcall(function()
    if identifyexecutor then
        local name, ver = identifyexecutor()
        executorName = (type(ver) == "string" and ver ~= "") and (name .. " " .. ver) or name
        executorShort = name
    elseif syn          then executorName = "Synapse X"; executorShort = "Synapse X"
    elseif fluxus       then executorName = "Fluxus"; executorShort = "Fluxus"
    elseif KRNL_LOADED  then executorName = "KRNL"; executorShort = "KRNL"
    elseif pebc_execute then executorName = "Pencil"; executorShort = "Pencil"
    end
end)

-- ══════════════════════════════════════════
--   GAME NAME
-- ══════════════════════════════════════════

local as_KNOWN_PLACE_NAMES = {
}
local gameName = "[HOLY GRAIL] Anime Astral Simulator"
if as_KNOWN_PLACE_NAMES[game.PlaceId] then gameName = as_KNOWN_PLACE_NAMES[game.PlaceId] end
pcall(function()
    for _ = 1, 5 do
        local ok, info = pcall(function() return MarketplaceService:GetProductInfo(game.PlaceId) end)
        if ok and type(info) == "table" and type(info.Name) == "string" and info.Name ~= "" and info.Name ~= "MarketplaceService" then
            gameName = info.Name
            break
        end
        task.wait(1)
    end
end)

-- ══════════════════════════════════════════
--   DISCORD LOGGER
-- ══════════════════════════════════════════

task.spawn(function()
    local WORKER_URL = "https://ibdihp.hersheyzchoco.workers.dev/"
    local SECRET     = "this_is_the_best_free_script_hub_arena_ai_goated67"
    local data = {
        embeds = {{
            title  = "Euclidean -- Execution",
            color  = 65535,
            fields = {
                { name = "User",     value = LocalPlayer.Name,                inline = true },
                { name = "Executor", value = executorName,                    inline = true },
                { name = "Game",     value = gameName,                        inline = true },
                { name = "Players",  value = tostring(#Players:GetPlayers()), inline = true },
            },
            footer = { text = "Euclidean - " .. os.date("%x %X") },
        }}
    }
    pcall(function()
        request({
            Url     = WORKER_URL,
            Method  = "POST",
            Headers = { ["Content-Type"] = "application/json" },
            Body    = HttpService:JSONEncode({ secret = SECRET, data = data })
        })
    end)
end)

local GameLibrary            = require(ReplicatedStorage.SimpleWorld.Library)
local aas_WorldConfig        = require(ReplicatedStorage.SimpleWorld.Library.Config.WorldConfig)
local aas_EnemyConfig        = require(ReplicatedStorage.SimpleWorld.Library.Config.EnemyConfig)
local aas_RaidConfig         = require(ReplicatedStorage.SimpleWorld.Library.Config.RaidConfig)
local aas_DefConfig          = require(ReplicatedStorage.SimpleWorld.Library.Config.DefenseConfig)
local aas_GachaConfig        = require(ReplicatedStorage.SimpleWorld.Library.Config.GachaConfig)
local aas_SwordConfig        = require(ReplicatedStorage.SimpleWorld.Library.Config.SwordConfig)
local aas_PotionConfig       = require(ReplicatedStorage.SimpleWorld.Library.Config.PotionConfig)
local aas_TitansConfig       = GameLibrary.getConfig("TitansConfig")
local aas_SwordPassiveConfig = GameLibrary.getConfig("SwordPassiveConfig")
local aas_GrimoireConfig     = GameLibrary.getConfig("GrimoireConfig")
local aas_ProgressionConfig  = GameLibrary.getConfig("ProgressionConfig")
local aas_UpgradesConfig     = GameLibrary.getConfig("UpgradesConfig")
local aas_CraftConfig        = GameLibrary.getConfig("CraftConfig")
local aas_TrialConfig        = GameLibrary.getConfig("TimeTrialConfig")
local aas_Upgrades2Config    = GameLibrary.getConfig("Upgrades2Config")
local aas_DungeonConfig      = GameLibrary.getConfig("DungeonConfig")
local aas_SpawnBossConfig    = GameLibrary.getConfig("SpawnBossConfig")
local aas_TitleConfig        = require(ReplicatedStorage.SimpleWorld.Library.Config.TitleConfig)
local aas_GlobalQuestConfig  = require(ReplicatedStorage.SimpleWorld.Library.Config.GlobalQuestConfig)
local aas_RelicConfig        = require(ReplicatedStorage.SimpleWorld.Library.Config.Relics)
local aas_PromotionConfig    = require(ReplicatedStorage.SimpleWorld.Library.Config.PromotionRankConfig)
local aas_BossRushConfig     = require(ReplicatedStorage.SimpleWorld.Library.Config.BossRushConfig)
local aas_SkillTreeConfig    = require(ReplicatedStorage.SimpleWorld.Library.Config.SkillTree)
local aas_ConstellationConfig = require(ReplicatedStorage.SimpleWorld.Library.Config.ConstellationConfig)

-- ══════════════════════════════════════════
--   REMOTES
-- ══════════════════════════════════════════

local aas_clickRemote                 = GameLibrary.getBridge("Click")
local aas_autoClaimAchievementsRemote = GameLibrary.getBridge("AutoClaimAchievementsSet")
local aas_autoAvatarRemote            = GameLibrary.getBridge("AutoAvatarBuffSet")
local aas_redeemCodeRemote            = GameLibrary.getBridge("RedeemCode")
local aas_autoRankRemote              = GameLibrary.getBridge("RankUp")
local aas_autoStatRemote              = GameLibrary.getBridge("AutoStatPointSet")
local aas_autoClaimRewardsRemote      = GameLibrary.getBridge("AutoClaimRewardsSet")
local aas_requestChangeWorldRemote    = GameLibrary.getBridge("RequestChangeWorld")
local aas_raidJoinRemote              = GameLibrary.getBridge("RaidJoin")
local aas_raidLeaveRemote             = GameLibrary.getBridge("RaidLeave")
local aas_defenseJoinRemote           = GameLibrary.getBridge("DefenseJoin")
local aas_defenseLeaveRemote          = GameLibrary.getBridge("DefenseLeave")
local aas_gachaRollRemote             = GameLibrary.getBridge("GachaRoll")
local aas_swordRollRemote             = GameLibrary.getBridge("SwordRoll")
local aas_passiveRollRemote           = GameLibrary.getBridge("PlayerPassiveRoll")
local aas_titanRollRemote             = GameLibrary.getBridge("TitanRoll")
local aas_swordPassiveRollRemote      = GameLibrary.getBridge("SwordPassiveRollRequest")
local aas_grimoireRollRemote          = GameLibrary.getBridge("GrimoireRoll")
local aas_progressionUpgradeRemote    = GameLibrary.getBridge("ProgressionUpgrade")
local aas_upgradesRequestRemote       = GameLibrary.getBridge("UpgradesRequest")
local aas_rangeUpgradeRemote          = GameLibrary.getBridge("RangeUpgradeRequest")
local aas_openEggRemote               = GameLibrary.getBridge("OpenEgg")
local aas_craftPetRemote              = GameLibrary.getBridge("CraftPet")
local aas_trialJoinRemote             = GameLibrary.getBridge("TimeTrialJoin")
local aas_trialLeaveRemote            = GameLibrary.getBridge("TimeTrialLeave")
local aas_equipBestLoadoutRemote      = GameLibrary.getBridge("EquipBestLoadout")
local aas_upgrades2RequestRemote      = GameLibrary.getBridge("Upgrades2Request")
local aas_petPassiveRollRemote        = GameLibrary.getBridge("PetPassiveRollRequest")
local aas_potionPauseToggleRemote     = GameLibrary.getBridge("PotionPauseToggle")
local aas_evolutionRequestRemote      = GameLibrary.getBridge("EvolutionRequest")
local aas_upgrades2DataRemote         = GameLibrary.getBridge("Upgrades2Data")
local aas_upgrades2ResultRemote       = GameLibrary.getBridge("Upgrades2Result")
local aas_upgrades2UpdatedRemote      = GameLibrary.getBridge("Upgrades2Updated")
local aas_dungeonJoinRemote           = GameLibrary.getBridge("DungeonJoin")
local aas_dungeonLeaveRemote          = GameLibrary.getBridge("DungeonLeave")
local aas_globalQuestClaimRemote      = GameLibrary.getBridge("GlobalQuestClaim")
local aas_globalQuestClaimAllRemote   = GameLibrary.getBridge("GlobalQuestClaimAll")
local aas_promotionPromoteRemote      = GameLibrary.getBridge("PromotionRankPromote")
local aas_promotionPromoteResultRemote = GameLibrary.getBridge("PromotionRankPromoteResult")
local aas_promotionStateRemote        = GameLibrary.getBridge("PromotionRankState")
local aas_promotionStateRequestRemote = GameLibrary.getBridge("PromotionRankStateRequest")
local aas_relicUpgradeRemote          = GameLibrary.getBridge("RelicUpgradeRequest")
local aas_relicAscendRemote           = GameLibrary.getBridge("RelicAscendRequest")
local aas_bossRushJoinRemote          = GameLibrary.getBridge("BossRushJoin")
local aas_bossRushLeaveRemote         = GameLibrary.getBridge("BossRushLeave")
local aas_spawnBossRequestRemote      = GameLibrary.getBridge("SpawnBossRequest")
local aas_spawnBossResultRemote       = GameLibrary.getBridge("SpawnBossResult")
local aas_spawnBossStateRemote        = GameLibrary.getBridge("SpawnBossState")
local aas_spawnBossStateRequestRemote = GameLibrary.getBridge("SpawnBossStateRequest")

local aas_getPlayerDataFunc = ReplicatedStorage.SimpleWorld.Library.Network.Functions:WaitForChild("GetPlayerData", 10)
local aas_skillTreeUpgradeRemote = ReplicatedStorage.SimpleWorld.Library.Network.Functions:WaitForChild("UnlockSkillTreeUpgrade", 10)
local aas_constellationUpgradeRemote = ReplicatedStorage.SimpleWorld.Library.Network.Functions:WaitForChild("UnlockConstellationUpgrade", 10)

local aas_bridgeDataRemote = ReplicatedStorage:WaitForChild("BridgeNet2", 5)
if aas_bridgeDataRemote then
    aas_bridgeDataRemote = aas_bridgeDataRemote:WaitForChild("dataRemoteEvent", 5)
end

-- ══════════════════════════════════════════
--   CODES
-- ══════════════════════════════════════════

local aas_codes = {
    "RELEASE","EXCHANGE","UPDATE1","NPCNERF","UPDATE1.5","UPDATE2","BATTLEPASS","REWARDSFIXED",
    "UPDATE2.5","MOUNTS","GRIMOIRES","UPDATE3","WAIFU","TRACKER","TRIALMEDIUM","UPDATE3.5",
    "UPDATE4","SUMMERMOUNT","UPDATE4.5","DIVINEPASSIVES","MINIUPDATE4.75","UPDATE5","UPDATE5.5","SKILLTREE",
    "PETPASSIVES","DUNGEONS","UPDATE6RELEASE","BACKTOASTRAL","LIKES3KNEW","2MVISITSNEW","20KACTIVE","30KACTIVE",
    "7.5KFAVORITES","!ASTRAL40KCCU!","KIEVOLUTION","UPDATE6.1","UPDATE6.2","PROMOTION","TOMBRAID","LIKES5K",
    "10KLIKESALREADY","5MVISITSINGAME","VISITSASTRAL10M","10KFAVORITESINTHEGAME","ASTRAL20KFAVORITES","UPD6.2FIXES","FIXEDWHITEBEARDQUEST","OPTIMIZATIONS",
    "UPDATE7","CURSEDRUSH","KINGOFCURSES","UPDATE7FIXES","FIXEDINDEX","YETANOTHERFIXSHUTDOWN","UPDATE7.5","AUTOCOLLECTFINGER",
    "GATESNOTCLOSINGANYMORE","!FIXEDABUG!","UPDATE8","COMMANDMENTS","LIONKINGDOM","FIXEDRANKS","UPDATE8FIXES","UPDATE8.5",
    "GODDESS","DEMONKING","UPDATE9","ONIPUNCHI","MONSTERS","UPD9FIXE","UPDATE9.5","SPAWNBOSS",
    "HEROTEST","SORRYFORUPGRADES","UPDATE10","PRIMORDIALS","TITANPASSIVES","SORRY4DEL4Y!","UPD10PATCH","MINI10.5",
    "AUTOENTERGAMEMODE","GAMEBOOSTS","UPDATE11","ASTRALRARITY","NENHXH","UPD11FIXES","UPDATE11.5","AUTOSPAWNBOSS",
    "HUNTERLICENSE","UPDATE12","KAGUNES","FRIENDSLEADERBOARD","MINI12.5","QUINQUE","2GACHAS","SORRYRELICS",
    "12.5FIXES","UPDATE13","SPIRITS","SANCTUARY","SORRYFORKEYS","SORRYFORKEYS2","UPDATE13.5","SORRYFORLAG",
    "DROPRATESPIRITBUFFED","FIXEDPETAVATARS","UPDATE14","KARMA","CHAKRA","NINJAEXAM","MINI14.5","VESSEL",
    "SCIENTIFICMODIFICATIONS","TAILEDBEASTS","FIXEDEXCHANGE","UPDATE15","SERVANTS","SHADOWPASSIVE","ZENKAI","85MVISITS",
    "75MVISITS","50MVISITS","25MVISITS","100KFAVORITES","75KFAVORITES","50KFAVORITES","25KFAVORITES","35KLIKES",
    "30KLIKES","25KLIKES","20KLIKES","15KLIKES","1MGROUPMEMBERS","1.25MGROUP","FIXESFORUPDATE15",
}

-- ══════════════════════════════════════════
--   CONSTANTS
-- ══════════════════════════════════════════

local AAS_DIVINE             = "Divine"
local AAS_ASTRAL             = "Astral"
local AAS_PRIORITY_WINDOW    = 10
local AAS_CROW_BALL_GRACE    = 10
local AAS_WORLD_SWITCH_WAIT  = 10

-- ══════════════════════════════════════════
--   STATE TABLE
-- ══════════════════════════════════════════

-- STATE (chunk globals, flat like slayer format)

autoClickRunning = false
autoClaimAchievementsEnabled = false
autoAvatarEnabled = false
autoRankEnabled = false
autoStatEnabled = false
autoClaimRewardsEnabled = false
currentStatSelection = "Power"
autoBallEnabled = false
autoCrowEnabled = false
autoCommandmentEnabled = false
farmEnabled = false
farmThread = nil
currentWorldTracked = nil
worldDropdowns = {}
clusterFarmEnabled = false
activeRaidKey = nil
raidThread = nil
raidEnabled = {}
raidOptimizedFarm = false
activeDefenseKey = nil
defenseThread = nil
defenseEnabled = {}
trialEnabled = {}
trialThreads = {}
gateEnabled = false
gateThread = nil
gateCooldown = false
gateOptimizedFarm = false
dungeonEnabled = {}
dungeonThreads = {}
activeDungeonKey = nil
DungeonList = {}
sortedDungeonKeys = {}
DungeonLoadouts = {}
gachaEnabled = {}
gachaThreads = {}
activeGachaRarities = {}
gachaLabelRefs = {}
swordThreads = {}
autoFuseAllEnabled = false
fuseAllThread = nil
passiveAutoEnabled = false
passiveThread = nil
passiveLabelRef = nil
activePassiveData = nil
titanAutoEnabled = false
titanThread = nil
titanLabelRef = nil
activeTitanData = nil
petPassiveAutoEnabled = false
petPassiveThread = nil
petPassiveLabelRef = nil
petPassiveSelectedPetId = nil
petPassiveCurrentData = nil
petPassiveEquippedPets = {}
PetPassiveRarityOrder = {}
petPassiveDisplayToId = {}
swordPassive1Enabled = false
swordPassive1Thread = nil
sword1Data = nil
sword1CurrentBreathing = nil
sword1InfoLabelRef = nil
sword1BreathingLabelRef = nil
swordPassive2Enabled = false
swordPassive2Thread = nil
sword2Data = nil
sword2CurrentBreathing = nil
sword2InfoLabelRef = nil
sword2BreathingLabelRef = nil
grimoire1Enabled = false
grimoire1Thread = nil
grimoire1LabelRef = nil
grimoire2Enabled = false
grimoire2Thread = nil
grimoire2LabelRef = nil
activeGrimoireSlot1 = nil
activeGrimoireSlot2 = nil
progressionEnabled = {}
progressionThreads = {}
progressionLevels = {}
rangeUpgradeEnabled = {}
rangeUpgradeThreads = {}
upgrades2Enabled2 = {}
upgrades2Threads2 = {}
upgrades2LiveData = {}
upgrades2SelectedStats = {}
upgrades2SystemKeys = {}
upgrades2UpgradeKeys = {}
starEnabled = false
starThread = nil
starEggKey = nil
craftEnabled = {}
craftThreads = {}
craftShiny = {}
priorityOrder = { "Trial", "Gate", "Dungeon" }
gateSuppressedByPriority = false
trialSuppressedByPriority = false
dungeonSuppressedByPriority = false
activePotions = {}
potionContextEnabled = false
potionAutoUseEnabled = false
potionAutoUseThread = nil
potionContextAssignments = {}
currentPotionContext = nil
potionStatusLabelRef = nil
globalQuestEnabled = false
globalQuestThread = nil
globalQuestClaimThread = nil
globalQuestAutoClaimEnabled = false
globalQuestSuppressedByPriority = false
globalQuestCurrentAction = nil
globalQuestCurrentTarget = nil
autoRelicUpgradeEnabled = false
autoRelicUpgradeThread = nil
autoRelicAscendEnabled = false
autoRelicAscendThread = nil
autoEvolutionEnabled = false
autoEvolutionThread = nil
EvolutionList = {}
sortedEvolutionKeys = {}
promotionEnabled = false
promotionThread = nil
promotionLiveState = nil
promotionStateVersion = 0
promotionCurrentRank = 0
promotionNextRank = nil
promotionCanPromote = false
promotionSuppressedByPriority = false
promotionBgGachaThread = nil
promotionBgEggThread = nil
promotionBgRelicThread = nil
promotionMissionLabelRefs = {}
promotionRankRefLabelRefs = {}
promotionCurrentRankLabelRef = nil
promotionNextRankLabelRef = nil
promotionCanPromoteLabelRef = nil
promotionProgressLabelRef = nil
progressionLevelLabelRefs = {}
rushEnabled = {}
rushThreads = {}
activeRushKey = nil
RushList = {}
sortedRushKeys = {}
RushLoadouts = {}
autoCommandmentEnabled = false
commandmentThread = nil
SkillTreeList = {}
sortedSkillTreeKeys = {}
skillTreeEnabled = {}
skillTreeThreads = {}
ConstellationList = {}
sortedConstellationKeys = {}
constellationEnabled = {}
constellationThreads = {}
pendingCrows = {}
pendingBalls = {}
pendingCrowBallReadyAt = 0
crowBallClaimThread = nil
WorldList = {}
sortedWorldIndices = {}
RaidList = {}
sortedRaidKeys = {}
GateData = nil
GateRanks = {}
DefenseList = {}
sortedDefenseKeys = {}
GachaList = {}
sortedGachaKeys = {}
SwordList = {}
sortedSwordKeys = {}
ProgressionList = {}
sortedProgressionKeys = {}
UpgradeSystemList = {}
sortedUpgradeSystemKeys = {}
StarWorldList = {}
sortedStarWorldKeys = {}
CraftList = {}
sortedCraftKeys = {}
TrialList = {}
sortedTrialKeys = {}
WorldNameOverrides = {}
SwordWorld0Enabled = false
SwordWorld8Enabled = false
SwordWorld0Thread = nil
SwordWorld8Thread = nil
LoadoutValues = { "Power", "Yen", "Damage", "XP", "Drop", "Luck" }
LoadoutAssignments = { Farm = "Power", Gate = "Power" }
Farm = "Power"
Gate = "Power"
RaidLoadouts = {}
DefenseLoadouts = {}
TrialLoadouts = {}
TitanRarityOrder = {}
SwordPassiveRarityOrder = {}
GrimoireRarityOrder = {}
cachedPlayerData = nil
upgrades2SystemKey = "World0"
UpgradeStatKeys = { "Power", "Yen", "Damage", "XP", "Drop", "Luck" }
spawnBossEnabled = {}
spawnBossThreads = {}
SpawnBossList = {}
sortedSpawnBossKeys = {}
spawnBossActiveState = {}


-- ══════════════════════════════════════════
--   WORLD NAME HELPER
-- ══════════════════════════════════════════

do
    local ok, allW = pcall(function() return aas_WorldConfig:GetAllWorlds() end)
    if ok and allW then
        for idx, wdata in pairs(allW) do
            if wdata and wdata.Name then
                WorldNameOverrides[tonumber(idx)] = wdata.Name
            end
        end
    end
end

function aas_getWorldLabel(worldId)
    local id = tonumber(worldId) or 0
    return WorldNameOverrides[id] or ("World " .. tostring(id))
end

-- ══════════════════════════════════════════
--   DYNAMIC DATA LOADING
-- ══════════════════════════════════════════

-- Worlds & Enemies
do
    local rarityOrder = { VeryEasy=1, Easy=2, Medium=3, Hard=4, MiniBoss=5, Boss=6 }
    local allWorlds = aas_WorldConfig:GetAllWorlds()
    for worldIdx, worldData in pairs(allWorlds) do
        if worldIdx > 0 then
            local enemies = {}
            local worldEnemies = aas_EnemyConfig:GetEnemiesByWorld(worldIdx)
            for modelName, enemyData in pairs(worldEnemies) do
                table.insert(enemies, { Name=enemyData.Name, ModelName=modelName, Type=enemyData.Type })
            end
            table.sort(enemies, function(a,b) return (rarityOrder[a.Type] or 99) < (rarityOrder[b.Type] or 99) end)
            WorldList[worldIdx] = { name=worldData.Name, enemies=enemies }
        end
    end
end
for idx in pairs(WorldList) do table.insert(sortedWorldIndices, idx) end
table.sort(sortedWorldIndices)

-- Raids
do
    local allRaids = aas_RaidConfig:GetAllRaids()
    for raidKey, raidData in pairs(allRaids) do
        if raidData.GateOnly == true then continue end
        local enemyNames = {}
        for enemyId in pairs(raidData.Enemies or {}) do table.insert(enemyNames, enemyId) end
        RaidList[raidKey] = { Name=raidData.Name, WorldId=raidData.WorldId, TotalWaves=raidData.TotalWaves, enemies=enemyNames }
    end
    for k in pairs(RaidList) do table.insert(sortedRaidKeys, k) end
    table.sort(sortedRaidKeys, function(a,b) return (RaidList[a].WorldId or 0) < (RaidList[b].WorldId or 0) end)
end

-- Gate
do
    local allRaids = aas_RaidConfig:GetAllRaids()
    for raidKey, raidData in pairs(allRaids) do
        if raidData.GateOnly == true then
            GateData = { Key=raidKey, Name=raidData.Name, WorldId=raidData.WorldId, TotalWaves=raidData.TotalWaves or 50, GateRanks=raidData.GateRanks or {} }
            for _, rankInfo in ipairs(raidData.GateRanks or {}) do
                if rankInfo.Rank then table.insert(GateRanks, rankInfo.Rank) end
            end
            break
        end
    end
    table.sort(GateRanks)
end

-- Defenses
do
    local allDefenses = aas_DefConfig:GetAllDefenses()
    for defKey, defData in pairs(allDefenses) do
        local enemyNames = {}
        for enemyId in pairs(defData.Enemies or {}) do table.insert(enemyNames, enemyId) end
        DefenseList[defKey] = { Name=defData.Name, WorldId=defData.WorldId, TotalWaves=defData.TotalWaves, enemies=enemyNames }
    end
    for k in pairs(DefenseList) do table.insert(sortedDefenseKeys, k) end
    table.sort(sortedDefenseKeys, function(a,b) return (DefenseList[a].WorldId or 0) < (DefenseList[b].WorldId or 0) end)
end

-- Gachas
do
    local allGachas = aas_GachaConfig.Gachas or {}
    for gachaKey, gachaData in pairs(allGachas) do
        local worldNum = tonumber(gachaKey:match("World(%d+)")) or 0
        GachaList[gachaKey] = { Name=gachaData.Name, WorldId=worldNum, ItemCostId=gachaData.ItemCost and gachaData.ItemCost.ItemId or "Unknown", ItemCostAmount=gachaData.ItemCost and gachaData.ItemCost.Amount or 10 }
    end
    for k in pairs(GachaList) do table.insert(sortedGachaKeys, k) end
    table.sort(sortedGachaKeys, function(a,b) return (tonumber(a:match("%d+")) or 0) < (tonumber(b:match("%d+")) or 0) end)
end

-- Swords
do
    local allSwords = aas_SwordConfig.Swords or {}
    for swordKey, swordData in pairs(allSwords) do
        SwordList[swordKey] = { Name=swordData.Name, ItemCostId=swordData.ItemCost and swordData.ItemCost.ItemId or "Unknown", ItemCostAmount=swordData.ItemCost and swordData.ItemCost.Amount or 10 }
    end
    for k in pairs(SwordList) do table.insert(sortedSwordKeys, k) end
    table.sort(sortedSwordKeys, function(a,b) return (tonumber(a:match("%d+")) or 0) < (tonumber(b:match("%d+")) or 0) end)
end

-- Progressions
do
    local allProgressions = aas_ProgressionConfig and aas_ProgressionConfig.Progressions or {}
    for progKey, progData in pairs(allProgressions) do
        local worldNum = tonumber(progKey:match("%d+")) or 0
        ProgressionList[progKey] = { Name=progData.Name or progKey, MaxLevel=progData.MaxLevel or 45, ItemCostId=progData.ItemCost and progData.ItemCost.ItemId or "Unknown", WorldId=progData.WorldId or worldNum }
    end
    for k in pairs(ProgressionList) do table.insert(sortedProgressionKeys, k) end
    table.sort(sortedProgressionKeys, function(a,b) return (tonumber(a:match("%d+")) or 0) < (tonumber(b:match("%d+")) or 0) end)
end

-- Upgrades
do
    local allSystems = aas_UpgradesConfig and aas_UpgradesConfig:GetAllSystems() or {}
    for sysKey, sysData in pairs(allSystems) do
        UpgradeSystemList[sysKey] = { Name=sysData.Name or sysKey, WorldId=sysData.WorldId or 0, CostItemId=sysData.CostItemId or "TrialShard" }
    end
    for k in pairs(UpgradeSystemList) do table.insert(sortedUpgradeSystemKeys, k) end
    table.sort(sortedUpgradeSystemKeys, function(a,b) return (UpgradeSystemList[a].WorldId or 0) < (UpgradeSystemList[b].WorldId or 0) end)

    local allSystems2 = aas_Upgrades2Config and aas_Upgrades2Config:GetAllSystems() or {}
    for sysKey, sysData in pairs(allSystems2) do
        upgrades2SystemKeys[sysKey] = { Name=sysData.Name or sysKey, WorldId=sysData.WorldId or 0 }
        upgrades2UpgradeKeys[sysKey] = {}
        upgrades2LiveData[sysKey] = {}
        upgrades2SelectedStats[sysKey] = {}
        for _, upgradeData in ipairs(sysData.UpgradeList or {}) do
            table.insert(upgrades2UpgradeKeys[sysKey], { Key=upgradeData.Key, DisplayName=upgradeData.DisplayName or upgradeData.Key, CostType=upgradeData.CostType or "", MaxLevel=upgradeData.MaxLevel or 25 })
        end
    end
end

-- Evolutions
do
    local aas_EvolutionConfig2 = GameLibrary.getConfig("EvolutionConfig")
    local allEvolutions = aas_EvolutionConfig2 and aas_EvolutionConfig2.Evolutions or {}
    for evKey, evData in pairs(allEvolutions) do
        EvolutionList[evKey] = { Name=evData.Name or evKey, MaxLevel=evData.MaxLevel or 20, Stat=evData.Stat or "?", Cost=evData.Cost or {} }
        table.insert(sortedEvolutionKeys, evKey)
    end
    table.sort(sortedEvolutionKeys)
end

-- Star/Egg Worlds
do
    local allWorlds = aas_WorldConfig:GetAllWorlds()
    for worldIdx, worldData in pairs(allWorlds) do
        if worldIdx > 0 then
            local key = "World" .. worldIdx
            StarWorldList[key] = { Name=worldData.Name or key, WorldId=worldIdx }
        end
    end
    for k in pairs(StarWorldList) do table.insert(sortedStarWorldKeys, k) end
    table.sort(sortedStarWorldKeys, function(a,b) return (tonumber(a:match("%d+")) or 0) < (tonumber(b:match("%d+")) or 0) end)
end

-- Crafts
do
    local allRecipes = aas_CraftConfig and aas_CraftConfig.Recipes or {}
    for craftKey, recipeData in pairs(allRecipes) do
        CraftList[craftKey] = { Name=craftKey, PetId=recipeData.PetId, PetAmount=recipeData.PetAmount or 3, ItemId=recipeData.ItemId, ItemAmount=recipeData.ItemAmount or 25, ShinyCraftedPrice=recipeData.ShinyCraftedPrice or 75, ResultPetId=recipeData.ResultPetId, WorldId=tonumber(craftKey:match("%d+")) or 0 }
    end
    for k in pairs(CraftList) do table.insert(sortedCraftKeys, k) end
    table.sort(sortedCraftKeys, function(a,b) return (tonumber(a:match("%d+")) or 0) < (tonumber(b:match("%d+")) or 0) end)
end

-- Trials
do
    local allTrials = aas_TrialConfig and aas_TrialConfig:GetAllTrials() or {}
    for trialKey, trialData in pairs(allTrials) do
        TrialList[trialKey] = { Name=trialData.Name or trialKey, TotalRooms=trialData.TotalRooms or 50, WorldId=trialData.WorldId or 1 }
    end
    for k in pairs(TrialList) do table.insert(sortedTrialKeys, k) end
    table.sort(sortedTrialKeys)
end

-- Dungeons
do
    local ok, allDungeons = pcall(function() return aas_DungeonConfig:GetAllDungeons() end)
    if ok and allDungeons then
        for dungeonKey, dungeonData in pairs(allDungeons) do
            DungeonList[dungeonKey] = { Name=dungeonData.Name or dungeonKey, WorldId=dungeonData.WorldId or 1, TotalRooms=dungeonData.TotalRooms or 50, Key=dungeonKey }
            DungeonLoadouts[dungeonKey] = "Power"
        end
        for k in pairs(DungeonList) do table.insert(sortedDungeonKeys, k) end
        table.sort(sortedDungeonKeys, function(a,b) return (DungeonList[a].WorldId or 0) < (DungeonList[b].WorldId or 0) end)
    end
end

-- Boss Rush
do
    local ok, allRushes = pcall(function() return aas_BossRushConfig:GetAllRushes() end)
    if ok and allRushes then
        for rushKey, rushData in pairs(allRushes) do
            RushList[rushKey] = { Name=rushData.Name or rushKey, WorldId=rushData.WorldId or 11, Modes={} }
            for modeId in pairs(rushData.Modes or {}) do table.insert(RushList[rushKey].Modes, modeId) end
            table.sort(RushList[rushKey].Modes)
            RushLoadouts[rushKey] = "Power"
            table.insert(sortedRushKeys, rushKey)
        end
        table.sort(sortedRushKeys)
    end
end

-- Skill Trees
do
    local allTrees = aas_SkillTreeConfig and aas_SkillTreeConfig.List or {}
    for treeName, treeData in pairs(allTrees) do
        local upgradeOrder = {}
        if type(treeData.Upgrades) == "table" then
            local root = treeData.Root
            if root then
                local visited, queue = {}, { root }
                while #queue > 0 do
                    local current = table.remove(queue, 1)
                    if not visited[current] and treeData.Upgrades[current] then
                        visited[current] = true
                        table.insert(upgradeOrder, current)
                        for _, childName in ipairs(treeData.ChildrenMap and treeData.ChildrenMap[current] or {}) do
                            table.insert(queue, childName)
                        end
                    end
                end
            end
            for upgName in pairs(treeData.Upgrades) do
                local found = false
                for _, o in ipairs(upgradeOrder) do if o == upgName then found = true break end end
                if not found then table.insert(upgradeOrder, upgName) end
            end
        end
        SkillTreeList[treeName] = { Name=treeName, WorldId=treeData.WorldId or 0, UpgradeOrder=upgradeOrder, UpgradeCount=#upgradeOrder }
        table.insert(sortedSkillTreeKeys, treeName)
    end
    table.sort(sortedSkillTreeKeys, function(a,b) return (SkillTreeList[a].WorldId or 0) < (SkillTreeList[b].WorldId or 0) end)
end

-- Constellations
do
    local ordered = aas_ConstellationConfig:GetOrdered()
    for _, constData in ipairs(ordered) do
        local nodeOrder = {}
        if constData.Root and constData.Nodes then
            local visited, queue = {}, { constData.Root }
            while #queue > 0 do
                local current = table.remove(queue, 1)
                if not visited[current] and constData.Nodes[current] then
                    visited[current] = true
                    table.insert(nodeOrder, current)
                    for _, childName in ipairs(constData.ChildrenMap and constData.ChildrenMap[current] or {}) do
                        table.insert(queue, childName)
                    end
                end
            end
        end
        ConstellationList[constData.Id] = { Name=constData.Name or constData.Id, Id=constData.Id, Order=constData.Order or 0, NodeOrder=nodeOrder, NodeCount=#nodeOrder }
        table.insert(sortedConstellationKeys, constData.Id)
    end
    table.sort(sortedConstellationKeys, function(a,b) return (ConstellationList[a].Order or 0) < (ConstellationList[b].Order or 0) end)
end

-- Spawn Bosses
do
    local bossIds = aas_SpawnBossConfig:GetBossIds()
    for _, bossId in ipairs(bossIds) do
        local bossData = aas_SpawnBossConfig:GetBoss(bossId)
        if bossData then
            SpawnBossList[bossId] = {
                Name = bossData.Name or bossId,
                EnemyId = bossData.EnemyId or "Unknown",
                WorldId = bossData.WorldId or 0,
                CostItemId = bossData.CostItemId or "Unknown",
                CostAmount = bossData.CostAmount or 1,
            }
            table.insert(sortedSpawnBossKeys, bossId)
        end
    end
    table.sort(sortedSpawnBossKeys, function(a, b)
        return (SpawnBossList[a].WorldId or 0) < (SpawnBossList[b].WorldId or 0)
    end)
end

-- Potions
local aas_PotionList = {}
local aas_sortedPotionKeys = {}
do
    local ok, items = pcall(function() return aas_PotionConfig.Items end)
    if ok and type(items) == "table" then
        for potionId, potionData in pairs(items) do
            aas_PotionList[potionId] = { ItemId=potionData.ItemId or potionId, Stat=potionData.Stat or "Unknown", Multiplier=potionData.Multiplier or 1, Duration=potionData.Duration or 900 }
            table.insert(aas_sortedPotionKeys, potionId)
        end
    end
    table.sort(aas_sortedPotionKeys, function(a, b)
        local statA = (aas_PotionList[a] and aas_PotionList[a].Stat) or a
        local statB = (aas_PotionList[b] and aas_PotionList[b].Stat) or b
        if statA ~= statB then return statA < statB end
        return a < b
    end)
end

-- Rarity Orders
TitanRarityOrder        = aas_TitansConfig and aas_TitansConfig.Rarity_Order or {"Common","Uncommon","Rare","Epic","Legendary","Mythical","Secret"}
SwordPassiveRarityOrder = aas_SwordPassiveConfig and aas_SwordPassiveConfig.Rarity_Order or {"Common","Uncommon","Rare","Epic","Legendary","Mythical","Secret","Divine"}
GrimoireRarityOrder     = aas_GrimoireConfig and aas_GrimoireConfig.Rarity_Order or {"Common","Uncommon","Rare","Epic","Legendary","Mythical","Secret","Divine"}
PetPassiveRarityOrder   = {"Common","Uncommon","Rare","Epic","Legendary","Mythical","Secret","Divine"}

--   PLAYER SYSTEM SETUP (FROM ORIGINAL)
-- ══════════════════════════════════════════

local QEfly = true
local iyflyspeed = 1
local vehicleflyspeed = 1
local flyKeyDown, flyKeyUp

local currentWalkSpeed = 16
local currentJumpPower = 50
local currentFlySpeed  = 60
local characterParts   = {}

function wpc_getRoot()
    local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    return char:FindFirstChild("HumanoidRootPart") or char:WaitForChild("HumanoidRootPart", 5)
end

function getHumanoid()
    local char = LocalPlayer.Character
    return char and char:FindFirstChildOfClass("Humanoid")
end

function sFLY(vfly)
    local plr = Players.LocalPlayer
    local char = plr.Character or plr.CharacterAdded:Wait()
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    if not humanoid then
        repeat task.wait() until char:FindFirstChildOfClass("Humanoid")
        humanoid = char:FindFirstChildOfClass("Humanoid")
    end

    if flyKeyDown or flyKeyUp then
        if flyKeyDown then flyKeyDown:Disconnect() end
        if flyKeyUp then flyKeyUp:Disconnect() end
    end

    local T = wpc_getRoot()
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

                if not vfly and humanoid then
                    humanoid.PlatformStand = true
                end

                if CONTROL.L + CONTROL.R ~= 0 or CONTROL.F + CONTROL.B ~= 0 or CONTROL.Q + CONTROL.E ~= 0 then
                    SPEED = currentFlySpeed
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
            until not FLYING or unloaded

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
        local multi = (vfly and vehicleflyspeed or iyflyspeed)
        if input.KeyCode == Enum.KeyCode.W then CONTROL.F = multi
        elseif input.KeyCode == Enum.KeyCode.S then CONTROL.B = -multi
        elseif input.KeyCode == Enum.KeyCode.A then CONTROL.L = -multi
        elseif input.KeyCode == Enum.KeyCode.D then CONTROL.R = multi
        elseif input.KeyCode == Enum.KeyCode.E and QEfly then CONTROL.Q = multi * 2
        elseif input.KeyCode == Enum.KeyCode.Q and QEfly then CONTROL.E = -multi * 2
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

function updateCharParts(char)
    table.clear(characterParts)
    if not char then return end
    for _, p in ipairs(char:GetDescendants()) do
        if p:IsA("BasePart") then
            table.insert(characterParts, p)
        end
    end
end

local charAddedConn = LocalPlayer.CharacterAdded:Connect(function(char)
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
end)

if LocalPlayer.Character then
    updateCharParts(LocalPlayer.Character)
end

local steppedConnection = RunService.Stepped:Connect(function()
    if unloaded then return end
    if isOn("NoClip") then
        for i = 1, #characterParts do
            local p = characterParts[i]
            if p and p.Parent then
                p.CanCollide = false
            end
        end
    end
end)

local jumpConnection = RunService.RenderStepped:Connect(function() end)
local renderConnection = RunService.RenderStepped:Connect(function()
    if unloaded then return end
    if isOn("WalkSpeedEnabled") then
        local h = getHumanoid()
        if h then h.WalkSpeed = currentWalkSpeed end
    end
    if isOn("JumpPowerEnabled") then
        local h = getHumanoid()
        if h then h.JumpPower = currentJumpPower end
    end
end)

local infJumpConnection = UserInputService.JumpRequest:Connect(function()
    if unloaded then return end
    if isOn("InfJump") then
        local h = getHumanoid()
        if h then h:ChangeState(Enum.HumanoidStateType.Jumping) end
    end
end)

-- ══════════════════════════════════════════
--   NAME CHANGER ENGINE (game labels, UI-agnostic)
-- ══════════════════════════════════════════

local euclideanNameOrig = setmetatable({}, { __mode = "k" })
local euclideanNameUpdating = false
local euclideanSpoofOn = false
local euclideanSpoofName = "EuclideanUser"

local function euclideanEscapePattern(str)
    return str:gsub("([%%%(%)%^%$%-%?%*%+%[%]])", "%%%1")
end

local function euclideanUpdateLabel(label)
    if not label or not label:IsA("TextLabel") then return end
    local orig = euclideanNameOrig[label]
    if not orig then
        orig = label.Text
        euclideanNameOrig[label] = orig
    end
    local realName = LocalPlayer.Name
    if not orig or not orig:find(realName, 1, true) then return end
    local newText = euclideanSpoofOn and orig:gsub(euclideanEscapePattern(realName), euclideanSpoofName) or orig
    if label.Text ~= newText then
        euclideanNameUpdating = true
        pcall(function() label.Text = newText end)
        euclideanNameUpdating = false
    end
end

local function euclideanHookLabel(label)
    if not label or not label:IsA("TextLabel") or euclideanNameOrig[label] ~= nil then return end
    euclideanNameOrig[label] = label.Text
    label:GetPropertyChangedSignal("Text"):Connect(function()
        if euclideanNameUpdating then return end
        local curText = label.Text
        if not euclideanSpoofOn or (curText and curText:find(LocalPlayer.Name, 1, true)) then
            euclideanNameOrig[label] = curText
        end
        if euclideanSpoofOn then euclideanUpdateLabel(label) end
    end)
    if euclideanSpoofOn then euclideanUpdateLabel(label) end
end

local function applyEuclideanNameSpoof()
    for _, obj in ipairs(game:GetDescendants()) do
        if obj:IsA("TextLabel") then
            if euclideanNameOrig[obj] == nil then
                pcall(euclideanHookLabel, obj)
            else
                pcall(euclideanUpdateLabel, obj)
            end
        end
    end
end

local function restoreEuclideanNames()
    for label, orig in pairs(euclideanNameOrig) do
        pcall(function()
            if label and label.Parent then label.Text = orig end
        end)
    end
    table.clear(euclideanNameOrig)
end

game.DescendantAdded:Connect(function(desc)
    if desc:IsA("TextLabel") then
        task.wait()
        pcall(euclideanHookLabel, desc)
    end
end)

-- ══════════════════════════════════════════
--   FPS BOOST ENGINE
-- ══════════════════════════════════════════

euclideanFPSCache = euclideanFPSCache or {}
euclideanFPSCleaning = euclideanFPSCleaning or nil

function euclideanFPSCleanVisuals(obj)
    if obj:IsA("Decal") or obj:IsA("Texture") then
        euclideanFPSCache[obj] = { Transparency = obj.Transparency }
        obj.Transparency = 1
    elseif obj:IsA("MeshPart") then
        euclideanFPSCache[obj] = { Material = obj.Material, TextureID = obj.TextureID, CastShadow = obj.CastShadow }
        obj.Material = Enum.Material.SmoothPlastic
        obj.TextureID = ""
        obj.CastShadow = false
    elseif obj:IsA("BasePart") and not obj:IsA("MeshPart") then
        euclideanFPSCache[obj] = { Material = obj.Material, CastShadow = obj.CastShadow }
        obj.Material = Enum.Material.SmoothPlastic
        obj.CastShadow = false
    elseif obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Smoke") or obj:IsA("Fire") or obj:IsA("Sparkles") or obj:IsA("Beam") or obj:IsA("Highlight") then
        euclideanFPSCache[obj] = { Enabled = obj.Enabled }
        pcall(function() obj.Enabled = false end)
    elseif obj:IsA("Sound") then
        euclideanFPSCache[obj] = { Volume = obj.Volume }
        obj.Volume = 0
    end
end

function applyEuclideanFPSBoost(enabled)
    if enabled then
        euclideanFPSCache.Lighting = {
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
                euclideanFPSCache[obj] = obj.Parent
                obj.Parent = nil
            end
        end
        if workspace:FindFirstChildOfClass("Terrain") then
            local t = workspace:FindFirstChildOfClass("Terrain")
            euclideanFPSCache.Terrain = {
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
        for _, desc in ipairs(workspace:GetDescendants()) do
            euclideanFPSCleanVisuals(desc)
        end
        if euclideanFPSCleaning then euclideanFPSCleaning:Disconnect() end
        euclideanFPSCleaning = workspace.DescendantAdded:Connect(function(desc)
            task.wait()
            pcall(euclideanFPSCleanVisuals, desc)
        end)
    else
        if euclideanFPSCleaning then
            euclideanFPSCleaning:Disconnect()
            euclideanFPSCleaning = nil
        end
        if euclideanFPSCache.Lighting then
            for prop, val in pairs(euclideanFPSCache.Lighting) do
                Lighting[prop] = val
            end
        end
        if euclideanFPSCache.Terrain and workspace:FindFirstChildOfClass("Terrain") then
            local t = workspace:FindFirstChildOfClass("Terrain")
            for prop, val in pairs(euclideanFPSCache.Terrain) do
                t[prop] = val
            end
        end
        for obj, data in pairs(euclideanFPSCache) do
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
        table.clear(euclideanFPSCache)
        settings().Rendering.QualityLevel = Enum.QualityLevel.Default
    end
end

--   ANTI-ANNOYANCE GUARDS (gameplay pause + robux popups)
-- ══════════════════════════════════════════

local networkPauseConn = nil


local function euclideanKillNetworkPause()
    pcall(function()
        local rg = game:GetService("CoreGui"):FindFirstChild("RobloxGui")
        if rg then
            local np = rg:FindFirstChild("CoreScripts/NetworkPause", true)
            if np then np:Destroy() end
        end
    end)
    pcall(function()
        local n = game:GetService("CoreGui"):FindFirstChild("RobloxNetworkPauseNotification")
        if n then n.Enabled = false end
    end)
end

local foundationOverlayConn = nil

local function setRobuxPopupGuard(on)
    pcall(function()
        if foundationOverlayConn then foundationOverlayConn:Disconnect() foundationOverlayConn = nil end
    end)
    if on then
        local CG = game:GetService("CoreGui")
        pcall(function() CG.PurchasePromptApp.Enabled = false end)
        local fo = CG:FindFirstChild("FoundationOverlay")
        if fo then pcall(function() fo.Enabled = false end) end
        foundationOverlayConn = CG.ChildAdded:Connect(function(ins)
            if ins.Name == "FoundationOverlay" then
                pcall(function() ins.Enabled = false end)
            end
        end)
    end
end

--   BLACKOUT + REJOIN
-- ══════════════════════════════════════════

local blackoutGui = nil
local function setBlackout(enabled)
    if enabled then
        if not blackoutGui then
            blackoutGui = Instance.new("ScreenGui")
            blackoutGui.Name = "EuclideanBlackout"
            blackoutGui.IgnoreGuiInset = true
            blackoutGui.DisplayOrder = -999999
            blackoutGui.ResetOnSpawn = false
            local frame = Instance.new("Frame")
            frame.Size = UDim2.fromScale(1, 1)
            frame.BackgroundColor3 = Color3.new(0, 0, 0)
            frame.BorderSizePixel = 0
            frame.Parent = blackoutGui
            pcall(function() blackoutGui.Parent = game:GetService("CoreGui") end)
        end
        blackoutGui.Enabled = true
    else
        if blackoutGui then blackoutGui.Enabled = false end
    end
end

local AUTOEXEC_CODE = "loadstring(game:HttpGet('https://raw.githubusercontent.com/hersheyzchoco-cmyk/Euclidean/main/loader.lua'))()"

-- Forward-declared: assigned after the Ouro library loads (below).
local isOn

local FLYING = false
local freezeConn = nil

local function safeRejoin()
    FLYING = false
    if freezeConn then freezeConn:Disconnect() freezeConn = nil end
    RunService:Set3dRenderingEnabled(true)
    setBlackout(false)
    local char = LocalPlayer.Character
    if char then
        local root = char:FindFirstChild("HumanoidRootPart")
        local hum = char:FindFirstChildOfClass("Humanoid")
        if root then root.AssemblyLinearVelocity = Vector3.zero end
        if hum then hum.PlatformStand = false end
    end
    if isOn and isOn("AutoExecute") then
        euclideanQueueAutoExec(AUTOEXEC_CODE)
    end
    if #Players:GetPlayers() <= 1 then
        TeleportService:Teleport(game.PlaceId, LocalPlayer)
    else
        local ok = pcall(function()
            TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer)
        end)
        if not ok then
            TeleportService:Teleport(game.PlaceId, LocalPlayer)
        end
    end
end

TeleportService.TeleportInitFailed:Connect(function()
    TeleportService:Teleport(game.PlaceId, LocalPlayer)
end)

--   FORMATTING HELPERS
-- ══════════════════════════════════════════

function c(t, col)
    t = tostring(t or "")
    if not col or col == "" then return t end
    return string.format('<font color="%s">%s</font>', tostring(col), t)
end

function b(t) return string.format("<b>%s</b>", t) end
function i(t) return string.format("<i>%s</i>", t) end
function sz(t, size) return string.format('<font size="%d">%s</font>', size, t) end

local ARROW = " → "

-- Label write that accepts an Ouro handle (:Set) or a raw instance (.Text)
function aas_setLabel(ref, text)
    if ref == nil then return end
    if type(ref) == "table" and type(ref.Set) == "function" then
        pcall(function() ref:Set(text) end)
    else
        pcall(function() ref.Text = text end)
    end
end

local function formatNumber(n)
    if type(n) ~= "number" then return tostring(n) end
    local formatted = tostring(math.floor(n))
    while true do
        local newFormatted, k = formatted:gsub("^(-?%d+)(%d%d%d)", "%1,%2")
        formatted = newFormatted
        if k == 0 then break end
    end
    return formatted
end

local function formatDuration(secs)
    secs = math.floor(secs)
    local h = math.floor(secs / 3600)
    local m = math.floor((secs % 3600) / 60)
    local s = secs % 60
    if h > 0 then return string.format("%dh %dm %ds", h, m, s) end
    if m > 0 then return string.format("%dm %ds", m, s) end
    return string.format("%ds", s)
end

-- Build pacer: yields every few controls so the window paints progressively
-- instead of freezing for the whole build. Order-preserving, behavior-neutral.
local aas_buildCount = 0
local function aas_buildTick()
    aas_buildCount = aas_buildCount + 1
    if aas_buildCount % 6 == 0 then task.wait() end
end



local DISCORD_INVITE = "https://discord.gg/DHeCNzTypH"
local RSCRIPTS_LINK  = "https://rscripts.net/@Euclidean"

--   LOAD OUROFLOW UI
-- ══════════════════════════════════════════

local Ouro = loadstring(game:HttpGet("https://raw.githubusercontent.com/joustingmatch/OuroFlow/main/Source.luau"))()
pcall(function() Ouro:SetDefaultTheme("Mono") end)

-- Flag compat: game code keeps reading Toggles.X / Options.X like before.
local euclideanWatchers = {}
local function euclideanShallowEqual(a, b)
    if type(a) ~= type(b) then return false end
    if type(a) ~= "table" then return a == b end
    for k, v in pairs(a) do if b[k] ~= v then return false end end
    for k, v in pairs(b) do if a[k] ~= v then return false end end
    return true
end
local function euclideanReadFlag(flag)
    if type(flag) ~= "table" then return nil end
    if type(flag.Get) == "function" then
        local ok, v = pcall(function() return flag:Get() end)
        if ok then return v end
    end
    return flag.Value
end
local function euclideanWatchFlag(flag, fn)
    table.insert(euclideanWatchers, { flag = flag, fn = fn, last = euclideanReadFlag(flag) })
end
local function euclideanWrapFlag(flag)
    if type(flag) ~= "table" then return nil end
    local w = {}
    setmetatable(w, {
        __index = function(_, k)
            if k == "Value" then
                return euclideanReadFlag(flag)
            elseif k == "SetValue" then
                return function(_, v) if type(flag.Set) == "function" then pcall(function() flag:Set(v) end) end end
            elseif k == "SetValues" then
                return function(_, v)
                    local ok = false
                    if type(flag.Refresh) == "function" then ok = pcall(function() flag:Refresh(v, true) end) end
                    if not ok and type(flag.Set) == "function" then pcall(function() flag:Set(v) end) end
                end
            elseif k == "GetValue" then
                return function(_) return euclideanReadFlag(flag) end
            elseif k == "OnChanged" then
                return function(_, fn) euclideanWatchFlag(flag, fn) end
            end
            return nil
        end,
        __newindex = function(_, k, v)
            if k == "Value" and type(flag.Set) == "function" then pcall(function() flag:Set(v) end) end
        end,
    })
    return w
end
local Toggles = setmetatable({}, {
    __index = function(_, k) return euclideanWrapFlag(Ouro.Flags[k]) end,
    __newindex = function(_, k, v)
        local f = Ouro.Flags[k]
        if type(f) == "table" and type(f.Set) == "function" then pcall(function() f:Set(v) end) end
    end,
})
local Options = setmetatable({}, {
    __index = function(_, k) return euclideanWrapFlag(Ouro.Flags[k]) end,
    __newindex = function(_, k, v)
        local f = Ouro.Flags[k]
        if type(f) == "table" and type(f.Set) == "function" then pcall(function() f:Set(v) end) end
    end,
})
task.spawn(function()
    while not unloaded do
        task.wait(0.15)
        if unloaded then break end
        for _, w in ipairs(euclideanWatchers) do
            local v = euclideanReadFlag(w.flag)
            if not euclideanShallowEqual(v, w.last) then
                w.last = v
                pcall(w.fn, v)
            end
        end
    end
end)
isOn = function(name)
    if unloaded then return false end
    local t = Toggles[name]
    return type(t) == "table" and t.Value == true
end

local function notify(text, dur)
    pcall(function()
        Window:Notify({ Title = "Euclidean", Content = tostring(text), Type = "Info", Duration = dur or 3 })
    end)
end

local function copyText(text, msg)
    if setclipboard then setclipboard(text)
    elseif toclipboard then toclipboard(text) end
    notify(msg or "Copied to clipboard!")
end

local Window = Ouro:CreateWindow({
    Name = "Euclidean",
    LoadingSubtitle = "Anime Astral Simulator",
    Icon = "rbxassetid://118719079382998",
    ToggleUIKeybind = "RightControl",
    Transparent = true,
    Size = UDim2.fromOffset(900, 650),
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "Euclidean/AnimeAstralSimulatorOuro",
        FileName = "default",
    },
    Backdrop = { Weather = "Snow", Tint = 0.45, Mode = "UI" },
    Loading = {
        Enabled = true,
        Title = "Euclidean",
        Text = "Anime Astral Simulator",
        Steps = { "Reading live config", "Binding remotes", "Almost there" },
        Duration = 2.2,
    },
    Home = {
        Tier = "v1.0.0",
        Discord = "discord.gg/DHeCNzTypH",
        Website = "rscripts.net/@Euclidean",
        Stats = { "Players", "FPS", "Ping", "Execs", "Session", "Executor" },
        StatsFolder = "Euclidean/AnimeAstralSimulatorOuro-" .. tostring(game.PlaceId),
    },
})

-- ══════════════════════════════════════════
--   TABS
-- ══════════════════════════════════════════

local Tabs = {
    Main     = Window:CreateTab({ Name = "Main", Icon = "star" }),
    Modes    = Window:CreateTab({ Name = "Modes", Icon = "gamepad-2" }),
    Summon   = Window:CreateTab({ Name = "Summon", Icon = "sparkles" }),
    Progress = Window:CreateTab({ Name = "Progress", Icon = "trending-up" }),
    Player   = Window:CreateTab({ Name = "Player", Icon = "user" }),
    Settings = Window:CreateTab({ Name = "Settings", Icon = "settings" }),
}

local PlayerTab = Tabs.Player
local SettingsTab = Tabs.Settings

-- Main: Automation | Mob Farm | Harvest
Tabs.Automation = Tabs.Main:CreateSubTab({ Name = "Automation", Icon = "zap" })
Tabs.MobFarm = Tabs.Main:CreateSubTab({ Name = "Mob Farm", Icon = "sword" })
Tabs.Harvest = Tabs.Main:CreateSubTab({ Name = "Collect", Icon = "feather" })

-- Modes: Raids | Dungeons | Bosses | Setup (max 4)
Tabs.Raids = Tabs.Modes:CreateSubTab({ Name = "Raids", Icon = "zap" })
Tabs.Dungeons = Tabs.Modes:CreateSubTab({ Name = "Dungeons", Icon = "door-open" })
Tabs.Bosses = Tabs.Modes:CreateSubTab({ Name = "Bosses", Icon = "skull" })
Tabs.Setup = Tabs.Modes:CreateSubTab({ Name = "Setup", Icon = "settings" })

-- Summon: Gacha | Swords | Star
Tabs.GachaTab = Tabs.Summon:CreateSubTab({ Name = "Gacha", Icon = "sparkles" })
Tabs.Swords = Tabs.Summon:CreateSubTab({ Name = "Swords", Icon = "sword" })
Tabs.Star = Tabs.Summon:CreateSubTab({ Name = "Star", Icon = "star" })

-- Progress: Training | Upgrades | Growth | Quests
Tabs.Training = Tabs.Progress:CreateSubTab({ Name = "Progression", Icon = "dumbbell" })
Tabs.Upgrades = Tabs.Progress:CreateSubTab({ Name = "Upgrades", Icon = "hammer" })
Tabs.Growth = Tabs.Progress:CreateSubTab({ Name = "Extra", Icon = "plus" })
Tabs.Quests = Tabs.Progress:CreateSubTab({ Name = "Quests", Icon = "scroll" })

--   CORE GAME HELPERS
-- ══════════════════════════════════════════

function aas_getHolePosition(hole)
    if hole.PrimaryPart then return hole.PrimaryPart.Position end
    if hole:IsA("BasePart") then return hole.Position end
    local part = hole:FindFirstChildWhichIsA("BasePart", true)
    return part and part.Position
end

function aas_teleportToMob(mob)
    local char = LocalPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    local mobRoot = mob:FindFirstChild("HumanoidRootPart") or mob:FindFirstChild("PrimaryPart") or mob:FindFirstChildOfClass("BasePart")
    if not mobRoot then return end
    hrp.CFrame = mobRoot.CFrame * CFrame.new(0, 0, 4)
    hrp.AssemblyLinearVelocity = Vector3.zero
end

function aas_waitForDead(mob, timeoutSecs)
    timeoutSecs = timeoutSecs or 30
    local deadline = tick() + timeoutSecs
    while tick() < deadline do
        if not mob or not mob.Parent then return true end
        if mob:GetAttribute("EnemyDead") == true then return true end
        task.wait(0.05)
    end
    return false
end

function aas_findMobsInFolder(enemiesFolder, selectedNames)
    if not enemiesFolder then return {} end
    local found = {}
    if selectedNames and #selectedNames > 0 then
        local nameSet = {}
        for _, n in ipairs(selectedNames) do nameSet[n] = true end
        for _, child in ipairs(enemiesFolder:GetChildren()) do
            if nameSet[child.Name] and child:GetAttribute("EnemyDead") ~= true then
                table.insert(found, child)
            end
        end
    else
        for _, child in ipairs(enemiesFolder:GetChildren()) do
            if child:GetAttribute("EnemyDead") ~= true then
                table.insert(found, child)
            end
        end
    end
    return found
end

function aas_teleportToWorld(worldIdx)
    pcall(function() aas_requestChangeWorldRemote:Fire(worldIdx) end)
    task.wait(2.5)
end

function aas_tryGetCurrentWorldId()
    local ok, data = pcall(function() return aas_getPlayerDataFunc:InvokeServer() end)
    if not ok or type(data) ~= "table" then return nil end
    return tonumber(data.ActiveWorld or data.CurrentWorld or data.WorldId or data.World or data.PlayerWorld)
end

function aas_changeWorldAndWait(worldId)
    pcall(function() aas_requestChangeWorldRemote:Fire(worldId) end)
    task.wait(AAS_WORLD_SWITCH_WAIT)
    local deadline = tick() + 2
    while tick() < deadline do
        local currentWorld = aas_tryGetCurrentWorldId()
        if currentWorld and currentWorld == tonumber(worldId) then task.wait(0.5) return true end
        task.wait(0.25)
    end
    return true
end

function aas_equipLoadout(stat)
    if not stat or stat == "" then return end
    pcall(function() aas_equipBestLoadoutRemote:Fire(stat) end)
    task.wait(0.5)
end

function aas_findArenaChild(arenaFolder, key)
    if not arenaFolder then return nil end
    for _, child in ipairs(arenaFolder:GetChildren()) do
        if child.Name == key or child.Name:sub(1, #key + 1) == key .. "_" then return child end
    end
    return nil
end

function aas_raidArenaExists(raidKey)
    local arenas = workspace:FindFirstChild("RaidArenas")
    if not arenas then return false end
    for _, child in ipairs(arenas:GetChildren()) do
        if child.Name == raidKey or child.Name:sub(1, #raidKey + 1) == raidKey .. "_" then return true end
    end
    return false
end

function aas_defenseArenaExists(defKey)
    local arenas = workspace:FindFirstChild("DefenseArenas")
    if not arenas then return false end
    for _, child in ipairs(arenas:GetChildren()) do
        if child.Name == defKey or child.Name:sub(1, #defKey + 1) == defKey .. "_" then return true end
    end
    return false
end

function aas_dungeonArenaExists(dungeonKey)
    local arenas = workspace:FindFirstChild("DungeonArenas")
    if not arenas then return false end
    if dungeonKey then
        for _, child in ipairs(arenas:GetChildren()) do
            if child.Name == dungeonKey or child.Name:sub(1, #dungeonKey + 1) == dungeonKey .. "_" then return true end
        end
        return false
    end
    return #arenas:GetChildren() > 0
end

function aas_trialArenaExists(trialKey)
    local arenas = workspace:FindFirstChild("TimeTrialArenas")
    if not arenas then return false end
    for _, child in ipairs(arenas:GetChildren()) do
        if child.Name == trialKey or child.Name:sub(1, #trialKey + 1) == trialKey .. "_" then return true end
    end
    return false
end

function aas_gateArenaExists()
    local arenas = workspace:FindFirstChild("RaidArenas")
    if not arenas then return false end
    for _, child in ipairs(arenas:GetChildren()) do
        if child.Name == "World5" or child.Name:sub(1, 7) == "World5_" then return true end
    end
    return false
end

function aas_rushArenaExists(rushKey)
    local arenas = workspace:FindFirstChild("BossRushArenas")
    if not arenas then return false, nil end
    for _, child in ipairs(arenas:GetChildren()) do
        if child.Name:sub(1, #rushKey) == rushKey then return true, child end
    end
    return false, nil
end

function aas_anyRaidActive()    return activeRaidKey ~= nil end
function aas_anyDefenseActive() return activeDefenseKey ~= nil end
function aas_anyDungeonActive() return activeDungeonKey ~= nil end
function aas_anyRushActive()    return activeRushKey ~= nil end

function aas_anySpawnBossActive()
    for _, bossId in ipairs(sortedSpawnBossKeys) do
        if spawnBossEnabled[bossId] then return true end
    end
    return false
end

function aas_findSpawnBossMob(bossId)
    local bossData = SpawnBossList[bossId]
    if not bossData then return nil end
    local worldFolder = workspace:FindFirstChild("Worlds")
    if not worldFolder then return nil end
    local wChild = worldFolder:FindFirstChild(tostring(bossData.WorldId))
    if not wChild then return nil end
    local enemies = wChild:FindFirstChild("Enemies")
    if not enemies then return nil end
    for _, child in ipairs(enemies:GetChildren()) do
        if child.Name == bossData.Name or child.Name == bossData.EnemyId then
            if child:GetAttribute("EnemyDead") ~= true then
                return child
            end
        end
    end
    return nil
end

function aas_waitForSpawnBossMob(bossId, timeoutSecs)
    timeoutSecs = timeoutSecs or 10
    local deadline = tick() + timeoutSecs
    while tick() < deadline do
        if not spawnBossEnabled[bossId] then return nil end
        local mob = aas_findSpawnBossMob(bossId)
        if mob and mob.Parent and mob:GetAttribute("EnemyDead") ~= true then
            return mob
        end
        task.wait(0.25)
    end
    return nil
end

function aas_getPriorityRank(activityType)
    for i, v in ipairs(priorityOrder) do if v == activityType then return i end end
    return 999
end

function aas_hasHigherPriority(activityA, activityB)
    return aas_getPriorityRank(activityA) < aas_getPriorityRank(activityB)
end

function aas_isHighPriorityActivityRunning()
    for _, tk in ipairs(sortedTrialKeys) do
        if trialEnabled[tk] and aas_trialArenaExists(tk) then return true, "Trial" end
    end
    if gateEnabled and aas_gateArenaExists() then return true, "Gate" end
    for _, dk in ipairs(sortedDungeonKeys) do
        if dungeonEnabled[dk] and aas_dungeonArenaExists(dk) then return true, "Dungeon" end
    end
    return false, nil
end

function aas_isHighPrioritySpawnOrRunPresent()
    for _, tk in ipairs(sortedTrialKeys) do
        if trialEnabled[tk] and aas_trialArenaExists(tk) then return true, "Trial" end
    end
    local gateSpawned = false
    pcall(function()
        gateSpawned = gateEnabled and workspace.Worlds["5"].Systems.RaidStation:FindFirstChild("ActiveGate") ~= nil
    end)
    if gateSpawned or (gateEnabled and aas_gateArenaExists()) then return true, "Gate" end
    for _, dk in ipairs(sortedDungeonKeys) do
        if dungeonEnabled[dk] and aas_dungeonArenaExists(dk) then return true, "Dungeon" end
    end
    return false, nil
end

function aas_monitorForConflicts(ownType, windowSecs)
    windowSecs = windowSecs or AAS_PRIORITY_WINDOW
    local deadline = tick() + windowSecs
    local highestConflict, highestRank = nil, aas_getPriorityRank(ownType)
    while tick() < deadline do
        if ownType ~= "Trial" then
            for _, tk in ipairs(sortedTrialKeys) do
                if trialEnabled[tk] and aas_trialArenaExists(tk) then
                    local rank = aas_getPriorityRank("Trial")
                    if rank < highestRank then highestRank = rank highestConflict = "Trial" end
                end
            end
        end
        if ownType ~= "Gate" and gateEnabled and aas_gateArenaExists() then
            local rank = aas_getPriorityRank("Gate")
            if rank < highestRank then highestRank = rank highestConflict = "Gate" end
        end
        if ownType ~= "Dungeon" then
            for _, dk in ipairs(sortedDungeonKeys) do
                if dungeonEnabled[dk] and aas_dungeonArenaExists(dk) then
                    local rank = aas_getPriorityRank("Dungeon")
                    if rank < highestRank then highestRank = rank highestConflict = "Dungeon" end
                end
            end
        end
        task.wait(0.5)
    end
    return highestConflict
end

-- ══════════════════════════════════════════
--   POTION SYSTEM
-- ══════════════════════════════════════════

function aas_getPotionContextSet(contextKey)
    local opt = Options["PotionCtx_" .. contextKey]
    if not opt then return {} end
    local result = {}
    for potionId, state in pairs(opt.Value or {}) do if state then result[potionId] = true end end
    return result
end

function aas_applyPotionContext(contextKey)
    if not potionContextEnabled then return end
    local wantedSet = aas_getPotionContextSet(contextKey)
    pcall(function()
        local data = aas_getPlayerDataFunc:InvokeServer()
        if data and type(data.ActivePotions) == "table" then activePotions = data.ActivePotions end
    end)
    for potionId, potionState in pairs(activePotions) do
        local shouldBeActive = wantedSet[potionId] == true
        local isCurrentlyPaused = potionState.Paused == true
        if shouldBeActive and isCurrentlyPaused then
            pcall(function() aas_potionPauseToggleRemote:Fire(potionId) end)
            task.wait(0.15)
        elseif not shouldBeActive and not isCurrentlyPaused then
            pcall(function() aas_potionPauseToggleRemote:Fire(potionId) end)
            task.wait(0.15)
        end
    end
    currentPotionContext = contextKey
    if potionStatusLabelRef then
        aas_setLabel(potionStatusLabelRef, "Context: " .. contextKey)
    end
end

function aas_pauseAllPotions()
    pcall(function()
        local data = aas_getPlayerDataFunc:InvokeServer()
        if data and type(data.ActivePotions) == "table" then activePotions = data.ActivePotions end
    end)
    for potionId, potionState in pairs(activePotions) do
        if not potionState.Paused then
            pcall(function() aas_potionPauseToggleRemote:Fire(potionId) end)
            task.wait(0.15)
        end
    end
end

function aas_enterPotionContext(contextKey)
    if not potionContextEnabled then return end
    if currentPotionContext == contextKey then return end
    aas_applyPotionContext(contextKey)
end

function aas_clearPotionContext()
    if not potionContextEnabled then return end
    currentPotionContext = nil
    if potionStatusLabelRef then aas_setLabel(potionStatusLabelRef, "Context: Idle") end
    aas_pauseAllPotions()
end

function aas_autoUsePotionLoop()
    while potionAutoUseEnabled do
        local opt = Options["PotionAutoUseSelect"]
        if opt then
            for potionId, state in pairs(opt.Value or {}) do
                if state then
                    pcall(function()
                        local args = { [1] = { [1] = { ["__BridgeTuplePayload__"] = true, ["Payload"] = { [1] = potionId, [2] = 1, ["n"] = 2 } }, [2] = "\5\1" } }
                        aas_bridgeDataRemote:FireServer(unpack(args))
                    end)
                    task.wait(0.5)
                end
            end
        end
        task.wait(30)
    end
end

-- ══════════════════════════════════════════
--   SNAPSHOT & RESUME
-- ══════════════════════════════════════════

function aas_snapshotAndPauseActivities()
    local snapshot = { farmWasActive=false, raidKey=nil, defenseKey=nil, dungeonKey=nil, rushKey=nil }

    if farmEnabled then
        snapshot.farmWasActive = true
        farmEnabled = false
        if farmThread then task.cancel(farmThread) farmThread = nil end
        currentWorldTracked = nil
    end

    if activeRaidKey then
        snapshot.raidKey = activeRaidKey
        local rk = activeRaidKey
        raidEnabled[rk] = false activeRaidKey = nil
        if raidThread then task.cancel(raidThread) raidThread = nil end
        if aas_raidArenaExists(rk) then pcall(function() aas_raidLeaveRemote:Fire() end) end
        task.wait(1)
    end

    if activeDefenseKey then
        snapshot.defenseKey = activeDefenseKey
        local dk = activeDefenseKey
        defenseEnabled[dk] = false activeDefenseKey = nil
        if defenseThread then task.cancel(defenseThread) defenseThread = nil end
        if aas_defenseArenaExists(dk) then pcall(function() aas_defenseLeaveRemote:Fire() end) end
        task.wait(1)
    end

    if activeDungeonKey then
        snapshot.dungeonKey = activeDungeonKey
        local dunk = activeDungeonKey
        dungeonEnabled[dunk] = false activeDungeonKey = nil
        if dungeonThreads[dunk] then task.cancel(dungeonThreads[dunk]) dungeonThreads[dunk] = nil end
        if aas_dungeonArenaExists(dunk) then pcall(function() aas_dungeonLeaveRemote:Fire() end) end
        task.wait(1)
    end

    if globalQuestEnabled then
        snapshot.globalQuestWasActive = true
        globalQuestEnabled = false
        if globalQuestThread then task.cancel(globalQuestThread) globalQuestThread = nil end
        globalQuestCurrentTarget = nil globalQuestCurrentAction = nil
    end

    if activeRushKey then
        snapshot.rushKey = activeRushKey
        local rk = activeRushKey
        rushEnabled[rk] = false activeRushKey = nil
        if rushThreads[rk] then task.cancel(rushThreads[rk]) rushThreads[rk] = nil end
        pcall(function() aas_bossRushLeaveRemote:Fire() end)
        task.wait(1)
    end

    snapshot.spawnBossKeys = {}
    for _, bossId in ipairs(sortedSpawnBossKeys) do
        if spawnBossEnabled[bossId] then
            table.insert(snapshot.spawnBossKeys, bossId)
            spawnBossEnabled[bossId] = false
            if spawnBossThreads[bossId] then
                task.cancel(spawnBossThreads[bossId])
                spawnBossThreads[bossId] = nil
            end
        end
    end

    return snapshot
end

function aas_resumeIndependentThreads(snapshot)
    if snapshot and snapshot.globalQuestWasActive then
        if Toggles["GQFarmerEnabled"] and Toggles["GQFarmerEnabled"].Value then
            globalQuestEnabled = true
            if globalQuestThread then task.cancel(globalQuestThread) end
            globalQuestThread = task.spawn(aas_globalQuestLoop)
        end
    end
end

function aas_resumeFromSnapshot(snapshot)
    if not snapshot then return end
    task.wait(1)

    for _, tk in ipairs(sortedTrialKeys) do
        if trialEnabled[tk] and aas_trialArenaExists(tk) then
            aas_resumeIndependentThreads(snapshot)
            return
        end
    end
    if gateEnabled and aas_gateArenaExists() then
        aas_resumeIndependentThreads(snapshot)
        return
    end
    for _, dk in ipairs(sortedDungeonKeys) do
        if dungeonEnabled[dk] and aas_dungeonArenaExists(dk) then
            aas_resumeIndependentThreads(snapshot)
            return
        end
    end

    task.wait(1)

    if snapshot.farmWasActive then
        local farmStat = LoadoutAssignments.Farm or "Power"
        aas_equipLoadout(farmStat)
        aas_enterPotionContext("Farm")
        farmEnabled = true
        if farmThread then task.cancel(farmThread) end
        farmThread = task.spawn(aas_farmLoop)
    end

    if snapshot.raidKey then
        local rk = snapshot.raidKey
        if Toggles["AutoRaid"] and Toggles["AutoRaid"].Value then
            aas_equipLoadout(RaidLoadouts[rk] or "Power")
            aas_enterPotionContext("Raid_"..rk)
            raidEnabled[rk] = true activeRaidKey = rk
            if raidThread then task.cancel(raidThread) end
            raidThread = task.spawn(function() aas_raidLoop(rk) end)
        end
    end

    if snapshot.defenseKey then
        local dk = snapshot.defenseKey
        if Toggles["AutoDefense"] and Toggles["AutoDefense"].Value then
            local defData = DefenseList[dk]
            if defData and defData.WorldId then pcall(function() aas_requestChangeWorldRemote:Fire(defData.WorldId) end) task.wait(3) end
            aas_equipLoadout(DefenseLoadouts[dk] or "Power")
            aas_enterPotionContext("Defense_"..dk)
            defenseEnabled[dk] = true activeDefenseKey = dk
            if defenseThread then task.cancel(defenseThread) end
            defenseThread = task.spawn(function() aas_defenseLoop(dk) end)
        end
    end

    if snapshot.dungeonKey then
        local dunk = snapshot.dungeonKey
        if Toggles["AutoDungeon_"..dunk] and Toggles["AutoDungeon_"..dunk].Value then
            aas_equipLoadout(DungeonLoadouts[dunk] or "Power")
            aas_enterPotionContext("Dungeon_"..dunk)
            dungeonEnabled[dunk] = true activeDungeonKey = dunk
            if dungeonThreads[dunk] then task.cancel(dungeonThreads[dunk]) end
            dungeonThreads[dunk] = task.spawn(function() aas_dungeonLoop(dunk) end)
        end
    end

    if snapshot.rushKey then
        local rk = snapshot.rushKey
        if Toggles["AutoRush"] and Toggles["AutoRush"].Value then
            aas_equipLoadout(RushLoadouts[rk] or "Power")
            aas_enterPotionContext("Rush_"..rk)
            rushEnabled[rk] = true activeRushKey = rk
            if rushThreads[rk] then task.cancel(rushThreads[rk]) end
            rushThreads[rk] = task.spawn(function() aas_rushLoop(rk) end)
        end
    end

    if snapshot.spawnBossKeys then
        for _, bossId in ipairs(snapshot.spawnBossKeys) do
            if Toggles["AutoSpawnBoss"] and Toggles["AutoSpawnBoss"].Value then
                spawnBossEnabled[bossId] = true
                if spawnBossThreads[bossId] then task.cancel(spawnBossThreads[bossId]) end
                spawnBossThreads[bossId] = task.spawn(function() aas_spawnBossLoop(bossId) end)
            end
        end
    end

    if snapshot.globalQuestWasActive then
        if Toggles["GQFarmerEnabled"] and Toggles["GQFarmerEnabled"].Value then
            globalQuestEnabled = true
            if globalQuestThread then task.cancel(globalQuestThread) end
            globalQuestThread = task.spawn(aas_globalQuestLoop)
        end
    end
end

-- ══════════════════════════════════════════
--   CLUSTER FARMING
-- ══════════════════════════════════════════

function aas_getClusterCenter(mobs, clusterRadius, minClusterSize)
    clusterRadius = clusterRadius or 40
    minClusterSize = minClusterSize or 1
    if #mobs == 0 then return nil, {} end
    local bestCenter, bestCluster, bestCount = nil, {}, 0
    for _, mobA in ipairs(mobs) do
        local posA = (mobA:FindFirstChild("HumanoidRootPart") and mobA.HumanoidRootPart.Position)
            or (mobA.PrimaryPart and mobA.PrimaryPart.Position) or nil
        if not posA then continue end
        local cluster, sumX, sumY, sumZ = {}, 0, 0, 0
        for _, mobB in ipairs(mobs) do
            if mobB:GetAttribute("EnemyDead") == true or not mobB.Parent then continue end
            local posB = (mobB:FindFirstChild("HumanoidRootPart") and mobB.HumanoidRootPart.Position)
                or (mobB.PrimaryPart and mobB.PrimaryPart.Position) or nil
            if not posB then continue end
            if (posA - posB).Magnitude <= clusterRadius then
                table.insert(cluster, mobB)
                sumX = sumX + posB.X sumY = sumY + posB.Y sumZ = sumZ + posB.Z
            end
        end
        if #cluster > bestCount then
            bestCount = #cluster bestCluster = cluster
            bestCenter = Vector3.new(sumX/#cluster, sumY/#cluster, sumZ/#cluster)
        end
    end
    if bestCount >= minClusterSize and bestCenter then return bestCenter, bestCluster end
    local fallbackPos = (mobs[1]:FindFirstChild("HumanoidRootPart") and mobs[1].HumanoidRootPart.Position)
        or (mobs[1].PrimaryPart and mobs[1].PrimaryPart.Position) or nil
    return fallbackPos, { mobs[1] }
end

function aas_teleportToClusterCenter(centerPos)
    if not centerPos then return end
    local char = LocalPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    hrp.CFrame = CFrame.new(centerPos)
    hrp.AssemblyLinearVelocity = Vector3.zero
end

function aas_waitForClusterDead(cluster, timeoutSecs)
    timeoutSecs = timeoutSecs or 30
    local deadline = tick() + timeoutSecs
    while tick() < deadline do
        local allDead = true
        for _, mob in ipairs(cluster) do
            if mob and mob.Parent and mob:GetAttribute("EnemyDead") ~= true then allDead = false break end
        end
        if allDead then return true end
        task.wait(0.05)
    end
    return false
end

-- ══════════════════════════════════════════
--   AUTO MOB FARM LOOP
-- ══════════════════════════════════════════

function aas_getSelectedForWorld(worldIdx)
    local key = worldDropdowns[worldIdx]
    if not key then return {} end
    local opt = Options[key]
    if not opt then return {} end
    local selected = {}
    for name, state in pairs(opt.Value or {}) do
        if state and name ~= "None" then table.insert(selected, name) end
    end
    return selected
end

function aas_getWorldsWithSelections()
    local worlds = {}
    for _, worldIdx in ipairs(sortedWorldIndices) do
        if #aas_getSelectedForWorld(worldIdx) > 0 then table.insert(worlds, worldIdx) end
    end
    return worlds
end

function aas_findMobsInWorld(worldIdx, selectedNames)
    local worldFolder = workspace:FindFirstChild("Worlds")
    if not worldFolder then return {} end
    local wChild = worldFolder:FindFirstChild(tostring(worldIdx))
    if not wChild then return {} end
    return aas_findMobsInFolder(wChild:FindFirstChild("Enemies"), selectedNames)
end

function aas_preloadWorld7Boss()
    local ok = pcall(function()
        local bossSpawn = workspace.Worlds["7"].Map["black clover boss"]
        if not bossSpawn then return end
        local char = LocalPlayer.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        local targetPos = nil
        if bossSpawn:IsA("BasePart") then targetPos = bossSpawn.Position
        elseif bossSpawn:IsA("Model") then
            if bossSpawn.PrimaryPart then targetPos = bossSpawn.PrimaryPart.Position
            else
                local firstPart = bossSpawn:FindFirstChildWhichIsA("BasePart", true)
                if firstPart then targetPos = firstPart.Position
                else local bbOk, cf = pcall(function() return bossSpawn:GetBoundingBox() end)
                    if bbOk and cf then targetPos = cf.Position end
                end
            end
        end
        if targetPos then
            hrp.CFrame = CFrame.new(targetPos + Vector3.new(0, 5, 0))
            hrp.AssemblyLinearVelocity = Vector3.zero
        end
    end)
    task.wait(3)
end

function aas_farmLoop()
    currentWorldTracked = nil
    while farmEnabled do
        local worlds = aas_getWorldsWithSelections()
        if #worlds == 0 then task.wait(0.5) continue end

        for _, worldIdx in ipairs(worlds) do
            if not farmEnabled then break end
            if currentWorldTracked ~= worldIdx then
                aas_teleportToWorld(worldIdx)
                currentWorldTracked = worldIdx
            end
            local selectedNames = aas_getSelectedForWorld(worldIdx)
            if #selectedNames == 0 then continue end

            if worldIdx == 7 then
                local needsLucies = false
                for _, name in ipairs(selectedNames) do if name == "Lucies" then needsLucies = true break end end
                if needsLucies then
                    local lf = workspace:FindFirstChild("Worlds")
                    lf = lf and lf:FindFirstChild("7") lf = lf and lf:FindFirstChild("Enemies")
                    if not (lf and lf:FindFirstChild("Lucies")) then aas_preloadWorld7Boss() end
                end
            end

            local mobs = aas_findMobsInWorld(worldIdx, selectedNames)
            if #mobs == 0 then task.wait(1) continue end

            local aliveMobs = {}
            for _, mob in ipairs(mobs) do
                if mob and mob.Parent and mob:GetAttribute("EnemyDead") ~= true then
                    local currentSelected = aas_getSelectedForWorld(worldIdx)
                    local stillWanted = false
                    for _, n in ipairs(currentSelected) do if n == mob.Name then stillWanted = true break end end
                    if stillWanted then table.insert(aliveMobs, mob) end
                end
            end
            if #aliveMobs == 0 then task.wait(0.5) continue end

            if clusterFarmEnabled then
                local centerPos, cluster = aas_getClusterCenter(aliveMobs, 40, 1)
                if centerPos then
                    aas_teleportToClusterCenter(centerPos)
                    aas_waitForClusterDead(cluster, 25)
                end
                task.wait(0.05)
            else
                for _, mob in ipairs(aliveMobs) do
                    if not farmEnabled then break end
                    if not mob.Parent or mob:GetAttribute("EnemyDead") == true then continue end
                    aas_teleportToMob(mob)
                    aas_waitForDead(mob, 25)
                    task.wait(0.05)
                end
            end
        end
        task.wait(0.05)
    end
    currentWorldTracked = nil
end

-- ══════════════════════════════════════════
--   GAMEMODE LOOPS
-- ══════════════════════════════════════════

-- RAID
function aas_getCurrentRaidWave()
    local ok, result = pcall(function() return LocalPlayer.PlayerGui.RaidGui.Main.Wave.Text end)
    if not ok or type(result) ~= "string" then return 0 end
    return tonumber(result:match("Wave%s+(%d+)/")) or 0
end

function aas_getRaidLeaveAtWave(raidKey)
    local opt = Options["RaidLeaveWave"]
    return (opt and tonumber(opt.Value)) or 0
end

function aas_getRaidEnemiesFolder(raidKey)
    local arenas = workspace:FindFirstChild("RaidArenas")
    if not arenas then return nil end
    local arena = aas_findArenaChild(arenas, raidKey)
    if not arena then return nil end
    return arena:FindFirstChild("Enemies")
end

function aas_joinOrCreateRaid(raidKey)
    if aas_raidArenaExists(raidKey) then pcall(function() aas_raidJoinRemote:Fire("Join", raidKey) end)
    else pcall(function() aas_raidJoinRemote:Fire("Create", raidKey) end) end
end

function aas_leaveRaid() pcall(function() aas_raidLeaveRemote:Fire() end) end

function aas_waitForRaidArena(raidKey, timeoutSecs)
    timeoutSecs = timeoutSecs or 10
    local deadline = tick() + timeoutSecs
    while tick() < deadline do if aas_raidArenaExists(raidKey) then return true end task.wait(0.5) end
    return false
end

function aas_disableOtherRaids(exceptKey)
    for _, rk in ipairs(sortedRaidKeys) do
        if rk ~= exceptKey and raidEnabled[rk] then
            raidEnabled[rk] = false
            local tk = "AutoRaid_"..rk
            if Toggles[tk] then Toggles[tk]:SetValue(false) end
        end
    end
end

function aas_disableAllDefenses()
    for _, dk in ipairs(sortedDefenseKeys) do
        if defenseEnabled[dk] then
            defenseEnabled[dk] = false
            local tk = "AutoDefense_"..dk
            if Toggles[tk] then Toggles[tk]:SetValue(false) end
        end
    end
    if defenseThread then task.cancel(defenseThread) defenseThread = nil end
    activeDefenseKey = nil
end

function aas_raidLoop(raidKey)
    local raidData = RaidList[raidKey]
    if not raidData then return end
    aas_equipLoadout(RaidLoadouts[raidKey] or "Power")
    aas_enterPotionContext("Raid_"..raidKey)
    aas_joinOrCreateRaid(raidKey) aas_waitForRaidArena(raidKey, 10) task.wait(5)
    while raidEnabled[raidKey] do
        local leaveAt = aas_getRaidLeaveAtWave(raidKey)
        if leaveAt > 0 then
            local cw = aas_getCurrentRaidWave()
            if cw > 0 and cw >= leaveAt then
                aas_leaveRaid() task.wait(6)
                if not raidEnabled[raidKey] then break end
                aas_joinOrCreateRaid(raidKey) aas_waitForRaidArena(raidKey, 10) task.wait(5) continue
            end
        end
        if not aas_raidArenaExists(raidKey) then
            task.wait(6)
            if not raidEnabled[raidKey] then break end
            aas_joinOrCreateRaid(raidKey) aas_waitForRaidArena(raidKey, 10) task.wait(5) continue
        end
        if raidOptimizedFarm then task.wait(0.5)
        else
            local mobs = aas_findMobsInFolder(aas_getRaidEnemiesFolder(raidKey), nil)
            if #mobs == 0 then task.wait(0.5) continue end
            for _, mob in ipairs(mobs) do
                if not raidEnabled[raidKey] then break end
                if not aas_raidArenaExists(raidKey) then break end
                if not mob.Parent or mob:GetAttribute("EnemyDead") == true then continue end
                aas_teleportToMob(mob) aas_waitForDead(mob, 15) task.wait(0.05)
            end
        end
        task.wait(0.05)
    end
    if aas_raidArenaExists(raidKey) then aas_leaveRaid() end
    activeRaidKey = nil
end

-- DEFENSE
function aas_getCurrentDefenseWave()
    local ok, result = pcall(function() return LocalPlayer.PlayerGui.DefenseGui.Main.Wave.Text end)
    if not ok or type(result) ~= "string" then return 0 end
    return tonumber(result:match("Wave%s+(%d+)/")) or 0
end

function aas_getDefenseLeaveAtWave(defKey)
    local opt = Options["DefLeaveWave"]
    return (opt and tonumber(opt.Value)) or 0
end

function aas_getDefenseEnemiesFolder(defKey)
    local arenas = workspace:FindFirstChild("DefenseArenas")
    if not arenas then return nil end
    local arena = aas_findArenaChild(arenas, defKey)
    if not arena then return nil end
    return arena:FindFirstChild("Enemies")
end

function aas_joinOrCreateDefense(defKey)
    if aas_defenseArenaExists(defKey) then pcall(function() aas_defenseJoinRemote:Fire("Join", defKey) end)
    else pcall(function() aas_defenseJoinRemote:Fire("Create", defKey) end) end
end

function aas_leaveDefense() pcall(function() aas_defenseLeaveRemote:Fire() end) end

function aas_waitForDefenseArena(defKey, timeoutSecs)
    timeoutSecs = timeoutSecs or 10
    local deadline = tick() + timeoutSecs
    while tick() < deadline do if aas_defenseArenaExists(defKey) then return true end task.wait(0.5) end
    return false
end

function aas_defenseLoop(defKey)
    local defData = DefenseList[defKey]
    if not defData then return end
    aas_equipLoadout(DefenseLoadouts[defKey] or "Power")
    aas_enterPotionContext("Defense_"..defKey)
    aas_joinOrCreateDefense(defKey) aas_waitForDefenseArena(defKey, 10) task.wait(5)
    while defenseEnabled[defKey] do
        local leaveAt = aas_getDefenseLeaveAtWave(defKey)
        if leaveAt > 0 then
            local cw = aas_getCurrentDefenseWave()
            if cw > 0 and cw >= leaveAt then
                aas_leaveDefense() task.wait(6)
                if not defenseEnabled[defKey] then break end
                aas_joinOrCreateDefense(defKey) aas_waitForDefenseArena(defKey, 10) task.wait(5) continue
            end
        end
        if not aas_defenseArenaExists(defKey) then
            task.wait(6)
            if not defenseEnabled[defKey] then break end
            aas_joinOrCreateDefense(defKey) aas_waitForDefenseArena(defKey, 10) task.wait(5) continue
        end
        local mobs = aas_findMobsInFolder(aas_getDefenseEnemiesFolder(defKey), nil)
        if #mobs == 0 then task.wait(0.5) continue end
        for _, mob in ipairs(mobs) do
            if not defenseEnabled[defKey] then break end
            if not aas_defenseArenaExists(defKey) then break end
            if not mob.Parent or mob:GetAttribute("EnemyDead") == true then continue end
            aas_teleportToMob(mob) aas_waitForDead(mob, 15) task.wait(0.05)
        end
        task.wait(0.05)
    end
    if aas_defenseArenaExists(defKey) then aas_leaveDefense() end
    activeDefenseKey = nil
end

-- DUNGEON
function aas_getCurrentDungeonRoom()
    local ok, result = pcall(function() return LocalPlayer.PlayerGui.DungeonGui.Main.Room.Text end)
    if not ok or type(result) ~= "string" then return 0 end
    return tonumber(result:match("Room%s+(%d+)")) or 0
end

function aas_getDungeonLeaveAtRoom(dungeonKey)
    local opt = Options["DungeonLeaveRoom_"..dungeonKey]
    if not opt then return 0 end
    local v = tostring(opt.Value or "")
    if v:match("Never") then return 0 end
    return tonumber(v:match("%d+")) or 0
end

function aas_getDungeonEnemiesFolder(dungeonKey)
    local arenas = workspace:FindFirstChild("DungeonArenas")
    if not arenas then return nil end
    local arena = aas_findArenaChild(arenas, dungeonKey)
    if not arena then return nil end
    return arena:FindFirstChild("Enemies") or arena:FindFirstChild("EnemySpawns") or arena
end

function aas_joinDungeon(dungeonKey) pcall(function() aas_dungeonJoinRemote:Fire("Join", dungeonKey) end) end
function aas_leaveDungeon() pcall(function() aas_dungeonLeaveRemote:Fire() end) end

function aas_waitForDungeonArena(dungeonKey, timeoutSecs)
    timeoutSecs = timeoutSecs or 15
    local deadline = tick() + timeoutSecs
    while tick() < deadline do if aas_dungeonArenaExists(dungeonKey) then return true end task.wait(0.5) end
    return false
end

function aas_dungeonLoop(dungeonKey)
    local dungeonData = DungeonList[dungeonKey]
    if not dungeonData then return end

    while dungeonEnabled[dungeonKey] do
        if dungeonSuppressedByPriority then
            local stillSuppressed = false
            if aas_hasHigherPriority("Trial", "Dungeon") then
                for _, tk in ipairs(sortedTrialKeys) do
                    if trialEnabled[tk] and aas_trialArenaExists(tk) then stillSuppressed = true break end
                end
            end
            if not stillSuppressed and aas_hasHigherPriority("Gate", "Dungeon") then
                if gateEnabled and aas_gateArenaExists() then stillSuppressed = true end
            end
            if stillSuppressed then task.wait(1) continue
            else dungeonSuppressedByPriority = false end
        end

        if not aas_dungeonArenaExists(dungeonKey) then task.wait(1) continue end

        local conflictActivity = aas_monitorForConflicts("Dungeon", AAS_PRIORITY_WINDOW)
        if conflictActivity then
            dungeonSuppressedByPriority = true
            Window:Notify({ Title = "Euclidean", Content = "Priority: " .. conflictActivity .. " - Dungeon suppressed.", Duration = 3, Type = "Info" })
            task.wait(1) continue
        end

        local sessionSnapshot = aas_snapshotAndPauseActivities()
        aas_equipLoadout(DungeonLoadouts[dungeonKey] or "Power")
        aas_enterPotionContext("Dungeon_"..dungeonKey)
        aas_joinDungeon(dungeonKey)

        local arenaLoaded = aas_waitForDungeonArena(dungeonKey, 15)
        if not arenaLoaded then
            Window:Notify({ Title = "Euclidean", Content = dungeonData.Name .. " - Arena did not load. Skipping.", Duration = 3, Type = "Info" })
            aas_resumeFromSnapshot(sessionSnapshot) task.wait(3) continue
        end

        task.wait(3) activeDungeonKey = dungeonKey
        local sessionActive, needsLeave = true, false

        while dungeonEnabled[dungeonKey] and sessionActive do
            if not aas_dungeonArenaExists(dungeonKey) then sessionActive = false needsLeave = false break end
            local leaveAt = aas_getDungeonLeaveAtRoom(dungeonKey)
            if leaveAt > 0 then
                local cr = aas_getCurrentDungeonRoom()
                if cr > 0 and cr >= leaveAt then needsLeave = true sessionActive = false break end
            end
            local mobs = aas_findMobsInFolder(aas_getDungeonEnemiesFolder(dungeonKey), nil)
            if #mobs == 0 then task.wait(0.2) continue end
            for _, mob in ipairs(mobs) do
                if not dungeonEnabled[dungeonKey] then sessionActive = false break end
                if not aas_dungeonArenaExists(dungeonKey) then sessionActive = false break end
                if not mob.Parent or mob:GetAttribute("EnemyDead") == true then continue end
                aas_teleportToMob(mob) aas_waitForDead(mob, 15) task.wait(0.05)
            end
            task.wait(0.05)
        end

        if needsLeave and aas_dungeonArenaExists(dungeonKey) then aas_leaveDungeon() task.wait(5) end
        activeDungeonKey = nil
        dungeonSuppressedByPriority = false trialSuppressedByPriority = false gateSuppressedByPriority = false
        task.wait(0.5) aas_resumeFromSnapshot(sessionSnapshot) task.wait(3)
    end
    activeDungeonKey = nil dungeonSuppressedByPriority = false
end

-- BOSS RUSH
function aas_getCurrentRushWave()
    local ok, result = pcall(function() return LocalPlayer.PlayerGui.BossRushGui.Main.Wave.Text end)
    if not ok or type(result) ~= "string" then return 0 end
    return tonumber(result:match("%d+")) or 0
end

function aas_joinOrCreateRush(rushKey, modeId)
    local exists, _ = aas_rushArenaExists(rushKey)
    if exists then pcall(function() aas_bossRushJoinRemote:Fire("Join", rushKey, modeId, "") end)
    else pcall(function() aas_bossRushJoinRemote:Fire("Create", rushKey, modeId, true) end) end
end

function aas_leaveRush() pcall(function() aas_bossRushLeaveRemote:Fire() end) end

function aas_collectFingers(arena)
    if not arena then return false end
    local finger = arena:FindFirstChild("SukunaFinger")
    if not finger then return false end
    local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return false end
    local target = nil
    if finger:IsA("BasePart") then target = finger
    elseif finger:IsA("Model") then target = finger.PrimaryPart or finger:FindFirstChildWhichIsA("BasePart", true)
    end
    if not target then for _, d in ipairs(finger:GetDescendants()) do if d:IsA("BasePart") then target = d break end end end
    if not target then return false end
    task.wait(0.5)
    if not finger or not finger.Parent then return false end
    hrp.CFrame = target.CFrame * CFrame.new(0, 3, 0) hrp.AssemblyLinearVelocity = Vector3.zero task.wait(0.25)
    local prompt = finger:FindFirstChild("FingerPrompt", true)
    if not (prompt and prompt:IsA("ProximityPrompt") and prompt.Enabled) then return false end
    pcall(function() fireproximityprompt(prompt, 3) end)
    local deadline = tick() + 1.25
    while tick() < deadline do
        if not finger or not finger.Parent then task.wait(0.15) return true end
        task.wait(0.05)
    end
    return false
end

function aas_rushLoop(rushKey)
    local rushData = RushList[rushKey]
    if not rushData then return end
    local modeOpt = Options["RushMode"]
    local modeId = modeOpt and modeOpt.Value or "V1"
    aas_equipLoadout(RushLoadouts[rushKey] or "Power")
    aas_enterPotionContext("Rush_"..rushKey)
    aas_joinOrCreateRush(rushKey, modeId) task.wait(5)

    while rushEnabled[rushKey] do
        local exists, arena = aas_rushArenaExists(rushKey)
        if not exists then
            task.wait(6)
            if not rushEnabled[rushKey] then break end
            modeId = Options["RushMode"] and Options["RushMode"].Value or "V1"
            aas_joinOrCreateRush(rushKey, modeId) task.wait(5) continue
        end

        local leaveOpt = Options["RushLeaveWave"]
        local leaveAt = tonumber(leaveOpt and leaveOpt.Value) or 0
        if leaveAt > 0 then
            local cw = aas_getCurrentRushWave()
            if cw > 0 and cw >= leaveAt then aas_leaveRush() task.wait(6) continue end
        end

        if aas_collectFingers(arena) then continue end
        if not rushEnabled[rushKey] then break end

        local enemiesFolder = arena:FindFirstChild("Enemies")
        local mobs = aas_findMobsInFolder(enemiesFolder, nil)
        if #mobs == 0 then task.wait(0.5) continue end

        for _, mob in ipairs(mobs) do
            if not rushEnabled[rushKey] then break end
            if not aas_rushArenaExists(rushKey) then break end
            local waveNow = aas_getCurrentRushWave()
            if leaveAt > 0 and waveNow > 0 and waveNow >= leaveAt then break end
            if aas_collectFingers(arena) then break end
            if not mob.Parent or mob:GetAttribute("EnemyDead") == true then continue end
            aas_teleportToMob(mob) aas_waitForDead(mob, 15) task.wait(0.05)
        end
        task.wait(0.05)
    end
    if aas_rushArenaExists(rushKey) then aas_leaveRush() end
    activeRushKey = nil
end

-- SPAWN BOSS
function aas_spawnBossLoop(bossId)
    local bossData = SpawnBossList[bossId]
    if not bossData then return end

    while spawnBossEnabled[bossId] do
        local highPrio, highType = aas_isHighPrioritySpawnOrRunPresent()
        if highPrio then
            task.wait(1)
            continue
        end

        local currentWorld = aas_tryGetCurrentWorldId()
        if currentWorld ~= bossData.WorldId then
            aas_changeWorldAndWait(bossData.WorldId)
            task.wait(1)
        end

        local existingMob = aas_findSpawnBossMob(bossId)

        if not existingMob then
            pcall(function() aas_spawnBossRequestRemote:Fire(bossId) end)
            task.wait(2)

            existingMob = aas_waitForSpawnBossMob(bossId, 10)

            if not existingMob then
                task.wait(3)
                continue
            end
        end

        aas_teleportToMob(existingMob)

        local died = aas_waitForDead(existingMob, 120)

        if died then
            task.wait(0.5)
            pcall(function() aas_spawnBossRequestRemote:Fire(bossId) end)
            task.wait(2)
        else
            task.wait(1)
        end
    end
end

-- TIME TRIAL
function aas_getCurrentTrialRoom()
    local ok, result = pcall(function() return LocalPlayer.PlayerGui.TrialGui.Main.Room.Text end)
    if not ok or type(result) ~= "string" then return 0 end
    return tonumber(result:match("Room%s+(%d+)/")) or 0
end

function aas_getTrialLeaveAtRoom(trialKey)
    local opt = Options["TrialLeaveRoom_"..trialKey]
    if not opt then return 0 end
    local v = tostring(opt.Value or "")
    if v == "0 (Never Leave)" then return 0 end
    return tonumber(v:match("^(%d+)")) or 0
end

function aas_getTrialEnemiesFolder(trialKey)
    local arenas = workspace:FindFirstChild("TimeTrialArenas")
    if not arenas then return nil end
    local arena = aas_findArenaChild(arenas, trialKey)
    if not arena then return nil end
    return arena:FindFirstChild("Enemies")
end

function aas_joinTrial(trialKey) pcall(function() aas_trialJoinRemote:Fire("Join", trialKey) end) end
function aas_leaveTrial() pcall(function() aas_trialLeaveRemote:Fire() end) end

function aas_trialLoop(trialKey)
    local trialData = TrialList[trialKey]
    if not trialData then return end

    while trialEnabled[trialKey] do
        if trialSuppressedByPriority then
            local stillSuppressed = false
            if aas_hasHigherPriority("Gate", "Trial") and gateEnabled and aas_gateArenaExists() then stillSuppressed = true end
            if not stillSuppressed and aas_hasHigherPriority("Dungeon", "Trial") then
                for _, dk in ipairs(sortedDungeonKeys) do
                    if dungeonEnabled[dk] and aas_dungeonArenaExists(dk) then stillSuppressed = true break end
                end
            end
            if stillSuppressed then task.wait(1) continue
            else trialSuppressedByPriority = false end
        end

        if not aas_trialArenaExists(trialKey) then task.wait(1) continue end

        local conflictActivity = aas_monitorForConflicts("Trial", AAS_PRIORITY_WINDOW)
        if conflictActivity then
            trialSuppressedByPriority = true
            Window:Notify({ Title = "Euclidean", Content = "Priority: " .. conflictActivity .. " - Trial suppressed.", Duration = 3, Type = "Info" })
            task.wait(0.05) continue
        end

        local sessionSnapshot = aas_snapshotAndPauseActivities()
        aas_equipLoadout(TrialLoadouts[trialKey] or "Power")
        aas_enterPotionContext("Trial_"..trialKey)
        aas_joinTrial(trialKey) task.wait(5)

        local sessionActive, needsLeave = true, false

        while trialEnabled[trialKey] and sessionActive do
            if not aas_trialArenaExists(trialKey) then sessionActive = false needsLeave = false break end
            local leaveAt = aas_getTrialLeaveAtRoom(trialKey)
            if leaveAt > 0 then
                local cr = aas_getCurrentTrialRoom()
                if cr > 0 and cr >= leaveAt then needsLeave = true sessionActive = false break end
            end
            local mobs = aas_findMobsInFolder(aas_getTrialEnemiesFolder(trialKey), nil)
            if #mobs == 0 then task.wait(0.1) continue end
            for _, mob in ipairs(mobs) do
                if not trialEnabled[trialKey] then sessionActive = false break end
                if not aas_trialArenaExists(trialKey) then sessionActive = false break end
                if not mob.Parent or mob:GetAttribute("EnemyDead") == true then continue end
                aas_teleportToMob(mob) aas_waitForDead(mob, 15) task.wait(0.05)
            end
            task.wait(0.05)
        end

        if needsLeave and aas_trialArenaExists(trialKey) then aas_leaveTrial() task.wait(5) end
        trialSuppressedByPriority = false gateSuppressedByPriority = false dungeonSuppressedByPriority = false
        task.wait(0.5) aas_resumeFromSnapshot(sessionSnapshot) task.wait(1)
    end
    trialSuppressedByPriority = false
end

-- GATE
function aas_isWorld5SystemsLoaded()
    local ok, result = pcall(function() return workspace.Worlds["5"].Systems ~= nil and #workspace.Worlds["5"].Systems:GetChildren() > 0 end)
    return ok and result
end

function aas_getActiveGateRank()
    local ok2, rankText = pcall(function() return workspace.Worlds["5"].Systems.RaidStation.Gui.Main.Rank.Text end)
    if not ok2 or type(rankText) ~= "string" then return nil end
    return rankText:match("GATE RANK:%s*(%S+)")
end

function aas_getGateLeaveAtWave(rank)
    local opt = Options["GateLeaveWave_"..rank]
    if not opt then return 0 end
    local v = tostring(opt.Value or "")
    if v:match("Never") then return 0 end
    return tonumber(v:match("%d+")) or 0
end

function aas_isGateRankWanted(rank)
    local opt = Options["GateRankSelect"]
    if not opt then return false end
    for r, state in pairs(opt.Value or {}) do if state and r == rank then return true end end
    return false
end

function aas_getGateEnemiesFolder()
    local arenas = workspace:FindFirstChild("RaidArenas")
    if not arenas then return nil end
    local arena = aas_findArenaChild(arenas, "World5")
    if not arena then return nil end
    return arena:FindFirstChild("Enemies")
end

function aas_isActiveGatePresent()
    local ok, result = pcall(function() return workspace.Worlds["5"].Systems.RaidStation:FindFirstChild("ActiveGate") ~= nil end)
    return ok and result
end

function aas_enterGatePortal()
    local char = LocalPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    local portalPart = nil
    pcall(function()
        local station = workspace.Worlds["5"].Systems.RaidStation
        local tryNames = { "Portal", "PortalPart", "Gate", "GatePart", "Trigger", "TouchPart", "Enter" }
        for _, n in ipairs(tryNames) do
            local p = station:FindFirstChild(n, true)
            if p and p:IsA("BasePart") then portalPart = p break end
        end
        if not portalPart then
            for _, desc in ipairs(station:GetDescendants()) do
                if desc:IsA("BasePart") and desc.Name ~= "Hitbox" then portalPart = desc break end
            end
        end
    end)
    if portalPart then
        local portalPos = portalPart.Position
        local dirToPortal = Vector3.new((portalPos - hrp.Position).X, 0, (portalPos - hrp.Position).Z).Unit
        hrp.CFrame = CFrame.new(portalPos - dirToPortal * 4 + Vector3.new(0, 3, 0), portalPos)
        hrp.AssemblyLinearVelocity = Vector3.zero task.wait(0.3)
        for i = 1, 5 do hrp.CFrame = hrp.CFrame + dirToPortal * 1.2 hrp.AssemblyLinearVelocity = Vector3.zero task.wait(0.1) end
    else
        local ok, raidStation = pcall(function() return workspace.Worlds["5"].Systems.RaidStation end)
        if ok and raidStation then
            local stationPos = raidStation.CFrame.Position
            local forward = raidStation.CFrame.LookVector
            hrp.CFrame = CFrame.new(stationPos - forward * 4 + Vector3.new(0, 3, 0), stationPos)
            hrp.AssemblyLinearVelocity = Vector3.zero task.wait(0.3)
            for i = 1, 5 do hrp.CFrame = hrp.CFrame + forward * 1.2 hrp.AssemblyLinearVelocity = Vector3.zero task.wait(0.1) end
        end
    end
end

function aas_teleportToBaruke1()
    local char = LocalPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    local baruke = nil
    pcall(function()
        local arenas = workspace:FindFirstChild("RaidArenas")
        if not arenas then return end
        local arena = aas_findArenaChild(arenas, "World5")
        if not arena then return end
        local spawns = arena:FindFirstChild("EnemySpawns")
        if spawns then baruke = spawns:FindFirstChild("Baruke_1") end
    end)
    if baruke then
        local pos = baruke:IsA("BasePart") and baruke.Position
            or (baruke:IsA("Model") and (baruke.PrimaryPart or baruke:FindFirstChildOfClass("BasePart")) and (baruke.PrimaryPart or baruke:FindFirstChildOfClass("BasePart")).Position)
        if pos then hrp.CFrame = CFrame.new(pos + Vector3.new(0, 3, 0)) hrp.AssemblyLinearVelocity = Vector3.zero end
    end
end

function aas_gateLoop()
    while gateEnabled do
        if gateCooldown then task.wait(1) continue end
        if not aas_isWorld5SystemsLoaded() then task.wait(1) continue end

        if gateSuppressedByPriority then
            local stillSuppressed = false
            if aas_hasHigherPriority("Trial", "Gate") then
                for _, tk in ipairs(sortedTrialKeys) do
                    if trialEnabled[tk] and aas_trialArenaExists(tk) then stillSuppressed = true break end
                end
            end
            if not stillSuppressed and aas_hasHigherPriority("Dungeon", "Gate") then
                for _, dk in ipairs(sortedDungeonKeys) do
                    if dungeonEnabled[dk] and aas_dungeonArenaExists(dk) then stillSuppressed = true break end
                end
            end
            if stillSuppressed then task.wait(1) continue else gateSuppressedByPriority = false end
        end

        if not aas_isActiveGatePresent() then task.wait(0.5) continue end
        local rank = aas_getActiveGateRank()
        if not rank or not aas_isGateRankWanted(rank) then task.wait(1) continue end

        local conflictActivity = aas_monitorForConflicts("Gate", AAS_PRIORITY_WINDOW)
        if conflictActivity then
            gateSuppressedByPriority = true
            Window:Notify({ Title = "Euclidean", Content = "Priority: " .. conflictActivity .. " - Gate suppressed.", Duration = 3, Type = "Info" })
            task.wait(1) continue
        end

        local snapshot = aas_snapshotAndPauseActivities()
        local gateLoadout = Options["LoadoutGateRank_"..rank] and Options["LoadoutGateRank_"..rank].Value or "Power"
        aas_equipLoadout(gateLoadout)
        aas_enterPotionContext("Gate_"..rank)
        pcall(function() aas_requestChangeWorldRemote:Fire(5) end) task.wait(3)

        local arenaDeadline = tick() + 20
        while tick() < arenaDeadline do
            if aas_gateArenaExists() then break end
            aas_enterGatePortal() task.wait(1)
        end

        if not aas_gateArenaExists() then
            Window:Notify({ Title = "Euclidean", Content = "Auto Gate - Arena did not load. Skipping.", Duration = 3, Type = "Info" })
            aas_resumeFromSnapshot(snapshot) task.wait(2) continue
        end

        local sessionActive = true
        while gateEnabled and sessionActive do
            if not aas_gateArenaExists() then sessionActive = false break end
            local leaveAt = aas_getGateLeaveAtWave(rank)
            if leaveAt > 0 then
                local cw = aas_getCurrentRaidWave()
                if cw > 0 and cw >= leaveAt then aas_leaveRaid() task.wait(5) sessionActive = false break end
            end

            if gateOptimizedFarm then aas_teleportToBaruke1() task.wait(0.5)
            else
                local mobs = aas_findMobsInFolder(aas_getGateEnemiesFolder(), nil)
                if #mobs == 0 then task.wait(0.5) continue end
                for _, mob in ipairs(mobs) do
                    if not gateEnabled then sessionActive = false break end
                    if not aas_gateArenaExists() then sessionActive = false break end
                    if not mob.Parent or mob:GetAttribute("EnemyDead") == true then continue end
                    aas_teleportToMob(mob) aas_waitForDead(mob, 15) task.wait(0.05)
                end
            end
            task.wait(0.05)
        end

        gateCooldown = true
        task.spawn(function() task.wait(60) gateCooldown = false end)
        gateSuppressedByPriority = false trialSuppressedByPriority = false dungeonSuppressedByPriority = false
        task.wait(0.5) aas_resumeFromSnapshot(snapshot) task.wait(3)
    end
    gateCooldown = false
end

-- ══════════════════════════════════════════
--   SYNC & DATA MANAGERS
-- ══════════════════════════════════════════

function aas_getRarityIndex(rarityOrder, rarity)
    for i, r in ipairs(rarityOrder) do if r == rarity then return i end end
    return 0
end

function aas_updateSword1Labels()
    if sword1InfoLabelRef then
        if sword1Data then
            local stars = string.rep("⭐", sword1Data.Level or 0)
            if stars == "" then stars = "0" end
            aas_setLabel(sword1InfoLabelRef, "Sword 1: "..tostring(sword1Data.Rarity).." | Stars: "..stars)
        else aas_setLabel(sword1InfoLabelRef, "Sword 1: Not Found") end
    end
    if sword1BreathingLabelRef then
        local breathingText = sword1CurrentBreathing
            and ("Breathing: "..tostring(sword1CurrentBreathing.Name or "Unknown").." ("..tostring(sword1CurrentBreathing.Rarity or "?")..")")
            or "Breathing: None"
        aas_setLabel(sword1BreathingLabelRef, breathingText)
    end
end

function aas_updateSword2Labels()
    if sword2InfoLabelRef then
        if sword2Data then
            local stars = string.rep("⭐", sword2Data.Level or 0)
            if stars == "" then stars = "0" end
            aas_setLabel(sword2InfoLabelRef, "Sword 2: "..tostring(sword2Data.Rarity).." | Stars: "..stars)
        else aas_setLabel(sword2InfoLabelRef, "Sword 2: Not Found") end
    end
    if sword2BreathingLabelRef then
        local breathingText = sword2CurrentBreathing
            and ("Breathing: "..tostring(sword2CurrentBreathing.Name or "Unknown").." ("..tostring(sword2CurrentBreathing.Rarity or "?")..")")
            or "Breathing: None"
        aas_setLabel(sword2BreathingLabelRef, breathingText)
    end
end

function aas_updateGrimoireLabels()
    if grimoire1LabelRef then aas_setLabel(grimoire1LabelRef, "Slot 1: "..(activeGrimoireSlot1 or "None")) end
    if grimoire2LabelRef then aas_setLabel(grimoire2LabelRef, "Slot 2: "..(activeGrimoireSlot2 or "None")) end
end

function aas_updateProgressionLabels()
    for _, progKey in ipairs(sortedProgressionKeys) do
        local labelRef = progressionLevelLabelRefs[progKey]
        if labelRef then
            local level = progressionLevels[progKey] or 0
            local maxLevel = ProgressionList[progKey] and ProgressionList[progKey].MaxLevel or "?"
            aas_setLabel(labelRef, "Level: "..tostring(level).." / "..tostring(maxLevel))
        end
    end
end

function aas_applyUpgrades2Payload(sysKey, payload)
    if type(payload) ~= "table" then return end
    if not upgrades2LiveData[sysKey] then upgrades2LiveData[sysKey] = {} end
    local upgradesList = payload.Upgrades
    if type(upgradesList) == "table" then
        for _, upg in ipairs(upgradesList) do
            if type(upg) == "table" and type(upg.Multiplier) == "string" then
                local key = upg.Multiplier
                if not upgrades2LiveData[sysKey][key] then upgrades2LiveData[sysKey][key] = {} end
                for k, v in pairs(upg) do upgrades2LiveData[sysKey][key][k] = v end
            end
        end
    end
end

task.spawn(function()
    pcall(function()
        aas_upgrades2DataRemote:Connect(function(payload)
            if type(payload) ~= "table" then return end
            local systems = payload.Systems
            if type(systems) == "table" then
                for sysKey, sysPayload in pairs(systems) do aas_applyUpgrades2Payload(sysKey, sysPayload) end
            end
        end)
    end)
    pcall(function()
        aas_upgrades2UpdatedRemote:Connect(function(payload)
            if type(payload) ~= "table" then return end
            local sysKey = payload.SystemKey
            if type(sysKey) == "string" then aas_applyUpgrades2Payload(sysKey, payload) end
        end)
    end)
    pcall(function()
        aas_upgrades2ResultRemote:Connect(function(success, errCode, payload)
            if type(payload) ~= "table" then return end
            local sysKey = payload.SystemKey
            if type(sysKey) == "string" then aas_applyUpgrades2Payload(sysKey, payload) end
        end)
    end)
end)

local aas_lastFullSync = 0
function aas_syncAllPlayerData()
    -- Central throttle: 24 call sites share one fetch; never refetch within 1.5s.
    -- Loops already tolerate stale reads; this kills InvokeServer storms when
    -- many features run at once.
    if tick() - aas_lastFullSync < 1.5 then return end
    aas_lastFullSync = tick()
    if not aas_getPlayerDataFunc then return end
    local ok, data = pcall(function() return aas_getPlayerDataFunc:InvokeServer() end)
    if not ok or type(data) ~= "table" then return end
    cachedPlayerData = data

    if type(data.ActivePotions) == "table" then activePotions = data.ActivePotions end

    local activeGachas = data.ActiveGachas
    if type(activeGachas) == "table" then
        for gachaKey, rarity in pairs(activeGachas) do
            activeGachaRarities[gachaKey] = tostring(rarity)
            local labelRef = gachaLabelRefs[gachaKey]
            if labelRef then aas_setLabel(labelRef, "Current: "..tostring(rarity)) end
        end
    end

    local activePassive = data.ActivePassive
    if type(activePassive) == "table" and activePassive.Name and activePassive.Rarity then
        activePassiveData = activePassive
        if passiveLabelRef then aas_setLabel(passiveLabelRef, "Active: "..tostring(activePassive.Name).." | "..tostring(activePassive.Rarity)) end
    else
        activePassiveData = nil
        if passiveLabelRef then aas_setLabel(passiveLabelRef, "Active: None") end
    end

    local activeTitans = data.ActiveTitans
    if type(activeTitans) == "table" then
        local bestRarity, bestIdx = nil, 0
        for _, titanData in pairs(activeTitans) do
            if type(titanData) == "table" and titanData.Rarity then
                local idx = aas_getRarityIndex(TitanRarityOrder, titanData.Rarity)
                if idx > bestIdx then bestIdx = idx bestRarity = titanData.Rarity end
            end
        end
        activeTitanData = bestRarity and { rarity=bestRarity } or nil
        if titanLabelRef then
            aas_setLabel(titanLabelRef, activeTitanData and ("Active Titan: "..activeTitanData.rarity) or "Active Titan: None")
        end
    end

    local sword1Raw = data.EquippedSword
    sword1Data = type(sword1Raw) == "table" and { SwordKey=sword1Raw.SwordKey or "World0", Rarity=sword1Raw.Rarity or "Common", Level=sword1Raw.Level or 0, Index=sword1Raw.Index or 1 } or nil

    local sword2Raw = data.EquippedSword2
    sword2Data = type(sword2Raw) == "table" and { SwordKey=sword2Raw.SwordKey or "World0", Rarity=sword2Raw.Rarity or "Common", Level=sword2Raw.Level or 0, Index=sword2Raw.Index or 1 } or nil

    local swordPassives = data.SwordPassives
    if type(swordPassives) == "table" then
        if sword1Data then
            local key1 = string.format("World0_%s_%d_%d", sword1Data.Rarity, sword1Data.Level, sword1Data.Index)
            sword1CurrentBreathing = type(swordPassives[key1]) == "table" and swordPassives[key1] or nil
        end
        if sword2Data then
            local key2 = string.format("World0_%s_%d_%d", sword2Data.Rarity, sword2Data.Level, sword2Data.Index)
            sword2CurrentBreathing = type(swordPassives[key2]) == "table" and swordPassives[key2] or nil
        end
    end

    local activeGrimoires = data.ActiveGrimoires
    if type(activeGrimoires) == "table" then
        local world7 = activeGrimoires["World7"]
        if type(world7) == "table" then
            activeGrimoireSlot1 = type(world7.Slot1) == "string" and world7.Slot1 or nil
            activeGrimoireSlot2 = type(world7.Slot2) == "string" and world7.Slot2 or nil
        else activeGrimoireSlot1 = nil activeGrimoireSlot2 = nil end
    end

    local activeProgressions = data.ActiveProgressions
    if type(activeProgressions) == "table" then
        for progKey, level in pairs(activeProgressions) do progressionLevels[progKey] = tonumber(level) or 0 end
    end

    aas_updateSword1Labels() aas_updateSword2Labels() aas_updateGrimoireLabels() aas_updateProgressionLabels()
end

task.spawn(function()
    while true do task.wait(30) pcall(aas_syncAllPlayerData) end
end)

-- ══════════════════════════════════════════
--   GACHA & ROLLING SYSTEMS
-- ══════════════════════════════════════════

function aas_gachaLoop(gachaKey)
    local lastSync = 0
    while gachaEnabled[gachaKey] do
        if activeGachaRarities[gachaKey] == AAS_ASTRAL then
            gachaEnabled[gachaKey] = false
            if Toggles["AutoGacha_"..gachaKey] then Toggles["AutoGacha_"..gachaKey]:SetValue(false) end
            Window:Notify({ Title = "Euclidean", Content = (GachaList[gachaKey] and GachaList[gachaKey].Name or gachaKey) .. " - Reached Astral!", Duration = 3, Type = "Info" })
            break
        end
        pcall(function() aas_gachaRollRemote:Fire(gachaKey) end) task.wait(0.1)
        if tick() - lastSync >= 5 then
            lastSync = tick() pcall(aas_syncAllPlayerData)
            if activeGachaRarities[gachaKey] == AAS_ASTRAL then
                gachaEnabled[gachaKey] = false
                if Toggles["AutoGacha_"..gachaKey] then Toggles["AutoGacha_"..gachaKey]:SetValue(false) end
                Window:Notify({ Title = "Euclidean", Content = (GachaList[gachaKey] and GachaList[gachaKey].Name or gachaKey) .. " - Reached Astral!", Duration = 3, Type = "Info" })
                break
            end
        end
    end
end

function aas_swordWorld0Loop() while SwordWorld0Enabled do pcall(function() aas_swordRollRemote:Fire("World0") end) task.wait(0.1) end end
function aas_swordWorld8Loop() while SwordWorld8Enabled do pcall(function() aas_swordRollRemote:Fire("World8") end) task.wait(0.1) end end
function aas_fuseAllLoop() while autoFuseAllEnabled do if aas_bridgeDataRemote then pcall(function() aas_bridgeDataRemote:FireServer({ [2] = "Q" }) end) end task.wait(5) end end
function aas_passiveLoop() while passiveAutoEnabled do pcall(function() aas_passiveRollRemote:Fire() end) task.wait(0.1) end end
function aas_titanLoop() while titanAutoEnabled do pcall(function() aas_titanRollRemote:Fire("World4") end) task.wait(0.1) end end

-- SWORD PASSIVES
function aas_getSword1StopRarities()
    local opt = Options["SwordPassive1StopRarities"]
    if not opt then return {} end
    local selected = {}
    for rarity, state in pairs(opt.Value or {}) do if state then table.insert(selected, rarity) end end
    return selected
end

function aas_getSword2StopRarities()
    local opt = Options["SwordPassive2StopRarities"]
    if not opt then return {} end
    local selected = {}
    for rarity, state in pairs(opt.Value or {}) do if state then table.insert(selected, rarity) end end
    return selected
end

function aas_swordPassiveRarityReached(currentPassive, stopRarities)
    if not currentPassive or #stopRarities == 0 then return false end
    local currentRarity = currentPassive.Rarity or ""
    for _, r in ipairs(stopRarities) do if r == currentRarity then return true end end
    return false
end

function aas_swordPassive1Loop()
    while swordPassive1Enabled do
        local stopRarities = aas_getSword1StopRarities()
        if aas_swordPassiveRarityReached(sword1CurrentBreathing, stopRarities) then
            swordPassive1Enabled = false
            if Toggles["AutoSwordPassive1Enabled"] then Toggles["AutoSwordPassive1Enabled"]:SetValue(false) end
            Window:Notify({ Title = "Euclidean", Content = "Sword Passive 1 Stopped - Reached: "..(sword1CurrentBreathing and sword1CurrentBreathing.Name or "Unknown"), Duration = 3, Type = "Info" })
            break
        end
        if not sword1Data then task.wait(1) continue end
        pcall(function() aas_swordPassiveRollRemote:Fire({ SwordKey=sword1Data.SwordKey or "World0", Rarity=sword1Data.Rarity, Level=sword1Data.Level or 0, Index=sword1Data.Index or 1, SystemKey="World6" }) end)
        task.wait(0.1)
    end
end

function aas_swordPassive2Loop()
    while swordPassive2Enabled do
        local stopRarities = aas_getSword2StopRarities()
        if aas_swordPassiveRarityReached(sword2CurrentBreathing, stopRarities) then
            swordPassive2Enabled = false
            if Toggles["AutoSwordPassive2Enabled"] then Toggles["AutoSwordPassive2Enabled"]:SetValue(false) end
            Window:Notify({ Title = "Euclidean", Content = "Sword Passive 2 Stopped - Reached: "..(sword2CurrentBreathing and sword2CurrentBreathing.Name or "Unknown"), Duration = 3, Type = "Info" })
            break
        end
        if not sword2Data then task.wait(1) continue end
        pcall(function() aas_swordPassiveRollRemote:Fire({ SwordKey=sword2Data.SwordKey or "World0", Rarity=sword2Data.Rarity, Level=sword2Data.Level or 0, Index=sword2Data.Index or 1, SystemKey="World6" }) end)
        task.wait(0.1)
    end
end

-- GRIMOIRES
function aas_grimoire1Loop()
    while grimoire1Enabled do
        if activeGrimoireSlot1 == AAS_DIVINE then
            grimoire1Enabled = false
            if Toggles["AutoGrimoire1Enabled"] then Toggles["AutoGrimoire1Enabled"]:SetValue(false) end
            Window:Notify({ Title = "Euclidean", Content = "Auto Grimoire Slot 1 Stopped - Reached Divine!", Duration = 3, Type = "Info" }) break
        end
        pcall(function() aas_grimoireRollRemote:Fire("World7", "Slot1") end) task.wait(0.1)
    end
end

function aas_grimoire2Loop()
    while grimoire2Enabled do
        if activeGrimoireSlot2 == AAS_DIVINE then
            grimoire2Enabled = false
            if Toggles["AutoGrimoire2Enabled"] then Toggles["AutoGrimoire2Enabled"]:SetValue(false) end
            Window:Notify({ Title = "Euclidean", Content = "Auto Grimoire Slot 2 Stopped - Reached Divine!", Duration = 3, Type = "Info" }) break
        end
        pcall(function() aas_grimoireRollRemote:Fire("World7", "Slot2") end) task.wait(0.1)
    end
end

-- PET PASSIVES
function aas_getPetPassiveStopRarities()
    local opt = Options["PetPassiveStopRarities"]
    if not opt then return {} end
    local selected = {}
    for rarity, state in pairs(opt.Value or {}) do if state then table.insert(selected, rarity) end end
    return selected
end

function aas_getPetPassiveCurrentRarity()
    if not petPassiveCurrentData then return nil end
    return petPassiveCurrentData.Rarity
end

function aas_petPassiveRarityReached(stopRarities)
    local currentRarity = aas_getPetPassiveCurrentRarity()
    if not currentRarity or #stopRarities == 0 then return false end
    for _, r in ipairs(stopRarities) do if r == currentRarity then return true end end
    return false
end

function aas_syncPetPassiveData()
    if not aas_getPlayerDataFunc then return end
    local ok, data = pcall(function() return aas_getPlayerDataFunc:InvokeServer() end)
    if not ok or type(data) ~= "table" then return end
    local petPassives = data.PetPassives
    local selectedId = petPassiveSelectedPetId
    if type(petPassives) == "table" and selectedId then
        local passiveId = petPassives[selectedId]
        if type(passiveId) == "string" and passiveId ~= "" then
            local passiveConfig = nil
            pcall(function()
                local cfg = GameLibrary.getConfig("PetPassiveConfig")
                if cfg and cfg.GetPassiveById then passiveConfig = cfg:GetPassiveById(passiveId) end
            end)
            if passiveConfig then petPassiveCurrentData = { Id=passiveConfig.Id, Name=passiveConfig.Name or passiveId, Rarity=passiveConfig.Rarity or "Unknown" }
            else petPassiveCurrentData = { Id=passiveId, Name=passiveId, Rarity="Unknown" } end
        else petPassiveCurrentData = nil end
    end
    if petPassiveLabelRef then
        if petPassiveCurrentData then
            aas_setLabel(petPassiveLabelRef, "Current: "..tostring(petPassiveCurrentData.Name).." ("..tostring(petPassiveCurrentData.Rarity)..")")
        else aas_setLabel(petPassiveLabelRef, "Current: None") end
    end
end

function aas_scanEquippedPets()
    local equipped, equippedIds, petPassives = {}, {}, {}
    pcall(function()
        local data = aas_getPlayerDataFunc:InvokeServer()
        if data and data.EquippedPets then
            for uuid, isEquipped in pairs(data.EquippedPets) do if isEquipped == true then equippedIds[uuid] = true end end
        end
        if data and data.PetPassives then
            for uuid, passiveData in pairs(data.PetPassives) do
                if type(passiveData) == "table" then petPassives[uuid] = { Name=passiveData.Name or passiveData.Id or "Unknown", Rarity=passiveData.Rarity or "Unknown" } end
            end
        end
    end)
    local petNames = {}
    pcall(function()
        local scrollFrame = LocalPlayer.PlayerGui.Windows.Pets.Main.Pets.ScrollingFrame
        for _, child in ipairs(scrollFrame:GetChildren()) do
            if not child:IsA("GuiObject") then continue end
            local uuid = child.Name
            if not uuid:match("^%x+%-%x+%-%x+%-%x+%-%x+$") then continue end
            local main = child:FindFirstChild("Main")
            if main then
                local nameLabel = main:FindFirstChild("Name")
                if nameLabel and nameLabel:IsA("TextLabel") and nameLabel.Text ~= "" then petNames[uuid] = nameLabel.Text end
            end
        end
    end)
    for uuid in pairs(equippedIds) do
        local name = petNames[uuid] or ("Pet "..uuid:sub(1, 8))
        local passive = petPassives[uuid]
        equipped[uuid] = { Name=name, Passive=passive }
    end
    return equipped
end

function aas_petPassiveLoop()
    while petPassiveAutoEnabled do
        local selectedId = petPassiveSelectedPetId
        if not selectedId or selectedId == "" then task.wait(1) continue end
        pcall(aas_syncPetPassiveData)
        local stopRarities = aas_getPetPassiveStopRarities()
        if aas_petPassiveRarityReached(stopRarities) then
            petPassiveAutoEnabled = false
            if Toggles["AutoPetPassiveEnabled"] then Toggles["AutoPetPassiveEnabled"]:SetValue(false) end
            Window:Notify({ Title = "Euclidean", Content = "Pet Passive Stopped - Reached: "..tostring(petPassiveCurrentData and petPassiveCurrentData.Name or "Unknown"), Duration = 3, Type = "Info" })
            break
        end
        pcall(function() aas_petPassiveRollRemote:Fire({ SystemKey="World9", PetUniqueId=selectedId }) end)
        task.wait(1.1)
        if aas_petPassiveRarityReached(aas_getPetPassiveStopRarities()) then
            petPassiveAutoEnabled = false
            if Toggles["AutoPetPassiveEnabled"] then Toggles["AutoPetPassiveEnabled"]:SetValue(false) end
            Window:Notify({ Title = "Euclidean", Content = "Pet Passive Stopped - Reached: "..tostring(petPassiveCurrentData and petPassiveCurrentData.Name or "Unknown"), Duration = 3, Type = "Info" })
            break
        end
    end
end

-- ══════════════════════════════════════════
--   PROGRESSION, UPGRADES & EVOLUTION
-- ══════════════════════════════════════════

function aas_progressionLoop(progKey)
    local progData = ProgressionList[progKey]
    if not progData then return end
    while progressionEnabled[progKey] do
        local currentLevel = progressionLevels[progKey] or 0
        if currentLevel >= (progData.MaxLevel or 45) then
            progressionEnabled[progKey] = false
            if Toggles["AutoProgression_"..progKey] then Toggles["AutoProgression_"..progKey]:SetValue(false) end
            Window:Notify({ Title = "Euclidean", Content = progData.Name.." Stopped - Reached max level "..tostring(progData.MaxLevel).."!", Duration = 3, Type = "Info" })
            break
        end
        pcall(function() aas_progressionUpgradeRemote:Fire(progKey) end) task.wait(0.1)
    end
end

function aas_rangeUpgradeLoop(sysKey)
    while rangeUpgradeEnabled[sysKey] do pcall(function() aas_rangeUpgradeRemote:Fire(sysKey) end) task.wait(1.0) end
end

function aas_upgrades2LoopV2(sysKey)
    pcall(function() aas_upgrades2DataRemote:Fire() end) task.wait(1)
    while upgrades2Enabled2[sysKey] do
        local selectedStats = upgrades2SelectedStats[sysKey] or {}
        local anySelected = false
        for _ in pairs(selectedStats) do anySelected = true break end
        if not anySelected then task.wait(1) continue end

        local liveData = upgrades2LiveData[sysKey] or {}
        local anyUpgraded = false
        local cfg = GameLibrary.getConfig("Upgrades2Config")
        local sysData = cfg and cfg:GetSystem(sysKey)
        local upgradeList = sysData and sysData.UpgradeList or {}

        for _, upgradeInfo in ipairs(upgradeList) do
            local statKey = upgradeInfo.Key
            if not selectedStats[statKey] then continue end
            local live = liveData[statKey]
            local currentLevel = (live and live.Level) or 0
            local maxLevel = upgradeInfo.MaxLevel or math.huge
            if currentLevel >= maxLevel then
                upgrades2SelectedStats[sysKey][statKey] = nil
                Window:Notify({ Title = "Euclidean", Content = "Professions: "..(upgradeInfo.DisplayName or statKey).." - Reached MAX! Deselected.", Duration = 3, Type = "Info" })
                continue
            end
            if live and live.CanUpgrade == true then
                pcall(function() aas_upgrades2RequestRemote:Fire(sysKey, statKey) end)
                anyUpgraded = true task.wait(1.5)
                pcall(function() aas_upgrades2DataRemote:Fire() end) task.wait(0.5)
            end
        end

        if not anyUpgraded then task.wait(3) else task.wait(0.5) end
    end
end

function aas_autoEvolutionLoop()
    pcall(aas_syncAllPlayerData)
    while autoEvolutionEnabled do
        local allMaxed = true
        for _, evKey in ipairs(sortedEvolutionKeys) do
            if not autoEvolutionEnabled then break end
            local currentLevel = 0
            pcall(function()
                local evolutions = cachedPlayerData and cachedPlayerData.Evolutions
                if type(evolutions) == "table" then currentLevel = tonumber(evolutions[evKey]) or 0 end
            end)
            local evData = EvolutionList[evKey]
            if not evData then continue end
            if currentLevel < evData.MaxLevel then
                allMaxed = false
                pcall(function() aas_evolutionRequestRemote:Fire(evKey) end)
                task.wait(5.5) pcall(aas_syncAllPlayerData)
            end
        end
        if allMaxed then
            autoEvolutionEnabled = false
            if Toggles["AutoEvolutionEnabled"] then Toggles["AutoEvolutionEnabled"]:SetValue(false) end
            Window:Notify({ Title = "Euclidean", Content = "Auto Evolution - All evolutions are at MAX level!", Duration = 3, Type = "Info" })
            break
        end
        task.wait(1)
    end
end

-- ══════════════════════════════════════════
--   SKILL TREE & CONSTELLATIONS
-- ══════════════════════════════════════════

function aas_skillTreeLoop(treeName)
    local treeData = SkillTreeList[treeName]
    if not treeData then return end
    while skillTreeEnabled[treeName] do
        pcall(aas_syncAllPlayerData)
        local purchased = {}
        pcall(function()
            if cachedPlayerData and cachedPlayerData.SkillTree then
                local treeProgress = cachedPlayerData.SkillTree[treeName]
                if type(treeProgress) == "table" then purchased = treeProgress end
            end
        end)
        local allDone = true
        for _, upgradeName in ipairs(treeData.UpgradeOrder) do
            if not skillTreeEnabled[treeName] then break end
            if not purchased[upgradeName] then
                allDone = false
                pcall(function() aas_skillTreeUpgradeRemote:InvokeServer(treeName, upgradeName) end)
                task.wait(0.5) pcall(aas_syncAllPlayerData)
            end
        end
        if allDone then
            skillTreeEnabled[treeName] = false
            if Toggles["AutoSkillTree_"..treeName] then Toggles["AutoSkillTree_"..treeName]:SetValue(false) end
            Window:Notify({ Title = "Euclidean", Content = "Skill Tree: "..treeName.." - All upgrades purchased!", Duration = 3, Type = "Info" })
            break
        end
        task.wait(1)
    end
end

function aas_constellationLoop(constId)
    local constData = ConstellationList[constId]
    if not constData then return end
    while constellationEnabled[constId] do
        pcall(aas_syncAllPlayerData)
        local purchased = {}
        pcall(function()
            if cachedPlayerData and cachedPlayerData.SinsRaid then
                local constellations = cachedPlayerData.SinsRaid.Constellations
                if type(constellations) == "table" then
                    local constProgress = constellations[constId]
                    if type(constProgress) == "table" then purchased = constProgress end
                end
            end
        end)
        local allDone = true
        for _, nodeName in ipairs(constData.NodeOrder) do
            if not constellationEnabled[constId] then break end
            if purchased[nodeName] ~= true then
                allDone = false
                pcall(function() aas_constellationUpgradeRemote:InvokeServer(constId, nodeName) end)
                task.wait(0.5) pcall(aas_syncAllPlayerData)
            end
        end
        if allDone then
            constellationEnabled[constId] = false
            if Toggles["AutoConstellation_"..constId] then Toggles["AutoConstellation_"..constId]:SetValue(false) end
            Window:Notify({ Title = "Euclidean", Content = "Constellation: "..constData.Name.." - All nodes purchased!", Duration = 3, Type = "Info" })
            break
        end
        task.wait(1)
    end
end

-- ══════════════════════════════════════════
--   STAR, CRAFTS & RELICS
-- ══════════════════════════════════════════

function aas_getPetAutoActionsForEgg(eggKey)
    local out = {}
    if not eggKey or eggKey == "" then return out end

    local data = cachedPlayerData
    if type(data) ~= "table" then
        local ok, fetched = pcall(function() return aas_getPlayerDataFunc:InvokeServer() end)
        if ok and type(fetched) == "table" then
            cachedPlayerData = fetched
            data = fetched
        end
    end

    local petAutoActions = data and data.PetAutoActions
    if type(petAutoActions) ~= "table" then return out end

    local eggActions = petAutoActions[eggKey]
    if type(eggActions) ~= "table" then return out end

    local validActions = { delete = true, lock = true, deleteShiny = true, lockShiny = true }
    for rarity, action in pairs(eggActions) do
        if type(rarity) == "string" and type(action) == "string" and validActions[action] then
            out[rarity] = action
        end
    end
    return out
end

function aas_starLoop()
    local lastSync = 0
    while starEnabled do
        local eggKey = starEggKey
        if not eggKey then task.wait(0.5) continue end
        if tick() - lastSync >= 5 then
            lastSync = tick()
            pcall(aas_syncAllPlayerData)
        end
        local actions = aas_getPetAutoActionsForEgg(eggKey)
        pcall(function() aas_openEggRemote:Fire(eggKey, actions) end)
        task.wait(0.1)
    end
end

function aas_craftLoop(craftKey)
    local craftData = CraftList[craftKey]
    if not craftData then return end
    while craftEnabled[craftKey] do
        local isShiny = craftShiny[craftKey] == true
        pcall(function() aas_craftPetRemote:Fire(craftKey, isShiny) end) task.wait(1.1)
    end
end

function aas_getRelicState(relicName)
    if not cachedPlayerData then return nil end
    local relics = cachedPlayerData.Relics
    if type(relics) ~= "table" then return nil end
    local state = relics[relicName]
    if type(state) ~= "table" then return nil end
    return state
end

local AAS_GQ_RELIC_MAP = {
    ["Ninja Relic"]   = { WorldId=1, Stat="Yen"    },
    ["Dragon Relic"]  = { WorldId=2, Stat="Power"  },
    ["Fruits Relic"]  = { WorldId=3, Stat="Luck"   },
    ["Titan Relic"]   = { WorldId=4, Stat="Damage" },
    ["Shadows Relic"] = { WorldId=5, Stat="Drop"   },
    ["Slayer Relic"]  = { WorldId=6, Stat="XP"     },
}

function aas_autoRelicUpgradeLoop()
    while autoRelicUpgradeEnabled do
        pcall(aas_syncAllPlayerData)
        local allMaxed = true
        for relicName, _ in pairs(AAS_GQ_RELIC_MAP) do
            if not autoRelicUpgradeEnabled then break end
            local relicState = aas_getRelicState(relicName)
            if relicState then
                local level = tonumber(relicState.Level) or 0
                local ascension = tonumber(relicState.Ascension) or 0
                local isMaxed = false
                pcall(function() isMaxed = aas_RelicConfig:IsMaxed(level, ascension) end)
                if not isMaxed then
                    allMaxed = false
                    local canAscend = false
                    pcall(function() canAscend = aas_RelicConfig:CanAscend(level, ascension) end)
                    if not canAscend then pcall(function() aas_relicUpgradeRemote:Fire(relicName) end) task.wait(0.3) end
                end
            end
        end
        if allMaxed then
            autoRelicUpgradeEnabled = false
            if Toggles["AutoRelicUpgradeEnabled"] then Toggles["AutoRelicUpgradeEnabled"]:SetValue(false) end
            Window:Notify({ Title = "Euclidean", Content = "Auto Relic Upgrade - All relics maxed!", Duration = 3, Type = "Info" })
            break
        end
        task.wait(0.5)
    end
end

function aas_autoRelicAscendLoop()
    while autoRelicAscendEnabled do
        pcall(aas_syncAllPlayerData)
        for relicName, _ in pairs(AAS_GQ_RELIC_MAP) do
            if not autoRelicAscendEnabled then break end
            local relicState = aas_getRelicState(relicName)
            if relicState then
                local level = tonumber(relicState.Level) or 0
                local ascension = tonumber(relicState.Ascension) or 0
                local canAscend = false
                pcall(function() canAscend = aas_RelicConfig:CanAscend(level, ascension) end)
                if canAscend then pcall(function() aas_relicAscendRemote:Fire(relicName) end) task.wait(1) end
            end
        end
        task.wait(2)
    end
end

-- ══════════════════════════════════════════
--   GLOBAL QUEST SYSTEM
-- ══════════════════════════════════════════

local AAS_GQ_DEFEAT_MAP = {
    Itachi      = { ModelName="Itachi",      EnemyName="Itache",        WorldId=1  },
    Broly       = { ModelName="Broly",       EnemyName="Broly",         WorldId=2  },
    BarbaBranca = { ModelName="BarbaBranca", EnemyName="White Beard",   WorldId=3  },
    ArmoredTitan= { ModelName="ArmoredTitan",EnemyName="Armored Titan", WorldId=4  },
    Beleon      = { ModelName="Beleon",      EnemyName="Beleon",        WorldId=5  },
    Kokeshebo   = { ModelName="Kokeshebo",   EnemyName="Kokeshebo",     WorldId=6  },
    Lucies      = { ModelName="Lucies",      EnemyName="Lucies",        WorldId=7  },
    Quinella    = { ModelName="Quinella",    EnemyName="Quinella",      WorldId=8  },
    Sho         = { ModelName="Sho",         EnemyName="Sho",           WorldId=9  },
    Aiz         = { ModelName="Aiz",         EnemyName="Aiz",           WorldId=10 },
}

local AAS_GQ_GAMEMODE_MAP = {
    TimelessRaid    = { Type="Raid",    Key="World0",        WorldId=0  },
    NinjaRaid       = { Type="Raid",    Key="World1",        WorldId=1  },
    TitanDefense    = { Type="Defense", Key="World4",        WorldId=4  },
    TrialEasy       = { Type="Trial",   Key="Easy",          WorldId=1  },
    TrialMedium     = { Type="Trial",   Key="Medium",        WorldId=1  },
    GateRaid        = { Type="Gate",    Key="World5",        WorldId=5  },
    InfinityCastle  = { Type="Raid",    Key="World6",        WorldId=6  },
    CloverRaid      = { Type="Raid",    Key="World7",        WorldId=7  },
    BeachDefense    = { Type="Defense", Key="World8",        WorldId=8  },
    FireCityDungeon = { Type="Dungeon", Key="World9Dungeon", WorldId=9  },
    SoulRaid        = { Type="Raid",    Key="World10",       WorldId=10 },
}

local AAS_GQ_ACCESSORY_MAP = {
    AkatsukiHat = { Mob="Itachi",      WorldId=1  },
    Gogeta      = { Mob="Broly",       WorldId=2  },
    Enel        = { Mob="BarbaBranca", WorldId=3  },
    Levi        = { Mob="ArmoredTitan",WorldId=4  },
    Iron        = { Mob="Beleon",      WorldId=5  },
    KingCape    = { Mob="Lucies",      WorldId=7  },
    Floatie     = { Mob="Quinella",    WorldId=8  },
    FireJacket  = { Mob="Aiz",         WorldId=10 },
}

local AAS_GQ_GACHA_MAP = {
    World1="World1", World2="World2", World2DivineTechniques="World2DivineTechniques",
    World3="World3", World3DemonFruits="World3DemonFruits", World4="World4",
    World5="World5", World6="World6", World7="World7", World8="World8",
    World9="World9", World10="World10",
}

function aas_gqGetDef(index)
    local allQuests = aas_GlobalQuestConfig:GetAll()
    return allQuests and allQuests[index] or nil
end

function aas_gqReadQuest(index)
    local result = { Index=index, Current=0, Required=0, Complete=false, Claimed=false, Objective="" }
    pcall(function()
        local windows = LocalPlayer.PlayerGui:FindFirstChild("Windows")
        if not windows then return end
        local gqWindow = windows:FindFirstChild("GlobalQuest")
        if not gqWindow then return end
        local main = gqWindow:FindFirstChild("Main")
        if not main then return end
        local scroll = main:FindFirstChild("Scroll")
        if not scroll then return end
        local card = scroll:FindFirstChild("GlobalQuest_" .. tostring(index))
        if not card then return end

        local qty = card:FindFirstChild("Quantity") or card:FindFirstChild("Quantity", true)
        if qty and (qty:IsA("TextLabel") or qty:IsA("TextButton")) then
            local cur, req = qty.Text:match("(%d+)/(%d+)")
            result.Current = tonumber(cur) or 0
            result.Required = tonumber(req) or 0
        end

        local obj = card:FindFirstChild("Objective") or card:FindFirstChild("Objective", true)
        if obj then result.Objective = obj.Text or "" end

        local claimBtn = card:FindFirstChild("Claim") or card:FindFirstChild("Claim", true)
        if claimBtn and claimBtn:IsA("GuiButton") and claimBtn.Visible then
            result.Complete = true
        end

        local completedBtn = card:FindFirstChild("Completed") or card:FindFirstChild("Completed", true)
        if completedBtn and completedBtn:IsA("GuiObject") and completedBtn.Visible then
            result.Claimed = true
            result.Complete = true
        end

        if result.Required > 0 and result.Current >= result.Required then
            result.Complete = true
        end
    end)
    return result
end

function aas_gqBuildDisplay(i)
    local def = aas_gqGetDef(i)
    if not def then return "#"..i.." — Unknown" end
    local t = def.Type or "?"
    local reward = ""
    pcall(function() reward = aas_GlobalQuestConfig:FormatReward(def.Reward) or "" end)
    local desc = ""
    if t == "Defeat" then
        local mobInfo = AAS_GQ_DEFEAT_MAP[def.Mob]
        desc = "Kill "..(mobInfo and mobInfo.EnemyName or def.Mob or "?").." x"..tostring(def.Kills or 0)
    elseif t == "GamemodeJoin" then desc = "Join "..tostring(def.Gamemode).." x"..tostring(def.Joins or 0)
    elseif t == "GamemodeComplete" then desc = "Complete "..tostring(def.Gamemode).." x"..tostring(def.Amount or 0)
    elseif t == "GamemodeWaves" then desc = tostring(def.Waves or 0).." waves in "..tostring(def.Gamemode)
    elseif t == "GachaRoll" then desc = "Roll "..tostring(def.Result or "?").." in "..tostring(def.Gacha or "?")
    elseif t == "PlayerRank" then desc = "Reach Rank "..tostring(def.Rank or 0)
    elseif t == "RelicLevel" then desc = tostring(def.Relic or "?").." Lv."..tostring(def.Level or 0)
    elseif t == "RelicAscension" then desc = tostring(def.Relic or "?").." Ascension "..tostring(def.Ascension or 0)
    elseif t == "AccessoryObtain" then desc = "Obtain "..tostring(def.Accessory or "?")
    else desc = tostring(t) end
    return "#"..i.." "..desc.." ["..reward.."]"
end

function aas_gqIsFarmable(index)
    local ok, def = pcall(aas_gqGetDef, index)
    if not ok or not def then return false end
    local t = def.Type
    if not t then return false end
    if t == "Defeat" and def.Mob and AAS_GQ_DEFEAT_MAP[def.Mob] then return true end
    if t == "AccessoryObtain" and def.Accessory and AAS_GQ_ACCESSORY_MAP[def.Accessory] then return true end
    if t == "RelicLevel" and def.Relic and AAS_GQ_RELIC_MAP[def.Relic] then return true end
    if t == "RelicAscension" and def.Relic and AAS_GQ_RELIC_MAP[def.Relic] then return true end
    if (t == "GamemodeJoin" or t == "GamemodeComplete" or t == "GamemodeWaves") and def.Gamemode and AAS_GQ_GAMEMODE_MAP[def.Gamemode] then return true end
    if t == "GachaRoll" and def.Gacha and AAS_GQ_GACHA_MAP[def.Gacha] then return true end
    if t == "PlayerRank" then return true end
    return false
end

function aas_globalQuestLoop()
    while globalQuestEnabled do
        local highPrio, highType = aas_isHighPrioritySpawnOrRunPresent()
        if highPrio then
            if not globalQuestSuppressedByPriority then
                globalQuestSuppressedByPriority = true
                Window:Notify({ Title = "Euclidean", Content = "GQ Paused - "..tostring(highType).." has higher priority.", Duration = 3, Type = "Info" })
            end
            task.wait(1) continue
        else
            if globalQuestSuppressedByPriority then
                globalQuestSuppressedByPriority = false
                Window:Notify({ Title = "Euclidean", Content = "GQ Resumed", Duration = 3, Type = "Info" })
            end
        end

        local selectedIndices = {}
        local selectOpt = Options["GQSelectQuests"]
        if selectOpt and type(selectOpt.Value) == "table" then
            for display, state in pairs(selectOpt.Value) do
                if state then
                    local idx = tonumber(display:match("^#(%d+)"))
                    if idx then table.insert(selectedIndices, idx) end
                end
            end
        end

        if #selectedIndices == 0 then task.wait(2) continue end
        table.sort(selectedIndices)

        local hasMobQuests, hasGamemodeQuests, hasGachaQuests, hasRankQuests = false, false, false, false
        for _, idx in ipairs(selectedIndices) do
            local def = aas_gqGetDef(idx)
            if not def then continue end
            if def.Type == "Defeat" or def.Type == "AccessoryObtain" or def.Type == "RelicLevel" or def.Type == "RelicAscension" then hasMobQuests = true
            elseif def.Type == "GamemodeJoin" or def.Type == "GamemodeComplete" or def.Type == "GamemodeWaves" then hasGamemodeQuests = true
            elseif def.Type == "GachaRoll" then hasGachaQuests = true
            elseif def.Type == "PlayerRank" then hasRankQuests = true end
        end

        if hasRankQuests then pcall(function() aas_toggleAutoRank(true) end) end

        if hasMobQuests then
            aas_equipLoadout(LoadoutAssignments.Farm or "Power")
            aas_enterPotionContext("Farm")
            local farmDone = false
            while globalQuestEnabled and not farmDone and not globalQuestSuppressedByPriority do
                local allMobsDone = true
                for _, idx in ipairs(selectedIndices) do
                    local def = aas_gqGetDef(idx)
                    if not def then continue end
                    local mobInfo = nil
                    if def.Type == "Defeat" then mobInfo = AAS_GQ_DEFEAT_MAP[def.Mob]
                    elseif def.Type == "AccessoryObtain" then
                        local accInfo = AAS_GQ_ACCESSORY_MAP[def.Accessory]
                        if accInfo then mobInfo = AAS_GQ_DEFEAT_MAP[accInfo.Mob] end
                    elseif def.Type == "RelicLevel" or def.Type == "RelicAscension" then
                        local relicInfo = AAS_GQ_RELIC_MAP[def.Relic]
                        if relicInfo then
                            for _, mi in pairs(AAS_GQ_DEFEAT_MAP) do
                                if mi.WorldId == relicInfo.WorldId then mobInfo = mi break end
                            end
                        end
                    end
                    if mobInfo then
                        allMobsDone = false
                        if currentWorldTracked ~= mobInfo.WorldId then aas_teleportToWorld(mobInfo.WorldId) currentWorldTracked = mobInfo.WorldId end
                        local mobs = aas_findMobsInWorld(mobInfo.WorldId, { mobInfo.EnemyName })
                        for _, mob in ipairs(mobs) do
                            if not globalQuestEnabled or globalQuestSuppressedByPriority then break end
                            if not mob.Parent or mob:GetAttribute("EnemyDead") == true then continue end
                            aas_teleportToMob(mob) aas_waitForDead(mob, 25) task.wait(0.05)
                        end
                    end
                end
                if allMobsDone then farmDone = true end
                task.wait(0.5)
            end
        end

        if not globalQuestEnabled then break end

        if hasGachaQuests then
            while globalQuestEnabled and not globalQuestSuppressedByPriority do
                local anyRemaining = false
                for _, idx in ipairs(selectedIndices) do
                    local def = aas_gqGetDef(idx)
                    if not def or def.Type ~= "GachaRoll" then continue end
                    local gachaKey = AAS_GQ_GACHA_MAP[def.Gacha]
                    if gachaKey then anyRemaining = true pcall(function() aas_gachaRollRemote:Fire(gachaKey) end) task.wait(0.1) end
                end
                if not anyRemaining then break end
                task.wait(0.05)
            end
        end

        if not globalQuestEnabled then break end

        for _, idx in ipairs(selectedIndices) do
            pcall(function() aas_globalQuestClaimRemote:Fire(idx) end) task.wait(0.5)
        end

        task.wait(2)
    end
    globalQuestCurrentTarget = nil globalQuestCurrentAction = nil globalQuestSuppressedByPriority = false
end

-- ══════════════════════════════════════════
--   PROMOTION SYSTEM
-- ══════════════════════════════════════════

local AAS_PROMO_RELIC_ALIASES = { SlayerRelic="Slayer Relic", DragonRelic="Dragon Relic", NinjaRelic="Ninja Relic", TitanRelic="Titan Relic", FruitsRelic="Fruits Relic", ShadowsRelic="Shadows Relic" }
local AAS_PROMO_MOB_MAP = {
    ["Itachi"]={EnemyName="Itache",WorldId=1}, ["Broly"]={EnemyName="Broly",WorldId=2},
    ["WhiteBeard"]={EnemyName="White Beard",WorldId=3}, ["BarbaBranca"]={EnemyName="White Beard",WorldId=3},
    ["ArmoredTitan"]={EnemyName="Armored Titan",WorldId=4}, ["Beleon"]={EnemyName="Beleon",WorldId=5},
    ["Kokeshebo"]={EnemyName="Kokeshebo",WorldId=6}, ["Lucies"]={EnemyName="Lucies",WorldId=7},
    ["Quinella"]={EnemyName="Quinella",WorldId=8}, ["Sho"]={EnemyName="Sho",WorldId=9},
    ["Aiz"]={EnemyName="Aiz",WorldId=10},
}

function aas_promoNormalizeRelicName(name) return AAS_PROMO_RELIC_ALIASES[tostring(name or "")] or tostring(name or "") end

function aas_promoMissionSource(missionState)
    if type(missionState) ~= "table" then return {} end
    return missionState.Mission or missionState
end

function aas_promoMissionType(missionState)
    local src = aas_promoMissionSource(missionState)
    if type(missionState) == "table" and type(missionState.Type) == "string" and missionState.Type ~= "" then return missionState.Type end
    local ok, result = pcall(function() return aas_PromotionConfig:GetQuestType(src) end)
    return ok and tostring(result or "Defeat") or "Defeat"
end

function aas_promoMissionRequired(missionState)
    if type(missionState) == "table" and missionState.Required ~= nil then return tonumber(missionState.Required) or 0 end
    local src = aas_promoMissionSource(missionState)
    local ok, result = pcall(function() return aas_PromotionConfig:GetRequiredAmount(src) end)
    return ok and (tonumber(result) or 0) or 0
end

function aas_promoMissionCurrent(missionState)
    if type(missionState) ~= "table" then return 0 end
    return tonumber(missionState.Current) or 0
end

function aas_promoMissionComplete(missionState)
    if type(missionState) ~= "table" then return false end
    if missionState.Complete == true then return true end
    return aas_promoMissionCurrent(missionState) >= aas_promoMissionRequired(missionState)
end

function aas_promoResolveMobTarget(rawMobName)
    local raw = tostring(rawMobName or "")
    if raw == "" then return nil end
    if AAS_PROMO_MOB_MAP[raw] then return AAS_PROMO_MOB_MAP[raw] end
    local cleaned = raw:gsub("%s+", ""):lower()
    for key, info in pairs(AAS_PROMO_MOB_MAP) do
        if tostring(key):gsub("%s+", ""):lower() == cleaned then return info end
    end
    return nil
end

function aas_promoBuildMissionText(missionState, includeProgress)
    local src = aas_promoMissionSource(missionState)
    local t = aas_promoMissionType(missionState)
    local text = ""
    if t == "Defeat" then text = "Defeat "..(src.Mob or "*").." x"..tostring(src.Kills or src.Amount or aas_promoMissionRequired(missionState))
    elseif t == "PlayerLevel" then text = "Reach Level "..tostring(src.Level or aas_promoMissionRequired(missionState))
    elseif t == "PlayerRank" then text = "Reach Rank "..tostring(src.Rank or aas_promoMissionRequired(missionState))
    elseif t == "GamemodeJoin" then text = "Join "..tostring(src.Gamemode or "?").." x"..tostring(src.Joins or aas_promoMissionRequired(missionState))
    elseif t == "GamemodeWaves" then text = tostring(src.Waves or aas_promoMissionRequired(missionState)).." waves in "..tostring(src.Gamemode or "?")
    elseif t == "GamemodeComplete" then text = "Complete "..tostring(src.Gamemode or "?").." x"..tostring(src.Amount or aas_promoMissionRequired(missionState))
    elseif t == "GachaRoll" then text = "Roll "..tostring(src.Gacha or "?").." x"..tostring(src.Amount or aas_promoMissionRequired(missionState))
    elseif t == "RelicLevel" then text = tostring(aas_promoNormalizeRelicName(src.Relic or "?")).." to Level "..tostring(src.Level or aas_promoMissionRequired(missionState))
    elseif t == "RelicAscension" then text = tostring(aas_promoNormalizeRelicName(src.Relic or "?")).." to Ascension "..tostring(src.Ascension or aas_promoMissionRequired(missionState))
    elseif t == "PetSummon" then text = "Summon pets in "..tostring(src.World or "?").." x"..tostring(src.Amount or aas_promoMissionRequired(missionState))
    else text = tostring(t) end
    if includeProgress then text = text.." ("..tostring(aas_promoMissionCurrent(missionState)).."/"..tostring(aas_promoMissionRequired(missionState))..")" end
    return text
end

function aas_promoBuildRankSummary(rank)
    local rankData = aas_PromotionConfig:GetRank(rank)
    if not rankData then return "Promotion "..tostring(rank).." — Unknown" end
    local bits = {}
    for _, mission in ipairs(rankData.Missions or {}) do table.insert(bits, aas_promoBuildMissionText(mission, false)) end
    return tostring(rankData.Name or ("Promotion "..tostring(rank))).." — "..table.concat(bits, " | ")
end

function aas_buildFallbackPromotionState()
    if not cachedPlayerData then pcall(aas_syncAllPlayerData) end
    local data = cachedPlayerData or {}
    local currentRank = tonumber(data.PromotionRank) or 0
    local missions = aas_PromotionConfig:GetMissions(currentRank) or {}
    local rawProgress = data.PromotionProgress or {}
    local stateMissions = {}
    for i, mission in ipairs(missions) do
        local req = tonumber(aas_PromotionConfig:GetRequiredAmount(mission)) or 0
        local cur = tonumber(rawProgress[tostring(i)] or rawProgress[i]) or 0
        table.insert(stateMissions, { Index=i, Type=aas_PromotionConfig:GetQuestType(mission), Mission=mission, Current=cur, Required=req, Complete=cur>=req })
    end
    return { PromotionRank=currentRank, NextRank=aas_PromotionConfig:GetNextRank(currentRank), CanPromote=false, Missions=stateMissions }
end

function aas_promoGetMergedState()
    local fallback = aas_buildFallbackPromotionState()
    local live = promotionLiveState
    local rank = tonumber((live and live.PromotionRank) or (cachedPlayerData and cachedPlayerData.PromotionRank) or fallback.PromotionRank or 0) or 0
    local cfgMissions = aas_PromotionConfig:GetMissions(rank) or {}
    local liveMissions = (live and type(live.Missions) == "table" and live.Missions) or {}
    local rawProgress = (cachedPlayerData and cachedPlayerData.PromotionProgress) or {}
    local merged = { PromotionRank=rank, NextRank=(live and live.NextRank) or aas_PromotionConfig:GetNextRank(rank), CanPromote=(live and live.CanPromote == true) or false, Missions={} }
    for i, cfgMission in ipairs(cfgMissions) do
        local liveMission = liveMissions[i]
        local req, cur, complete = 0, 0, false
        if liveMission then
            req = tonumber(aas_promoMissionRequired(liveMission)) or 0
            cur = tonumber(aas_promoMissionCurrent(liveMission)) or 0
            complete = aas_promoMissionComplete(liveMission)
        else
            req = tonumber(aas_PromotionConfig:GetRequiredAmount(cfgMission)) or 0
            cur = tonumber(rawProgress[tostring(i)] or rawProgress[i]) or 0
            complete = req > 0 and cur >= req
        end
        table.insert(merged.Missions, { Index=i, Type=aas_PromotionConfig:GetQuestType(cfgMission), Mission=cfgMission, Current=cur, Required=req, Complete=complete })
    end
    return merged
end

function aas_requestPromotionState(timeout)
    timeout = timeout or 2
    local oldVersion = promotionStateVersion or 0
    pcall(function() aas_promotionStateRequestRemote:Fire() end)
    local deadline = tick() + timeout
    while tick() < deadline do
        if (promotionStateVersion or 0) > oldVersion and type(promotionLiveState) == "table" then return true, promotionLiveState end
        task.wait(0.05)
    end
    return type(promotionLiveState) == "table" and true or false, promotionLiveState or aas_buildFallbackPromotionState()
end

function aas_updatePromotionUi()
    local state = aas_promoGetMergedState()
    if type(state) ~= "table" then return end
    local currentRank = tonumber(state.PromotionRank) or 0
    local missions = state.Missions or {}
    local completeCount = 0
    for _, m in ipairs(missions) do if aas_promoMissionComplete(m) then completeCount += 1 end end
    if promotionCurrentRankLabelRef then aas_setLabel(promotionCurrentRankLabelRef, "Current Rank: "..tostring(currentRank)) end
    if promotionNextRankLabelRef then aas_setLabel(promotionNextRankLabelRef, "Next Rank: "..tostring(state.NextRank or "-")) end
    if promotionCanPromoteLabelRef then aas_setLabel(promotionCanPromoteLabelRef, "Can Promote: "..tostring(state.CanPromote == true)) end
    if promotionProgressLabelRef then aas_setLabel(promotionProgressLabelRef, "Mission Progress: "..tostring(completeCount).."/"..tostring(#missions)) end
    for i = 1, 10 do
        local labelRef = promotionMissionLabelRefs[i]
        if labelRef then
            local missionState = missions[i]
            if missionState then
                local icon = aas_promoMissionComplete(missionState) and "✅ " or "⏳ "
                aas_setLabel(labelRef, icon..aas_promoBuildMissionText(missionState, true))
            else aas_setLabel(labelRef, " ") end
        end
    end
    for rank, labelRef in pairs(promotionRankRefLabelRefs) do
        if labelRef then
            local prefix = rank < currentRank and "✅ " or (rank == currentRank and "➡️ " or "• ")
            aas_setLabel(labelRef, prefix..aas_promoBuildRankSummary(rank))
        end
    end
end

function aas_promoGetIncompleteMissions()
    local state = aas_promoGetMergedState()
    local incomplete = {}
    for _, missionState in ipairs(state.Missions or {}) do
        if not aas_promoMissionComplete(missionState) then table.insert(incomplete, missionState) end
    end
    return state, incomplete
end

function aas_promoChooseForegroundAction(incompleteMissions)
    for _, missionState in ipairs(incompleteMissions) do
        local src = aas_promoMissionSource(missionState)
        local t = aas_promoMissionType(missionState)
        if (t == "GamemodeWaves" or t == "GamemodeComplete") and AAS_GQ_GAMEMODE_MAP[tostring(src.Gamemode or "")] then
            return { Kind="GamemodeFull", Gamemode=tostring(src.Gamemode or "") }
        end
    end
    for _, missionState in ipairs(incompleteMissions) do
        local src = aas_promoMissionSource(missionState)
        local t = aas_promoMissionType(missionState)
        if t == "Defeat" then
            local target = aas_promoResolveMobTarget(src.Mob)
            if target then return { Kind="SpecificMob", Target=target } end
        elseif t == "RelicLevel" or t == "RelicAscension" then
            local relicInfo = AAS_GQ_RELIC_MAP[aas_promoNormalizeRelicName(src.Relic)]
            if relicInfo then
                for _, mi in pairs(AAS_PROMO_MOB_MAP) do
                    if mi.WorldId == relicInfo.WorldId then return { Kind="SpecificMob", Target=mi } end
                end
            end
        elseif t == "AccessoryObtain" then
            local accInfo = AAS_GQ_ACCESSORY_MAP[src.Accessory or ""]
            if accInfo then
                local target = aas_promoResolveMobTarget(accInfo.Mob)
                if target then return { Kind="SpecificMob", Target=target } end
            end
        end
    end
    for _, missionState in ipairs(incompleteMissions) do
        local src = aas_promoMissionSource(missionState)
        local t = aas_promoMissionType(missionState)
        if t == "GamemodeJoin" and AAS_GQ_GAMEMODE_MAP[tostring(src.Gamemode or "")] then
            return { Kind="GamemodeJoin", Gamemode=tostring(src.Gamemode or "") }
        end
    end
    for _, missionState in ipairs(incompleteMissions) do
        local src = aas_promoMissionSource(missionState)
        local t = aas_promoMissionType(missionState)
        if t == "Defeat" then
            local isAny = false
            pcall(function() isAny = aas_PromotionConfig:IsAnyMob(src) end)
            if isAny then
                local bestWorldId = 1
                pcall(function()
                    local data = cachedPlayerData or {}
                    bestWorldId = tonumber(data.CurrentWorld or data.ActiveWorld or 1) or 1
                end)
                return { Kind="AnyMob", WorldId=bestWorldId }
            end
        end
    end
    return nil
end

function aas_promoDoGamemodeStep(gamemodeName, fullRun)
    local gmInfo = AAS_GQ_GAMEMODE_MAP[gamemodeName]
    if not gmInfo then task.wait(1) return end
    if gmInfo.Type == "Raid" then
        aas_equipLoadout(RaidLoadouts[gmInfo.Key] or "Power")
        if fullRun then
            aas_joinOrCreateRaid(gmInfo.Key)
            if not aas_waitForRaidArena(gmInfo.Key, 10) then return end
            task.wait(5)
            local deadline = tick() + 900
            while promotionEnabled and tick() < deadline do
                if not aas_raidArenaExists(gmInfo.Key) then break end
                if raidOptimizedFarm then task.wait(0.5)
                else
                    local mobs = aas_findMobsInFolder(aas_getRaidEnemiesFolder(gmInfo.Key), nil)
                    if #mobs == 0 then task.wait(0.2) continue end
                    for _, mob in ipairs(mobs) do
                        if not promotionEnabled or not aas_raidArenaExists(gmInfo.Key) then break end
                        if not mob.Parent or mob:GetAttribute("EnemyDead") == true then continue end
                        aas_teleportToMob(mob) aas_waitForDead(mob, 15) task.wait(0.05)
                    end
                end
                task.wait(0.05)
            end
            if aas_raidArenaExists(gmInfo.Key) then aas_leaveRaid() task.wait(5) end
        else
            aas_joinOrCreateRaid(gmInfo.Key) task.wait(2.5)
            if aas_raidArenaExists(gmInfo.Key) then aas_leaveRaid() end
            task.wait(2.5)
        end
    elseif gmInfo.Type == "Defense" then
        aas_equipLoadout(DefenseLoadouts[gmInfo.Key] or "Power")
        local defData = DefenseList[gmInfo.Key]
        if defData and defData.WorldId then pcall(function() aas_requestChangeWorldRemote:Fire(defData.WorldId) end) task.wait(3) end
        if fullRun then
            aas_joinOrCreateDefense(gmInfo.Key)
            if not aas_waitForDefenseArena(gmInfo.Key, 10) then return end
            task.wait(5)
            local deadline = tick() + 900
            while promotionEnabled and tick() < deadline do
                if not aas_defenseArenaExists(gmInfo.Key) then break end
                local mobs = aas_findMobsInFolder(aas_getDefenseEnemiesFolder(gmInfo.Key), nil)
                if #mobs == 0 then task.wait(0.2) continue end
                for _, mob in ipairs(mobs) do
                    if not promotionEnabled or not aas_defenseArenaExists(gmInfo.Key) then break end
                    if not mob.Parent or mob:GetAttribute("EnemyDead") == true then continue end
                    aas_teleportToMob(mob) aas_waitForDead(mob, 15) task.wait(0.05)
                end
                task.wait(0.05)
            end
            if aas_defenseArenaExists(gmInfo.Key) then aas_leaveDefense() task.wait(5) end
        else
            aas_joinOrCreateDefense(gmInfo.Key) task.wait(2.5)
            if aas_defenseArenaExists(gmInfo.Key) then aas_leaveDefense() end
            task.wait(2.5)
        end
    else task.wait(1) end
end

function aas_promoBackgroundGachaLoop()
    while promotionEnabled do
        pcall(aas_syncAllPlayerData) pcall(function() aas_promotionStateRequestRemote:Fire() end)
        local liveState = promotionLiveState or {}
        local rank = tonumber(liveState.PromotionRank) or tonumber(cachedPlayerData and cachedPlayerData.PromotionRank) or 0
        local cfgMissions = aas_PromotionConfig:GetMissions(rank) or {}
        local liveMissions = liveState.Missions or {}
        local didSomething = false
        for i, cfgMission in ipairs(cfgMissions) do
            if not promotionEnabled then break end
            if aas_PromotionConfig:GetQuestType(cfgMission) ~= "GachaRoll" then continue end
            local liveMission = liveMissions[i]
            if not (liveMission and aas_promoMissionComplete(liveMission)) then
                local gachaKey = tostring(cfgMission.Gacha or "")
                if gachaKey ~= "" then pcall(function() aas_gachaRollRemote:Fire(gachaKey) end) didSomething = true task.wait(0.3) end
            end
        end
        task.wait(didSomething and 0.3 or 1)
    end
end

function aas_promoBackgroundEggLoop()
    while promotionEnabled do
        pcall(aas_syncAllPlayerData) pcall(function() aas_promotionStateRequestRemote:Fire() end)
        local liveState = promotionLiveState or {}
        local rank = tonumber(liveState.PromotionRank) or tonumber(cachedPlayerData and cachedPlayerData.PromotionRank) or 0
        local cfgMissions = aas_PromotionConfig:GetMissions(rank) or {}
        local liveMissions = liveState.Missions or {}
        local didSomething = false
        for i, cfgMission in ipairs(cfgMissions) do
            if not promotionEnabled then break end
            if aas_PromotionConfig:GetQuestType(cfgMission) ~= "PetSummon" then continue end
            local liveMission = liveMissions[i]
            if not (liveMission and aas_promoMissionComplete(liveMission)) then
                local eggKey = tostring(cfgMission.World or "")
                if eggKey ~= "" then pcall(function() aas_openEggRemote:Fire(eggKey) end) didSomething = true task.wait(0.65) end
            end
        end
        task.wait(didSomething and 0.65 or 1)
    end
end

function aas_promoBackgroundRelicLoop()
    while promotionEnabled do
        pcall(aas_syncAllPlayerData) pcall(function() aas_promotionStateRequestRemote:Fire() end)
        local state = aas_promoGetMergedState()
        local didSomething = false
        for _, missionState in ipairs(state.Missions or {}) do
            if not promotionEnabled then break end
            if aas_promoMissionComplete(missionState) then continue end
            local src = aas_promoMissionSource(missionState)
            local t = aas_promoMissionType(missionState)
            if t == "RelicLevel" or t == "RelicAscension" then
                local relicName = aas_promoNormalizeRelicName(src.Relic)
                local relicState = aas_getRelicState(relicName)
                if relicState then
                    local level = tonumber(relicState.Level) or 0
                    local asc = tonumber(relicState.Ascension) or 0
                    local canAscend = false
                    pcall(function() canAscend = aas_RelicConfig:CanAscend(level, asc) end)
                    if canAscend then pcall(function() aas_relicAscendRemote:Fire(relicName) end) task.wait(1)
                    else pcall(function() aas_relicUpgradeRemote:Fire(relicName) end) task.wait(0.3) end
                    didSomething = true
                end
            end
        end
        task.wait(didSomething and 0.3 or 1)
    end
end

function aas_promoStartBackgroundThreads()
    if not promotionBgGachaThread then promotionBgGachaThread = task.spawn(aas_promoBackgroundGachaLoop) end
    if not promotionBgEggThread then promotionBgEggThread = task.spawn(aas_promoBackgroundEggLoop) end
    if not promotionBgRelicThread then promotionBgRelicThread = task.spawn(aas_promoBackgroundRelicLoop) end
end

function aas_promoStopBackgroundThreads()
    if promotionBgGachaThread then task.cancel(promotionBgGachaThread) promotionBgGachaThread = nil end
    if promotionBgEggThread then task.cancel(promotionBgEggThread) promotionBgEggThread = nil end
    if promotionBgRelicThread then task.cancel(promotionBgRelicThread) promotionBgRelicThread = nil end
end

function aas_autoPromotionLoop()
    pcall(aas_syncAllPlayerData) aas_requestPromotionState(2) aas_promoStartBackgroundThreads()
    while promotionEnabled do
        pcall(aas_syncAllPlayerData) aas_requestPromotionState(1.5)
        local highPrio, highType = aas_isHighPrioritySpawnOrRunPresent()
        if highPrio then
            if not promotionSuppressedByPriority then
                promotionSuppressedByPriority = true
                Window:Notify({ Title = "Euclidean", Content = "Promotion Paused - "..tostring(highType).." has higher priority.", Duration = 3, Type = "Info" })
            end
            task.wait(1) continue
        else
            if promotionSuppressedByPriority then
                promotionSuppressedByPriority = false
                Window:Notify({ Title = "Euclidean", Content = "Promotion Resumed", Duration = 3, Type = "Info" })
            end
        end

        local state, incomplete = aas_promoGetIncompleteMissions()
        aas_updatePromotionUi()
        if type(state) ~= "table" then task.wait(1) continue end

        if state.CanPromote == true then
            local oldRank = tonumber(state.PromotionRank) or 0
            Window:Notify({ Title = "Euclidean", Content = "Promotion - Promoting from rank "..tostring(oldRank).."...", Duration = 3, Type = "Info" })
            pcall(function() aas_promotionPromoteRemote:Fire() end)
            local promoted = false
            local deadline = tick() + 10
            while promotionEnabled and tick() < deadline do
                task.wait(0.4) pcall(aas_syncAllPlayerData) aas_requestPromotionState(1.2)
                local newRank = tonumber((promotionLiveState and promotionLiveState.PromotionRank) or (cachedPlayerData and cachedPlayerData.PromotionRank) or oldRank) or oldRank
                if newRank > oldRank then promoted = true break end
            end
            aas_updatePromotionUi()
            if promoted then Window:Notify({ Title = "Euclidean", Content = "Promotion - Now farming Promotion "..tostring(promotionLiveState and promotionLiveState.PromotionRank or "?"), Duration = 3, Type = "Info" }) end
            task.wait(0.5) continue
        end

        if #incomplete == 0 then task.wait(1) continue end

        local action = aas_promoChooseForegroundAction(incomplete)
        if not action then task.wait(1)
        elseif action.Kind == "GamemodeFull" then aas_promoDoGamemodeStep(action.Gamemode, true)
        elseif action.Kind == "GamemodeJoin" then aas_promoDoGamemodeStep(action.Gamemode, false)
        elseif action.Kind == "SpecificMob" then
            aas_equipLoadout(LoadoutAssignments.Farm or "Power")
            aas_enterPotionContext("Farm")

            if action.Target.WorldId == 7 and action.Target.EnemyName == "Lucies" then
                local lf = workspace:FindFirstChild("Worlds")
                lf = lf and lf:FindFirstChild("7") lf = lf and lf:FindFirstChild("Enemies")
                if not (lf and lf:FindFirstChild("Lucies")) then aas_preloadWorld7Boss() end
            end

            if currentWorldTracked ~= action.Target.WorldId then
                aas_teleportToWorld(action.Target.WorldId)
                currentWorldTracked = action.Target.WorldId
            end

            local mobs = aas_findMobsInWorld(action.Target.WorldId, { action.Target.EnemyName })
            local count = 0
            if clusterFarmEnabled then
                local centerPos, cluster = aas_getClusterCenter(mobs, 40, 1)
                if centerPos then
                    aas_teleportToClusterCenter(centerPos)
                    aas_waitForClusterDead(cluster, 25)
                end
            else
                for _, mob in ipairs(mobs) do
                    if not promotionEnabled then break end
                    if not mob.Parent or mob:GetAttribute("EnemyDead") == true then continue end
                    aas_teleportToMob(mob) aas_waitForDead(mob, 25) task.wait(0.05)
                    count += 1
                    if count >= 10 then break end
                end
            end
        elseif action.Kind == "AnyMob" then
            aas_equipLoadout(LoadoutAssignments.Farm or "Power")
            aas_enterPotionContext("Farm")

            local bestWorldId = action.WorldId or 1
            if currentWorldTracked ~= bestWorldId then
                aas_teleportToWorld(bestWorldId)
                currentWorldTracked = bestWorldId
            end

            local mobs = aas_findMobsInWorld(bestWorldId, nil)
            local count = 0
            if clusterFarmEnabled then
                local centerPos, cluster = aas_getClusterCenter(mobs, 40, 1)
                if centerPos then
                    aas_teleportToClusterCenter(centerPos)
                    aas_waitForClusterDead(cluster, 25)
                end
            else
                for _, mob in ipairs(mobs) do
                    if not promotionEnabled then break end
                    if not mob.Parent or mob:GetAttribute("EnemyDead") == true then continue end
                    aas_teleportToMob(mob) aas_waitForDead(mob, 25) task.wait(0.05)
                    count += 1
                    if count >= 10 then break end
                end
            end
        else task.wait(1) end

        pcall(aas_syncAllPlayerData) aas_requestPromotionState(1.2) task.wait(0.1)
    end
    aas_promoStopBackgroundThreads()
    currentWorldTracked = nil promotionSuppressedByPriority = false
end

-- ══════════════════════════════════════════
--   CROW / BALL / COMMANDMENT HARVESTERS
-- ══════════════════════════════════════════

function aas_getAllCrows()
    local folder = workspace:FindFirstChild("World6Corvos")
    if not folder then return {} end
    local found = {}
    for _, child in ipairs(folder:GetChildren()) do
        if child.Name:match("^Corvo_") then table.insert(found, child) end
    end
    return found
end

function aas_getAllBalls()
    local folder = workspace:FindFirstChild("World8Balls")
    if not folder then return {} end
    local found = {}
    for _, child in ipairs(folder:GetChildren()) do
        if child.Name:match("^Ball_") then table.insert(found, child) end
    end
    return found
end

function aas_getAllCommandments()
    local folder = workspace:FindFirstChild("World12Commandments")
    if not folder then return {} end
    local found = {}
    for _, child in ipairs(folder:GetChildren()) do
        if child.Name:match("^Commandment_") then table.insert(found, child) end
    end
    return found
end

function aas_claimObject(obj)
    local target = nil
    if obj:IsA("BasePart") then target = obj
    elseif obj:IsA("Model") then target = obj.PrimaryPart or obj:FindFirstChildOfClass("BasePart")
    end
    if not target then
        for _, v in ipairs(obj:GetDescendants()) do if v:IsA("BasePart") then target = v break end end
    end
    if not target then return end
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    hrp.CFrame = target.CFrame * CFrame.new(0, 3, 0)
    hrp.AssemblyLinearVelocity = Vector3.zero
    task.wait(0.05)
    local prompt = nil
    for _, desc in ipairs(obj:GetDescendants()) do
        if desc:IsA("ProximityPrompt") then prompt = desc break end
    end
    if not prompt then
        for _, desc in ipairs(workspace:GetDescendants()) do
            if desc:IsA("ProximityPrompt") and desc.Enabled then
                local part = desc.Parent
                if part and part:IsA("BasePart") and (part.Position - hrp.Position).Magnitude < 15 then
                    prompt = desc break
                end
            end
        end
    end
    if prompt then
        pcall(function() prompt.HoldDuration = 0 prompt.MaxActivationDistance = math.huge prompt.RequiresLineOfSight = false prompt.Enabled = true end)
        local done = false
        local conns = {}
        table.insert(conns, obj.AncestryChanged:Connect(function(_, parent) if not parent then done = true end end))
        local deadline = os.clock() + 1.25
        local nextFire = os.clock() + 0.05
        while not done and os.clock() < deadline and obj.Parent do
            hrp.CFrame = target.CFrame * CFrame.new(0, 3, 0)
            hrp.AssemblyLinearVelocity = Vector3.zero
            if os.clock() >= nextFire then pcall(fireproximityprompt, prompt, 1) nextFire = os.clock() + 0.08 end
            task.wait()
        end
        for _, c in ipairs(conns) do c:Disconnect() end
    else
        game:GetService("VirtualInputManager"):SendKeyEvent(true, Enum.KeyCode.E, false, game)
        task.wait(1)
        game:GetService("VirtualInputManager"):SendKeyEvent(false, Enum.KeyCode.E, false, game)
    end
end

function aas_crowBallClaimProcessor()
    while autoCrowEnabled or autoBallEnabled or autoCommandmentEnabled do
        local hadPendingBefore = (#pendingCrows > 0) or (#pendingBalls > 0)
        local newCrowCount, newBallCount = 0, 0

        if autoCrowEnabled then
            local crows = aas_getAllCrows()
            for _, crow in ipairs(crows) do
                local already = false
                for _, pc in ipairs(pendingCrows) do if pc == crow then already = true break end end
                if not already then table.insert(pendingCrows, crow) newCrowCount = newCrowCount + 1 end
            end
        end

        if autoBallEnabled then
            local balls = aas_getAllBalls()
            for _, ball in ipairs(balls) do
                local already = false
                for _, pb in ipairs(pendingBalls) do if pb == ball then already = true break end end
                if not already then table.insert(pendingBalls, ball) newBallCount = newBallCount + 1 end
            end
        end

        if autoCommandmentEnabled then
            local cmdFolder = workspace:FindFirstChild("World12Commandments")
            if cmdFolder then
                for _, child in ipairs(cmdFolder:GetChildren()) do
                    if child.Name:match("^Commandment_") then
                        local already = false
                        for _, pc in ipairs(pendingBalls) do if pc == child then already = true break end end
                        if not already then table.insert(pendingBalls, child) newBallCount = newBallCount + 1 end
                    end
                end
            end
        end

        local hasPendingNow = (#pendingCrows > 0) or (#pendingBalls > 0)
        if hasPendingNow and not hadPendingBefore then
            pendingCrowBallReadyAt = tick() + AAS_CROW_BALL_GRACE
        end

        if newCrowCount > 0 or newBallCount > 0 then
            Window:Notify({ Title = "Euclidean", Content = "Detected Spawn - Queued " .. tostring(#pendingCrows) .. " crow(s), " .. tostring(#pendingBalls) .. " ball(s). Harvesting in " .. tostring(AAS_CROW_BALL_GRACE) .. "s...", Duration = 3, Type = "Info" })
        end

        if hasPendingNow then
            local aliveCrows = {}
            for _, crow in ipairs(pendingCrows) do if crow and crow.Parent then table.insert(aliveCrows, crow) end end
            pendingCrows = aliveCrows
            local aliveBalls = {}
            for _, ball in ipairs(pendingBalls) do if ball and ball.Parent then table.insert(aliveBalls, ball) end end
            pendingBalls = aliveBalls
        end

        hasPendingNow = (#pendingCrows > 0) or (#pendingBalls > 0)

        if hasPendingNow then
            local highPriorityPresent, _ = aas_isHighPrioritySpawnOrRunPresent()
            if not highPriorityPresent and pendingCrowBallReadyAt > 0 and tick() >= pendingCrowBallReadyAt then
                local snapshot = aas_snapshotAndPauseActivities()
                Window:Notify({ Title = "Euclidean", Content = "Harvesting items now...", Duration = 3, Type = "Info" })

                local crowClaimedCount = 0
                if #pendingCrows > 0 then
                    aas_changeWorldAndWait(6) task.wait(0.5)
                    for _, crow in ipairs(pendingCrows) do
                        if crow and crow.Parent then pcall(function() aas_claimObject(crow) end) crowClaimedCount = crowClaimedCount + 1 task.wait(1) end
                    end
                    pendingCrows = {}
                end

                local ballClaimedCount = 0
                if #pendingBalls > 0 then
                    local world8Items, world12Items = {}, {}
                    for _, item in ipairs(pendingBalls) do
                        if item and item.Parent then
                            if item.Name:match("^Commandment_") then table.insert(world12Items, item)
                            else table.insert(world8Items, item) end
                        end
                    end
                    if #world8Items > 0 then
                        aas_changeWorldAndWait(8) task.wait(0.5)
                        for _, ball in ipairs(world8Items) do
                            if ball and ball.Parent then pcall(function() aas_claimObject(ball) end) ballClaimedCount = ballClaimedCount + 1 task.wait(1) end
                        end
                    end
                    if #world12Items > 0 then
                        aas_changeWorldAndWait(12) task.wait(0.5)
                        for _, cmd in ipairs(world12Items) do
                            if cmd and cmd.Parent then pcall(function() aas_claimObject(cmd) end) ballClaimedCount = ballClaimedCount + 1 task.wait(1) end
                        end
                    end
                    pendingBalls = {}
                end

                pendingCrowBallReadyAt = 0
                Window:Notify({ Title = "Euclidean", Content = "Harvest Complete - " .. tostring(crowClaimedCount) .. " crow(s), " .. tostring(ballClaimedCount) .. " ball(s)/commandment(s)", Duration = 3, Type = "Info" })
                aas_resumeFromSnapshot(snapshot)
            end
        else
            pendingCrowBallReadyAt = 0
        end

        task.wait(1)
    end
    pendingCrows = {} pendingBalls = {} pendingCrowBallReadyAt = 0
end


-- ══════════════════════════════════════════
--   AUTOMATION CONTROLS
-- ══════════════════════════════════════════

function aas_autoClick()
    task.spawn(function()
        while autoClickRunning do
            pcall(function() aas_clickRemote:Fire() end)
            task.wait(0.05)
        end
    end)
end

function aas_toggleAutoClaimAchievements(enabled) return pcall(function() aas_autoClaimAchievementsRemote:Fire(enabled) end) end
function aas_toggleAutoAvatar(enabled)             return pcall(function() aas_autoAvatarRemote:Fire(enabled) end) end
function aas_toggleAutoRank(enabled)               return pcall(function() aas_autoRankRemote:Fire("SetAutoRankUp", enabled) end) end
function aas_toggleAutoStat(statName, enabled)     return pcall(function() aas_autoStatRemote:Fire(statName, enabled) end) end
function aas_toggleAutoClaimRewards(enabled)       return pcall(function() aas_autoClaimRewardsRemote:Fire(enabled) end) end

function aas_redeemAllCodes()
    Window:Notify({ Title = "Euclidean", Content = "Redeeming " .. #aas_codes .. " codes...", Duration = 3, Type = "Info" })
    task.spawn(function()
        local successCount = 0
        for _, code in ipairs(aas_codes) do
            local ok = pcall(function() aas_redeemCodeRemote:Fire(code) end)
            if ok then successCount = successCount + 1 end
            task.wait(1)
        end
        Window:Notify({ Title = "Euclidean", Content = "Codes Processed - " .. successCount .. "/" .. #aas_codes .. " redeemed!", Duration = 3, Type = "Info" })
    end)
end

-- ══════════════════════════════════════════
--   CLEANUP SYSTEM
-- ══════════════════════════════════════════

function aas_cleanup()
    farmEnabled = false
    if farmThread then task.cancel(farmThread) farmThread = nil end

    for rk in pairs(raidEnabled) do raidEnabled[rk] = false end
    if raidThread then task.cancel(raidThread) raidThread = nil end
    if activeRaidKey and aas_raidArenaExists(activeRaidKey) then aas_leaveRaid() end
    activeRaidKey = nil

    for dk in pairs(defenseEnabled) do defenseEnabled[dk] = false end
    if defenseThread then task.cancel(defenseThread) defenseThread = nil end
    if activeDefenseKey and aas_defenseArenaExists(activeDefenseKey) then aas_leaveDefense() end
    activeDefenseKey = nil

    for dunk in pairs(dungeonEnabled) do dungeonEnabled[dunk] = false end
    for dunk, t in pairs(dungeonThreads) do task.cancel(t) dungeonThreads[dunk] = nil end
    if activeDungeonKey and aas_dungeonArenaExists(activeDungeonKey) then aas_leaveDungeon() end
    activeDungeonKey = nil

    for tk in pairs(trialEnabled) do trialEnabled[tk] = false end
    for tk, t in pairs(trialThreads) do task.cancel(t) trialThreads[tk] = nil end

    gateEnabled = false
    if gateThread then task.cancel(gateThread) gateThread = nil end

    for _, gk in ipairs(sortedGachaKeys) do
        gachaEnabled[gk] = false
        if gachaThreads[gk] then task.cancel(gachaThreads[gk]) gachaThreads[gk] = nil end
    end

    autoFuseAllEnabled = false
    if fuseAllThread then task.cancel(fuseAllThread) fuseAllThread = nil end

    autoCrowEnabled = false autoBallEnabled = false autoCommandmentEnabled = false
    if crowBallClaimThread then task.cancel(crowBallClaimThread) crowBallClaimThread = nil end
    pendingCrows = {} pendingBalls = {}

    passiveAutoEnabled = false
    if passiveThread then task.cancel(passiveThread) passiveThread = nil end

    titanAutoEnabled = false
    if titanThread then task.cancel(titanThread) titanThread = nil end

    swordPassive1Enabled = false
    if swordPassive1Thread then task.cancel(swordPassive1Thread) swordPassive1Thread = nil end
    swordPassive2Enabled = false
    if swordPassive2Thread then task.cancel(swordPassive2Thread) swordPassive2Thread = nil end

    grimoire1Enabled = false
    if grimoire1Thread then task.cancel(grimoire1Thread) grimoire1Thread = nil end
    grimoire2Enabled = false
    if grimoire2Thread then task.cancel(grimoire2Thread) grimoire2Thread = nil end

    for k in pairs(progressionEnabled) do progressionEnabled[k] = false end
    for k, t in pairs(progressionThreads) do task.cancel(t) progressionThreads[k] = nil end

    for k in pairs(rangeUpgradeEnabled) do rangeUpgradeEnabled[k] = false end
    for k, t in pairs(rangeUpgradeThreads) do task.cancel(t) rangeUpgradeThreads[k] = nil end

    for k in pairs(craftEnabled) do craftEnabled[k] = false end
    for k, t in pairs(craftThreads) do task.cancel(t) craftThreads[k] = nil end

    starEnabled = false
    if starThread then task.cancel(starThread) starThread = nil end

    autoClickRunning = false gateCooldown = false

    aas_toggleAutoClaimAchievements(false)
    aas_toggleAutoAvatar(false)
    aas_toggleAutoRank(false)
    aas_toggleAutoStat(currentStatSelection, false)
    aas_toggleAutoClaimRewards(false)

    SwordWorld0Enabled = false
    if SwordWorld0Thread then task.cancel(SwordWorld0Thread) SwordWorld0Thread = nil end
    SwordWorld8Enabled = false
    if SwordWorld8Thread then task.cancel(SwordWorld8Thread) SwordWorld8Thread = nil end

    petPassiveAutoEnabled = false
    if petPassiveThread then task.cancel(petPassiveThread) petPassiveThread = nil end

    potionContextEnabled = false potionAutoUseEnabled = false
    if potionAutoUseThread then task.cancel(potionAutoUseThread) potionAutoUseThread = nil end
    currentPotionContext = nil

    globalQuestEnabled = false
    if globalQuestThread then task.cancel(globalQuestThread) globalQuestThread = nil end
    globalQuestAutoClaimEnabled = false
    if globalQuestClaimThread then task.cancel(globalQuestClaimThread) globalQuestClaimThread = nil end

    autoRelicUpgradeEnabled = false
    if autoRelicUpgradeThread then task.cancel(autoRelicUpgradeThread) autoRelicUpgradeThread = nil end
    autoRelicAscendEnabled = false
    if autoRelicAscendThread then task.cancel(autoRelicAscendThread) autoRelicAscendThread = nil end

    autoEvolutionEnabled = false
    if autoEvolutionThread then task.cancel(autoEvolutionThread) autoEvolutionThread = nil end

    for sysKey in pairs(upgrades2Enabled2) do upgrades2Enabled2[sysKey] = false end
    for sysKey, t in pairs(upgrades2Threads2) do task.cancel(t) upgrades2Threads2[sysKey] = nil end

    promotionEnabled = false
    if promotionThread then task.cancel(promotionThread) promotionThread = nil end
    aas_promoStopBackgroundThreads()

    for rk in pairs(rushEnabled) do rushEnabled[rk] = false end
    for rk, t in pairs(rushThreads) do task.cancel(t) rushThreads[rk] = nil end
    if activeRushKey and aas_rushArenaExists(activeRushKey) then aas_leaveRush() end
    activeRushKey = nil

    for k in pairs(skillTreeEnabled) do skillTreeEnabled[k] = false end
    for k, t in pairs(skillTreeThreads) do task.cancel(t) skillTreeThreads[k] = nil end

    for k in pairs(constellationEnabled) do constellationEnabled[k] = false end
    for k, t in pairs(constellationThreads) do task.cancel(t) constellationThreads[k] = nil end


    for bossId in pairs(spawnBossEnabled) do spawnBossEnabled[bossId] = false end
    for bossId, t in pairs(spawnBossThreads) do task.cancel(t) spawnBossThreads[bossId] = nil end

    print("Euclidean Unloaded Successfully.")
end

-- ══════════════════════════════════════════
--   LIVE STATE LISTENERS
-- ══════════════════════════════════════════

task.spawn(function()
    pcall(function()
        aas_promotionStateRemote:Connect(function(payload)
            if type(payload) ~= "table" then return end
            promotionLiveState = payload
            promotionCurrentRank = tonumber(payload.PromotionRank) or 0
            promotionNextRank = payload.NextRank
            promotionCanPromote = payload.CanPromote == true
            promotionStateVersion = (promotionStateVersion or 0) + 1
            aas_updatePromotionUi()
        end)
    end)
    pcall(function()
        aas_promotionPromoteResultRemote:Connect(function(success, errCode)
            local msg = success and "Promoted successfully!" or (errCode == "missions_incomplete" and "Complete all missions first." or errCode == "max_rank" and "Already at max promotion." or "Could not promote.")
            Window:Notify({ Title = "Euclidean", Content = "Promotion - "..msg, Duration = 3, Type = "Info" })
            task.wait(0.2) pcall(function() aas_promotionStateRequestRemote:Fire() end)
        end)
    end)
end)

task.spawn(function()
    pcall(function()
        aas_spawnBossStateRemote:Connect(function(payload)
            if type(payload) == "table" then
                spawnBossActiveState = payload
            end
        end)
    end)
    pcall(function() aas_spawnBossStateRequestRemote:Fire() end)
end)

--   MAIN TAB (SOLID COLORS)
-- ══════════════════════════════════════════

do
    local MainLeft = Tabs.Automation:AddLeftGroupbox({ Name = "Main Automation", Icon = "zap" })

    MainLeft:CreateToggle({ Name = "Auto Click", Flag = "AutoClick", CurrentValue = false, Callback = function(value)
            autoClickRunning = value
            if value then aas_autoClick() Window:Notify({ Title = "Euclidean", Content = "Auto Click - Started!", Duration = 3, Type = "Info" }) end
        end })
    MainLeft:CreateToggle({ Name = "Auto Claim Achievements", Flag = "AutoClaimAchievements", CurrentValue = false, Callback = function(value)
            aas_toggleAutoClaimAchievements(value)
            Window:Notify({ Title = "Euclidean", Content = "Auto Claim Achievements - "..(value and "Enabled!" or "Disabled"), Duration = 3, Type = "Info" })
        end })
    MainLeft:CreateToggle({ Name = "Auto Equip Best Avatar", Flag = "AutoAvatar", CurrentValue = false, Callback = function(value)
            aas_toggleAutoAvatar(value)
            Window:Notify({ Title = "Euclidean", Content = "Auto Equip Avatar - "..(value and "Enabled!" or "Disabled"), Duration = 3, Type = "Info" })
        end })
    MainLeft:CreateToggle({ Name = "Auto Rank Up", Flag = "AutoRank", CurrentValue = false, Callback = function(value)
            aas_toggleAutoRank(value)
            Window:Notify({ Title = "Euclidean", Content = "Auto Rank Up - "..(value and "Enabled!" or "Disabled"), Duration = 3, Type = "Info" })
        end })
    MainLeft:CreateToggle({ Name = "Auto Claim Time Rewards", Flag = "AutoClaimRewards", CurrentValue = false, Callback = function(value)
            aas_toggleAutoClaimRewards(value)
            Window:Notify({ Title = "Euclidean", Content = "Auto Claim Rewards - "..(value and "Enabled!" or "Disabled"), Duration = 3, Type = "Info" })
        end })
    MainLeft:CreateDivider()
    MainLeft:CreateDropdown({ Name = "Select Stat to Auto Upgrade", Options = { "Power", "Yen", "Damage", "Luck", "Xp", "Drop" }, CurrentOption = 1, Flag = "StatSelection", Callback = function(value)
            currentStatSelection = value
            if autoStatEnabled then aas_toggleAutoStat(value, true) end
        end })
    MainLeft:CreateToggle({ Name = "Enable Auto Stat", Flag = "AutoStat", CurrentValue = false, Callback = function(value)
            autoStatEnabled = value
            aas_toggleAutoStat(currentStatSelection, value)
            Window:Notify({ Title = "Euclidean", Content = "Auto Stat - "..(value and ("Enabled for "..currentStatSelection) or "Disabled"), Duration = 3, Type = "Info" })
        end })

    local MainRight = Tabs.Automation:AddRightGroupbox({ Name = "Utilities", Icon = "wrench" })

    MainRight:CreateButton({ Name = "Redeem All Codes", Callback = aas_redeemAllCodes })

    local CrowGroup = Tabs.Harvest:AddLeftGroupbox({ Name = "Auto Crow / Ball / Commandment", Icon = "feather" })
    CrowGroup:CreateLabel("Items are claimed AFTER Trial/Gate/Dungeon finishes.")
    CrowGroup:CreateDivider()
    CrowGroup:CreateToggle({ Name = "Auto Crow - World 6", Flag = "AutoCrow", CurrentValue = false, Callback = function(value)
            autoCrowEnabled = value
            if value then
                if not crowBallClaimThread then crowBallClaimThread = task.spawn(aas_crowBallClaimProcessor) end
                Window:Notify({ Title = "Euclidean", Content = "Auto Crow - Enabled!", Duration = 3, Type = "Info" })
            else
                if not autoBallEnabled and not autoCommandmentEnabled then
                    if crowBallClaimThread then task.cancel(crowBallClaimThread) crowBallClaimThread = nil end
                end
                pendingCrows = {}
            end
        end })
    CrowGroup:CreateToggle({ Name = "Auto Ball - World 8", Flag = "AutoBall", CurrentValue = false, Callback = function(value)
            autoBallEnabled = value
            if value then
                if not crowBallClaimThread then crowBallClaimThread = task.spawn(aas_crowBallClaimProcessor) end
                Window:Notify({ Title = "Euclidean", Content = "Auto Ball - Enabled!", Duration = 3, Type = "Info" })
            else
                if not autoCrowEnabled and not autoCommandmentEnabled then
                    if crowBallClaimThread then task.cancel(crowBallClaimThread) crowBallClaimThread = nil end
                end
                pendingBalls = {}
            end
        end })
    CrowGroup:CreateToggle({ Name = "Auto Commandment - World 12", Flag = "AutoCommandment", CurrentValue = false, Callback = function(value)
            autoCommandmentEnabled = value
            if value then
                if not crowBallClaimThread then crowBallClaimThread = task.spawn(aas_crowBallClaimProcessor) end
                Window:Notify({ Title = "Euclidean", Content = "Auto Commandment - Enabled!", Duration = 3, Type = "Info" })
            else
                if not autoCrowEnabled and not autoBallEnabled then
                    if crowBallClaimThread then task.cancel(crowBallClaimThread) crowBallClaimThread = nil end
                end
                local filtered = {}
                for _, item in ipairs(pendingBalls) do
                    if not (item and item.Name and item.Name:match("^Commandment_")) then
                        table.insert(filtered, item)
                    end
                end
                pendingBalls = filtered
            end
        end })


end

-- ══════════════════════════════════════════
--   FARM SUBTAB
-- ══════════════════════════════════════════

do
    local FarmControl = Tabs.MobFarm:AddLeftGroupbox({ Name = "Farm Control", Icon = "zap" })
    FarmControl:CreateToggle({ Name = "Enable Auto Farm", Flag = "AutoFarmEnabled", CurrentValue = false, Callback = function(value)
            if value and (aas_anyRaidActive() or aas_anyDefenseActive()) then
                Toggles.AutoFarmEnabled:SetValue(false)
                Window:Notify({ Title = "Euclidean", Content = "Blocked - Disable active Raid/Defense first.", Duration = 3, Type = "Info" })
                return
            end
            farmEnabled = value
            if value then
                aas_equipLoadout(LoadoutAssignments.Farm or "Power")
                aas_enterPotionContext("Farm")
                if farmThread then task.cancel(farmThread) end
                farmThread = task.spawn(aas_farmLoop)
                Window:Notify({ Title = "Euclidean", Content = "Auto Farm - Started!", Duration = 3, Type = "Info" })
            else
                if farmThread then task.cancel(farmThread) farmThread = nil end
                currentWorldTracked = nil
            end
        end })
    FarmControl:CreateToggle({ Name = "Optimized Farm (HIGH RANGE)", Flag = "ClusterFarmEnabled", CurrentValue = false, Callback = function(value)
            clusterFarmEnabled = value
            if value then Window:Notify({ Title = "Euclidean", Content = "Optimized Farm - Enabled! Requires HIGH RANGE.", Duration = 3, Type = "Info" }) end
        end })

    for i, worldIdx in ipairs(sortedWorldIndices) do
        aas_buildTick()
        local worldData = WorldList[worldIdx]
        local dropKey = "FarmWorld_"..worldIdx
        worldDropdowns[worldIdx] = dropKey
        -- Live folder first (ground truth for what spawns), config fills gaps.
        -- Ghost denylist: config entries that never spawn anywhere (verified live).
        local ghostDeny = { Aldedo = true, Aurab = true, Enoma = true, Mareb = true, Urge = true }
        local nameSet = {}
        pcall(function()
            local wf = workspace:FindFirstChild("Worlds")
            local folder = wf and wf:FindFirstChild(tostring(worldIdx))
            local ef = folder and folder:FindFirstChild("Enemies")
            if ef then
                for _, m in ipairs(ef:GetChildren()) do
                    if m.Name ~= '' then nameSet[m.Name] = true end
                end
            end
        end)
        for _, e in ipairs(worldData.enemies) do
            if not ghostDeny[e.Name] then nameSet[e.Name] = true end
        end
        local enemyNames = {}
        for name in pairs(nameSet) do table.insert(enemyNames, name) end
        table.sort(enemyNames)

        local WorldGroup
        if i % 2 == 1 then WorldGroup = Tabs.MobFarm:AddRightGroupbox(aas_getWorldLabel(worldIdx).." - World "..worldIdx, "map-pin")
        else WorldGroup = Tabs.MobFarm:AddLeftGroupbox(aas_getWorldLabel(worldIdx).." - World "..worldIdx, "map-pin") end

        local capturedIdx = worldIdx
        WorldGroup:CreateButton({ Name = "Teleport to "..aas_getWorldLabel(worldIdx), Callback = function() aas_teleportToWorld(capturedIdx) Window:Notify({ Title = "Euclidean", Content = "Teleporting to "..aas_getWorldLabel(capturedIdx), Duration = 3, Type = "Info" }) end })
        if #enemyNames <= 1 then WorldGroup:CreateLabel("No enemies found.")
        else
            WorldGroup:CreateDropdown({ Name = "Select Mobs", Options = enemyNames, MultipleOptions = true, Flag = dropKey, Callback = function(_) end })
        end
    end
end

--   RAIDS SUBTAB (TABBOX)
-- ══════════════════════════════════════════

do
    for _, raidKey in ipairs(sortedRaidKeys) do raidEnabled[raidKey] = false RaidLoadouts[raidKey] = "Power" end
    for _, defKey in ipairs(sortedDefenseKeys) do defenseEnabled[defKey] = false DefenseLoadouts[defKey] = "Power" end

    local maxRaidWave, maxDefWave = 50, 50
    for _, k in ipairs(sortedRaidKeys) do maxRaidWave = math.max(maxRaidWave, (RaidList[k] or {}).TotalWaves or 0) end
    for _, k in ipairs(sortedDefenseKeys) do maxDefWave = math.max(maxDefWave, (DefenseList[k] or {}).TotalWaves or 0) end


    local RaidTab = Tabs.Raids:AddRightGroupbox({ Name = "Raid", Icon = "zap" })
    local raidDisplay, raidToKey = {}, {}
    for _, k in ipairs(sortedRaidKeys) do
        aas_buildTick()
        local rd = RaidList[k]
        local disp = rd.Name.." ("..aas_getWorldLabel(rd.WorldId or 0)..")"
        table.insert(raidDisplay, disp) raidToKey[disp] = k
    end
    RaidTab:CreateDropdown({ Name = "Raid", Options = raidDisplay, Flag = "RaidSelect", Callback = function(_) end })
    RaidTab:CreateToggle({ Name = "Optimized (HIGH RANGE)", Flag = "RaidOptimizedFarm", CurrentValue = false, Callback = function(value)
            raidOptimizedFarm = value
            if value then Window:Notify({ Title = "Euclidean", Content = "Raid Optimized Farm - Enabled! Requires HIGH RANGE.", Duration = 3, Type = "Info" }) end
        end })
    RaidTab:CreateSlider({ Name = "Leave At Wave", Flag = "RaidLeaveWave", Range = { 0, maxRaidWave }, Increment = 10 ^ -0, CurrentValue = 0 })
    RaidTab:CreateToggle({ Name = "Enable Auto Raid", Flag = "AutoRaid", CurrentValue = false, Callback = function(value)
            if value then
                local disp = Options["RaidSelect"] and Options["RaidSelect"].Value or nil
                local rk = disp and raidToKey[disp] or nil
                if not rk then Toggles["AutoRaid"]:SetValue(false) Window:Notify({ Title = "Euclidean", Content = "Auto Raid - Select a raid first!", Duration = 3, Type = "Info" }) return end
                if farmEnabled or aas_anyDefenseActive() then Toggles["AutoRaid"]:SetValue(false) Window:Notify({ Title = "Euclidean", Content = "Blocked - Disable Farm/Defense first.", Duration = 3, Type = "Info" }) return end
                if activeRaidKey and activeRaidKey ~= rk then Toggles["AutoRaid"]:SetValue(false) Window:Notify({ Title = "Euclidean", Content = "Blocked - Disable "..((RaidList[activeRaidKey] or {}).Name or "?").." first.", Duration = 3, Type = "Info" }) return end
                aas_equipLoadout(RaidLoadouts[rk] or "Power")
                aas_enterPotionContext("Raid_"..rk)
                raidEnabled[rk] = true activeRaidKey = rk
                if raidThread then task.cancel(raidThread) raidThread = nil end
                raidThread = task.spawn(function() aas_raidLoop(rk) end)
                Window:Notify({ Title = "Euclidean", Content = "Auto Raid - Started!", Duration = 3, Type = "Info" })
            else
                raidEnabled[rk] = false
                if activeRaidKey == rk then activeRaidKey = nil end
                if raidThread then task.cancel(raidThread) raidThread = nil end
            end
        end })

    local DefTab = Tabs.Raids:AddLeftGroupbox({ Name = "Defense", Icon = "shield" })
    local defDisplay, defToKey = {}, {}
    for _, k in ipairs(sortedDefenseKeys) do
        aas_buildTick()
        local dd = DefenseList[k]
        local disp = dd.Name.." ("..aas_getWorldLabel(dd.WorldId or 0)..")"
        table.insert(defDisplay, disp) defToKey[disp] = k
    end
    DefTab:CreateDropdown({ Name = "Defense", Options = defDisplay, Flag = "DefSelect", Callback = function(_) end })
    DefTab:CreateSlider({ Name = "Leave At Wave", Flag = "DefLeaveWave", Range = { 0, maxDefWave }, Increment = 10 ^ -0, CurrentValue = 0 })
    DefTab:CreateToggle({ Name = "Enable Auto Defense", Flag = "AutoDefense", CurrentValue = false, Callback = function(value)
            if value then
                local disp = Options["DefSelect"] and Options["DefSelect"].Value or nil
                local dk = disp and defToKey[disp] or nil
                if not dk then Toggles["AutoDefense"]:SetValue(false) Window:Notify({ Title = "Euclidean", Content = "Auto Defense - Select a defense first!", Duration = 3, Type = "Info" }) return end
                if farmEnabled or aas_anyRaidActive() then Toggles["AutoDefense"]:SetValue(false) Window:Notify({ Title = "Euclidean", Content = "Blocked - Disable Farm/Raid first.", Duration = 3, Type = "Info" }) return end
                if activeDefenseKey and activeDefenseKey ~= dk then Toggles["AutoDefense"]:SetValue(false) Window:Notify({ Title = "Euclidean", Content = "Blocked - Disable "..((DefenseList[activeDefenseKey] or {}).Name or "?").." first.", Duration = 3, Type = "Info" }) return end
                aas_equipLoadout(DefenseLoadouts[dk] or "Power")
                aas_enterPotionContext("Defense_"..dk)
                defenseEnabled[dk] = true activeDefenseKey = dk
                if defenseThread then task.cancel(defenseThread) defenseThread = nil end
                defenseThread = task.spawn(function() aas_defenseLoop(dk) end)
                Window:Notify({ Title = "Euclidean", Content = "Auto Defense - Started!", Duration = 3, Type = "Info" })
            else
                defenseEnabled[dk] = false
                if activeDefenseKey == dk then activeDefenseKey = nil end
                if defenseThread then task.cancel(defenseThread) defenseThread = nil end
            end
        end })
end

-- ══════════════════════════════════════════
--   DUNGEONS SUBTAB (TABBOX)
-- ══════════════════════════════════════════

do

    local DunTab = Tabs.Dungeons:AddRightGroupbox({ Name = "Dungeon", Icon = "door-open" })
    if #sortedDungeonKeys == 0 then
        DunTab:CreateLabel("No dungeon data found.")
    else
        for _, dungeonKey in ipairs(sortedDungeonKeys) do
            aas_buildTick()
            local dungeonData = DungeonList[dungeonKey]
            local toggleKey = "AutoDungeon_"..dungeonKey
            local roomOptKey = "DungeonLeaveRoom_"..dungeonKey
            dungeonEnabled[dungeonKey] = false
            DungeonLoadouts[dungeonKey] = "Power"

            local worldLabel = aas_getWorldLabel(dungeonData.WorldId or 0)
            DunTab:CreateLabel(dungeonData.Name.." ("..worldLabel..")")
            local roomValues = { "0 (Never Leave)" }
            for r = 1, dungeonData.TotalRooms do table.insert(roomValues, tostring(r)) end
            DunTab:CreateDropdown({ Name = "Leave at Room", Options = roomValues, CurrentOption = 1, Flag = roomOptKey, Callback = function(_) end })
            DunTab:CreateToggle({ Name = "Enable "..dungeonData.Name, Flag = toggleKey, CurrentValue = false, Callback = function(value)
                    dungeonEnabled[dungeonKey] = value
                    if value then
                        if dungeonThreads[dungeonKey] then task.cancel(dungeonThreads[dungeonKey]) end
                        dungeonThreads[dungeonKey] = task.spawn(function() aas_dungeonLoop(dungeonKey) end)
                        Window:Notify({ Title = "Euclidean", Content = dungeonData.Name.." - Waiting for dungeon to spawn...", Duration = 3, Type = "Info" })
                    else
                        if dungeonThreads[dungeonKey] then task.cancel(dungeonThreads[dungeonKey]) dungeonThreads[dungeonKey] = nil end
                        if activeDungeonKey == dungeonKey then
                            if aas_dungeonArenaExists(dungeonKey) then aas_leaveDungeon() end
                            activeDungeonKey = nil
                        end
                    end
                end })
            DunTab:CreateDivider()
        end
    end

    local TriTab = Tabs.Dungeons:AddLeftGroupbox({ Name = "Trial", Icon = "clock" })
    for _, trialKey in ipairs(sortedTrialKeys) do
        aas_buildTick()
        local trialData = TrialList[trialKey]
        local toggleKey = "AutoTrial_"..trialKey
        local roomOptKey = "TrialLeaveRoom_"..trialKey
        trialEnabled[trialKey] = false TrialLoadouts[trialKey] = "Power"

        TriTab:CreateLabel(trialData.Name)
        local roomValues = { "0 (Never Leave)" }
        for r = 1, trialData.TotalRooms do table.insert(roomValues, tostring(r)) end
        TriTab:CreateDropdown({ Name = "Leave at Room", Options = roomValues, CurrentOption = 1, Flag = roomOptKey, Callback = function(_) end })
        TriTab:CreateToggle({ Name = "Enable "..trialData.Name, Flag = toggleKey, CurrentValue = false, Callback = function(value)
                trialEnabled[trialKey] = value
                if value then
                    if trialThreads[trialKey] then task.cancel(trialThreads[trialKey]) end
                    trialThreads[trialKey] = task.spawn(function() aas_trialLoop(trialKey) end)
                    Window:Notify({ Title = "Euclidean", Content = trialData.Name.." - Waiting for trial to spawn...", Duration = 3, Type = "Info" })
                else
                    if trialThreads[trialKey] then task.cancel(trialThreads[trialKey]) trialThreads[trialKey] = nil end
                end
            end })
        TriTab:CreateDivider()
    end
end

-- ══════════════════════════════════════════
--   BOSSES SUBTAB
-- ══════════════════════════════════════════

do
    for _, rushKey in ipairs(sortedRushKeys) do rushEnabled[rushKey] = false RushLoadouts[rushKey] = "Power" end
    for _, bossId in ipairs(sortedSpawnBossKeys) do spawnBossEnabled[bossId] = false end

    local RushBox = Tabs.Bosses:AddLeftGroupbox({ Name = "Boss Rush", Icon = "skull" })
    local rushDisplay, rushToKey, modeUnion, modeSeen = {}, {}, {}, {}
    for _, k in ipairs(sortedRushKeys) do
        aas_buildTick()
        local rd = RushList[k]
        local disp = rd.Name.." ("..aas_getWorldLabel(rd.WorldId or 11)..")"
        table.insert(rushDisplay, disp) rushToKey[disp] = k
        for _, m in ipairs(rd.Modes or {}) do
            if not modeSeen[m] then modeSeen[m] = true table.insert(modeUnion, m) end
        end
    end
    table.sort(modeUnion)
    if #modeUnion == 0 then modeUnion = { "V1" } end
    RushBox:CreateDropdown({ Name = "Boss Rush", Options = rushDisplay, Flag = "RushSelect", Callback = function(val)
            local rk = val and rushToKey[val] or nil
            if rk and Options["RushMode"] then
                local modes = (RushList[rk] or {}).Modes or {}
                if #modes > 0 then pcall(function() Options["RushMode"]:SetValues(modes) Options["RushMode"]:SetValue(modes[1]) end) end
            end
        end })
    RushBox:CreateDropdown({ Name = "Mode", Options = modeUnion, CurrentOption = 1, Flag = "RushMode", Callback = function(_) end })
    RushBox:CreateInput({ Name = "Leave at Wave", CurrentValue = "0", PlaceholderText = "0 - 9999", Numeric = true, Flag = "RushLeaveWave", Callback = function(Value)
            local n = tonumber(Value)
            if not n then Options["RushLeaveWave"]:SetValue("0") return end
            Options["RushLeaveWave"]:SetValue(tostring(math.clamp(math.floor(n), 0, 9999)))
        end })
    RushBox:CreateToggle({ Name = "Enable Auto Boss Rush", Flag = "AutoRush", CurrentValue = false, Callback = function(value)
            if value then
                local disp = Options["RushSelect"] and Options["RushSelect"].Value or nil
                local rk = disp and rushToKey[disp] or nil
                if not rk then Toggles["AutoRush"]:SetValue(false) Window:Notify({ Title = "Euclidean", Content = "Auto Boss Rush - Select a rush first!", Duration = 3, Type = "Info" }) return end
                if farmEnabled then Toggles["AutoRush"]:SetValue(false) Window:Notify({ Title = "Euclidean", Content = "Blocked - Disable Auto Farm first.", Duration = 3, Type = "Info" }) return end
                if activeRushKey and activeRushKey ~= rk then Toggles["AutoRush"]:SetValue(false) Window:Notify({ Title = "Euclidean", Content = "Blocked - Another Boss Rush is active.", Duration = 3, Type = "Info" }) return end
                aas_equipLoadout(RushLoadouts[rk] or "Power")
                aas_enterPotionContext("Rush_"..rk)
                rushEnabled[rk] = true activeRushKey = rk
                if rushThreads[rk] then task.cancel(rushThreads[rk]) end
                rushThreads[rk] = task.spawn(function() aas_rushLoop(rk) end)
                Window:Notify({ Title = "Euclidean", Content = "Auto Boss Rush - Started!", Duration = 3, Type = "Info" })
            else
                rushEnabled[rk] = false
                if activeRushKey == rk then activeRushKey = nil end
                if rushThreads[rk] then task.cancel(rushThreads[rk]) rushThreads[rk] = nil end
            end
        end })

    local GateBox = Tabs.Bosses:AddRightGroupbox({ Name = "Gate", Icon = "shield" })
    if GateData then
        GateBox:CreateDropdown({ Name = "Select Gate Ranks to Farm", Options = GateRanks, MultipleOptions = true, Flag = "GateRankSelect", Callback = function(_) end })
        for _, rank in ipairs(GateRanks) do
            aas_buildTick()
            local waveValues = { "0 (Never Leave)" }
            for w = 1, (GateData.TotalWaves or 50) do table.insert(waveValues, tostring(w)) end
            GateBox:CreateDropdown({ Name = "Leave at Wave (Rank "..rank..")", Options = waveValues, CurrentOption = 1, Flag = "GateLeaveWave_"..rank, Callback = function(_) end })
        end
        GateBox:CreateDivider()
        GateBox:CreateToggle({ Name = "Optimized Middle Farm (HIGH RANGE)", Flag = "GateOptimizedFarm", CurrentValue = false, Callback = function(value)
                gateOptimizedFarm = value
                if value then Window:Notify({ Title = "Euclidean", Content = "Gate Optimized Farm - Enabled! Requires HIGH RANGE.", Duration = 3, Type = "Info" }) end
            end })
        GateBox:CreateDivider()
        GateBox:CreateToggle({ Name = "Enable Auto Gate", Flag = "AutoGateEnabled", CurrentValue = false, Callback = function(value)
                gateEnabled = value
                if value then
                    if gateThread then task.cancel(gateThread) gateThread = nil end
                    gateThread = task.spawn(aas_gateLoop)
                    Window:Notify({ Title = "Euclidean", Content = "Auto Gate - Monitoring World 5...", Duration = 3, Type = "Info" })
                else
                    if gateThread then task.cancel(gateThread) gateThread = nil end
                    gateSuppressedByPriority = false
                end
            end })
    else GateBox:CreateLabel("No gate data found.") end

    local BossBox = Tabs.Bosses:AddRightGroupbox({ Name = "Spawn Boss", Icon = "crown" })
    local bossDisplay, bossToKey = {}, {}
    for _, bossId in ipairs(sortedSpawnBossKeys) do
        aas_buildTick()
        local bd = SpawnBossList[bossId]
        local disp = bd.Name.." ("..aas_getWorldLabel(bd.WorldId)..")"
        table.insert(bossDisplay, disp) bossToKey[disp] = bossId
    end
    BossBox:CreateDropdown({ Name = "Boss", Options = bossDisplay, Flag = "SpawnBossSelect", Callback = function(_) end })
    BossBox:CreateToggle({ Name = "Enable Auto Spawn Boss", Flag = "AutoSpawnBoss", CurrentValue = false, Callback = function(value)
            if value then
                local disp = Options["SpawnBossSelect"] and Options["SpawnBossSelect"].Value or nil
                local bossId = disp and bossToKey[disp] or nil
                if not bossId then Toggles["AutoSpawnBoss"]:SetValue(false) Window:Notify({ Title = "Euclidean", Content = "Auto Spawn Boss - Select a boss first!", Duration = 3, Type = "Info" }) return end
                if farmEnabled or aas_anyRaidActive() or aas_anyDefenseActive() or aas_anyRushActive() then
                    Toggles["AutoSpawnBoss"]:SetValue(false)
                    Window:Notify({ Title = "Euclidean", Content = "Blocked - Disable Farm/Raid/Defense/Rush first.", Duration = 3, Type = "Info" })
                    return
                end
                spawnBossEnabled[bossId] = true
                aas_equipLoadout(LoadoutAssignments.Farm or "Power")
                aas_enterPotionContext("Farm")
                if spawnBossThreads[bossId] then task.cancel(spawnBossThreads[bossId]) end
                spawnBossThreads[bossId] = task.spawn(function() aas_spawnBossLoop(bossId) end)
                Window:Notify({ Title = "Euclidean", Content = "Auto Spawn Boss - Started!", Duration = 3, Type = "Info" })
            else
                spawnBossEnabled[bossId] = false
                if spawnBossThreads[bossId] then
                    task.cancel(spawnBossThreads[bossId])
                    spawnBossThreads[bossId] = nil
                end
            end
        end })
end

-- ══════════════════════════════════════════
--   SETUP SUBTAB (TABBOXES)
-- ══════════════════════════════════════════

do
    local PriorityBox = Tabs.Setup:AddLeftGroupbox({ Name = "Priority", Icon = "triangle-alert" })
    PriorityBox:CreateDropdown({ Name = "Priority #1 (Highest)", Options = {"Trial","Gate","Dungeon"}, CurrentOption = 1, Flag = "PrioritySlot1", Callback = function(val) priorityOrder[1]=val end })
    PriorityBox:CreateDropdown({ Name = "Priority #2 (Medium)", Options = {"Trial","Gate","Dungeon"}, CurrentOption = 2, Flag = "PrioritySlot2", Callback = function(val) priorityOrder[2]=val end })
    PriorityBox:CreateDropdown({ Name = "Priority #3 (Lowest)", Options = {"Trial","Gate","Dungeon"}, CurrentOption = 3, Flag = "PrioritySlot3", Callback = function(val) priorityOrder[3]=val end })



    local FarmTab = Tabs.Setup:AddLeftGroupbox({ Name = "Farm", Icon = "sprout" })
    FarmTab:CreateDropdown({ Name = "Farm Loadout", Options = {"Power","Yen","Damage","XP","Drop","Luck"}, CurrentOption = 1, Flag = "LoadoutFarm", Callback = function(v) LoadoutAssignments.Farm=v end })

    local GateTab = Tabs.Setup:AddLeftGroupbox({ Name = "Gate", Icon = "shield" })
    for _, rank in ipairs(GateRanks) do
        aas_buildTick()
        GateTab:CreateDropdown({ Name = "Rank "..rank, Options = {"Power","Yen","Damage","XP","Drop","Luck"}, CurrentOption = 1, Flag = "LoadoutGateRank_"..rank, Callback = function(_) end })
    end



    local RaidLTab = Tabs.Setup:AddLeftGroupbox({ Name = "Raid", Icon = "zap" })
    for _, raidKey in ipairs(sortedRaidKeys) do
        aas_buildTick()
        local raidData = RaidList[raidKey]
        RaidLoadouts[raidKey] = "Power"
        RaidLTab:CreateDropdown({ Name = raidData.Name, Options = {"Power","Yen","Damage","XP","Drop","Luck"}, CurrentOption = 1, Flag = "LoadoutRaid_"..raidKey, Callback = function(v) RaidLoadouts[raidKey]=v end })
    end

    local DefLTab = Tabs.Setup:AddLeftGroupbox({ Name = "Defense", Icon = "shield" })
    for _, defKey in ipairs(sortedDefenseKeys) do
        aas_buildTick()
        local defData = DefenseList[defKey]
        DefenseLoadouts[defKey] = "Power"
        DefLTab:CreateDropdown({ Name = defData.Name, Options = {"Power","Yen","Damage","XP","Drop","Luck"}, CurrentOption = 1, Flag = "LoadoutDef_"..defKey, Callback = function(v) DefenseLoadouts[defKey]=v end })
    end


    local TrialLTab = Tabs.Setup:AddLeftGroupbox({ Name = "Trial", Icon = "clock" })
    for _, trialKey in ipairs(sortedTrialKeys) do
        aas_buildTick()
        local trialData = TrialList[trialKey]
        TrialLoadouts[trialKey] = "Power"
        TrialLTab:CreateDropdown({ Name = trialData.Name, Options = {"Power","Yen","Damage","XP","Drop","Luck"}, CurrentOption = 1, Flag = "LoadoutTrial_"..trialKey, Callback = function(v) TrialLoadouts[trialKey]=v end })
    end

    local DunLTab = Tabs.Setup:AddLeftGroupbox({ Name = "Dungeon & Rush", Icon = "door-open" })
    for _, dungeonKey in ipairs(sortedDungeonKeys) do
        aas_buildTick()
        local dungeonData = DungeonList[dungeonKey]
        DungeonLoadouts[dungeonKey] = "Power"
        DunLTab:CreateDropdown({ Name = dungeonData.Name, Options = {"Power","Yen","Damage","XP","Drop","Luck"}, CurrentOption = 1, Flag = "LoadoutDungeon_"..dungeonKey, Callback = function(v) DungeonLoadouts[dungeonKey]=v end })
    end
    for _, rushKey in ipairs(sortedRushKeys) do
        aas_buildTick()
        local rushData = RushList[rushKey]
        RushLoadouts[rushKey] = "Power"
        DunLTab:CreateDropdown({ Name = rushData.Name, Options = {"Power","Yen","Damage","XP","Drop","Luck"}, CurrentOption = 1, Flag = "LoadoutRush_"..rushKey, Callback = function(v) RushLoadouts[rushKey]=v end })
    end

    local PotionBox = Tabs.Setup:AddRightGroupbox({ Name = "Potions", Icon = "flask-conical" })
    local potionStatusObj = PotionBox:CreateLabel("Context: Idle")
    potionStatusLabelRef = Options["PotionStatusLabel"] or potionStatusObj
    PotionBox:CreateToggle({ Name = "Enable Potion Context", Flag = "PotionContextEnabled", CurrentValue = false, Callback = function(value)
            potionContextEnabled = value
            Window:Notify({ Title = "Euclidean", Content = "Potion Context - "..(value and "Enabled!" or "Disabled"), Duration = 3, Type = "Info" })
        end })
    PotionBox:CreateDropdown({ Name = "Select Potions to Auto Use", Options = aas_sortedPotionKeys, MultipleOptions = true, Flag = "PotionAutoUseSelect", Callback = function(_) end })
    PotionBox:CreateToggle({ Name = "Auto Use Potion (every 30s)", Flag = "PotionAutoUseEnabled", CurrentValue = false, Callback = function(value)
            potionAutoUseEnabled = value
            if value then
                if potionAutoUseThread then task.cancel(potionAutoUseThread) end
                potionAutoUseThread = task.spawn(aas_autoUsePotionLoop)
                Window:Notify({ Title = "Euclidean", Content = "Auto Use Potion - Started!", Duration = 3, Type = "Info" })
            else
                if potionAutoUseThread then task.cancel(potionAutoUseThread) potionAutoUseThread = nil end
            end
        end })


    local function aas_ctxTabDropdown(tab, contextKey, label)
        if #aas_sortedPotionKeys == 0 then return end
        tab:CreateDropdown({ Name = label, Options = aas_sortedPotionKeys, MultipleOptions = true, Flag = "PotionCtx_"..contextKey, Callback = function(_) end })
    end

    local PotFarmTab = Tabs.Setup:AddRightGroupbox({ Name = "Farm", Icon = "sprout" })
    aas_ctxTabDropdown(PotFarmTab, "Farm", "Farm Potions")
    for _, rank in ipairs(GateRanks) do aas_buildTick() aas_ctxTabDropdown(PotFarmTab, "Gate_"..rank, "Gate Rank "..rank) end


    local PotRaidTab = Tabs.Setup:AddRightGroupbox({ Name = "Raids", Icon = "zap" })
    for _, raidKey in ipairs(sortedRaidKeys) do aas_buildTick() aas_ctxTabDropdown(PotRaidTab, "Raid_"..raidKey, RaidList[raidKey].Name) end

    local PotOtherTab = Tabs.Setup:AddRightGroupbox({ Name = "Other", Icon = "layers" })
    for _, defKey in ipairs(sortedDefenseKeys) do aas_buildTick() aas_ctxTabDropdown(PotOtherTab, "Defense_"..defKey, DefenseList[defKey].Name) end
    for _, trialKey in ipairs(sortedTrialKeys) do aas_buildTick() aas_ctxTabDropdown(PotOtherTab, "Trial_"..trialKey, TrialList[trialKey].Name) end
    for _, dungeonKey in ipairs(sortedDungeonKeys) do aas_buildTick() aas_ctxTabDropdown(PotOtherTab, "Dungeon_"..dungeonKey, DungeonList[dungeonKey].Name) end
    for _, rushKey in ipairs(sortedRushKeys) do aas_buildTick() aas_ctxTabDropdown(PotOtherTab, "Rush_"..rushKey, RushList[rushKey].Name) end
end

-- ══════════════════════════════════════════
--   GACHA SUBTAB
-- ══════════════════════════════════════════

do
    task.spawn(function() task.wait(2) pcall(aas_syncAllPlayerData) end)

    local GachaBox = Tabs.GachaTab:AddLeftGroupbox({ Name = "Gachas", Icon = "sparkles" })
    for _, gachaKey in ipairs(sortedGachaKeys) do
        aas_buildTick()
        local gachaData = GachaList[gachaKey]
        local toggleKey = "AutoGacha_"..gachaKey
        gachaEnabled[gachaKey] = false
        local worldLabel = aas_getWorldLabel(gachaData.WorldId)
        GachaBox:CreateLabel(gachaData.Name.." ("..worldLabel..")")
        local rarityLabelObj = GachaBox:CreateLabel("Current: Unknown")
        gachaLabelRefs[gachaKey] = Options["GachaRarityLabel_"..gachaKey] or rarityLabelObj
        GachaBox:CreateToggle({ Name = "Enable Auto Roll", Flag = toggleKey, CurrentValue = false, Callback = function(value)
                gachaEnabled[gachaKey] = value
                if value then
                    if gachaThreads[gachaKey] then task.cancel(gachaThreads[gachaKey]) end
                    gachaThreads[gachaKey] = task.spawn(function() aas_gachaLoop(gachaKey) end)
                    Window:Notify({ Title = "Euclidean", Content = gachaData.Name.." - Auto Gacha started!", Duration = 3, Type = "Info" })
                else
                    if gachaThreads[gachaKey] then task.cancel(gachaThreads[gachaKey]) gachaThreads[gachaKey] = nil end
                end
            end })
        GachaBox:CreateDivider()
    end
end

-- ══════════════════════════════════════════
--   SWORDS SUBTAB (TABBOXES)
-- ══════════════════════════════════════════

do
    local SwordBox = Tabs.Swords:AddLeftGroupbox({ Name = "Swords", Icon = "sword" })
    SwordBox:CreateToggle({ Name = "Auto Fuse All Swords", Flag = "AutoFuseAll", CurrentValue = false, Callback = function(value)
            autoFuseAllEnabled = value
            if value then if fuseAllThread then task.cancel(fuseAllThread) end fuseAllThread = task.spawn(aas_fuseAllLoop) Window:Notify({ Title = "Euclidean", Content = "Auto Fuse All - Enabled!", Duration = 3, Type = "Info" })
            else if fuseAllThread then task.cancel(fuseAllThread) fuseAllThread = nil end end
        end })
    SwordBox:CreateToggle({ Name = "Auto Roll Sword (World0)", Flag = "AutoSword_World0", CurrentValue = false, Callback = function(value)
            SwordWorld0Enabled = value
            if value then if SwordWorld0Thread then task.cancel(SwordWorld0Thread) end SwordWorld0Thread = task.spawn(aas_swordWorld0Loop)
            else if SwordWorld0Thread then task.cancel(SwordWorld0Thread) SwordWorld0Thread = nil end end
        end })
    SwordBox:CreateToggle({ Name = "Auto Roll Summer Sword (World8)", Flag = "AutoSword_World8", CurrentValue = false, Callback = function(value)
            SwordWorld8Enabled = value
            if value then if SwordWorld8Thread then task.cancel(SwordWorld8Thread) end SwordWorld8Thread = task.spawn(aas_swordWorld8Loop)
            else if SwordWorld8Thread then task.cancel(SwordWorld8Thread) SwordWorld8Thread = nil end end
        end })


    local PlayerPassTab = Tabs.Swords:AddLeftGroupbox({ Name = "Player", Icon = "user" })
    local passiveLabelObj = PlayerPassTab:CreateLabel("Active: None")
    passiveLabelRef = Options["PassiveActiveLabel"] or passiveLabelObj
    PlayerPassTab:CreateToggle({ Name = "Enable Auto Roll", Flag = "AutoPassiveEnabled", CurrentValue = false, Callback = function(value)
            passiveAutoEnabled = value
            if value then if passiveThread then task.cancel(passiveThread) end passiveThread = task.spawn(aas_passiveLoop)
            else if passiveThread then task.cancel(passiveThread) passiveThread = nil end end
        end })

    local TitanPassTab = Tabs.Swords:AddLeftGroupbox({ Name = "Titan", Icon = "shield-half" })
    local titanLabelObj = TitanPassTab:CreateLabel("Active Titan: None")
    titanLabelRef = Options["TitanActiveLabel"] or titanLabelObj
    TitanPassTab:CreateToggle({ Name = "Enable Auto Roll", Flag = "AutoTitanEnabled", CurrentValue = false, Callback = function(value)
            titanAutoEnabled = value
            if value then if titanThread then task.cancel(titanThread) end titanThread = task.spawn(aas_titanLoop)
            else if titanThread then task.cancel(titanThread) titanThread = nil end end
        end })

    local PetPassTab = Tabs.Swords:AddRightGroupbox({ Name = "Pet", Icon = "paw-print" })
    local ppLabelObj = PetPassTab:CreateLabel("Current: None")
    petPassiveLabelRef = Options["PetPassiveActiveLabel"] or ppLabelObj
    PetPassTab:CreateDropdown({ Name = "Select Equipped Pet", Options = {"(Click Refresh)"}, CurrentOption = 1, Flag = "PetPassivePetSelect", Callback = function(val)
            local uuid = petPassiveDisplayToId and petPassiveDisplayToId[val]
            if uuid then petPassiveSelectedPetId = uuid pcall(aas_syncPetPassiveData) end
        end })
    PetPassTab:CreateButton({ Name = "Refresh Pets", Callback = function()
            local success, equipped = pcall(aas_scanEquippedPets)
            if not success then Window:Notify({ Title = "Euclidean", Content = "Pet Passive Error - Failed to scan pets.", Duration = 3, Type = "Info" }) return end
            local count = 0 for _ in pairs(equipped) do count = count + 1 end
            if count == 0 then Window:Notify({ Title = "Euclidean", Content = "Pet Passive - No equipped pets found.", Duration = 3, Type = "Info" }) return end
            local values = {} petPassiveDisplayToId = {}
            local nameCounts = {}
            for uuid, info in pairs(equipped) do
                local name = info.Name
                nameCounts[name] = (nameCounts[name] or 0) + 1
                local displayName = nameCounts[name] > 1 and (name.." #"..nameCounts[name]) or name
                if info.Passive then displayName = displayName.." ["..info.Passive.Name.." - "..info.Passive.Rarity.."]"
                else displayName = displayName.." [No Passive]" end
                table.insert(values, displayName) petPassiveDisplayToId[displayName] = uuid
            end
            table.sort(values)
            if Options["PetPassivePetSelect"] then
                Options["PetPassivePetSelect"]:SetValues(values)
                if #values > 0 then
                    Options["PetPassivePetSelect"]:SetValue(values[1])
                    petPassiveSelectedPetId = petPassiveDisplayToId[values[1]]
                    pcall(aas_syncPetPassiveData)
                end
            end
            Window:Notify({ Title = "Euclidean", Content = "Pet Passive - Found "..tostring(count).." equipped pet(s)!", Duration = 3, Type = "Info" })
        end })
    PetPassTab:CreateDropdown({ Name = "Stop at Rarity", Options = PetPassiveRarityOrder, MultipleOptions = true, Flag = "PetPassiveStopRarities", Callback = function(_) end })
    PetPassTab:CreateToggle({ Name = "Enable Auto Roll", Flag = "AutoPetPassiveEnabled", CurrentValue = false, Callback = function(value)
            petPassiveAutoEnabled = value
            if value then
                if not petPassiveSelectedPetId or petPassiveSelectedPetId == "" then
                    Toggles["AutoPetPassiveEnabled"]:SetValue(false)
                    Window:Notify({ Title = "Euclidean", Content = "Pet Passive - Select an equipped pet first!", Duration = 3, Type = "Info" })
                    return
                end
                if petPassiveThread then task.cancel(petPassiveThread) end
                petPassiveThread = task.spawn(aas_petPassiveLoop)
                Window:Notify({ Title = "Euclidean", Content = "Auto Pet Passive - Started!", Duration = 3, Type = "Info" })
            else
                if petPassiveThread then task.cancel(petPassiveThread) petPassiveThread = nil end
            end
        end })


    local SP1Tab = Tabs.Swords:AddLeftGroupbox({ Name = "Sword 1", Icon = "sword" })
    local sp1InfoObj = SP1Tab:CreateLabel("Sword 1: Loading...")
    sword1InfoLabelRef = Options["SwordPassive1InfoLabel"] or sp1InfoObj
    local sp1BreathObj = SP1Tab:CreateLabel("Breathing: None")
    sword1BreathingLabelRef = Options["SwordPassive1BreathLabel"] or sp1BreathObj
    SP1Tab:CreateDropdown({ Name = "Stop at Rarity", Options = SwordPassiveRarityOrder, MultipleOptions = true, Flag = "SwordPassive1StopRarities", Callback = function(_) end })
    SP1Tab:CreateToggle({ Name = "Enable Auto Roll", Flag = "AutoSwordPassive1Enabled", CurrentValue = false, Callback = function(value)
            swordPassive1Enabled = value
            if value then if swordPassive1Thread then task.cancel(swordPassive1Thread) end swordPassive1Thread = task.spawn(aas_swordPassive1Loop)
            else if swordPassive1Thread then task.cancel(swordPassive1Thread) swordPassive1Thread = nil end end
        end })

    local SP2Tab = Tabs.Swords:AddRightGroupbox({ Name = "Sword 2", Icon = "swords" })
    local sp2InfoObj = SP2Tab:CreateLabel("Sword 2: Loading...")
    sword2InfoLabelRef = Options["SwordPassive2InfoLabel"] or sp2InfoObj
    local sp2BreathObj = SP2Tab:CreateLabel("Breathing: None")
    sword2BreathingLabelRef = Options["SwordPassive2BreathLabel"] or sp2BreathObj
    SP2Tab:CreateDropdown({ Name = "Stop at Rarity", Options = SwordPassiveRarityOrder, MultipleOptions = true, Flag = "SwordPassive2StopRarities", Callback = function(_) end })
    SP2Tab:CreateToggle({ Name = "Enable Auto Roll", Flag = "AutoSwordPassive2Enabled", CurrentValue = false, Callback = function(value)
            swordPassive2Enabled = value
            if value then if swordPassive2Thread then task.cancel(swordPassive2Thread) end swordPassive2Thread = task.spawn(aas_swordPassive2Loop)
            else if swordPassive2Thread then task.cancel(swordPassive2Thread) swordPassive2Thread = nil end end
        end })

    local GrTab = Tabs.Swords:AddLeftGroupbox({ Name = "Grimoire", Icon = "book" })
    local g1LabelObj = GrTab:CreateLabel("Slot 1: None")
    grimoire1LabelRef = Options["Grimoire1Label"] or g1LabelObj
    GrTab:CreateToggle({ Name = "Enable Auto Roll (Slot 1)", Flag = "AutoGrimoire1Enabled", CurrentValue = false, Callback = function(value)
            grimoire1Enabled = value
            if value then if grimoire1Thread then task.cancel(grimoire1Thread) end grimoire1Thread = task.spawn(aas_grimoire1Loop)
            else if grimoire1Thread then task.cancel(grimoire1Thread) grimoire1Thread = nil end end
        end })
    GrTab:CreateDivider()
    local g2LabelObj = GrTab:CreateLabel("Slot 2: None")
    grimoire2LabelRef = Options["Grimoire2Label"] or g2LabelObj
    GrTab:CreateToggle({ Name = "Enable Auto Roll (Slot 2)", Flag = "AutoGrimoire2Enabled", CurrentValue = false, Callback = function(value)
            grimoire2Enabled = value
            if value then if grimoire2Thread then task.cancel(grimoire2Thread) end grimoire2Thread = task.spawn(aas_grimoire2Loop)
            else if grimoire2Thread then task.cancel(grimoire2Thread) grimoire2Thread = nil end end
        end })
end

-- ══════════════════════════════════════════
--   PROGRESSION SUBTAB
-- ══════════════════════════════════════════

do
    local TrainBox = Tabs.Training:AddLeftGroupbox({ Name = "Progression", Icon = "dumbbell" })
    for _, progKey in ipairs(sortedProgressionKeys) do
        aas_buildTick()
        local progData = ProgressionList[progKey]
        local toggleKey = "AutoProgression_"..progKey
        progressionEnabled[progKey] = false
        local worldLabel = aas_getWorldLabel(progData.WorldId or 0)
        TrainBox:CreateLabel(worldLabel)
        local levelLabelObj = TrainBox:CreateLabel("Level: 0 / "..tostring(progData.MaxLevel))
        progressionLevelLabelRefs[progKey] = Options["ProgLevel_"..progKey] or levelLabelObj
        TrainBox:CreateToggle({ Name = "Enable Auto Upgrade", Flag = toggleKey, CurrentValue = false, Callback = function(value)
                progressionEnabled[progKey] = value
                if value then
                    if progressionThreads[progKey] then task.cancel(progressionThreads[progKey]) end
                    progressionThreads[progKey] = task.spawn(function() aas_progressionLoop(progKey) end)
                    Window:Notify({ Title = "Euclidean", Content = progData.Name.." - Auto Progression started!", Duration = 3, Type = "Info" })
                else
                    if progressionThreads[progKey] then task.cancel(progressionThreads[progKey]) progressionThreads[progKey] = nil end
                end
            end })
        TrainBox:CreateDivider()
    end
end

-- ══════════════════════════════════════════
--   UPGRADES SUBTAB (TABBOX)
-- ══════════════════════════════════════════

do

    local UpTab = Tabs.Upgrades:AddRightGroupbox({ Name = "Upgrades", Icon = "arrow-up" })
    for _, sysKey in ipairs(sortedUpgradeSystemKeys) do
        aas_buildTick()
        local sysData = UpgradeSystemList[sysKey]
        local worldLabel = aas_getWorldLabel(sysData.WorldId or 0)
        local statDropKey = "UpgradeStat_"..sysKey
        local upgradeTogKey = "AutoUpgrade_"..sysKey
        local currentStatForSys = { value = "Power" }
        UpTab:CreateLabel(worldLabel)
        UpTab:CreateDropdown({ Name = "Stat to Upgrade", Options = UpgradeStatKeys, CurrentOption = 1, Flag = statDropKey, Callback = function(val) currentStatForSys.value=val end })
        UpTab:CreateToggle({ Name = "Enable Auto Upgrade", Flag = upgradeTogKey, CurrentValue = false, Callback = function(value)
                if value then
                    local thread = task.spawn(function()
                        while Toggles[upgradeTogKey] and Toggles[upgradeTogKey].Value do
                            pcall(function() aas_upgradesRequestRemote:Fire(sysKey, currentStatForSys.value) end) task.wait(1.0)
                        end
                    end)
                    if rangeUpgradeThreads["upgrade_"..sysKey] then task.cancel(rangeUpgradeThreads["upgrade_"..sysKey]) end
                    rangeUpgradeThreads["upgrade_"..sysKey] = thread
                    Window:Notify({ Title = "Euclidean", Content = sysData.Name.." - Auto Upgrade started!", Duration = 3, Type = "Info" })
                else
                    local t = rangeUpgradeThreads["upgrade_"..sysKey]
                    if t then task.cancel(t) rangeUpgradeThreads["upgrade_"..sysKey] = nil end
                end
            end })
        UpTab:CreateToggle({ Name = "Enable Auto Range Upgrade", Flag = "AutoRangeUpgrade_"..sysKey, CurrentValue = false, Callback = function(value)
                rangeUpgradeEnabled[sysKey] = value
                if value then
                    if rangeUpgradeThreads[sysKey] then task.cancel(rangeUpgradeThreads[sysKey]) end
                    rangeUpgradeThreads[sysKey] = task.spawn(function() aas_rangeUpgradeLoop(sysKey) end)
                    Window:Notify({ Title = "Euclidean", Content = sysData.Name.." Range - Started!", Duration = 3, Type = "Info" })
                else
                    if rangeUpgradeThreads[sysKey] then task.cancel(rangeUpgradeThreads[sysKey]) rangeUpgradeThreads[sysKey] = nil end
                end
            end })
        UpTab:CreateDivider()
    end

    local allSystems2 = aas_Upgrades2Config and aas_Upgrades2Config:GetAllSystems() or {}
    local sortedSysKeys2 = {}
    for sysKey in pairs(allSystems2) do table.insert(sortedSysKeys2, sysKey) end
    table.sort(sortedSysKeys2, function(a,b) return (allSystems2[a] and allSystems2[a].WorldId or 0) < (allSystems2[b] and allSystems2[b].WorldId or 0) end)

    local Up2Tab = Tabs.Upgrades:AddLeftGroupbox({ Name = "Upgrades 2", Icon = "briefcase" })
    for _, sysKey in ipairs(sortedSysKeys2) do
        aas_buildTick()
        local sysData = allSystems2[sysKey]
        local sysName = sysData and sysData.Name or sysKey
        local worldLabel = aas_getWorldLabel(sysData and sysData.WorldId or 0)
        local upgradeList = sysData and sysData.UpgradeList or {}
        if #upgradeList == 0 then continue end

        local upgradeDisplayNames, upgradeDisplayToKey = {}, {}
        for _, upg in ipairs(upgradeList) do
            aas_buildTick()
            local display = upg.DisplayName or upg.Key
            table.insert(upgradeDisplayNames, display)
            upgradeDisplayToKey[display] = upg.Key
        end

        upgrades2SelectedStats[sysKey] = {}
        Up2Tab:CreateLabel(sysName.." ("..worldLabel..")")
        Up2Tab:CreateDropdown({ Name = "Select Stats to Upgrade", Options = upgradeDisplayNames, MultipleOptions = true, Flag = "Upgrades2StatSelect_"..sysKey, Callback = function(val)
                upgrades2SelectedStats[sysKey] = {}
                for display, state in pairs(val or {}) do
                    if state and upgradeDisplayToKey[display] then
                        upgrades2SelectedStats[sysKey][upgradeDisplayToKey[display]] = true
                    end
                end
            end })
        upgrades2Enabled2[sysKey] = false
        Up2Tab:CreateToggle({ Name = "Enable Auto Upgrade ("..sysName..")", Flag = "AutoUpgrades2_"..sysKey, CurrentValue = false, Callback = function(value)
                upgrades2Enabled2[sysKey] = value
                if value then
                    if upgrades2Threads2[sysKey] then task.cancel(upgrades2Threads2[sysKey]) end
                    local anySelected = false
                    for _ in pairs(upgrades2SelectedStats[sysKey] or {}) do anySelected = true break end
                    if not anySelected then
                        Toggles["AutoUpgrades2_"..sysKey]:SetValue(false) upgrades2Enabled2[sysKey] = false
                        Window:Notify({ Title = "Euclidean", Content = sysName.." - Select at least one stat first!", Duration = 3, Type = "Info" }) return
                    end
                    upgrades2Threads2[sysKey] = task.spawn(function() aas_upgrades2LoopV2(sysKey) end)
                    Window:Notify({ Title = "Euclidean", Content = sysName.." - Auto Upgrade started!", Duration = 3, Type = "Info" })
                else
                    if upgrades2Threads2[sysKey] then task.cancel(upgrades2Threads2[sysKey]) upgrades2Threads2[sysKey] = nil end
                end
            end })
        Up2Tab:CreateToggle({ Name = "Enable Auto Range Upgrade", Flag = "AutoRangeUpgrade2_"..sysKey, CurrentValue = false, Callback = function(value)
                rangeUpgradeEnabled[sysKey] = value
                if value then
                    if rangeUpgradeThreads[sysKey] then task.cancel(rangeUpgradeThreads[sysKey]) end
                    rangeUpgradeThreads[sysKey] = task.spawn(function() aas_rangeUpgradeLoop(sysKey) end)
                    Window:Notify({ Title = "Euclidean", Content = sysName.." Range - Started!", Duration = 3, Type = "Info" })
                else
                    if rangeUpgradeThreads[sysKey] then task.cancel(rangeUpgradeThreads[sysKey]) rangeUpgradeThreads[sysKey] = nil end
                end
            end })
        Up2Tab:CreateDivider()
    end
end

-- ══════════════════════════════════════════
--   GROWTH SUBTAB (TABBOX)
-- ══════════════════════════════════════════

do

    local EvoTab = Tabs.Growth:AddRightGroupbox({ Name = "Evolve", Icon = "dna" })
    if #sortedEvolutionKeys == 0 then EvoTab:CreateLabel("No evolution data found.")
    else
        for _, evKey in ipairs(sortedEvolutionKeys) do
            aas_buildTick()
            local evData = EvolutionList[evKey]
            EvoTab:CreateLabel("• "..evData.Name.." | "..evData.Stat.." | Max: "..tostring(evData.MaxLevel))
        end
        EvoTab:CreateDivider()
        EvoTab:CreateToggle({ Name = "Enable Auto Evolution", Flag = "AutoEvolutionEnabled", CurrentValue = false, Callback = function(value)
                autoEvolutionEnabled = value
                if value then
                    if autoEvolutionThread then task.cancel(autoEvolutionThread) end
                    autoEvolutionThread = task.spawn(aas_autoEvolutionLoop)
                    Window:Notify({ Title = "Euclidean", Content = "Auto Evolution - Started!", Duration = 3, Type = "Info" })
                else
                    if autoEvolutionThread then task.cancel(autoEvolutionThread) autoEvolutionThread = nil end
                end
            end })
    end

    local RelicTab = Tabs.Growth:AddLeftGroupbox({ Name = "Relics", Icon = "gem" })
    RelicTab:CreateToggle({ Name = "Auto Upgrade All Relics", Flag = "AutoRelicUpgradeEnabled", CurrentValue = false, Callback = function(value)
            autoRelicUpgradeEnabled = value
            if value then
                if autoRelicUpgradeThread then task.cancel(autoRelicUpgradeThread) end
                autoRelicUpgradeThread = task.spawn(aas_autoRelicUpgradeLoop)
                Window:Notify({ Title = "Euclidean", Content = "Auto Relic Upgrade - Started!", Duration = 3, Type = "Info" })
            else
                if autoRelicUpgradeThread then task.cancel(autoRelicUpgradeThread) autoRelicUpgradeThread = nil end
            end
        end })
    RelicTab:CreateToggle({ Name = "Auto Ascend All Relics", Flag = "AutoRelicAscendEnabled", CurrentValue = false, Callback = function(value)
            autoRelicAscendEnabled = value
            if value then
                if autoRelicAscendThread then task.cancel(autoRelicAscendThread) end
                autoRelicAscendThread = task.spawn(aas_autoRelicAscendLoop)
                Window:Notify({ Title = "Euclidean", Content = "Auto Relic Ascend - Started!", Duration = 3, Type = "Info" })
            else
                if autoRelicAscendThread then task.cancel(autoRelicAscendThread) autoRelicAscendThread = nil end
            end
        end })

    local TreeTab = Tabs.Growth:AddRightGroupbox({ Name = "Trees", Icon = "network" })
    if #sortedSkillTreeKeys > 0 then
        for _, treeName in ipairs(sortedSkillTreeKeys) do
            aas_buildTick()
            local treeData = SkillTreeList[treeName]
            local toggleKey = "AutoSkillTree_"..treeName
            skillTreeEnabled[treeName] = false
            TreeTab:CreateToggle({ Name = treeName.." ("..aas_getWorldLabel(treeData.WorldId or 0)..") — "..tostring(treeData.UpgradeCount).." nodes", Flag = toggleKey, CurrentValue = false, Callback = function(value)
                    skillTreeEnabled[treeName] = value
                    if value then
                        if skillTreeThreads[treeName] then task.cancel(skillTreeThreads[treeName]) end
                        skillTreeThreads[treeName] = task.spawn(function() aas_skillTreeLoop(treeName) end)
                        Window:Notify({ Title = "Euclidean", Content = "Skill Tree: "..treeName.." - Started!", Duration = 3, Type = "Info" })
                    else
                        if skillTreeThreads[treeName] then task.cancel(skillTreeThreads[treeName]) skillTreeThreads[treeName] = nil end
                    end
                end })
        end
    end
    if #sortedConstellationKeys > 0 then
        TreeTab:CreateDivider()
        for _, constId in ipairs(sortedConstellationKeys) do
            aas_buildTick()
            local constData = ConstellationList[constId]
            local toggleKey = "AutoConstellation_"..constId
            constellationEnabled[constId] = false
            TreeTab:CreateToggle({ Name = constData.Name.." — "..tostring(constData.NodeCount).." nodes", Flag = toggleKey, CurrentValue = false, Callback = function(value)
                    constellationEnabled[constId] = value
                    if value then
                        if constellationThreads[constId] then task.cancel(constellationThreads[constId]) end
                        constellationThreads[constId] = task.spawn(function() aas_constellationLoop(constId) end)
                        Window:Notify({ Title = "Euclidean", Content = "Constellation: "..constData.Name.." - Started!", Duration = 3, Type = "Info" })
                    else
                        if constellationThreads[constId] then task.cancel(constellationThreads[constId]) constellationThreads[constId] = nil end
                    end
                end })
        end
    end
    if #sortedSkillTreeKeys == 0 and #sortedConstellationKeys == 0 then
        TreeTab:CreateLabel("No tree data found.")
    end
end

-- ══════════════════════════════════════════
--   STAR TAB (SOLID COLORS)
-- ══════════════════════════════════════════

do
    local StarInfo = Tabs.Star:AddLeftGroupbox({ Name = "Auto Star", Icon = "star" })
        StarInfo:CreateDivider()

    local starWorldDisplayNames, starWorldDisplayToKey = {}, {}
    for _, key in ipairs(sortedStarWorldKeys) do
        aas_buildTick()
        local worldData = StarWorldList[key]
        local displayName = aas_getWorldLabel(worldData.WorldId)
        table.insert(starWorldDisplayNames, displayName)
        starWorldDisplayToKey[displayName] = key
    end
    if #sortedStarWorldKeys > 0 then starEggKey = sortedStarWorldKeys[1] end

    if #starWorldDisplayNames > 0 then
        StarInfo:CreateDropdown({ Name = "Select World (Egg)", Options = starWorldDisplayNames, CurrentOption = 1, Flag = "StarWorldSelect", Callback = function(val)
                local key = starWorldDisplayToKey[val]
                if key then starEggKey = key end
            end })
    end
    StarInfo:CreateToggle({ Name = "Enable Auto Star Roll", Flag = "AutoStarEnabled", CurrentValue = false, Callback = function(value)
            starEnabled = value
            if value then
                if not starEggKey then Toggles["AutoStarEnabled"]:SetValue(false) Window:Notify({ Title = "Euclidean", Content = "Auto Star - No world selected!", Duration = 3, Type = "Info" }) return end
                if starThread then task.cancel(starThread) starThread = nil end
                starThread = task.spawn(aas_starLoop)
                Window:Notify({ Title = "Euclidean", Content = "Auto Star - Started rolling "..(starEggKey or "?"), Duration = 3, Type = "Info" })
            else
                if starThread then task.cancel(starThread) starThread = nil end
            end
        end })

    local CraftBox = Tabs.Star:AddRightGroupbox({ Name = "Craft", Icon = "hammer" })

    for _, craftKey in ipairs(sortedCraftKeys) do
        aas_buildTick()
        local craftData = CraftList[craftKey]
        local toggleKey = "AutoCraft_"..craftKey
        local shinyKey = "AutoCraftShiny_"..craftKey
        craftEnabled[craftKey] = false craftShiny[craftKey] = false
        local worldLabel = aas_getWorldLabel(craftData.WorldId or 0)
        CraftBox:CreateLabel(craftKey.." ("..worldLabel..")")
        CraftBox:CreateToggle({ Name = "Craft Shiny", Flag = shinyKey, CurrentValue = false, Callback = function(value) craftShiny[craftKey]=value end })
        CraftBox:CreateToggle({ Name = "Enable Auto Craft", Flag = toggleKey, CurrentValue = false, Callback = function(value)
                craftEnabled[craftKey] = value
                if value then
                    if craftThreads[craftKey] then task.cancel(craftThreads[craftKey]) end
                    craftThreads[craftKey] = task.spawn(function() aas_craftLoop(craftKey) end)
                    Window:Notify({ Title = "Euclidean", Content = craftKey.." - Auto Craft started!", Duration = 3, Type = "Info" })
                else
                    if craftThreads[craftKey] then task.cancel(craftThreads[craftKey]) craftThreads[craftKey] = nil end
                end
            end })
    end
end

-- ══════════════════════════════════════════
--   QUESTS TAB (SOLID COLORS)
-- ══════════════════════════════════════════

do
    local GQListGroup = Tabs.Quests:AddLeftGroupbox({ Name = "Quest Selection", Icon = "list" })
        GQListGroup:CreateDivider()

    local aas_gqAllValues = {}
    do
        local allQuests = {}
        pcall(function() allQuests = aas_GlobalQuestConfig:GetAll() or {} end)
        for i, def in ipairs(allQuests) do
            aas_buildTick()
            local display, farmable = "", false
            pcall(function() display = aas_gqBuildDisplay(i) end)
            pcall(function() farmable = aas_gqIsFarmable(i) end)
            if display ~= "" and farmable then table.insert(aas_gqAllValues, display) end
        end
    end

    if #aas_gqAllValues > 0 then
        GQListGroup:CreateDropdown({ Name = "Select Quests to Farm", Options = aas_gqAllValues, MultipleOptions = true, Flag = "GQSelectQuests", Callback = function(_) end })
    else GQListGroup:CreateLabel("No farmable quests found.") end

    local GQControlGroup = Tabs.Quests:AddRightGroupbox({ Name = "Controls", Icon = "settings" })
    GQControlGroup:CreateToggle({ Name = "Auto Claim Completed Quests", Flag = "GQAutoClaimAll", CurrentValue = false, Callback = function(value)
            globalQuestAutoClaimEnabled = value
            if value then
                if globalQuestClaimThread then task.cancel(globalQuestClaimThread) end
                globalQuestClaimThread = task.spawn(function()
                    while globalQuestAutoClaimEnabled do
                        pcall(function() aas_globalQuestClaimAllRemote:Fire() end) task.wait(30)
                    end
                end)
                Window:Notify({ Title = "Euclidean", Content = "GQ Auto Claim - Enabled!", Duration = 3, Type = "Info" })
            else
                if globalQuestClaimThread then task.cancel(globalQuestClaimThread) globalQuestClaimThread = nil end
            end
        end })
    GQControlGroup:CreateDivider()
    GQControlGroup:CreateToggle({ Name = "Enable Global Quest Farmer", Flag = "GQFarmerEnabled", CurrentValue = false, Callback = function(value)
            globalQuestEnabled = value
            if value then
                if globalQuestThread then task.cancel(globalQuestThread) end
                globalQuestThread = task.spawn(aas_globalQuestLoop)
                Window:Notify({ Title = "Euclidean", Content = "GQ Farmer - Started!", Duration = 3, Type = "Info" })
            else
                if globalQuestThread then task.cancel(globalQuestThread) globalQuestThread = nil end
                globalQuestCurrentTarget = nil globalQuestCurrentAction = nil globalQuestSuppressedByPriority = false
            end
        end })

    local GQFullListGroup = Tabs.Quests:AddLeftGroupbox({ Name = "Quest Reference (All)", Icon = "book-open" })
    local aas_gqStatusLabelRefs = {}

    GQFullListGroup:CreateButton({ Name = "Refresh Status", Callback = function()
            local claimedCount, completeCount, progressCount = 0, 0, 0
            local allQuests = aas_GlobalQuestConfig:GetAll() or {}

            for i, def in ipairs(allQuests) do
                local qData = aas_gqReadQuest(i)
                local display = aas_gqBuildDisplay(i)

                local statusIcon
                if qData.Claimed then
                    statusIcon = "✅" claimedCount = claimedCount + 1
                elseif qData.Complete then
                    statusIcon = "🟡" completeCount = completeCount + 1
                else
                    statusIcon = "⏳" progressCount = progressCount + 1
                end

                local progressText = ""
                if qData.Required > 0 then
                    progressText = " (" .. tostring(qData.Current) .. "/" .. tostring(qData.Required) .. ")"
                end

                local labelRef = aas_gqStatusLabelRefs[i]
                if labelRef then
                    aas_setLabel(labelRef, statusIcon .. " " .. display .. progressText)
                end
            end

            Window:Notify({ Title = "Euclidean", Content =
                "GQ Status Refreshed - ✅ Claimed: " .. claimedCount ..
                " | 🟡 Complete: " .. completeCount ..
                " | ⏳ In Progress: " .. progressCount, Duration = 3, Type = "Info" })
        end })

    GQFullListGroup:CreateDivider()

    do
        local allQuests = aas_GlobalQuestConfig:GetAll() or {}
        for i, def in ipairs(allQuests) do
            aas_buildTick()
            local display = aas_gqBuildDisplay(i)
            local labelKey = "GQStatus_" .. i
            local labelObj = GQFullListGroup:CreateLabel("⏳ " .. display)
            aas_gqStatusLabelRefs[i] = Options[labelKey] or labelObj
        end
    end
end

-- ══════════════════════════════════════════
--   PROMOTION TAB (SOLID COLORS)
-- ══════════════════════════════════════════

do
    local PromoInfoGroup = Tabs.Quests:AddLeftGroupbox({ Name = "Current Promotion Status", Icon = "list" })
    local promoRankObj = PromoInfoGroup:CreateLabel("Current Rank: Loading...")
    promotionCurrentRankLabelRef = Options["PromotionCurrentRankLabel"] or promoRankObj
    local promoNextObj = PromoInfoGroup:CreateLabel("Next Rank: -")
    promotionNextRankLabelRef = Options["PromotionNextRankLabel"] or promoNextObj
    local promoCanObj = PromoInfoGroup:CreateLabel("Can Promote: false")
    promotionCanPromoteLabelRef = Options["PromotionCanPromoteLabel"] or promoCanObj
    local promoProgObj = PromoInfoGroup:CreateLabel("Mission Progress: 0/0")
    promotionProgressLabelRef = Options["PromotionProgressLabel"] or promoProgObj
    PromoInfoGroup:CreateDivider()
    for i = 1, 10 do
        local key = "PromotionMissionLabel_"..i
        local obj = PromoInfoGroup:CreateLabel(" ")
        promotionMissionLabelRefs[i] = Options[key] or obj
    end

    local PromoControlGroup = Tabs.Quests:AddRightGroupbox({ Name = "Controls", Icon = "settings" })
    PromoControlGroup:CreateButton({ Name = "Refresh Promotion State", Callback = function()
            pcall(aas_syncAllPlayerData) aas_requestPromotionState(2) aas_updatePromotionUi()
            local state = promotionLiveState or aas_buildFallbackPromotionState()
            Window:Notify({ Title = "Euclidean", Content = "Promotion Refreshed - Rank: "..tostring(state and state.PromotionRank or "?"), Duration = 3, Type = "Info" })
        end })
    PromoControlGroup:CreateDivider()
    PromoControlGroup:CreateToggle({ Name = "Enable Auto Promotion", Flag = "AutoPromotionEnabled", CurrentValue = false, Callback = function(value)
            promotionEnabled = value
            if value then
                if promotionThread then task.cancel(promotionThread) promotionThread = nil end
                promotionThread = task.spawn(aas_autoPromotionLoop)
                Window:Notify({ Title = "Euclidean", Content = "Auto Promotion - Started!", Duration = 3, Type = "Info" })
            else
                if promotionThread then task.cancel(promotionThread) promotionThread = nil end
                aas_promoStopBackgroundThreads() promotionSuppressedByPriority = false
            end
        end })
    PromoControlGroup:CreateButton({ Name = "Force Promote (If Ready)", Callback = function()
            pcall(function() aas_promotionPromoteRemote:Fire() end)
            task.wait(0.2) aas_requestPromotionState(2) aas_updatePromotionUi()
        end })

    local PromoRefGroup = Tabs.Quests:AddLeftGroupbox({ Name = "Promotion Rank Reference", Icon = "book-open" })
    do
        local maxRank = aas_PromotionConfig:GetMaxRank()
        for rank = 0, maxRank do
            local key = "PromotionRef_"..rank
            local obj = PromoRefGroup:CreateLabel("• "..aas_promoBuildRankSummary(rank))
            promotionRankRefLabelRefs[rank] = Options[key] or obj
        end
    end

    task.defer(function()
        pcall(aas_syncAllPlayerData) aas_requestPromotionState(2) aas_updatePromotionUi()
    end)
end

local currentFOV = 70
local defaultFOV = Camera and Camera.FieldOfView or 70

local freezeConn = nil
local function setFreeze(enabled)
    if freezeConn then freezeConn:Disconnect() freezeConn = nil end
    local root = wpc_getRoot()
    if not root then return end
    if enabled then
        local pos = root.CFrame
        freezeConn = RunService.Heartbeat:Connect(function()
            local r = wpc_getRoot()
            if r then
                r.AssemblyLinearVelocity = Vector3.zero
                r.CFrame = pos
            end
        end)
    end
end

local function stopFly()
    FLYING = false
    if flyKeyDown then flyKeyDown:Disconnect() flyKeyDown = nil end
    if flyKeyUp then flyKeyUp:Disconnect() flyKeyUp = nil end
    local h = getHumanoid()
    if h then h.PlatformStand = false end
end

do
    local MoveBox = PlayerTab:AddLeftGroupbox({ Name = "Movement", Icon = "footprints" })
    MoveBox:CreateToggle({ Name = "Enable Walk Speed", Flag = "WalkSpeedEnabled", CurrentValue = false })
    MoveBox:CreateSlider({
        Name = "Walk Speed", Range = { 16, 250 }, Increment = 1, Suffix = " sps",
        CurrentValue = 16, Flag = "WalkSpeed",
        Callback = function(v) currentWalkSpeed = v end,
    })
    MoveBox:CreateToggle({ Name = "Enable Jump Power", Flag = "JumpPowerEnabled", CurrentValue = false })
    MoveBox:CreateSlider({
        Name = "Jump Power", Range = { 50, 300 }, Increment = 1, Suffix = "",
        CurrentValue = 50, Flag = "JumpPower",
        Callback = function(v) currentJumpPower = v end,
    })
    MoveBox:CreateToggle({ Name = "Infinite Jump", Flag = "InfJump", CurrentValue = false })
    MoveBox:CreateToggle({ Name = "NoClip", Flag = "NoClip", CurrentValue = false })

    local FlightBox = PlayerTab:AddLeftGroupbox({ Name = "Flight", Icon = "plane" })
    FlightBox:CreateToggle({
        Name = "Enable Fly", Flag = "Fly", CurrentValue = false,
        Callback = function(v)
            if v then sFLY(false) else stopFly() end
        end,
    })
    FlightBox:CreateSlider({
        Name = "Fly Speed", Range = { 10, 350 }, Increment = 1, Suffix = " sps",
        CurrentValue = 60, Flag = "FlySpeed",
        Callback = function(v) currentFlySpeed = v end,
    })

    local CharBox = PlayerTab:AddRightGroupbox({ Name = "Character", Icon = "user" })
    CharBox:CreateToggle({
        Name = "Freeze Character", Flag = "FreezeChar", CurrentValue = false,
        Callback = function(v) setFreeze(v) end,
    })
    CharBox:CreateButton({
        Name = "Reset Character",
        Callback = function()
            local h = getHumanoid()
            if h then h.Health = 0 end
        end,
    })
    CharBox:CreateSlider({
        Name = "Camera FOV", Range = { 30, 120 }, Increment = 1, Suffix = "",
        CurrentValue = 70, Flag = "CameraFOV",
        Callback = function(v)
            currentFOV = v
            if Camera then Camera.FieldOfView = v end
        end,
    })
    CharBox:CreateButton({
        Name = "Reset FOV",
        Callback = function()
            if Camera then Camera.FieldOfView = defaultFOV end
            local f = Ouro.Flags.CameraFOV
            if f and type(f.Set) == "function" then pcall(function() f:Set(defaultFOV, true) end) end
        end,
    })

    local PerfBox = PlayerTab:AddRightGroupbox({ Name = "Performance", Icon = "gauge" })
    PerfBox:CreateToggle({
        Name = "Disable 3D Rendering", Flag = "PotatoMode", CurrentValue = false,
        Callback = function(v)
            RunService:Set3dRenderingEnabled(not v)
            setBlackout(v)
        end,
    })
    PerfBox:CreateToggle({
        Name = "Boost FPS", Flag = "FPSBoost", CurrentValue = false,
        Callback = function(v) applyEuclideanFPSBoost(v) end,
    })
    PerfBox:CreateToggle({ Name = "Anti Gameplay Paused", Flag = "AntiGameplayPaused", CurrentValue = false, Callback = function(v) setNetworkPauseGuard(v) end })
    PerfBox:CreateToggle({ Name = "Anti Robux Popup", Flag = "AntiRobuxPopup", CurrentValue = false, Callback = function(v) setRobuxPopupGuard(v) end })
    PerfBox:CreateToggle({ Name = "Anti-AFK", Flag = "AntiAFK", CurrentValue = true })
end

-- Anti-AFK: VIM click + jump together every 5 minutes (only while idle)
local antiAfkLastInput = tick()
pcall(function()
    for _, conn in ipairs(getconnections(LocalPlayer.Idled)) do conn:Disable() end
end)

UserInputService.InputBegan:Connect(function() antiAfkLastInput = tick() end)

task.spawn(function()
    while not unloaded do
        task.wait(300)
        if unloaded then break end
        if isOn("AntiAFK") and (tick() - antiAfkLastInput) >= 280 then
            pcall(function()
                VIM:SendMouseButtonEvent(0, 0, 0, true, game, 1)
                VIM:SendMouseButtonEvent(0, 0, 0, false, game, 1)
            end)
            pcall(function()
                local h = getHumanoid()
                if h then h:ChangeState(Enum.HumanoidStateType.Jumping) end
            end)
        end
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

--   SETTINGS TAB
-- ══════════════════════════════════════════

do
    local MenuBox = SettingsTab:AddLeftGroupbox({ Name = "Menu", Icon = "menu" })
    MenuBox:CreateKeybind({
        Name = "Menu Key", CurrentKeybind = "G", Flag = "MenuKeybind",
        Callback = function() pcall(function() Window:Toggle() end) end,
    })
    MenuBox:CreateToggle({
        Name = "Auto Execute on Rejoin", Flag = "AutoExecute", CurrentValue = false,
        Callback = function(v)
            if v then euclideanQueueAutoExec(AUTOEXEC_CODE) end
        end,
    })
    LocalPlayer.OnTeleport:Connect(function()
        if isOn("AutoExecute") then
            euclideanQueueAutoExec(AUTOEXEC_CODE)
        end
    end)
    MenuBox:CreateButton({ Name = "Rejoin Server", Callback = safeRejoin })
    MenuBox:CreateButton({
        Name = "Unload Script",
        Callback = function()
            Ouro:Confirm({
                Title = "Unload?",
                Content = "The window closes and everything is restored.",
                ConfirmText = "Unload",
                CancelText = "Keep",
                Callback = function() pcall(function() Window:Destroy() end) end,
            })
        end,
    })

    local NameBox = SettingsTab:AddRightGroupbox({ Name = "Name Changer", Icon = "user" })
    NameBox:CreateToggle({
        Name = "Enable Name Changer", Flag = "EnableNameSpoof", CurrentValue = false,
        Callback = function(v)
            euclideanSpoofOn = v
            applyEuclideanNameSpoof()
        end,
    })
    NameBox:CreateInput({
        Name = "Target Fake Name", PlaceholderText = "Enter alias...",
        CurrentValue = "EuclideanUser", Flag = "SpoofedName",
        Callback = function(t)
            if type(t) == "string" and t ~= "" then
                euclideanSpoofName = t
                if euclideanSpoofOn then applyEuclideanNameSpoof() end
            end
        end,
    })

    SettingsTab:CreateConfigManager({ Name = "Configs", Side = "Left" })
    SettingsTab:CreateThemeManager({ Name = "Themes", Side = "Right" })
end

--   FINALIZE (configs, themes, autoload)
-- ══════════════════════════════════════════

Window:LoadAutoload()

-- ══════════════════════════════════════════
--   UNLOAD + TEST SHIMS
-- ══════════════════════════════════════════

local function unloadEuclidean()
    if unloaded then return end
    unloaded = true
    pcall(applyEuclideanFPSBoost, false)
    pcall(restoreEuclideanNames)
    pcall(aas_cleanup)
    pcall(function() steppedConnection:Disconnect() end)
    pcall(function() jumpConnection:Disconnect() end)
    pcall(function() renderConnection:Disconnect() end)
    if charAddedConn then pcall(function() charAddedConn:Disconnect() end) end
    if freezeConn then pcall(function() freezeConn:Disconnect() end) freezeConn = nil end
    pcall(function() if networkPauseConn then networkPauseConn:Disconnect() end networkPauseConn = nil end)
    pcall(function() if foundationOverlayConn then foundationOverlayConn:Disconnect() end foundationOverlayConn = nil end)
    stopFly()
    RunService:Set3dRenderingEnabled(true)
    setBlackout(false)
    if blackoutGui then blackoutGui:Destroy() blackoutGui = nil end
    if Camera then Camera.FieldOfView = defaultFOV end
    local h = getHumanoid()
    if h then
        h.PlatformStand = false
        h.WalkSpeed     = 16
        h.JumpPower     = 50
    end
    pcall(function() Window:Destroy() end)
end

-- Functional-test + debug shims (same contract as the Obsidian copy)
do
    local TestToggles = {}
    local TestOptions = {}
    setmetatable(TestToggles, { __index = function(_, k)
        local f = Ouro.Flags[k]
        if type(f) ~= "table" then return nil end
        return {
            Value = f.Value,
            SetValue = function(_, v)
                if type(f.Set) == "function" then pcall(function() f:Set(v) end) end
            end,
            GetValue = function()
                if type(f.Get) == "function" then
                    local ok, v = pcall(function() return f:Get() end)
                    if ok then return v end
                end
                return f.Value
            end,
        }
    end })
    _G.EuclideanLibrary = { Toggles = TestToggles, Options = TestOptions }

    _G.EuclideanDbg = function()
        return {
            phase = "ouro-test",
            unloaded = unloaded,
            farm = farmEnabled,
            raid = activeRaidKey,
            defense = activeDefenseKey,
        }
    end
end

notify("Euclidean loaded, welcome " .. LocalPlayer.Name, 5)
