-- runner/src/platforms.lua - v3 (Timer & Robust Slot System)

Platform = {}
Platform.__index = Platform

-- Table to encapsulate manager state
PlatformManager = {}

-- The `new` function now takes a slot_index to guarantee its position
function Platform:new(x, y, speed, sprite, width, direction, slot_index)
  local platform = setmetatable({}, Platform)
  platform.x = x
  platform.y = y
  platform.speed = speed or 2
  platform.sprite = sprite or 7
  platform.width = width or 8
  platform.direction = direction or DIRECTIONS.RIGHT_TO_LEFT
  platform.id = generate_platform_id() -- Unique identifier for scoring
  platform.slot_index = slot_index -- Crucial for releasing the slot later
  return platform
end

function Platform:update()
  -- Move based on platform's direction
  if self.direction == DIRECTIONS.RIGHT_TO_LEFT then
    self.x -= self.speed
  elseif self.direction == DIRECTIONS.UP_TO_DOWN then
    self.y += self.speed
  elseif self.direction == DIRECTIONS.LEFT_TO_RIGHT then
    self.x += self.speed
  elseif self.direction == DIRECTIONS.DOWN_TO_UP then
    self.y -= self.speed
  end
end

function Platform:draw()
  -- Draw the platform as a row of sprites
  for i = 0, self.width - 1 do
    spr(self.sprite, self.x + i * 8, self.y)
  end
end

function Platform:is_off_screen()
  -- Check if platform has moved off screen
  if self.direction == DIRECTIONS.RIGHT_TO_LEFT then
    return self.x < -self.width * 8
  elseif self.direction == DIRECTIONS.UP_TO_DOWN then
    return self.y > SCREEN_HEIGHT
  elseif self.direction == DIRECTIONS.LEFT_TO_RIGHT then
    return self.x > SCREEN_WIDTH
  elseif self.direction == DIRECTIONS.DOWN_TO_UP then
    return self.y < -8
  end
  return false
end

-- ======================================================
-- Platform Manager V3: Timer & Robust Slot-Based System
-- ======================================================

function init_platforms()
  PlatformManager.platform_base_speed = 0.5
  PlatformManager.platforms = {}
  PlatformManager.plat_widths = { 2, 3, 4 }

  -- Timer-based spawning
  PlatformManager.spawn_timer = 0
  PlatformManager.spawn_delay = 30 -- frames

  -- Simplified Slot System Setup
  PlatformManager.min_distance = 24

  -- Create lists of *available* slot indices
  PlatformManager.y_free_slots = {}
  local num_y_slots = flr((SCREEN_HEIGHT - 32) / PlatformManager.min_distance)
  for i = 1, num_y_slots do
    add(PlatformManager.y_free_slots, i)
  end

  PlatformManager.x_free_slots = {}
  local num_x_slots = flr((SCREEN_WIDTH - 32) / PlatformManager.min_distance)
  for i = 1, num_x_slots do
    add(PlatformManager.x_free_slots, i)
  end
end

-- Gets a slot by *removing* it from the list of available slots. Guaranteed unique.
function get_free_slot(is_horizontal)
  local free_slots = is_horizontal and PlatformManager.y_free_slots or PlatformManager.x_free_slots
  if #free_slots == 0 then
    return nil
  end

  local table_index = flr(rnd(#free_slots)) + 1
  -- deli() removes the item at table_index and returns its value (the slot number)
  local slot_index = deli(free_slots, table_index)
  return slot_index
end

-- Releases a slot by *adding* its index back to the list of available slots.
function release_slot(platform)
  local is_horizontal = platform.direction == DIRECTIONS.RIGHT_TO_LEFT or platform.direction == DIRECTIONS.LEFT_TO_RIGHT
  local free_slots = is_horizontal and PlatformManager.y_free_slots or PlatformManager.x_free_slots

  -- Only release if the platform had a valid slot
  if platform.slot_index then
    add(free_slots, platform.slot_index)
  end
end

function spawn_platform()
  local direction = get_current_direction()
  local is_horizontal = direction == DIRECTIONS.RIGHT_TO_LEFT or direction == DIRECTIONS.LEFT_TO_RIGHT

  -- Set limits based on direction
  local min_platforms = is_horizontal and MIN_PLATFORMS_H or MIN_PLATFORMS_V
  local max_platforms = is_horizontal and MAX_PLATFORMS_H or MAX_PLATFORMS_V

  -- CORE FIX 1: Count only platforms of the CURRENT direction
  local current_direction_platforms = 0
  for plat in all(PlatformManager.platforms) do
    if plat.direction == direction then
      current_direction_platforms += 1
    end
  end

  -- Determine if we should attempt to spawn
  local should_spawn = false
  if current_direction_platforms < min_platforms then
    -- SAFETY NET: If below minimum, always try to spawn to fill the screen
    should_spawn = true
  else
    -- TIMER: If at or above minimum, use the timer for steady spawning
    PlatformManager.spawn_timer += 1
    if PlatformManager.spawn_timer >= PlatformManager.spawn_delay then
      should_spawn = true
      PlatformManager.spawn_timer = 0
    end
  end

  -- Exit if we don't need to spawn or are at max capacity
  if not should_spawn or current_direction_platforms >= max_platforms then
    return
  end

  -- CORE FIX 2: Get a guaranteed unique, free slot
  local slot_index = get_free_slot(is_horizontal)
  if not slot_index then
    return
  end -- No free slots, can't spawn right now

  local plat_width = rnd(PlatformManager.plat_widths)
  local speed = PlatformManager.platform_base_speed + rnd(0.5)
  local x, y

  -- Calculate position from the slot index, guaranteeing no overlap
  if is_horizontal then
    y = 16 + slot_index * PlatformManager.min_distance
    x = (direction == DIRECTIONS.RIGHT_TO_LEFT) and SCREEN_WIDTH + 8 or - (plat_width * 8)
  else -- Vertical
    x = 16 + slot_index * PlatformManager.min_distance
    x = clamp(x, 0, SCREEN_WIDTH - plat_width * 8)
    y = (direction == DIRECTIONS.UP_TO_DOWN) and -16 or SCREEN_HEIGHT + 8
  end

  local new_platform = Platform:new(x, y, speed, 7, plat_width, direction, slot_index)
  add(PlatformManager.platforms, new_platform)

  spawn_coin_on_platform(new_platform)
end

function update_platforms()
  -- Spawn new platforms using the new robust system
  spawn_platform()

  -- Update existing platforms
  for i = #PlatformManager.platforms, 1, -1 do
    local plat = PlatformManager.platforms[i]
    plat:update()

    if plat:is_off_screen() then
      -- CRUCIAL: Release the slot before deleting the platform
      release_slot(plat)
      del(PlatformManager.platforms, plat)
    end
  end
end

-- Remove platforms that don't match the given direction
function cleanup_platforms(new_direction)
  for i = #PlatformManager.platforms, 1, -1 do
    local plat = PlatformManager.platforms[i]
    if plat.direction ~= new_direction then
      release_slot(plat)
      del(PlatformManager.platforms, plat)
    end
  end
  PlatformManager.spawn_timer = 0
end

function draw_platforms()
  for plat in all(PlatformManager.platforms) do
    plat:draw()
  end
end
