-- Rank System [Entry Point File] (v1.0)
-- Copyright (c) 2022, Jericho Crosby <jericho.crosby227@gmail.com>

--[[

A fully integrated Halo 3 style ranking system for SAPP servers.
Players earn credits for killing, scoring and achievements, such as sprees, kill-combos and more!

Stats are permanently saved to a local database called ranks.json.

Players are required to create a ranked account (in-game) to use this mod.
See the command syntax section below.

If you have an existing account, your credits will be restored when you log into your account.

Client login sessions are temporarily cached.
You will not have to log into your account when you quit and rejoin unless:
1. The server is restarted
2. Your IP address changes
3. Your client port changes (depending on config, see more on that below)
   In ./settings.lua, there is an option to cache sessions by IP only, or IP:PORT.
   The default setting is IP:PORT.
   This setting is recommended otherwise all players on that IP will share the same account.
   This requires that players always have the same port, otherwise they will have to log into their account every time they join.

## COMMANDS:
| Command                                                           | Description                                               | Permission Level |
|-------------------------------------------------------------------|-----------------------------------------------------------|------------------|
| /c (user) (password)                                              | Create new ranked account                                 | -1               |
| /l (user) (password)                                              | Log into ranked account                                   | -1               |
| /cpu (current/new username) (current/new password)                | Change username & password                                | -1               |
                                                                      You need to be logged in to change the username/password.                    |
| /ranks                                                            | See a list of available ranks                             | -1               |
| /toplist                                                          | View list of top 10 players                               | -1               |
| /prestige                                                         | Prestige and reset your stats                             | -1               |
| /rank (player id [number])                                        | View yours (or someone else's rank)                       | -1               |
| /setrank (player [number]) (rank [number]) (grade [number])       | Rank a player up or down                                  | 4                |
----------------------------------------------------------------------------------------------------------------------------------------------------

## SCORING:
| Type                            | Credits                                                             |
|---------------------------------|---------------------------------------------------------------------|
| close call                      | (+2cR)                                                              |
| reload this                     | (+1cR)                                                              |
| headshot                        | (+1cR)                                                              |
| avenge                          | (+1cR)                                                              |
| revenge                         | (+1cR)                                                              |
| winning a game of FFA           | (+30cR)                                                             |
| team win                        | (+30cR)                                                             |
| team lose                       | (-5cR)                                                              |
| first blood                     | (+30 cR)                                                            |
| scoring (flag cap or new lap)   | (+5cR)                                                              |
| killed by server                | (-0cR)                                                              |
| killed by guardians             | (-5cR)                                                              |
| suicide                         | (-10cR)                                                             |
| betrayal (team games only)      | (-15cR)                                                             |
| spree                           | (+5cR every 5 consecutive kills).
                                    Script will award +50cR every 5 kills at or above 50.               |
| kill-combo                      | (+8cR for the first two kills.)
                                    Points increase by 2 for every kill after the fact: +10, +12, +14.
                                    Script will award 25 cR every 2 kills at or above a combo of 10.    |
| fall-damage                     | (-3cR)                                                              |
| distance-damage                 | (-4cR)                                                              |
| vehicle-squash ghost            | (+5cR)                                                              |
| vehicle-squash rocket-hog       | (+6cR)                                                              |
| vehicle-squash chaingun-hog     | (+7cR)                                                              |
| vehicle-squash banshee          | (+8cR)                                                              |
| vehicle-squash scorpion         | (+10cR)                                                             |
| vehicle-squash gun turret       | (+1000cR) If you can manage this, you deserve +1000cR!              |
| ghost bolt                      | (+7cR)                                                              |
| scorpion bullet                 | (+6cR)                                                              |
| warthog bullet                  | (+6cR)                                                              |
| gun turret bolt                 | (+7cR)                                                              |
| banshee bolt                    | (+7cR)                                                              |
| scorpion shell explosion        | (+10cR)                                                             |
| banshee fuel rod explosion      | (+10cR)                                                             |
| pistol bullet                   | (+5cR)                                                              |
| shotgun pellet                  | (+6cR)                                                              |
| plasma rifle bolt               | (+4cR)                                                              |
| needler explosion               | (+8cR)                                                              |
| plasma pistol bolt              | (+4cR)                                                              |
| assault rifle bullet            | (+5cR)                                                              |
| needler impact damage           | (+4cR)                                                              |
| flamethrower explosion          | (+5cR)                                                              |
| rocket launcher explosion       | (+8cR)                                                              |
| needler detonation damage       | (+3cR)                                                              |
| plasma rifle charged bolt       | (+4cR)                                                              |
| sniper rifle bullet             | (+6cR)                                                              |
| plasma cannon explosion         | (+8cR)                                                              |
| frag grenade explision          | (+8cR)                                                              |
| plasma grenade attached         | (+7cR)                                                              |
| plasma grenade explision        | (+5cR)                                                              |
| flag melee                      | (+5cR)                                                              |
| skull melee                     | (+5cR)                                                              |
| pistol melee                    | (+4cR)                                                              |
| needler melee                   | (+4cR)                                                              |
| shotgun melee                   | (+5cR)                                                              |
| flamethrower melee              | (+5cR)                                                              |
| sniper rifle melee              | (+5cR)                                                              |
| plasma rifle melee              | (+4cR)                                                              |
| plasma pistol melee             | (+4cR)                                                              |
| assault rifle melee             | (+4cR)                                                              |
| rocket launcher melee           | (+10cR)                                                             |
| plasma cannon melee             | (+10cR)                                                             |
---------------------------------------------------------------------------------------------------------

## RANK REQUIREMENTS:
| Rank                 | Grade 1 | Grade 2 | Grade 3 | Grade 4 |
|----------------------|---------|---------|---------|---------|
| Recruit              | 0       |         |         |         |
| Apprentice           | 3000    | 6000    |         |         |
| Private              | 9000    | 12000   |         |         |
| Corporal             | 13000   | 14000   |         |         |
| Sergeant             | 15000   | 16000   | 17000   | 18000   |
| Gunnery Sergeant     | 19000   | 20000   | 21000   | 22000   |
| Lieutenant           | 23000   | 24000   | 25000   | 26000   |
| Captain              | 27000   | 28000   | 29000   | 30000   |
| Major                | 31000   | 32000   | 33000   | 34000   |
| Commander            | 35000   | 36000   | 37000   | 38000   |
| Colonel              | 39000   | 40000   | 41000   | 42000   |
| Brigadier            | 43000   | 44000   | 45000   | 46000   |
| General              | 47000   | 48000   | 49000   | 50000   |
----------------------------------------------------------------

## Other Settings:
- Change the name of the local database (default: ranks.json)
- Change the currency symbol in all game messages
- Set the starting rank, grade and credits
- Choose when the local database is updated (default: event_game_end)
- Fully customizable messages

---

## INSTALLATION:
- Rank System.lua (SAPP SCRIPT)
1). Place the Rank System.lua file in your Lua folder.

- Rank System (FOLDER - DEPENDENCIES)
2). Place the Rank System folder in your server's root directory (exact location as sapp.dll).

## CONFIGURATION:
All config settings can be edited in ./SDTM/settings.lua

]]

local RankSystem = {
    json = loadfile('./Rank System/Dependencies/Utils/Json.lua')(),
    dependencies = {
        ['./Rank System/'] = { 'settings' },
        ['./Rank System/Dependencies/Events/'] = {
            'Damage',
            'Death',
            'End',
            'Join',
            'On Score'
        },
        ['./Rank System/Dependencies/Utils/'] = {
            'Bonuses',
            'Load Stats',
            'Misc',
            'Update Rank'
        },
        ['./Rank System/Dependencies/Commands/'] = {
            'Change UP',
            'Create',
            'Login',
            'Logout',
            'Prestige',
            'Rank',
            'Rank List',
            'Set Rank',
            'Top List'
        }
    }
}

local function HasPermission(Ply, Lvl, Msg)
    local lvl = tonumber(get_var(Ply, '$lvl'))
    return (Ply == 0 or lvl >= Lvl) or rprint(Ply, Msg) and false
end

local cmds = {}
function RankSystem:LoadDependencies()

    local s = self
    for path, t in pairs(self.dependencies) do
        for _, file in pairs(t) do
            local f = loadfile(path .. file .. '.lua')()
            local cmd = f.command_name
            if (cmd) then
                cmds[cmd] = f -- command file
                cmds[cmd].permission = HasPermission
                setmetatable(cmds[cmd], { __index = self })
            else
                setmetatable(s, { __index = f })
                s = f
            end
        end
    end
end

function RankSystem:Init()

    self.ips = {}
    self.game_over = false
    self.delay_welcome = true
    self.first_blood = true
    self.gt = get_var(0, '$gt')
    self.map = get_var(0, '$map')
    self.ffa = (get_var(0, '$ffa') == '1')

    self:TagsToID()
    timer(5000, 'DelayWelcome')
end

local open = io.open
function RankSystem:Update()
    local file = open(self.dir, 'w')
    if (file) then
        file:write(self.json:encode_pretty(self.db))
        file:close()
    end
end

------------------------------------------------------------
--- [ SAPP FUNCTIONS ] ---
------------------------------------------------------------

function OnStart()
    if (get_var(0, '$gt') ~= 'n/a') then
        RankSystem:Init()
        for i = 1, 16 do
            if player_present(i) then
                OnJoin(i)
            end
        end
    end
end

function OnEnd()
    RankSystem:OnEnd()
end

function OnJoin(P)
    RankSystem:Join(P)
end

function OnQuit(P)
    RankSystem:GetPlayer(P).pid = nil -- important!
    RankSystem.ips[P] = nil
    if (RankSystem.update_file_database['OnQuit']) then
        RankSystem:Update()
    end
end

local function StrSplit(str)
    local t = { }
    for arg in str:gmatch("([^%s]+)") do
        t[#t + 1] = arg
    end
    return t
end

function OnCommand(P, Cmd)
    local args = StrSplit(Cmd)
    return (cmds[args[1]] and cmds[args[1]]:Run(P, args))
end

function OnDamage(V, K, M, _, H)
    RankSystem:OnDamage(V, K, M, _, H)
end

function OnDeath(V, K)
    RankSystem:OnDeath(V, K)
end

function OnSwitch(P)
    RankSystem:GetPlayer(P).team = get_var(P, '$team')
end

function OnSpawn(P)
    RankSystem:GetPlayer(P).avenge = {}
    RankSystem:GetPlayer(P).meta_id = 0
    RankSystem:GetPlayer(P).headshot = false
end

function OnScore(P)
    RankSystem:GetPlayer(P):OnScore()
end

function DelayWelcome()
    RankSystem.delay_welcome = false
    return false
end

function OnScriptLoad()

    RankSystem:LoadDependencies()

    local dir = read_string(read_dword(sig_scan('68??????008D54245468') + 0x1))
    RankSystem.dir = dir .. '\\sapp\\' .. RankSystem.file
    RankSystem.db = RankSystem:LoadStats()

    -- Register needed event callbacks:
    register_callback(cb['EVENT_DIE'], 'OnDeath')
    register_callback(cb['EVENT_JOIN'], 'OnJoin')
    register_callback(cb['EVENT_LEAVE'], 'OnQuit')
    register_callback(cb['EVENT_SCORE'], 'OnScore')
    register_callback(cb['EVENT_SPAWN'], 'OnSpawn')
    register_callback(cb['EVENT_GAME_END'], 'OnEnd')
    register_callback(cb['EVENT_COMMAND'], 'OnCommand')
    register_callback(cb['EVENT_GAME_START'], 'OnStart')
    register_callback(cb['EVENT_TEAM_SWITCH'], 'OnSwitch')
    register_callback(cb['EVENT_DAMAGE_APPLICATION'], 'OnDamage')

    OnStart()
end

function OnScriptUnload()
    -- N/A
end

api_version = '1.12.0.0'