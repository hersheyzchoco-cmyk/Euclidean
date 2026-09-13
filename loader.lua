if not game:IsLoaded() then 
    game.Loaded:Wait() 
end

local poops = {
    [112231208081788] = "%2B1-wood-per-click.lua",
    [15744137588] = "%2B1-slayer-blade.lua",
    [121003786627094] = "1keyboard%3D1%24s.lua",
    [70437719899064] = "airline-idle.lua",
    [102072869879193] = "anime-astral-simulator.lua",
    [94717504417144] = "anime-capture.lua",
    [125039473548047] = "anime-card-farm.lua",
    [6990129309] = "anime-dimensions-simulator.lua",
    [7274690025] = "anime-dimensions-simulator.lua",
    [6938803436] = "anime-dimensions-simulator.lua",
    [7338881230] = "anime-dimensions-simulator.lua",
    [135858844777165] = "anime-duelists.lua",
    [71585686583516] = "anime-dungeons.lua",
    [127204771568038] = "anime-dungeons.lua",
    [123509790592616] = "anime-dungeons.lua",
    [85662046383338] = "anime-dungeons.lua",
    [109955310601194] = "anime-dungeons.lua",
    [122377279703567] = "anime-dungeons.lua",
    [82475659339476] = "anime-dungeons.lua",
    [70972455539417] = "anime-dungeons.lua",
    [106947257450176] = "anime-dungeons.lua",
    [123913530595702] = "anime-dungeons.lua",
    [80761400409015] = "anime-dungeons.lua",
    [70863683083739] = "anime-dungeons-lobby.lua",
    [85580552562948] = "anime-powerscaling-card-collection.lua",
    [126229277218112] = "anime-rng-battles.lua",
    [104693964860826] = "anime-rng-defense.lua",
    [122553263569744] = "anime-stars.lua",
    [109715918987082] = "anime-stars-card-collection.lua",
    [95992966043247] = "anime-universe.lua",
    [96891089305948] = "become-an-anime-billionaire.lua",
    [118677256126351] = "bomb-fishing.lua",
    [132016691802922] = "build-a-base-and-steal.lua",
    [82441325527385] = "build-a-base-and-steal.lua",
    [134162299584012] = "build-a-gun-army.lua",
    [96645548064314] = "catch-and-tame.lua",
    [137233438285284] = "chicken-farm.lua",
    [84016394196827] = "clean-the-squishies.lua",
    [92605157087535] = "crab-tycoon.lua",
    [87555052900625] = "crunch-my-butter.lua",
    [77192431769439] = "digimon-era.lua",
    [113526284476060] = "dungeon-leveling-origin.lua",
    [132285059959516] = "dungeon-lootr.lua",
    [106484206883664] = "dungeon-lootr.lua",
    [74144293690546] = "egg-case-farm.lua",
    [10771129745] = "elemental-dungeons.lua",
    [10515146389] = "elemental-dungeons.lua",
    [15278089327] = "elemental-dungeons.lua",
    [85167011669131] = "fantasy-rng.lua",
    [78769336859161] = "farm-an-island.lua",
    [78292727217500] = "grow-it-rng.lua",
    [105420216739306] = "hatch-a-dragon.lua",
    [133294838637122] = "jump-to-steal-soccer-players.lua",
    [118575129990331] = "loot-rng.lua",
    [79315121100812] = "make-a-drill-farm.lua",
    [122391683154858] = "make-hotsauce.lua",
    [118605709428489] = "merge-a-blackhole.lua",
    [125927821145949] = "mine-a-mountain.lua",
    [121125129560252] = "mine-a-planet.lua",
    [112641748896693] = "missiles-vs-cities.lua",
    [133341016381877] = "mount-rng.lua",
    [112244246405144] = "my-fishing-anime.lua",
    [139546619723000] = "my-giant-sandwich.lua",
    [104065269680557] = "my-shrimp-farm.lua",
    [108364799245223] = "my-sword-empire.lua",
    [79267089300389] = "my-wood-farm.lua",
    [131906518201863] = "own-a-cafe.lua",
    [89561601601392] = "penguin-tycoon.lua",
    [103984418130080] = "place-the-keycaps.lua",
    [107099092059259] = "planet-rng.lua",
    [108307565942574] = "rng-heroes.lua",
    [91679585668032] = "roll-a-keycap.lua",
    [117752943664280] = "roll-a-pack.lua",
    [107706720875645] = "roll-anime.lua",
    [115113242795436] = "roll-anime-fighters.lua",
    [129559579789369] = "roll-to-defend.lua",
    [78105732598311] = "scratchy-loot.lua",
    [76113971506717] = "snowcone-stand.lua",
    [83988958116126] = "soccer-manager.lua",
    [136758055891411] = "spin-a-car.lua",
    [86789126516616] = "spin-a-duel-monster.lua",
    [107778070777162] = "steal-an-egg.lua",
    [82103875404639] = "tap-incremental.lua",
    [115681808123944] = "throw-a-coin.lua",
    [72042130041700] = "throw-a-coin.lua",
    [100875131717601] = "throw-a-coin.lua",
    [81335362752013] = "throw-a-coin.lua",
    [129972079094718] = "tnt-to-earths-core.lua",
    [71724366181884] = "world-cup-album.lua",
    [81440501385895] = "youtuber-card-collection.lua",
    [70790155462881] = "zombie-turret-farm.lua"
}

local gameFile = poops[game.PlaceId]
if not gameFile then return end

icon = "rbxassetid://119891081031642"

local function runScript()
    local content = game:HttpGet("https://raw.githubusercontent.com/hersheyzchoco-cmyk/ggs/refs/heads/main/games/" .. gameFile)
    content = content:gsub("rbxassetid://117487160988921", icon)
    loadstring(content)()
end

local keyPath = "PrismKey.txt"
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
