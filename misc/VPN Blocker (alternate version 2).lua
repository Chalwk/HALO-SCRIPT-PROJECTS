--[[
--=====================================================================================================--
Script Name: VPN Blocker (alternate version 2), for SAPP (PC & CE)

This mod requires that you install all of the following database files to your servers root directory: 
https://github.com/Chalwk/HALO-SCRIPT-PROJECTS/tree/master/Miscellaneous/VPN%20Blocker%20Database

Copyright (c) 2019, Jericho Crosby <jericho.crosby227@gmail.com>
Notice: You can use this script subject to the following conditions:
https://github.com/Chalwk/HALO-SCRIPT-PROJECTS/blob/master/LICENSE
--=====================================================================================================--
]] --

api_version = "1.12.0.0"

local vpn_blocker = {
    -- Configuration [starts]
    database = {

        'firehol_proxies.netset',
        'firehol_level1.netset',
        'firehol_level2.netset',
        'firehol_level3.netset',

        'firehol_level4.netset',
        'firehol_abusers_1d.netset',

        'proxylists.netset',
        'proxylists_1d.netset',
        'proxylists_7d.netset',
        'proxylists_30d.netset',

        'bm_tor.netset',
        'vpn_ipv4.netset',
    },
    action = "k", -- k = kick, b = ban
    feedback1 = "We\'ve detected that you\'re using a VPN or Proxy - we do not allow these!'",
    feedback2 = "%name% was %action% for using a VPN or Proxy (IP: %ip%)",
    -- Configuration [ends]
}

local gsub = string.gsub

function OnScriptLoad()
    vpn_blocker:GetData()
    register_callback(cb["EVENT_PREJOIN"], "OnPreJoin")
end

function OnPreJoin(p)
    local player = vpn_blocker:GetCredentials(p)
    for _, v in pairs(vpn_blocker.ips) do
        if (player.ip == v) then
            say(p, vpn_blocker.feedback1)
            execute_command(vpn_blocker.action .. " " .. p)

            if (vpn_blocker.action == "k") then
                action = "kicked"
            elseif (vpn_blocker.action == "b") then
                action = "banned"
            end

            local msg = gsub(gsub(gsub(vpn_blocker.feedback2, "%%name%%", player.name), "%%action%%", action), "%%ip%%", player.ip)
            cprint(msg, 4 + 8)
            vpn_blocker:WriteLog(msg)
        end
    end
end

function vpn_blocker:GetData()
    cprint("VPN Blocker -> Retrieving vpn-ipv4 addresses. Please wait...", 2 + 8)

    local files = vpn_blocker.database
    vpn_blocker.ips = vpn_blocker.ips or { }
    vpn_blocker.ips = { }

    for i = 1, #files do
        for line in io.lines(files[i]) do
            local ip = line:match('(%d+.%d+.%d+.%d+)')
            vpn_blocker.ips[#vpn_blocker.ips + 1] = ip
        end
    end
    cprint("VPN Blocker -> Successfully stored (" .. #vpn_blocker.ips .. ") vpn-ipv4 IPs.", 2 + 8)
end

function vpn_blocker:WriteLog(msg)
    local file = io.open("VPN Blocker.log", "a+")
    if file then
        local timestamp = os.date("[%H:%M:%S - %d/%m/%Y]: ")
        local line = string.format("%s\t%s\n", timestamp, tostring(msg))
        file:write(line)
        file:close()
    end
end

function vpn_blocker:GetCredentials(p)
    local ip = get_var(p, "$ip")
    local name = get_var(p, "$name")
    return { ip = ip:match('(%d+.%d+.%d+.%d+)'), name = name }
end

function OnScriptUnload()
    --
end
