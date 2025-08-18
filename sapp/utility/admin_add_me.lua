--[[
--=====================================================================================================--
Script Name: HPC Admin-Add-Me (utility), for SAPP (PC & CE)
Description:    Type "/admin me" in chat to add yourself as an admin - (level 4 by default)
                This was particularly useful to me when testing other scripts.
                I'm sure you can think of some creative reasons to use this.

Copyright (c) 2016-2022, Jericho Crosby <jericho.crosby227@gmail.com>
Notice: You can use this script subject to the following conditions:
https://github.com/Chalwk/HALO-SCRIPT-PROJECTS/blob/master/LICENSE
--=====================================================================================================--
]]--

local MOD = {

    -- Default admin level to set:
    --
    level = 4,

    users = {
        'PlayerName',
        'xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx',
        "127.0.0.1"
    },

    -- List of all known pirated hashes:
    --
    known_pirated_hashes = {
        ['388e89e69b4cc08b3441f25959f74103'] = true,
        ['81f9c914b3402c2702a12dc1405247ee'] = true,
        ['c939c09426f69c4843ff75ae704bf426'] = true,
        ['13dbf72b3c21c5235c47e405dd6e092d'] = true,
        ['29a29f3659a221351ed3d6f8355b2200'] = true,
        ['d72b3f33bfb7266a8d0f13b37c62fddb'] = true,
        ['76b9b8db9ae6b6cacdd59770a18fc1d5'] = true,
        ['55d368354b5021e7dd5d3d1525a4ab82'] = true,
        ['d41d8cd98f00b204e9800998ecf8427e'] = true,
        ['c702226e783ea7e091c0bb44c2d0ec64'] = true,
        ['f443106bd82fd6f3c22ba2df7c5e4094'] = true,
        ['10440b462f6cbc3160c6280c2734f184'] = true,
        ['3d5cd27b3fa487b040043273fa00f51b'] = true,
        ['b661a51d4ccf44f5da2869b0055563cb'] = true,
        ['740da6bafb23c2fbdc5140b5d320edb1'] = true,
        ['7503dad2a08026fc4b6cfb32a940cfe0'] = true,
        ['4486253cba68da6786359e7ff2c7b467'] = true,
        ['f1d7c0018e1648d7d48f257dc35e9660'] = true,
        ['40da66d41e9c79172a84eef745739521'] = true,
        ['2863ab7e0e7371f9a6b3f0440c06c560'] = true,
        ['34146dc35d583f2b34693a83469fac2a'] = true,
        ['b315d022891afedf2e6bc7e5aaf2d357'] = true,
        ['63bf3d5a51b292cd0702135f6f566bd1'] = true,
        ['6891d0a75336a75f9d03bb5e51a53095'] = true,
        ['325a53c37324e4adb484d7a9c6741314'] = true,
        ['0e3c41078d06f7f502e4bb5bd886772a'] = true,
        ['fc65cda372eeb75fc1a2e7d19e91a86f'] = true,
        ['f35309a653ae6243dab90c203fa50000'] = true,
        ['50bbef5ebf4e0393016d129a545bd09d'] = true,
        ['a77ee0be91bd38a0635b65991bc4b686'] = true,
        ['3126fab3615a94119d5fe9eead1e88c1'] = true,
    }
}

local players = {}

api_version = '1.12.0.0'

function OnScriptLoad()
    register_callback(cb['EVENT_COMMAND'], 'OnCommand')
    register_callback(cb['EVENT_JOIN'], 'OnJoin')
    register_callback(cb['EVENT_LEAVE'], 'OnQuit')
end

function MOD:NewPlayer(o)
    setmetatable(o, self)
    self.__index = self
    return o
end

function OnJoin(P)
    players[P] = MOD:NewPlayer({
        id = P,
        hash = get_var(P, '$hash'),
        name = get_var(P, '$name'),
        ip = get_var(P, '$ip'):match('%d+.%d+.%d+.%d+')
    })
end

function OnQuit(P)
    players[P] = nil
end

local function SetIPAdmin(P, lvl)
    rprint(P, "You're now level " .. lvl)
    execute_command('ipadmin_add ' .. P .. ' ' .. lvl)
end

local function SetHashAdmin(P, lvl)
    rprint(P, "You're now level " .. lvl)
    execute_command('admin_add ' .. P .. ' ' .. lvl)
end

function MOD:CheckHash()
    return self.known_pirated_hashes[self.hash]
end

function MOD:AdminAdd()

    local lvl = tonumber(get_var(self.id, '$lvl'))
    if (lvl == self.level) then
        rprint(self.id, "You're already a level " .. self.level .. ' admin!')
        return
    elseif (lvl < self.level) then
        local users = self.users
        for i = 1, #users do
            if (self.name == users[i] or self.ip == users[i]) then
                SetIPAdmin(self.id, lvl)
                break
            elseif (self.hash == users[i] and self:CheckHash()) then
                SetHashAdmin(self.id, lvl)
                break
            end
        end
    end
end

local function CMDSplit(s)
    local args = {}
    for arg in s:gmatch('([^%s]+)') do
        args[#args + 1] = arg:lower()
    end
    return args
end

function OnCommand(Ply, CMD)

    local args = CMDSplit(CMD)
    if (args and args[1] == 'admin' and args[2] == 'me') then

        local p = players[Ply]
        if (p) then
            p:AdminAdd()
        end

        return false
    end
end

function OnScriptUnload()
    -- N/A
end