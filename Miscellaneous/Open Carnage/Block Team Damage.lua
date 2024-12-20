--[[
--=====================================================================================================--
Script Name: Block Team Damage, for SAPP (PC & CE)
Description: Prevent grenades/rocket launcher damage from killing teammates.

Designed in response to this post: https://opencarnage.net/index.php?/topic/8587-friendly-fire-desync/

Copyright (c) 2022, Jericho Crosby <jericho.crosby227@gmail.com>
Notice: You can use this script subject to the following conditions:
https://github.com/Chalwk/HALO-SCRIPT-PROJECTS/blob/master/LICENSE
--=====================================================================================================--
]]--

-- config starts:
local jpt_tags = {
    'weapons\\rocket launcher\\explosion',
    'weapons\\frag grenade\\explosion',
    'weapons\\plasma grenade\\attached',
    'weapons\\plasma grenade\\explosion',
}
-- config ends

api_version = "1.12.0.0"

local meta_ids = {}

function OnScriptLoad()
    register_callback(cb['EVENT_GAME_START'], 'OnStart')
    OnStart()
end

local function GetTag(Type, Name)
    local Tag = lookup_tag(Type, Name)
    return Tag ~= 0 and read_dword(Tag + 0xC) or nil
end

local function GetJPTTags()
    meta_ids = {}
    for _, tag in ipairs(jpt_tags) do
        local id = GetTag('jpt!', tag)
        if id then
            meta_ids[id] = true
        end
    end
end

function OnStart()
    if get_var(0, '$gt') ~= 'n/a' and get_var(0, '$ffa') == '0' then
        register_callback(cb['EVENT_DAMAGE_APPLICATION'], 'BlockDamage')
        GetJPTTags()
    else
        unregister_callback(cb['EVENT_DAMAGE_APPLICATION'])
    end
end

function BlockDamage(Victim, Killer, MapID)
    local v_team = get_var(Victim, '$team')
    local k_team = get_var(Killer, '$team')
    return not (Killer ~= Victim and k_team == v_team and meta_ids[MapID])
end

function OnScriptUnload()
    -- N/A
end