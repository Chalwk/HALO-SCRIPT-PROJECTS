--=====================================================================================--
-- SCRIPT NAME:      Word Buster
-- DESCRIPTION:      An advanced, multilingual profanity filter.
--
-- FEATURES:         Monitors chat messages for offensive words with flexible pattern matching
--                   to catch leet-speak (e.g., "a$$hole"). Tracks player infractions
--                   over time, issues warnings, and enforces punishments like kicks or temporary bans.
--                   Supports 21 languages, admin immunity, configurable settings, and in-game
--                   commands to manage word lists and languages dynamically.
--
-- AUTHOR:           Chalwk (Jericho Crosby)
-- COMPATIBILITY:    Halo PC/CE | SAPP 1.12.0.0
--
-- Copyright (c) 2025 Jericho Crosby <jericho.crosby227@gmail.com>
-- LICENSE:          MIT License
--                   https://github.com/Chalwk/HALO-SCRIPT-PROJECTS/blob/master/LICENSE
--=====================================================================================--

-- ========================
-- Configurable Settings
-- ========================
local CFG = {

    -- General behaviour
    warnings = 5,                -- Number of warnings before punishment
    grace_period = 1,            -- Days before infractions expire
    ignore_commands = true,      -- Whether to ignore commands when checking for infractions
    clean_interval_seconds = 30, -- How often to clean infractions (in seconds)
    immune = {                   -- Admin levels that are immune
        [1] = true, [2] = true, [3] = true, [4] = false
    },

    -- Notification messages
    notify_text = 'Please do not use profanity.',
    last_warning = 'Last warning. You will be punished if you continue to use profanity.',

    -- Punishment handling
    punishment = 'kick', -- 'kick' or 'ban'
    on_punish = 'You were $punishment for profanity',
    ban_duration = 10,   -- Minutes for temp bans

    -- Storage / file paths
    lang_directory = './WordBuster/langs/',
    infractions_directory = './WordBuster/infractions.json',

    -- Console notifications
    notify_console = true,
    notify_console_format = '[INFRACTION] | $name | $word | $pattern | $lang',

    -- Commands
    command_permission_level = 4,  -- Required level to run commands
    commands = {
        wb_langs = true,
        wb_add_word = true,
        wb_del_word = true,
        wb_enable_lang = true,
        wb_disable_lang = true,
    },

    -- Language activation
    languages = {
        ['cs.txt'] = false, ['da.txt'] = false, ['de.txt'] = false, ['en.txt'] = true,
        ['eo.txt'] = false, ['es.txt'] = false, ['fr.txt'] = false, ['hu.txt'] = false,
        ['it.txt'] = false, ['ja.txt'] = false, ['ko.txt'] = false, ['nl.txt'] = false,
        ['no.txt'] = false, ['pl.txt'] = false, ['pt.txt'] = false, ['ru.txt'] = false,
        ['sv.txt'] = false, ['th.txt'] = false, ['tr.txt'] = false, ['zh.txt'] = false,
        ['tlh.txt'] = false
    },

    -- ========================================
    -- BELOW: FOR ADVANCED USERS ONLY
    -- ========================================

    -- Leet-speak substitutions

    pattern_settings = {
        separator = "[-*_. ]*",
        leet_map = {
            a = "[aA@*#]", b = "[bB]",	 c = "[cCkK*#]",  d = "[dD]", 	e = "[eE3]", 	f = "[fF]",
            g = "[gG6]",   h = "[hH]",	 i = "[iIl!1]",   j = "[jJ]", 	k = "[cCkK*#]", l = "[lL1!i]",
            m = "[mM]",    n = "[nN]",	 o = "[oO0*#]",   p = "[pP]", 	q = "[qQ9]", 	r = "[rR]",
            s = "[sS$5]",  t = "[tT7+]", u = "[uUvV*#]",  v = "[vVuU]", w = "[wW]", 	x = "[xX]",
            y = "[yY]",    z = "[zZ2]"
        }
    }
}

-- CONFIG ENDS ---------------------------------------------------------------

-- Load dependencies
api_version = '1.12.0.0'
local json = loadfile('./WordBuster/json.lua')()
local infractions = {}
local infractions_dirty = false
local bad_words = {}
local immune_cache = {}
local pattern_cache = {}
local global_word_cache = {}

-- Precomputed values
local GRACE_PERIOD_SECONDS = CFG.grace_period * 86400
local CLEAN_INTERVAL_MS = CFG.clean_interval_seconds * 1000

local pcall = pcall
local open = io.open
local rprint = rprint
local get_var = get_var
local pairs, ipairs = pairs, ipairs
local tonumber = tonumber
local concat = table.concat
local clock, time = os.clock, os.time

-- Metatable for pattern fallback
setmetatable(CFG.pattern_settings.leet_map, {
    __index = function(_, char)
        return char:gsub("([^%w])", "%%%1")
    end
})

-- ========================
-- Utility Functions
-- ========================
local function write_file(path, content, is_json)
    local file = open(path, 'w')
    if not file then return false end
    file:write(is_json and json:encode_pretty(content) or content)
    file:close()
    return true
end

local function read_file(path)
    local file = open(path, 'r')
    if not file then return end
    local content = file:read('*a')
    file:close()
    return content
end

local function load_infractions()
    local content = read_file(CFG.infractions_directory)
    return content and json:decode(content) or {}
end

local function save_infractions()
    if infractions_dirty then
        if write_file(CFG.infractions_directory, infractions, true) then
            infractions_dirty = false
        end
    end
end

local function has_permission(id, level)
    return id == 0 or tonumber(get_var(id, '$lvl')) >= level
end

local function compile_pattern(word)
    if pattern_cache[word] then return pattern_cache[word] end

    word = word:match("^%s*(.-)%s*$") or ""
    local separator = CFG.pattern_settings.separator

    local letters = {}
    for char in word:gmatch(".") do
        letters[#letters + 1] = CFG.pattern_settings.leet_map[char:lower()]
    end

    local pattern = '%f[%w]' .. concat(letters, separator) .. '%f[%W]'
    pattern_cache[word] = pattern
    return pattern
end

-- ========================
-- Core Functionality
-- ========================
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
                    cprint(('WARNING: Could not compile pattern for "%s" in %s'):format(word, path), 12)
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
    bad_words = {}
    local word_count = 0
    local lang_count = 0
    local start_time = clock()

    for lang, enabled in pairs(CFG.languages) do
        if enabled then
            local path = CFG.lang_directory .. lang
            local count = load_bad_word_file(path, lang)
            if count > 0 then
                word_count = word_count + count
                lang_count = lang_count + 1
            end
        end
    end

    local load_time = clock() - start_time
    cprint(('Loaded %d words from %d languages in %.4f seconds'):format(word_count, lang_count, load_time), 10)
    return word_count
end

local function format_message(template, vars)
    return template:gsub('%$(%w+)', function(k) return tostring(vars[k] or '') end)
end

local function notify_infraction(name, word, pattern, lang)
    if CFG.notify_console then
        local message = format_message(CFG.notify_console_format, {
            name = name,
            word = word,
            pattern = pattern,
            lang = lang
        })
        cprint(message)
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

    return true
end

-- ========================
-- Command Handlers
-- ========================
local function handle_wb_langs(id)
    rprint(id, 'Enabled Languages:')
    local found = false
    for lang, enabled in pairs(CFG.languages) do
        if enabled then
            rprint(id, '- ' .. lang)
            found = true
        end
    end
    if not found then rprint(id, 'No languages enabled') end
end

local function handle_wb_add_word(id, args)
    if #args < 3 then
        rprint(id, 'Usage: /wb_add_word <word> <lang>')
        return
    end

    local word, lang = args[2], args[3]
    if not CFG.languages[lang] then
        rprint(id, 'Invalid language file')
        return
    end

    local path = CFG.lang_directory .. lang
    local content = read_file(path) or ''
    local new_content = content .. '\n' .. word

    if write_file(path, new_content) then
        rprint(id, ('Added "%s" to %s'):format(word, lang))
        load_bad_words()
    else
        rprint(id, 'Failed to write to language file')
    end
end

local function handle_wb_del_word(id, args)
    if #args < 3 then
        rprint(id, 'Usage: /wb_del_word <word> <lang>')
        return
    end

    local word, lang = args[2], args[3]
    if not CFG.languages[lang] then
        rprint(id, 'Invalid language file')
        return
    end

    local path = CFG.lang_directory .. lang
    local content = read_file(path)
    if not content then
        rprint(id, 'Language file not found')
        return
    end

    local ps = CFG.pattern_settings
    local new_content = {}
    local removed = false

    for line in content:gmatch(ps.line_pattern) do
        if line ~= word then
            new_content[#new_content + 1] = line
        else
            removed = true
        end
    end

    if not removed then
        rprint(id, ('Word "%s" not found in %s'):format(word, lang))
        return
    end

    if write_file(path, concat(new_content, '\n')) then
        rprint(id, ('Removed "%s" from %s'):format(word, lang))
        load_bad_words()
    else
        rprint(id, 'Failed to update language file')
    end
end

local function handle_lang_toggle(id, args, enable)
    if #args < 2 then
        rprint(id, 'Usage: /wb_' .. (enable and 'enable' or 'disable') .. '_lang <lang>')
        return
    end

    local lang = args[2]
    if not CFG.languages[lang] then
        rprint(id, 'Language file not found')
        return
    end

    if CFG.languages[lang] == enable then
        rprint(id, 'Language already ' .. (enable and 'enabled' or 'disabled'))
        return
    end

    CFG.languages[lang] = enable
    rprint(id, ('%s %s'):format(enable and 'Enabled' or 'Disabled', lang))
    load_bad_words()
end

local command_handlers = {
    wb_langs = handle_wb_langs,
    wb_add_word = handle_wb_add_word,
    wb_del_word = handle_wb_del_word,
    wb_enable_lang = function(id, args) handle_lang_toggle(id, args, true) end,
    wb_disable_lang = function(id, args) handle_lang_toggle(id, args, false) end
}

local function immune(id)
    if immune_cache[id] == nil then
        immune_cache[id] = CFG.immune[tonumber(get_var(id, '$lvl'))] or false
    end
    return immune_cache[id]
end

-- ========================
-- Main Callbacks
-- ========================
function OnScriptLoad()
    register_callback(cb['EVENT_CHAT'], 'OnChat')
    register_callback(cb['EVENT_COMMAND'], 'OnCommand')
    register_callback(cb['EVENT_GAME_END'], 'OnGameEnd')
    register_callback(cb['EVENT_LEAVE'], 'OnPlayerLeave')

    infractions = load_infractions()
    load_bad_words()
    timer(CLEAN_INTERVAL_MS, 'clean_infractions')
end

function OnScriptUnload()
    save_infractions()
end

function OnGameEnd()
    save_infractions()
    immune_cache = {}
end

function OnPlayerLeave(id)
    immune_cache[id] = nil
end

function OnCommand(id, command)
    local cmd = command:match("^(%S+)")
    if not cmd or not CFG.commands[cmd] then return true end

    local handler = command_handlers[cmd]
    if handler then
        if not has_permission(id, CFG.command_permission_level) then
            rprint(id, ('You need level %d+ for this command'):format(CFG.command_permission_level))
            return false
        end

        local args = {}
        for arg in command:gmatch('%S+') do
            args[#args + 1] = arg:lower()
        end
        handler(id, args)
        return false
    end
    return true
end

function OnChat(id, message)
    if CFG.ignore_commands and (message:find('^/') or message:find('^\\')) then return true end
    if immune(id) then return true end

    local name = get_var(id, '$name')
    local ip = get_var(id, '$ip')

    for _, data in ipairs(bad_words) do
        if message:find(data.pattern) then
            notify_infraction(name, data.word, data.pattern, data.language)

            local ip_data = infractions[ip] or { warnings = 0, name = name }
            ip_data.warnings = ip_data.warnings + 1
            ip_data.last_infraction = time()

            infractions[ip] = ip_data
            infractions_dirty = true

            local warnings = ip_data.warnings
            if warnings == CFG.warnings then
                rprint(id, CFG.last_warning)
            elseif warnings > CFG.warnings then
                local action = CFG.punishment
                local msg = format_message(CFG.on_punish, { punishment = action })

                if action == 'kick' then
                    execute_command('k ' .. id .. ' "' .. msg .. '"')
                elseif action == 'ban' then
                    execute_command('ipban ' .. id .. ' ' .. CFG.ban_duration .. ' "' .. msg .. '"')
                end
                infractions[ip] = nil
            else
                rprint(id, CFG.notify_text)
            end
            return false
        end
    end
    return true
end