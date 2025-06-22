-- game_manager.lua

GAME_STATES = {STARTING = "starting", PLAYING = "playing", LOSE = "lose"}
game_state = GAME_STATES.STARTING

-- Direction management
current_direction = DIRECTIONS.RIGHT_TO_LEFT

function game_init()
    init_player()
    init_obstacles()
    init_platforms()
    init_coins()
    init_score()
    current_direction = DIRECTIONS.RIGHT_TO_LEFT  -- Reset direction
    game_state = GAME_STATES.STARTING
    -- Center player for start
    player.x = 64
    player.y = 64
    player.vel_y = 0
    player.accel_y = 0
end

function game_update()
    if game_state == GAME_STATES.STARTING then
        -- Player floats in center, waits for input
        player.vel_y = 0
        player.accel_y = 0

        -- Platforms will be moving
        update_platforms()

        -- Start game on any movement input
        if btn(⬅️) or btn(➡️) or btn(⬆️) then
            game_state = GAME_STATES.PLAYING
        end
    elseif game_state == GAME_STATES.PLAYING then
        update_player()
        update_obstacles()
        update_platforms()
        update_coins()
        
        -- Check for direction changes based on coin count
        check_direction_change()
        
        -- Lose if player falls off map
        if player.y > 128 then
            game_state = GAME_STATES.LOSE
        end
    elseif game_state == GAME_STATES.LOSE then
        -- Wait for X to restart
        if btnp(❎) then
            game_init()
        end
    end
end

function game_draw()
    cls()
    -- Draw background
    map(0, 0, 0, 0, 16, 16)
    -- draw_obstacles()
    draw_platforms()
    draw_coins()
    draw_player()
    draw_score()

    if game_state == GAME_STATES.STARTING then
        print("press to start", 28, 60, 7)
    elseif game_state == GAME_STATES.LOSE then
        print("game over", 44, 60, 8)
        print("press x to restart", 28, 68, 7)
        print("platforms: " .. score.platforms ,20, 76, 11)
        print('coins: ' .. score.coins, 20, 84, 14)
    end

    -- Debug flags
end

-- Direction management functions
function check_direction_change()
    -- Calculate what direction we should be in based on coin count
    local target_direction = flr(score.coins / COINS_PER_DIRECTION_CHANGE) % 4
    
    -- Only change if we need to
    if target_direction ~= current_direction then
        current_direction = target_direction
    end
end

function get_current_direction()
    return current_direction
end
