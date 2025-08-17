api_version = '1.12.0.0'

-- Table to store weapon weights and configuration
local WeaponWeights = {

    -- Default player speed
    default_speed = 1.0,

    -- Flag to determine if weights of all weapons in inventory should be combined
    combined = false,

    -- Table mapping weapon tags to their respective weights
    -- To simulate weapon weight in-game, the speed of the player is reduced by the weight of the weapon
    weapons = {
        ['weapons\\flag\\flag'] = 0.056,
        ['weapons\\ball\\ball'] = 0.056,
        ['weapons\\pistol\\pistol'] = 0.072,
        ['weapons\\plasma pistol\\plasma pistol'] = 0.072,
        ['weapons\\needler\\mp_needler'] = 0.084,
        ['weapons\\plasma rifle\\plasma rifle'] = 0.084,
        ['weapons\\shotgun\\shotgun'] = 0.094,
        ['weapons\\assault rifle\\assault rifle'] = 0.122,
        ['weapons\\flamethrower\\flamethrower'] = 0.140,
        ['weapons\\sniper rifle\\sniper rifle'] = 0.146,
        ['weapons\\plasma_cannon\\plasma_cannon'] = 0.190,
        ['weapons\\rocket launcher\\rocket launcher'] = 0.200
    }
}

-- Table to store weapon weights
local weight = {}

-- Function called when the script is loaded
function OnScriptLoad()
    register_callback(cb['EVENT_TICK'], 'OnTick')
    register_callback(cb['EVENT_GAME_START'], 'OnStart')
end

-- Function to get the tag ID of a weapon
-- @param class The class of the tag
-- @param name The name of the tag
-- @return The tag ID or nil if not found
local function getTag(class, name)
    local tag = lookup_tag(class, name)
    return (tag ~= 0 and read_dword(tag + 0xC)) or nil
end

-- Function to map weapon tags to their respective weights
-- @param t Table containing weapon tags and their weights
local function tagsToID(t)
    for name, speed in pairs(t) do
        local tag = getTag('weap', name)
        if tag then
            weight[tag] = speed
        end
    end
end

-- Function called when the game starts
function OnStart()
    -- Check if the game type is not 'n/a'
    if get_var(0, '$gt') ~= 'n/a' then
        weight = {}
        -- Map weapon tags to their weights
        tagsToID(WeaponWeights.weapons)
    end
end

-- Function to get the weight of a weapon
-- @param weapon The weapon object ID
-- @return The weight of the weapon or 0 if not found
local function getWeight(weapon)
    local object = get_object_memory(weapon)
    if object == 0 or weapon == 0xFFFFFFFFF then
        return 0
    end
    return weight[read_dword(object)] or 0
end

-- Function to get the speed of a player
-- @param player The player ID
-- @return The speed of the player
local function getSpeed(player)
    local dyn = get_dynamic_player(player)
    if dyn == 0 or not player_alive(player) then
        return WeaponWeights.default_speed
    end

    -- If combined is false, then we will only use the weapon in the player's hand
    if not WeaponWeights.combined then
        return WeaponWeights.default_speed - getWeight(read_dword(dyn + 0x118))
    end

    -- Otherwise, we will use all weapons in the player's inventory
    local speed = WeaponWeights.default_speed
    for i = 0, 3 do
        speed = speed - getWeight(read_dword(dyn + 0x2F8 + i * 4))
    end

    return math.max(speed, 0)
end

-- Function called on each tick event
function OnTick()
    for i = 1, 16 do
        local dyn = get_dynamic_player(i)
        if player_present(i) and player_alive(i) and dyn ~= 0 then
            local speed = getSpeed(i)
            print("New Speed: " .. speed)
            execute_command('s ' .. i .. ' ' .. speed)
        end
    end
end

-- Function called when the script is unloaded
function OnScriptUnload()
    -- N/A
end