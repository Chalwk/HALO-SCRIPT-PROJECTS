--[[
--=====================================================================================================--
Script Name: VPN Blocker (v 1.1), for SAPP (PC & CE)

Description: VPN Blocker will detect whether an IP Address is a Proxy, Tor, or VPN Connection
             and retrieve an overall Fraud Score that provides accurate risk analysis. 

             The Fraud Score is a probability of malicious intent based on Machine Learning 
             and Data Analysis systems that are run by IP Quality Score.

             For each IP lookup, an IP address and other forensic factors of the connection are analysed to 
             determine if the user is hiding behind a spoofed or anonymized IP, tunnelled connection, a botnet, 
             or attempting to frequently change their device.

             Private VPNs can be detected, but it might pay to upgrade your IP Quality Score account.
             This is at your own expense, obviously. 
             I provide the tool to connect to the API but it's up to the end-user to decide what account type they register with. 
             The Free account is pretty good in general.


I M P O R T A N T
-----------------

1): This mod requires that the following plugins are installed to your server:
    https://opencarnage.net/index.php?/topic/5998-sapp-http-client/
    http://regex.info/blog/lua/json

2): Place "json.lua" and the contents of "sapp-http-client" in your servers root directory.

3): Sign up for an account at www.ipqualityscore.com.
    Navigate to Proxy Detection Overview page: https://www.ipqualityscore.com/documentation/proxy-detection/overview
    Copy your unique "Private Key" from that page and paste it into the API_KEY field (line 62) in this script (see config below).

    If VPN Blocker kicks or bans someone it will log the details of that action 
    to a file called "VPN Blocker.log" in the servers root directory.

D I S C L A I M E R
-------------------
Some genuine players use a VPN to protect their privacy online and also game while using one. 
VPN Blocker cannot differentiate between good and bad intentions 
and will, therefore, kick or ban on sight if their IP is on the VPN Blocker database.
--

Copyright (c) 2019, Jericho Crosby <jericho.crosby227@gmail.com>
Notice: You can use this script subject to the following conditions:
https://github.com/Chalwk/HALO-SCRIPT-PROJECTS/blob/master/LICENSE
--=====================================================================================================--
]] --

api_version = "1.12.0.0"
local vpn_blocker = {
    --====================================== --
    -- Configuration [STARTS]
    --====================================== --

    -- I recommend reading the API Documentation before changing any settings:
    -- https://www.ipqualityscore.com/documentation/proxy-detection/overview

    -- Paste your API KEY here (from the above link)
    api_key = "API_KEY",

    -- If the player is using a VPN Connection, do this action:
    -- k = kick, b = ban, c = crash (Warning: Crash function only works on stock maps!)
    action = "k",

    -- If action is "b" the player will be banned for this amount of time ((in minutes) set to 0 for permanent ban)
    bantime = 10,

    -- The reason for being kicked or banned:
    reason = "VPN Connection",

    -- Message output to the joining player:
    feedback1 = "We\'ve detected that you\'re using a VPN or Proxy - we do not allow these!'",

    -- Message output to Dedicated Server Console:
    feedback2 = "%name% was %action% for using a VPN or Proxy (IP: %ip%)",

    -- Request Parameters:
    checks = {
        --Check if IP is associated with being a confirmed crawler 
        --such as Googlebot, Bingbot, etc based on hostname or IP address verification.
        is_crawler = true,

        --Check if IP suspected of being a VPN connection?
        vpn = true,

        --Check if IP suspected of being a Tor connection?
        tor = true,

        --Check if IP address suspected to be a proxy? (SOCKS, Elite, Anonymous, VPN, Tor, etc.)
        proxy = true,

        --Fraud Score Threshold: 
        --Fraud Scores >= 75 are suspicious, but not necessarily fraudulent. 
        --I recommend flagging or blocking traffic with Fraud Scores >= 85, 
        --but you may find it beneficial to use a higher or lower threshold.
        fraud_score = 85,

        --Premium Account Feature:
        --Indicates if bots or non-human traffic has recently used this IP address to engage 
        --in automated fraudulent behavior. Provides stronger confidence that the IP address is suspicious.
        bot_status = true,
    },

    parameters = {
        -- How in depth (strict) do you want this query to be? 
        -- Higher values take longer to process and may provide a higher false-positive rate. 
        -- It is recommended to start at "0", the lowest strictness setting, and increasing to "1" or "2" depending on your needs.
        strictness = 1,

        -- Bypasses certain checks for IP addresses from education and research institutions, schools, and some corporate connections 
        -- to better accommodate audiences that frequently use public connections.
        allow_public_access_points = true,

        -- Enable this setting to lower detection rates and Fraud Scores for mixed quality IP addresses. 
        -- If you experience any false-positives with your traffic then enabling this feature will provide better results.
        lighter_penalties = false,

        -- This setting is used for time-sensitive lookups that require a faster response time. 
        -- Accuracy is slightly degraded with the "fast" approach, but not significantly noticeable.
        fast = false,

        -- You can optionally specify that this lookup should be treated as a mobile device.
        mobile = false,
    },

    exclusion_list = {
        "127.0.0.1", -- localhost
        "000.000.000.000",
        -- Repeat the structure to add more entries
    }
    --====================================== --
    -- Configuration [ENDS]
    --====================================== --
}

local gsub, format = string.gsub, string.format
local json = (loadfile "json.lua")()
local script_version = 1.1

function OnScriptLoad()
    register_callback(cb["EVENT_JOIN"], "OnPlayerJoin")
    register_callback(cb["EVENT_PREJOIN"], "OnPreJoin")
    if (vpn_blocker.action == "c") then
        register_callback(cb["EVENT_SPAWN"], "OnPlayerSpawn")
        register_callback(cb["EVENT_LEAVE"], "OnPlayerDisconnect")
    end
end

function OnPlayerJoin(p)
	rprint(p, "VPN BLOCKER IS ENABLED (remove this message)")
end

function OnPreJoin(p)
    local player = vpn_blocker:GetCredentials(p)
    if (player) then

        local site = "https://www.ipqualityscore.com/api/json/ip/api_key/"
        local key = gsub(site, "api_key", vpn_blocker.api_key)

        local query_link = tostring(key .. player.ip .. "?")
        local i_iteration = 0
        for k, v in pairs(vpn_blocker.parameters) do
            if (i_iteration == 0) then
                query_link = query_link .. k .. "=" .. tostring(v)
            else
                query_link = query_link .. "&" .. k .. "=" .. tostring(v)
            end
            i_iteration = i_iteration + 1
        end

        local JsonData = vpn_blocker:Query(query_link)
        if (JsonData) then

            local ip_lookup = json:decode(JsonData)
            if (ip_lookup.success) then

                local connected = function()
                    cprint("VPN Blocker -> Running Ip Lookup ^ Please wait...", 4 + 8)
                    for k, v in pairs(vpn_blocker.checks) do
                        if (type(v) == "boolean") then
                            if (v) and (ip_lookup[k]) then
                                return false
                            end
                        elseif (type(v) == "number") then
                            if (ip_lookup[k] >= v) then
                                return false
                            end
                        end
                    end
                    return true
                end

                if (not connected()) then

                    say(p, vpn_blocker.feedback1)
                    local state = "none"

                    if (vpn_blocker.action == "k") then
                        state = "kicked"
                        execute_command("k" .. " " .. p .. " \"" .. vpn_blocker.reason .. "\"")
                    elseif (vpn_blocker.action == "b") then
                        state = "banned"
                        execute_command("b" .. " " .. p .. " " .. vpn_blocker.bantime .. " \"" .. vpn_blocker.reason .. "\"")
                    elseif (vpn_blocker.action == "c") then
                        state = "crashed"
                        vpn_blocker[p] = {}
                        vpn_blocker[p].crash = true
                    end

                    local logtime = true
                    for key, value in pairs(ip_lookup) do
                        vpn_blocker:WriteLog(key, value, logtime)
                        if logtime then
                            logtime = false
                        end
                    end

                    local msg = gsub(gsub(gsub(vpn_blocker.feedback2, "%%name%%", player.name),
                            "%%action%%", state),
                            "%%ip%%", player.ip)
                    cprint(msg, 4 + 8)
                else
                    cprint("VPN Blocker -> Player connected successfully.", 2 + 8)
                end
            else
                -- Error Handling
                cprint("[VPN BLOCKER ERROR]", 4 + 8)
                for k, v in pairs(ip_lookup) do
                    print(k, v)
                end
                cprint("=========================================================", 4 + 8)
            end
        end
    end
end

----------------------------------------------------------
-- Only used if vpn_blocker.action is set to "c"
function OnPlayerDisconnect(PlayerIndex)
    vpn_blocker[PlayerIndex] = nil
end
function OnPlayerSpawn(PlayerIndex)
    if player_alive(PlayerIndex) then
        if (vpn_blocker[PlayerIndex].crash) then
            vpn_blocker:CrashPlayer(PlayerIndex)
        end
    end
end
----------------------------------------------------------

function vpn_blocker:CrashPlayer(PlayerIndex)
    local player_object = get_dynamic_player(PlayerIndex)
    if (player_object ~= 0) then
        local x, y, z = read_vector3d(player_object + 0x5C)
        local VehicleID = spawn_object("vehi", "vehicles\\rwarthog\\rwarthog", x, y, z)
        local VehicleObject = get_object_memory(VehicleID)
        if (VehicleObject ~= 0) then
            for j = 0, 20 do
                enter_vehicle(VehicleID, PlayerIndex, j)
                exit_vehicle(PlayerIndex)
            end
            destroy_object(VehicleID)
        end
    end
end

function vpn_blocker:WriteLog(k, v, logtime)
    local file = io.open("VPN Blocker.log", "a+")
    if file then

        if (logtime) then
            file:write(os.date("[%H:%M:%S - %d/%m/%Y]: ") .. "\n")
        end

        local line = format("%s\t%s\n", tostring(k), tostring(v))
        file:write(line)
        file:close()
    end
end

function isExcluded(IP)
    -- Check if IP is in the exclusion list.
    local t = vpn_blocker.exclusion_list
    for i = 1, #t do
        if (t[i]) then
            if (IP == t[i]) then
                return true
            end
        end
    end
    return false
end

function vpn_blocker:GetCredentials(p)
    local ip = get_var(p, "$ip"):match('(%d+.%d+.%d+.%d+)')
    if (not isExcluded(ip)) then
        local name = get_var(p, "$name")
        return { ip = ip, name = name }
    else
        return nil
    end
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

function vpn_blocker:Query(URL)
    local response = http_client.http_get(URL, false)
    local returning = nil
    if http_client.http_response_is_null(response) ~= true then
        local response_text_ptr = http_client.http_read_response(response)
        returning = ffi.string(response_text_ptr)
    end
    http_client.http_destroy_response(response)
    return returning
end

function OnScriptUnload()
    --
end

-- In the event of an error, the script will trigger these two functions: OnError(), report()
function report()
    local script_version = format("%0.2f", script_version)
    cprint("--------------------------------------------------------", 5 + 8)
    cprint("Please report this error on github:", 7 + 8)
    cprint("https://github.com/Chalwk/HALO-SCRIPT-PROJECTS/issues", 7 + 8)
    cprint("Script Version: " .. script_version, 7 + 8)
    cprint("--------------------------------------------------------", 5 + 8)
end

-- This function will return a string with a traceback of the stack call...
-- ...and call function 'report' after 50 milliseconds.
function OnError()
    cprint(debug.traceback(), 4 + 8)
    timer(50, "report")
end

return vpn_blocker


-- CHANGE LOG --
-- 16th November 2019
-- You can now optionally crash players with VPN Connections instead of kicking/banning them.
