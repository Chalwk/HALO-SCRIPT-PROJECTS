--[[
--=====================================================================================================--
Script Name: Stun Grenades, for SAPP (PC & CE)
Description: Make frags and plasmas behave like stun grenades.

			 When someone is damaged by a grenade,
			 their speed is reduced to 0.5% for 5-10 seconds (depending on damage type).

			 Plasma explosion  = 5 seconds
			 Plasma sticky     = 10 seconds
			 Frag explosion    = 5 seconds

Copyright (c) 2019-2022, Jericho Crosby <jericho.crosby227@gmail.com>
Notice: You can use this script subject to the following conditions:
https://github.com/Chalwk/HALO-SCRIPT-PROJECTS/blob/master/LICENSE
--=====================================================================================================--
]]--

-- config starts --
local tags = {
    --
    -- format:
    -- {tag name, stun time, stun percent}
    --
    { 'weapons\\frag grenade\\explosion', 5, 0.5 },
    { 'weapons\\plasma grenade\\explosion', 5, 0.5 },
    { 'weapons\\plasma grenade\\attached', 10, 0.5 }
}
-- config ends --

api_version = '1.12.0.0'

local stuns = {}
local players = {}
local time = os.time

-- Register needed event callbacks:
function OnScriptLoad()
    register_callback(cb['EVENT_TICK'], 'OnTick')
    register_callback(cb['EVENT_GAME_START'], 'OnStart')
    register_callback(cb['EVENT_DAMAGE_APPLICATION'], "OnDamage")
    OnStart()
end

-- Return meta id of a tag address using its class and name:
local function GetTag(Class, Name)
    local tag = lookup_tag(Class, Name)
    return (tag ~= 0 and read_dword(tag + 0xC) or 0)
end

-- Returns a table where the key of the table is the meta id and the value is
-- a table containing the stun time and stun percent for that tag.
-- Reason: So we don't have to keep making calls to GetTag() every time we want to check a tag.
local function TagsToID()
    local t = {}

    for i = 1, #tags do

        local v = tags[i]
        local name = v[1]
        local tag = GetTag('jpt!', name)

        if (tag ~= 0) then
            local stun_time = v[2]
            local stun_percent = v[3]
            t[tag] = { stun_time, stun_percent }
        end
    end

    return t
end

-- Called when the game starts:
function OnStart()
    if (get_var(0, '$gt') ~= 'n/a') then
        players = { }
        stuns = TagsToID()
    end
end

-- Called every tick (1/30th second)
function OnTick()
    for i, player in pairs(players) do
        if (i) and player_alive(i) then
            if (player.start() < player.finish) then
                execute_command('s ' .. i .. ' ' .. player.stun_percent)
            else
                execute_command('s ' .. i .. ' 1')
                players[i] = nil
            end
        elseif (i) and (not player_alive(i)) then
            players[i] = nil
        end
    end
end

-- Called when a player receives damage:
function OnDamage(Victim, Killer, MetaID)

    victim = tonumber(Victim)
    killer = tonumber(Killer)

    local pvp = (killer > 0 and victim ~= killer)

    if (pvp and stuns[MetaID]) then

        local stun_time = stuns[MetaID][1]
        local stun_percent = stuns[MetaID][2]

        players[victim] = {
            start = time,
            finish = time() + stun_time,
            stun_percent = stun_percent,
        }
    end
end

function OnScriptUnload()
    -- N/A
end