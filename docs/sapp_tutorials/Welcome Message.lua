---------------------------------------------------
-- Welcome Message Tutorial for SAPP
-- Greets players on join and displays server info
---------------------------------------------------

--------------------------------------------------------------------------------
-- CONFIG / CONSTANTS
--------------------------------------------------------------------------------
-- Messages and settings that rarely change during runtime
local WELCOME_MESSAGE = "Welcome to the server, %s!" -- %s will be replaced with the player's name
local DELAY_BEFORE_WELCOME = 3                       -- Delay in seconds before showing the welcome message
local SHOW_SERVER_INFO = true                        -- Whether to display map and mode info

-- * Required for all SAPP Lua scripts.
-- Tells SAPP the Lua API version being used on the server.
api_version = '1.12.0.0'

--------------------------------------------------------------------------------
-- INTERNAL STATE
--------------------------------------------------------------------------------
-- Variables that will store the current map and game mode
-- These change whenever a new game starts
local mapName, gameMode

--------------------------------------------------------------------------------
-- EVENT CALLBACKS
--------------------------------------------------------------------------------
-- Called automatically when the script is loaded
function OnScriptLoad()
    -- Register event callbacks for when a player joins or a new game starts
    register_callback(cb['EVENT_JOIN'], "OnPlayerJoin")
    register_callback(cb['EVENT_GAME_START'], "OnGameStart")

    -- Print a message to the server console so we know the script loaded successfully
    print("Welcome script loaded successfully!")

    -- Immediately update map and mode in case the script is loaded mid-game
    OnGameStart()
end

-- Called automatically when the script is unloaded (optional, here left empty)
function OnScriptUnload() end

--------------------------------------------------------------------------------
-- EVENT HANDLERS
--------------------------------------------------------------------------------
-- Called whenever a new game starts
function OnGameStart()
    -- If the game hasn't actually started yet, exit the function early
    if get_var(0, '$gt') == 'n/a' then return end

    -- Update our internal state variables with the current map and mode
    mapName = get_var(0, "$map")
    gameMode = get_var(0, "$mode")
end

-- Called whenever a player joins the server
function OnPlayerJoin(playerIndex)
    -- Wait a few seconds before sending the welcome message
    timer(DELAY_BEFORE_WELCOME * 1000, "DelayedWelcome", playerIndex)
end

--------------------------------------------------------------------------------
-- HELPER FUNCTIONS
--------------------------------------------------------------------------------
-- Format the welcome message with the player's name
local function formatMessage(name)
    -- string.format replaces %s in WELCOME_MESSAGE with the player's name
    return string.format(WELCOME_MESSAGE, name)
end

--------------------------------------------------------------------------------
-- TIMER HANDLER
--------------------------------------------------------------------------------
-- Called by the timer to actually send the welcome message
function DelayedWelcome(playerIndex)
    -- Get the player's name
    local name = get_var(playerIndex, '$name')

    -- Format the welcome message to include the player's name
    local welcome_message = formatMessage(name)

    -- Send the welcome message to the player
    rprint(playerIndex, welcome_message)

    -- Optionally, show the server's current map and mode
    if SHOW_SERVER_INFO then
        rprint(playerIndex, "Map: " .. mapName)
        rprint(playerIndex, "Mode: " .. gameMode)
    end

    -- Returning false prevents the timer from repeating
    return false
end
