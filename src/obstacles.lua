-- obstacles.lua

function init_obstacles()
    obstacles = {}
    obstacle_spawn_timer = 0
    obstacle_spawn_delay = 30
    -- Frames between spawns
    max_obstacles = 4
    obstacle_y = 110
    base_speed = 1.5
    speed_variation = 0.5
end

function spawn_obstacle()
    if #obstacles < max_obstacles then
        local new_obstacle = {
            x = 128, -- Start off-screen to the right
            y = obstacle_y - rnd(40),
            speed = base_speed + rnd(speed_variation * 2) - speed_variation,
            sprite = 5
        }
        add(obstacles, new_obstacle)
    end
end

function update_obstacles()
    -- Spawn new obstacles
    obstacle_spawn_timer += 1
    if obstacle_spawn_timer >= obstacle_spawn_delay then
        spawn_obstacle()
        obstacle_spawn_timer = 0
    end

    -- Update existing obstacles
    for i = #obstacles, 1, -1 do
        local obs = obstacles[i]
        obs.x -= obs.speed

        -- Remove obstacles that have moved off-screen to the left
        if obs.x < -8 then
            del(obstacles, obs)
        end
    end
end

function draw_obstacles()
    for obs in all(obstacles) do
        spr(obs.sprite, obs.x, obs.y)
    end
end
