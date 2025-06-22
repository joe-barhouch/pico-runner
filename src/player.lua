-- player.lua

-- Player class definition
Player = {}
Player.__index = Player

function Player:new()
    local self = setmetatable({}, Player)
    self.x = 64
    self.y = 64
    self.speed = 2
    self.flip = false
    self.anim_timer = 0
    self.walk_anim = { 1, 2 }
    self.anim_speed = 5 -- Animation speed in frames, the lower the faster
    self.frame_index = 1
    self.vel_y = 0
    self.accel_y = 0
    self.on_ground = true
    self.jumping = false

    -- Jump tuning parameters
    self.max_height = -16 -- Maximum jump height (negative = up)
    self.gravity = 0.5 -- Gravity acceleration
    self.initial_acceleration = -1.5 -- Initial jump acceleration
    self.alpha = 0.03 -- Deceleration factor for variable jump height

    -- Score counters
    self.score = { coins = 0, enemies = 0, platforms = 0 }

    -- Calculate the alpha value for smooth variable jumps
    calc_alpha(self)
    return self
end

function Player:animate(sprites)
    self.anim_timer += 1
    if self.anim_timer >= self.anim_speed then
        self.anim_timer = 0
        self.frame_index = (self.frame_index % #sprites) + 1
    end
end

function Player:check_platform_collision(goal_x, goal_y)
    -- Use advanced collision detection with provided goal position
    local collision, platform = check_platform_landing(self.x, self.y, goal_x, goal_y, self.vel_y)
    
    -- Store detailed collision debug info
    if collision then
        self.debug_collision_t = collision.t
        self.debug_collision_nx = collision.nx
        self.debug_collision_ny = collision.ny
        return collision.platform_y, collision.platform_speed, collision.ty, platform
    else
        self.debug_collision_t = 0
        self.debug_collision_nx = 0
        self.debug_collision_ny = 0
    end
    
    return nil
end

function Player:move()
    local moving = false
    -- Horizontal movement
    if btn(➡️) then
        self.x += self.speed
        self.flip = false
        moving = true
        self.x = clamp(self.x, 0, 120)
    elseif btn(⬅️) then
        self.x -= self.speed
        self.flip = true
        moving = true
        self.x = clamp(self.x, 0, 120)
    end
    
    -- Check for coin collection
    check_coin_collection(self.x, self.y, 8, 8)

    -- Improved jump handling with variable height
    if btn(⬆️) and self.on_ground then
        self.accel_y = self.initial_acceleration
        self.on_ground = false
        self.jumping = true
    elseif btn(⬆️) and self.jumping then
        -- Variable height: continue adding acceleration while held
        self.accel_y += self.alpha
        if self.accel_y > self.gravity then
            self.accel_y = self.gravity
            self.jumping = false
        end
    else
        -- Not jumping or button released
        self.accel_y = self.gravity
        self.jumping = false
    end

    -- Apply physics
    self.vel_y += self.accel_y
    
    -- Calculate intended movement
    local goal_x = self.x
    local goal_y = self.y + self.vel_y
    
    -- Check for platform collision before moving
    local plat_y, plat_speed, collision_y, platform = self:check_platform_collision(goal_x, goal_y)
    
    -- Store debug info
    self.debug_plat_y = plat_y or 0
    self._collision_y = collision_y or 0
    self._goal_y = goal_y
    
    -- Track previous ground state for landing detection
    local was_on_ground = self.on_ground
    
    if plat_y then
        -- Land on platform - always use platform top minus player height
        self.y = plat_y - 8
        self.vel_y = 0
        self.on_ground = true
        
        -- Score platform if this is a new landing
        if not was_on_ground and platform then
            score_platform_landing(platform.id)
        end
    else
        -- No collision - apply normal movement
        self.y = goal_y
        self.on_ground = false
    end

    -- Apply platform speed if on one
    if self.on_ground and plat_speed then
        if platform.direction == DIRECTIONS.RIGHT_TO_LEFT then
            self.x -= plat_speed
        elseif platform.direction == DIRECTIONS.LEFT_TO_RIGHT then
            self.x += plat_speed
        elseif platform.direction == DIRECTIONS.UP_TO_DOWN then
            self.y += plat_speed
        elseif platform.direction == DIRECTIONS.DOWN_TO_UP then
            self.y -= plat_speed
        end

        if self.x < 0 then
            self.x = 0
        elseif self.x > 120 then
            self.x = 120
        end
    end


    return moving
end

function Player:update()
    local moving = self:move()

    if moving then
        self:animate(self.walk_anim)
    else
        self.frame_index = 1
        self.anim_timer = 0
    end
end

function Player:draw()
    spr(self.walk_anim[self.frame_index], self.x, self.y, 1, 1, self.flip)
    if DEBUG_MODE.player then
        print("x: " .. self.x .. ", y: " .. self.y, 0, 0, 7)
        print("vel_y: " .. self.vel_y .. ", ground: " .. tostr(self.on_ground), 0, 8, 7)
        print("goal_y: " .. (self._goal_y or 0), 0, 16, 7)
    end
    
    if DEBUG_MODE.collisions and self.debug_collision_t and self.debug_collision_t > 0 then
        print("t: " .. (self.debug_collision_t or 0), 0, 40, 8)
        print("nx: " .. (self.debug_collision_nx or 0) .. ", ny: " .. (self.debug_collision_ny or 0), 0, 48, 8)
    end
end

-- Global player instance
function init_player()
    player = Player:new()
end

function update_player()
    player:update()
end

function draw_player()
    
    player:draw()
end
