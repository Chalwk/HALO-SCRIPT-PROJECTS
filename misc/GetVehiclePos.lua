function OnScriptLoad()
    register_callback(cb['EVENT_OBJECT_SPAWN'], "OnObjectSpawn")
    register_callback(cb['EVENT_CHAT'], "OnChat")
end

function OnChat()
    if (get_var(0, '$gt') ~= 'n/a') then
        timer(1000, 'GET')
    end
end

local objects = {}
function OnObjectSpawn(_, _, _, ObjectID)
    objects[#objects + 1] = ObjectID
end

function GET()
    for _, i in pairs(objects) do
        local object = get_object_memory(i)
        if (object ~= 0) then
            local type = read_byte(object + 0xB4)
            if (type == 1) then
                local n = read_string(read_dword(read_word(object) * 32 + 0x40440038))
                local r = read_float(object + 0x82)
                local x, y, z = read_vector3d(object + 0x5c)
                cprint("{'vehi', '" .. n .. "', " .. x .. ", " .. y .. ", " .. z .. ", " .. r .. ', 30, 1 },')
            end
        end
    end
end

api_version = '1.12.0.0'