-- Configuration settings:
local max_afk_time = 300                    -- Maximum allowed AFK time in seconds
local kick_reason = 'AFK for too long!'     -- Reason displayed when kicking an AFK player
local grace_period = 60                     -- Grace period before kicking in seconds
local threshold = 0.001                     -- Threshold for checking aim differences (only change if necessary)
local warning_message = "Warning: You will be kicked in $time_until_kick seconds for being AFK."
local kick_message = 'You have been kicked for being AFK!'
local server_prefix = '**SAPP**'
local warning_interval = 30                 -- Interval in seconds to send warnings
local afk_immunity = {                      -- List of players with AFK immunity
    -- Example: ["Player1"] = true,
}
api_version = '1.12.0.0'                    -- API version used by the script
-- Configuration ends here.

-- Empty table for storing player instances
local players = {}

-- Importing necessary functions and variables from external libraries
local abs, clock, pairs, ipairs = math.abs, os.clock, pairs, ipairs

-- Player class
local Player = {}
Player.__index = Player

-- Constructor for Player class
function Player:new(id)
    local instance = setmetatable({}, Player)
    instance.name = get_var(id, '$name')
    instance.id = id
    instance.last_active = clock()
    instance.last_warning = 0
    instance.camera_old = { 0, 0, 0 }
    instance.inputs = {
        { read_float, 0x490, state = 0 }, -- shooting
        { read_byte, 0x2A3, state = 0 }, -- forward, backward, left, right, grenade throw
        { read_byte, 0x47C, state = 0 }, -- weapon switch
        { read_byte, 0x47E, state = 0 }, -- grenade switch
        { read_byte, 0x2A4, state = 0 }, -- weapon reload
        { read_word, 0x480, state = 0 }, -- zoom
        { read_word, 0x208, state = 0 }   -- melee, flashlight, action, crouch, jump
    }
    return instance
end

function Player:broadcast(msg)
    execute_command('msg_prefix ""')
    say(self.id, msg)
    execute_command('msg_prefix "' .. server_prefix .. '"')
end

-- Check if the player is AFK
function Player:isAfk()
    local time_since_active = clock() - self.last_active
    local time_until_afk = max_afk_time - time_since_active
    local time_until_kick = max_afk_time + grace_period - time_since_active

    if time_until_afk <= 0 then
        return true
    elseif time_until_kick <= 0 then
        if clock() - self.last_warning >= warning_interval then
            self:broadcast(warning_message:gsub('$time_until_kick', -time_until_kick))
            self.last_warning = clock()
        end
    end

    return false
end

-- Update player's last_active timestamp and camera_old values
function Player:update(camera_current)
    self.last_active = clock()
    self.camera_old = { camera_current[1], camera_current[2], camera_current[3] }
end

-- Check if the player's aim has changed
function Player:checkAim(x1, y1, z1, x2, y2, z2)
    return abs(x1 - x2) <= threshold and abs(y1 - y2) <= threshold and abs(z1 - z2) <= threshold
end

-- Kick the player with the given ID and display the kick reason:
function Player:kick(reason)
    execute_command('k ' .. self.id .. ' "' .. reason .. '"')
    self:broadcast(kick_message)
    players[self.id] = nil
end

-- Check player inputs and update their last_active timestamp
function Player:checkInputs(dyn)
    for _, input in ipairs(self.inputs) do
        local func, address = input[1], input[2]
        if func(dyn + address) ~= input.state then
            self.last_active = clock()  -- Update the player's last_active timestamp
            input.state = func(dyn + address)  -- Update the input state
        end
    end
end

-- Function to get the current x,y,z camera position of a player at the given memory address
local function getCameraCurrent(dyn)
    return {
        read_float(dyn + 0x230),
        read_float(dyn + 0x234),
        read_float(dyn + 0x238)
    }
end

--================--
-- SAPP functions:
--================--

function OnScriptLoad()
    register_callback(cb['EVENT_TICK'], 'OnTick')
    register_callback(cb['EVENT_JOIN'], 'OnJoin')
    register_callback(cb['EVENT_LEAVE'], 'OnQuit')
    register_callback(cb['EVENT_GAME_START'], 'OnStart')
    register_callback(cb['EVENT_COMMAND'], 'OnChatOrCommand')
    register_callback(cb['EVENT_CHAT'], 'OnChatOrCommand')
    OnStart()
end

-- Initialize the players' data when a game starts
function OnStart()
    players = {}
    if (get_var(0, '$gt') ~= 'n/a') then
        for i = 1, 16 do
            if player_present(i) then
                players[i] = Player:new(i) -- Create new player instance
            end
        end
    end
end

-- Update player inputs and last_active timestamp, kick AFK players
function OnTick()
    for id, player in pairs(players) do
        -- Ensure the player exists and is not immune
        if not player or afk_immunity[player.name] then
            goto continue
        end

        -- Check if the player is AFK
        if player:isAfk(max_afk_time) then
            player:kick(kick_reason)
            goto continue
        end

        -- Check if the player is alive and has a valid dynamic address
        local dyn = get_dynamic_player(id)
        if dyn == 0 or not player_alive(id) then
            goto continue
        end

        -- Update player inputs and last_active timestamp
        player:checkInputs(dyn)

        -- Check and update player's aim
        local current_aim = getCameraCurrent(dyn)
        local old_aim = player.camera_old
        if not player:checkAim(old_aim[1], old_aim[2], old_aim[3], current_aim[1], current_aim[2], current_aim[3]) then
            player:update(current_aim) -- Update player data if aim has changed
        end

        :: continue ::
    end
end

-- Create a new player object when a player joins the game
function OnJoin(id)
    players[id] = Player:new(id) -- Create new player instance
end

-- Remove a player object when a player leaves the game
function OnQuit(id)
    players[id] = nil
end

-- Update the player's last_active timestamp when they send a chat message/command
function OnChatOrCommand(id)
    if id > 0 and players[id] then
        players[id].last_active = clock()
    end
end