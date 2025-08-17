--[[
--=====================================================================================================--
Script Name: Parkour, for SAPP (PC & CE)
Description: This script will record how long it takes a player to complete the parkour course.

Copyright (c) 2022-2024, Jericho Crosby <jericho.crosby227@gmail.com>
Notice: You can use this script subject to the following conditions:
https://github.com/Chalwk/HALO-SCRIPT-PROJECTS/blob/master/LICENSE
--=====================================================================================================--
]]--

local config = {
    json = loadfile('./Parkour/util/json.lua')(),
    timer = loadfile('./Parkour/util/timer.lua')(),
    dependencies = {
        ['./Parkour/checkpoints/'] = {
            'anchor',
            'check',
            'init'
        },
        ['./Parkour/entities/'] = { 'player' },
        ['./Parkour/events/'] = {
            'on_death',
            'on_join',
            'on_pre_spawn',
            'on_quit',
            'on_spawn',
            'on_start',
            'on_tick'
        },
        ['./Parkour/start_finish_setup/'] = { 'line_intersect', 'race_lines' },
        ['./Parkour/util/'] = { 'fileIO', 'utils' },
        ['./Parkour/'] = { 'settings' }
    }
}

api_version = '1.12.0.0'

function config:loadDependencies()
    local s = self
    for path, t in pairs(self.dependencies) do
        for _, file in pairs(t) do
            local f = loadfile(path .. file .. '.lua')()
            setmetatable(s, { __index = f })
            s = f
            _G[file] = path:find('/events/') and function(...)
                return f[file](self, ...)
            end or nil
        end
    end
end

function OnScriptLoad()
    config:loadDependencies()
end

function OnScriptUnload()
    -- N/A
end