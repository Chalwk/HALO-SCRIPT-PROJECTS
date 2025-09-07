Delay **tertiary** and **quaternary** assignments by `≥250ms` to prevent them from dropping.

```lua
api_version = '1.12.0.0'

local WEAPONS = {
    'weapons\\pistol\\pistol',
    'weapons\\sniper rifle\\sniper rifle',
    'weapons\\shotgun\\shotgun',
    'weapons\\assault rifle\\assault rifle'
}

-- Function to assign weapons to a player
local function assignWeapons(playerId)
    -- Delete the player's inventory first:
    execute_command('wdel ' .. playerId)

    -- Assign primary and secondary weapons immediately
    local primary_weapon = spawn_object('weap', WEAPONS[1], 0, 0, 0)
    local secondary_weapon = spawn_object('weap', WEAPONS[2], 0, 0, 0)
    
    assign_weapon(primary_weapon, playerId)
    assign_weapon(secondary_weapon, playerId)

    local tertiary_weapon = spawn_object('weap', WEAPONS[3], 0, 0, 0)
    local quaternary_weapon = spawn_object('weap', WEAPONS[4], 0, 0, 0)
    
    -- Assign tertiary and quaternary weapons with a delay
    timer(250, 'assign_weapon', tertiary_weapon, playerId)
    timer(500, 'assign_weapon', quaternary_weapon, playerId)
    
    -- Technical note: 
    -- SAPP's "assign_weapon" function will fail silently/safely if the player is dead.
end

function OnScriptLoad()
    register_callback(cb['EVENT_SPAWN'], 'OnSpawn')
end

-- Assign weapons when the player spawns:
function OnSpawn(playerId)
    assignWeapons(playerId)    
end

function OnScriptUnload() end
```