--=====================================================================================--
-- SCRIPT NAME:      Word Buster
-- DESCRIPTION:      An advanced, multilingual profanity filter.
--
-- FEATURES:         Monitors chat messages for offensive words with flexible pattern matching
--                   to catch variations and substitutions (e.g., "a$$hole"). Tracks player infractions
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

api_version = '1.12.0.0'

-- ========================
-- Configurable Settings
-- ========================
local settings = {

    -- General behaviour
    warnings = 5,                -- Number of warnings before punishment
    grace_period = 1,            -- Days before infractions expire
    ignore_commands = true,      -- Whether to ignore commands when checking for infractions
    clean_interval_seconds = 30, -- How often to clean infractions (in seconds)
    immune = {                   -- Admin levels that are immune
        [1] = true,
        [2] = true,
        [3] = true,
        [4] = true
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
    commands = {
        wb_langs = true,
        wb_add_word = true,
        wb_del_word = true,
        wb_enable_lang = true,
        wb_disable_lang = true,
    },

    -- Language activation
    languages = {
        ['cs.txt'] = false,
        ['da.txt'] = false,
        ['de.txt'] = false,
        ['en.txt'] = true,
        ['eo.txt'] = false,
        ['es.txt'] = false,
        ['fr.txt'] = false,
        ['hu.txt'] = false,
        ['it.txt'] = false,
        ['ja.txt'] = false,
        ['ko.txt'] = false,
        ['nl.txt'] = false,
        ['no.txt'] = false,
        ['pl.txt'] = false,
        ['pt.txt'] = false,
        ['ru.txt'] = false,
        ['sv.txt'] = false,
        ['th.txt'] = false,
        ['tr.txt'] = false,
        ['zh.txt'] = false,
        ['tlh.txt'] = false
    },

    -- Character pattern matching
    patterns = {
        a = '[aA@]',
        b = '[bB]',
        c = '[cCkK]',
        d = '[dD]',
        e = '[eE3]',
        f = '[fF]',
        g = '[gG6]',
        h = '[hH]',
        i = '[iIl!1]',
        j = '[jJ]',
        k = '[cCkK]',
        l = '[lL1!i]',
        m = '[mM]',
        n = '[nN]',
        o = '[oO0]',
        p = '[pP]',
        q = '[qQ9]',
        r = '[rR]',
        s = '[sS$5]',
        t = '[tT7]',
        u = '[uUvV]',
        v = '[vVuU]',
        w = '[wW]',
        x = '[xX]',
        y = '[yY]',
        z = '[zZ2]'
    }
}

-- Load dependencies
local json = loadfile('./WordBuster/json.lua')()
local infractions = {}
local infractions_dirty = false
local bad_words = {}
local immune_cache = {}
local pattern_cache = {}
local global_word_cache = {}

-- Metatable for pattern fallback:
setmetatable(settings.patterns, {
    __index = function(_, char)
        return char:gsub("([^%w])", "%%%1")  -- Escape non-alphanumeric
    end
})

-- ========================
-- Utility Functions
-- ========================
local function write_file(path, content, is_json)
    local file = io.open(path, 'w')
    if not file then return false end
    file:write(is_json and json:encode_pretty(content) or content)
    file:close()
    return true
end

local function read_file(path)
    local file = io.open(path, 'r')
    if not file then return nil end
    local content = file:read('*a')
    file:close()
    return content
end

local function load_infractions()
    local content = read_file(settings.infractions_directory)
    return content and json:decode(content) or {}
end

local function save_infractions()
    if not infractions_dirty then return false end
    local success = write_file(settings.infractions_directory, infractions, true)
    if success then infractions_dirty = false end
    return success
end

local function has_permission(id, level, msg)
    if id == 0 or tonumber(get_var(id, '$lvl')) >= level then return true end
    if id ~= 0 then rprint(id, msg) end
    return false
end

local function compile_pattern(word)
    if pattern_cache[word] then return pattern_cache[word] end

    word = word:match("^%s*(.-)%s*$") or ""
    local pattern = ''

    for char in word:lower():gmatch(".") do
        pattern = pattern .. settings.patterns[char]:lower()
    end

    pattern = '%f[%w]' .. pattern .. '%f[%W]'
    pattern_cache[word] = pattern
    return pattern
end

-- ========================
-- Core Functionality
-- ========================
local function load_bad_words()
    bad_words = {}
    local count_langs = 0
    local word_count = 0
    local start_time = os.clock()

    for lang, enabled in pairs(settings.languages) do
        if enabled then
            local path = settings.lang_directory .. lang
            local content = read_file(path)
            if content then
                for line in content:gmatch("[^\r\n]+") do
                    local word = line:match("^%s*(.-)%s*$") or ""
                    if word ~= "" and not word:match("^%s*#") then

                        if not global_word_cache[word] then
                            local ok, pattern = pcall(compile_pattern, word)
                            if ok and pattern then
                                global_word_cache[word] = pattern
                            else
                                cprint(('WARNING: Could not compile pattern for "%s" in %s'):format(word, path), 12)
                                global_word_cache[word] = nil
                            end
                        end

                        if global_word_cache[word] then
                            bad_words[#bad_words + 1] = {
                                pattern = global_word_cache[word],
                                language = lang,
                                word = word
                            }
                            word_count = word_count + 1
                        end
                    end
                end
                count_langs = count_langs + 1
            else
                cprint(('WARNING: Language file not found: %s'):format(path), 12)
            end
        end
    end

    local load_time = os.clock() - start_time
    cprint(('Loaded %d words from %d languages in %.4f seconds'):format(word_count, count_langs, load_time), 10)
    return word_count
end

local function format_message(template, vars)
    return (template:gsub('%$(%w+)', function(k)
        return tostring(vars[k] or '')
    end))
end

local function notify_infraction(name, word, pattern, lang)
    if not settings.notify_console then return end

    local message = format_message(settings.notify_console_format, {
        name = name,
        word = word,
        pattern = pattern,
        lang = lang
    })
    cprint(message)
end

function clean_infractions()
    if next(infractions) == nil then return true end  -- Skip if empty

    local now = os.time()
    local changed = false
    local grace_seconds = settings.grace_period * 86400

    for ip, data in pairs(infractions) do
        if data.last_infraction and (now - data.last_infraction) > grace_seconds then
            infractions[ip] = nil
            changed = true
        end
    end

    if changed then infractions_dirty = true end
    save_infractions()
    return true
end

-- ========================
-- Command Handlers
-- ========================
local command_handlers = {
    wb_langs = function(id)
        if not has_permission(id, 4, 'You need level 4+ for this command') then return end
        rprint(id, 'Enabled Languages:')
        local found = false
        for lang, enabled in pairs(settings.languages) do
            if enabled then
                rprint(id, '- ' .. lang)
                found = true
            end
        end
        if not found then rprint(id, 'No languages enabled') end
    end,

    wb_add_word = function(id, args)
        if not has_permission(id, 4, 'You need level 4+ for this command') then return end
        if #args < 3 then
            rprint(id, 'Usage: /wb_add_word <word> <lang>')
            return
        end

        local word, lang = args[2], args[3]
        if not settings.languages[lang] then
            rprint(id, 'Invalid language file')
            return
        end
        if not settings.languages[lang] then
            rprint(id, 'Language is disabled')
            return
        end

        local path = settings.lang_directory .. lang
        local content = read_file(path) or ''
        local new_content = content .. '\n' .. word
        if write_file(path, new_content) then
            rprint(id, ('Added "%s" to %s'):format(word, lang))
            load_bad_words()
        else
            rprint(id, 'Failed to write to language file')
        end
    end,

    wb_del_word = function(id, args)
        if not has_permission(id, 4, 'You need level 4+ for this command') then return end
        if #args < 3 then
            rprint(id, 'Usage: /wb_del_word <word> <lang>')
            return
        end

        local word, lang = args[2], args[3]
        if not settings.languages[lang] then
            rprint(id, 'Invalid language file')
            return
        end

        local path = settings.lang_directory .. lang
        local content = read_file(path)
        if not content then
            rprint(id, 'Language file not found')
            return
        end

        local new_content = {}
        local removed = false
        for line in content:gmatch("[^\r\n]+") do
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

        if write_file(path, table.concat(new_content, '\n')) then
            rprint(id, ('Removed "%s" from %s'):format(word, lang))
            load_bad_words()
        else
            rprint(id, 'Failed to update language file')
        end
    end,

    wb_enable_lang = function(id, args)
        if not has_permission(id, 4, 'You need level 4+ for this command') then return end
        if #args < 2 then
            rprint(id, 'Usage: /wb_enable_lang <lang>')
            return
        end

        local lang = args[2]
        if not settings.languages[lang] then
            rprint(id, 'Language file not found')
            return
        end
        if settings.languages[lang] then
            rprint(id, 'Language already enabled')
            return
        end

        settings.languages[lang] = true
        rprint(id, ('Enabled %s'):format(lang))
        load_bad_words()
    end,

    wb_disable_lang = function(id, args)
        if not has_permission(id, 4, 'You need level 4+ for this command') then return end
        if #args < 2 then
            rprint(id, 'Usage: /wb_disable_lang <lang>')
            return
        end

        local lang = args[2]
        if not settings.languages[lang] then
            rprint(id, 'Language file not found')
            return
        end
        if not settings.languages[lang] then
            rprint(id, 'Language already disabled')
            return
        end

        settings.languages[lang] = false
        rprint(id, ('Disabled %s'):format(lang))
        load_bad_words()
    end
}

local function immune(id)
    if immune_cache[id] ~= nil then return immune_cache[id] end
    local lvl = tonumber(get_var(id, '$lvl'))
    immune_cache[id] = settings.immune[lvl] or false
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

    timer(settings.clean_interval_seconds * 1000, 'clean_infractions')
end

function OnScriptUnload()
    save_infractions()
end

function OnGameEnd()
    save_infractions()
    immune_cache = {}  -- Reset immunity cache
end

function OnPlayerLeave(id)
    immune_cache[id] = nil
end

function OnCommand(id, command)
    local cmd = command:match("^(%S+)")
    if not cmd or not settings.commands[cmd] then return true end

    local handler = command_handlers[cmd]
    if handler then

        local args = {}
        for arg in command:gmatch('%S+') do
            table.insert(args, arg:lower())
        end
        handler(id, args)

        return false
    end
    return true
end

function OnChat(id, message)
    if settings.ignore_commands and (message:find('^/') or message:find('^\\')) then return true end
    if immune(id) then return true end

    local name = get_var(id, '$name')
    local ip = get_var(id, '$ip')
    local msg_lower = message:lower()

    for _, data in ipairs(bad_words) do
        if msg_lower:find(data.pattern) then
            notify_infraction(name, data.word, data.pattern, data.language)

            -- Handle infractions with local caching
            local ip_data = infractions[ip]
            if not ip_data then
                ip_data = { warnings = 0, name = name }
                infractions[ip] = ip_data
            end
            ip_data.warnings = ip_data.warnings + 1
            ip_data.last_infraction = os.time()
            infractions_dirty = true

            -- Handle warnings/punishment
            local warnings = ip_data.warnings
            if warnings >= settings.warnings then
                if warnings == settings.warnings then
                    rprint(id, settings.last_warning)
                else
                    local action = settings.punishment
                    local msg = format_message(settings.on_punish, { punishment = action })

                    if action == 'kick' then
                        execute_command('k ' .. id .. ' "' .. msg .. '"')
                    elseif action == 'ban' then
                        execute_command('ipban ' .. id .. ' ' .. settings.ban_duration .. ' "' .. msg .. '"')
                    end
                    infractions[ip] = nil
                end
            else
                rprint(id, settings.notify_text)
            end
            return false
        end
    end
    return true
end