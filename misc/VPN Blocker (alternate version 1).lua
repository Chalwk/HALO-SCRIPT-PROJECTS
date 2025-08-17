--[[
--=====================================================================================================--
Script Name: VPN Blocker (alternate version 1), for SAPP (PC & CE)

1). This mod requires that the following plugin is installed to your server:
https://opencarnage.net/index.php?/topic/5998-sapp-http-client/

2). This mod requires that you install the following database files to your servers root directory: 
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

local gsub, match, gmatch = string.gsub, string.match, string.gmatch

function OnScriptLoad()
    if vpn_blocker:GetData() then
        register_callback(cb["EVENT_PREJOIN"], "OnPreJoin")
    end
end

function OnScriptUnload()
    --
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
    cprint("Retrieving vpn-ipv4 addresses. Please wait...", 2 + 8)

    local url = "https://github.com/Chalwk/HALO-SCRIPT-PROJECTS/tree/master/misc/VPN%20Blocker%20Database/"

    vpn_blocker.ips = vpn_blocker.ips or { }
    vpn_blocker.ips = { }

    local database_files = vpn_blocker.database
    local count = 0

    for i = 1, #database_files do

        local url = url .. database_files[i]
        local data = vpn_blocker:GetPage(tostring(url))

        if (data) then
            count = count + 1

            local line = vpn_blocker:stringSplit(data, "\n")
            for j = 1, #line do
                local ip = line[j]:match('(%d+.%d+.%d+.%d+)')
                vpn_blocker.ips[#vpn_blocker.ips + 1] = ip
            end

            cprint("VPN Blocker -> Successfully saved (" .. #vpn_blocker.ips .. ") VPN/Proxy Addresses (" .. database_files[i] .. ")", 2 + 8)
            --cprint("Collected from: " .. url..")", 2+8)
        else
            error('VPN Blocker was unable to retrieve the IP Data.')
        end
        if (count == #database_files) then
            return true
        end
    end

end

function vpn_blocker:GetCredentials(p)
    local ip = get_var(p, "$ip")
    local name = get_var(p, "$name")
    return { ip = ip:match('(%d+.%d+.%d+.%d+)'), name = name }
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

function vpn_blocker:stringSplit(InputString, Seperator)
    if Seperator == nil then
        Seperator = "%s"
    end
    local tab = {}
    i = 1
    for String in gmatch(InputString, "([^" .. Seperator .. "]+)") do
        tab[i] = String
        i = i + 1
    end
    return tab
end

-- Credits to Kavawuvi (002) for HTTP client functionality:
local ffi = require("ffi")
ffi.cdef [[
    typedef void http_response;
    http_response *http_get(const char *url, bool async);
    void http_destroy_response(http_response *);
    void http_wait_async(const http_response *);
    bool http_response_is_null(const http_response *);
    bool http_response_received(const http_response *);
    const char *http_read_response(const http_response *);
    uint32_t http_response_length(const http_response *);
]]
local http_client = ffi.load("lua_http_client")

function vpn_blocker:GetPage(URL)
    local response = http_client.http_get(URL, false)
    local returning = nil
    if http_client.http_response_is_null(response) ~= true then
        local response_text_ptr = http_client.http_read_response(response)
        returning = ffi.string(response_text_ptr)
    end
    http_client.http_destroy_response(response)
    return returning
end
