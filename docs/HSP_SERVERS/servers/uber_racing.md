# HSP-Uber Racing

## How to Connect

* 🔗 **IP Address:** jericraft.net:2314
* **Client:** Halo Custom Edition

---

## Overview

The **Uber Racing** experience combines intense team-based racing with advanced scripting systems. It's not just about
being the fastest driver, it's about teamwork, strategy, and leveraging the unique "Uber" system to get your entire team
across the finish line.

### Key Features

* **On-Demand Vehicle Spawning:** Type keywords like `hog` or `rhog` in chat to instantly spawn a vehicle in front of
  you and automatically enter the driver's seat.
* **The Uber System:** Use chat commands like `uber` or `taxi` to instantly join a teammate's vehicle. Perfect for
  recovering from wipeouts or coordinating team movements.
* **Advanced Lap Tracking:** The system tracks lap times, validates laps (with minimum time and driver-seat
  requirements), and maintains personal bests and all-time map records.
* **Global Rankings:** A weighted point system ranks players across all maps based on map records, global records,
  performance relative to records, and top finishes.
* **Massive Vehicle Whitelist:** Supports a huge variety of custom vehicles from countless maps, all configured with
  proper seat priorities (Driver, Gunner, Passenger).
* **Team-Based Strategy:** Work with your team to create convoys. Gunners defend against opponents while drivers focus
  on racing. The Uber system makes coordination effortless.
* **Smart Vehicle Management:** Empty vehicles automatically despawn after a delay to maintain map cleanliness and
  performance.
* **In-Game Commands:** Use `stats`, `top`, and `global` commands to view personal bests, map records, and global
  rankings.

---

## Maps and Lap Numbers

- timberland - laps 10
- [Gauntlet_Race](https://maps.halonet.net/maps/Gauntlet_Race.zip) - laps 10
- [mercury_falling](https://maps.halonet.net/maps/mercury_falling.zip) - laps 8
- [LostCove_Race](https://maps.halonet.net/maps/LostCove_Race.zip) - laps 8
- [Camtrack-Arena-Race](https://maps.halonet.net/maps/Camtrack-Arena-Race.zip) - laps 16
- [hypothermia_race](https://maps.halonet.net/maps/hypothermia_race.zip) - laps 10
- [Massacre_Mountain_Race](https://maps.halonet.net/maps/Massacre_Mountain_Race.zip) - laps 8
- [Mongoose_Point](https://maps.halonet.net/maps/Mongoose_Point.zip) - laps 16
- [bc_raceway_final_mp](https://maps.halonet.net/maps/bc_raceway_final_mp.zip) - laps 8
- [islandthunder_race](https://maps.halonet.net/maps/islandthunder_race.zip) - laps 12
- [Cityscape-Adrenaline](https://maps.halonet.net/maps/Cityscape-Adrenaline.zip) - laps 10
- [cliffhanger](https://maps.halonet.net/maps/cliffhanger.zip) - laps 12
- [New_Mombasa_Race_v2](https://maps.halonet.net/maps/New_Mombasa_Race_v2.zip) - laps 6
- [mystic_mod](https://maps.halonet.net/maps/mystic_mod.zip) - laps 10
- [luigi_raceway](https://maps.halonet.net/maps/luigi_raceway.zip) - laps 16
- [dessication_pb1](https://maps.halonet.net/maps/dessication_pb1.zip) - laps 12
- [equinox_v2](https://maps.halonet.net/maps/equinox_v2.zip) - laps 8
- [Nervous_King](https://maps.halonet.net/maps/Nervous_King.zip) - laps 6
- [Prime_C3_Race](https://maps.halonet.net/maps/Prime_C3_Race.zip) - laps 10
- [TLSstronghold](https://maps.halonet.net/maps/TLSstronghold.zip) - laps 14
- [wpitest1_race](https://maps.halonet.net/maps/wpitest1_race.zip) - laps 14

---

## Advanced Features

### Lap Tracking System

- Validates laps based on minimum time requirements and driver-seat verification
- Records personal bests per player and maintains all-time map records
- Calculates detailed statistics: laps completed, best lap, average lap time
- Announces new personal bests and map records in-game

### Global Ranking System

- Uses a weighted point system to rank players across all maps
- Awards points for:
    - Holding map records (`200`)
    - Holding global best lap (`300`)
    - Performance relative to map record (`50`)
    - Top finishes (within 95% of record time)
- Applies participation penalties for players with few maps played
- Uses tiebreakers: map records > global record > top finishes

### Vehicle System Enhancements

- **Configurable Vehicle Whitelist:** Extensive list of supported vehicles with proper seat configuration
- **Smart Seat Assignment:** Follows insertion order priority for each vehicle type
- **Team-Based Functionality:** Only works with teammates' vehicles
- **Accept/Reject System:** Drivers can accept or decline Uber requests (configurable)
- **Proximity-Based Calls:** Optional radius limit for Uber calls
- **Objective Carrier Restrictions:** Prevents Uber calls while carrying flags or oddballs
- **Automatic Ejection:** Removes players from invalid vehicles or vehicles without drivers

### In-Game Commands

- `stats` - Show your personal best on current map
- `top [N]` - Display top N laps for current map (default: 5)
- `global [N]` - Display top N overall players across all maps (default: 5)

---

## Important Notes

1. Only laps completed as the driver count toward records
2. There's a minimum lap time requirement to prevent abuse
3. Uber calls only work with teammates' vehicles
4. You may be ejected from vehicles that lose their driver
5. Objective carriers cannot call Ubers
6. Use the ranking commands to track your progress across all maps