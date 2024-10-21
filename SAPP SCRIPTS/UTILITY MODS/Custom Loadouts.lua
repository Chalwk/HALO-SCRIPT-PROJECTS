--[[
--=====================================================================================================--
Script Name: Custom Loadouts, for SAPP (PC & CE)
Description:

    This script allows players to switch between pre-defined loadouts.
    Players can select a loadout by typing `/1`, `/2`, etc., where the number corresponds to the loadout's unique `id`.
    Each loadout consists of different weapon configurations, with options for varying numbers of
    weapons (ranging from 1 to 4), as well as different amounts of frag and plasma grenades.
    The loadout will be applied when the player respawns.

Key Features:
    - Customizable loadouts (1-4 weapons per loadout)
    - Unique loadout IDs for selection (/ID)
    - Frag and plasma grenade customization
    - Weapon clip and ammo specifications for each weapon
    - Real-time switching between loadouts using in-game commands

Copyright (c) 2024, Jericho Crosby <jericho.crosby227@gmail.com>
* Notice: You can use this document subject to the following conditions:
https://github.com/Chalwk/HALO-SCRIPT-PROJECTS/blob/master/LICENSE
--=====================================================================================================--
]]--

--[[
--------------------------------- Documentation of Loadout Settings ----------------------------------

Each loadout is defined with the following properties:

    id: [integer] - A unique ID that players use to select the loadout (e.g., `/1` for ID 1).

    frags: [integer] - Number of frag grenades given to the player.

    plasmas: [integer] - Number of plasma grenades given to the player.

    weapons: [table] - A list of weapon tags assigned to the player. Each weapon has:
        label: [string] - The weapon's display name.
        clip: [integer] - The number of bullets per clip (for the weapon).
        ammo: [integer] - The total ammo carried for the weapon (outside of the clip).

Weapon tags are stored in a table at the beginning of the script. Each loadout references these tags when assigning weapons.

-----------------------------------------------------------------------------------------------------
]]

-- config starts
local weapon_tags = {
    pistol = 'weapons\\pistol\\pistol',
    sniper_rifle = 'weapons\\sniper rifle\\sniper rifle',
    plasma_cannon = 'weapons\\plasma_cannon\\plasma_cannon',
    rocket_launcher = 'weapons\\rocket launcher\\rocket launcher',
    plasma_pistol = 'weapons\\plasma pistol\\plasma pistol',
    plasma_rifle = 'weapons\\plasma rifle\\plasma rifle',
    assault_rifle = 'weapons\\assault rifle\\assault rifle',
    flamethrower = 'weapons\\flamethrower\\flamethrower',
    needler = 'weapons\\needler\\mp_needler',
    shotgun = 'weapons\\shotgun\\shotgun'
}

local loadouts = {

    -- Default Loadout (don't modify the name of this one)
    default = {
        id = 1,
        frags = 1,
        plasmas = 3,
        weapons = {
            [weapon_tags.assault_rifle] = {
                label = 'Assault Rifle',
                clip = 60,
                ammo = 120
            },
            [weapon_tags.pistol] = {
                label = 'Pistol',
                clip = 12,
                ammo = 48
            }
        }
    },

    LoneWolf = {
        id = 2,
        frags = 0,
        plasmas = 0,
        weapons = {
            [weapon_tags.sniper_rifle] = {
                label = 'Sniper Rifle',
                clip = 4,
                ammo = 8
            }
        }
    },

    ShottySnipes = {
        id = 3,
        frags = 0,
        plasmas = 0,
        weapons = {
            [weapon_tags.shotgun] = {
                label = 'Shotgun',
                clip = 12,
                ammo = 24
            },
            [weapon_tags.sniper_rifle] = {
                label = 'Sniper Rifle',
                clip = 4,
                ammo = 8
            }
        }
    },

    HeavyOrdnance = {
        id = 4,
        frags = 2,
        plasmas = 0,
        weapons = {
            [weapon_tags.rocket_launcher] = {
                label = 'Rocket Launcher',
                clip = 2,
                ammo = 4
            },
            [weapon_tags.plasma_cannon] = {
                label = 'Plasma Cannon',
                clip = 100,
                ammo = 200
            },
            [weapon_tags.pistol] = {
                label = 'Pistol',
                clip = 12,
                ammo = 48
            }
        }
    },

    TacticalOverload = {
        id = 5,
        frags = 1,
        plasmas = 1,
        weapons = {
            [weapon_tags.sniper_rifle] = {
                label = 'Sniper Rifle',
                clip = 4,
                ammo = 8
            },
            [weapon_tags.assault_rifle] = {
                label = 'Assault Rifle',
                clip = 60,
                ammo = 120
            },
            [weapon_tags.plasma_pistol] = {
                label = 'Plasma Pistol',
                clip = 100,
                ammo = 200
            },
            [weapon_tags.shotgun] = {
                label = 'Shotgun',
                clip = 12,
                ammo = 24
            }
        }
    },

    BreachAndClear = {
        id = 6,
        frags = 2,
        plasmas = 0,
        weapons = {
            [weapon_tags.shotgun] = {
                label = 'Shotgun',
                clip = 12,
                ammo = 24
            },
            [weapon_tags.rocket_launcher] = {
                label = 'Rocket Launcher',
                clip = 2,
                ammo = 4
            }
        }
    },

    Marksman = {
        id = 7,
        frags = 1,
        plasmas = 1,
        weapons = {
            [weapon_tags.assault_rifle] = {
                label = 'Assault Rifle',
                clip = 60,
                ammo = 120,
            },
            [weapon_tags.pistol] = {
                label = 'Pistol',
                clip = 12,
                ammo = 48
            },
            [weapon_tags.sniper_rifle] = {
                label = 'Sniper Rifle',
                clip = 30,
                ammo = 60
            }
        }
    },

    InfernoNeedler = {
        id = 8,
        frags = 0,
        plasmas = 2,
        weapons = {
            [weapon_tags.flamethrower] = {
                label = 'Flamethrower',
                clip = 100,
                ammo = 200
            },
            [weapon_tags.needler] = {
                label = 'Needler',
                clip = 30,
                ammo = 60
            },
            [weapon_tags.pistol] = {
                label = 'Pistol',
                clip = 12,
                ammo = 48
            },
            [weapon_tags.plasma_rifle] = {
                label = 'Plasma Rifle',
                clip = 100,
                ammo = 200
            }
        }
    },
    PlasmaFury = {
        id = 9,
        frags = 0,
        plasmas = 2,
        weapons = {
            [weapon_tags.plasma_rifle] = {
                label = 'Plasma Rifle',
                clip = 100,
                ammo = 200
            },
            [weapon_tags.plasma_pistol] = {
                label = 'Plasma Pistol',
                clip = 100,
                ammo = 200
            }
        }
    },

    Longshot = {
        id = 10,
        frags = 0,
        plasmas = 0,
        weapons = {
            [weapon_tags.sniper_rifle] = {
                label = 'Sniper Rifle',
                clip = 4,
                ammo = 8
            },
            [weapon_tags.needler] = {
                label = 'Needler',
                clip = 30,
                ammo = 60
            },
            [weapon_tags.pistol] = {
                label = 'Pistol',
                clip = 12,
                ammo = 48
            }
        }
    }
}

-- config ends

local players = {}

api_version = '1.12.0.0'

local function getTag(...)
    local tag = lookup_tag(...)
    return tag ~= 0 and read_dword(tag + 0xC) or nil
end

function OnScriptLoad()
    register_callback(cb['EVENT_JOIN'], 'OnJoin')
    register_callback(cb['EVENT_LEAVE'], 'OnQuit')
    register_callback(cb['EVENT_DIE'], 'OnDeath')
    register_callback(cb['EVENT_SPAWN'], 'OnSpawn')
    register_callback(cb['EVENT_COMMAND'], 'OnCommand')
    register_callback(cb['EVENT_GAME_START'], 'OnStart')

    OnStart()
end

function OnStart()
    if get_var(0, '$gt') ~= 'n/a' then
        for i = 1,16 do
            if player_present(i) then
                OnJoin(i)
            end
        end
    end
end

function assignWeapon(playerId, weapon)
    assign_weapon(weapon, playerId)
end

local function setGrenades(dynamic_player, grenade_type, amount)
    write_byte(dynamic_player + (grenade_type == 1 and 0x31E or 0x31F), amount)
end

local function AssignWeapons(playerId)

    local dynamic_player = get_dynamic_player(playerId)
    if (dynamic_player == 0) then
        return
    end

    execute_command('wdel ' .. playerId)

    local current_loadout = players[playerId].inventory.current_loadout
    local weapons = loadouts[current_loadout].weapons
    local frags = loadouts[current_loadout].frags
    local plasmas = loadouts[current_loadout].plasmas

    local slot = 0

    for weapon_tag, attributes in pairs(weapons) do
        local tag = getTag('weap', weapon_tag)

        if not tag then
            goto next
        end

        local weapon = spawn_object('', '', 0, 0, 0, 0, tag)
        local weapon_object_memory = get_object_memory(weapon)

        if weapon_object_memory ~= 0 then
            slot = slot + 1
            write_word(weapon_object_memory + 0x2B6, attributes.ammo)
            write_word(weapon_object_memory + 0x2B8, attributes.clip)
            sync_ammo(weapon)

            if slot <= 2 then
                assignWeapon(playerId, weapon) -- Primary and secondary weapons
            else
                timer(250, 'assignWeapon', playerId, weapon) -- Tertiary and quaternary weapons must have a delay
            end
        end
        :: next ::
    end

    setGrenades(dynamic_player, 1, frags)
    setGrenades(dynamic_player, 2, plasmas)
end

function OnSpawn(playerId)
    AssignWeapons(playerId)
end

function OnJoin(playerId)
    players[playerId] = {
        inventory = {
            current_loadout = 'default'
        }
    }
end

function OnQuit(playerId)
    players[playerId] = nil
end

local function getLoadouts()
    local options = {}
    for _, loadout in pairs(loadouts) do
        local option = "[" .. loadout.id .. "]: "
        for _, weapon in pairs(loadout.weapons) do
            option = option .. weapon.label .. ", "
        end
        option = option:sub(1, -3) .. " | Frags: " .. loadout.frags .. ", Plasmas: " .. loadout.plasmas
        table.insert(options, option)
    end
    table.sort(options)
    return options
end

local function showLoadouts(playerId)
    local loadout_options = getLoadouts()
    rprint(playerId, "Select a loadout: Use /[id]")
    for _, option in ipairs(loadout_options) do
        rprint(playerId, option)
    end
end

function OnCommand(playerId, command)
    local command_num = tonumber(command:match("^(%d+)"))
    if command_num then
        for loadout_name, loadout in pairs(loadouts) do
            if loadout.id == command_num then
                players[playerId].inventory.current_loadout = loadout_name
                rprint(playerId, "Loadout [" .. loadout_name .. "] selected! It will take effect upon respawn.")
                return false
            end
        end
        rprint(playerId, "Invalid loadout number!")
    elseif command:lower() == "loadouts" then
        showLoadouts(playerId)
        return false
    end
end


function OnDeath(playerId)
    showLoadouts(playerId)
end

function OnScriptUnload()
    -- N/A
end