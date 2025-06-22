-- constants.lua

-- Screen dimensions
SCREEN_WIDTH = 128
SCREEN_HEIGHT = 128
SCREEN_CENTER_X = 64
SCREEN_CENTER_Y = 64

-- Player constants
PLAYER_MAX_LIVES = 3
INVINCIBILITY_DURATION = 180 -- 3 seconds at 60fps
RESPAWN_DURATION = 120 -- 2 seconds at 60fps

-- Sound effect IDs
SFX_JUMP = 0
SFX_PLAYER_HIT = 4
SFX_COIN_COLLECT = 1

-- Direction system constants
DIRECTIONS = {
  RIGHT_TO_LEFT = 0,
  UP_TO_DOWN = 1,
  LEFT_TO_RIGHT = 2,
  DOWN_TO_UP = 3,
}

-- Coins to get per direction change
COINS_PER_DIRECTION_CHANGE = 5

-- Platform spawning limits
MAX_PLATFORMS_H = 6 -- Max platforms for horizontal directions
MIN_PLATFORMS_H = 3 -- Min platforms for horizontal directions
MAX_PLATFORMS_V = 8 -- Max platforms for vertical directions
MIN_PLATFORMS_V = 4 -- Min platforms for vertical directions

-- Global flags
DEBUG_MODE = {
  player = false,
  platforms = true,
  collisions = false,
}
