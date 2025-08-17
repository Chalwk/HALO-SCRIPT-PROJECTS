local crNotice = {
    DOCUMENT = "HPC Crash Player, Phasor V2+.lua",
    VERSION = "1.1.0",
    DESCRIPTION = "This script will crash the user on join (based on IGN and Hash)",
    ENGINE = "Phasor V2+ (modified)",
    INTENDED = "Halo PC (Combat Evolved)",
    URL = "https://github.com/Chalwk",
    AUTHOR = "Jericho Crosby (Chalwk)",
    LICENSE = [[
        MIT LICENSE

        Copyright � 2018 Jericho Crosby <jericho.crosby227@gmail.com>

        Permission is hereby granted, free of charge, to any person obtaining a
        copy of this software and associated documentation files (the
        "Software"), to deal in the Software without restriction, including
        without limitation the rights to use, copy, modify, merge, publish,
        distribute, sublicense, and/or sell copies of the Software, and to
        permit persons to whom the Software is furnished to do so, subject to
        the following conditions:

        The above copyright notice and this permission notice shall be included
        in all copies or substantial portions of the Software.

        THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
        OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
        MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
        IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
        CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
        TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
        SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
      ]]
}

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

--[[ ======================================================= ]]--
-------------------------DO NOT REMOVE-------------------------
function printCRnotice()
    for k, v in pairs(crNotice) do
        print(k, v)
    end
end
-------------------------DO NOT REMOVE-------------------------
--[[ ======================================================= ]]--