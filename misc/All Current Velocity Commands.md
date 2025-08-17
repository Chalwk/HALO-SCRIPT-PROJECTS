#### Command Count: 41<br/><br/><br/><br/>

## Admin Chat:
`/achat on|off|status|-s [me | id */all]`
> 'status' or '-s' tells you whether the target's achat is enabled/disabled.
- - - -

## Alias System:
`/alias [me | id] [page id]`
> If you don't specify a page ID it will show you page 1 by default.
- - - -

## Auto Message:
`/broadcast [announcement id]`<br/>
`/broadcast [list]`
> 'status' or '-s' tells you whether the target's achat is enabled/disabled.
- - - -

## Block Object Pickup:
`/block [me | id | */all]`<br/>
`/unblock [me | id | */all]`
> Prevents players from picking up objects.
- - - -

## Color Changer:
`/setcolor [color id] [me | id | */all]`<br/>
> Change any player's armor color on demand.
- - - -

## Cute:
`/cute [id */all]`
> You cannot execute this command on yourself.
- - - -

## Enter Vehicle:
`/enter [item] [me | id | */all] (optional: height/distance)`
> Optional Flags: 'height' = height from ground, 'distance' = distance from player.<br/>
> You can optionally specify how high off the ground the object spawns, and the distance it spawns from the player's standing position.
- - - -

## Get Coords:
`/gc [me | id | */all]`
> Use this command to retrieve the current x,y,z coordinates of the target player.
- - - -

## Give:
`/give [item] [me | id | */all]`
> Give yourself (or others) weapons and powerups.
- - - -

## Infinity Ammo:
`/infammo [me | id | */all] [multiplier or off] ( optional: {flag} )`
> You can optionally execute this command silently for other players by specifying the '-s' command parameter.
- - - -

## Item Spawner:
`/spawn [item] [me | id | */all] [amount]`<br/>
`/itemlist`
> `/itemlist` shows a list of valid items for the current map.
- - - -

## Lurker:
`/lurker on|off [me | id | */all] <flag>`
> If Player ID parameter ([me | id | */all]) is not specified, Lurker will default to the executor.<br/>
> Command flags: '-c', '-h' and '-ch'.<br/>
> If '-c' (short for camouflage) command parameter is specified, you will only have camo!<br/>
> If '-h' (short for hidden) command parameter is specified, you will only be hidden!<br/>
> If '-ch' (short for camouflage + hidden) command parameter is specified, you will be both hidden and camouflaged!<br/>
> If neither are specified, the script will revert to default settings.
- - - -

## Mute System:
`/mute [id | */all] ( optional: [time diff] )`
> If `[time diff]` parameter is not specified, the player will be muted permanently.<br/><br/>

`/unmute [id | */all]`<br/>
`/mutelist ( optional: {flag} )`<br/>

> If you specify the '-o' flag, this command will only show you muted players who are currently online.<br/>
> Note: You cannot execute `/mute` or `/unmute` on yourself.
- - - -

## Player List (4 command aliases):
`/pl, players, playerlist, playeslist`
- - - -

## Portal Gun:
`/portalgun on|off [me | id | */all]`
> If `on|off` parameter is not specified, it will show you the target's current portalgun setting (enabled/disabled).
- - - -

## Private Messaging System:
`/pm [id | ip] {message}`<br/>
`/readmail [page id]`<br/>
`/delpm [#mail id | */all]`
> FYI: The `[#mail id]` is inserted 'before' the senders name on the `/readmail page`.
- - - -

## Respawn Time:
`/setrespawn [me | id | */all] [time diff]`
> If `[time diff]` parameter is not specified, it will show you the target's current respawn time setting.
- - - -

## Respawn:
`/respawn [me | id | */all]`
> Respawn yourself or others on demand (no death penalty incurred).
- - - -

## Special Commands:
`/plugins [page id]`<br/>
`/enable [id]`<br/>
`/disable [id]`
> "/plugins [page id]" will show you a list of all individual features and tells you which ones are enabled or disabled.

> You can enable or disable any feature at any time with /enable [id], /disable [id].

`/clean [me | id | */all] 1` > (cleans up "Enter Vehicle" objects)<br/>
`/clean [me | id | */all] 2` > (cleans up "Item Spawner" objects)<br/>
`/clean [me | id | */all] *` > (cleans up "everything")<br/>

`/velocity`
> If update checking is disabled this command will only display the current version.<br/>
> If update checking is enabled this command will send an http query to the gitpage for Velocity and tell you if an update is available. (returns current version of both version match)

`/clear`
> Clears the chat (useful if someone says something negative or derogatory)
- - - -

## Suggestion Box:
`/suggestion {message}`
> Players can suggest features or maps (or report bugs) with this command.
- - - -

## Teleport Manager:
`/setwarp <<warp name>>`<br/>
`/warp <<warp name>>`<br/>
`/back`<br/>
`/warplist`<br/>
`/warplistall`<br/>
`/delwarp [warp id]`
- - - -
