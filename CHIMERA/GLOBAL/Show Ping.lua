--=====================================================================================--
-- SCRIPT NAME:      Player Ping Display
-- DESCRIPTION:      Continuously calculates and visually displays the player's network
--                   ping on screen while enabled. Supports configurable display modes,
--                   color-coded ping thresholds, animated flash on spikes, and smoothing
--                   over recent ping history for stability. The display position, font,
--                   and toggle command are configurable. Toggle on/off in-game by typing
--                   the configured command (default: "ping") in the console.
--
--                   Advanced console commands allow changing display mode, resetting
--                   ping history, and viewing current configuration.
--
-- AUTHOR:           Jericho Crosby (Chalwk)
-- COMPATIBILITY:    Halo PC/CE | Chimera
--
-- Copyright (c) 2025 Jericho Crosby <jericho.crosby227@gmail.com>
-- LICENSE:          MIT License
--                   https://github.com/Chalwk/HALO-SCRIPT-PROJECTS/blob/master/LICENSE
--=====================================================================================--

-- CONFIG STARTS ------------------------------------------------------------------------
local CONFIG = {
    ENABLED = true,       -- Default enabled state
    COMMAND = "ping",     -- Toggle command name
    SAVE_SETTINGS = true, -- Persist settings between sessions
    HISTORY_SIZE = 60,    -- Store 60 seconds of history

    -- Display settings
    FONT = "small",
    ALIGN = "right",
    POSITION = { -- Bottom right corner
        left = 0,
        top = 460,
        right = 640,
        bottom = 20
    },

    -- Ping thresholds (ms)
    THRESHOLDS = {
        EXCELLENT = 50, -- Green
        GOOD = 100,     -- Cyan
        FAIR = 150,     -- Yellow
        POOR = 300      -- Red
    },

    -- Display modes
    MODES = {
        SIMPLE = "{ping} ms",
        DETAILED = "Latency: {ping} ms",
        GRAPHICAL = "⬤ {ping} ms", -- Circle character
        HISTORICAL = "Ping: {ping} ms ({min}/{max})"
    },
    ACTIVE_MODE = "HISTORICAL",

    -- Animation
    FLASH_ON_SPIKE = true, -- Flash on sudden ping increase
    SPIKE_THRESHOLD = 50,  -- ms change to trigger flash
    FLASH_DURATION = 30    -- Frames to flash
}
-- CONFIG ENDS --------------------------------------------------------------

clua_version = 2.056

local state = {
    pingHistory = {},
    pingMin = 9999,
    pingMax = 0,
    currentPing = 0,
    smoothedPing = 0,
    frameCounter = 0,
    flashCounter = 0,
    lastPing = 0,
    configLoaded = false
}

local function formatPingString(ping)
    return CONFIG.MODES[CONFIG.ACTIVE_MODE]
        :gsub("{ping}", string.format("%.0f", ping))
        :gsub("{min}", state.pingMin)
        :gsub("{max}", state.pingMax)
end

local function updateMinMax(ping)
    if ping < state.pingMin then state.pingMin = ping end
    if ping > state.pingMax then state.pingMax = ping end
end

local function detectSpike(currentPing)
    if not CONFIG.FLASH_ON_SPIKE then return false end
    local delta = math.abs(currentPing - state.lastPing)
    return delta > CONFIG.SPIKE_THRESHOLD
end

local function getPingColor(ping)
    local t = CONFIG.THRESHOLDS

    if ping <= t.EXCELLENT then
        return 0.0, 1.0, 0.0, 1.0 -- Green
    elseif ping <= t.GOOD then
        return 0.0, 1.0, 1.0, 1.0 -- Cyan
    elseif ping <= t.FAIR then
        return 1.0, 1.0, 0.0, 1.0 -- Yellow
    elseif ping <= t.POOR then
        return 1.0, 0.5, 0.0, 1.0 -- Orange
    else
        return 1.0, 0.0, 0.0, 1.0 -- Red
    end
end

local function getFlashColor()
    local progress = state.flashCounter / CONFIG.FLASH_DURATION
    local pulse = math.sin(progress * math.pi * 4) * 0.5 + 0.5
    return 1.0, pulse, pulse, 1.0 -- Pulsing red
end

local function saveConfig()
    if not CONFIG.SAVE_SETTINGS then return end
    write_file("ping_display.cfg",
        string.format("%s\n%s\n%s\n%d",
            tostring(CONFIG.ENABLED),
            CONFIG.ACTIVE_MODE,
            CONFIG.ALIGN,
            CONFIG.HISTORY_SIZE
        ))
end

local function loadConfig()
    if not CONFIG.SAVE_SETTINGS or not file_exists("ping_display.cfg") then
        return
    end

    local data = read_file("ping_display.cfg"):split("\n")
    if #data >= 4 then
        CONFIG.ENABLED = data[1] == "true"
        CONFIG.ACTIVE_MODE = data[2]
        CONFIG.ALIGN = data[3]
        CONFIG.HISTORY_SIZE = tonumber(data[4])
    end
    state.configLoaded = true
end

local function updatePingHistory(ping)
    table.insert(state.pingHistory, ping)

    if #state.pingHistory > CONFIG.HISTORY_SIZE then
        table.remove(state.pingHistory, 1)
    end

    -- Simple smoothing: moving average
    local sum = 0
    for _, v in ipairs(state.pingHistory) do
        sum = sum + v
    end
    state.smoothedPing = sum / #state.pingHistory
end

local function drawPingDisplay()
    if not CONFIG.ENABLED or state.currentPing == 0 then return end

    local ping = state.smoothedPing
    local text = formatPingString(ping)
    local r, g, b, a

    if state.flashCounter > 0 then
        r, g, b, a = getFlashColor()
        state.flashCounter = state.flashCounter - 1
    else
        r, g, b, a = getPingColor(ping)
    end

    draw_text(text,
        CONFIG.POSITION.left,
        CONFIG.POSITION.top,
        CONFIG.POSITION.right,
        CONFIG.POSITION.bottom,
        CONFIG.FONT,
        CONFIG.ALIGN,
        a, r, g, b
    )
end

function OnTick()
    state.frameCounter = state.frameCounter + 1

    -- Update ping every 30 frames (~0.5s)
    if state.frameCounter % 30 ~= 0 then return end

    local player = get_player()
    if player and server_type == "dedicated" then
        local rawPing = read_dword(player + 0xDC)

        -- Validate ping reading
        if rawPing > 0 and rawPing < 1000 then
            state.lastPing = state.currentPing
            state.currentPing = rawPing
            updatePingHistory(rawPing)
            updateMinMax(rawPing)

            if detectSpike(rawPing) then
                state.flashCounter = CONFIG.FLASH_DURATION
            end
        end
    end
end

function OnPreFrame()
    drawPingDisplay()
end

function OnCommand(cmd)
    local args = {}
    for arg in cmd:gmatch("%S+") do
        table.insert(args, arg:lower())
    end

    if #args == 0 then return true end

    -- Toggle display
    if args[1] == CONFIG.COMMAND then
        if #args == 1 then
            CONFIG.ENABLED = not CONFIG.ENABLED
            console_out("Ping display " .. (CONFIG.ENABLED and "enabled" or "disabled"))
        else
            -- Advanced commands
            if args[2] == "mode" and args[3] then
                local mode = args[3]:upper()
                if CONFIG.MODES[mode] then
                    CONFIG.ACTIVE_MODE = mode
                    console_out("Display mode set to: " .. mode)
                else
                    console_out("Invalid mode. Available: " .. table.concat(table.keys(CONFIG.MODES), ", "))
                end
            elseif args[2] == "reset" then
                state.pingHistory = {}
                state.pingMin = 9999
                state.pingMax = 0
                console_out("Ping history reset")
            elseif args[2] == "config" then
                console_out("Current configuration:")
                console_out("  Enabled: " .. tostring(CONFIG.ENABLED))
                console_out("  Mode: " .. CONFIG.ACTIVE_MODE)
                console_out("  Position: " .. CONFIG.POSITION.x .. ", " .. CONFIG.POSITION.y)
                console_out("  History Size: " .. CONFIG.HISTORY_SIZE)
            end
        end

        saveConfig()
        return false
    end

    return true
end

function OnMapLoad()
    if not state.configLoaded then
        loadConfig()
    end

    -- Reset transient state
    state.pingHistory = {}
    state.currentPing = 0
    state.smoothedPing = 0
    state.pingMin = 9999
    state.pingMax = 0
end

-- === SETUP AND INITIALIZATION ===
-- Add missing utility functions
function string:split(delimiter)
    local result = {}
    local from = 1
    local delim_from, delim_to = string.find(self, delimiter, from)
    while delim_from do
        table.insert(result, string.sub(self, from, delim_from - 1))
        from = delim_to + 1
        delim_from, delim_to = string.find(self, delimiter, from)
    end
    table.insert(result, string.sub(self, from))
    return result
end

function table.keys(tbl)
    local keys = {}
    for k in pairs(tbl) do
        table.insert(keys, k)
    end
    return keys
end

set_callback("tick", "OnTick")
set_callback("preframe", "OnPreFrame")
set_callback("command", "OnCommand")
set_callback("map load", "OnMapLoad")

-- Initial configuration load
OnMapLoad()
