local spoils = {}
local insert, random, clock = table.insert, math.random, os.clock
local execute_command, spawn_object, assign_weapon, read_float, write_float =
    execute_command, spawn_object, assign_weapon, read_float, write_float

-- ========== Bonus Lives ==========
function spoils.bonus_lives(player, _, CFG)
    player.lives = (player.lives or 0) + 1
    CFG:send(player.id, "Received bonus life!")
    return true
end

-- ========== Random Weapons ==========
function spoils.random_weapons(player, spoil, CFG)
    local weapon_names = {}
    for name in pairs(spoil.random_weapons) do
        insert(weapon_names, name)
    end

    local weapon_name = weapon_names[random(#weapon_names)]
    local weapon_path = spoil.random_weapons[weapon_name]

    local inventory = CFG.get_inventory(player.dyn_player)
    if #inventory >= 4 then
        CFG.cls(player.id)
        CFG:send(player.id, "Attempted to receive %s, but you're already full!", weapon_name)
        return false
    end

    local meta_id = CFG.get_tag('weap', weapon_path)
    if not meta_id then
        CFG:send(player.id, "This crate was a dud!")
        error("Invalid weapon tag: " .. weapon_path, 2)
        return false
    end

    local weapon = spawn_object('', '', 0, 0, 0, 0, meta_id)
    assign_weapon(weapon, player.id)
    CFG:send(player.id, "Received %s!", weapon_name)
    return true
end

-- ========== Speed Boosts ==========
function spoils.speed_boosts(player, spoil, CFG)
    local boost = spoil.speed_boosts[random(#spoil.speed_boosts)]
    local mult, duration = boost[1], boost[2]

    CFG.player_effects[player.id] = CFG.player_effects[player.id] or {}
    insert(CFG.player_effects[player.id], {
        effect = "speed",
        multiplier = mult,
        expires = clock() + duration
    })

    execute_command("s " .. player.id .. " " .. mult)
    CFG:send(player.id, "%.2fX speed boost for %d seconds!", mult, duration)
    return true
end

-- ========== Grenades ==========
function spoils.grenades(player, spoil, CFG)
    local frags, plasmas = spoil.grenades[1], spoil.grenades[2]
    execute_command("nades " .. player.id .. " " .. frags .. " 1")
    execute_command("nades " .. player.id .. " " .. plasmas .. " 2")
    CFG:send(player.id, "Received %d frags, %d plasmas!", frags, plasmas)
    return true
end

-- ========== Camouflage ==========
function spoils.camouflage(player, spoil, CFG)
    local duration = spoil.camouflage[random(#spoil.camouflage)]


    CFG.player_effects[player.id] = CFG.player_effects[player.id] or {}
    insert(CFG.player_effects[player.id], {
        effect = "camouflage",
        expires = clock() + duration
    })

    execute_command("camo " .. player.id .. " " .. duration)
    CFG:send(player.id, "Received camouflage for %d seconds!", duration)
    return true
end

-- ========== Overshield ==========
function spoils.overshield_boosts(player, spoil, CFG)
    local level = spoil.overshield_boosts[random(#spoil.overshield_boosts)]
    execute_command("sh " .. player.id .. " " .. level)
    CFG:send(player.id, "Received %dX overshield!", level)
    return true
end

-- ========== Health ==========
function spoils.health_boosts(player, spoil, CFG)
    local bonus = spoil.health_boosts[random(#spoil.health_boosts)]
    local current = read_float(player.dyn_player + 0xE0)

    if not current then
        CFG:send(player.id, "Failed to read health!")
        return false
    end

    write_float(player.dyn_player + 0xE0, current + bonus)
    CFG:send(player.id, "Received +%.2f health!", bonus)
    return true
end

return spoils
