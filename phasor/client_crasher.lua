-- Name: client_crasher.lua
-- Copyright (c) 2016-2018 Jericho Crosby (Chalwk)

function GetRequiredVersion()
    return 200
end

function OnScriptLoad()

    --  Load Name/Hash tables
    InitiateTables()
    printCRnotice()
end

function OnScriptUnload()

    --  Unload Name/Hash tables
    Victim_Name_Table = { }
    Victim_Hash_Table = { }
end

function InitiateTables()

    --  Player names have a maximum of 10 Characters
    Victim_Name_Table = {
        "billybob",
        "name-not-used",
        "name-not-used",
        "name-not-used"
    }

    Victim_Hash_Table = {
        "4d102436ecc0621415e81d21d5a39361", -- Example Hash
        "hash-not-used",
        "hash-not-used",
        "hash-not-used"
    }
end

function OnPlayerJoin(player)

    local VictimName = getname(player)
    local VictimHash = gethash(player)

    for i = 0, 15 do
        if getplayer(i) ~= nil then
            if table.HasValue(Victim_Name_Table, VictimName) and table.HasValue(Victim_Hash_Table, VictimHash) then
                svcmd("sv_crash " .. resolveplayer(i))
            end
        end
    end
end

function OnGameEnd()

    --  Unload Name/Hash tables
    InitiateTables()
end

function table.HasValue(table, value)
    for k, v in pairs(table) do
        if v == value then
            return k
        end
    end
end