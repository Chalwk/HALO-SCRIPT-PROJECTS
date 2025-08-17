api_version = '1.12.0.0'

function OnScriptLoad()
    register_callback(cb['EVENT_TICK'], 'OnTick')
    register_callback(cb['EVENT_COMMAND'], 'Reset')
end

local str, state, count, mode = '', 0, 0, 1
local format, p = string.format, '%0.3f'

local function GetTeleportPair(i, x, y, z, r)
    if count == 0 then
        rprint(i, 'origin x,y,z set')
        str = format('{ %s, %s, %s, 0.5, ', x, y, z)
        count = 1
    else
        rprint(i, 'destination x,y,z set')
        str = format('%s%s, %s, %s, %s },', str, x, y, z, r)
        count = 0
        cprint(str)
    end
end

local function GetVehiclePos(i, x, y, z, r)
    rprint(i, 'vehicle position saved')
    cprint(format('{ %s, %s, %s, %s, 30, 1 },', x, y, z, r))
end

function OnTick()
    for i = 1, 16 do
        if player_present(i) and player_alive(i) then
            local dyn = get_dynamic_player(i)
            if dyn ~= 0 then
                local shooting = read_float(dyn + 0x490)
                if shooting ~= state and shooting == 1 then
                    local r = format(p, read_float(dyn + 0x82))
                    local x, y, z = read_vector3d(dyn + 0x5C)
                    x, y, z = format(p, x), format(p, y), format(p, z)
                    if mode == 1 then
                        GetTeleportPair(i, x, y, z, r)
                    else
                        GetVehiclePos(i, x, y, z, r)
                    end
                end
                state = shooting
            end
        end
    end
end

local function Split(CMD)
    local t = {}
    for Params in CMD:gmatch('%S+') do
        t[#t + 1] = Params:lower()
    end
    return t
end

function Reset(Ply, CMD)
    local args = Split(CMD)
    if args[1] == 'reset' then
        count = 0
        rprint(Ply, 'Coords reset.')
        return false
    elseif args[1] == 'mode' then
        mode = tonumber(args[2])
        rprint(Ply, 'MODE: ' .. mode .. (mode == 1 and ' [TELEPORTS]' or ' [VEHICLES]'))
        return false
    end
end

function OnScriptUnload()
    -- N/A
end