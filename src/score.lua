-- score.lua - Centralized scoring system

-- Global score state
score = {
  platforms = 0,
  coins = 0,
  enemies = 0,
  visited_platforms = {},
}


-- Platform ID counter for unique identification
platform_id_counter = 0

-- Generate unique platform ID
function generate_platform_id()
  platform_id_counter += 1
  return platform_id_counter
end

-- Reset all scores and tracking
function reset_score()
  score.platforms = 0
  score.coins = 0
  score.enemies = 0
  score.visited_platforms = {}
  platform_id_counter = 0
end

-- Check if platform has been visited and increment score if new
function score_platform_landing(platform_id)
  if platform_id and not score.visited_platforms[platform_id] then
    score.visited_platforms[platform_id] = true
    score.platforms += 1
    return true -- New platform scored
  end
  return false -- Already visited
end

-- Add coin to score
function score_coin()
  score.coins += 1
end

-- Add enemy defeat to score
function score_enemy()
  score.enemies += 1
end

-- Get total score (for future use)
function get_total_score()
  return score.platforms * 10 + score.coins * 5 + score.enemies * 25
end

-- Initialize scoring system
function init_score()
  reset_score()
end

-- Draw score display
function draw_score()
  -- Draw platforms counter in top-left
  print("platforms: " .. score.platforms, 2, 2, 11)

  -- Draw other scores if they exist (for future use)
  if score.coins > 0 then
    print("coins: " .. score.coins, 2, 10, 14)
  end
  if score.enemies > 0 then
    print("enemies: " .. score.enemies, 2, 18, 8)
  end
end

