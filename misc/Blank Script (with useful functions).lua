api_version = '1.12.0.0'

-- This function is called when the script is loaded. It registers various callbacks
-- for different game events, allowing the script to respond to those events.
function OnScriptLoad()
    register_callback(cb['EVENT_ECHO'], 'OnEcho') -- Triggered when an event is echoed.
    register_callback(cb['EVENT_SNAP'], 'OnSnap') -- Triggered when a player's snap score is updated.
    register_callback(cb['EVENT_CAMP'], 'OnCamp') -- Triggered when a player achieves camp kills.
    register_callback(cb['EVENT_WARP'], 'OnWarp') -- Triggered when a player warps.
    register_callback(cb['EVENT_TICK'], 'OnTick') -- Triggered every tick of the game.
    register_callback(cb['EVENT_LOGIN'], 'OnLogin') -- Triggered when a player logs into the server.
    register_callback(cb['EVENT_SCORE'], 'OnScore') -- Triggered when a player's score is updated.
    register_callback(cb['EVENT_BETRAY'], 'OnBetray') -- Triggered when a player betrays another.
    register_callback(cb['EVENT_SUICIDE'], 'OnSuicide') -- Triggered when a player commits suicide.
    register_callback(cb['EVENT_GAME_END'], 'OnGameEnd') -- Triggered when the game ends.
    register_callback(cb['EVENT_GAME_START'], 'OnNewGame') -- Triggered when a new game starts.
    register_callback(cb['EVENT_MAP_RESET'], 'OnMapReset') -- Triggered when the map is reset.
    register_callback(cb['EVENT_AREA_EXIT'], 'OnAreaExit') -- Triggered when a player exits an area.
    register_callback(cb['EVENT_AREA_ENTER'], 'OnAreaEnter') -- Triggered when a player enters an area.
    register_callback(cb['EVENT_TEAM_SWITCH'], 'OnTeamSwitch') -- Triggered when a player switches teams.
    register_callback(cb['EVENT_WEAPON_DROP'], 'OnWeaponDrop') -- Triggered when a player drops a weapon.
    register_callback(cb['EVENT_JOIN'], 'OnPlayerJoin') -- Triggered when a player joins the game.
    register_callback(cb['EVENT_CHAT'], 'OnPlayerChat') -- Triggered when a player sends a chat message.
    register_callback(cb['EVENT_KILL'], 'OnPlayerKill') -- Triggered when a player kills another player.
    register_callback(cb['EVENT_ALIVE'], 'OnCheckAlive') -- Triggered to check if a player is alive.
    register_callback(cb['EVENT_DIE'], 'OnPlayerDeath') -- Triggered when a player dies.
    register_callback(cb['EVENT_SPAWN'], 'OnPlayerSpawn') -- Triggered when a player spawns.
    register_callback(cb['EVENT_LEAVE'], 'OnPlayerLeave') -- Triggered when a player leaves the game.
    register_callback(cb['EVENT_OBJECT_SPAWN'], 'OnObjectSpawn') -- Triggered when an object spawns in the game.
    register_callback(cb['EVENT_VEHICLE_EXIT'], 'OnVehicleExit') -- Triggered when a player exits a vehicle.
    register_callback(cb['EVENT_WEAPON_PICKUP'], 'OnWeaponPickup') -- Triggered when a player picks up a weapon.
    register_callback(cb['EVENT_VEHICLE_ENTER'], 'OnVehicleEntry') -- Triggered when a player enters a vehicle.
    register_callback(cb['EVENT_COMMAND'], 'OnServerCommand') -- Triggered when a command is executed on the server.
    register_callback(cb['EVENT_PREJOIN'], 'OnPlayerPrejoin') -- Triggered before a player joins the game.
    register_callback(cb['EVENT_PRESPAWN'], 'OnPlayerPrespawn') -- Triggered before a player spawns.
    register_callback(cb['EVENT_DAMAGE_APPLICATION'], 'OnDamageApplication') -- Triggered when damage is applied to a player.
end

-- This function is called when the script is unloaded. It can be used to clean up resources.
function OnScriptUnload()

end

-- This function is triggered when an event is echoed.
function OnEcho()

end

-- This function is triggered when a player's snap score is updated.
-- It can be used to perform actions based on the player's score.
-- @param PlayerIndex (number) | The player's index.
-- @param SnapScore (number) | The player's snap score.
function OnSnap(PlayerIndex, SnapScore)

end

-- This function is triggered when a player achieves camp kills.
-- It can be used to reward or track camping players.
-- @param PlayerIndex (number) | The player's index.
-- @param CampKills (number) | The number of camp kills achieved by the player.
function OnCamp(PlayerIndex, CampKills)

end

-- This function is triggered when a player warps in the game.
-- It can be used for logging or notifications about player movement.
-- @param PlayerIndex (number) | The player's index.
function OnWarp(PlayerIndex)

end

-- This function is triggered when a player logs into the server.
-- It can be used to welcome the player or perform initial setup.
-- @param PlayerIndex (number) | The player's index.
function OnLogin(PlayerIndex)

end

-- This function is triggered when a player's score is updated.
-- It can be used to display score notifications or updates.
-- @param PlayerIndex (number) | The player's index.
function OnScore(PlayerIndex)

end

-- This function is triggered every tick of the game.
-- It can be used for continuous checks or updates.
function OnTick()

end

-- This function is triggered when a player betrays another player.
-- It can be used for logging betrayals or punishing players.
-- @param PlayerIndex (number) | The index of the player who betrayed.
-- @param VictimIndex (number) | The index of the victim player.
function OnBetray(PlayerIndex, VictimIndex)

end

-- This function is triggered when a player commits suicide.
-- It can be used for tracking player deaths or for statistics.
-- @param PlayerIndex (number) | The player's index.
function OnSuicide(PlayerIndex)

end

-- This function is triggered when the game ends.
-- It can be used for logging end-of-game statistics or cleanup.
function OnGameEnd()

end

-- This function is triggered when a new game starts.
-- It can be used to initialize game settings or notify players.
function OnNewGame()

end

-- This function is triggered when the map is reset.
-- It can be used for resetting game state or notifying players.
function OnMapReset()

end

-- This function is triggered when a player exits an area.
-- It can be used for tracking player movements or notifying players.
-- @param PlayerIndex (number) | The player's index.
-- @param AreaName (string) | The name of the area exited.
function OnAreaExit(PlayerIndex, AreaName)

end

-- This function is triggered when a player enters an area.
-- It can be used for tracking player movements or notifying players.
-- @param PlayerIndex (number) | The player's index.
-- @param AreaName (string) | The name of the area entered.
function OnAreaEnter(PlayerIndex, AreaName)

end

-- This function is triggered when a player switches teams.
-- It can be used for tracking team changes or notifying players.
-- @param PlayerIndex (number) | The player's index.
function OnTeamSwitch(PlayerIndex)

end

-- This function is triggered when a player joins the game.
-- It can be used to welcome the player or perform initial setup.
-- @param PlayerIndex (number) | The player's index.
function OnPlayerJoin(PlayerIndex)

end

-- This function is triggered when a player sends a chat message.
-- It can be used to log chat messages or enforce chat rules.
-- @param PlayerIndex (number) | The player's index.
-- @param Message (string) | The chat message sent by the player.
-- @param Type (string) | The type of chat (e.g., public, private).
function OnPlayerChat(PlayerIndex, Message, Type)

end

-- This function is triggered when a player drops a weapon.
-- It can be used to track weapon drops or notify players.
-- @param PlayerIndex (number) | The player's index.
-- @param Slot (number) | The slot from which the weapon was dropped.
function OnWeaponDrop(PlayerIndex, Slot)

end

-- This function is triggered when a player kills another player.
-- It can be used to track kills or notify players about the kill.
-- @param PlayerIndex (number) | The index of the player who killed.
-- @param VictimIndex (number) | The index of the victim player.
function OnPlayerKill(PlayerIndex, VictimIndex)

end

-- This function is triggered to check if a player is alive.
-- It can be used for health checks or to prevent actions if the player is dead.
function OnCheckAlive()

end

-- This function is triggered when a player dies.
-- It can be used for tracking deaths or notifying players about the death.
-- @param PlayerIndex (number) | The index of the player who died.
-- @param KillerIndex (number) | The index of the player who killed.
function OnPlayerDeath(PlayerIndex, KillerIndex)

end

-- This function is triggered when a player spawns in the game.
-- It can be used for notifications or setting up the player's state.
-- @param PlayerIndex (number) | The player's index.
function OnPlayerSpawn(PlayerIndex)

end

-- This function is triggered when a player leaves the game.
-- It can be used for logging player exits or updating player counts.
-- @param PlayerIndex (number) | The player's index.
function OnPlayerLeave(PlayerIndex)

end

-- This function is triggered when an object spawns in the game.
-- It can be used to track objects or notify players.
-- @param ObjectId (number) | The ID of the spawned object.
function OnObjectSpawn(ObjectId)

end

-- This function is triggered when a player exits a vehicle.
-- It can be used for tracking vehicle exits or notifying players.
-- @param PlayerIndex (number) | The player's index.
-- @param VehicleId (number) | The ID of the vehicle exited.
function OnVehicleExit(PlayerIndex, VehicleId)

end

-- This function is triggered when a player picks up a weapon.
-- It can be used for tracking weapon pickups or notifying players.
-- @param PlayerIndex (number) | The player's index.
-- @param WeaponId (number) | The ID of the weapon picked up.
function OnWeaponPickup(PlayerIndex, WeaponId)

end

-- This function is triggered when a player enters a vehicle.
-- It can be used for tracking vehicle entries or notifying players.
-- @param PlayerIndex (number) | The player's index.
-- @param VehicleId (number) | The ID of the vehicle entered.
function OnVehicleEntry(PlayerIndex, VehicleId)

end

-- This function is triggered when a command is executed on the server.
-- It can be used for logging commands or enforcing command rules.
-- @param PlayerIndex (number) | The player's index.
-- @param Command (string) | The command executed.
function OnServerCommand(PlayerIndex, Command)

end

-- This function is triggered before a player joins the game.
-- It can be used to perform checks or notifications.
-- @param PlayerIndex (number) | The player's index.
function OnPlayerPrejoin(PlayerIndex)

end

-- This function is triggered before a player spawns in the game.
-- It can be used for setting up the player's state before they spawn.
-- @param PlayerIndex (number) | The player's index.
function OnPlayerPrespawn(PlayerIndex)

end

-- This function is triggered when damage is applied to a player.
-- It can be used for tracking damage or implementing damage rules.
-- @param PlayerIndex (number) | The player's index.
-- @param Damage (number) | The amount of damage applied.
function OnDamageApplication(PlayerIndex, Damage)

end