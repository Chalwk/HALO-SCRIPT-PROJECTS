--[[
--=====================================================================================================--
Script Name: Zombies (v1.0), for SAPP (PC & CE)

-- Introduction --
Players in zombies matches are split into two teams: Humans (red team) and Zombies (blue team).
When a human dies, they switch to the zombie team. A human's goal is to remain alive (uninfected) until
the end of the round, while a zombie's goal is to kill (infect) as many humans as possible.

When only one human remains, that human becomes the "Last Man Standing".
The Last Man Standing is given unique player traits; including a waypoint revealing
their location to zombies, making survival an extreme challenge, among other traits.

The players who start a round as zombies are Alpha Zombies.
Alpha Zombies have unique player traits to distinguish them from standard zombies.

Zombies have melee weapons at their disposal and are capable of killing humans in a single blow.
Humans are given short - and medium-range firearms by default.

* See the bottom of this script for recommended game type settings.

Copyright (c) 2021, Jericho Crosby <jericho.crosby227@gmail.com>
* Notice: You can use this document subject to the following conditions:
https://github.com/Chalwk77/HALO-SCRIPT-PROJECTS/blob/master/LICENSE
--=====================================================================================================--
]]--

-- config starts --
local Zombies = {

    -- Time (in seconds) until a game begins:
    --
    game_start_delay = 5,

    -- Number of players required to start the game:
    --
    required_players = 2,

    -- When enabled, the script will broadcast a continuous message
    -- showing how many players are required to start the game.
    --
    show_not_enough_players_message = true,

    -- Time (in seconds) until a human is selected to become a zombie:
    --
    no_zombies_delay = 5,

    -- Human Team:
    --
    human_team = "red",

    -- Zombie Team:
    --
    zombie_team = "blue",

    -- Zombie Curing:
    -- When enabled, a zombie needs X (cure_threshold) consecutive kills to become human again.
    --
    zombies_can_be_cured = true,

    -- Cure Threshold:
    -- Number of kills required to become a human again:
    -- Do not set this value to 1 or curing will not work.
    --
    cure_threshold = 3,

    -- Regenerating Health (off by default):
    -- When enabled, the last man standing will have regenerating health (see attributes table).
    -- This feature is only practical if the zombie damage_multiplier is set to 1.
    --
    regenerating_health = false,

    -- Nav Marker (off by default):
    -- When enabled, the last man standing will have a nav marker above his head.
    --
    nav_marker = false,

    -- Player attributes:
    --
    attributes = {

        --[[

            ------------------------
            Notes on variables --
            ------------------------
            *   speed:                  Set to 0 to use map settings (1 = normal speed).
            *   health:                 Units of health range from 0 to 99999, (1 = normal health).
                                        Last Man has optional Health Regeneration that regenerates at increments of 0.0005 units per 30 ticks.

            *   respawn_time:           Range from 0-999 (in seconds).
            *   weapons:                Leave the array blank to use default weapon sets.
            *   damage_multiplier:      Units of damage range from 0-10.
            *   nav_marker              A NAV marker will appear above the last man standing's head.
            *   camo                    Alpha-Zombies and Standard Zombies have optional Crouch Camo traits.
            *   grenades                Allows you to define the starting number of frags & plasmas.
                                        Format: {frags [number], plasmas [number]}
                                        Example: {1, 3} = 1 frag, 3 plasmas

            --=====================================================================================================================--
            -- NOTES --

            Weapons:
            You can define up to four weapon tag names (see example below):

            weapons = { "weapons\\flag\\flag", "weapons\\pistol\\pistol", "weapons\\shotgun\\shotgun", "weapons\\ball\\ball" }
            See the "weapons" section of the "objects" table below (on or near line 261) for a full list of weapon tags.

            Nav Markers:
            If the Nav Marker attribute is enabled, the kill-in-order game type flag must be set to YES.
            The objectives indicator flag must also be set to NAV POINTS.

            Grenade Attributes:
            If you want to use game type settings for a specific grenade,
            set the grenade value to nil. For example: {1, nil}
            In the above example, the script will override the value for frags (by setting it to 1) but plasmas will use game mode settings.

            IMPORTANT:
            Zombies will only be able to use their grenades if they have been assigned a weapon other than the oddball or flag.
            This is a limitation with Halo, unfortunately.
            --=====================================================================================================================--

        --]]

        ["Alpha Zombies"] = {
            speed = 1.5,
            health = 2,
            camo = true,
            respawn_time = 1.5,
            grenades = { 0, 2 },
            damage_multiplier = 10,
            weapons = {
                "weapons\\shotgun\\shotgun",
                "weapons\\pistol\\pistol",
                "weapons\\plasma rifle\\plasma rifle",
                "weapons\\plasma pistol\\plasma pistol"
            }
        },

        ["Standard Zombies"] = {
            speed = 1,
            health = 1,
            camo = false,
            respawn_time = 2.5,
            grenades = { 0, 0 },
            damage_multiplier = 1,
            weapons = { "weapons\\ball\\ball" }
        },

        ["Humans"] = {
            speed = 1,
            health = 1,
            weapons = { },
            respawn_time = 3,
            grenades = { 2, 2 },
            damage_multiplier = 1
        },

        ["Last Man Standing"] = {
            speed = 1.5,
            weapons = { },
            respawn_time = 0,
            grenades = { 4, 4 },
            damage_multiplier = 1,
            health = {
                base = 1,
                increment = 0.0005
            }
        }
    },

    -- Game messages:
    --
    messages = {

        -- Continuous message announced when there aren't enough players:
        -- Variables:        $current (current players online [number])
        --                   $required (number of required players)
        --
        not_enough_players = "$current/$required players needed to start the game",

        -- Pre-Game message:
        -- Variables:        $time (time remaining until game begins)
        --                   $s placeholder to pluralize the word "seconds" (if $time is >1)
        --
        pre_game_message = "Game will begin in $time second$s",

        -- End of Game message:
        -- Variables:        $team (team name [string])
        --
        end_of_game = "The $team team won!",

        -- New Game message:
        -- Variables:        $team (team name)
        --
        on_game_begin = "The game has begun. You're on the $team team!",

        -- Message announced when you kill a human:
        -- Variables:        $victim (victim name)
        --                   $killer (killer name)
        --
        on_zombify = "$victim was zombified by $killer",

        -- Last Man Alive message:
        -- Variables:        $name (last man standing name)
        --
        on_last_man = "$name is the Last Human Alive!",

        -- Message announced when there are no zombies:
        -- Variables:        $time (time remaining until a random human is chosen to become a zombie)
        --                   $s placeholder to pluralize the word "seconds" (if $time is >1)
        --
        no_zombies = "No Zombies! Switching random human in $time second$s",

        -- Message announced when a human is selected to become a zombie:
        -- Variables:        $name (name of human who was switched to zombie team)
        --
        no_zombies_switch = "$name was switched to the Zombie team",

        -- Message announced when a zombie has been cured:
        -- Variables:        $name (name of human who was cured)
        --
        on_cure = "$name was cured!",

        -- Message announced when someone commits suicide:
        -- Variables:        $name (name of person who died)
        --

        suicide = "$victim committed suicide",
        -- Message announced when someone commits suicide:
        -- Variables:        $victim (victim name)
        --

        pvp = "$victim was killed by $killer",
        -- Message announced when PvP even occurs:
        -- Variables:        $victim (victim name)
        --                   $killer (killer name)
        --
        generic_death = "$name died"
        -- Message announced when someone dies by any means other than PvP and suicide:
        -- Variables:        $victim (victim name)
        --
    },

    --
    -- Game objects to disable:
    -- Format: {tag type, tag name, team}
    -- Teams: 0 = both, 1 = red, 2 = blue
    --
    objects = {

        -- vehicles:
        --
        { "vehi", "vehicles\\ghost\\ghost_mp", 2 },
        { "vehi", "vehicles\\rwarthog\\rwarthog", 2 },
        { "vehi", "vehicles\\banshee\\banshee_mp", 2 },
        { "vehi", "vehicles\\scorpion\\scorpion_mp", 2 },
        { "vehi", "vehicles\\c gun turret\\c gun turret_mp", 2 },
        { "vehi", "vehicles\\warthog\\mp_warthog", "Warthog", 2 },

        -- weapons:
        --
        { "weap", "weapons\\flag\\flag", 2 },
        { "weap", "weapons\\ball\\ball", 2 },
        { "weap", "weapons\\pistol\\pistol", 2 },
        { "weap", "weapons\\shotgun\\shotgun", 2 },
        { "weap", "weapons\\needler\\mp_needler", 2 },
        { "weap", "weapons\\plasma rifle\\plasma rifle", 2 },
        { "weap", "weapons\\flamethrower\\flamethrower", 2 },
        { "weap", "weapons\\sniper rifle\\sniper rifle", 2 },
        { "weap", "weapons\\plasma_cannon\\plasma_cannon", 2 },
        { "weap", "weapons\\plasma pistol\\plasma pistol", 2 },
        { "weap", "weapons\\assault rifle\\assault rifle", 2 },
        { "weap", "weapons\\gravity rifle\\gravity rifle", 2 },
        { "weap", "weapons\\rocket launcher\\rocket launcher", 2 },

        -- equipment:
        --
        { "eqip", "powerups\\health pack", 2 },
        { "eqip", "powerups\\over shield", 2 },
        { "eqip", "powerups\\active camouflage", 2 },
        { "eqip", "weapons\\frag grenade\\frag grenade", 2 },
        { "eqip", "weapons\\plasma grenade\\plasma grenade", 2 },
    },

    -- A message relay function temporarily removes the server prefix
    -- and will restore it to this when the relay is finished
    server_prefix = "**SAPP**",
    --
}
-- config ends --
-- do not touch anything below this point --

api_version = "1.12.0.0"

-- This function registers needed event callbacks:
--
function OnScriptLoad()

    register_callback(cb["EVENT_TICK"], "OnTick")
    register_callback(cb["EVENT_DIE"], "OnPlayerDeath")
    register_callback(cb["EVENT_SPAWN"], "OnPlayerSpawn")
    register_callback(cb["EVENT_JOIN"], "OnPlayerConnect")
    register_callback(cb["EVENT_GAME_START"], "OnGameEnd")
    register_callback(cb["EVENT_GAME_START"], "OnGameStart")
    register_callback(cb["EVENT_LEAVE"], "OnPlayerDisconnect")
    register_callback(cb["EVENT_WEAPON_DROP"], "OnWeaponDrop")
    register_callback(cb["EVENT_WEAPON_PICKUP"], "OnWeaponPickup")
    register_callback(cb["EVENT_DAMAGE_APPLICATION"], "DamageMultiplier")

    DisableDeathMessages()

    Zombies:Init()
end

function OnScriptUnload()
    if (get_var(0, "$gt") ~= "n/a") then
        execute_command("sv_map_reset")
    end
    EnableDeathMessages()
end

-- Sets up pre-game parameters:
--
function Zombies:Init()

    self.players = { }
    self.last_man = nil
    self.switching = false
    self.game_started = false

    self.health_increment = self.attributes["Last Man Standing"].health.increment

    self.timers = {

        ["Not Enough Players"] = {
            timer = 0,
            init = false
        },

        ["Pre-Game Countdown"] = {
            timer = 0,
            init = false,
            enough_players = false,
            delay = self.game_start_delay + 1
        },

        ["No Zombies"] = {
            timer = 0,
            init = false,
            delay = self.no_zombies_delay + 1
        }
    }

    if (get_var(0, "$gt") ~= "n/a") then

        -- Disable game objects:
        --
        for _, v in pairs(self.objects) do
            execute_command("disable_object '" .. v[2] .. "' " .. v[3])
        end

        -- Init new players array for each player:
        --
        for i = 1, 16 do
            if player_present(i) then
                self:InitPlayer(i, false)
                self:GameStartCheck(i, false)
            end
        end
    end
end

-- Create (new) or delete (old) player array:
-- @param Ply (player index) [number]
-- @param Reset (reset players array for this player) [boolean]
--
function Zombies:InitPlayer(Ply, Reset)

    if (not Reset) then
        self.players[Ply] = {
            drones = {},
            assign = false,
            standard = true,
            name = get_var(Ply, "$name")
        }
        return
    end

    self:CleanUpDrones(Ply)
    self.players[Ply] = nil
end

-- Used to clear a players rcon console:
-- @param Ply (player index) [number]
--
local function ClearConsole(Ply)
    for _ = 1, 25 do
        rprint(Ply, " ")
    end
end

-- Used to pluralize a string based on whether n>0.
-- @param n (time remaining) [number]
-- @return char n [string]
local function Plural(n)
    return (n > 0 and "s") or ""
end

-- Starts a given timer:
-- @param t (timer table) [table]
function Zombies:StartTimer(t, Callback)
    t.timer = 0
    t.init = true
    timer(1000, Callback)
end

-- Stops a given timer:
-- @param t (timer table) [table]
function Zombies:StopTimer(t)
    t.timer = 0
    t.init = false
end

-- Game Start Check logic:
-- @param Ply (player index) [number]
-- @param Deduct (deduct 1 from player count) [boolean]
--
function Zombies:GameStartCheck(Ply, Deduct)

    local player_count = tonumber(get_var(0, "$pn"))
    if (Deduct) then
        player_count = player_count - 1
    end

    local countdown1 = self.timers["Pre-Game Countdown"]
    local countdown2 = self.timers["Not Enough Players"]
    local countdown3 = self.timers["No Zombies"]
    local enough_players = (player_count >= self.required_players)
    local show_countdown = (enough_players and not countdown1.init and not self.game_started)

    -- Show pre-game countdown or "not enough players" message:
    --
    if (not enough_players) then
        self:StopTimer(countdown1) -- in case it was running
        if (self.show_not_enough_players_message) then
            self:StartTimer(countdown2, "NotEnoughPlayers")
        end
    elseif (show_countdown) then
        self:StartTimer(countdown1, "StartPreGameTimer")
        self:StopTimer(countdown2)
        self:StopTimer(countdown3)
    elseif (self.game_started) then

        -- Game has already begun.
        -- Switch this player (Ply) to zombie team:
        --
        self:SwitchTeam(Ply, self.zombie_team)

        -- Stop No Zombies timer (in case it was running when this player joined):
        --
        if (countdown3.init) then
            self:StopTimer(countdown3)
        end
    end
end

-- Returns player memory address and X,Y,Z coordinates:
-- @param Ply (player index) [number]
-- @return memory address (DyN) of a player (Ply) and three 32-bit floating point numbers (x,y,z)
--
local function GetPos(Ply)
    local DyN = get_dynamic_player(Ply)
    if (DyN ~= 0 and player_alive(Ply)) then
        local x, y, z = read_vector3d(DyN + 0x5C)
        return DyN, x, y, z
    end
end

-- This function returns the number of players in each team:
-- @return humans [number], zombies [number]
--
function Zombies:GetTeamCounts()

    local human_team = self.human_team
    local zombie_team = self.zombie_team

    local humans, zombies
    if (human_team == "red" and zombie_team == "blue") then
        humans = get_var(0, "$reds")
        zombies = get_var(0, "$blues")
    elseif (human_team == "blue" and zombie_team == "red") then
        humans = get_var(0, "$blues")
        zombies = get_var(0, "$reds")
    end

    return tonumber(humans), tonumber(zombies)
end

-- Returns the appropriate weapon table for a given player:
-- @param Ply (player index) [number]
-- @return, weapon table [table]
--
function Zombies:GetWeaponTable(Ply)
    local team = get_var(Ply, "$team")
    if (team == "blue") then
        local standard = self:AlphaZombie(Ply)
        if (standard) then
            return self.attributes["Standard Zombies"].weapons
        else
            return self.attributes["Alpha Zombies"].weapons
        end
    elseif tonumber(get_var(0, "$reds")) > 1 then
        return self.attributes["Humans"].weapons
    else
        return self.attributes["Last Man Standing"].weapons
    end
end

-- This function is responsible for increment player health:
-- Only applies to the Last Man Standing
-- @param Ply (player index) [number]
--
function Zombies:HealthRegeneration(Ply)
    if (self.regenerating_health and self.last_man == Ply) then
        local DyN = get_dynamic_player(Ply)
        if (DyN ~= 0 and player_alive(Ply)) then
            local health = read_float(DyN + 0xE0)
            if (health < 1) then
                write_float(DyN + 0xE0, health + self.health_increment)
            end
        end
    end
end

-- This function is responsible for making a zombie go invisible when they crouch:
-- @param Ply (player index) [number]
--
function Zombies:CrouchCamo(Ply)
    if (get_var(Ply, "$team") == self.zombie_team) then

        -- Check if zombie is allowed to use camo:
        --
        local camo
        local standard = self:AlphaZombie(Ply)
        if (standard) then
            camo = self.attributes["Standard Zombies"].camo
        else
            camo = self.attributes["Alpha Zombies"].camo
        end

        -- Apply Camo:
        --
        if (camo) then
            local DyN = get_dynamic_player(Ply)
            if (DyN ~= 0 and player_alive(Ply)) then
                local couching = read_float(DyN + 0x50C)
                if (couching == 1) then
                    execute_command("camo " .. Ply .. " 1")
                end
            end
        end
    end
end

-- Removes Ammo and Grenades from zombie weapons:
--
local function RemoveAmmo(Ply)
    if (Zombies.game_started) then
        local team = get_var(Ply, "$team")
        if (team == Zombies.zombie_team) then
            execute_command_sequence("w8 1; ammo " .. Ply .. " 0 5")
            execute_command_sequence("w8 1; mag " .. Ply .. " 0  5")
            execute_command_sequence("w8 1; battery " .. Ply .. " 0  5")
        end
    end
end

-- Sets player grenades (frags/plasmas):
-- @param Ply (player index) [number]
--
local function SetGrenades(Ply)

    local grenades
    local team = get_var(Ply, "$team")
    if (team == Zombies.zombie_team) then
        local standard = Zombies:AlphaZombie(Ply)
        if (standard) then
            grenades = Zombies.attributes["Standard Zombies"].grenades
        else
            grenades = Zombies.attributes["Alpha Zombies"].grenades
        end
    elseif (team == Zombies.human_team) then
        if (Ply ~= Zombies.last_man) then
            grenades = Zombies.attributes["Humans"].grenades
        else
            grenades = Zombies.attributes["Last Man Standing"].grenades
        end
    end

    if (grenades[1] ~= nil) then
        execute_command_sequence("w8 1; nades " .. Ply .. " " .. grenades[1])
    end

    if (grenades[2] ~= nil) then
        execute_command_sequence("w8 1; plasmas " .. Ply .. " " .. grenades[2])
    end
end

-- This function is called once every 1/30th second (1 tick):
-- Used for weapon assignments, health regeneration and Last-Man Nav Makers.
--
function Zombies:GameTick()

    self:SetNavMarker()

    for i, player in pairs(self.players) do
        if (i and self.game_started) then

            self:CrouchCamo(i)
            self:HealthRegeneration(i)

            if (player.assign) then
                local DyN, x, y, z = GetPos(i)
                if (DyN ~= 0 and x) then

                    player.assign = false

                    -- Get the appropriate weapon array for this player:
                    -- If the weapons array is empty, the player will receive default weapons.
                    --
                    local weapons = self:GetWeaponTable(i)
                    if (#weapons > 0) then

                        -- Delete this players inventory:
                        --
                        execute_command("wdel " .. i)

                        -- Assign Weapons:
                        --
                        for slot, v in pairs(weapons) do

                            -- Assign primary & secondary weapons:
                            --
                            if (slot == 1 or slot == 2) then

                                -- Spawn the weapon:
                                --
                                local weapon = spawn_object("weap", v, x, y, z)

                                -- Store a copy of this weapon to the drones table:
                                --
                                table.insert(player.drones, weapon)

                                -- Assign this weapon:
                                --
                                assign_weapon(weapon, i)

                                -- Assign tertiary & quaternary weapons:
                                --
                            elseif (slot >= 3) then
                                timer(250, "DelaySecQuat", i, v, x, y, z)
                                --
                                -- Technical note:
                                -- It's important that we delay the logic responsible for assigning tertiary and quaternary weapon
                                -- assignments otherwise they will fall to the ground and never be assigned.
                                --
                            end
                        end
                        RemoveAmmo(i)
                    end
                    SetGrenades(i)
                end
            end
        end
    end
end

--
-- Deletes player weapon drones:
-- @param Victim (player index) [number]
-- @param Assign (assign new weapons) [boolean]
--
function Zombies:CleanUpDrones(Ply, Assign)
    local team = get_var(Ply, "$team")
    if (team == self.zombie_team) then
        local drones = self.players[Ply].drones
        if (#drones > 0) then
            for _, weapon in pairs(drones) do
                destroy_object(weapon)
            end
            if (Assign) then
                self.players[Ply].assign = true
            end
        end
    end
end

--
-- Returns the team type (red = human, blue = zombie):
-- @param Ply (player index) [number]
-- @return player team type [string]
function Zombies:GetTeamType(Ply)
    local team = get_var(Ply, "$team")
    return (team == self.human_team and "human") or "zombie"
end

-- Shows the pre-game countdown message,
-- resets the map and sorts players into teams:
--
function Zombies:StartPreGameTimer()

    local countdown = self.timers["Pre-Game Countdown"]
    countdown.timer = countdown.timer + 1

    local time_remaining = (countdown.delay - countdown.timer)
    if (time_remaining <= 0) then

        -- Stop the timer:
        self:StopTimer(countdown)

        -- Reset the map:
        execute_command("sv_map_reset")
        self.game_started = true

        -- Sort players into teams:
        --
        local players = {}
        for i = 1, 16 do
            if player_present(i) then
                players[#players + 1] = i
            end
        end

        if (#players > 0) then

            math.randomseed(os.clock())
            local new_zombie = players[math.random(1, #players)]
            for i, _ in pairs(players) do
                if (i == new_zombie) then

                    -- Set zombie type to Alpha-Zombie:
                    --
                    self.players[i].standard = false

                    -- Set player to zombie team:
                    self:SwitchTeam(i, self.zombie_team)

                    -- Tell player what team they are on:
                    local msg = self.messages.on_game_begin
                    local team = self:GetTeamType(i)
                    self:Broadcast(i, msg:gsub("$team", team))

                else

                    -- Set zombie type to Standard-Zombie:
                    --
                    self.players[i].standard = false

                    -- Set player to human team:
                    --
                    self:SwitchTeam(i, self.human_team)

                    -- Tell player what team they are on:
                    --
                    local msg = self.messages.on_game_begin
                    local team = self:GetTeamType(i)
                    self:Broadcast(i, msg:gsub("$team", team))
                end
            end
        end

        self:GamePhaseCheck(nil, nil)
        return false
    end

    -- Show the pre-game message:
    --
    local msg = self.messages.pre_game_message
    msg = msg:gsub("$time", time_remaining):gsub("$s", Plural(time_remaining))
    self:Broadcast(nil, msg)

    return countdown.init
end

-- Broadcasts self.messages.not_enough_players:
--
function Zombies:NotEnoughPlayers()
    local countdown = self.timers["Not Enough Players"]
    if (countdown.init) then
        for i = 1, 16 do
            if player_present(i) then
                local msg = self.messages.not_enough_players
                msg = msg:gsub("$current", get_var(0, "$pn"))
                msg = msg:gsub("$required", self.required_players)
                ClearConsole(i)
                rprint(i, msg)
            end
        end
    end
    return (countdown.init)
end

-- This function chooses a random human to become a zombie
-- when there are no zombies left:
--
function Zombies:SwitchHumanToZombie()
    local countdown = self.timers["No Zombies"]
    countdown.timer = countdown.timer + 1

    local time_remaining = (countdown.delay - countdown.timer)
    if (time_remaining <= 0) then

        self:StopTimer(countdown)

        -- Save all players on the human team to the humans array:
        --
        local humans = {}
        for i = 1, 16 do
            local team = get_var(i, "$team")
            if (team == self.human_team) then
                humans[#humans + 1] = i
            end
        end

        --Pick a random human (from humans array) to become the zombie:
        --
        math.randomseed(os.clock())
        local new_zombie = humans[math.random(1, #humans)]
        local name = self.players[new_zombie].name

        -- Tell player what team they're on:
        --
        local msg = self.messages.no_zombies_switch
        msg = msg:gsub("$name", name)
        self:Broadcast(nil, msg)

        -- Set zombie type to Standard-Zombie:
        --
        self.players[new_zombie].standard = true

        -- Switch them:
        --
        self:SwitchTeam(new_zombie, self.zombie_team)

        -- Check game phase:
        --
        self:GamePhaseCheck(nil, nil)

        return false
    end

    local msg = self.messages.no_zombies
    msg = msg:gsub("$time", time_remaining):gsub("$s", Plural(time_remaining))
    self:Broadcast(nil, msg)

    return countdown.init
end

-- This function sets a nav marker above the Last Man Standing's head:
--
function Zombies:SetNavMarker()
    if (self.nav_marker) then
        for i, _ in pairs(self.players) do

            -- Get static memory address of each player:
            --
            local p1 = get_player(i)
            if (p1 ~= 0) then

                -- Set slayer target indicator to the last man:
                --
                if (self.last_man ~= nil and i ~= self.last_man) and player_alive(i) then
                    write_word(p1 + 0x88, to_real_index(self.last_man))
                else
                    -- Set slayer target indicator to themselves:
                    --
                    write_word(p1 + 0x88, to_real_index(i))
                end
            end
        end
    end
end

function Zombies:AlphaZombie(Ply)
    return self.players[Ply].standard
end

-- @param Ply (player index) [number]
-- @param Team (new team) [string]
function Zombies:SwitchTeam(Ply, Team)
    self.switching = true
    execute_command("st " .. Ply .. " " .. Team)
end

-- This function ends the game:
-- @param Team (player team) [string]
function Zombies:EndTheGame(Team)
    Team = Team or ""
    local msg = self.messages.end_of_game
    self:Broadcast(nil, msg:gsub("$team", Team))
    execute_command("sv_map_next")
end

--
-- Assigns tertiary & quaternary weapons:
-- Stores a copy of the weapon object to a table called drones.
--
-- @param Ply (player index) [number]
-- @param Tag (weapon tag type) [string]
-- @param x,y,z (three 32-bit floating point numbers (player coordinates)) [float]
--
function DelaySecQuat(Ply, Tag, x, y, z)
    local weapon = spawn_object("weap", Tag, x, y, z)
    local drones = Zombies.players[tonumber(Ply)].drones
    table.insert(drones, weapon)
    assign_weapon(weapon, Ply)
end

-- This function:
-- .Checks if we need to end the game.
-- .Sets the last man alive.
-- .Switches random human to zombie team when there are no zombies.
--
-- @param Ply (player index) [number]
-- @param PlayerCount (total number of players) [number]
function Zombies:GamePhaseCheck(Ply, PlayerCount)

    -- Returns the number of humans and zombies:
    --
    local humans, zombies = self:GetTeamCounts()

    -- Returns the total player count:
    --
    local player_count = (PlayerCount or tonumber(get_var(0, "$pn")))
    local team = (Ply ~= nil and get_var(Ply, "$team")) or ""
    if (team == self.human_team) then
        humans = humans - 1
    elseif (team == self.zombie_team) then
        zombies = zombies - 1
    end

    -- Check for (and set) last man alive:
    --
    if (humans == 1 and zombies > 0) then

        for i = 1, 16 do
            if player_present(i) then
                local last_man_team = get_var(i, "$team")
                if (last_man_team == self.human_team and not self.last_man) then
                    self.last_man = i
                    local name = self.players[i].name
                    local msg = self.messages.on_last_man
                    self:Broadcast(nil, msg:gsub("$name", name))
                    self:SetAttributes(i, true)
                end
            end
        end

        -- Announce zombie team won:
        --
    elseif (humans == 0 and zombies >= 1) then
        self:EndTheGame("Zombie")

        -- One player remains | end the game:
        --
    elseif (player_count == 1 and Ply ~= nil) then

        for i = 1, 16 do
            if (i ~= Ply and player_present(i)) then
                local team_type = self:GetTeamType(i)
                self:EndTheGame(team_type)
            end
        end

        -- No zombies left | Select random player to become zombie:
    elseif (zombies <= 0 and humans >= 1) then
        local countdown = self.timers["No Zombies"]
        self:StartTimer(countdown, "SwitchHumanToZombie")
    end
end

-- This function cures a zombie when they have >= self.cure_threshold kills:
-- @param Ply (player index) [number]
--
function Zombies:ZombieCured(Ply)
    if (self.cure_threshold > 1 and self.players[Ply] ~= nil) then
        local streak = tonumber(get_var(Ply, "$streak"))
        if (streak >= self.cure_threshold) then

            -- Delete the skull BEFORE switching (important):
            --
            self:CleanUpDrones(Ply)

            -- Switch zombie to the human team:
            --
            self:SwitchTeam(Ply, self.human_team)

            -- Announce that this player has been cured:
            --
            local msg = self.messages.on_cure
            local name = self.players[Ply].name
            msg = msg:gsub("$name", name)

            self:Broadcast(nil, msg)
        end
    end
end

-- Announces suicide messages:
-- @param victim_name (player index) [number]
--
local function AnnounceSuicide(victim_name)
    local msg = Zombies.messages.suicide
    msg = msg:gsub("$victim", victim_name)
    Zombies:Broadcast(nil, msg)
end

-- Announces pvp messages:
-- @param victim_name (victim index) [number]
-- @param killer_name (killer index) [number]
--
local function AnnouncePvP(victim_name, killer_name)
    local msg = Zombies.messages.pvp
    msg = msg:gsub("$victim", victim_name)
    msg = msg:gsub("$killer", killer_name)
    Zombies:Broadcast(nil, msg)
end

-- Announces generic death messages:
-- @param victim_name (player index) [number]
--
local function AnnounceGenericDeath(victim_name)
    local msg = Zombies.messages.generic_death
    msg = msg:gsub("$victim", victim_name)
    Zombies:Broadcast(nil, msg)
end

-- This function is called every time a player dies:
-- @param Victim (victim index) [number]
-- @param Killer (killer index) [number]

function Zombies:OnPlayerDeath(Victim, Killer)

    local killer = tonumber(Killer)
    local victim = tonumber(Victim)
    local v_name = self.players[victim].name
    local k_name = (self.players[killer] ~= nil and self.players[killer].name) or "UNKNOWN"
    local victim_team = get_var(victim, "$team")

    if (self.game_started) then

        -- PvP & Suicide:
        if (killer > 0) then

            -- Human died:
            --
            if (victim_team == self.human_team) then

                -- If the last man alive was killed by someone who is about to be cured,
                -- reset their last-man status:
                --
                if (self.last_man == victim) then
                    self.last_man = nil
                end

                -- Switch victim to the zombie team:
                --
                self:SwitchTeam(victim, self.zombie_team)

                -- Set zombie type to Standard-Zombie:
                --
                self.players[victim].standard = true

                -- Check if we need to cure this zombie:
                --
                self:ZombieCured(killer)

                -- Check game phase:
                --
                self:GamePhaseCheck(nil, nil)

                -- Broadcast "self.messages.on_zombify" message:
                --
                if (victim ~= killer) then
                    local msg = self.messages.on_zombify
                    msg = msg:gsub("$victim", v_name)
                    msg = msg:gsub("$killer", k_name)
                    self:Broadcast(nil, msg)
                else
                    -- Suicide Message override:
                    --
                    AnnounceSuicide(v_name)
                end

            else
                -- Human vs Zombie:
                --
                AnnouncePvP(v_name, k_name)
            end


        elseif (not self.switching) then
            -- Generic Death:
            --
            AnnounceGenericDeath(v_name)
        end

        self:CleanUpDrones(Victim, true)

        --
        -- Pre-Game death message overrides:
        --
    elseif (killer > 0) then
        if (victim == killer) then
            -- Suicide Message override:
            --
            AnnounceSuicide(v_name)
        else
            -- PvP:
            --
            AnnouncePvP(v_name, k_name)
        end
    else
        -- Generic Death:
        --
        AnnounceGenericDeath(v_name)
    end

    self.switching = false
end

-- This function returns the relevant respawn time for this player:
-- @param Ply (player index) [number]
-- @param return (respawn time) [number]
--
function Zombies:GetRespawnTime(Ply)
    local time
    local team = get_var(Ply, "$team")
    if (team == self.zombie_team) then
        local standard = self:AlphaZombie(Ply)
        if (standard) then
            time = self.attributes["Standard Zombies"].respawn_time
        else
            time = self.attributes["Alpha Zombies"].respawn_time
        end
    elseif (team == self.human_team) then
        time = self.attributes["Humans"].respawn_time
        if (self.last_man == Ply) then
            time = self.attributes["Last Man Standing"].respawn_time
        end
    end
    return time
end

-- This function sets this players speed:
-- @param Ply (player index) [number]
-- @param Instant (affect immediately) [boolean]
--
function Zombies:SetSpeed(Ply, Instant)
    local speed
    local team = get_var(Ply, "$team")
    local time = (Instant and 0) or self:GetRespawnTime(Ply)
    if (team == self.zombie_team) then
        local standard = self:AlphaZombie(Ply)
        if (standard) then
            speed = self.attributes["Standard Zombies"].speed
        else
            speed = self.attributes["Alpha Zombies"].speed
        end
    elseif (team == self.human_team) then
        speed = self.attributes["Humans"].speed
        if (self.last_man == Ply) then
            speed = self.attributes["Last Man Standing"].speed
        end
    end
    if (speed ~= 0) then
        execute_command_sequence("w8 " .. time .. ";s " .. Ply .. " " .. speed)
    end
end

-- This function sets this players health:
-- @param Ply (player index) [number]
-- @param Instant (affect immediately) [boolean]
--
function Zombies:SetHealth(Ply, Instant)
    local health
    local team = get_var(Ply, "$team")
    local time = (Instant and 0) or self:GetRespawnTime(Ply)
    if (team == self.zombie_team) then
        local standard = self:AlphaZombie(Ply)
        if (standard) then
            health = self.attributes["Standard Zombies"].health
        else
            health = self.attributes["Alpha Zombies"].health
        end
    elseif (team == self.human_team) then
        health = self.attributes["Humans"].health
        if (self.last_man == Ply) then
            health = self.attributes["Last Man Standing"].health.base
        end
    end

    if (health ~= 0) then
        execute_command_sequence("w8 " .. time .. ";hp " .. Ply .. " " .. health)
    end
end

--
-- This function Sets player attributes:
-- @param Ply (player index) [number]
--
function Zombies:SetAttributes(Ply, Instant)

    if (Zombies.game_started) then
        -- Set respawn time:
        --
        local time = Zombies:GetRespawnTime(Ply)
        local Player = get_player(Ply)
        if (Player ~= 0) then
            write_dword(Player + 0x2C, time * 33)
        end

        -- Set Player Health:
        Zombies:SetHealth(Ply, Instant)

        -- Set Player Speed:
        Zombies:SetSpeed(Ply, Instant)
    end
end

--
-- This function broadcasts a custom server message:
-- @param Msg (message) [string]
--
function Zombies:Broadcast(Ply, Msg)
    execute_command("msg_prefix \"\"")
    if (Ply) then
        say(Ply, Msg)
    else
        say_all(Msg)
    end
    execute_command("msg_prefix \" " .. self.server_prefix .. "\"")
end

-- This function is responsible for multiplying applied Damage
-- @param Ply (Victim) [number]
-- @param Causer (Killer) [number]
-- @param Damage (applied damage %) [number]
--
function DamageMultiplier(Ply, Causer, _, Damage, _, _)
    if (tonumber(Causer) > 0 and Ply ~= Causer and Zombies.game_started) then

        local c_team = get_var(Causer, "$team")
        local v_team = get_var(Ply, "$team")

        -- Block friendly fire:
        --
        if (c_team == v_team) then
            return false
        end

        -- Multiply units of damage by the appropriate damage multiplier property:
        --
        if (c_team == Zombies.zombie_team) then
            local standard = self:AlphaZombie(Ply)
            if (standard) then
                return true, Damage * Zombies.attributes["Standard Zombies"].damage_multiplier
            else
                return true, Damage * Zombies.attributes["Alpha Zombies"].damage_multiplier
            end
        elseif (c_team == Zombies.human_team) then
            if (Causer ~= Zombies.last_man) then
                return true, Damage * Zombies.attributes["Humans"].damage_multiplier
            else
                return true, Damage * Zombies.attributes["Last Man Standing"].damage_multiplier
            end
        end
    end
end

-- This function is called every time a new game begins:
--
function OnGameStart()
    Zombies:Init()
end

-- This function is called every time a game ends:
--
function OnGameEnd()
    Zombies.game_started = false
end

-- This function is called when a player has connected:
-- @param Ply (player index) [number]
--
function OnPlayerConnect(Ply)
    Zombies:InitPlayer(Ply, false)
    Zombies:GameStartCheck(Ply)
end

-- This function is called when a player has disconnected:
-- @param Ply (player index) [number]
--
function OnPlayerDisconnect(Ply)
    Zombies:InitPlayer(Ply, true)

    if (Zombies.game_started) then

        local player_count = tonumber(get_var(0, "$pn"))
        player_count = player_count - 1

        -- Stop timers:
        --
        if (player_count <= 0) then

            local countdown = Zombies.timers["Pre-Game Countdown"]
            Zombies:StopTimer(countdown)

            countdown = Zombies.timers["No Zombies"]
            Zombies:StopTimer(countdown)
        end

        Zombies:GamePhaseCheck(Ply, player_count)
    else
        Zombies:GameStartCheck(Ply, true)
    end
end

--
-- This function is called when a player has finished spawning:
-- @param Ply (player index) [number]
--
function OnPlayerSpawn(Ply)
    Zombies.players[Ply].assign = true
    Zombies:SetAttributes(Ply)
end

-- This function is called every time a player drops a weapon:
-- @param Ply (player index) [number]
--
function OnWeaponDrop(Ply)
    Zombies:CleanUpDrones(Ply, true)
end

-- This function is called every time a player picks up a weapon:
-- @param Ply (player index) [number]
--
function OnWeaponPickup(Ply)
    RemoveAmmo(Ply)
end

-- Enables the servers default death messages:
--
function EnableDeathMessages()
    safe_write(true)
    write_dword(Zombies.kill_message_address, Zombies.original_kill_message)
    safe_write(false)
end

-- Disables the servers default death messages:
--
function DisableDeathMessages()

    Zombies.kill_message_address = sig_scan("8B42348A8C28D500000084C9") + 3
    Zombies.original_kill_message = read_dword(Zombies.kill_message_address)

    safe_write(true)
    write_dword(Zombies.kill_message_address, 0x03EB01B1)
    safe_write(false)
end

-- Functions with a call to another function:
--
function OnTick()
    return Zombies:GameTick()
end
function StartPreGameTimer()
    return Zombies:StartPreGameTimer()
end
function NotEnoughPlayers()
    return Zombies:NotEnoughPlayers()
end
function SwitchHumanToZombie()
    return Zombies:SwitchHumanToZombie()
end
function OnPlayerDeath(V, K)
    return Zombies:OnPlayerDeath(V, K)
end

--[[

    -----------------------------------------------------------------------
    Quality of Life feedback:
    This script is designed to run Team Slayer on the following stock maps:

    Ratrace,            Hangemhigh,         Beavercreek,          Carousel
    Chillout,           Damnation,          Gephyrophobia,        Prisoner
    Timberland,         Bloodgulch,         Putput
    -----------------------------------------------------------------------


    -------------------------------
    RECOMMENDED GAME TYPE SETTINGS:
    -------------------------------

    ----------* Game Options * ----------
    SELECT GAME:                    SLAYER
    DEATH BONUS:                    NO
    KILL IN ORDER:                  NO (set to YES if using Nav Marker feature)
    KILL PENALTY:                   NO
    KILLS TO WIN:                   50
    TEAM PLAY                       YES
    TIME LIMIT:                     45 MINUTES

    ----------* Player Options * ----------
    NUMBER OF LIVES:                INFINITE
    MAXIMUM HEALTH:                 100%
    SHIELDS:                        NO
    RESPAWN TIME:                   INSTANT
    RESPAWN TIME GROWTH:            NONE
    ODD MAN OUT:                    NO
    INVISIBLE PLAYERS:              NO
    SUICIDE PENALTY:                NONE

    ----------* Item Options * ----------
    INFINITE GRENADES:              NO
    WEAPON SET:                     NORMAL
    STARTING EQUIPMENT:             GENERIC

    ----------* Vehicle Options * ----------
    SIDE:                           BLUE TEAM
    VEHICLE SET:                    NONE
    SIDE:                           RED TEAM
    VEHICLE SET:                    NONE

    ----------* Indicator Options * ----------
    OBJECTIVES INDICATOR:           NONE (set to NAV POINTS if using Nav Marker feature)
    OTHER PLAYERS ON RADAR:         NO
    FRIEND INDICATORS ON SCREEN:    YES
]]

-- For a future update:
return Zombies