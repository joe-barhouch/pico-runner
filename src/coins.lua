-- coins.lua - Coin collection system

Coin = {}
Coin.__index = Coin

function Coin:new(platform)
  local coin = setmetatable({}, Coin)
  coin.platform = platform
  coin.x = platform.x + (platform.width * 8) / 2 - 4 -- Center on platform
  coin.y = platform.y - 10 -- Hover 2 pixels above platform (8 pixel coin + 2 pixel gap)
  coin.base_y = coin.y
  coin.collected = false
  coin.bob_timer = 1 -- Timer for bobbing animation, lower
  coin.bob_speed = 0.05
  coin.bob_amplitude = 2
  coin.sprite = 49
  return coin
end

function Coin:update()
  if self.collected then
    return
  end

  -- Move with platform
  self.x = self.platform.x + (self.platform.width * 8) / 2 - 4
  self.base_y = self.platform.y - 10

  -- Bob animation
  self.bob_timer += self.bob_speed
  self.y = self.base_y + sin(self.bob_timer) * self.bob_amplitude
end

function Coin:draw()
  if not self.collected then
    spr(self.sprite, self.x, self.y)
  end
end

function Coin:is_off_screen()
  return self.platform:is_off_screen()
end

function Coin:collect()
  if not self.collected then
    self.collected = true
    score_coin()
    -- TODO: Play coin collection sound
    -- sfx(SFX_COIN_COLLECT)
    return true
  end
  return false
end

function Coin:get_bounds()
  -- Smaller collision box - 4x4 pixels centered in the 8x8 sprite
  return self.x + 2, self.y + 2, 4, 4
end

-- Global coin management
coins = {}

function init_coins()
  coins = {}
end

function spawn_coin_on_platform(platform)
  -- 40% chance to spawn a coin on a platform
  if rnd(1) < 0.4 then
    local coin = Coin:new(platform)
    add(coins, coin)
    return coin
  end
  return nil
end

function update_coins()
  -- Update existing coins
  for i = #coins, 1, -1 do
    local coin = coins[i]
    coin:update()

    -- Remove coins that are off-screen or collected
    if coin:is_off_screen() or coin.collected then
      del(coins, coin)
    end
  end
end

function draw_coins()
  for coin in all(coins) do
    coin:draw()
  end
end

function check_coin_collection(player_x, player_y, player_w, player_h)
  for coin in all(coins) do
    if not coin.collected then
      local coin_x, coin_y, coin_w, coin_h = coin:get_bounds()

      -- Stricter AABB collision check with smaller coin bounds
      if player_x < coin_x + coin_w and player_x + player_w > coin_x and player_y < coin_y + coin_h and player_y + player_h > coin_y then
        coin:collect()
        return true
      end
    end
  end
  return false
end
