-- utils.lua

-- Math utilities
function clamp(value, min_val, max_val)
    if value < min_val then return min_val end
    if value > max_val then return max_val end
    return value
end

function distance(x1, y1, x2, y2)
    local dx = x2 - x1
    local dy = y2 - y1
    return sqrt(dx * dx + dy * dy)
end


-- Calculate the alpha deceleration for variable jump height
function calc_alpha(player)
    local y1 = calc_y(player)
    local t1 = sqrt((6 * y1) / (2 * player.initial_acceleration + player.gravity))
    player.alpha = (player.gravity - player.initial_acceleration) / t1
end

-- Helper function for alpha calculation
function calc_y(player)
    local s = player.max_height
    local e = 0
    local mid, v
    while true do
        mid = 0.5 * (s + e)
        v = magic(mid, player)
        if abs(v) <= 0.01 then
            return mid
        elseif v * magic(s, player) > 0 then
            s = mid
        else
            e = mid
        end
    end
end

-- Magic function for physics calculations
function magic(y, player)
    local a = player.initial_acceleration
    local g = player.gravity
    local h = player.max_height
    local x = sqrt((6 * y) / (2 * a + g))
    local y_val = 2 * sqrt(-2 * (h - y) * g) / (a + g)
    return x + y_val
end
