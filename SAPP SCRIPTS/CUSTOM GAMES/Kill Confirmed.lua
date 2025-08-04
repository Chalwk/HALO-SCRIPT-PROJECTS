--=====================================================================================================--
-- Script Name:      Kill Confirmed
-- Description:      Inspired by Call of Duty: Modern Warfare 3.
--
--                   - Teams score by collecting enemy dog tags (skulls) dropped on death.
--                   - First team to 65 points wins or highest score when time runs out.
--                   - Dog tags despawn after 30 seconds (configurable).
--                   - No penalty points for suicide.
--
--                   NOTE: Must be run on Team Slayer game mode.
--
-- Author:           Jericho Crosby (Chalwk)
-- Compatibility:    Halo PC/CE | SAPP 1.12.0.0
--
-- Copyright (c) 2021 Jericho Crosby <jericho.crosby227@gmail.com>
-- License:          MIT License
--                   https://github.com/Chalwk/HALO-SCRIPT-PROJECTS/blob/master/LICENSE
--=====================================================================================================--

local KillConfirmed = {
    score_limit = 65,
    points_on_confirm = 2,
    despawn_delay = 30,
    block_friendly_fire = true,
    dog_tag_object = "weapons\\ball\\ball",
    on_confirm = {
        "$name confirmed a kill on $victim",
        "$name confirmed $killer's kill on $victim"
    },
    on_deny = "$name denied $killer's kill",
    server_prefix = "**SAPP**",
    error_file = "Kill Confirmed (errors).log",
    script_version = 1.2
}

api_version = "1.12.0.0"

local function GetPlayerCoordinates(player)
    local dynamic_player = get_dynamic_player(player)
    if dynamic_player ~= 0 then
        local vehicle_id = read_dword(dynamic_player + 0x11C)
        local vehicle_object = get_object_memory(vehicle_id)
        if vehicle_id == 0xFFFFFFFF then
            return read_vector3d(dynamic_player + 0x5C)
        elseif vehicle_object ~= 0 then
            return read_vector3d(vehicle_object + 0x5C)
        end
    end
    return nil
end

local function DestroyDogTag(index, tag)
    destroy_object(tag.object)
    KillConfirmed.dog_tags[index] = nil
end

local function RemoveAllDogTags()
    for index, tag in pairs(KillConfirmed.dog_tags) do
        DestroyDogTag(index, tag)
    end
end

local function BroadcastMessage(message)
    execute_command("msg_prefix \"\"")
    say_all(message)
    execute_command("msg_prefix \" " .. KillConfirmed.server_prefix .. "\"")
end

local function UpdateTeamScore(player, add_points)
    local team = get_var(player, "$team")
    local score = (team == "red") and get_var(0, "$redscore") or get_var(0, "$bluescore")
    score = add_points and score + KillConfirmed.points_on_confirm or score - 1
    execute_command("team_score " .. ((team == "red") and 0 or 1) .. " " .. score)
end

local function UpdatePlayerScore(player, deduct, add)
    local score = tonumber(get_var(player, "$score"))
    if deduct then
        score = math.max(0, score - 1)
        UpdateTeamScore(player, false)
    elseif add then
        score = score + 1
    else
        UpdateTeamScore(player, true)
        score = score + KillConfirmed.points_on_confirm
    end
    execute_command("score " .. player .. " " .. score)
end

local function GetTagID(object)
    if object and object ~= 0 then
        return read_string(read_dword(read_word(object) * 32 + 0x40440038))
    end
    return nil
end

function KillConfirmed:Init()
    self.game_started = false
    self.dog_tags = {}
    RemoveAllDogTags()
    local game_type = get_var(0, "$gt")
    if game_type ~= "n/a" and self:RegisterEvents(game_type) then
        self.game_started = true
        execute_command("scorelimit " .. self.score_limit)
    end
end

function KillConfirmed:RegisterEvents(game_type)
    if game_type == "slayer" and get_var(0, "$ffa") == "0" then
        register_callback(cb["EVENT_TICK"], "OnTick")
        register_callback(cb["EVENT_DIE"], "DeathHandler")
        register_callback(cb["EVENT_WEAPON_PICKUP"], "OnWeaponPickUp")
        register_callback(cb["EVENT_DAMAGE_APPLICATION"], "DeathHandler")
        return true
    end
    unregister_callback(cb["EVENT_TICK"])
    unregister_callback(cb["EVENT_DIE"])
    unregister_callback(cb["EVENT_WEAPON_PICKUP"])
    unregister_callback(cb["EVENT_DAMAGE_APPLICATION"])
    error("This game type is not supported! Must be Team Slayer")
    return false
end

function KillConfirmed:SpawnNewTag(victim, killer)
    local x, y, z = GetPlayerCoordinates(victim)
    if x then
        local z_offset = 0.2
        local object = spawn_object("weap", self.dog_tag_object, x, y, z + z_offset)
        local tag = get_object_memory(object)
        self.dog_tags[tag] = {
            timer = 0,
            kid = killer,
            vid = victim,
            object = object,
            v_name = get_var(victim, "$name"),
            k_name = get_var(killer, "$name")
        }
    end
end

function OnScriptLoad()
    register_callback(cb["EVENT_GAME_END"], "OnGameEnd")
    register_callback(cb["EVENT_GAME_START"], "OnNewGame")
    KillConfirmed:Init()
end

function OnNewGame()
    KillConfirmed:Init()
end

function OnGameEnd()
    KillConfirmed.game_started = false
end

function OnTick()
    local KC = KillConfirmed
    if KC.game_started then
        for index, tag in pairs(KC.dog_tags) do
            tag.timer = tag.timer + 1 / 30
            if tag.timer >= KC.despawn_delay then
                DestroyDogTag(index, tag)
            end
        end
    end
end

function DeathHandler(victim, killer, meta_id)
    local KC = KillConfirmed
    local victim_id = tonumber(victim)
    local killer_id = tonumber(killer)
    if killer_id > 0 and KC.game_started then
        local killer_team = get_var(killer_id, "$team")
        local victim_team = get_var(victim_id, "$team")
        local is_suicide = (killer_id == victim_id)
        local is_friendly_fire = (killer_team == victim_team and not is_suicide)
        if meta_id then
            return (KC.block_friendly_fire and is_friendly_fire and false) or true
        end
        if not is_suicide and not is_friendly_fire then
            UpdatePlayerScore(killer_id, true, false)
            KC:SpawnNewTag(victim_id, killer_id)
        elseif is_suicide then
            UpdatePlayerScore(victim_id, false, true)
        end
    end
end

function OnWeaponPickUp(player, weapon_index, weapon_type)
    local KC = KillConfirmed
    if tonumber(weapon_type) == 1 and KC.game_started then
        local dynamic_player = get_dynamic_player(player)
        if dynamic_player ~= 0 then
            local weapon = read_dword(dynamic_player + 0x2F8 + (tonumber(weapon_index) - 1) * 4)
            local object = get_object_memory(weapon)
            if object ~= 0 and GetTagID(object) == KC.dog_tag_object then
                for index, tag in pairs(KC.dog_tags) do
                    if index == object then
                        local team = get_var(player, "$team")
                        local name = get_var(player, "$name")
                        local confirmed = (player == tag.kid) or (team == get_var(tag.kid, "$team"))
                        local denied = (player == tag.vid) or (team == get_var(tag.vid, "$team"))
                        local message = (tag.kid == player and KC.on_confirm[1]) or KC.on_confirm[2]
                        if confirmed then
                            UpdatePlayerScore(player, false, false)
                        elseif denied then
                            message = KC.on_deny
                        end
                        message = message:gsub("$name", name):gsub("$killer", tag.k_name):gsub("$victim", tag.v_name)
                        BroadcastMessage(message)
                        DestroyDogTag(index, tag)
                        break
                    end
                end
            end
        end
    end
end

function OnScriptUnload()
    RemoveAllDogTags()
end