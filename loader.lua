if not game:IsLoaded() then 
    game.Loaded:Wait() 
end

local poops = {
    [156771660] = "%2B1-wood-per-click.lua",
    [32617906] = "%2B1-slayer-blade.lua",
    [629976265] = "1keyboard%3D1%24s.lua",
    [32946892] = "airline-idle.lua",
    [973045631] = "anime-card-farm.lua",
    [10249200] = "anime-dimensions-simulator.lua",
    [35812225] = "anime-duelists.lua",
    [794813948] = "anime-dungeons.lua",
    [452957338] = "anime-rng-battles.lua",
    [33724194] = "anime-rng-defense.lua",
    [788592731] = "anime-stars.lua",
    [725311854] = "anime-universe.lua",
    [886806949] = "become-an-anime-billionaire.lua",
    [654102831] = "bomb-fishing.lua",
    [540612760] = "build-a-base-and-steal.lua",
    [308858726] = "build-a-gun-army.lua",
    [177870152] = "build-a-keyboard.lua",
    [4127076] = "catch-and-tame.lua",
    [34492682] = "chicken-farm.lua",
    [1050787888] = "clean-the-squishies.lua",
    [192031578] = "crab-tycoon.lua",
    [416436258] = "crunch-my-butter.lua",
    [918842803] = "digimon-era.lua",
    [321593943] = "dungeon-leveling-origin.lua",
    [110427303] = "dungeon-lootr.lua",
    [635379718] = "egg-case-farm.lua",
    [15564363] = "elemental-dungeons.lua",
    [1098654977] = "fantasy-rng.lua",
    [35532215] = "farm-an-island.lua",
    [330064258] = "grow-it-rng.lua",
    [1042291725] = "hatch-a-dragon.lua",
    [854390513] = "jump-to-steal-soccer-players.lua",
    [10353739] = "loot-rng.lua",
    [1000628384] = "make-a-drill-farm.lua",
    [444132252] = "make-hotsauce.lua",
    [878417107] = "merge-a-blackhole.lua",
    [596089868] = "mine-a-mountain.lua",
    [627287172] = "mine-a-planet.lua",
    [33896179] = "missiles-vs-cities.lua",
    [33259677] = "mount-rng.lua",
    [458870316] = "my-fishing-anime.lua",
    [882819480] = "my-giant-sandwich.lua",
    [8413545680] = "my-shrimp-farm.lua",
    [706743014] = "my-sword-empire.lua",
    [308844184] = "my-wood-farm.lua",
    [719390069] = "open-sea-for-animals.lua",
    [1053923615] = "own-a-cafe.lua",
    [140648141] = "penguin-tycoon.lua",
    [286191944] = "place-the-keycaps.lua",
    [941101223] = "planet-rng.lua",
    [15904375] = "heroes-rng.lua",
    [14444762] = "roll-a-pack.lua",
    [412698300] = "roll-anime-fighters.lua",
    [861213399] = "roll-to-defend.lua",
    [431165110] = "snowcone-stand.lua",
    [711432426] = "soccer-manager.lua",
    [831907229] = "spin-a-car.lua",
    [1071096739] = "spin-a-duel-monster.lua",
    [10185612] = "tap-incremental.lua",
    [380415714] = "throw-a-coin.lua",
    [556965441] = "tnt-to-earths-core.lua",
    [383912360] = "zombie-turret-farm.lua"
}



local samegroup = {
    [102072869879193] = "anime-astral-simulator.lua",
    [94717504417144] = "anime-capture.lua",
    [85580552562948] = "anime-powerscaling-card-collection.lua",
    [109715918987082] = "anime-stars-card-collection.lua",
}

local gameFile = samegroup[game.PlaceId] or poops[game.CreatorId]
if not gameFile then return end

local icon = "rbxassetid://118719079382998"

local function runScript()
    local url = "https://raw.githubusercontent.com/hersheyzchoco-cmyk/ggs/refs/heads/main/games/" .. gameFile
    local content = game:HttpGet(url)
    content = content:gsub("rbxassetid://117487160988921", icon)
    loadstring(content)()
end

local keyPath = "EuclideanKey.txt"
if isfile and isfile(keyPath) and readfile(keyPath) == "thanks" then
    runScript()
    return
end

local sg = Instance.new("ScreenGui", game:GetService("CoreGui") or game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui"))
local frame = Instance.new("Frame", sg)
frame.Size = UDim2.new(0, 300, 0, 150)
frame.Position = UDim2.new(0.5, -150, 0.5, -75)
frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
frame.Active = true
frame.Draggable = true
Instance.new("UICorner", frame)

local input = Instance.new("TextBox", frame)
input.Size = UDim2.new(0.9, 0, 0, 35)
input.Position = UDim2.new(0.05, 0, 0.2, 0)
input.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
input.PlaceholderText = "Enter key here..."
input.Text = ""
input.TextColor3 = Color3.fromRGB(255, 255, 255)
Instance.new("UICorner", input)

local submit = Instance.new("TextButton", frame)
submit.Size = UDim2.new(0.42, 0, 0, 35)
submit.Position = UDim2.new(0.05, 0, 0.6, 0)
submit.BackgroundColor3 = Color3.fromRGB(0, 150, 80)
submit.Text = "Submit"
submit.TextColor3 = Color3.fromRGB(255, 255, 255)
Instance.new("UICorner", submit)

local discord = Instance.new("TextButton", frame)
discord.Size = UDim2.new(0.42, 0, 0, 35)
discord.Position = UDim2.new(0.53, 0, 0.6, 0)
discord.BackgroundColor3 = Color3.fromRGB(88, 101, 242)
discord.Text = "Join Discord"
discord.TextColor3 = Color3.fromRGB(255, 255, 255)
Instance.new("UICorner", discord)

submit.MouseButton1Click:Connect(function()
    if input.Text == "thanks" then
        if writefile then writefile(keyPath, "thanks") end
        sg:Destroy()
        runScript()
    else
        submit.Text = "Invalid Key"
        task.wait(1.5)
        submit.Text = "Submit"
    end
end)

discord.MouseButton1Click:Connect(function()
    if setclipboard then
        setclipboard("https://discord.gg/DHeCNzTypH")
        discord.Text = "Copied!"
        task.wait(1.5)
        discord.Text = "Join Discord"
    end
end)
