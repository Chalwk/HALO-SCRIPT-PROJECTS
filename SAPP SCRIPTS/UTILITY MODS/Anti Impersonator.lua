--[[
--=====================================================================================================--
Script Name: AntiImpersonator for SAPP (PC & CE)
Description: Prevent other players from impersonating your community members.

-------------------------
IMPORTANT NOTE
-------------------------

* Shared Hashes and Dynamic IPs:

If a community member has a shared hash or uses a dynamic IP address, this system may not work effectively for them.

Shared Hashes: Some players may share the same hash (e.g., cracked/pirated account), which means
               multiple legitimate users might have the same hash. This could lead to false positives,
               where one player is mistakenly flagged as an impersonator.

Dynamic IPs: If a member’s IP address changes frequently (e.g., due to using dynamic IPs provided by their ISP),
             the system could mistakenly flag players as impersonators if their IP address
             doesn't match the one originally listed for them.

To Protect a Community Member:
    1. Static IP:
        If possible, ensure that the member uses a static IP address. This will allow their IP to remain consistent and reliably be recognized as theirs.

    2. Legitimate Hash:
        If the member uses a legitimate, unique player hash, that will be more reliable than relying on IP alone.
        Player hashes are more consistent and tied to their specific Halo account, so they are less prone to change than IP addresses.

Copyright (c) 2019-2025, Jericho Crosby <jericho.crosby227@gmail.com>
Notice: You can use this script subject to the following conditions:
https://github.com/Chalwk/HALO-SCRIPT-PROJECTS/blob/master/LICENSE
--=====================================================================================================--
]]

-- Configuration -----------------------------------------------------------------
api_version = "1.12.0.0"

local config = {
    -- Action to take when an impersonator is detected ('kick' or 'ban'):
    action = 'kick',  -- Default action against impersonators.

    -- Ban duration in minutes (0 for permanent ban):
    ban_duration = 10,  -- Default ban duration.

    -- Reason for punishment:
    punishment_reason = 'Impersonating',  -- Reason shown when a player is kicked or banned.

    -- Community members list with corresponding IPs or hashes (at least one required):
    members = {
        -- Example structure for a community member
        ['ExampleGamerTag'] = {
            '127.0.0.1',  -- IP address of the member (optional)
            'xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx',  -- Player hash of the member (optional)
        },

        -- Additional members can be added in the same format:
        ['someone'] = {
            'ip1',  -- IP address (optional)
            'hash1', -- Player hash (optional)
            'hash2', -- Additional hashes (optional)
        }
    },

    -- Enable logging of impersonator actions (true/false):
    log = true,  -- Set to true to log impersonator actions.

    -- Log file path for impersonator actions:
    log_file_path = "anti_impersonator_log.txt"  -- Path to the log file.
}
-- End of configuration ------------------------------------------------------------

local function getDate()
    return os.date("%d-%m-%Y %H:%M:%S")
end

local function perform_action(playerId, name, hash, ip, action, reason, ban_duration)

    local log_message = string.format(
            "Player ID: %d | Name: %s | Hash: %s | IP: %s | Action: %s | Reason: %s",
            playerId, name, hash, ip, action, reason
    )

    -- Log to file if enabled
    if config.log then
        local log_file, err = io.open(config.sapp_path, "a")
        if log_file then
            log_file:write(string.format("%s - %s\n", getDate(), log_message))
            log_file:close()
        else
            error("Error opening log file: " .. err)
        end
    end

    -- Perform the kick or ban action
    if action == 'kick' then
        execute_command('k ' .. playerId .. ' "' .. reason .. '"')
        cprint(log_message, 12)
    elseif action == 'ban' then
        execute_command('b ' .. playerId .. ' ' .. ban_duration .. ' "' .. reason .. '"')
        cprint(string.format("%s - Ban duration: %d minutes", log_message, ban_duration), 12)
    else
        cprint("Invalid action specified: " .. action, 12)
    end
end

local function is_impersonator(name, hash, ip)
    local member_data = config.members[name]
    if member_data then
        for _, value in ipairs(member_data) do
            if value == hash or value == ip then
                return false -- Not an impersonator
            end
        end
        return true -- Impersonator detected
    end
    return false -- Name not found in members list
end

function OnJoin(playerId)
    local name = get_var(playerId, '$name')
    local hash = get_var(playerId, '$hash')
    local ip = get_var(playerId, '$ip'):match('%d+%.%d+%.%d+%.%d+')
    if is_impersonator(name, hash, ip) then
        perform_action(playerId, name, hash, ip, config.action, config.punishment_reason, config.ban_duration)
    end
end

function OnScriptLoad()
    config.sapp_path = read_string(read_dword(sig_scan('68??????008D54245468') + 0x1)) .. '\\sapp\\' .. config.log_file_path
    register_callback(cb['EVENT_JOIN'], 'OnJoin')
end

function OnScriptUnload()
    -- N/A
end