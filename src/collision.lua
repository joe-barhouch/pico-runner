-- Advanced swept AABB collision detection
-- Returns: t (time of collision), nx,ny (collision normal), tx,ty (touch point), intersect (already overlapping)
function swept_aabb_collision(x1, y1, w1, h1, x2, y2, w2, h2, goalx, goaly)
  -- minkowsky difference between 2 aabbs, which is another aabb
  local x, y, w, h = x2 - x1 - w1, y2 - y1 - h1, w1 + w2, h1 + h2
  local dx, dy = goalx - x1, goaly - y1

  local t, nx, ny, tx, ty
  -- if diff contains point 0,0, there's intersection between first and second aabb
  local intersect = x < 0 and x + w > 0 and y < 0 and y + h > 0

  -- degenerate case: intersecting and not moving - use minimum displacement vector
  -- which is the nearest corner to 0,0 in the minkowsky diff
  if intersect and dx == 0 and dy == 0 then
    local px = abs(x) < abs(x + w) and x or x + w -- abs(x) can be bigger than abs(x+w)
    local py = abs(y) < abs(y + h) and y or y + h
    if abs(px) < abs(py) then
      py = 0
      t = -abs(px) / w
    else
      px = 0
      t = -abs(py) / h
    end
    nx = px > 0 and 1 or px < 0 and -1 or 0
    ny = py > 0 and 1 or py < 0 and -1 or 0
    tx, ty = x1 + px, y1 + py
    return t, nx, ny, tx, ty, true
  end

  -- no intersection, or intersection with movement
  -- calculate the clipping between the minkowsky diff aabb with the displacement vector dx,dy
  -- this is a modified version of the liang-barky line-clipping algorithm with normals added
  local t1, t2 = -32768, 32767 -- -huge,+huge
  local nx1, ny1, nx2, ny2 = 0, 0, 0, 0
  local p, q, r

  for side = 1, 4 do
    if side == 1 then
      nx, ny, p, q = -1, 0, -dx, -x -- left
    elseif side == 2 then
      nx, ny, p, q = 1, 0, dx, x + w -- right
    elseif side == 3 then
      nx, ny, p, q = 0, -1, -dy, -y -- top
    else
      nx, ny, p, q = 0, 1, dy, y + h -- bottom
    end

    if p == 0 then
      if q <= 0 then
        return nil
      end
    else
      r = q / p
      if p < 0 then
        if r > t2 then
          return nil
        elseif r > t1 then
          t1, nx1, ny1 = r, nx, ny
        end
      else
        if r < t1 then
          return nil
        elseif r < t2 then
          t2, nx2, ny2 = r, nx, ny
        end
      end
    end
  end

  if intersect then
    -- aabb1 goes though aabb2, in the direction (forwards or backwards)
    -- select the smallest displacement
    if abs(t1) <= abs(t2) then
      t, nx, ny = t1, nx1, ny1
    else
      t, nx, ny = t2, nx2, ny2
    end
  elseif 0 <= t1 and t1 <= 1 then
    t, nx, ny = t1, nx1, ny1
  else
    return nil
  end

  -- x1+dx*t alone will be inaccurate because of floating point
  -- use a more direct number for the "touch points" when possible
  tx = nx < 0 and x2 - w1 or nx > 0 and x2 + w2 or x1 + dx * t
  ty = ny < 0 and y2 - h1 or ny > 0 and y2 + h2 or y1 + dy * t

  return t, nx, ny, tx, ty, intersect
end

-- Platform-specific collision function that preserves jump-through behavior
-- Only checks collision when player is falling (vel_y >= 0)
function check_platform_landing(player_x, player_y, goal_x, goal_y, vel_y)
  -- Only check collision if player is falling or moving down
  if vel_y < 0 then
    return nil
  end

  local player_w, player_h = 8, 8
  local earliest_collision = nil
  local collision_platform = nil

  for plat in all(PlatformManager.platforms) do
    local t, nx, ny, tx, ty, intersect = swept_aabb_collision(player_x, player_y, player_w, player_h, plat.x, plat.y, plat.width * 8, 8, goal_x, goal_y)

    -- Only consider top surface collisions (normal pointing up)
    if t and ny < 0 and (not earliest_collision or t < earliest_collision.t) then
      earliest_collision = {
        t = t,
        nx = nx,
        ny = ny,
        tx = tx,
        ty = ty,
        intersect = intersect,
        platform_y = plat.y,
        platform_speed = plat.speed,
      }
      collision_platform = plat
    end
  end

  return earliest_collision, collision_platform
end
