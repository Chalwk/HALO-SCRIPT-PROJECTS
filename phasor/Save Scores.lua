--[[
------------------------------------
Description: HPC Save Scores, Phasor V2+
Copyright (c) 2016-2018
* Author: Jericho Crosby
* IGN: Chalwk
* Written and Created by Jericho Crosby
-----------------------------------
]]--

math.inf = 1 / 0
UpdateScores = false
function OnScriptUnload()
end
function GetRequiredVersion()
    return 200
end
function OnScriptLoad(processid, game, persistent)
end
function OnPlayerJoin(player)
    if UpdateScores == true then
        LoadScores(player)
    end
end

function OnNewGame(map)
    local dir = getprofilepath()
    local file = loadfile(dir .. "\\data\\Scores.tmp")
    if file then
        score = table.load("Scores.tmp")
        UpdateScores = true
        os.remove(dir .. "\\data\\Scores.tmp")
        registertimer(1000 * 60 * 5, "WipeScores")
    end
end

function WipeScores(id, count)
    UpdateScores = false
    score = { }
    return 0
end

function OnServerCommand(player, command)
    if command == "sv_mnext" or command == "sv_mapcycle_begin" then
        SaveScores()
    end
end

function StandBy()
    for i = 0, 15 do
        if getplayer(i) then
            privatesay(i, "* Server restarting for maintenance or repair. Your scores will be restored!", false)
            privatesay(i, "Please Stand by...", false)
        end
    end
end

function SaveScores()
    score = { }
    for i = 0, 15 do
        if getplayer(i) then
            local hash = gethash(i)
            score[hash] = { }
            score[hash].s = readword(getplayer(i) + 0xC8)
            score[hash].kills = readword(getplayer(i) + 0x9C)
            score[hash].assists = readword(getplayer(i) + 0xA4)
            score[hash].deaths = readword(getplayer(i) + 0xAE)
            StandBy()
        end
    end
    table.save(score, "Scores.tmp")
end

function LoadScores(player)
    local hash = gethash(player)
    if score[hash] then
        if getplayer(player) then
            writeword(getplayer(player) + 0xC8, score[hash].s)
            writeword(getplayer(player) + 0xAE, score[hash].deaths)
            writeword(getplayer(player) + 0xA4, score[hash].assists)
            writeword(getplayer(player) + 0x9C, score[hash].kills)
            say("Your Scores have been restored!\nThank you for your patience.")
            hprintf("{" .. player .. "}'s scores were re-loaded")
        end
    end
end

function table.save(t, filename)

    local dir = getprofilepath()
    local file = io.open(dir .. "\\data\\" .. filename, "w")
    local spaces = 0

    local function tab()

        local str = ""
        for i = 1, spaces do
            str = str .. " "
        end

        return str
    end

    local function format(t)

        spaces = spaces + 4
        local str = "{ "

        for k, v in opairs(t) do
            if type(k) == "string" then
                k = string.format("%q", k)
            elseif k == math.inf then
                k = "1 / 0"
            end

            if type(v) == "string" then
                v = string.format("%q", v)
            elseif v == math.inf then
                v = "1 / 0"
            end

            if type(v) == "table" then
                if table.len(v) > 0 then
                    str = str .. "\n" .. tab() .. "[" .. k .. "] = " .. format(v) .. ","
                else
                    str = str .. "\n" .. tab() .. "[" .. k .. "] = {},"
                end
            else
                str = str .. "\n" .. tab() .. "[" .. k .. "] = " .. tostring(v) .. ","
            end
        end

        spaces = spaces - 4

        return string.sub(str, 1, string.len(str) - 1) .. "\n" .. tab() .. "}"
    end

    file:write("return " .. format(t))
    file:close()
end

function table.load(filename)

    local dir = getprofilepath()
    local file = loadfile(dir .. "\\data\\" .. filename)
    if file then
        return file() or { }
    end

    return { }
end

function table.len(t)

    local count = 0
    for k, v in pairs(t) do
        count = count + 1
    end

    return count
end

function table.find(t, v, case)

    if case == nil then
        case = true
    end

    for k, val in pairs(t) do
        if case then
            if v == val then
                return k
            end
        else
            if string.lower(v) == string.lower(val) then
                return k
            end
        end
    end
end

function table.max(t)

    local max = -math.inf
    local key

    for k, v in pairs(t) do
        if tonumber(v) then
            if tonumber(v) > max then
                key = k
                max = tonumber(v)
            end
        end
    end

    return key, max
end

function table.maxv(t)

    local max = -math.inf
    local key

    for k, v in pairs(t) do
        if tonumber(v) then
            if tonumber(v) > max then
                key = k
                max = tonumber(v)
            end
        end
    end

    return max
end

function table.maxes(t)

    local keys = { }
    local max = -math.inf
    for k, v in pairs(t) do
        if tonumber(v) then
            if tonumber(v) > max then
                max = tonumber(v)
            end
        end
    end

    for k, v in pairs(t) do
        if tonumber(v) == max then
            table.insert(keys, k)
        end
    end

    return keys, max
end

function table.sum(t, key)

    local sum = 0
    for k, v in pairs(t) do
        if type(v) == "table" then
            sum = sum + table.sum(v, key)
        elseif tonumber(v) then
            if key then
                if key == k then
                    sum = sum + tonumber(v)
                end
            else
                sum = sum + tonumber(v)
            end
        end
    end

    return sum
end

function opairs(t)

    local keys = { }
    for k, v in pairs(t) do
        table.insert(keys, k)
    end
    table.sort(keys,
            function(a, b)
                if type(a) == "number" and type(b) == "number" then
                    return a < b
                end
                an = string.lower(tostring(a))
                bn = string.lower(tostring(b))
                if an ~= bn then
                    return an < bn
                else
                    return tostring(a) < tostring(b)
                end
            end)
    local count = 1
    return function()
        if table.unpack(keys) then
            local key = keys[count]
            local value = t[key]
            count = count + 1
            return key, value
        end
    end
end

function rpairs(t)

    local keys = { }
    for k, v in pairs(t) do
        table.insert(keys, k)
    end
    table.sort(keys,
            function(a, b)
                if type(a) == "number" and type(b) == "number" then
                    return a > b
                end
                an = string.lower(tostring(a))
                bn = string.lower(tostring(b))
                if an ~= bn then
                    return an > bn
                else
                    return tostring(a) > tostring(b)
                end
            end)
    local count = 1
    return function()
        if table.unpack(keys) then
            local key = keys[count]
            local value = t[key]
            count = count + 1
            return key, value
        end
    end
end

function expairs(t, fn)

    local keys = { }
    for k, v in opairs(t) do
        if fn(k, v) then
            table.insert(keys, k)
        end
    end
    local count = 1
    return function()
        if table.unpack(keys) then
            local key = keys[count]
            local value = t[key]
            count = count + 1
            return key, value
        end
    end
end

function irand(min, max)

    local u = { }
    for i = min, max do
        table.insert(u, i)
    end
    return function()
        if table.unpack(u) then
            local rand = getrandomnumber(1, #u + 1)
            local value = u[rand]
            table.remove(u, rand)
            return value
        end
    end
end