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
        [1] = true, [2] = true, [3] = true, [4] = true
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
    pattern_settings = {

        -- Trim whitespace
        trim_pattern = "^%s*(.-)%s*$",

        -- Comment lines in word lists
        comment_pattern = "^%s*#",

        -- Characters allowed between letters (no quantifier)
        separator_class = "[%s%p]",

        -- Word boundary anchors
        word_boundary_start = "",
        word_boundary_end = "",

        -- Non-alphanumeric character escape
        escape_non_word = "([^%w])",
        escape_replacement = "%%%1",

        -- Pattern for reading lines in a file
        line_pattern = "[^\\r\\n]+",

        -- Leet-speak substitutions
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
local GRACE_PERIOD_SECONDS = settings.grace_period * 86400
local CLEAN_INTERVAL_MS = settings.clean_interval_seconds * 1000

local open = io.open
local pairs, ipairs = pairs, ipairs
local concat = table.concat
local clock, time = os.clock, os.time

-- Metatable for pattern fallback
setmetatable(settings.pattern_settings.leet_map, {
    __index = function(_, char)
        return char:gsub(settings.pattern_settings.escape_non_word, settings.pattern_settings.escape_replacement)
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
    local content = read_file(settings.infractions_directory)
    return content and json:decode(content) or {}
end

local function save_infractions()
    if infractions_dirty then
        if write_file(settings.infractions_directory, infractions, true) then
            infractions_dirty = false
        end
    end
end

local function has_permission(id, level)
    return id == 0 or tonumber(get_var(id, '$lvl')) >= level
end

local function compile_pattern(word)
    if pattern_cache[word] then return pattern_cache[word] end

    local ps = settings.pattern_settings
    word = word:match(ps.trim_pattern) or ""
    local pattern_builder = {}

    local sep = (ps.separator_class) .. '*'
    local len = #word
    for i = 1, len do
        local ch = word:sub(i, i)
        local chpat = ps.leet_map[ch:lower()] or ch:gsub(ps.escape_non_word, ps.escape_replacement)
        pattern_builder[#pattern_builder + 1] = chpat
        if i < len then
            pattern_builder[#pattern_builder + 1] = sep
        end
    end

    local pattern = ps.word_boundary_start .. concat(pattern_builder) .. ps.word_boundary_end
    pattern_cache[word] = pattern
    return pattern
end

-- ========================
-- Core Functionality
-- ========================
local function load_bad_word_file(path, lang)
    local ps = settings.pattern_settings
    local content = read_file(path)
    if not content then return 0 end

    local count = 0
    for line in content:gmatch(ps.line_pattern) do
        local word = line:match(ps.trim_pattern)
        if word and word ~= "" and not word:match(ps.comment_pattern) then
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

    for lang, enabled in pairs(settings.languages) do
        if enabled then
            local path = settings.lang_directory .. lang
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
    if settings.notify_console then
        local message = format_message(settings.notify_console_format, {
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
    for lang, enabled in pairs(settings.languages) do
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
    if not settings.languages[lang] then
        rprint(id, 'Invalid language file')
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
end

local function handle_wb_del_word(id, args)
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

    local ps = settings.pattern_settings
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
    if not settings.languages[lang] then
        rprint(id, 'Language file not found')
        return
    end

    if settings.languages[lang] == enable then
        rprint(id, 'Language already ' .. (enable and 'enabled' or 'disabled'))
        return
    end

    settings.languages[lang] = enable
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
        immune_cache[id] = settings.immune[tonumber(get_var(id, '$lvl'))] or false
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
    --register_callback(cb['EVENT_GAME_START'], 'OnStart') -- for debugging

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
    if not cmd or not settings.commands[cmd] then return true end

    local handler = command_handlers[cmd]
    if handler then
        if not has_permission(id, 4) then
            rprint(id, 'You need level 4+ for this command')
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
    if settings.ignore_commands and (message:find('^/') or message:find('^\\')) then return true end
    if immune(id) then return true end

    local ps = settings.pattern_settings
    local name = get_var(id, '$name')
    local ip = get_var(id, '$ip')
    local msg_lower = message:lower()

    for _, data in ipairs(bad_words) do
        if msg_lower:find(data.pattern) then
            notify_infraction(name, data.word, data.pattern, data.language)

            local ip_data = infractions[ip] or { warnings = 0, name = name }
            ip_data.warnings = ip_data.warnings + 1
            ip_data.last_infraction = time()

            infractions[ip] = ip_data
            infractions_dirty = true

            local warnings = ip_data.warnings
            if warnings == settings.warnings then
                rprint(id, settings.last_warning)
            elseif warnings > settings.warnings then
                local action = settings.punishment
                local msg = format_message(settings.on_punish, { punishment = action })

                if action == 'kick' then
                    execute_command('k ' .. id .. ' "' .. msg .. '"')
                elseif action == 'ban' then
                    execute_command('ipban ' .. id .. ' ' .. settings.ban_duration .. ' "' .. msg .. '"')
                end
                infractions[ip] = nil
            else
                rprint(id, settings.notify_text)
            end
            return false
        end
    end
    return true
end

function OnStart()
    if get_var(0, '$gt') == 'n/a' then return end

    -- ================================
    -- Profanity Filter Test Harness
    -- ================================

    local test_bad_words = { "fuck", "shit", "bitch", "asshole", "bastard", "cunt", "dick", "piss" }
    local test_patterns = {}
    for _, w in ipairs(test_bad_words) do
        test_patterns[#test_patterns + 1] = {
            word = w,
            pattern = compile_pattern(w),
            language = "en.txt"
        }
    end

    local test_sentences = {
        { msg = "Hello there, friend!", should_match = false },
        { msg = "You are a fuck!", should_match = true },
        { msg = "That guy is an a$$hole!", should_match = true },
        { msg = "Sh1t happens.", should_match = true },
        { msg = "$h1+ happens.", should_match = true },
        { msg = "s_h_i_t+", should_match = true },
        { msg = "5h!t", should_match = true },
        { msg = "sh!t.", should_match = true },
        { msg = "This is a clean sentence with no swearing.", should_match = false },
        { msg = "You little b!tch!", should_match = true },
        { msg = "P1ss off, mate.", should_match = true },
        { msg = "Good morning everyone.", should_match = false },
        { msg = "You're such a BasTaRd!", should_match = true },
        { msg = "F.U.C.K this!", should_match = true },
        { msg = "Nothing rude here at all.", should_match = false },
        { msg = "f*ck off!", should_match = true },
        { msg = "f#ck you!", should_match = true },
        { msg = "f**k!", should_match = true },
        { msg = "sh!7 happens.", should_match = true },
        { msg = "b!tch please.", should_match = true },
        { msg = "a$$h0le alert!", should_match = true },
        { msg = "a5sh0le!", should_match = true },
        { msg = "c*nt!", should_match = true },
        { msg = "d!ckhead.", should_match = true },
        { msg = "d1ck!", should_match = true },
        { msg = "p!$$ off.", should_match = true },
        { msg = "p1$$ed off!", should_match = true },
        { msg = "b@st@rd!", should_match = true },
        { msg = "c.u.n.t", should_match = true },
        { msg = "sh!tty.", should_match = true },
        { msg = "f.u.c.k.y.o.u", should_match = true },
        { msg = "5h!7 h@pp3ns.", should_match = true },
        { msg = "b1tch!", should_match = true },
        { msg = "a$$h*l3", should_match = true },
        { msg = "p!ss off!", should_match = true },
    }

    -- Run the tests
    print("=== Word Buster Test Results ===")
    for i, test in ipairs(test_sentences) do
        local lower_msg = test.msg:lower()
        local matched = false
        local matched_word, matched_pattern

        for _, data in ipairs(test_patterns) do
            if lower_msg:find(data.pattern) then
                matched = true
                matched_word = data.word
                matched_pattern = data.pattern
                break
            end
        end

        local result = matched == test.should_match and "PASS" or "FAIL"
        print(string.format(
            "[%02d] %-50s | Expected: %-5s | Got: %-5s | %s%s",
            i,
            '"' .. test.msg .. '"',
            tostring(test.should_match),
            tostring(matched),
            result,
            matched and (" | Matched Word: " .. matched_word) or ""
        ))
    end
end