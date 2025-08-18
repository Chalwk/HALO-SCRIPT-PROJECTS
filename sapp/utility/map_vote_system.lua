--[[
--=====================================================================================================--
Script Name: Custom Map Voting System (v2), for SAPP (PC & CE)
Description: A custom map voting system that replaces the built-in SAPP voting mechanism.

Features:
   1. Players can cast and recast their votes.
   2. Support for displaying more than six voting options.
   3. Fully configurable settings and messages.
   4. Limitation on how many times a player can change their vote.
   5. Adjustable timers for map vote display, tallying votes, and map cycling.

Copyright (c) 2022-2024, Jericho Crosby <jericho.crosby227@gmail.com>
Notice: You can use this script subject to the following conditions:
https://github.com/Chalwk/HALO-SCRIPT-PROJECTS/blob/master/LICENSE
--=====================================================================================================--
]]--

api_version = "1.12.0.0"

local MapVoteConfig = {
    map_skip_percentage = 60, -- Percentage required for map skip (0 to disable).
    re_vote_allowed = true, -- Allow players to recast votes.
    max_re_votes = 1, -- Maximum re-votes allowed per player.
    display_vote_options = 8, -- Number of maps to display for voting.
    clear_console = false, -- Clear player's console when displaying votes.
    message_format = {
        vote_message = "$name voted for [#$id] $map",
        re_vote_message = "$name changed vote to [#$id] $map",
        map_option_message = "[$id] $map",
        vote_winner = "$map won with $votes votes",
        no_votes_message = "No votes cast. Choosing $map...",
        invalid_vote = "Invalid vote id. Please enter a number between 1 and $max",
        too_early_vote = "Please wait $time seconds before voting...",
        vote_limit_reached = "You have reached the re-vote limit.",
    },
    timers = {
        time_to_show_votes = 7, -- Time to show votes after game ends.
        time_to_tally_votes = 13, -- Time to tally votes after voting period ends.
        time_to_cycle_map = 13, -- Time to cycle map after PGCR.
        re_show_interval = 3, -- Time interval to re-show vote options.
    },
    map_repeats_limit = 2, -- Maximum number of times a map can be played consecutively.
    map_list = {
        { "bloodgulch", "ctf" },
        { "deathisland", "ctf" },
        { "sidewinder", "ctf" },
        { "icefields", "ctf" },
        { "infinity", "ctf" },
        { "timberland", "ctf" },
        { "dangercanyon", "ctf" },
        { "beavercreek", "ctf" },
        { "boardingaction", "ctf" },
        { "carousel", "ctf" },
        { "chillout", "ctf" },
        { "damnation", "ctf" },
        { "gephyrophobia", "ctf" },
        { "hangemhigh", "ctf" },
        { "longest", "ctf" },
        { "prisoner", "ctf" },
        { "putput", "ctf" },
        { "ratrace", "ctf" },
        { "wizard", "ctf" }
    },
}

-- Script Variables:
local player_votes = {}
local map_results = {}
local vote_timer = 0
local vote_active = false
local map_streak = { last_map = -1, streak_count = 0 }

-- Register events and callbacks.
function OnScriptLoad()
    register_callback(cb["EVENT_CHAT"], "OnPlayerVote")
    register_callback(cb["EVENT_GAME_END"], "OnGameEnd")
    register_callback(cb["EVENT_GAME_START"], "OnGameStart")
    register_callback(cb["EVENT_JOIN"], "OnPlayerJoin")
    register_callback(cb["EVENT_LEAVE"], "OnPlayerLeave")
    OnGameStart(true)
end

function OnScriptUnload()
    -- N/A
end

local function InitializePlayers()
    for i = 1, 16 do
        if player_present(i) then
            player_votes[i] = MapVoteConfig.max_re_votes
        end
    end
end

local function ResetVoteData()
    vote_timer = 0
    vote_active = false
    map_results = {}
end

function OnGameStart(reset)
    if reset then
        ResetVoteData()
    end
    InitializePlayers()
end

function OnGameEnd()
    vote_active = true
    vote_timer = 0
    timer(25, "DisplayVoteOptions")
end

local function ClearConsole(Player)
    for _ = 1, 25 do
        rprint(Player, " ")
    end
end

local function BroadcastVoteOptions(map_options)
    for i = 1, 16 do
        if player_present(i) then
            if MapVoteConfig.clear_console then
                ClearConsole(i)
            end
            for j, map in ipairs(map_options) do
                local message = MapVoteConfig.message_format.map_option_message
                message = message:gsub("$id", j):gsub("$map", map[1])
                rprint(i, message)
            end
        end
    end
end

local function GenerateMapOptions()
    local maps = MapVoteConfig.map_list
    local vote_options = {}
    local count = 0

    for _, map in ipairs(maps) do
        -- Exclude maps that have exceeded the repeat limit:
        if map_streak.last_map ~= map[1] or map_streak.streak_count < MapVoteConfig.map_repeats_limit then
            table.insert(vote_options, map)
            count = count + 1
        end
        if count >= MapVoteConfig.display_vote_options then
            break
        end
    end

    -- If not enough maps were found, allow maps that were excluded due to streak:
    if count < MapVoteConfig.display_vote_options then
        for _, map in ipairs(maps) do
            if not table.contains(vote_options, map) then
                table.insert(vote_options, map)
                count = count + 1
            end
            if count >= MapVoteConfig.display_vote_options then
                break
            end
        end
    end

    return vote_options
end

function DisplayVoteOptions()
    local map_options = GenerateMapOptions()
    BroadcastVoteOptions(map_options)
    timer(MapVoteConfig.timers.time_to_tally_votes * 1000, "TallyVotesAndSelectMap") -- Call to tally votes after a delay
end

function OnPlayerJoin(player)
    player_votes[player] = MapVoteConfig.max_re_votes
end

function OnPlayerLeave(player)
    player_votes[player] = nil
end

local function ProcessPlayerVote(Player, vote_id)
    if player_votes[Player] > 0 then
        player_votes[Player] = player_votes[Player] - 1
        local map_voted = MapVoteConfig.map_list[vote_id][1]
        local vote_message = MapVoteConfig.message_format.vote_message
        vote_message = vote_message:gsub("$name", get_var(Player, "$name")):gsub("$id", vote_id):gsub("$map", map_voted)
        say_all(vote_message)

        -- Tally the votes:
        map_results[vote_id] = (map_results[vote_id] or 0) + 1
    else
        rprint(Player, MapVoteConfig.message_format.vote_limit_reached)
    end
end

function OnPlayerVote(Player, Message)
    if vote_active then
        local vote_id = tonumber(Message)
        if vote_id and vote_id >= 1 and vote_id <= #MapVoteConfig.map_list then
            ProcessPlayerVote(Player, vote_id)
        else
            rprint(Player, MapVoteConfig.message_format.invalid_vote:gsub("$max", #MapVoteConfig.map_list))
        end
    end
end

function TallyVotesAndSelectMap()
    local highest_vote = 0
    local winning_map

    for map_id, votes in pairs(map_results) do
        if votes > highest_vote then
            highest_vote = votes
            winning_map = MapVoteConfig.map_list[map_id]
        end
    end

    -- Handle case where no votes were cast:
    if not winning_map then
        winning_map = MapVoteConfig.map_list[1] -- Default to first map in list
        say_all(MapVoteConfig.message_format.no_votes_message:gsub("$map", winning_map[1]))
    else
        say_all(MapVoteConfig.message_format.vote_winner:gsub("$map", winning_map[1]):gsub("$votes", highest_vote))
    end

    -- Update map streak:
    if map_streak.last_map == winning_map[1] then
        map_streak.streak_count = map_streak.streak_count + 1
    else
        map_streak.last_map = winning_map[1]
        map_streak.streak_count = 1
    end

    -- Cycle to the selected map:
    timer(MapVoteConfig.timers.time_to_cycle_map * 1000, "load_map", winning_map[1], winning_map[2])
end

function OnCommand(PlayerIndex, Command, _, _)
    -- Custom commands if needed.
end

-- Helper function to check if a map is already in the vote options:
function table.contains(table, element)
    for _, value in pairs(table) do
        if value[1] == element[1] then
            return true
        end
    end
    return false
end

return false
