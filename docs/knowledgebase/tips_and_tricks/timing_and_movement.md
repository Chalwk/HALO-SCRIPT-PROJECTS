**Timing & Movement**

**Core tick rate**
Halo: Combat Evolved (PC / CE) simulates at **30 ticks per second**. Tick duration = **1 / 30 = 0.033333... s** (≈ 33.333 ms). Simulation logic and many recorded animations run tick-for-tick at 30Hz on CE.

**World unit conversion**
**1 World Unit (WU) = 10 feet = 3.048 meters.** Waypoints shown in-game are expressed in meters, so multiply WU by **3.048** to get metres.

**How to compute distances per tick**
• Tick seconds = **1 / 30**.
• Distance per tick (WU) = `velocity_wu_per_s * (1 / 30)`.
• Distance per tick (m) = `velocity_wu_per_s * (1 / 30) * 3.048`.
Use these to compute first-tick travel and effective "hitscan" ranges for projectiles.

**Where to get projectile speeds (CE PC)**
Projectile speed values for CE are stored in the projectile tag (HEK / Custom Edition). Look up the projectile tag's initial velocity field (the projectile tag's numeric initial velocity) using the HEK tools (Tool / Guerilla / Sapien or tag inspectors from the CE toolchain).

**Why first-tick distance matters**
CE simulates motion on discrete ticks. A projectile with initial velocity `V` (WU/s) will travel `V / 30` WU in its first tick. That first-tick travel often determines the range at which a projectile *feels* instant, so accurate scripting or lead calculations should use the projectile's tag value and the 1/30 tick.

---

**Scripter quick formulas**

```
-- CE constants
TICK_RATE = 30               -- ticks per second (CE)
TICK_SEC  = 1 / TICK_RATE    -- seconds per tick (~0.033333)
WU_TO_M = 3.048              -- metres per world unit

-- Given initial projectile velocity (from the CE projectile tag) in WU/s:
initial_wu_s = <read_from_projectile_tag> 

-- distance travelled in one tick
wu_per_tick = initial_wu_s * TICK_SEC
m_per_tick  = wu_per_tick * WU_TO_M
```

**Practical notes for CE server operators**
• Always read projectile initial velocities from the CE tag files used by your server build rather than copying values from MCC or community posts. HEK tag values are authoritative for CE.
• Small differences across community builds, patches, or ports can change projectile timing or behavior. Test on the exact CE executable and tagset your players use.
• If you want a short command to measure first-tick travel for a weapon, use the projectile tag initial velocity, divide by 30, and convert to metres with `* 3.048`. That gives you the first-tick distance to use for lead / hitscan approximations.

# Sources:

[Scripting - c20](https://c20.reclaimers.net/h1/scripting)
[Halo in 60 FPS - Halo PC: Development - Open Carnage](https://opencarnage.net/index.php?%2Ftopic%2F6527-halo-in-60-fps)
[Set up metric units in Blender - Halo CE - Open Carnage](https://opencarnage.net/index.php?%2Ftopic%2F8402-set-up-metric-units-in-blender)
[Scale and unit conversions - c20](https://c20.reclaimers.net/general/scale)
[weapon - c20](https://c20.reclaimers.net/h1/tags/object/item/weapon)
[(HEK) Halo Editing Kit for Halo (CE) Custom Edition](https://www.halomaps.org/hce/detail.cfm?fid=411)
[Halo CE: The Xbox Experience - Open Carnage](https://opencarnage.net/index.php?%2Ftopic%2F5784-halo-ce-the-xbox-experience)