--[[
--=====================================================================================================--
Script Name: Script Manager, for SAPP (PC & CE)
Description: Dynamically loads/unloads scripts based on current map and game mode

Copyright (c) 2024, Jericho Crosby
Notice: You can use this script subject to the following conditions:
https://github.com/Chalwk/HALO-SCRIPT-PROJECTS/blob/master/LICENSE
--=====================================================================================================--
]]--

api_version = '1.12.0.0'

-- Configuration --------------------------------------------------------------
local ScriptManager = {
    -- Map-game mode associations
    maps = {
        ['bloodgulch'] = {
            ['LNZ-DAC'] = { 'Notify Me', 'Another Script' },
        },
        ['deathisland'] = {
            ['ctf'] = { 'CTF Helper' },
            ['slayer'] = { 'Slayer Enhancer' }
        },
        -- Add new maps here
    }
}
------------------------------------------------------------------------------

function OnScriptLoad()
    cprint('[Script Manager] Initialized')
    register_callback(cb['EVENT_GAME_START'], 'OnGameStart')
    register_callback(cb['EVENT_GAME_END'], 'OnGameEnd')
    ScriptManager.loaded = {}    -- Tracks currently loaded scripts
    ScriptManager.scheduled = {} -- Scripts scheduled for loading/unloading
end

function OnGameStart()
    local gameType = get_var(0, '$gt')
    if gameType == 'n/a' then return end

    local map = get_var(0, '$map'):lower()
    local mode = get_var(0, '$mode'):lower()

    ScriptManager:ProcessMapMode(map, mode)
end

function OnGameEnd()
    ScriptManager:UnloadAllScripts()
end

function ScriptManager:ProcessMapMode(map, mode)
    self:ClearScheduled()

    -- Schedule new scripts for loading
    if self.maps[map] and self.maps[map][mode] then
        for _, script in ipairs(self.maps[map][mode]) do
            if not self.loaded[script] then
                self.scheduled[script] = true
            end
        end
    end

    -- Schedule obsolete scripts for unloading
    for script in pairs(self.loaded) do
        if not (self.maps[map] and self.maps[map][mode] and self:Contains(self.maps[map][mode], script)) then
            self.scheduled[script] = false
        end
    end

    self:ExecuteScheduled()
end

function ScriptManager:ExecuteScheduled()
    for script, load_flag in pairs(self.scheduled) do
        if load_flag then
            self:Load(script)
        else
            self:Unload(script)
        end
    end
    self:ClearScheduled()
end

function ScriptManager:Load(script)
    if self.loaded[script] then return end

    local success, err = pcall(function()
        execute_command('lua_load "' .. script .. '"')
        self.loaded[script] = true
        cprint('[Script Manager] Loaded: ' .. script)
    end)

    if not success then
        cprint('[Script Manager] ERROR loading ' .. script .. ': ' .. tostring(err))
        self.loaded[script] = nil
    end
end

function ScriptManager:Unload(script)
    if not self.loaded[script] then return end

    local success, err = pcall(function()
        execute_command('lua_unload "' .. script .. '"')
        self.loaded[script] = nil
        cprint('[Script Manager] Unloaded: ' .. script)
    end)

    if not success then
        cprint('[Script Manager] ERROR unloading ' .. script .. ': ' .. tostring(err))
    end
end

function ScriptManager:UnloadAllScripts()
    for script in pairs(self.loaded) do
        self:Unload(script)
    end
    cprint('[Script Manager] All scripts unloaded')
end
------------------------------------------------------------------------------

-- Utility functions ----------------------------------------------------------
function ScriptManager:ClearScheduled()
    self.scheduled = {}
end

function ScriptManager:Contains(tbl, item)
    for _, v in ipairs(tbl) do
        if v == item then
            return true
        end
    end
    return false
end

function OnScriptUnload()
    ScriptManager:UnloadAllScripts()
    cprint('[Script Manager] Unloaded')
end