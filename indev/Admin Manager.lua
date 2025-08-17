--[[
--=====================================================================================================--
Script Name: Admin Manager, for SAPP (PC & CE)
Description: See link below for full description.

INTRO: https://github.com/Chalwk/HALO-SCRIPT-PROJECTS/releases/tag/AdminManager

Copyright (c) 2023, Jericho Crosby <jericho.crosby227@gmail.com>
Notice: You can use this script subject to the following conditions:
https://github.com/Chalwk/HALO-SCRIPT-PROJECTS/blob/master/LICENSE
--=====================================================================================================--
]]--

api_version = '1.12.0.0'

local AdminManager = {
    commands_dir = './Admin Manager/commands/',
    dependencies = {
        ['./Admin Manager/'] = { 'settings' },
        ['./Admin Manager/events/'] = {
            'on_chat',
            'on_command',
            'on_end',
            'on_join',
            'on_quit',
            'on_start',
            'on_tick',
            'on_unload'
        },
        ['./Admin Manager/util/'] = {
            'ban',
            'custom_variables',
            'file_io',
            'misc'
        }
    }
}

function AdminManager:loadDependencies()

    local deps = self.dependencies
    local dir = read_string(read_dword(sig_scan('68??????008D54245468') + 0x1))
    self.data_dir = dir .. '\\sapp\\'

    local s = self
    for path, t in pairs(deps) do
        for _, file in pairs(t) do

            local f = loadfile(path .. file .. '.lua')()
            setmetatable(s, { __index = f })
            s = f

            _G[file] = path:find('/events/') and function(...)
                return f[file](self, ...)
            end or nil
        end
    end

    self:registerLevelVariable()
    self:loadBans()
    self:loadAliases()
    self:setDefaultCommands()
    self:setManagementCMDS()
    self:setAdmins()
    self:on_start()
end

function OnScriptLoad()
    AdminManager:loadDependencies()
end

function OnScriptUnload()
    AdminManager:on_unload()
end