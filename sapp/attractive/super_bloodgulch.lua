--[[
=====================================================================================
SCRIPT NAME:      super_bloogulch.lua
DESCRIPTION:      Super Bloogulch mod for SAPP.

Copyright (c) 2022-2025 Jericho Crosby (Chalwk)
LICENSE:          MIT License
                  https://github.com/Chalwk/HALO-SCRIPT-PROJECTS/blob/master/LICENSE
=====================================================================================
]]


api_version = "1.12.0.0"

function OnScriptLoad()
    register_callback(cb['EVENT_GAME_START'], "OnGameStart")
    register_callback(cb['EVENT_DAMAGE_APPLICATION'], "OnDamageApplication")
    if (get_var(0, "$gt") ~= "n/a") then
        ModifyGameDependicies()
    end
end

function OnScriptUnload()
    --
end

function OnGameStart()
    if (get_var(0, "$gt") ~= "n/a") then
        ModifyGameDependicies()
    end
end

function ModifyGameDependicies()
    local tag_address = read_dword(0x40440000)
    local tag_count = read_dword(0x4044000C)
    -- weapons\assault rifle\bullet.jpt!
    for i = 0, tag_count - 1 do
        local tag = tag_address + 0x20 * i
        local tag_name = read_string(read_dword(tag + 0x10))
        local tag_class = read_dword(tag)
        if (tag_class == 1785754657 and tag_name == "weapons\\assault rifle\\bullet") then
            local tag_data = read_dword(tag + 0x14)
            write_dword(tag_data + 0x1d0, 1133936640)
            write_dword(tag_data + 0x1d4, 1137213440)
            write_dword(tag_data + 0x1d8, 1140490240)
            write_dword(tag_data + 0x1f4, 1075838976)
            break
        end
    end
    -- weapons\pistol\pistol.weap
    for i = 0, tag_count - 1 do
        local tag = tag_address + 0x20 * i
        local tag_name = read_string(read_dword(tag + 0x10))
        local tag_class = read_dword(tag)
        if (tag_class == 2003132784 and tag_name == "weapons\\pistol\\pistol") then
            local tag_data = read_dword(tag + 0x14)
            write_dword(tag_data + 0x308, 32)
            write_dword(tag_data + 0x3e0, 1082130432)
            write_dword(tag_data + 0x71c, 34340864)
            write_dword(tag_data + 0x720, 1573114)
            write_dword(tag_data + 0x730, 24)
            write_dword(tag_data + 0x7a8, 1103626240)
            write_dword(tag_data + 0x7ac, 1103626240)
            write_dword(tag_data + 0x7c4, 0)
            write_dword(tag_data + 0x820, 841731191)
            write_dword(tag_data + 0x824, 869711765)
            break
        end
    end
    -- weapons\pistol\melee.jpt!
    for i = 0, tag_count - 1 do
        local tag = tag_address + 0x20 * i
        local tag_name = read_string(read_dword(tag + 0x10))
        local tag_class = read_dword(tag)
        if (tag_class == 1785754657 and tag_name == "weapons\\pistol\\melee") then
            local tag_data = read_dword(tag + 0x14)
            write_dword(tag_data + 0x1d0, 1148846080)
            write_dword(tag_data + 0x1d4, 1148846080)
            write_dword(tag_data + 0x1d8, 1148846080)
            break
        end
    end
    -- weapons\pistol\bullet.proj
    for i = 0, tag_count - 1 do
        local tag = tag_address + 0x20 * i
        local tag_name = read_string(read_dword(tag + 0x10))
        local tag_class = read_dword(tag)
        if (tag_class == 1886547818 and tag_name == "weapons\\pistol\\bullet") then
            local tag_data = read_dword(tag + 0x14)
            write_dword(tag_data + 0x1c8, 1148846080)
            write_dword(tag_data + 0x1e4, 1097859072)
            write_dword(tag_data + 0x1e8, 1097859072)
            break
        end
    end
    -- weapons\pistol\bullet.jpt!
    for i = 0, tag_count - 1 do
        local tag = tag_address + 0x20 * i
        local tag_name = read_string(read_dword(tag + 0x10))
        local tag_class = read_dword(tag)
        if (tag_class == 1785754657 and tag_name == "weapons\\pistol\\bullet") then
            local tag_data = read_dword(tag + 0x14)
            write_dword(tag_data + 0x1d0, 1133903872)
            write_dword(tag_data + 0x1d4, 1133903872)
            write_dword(tag_data + 0x1d8, 1133903872)
            write_dword(tag_data + 0x1e4, 1065353216)
            write_dword(tag_data + 0x1ec, 1041865114)
            write_dword(tag_data + 0x1f4, 1073741824)
            break
        end
    end
    -- vehicles\warthog\warthog gun.weap
    for i = 0, tag_count - 1 do
        local tag = tag_address + 0x20 * i
        local tag_name = read_string(read_dword(tag + 0x10))
        local tag_class = read_dword(tag)
        if (tag_class == 2003132784 and tag_name == "vehicles\\warthog\\warthog gun") then
            local tag_data = read_dword(tag + 0x14)
            write_dword(tag_data + 0x928, 1078307906)
            SwapDependency(tag_data + 0x930, "vehicles\\scorpion\\tank shell", 1886547818)
            break
        end
    end
    -- vehicles\scorpion\tank shell.proj
    for i = 0, tag_count - 1 do
        local tag = tag_address + 0x20 * i
        local tag_name = read_string(read_dword(tag + 0x10))
        local tag_class = read_dword(tag)
        if (tag_class == 1886547818 and tag_name == "vehicles\\scorpion\\tank shell") then
            local tag_data = read_dword(tag + 0x14)
            write_dword(tag_data + 0x1e4, 1114636288)
            write_dword(tag_data + 0x1e8, 1114636288)
            break
        end
    end
    -- vehicles\scorpion\shell explosion.jpt!
    for i = 0, tag_count - 1 do
        local tag = tag_address + 0x20 * i
        local tag_name = read_string(read_dword(tag + 0x10))
        local tag_class = read_dword(tag)
        if (tag_class == 1785754657 and tag_name == "vehicles\\scorpion\\shell explosion") then
            local tag_data = read_dword(tag + 0x14)
            write_dword(tag_data + 0x0, 1073741824)
            write_dword(tag_data + 0x4, 1081081856)
            write_dword(tag_data + 0xcc, 1061158912)
            write_dword(tag_data + 0xd4, 1011562294)
            write_dword(tag_data + 0x1d0, 1131413504)
            write_dword(tag_data + 0x1f4, 1092091904)
            break
        end
    end
    -- weapons\frag grenade\shock wave.jpt!
    for i = 0, tag_count - 1 do
        local tag = tag_address + 0x20 * i
        local tag_name = read_string(read_dword(tag + 0x10))
        local tag_class = read_dword(tag)
        if (tag_class == 1785754657 and tag_name == "weapons\\frag grenade\\shock wave") then
            local tag_data = read_dword(tag + 0x14)
            write_dword(tag_data + 0xd4, 1048576000)
            write_dword(tag_data + 0xd8, 1022739087)
            break
        end
    end
    -- vehicles\ghost\mp_ghost gun.weap
    for i = 0, tag_count - 1 do
        local tag = tag_address + 0x20 * i
        local tag_name = read_string(read_dword(tag + 0x10))
        local tag_class = read_dword(tag)
        if (tag_class == 2003132784 and tag_name == "vehicles\\ghost\\mp_ghost gun") then
            local tag_data = read_dword(tag + 0x14)
            write_dword(tag_data + 0x6dc, 1638400)
            break
        end
    end
    -- vehicles\ghost\ghost bolt.proj
    for i = 0, tag_count - 1 do
        local tag = tag_address + 0x20 * i
        local tag_name = read_string(read_dword(tag + 0x10))
        local tag_class = read_dword(tag)
        if (tag_class == 1886547818 and tag_name == "vehicles\\ghost\\ghost bolt") then
            local tag_data = read_dword(tag + 0x14)
            write_dword(tag_data + 0x1c8, 1140457472)
            write_dword(tag_data + 0x1ec, 1056964608)
            break
        end
    end
    -- vehicles\ghost\ghost bolt.jpt!
    for i = 0, tag_count - 1 do
        local tag = tag_address + 0x20 * i
        local tag_name = read_string(read_dword(tag + 0x10))
        local tag_class = read_dword(tag)
        if (tag_class == 1785754657 and tag_name == "vehicles\\ghost\\ghost bolt") then
            local tag_data = read_dword(tag + 0x14)
            write_dword(tag_data + 0x1d4, 1103626240)
            write_dword(tag_data + 0x1d8, 1108082688)
            write_dword(tag_data + 0x1f4, 1073741824)
            break
        end
    end
    -- vehicles\rwarthog\rwarthog_gun.weap
    for i = 0, tag_count - 1 do
        local tag = tag_address + 0x20 * i
        local tag_name = read_string(read_dword(tag + 0x10))
        local tag_class = read_dword(tag)
        if (tag_class == 2003132784 and tag_name == "vehicles\\rwarthog\\rwarthog_gun") then
            local tag_data = read_dword(tag + 0x14)
            write_dword(tag_data + 0x64c, 655294464)
            write_dword(tag_data + 0x650, 1320719)
            write_dword(tag_data + 0x660, 20)
            write_dword(tag_data + 0x6c0, 993039)
            write_dword(tag_data + 0x6d0, 15)
            write_dword(tag_data + 0x794, 131072)
            break
        end
    end
    -- weapons\rocket launcher\rocket.proj
    for i = 0, tag_count - 1 do
        local tag = tag_address + 0x20 * i
        local tag_name = read_string(read_dword(tag + 0x10))
        local tag_class = read_dword(tag)
        if (tag_class == 1886547818 and tag_name == "weapons\\rocket launcher\\rocket") then
            local tag_data = read_dword(tag + 0x14)
            write_dword(tag_data + 0x1c8, 1148846080)
            break
        end
    end
    -- weapons\rocket launcher\explosion.jpt!
    for i = 0, tag_count - 1 do
        local tag = tag_address + 0x20 * i
        local tag_name = read_string(read_dword(tag + 0x10))
        local tag_class = read_dword(tag)
        if (tag_class == 1785754657 and tag_name == "weapons\\rocket launcher\\explosion") then
            local tag_data = read_dword(tag + 0x14)
            write_dword(tag_data + 0x0, 1077936128)
            write_dword(tag_data + 0x4, 1080033280)
            write_dword(tag_data + 0xcc, 1061158912)
            write_dword(tag_data + 0xd4, 1011562294)
            write_dword(tag_data + 0x1d0, 1120403456)
            write_dword(tag_data + 0x1d4, 1137180672)
            write_dword(tag_data + 0x1d8, 1137180672)
            write_dword(tag_data + 0x1f4, 1094713344)
            break
        end
    end
    -- vehicles\banshee\mp_banshee gun.weap
    for i = 0, tag_count - 1 do
        local tag = tag_address + 0x20 * i
        local tag_name = read_string(read_dword(tag + 0x10))
        local tag_class = read_dword(tag)
        if (tag_class == 2003132784 and tag_name == "vehicles\\banshee\\mp_banshee gun") then
            local tag_data = read_dword(tag + 0x14)
            write_dword(tag_data + 0x5cc, 8224)
            write_dword(tag_data + 0x5ec, 65536)
            write_dword(tag_data + 0x604, 655294464)
            write_dword(tag_data + 0x608, 141071)
            write_dword(tag_data + 0x618, 2)
            write_dword(tag_data + 0x638, 196608)
            write_dword(tag_data + 0x64c, 0)
            write_dword(tag_data + 0x678, 665359)
            write_dword(tag_data + 0x688, 10)
            write_dword(tag_data + 0x74c, 196608)
            write_dword(tag_data + 0x860, 196608)
            write_dword(tag_data + 0x88c, 1078314612)
            SwapDependency(tag_data + 0x894, "weapons\\rocket launcher\\rocket", 1886547818)
            break
        end
    end
    -- vehicles\banshee\banshee bolt.proj
    for i = 0, tag_count - 1 do
        local tag = tag_address + 0x20 * i
        local tag_name = read_string(read_dword(tag + 0x10))
        local tag_class = read_dword(tag)
        if (tag_class == 1886547818 and tag_name == "vehicles\\banshee\\banshee bolt") then
            local tag_data = read_dword(tag + 0x14)
            write_dword(tag_data + 0x1c8, 1148846080)
            write_dword(tag_data + 0x1ec, 1056964608)
            break
        end
    end
    -- vehicles\banshee\banshee bolt.jpt!
    for i = 0, tag_count - 1 do
        local tag = tag_address + 0x20 * i
        local tag_name = read_string(read_dword(tag + 0x10))
        local tag_class = read_dword(tag)
        if (tag_class == 1785754657 and tag_name == "vehicles\\banshee\\banshee bolt") then
            local tag_data = read_dword(tag + 0x14)
            write_dword(tag_data + 0x0, 1082130432)
            write_dword(tag_data + 0x4, 1084227584)
            write_dword(tag_data + 0x1d0, 1125515264)
            write_dword(tag_data + 0x1d4, 1125515264)
            write_dword(tag_data + 0x1d8, 1125515264)
            write_dword(tag_data + 0x1f4, 1069547520)
            break
        end
    end
    -- vehicles\banshee\mp_banshee fuel rod.proj
    for i = 0, tag_count - 1 do
        local tag = tag_address + 0x20 * i
        local tag_name = read_string(read_dword(tag + 0x10))
        local tag_class = read_dword(tag)
        if (tag_class == 1886547818 and tag_name == "vehicles\\banshee\\mp_banshee fuel rod") then
            local tag_data = read_dword(tag + 0x14)
            write_dword(tag_data + 0x1c8, 1148846080)
            write_dword(tag_data + 0x1cc, 0)
            write_dword(tag_data + 0x1e4, 1053609165)
            write_dword(tag_data + 0x1e8, 1051372091)
            break
        end
    end
    -- weapons\shotgun\shotgun.weap
    for i = 0, tag_count - 1 do
        local tag = tag_address + 0x20 * i
        local tag_name = read_string(read_dword(tag + 0x10))
        local tag_class = read_dword(tag)
        if (tag_class == 2003132784 and tag_name == "weapons\\shotgun\\shotgun") then
            local tag_data = read_dword(tag + 0x14)
            write_dword(tag_data + 0x3e8, 1120403456)
            write_dword(tag_data + 0x3f0, 1120403456)
            write_dword(tag_data + 0xaf0, 1638400)
            break
        end
    end
    -- weapons\shotgun\pellet.proj
    for i = 0, tag_count - 1 do
        local tag = tag_address + 0x20 * i
        local tag_name = read_string(read_dword(tag + 0x10))
        local tag_class = read_dword(tag)
        if (tag_class == 1886547818 and tag_name == "weapons\\shotgun\\pellet") then
            local tag_data = read_dword(tag + 0x14)
            write_dword(tag_data + 0x1c8, 1148846080)
            write_dword(tag_data + 0x1d4, 1112014848)
            break
        end
    end
    -- weapons\shotgun\pellet.jpt!
    for i = 0, tag_count - 1 do
        local tag = tag_address + 0x20 * i
        local tag_name = read_string(read_dword(tag + 0x10))
        local tag_class = read_dword(tag)
        if (tag_class == 1785754657 and tag_name == "weapons\\shotgun\\pellet") then
            local tag_data = read_dword(tag + 0x14)
            write_dword(tag_data + 0x1d0, 1137213440)
            write_dword(tag_data + 0x1d4, 1140490240)
            write_dword(tag_data + 0x1d8, 1142308864)
            write_dword(tag_data + 0x1f4, 1077936128)
            break
        end
    end
    -- weapons\plasma rifle\plasma rifle.weap
    for i = 0, tag_count - 1 do
        local tag = tag_address + 0x20 * i
        local tag_name = read_string(read_dword(tag + 0x10))
        local tag_class = read_dword(tag)
        if (tag_class == 2003132784 and tag_name == "weapons\\plasma rifle\\plasma rifle") then
            local tag_data = read_dword(tag + 0x14)
            write_dword(tag_data + 0x3e8, 1140457472)
            write_dword(tag_data + 0x3f0, 1140457472)
            write_dword(tag_data + 0xd10, 327680)
            break
        end
    end
    -- weapons\plasma rifle\bolt.jpt!
    for i = 0, tag_count - 1 do
        local tag = tag_address + 0x20 * i
        local tag_name = read_string(read_dword(tag + 0x10))
        local tag_class = read_dword(tag)
        if (tag_class == 1785754657 and tag_name == "weapons\\plasma rifle\\bolt") then
            local tag_data = read_dword(tag + 0x14)
            write_dword(tag_data + 0x1d4, 1097859072)
            write_dword(tag_data + 0x1d8, 1103626240)
            write_dword(tag_data + 0x1f4, 1065353216)
            break
        end
    end
    -- weapons\frag grenade\explosion.jpt!
    for i = 0, tag_count - 1 do
        local tag = tag_address + 0x20 * i
        local tag_name = read_string(read_dword(tag + 0x10))
        local tag_class = read_dword(tag)
        if (tag_class == 1785754657 and tag_name == "weapons\\frag grenade\\explosion") then
            local tag_data = read_dword(tag + 0x14)
            write_dword(tag_data + 0x0, 1073741824)
            write_dword(tag_data + 0x4, 1083703296)
            write_dword(tag_data + 0xcc, 1061158912)
            write_dword(tag_data + 0xd4, 1011562294)
            write_dword(tag_data + 0x1d0, 1131413504)
            write_dword(tag_data + 0x1d4, 1135575040)
            write_dword(tag_data + 0x1d8, 1135575040)
            write_dword(tag_data + 0x1f4, 1092091904)
            break
        end
    end
    -- weapons\rocket launcher\melee.jpt!
    for i = 0, tag_count - 1 do
        local tag = tag_address + 0x20 * i
        local tag_name = read_string(read_dword(tag + 0x10))
        local tag_class = read_dword(tag)
        if (tag_class == 1785754657 and tag_name == "weapons\\rocket launcher\\melee") then
            local tag_data = read_dword(tag + 0x14)
            write_dword(tag_data + 0x1d0, 1148846080)
            write_dword(tag_data + 0x1d4, 1148846080)
            write_dword(tag_data + 0x1d8, 1148846080)
            break
        end
    end
    -- weapons\rocket launcher\trigger.jpt!
    for i = 0, tag_count - 1 do
        local tag = tag_address + 0x20 * i
        local tag_name = read_string(read_dword(tag + 0x10))
        local tag_class = read_dword(tag)
        if (tag_class == 1785754657 and tag_name == "weapons\\rocket launcher\\trigger") then
            local tag_data = read_dword(tag + 0x14)
            write_dword(tag_data + 0xcc, 1061158912)
            write_dword(tag_data + 0xd4, 1008981770)
            write_dword(tag_data + 0xd8, 1017370378)
            break
        end
    end
    -- weapons\sniper rifle\sniper rifle.weap
    for i = 0, tag_count - 1 do
        local tag = tag_address + 0x20 * i
        local tag_name = read_string(read_dword(tag + 0x10))
        local tag_class = read_dword(tag)
        if (tag_class == 2003132784 and tag_name == "weapons\\sniper rifle\\sniper rifle") then
            local tag_data = read_dword(tag + 0x14)
            write_dword(tag_data + 0x3e8, 1128792064)
            write_dword(tag_data + 0x3f0, 1128792064)
            write_dword(tag_data + 0x894, 7340032)
            write_dword(tag_data + 0x898, 786532)
            write_dword(tag_data + 0x8a8, 12)
            write_dword(tag_data + 0x920, 1075838976)
            write_dword(tag_data + 0x924, 1075838976)
            write_dword(tag_data + 0x9b4, 1078307906)
            SwapDependency(tag_data + 0x9bc, "vehicles\\scorpion\\tank shell", 1886547818)
            break
        end
    end
    -- weapons\sniper rifle\melee.jpt!
    for i = 0, tag_count - 1 do
        local tag = tag_address + 0x20 * i
        local tag_name = read_string(read_dword(tag + 0x10))
        local tag_class = read_dword(tag)
        if (tag_class == 1785754657 and tag_name == "weapons\\sniper rifle\\melee") then
            local tag_data = read_dword(tag + 0x14)
            write_dword(tag_data + 0xcc, 1061158912)
            write_dword(tag_data + 0xd4, 1011562294)
            write_dword(tag_data + 0x1d0, 1148846080)
            write_dword(tag_data + 0x1d4, 1148846080)
            write_dword(tag_data + 0x1d8, 1148846080)
            break
        end
    end
    -- weapons\sniper rifle\sniper bullet.proj
    for i = 0, tag_count - 1 do
        local tag = tag_address + 0x20 * i
        local tag_name = read_string(read_dword(tag + 0x10))
        local tag_class = read_dword(tag)
        if (tag_class == 1886547818 and tag_name == "weapons\\sniper rifle\\sniper bullet") then
            local tag_data = read_dword(tag + 0x14)
            write_dword(tag_data + 0x144, 1081053092)
            write_dword(tag_data + 0x180, 0)
            write_dword(tag_data + 0x1b0, 1078308047)
            SwapDependency(tag_data + 0x1b8, "vehicles\\scorpion\\shell explosion", 1701209701)
            write_dword(tag_data + 0x1e4, 1114636288)
            write_dword(tag_data + 0x1e8, 1114636288)
            write_dword(tag_data + 0x1f0, 2)
            write_dword(tag_data + 0x208, 1078308640)
            SwapDependency(tag_data + 0x210, "sound\\sfx\\impulse\\impacts\\scorpion_projectile", 1936614433)
            write_dword(tag_data + 0x228, 0)
            write_dword(tag_data + 0x230, 4294967295)
            write_dword(tag_data + 0x244, 1081053164)
            write_dword(tag_data + 0x250, 1078307935)
            SwapDependency(tag_data + 0x258, "vehicles\\scorpion\\shell", 1668247156)
            write_dword(tag_data + 0x294, 65536)
            write_dword(tag_data + 0x29c, 0)
            write_dword(tag_data + 0x2a4, 4294967295)
            write_dword(tag_data + 0x300, 1078308686)
            SwapDependency(tag_data + 0x308, "vehicles\\scorpion\\shell impact dirt", 1701209701)
            write_dword(tag_data + 0x334, 65536)
            write_dword(tag_data + 0x33c, 0)
            write_dword(tag_data + 0x344, 4294967295)
            write_dword(tag_data + 0x3d4, 65536)
            write_dword(tag_data + 0x3dc, 0)
            write_dword(tag_data + 0x3e4, 4294967295)
            write_dword(tag_data + 0x440, 1078308835)
            SwapDependency(tag_data + 0x448, "vehicles\\wraith\\effects\\impact stone", 1701209701)
            write_dword(tag_data + 0x474, 65536)
            write_dword(tag_data + 0x47c, 0)
            write_dword(tag_data + 0x484, 4294967295)
            write_dword(tag_data + 0x4e0, 1078309337)
            SwapDependency(tag_data + 0x4e8, "vehicles\\wraith\\effects\\impact snow", 1701209701)
            write_dword(tag_data + 0x514, 65536)
            write_dword(tag_data + 0x51c, 0)
            write_dword(tag_data + 0x524, 4294967295)
            write_dword(tag_data + 0x580, 1078309578)
            SwapDependency(tag_data + 0x588, "vehicles\\wraith\\effects\\impact wood", 1701209701)
            write_dword(tag_data + 0x5b4, 65536)
            write_dword(tag_data + 0x5bc, 0)
            write_dword(tag_data + 0x5c4, 4294967295)
            write_dword(tag_data + 0x620, 1078309614)
            SwapDependency(tag_data + 0x628, "weapons\\rocket launcher\\effects\\impact metal", 1701209701)
            write_dword(tag_data + 0x654, 65536)
            write_dword(tag_data + 0x65c, 0)
            write_dword(tag_data + 0x664, 4294967295)
            write_dword(tag_data + 0x6c0, 1078309614)
            SwapDependency(tag_data + 0x6c8, "weapons\\rocket launcher\\effects\\impact metal", 1701209701)
            write_dword(tag_data + 0x6f4, 65536)
            write_dword(tag_data + 0x6fc, 0)
            write_dword(tag_data + 0x704, 4294967295)
            write_dword(tag_data + 0x760, 1078309614)
            SwapDependency(tag_data + 0x768, "weapons\\rocket launcher\\effects\\impact metal", 1701209701)
            write_dword(tag_data + 0x794, 65536)
            write_dword(tag_data + 0x79c, 0)
            write_dword(tag_data + 0x7a4, 4294967295)
            write_dword(tag_data + 0x800, 1078309614)
            SwapDependency(tag_data + 0x808, "weapons\\rocket launcher\\effects\\impact metal", 1701209701)
            write_dword(tag_data + 0x834, 65536)
            write_dword(tag_data + 0x83c, 0)
            write_dword(tag_data + 0x844, 4294967295)
            write_dword(tag_data + 0x8a0, 1078309659)
            SwapDependency(tag_data + 0x8a8, "vehicles\\wraith\\effects\\impact ice", 1701209701)
            write_dword(tag_data + 0x8d4, 65536)
            write_dword(tag_data + 0x8dc, 0)
            write_dword(tag_data + 0x8e4, 4294967295)
            write_dword(tag_data + 0x974, 65536)
            write_dword(tag_data + 0x97c, 0)
            write_dword(tag_data + 0x984, 4294967295)
            write_dword(tag_data + 0xa14, 65536)
            write_dword(tag_data + 0xa1c, 0)
            write_dword(tag_data + 0xa24, 4294967295)
            write_dword(tag_data + 0xab4, 65536)
            write_dword(tag_data + 0xabc, 0)
            write_dword(tag_data + 0xac4, 4294967295)
            write_dword(tag_data + 0xb54, 65536)
            write_dword(tag_data + 0xb5c, 0)
            write_dword(tag_data + 0xb64, 4294967295)
            write_dword(tag_data + 0xbf4, 65536)
            write_dword(tag_data + 0xbfc, 0)
            write_dword(tag_data + 0xc04, 4294967295)
            write_dword(tag_data + 0xc94, 65536)
            write_dword(tag_data + 0xc9c, 0)
            write_dword(tag_data + 0xca4, 4294967295)
            write_dword(tag_data + 0xd34, 65536)
            write_dword(tag_data + 0xd3c, 0)
            write_dword(tag_data + 0xd44, 4294967295)
            write_dword(tag_data + 0xdd4, 65536)
            write_dword(tag_data + 0xddc, 0)
            write_dword(tag_data + 0xde4, 4294967295)
            write_dword(tag_data + 0xe74, 65536)
            write_dword(tag_data + 0xe7c, 0)
            write_dword(tag_data + 0xe84, 4294967295)
            write_dword(tag_data + 0xf14, 65536)
            write_dword(tag_data + 0xf1c, 0)
            write_dword(tag_data + 0xf24, 4294967295)
            write_dword(tag_data + 0xfb4, 65536)
            write_dword(tag_data + 0xfbc, 0)
            write_dword(tag_data + 0xfc4, 4294967295)
            write_dword(tag_data + 0x1054, 65536)
            write_dword(tag_data + 0x105c, 0)
            write_dword(tag_data + 0x1064, 4294967295)
            write_dword(tag_data + 0x10f4, 65536)
            write_dword(tag_data + 0x10fc, 0)
            write_dword(tag_data + 0x1104, 4294967295)
            write_dword(tag_data + 0x1194, 65536)
            write_dword(tag_data + 0x119c, 0)
            write_dword(tag_data + 0x11a4, 4294967295)
            write_dword(tag_data + 0x1234, 65536)
            write_dword(tag_data + 0x123c, 0)
            write_dword(tag_data + 0x1244, 4294967295)
            write_dword(tag_data + 0x12d4, 65536)
            write_dword(tag_data + 0x12dc, 0)
            write_dword(tag_data + 0x12e4, 4294967295)
            write_dword(tag_data + 0x1374, 65536)
            write_dword(tag_data + 0x137c, 0)
            write_dword(tag_data + 0x1384, 4294967295)
            write_dword(tag_data + 0x1414, 65536)
            write_dword(tag_data + 0x141c, 0)
            write_dword(tag_data + 0x1424, 4294967295)
            write_dword(tag_data + 0x1480, 1078309694)
            SwapDependency(tag_data + 0x1488, "weapons\\rocket launcher\\effects\\impact water", 1701209701)
            write_dword(tag_data + 0x14b4, 65536)
            write_dword(tag_data + 0x14bc, 0)
            write_dword(tag_data + 0x14c4, 4294967295)
            write_dword(tag_data + 0x1520, 1078309777)
            SwapDependency(tag_data + 0x1528, "weapons\\frag grenade\\effects\\impact water pen", 1701209701)
            write_dword(tag_data + 0x1554, 65536)
            write_dword(tag_data + 0x155c, 0)
            write_dword(tag_data + 0x1564, 4294967295)
            write_dword(tag_data + 0x15f4, 65536)
            write_dword(tag_data + 0x15fc, 0)
            write_dword(tag_data + 0x1604, 4294967295)
            write_dword(tag_data + 0x1660, 1078309659)
            SwapDependency(tag_data + 0x1668, "vehicles\\wraith\\effects\\impact ice", 1701209701)
            write_dword(tag_data + 0x1694, 65536)
            write_dword(tag_data + 0x169c, 0)
            write_dword(tag_data + 0x16a4, 4294967295)
            break
        end
    end
    -- weapons\plasma grenade\explosion.jpt!
    for i = 0, tag_count - 1 do
        local tag = tag_address + 0x20 * i
        local tag_name = read_string(read_dword(tag + 0x10))
        local tag_class = read_dword(tag)
        if (tag_class == 1785754657 and tag_name == "weapons\\plasma grenade\\explosion") then
            local tag_data = read_dword(tag + 0x14)
            write_dword(tag_data + 0x4, 1086324736)
            write_dword(tag_data + 0x1d0, 1140457472)
            write_dword(tag_data + 0x1d4, 1140457472)
            write_dword(tag_data + 0x1d8, 1140457472)
            write_dword(tag_data + 0x1f4, 1094713344)
            break
        end
    end
    -- weapons\plasma_cannon\plasma_cannon.weap
    for i = 0, tag_count - 1 do
        local tag = tag_address + 0x20 * i
        local tag_name = read_string(read_dword(tag + 0x10))
        local tag_class = read_dword(tag)
        if (tag_class == 2003132784 and tag_name == "weapons\\plasma_cannon\\plasma_cannon") then
            local tag_data = read_dword(tag + 0x14)
            write_dword(tag_data + 0x92c, 196608)
            break
        end
    end
    -- weapons\plasma_cannon\plasma_cannon.proj
    for i = 0, tag_count - 1 do
        local tag = tag_address + 0x20 * i
        local tag_name = read_string(read_dword(tag + 0x10))
        local tag_class = read_dword(tag)
        if (tag_class == 1886547818 and tag_name == "weapons\\plasma_cannon\\plasma_cannon") then
            local tag_data = read_dword(tag + 0x14)
            write_dword(tag_data + 0x1b0, 1078308047)
            SwapDependency(tag_data + 0x1b8, "vehicles\\scorpion\\shell explosion", 1701209701)
            break
        end
    end
    -- weapons\plasma_cannon\effects\plasma_cannon_explosion.jpt!
    for i = 0, tag_count - 1 do
        local tag = tag_address + 0x20 * i
        local tag_name = read_string(read_dword(tag + 0x10))
        local tag_class = read_dword(tag)
        if (tag_class == 1785754657 and tag_name == "weapons\\plasma_cannon\\effects\\plasma_cannon_explosion") then
            local tag_data = read_dword(tag + 0x14)
            write_dword(tag_data + 0x1d0, 1142308864)
            write_dword(tag_data + 0x1d4, 1142308864)
            write_dword(tag_data + 0x1d8, 1142308864)
            write_dword(tag_data + 0x1f4, 1083179008)
            break
        end
    end
    -- weapons\plasma_cannon\impact damage.jpt!
    for i = 0, tag_count - 1 do
        local tag = tag_address + 0x20 * i
        local tag_name = read_string(read_dword(tag + 0x10))
        local tag_class = read_dword(tag)
        if (tag_class == 1785754657 and tag_name == "weapons\\plasma_cannon\\impact damage") then
            local tag_data = read_dword(tag + 0x14)
            write_dword(tag_data + 0x1d0, 1142308864)
            write_dword(tag_data + 0x1d4, 1142308864)
            write_dword(tag_data + 0x1d8, 1142308864)
            write_dword(tag_data + 0x1f4, 1083179008)
            break
        end
    end
    -- weapons\plasma rifle\charged bolt.jpt!
    for i = 0, tag_count - 1 do
        local tag = tag_address + 0x20 * i
        local tag_name = read_string(read_dword(tag + 0x10))
        local tag_class = read_dword(tag)
        if (tag_class == 1785754657 and tag_name == "weapons\\plasma rifle\\charged bolt") then
            local tag_data = read_dword(tag + 0x14)
            write_dword(tag_data + 0x0, 1084227584)
            write_dword(tag_data + 0x4, 1090519040)
            write_dword(tag_data + 0xcc, 1065353216)
            write_dword(tag_data + 0xd4, 1017370378)
            write_dword(tag_data + 0x1d0, 1140457472)
            write_dword(tag_data + 0x1d4, 1140457472)
            write_dword(tag_data + 0x1d8, 1140457472)
            write_dword(tag_data + 0x1f4, 1097859072)
            break
        end
    end
    -- weapons\frag grenade\frag grenade.proj
    for i = 0, tag_count - 1 do
        local tag = tag_address + 0x20 * i
        local tag_name = read_string(read_dword(tag + 0x10))
        local tag_class = read_dword(tag)
        if (tag_class == 1886547818 and tag_name == "weapons\\frag grenade\\frag grenade") then
            local tag_data = read_dword(tag + 0x14)
            write_dword(tag_data + 0x1bc, 1050253722)
            write_dword(tag_data + 0x1c0, 1050253722)
            write_dword(tag_data + 0x1cc, 1057803469)
            write_dword(tag_data + 0x1ec, 1065353216)
            break
        end
    end
    -- weapons\plasma grenade\plasma grenade.proj
    for i = 0, tag_count - 1 do
        local tag = tag_address + 0x20 * i
        local tag_name = read_string(read_dword(tag + 0x10))
        local tag_class = read_dword(tag)
        if (tag_class == 1886547818 and tag_name == "weapons\\plasma grenade\\plasma grenade") then
            local tag_data = read_dword(tag + 0x14)
            write_dword(tag_data + 0x1bc, 1065353216)
            write_dword(tag_data + 0x1c0, 1065353216)
            write_dword(tag_data + 0x1cc, 1056964608)
            write_dword(tag_data + 0x1ec, 1077936128)
            break
        end
    end
    -- weapons\plasma grenade\attached.jpt!
    for i = 0, tag_count - 1 do
        local tag = tag_address + 0x20 * i
        local tag_name = read_string(read_dword(tag + 0x10))
        local tag_class = read_dword(tag)
        if (tag_class == 1785754657 and tag_name == "weapons\\plasma grenade\\attached") then
            local tag_data = read_dword(tag + 0x14)
            write_dword(tag_data + 0x1d0, 1137180672)
            write_dword(tag_data + 0x1d4, 1137180672)
            write_dword(tag_data + 0x1d8, 1137180672)
            write_dword(tag_data + 0x1f4, 1092616192)
            break
        end
    end
    -- vehicles\c gun turret\c gun turret_mp.vehi
    for i = 0, tag_count - 1 do
        local tag = tag_address + 0x20 * i
        local tag_name = read_string(read_dword(tag + 0x10))
        local tag_class = read_dword(tag)
        if (tag_class == 1986357353 and tag_name == "vehicles\\c gun turret\\c gun turret_mp") then
            local tag_data = read_dword(tag + 0x14)
            write_dword(tag_data + 0x8c, 4294967295)
            write_dword(tag_data + 0x9c0, 973078558)
            break
        end
    end
    -- vehicles\c gun turret\mp gun turret gun.weap
    for i = 0, tag_count - 1 do
        local tag = tag_address + 0x20 * i
        local tag_name = read_string(read_dword(tag + 0x10))
        local tag_class = read_dword(tag)
        if (tag_class == 2003132784 and tag_name == "vehicles\\c gun turret\\mp gun turret gun") then
            local tag_data = read_dword(tag + 0x14)
            write_dword(tag_data + 0x8b4, 3276800)
            break
        end
    end
    -- globals\falling.jpt!
    for i = 0, tag_count - 1 do
        local tag = tag_address + 0x20 * i
        local tag_name = read_string(read_dword(tag + 0x10))
        local tag_class = read_dword(tag)
        if (tag_class == 1785754657 and tag_name == "globals\\falling") then
            local tag_data = read_dword(tag + 0x14)
            write_dword(tag_data + 0x1d4, 1092616192)
            write_dword(tag_data + 0x1d8, 1092616192)
            break
        end
    end
end

function SwapDependency(Address, ToTag, ToClass)
    local tag_address = read_dword(0x40440000)
    local tag_count = read_dword(0x4044000C)
    for i = 0, tag_count - 1 do
        local tag = tag_address + 0x20 * i
        if (read_dword(tag) == ToClass and read_string(read_dword(tag + 0x10)) == ToTag) then
            write_dword(Address, read_dword(tag + 0xC))
            return
        end
    end
end

local function Tag(obj_type, obj_name)
    local tag = lookup_tag(obj_type, obj_name)
    return tag ~= 0 and read_dword(tag + 0xC) or nil
end

function OnDamageApplication(PlayerIndex, CauserIndex, MetaID, Damage, HitString, Backtap)
    if (PlayerIndex == CauserIndex) then
        if (MetaID == Tag("jpt!", "vehicles\\scorpion\\shell explosion")) then
            return true, Damage * 0
        end
    end
end
