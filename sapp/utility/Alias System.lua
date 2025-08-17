-- Alias System [Entry Point File] (v1.0)
-- Copyright (c) 2022, Jericho Crosby <jericho.crosby227@gmail.com>

local Alias = {
    players = {},
    json = loadfile('./Alias System/Dependencies/Json.lua')(),
    dependencies = {
        ['./Alias System/'] = { 'settings' },
        ['./Alias System/Dependencies/'] = {
            'Stale',
            'Results',
            'Database',
            'Commands',
            'NewAlias'
        }
    }
}

function Alias:LoadDependencies()
    local s = self
    for path, t in pairs(self.dependencies) do
        for _, file in pairs(t) do
            local f = loadfile(path .. file .. '.lua')()
            setmetatable(s, { __index = f })
            s = f
        end
    end
end

local open = io.open
function Alias:Update(t)
    t = t or self.records
    local file = open(self.dir, 'w')
    if (file) then
        file:write(self.json:encode_pretty(t))
        file:close()
    end
end

function Alias:Send(msg)
    if (not self.pid) then
        cprint(msg)
    else
        rprint(self.pid, msg)
    end
end

------------------------------------------------------------
--- [ SAPP FUNCTIONS ] ---
------------------------------------------------------------

function OnStart()
    if (get_var(0, '$gt') ~= 'n/a') then
        Alias.players = {}
        Alias.records = Alias:GetRecords()
        for i = 1, 16 do
            if player_present(i) then
                OnJoin(i)
            end
        end
    end
end

function OnEnd()
    Alias:Update()
end

function OnJoin(P)
    Alias.players[P] = Alias:New({
        pid = P,
        name = get_var(P, '$name'),
        hash = get_var(P, '$hash'),
        ip = get_var(P, '$ip'):match('%d+.%d+.%d+.%d+')
    })
end

function OnQuit(P)
    Alias.players[P] = nil
end

function OnCommand(Ply, Cmd)
    local t = Alias.players[Ply]
    if (t) then
        return t:Query(Cmd)
    else
        return Alias:Query(Cmd)
    end
end

function StaleTimer()
    return Alias:CheckStale()
end

function OnScriptLoad()

    Alias:LoadDependencies()

    local dir = read_string(read_dword(sig_scan('68??????008D54245468') + 0x1))
    Alias.dir = dir .. '\\sapp\\' .. Alias.file

    register_callback(cb['EVENT_JOIN'], 'OnJoin')
    register_callback(cb['EVENT_LEAVE'], 'OnQuit')
    register_callback(cb['EVENT_GAME_END'], 'OnEnd')
    register_callback(cb['EVENT_COMMAND'], 'OnCommand')
    register_callback(cb['EVENT_GAME_START'], 'OnStart')

    if (Alias.delete_stale_records) then
        timer(1000, 'StaleTimer')
    end
end

function OnScriptUnload()
    -- N/A
end

api_version = "1.12.0.0"