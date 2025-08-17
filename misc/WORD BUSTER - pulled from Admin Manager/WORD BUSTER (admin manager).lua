word_buster = {

	enabled = false,

	-- SUPPORTED LANGUAGES:
	languages = {
		['cs.json'] = false, -- Czech
		['da.json'] = false, -- Danish
		['de.json'] = false, -- German
		['en.json'] = true, -- English
		['eo.json'] = false, -- Esperanto
		['es.json'] = true, -- Spanish
		['fr.json'] = false, -- French
		['hu.json'] = false, -- Hungry
		['it.json'] = false, -- Italy
		['ja.json'] = false, -- Japan
		['ko.json'] = false, -- Korea
		['nl.json'] = false, -- Dutch
		['no.json'] = false, -- Norway
		['pl.json'] = false, -- Poland
		['pt.json'] = false, -- Portuguese
		['ru.json'] = false, -- Russia
		['sv.json'] = false, -- Swedish
		['th.json'] = false, -- Thai
		['tr.json'] = false, -- Turkish
		['zh.json'] = false, -- Chinese
		['tlh.json'] = false -- Vietnamese
	},


	-- PATTERNS:
	-- Advanced users can add their own regular expressions to the list.
	--
	patterns = {
		['a'] = { '[aA@4]', '[aA@4][%-%s]', '[aA@4].' },
		['b'] = { '[bB]', '[bB][%-%s]', '[bB].' },
		['c'] = { '[cCkK<([]', '[cCkK<([][%-%s]', '[cCkK<([].', '[aA@4]_' },
		['d'] = { '[dD]', '[dD][%-%s]', '[dD].', '[dD]_' },
		['e'] = { '[eE3]', '[eE3][%-%s]', '[eE3].', '[eE3]_' },
		['f'] = { '[fF]', '[fF][%-%s]', '[fF].', '[fF]_' },
		['g'] = { '[gG6]', '[gG6][%-%s]', '[gG6].', '[gG6]_' },
		['h'] = { '[hH]', '[hH][%-%s]', '[hH].', '[hH]_' },
		['i'] = { '[iIl!1]', '[iIl!1][%-%s]', '[iIl!1].', '[iIl!1]_' },
		['j'] = { '[jJ]', '[jJ][%-%s]', '[jJ].', '[jJ]_' },
		['k'] = { '[cCkK]', '[cCkK][%-%s]', '[cCkK].', '[cCkK]_' },
		['l'] = { '[lL1!i]', '[lL1!i][%-%s]', '[lL1!i].', '[lL1!i]_' },
		['m'] = { '[mM]', '[mM][%-%s]', '[mM].', '[mM]_' },
		['n'] = { '[nN]', '[nN][%-%s]', '[nN].', '[nN]_' },
		['o'] = { '[oO0]', '[oO0][%-%s]', '[oO0].', '[oO0]_' },
		['p'] = { '[pP]', '[pP][%-%s]', '[pP].', '[pP]_' },
		['q'] = { '[qQ9]', '[qQ9][%-%s]', '[qQ9].', '[qQ9]_' },
		['r'] = { '[rR]', '[rR][%-%s]', '[rR].', '[rR]_' },
		['s'] = { '[sSzZ$5]', '[sSzZ$5][%-%s]', '[sSzZ$5].', '[sSzZ$5]_' },
		['t'] = { '[tT7]', '[tT7][%-%s]', '[tT7]].', '[tT7]]_' },
		['u'] = { '[uUvV]', '[uUvV][%-%s]', '[uUvV].', '[uUvV]_' },
		['v'] = { '[vVuU]', '[vVuU][%-%s]', '[vVuU].', '[vVuU]_' },
		['w'] = { '[wW]', '[wW][%-%s]', '[wW].', '[wW]_' },
		['x'] = { '[xX]', '[xX][%-%s]', '[xX].', '[xX]_' },
		['y'] = { '[yY]', '[yY][%-%s]', '[yY].', '[yY]_' },
		['z'] = { '[zZ2]', '[zZ2][%-%s]', '[zZ2].', '[zZ2]_' },
	}
}


function event:onChat(id, message)
    local player = self.players[id]
    if (not player or player:isMuted() or player:filterBadWords(message)) then
        return false
    end
end

local function regexMatch(message, pattern)
    message = message:lower():gsub('(.*)', ' %1 ')
    return message:find('[^%a]' .. pattern .. '[^%a]')
end

function event:filterBadWords(message)

    local word_buster = self.word_buster
    if (not word_buster.enabled) then
        return false
    end

    local ip = self.ip
    local name = self.name
    local found = false

    for word, data in _pairs(self.bad_words) do

        local regex = data.regex
        local lang = data.lang

        for i = 1, #regex do
            local pattern = regex[i]
            if regexMatch(message, pattern) then
                if (not found) then
                    found = true
                    cprint('Filtering bad words from ' .. name .. ' [' .. ip .. '].', 12)
                end
                cprint(word .. ' [' .. lang .. ']' .. ' ' .. pattern .. '', 5)
            end
        end
    end

    if (found) then
        self:log('Filtering bad word(s) from ' .. name .. ' [' .. ip .. '].', self.logging.management)
        self:send('Please do not use profanity in chat.')
        return true
    end

    return false
end

local function stringToTable(string)
    local strings = {}
    for i = 1, #string do
        strings[i] = string:sub(i, i)
    end
    return strings
end

local function getRegex(word, self)

    local args = stringToTable(word)
    local patterns = self.word_buster.patterns

    local regex = {}
    for i = 1, #args do
        local chars = patterns[args[i]]
        if (chars) then
            for char, pattern in _pairs(chars) do
                if (not regex[char]) then
                    regex[char] = pattern
                else
                    regex[char] = regex[char] .. pattern
                end
            end
        end
    end

    return regex
end

local function saveWords(words, lang, self)
    for i = 1, #words do
        local word = words[i]
        local regex = getRegex(word, self)
        self.bad_words[word] = {
            regex = regex,
            lang = lang:gsub('.json', '')
        }
    end
end

function IO:loadBadWords()

    local word_buster = self.word_buster
    if (not word_buster.enabled) then
        return
    end

    self.bad_words = {}
    local dir = './Admin Manager/langs/'
    local languages = word_buster.languages

    for lang, enabled in _pairs(languages) do
        if (enabled) then
            local file = dir .. lang
            local words = loadFile(file, self)
            if (words) then
                saveWords(words, lang, self)
            end
        end
    end
end