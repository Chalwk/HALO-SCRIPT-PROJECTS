--=====================================================================================--
-- SCRIPT NAME:      Anti-Impersonator
-- DESCRIPTION:      Detects and removes players attempting to impersonate trusted
--                   community members based on player hash and/or IP address.
--                   Supports kicking or banning impersonators, with optional logging.
--
-- AUTHOR:           Chalwk (Jericho Crosby)
-- COMPATIBILITY:    Halo PC/CE | SAPP 1.12.0.0
--
-- IMPORTANT NOTES:
--   * Shared Hashes: Players using cracked or shared copies of Halo may have identical
--     hashes, resulting in false positives.
--   * Dynamic IPs: Players with changing IPs may be incorrectly flagged unless a
--     static IP or consistent hash is used.
--
-- RECOMMENDATIONS:
--   * Use player hashes where possible (they are more stable than IPs).
--   * Ensure trusted members use legitimate accounts and, if feasible, static IPs.
--
-- COPYRIGHT (c) 2019–2025, Jericho Crosby <jericho.crosby227@gmail.com>
-- NOTICE:           You may use this script subject to the following license:
--                   https://github.com/Chalwk/HALO-SCRIPT-PROJECTS/blob/master/LICENSE
--=====================================================================================--


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