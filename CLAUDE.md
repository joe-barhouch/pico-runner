# Pico Runner - Development Guide

## Game Overview

Pico Runner is a dynamic endless runner that evolves as you play. The core innovation is directional cycling - every 10 coins collected, the game shifts movement direction through a 4-phase cycle:
1. **Right-to-Left** (Traditional sidescroller)
2. **Up-to-Down** (Platforms fall from above) 
3. **Left-to-Right** (Reverse horizontal)
4. **Down-to-Up** (Platforms rise from below)

This creates constantly changing challenges that require mastery of all four movement patterns.

## Current Code Architecture

### File Structure
```
main.p8              - Entry point with _init(), _update(), _draw()
src/
├── constants.lua    - Game constants and debug flags
├── utils.lua        - Math utilities and jump physics calculations
├── player.lua       - Player class with movement and collision
├── platforms.lua    - Platform system with spawning and collision
├── obstacles.lua    - Basic enemy system (prototype)
├── collision.lua    - Advanced swept AABB collision system
└── game_manager.lua - Game state management
```

### Current Responsibilities

**main.p8**
- Includes all source files
- Basic game loop delegation
- Sprite and map data

**constants.lua** ✅ Complete
- Screen dimensions and centers
- Player constants (lives, timers)
- Sound effect IDs
- Debug mode flags

**utils.lua** ✅ Complete
- `clamp()` - Value clamping utility
- `distance()` - 2D distance calculation
- Variable jump physics calculations (`calc_alpha`, `calc_y`, `magic`)

**player.lua** ✅ Well Implemented
- `Player` class with comprehensive movement system
- Variable jump height (tap vs hold mechanics)
- Walking animation system
- Basic platform collision detection
- Proper physics with gravity and acceleration

**platforms.lua** 🔧 Currently Working On
- `Platform` class with movement and rendering
- Platform spawning with Y-distance validation - not fully working
- Basic collision detection
- **Issues**: Only basic rectangular platforms, simple spawning algorithm
- **Missing**: Platform types (stairs, jump pads, temporary)

**obstacles.lua** 🚧 Prototype Only
- Basic enemy spawning and movement
- Simple table-based enemies (not classes)
- **Needs**: Complete redesign with proper AI behaviors

**collision.lua** 🔧 Advanced System Available
- Sophisticated swept AABB collision detection
- Handles tunneling prevention
- Provides collision normals and touch points
- **Status**: Not integrated into game yet (contains demo code)

**game_manager.lua** ✅ Basic Implementation
- Three states: STARTING, PLAYING, LOSE
- Simple state transitions
- **Missing**: Direction change system, coin collection

## Development Status

### ✅ Completed Features
- **Player Movement**: Smooth horizontal movement with variable jump physics
- **Advanced Collision System**: Swept AABB collision prevents tunneling while preserving jump-through behavior
- **Complete Scoring System**: Unique platform counting and coin collection with UI display
- **Dynamic Direction System**: 4-direction cycle (right-left, up-down, left-right, down-up) triggered every 5 coins
- **Coin Collection**: Floating coins with bob animation, precise collision detection
- **Platform Spawning**: Direction-based spawning with rate limiting and minimum platform guarantees
- **Game State Management**: Start screen, gameplay, game over states with score display

### 🔧 Current Focus Areas
1. **Platform Spawning Refinement**: Improve spacing logic and spawn distribution for better gameplay flow
2. **Platform Variety**: Add stairs, jump pads, and temporary platforms for gameplay depth
3. **Enemy System**: Needs complete redesign with proper AI behaviors

### 🎯 Next Development Priorities
1. **Platform Spawning Logic Refinement** (Current Priority)
2. **Platform Type Variety** (Phase 2)
3. **Enemy System Redesign** (Phase 3)

## Phase 1: Collision System Integration ✅ COMPLETED

### Problem Solved
Replaced simple AABB collision with advanced swept AABB system that:
- **Prevents Tunneling**: Tests full movement path, not just final position
- **Preserves Jump-Through**: Only collides when falling (vel_y >= 0)
- **Precise Positioning**: Uses exact collision touch points
- **Surface Normals**: Proper collision response direction

### Implementation Details
1. **collision.lua**: Cleaned and integrated `swept_aabb_collision()` function
2. **check_platform_landing()**: Platform-specific collision that preserves jump-through behavior
3. **Player:check_platform_collision()**: Replaced simple AABB with swept collision
4. **Integrated**: Added collision.lua to main.p8 include chain

### Key Features
- **Jump-Through Preserved**: Player can still jump up through platforms
- **No Tunneling**: Fast falls are caught precisely
- **Exact Landing**: Uses consistent platform positioning (plat_y - 8)
- **Debug System**: Comprehensive collision debugging for development
- **Foundation Ready**: System supports advanced platform behaviors

### Final Result
✅ **Collision system working perfectly** - No bouncing, no tunneling, smooth platforming gameplay

## Recent Major Achievements ✅ COMPLETED

### Core Game Systems Implemented
1. **Complete Scoring System**: Platform counting and coin collection with UI
2. **Direction Change Mechanics**: Dynamic 4-direction cycle every 5 coins collected
3. **Advanced Platform Spawning**: 
   - Direction-based spawn positions using screen constants
   - Rate limiting to prevent overload during direction changes
   - Per-direction platform counting (horizontal vs vertical limits)
   - Minimum platform guarantees to prevent player death
   - Position validation with proper spacing (Y-distance for horizontal, X-distance for vertical)

### Direction System Features
- **Smooth Transitions**: Existing platforms continue current direction until natural despawn
- **Gradual Spawning**: New direction platforms appear gradually, no screen flooding
- **Proper Limits**: Different max platforms for horizontal (12) vs vertical (16) directions
- **Survival Safety**: Minimum platform counts (4 horizontal, 6 vertical) ensure player survival

## Current Priority: Platform Spawning Logic Refinement

### Issues to Address
1. **Spacing Optimization**: Fine-tune min_distance values for better platform distribution
2. **Spawn Rate Balancing**: Adjust spawn_delay for optimal platform flow
3. **Validation Efficiency**: Improve position validation algorithms for smoother spawning
4. **Direction Transition Polish**: Enhance direction change smoothness

### Platform Spawning Status
- ✅ **Direction-based spawning** working
- ✅ **Min/max platform limits** enforced  
- ✅ **Position validation** implemented
- ✅ **Rate limiting** prevents overload
- 🔧 **Spacing logic** needs refinement
- 🔧 **Spawn distribution** could be improved

## Phase 2: Platform System Enhancement

### Current Limitations
- Only basic rectangular platforms
- Simple random spawning
- No gameplay variety

### Platform Types to Add

**Normal Platforms** ✅ (Current)
- Basic rectangular landing spots
- 1x1, 2x1, 3x1 sizes

**Stairs Platforms** 🎯
- Multi-level step patterns
- 1, 2, or 3 tile heights
- Allows gradual elevation changes

**Jump Pads** 🎯
- Boost player higher than normal jump
- Visual animation when activated
- Adds verticality to gameplay

**Temporary Platforms** 🎯
- Degrade when player stands on them
- Timer-based destruction
- Forces quick movement decisions

### Implementation Plan
1. **Extend Platform Class**: Add `platform_type` and `behavior` properties
2. **Create Type-Specific Logic**: Different collision responses per type
3. **Add Visual Variety**: Unique sprites for each platform type
4. **Improve Spawning**: Intelligent placement for good gameplay flow
5. **Behavioral Systems**: Jump pad boost, temporary platform decay

### Expected Outcome
- Rich, varied platforming gameplay
- Strategic platform usage
- Visual and mechanical diversity

## Phase 3: Enemy System Redesign

### Current State
Basic prototype with simple movement:
```lua
-- Table-based enemies with basic movement
local new_obstacle = {
    x = 128,
    y = obstacle_y - rnd(40),
    speed = base_speed + rnd(speed_variation * 2) - speed_variation,
    sprite = 5
}
```

### Target Enemy Types

**Flying Missiles** 🎯
- Simple straight-line projectiles
- Spawn from movement direction
- Predictable but fast

**Floating Shooters** 🎯
- Hover in place
- Shoot projectiles at player when in range
- Require timing to avoid

**Platform Walkers** 🎯
- Move along platform surfaces
- Turn around at platform edges
- Can be jumped over

### Implementation Plan
1. **Create Enemy Base Class**: Common properties and behaviors
2. **Implement Each Enemy Type**: Specific AI and movement patterns
3. **Add Projectile System**: For shooter enemies
4. **Collision Integration**: Use advanced collision for all enemy interactions
5. **Balancing**: Adjust spawn rates and behaviors for good difficulty curve

### Expected Outcome
- Engaging enemy variety
- Strategic combat encounters
- Proper AI behaviors

## Technical Notes

### Pico-8 Constraints
- **Resolution**: 128x128 pixels
- **Colors**: 16 color palette
- **Performance**: Target 30fps with 10 platforms + 5 enemies
- **Memory**: Optimize for token and memory limits

### Code Conventions
- **Classes**: Use Lua tables with `__index` metamethod
- **Global Functions**: Prefixed with system name (`init_player`, `update_platforms`)
- **Debug Mode**: Controlled via `DEBUG_MODE` table in constants.lua
- **File Organization**: One system per file, clear separation of concerns

### Key Design Principles
1. **Responsive Controls**: Player input should feel immediate
2. **Fair Gameplay**: No unavoidable damage or impossible situations
3. **Progressive Difficulty**: Start simple, add complexity gradually
4. **Performance First**: Maintain smooth framerate above all else

## Development Workflow

### After Each Feature Completion
1. **Update This Document**: Reflect current state and next priorities
2. **Test Thoroughly**: Verify no regressions
3. **Performance Check**: Ensure smooth gameplay
4. **Plan Next Phase**: Adjust priorities based on results

### Debug Tools Available
- **Player Debug**: Position and state display
- **Platform Debug**: Y-position tracking and count
- **Collision Debug**: Visual collision feedback (in collision.lua)

---

*Last Updated: Completed direction system, scoring, and platform spawning with min/max limits*
*Current Priority: Refine platform spawning logic for better distribution and gameplay flow*
*Next Phase: Add platform variety (stairs, jump pads, temporary) and enemy system redesign*
