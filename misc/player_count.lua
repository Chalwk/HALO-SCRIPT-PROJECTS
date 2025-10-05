-- CONFIG start ------------------------
local POLL_INTERVAL = 1 -- How often (in seconds to update player count)

local BOT_NAMES = {
    ["Donut"] = true,
    ["Penguin"] = true,
    ["Stumpy"] = true,
    ["Whicker"] = true,
    ["Shadow"] = true,
    ["Howard"] = true,
    ["Wilshire"] = true,
    ["Darling"] = true,
    ["Disco"] = true,
    ["Jack"] = true,
    ["The Bear"] = true,
    ["Sneak"] = true,
    ["The Big L"] = true,
    ["Whisp"] = true,
    ["Wheezy"] = true,
    ["Crazy"] = true,
    ["Goat"] = true,
    ["Pirate"] = true,
    ["Hambone"] = true,
    ["Butcher"] = true,
    ["Walla Walla"] = true,
    ["Snake"] = true,
    ["Caboose"] = true,
    ["Sleepy"] = true,
    ["Killer"] = true,
    ["Stompy"] = true,
    ["Mopey"] = true,
    ["Dopey"] = true,
    ["Weasel"] = true,
    ["Dasher"] = true,
    ["Grumpy"] = true,
    ["Hollywood"] = true,
    ["Tooth"] = true,
    ["Ghost"] = true,
    ["Noodle"] = true,
    ["King"] = true,
    ["Cupid"] = true,
    ["Prancer"] = true,
    ["Saucy"] = true
}
-- CONFIG end --------------------------

local file_path
api_version = '1.12.0.0'

local previous_count
local io_open = io.open
local get_var = get_var
local player_present = player_present

local function getConfigPath()
    return read_string(read_dword(sig_scan('68??????008D54245468') + 0x1))
end

local function isBot(name)
    return BOT_NAMES[name]
end

local function writeFile(count)
    local file = io_open(file_path, "w")
    if file then
        file:write(count)
        file:close()
    end
end

function UpdatePlayerCount()
    local count = 0
    for i = 1, 16 do
        if player_present(i) then
            local name = get_var(i, '$name')
            if not isBot(name) then
                count = count + 1
            end
        end
    end

    if count ~= previous_count then
        previous_count = count
        writeFile(count)
    end

    return true
end

function OnScriptLoad()
    local directory = getConfigPath()
    file_path = directory .. '\\sapp\\player_count.txt'
    UpdatePlayerCount()
    timer(1000 * POLL_INTERVAL, "UpdatePlayerCount")
end

function OnScriptUnload()
    writeFile(0)
end