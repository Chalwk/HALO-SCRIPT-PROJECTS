-- Custom Teleports, by Chalwk
-- For Naked Chick.

api_version = "1.12.0.0"

api_version = "1.12.0.0"

local Teleports = {
    ["Sniper Island"] = {
        { 20.5739, 129.558, 17.6009, 0.5, 39.0283, 65.921, 16.3919, 0.2 },
        { 000, 000, 000, 0, 000, 000, 000, 0 },
    },
    ["map_name_here"] = {
        { 000, 000, 000, 0, 000, 000, 000, 0 },
    },
}

local coordinates
local sqrt = math.sqrt

function OnScriptLoad()
    register_callback(cb["EVENT_GAME_START"], "OnGameStart")
    register_callback(cb["EVENT_TICK"], "OnTick")
    OnGameStart()
end

function OnGameStart()
    coordinates = Teleports[get_var(0, "$map")]
end

local function GetPortal(x, y, z)
    for _, t in pairs(coordinates) do

        local px1, py1, pz1, radius, px2, py2, pz2, height = unpack(t)

        if sqrt((x - px1)^2 + (y - py1)^2 + (z - pz1)^2) <= radius then
            return { x = px2, y = py2, z = pz2 + height }
        end
    end
end

function OnTick()
    if coordinates then
        for i = 1, 16 do
            if player_present(i) and player_alive(i) then
                local DyN = get_dynamic_player(i)
                if DyN ~= 0 and read_dword(DyN + 0x11C) == 0xFFFFFFFF then
                    local x, y, z = read_vector3d(DyN + 0x5C)
                    local new_pos = GetPortal(x, y, z)
                    if new_pos then
                        write_vector3d(DyN + 0x5C, new_pos.x, new_pos.y, new_pos.z)
                    end
                end
            end
        end
    end
end

function OnScriptUnload()
    -- N/A
end