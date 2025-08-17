--[[
--=====================================================================================================--
Script Name: Battle Royale, for SAPP (PC & CE)

Copyright (c) 2023, Jericho Crosby <jericho.crosby227@gmail.com>
Notice: You can use this script subject to the following conditions:
https://github.com/Chalwk/HALO-SCRIPT-PROJECTS/blob/master/LICENSE
--=====================================================================================================--
]]--

local BattleRoyale = {

    cmds = {},
    players = {},
    pre_game_timer = nil,
    post_game_carnage_report = false,

    settings = require('./Battle Royale/settings'),

    dependencies = {
        ['./Battle Royale/commands/'] = {
            'get_loot_coords',
            'get_spawn_coords',
            'repair_weapons',
            'restart'
        },
        ['./Battle Royale/countdown/'] = {
            'pre_game'
        },
        ['./Battle Royale/events/'] = {
            'on_command',
            'on_damage',
            'on_death',
            'on_end',
            'on_join',
            'on_object_spawn',
            'on_pickup',
            'on_pre_spawn',
            'on_quit',
            'on_spawn',
            'on_start',
            'on_tick'
        },
        ['./Battle Royale/hud/'] = {
            'hud'
        },
        ['./Battle Royale/loot/'] = {
            'crates',
            'monitor',
            'spawn',
            'spoils'
        },
        ['./Battle Royale/misc/'] = {
            'initialize',
            'misc',
        },
        ['./Battle Royale/safe zone/'] = {
            'hurt_player',
            'safe_zone'
        },
        ['./Battle Royale/sky spawning/'] = {
            'getters_and_setters',
            'god_mode',
            'teleport'
        },
        ['./Battle Royale/spectator/'] = {
          'spectate'
        },
        ['./Battle Royale/stun/'] = {
          'stun'
        },
        ['./Battle Royale/util/'] = {
            'timer'
        },
        ['./Battle Royale/weapon degradation/'] = {
            'degradation'
        },
        ['./Battle Royale/weapons/'] = {
            'weapons'
        },
        ['./Battle Royale/weight/'] = {
            'weapons'
        }
    }
}

--- Load file dependencies:
-- Each file inherits the parent BattleRoyale object.
--
function BattleRoyale:loadDependencies()

    self.death_message_address = sig_scan("8B42348A8C28D500000084C9") + 3
    self.original_death_message_address = read_dword(self.death_message_address)

    local s = self

    for k, v in pairs(self.settings) do
        self[k] = v
    end

    for path, t in pairs(self.dependencies) do

        for i = 1, #t do

            local f
            local file = t[i] -- name of the file (without extension)

            local success = pcall(function()
                f = loadfile(path .. file .. '.lua')()
            end)

            if (not success) then
                cprint('[BATTLE ROYALE] FILE DEPENDENCY NOT FOUND: ' .. path .. file .. '.lua', 12)
                goto next
            end

            local command = self.commands[file]
            if (command) then
                local cmd = command.name
                self.cmds[cmd] = f
                self.cmds[cmd].enabled = command.enabled
                self.cmds[cmd].description = command.description
                self.cmds[cmd].level = command.level
                self.cmds[cmd].help = command.help:gsub('$cmd', cmd)
                setmetatable(self.cmds[cmd], { __index = self })
                goto next
            end

            setmetatable(s, { __index = f })
            s = f

            _G[file] = path:find('events/') and function(...)
                return f[file](self, ...)
            end or nil

            :: next ::
        end
    end

    self:on_start() -- in case the plugin loads mid-game
end

api_version = '1.12.0.0'

function OnScriptLoad()
    BattleRoyale:loadDependencies()
end

function OnScriptUnload()
    -- N/A
end

function OnError()
    print(debug.traceback())
end