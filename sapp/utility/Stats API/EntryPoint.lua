-- Stats API (v1.0)
-- Copyright (c) 2022, Jericho Crosby <jericho.crosby227@gmail.com>

local Stats = require('./Stats API/Stats')
setmetatable(Stats, { __index = {
    json = require('./Stats API/json'),
    settings = require('./Stats API/settings')
} })

function OnStart()
    if (get_var(0, '$gt') ~= 'n/a') then
        Stats:CheckFile(false)
        for i = 1, 16 do
            if player_present(i) then
                OnJoin(i)
            end
        end
    end
end

function OnTick()
    Stats:CheckStale()
end

function OnJoin(Ply)
    Stats:OnJoin(Ply)
end

function OnCommand(Ply, CMD)
    return Stats:OnCommand(Ply, CMD)
end

--=====================================================--
Stats:CheckFile(true)
register_callback(cb['EVENT_GAME_START'], 'OnStart')
register_callback(cb['EVENT_COMMAND'], 'OnCommand')
register_callback(cb['EVENT_JOIN'], 'OnJoin')
register_callback(cb['EVENT_TICK'], 'OnTick')
--=====================================================--

return Stats