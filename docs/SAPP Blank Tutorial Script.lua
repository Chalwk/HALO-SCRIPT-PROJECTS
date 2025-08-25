api_version = '1.12.0.0'

--[[
SAPP Tutorial Script
This script demonstrates how to use various SAPP event callbacks.
Server operators can use this as a starting point for their own scripts.
]]

function OnScriptLoad()
    -- Register all event callbacks
    -- Game State Events
    register_callback(cb['EVENT_GAME_START'], 'OnNewGame')
    register_callback(cb['EVENT_GAME_END'], 'OnGameEnd')
    register_callback(cb['EVENT_MAP_RESET'], 'OnMapReset')
    register_callback(cb['EVENT_TICK'], 'OnTick')

    -- Player Lifecycle Events
    register_callback(cb['EVENT_PREJOIN'], 'OnPlayerPrejoin')
    register_callback(cb['EVENT_JOIN'], 'OnPlayerJoin')
    register_callback(cb['EVENT_LEAVE'], 'OnPlayerLeave')
    register_callback(cb['EVENT_PRESPAWN'], 'OnPlayerPrespawn')
    register_callback(cb['EVENT_SPAWN'], 'OnPlayerSpawn')
    register_callback(cb['EVENT_ALIVE'], 'OnCheckAlive')
    register_callback(cb['EVENT_DIE'], 'OnPlayerDeath')

    -- Player Action Events
    register_callback(cb['EVENT_CHAT'], 'OnPlayerChat')
    register_callback(cb['EVENT_KILL'], 'OnPlayerKill')
    register_callback(cb['EVENT_SUICIDE'], 'OnSuicide')
    register_callback(cb['EVENT_BETRAY'], 'OnBetray')
    register_callback(cb['EVENT_SCORE'], 'OnScore')
    register_callback(cb['EVENT_LOGIN'], 'OnLogin')
    register_callback(cb['EVENT_TEAM_SWITCH'], 'OnTeamSwitch')

    -- Anti-Cheat Events
    register_callback(cb['EVENT_SNAP'], 'OnSnap')
    register_callback(cb['EVENT_CAMP'], 'OnCamp')
    register_callback(cb['EVENT_WARP'], 'OnWarp')

    -- Object Interaction Events
    register_callback(cb['EVENT_WEAPON_DROP'], 'OnWeaponDrop')
    register_callback(cb['EVENT_WEAPON_PICKUP'], 'OnWeaponPickup')
    register_callback(cb['EVENT_VEHICLE_ENTER'], 'OnVehicleEntry')
    register_callback(cb['EVENT_VEHICLE_EXIT'], 'OnVehicleExit')
    register_callback(cb['EVENT_OBJECT_SPAWN'], 'OnObjectSpawn')

    -- Area Events
    register_callback(cb['EVENT_AREA_ENTER'], 'OnAreaEnter')
    register_callback(cb['EVENT_AREA_EXIT'], 'OnAreaExit')

    -- Command and Damage Events
    register_callback(cb['EVENT_COMMAND'], 'OnServerCommand')
    register_callback(cb['EVENT_DAMAGE_APPLICATION'], 'OnDamageApplication')
    register_callback(cb['EVENT_ECHO'], 'OnEcho')
end

function OnScriptUnload()
    -- Cleanup code when script is unloaded
    -- Unregister timers, free resources, etc.
end

-- Game State Events
function OnNewGame()
    -- Called when a new game starts
    -- Good for initializing game-specific variables
end

function OnGameEnd()
    -- Called when the game ends
    -- Good for cleanup or saving statistics
end

function OnMapReset()
    -- Called when sv_map_reset is executed
    -- Resets the map without changing game variant
end

function OnTick()
    -- Called every game tick (approximately 30 times per second)
    -- Use for frequent checks or updates
end

-- Player Lifecycle Events
function OnPlayerPrejoin(PlayerIndex)
    -- Called when a player is joining but not fully connected yet
    -- Can be used to block players before they fully join
end

function OnPlayerJoin(PlayerIndex)
    -- Called when a player has successfully joined the server
    -- Good for welcome messages or initializing player data
end

function OnPlayerLeave(PlayerIndex)
    -- Called when a player disconnects from the server
    -- Good for cleanup of player-specific data
end

function OnPlayerPrespawn(PlayerIndex)
    -- Called when a player is about to spawn
    -- Can modify player properties before they spawn
end

function OnPlayerSpawn(PlayerIndex)
    -- Called after a player has spawned
    -- Good for giving items or setting up player state
end

function OnCheckAlive(PlayerIndex)
    -- Called every second for each alive player
    -- Good for periodic checks on living players
end

function OnPlayerDeath(PlayerIndex, KillerIndex)
    -- Called when a player dies
    -- PlayerIndex: who died
    -- KillerIndex: who caused the death (-1 for suicide, 0 for environment)
end

-- Player Action Events
function OnPlayerChat(PlayerIndex, Message, Type)
    -- Called when a player sends a chat message
    -- Return false to block the message
    -- Type: 0 = global, 1 = team, 2 = vehicle chat
end

function OnPlayerKill(PlayerIndex, VictimIndex)
    -- Called when a player gets a kill
    -- PlayerIndex: who got the kill
    -- VictimIndex: who was killed
end

function OnSuicide(PlayerIndex)
    -- Called when a player commits suicide
end

function OnBetray(PlayerIndex, VictimIndex)
    -- Called when a player betrays a teammate
end

function OnScore(PlayerIndex)
    -- Called when a player scores (in objective games)
end

function OnLogin(PlayerIndex)
    -- Called when a player successfully logs in as admin
end

function OnTeamSwitch(PlayerIndex)
    -- Called when a player changes teams
end

-- Anti-Cheat Events
function OnSnap(PlayerIndex, SnapScore)
    -- Called when anti-cheat detects snapping (aimbot behavior)
    -- SnapScore: the calculated snap score
end

function OnCamp(PlayerIndex, CampKills)
    -- Called when anti-camp detects camping behavior
    -- CampKills: number of kills while camping
end

function OnWarp(PlayerIndex)
    -- Called when anti-warp detects warping (lag switching)
end

-- Object Interaction Events
function OnWeaponDrop(PlayerIndex, Slot)
    -- Called when a player drops a weapon
    -- Slot: which weapon slot was dropped
end

function OnWeaponPickup(PlayerIndex, WeaponId)
    -- Called when a player picks up a weapon
    -- WeaponId: the object ID of the picked up weapon
end

function OnVehicleEntry(PlayerIndex, VehicleId)
    -- Called when a player enters a vehicle
    -- VehicleId: the object ID of the vehicle entered
end

function OnVehicleExit(PlayerIndex, VehicleId)
    -- Called when a player exits a vehicle
    -- VehicleId: the object ID of the vehicle exited
end

function OnObjectSpawn(ObjectId)
    -- Called when an object spawns in the game
    -- ObjectId: the object ID of the spawned object
end

-- Area Events
function OnAreaEnter(PlayerIndex, AreaName)
    -- Called when a player enters a defined area
    -- AreaName: the name of the area entered
end

function OnAreaExit(PlayerIndex, AreaName)
    -- Called when a player exits a defined area
    -- AreaName: the name of the area exited
end

-- Command and Damage Events
function OnServerCommand(PlayerIndex, Command)
    -- Called when a command is executed on the server
    -- Return false to block the command
end

function OnDamageApplication(PlayerIndex, Damage)
    -- Called when damage is applied to a player
    -- Can modify or block damage before it's applied
    -- Return false to block the damage
end

function OnEcho()
    -- Called when command output is echoed to console
end
