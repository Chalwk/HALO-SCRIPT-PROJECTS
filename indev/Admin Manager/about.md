## Last Updated: 05/09/23 @ 09:24 (NZST)

---

This plugin is a drop-in replacement for SAPP's built-in admin system and adds new features:


> <ins>**Custom admins levels:**

- You can add as many admin levels as you want (currently configured with 6).
- Configure each level to have access to any command you want.
- Admin levels follow a hierarchy system. If you add an admin by IP and Hash, the admin level will be the highest of the
  two.
- Players will inherit commands from the admin levels below their own.

---
> <ins>**Authentication:**

- Add admins by <ins>IP</ins>, <ins>Hash</ins> or <ins>Username & Password</ins>.
- Passwords and usernames are case-sensitive but may contain spaces.
- Passwords are hashed with SHA-256.

---
> <ins>**Custom Ban Commands:**

- IP-ban, hash-ban, text-ban and name-ban.
- You can text-ban by IP or Hash.
- You can name-ban by ID or name.

---
> <ins>**Command Spy:**

- Those with permission will see commands executed by other players.
- You can only see commands executed by players with a lower or equal admin level than your own.

---
> <ins>**VIP messages:**

- Customizable join messages for each admin level.

---
> <ins>**Admin Chat:**

- Chat with other admins in a private text channel.
- You can only see messages from admins with a lower or equal admin level than your own.

---
> <ins>**Alias System:**

- Lookup aliases by IP or Hash.

---

## <ins>Admin Manager Commands:

| Command                                                                                     | Description                                                         | Permission Level |
|---------------------------------------------------------------------------------------------|---------------------------------------------------------------------|------------------|
| **login** `<password>`                                                                      | Login with a password (username is your IGN)                        | **1**            |
| **logout**                                                                                  | Logout of the server                                                | **1**            |
| **admin_chat** `<1/0 (on/off)>`                                                             | Toggle admin chat on or off for yourself                            | **2**            |
| **change_password** `<old password>` `<"new password">`                                     | Change your own password                                            | **2**            |
| **ip_mute** `<player id>` `<flag (-y -mo -d -h -m -s -r "example reason")>`                 | Mute a player by IP                                                 | **3**            |
| **ip_unmute** `<ban id>`                                                                    | Unmute a player's IP                                                | **3**            |
| **ip_mutes** `<page>`                                                                       | List all muted players by IP                                        | **3**            |
| **hash_mute** `<player id>` `<flag (-y -mo -d -h -m -s -r "example reason")>`               | Mute a player by hash                                               | **3**            |
| **hash_unmute** `<ban id>`                                                                  | Unmute a player's hash                                              | **3**            |
| **hash_mutes** `<page>`                                                                     | List all muted players by hash                                      | **3**            |
| **spy** `<1/0 (on/off)>`                                                                    | Toggle command spy on or off for yourself                           | **3**            |
| **ip_alias** `<player/ip>` `<page>`                                                         | Lookup aliases by player id or ip                                   | **4**            |
| **hash_alias** `<player/hash>` `<page>`                                                     | Lookup aliases by player id or hash                                 | **4**            |
| **ip_ban** `<player id>` `<flag (-y -mo -d -h -m -s -r "example reason")>`                  | Ban a player by IP                                                  | **4**            |
| **ip_unban** `<ban id>`                                                                     | Unban a player's IP                                                 | **4**            |
| **ip_bans** `<page>`                                                                        | List all IP-bans                                                    | **4**            |
| **hash_admin_add** `<player id / -u "name">` `<-l level>` `<-h hash>`                       | Add player as a hash-admin                                          | **5**            |
| **hash_admin_delete** `<admin id>`                                                          | Remove player as a hash-admin                                       | **5**            |
| **hash_admins** `<page>`                                                                    | List all hash-admins                                                | **5**            |
| **ip_admin_add** `<player id / -u "name">` `<-l level>` `<-ip IP>`                          | Add player as an ip-admin                                           | **5**            | 
| **ip_admin_delete** `<admin id>`                                                            | Remove player as an ip-admin                                        | **5**            |
| **ip_admins** `<page>`                                                                      | List all ip-admins                                                  | **5**            |
| **hash_ban** `<player id>` `<flag (-y -mo -d -h -m -s -r "example reason")>`                | Ban a player by hash (requires confirmation if the hash is pirated) | **5**            |
| **hash_unban** `<ban id>`                                                                   | Unban a player's hash                                               | **5**            |
| **hash_bans** `<page>`                                                                      | List all hash-bans                                                  | **5**            |
| **name_ban** `<player id or name>`                                                          | Ban a players name by ID or name                                    | **5**            |
| **name_unban** `<ban id>`                                                                   | Unban a name                                                        | **5**            |
| **name_bans** `<page>`                                                                      | List all name bans                                                  | **5**            |
| **pw_admin_add** `<player id / -u "name">` `<-l level>` `<-p "password">`                   | Add player as a password-admin                                      | **5**            |
| **pw_admin_delete** `<admin id>`                                                            | Remove player as a password-admin                                   | **5**            |
| **pw_admins** `<page>`                                                                      | List all password-admins                                            | **5**            |
| **confirm**                                                                                 | Confirm level delete                                                | **5**            |
| **change_level** `<player id>` `<type (hash/ip/password)>`                                  | Change player admin level                                           | **6**            |
| **change_admin_password** `<player id>` `<"new password">`                                  | Change another player's password                                    | **6**            |
| **level_add** `<level>`                                                                     | Add an admin level                                                  | **6**            |
| **level_delete** `<level>`                                                                  | Delete an admin level (requires confirmation)                       | **6**            |
| **disable_command** `<command>`                                                             | Disables a command                                                  | **6**            |
| **enable_command** `<command>`                                                              | Enables a command                                                   | **6**            |
| **set_command** `<command>` `<level>` `(opt 3rd arg: "true" to enable, "false" to disable)` | Add or set a new/existing command to a new level                    | **6**            |

### <ins>Getting started:

Before you can add members of your clan/community as admins, you must first add yourself as an admin.<br>
Access to the server terminal is required to do this (one-time only).<br>
This can be done by following this procedure:

- Join the server.
- Execute one of the admin-add commands (*hash_admin_add*, *ip_admin_add*, *pw_admin_add*) from the server console.<br>

Examples:

- `/hash_admin_add` `1` `-l 6`
    - This will add player 1 as a hash-admin with admin level 6.<br><br>

- `/hash_admin_add` `-u "the Juan"` `-l 5` `-h 073949b8eb4c822cc71dbd3965009a2d`
    - This will add an offline player by the name `the Juan` as a hash-admin with admin level 5.<br>
      **Technical notes:**<br>
      The username must be encapsulated in quotes.<br>
      Do not encapsulate the hash.<br><br>

- `/ip_admin_add` `1` `-l 6`
    - This will add player 1 as an ip-admin with admin level 6.<br><br>

- `/ip_admin_add` `-u "daisy101"` `-l 2` `-ip 127.0.0.5`
    - This will add an offline player by the name `daisy101` as an ip-admin with admin level 2.<br>
      **Technical notes:**<br>
      The username must be encapsulated in quotes.<br>
      Do not encapsulate the IP.<br><br>

- `/pw_admin_add` `1` `-l 3` `-p "my password"`
    - This will add player 1 as a password-admin with admin level 3 and the password `my password`.<br>
      **Technical note:**<br>
      The password must be encapsulated in quotes.<br><br>

- `/pw_admin_add` `-u "thyme 2 die"` `-l 3` `-p "cheap as chips"`
    - This will add an offline player by the name `thyme 2 die` as a password-admin with admin level 3 and the password `cheap as chips`.<br>
      **Technical note:**<br>
      The username and password must be encapsulated in quotes.<br>
---

### <ins>Databases:

Admin Manager automatically creates a few files when the plugin is loaded.<br>
The files are used to store the admin database, bans, commands and aliases (all in JSON format).<br>
These files will be located in the *sapp* folder (the same directory as the Lua folder):

- **admins.json**
    - Can be edited manually, but it's recommended to use the plugin commands to manage admins.
- **commands.json**
    - Intended to be edited manually, but you can use the plugin commands to manage this.
- **bans.json**
    - Do not edit this file. Use the plugin commands to manage bans.
- **aliases.json**
    - Do not edit this file. Use the plugin commands to manage aliases.
- **logs.json**
    - Do not edit this file. This is used to store verbose logs about admin activity.

---

### <ins>Banning:

- Ban by: IP, Hash or Text.<br>
    - You can ban for a specific amount of time or permanently.
    - To ban for a specific amount of time, use the following flags:
        - `-y` `<number>` - Years
        - `-mo` `<number>` - Months
        - `-d` `<number>` - Days
        - `-h` `<number>` - Hours
        - `-m` `<number>` - Minutes
        - `-s` `<number>` - Seconds

Ban command examples:

- `/hash_ban` `1` `-y 1` `-mo 6` `-r "caught cheating"`
    - This will ban player 1 by hash for 1 year, 6 months with the reason "caught cheating".<br><br>

- `/hash_ban` `1`
    - This will ban player 1 by hash permanently.<br><br>

- `/ip_ban` `1` `-h 1` `-m 30` `-r "caught cheating"`
    - This will ban player 1 by IP for 1 hour, 30 minutes with the reason "caught cheating".<br><br>

- `/ip_ban` `1`
    - This will ban player 1 by IP permanently.<br><br>

- `/name_ban` `1` `-r "explicit name"`
    - This will blacklist player 1's name with the reason "explicit name".<br><br>

- `/name_ban` `penis`
    - This will blacklist the name "penis".<br><br>

- `/ip_mute` `1` `-m 10` `-r "spamming"`
    - This will text-ban player 1 by IP for 10 minutes with reason "spamming".<br><br>

- `/hash_mute` `1` `-d 5` `-r "constant swearing"`
    - This will text-ban player 1 by hash for 5 days with reason "spamming".

**TIP:**<br>
The order of the flags <ins>doesn't matter</ins>, but the player id <ins>must</ins> be the first argument.<br>

**Pirated Hashes:**<br>
> Shared CD Key hashes are detected automatically.<br>
> If a player has a shared CD Key hash, the admin will be informed<br>
> and will have to confirm the ban by typing */confirm*.<br>
> Otherwise, the action will time out after 10 seconds.

---

## <ins>Default Command Permissions:

The default command permission levels are as follows:

- 1: Public
- 2: Moderator
- 3: Admin
- 4: Senior Admin
- 5: Head Admin
- 6: Owner

Add your own custom levels in the `commands.json` file, or edit the existing ones.<br>
You can also add or remove levels using the `level_add` and `level_delete` commands.<br>
There is no limit to the number of levels you can add. Just make sure there is at least one level with the `1` key.<br>

If a command's value is set to `true`, then the command is enabled for that permission level.<br>

You can define custom commands in this file, and it will manage the required permission level for those commands.<br>

```json
{
  "1": {
    "clead": true,
    "info": true,
    "lead": true,
    "login": true,
    "logout": true,
    "stats": true,
    "stfu": true,
    "sv_stats": true,
    "unstfu": true,
    "whatsnext": true
  },
  "2": {
    "kdr": true,
    "mapcycle": true,
    "pl": true,
    "say": true
  },
  "3": {
    "afk": true,
    "afks": true,
    "aimbot_scores": true,
    "k": true,
    "skips": true
  },
  "4": {
    "balance_teams": true,
    "inf": true,
    "ip": true,
    "st": true,
    "tell": true,
    "uptime": true
  },
  "5": {
    "map": true,
    "maplist": true
  },
  "6": {
    "about": true,
    "admin_prefix": true,
    "afk_kick": true,
    "aimbot_ban": true,
    "ammo": true,
    "anticamp": true,
    "anticaps": true,
    "anticheat": true,
    "antiglitch": true,
    "antihalofp": true,
    "antilagspawn": true,
    "antispam": true,
    "antiwar": true,
    "area_add_cuboid": true,
    "area_add_sphere": true,
    "area_del": true,
    "area_list": true,
    "area_listall": true,
    "assists": true,
    "auto_update": true,
    "ayy lmao": true,
    "battery": true,
    "beep": true,
    "block_all_objects": true,
    "block_all_vehicles": true,
    "block_object": true,
    "block_tc": true,
    "boost": true,
    "camo": true,
    "cevent": true,
    "chat_console_echo": true,
    "cmd_add": true,
    "cmd_del": true,
    "cmdstart1": true,
    "cmdstart2": true,
    "color": true,
    "console_input": true,
    "coord": true,
    "cpu": true,
    "custom_sleep": true,
    "d": true,
    "deaths": true,
    "debug_strings": true,
    "disable_all_objects": true,
    "disable_all_vehicles": true,
    "disable_backtap": true,
    "disable_object": true,
    "disable_timer_offsets": true,
    "disabled_objects": true,
    "dns": true,
    "enable_object": true,
    "eventdel": true,
    "events": true,
    "files": true,
    "gamespeed": true,
    "god": true,
    "gravity": true,
    "hill_timer": true,
    "hp": true,
    "kill": true,
    "kills": true,
    "lag": true,
    "loc_add": true,
    "loc_del": true,
    "loc_list": true,
    "loc_listall": true,
    "log": true,
    "log_name": true,
    "log_note": true,
    "log_rotation": true,
    "lua": true,
    "lua_api_v": true,
    "lua_call": true,
    "lua_list": true,
    "lua_load": true,
    "lua_unload": true,
    "m": true,
    "mag": true,
    "map_download": true,
    "map_load": true,
    "map_next": true,
    "map_prev": true,
    "map_query": true,
    "map_skip": true,
    "map_spec": true,
    "mapcycle_add": true,
    "mapcycle_begin": true,
    "mapcycle_del": true,
    "mapvote": true,
    "mapvote_add": true,
    "mapvote_begin": true,
    "mapvote_del": true,
    "mapvotes": true,
    "max_idle": true,
    "max_votes": true,
    "motd": true,
    "msg_prefix": true,
    "mtv": true,
    "nades": true,
    "network_thread": true,
    "no_lead": true,
    "object_sync_cleanup": true,
    "packet_limit": true,
    "ping_kick": true,
    "query_add": true,
    "query_del": true,
    "query_list": true,
    "reload": true,
    "reload_gametypes": true,
    "remote_console": true,
    "remote_console_list": true,
    "remote_console_port": true,
    "report": true,
    "rprint": true,
    "s": true,
    "sapp_console": true,
    "sapp_mapcycle": true,
    "sapp_rcon": true,
    "save_respawn_time": true,
    "save_scores": true,
    "say_prefix": true,
    "score": true,
    "scorelimit": true,
    "scrim_mode": true,
    "set_ccolor": true,
    "setcmd": true,
    "sh": true,
    "sj_level": true,
    "spawn": true,
    "spawn_protection": true,
    "t": true,
    "team_score": true,
    "teamup": true,
    "text": true,
    "timelimit": true,
    "tp": true,
    "unblock_object": true,
    "ungod": true,
    "unlag": true,
    "unlock_console_log": true,
    "usage": true,
    "v": true,
    "var_add": true,
    "var_conv": true,
    "var_del": true,
    "var_list": true,
    "var_set": true,
    "vdel": true,
    "vdel_all": true,
    "venter": true,
    "vexit": true,
    "wadd": true,
    "wdel": true,
    "wdrop": true,
    "yeye": true,
    "zombies": true
  }
}
```

---

### ⚠️ WARNING ⚠️

> For this system to work, all players are given SAPP level 4.<br>
> In the rare event that this plugin crashes, all players will have unrestricted access to SAPP's commands.<br>
> **There are currently no known bugs or crashes with this plugin. Just something to note.**

# INSTALLATION:

The release zip contains:

- **Admin Manager.lua** (sapp script)
- **Admin Manager** (folder)

Note: You will need a file decompression tool like [WinRAR](https://www.win-rar.com/start.html?&L=0)
or [7-zip](https://www.7-zip.org/download.html) to extract the **Admin.Manager.zip** file (download at bottom of page).

Place the **Admin Manager.lua** script in the server *Lua folder*.
The **Admin Manager** folder MUST go in the server's root directory (the same location as *sapp.dll* & *strings.dll*).

### CONFIGURATION:

All configuration is done from within a file called **settings.lua**, located in the **Admin Manager** folder.