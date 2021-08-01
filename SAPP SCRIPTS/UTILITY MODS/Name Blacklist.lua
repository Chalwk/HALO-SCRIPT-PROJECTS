--[[
--=====================================================================================================--
Script Name: Name Ban, for SAPP (PC & CE)
Description: Players have names that you don't like? No problem!

NOTE: This is not an anti-impersonator script!

Copyright (c) 2021, Jericho Crosby <jericho.crosby227@gmail.com>
* Notice: You can use this document subject to the following conditions:
https://github.com/Chalwk77/HALO-SCRIPT-PROJECTS/blob/master/LICENSE
--=====================================================================================================--
]]--

api_version = "1.12.0.0"

local NameBan = {

    -- When a player joins the server, their name is cross-checked against the BLACKLIST TABLE.
    -- If a match is made, their name will be changed to a random name from the below NAMES TABLE.


    --
    -- BLACKLIST TABLE:
    --
    blacklist = {
        "Hacker",
        "TᑌᗰᗷᗩᑕᑌᒪOᔕ",
        "TUMBACULOS",
    },


    --
    -- NAMES TABLE:
    --
    names = {
        { "iLoveAG" },
        { "iLoveV3" },
        { "loser4Eva" },
        { "iLoveChalwk" },
        { "iLoveSe7en" },
        { "iLoveAussie" },
        { "benDover" },
        { "clitEruss" },
        { "tinyDick" },
        { "cumShot" },
        { "PonyGirl" },
        { "iAmGroot" },
        { "twi$t3d" },
        { "maiBahd" },
        { "frown" },
        { "Laugh@me" },
        { "imaDick" },
        { "facePuncher" },
        { "TEN" },
        { "whatElse" },

        -- repeat the structure to add more entries
        --
        --
    }
}

local network_struct

function OnScriptLoad()

    register_callback(cb["EVENT_PREJOIN"], "OnPreJoin")
    register_callback(cb["EVENT_LEAVE"], "OnPlayerQuit")

    register_callback(cb["EVENT_GAME_START"], "OnGameStart")

    network_struct = read_dword(sig_scan("F3ABA1????????BA????????C740??????????E8????????668B0D") + 3)
    OnGameStart()
end

function NameBan:CheckNameExists(Ply)
    local name = get_var(Ply, "$name")
    for j = 1, #self.names do
        if (name == self.names[j][1]) then
            self.names[j][1].used = true
        end
    end
end

function OnGameStart()
    if (get_var(0, "$gt") ~= "n/a") then

        NameBan.players = { }

        for i = 1, #NameBan.names do
            NameBan.names[i].used = false
        end

        for i = 1, 16 do
            if player_present(i) then
                NameBan:CheckNameExists(i)
            end
        end
    end
end

function OnPlayerQuit(Ply)

    Ply = NameBan.players[Ply]
    if (Ply ~= nil) then
        NameBan.names[Ply].used = false
    end

    NameBan.players[Ply] = nil
end

function NameBan:GetRandomName(Ply)

    local t = { }
    for i = 1, #self.names do
        if (self.names[i][1]:len() < 12 and not self.names[i].used) then
            t[#t + 1] = { self.names[i][1], i }
        end
    end

    if (#t > 0) then

        local rand = rand(1, #t - 1)
        local name = t[rand][1]
        local n_id = t[rand][2]

        self.players[Ply] = n_id
        self.names[n_id].used = true

        return name
    end

    return "no name"
end

function NameBan:PreJoin(Ply)

    self:CheckNameExists(Ply)

    local name_on_join = get_var(Ply, "$name")
    for _, name in pairs(self.blacklist) do

        if (name_on_join == name) then

            local new_name = self:GetRandomName(Ply)

            local count = 0
            local address = network_struct + 0x1AA + 0x40 + to_real_index(Ply) * 0x20

            for _ = 1, 12 do
                write_byte(address + count, 0)
                count = count + 2
            end

            count = 0

            local str = new_name:sub(1, 11)
            local length = str:len()

            for j = 1, length do
                local new_byte = string.byte(str:sub(j, j))
                write_byte(address + count, new_byte)
                count = count + 2
            end

            break
        end
    end
end

function OnPreJoin(Ply)
    return NameBan:PreJoin(Ply)
end

return NameBan