--[[
--=====================================================================================================--
Script Name: Talkative Bots, for SAPP (PC & CE)
Description: Bots (AFK Clients) that talk!

-----[!] IMPORTANT [!] -----
1): This script requires that the following plugins are installed to your server:
    https://opencarnage.net/index.php?/topic/5998-sapp-http-client/
    http://regex.info/blog/lua/json

2): Place "json.lua" and the contents of "sapp-http-client" in your servers root directory.

Copyright (c) 2021, Jericho Crosby <jericho.crosby227@gmail.com>
Notice: You can use this script subject to the following conditions:
https://github.com/Chalwk/HALO-SCRIPT-PROJECTS/blob/master/LICENSE
--=====================================================================================================--
]]--

-- config starts --

local ChatBot = {

    -- A message relay function temporarily removes the "msg_prefix"
    -- and will restore it to this when the relay is finished:
    --
    server_prefix = "**SAPP**",
    --

    -- The remote database containing death messages and general chatter is located here:
    --
    database_endpoint = "https://raw.githubusercontent.com/Chalwk/HALO-SCRIPT-PROJECTS/master/misc/OSH/Talkative%20Bots.json",

    -- NOTE:
    -- general_chatter_delay is the min,max time between random chatter broadcasts:
    --

    -- BOTS:
    --
    ["eatit"] = {
        ip = "127.0.0.1",
        general_chatter_delay = { 60, 300 },
        death_message_chance = 5
    },

    ["whosaidthat"] = {
        ip = "127.0.0.1",
        general_chatter_delay = { 60, 300 },
        death_message_chance = 5
    },

    ["trippletits"] = {
        ip = "127.0.0.1",
        general_chatter_delay = { 60, 300 },
        death_message_chance = 5
    },

    ["a girl"] = {
        ip = "127.0.0.1",
        general_chatter_delay = { 60, 300 },
        death_message_chance = 5
    },

    ["ucanteven"] = {
        ip = "127.0.0.1",
        general_chatter_delay = { 60, 300 },
        death_message_chance = 5
    },

    ["randomshit"] = {
        ip = "127.0.0.1",
        general_chatter_delay = { 60, 300 },
        death_message_chance = 5
    },

    ["thisguy"] = {
        ip = "127.0.0.1",
        general_chatter_delay = { 60, 300 },
        death_message_chance = 5
    },

    ["moneyindabnk"] = {
        ip = "127.0.0.1",
        general_chatter_delay = { 60, 300 },
        death_message_chance = 5
    },

    ["11chars"] = {
        ip = "127.0.0.1",
        general_chatter_delay = { 60, 300 },
        death_message_chance = 5
    },

    ["billion0110"] = {
        ip = "127.0.0.1",
        general_chatter_delay = { 60, 300 },
        death_message_chance = 5
    },

    ["niceoneboss"] = {
        ip = "127.0.0.1",
        general_chatter_delay = { 60, 300 },
        death_message_chance = 5
    },

    ["neuralnet"] = {
        ip = "127.0.0.1",
        general_chatter_delay = { 60, 300 },
        death_message_chance = 5
    },

    ["epoch101"] = {
        ip = "127.0.0.1",
        general_chatter_delay = { 60, 300 },
        death_message_chance = 5
    },

    ["epic"] = {
        ip = "127.0.0.1",
        general_chatter_delay = { 60, 300 },
        death_message_chance = 5
    },

    ["fashionshow"] = {
        ip = "127.0.0.1",
        general_chatter_delay = { 60, 300 },
        death_message_chance = 5
    },

    ["rektkid"] = {
        ip = "127.0.0.1",
        general_chatter_delay = { 60, 300 },
        death_message_chance = 5
    },

    ["props2u"] = {
        ip = "127.0.0.1",
        general_chatter_delay = { 60, 300 },
        death_message_chance = 5
    },

    ["headmasta"] = {
        ip = "127.0.0.1",
        general_chatter_delay = { 60, 300 },
        death_message_chance = 5
    },

    ["thumping"] = {
        ip = "127.0.0.1",
        general_chatter_delay = { 60, 300 },
        death_message_chance = 5
    },

    ["silky"] = {
        ip = "127.0.0.1",
        general_chatter_delay = { 60, 300 },
        death_message_chance = 5
    },

    ["bread&crumb"] = {
        ip = "127.0.0.1",
        general_chatter_delay = { 60, 300 },
        death_message_chance = 5
    },

    ["luckyboss"] = {
        ip = "127.0.0.1",
        general_chatter_delay = { 60, 300 },
        death_message_chance = 5
    },

    ["mc jagger"] = {
        ip = "127.0.0.1",
        general_chatter_delay = { 60, 300 },
        death_message_chance = 5
    },

    ["jaggins"] = {
        ip = "127.0.0.1",
        general_chatter_delay = { 60, 300 },
        death_message_chance = 5
    },

    ["thuglife"] = {
        ip = "127.0.0.1",
        general_chatter_delay = { 60, 300 },
        death_message_chance = 5
    },

    ["your_mama"] = {
        ip = "127.0.0.1",
        general_chatter_delay = { 60, 300 },
        death_message_chance = 5
    },

    ["some_guy"] = {
        ip = "127.0.0.1",
        general_chatter_delay = { 60, 300 },
        death_message_chance = 5
    },
}

api_version = "1.12.0.0"

-- config ends --

-- Used for custom timers:
local time_scale = 1 / 30

-- One-time load of JSON routines:
local json = (loadfile "json.lua")()

function OnScriptLoad()

    -- Register needed event callbacks:
    --
    register_callback(cb["EVENT_TICK"], "OnTick")
    register_callback(cb["EVENT_JOIN"], "OnJoin")
    register_callback(cb["EVENT_LEAVE"], "OnQuit")
    register_callback(cb["EVENT_DIE"], "OnPlayerDeath")
    register_callback(cb["EVENT_GAME_END"], "OnGameEnd")
    register_callback(cb["EVENT_GAME_START"], "OnGameStart")

    OnGameStart()
end

function ChatBot:OnGameStart()

    -- Ensures the script doesn't run talk-logic unless a game is running:
    --
    self.init = false

    --

    self.players = { }
    self.messages = { general_chatter = {}, death_messages = {} }

    if (get_var(0, "$gt") ~= "n/a") then

        -- Sets the script into run mode (ensures talk-logic is in play):
        --
        self.init = true
        self.delayed_messages = self.delayed_messages or {}

        -- Loop through all players online and initialise a new array for them:
        --
        for i = 1, 16 do
            if player_present(i) then
                self:InitPlayer(i, false)
            end
        end

        -- Retrieve remote database:
        --
        local time_to_load = os.clock()

        local JsonData = self:Query(self.database_endpoint)
        if (assert(JsonData, "Unable to load database")) then

            -- Converts JSON array into a string-indexed Lua array:
            --
            local messages = json:decode(JsonData)

            -- Convert tables into numerically indexed arrays:
            --
            local gc_count, dm_count = 0, 0
            for txt, enabled in pairs(messages.general_chatter) do
                gc_count = gc_count + 1
                table.insert(self.messages.general_chatter, { txt, enabled })
            end

            for txt, enabled in pairs(messages.death_messages) do
                dm_count = dm_count + 1
                table.insert(self.messages.death_messages, { txt, enabled })
            end

            cprint("----- [ Talkative Bots ] -----", 10)
            cprint(gc_count .. " general chatter messages loaded", 10)
            cprint(dm_count .. " death messages loaded", 10)
            cprint(gc_count + dm_count .. " total messages", 10)
            cprint("Database finished loading in " .. os.clock() - time_to_load .. " seconds", 5)
            cprint("--------------------------------------------------------------", 10)
        end
    end
end

function ChatBot:InitPlayer(Ply, Reset)
    local name = get_var(Ply, "$name")

    -- TRUE when called from OnJoin:
    --
    if (not Reset) then

        local player = self[name]
        local ip = get_var(Ply, "$ip"):match("%d+.%d+.%d+.%d+")
        if (player and player.ip == ip) then

            -- Assign this player an associative array (self[name]):
            --
            self.players[name] = player

            -- Used to keep track of how often random messages are broadcast:
            --
            self.players[name].timer = 0

            -- Set the initial general chatter delay:
            --
            local duration = player.general_chatter_delay
            self.players[name].time_until_next_talk = rand(duration[1], duration[2] + 1)

            return
        end
    end

    -- Clear tables for this player:
    --
    self.players[name] = nil
    self.delayed_messages[name] = nil
end

function OnGameEnd()
    ChatBot.init = false
end

function OnJoin(Ply)
    ChatBot:InitPlayer(Ply, false)
end

function OnQuit(Ply)
    ChatBot:InitPlayer(Ply, true)
end

-- This function is used to broadcast messages from the self.messages table.
--
function ChatBot:Say(String)
    execute_command("msg_prefix \"\"")
    say_all(String)
    execute_command("msg_prefix \" " .. self.server_prefix .. "\"")
end

function ChatBot:OnTick()
    if (self.init) then

        -- Loop through all online Bots:
        --
        for name, v in pairs(self.players) do

            -- Increment the timer variable:
            --
            v.timer = v.timer + time_scale

            -- Check if we need to output a message:
            --
            if (v.timer >= v.time_until_next_talk) then

                -- Update general chatter delay and timer:
                --
                local duration = v.general_chatter_delay
                v.time_until_next_talk = rand(duration[1], duration[2] + 1)
                v.timer = 0

                -- Access general chatter array and pick a random message table:
                --
                local messages = self.messages.general_chatter
                local txt = messages[rand(1, #messages + 1)]

                -- Check if message is enabled (txt[2] = boolean):
                --
                if (txt[2]) then

                    -- txt[1] = message string
                    txt = txt[1]

                    -- Loop through all players (i) who are not Bots:
                    --
                    local names = { }
                    for i = 1, 16 do
                        if player_present(i) then

                            -- Add each candidate (i) to a table called "names" (excludes Bots):
                            --
                            local player_name = get_var(i, "$name")
                            if (name ~= player_name) then
                                names[#names + 1] = player_name
                            end
                        end
                    end

                    -- Prepare and format "txt" for output:
                    --
                    local random_name = names[rand(1, #names + 1)] or "server"
                    txt = txt:gsub("%%bot%%", name):gsub("%%random_player_name%%", random_name)
                    self:Say(txt:gsub("%%bot%%", name))
                end
            end
        end

        -- Used to broadcast messages that are on a delay:
        -- This applies to death messages only.
        for name, v in pairs(self.delayed_messages) do
            if (name) then
                v.timer = v.timer + time_scale
                if (v.timer >= v.delay) then
                    self.delayed_messages[name] = nil
                    self:Say(v.txt)
                end
            end
        end
    end
end

local function RepalceStr(n, kn, vn, vk, kk)
    return {
        ["%%bot%%"] = n, -- bot name
        ["%%killer%%"] = kn, -- killer name
        ["%%victim%%"] = vn, -- victim name
        ["%%v_kills%%"] = vk, -- victim kills
        ["%%k_kills%%"] = kk, -- killer kills
    }
end

function ChatBot:OnPlayerDeath(Victim, Killer)
    if (self.init and self.players) then

        local killer, victim = tonumber(Killer), tonumber(Victim)
        if (killer > 0 and killer ~= victim) then

            -- Iterate through online bots:
            --
            for name, v in pairs(self.players) do

                -- Retrieve killer & victim's names:
                --
                local k_name = get_var(killer, "$name")
                local v_name = get_var(victim, "$name")

                -- Make sure the bot is not the killer nor victim:
                --
                if (k_name ~= name and v_name ~= name) then

                    math.randomseed(os.clock())
                    math.random();
                    math.random();
                    math.random();

                    local txt
                    local chance = v.death_message_chance
                    if (math.random() < chance / 100) then

                        -- Access death message array and pick a random message table:
                        --
                        local messages = self.messages.death_messages
                        txt = messages[rand(1, #messages + 1)]

                        -- Check if message is enabled (txt[2] = boolean):
                        --
                        if (txt[2]) then

                            -- txt[1] = message string
                            txt = txt[1]

                            -- Retrieve killer & victim's kills:
                            --
                            local v_kills = get_var(victim, "$kills")
                            local k_kills = get_var(killer, "$kills")

                            -- Prepare and format "txt" for output:
                            --
                            local str = RepalceStr(name, k_name, v_name, v_kills, k_kills)
                            for a, b in pairs(str) do
                                txt = txt:gsub(a, b)
                            end
                            goto next
                        end
                        break
                    end

                    -- Store "txt" in a temporary array (used to delay message output).
                    --
                    :: next ::
                    if (txt) then
                        self.delayed_messages[name] = {
                            txt = txt,
                            timer = 0,
                            delay = math.random(0, 5)
                        }
                    end

                    break
                end
            end
        end
    end
end

function OnTick()
    return ChatBot:OnTick()
end

function OnPlayerDeath(V, K)
    return ChatBot:OnPlayerDeath(V, K)
end

function OnGameStart()
    return ChatBot:OnGameStart()
end

function OnScriptUnload()
    -- N/A
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

function ChatBot:Query(URL)
    local response = http_client.http_get(URL, false)
    local returning
    if http_client.http_response_is_null(response) ~= true then
        local response_text_ptr = http_client.http_read_response(response)
        returning = ffi.string(response_text_ptr)
    end
    http_client.http_destroy_response(response)
    return returning
end

return ChatBot