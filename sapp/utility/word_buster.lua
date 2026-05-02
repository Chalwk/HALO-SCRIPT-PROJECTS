--[[
=====================================================================================
SCRIPT NAME:      word_buster.lua
DESCRIPTION:      Advanced multilingual profanity filter with dynamic enforcement.

FEATURES:
                  - 21+ language support with customizable dictionaries
                  - Leet-speak detection (e.g., "a$$hole", "f*ck")
                  - Progressive punishment system (warnings -> kicks -> bans)
                  - Admin immunity system
                  - Word list management
                  - Configurable thresholds and grace periods
                  - Comprehensive logging system

COMMANDS:
                  /wb_langs                   - List enabled languages
                  /wb_add_word <word> <lang>  - Add word to filter
                  /wb_del_word <word> <lang>  - Remove word from filter
                  /wb_enable_lang <lang>      - Enable language filter
                  /wb_disable_lang <lang>     - Disable language filter

REQUIREMENTS:     WordBuster folder from the repo: /sapp/utility/WordBuster
                  Place in same directory as sapp.dll.

Copyright (c) 2020-2026 Jericho Crosby (Chalwk)
LICENSE:          MIT License
                  https://github.com/Chalwk/HALO-SCRIPT-PROJECTS/blob/master/LICENSE
=====================================================================================
]]

-- CONFIG START --
api_version = "1.12.0.0"

local CONFIG = {

    warnings = 5,                -- strikes before punishment
    grace_period = 1,            -- days before infractions expire
    ignore_commands = true,      -- skip lines that look like commands
    clean_interval_seconds = 30, -- how often we prune old infractions
    immune = {                   -- admin levels that can swear all they want
        [1] = true, [2] = true, [3] = true, [4] = true
    },

    -- Messages
    notify_text = "Please do not use profanity.",
    last_warning = "Last warning. You will be punished if you continue to use profanity.",
    on_punish = "You were $punishment for profanity",

    -- Punishment
    punishment = "kick", -- "kick" or "ban"
    ban_duration = 10,   -- minutes for temp bans

    -- File paths (relative to sapp.dll)
    lang_directory = "./WordBuster/langs/",
    infractions_file = "./WordBuster/infractions.txt",

    -- Console log
    notify_console = true,
    notify_console_format = "[INFRACTION] | $name | $word | $pattern | $lang",

    -- Who can use the configuration commands
    command_permission_level = 4,

    -- Turn commands on/off
    commands = {
        wb_langs = true,
        wb_add_word = true,
        wb_del_word = true,
        wb_enable_lang = true,
        wb_disable_lang = true,
    },

    -- Which language files to load
    languages = {
        ["cs.txt"] = false,
        ["da.txt"] = false,
        ["de.txt"] = false,
        ["en.txt"] = true,
        ["eo.txt"] = false,
        ["es.txt"] = false,
        ["fr.txt"] = false,
        ["hu.txt"] = false,
        ["it.txt"] = false,
        ["ja.txt"] = false,
        ["ko.txt"] = false,
        ["nl.txt"] = false,
        ["no.txt"] = false,
        ["pl.txt"] = false,
        ["pt.txt"] = false,
        ["ru.txt"] = false,
        ["sv.txt"] = false,
        ["th.txt"] = false,
        ["tr.txt"] = false,
        ["zh.txt"] = false,
        ["tlh.txt"] = false
    },

    --
    -- ADVANCED
    --
    pattern_settings = {
        -- What characters can sit between letters inside a word
        separator = "[-*_. ]*",

        -- Letter -> regex class with common leet‑speak substitutions
        leet_map = {
            a = "[aA@*#]",
            b = "[bB]",
            c = "[cCkK*#]",
            d = "[dD]",
            e = "[eE3]",
            f = "[fF]",
            g = "[gG6]",
            h = "[hH]",
            i = "[iIl!1]",
            j = "[jJ]",
            k = "[cCkK*#]",
            l = "[lL1!i]",
            m = "[mM]",
            n = "[nN]",
            o = "[oO0*#]",
            p = "[pP]",
            q = "[qQ9]",
            r = "[rR]",
            s = "[sS$5]",
            t = "[tT7+]",
            u = "[uUvV*#]",
            v = "[vVuU]",
            w = "[wW]",
            x = "[xX]",
            y = "[yY]",
            z = "[zZ2]"
        }
    }
}
-- CONFIG END --

local infractions = {}
local infractions_dirty = false
local bad_words = {}
local immune_cache = {}
local pattern_cache = {}
local global_word_cache = {}

local GRACE_PERIOD_SECONDS = CONFIG.grace_period * 86400
local CLEAN_INTERVAL_MS = CONFIG.clean_interval_seconds * 1000

local open = io.open
local rprint, cprint = rprint, cprint
local get_var = get_var
local execute_command = execute_command
local tonumber = tonumber
local fmt = string.format
local pairs, ipairs = pairs, ipairs
local table_concat = table.concat
local clock, time = os.clock, os.time

-- Metatable fallback for leet_map
setmetatable(CONFIG.pattern_settings.leet_map, {
    __index = function(_, char)
        return char:gsub("([^%w])", "%%%1")
    end
})

local function respond(id)
    if id == 0 then
        return function(msg) cprint(msg) end
    else
        return function(msg) rprint(id, msg) end
    end
end

local function parse_args(input)
    local parts = {}
    for word in input:gmatch("([^%s]+)") do parts[#parts + 1] = word end
    return parts
end

local function write_file(path, content)
    local file = open(path, "w")
    if not file then return false end
    file:write(content)
    file:close()
    return true
end

local function read_file(path)
    local file = open(path, "r")
    if not file then return end
    local content = file:read("*a")
    file:close()
    return content
end

local function is_admin(id, level)
    return id == 0 or tonumber(get_var(id, "$lvl")) >= level
end

local function format_message(template, vars)
    return template:gsub("%$(%w+)", function(k) return tostring(vars[k] or "") end)
end

local function compile_pattern(word)
    if pattern_cache[word] then return pattern_cache[word] end

    word = word:match("^%s*(.-)%s*$") or ""
    local sep = CONFIG.pattern_settings.separator
    local letters = {}
    for char in word:gmatch(".") do
        letters[#letters + 1] = CONFIG.pattern_settings.leet_map[char:lower()] .. "+"
    end

    local pattern = "%f[%w]" .. table_concat(letters, sep) .. "%f[%W]"
    pattern_cache[word] = pattern
    return pattern
end

local function load_bad_word_file(path, lang)
    local content = read_file(path)
    if not content then return 0 end

    local count = 0
    for line in content:gmatch("[^\r\n]+") do
        local word = line:match("^%s*(.-)%s*$")
        if word and word ~= "" and not word:match("^%s*#") then
            if not global_word_cache[word] then
                local ok, pattern = pcall(compile_pattern, word)
                if ok and pattern then
                    global_word_cache[word] = pattern
                else
                    cprint(("WARNING: Can't compile pattern for '%s' in %s"):format(word, path), 12)
                end
            end

            if global_word_cache[word] then
                bad_words[#bad_words + 1] = {
                    pattern = global_word_cache[word],
                    language = lang,
                    word = word
                }
                count = count + 1
            end
        end
    end

    return count
end

local function load_bad_words()
    pattern_cache = {}
    global_word_cache = {}
    bad_words = {}
    local word_count = 0
    local lang_count = 0
    local start_time = clock()

    for lang, enabled in pairs(CONFIG.languages) do
        if enabled then
            local path = CONFIG.lang_directory .. lang
            local count = load_bad_word_file(path, lang)
            if count > 0 then
                word_count = word_count + count
                lang_count = lang_count + 1
            end
        end
    end

    local elapsed = clock() - start_time
    cprint(("Loaded %d words from %d language(s) in %.4f seconds"):format(word_count, lang_count, elapsed), 10)
    return word_count
end

local function load_infractions()
    local content = read_file(CONFIG.infractions_file)
    if not content then return {} end

    local result = {}
    for line in content:gmatch("[^\r\n]+") do
        local ip, warnings, timestamp, quoted_name = line:match("^([%d%.]+)%s+(%d+)%s+(%d+)%s+(.+)$")
        if ip and warnings and timestamp and quoted_name then
            local fn, load_err = load("return " .. quoted_name)
            if fn then
                local ok, name_str = pcall(fn)
                if ok and type(name_str) == "string" then
                    result[ip] = {
                        warnings = tonumber(warnings),
                        last_infraction = tonumber(timestamp),
                        name = name_str
                    }
                end
            end
        end
    end
    return result
end

local function save_infractions()
    if infractions_dirty then
        local lines = {}
        for ip, data in pairs(infractions) do
            -- %q produces a valid Lua string representation of the name
            local name_quoted = fmt("%q", data.name)
            lines[#lines + 1] = ip .. " " .. data.warnings .. " " .. data.last_infraction .. " " .. name_quoted
        end
        local content = table_concat(lines, "\n")
        if write_file(CONFIG.infractions_file, content) then
            infractions_dirty = false
        end
    end
end

local function notify_console(name, word, pattern, lang)
    if CONFIG.notify_console then
        local msg = format_message(CONFIG.notify_console_format, {
            name = name,
            word = word,
            pattern = pattern,
            lang = lang
        })
        cprint(msg)
    end
end

function clean_infractions()
    if not next(infractions) then return end

    local now = time()
    local changed = false

    for ip, data in pairs(infractions) do
        if data.last_infraction and (now - data.last_infraction) > GRACE_PERIOD_SECONDS then
            infractions[ip] = nil
            changed = true
        end
    end

    if changed then
        infractions_dirty = true
        save_infractions()
    end
end

local function is_player_immune(id)
    if immune_cache[id] == nil then
        immune_cache[id] = CONFIG.immune[tonumber(get_var(id, "$lvl"))] or false
    end
    return immune_cache[id]
end

local function handle_wb_langs(id)
    respond(id)("Enabled languages:")
    local found = false
    for lang, enabled in pairs(CONFIG.languages) do
        if enabled then
            respond(id)("- " .. lang)
            found = true
        end
    end
    if not found then respond(id)("None enabled.") end
end

local function handle_wb_add_word(id, args)
    if #args < 3 then
        respond(id)("Usage: /wb_add_word <word> <lang>")
        return
    end

    local word, lang = args[2], args[3]
    if not CONFIG.languages[lang] then
        respond(id)("No language file named " .. lang)
        return
    end

    local path = CONFIG.lang_directory .. lang
    local content = read_file(path) or ""
    local new_content = content .. "\n" .. word

    if write_file(path, new_content) then
        respond(id)(("Added \"%s\" to %s"):format(word, lang))
        load_bad_words()
    else
        respond(id)("Failed to write to language file")
    end
end

local function handle_wb_del_word(id, args)
    if #args < 3 then
        respond(id)("Usage: /wb_del_word <word> <lang>")
        return
    end

    local word, lang = args[2], args[3]
    if not CONFIG.languages[lang] then
        respond(id)("No language file named " .. lang)
        return
    end

    local path = CONFIG.lang_directory .. lang
    local content = read_file(path)
    if not content then
        respond(id)("Language file not found")
        return
    end

    local new_lines = {}
    local removed = false
    for line in content:gmatch("[^\r\n]+") do
        if line == word then
            removed = true
        else
            new_lines[#new_lines + 1] = line
        end
    end

    if not removed then
        respond(id)(("\"%s\" not found in %s"):format(word, lang))
        return
    end

    if write_file(path, table_concat(new_lines, "\n")) then
        respond(id)(("Removed \"%s\" from %s"):format(word, lang))
        load_bad_words()
    else
        respond(id)("Failed to update language file")
    end
end

local function handle_lang_toggle(id, args, enable)
    if #args < 2 then
        respond(id)("Usage: /wb_" .. (enable and "enable" or "disable") .. "_lang <lang>")
        return
    end

    local lang = args[2]
    if not CONFIG.languages[lang] then
        respond(id)("Language file " .. lang .. " not found")
        return
    end

    if CONFIG.languages[lang] == enable then
        respond(id)("That language is already " .. (enable and "enabled" or "disabled"))
        return
    end

    CONFIG.languages[lang] = enable
    respond(id)((enable and "Enabled" or "Disabled") .. " " .. lang)
    load_bad_words()
end

function OnScriptLoad()
    register_callback(cb["EVENT_CHAT"], "OnChat")
    register_callback(cb["EVENT_COMMAND"], "OnCommand")
    register_callback(cb["EVENT_GAME_END"], "OnGameEnd")
    register_callback(cb["EVENT_LEAVE"], "OnPlayerLeave")

    infractions = load_infractions()
    load_bad_words()
    timer(CLEAN_INTERVAL_MS, "clean_infractions")
end

function OnGameEnd()
    save_infractions()
    immune_cache = {}
end

function OnPlayerLeave(id) immune_cache[id] = nil end

function OnChat(id, message)
    if CONFIG.ignore_commands and (message:find("^/") or message:find("^\\")) then return true end
    if is_player_immune(id) then return true end

    local name = get_var(id, "$name")
    local ip = get_var(id, "$ip")

    for _, data in ipairs(bad_words) do
        if message:find(data.pattern) then
            notify_console(name, data.word, data.pattern, data.language)

            local ip_data = infractions[ip] or { warnings = 0, name = name }
            ip_data.warnings = ip_data.warnings + 1
            ip_data.last_infraction = time()

            infractions[ip] = ip_data
            infractions_dirty = true

            local warnings = ip_data.warnings
            if warnings == CONFIG.warnings then
                respond(id)(CONFIG.last_warning)
            elseif warnings > CONFIG.warnings then
                local action = CONFIG.punishment
                local msg = format_message(CONFIG.on_punish, { punishment = action })

                if action == "kick" then
                    execute_command("k " .. id .. ' "' .. msg .. '"')
                elseif action == "ban" then
                    execute_command("ipban " .. id .. " " .. CONFIG.ban_duration .. ' "' .. msg .. '"')
                end

                infractions[ip] = nil
            else
                respond(id)(CONFIG.notify_text)
            end
            return false
        end
    end

    return true
end

function OnCommand(id, command)
    local args = parse_args(command)
    if #args == 0 then return end

    local cmd = args[1]:lower()
    if not CONFIG.commands[cmd] then return end -- unknown or disabled

    if not is_admin(id, CONFIG.command_permission_level) then
        respond(id)("You need level " .. CONFIG.command_permission_level .. "+ for this command")
        return false
    end

    if cmd == "wb_langs" then
        handle_wb_langs(id)
    elseif cmd == "wb_add_word" then
        handle_wb_add_word(id, args)
    elseif cmd == "wb_del_word" then
        handle_wb_del_word(id, args)
    elseif cmd == "wb_enable_lang" then
        handle_lang_toggle(id, args, true)
    elseif cmd == "wb_disable_lang" then
        handle_lang_toggle(id, args, false)
    end

    return false
end

function OnScriptUnload() save_infractions() end
