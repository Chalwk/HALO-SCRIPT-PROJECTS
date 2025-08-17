--[[
--=====================================================================================================--
Script Name: Modify Tags, for SAPP (PC & CE)
Description: Frags & Plasma grenades are both super powerful
             and you can throw them 5x further than vanilla settings.

Copyright (c) 2021, Jericho Crosby <jericho.crosby227@gmail.com>
Notice: You can use this script subject to the following conditions:
https://github.com/Chalwk/HALO-SCRIPT-PROJECTS/blob/master/LICENSE
--=====================================================================================================--
]]--


api_version = "1.12.0.0"

function OnScriptLoad()
    register_callback(cb["EVENT_GAME_START"], "OnGameStart")
end

function OnGameStart()
    if (get_var(0, "$gt") ~= "n/a") then

        local tag_address = read_dword(0x40440000)
        local tag_count = read_dword(0x4044000C)

        for i=0,tag_count-1 do

            local tag = tag_address + 0x20 * i
            local tag_class = read_dword(tag)
            local tag_data = read_dword(tag + 0x14)
            local tag_name = read_string(read_dword(tag + 0x10))

            -- weapons\frag grenade\shock wave.jpt!
            if (tag_class == 1785754657 and tag_name == "weapons\\frag grenade\\shock wave") then
                write_dword(tag_data + 0xd4, 1048576000)
                write_dword(tag_data + 0xd8, 1022739087)
            end

            -- weapons\frag grenade\explosion.jpt!
            -- cmt\weapons\evolved\human\frag_grenade\damage_effects\frag_grenade_explosion.jpt!
            local frag_explosion = "weapons\\frag grenade\\explosion"
            local tsce_frag_explosion = "cmt\\weapons\\evolved\\human\\frag_grenade\\damage_effects\\frag_grenade_explosion"
            if (tag_class == 1785754657 and tag_name == frag_explosion or tag_name == tsce_frag_explosion) then
                write_dword(tag_data + 0x0, 1073741824)
                write_dword(tag_data + 0x4, 1083703296)
                write_dword(tag_data + 0xcc, 1061158912)
                write_dword(tag_data + 0xd4, 1011562294)
                write_dword(tag_data + 0x1d0, 1131413504)
                write_dword(tag_data + 0x1d4, 1135575040)
                write_dword(tag_data + 0x1d8, 1135575040)
                write_dword(tag_data + 0x1f4, 1092091904)
            end

            -- weapons\frag grenade\frag grenade.proj
            if (tag_class == 1886547818 and tag_name == "weapons\\frag grenade\\frag grenade") then
                write_dword(tag_data + 0x1bc, 1050253722)
                write_dword(tag_data + 0x1c0, 1050253722)
                write_dword(tag_data + 0x1cc, 1057803469)
                write_dword(tag_data + 0x1ec, 1065353216)
            end

            -- cmt\weapons\evolved\covenant\plasma_grenade\damage_effects\plasma_grenade_explosion.jpt!
            -- weapons\plasma grenade\explosion.jpt!
            local plasma_explosion = "weapons\\plasma grenade\\explosion"
            local tsce_plasma_explosion = "cmt\\weapons\\evolved\\covenant\\plasma_grenade\\damage_effects\\plasma_grenade_explosion"
            if (tag_class == 1785754657 and tag_name == plasma_explosion or tag_name == tsce_plasma_explosion) then
                write_dword(tag_data + 0x4, 1086324736)
                write_dword(tag_data + 0x1d0, 1140457472)
                write_dword(tag_data + 0x1d4, 1140457472)
                write_dword(tag_data + 0x1d8, 1140457472)
                write_dword(tag_data + 0x1f4, 1094713344)
            end

            -- weapons\plasma grenade\plasma grenade.proj
            if (tag_class == 1886547818 and tag_name == "weapons\\plasma grenade\\plasma grenade") then
                write_dword(tag_data + 0x1bc, 1065353216)
                write_dword(tag_data + 0x1c0, 1065353216)
                write_dword(tag_data + 0x1cc, 1056964608)
                write_dword(tag_data + 0x1ec, 1077936128)
            end

            -- cmt\weapons\evolved\covenant\plasma_grenade\damage_effects\plasma_grenade_attached.jpt!
            -- weapons\plasma grenade\attached.jpt!
            local plasma_attached = "cmt\\weapons\\evolved\\covenant\\plasma_grenade\\damage_effects\\plasma_grenade_attached"
            local tsce_plasma_attached = "weapons\\plasma grenade\\attached"
            if (tag_class == 1785754657 and tag_name == plasma_attached or tag_name == tsce_plasma_attached) then
                write_dword(tag_data + 0x1d0, 1137180672)
                write_dword(tag_data + 0x1d4, 1137180672)
                write_dword(tag_data + 0x1d8, 1137180672)
                write_dword(tag_data + 0x1f4, 1092616192)
            end

            -- vehicles\c gun turret\mp gun turret gun.weap
            if (tag_class == 2003132784 and tag_name == "vehicles\\c gun turret\\mp gun turret gun") then
                write_dword(tag_data + 0x8b4, 3276800)
            end
        end
    end
end