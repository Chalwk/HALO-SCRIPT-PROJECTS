--=====================================================================================================--
-- SCRIPT NAME: Vote Kick Manager for SAPP (PC & CE)
-- Description: Manage vote kicks for disruptive players on the server.
--              Command syntax for voting: /votekick (player id)
--              Command syntax for vote list: /votelist
--              Command syntax for cancel vote: /cancelvote
--
-- Copyright (c) 2020-2024, Jericho Crosby <jericho.crosby227@gmail.com>
-- License: Use subject to the conditions outlined at:
--         https://github.com/Chalwk/HALO-SCRIPT-PROJECTS/blob/master/LICENSE
--=====================================================================================================--

local VoteKick = {
    vote_command = 'votekick', -- Command to initiate a vote kick
    vote_list_command = 'votelist', -- Command to list players eligible for vote
    cancel_vote_command = 'cancelvote', -- Command to cancel an ongoing vote
    minimum_players = 2, -- Minimum players required to initiate a vote
    vote_percentage = 60, -- Percentage of votes needed to kick a player
    vote_grace_period = 30, -- Time allowed for voting (seconds)
    quit_grace_period = 30, -- Time to wait after a player quits (seconds)
    kicked_grace_period = 60, -- Time to wait after a player is kicked before they can rejoin (seconds)
    anonymous_votes = false, -- Enable anonymous voting
    announce_on_initiate = true, -- Announce when a vote kick starts
    announce_usage = true, -- Periodically remind players about vote kick usage
    announce_interval = 120, -- Announcement interval (seconds)
    admin_immunity = true, -- Admins cannot be voted to kick
    prefix = '**SAPP**', -- Prefix for server messages
}

local players = {}
local active_votes = {}
local kicked_players = {}                -- Track kicked players
api_version = '1.12.0.0'

-- Utility function to split command arguments
local function CMDSplit(s)
    local args = {}
    for arg in s:gmatch('([^%s]+)') do
        table.insert(args, arg)
    end
    return args
end

-- Function to announce usage of the vote kick command
local function AnnounceUsage()
    say_all("Use /" .. VoteKick.vote_command .. " [player id] to initiate a vote kick.")
end

-- Function to initialize periodic announcements
local function InitAnnouncements()
    if VoteKick.announce_usage then
        timer(VoteKick.announce_interval * 1000, "AnnounceUsage")
    end
end

-- Player class definition
local Player = {}
Player.__index = Player

function Player:new(id)
    local self = setmetatable({}, Player)
    self.id = id
    self.name = get_var(id, "$name")
    self.votes = 0
    self.active_vote = false
    self.kicked = false              -- Track if the player has been kicked
    self.kicked_time = nil           -- Track the time the player was kicked
    return self
end

function Player:IsAdmin()
    return VoteKick.admin_immunity and tonumber(get_var(self.id, "$lvl")) >= 0
end

function Player:Send(msg)
    rprint(self.id, "|c" .. msg)
end

function Player:ResetVotes()
    self.votes = 0
    self.active_vote = false
    self.kicked = false               -- Reset kicked status
    self.kicked_time = nil            -- Reset kicked time
    self:Send('Your votes have been reset.')
end

function Player:AnnounceVote()
    execute_command('msg_prefix ""')
    say_all('Vote Kick initiated against ' .. self.name .. '.')
    say_all('Use command /' .. VoteKick.vote_list_command .. ' to see who can be voted out.')
    say_all('Use command /' .. VoteKick.vote_command .. ' (id) to vote to kick a player.')
    say_all('Use command /' .. VoteKick.cancel_vote_command .. ' to cancel the vote.')
    execute_command('msg_prefix "' .. VoteKick.prefix .. '"')
end

function Player:CheckVotes(voter)
    if self.votes == 1 then
        self:AnnounceVote()
    end

    local total_players = tonumber(get_var(0, '$pn'))
    local votes_needed = math.ceil((VoteKick.vote_percentage / 100) * total_players) - self.votes

    if votes_needed <= 0 then
        self:Kick(voter)
    elseif not VoteKick.anonymous_votes then
        say_all(voter.name .. ' voted to kick ' .. self.name .. ' - (' .. votes_needed .. ' votes needed)');
    end
end

function Player:Kick(voter)
    self.kicked = true
    self.kicked_time = os.clock()     -- Record the time of kicking
    self:Send('Vote kick passed. You have been kicked from the server.')
    execute_command('k ' .. self.id .. ' "[Vote Kick - ' .. self.votes .. ' votes]"')
    if not VoteKick.anonymous_votes then
        say_all(voter.name .. ' voted to kick ' .. self.name)
    end
end

-- Main event handlers
function OnScriptLoad()
    register_callback(cb['EVENT_TICK'], 'OnTick')
    register_callback(cb['EVENT_JOIN'], 'OnJoin')
    register_callback(cb['EVENT_LEAVE'], 'OnLeave')
    register_callback(cb['EVENT_COMMAND'], 'OnCommand')
    register_callback(cb['EVENT_GAME_START'], 'OnGameStart')

    OnGameStart()
    InitAnnouncements()
end

function OnGameStart()
    if get_var(0, '$gt') ~= 'n/a' then
        players = {}
        active_votes = {}
        kicked_players = {}
        for i = 1, 16 do
            if player_present(i) then
                OnJoin(i)
            end
        end
    end
end

function OnJoin(id)
    if kicked_players[id] and os.clock() < (kicked_players[id] + VoteKick.kicked_grace_period) then
        rprint(id, "You cannot join the server yet. Please wait a moment.")
        execute_command('k ' .. id .. ' "You have been kicked. Wait for your grace period to expire."')
        return
    end

    players[id] = Player:new(id)
end

function OnLeave(id)
    if players[id] then
        players[id].active_vote = false
        players[id]:ResetVotes()
        players[id].kicked_time = nil        -- Reset kicked time on leave
        kicked_players[id] = nil             -- Remove from kicked players
        players[id] = nil
    end
end

function OnTick()
    for _, player in pairs(players) do
        if player.active_vote and player.votes == 0 then
            player:ResetVotes()
        end
    end

    -- Check for kicked players who can rejoin
    for id, time in pairs(kicked_players) do
        if os.clock() > (time + VoteKick.kicked_grace_period) then
            kicked_players[id] = nil -- Remove from kicked players list
        end
    end
end

-- Local function to handle the vote kick command
local function HandleVoteKickCommand(player_id, args)
    local target_id = tonumber(args[2])
    if target_id and player_present(target_id) then
        local target_player = players[target_id]
        if target_player and not target_player:IsAdmin() then
            target_player.votes = target_player.votes + 1
            target_player:CheckVotes(players[player_id])
            target_player.active_vote = true
            active_votes[target_id] = target_player
        end
    end
end

-- Local function to handle the vote list command
local function HandleVoteListCommand(player_id)
    rprint(player_id, "Players eligible for vote kick:")
    for _, player in pairs(players) do
        if player_present(player.id) and not player:IsAdmin() then
            rprint(player_id, player.id .. " - " .. player.name)
        end
    end
end

-- Local function to handle the cancel vote command
local function HandleCancelVoteCommand(player_id, args)
    local target_id = tonumber(args[2])
    if target_id and active_votes[target_id] then
        local target_player = active_votes[target_id]
        target_player:Send("Vote kick has been canceled.")
        target_player:ResetVotes()
        active_votes[target_id] = nil
        say_all(players[player_id].name .. ' has canceled the vote kick against ' .. target_player.name .. '.')
    else
        rprint(player_id, "No active vote kick against that player.")
    end
end

function OnCommand(player_id, command)
    local args = CMDSplit(command)
    local command_name = args[1]

    if player_id == 0 then
        return
    end

    if command_name == VoteKick.vote_command then
        HandleVoteKickCommand(player_id, args)
    elseif command_name == VoteKick.vote_list_command then
        HandleVoteListCommand(player_id)
    elseif command_name == VoteKick.cancel_vote_command then
        HandleCancelVoteCommand(player_id, args)
    end
end

function OnScriptUnload()
    -- Cleanup actions can be added here
end