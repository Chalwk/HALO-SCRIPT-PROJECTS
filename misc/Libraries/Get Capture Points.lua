api_version = "1.12.0.0"

local ctf_globals

function OnScriptLoad()
    local pointer = sig_scan("8B3C85????????3BF9741FE8????????8B8E2C0200008B4610") + 3
    if (pointer == 3) then
        return
    end
    ctf_globals = read_dword(pointer)
    register_callback(cb["EVENT_GAME_START"], "START")
end

function START()

    local rx, ry, rz = read_vector3d(read_dword(ctf_globals))
    local bx, by, bz = read_vector3d(read_dword(ctf_globals + 4))

    cprint("{" .. rx .. "," .. ry .. "," .. rz .. "},")
    cprint("{" .. bx .. "," .. by .. "," .. bz .. "}")
end