# Change Log: liberty_vehicle_spawner.lua

## [Updated Version] - 14/9/2025

### Major Changes:

1. **Restructured Configuration System**:
    - Split vehicle definitions into `DEFAULT_TAGS` (fallback) and `CUSTOM_TAGS` (map-specific)
    - Added support for multiple custom vehicle variants on specific maps (e.g., bc_raceway_final_mp)

2. **Added New Features**:
    - Periodic announcements system with configurable interval
    - Vehicle meta caching system for improved performance
    - Proper yaw rotation based on player camera direction
    - Enhanced error handling and logging

3. **Improved Vehicle Management**:
    - More robust vehicle tracking using object IDs instead of meta IDs
    - Better cleanup system with proper object destruction on script unload
    - Fixed occupancy detection logic

### Configuration Changes:

- Added `ANNOUNCEMENTS` and `ANNOUNCEMENT_INTERVAL` settings
- Replaced single `map_vehicles` table with dual-configuration system
- Expanded vehicle options for specific maps (e.g., multiple colored hogs on bc_raceway_final_mp)

### Code Improvements:

- Added proper game state management with `game_started` flag
- Implemented `OnEnd` callback for game end events
- Enhanced position calculation with proper camera-based yaw rotation
- Added map name caching for better performance
- Improved error messages with color coding

### Removed Features:

- Removed several map configurations from the previous version (Camtrack-Arena-Race, ciffhanger, dessication_pb1, etc.)
- Simplified configuration to focus on custom map variants

### Bug Fixes:

- Fixed vehicle spawning position calculation
- Resolved issues with vehicle entry after spawning
- Improved error handling for missing vehicle tags
- Fixed timer-based announcement system

### Backward Compatibility:

- Maintains same basic functionality: chat-based vehicle spawning
- Keeps same DESPAWN_DELAY_SECONDS configuration option
- Preserves core vehicle spawning mechanics

---

# Change Log: track_master.lua

## [Updated Version] - 14/9/2025

### Major Changes:

1. **Enhanced Command System**:
    - Completely redesigned `/stats` command with advanced argument parsing
    - Added support for querying stats by player ID, player name, or map name
    - Added flexible syntax: `/stats [player id|name|map] [optional map name]`

2. **Improved `/top5` Command**:
    - Added scope parameter (`global` or `map`)
    - Added optional map name argument for map-specific top 5 queries
    - Restructured output formatting

3. **Refactored Message System**:
    - Updated all message templates in CONFIG.MESSAGES for better clarity
    - Simplified stats display format
    - Improved announcement messages for records and personal bests

### New Features:

1. **Advanced Argument Parsing**:
    - Added `parseArgs()` function to handle complex command inputs
    - Support for mixed parameters (player IDs, names, and map names)

2. **Flexible Stats Querying**:
    - Query own stats on current map: `/stats`
    - Query other player's stats: `/stats <player id|name>`
    - Query stats on specific map: `/stats <map name>`
    - Query other player's stats on specific map: `/stats <player id|name> <map name>`

3. **Enhanced Top 5 System**:
    - Global top 5: `/top5 global`
    - Map-specific top 5: `/top5 map [map name]` (uses current map if omitted)

### Code Improvements:

1. **Better Error Handling**:
    - Added syntax error messages for invalid commands
    - Improved player validation for online/offline queries

2. **Refactored Export Function**:
    - Fixed `exportLapRecords()` to properly format time in export file
    - Added proper map sorting in export file

3. **Optimized Data Structures**:
    - Improved map processing in export function
    - Better handling of player statistics data

### Message Changes:

- **NEW_MAP_RECORD**: Changed from "%s set a new map record with %s!" to "New map record by %s: %s!"
- **PERSONAL_BEST**: Changed from "%s beat their personal best with %s!" to "New personal best for %s: %s"
- **CURRENT_GAME_BEST**: Simplified format
- **ALL_TIME_BEST**: Simplified format
- **STATS display**: Consolidated into simpler format without headers
- **Removed STATS_GLOBAL_HEADER, STATS_BEST_LAP, STATS_AVG_LAP, STATS_MAP_HEADER**

### Backward Compatibility:

- Maintains same core functionality: lap tracking, record keeping, and statistics
- Preserves same data storage format (JSON compatibility)
- Keeps same basic command structure (stats, top5, current)

---

# Change Log: uber.lua

## [Updated Version] - 14/9/2025

### Major Changes:

1. **Added New Feature: Driver-Only Vehicle Immunity**
    - Added `DRIVER_ONLY_IMMUNE` configuration option (default: true)
    - Vehicles with only a driver (no passengers) become immune to damage
    - Added `OnDamageApplication` callback to handle damage immunity logic

2. **Enhanced Vehicle Configuration System**
    - Renamed `VEHICLE_SETTINGS` to `VEHICLES` for consistency
    - Added comprehensive vehicle configurations for many custom maps
    - Added support for tsce_multiplayerv1 map vehicles
    - Expanded bc_raceway_final_mp vehicle variants (multi-colored hogs)
    - Added many additional custom vehicle configurations

3. **Improved Event Handling**
    - Added map-specific vehicle meta caching for better performance
    - Consolidated ejection events into `HandleEjection` function
    - Added proper map name tracking for vehicle configuration

### Configuration Additions:

1. **New Vehicles Added:**
    - tsce_multiplayerv1: Chain Gun Hog and Rocket Hog variants
    - bc_raceway_final_mp: Multiple multi-colored Warthog variants
    - Various other custom map vehicles with proper seat configurations

2. **New Configuration Option:**
    - `DRIVER_ONLY_IMMUNE`: When enabled, vehicles with only a driver are immune to damage

### Code Improvements:

1. **Performance Optimization:**
    - Implemented map-specific vehicle meta caching (`vehicle_meta_cache`)
    - Vehicle configurations are now cached per map instead of reloading every game

2. **Event System Refactor:**
    - Consolidated `OnVehicleExit` and `OnPlayerDeath` into `HandleEjection`
    - Added `OnDamageApplication` event for damage immunity system
    - Updated callback registration system

3. **Memory Management:**
    - Improved vehicle validation with proper memory address handling
    - Enhanced position calculation with better offset handling

### Bug Fixes:

1. **Fixed Vehicle Configuration:**
    - Corrected seat configurations for various custom vehicles
    - Fixed insertion order priorities for multi-seat vehicles
    - Improved vehicle tag path accuracy

2. **Enhanced Error Handling:**
    - Better validation for vehicle object memory
    - Improved player state checking

### Backward Compatibility:

- Maintains all existing functionality and configuration structure
- Preserves same chat commands and user interface
- Compatible with existing vehicle configurations

---