# List of all Sapp Commands (by level)

> ### Public Commands:
* whatsnext
* usage <command name>
* unstfu
* stats
* stfu
* sv_stats
* report [message]
* info
* lead [boolean]
* list [generic/player/custom]
* login <password>
* clead [milliseconds(0-999)]
* about

> ### Level 0 Commands:
* uptime
* kdr <player expression>
* mapcycle
* change_password <old password> <new password>
* admindel <admin id>
* adminadd <player expression> <level(0-4)> [ip-ranges(<ip>/<mask>)]...
* afk

> ### Level 1 Commands:
* skips
* aimbot_scores

> ### Level 2 Commands:
* say <player expression> <message>
* tell <message>...
* mute <player expression> [minutes(=0)]
* mutes
* k <player expression> [reason]
* afks
* balance_teams
* pl
* st <player expression> [red/blue]
* teamup
* textban <player expression> [minutes(=0)]
* textbans
* textunban <text ban index>
* unmute <mute index>

> ### Level 3 Commands:
* ub <ban index>
* inf <player expression>
* ip <player expression>
* ipban <player expression> [reason]
* ipban <player expression> <minutes> <reason>
* ipban <player expression> <reason> <minutes>
* ipbans
* ipunban <ip ban index>
* map <map> <gametype>
* refresh_ipbans
* maplist
* b <player expression> [reason] [time]
* bans

> ### Level 4 Commands:
* admin_add <player expression> <password> <admin level(0-4)>
* admin_add_manually <username(1-11)> <password> <admin level(0-4)>
* admin_change_level <admin id> <admin level(0-4)>
* admin_change_pw <admin id> <new password>
* admin_del <admin id>
* admin_list
* admin_prefix [prefix]
* adminadd_samelevel [value(0-2)]
* adminban [value(0-2)]
* admindel_samelevel [value(0-2)]
* adminlevel <admin id> <new admin level(0-4)>
* admins
* afk_kick [seconds(0 or 60-86400)]
* aimbot_ban [score(0 or 5000-20000)] [ban type(=1, 0-4)] [ban length in minutes(=1440)]
* alias <player expression>
* ammo <player expression> <amount> [weapon index(=0, 0-5)]
* anticamp [seconds(0 or 10+)] [world units(=5)]
* anticaps [boolean]
* anticheat [boolean]
* antiglitch [boolean]
* antihalofp [boolean]
* antilagspawn [boolean]
* antispam [value(0-2)]
* antiwarp [warps(0 or 3+)]
* area_add_cuboid <area name> <Ax> <Ay> <Az> <Bx> <By> <Bz>
* area_add_sphere <area name> <x> <y> <z> <radius>
* area_del <area name>
* area_list
* area_listall
* assists <player expression> [assists]
* auto_update [boolean]
* ayy lmao
* battery <player expression> <amount(%)> [weapon index(=0, 0-5)]
* beep [hertz(=1000)] [milliseconds(=1000)]
* block_all_objects <player expression> <block(0-1)>
* block_all_vehicles <player expression> <block(0-1)>
* block_object <player expression> <object name with path>
* block_tc [boolean]
* boost <player expression>
* camo <player expression> [duration(=0)]
* cevent <event name> [player index(1-16)]
* chat_console_echo [boolean]
* cmd_add <command name> [#arguments]... <command sequence> [level(=4, -1-4)]
* cmd_del <command name>
* cmdstart1 [character]
* cmdstart2 [character]
* collect_aliases [boolean] [only valid(=1, boolean)]
* color <player expression> [color index]
* console_input [boolean]
* coord <player expression>
* cpu
* custom_sleep [ms(0-33)]
* d <player expression>
* deaths <player expression> [deaths]
* debug_strings [boolean]
* disable_all_objects <team(0-2)> <disable(0-1)>
* disable_all_vehicles <team(0-2)> <disable(0-1)>
* disable_backtap [boolean]
* disable_object <object name with path> [team(0-2)]
* disable_timer_offsets [boolean]
* disabled_objects
* dns [dns string]
* enable_object <object name with path> [team(0-2)]
* enable_object <object id> [team(0-2)]
* eventdel <event id>
* events
* files
* full_ipban [boolean]
* gamespeed [value]
* god <player expression>
* gravity [value]
* hide_admin [boolean]
* hill_timer [seconds]
* hp <player expression> [health]
* iprangeban <name> <ip/mask> [reason] [minutes]
* kill <player expression>
* kills <player expression> [kills]
* lag <player expression>
* loc_add <location name> [x] [y] [z]
* loc_del <location name>
* loc_list
* loc_listall
* log [boolean]
* log_name [file name]
* log_note <message>
* log_rotation [kb(0 or 1024+)]
* lua [boolean]
* lua_api_v
* lua_call <script name> <function name> [arguments]...
* lua_list
* lua_load <script name>
* lua_unload <script name>
* m <player expression> <x> <y> <z>
* mag <player expression> <amount> [weapon index(=0, 0-5)]
* map_download <map id>
* map_load <map name>
* map_next
* map_prev
* map_query <part of map name(3+)>
* map_skip [value(%, 0-100)]
* map_spec <mapcycle index>
* mapcycle_add <map> <gametype> [min players(=0, 0-16)] [max players(= 16, 0-16)] [position]
* mapcycle_begin
* mapcycle_del <mapcycle index>
* mapvote [boolean]
* mapvote_add <map> <gametype> <description> [min players(=0, 0-16)] [max players(=16, 0-16)] [position]
* mapvote_begin
* mapvote_del <mapvote index>
* mapvotes
* max_idle [seconds]
* max_votes [votes to display(1+)]
* motd [message]
* msg_prefix [prefix]
* mtv [boolean]
* nades <player expression> [amount] [type(=0, 0-2)]
* network_thread [boolean]
* no_lead [boolean]
* object_sync_cleanup [boolean]
* packet_limit [value(0 or 250+)]
* ping_kick [ms(0 or 150-999)]
* query_add <key> <value>
* query_del <query name>
* query_del <query index>
* query_list
* reload
* reload_gametypes
* remote_console [boolean]
* remote_console_list
* remote_console_port [port(1-65535)]
* rprint <player expression> <message>
* s <player expression> [speed]
* sapp_console [boolean]
* sapp_mapcycle [boolean]
* sapp_rcon [boolean]
* save_respawn_time [boolean]
* save_scores [boolean]
* say_prefix [boolean]
* score <player expression> [score]
* scorelimit [score]
* scrim_mode [boolean]
* set_ccolor [color]
* setadmin <player expression> <level(-1-4)>
* setcmd <command name> <new name>
* setcmd <command name> <new level(-1-4)>
* sh <player expression> [shield]
* sj_level [level(-1-5)]
* spawn <tag type> <tag name> [player index] [rotation]
* spawn <tag type> <tag name> [location name] [rotation]
* spawn <tag type> <tag name> [<x> <y> <z>] [rotation]
* spawn_protection [seconds(0-10)]
* t <player expression> <location name>
* t <player expression> <x> <y> <z>
* team_score [team(0-2)] [score]
* team_score [red/blue/both] [score]
* text <message> [color]
* timelimit [minutes]
* tp <player expression> <player index>
* unblock_object <player expression> <object name with path>
* ungod <player expression>
* unlag <player expression>
* unlock_console_log [boolean]
* v [version string]
* var_add <name> <type(0-5)>
* var_conv <name>
* var_del <name>
* var_list [custom]
* var_set <name> <value> [player index(=0, 0-16)]
* vdel <player expression>
* vdel_all
* venter <player expression> [seat(=0)]
* vexit <player expression>
* wadd <player expression>
* wdel <player expression> [weapon index(=5, 0-5)]
* wdrop <player expression>
* yeye
* zombies [value(0-2)]
