--[[
    ------------------------------------
    Description: HPC OnNameRequest, Phasor V2+
    Copyright (c) 2016-2018
    * Author: Jericho Crosby
    * IGN: Chalwk
    * Written and Created by Jericho Crosby
    -----------------------------------
]]--

function OnNameRequest(hash, name)
    local timestamp = os.date("%H:%M:%S - %d/%m/%Y")
    hprintf("---------------------------------------------------------------------------------------------------")
    hprintf("            - - |   P L A Y E R   A T T E M P T I N G   T O   J O I N   | - -")
    hprintf("                 - - - - - - - - - - - - - - - - - - - - - - - - - - - -                    ")
    hprintf("Player Name: " .. name)
    hprintf("CD Hash: " .. hash)
    hprintf("Join Time: " .. timestamp)
    return nil
end

function OnPlayerLeave(player)

    local timestamp = os.date("%H:%M:%S, %d/%m/%Y:")
    local name = getname(player)
    local id = resolveplayer(player)
    local port = getport(player)
    local ip = getip(player)
    local ping = readword(getplayer(player) + 0xDC)
    local hash = gethash(player)

    hprintf("P L A Y E R   Q U I T   T H E   G A M E")
    hprintf("-  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -")
    hprintf(name .. " (" .. id .. ")   -   Quit The Game.")
    hprintf("IP Address: (" .. ip .. ")  Quit Time: (" .. timestamp .. ")  Player Ping: (" .. ping .. ")")
    hprintf("CD Hash: " .. hash)
    hprintf("-  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -")

end

function OnPlayerJoin(player)
    local name = getname(player)
    local hash = gethash(player)
    local ip = getip(player)
    local port = getport(player)
    local ping = readword(getplayer(player) + 0xDC)
    local id = resolveplayer(player)
    local player_team = getteam(player)
    if team_play then
        if player_team == 0 then
            player_team = "the Red Team."
        elseif player_team == 1 then
            player_team = "the Blue Team."
        else
            player_team = "Hidden"
        end
    else
        player_team = "the FFA"
    end
    hprintf("Access:   " .. name .. " connected successfully.")
    hprintf("Connection Details:   IP:  (" .. ip .. "),   Port:  (" .. port .. "),  Ping:  (" .. ping .. ")")
    hprintf("Assigned ID number:   (" .. id .. ")")
    hprintf("Team:   {" .. tostring(player) .. "} has been assigned to " .. player_team)
    hprintf("---------------------------------------------------------------------------------------------------")
end    